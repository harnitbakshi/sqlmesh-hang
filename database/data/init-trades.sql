create schema if not exists schema1;

create table if not exists schema1.ord_hist (
    db_timestamp timestamp,
    timestamp timestamp,
    order_id varchar(255),
    exchange_order_id varchar(255),
    order_version int,
    order_timestamp timestamp,
    inst_type  varchar(255),
    exchange_code varchar(255)
);

create index ord_hist_idx_2
    on schema1.ord_hist (timestamp);
create index ord_hist_idx_3
    on schema1.ord_hist (db_timestamp);
create index ord_hist_idx_4
    on schema1.ord_hist (inst_type);
create index ord_hist_idx_5
    on schema1.ord_hist (exchange_code);
create index ord_hist_idx_6
    on schema1.ord_hist (order_timestamp);

create table if not exists schema1.trd_hist (
    db_timestamp timestamp,
    timestamp timestamp,
    trade_date_utc date,
    trade_id varchar(255),
    trade_version int,
    trade_part_index int,
    exchange_trade_id varchar(255),
    order_id varchar(255)
);

copy schema1.ord_hist from '/docker-entrypoint-initdb.d/ord_hist.csv' delimiter ',' csv header null '';
copy schema1.trd_hist from '/docker-entrypoint-initdb.d/trd_hist.csv' delimiter ',' csv header null '';
