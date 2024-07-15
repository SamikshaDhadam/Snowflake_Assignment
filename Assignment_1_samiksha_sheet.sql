----warehouse

create or replace WAREHOUSE IMPORT_WH
with 
warehouse_size = 'MEDIUM'
auto_suspend = 300
initially_suspended = true;

create WAREHOUSE TRANSFORM_WH
with 
warehouse_size = 'MEDIUM'
auto_suspend = 300
initially_suspended = true;

create WAREHOUSE REPORTING_WH
with 
warehouse_size = 'small',
auto_suspend = 900,
min_cluster_count = 1,
max_cluster_count = 5,
Scaling_Policy = 'standard'
initially_suspended = true;

------------------------Database-------------------------------

create or replace database STAGING;

create or replace database PROD;

--------------------------Schema--------------------------------

create or replace schema STAGING.RAW
data_retention_time_in_days = 3;

create or replace schema STAGING.CLEAN
data_retention_time_in_days = 3;


create or replace schema PROD.REPORTING
data_retention_time_in_days = 90;


-------------------------Rolr------------------------------------
USE ROLE SECURITYADMIN;
create or replace role IMPORT_ROLE;


grant usage on warehouse IMPORT_WH to role IMPORT_ROLE ;

---create or replace stage STAGING_SOURCE;

USE ROLE SECURITYADMIN;

---grant usage on stage staging.public.STAGING_SOURCE to role IMPORT_ROLE;

grant all privileges on all tables in schema staging.RAW to role IMPORT_ROLE;

grant all privileges on all tables in schema staging.CLEAN to role IMPORT_ROLE;


create or replace role TRANSFORM_ROLE;

grant usage on warehouse TRANSFORM_WH to role TRANSFORM_ROLE;

grant usage on database STAGING to role TRANSFORM_ROLE;

grant all privileges on all tables in schema STAGING.CLEAN to role TRANSFORM_ROLE ;

grant all privileges on all tables in schema PROD.REPORTING to role TRANSFORM_ROLE;



create or replace role  REPORTING_ROLE;

grant usage on warehouse REPORTING_WH to role REPORTING_ROLE;

grant usage on database PROD to role REPORTING_ROLE ;


-------------------------Users-------------------------------------------

CREATE USER UserReporting PASSWORD='password123' MUST_CHANGE_PASSWORD = TRUE;

grant role REPORTING_ROLE to user UserReporting;


CREATE USER UserTransform PASSWORD='password123' MUST_CHANGE_PASSWORD = TRUE;

grant role TRANSFORM_ROLE to user UserTransform;


CREATE USER UserImport PASSWORD='password123' MUST_CHANGE_PASSWORD = TRUE;

grant role IMPORT_ROLE to user UserImport;



-----------------------Monitor-----------------------------------
use role accountadmin;
create or replace resource monitor IMPORT_MONITOR with credit_quota = 100 
FREQUENCY = MONTHLY
start_timestamp = IMMEDIATELY;


create or replace resource monitor TRANSFORM_MONITOR with credit_quota = 100 
FREQUENCY = MONTHLY
start_timestamp = IMMEDIATELY;

create or replace resource monitor REPORTING_MONITOR with credit_quota = 100 
FREQUENCY = MONTHLY
start_timestamp = IMMEDIATELY;


SHOW RESOURCE MONITORS;

SHOW Schemas;

SHOW ROLES;

SHOW USERS;


