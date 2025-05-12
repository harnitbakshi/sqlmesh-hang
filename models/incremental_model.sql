MODEL (
  name sqlmesh_example.incremental_model,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column (db_timestamp, '%YYYY-%MM-%DD %HH24:%MI:%SS'),
    batch_size 1,
    batch_concurrency 1
  ),
  start '2025-03-03',
  grains [source, db_timestamp, order_id, trade_id, exchange_order_id],
  interval_unit 'five_minute'
);

SELECT
 'SRC1' as source,
 trade.db_timestamp,
 trade.trade_id,
 trade.exchange_trade_id,
-- coalesce(trade.exchange_trade_id),
 ord.order_id,
 ord.exchange_order_id
-- , coalesce(ord.exchange_order_id)
from
  (select * from (select * from schema1.trd_hist th
    where th.trade_version = (select max(trade_version) from schema1.trd_hist as th1 where th.trade_id = th1.trade_id
    and th.trade_part_index = th1.trade_part_index)
    and th.db_timestamp between @start_ts and @end_ts) as maxversion
    where maxversion.db_timestamp = (select max(db_timestamp) from schema1.trd_hist as th2
                                       where th2.db_timestamp between @start_ts and @end_ts
                                            and th2.trade_version = maxversion.trade_version
                                            and th2.trade_id = maxversion.trade_id
                                            and th2.trade_date_utc = maxversion.trade_date_utc)) as trade
  left join (select * from
                schema1.ord_hist oh where oh.db_timestamp = (select max(oh1.db_timestamp)
                from schema1.ord_hist oh1
                where oh1.order_id = oh.order_id)
                and oh.db_timestamp between @start_ts and @end_ts) as ord
  on
    trade.order_id = ord.order_id
WHERE
  trade.db_timestamp BETWEEN @start_ts AND @end_ts;

@IF(
    @runtime_stage='creating',
    ALTER TABLE @this_model ADD PRIMARY KEY (source, db_timestamp, order_id, trade_id, exchange_order_id, exchange_trade_id)
);


