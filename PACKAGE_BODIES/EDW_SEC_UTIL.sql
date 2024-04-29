--------------------------------------------------------
--  DDL for Package Body EDW_SEC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SEC_UTIL" as
/* $Header: EDWSUTLB.pls 115.5 2002/12/06 02:57:37 tiwang noship $*/

-- This procedure refreshes security metadata tables from owb repository

PROCEDURE refresh_sec_metadata(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2) IS

  v_Errorcode			number;
  v_ErrorText			varchar2(200);

  g_conc_program_id		number;

  x_object_name                 varchar2(50) := 'EDW_SEC_UTIL.REFRESH_SEC_METADATA';
  x_object_type                 varchar2(30) := 'Security Procedure';

  x_message			varchar2(2000);

BEGIN

Errbuf := NULL;
Retcode := 0;

g_conc_program_id := FND_GLOBAL.conc_request_id;


-- Call procedure to refresh EDW metadata tables

	 edw_metadata_refresh.refresh_metadata_tables(Errbuf ,retcode);

-- First delete data from tables

delete from edw_sec_dim_info_t;
delete from edw_sec_fact_info_t;
delete from edw_sec_lvl_info_t;
delete from edw_sec_itemset_info_t;


-- Now populate tables from owb repository views

insert into edw_sec_dim_info_t
(dim_id,
dim_name,
dim_long_name,
table_name,
lowest_level_col_name,
context_name)
select
dim_id,
dim_name,
dim_long_name,
table_name,
lowest_level_col_name,
context_name
from edw_sec_dim_info_v;

insert into edw_sec_fact_info_t
(fact_id,
fact_name,
fact_long_name,
dim_id,
fk_col_name)
select
fact_id,
fact_name,
fact_long_name,
dim_id,
fk_col_name
from edw_sec_fact_info_v;

insert into edw_sec_lvl_info_t
(dim_id,
level_id,
level_name,
level_long_name,
star_level_name_col_name)
select
dim_id,
level_id,
level_name,
level_long_name,
star_level_name_col_name
from edw_sec_lvl_info_v;

insert into edw_sec_itemset_info_t
(fact_id,
fact_name,
fact_long_name,
itemset_name,
fk_col_name)
select
fact_id,
fact_name,
fact_long_name,
itemset_name,
fk_col_name
from edw_sec_itemset_info_v;

COMMIT;


-- Call procedure to upgrade EDW security access setup data

	 edw_sec_util.upgrade_sec_access_data;



EXCEPTION

  WHEN OTHERS THEN

	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message

        x_message :=   'Oracle error occured.
                        Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;


        edw_sec_util.log_error(x_object_name, x_object_type, null, g_conc_program_id, x_message);

        Errbuf := v_ErrorText;
        Retcode := SQLCODE;


END refresh_sec_metadata;



PROCEDURE log_error(x_object_name varchar2, x_object_type varchar2, x_resp_id number, x_conc_id number, x_message varchar2) IS

BEGIN

--      Log error message into edw_error_log table

        insert into edw_error_log
        (object_name, object_type, resp_id, concurrent_id, message,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login)
        values
        (x_object_name, x_object_type, x_resp_id, x_conc_id, x_message,
        sysdate, 0, sysdate, 0, 0);
        commit;

EXCEPTION

-- What do we do if error logging fails ..??
-- If we raise,it may go into infinite loop as outer procedure will again try to log error

	WHEN OTHERS THEN
		null;

END log_error;


PROCEDURE upgrade_sec_access_data IS

-- This procedure upgrades data in security access table(edw_sec_dim_access)

  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);

--  g_conc_program_id             number;

  x_object_name                 varchar2(50) := 'EDW_SEC_UTIL.UPGRADE_SEC_ACCESS_DATA';
  x_object_type                 varchar2(30) := 'Security Procedure';

  x_message                     varchar2(2000);

  x_dim_id			edw_sec_dim_access.dim_id%TYPE;
  x_level_id			edw_sec_dim_access.level_id%TYPE;


cursor dim_cursor is
select distinct dim_short_name from edw_sec_dim_access edw
where dim_id <>
(
select
dim.dim_id
from
edw_sec_dim_info_t dim
WHERE
edw.dim_short_name = dim.dim_name
)
;
cursor level_cursor is
select distinct level_short_name from edw_sec_dim_access edw
where level_id <>
(select
lvl.level_id
from
edw_sec_lvl_info_t lvl
WHERE
edw.level_short_name = lvl.level_name
and edw.dim_id = lvl.dim_id
);


  dim_rec        dim_cursor%ROWTYPE;
  level_rec      level_cursor%ROWTYPE;



BEGIN


  FOR dim_rec IN dim_cursor LOOP

        select dim_id into x_dim_id
        from edw_sec_dim_info_v
        where dim_name = dim_rec.dim_short_name;

        update edw_sec_dim_access
        set dim_id = x_dim_id
        where dim_short_name = dim_rec.dim_short_name;

  END LOOP;



  FOR level_rec IN level_cursor LOOP

	select level_id into x_level_id
	from edw_sec_lvl_info_v
	where level_name = level_rec.level_short_name;

	update edw_sec_dim_access
	set level_id = x_level_id
	where level_short_name = level_rec.level_short_name;

  END LOOP;

COMMIT;

EXCEPTION

  WHEN OTHERS THEN

        v_ErrorCode := SQLCODE;
        v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message

        x_message :=   'Oracle error occured.
                        Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;


        edw_sec_util.log_error(x_object_name, x_object_type, null, null, x_message);

	RAISE;

END upgrade_sec_access_data;





END edw_sec_util;

/
