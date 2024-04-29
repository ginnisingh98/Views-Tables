--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RUNNING_TOTAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RUNNING_TOTAL_PVT" AS
/* $Header: amslrutb.pls 120.7.12010000.3 2009/03/05 05:45:08 hbandi ship $*/
-- Start of Comments
--
-- NAME
--   AMS_List_running_total_pvt
--
-- PURPOSE
--   This package calculates the running totals
--
--   Procedures:
--
--
-- NOTES
--
--
-- HISTORY
--   10/29/2003 usingh created
-- End of Comments

PROCEDURE gen_constant_filter (
                            x_filter_sql    IN OUT NOCOPY      VARCHAR2,
                            x_string_params IN OUT NOCOPY sql_string_4k,
                            x_num_params    IN OUT NOCOPY        NUMBER,
                            p_template_id   IN   NUMBER
                            );

--  -----------------------------------------------
--  hbandi added this procedure for resolving the bug #8221231

PROCEDURE parse_db_version(
			db_version_major OUT NOCOPY NUMBER,
		        db_version_minor OUT NOCOPY NUMBER
				)
IS
BEGIN
   SELECT to_number(SUBSTR(version_text, 1, instr(version_text, '|') -1) ),
    to_number( SUBSTR(version_text, instr(version_text, '|')         + 1) )
     INTO db_version_major,
      db_version_minor
     FROM
    (SELECT SUBSTR(REPLACE(REPLACE(version, '.', '|'), ',', '|'), 1, instr(REPLACE(REPLACE(version, '.', '|'), ',', '|'), '|', 1, 2) -1) version_text
       FROM v$instance
    );

END parse_db_version;
--  -----------------------------------------------

PROCEDURE calculate_running_totals(
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            p_template_id                  NUMBER
                            )  IS
l_request_id              number;
l_return_status           VARCHAR2(1);
l_profile_value           VARCHAR2(30);
l_fnd_return              boolean;
l_application_short_name  VARCHAR2(200);
l_status_AppInfo          varchar2(1);
l_industry_AppInfo        varchar2(1);
l_ams_schema              VARCHAR2(200);
l_drop_string             VARCHAR2(32767);
l_owner                   VARCHAR2(30);
l_view_name               VARCHAR2(200);

cursor c_view_exists(c_view_name VARCHAR2) is
  select owner from sys.all_tables
  where table_name = c_view_name;

BEGIN
        IF NVL(FND_PROFILE.VALUE('AMS_ENABLE_RECALC_AND_PREVIEW'), 'N') = 'Y'
        THEN
            l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                        application => 'AMS',
                        program     => 'AMSGMVTP',
                        argument1   => p_template_id);

            IF l_request_id = 0 THEN
              RAISE FND_API.g_exc_unexpected_error;
            end if;

            UPDATE ams_query_template_all
            SET recalc_table_status    = 'IN_PROGRESS',
                mv_available_flag      = 'N',
                request_id             = l_request_id,
                LAST_UPDATE_DATE       = SYSDATE,
                LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN      = FND_GLOBAL.CONC_LOGIN_ID,
                PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID,
                PROGRAM_UPDATE_DATE    = SYSDATE
            WHERE template_id = p_template_id;
        ELSE
            UPDATE ams_query_template_all
            SET recalc_table_status    = 'DRAFT',
                mv_available_flag      = 'N',
                LAST_UPDATE_DATE       = SYSDATE,
                LAST_UPDATED_BY        = FND_GLOBAL.USER_ID
            WHERE template_id = p_template_id;

            l_view_name  := 'AMS_QT_'||to_char(p_template_id)||'_MV';
            open c_view_exists(l_view_name);
            fetch c_view_exists into l_owner;
            close c_view_exists;

            IF l_owner IS NOT NULL THEN
                l_drop_string := 'DROP TABLE '||l_owner||'.'||l_view_name;
                execute immediate l_drop_string;
            END IF;
        END IF;
commit;
   retcode:= 0;
EXCEPTION
 WHEN OTHERS THEN
   errbuf:= substr(SQLERRM,1,254);
   retcode:= 2;
   raise;
end calculate_running_totals;
-- ----------------------------------------------------------
PROCEDURE generate_mv_for_template (
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            p_template_id                  NUMBER
                            ) IS
l_create_string           VARCHAR2(32767);
l_create1_string           VARCHAR2(32767);
l_insert_string           VARCHAR2(32767);
l_select_string           VARCHAR2(32767);
l_from_string             VARCHAR2(32767) := 'FROM';
l_where_string            VARCHAR2(32767) := 'WHERE';
l_policy_where            VARCHAR2(32767);
l_view_name               VARCHAR2(200);
l_attribute_name          VARCHAR2(30);
l_query_alias_id	  NUMBER;
l_q_alias_id		  NUMBER;
-- l_source_object_name      VARCHAR2(30);
l_source_object_name      VARCHAR2(2000);
l_master_flag             VARCHAR2(1);
l_source_pk_field         VARCHAR2(30);
l_comma                   VARCHAR2(1) := ',';
l_total_recs		  NUMBER := 0;
l_total_attributes	  NUMBER := 0;
l_column_alias            VARCHAR2(5);
l_master_field            VARCHAR2(200);
l_child_field             VARCHAR2(200);
l_and                     VARCHAR2(3) := 'AND';
l_total_child    	  NUMBER := 0;
l_index_column            VARCHAR2(30);
l_index_string            VARCHAR2(32767);
l_counter        	  NUMBER := 0;
l_drop_string             VARCHAR2(32767);
l_view_exists             VARCHAR2(1);
l_master_view             VARCHAR2(30);
l_master_total_records    NUMBER;
l_master_string           VARCHAR2(32767);
l_sample                  VARCHAR2(1) := 'N';
l_sample_records	  NUMBER;
l_sample_pct		  NUMBER := 0;
l_master_columns_string   VARCHAR2(32767) ;
l_master_column		  VARCHAR2(30);
l_master_alias		  VARCHAR2(30);
l_policy		  VARCHAR2(30);
l_return_status           VARCHAR2(1);
l_policy_exists           VARCHAR2(1);
l_table_policy_exists	  VARCHAR2(1);
l_no_of_chunks		  Number;
-- l_tmp_string		  VARCHAR2(32767) ;
l_remote_drop_string      VARCHAR2(32767);
l_truncate_string         VARCHAR2(32767);
l_remote_truncate_string  VARCHAR2(32767);

cursor c_attributes is
SELECT  distinct non_variant_value, query_alias_id
  from AMS_QUERY_COND_DISP_STRUCT_vl
where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
  and query_alias_id is not null;

cursor c_total_attributes is
select count(*) from (SELECT  distinct non_variant_value, query_alias_id
  from AMS_QUERY_COND_DISP_STRUCT_vl
where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
  and query_alias_id is not null) total_records;

cursor c_attributes_alias is
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.master_source_type_flag,alias2.source_object_pk_field,
alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id;

cursor c_where_policy is
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.master_source_type_flag,alias2.source_object_pk_field,
alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id
 and alias2.source_object_name like 'HZ_%';

cursor c_tot_attributes_alias is
select count(*) from (
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.master_source_type_flag,alias2.source_object_pk_field,
alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id ) alias_count;

cursor c_Where_clause is
select  types.master_source_type_flag,
decode(master_source_type_flag,'Y','A'||to_char(rownum)||'.'||source_object_pk_field||'  =  ',
'A'||to_char(rownum)||'.'||source_object_pk_field ||'(+)')
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id;

cursor c_total_child is
select count(*) from
 (
 select distinct alias2.query_alias_id,alias2.source_object_name, alias2.master_source_type_flag,alias2.source_object_pk_field,
alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id
) tab3
where master_source_type_flag = 'N';

cursor c_index_columns is
select column_name from sys.all_tab_columns where table_name = l_view_name
and column_name not in (
select flds.source_column_name
from ams_list_src_fields flds ,AMS_QUERY_ALIAS alias,ams_list_src_types types,
     ams_query_template_all qtemp
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.LIST_SOURCE_TYPE_ID = flds.LIST_SOURCE_TYPE_ID
  and types.MASTER_SOURCE_TYPE_FLAG = 'Y'
  and qtemp.template_id = alias.template_id
  and qtemp.list_src_type = types.source_type_code);

cursor c_view_exists is
select 'Y' from sys.all_tables where table_name = l_view_name;

l_synonym_exists	varchar2(1);
cursor c_synonym_exists is
select 'Y' from sys.all_objects
where object_name = l_view_name
and object_type = 'SYNONYM';


cursor c_master_view is
select types.source_object_name
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and types.master_source_type_flag = 'Y'
  and alias.object_name = types.source_type_code;

cursor c_from_clause is
select tab1.query_alias_id,
decode(tab1.master_source_type_flag,'Y',
'( select * from ( select * from '|| tab1.source_object_name||
' order by dbms_random.value ) where rownum <=
(select (count(*) * '|| l_sample_pct ||'/100) from '|| tab1.source_object_name||')  )' ,tab1.source_object_name),
tab1.master_source_type_flag,tab1.source_object_pk_field,
tab1.line_num
from
(
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.master_source_type_flag,alias2.source_object_pk_field,
alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
   and types.list_source_type = 'TARGET'
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id ) tab1;

/*
cursor c_master_columns is
select flds.source_column_name
from ams_list_src_fields flds ,AMS_QUERY_ALIAS alias,ams_list_src_types types,
     ams_query_template_all qtemp
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.LIST_SOURCE_TYPE_ID = flds.LIST_SOURCE_TYPE_ID
  and types.MASTER_SOURCE_TYPE_FLAG = 'Y'
  and qtemp.template_id = alias.template_id
  and qtemp.list_src_type = types.source_type_code;
*/

-- SOLIN, select primary key only to save table space
-- In preview entries, it will join master data source.
cursor c_master_columns is
--select flds.source_column_name
--from ams_list_src_fields flds ,AMS_QUERY_ALIAS alias,ams_list_src_types types,
--     ams_query_template_all qtemp
--where alias.template_id = p_template_id
--  and alias.object_name = types.source_type_code
--  and types.LIST_SOURCE_TYPE_ID = flds.LIST_SOURCE_TYPE_ID
--  and flds.ENABLED_FLAG = 'Y'
--  and flds.USED_IN_LIST_ENTRIES = 'Y'
--  and types.MASTER_SOURCE_TYPE_FLAG = 'Y'
--  and qtemp.template_id = alias.template_id
--  and qtemp.list_src_type = types.source_type_code
--Union
select typ.SOURCE_OBJECT_PK_FIELD
from ams_query_template_all tmp,ams_list_src_types typ
where tmp.template_id = p_template_id
  and tmp.list_src_type = typ.SOURCE_TYPE_CODE;



cursor c_const_where is
select tab2.source_object_name,tab2.list_source_type_id,tab2.master_source_type_flag,tab2.line_num||'.'
from
(
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.master_source_type_flag,alias2.source_object_pk_field,
alias2.line_num, alias2.list_source_type_id
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num,types.list_source_type_id
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id
) tab2;

l_master_lstype_id	number;
l_mst_alias	varchar2(30);
l_child_lstype_id	number;
l_chd_alias	varchar2(30);


cursor c_const_where_cols is
select nvl(assoc.master_source_type_pk_column,types.SOURCE_OBJECT_PK_FIELD ),assoc.sub_source_type_pk_column from
ams_list_src_type_assocs assoc , ams_list_src_types types
where assoc.master_source_type_id = l_master_lstype_id
  and assoc.sub_source_type_id = l_child_lstype_id
  and assoc.master_source_type_id = types.list_source_type_id;

l_mst_col	varchar(60);
l_chd_col	varchar2(60);
x_return_status varchar(1);
x_msg_count	number;
x_msg_data      varchar2(2000);

cursor c_master_pk is
select source_object_pk_field from ams_list_src_types where list_source_type_id = p_template_id;

l_master_pk	varchar2(60);

cursor c_policy_exists is
select 'Y' from sys.dba_policies where object_name like 'HZ%';

cursor c_table_policy_exists is
select 'Y' from sys.dba_policies where object_name = l_source_object_name;

l_tablespace	varchar2(1000);
l_index_tablespace	varchar2(1000);
cursor c_tablespace is
select tablespace,INDEX_TABLESPACE from fnd_product_installations
where application_id = '530';

l_qal_id	number;
l_mastcol_alias varchar2(100);
l_mastobj_name  varchar2(100);
cursor c_find_mast_alias is
select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias, ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id;

cursor c_mast_alias is
select types.LIST_SOURCE_TYPE_ID, types.source_object_name, types.master_source_type_flag,'A'||to_char(rownum)||'.' line_num
from AMS_QUERY_ALIAS alias, ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
  and types.list_source_type = 'TARGET'
order by alias.query_alias_id;


l_filter_sql	VARCHAR2(32767) ;
l_string_params AMS_List_running_total_pvt.sql_string_4k;
l_num_params	number := 0;
TYPE table_char  IS TABLE OF VARCHAR2(200) INDEX  BY BINARY_INTEGER;
l_table_char table_char;
l_string VARCHAR2(32767);
l_where1 VARCHAR2(100) := ' Where rownum < 1 ';
l_where2 VARCHAR2(100) := ' and rownum < 1 ';

l_apps_schema	VARCHAR2(200) ;
cursor c_apps is
select sys_context( 'userenv', 'current_schema' ) "apps_schema" from dual;

-- SOLIN, Bug 3696553
CURSOR c_get_dblink is
  select NVL(types.remote_flag, 'N'), database_link
  from AMS_QUERY_ALIAS alias, ams_list_src_types types
  where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code;

l_remote_flag         VARCHAR2(1);
l_dblink              VARCHAR2(120);
l_null                varchar2(30) := null;
l_create_remote       VARCHAR2(4000);
l_check_table_string  VARCHAR2(500);
l_remote_index_string VARCHAR2(4000);
l_exist               NUMBER;
l_number_of_index     NUMBER;
-- SOLIN, end

l_application_short_name VARCHAR2(200) ;
cursor c_apps_short_name is
select application_short_name from fnd_application where application_id = 530;

l_ams_schema VARCHAR2(200) ;
l_fnd_return                boolean;
l_status_AppInfo            varchar2(1);
l_industry_AppInfo          varchar2(1);
l_create_synonym            varchar2(200);
l_drop_synonym              varchar2(200);
l_remote_create_synonym     varchar2(1000);

  --cursor c_get_db_version is
  -- hbandi replaced the previous query to new query for the  #BUG8221231
  -- select to_number(substr(version, 1, instr(version,'.',1,2)-1)) from v$instance;
  -- select to_number(substr(version, 1, instr(version,'.',1,2)-1),'99.9','NLS_NUMERIC_CHARACTERS = ''.,''') from v$instance;



 -- l_db_version number;
l_sample_size number;
--l_sample_pct number;

l_db_version_major number;
l_db_version_minor number;

l_oders_view_used varchar2(30);
l_number_of_days NUMBER;

begin
Ams_Utility_Pvt.Write_Conc_log('+++++++++++++++++++++Start CM program : AMSGMVTP.+++++++++++++++++++++');
Ams_Utility_Pvt.Write_Conc_log('p_template_id = '||to_char(p_template_id));

-- Update the ams_query_template_all table to set mv_available_flag to N
-- so that list creation UI can grey out Recalc and Preview button
-- while the regeneration process is in progress
   update ams_query_template_all
      set MV_AVAILABLE_FLAG = 'N'
    where TEMPLATE_ID = p_template_id;

   commit;

open c_apps_short_name;
fetch c_apps_short_name into l_application_short_name;
close c_apps_short_name;
Ams_Utility_Pvt.Write_Conc_log('l_application_short_name = '||l_application_short_name);
l_fnd_return := fnd_installation.get_app_info(l_application_short_name,
                                          l_status_AppInfo,
                                          l_industry_AppInfo ,
                                          l_ams_schema);
Ams_Utility_Pvt.Write_Conc_log('l_ams_schema             = '||l_ams_schema);
open c_apps;
fetch c_apps into l_apps_schema;
close c_apps;
Ams_Utility_Pvt.Write_Conc_log('l_apps_schema            = '||l_apps_schema);

open c_tablespace;
fetch c_tablespace into l_tablespace,l_index_tablespace;
close c_tablespace;
Ams_Utility_Pvt.Write_Conc_log('l_tablespace             = '||l_tablespace);
Ams_Utility_Pvt.Write_Conc_log('l_index_tablespace       = '||l_index_tablespace);

-- View Name
-- ---------
   l_view_name  := 'AMS_QT_'||to_char(p_template_id)||'_MV';
Ams_Utility_Pvt.Write_Conc_log('l_view_name = '||l_view_name);

-- SOLIN, Bug 3696553
OPEN c_get_dblink;
FETCH c_get_dblink INTO l_remote_flag, l_dblink;
CLOSE c_get_dblink;

-- -----------------------------------------
-- hbandi calling this procedure for resolving the BUG #8221231(Database version issue)

parse_db_version(
                db_version_major => l_db_version_major  ,
                db_version_minor => l_db_version_minor
                );

-- -----------------------------------------

-- Get Database version ----aanjaria
-- OPEN c_get_db_version;
-- FETCH c_get_db_version INTO l_db_version;
-- CLOSE c_get_db_version;
-- Ams_Utility_Pvt.Write_Conc_log('Database version = '||to_char(l_db_version));

IF l_remote_flag = 'N'
THEN
-- SOLIN, end
   l_create_string := ' CREATE TABLE '||l_ams_schema||'.'||l_view_name||' PCTFREE 0 TABLESPACE '||l_tablespace||' STORAGE (INITIAL 16k NEXT 10M PCTINCREASE 0 MAXEXTENTS UNLIMITED ) NOLOGGING ';
-- SOLIN, Bug 3696553
ELSE
   l_create_string := ' CREATE TABLE ' ||l_view_name;
   l_remote_create_synonym := 'CREATE PUBLIC SYNONYM '||l_view_name||' FOR '||l_view_name||'@'||l_dblink;
   Ams_Utility_Pvt.Write_Conc_log('l_remote_create_synonym = '||l_remote_create_synonym);
   l_remote_drop_string := 'DROP TABLE '||l_ams_schema||'.'||l_view_name;
   Ams_Utility_Pvt.Write_Conc_log('l_remote_drop_string = '||l_remote_drop_string);
   l_remote_truncate_string := 'TRUNCATE TABLE '||l_view_name;
   Ams_Utility_Pvt.Write_Conc_log('l_remote_truncate_string = '||l_remote_truncate_string);
END IF;
-- SOLIN, end

-- If database version 9.2 or higher then use TABLE COMPRESSION feature --aanjaria

-- -------------------------------------------------------
--  hbandi added these statements for resolving the BUG #8221231(Database version issue)

IF l_db_version_major < 9 THEN
	l_create_string := l_create_string || ' AS SELECT ';
        l_insert_string := ' INSERT INTO '||l_view_name||' SELECT ';
END IF;

IF l_db_version_major = 9 THEN
   IF l_db_version_minor >= 2 THEN
	l_create_string := l_create_string || ' COMPRESS AS SELECT ';
        l_insert_string := ' INSERT /*+ APPEND */ INTO  '||l_view_name||' SELECT ';
   ELSE
	 l_create_string := l_create_string || ' AS SELECT ';
         l_insert_string := ' INSERT INTO  '||l_view_name||' SELECT ';
   END IF;
END IF;

IF l_db_version_major >= 10 THEN
	 l_create_string := l_create_string || ' COMPRESS AS SELECT ';
         l_insert_string := ' INSERT /*+ APPEND */ INTO  '||l_view_name||' SELECT ';
END IF;

Ams_Utility_Pvt.Write_Conc_log('Database version = '||to_char(l_db_version_major)||'.'||to_char(l_db_version_minor));
-- -------------------------------------------------------

-- hbandi commented these statements
-- IF l_db_version >= 9.2 THEN
-- l_create_string := l_create_string || ' COMPRESS AS SELECT ';
-- l_insert_string := ' INSERT /*+ APPEND */ INTO  '||l_view_name||' SELECT ';
-- ELSE
-- l_create_string := l_create_string || ' AS SELECT ';
-- l_insert_string := ' INSERT INTO  '||l_view_name||' SELECT ';
-- END IF;
-- end of hbandi comments

Ams_Utility_Pvt.Write_Conc_log('l_create_string = '||l_create_string);
Ams_Utility_Pvt.Write_Conc_log('l_insert_string = '||l_insert_string);
l_create_synonym := 'CREATE PUBLIC SYNONYM '||l_view_name||' FOR '||l_ams_schema||'.'||l_view_name;
l_drop_synonym  := 'DROP PUBLIC SYNONYM '||l_view_name;
Ams_Utility_Pvt.Write_Conc_log('l_create_synonym = '||l_create_synonym);
Ams_Utility_Pvt.Write_Conc_log('l_drop_synonym = '||l_drop_synonym);
   open c_master_view;
   fetch c_master_view into l_master_view;
   close c_master_view;
/*
   open c_policy_exists;
   fetch c_policy_exists into l_policy_exists;
   close c_policy_exists;
Ams_Utility_Pvt.Write_Conc_log('l_policy_exists  : '||l_policy_exists);
*/
Ams_Utility_Pvt.Write_Conc_log('QT Table cretion started for view : '||l_view_name);
-- Get the records in the master data source view
-- ----------------------------------------------
-- SOLIN, Bug 3696553
IF l_remote_flag = 'N'
THEN
-- SOLIN, end
   l_master_string := 'begin select count(*) into :l_master_total_records from '||l_master_view||' ;end;';
-- SOLIN, Bug 3696553
ELSE
   l_master_string := 'begin select count(*) into :l_master_total_records from '||l_master_view||'@'||l_dblink||' ;end;';
END IF;
-- SOLIN, end
   execute immediate l_master_string using OUT l_master_total_records;
   open c_total_attributes;
   fetch c_total_attributes into l_total_attributes;
   close c_total_attributes;

--Get values from profiles
l_sample_size := FND_PROFILE.VALUE('AMS_LIST_QT_SAMPLE_SIZE');
-- batoleti Bug# 4684584  the 'AMS_LIST_QT_SAMPLE_PCT' is considered only when taking the sample records.
-- in other cases, the sample_pct should be zero.
l_sample_pct := 0;

Ams_Utility_Pvt.Write_Conc_log('Profile Value of AMS_LIST_QT_SAMPLE_SIZE : '|| to_char(l_sample_size));
Ams_Utility_Pvt.Write_Conc_log('Profile Value of AMS_LIST_QT_SAMPLE_PCT : '|| to_char(l_sample_pct));

   if l_master_total_records > l_sample_size then
        l_sample_pct := FND_PROFILE.VALUE('AMS_LIST_QT_SAMPLE_PCT');
	l_sample := 'Y';
        l_sample_records := round((l_master_total_records * l_sample_pct)/100);
--      l_sample_pct := 30;
--      l_sample_pct := FND_PROFILE.VALUE('AMS_LIST_QT_SAMPLE_PCT');
--      Ams_Utility_Pvt.Write_Conc_log('Sampling percentage = '||l_sample_pct);
--      Ams_Utility_Pvt.Write_Conc_log('Sampling size = '||l_sample_size);
     else
	l_sample := 'N';
   end if;
Ams_Utility_Pvt.Write_Conc_log('After getting total number of rows from the master DS : '|| to_char(l_master_total_records));

-- Get All The Columns
-- -------------------
Ams_Utility_Pvt.Write_Conc_log('Start: Get All The Columns - c_attributes' );
   open c_attributes;
   LOOP
   	fetch c_attributes into l_attribute_name, l_query_alias_id;
	exit when c_attributes%notfound;
        l_total_recs := l_total_recs + 1;
        if l_total_recs = l_total_attributes then
		l_comma := ' ';
	end if;

-- Get All The Columns With Alias
-- ------------------------------
Ams_Utility_Pvt.Write_Conc_log('Start: Get All The Columns With Alias - c_attributes_alias ' );
        open c_attributes_alias;
        loop
		fetch c_attributes_alias into l_q_alias_id, l_source_object_name,l_master_flag,l_source_pk_field,
                                              l_column_alias;
		exit when c_attributes_alias%notfound;
		if l_master_flag = 'Y' then
			l_master_alias := l_column_alias;
		end if;
		if l_query_alias_id = l_q_alias_id then
			exit;
		end if;
        end loop;
		l_select_string := l_select_string||' '||l_column_alias||'.'||l_attribute_name||' '
                                   ||l_column_alias||'_'||l_attribute_name||' '||l_comma;
        close c_attributes_alias;
Ams_Utility_Pvt.Write_Conc_log('l_select_string = '||l_select_string );
Ams_Utility_Pvt.Write_Conc_log('End: Get All The Columns With Alias - c_attributes_alias ' );
   END LOOP;
   close c_attributes;
Ams_Utility_Pvt.Write_Conc_log('End: Get All The Columns - c_attributes' );
   l_comma := ',';

   --    (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((
-- Get All the Columns for MASTER view
--*
--*
if l_master_alias is null then
  open c_find_mast_alias;
  loop
    fetch c_find_mast_alias into l_qal_id,l_mastobj_name, l_master_flag,l_mastcol_alias;
    exit when c_find_mast_alias%notfound;
    if l_master_flag = 'Y' then
        l_master_alias := l_mastcol_alias;
        exit;
    end if;
  end loop;
  close c_find_mast_alias;
end if;

-- -----------------------------------
Ams_Utility_Pvt.Write_Conc_log('Start:  Get All the Columns for MASTER view - c_master_columns ' );
   open c_master_columns;
   LOOP
	fetch c_master_columns into l_master_column;
	Exit when c_master_columns%notfound;
	if l_master_column is not NULL then
          l_master_columns_string := l_master_columns_string||
	  ' '||l_comma||' '||l_master_alias||'.'||l_master_column||' '||l_master_column;
	  l_master_column := null;
	end if;
   END LOOP;
   close c_master_columns;
Ams_Utility_Pvt.Write_Conc_log('l_master_columns_string = '||l_master_columns_string );
Ams_Utility_Pvt.Write_Conc_log('End:  Get All the Columns for MASTER view - c_master_columns ' );

      l_select_string := l_select_string||' '||l_master_columns_string;
Ams_Utility_Pvt.Write_Conc_log('l_select_string = '||l_select_string);
   --  }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
   l_total_attributes := 0;
   l_total_recs := 0;
   open c_tot_attributes_alias;
   fetch c_tot_attributes_alias into l_total_attributes;
   close c_tot_attributes_alias;
Ams_Utility_Pvt.Write_Conc_log('l_total_attributes = '||to_char(l_total_attributes));

-- dbms_output.put_line('l_total_attributes = '||to_char(l_total_attributes));

-- Construct The From Clause
-- -------------------------
Ams_Utility_Pvt.Write_Conc_log('Start: Construct The From Clause ');
Ams_Utility_Pvt.Write_Conc_log('l_sample = '||l_sample);
  if l_sample = 'N' then
   open c_attributes_alias;
   loop
	fetch c_attributes_alias into l_q_alias_id, l_source_object_name,l_master_flag,l_source_pk_field,
                                      l_column_alias;
 	exit when c_attributes_alias%notfound;
        l_total_recs := l_total_recs + 1;
        if l_total_recs = l_total_attributes then
                l_comma := ' ';
        end if;
   l_from_string := l_from_string||' '||l_source_object_name||' '||l_column_alias||' '||l_comma;
   Ams_Utility_Pvt.Write_Conc_log('l_from_string = '||l_from_string);

Ams_Utility_Pvt.Write_Conc_log('l_mastobj_name = '||l_mastobj_name);
Ams_Utility_Pvt.Write_Conc_log('l_master_flag = '||l_master_flag);

   end loop;
   close c_attributes_alias;

    if l_mastobj_name is not null then
      Ams_Utility_Pvt.Write_Conc_log('inside the if');
      l_from_string := l_from_string||', '||l_mastobj_name||' '||l_master_alias||' '||l_comma;
      Ams_Utility_Pvt.Write_Conc_log('l_from_string = '||l_from_string);
   end if;

-- Ams_Utility_Pvt.Write_Conc_log('FINAL -- l_tmp_string  = '||l_tmp_string);
Ams_Utility_Pvt.Write_Conc_log('sample (N) l_from_string = '||l_from_string);


  end if;
  if l_sample = 'Y' then
   open c_from_clause;
   loop
        fetch c_from_clause into l_q_alias_id, l_source_object_name,l_master_flag,l_source_pk_field,
                                      l_column_alias;
        exit when c_from_clause%notfound;
        l_total_recs := l_total_recs + 1;
        if l_total_recs = l_total_attributes then
                l_comma := ' ';
        end if;
	   Ams_Utility_Pvt.Write_Conc_log('l_from_string:'||l_from_string||'----l_source_object_name:'||l_source_object_name||'--l_column_alias'||l_column_alias);
   l_from_string := l_from_string||' '||l_source_object_name||' '||l_column_alias||' '||l_comma;
   end loop;
   close c_from_clause;
Ams_Utility_Pvt.Write_Conc_log('sample (Y) l_from_string = '||l_from_string);

  end if;
Ams_Utility_Pvt.Write_Conc_log('End: Construct The From Clause ');

-- dbms_output.put_line('coming after the from clause........ ');

-- Construct The Where Clause
-- --------------------------
-- --------------------------------------------------------

l_number_of_days := FND_PROFILE.VALUE('AMS_ORDER_LOOK_BACK_PRD_DAYS');
Ams_Utility_Pvt.Write_Conc_log('Profile value for Orders look back period: '||l_number_of_days);
Ams_Utility_Pvt.Write_Conc_log('Start:  Construct The Where Clause ');
   l_total_attributes := 0;
   open c_tot_attributes_alias;
   fetch c_tot_attributes_alias into l_total_attributes;
   close c_tot_attributes_alias;
Ams_Utility_Pvt.Write_Conc_log('l_total_attributes = '||to_char(l_total_attributes));
 if l_total_attributes = 1 AND l_mastobj_name is null then
	l_where_string := null;
 end if;
  if l_total_attributes > 1 or (l_total_attributes = 1 AND l_mastobj_name is not null) then
  open c_const_where;
  loop
    fetch c_const_where into l_oders_view_used,l_master_lstype_id,l_master_flag,l_mst_alias;
    exit when c_const_where%notfound;
	if l_master_flag = 'Y' then
	   exit;
	end if;
  end loop;
  close c_const_where;
  if (l_master_flag = 'N' or l_master_flag is null) then
  open c_mast_alias;
  loop
    fetch c_mast_alias into l_master_lstype_id,l_mastobj_name, l_master_flag,l_mst_alias;
    exit when c_mast_alias%notfound;
    if l_master_flag = 'Y' then
        exit;
    end if;
  end loop;
  close c_mast_alias;
  end if;

  l_total_recs := 0;
  open c_total_child;
  fetch c_total_child into l_total_child;
  close c_total_child;
Ams_Utility_Pvt.Write_Conc_log('l_total_child = '||to_char(l_total_child));
  If l_total_child = 0 then
	l_where_string := null;
  end if;
 if l_total_child > 0 then
  open c_const_where;
  loop
    fetch c_const_where into l_oders_view_used,l_child_lstype_id,l_master_flag,l_chd_alias;
    exit when c_const_where%notfound;
	if l_master_flag = 'N' then
              l_total_recs := l_total_recs + 1;
              if l_total_recs = l_total_child then
                   l_and := ' ';
              end if;
	      open c_const_where_cols;
	      fetch c_const_where_cols into l_mst_col, l_chd_col;
	      close c_const_where_cols;
              if (l_number_of_days is NOT NULL) OR (l_number_of_days > 0) then
                 if (l_oders_view_used = 'AMS_DS_ORDERS_V') then
                    l_where_string := l_where_string||' '||l_mst_alias||l_mst_col||'  =  '||l_chd_alias||l_chd_col||'(+)  AND '||l_chd_alias||'creation_date > sysdate - '||l_number_of_days||' '||l_and;
                 else
                    l_where_string := l_where_string||' '||l_mst_alias||l_mst_col||'  =  '||l_chd_alias||l_chd_col||'(+)  '||l_and;
                 end if;
              else
                    l_where_string := l_where_string||' '||l_mst_alias||l_mst_col||'  =  '||l_chd_alias||l_chd_col||'(+)  '||l_and;
              end if;
	end if; -- l_master_flag = 'N'
        if l_total_recs = l_total_child then
		exit;
	end if;
  end loop;
  close c_const_where;

Ams_Utility_Pvt.Write_Conc_log('l_where_string = '||l_where_string);
 end if;
 end if; -- if l_total_attributes > 1 then
Ams_Utility_Pvt.Write_Conc_log('End:  Construct The Where Clause ');
Ams_Utility_Pvt.Write_Conc_log('l_create_string = '||l_create_string);
 l_no_of_chunks := 0;
 l_no_of_chunks  := ceil(length(l_select_string)/2000 );
 for i in 1 ..l_no_of_chunks
 loop
      Ams_Utility_Pvt.Write_Conc_log('l_select_string = '||substrb(l_select_string,(2000*i) - 1999,2000));
 end loop;

l_create1_string := l_create_string ||' '||l_select_string||' '||l_from_string||' '||l_where_string||' '||l_policy_where||' ';
   if l_where_string is null then
     l_create1_string := l_create1_string||' '||l_where1;
     else
      l_create1_string := l_create1_string||' '||l_where2;
   end if;

-- Construct the LOV condirion Start --------------------------- *********************************
   Ams_Utility_Pvt.Write_Conc_log('Start Construction LOV condition. ');
   AMS_List_running_total_pvt.gen_lov_filter_for_templmv(
                            l_filter_sql,
                            l_string_params,
                            l_num_params,
                            p_template_id
                     ) ;

   Ams_Utility_Pvt.Write_Conc_log('l_filter_sql = '||l_filter_sql);
   Ams_Utility_Pvt.Write_Conc_log('l_num_params = '||l_num_params);
   Ams_Utility_Pvt.Write_Conc_log('l_string_params.count = '||l_string_params.count);
   if l_string_params.count > 100 then
      Ams_Utility_Pvt.Write_Conc_log('ERROR->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ');
      Ams_Utility_Pvt.Write_Conc_log('Maximum 100 LOV value selections are allowed. Please reselect the LOV values.');
      errbuf:= substr(SQLERRM,1,254);
      retcode:= 2;
      return;
   end if;

   AMS_List_running_total_pvt.gen_constant_filter(
                            l_filter_sql,
                            l_string_params,
                            l_num_params,
                            p_template_id
                     ) ;

   Ams_Utility_Pvt.Write_Conc_log('l_filter_sql = '||l_filter_sql);
   Ams_Utility_Pvt.Write_Conc_log('l_num_params = '||l_num_params);
   Ams_Utility_Pvt.Write_Conc_log('l_string_params.count = '||l_string_params.count);
   if l_string_params.count > 100 then
      Ams_Utility_Pvt.Write_Conc_log('ERROR->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ');
      Ams_Utility_Pvt.Write_Conc_log('Maximum 100 LOV value selections are allowed. Please reselect the LOV values.');
      errbuf:= substr(SQLERRM,1,254);
      retcode:= 2;
      return;
   end if;
   begin
       for i in 1 .. l_string_params.count  loop
          Ams_Utility_Pvt.Write_Conc_log('param  '||to_char(i)||' = '|| l_string_params(i));
        end loop;
     exception
	when others then
        Ams_Utility_Pvt.Write_Conc_log('Exception in loop : '||SQLERRM);
    end;
   Ams_Utility_Pvt.Write_Conc_log('End Construction LOV condition. ');
-- Construct the LOV condirion End   --------------------------- *********************************

if l_num_params > 0 and l_filter_sql is not NULL then
   if l_where_string is null then
      l_where_string := ' WHERE '||l_filter_sql;
     else
      l_where_string := l_where_string||' AND '||l_filter_sql;
   end if;
end if;
Ams_Utility_Pvt.Write_Conc_log('l_from_string = '||l_from_string);
Ams_Utility_Pvt.Write_Conc_log('l_where_string = '||l_where_string);
-- Ams_Utility_Pvt.Write_Conc_log('FINAL -- l_tmp_string  = '||l_tmp_string);
 l_create_string := l_create_string ||' '||l_select_string||' '||l_from_string||' '||l_where_string||' '||l_policy_where||' ';
 l_insert_string := l_insert_string ||' '||l_select_string||' '||l_from_string||' '||l_where_string||' '||l_policy_where||' ';
 l_no_of_chunks := 0;
 l_no_of_chunks  := ceil(length(l_create_string)/2000 );
 for i in 1 ..l_no_of_chunks
 loop
      Ams_Utility_Pvt.Write_Conc_log('Final l_create_string = '||substrb(l_create_string,(2000*i) - 1999,2000));
 end loop;

 l_no_of_chunks  := ceil(length(l_insert_string)/2000 );
 Ams_Utility_Pvt.Write_Conc_log('Final l_insert_string chunks= '||l_no_of_chunks);
 for i in 1 ..l_no_of_chunks
 loop
      Ams_Utility_Pvt.Write_Conc_log(substrb(l_insert_string,(2000*i) - 1999,2000));
 end loop;

    -- SOLIN, bug 3696553
    IF l_remote_flag = 'N'
    THEN
    -- ELSE part is close to the end of the procedure
    -- SOLIN, end
open c_view_exists;
fetch c_view_exists into l_view_exists;
close c_view_exists;
Ams_Utility_Pvt.Write_Conc_log('l_view_exists = '||l_view_exists);
if l_view_exists = 'Y' then
            -- l_truncate_string := 'TRUNCATE TABLE '||l_ams_schema||'.'||l_view_name;
            l_drop_string := 'DROP TABLE '||l_ams_schema||'.'||l_view_name;
            -- l_drop_string := 'DROP MATERIALIZED VIEW '||l_view_name;
            -- Ams_Utility_Pvt.Write_Conc_log('local l_truncate_string = '||l_truncate_string);
            -- execute immediate l_truncate_string;
            Ams_Utility_Pvt.Write_Conc_log('local l_drop_string = '||l_drop_string);
            execute immediate l_drop_string;

Ams_Utility_Pvt.Write_Conc_log('Table  Droped  ');
end if;
open c_synonym_exists;
fetch c_synonym_exists into l_synonym_exists;
close c_synonym_exists;
if l_synonym_exists = 'Y' then
Ams_Utility_Pvt.Write_Conc_log('l_drop_synonym = '||l_drop_synonym);
 	execute immediate l_drop_synonym;
Ams_Utility_Pvt.Write_Conc_log('Synonym  Droped  ');
end if;
/*
if l_policy_exists = 'Y' then
	Ams_Utility_Pvt.Write_Conc_log('Disable Contant Source Security ');
 	hz_common_pub.disable_cont_source_security;
end if;
*/
 if l_num_params = 0 or l_num_params is null  then
        execute immediate l_create1_string;
        Ams_Utility_Pvt.Write_Conc_log('Table created. ');
        execute immediate l_create_synonym;
        Ams_Utility_Pvt.Write_Conc_log('Synonym created. ');
        execute immediate l_insert_string;
        Ams_Utility_Pvt.Write_Conc_log('Insert statement executed. ');
 end if;

if l_num_params > 0 and l_filter_sql is not NULL then
 l_no_of_chunks := 0;
 l_no_of_chunks  := ceil(length(l_create1_string)/2000 );
 for i in 1 ..l_no_of_chunks
 loop
      Ams_Utility_Pvt.Write_Conc_log('Final l_create1_string = '||substrb(l_create1_string,(2000*i) - 1999,2000));
 end loop;
    execute immediate l_create1_string;
    Ams_Utility_Pvt.Write_Conc_log('Table creation with LOV conditions. ');
    execute immediate  l_create_synonym;
    Ams_Utility_Pvt.Write_Conc_log('Synonym created. ');
     for i in 1 .. 100 loop
         l_table_char(i) := ' ';
     end loop;
     for i in 1 .. l_string_params.count
     loop
        l_table_char(i) := l_string_params(i);
        Ams_Utility_Pvt.Write_Conc_log('l_table_char(i) '||to_char(i)||'  = '|| l_table_char(i));
     end loop;
        l_string := 'DECLARE   ' ||
        'l_string1 varchar2(10000) ; ' ||
        'begin    ' ||
        ' l_string1 :=   :1  || ' || ' :2  || ' || ' :3  || ' || ' :4  || ' ||
                       ' :5  || ' || ' :6  || ' || ' :7  || ' || ' :8  || ' ||
                       ' :9  || ' || ' :10  || ' || ' :11  || ' || ' :12  || ' ||
                       ' :13  || ' || ' :14  || ' || ' :15  || ' || ' :16  || ' ||
                       ' :17  || ' || ' :18  || ' || ' :19  || ' || ' :20  || ' ||
                       ' :21  || ' || ' :22  || ' || ' :23  || ' || ' :24  || ' ||
                       ' :25  || ' || ' :26  || ' || ' :27  || ' || ' :28  || ' ||
                       ' :29  || ' || ' :30  || ' || ' :31  || ' || ' :32  || ' ||
                       ' :33  || ' || ' :34  || ' || ' :35  || ' || ' :36  || ' ||
                       ' :37  || ' || ' :38  || ' || ' :39  || ' || ' :40  || ' ||
                       ' :41  || ' || ' :42  || ' || ' :43  || ' || ' :44  || ' ||
                       ' :45  || ' || ' :46  || ' || ' :47  || ' || ' :48  || ' ||
                       ' :49  || ' || ' :50  || ' || ' :51  || ' || ' :52  || ' ||
                       ' :53  || ' || ' :54  || ' || ' :55  || ' || ' :56  || ' ||
                       ' :57  || ' || ' :58  || ' || ' :59  || ' || ' :60  || ' ||
                       ' :61  || ' || ' :62  || ' || ' :63  || ' || ' :64  || ' ||
                       ' :65  || ' || ' :66  || ' || ' :67  || ' || ' :68  || ' ||
                       ' :69  || ' || ' :70  || ' || ' :71  || ' || ' :72  || ' ||
                       ' :73  || ' || ' :74  || ' || ' :75  || ' || ' :76  || ' ||
                       ' :77  || ' || ' :78  || ' || ' :79  || ' || ' :80  || ' ||
                       ' :81  || ' || ' :82  || ' || ' :83  || ' || ' :84  || ' ||
                       ' :85  || ' || ' :86  || ' || ' :87  || ' || ' :88  || ' ||
                       ' :89  || ' || ' :90  || ' || ' :91  || ' || ' :92  || ' ||
                       ' :93  || ' || ' :94  || ' || ' :95  || ' || ' :96  || ' ||
                       ' :97  || ' || ' :98  || ' || ' :99  || ' || ' :100  ; ' ||
         l_insert_string||
 '; exception when others then  Ams_Utility_Pvt.Write_Conc_log(SQLERRM);  end;  '  ;
 l_no_of_chunks := 0;
 l_no_of_chunks  := ceil(length(l_string)/2000 );
 for i in 1 ..l_no_of_chunks
 loop
      Ams_Utility_Pvt.Write_Conc_log('Final l_string = '||substrb(l_string,(2000*i) - 1999,2000));
 end loop;
         for i in 1 .. l_table_char.count
         loop
            Ams_Utility_Pvt.Write_Conc_log('l_table_char '||to_char(i)||' = '||l_table_char(i));
         end loop;
execute immediate   l_string
using l_table_char(1), l_table_char(2), l_table_char(3), l_table_char(4),
      l_table_char(5), l_table_char(6), l_table_char(7), l_table_char(8),
      l_table_char(9), l_table_char(10), l_table_char(11), l_table_char(12),
      l_table_char(13), l_table_char(14), l_table_char(15), l_table_char(16),
      l_table_char(17), l_table_char(18), l_table_char(19), l_table_char(20),
      l_table_char(21), l_table_char(22), l_table_char(23), l_table_char(24),
      l_table_char(25), l_table_char(26), l_table_char(27), l_table_char(28),
      l_table_char(29), l_table_char(30), l_table_char(31), l_table_char(32),
      l_table_char(33), l_table_char(34), l_table_char(35), l_table_char(36),
      l_table_char(37), l_table_char(38), l_table_char(39), l_table_char(40),
      l_table_char(41), l_table_char(42), l_table_char(43), l_table_char(44),
      l_table_char(45), l_table_char(46), l_table_char(47), l_table_char(48),
      l_table_char(49), l_table_char(50),
      l_table_char(51), l_table_char(52), l_table_char(53), l_table_char(54),
      l_table_char(55), l_table_char(56), l_table_char(57), l_table_char(58),
      l_table_char(59), l_table_char(60), l_table_char(61), l_table_char(62),
      l_table_char(63), l_table_char(64), l_table_char(65), l_table_char(66),
      l_table_char(67), l_table_char(68), l_table_char(69), l_table_char(70),
      l_table_char(71), l_table_char(72), l_table_char(73), l_table_char(74),
      l_table_char(75), l_table_char(76), l_table_char(77), l_table_char(78),
      l_table_char(79), l_table_char(80), l_table_char(81), l_table_char(82),
      l_table_char(83), l_table_char(84), l_table_char(85), l_table_char(86),
      l_table_char(87), l_table_char(88), l_table_char(89), l_table_char(90),
      l_table_char(91), l_table_char(92), l_table_char(93), l_table_char(94),
      l_table_char(95), l_table_char(96), l_table_char(97), l_table_char(98),
      l_table_char(79), l_table_char(100);
commit;
end if;

Ams_Utility_Pvt.Write_Conc_log('QT Table Created ');
/*
if l_policy_exists = 'Y' then
	 hz_common_pub.enable_cont_source_security;
	 Ams_Utility_Pvt.Write_Conc_log('Enable Contant Source Security ');
end if;
*/
-- Update the ams_query_template_all table
   update ams_query_template_all
        set mv_name = l_view_name,
            MV_AVAILABLE_FLAG = 'Y',
            SAMPLE_PCT = l_sample_pct,
            SAMPLE_PCT_RECORDS = l_sample_records,
            MASTER_DS_REC_NUMBERS = l_master_total_records,
            RECALC_TABLE_STATUS = 'AVAILABLE'
        where TEMPLATE_ID = p_TEMPLATE_ID;

Ams_Utility_Pvt.Write_Conc_log('QT Table creation Finish. ');

commit;

Ams_Utility_Pvt.Write_Conc_log('Start Table Analyze .');
Ams_Utility_Pvt.Write_Conc_log(' ANALYZE TABLE '||l_ams_schema||'.'||l_view_name||' COMPUTE STATISTICS ');
execute immediate  ' ANALYZE TABLE '||l_ams_schema||'.'||l_view_name||' COMPUTE STATISTICS ';
Ams_Utility_Pvt.Write_Conc_log('Finish Table Analyze .');

-- Bitmap Index Creation
-- ---------------------
Ams_Utility_Pvt.Write_Conc_log('Start: Bitmap Index Creation  ');

  open c_index_columns;
  loop
	fetch c_index_columns into l_index_column;
	exit when c_index_columns%notfound;
	l_counter := l_counter + 1;
l_index_string := 'CREATE BITMAP INDEX '||l_view_name||'_N_'||to_char(l_counter)||' ON '||l_view_name||'('||l_index_column||')';
Ams_Utility_Pvt.Write_Conc_log('l_index_string = '||l_index_string);
 execute immediate l_index_string;
Ams_Utility_Pvt.Write_Conc_log('Index Created  ');
Ams_Utility_Pvt.Write_Conc_log('Start Index Analyze .');
Ams_Utility_Pvt.Write_Conc_log(' ANALYZE INDEX '||l_view_name||'_N_'||to_char(l_counter)||' COMPUTE STATISTICS ');
execute immediate  ' ANALYZE INDEX '||l_view_name||'_N_'||to_char(l_counter)||' COMPUTE STATISTICS ';
Ams_Utility_Pvt.Write_Conc_log('Finish Index Analyze .');
  end loop;
  close c_index_columns;

Ams_Utility_Pvt.Write_Conc_log('End: Bitmap Index Creation  ');

commit;
   retcode:= 0;
    -- SOLIN, Bug 3696553
    -- IF part is very up above
    ELSE
        l_check_table_string := 'begin select 1 into :l_exist from sys.all_tables'||'@'||l_dblink||' where table_name = '''||l_view_name||''' ;end;';
        Ams_Utility_Pvt.Write_Conc_log('l_check_table_string = '||l_check_table_string);

        BEGIN
        execute immediate l_check_table_string using OUT l_exist;
        EXCEPTION
            WHEN OTHERS THEN
            l_exist := 0;
        END;

        IF l_exist = 1
        THEN
        Ams_Utility_Pvt.Write_Conc_log('remote l_remote_truncate_string = '||l_remote_truncate_string);
        l_create_remote := 'BEGIN dbms_utility.exec_ddl_statement'||'@'||l_dblink||'('''|| l_remote_truncate_string||'''); END;';
        Ams_Utility_Pvt.Write_Conc_log('drop command = '||l_create_remote);
        execute immediate l_create_remote;

        l_drop_string := 'DROP TABLE '||l_view_name;
        Ams_Utility_Pvt.Write_Conc_log('remote l_drop_string = '||l_drop_string);
        l_create_remote := 'BEGIN dbms_utility.exec_ddl_statement'||'@'||l_dblink||'('''|| l_drop_string ||'''); END;';
        Ams_Utility_Pvt.Write_Conc_log('drop command = '||l_create_remote);
        execute immediate l_create_remote;
        END IF;

        Ams_Utility_Pvt.Write_Conc_log('x_return_status='||x_return_status || ' x_msg_data=' || x_msg_data);
        Ams_Utility_Pvt.Write_Conc_log('remote l_create1_string = '||l_create1_string);
        Ams_Utility_Pvt.Write_Conc_log('remote l_insert_string = '||l_insert_string);
        l_create_remote := 'BEGIN dbms_utility.exec_ddl_statement'||'@'||l_dblink||'('''|| l_create1_string ||'''); END;';
        Ams_Utility_Pvt.Write_Conc_log('create command = '||l_create_remote);
        execute immediate l_create_remote;

        execute immediate
          'BEGIN
          AMS_Remote_ListGen_PKG.remote_list_gen'||'@'||l_dblink||'(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'||';'||
          ' END;'
          using  '1',
          l_null,
          'T',
          l_null,
          OUT x_return_status,
          OUT x_msg_count,
          OUT x_msg_data,
          TO_NUMBER(NULL), --g_list_header_id,
          --l_create1_string,
          l_insert_string,
          l_null,
          OUT l_total_recs,
          'EXECUTE_STRING';

        Ams_Utility_Pvt.Write_Conc_log('x_return_status='||x_return_status || ' x_msg_data=' || x_msg_data);

        -- Update the ams_query_template_all table
        update ams_query_template_all
        set mv_name = l_view_name,
            MV_AVAILABLE_FLAG = 'Y',
            SAMPLE_PCT = l_sample_pct,
            SAMPLE_PCT_RECORDS = l_sample_records,
            MASTER_DS_REC_NUMBERS = l_master_total_records,
		  RECALC_TABLE_STATUS = 'AVAILABLE'
        where TEMPLATE_ID = p_TEMPLATE_ID;
        -- SOLIN, bug 4103157
        l_synonym_exists := NULL;
        -- SOLIN, end
	open c_synonym_exists;
	fetch c_synonym_exists into l_synonym_exists;
	close c_synonym_exists;
	if l_synonym_exists = 'Y' then
	Ams_Utility_Pvt.Write_Conc_log('l_drop_synonym = '||l_drop_synonym);
 		execute immediate l_drop_synonym;
	Ams_Utility_Pvt.Write_Conc_log('Synonym  Droped  ');
	end if;
        execute immediate l_remote_create_synonym;
        Ams_Utility_Pvt.Write_Conc_log('Synonym created. ');

        -- create index for remote table?
        l_remote_index_string := 'begin select max(COLUMN_ID) into :l_number_of_index from sys.all_tab_columns'||'@'||l_dblink||' where table_name = '''||l_view_name||''' and column_name like ''A%'';end;';
        Ams_Utility_Pvt.Write_Conc_log('l_remote_index_string = '||l_remote_index_string);
        BEGIN
        execute immediate l_remote_index_string using OUT l_number_of_index;
        Ams_Utility_Pvt.Write_Conc_log('number of index = '||l_number_of_index);
        EXCEPTION
            WHEN OTHERS THEN
            l_number_of_index := 0;
        END;
        l_counter := 1;
        WHILE l_counter <= l_number_of_index
        LOOP

            l_remote_index_string := 'BEGIN select column_name into :l_index_column from sys.all_tab_columns'||'@'||l_dblink||' where table_name = '''||l_view_name||''' and column_name like ''A%'' and column_id = '||l_counter||'; END;';
            Ams_Utility_Pvt.Write_Conc_log('get column name string = '||l_remote_index_string);
            BEGIN
            execute immediate l_remote_index_string using OUT l_index_column;
            Ams_Utility_Pvt.Write_Conc_log('index column = '||l_index_column);
            EXCEPTION
                WHEN OTHERS THEN
                NULL;
            END;
            l_index_string := 'BEGIN dbms_utility.exec_ddl_statement'||'@'
                ||l_dblink||'(''CREATE BITMAP INDEX '||l_view_name||'_N_'
                ||to_char(l_counter)||' ON '||l_view_name||'('||l_index_column
                ||')'||'''); END;';
            Ams_Utility_Pvt.Write_Conc_log('l_index_string = '||l_index_string);

            execute immediate l_index_string;

            Ams_Utility_Pvt.Write_Conc_log('remote Index Created  ');
            l_counter := l_counter + 1;
        end loop;
    END IF;
    -- SOLIN, END
Ams_Utility_Pvt.Write_Conc_log('+++++++++++++++++++++End CM program : AMSGMVTP.+++++++++++++++++++++');

EXCEPTION
 WHEN OTHERS THEN
 -- hz_common_pub.enable_cont_source_security;
Ams_Utility_Pvt.Write_Conc_log('Exception in generate_mv_for_template : '||SQLERRM);
   errbuf:= substr(SQLERRM,1,254);
   retcode:= 2;

   update ams_query_template_all
   set RECALC_TABLE_STATUS = 'FAILED'
   where TEMPLATE_ID = p_TEMPLATE_ID;

   commit;

-- SOLIN, BUG 3736770
l_view_exists := NULL;
open c_view_exists;
fetch c_view_exists into l_view_exists;
close c_view_exists;
Ams_Utility_Pvt.Write_Conc_log('l_view_exists = '||l_view_exists);
if l_view_exists = 'Y' then
    IF l_remote_flag = 'N'
    THEN
            l_truncate_string := 'TRUNCATE TABLE '||l_ams_schema||'.'||l_view_name;
            l_drop_string := 'DROP TABLE '||l_ams_schema||'.'||l_view_name;
            Ams_Utility_Pvt.Write_Conc_log('local l_truncate_string = '||l_truncate_string);
            execute immediate l_truncate_string;
            Ams_Utility_Pvt.Write_Conc_log('local l_drop_string = '||l_drop_string);
            execute immediate l_drop_string;
    ELSE
        Ams_Utility_Pvt.Write_Conc_log('remote l_remote_truncate_string = '||l_remote_truncate_string);
        l_create_remote := 'BEGIN dbms_utility.exec_ddl_statement'||'@'||l_dblink||'('''|| l_remote_truncate_string||'''); END;';
        Ams_Utility_Pvt.Write_Conc_log('truncate command = '||l_create_remote);
        execute immediate l_create_remote;

        l_drop_string := 'DROP TABLE '||l_view_name;
        Ams_Utility_Pvt.Write_Conc_log('remote l_drop_string = '||l_drop_string);
        l_create_remote := 'BEGIN dbms_utility.exec_ddl_statement'||'@'||l_dblink||'('''|| l_drop_string ||'''); END;';
        Ams_Utility_Pvt.Write_Conc_log('drop command = '||l_create_remote);
        execute immediate l_create_remote;
    END IF;

    Ams_Utility_Pvt.Write_Conc_log('Table Droped in exception ');
    Ams_Utility_Pvt.Write_Conc_log('This query template is returning lot of data , please modify the query. ');
    Ams_Utility_Pvt.Write_Conc_log('To restruct the size use LOV filter conditions.');
end if;
-- SOLIN, end
   raise;
End generate_mv_for_template;
-- -------------------------------


PROCEDURE calc_tot_for_all_templates (
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2
                            ) IS
l_template_id		number;
l_mv_name		varchar2(30);
l_delete_string		varchar2(2000);
l_Errbuf		varchar2(2000);
l_Retcode		varchar2(1);

cursor c_all_templates is
select template_id, mv_name from ams_query_template_all where mv_name is not null;
begin

	open c_all_templates;
	loop
		fetch c_all_templates into l_template_id, l_mv_name;
		exit when c_all_templates%notfound;

		l_delete_string := ' DROP MATERIALIZED VIEW '||l_mv_name;
		execute immediate l_delete_string;

   		update ams_query_template_all
	    	   set MV_AVAILABLE_FLAG = 'N'
		where TEMPLATE_ID = L_TEMPLATE_ID;


		Calculate_running_totals (
                            L_Errbuf ,
                            L_Retcode,
                            l_template_id);

	end loop;
	close c_all_templates;

   retcode:= 0;
EXCEPTION
 WHEN OTHERS THEN
   errbuf:= substr(SQLERRM,1,254);
   retcode:= 2;
   raise;
end calc_tot_for_all_templates;
-- ---------------------------

PROCEDURE process_query (
                            p_sql_string        IN sql_string_4k,
                            p_total_parameters  IN t_number,
                            p_string_parameters IN sql_string_4k,
                            p_template_id       IN NUMBER,
                            p_parameters        IN sql_string_4k,
                            p_parameters_value  IN t_number,
                            p_sql_results       OUT NOCOPY t_number
                        ) IS

l_total	     		number;
l_sql_count  		number;
l_i			number := 1;  -- 0;
l_create_string    	VARCHAR2(32767);
l_total_param 		number;
l_param_start 		number := 1;  -- 0;
l_bind_string    	VARCHAR2(32767);
l_total_bind 		number := 100;
l_bind_avail 		number ;
l_sample_pct		number;
l_master_ds_rec_numbers number;
l_sample_pct_recrods	number;

l_return_status        varchar2(1);

cursor c_master_ds_rec_numbers is
select nvl(SAMPLE_PCT,0),MASTER_DS_REC_NUMBERS,SAMPLE_PCT_RECORDS from ams_query_template_all
where TEMPLATE_ID = P_TEMPLATE_ID;


-- SOLIN, Bug 3696553
CURSOR c_get_dblink is
  select NVL(types.remote_flag, 'N'), database_link
  from AMS_QUERY_ALIAS alias, ams_list_src_types types
  where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code;

l_remote_flag   VARCHAR2(1);
l_dblink        VARCHAR2(120);
l_null          varchar2(30) := null;
l_msg_count	number;
l_msg_data      varchar2(2000);
-- SOLIN, end

 cur BINARY_INTEGER;
 l_exec BINARY_INTEGER;
 l_count number; --DBMS_SQL.NUMBER_TABLE;
 idx varchar2(6);

begin
delete from ams_act_logs where ARC_ACT_LOG_USED_BY =
'RECL' and ACT_LOG_USED_BY_ID =  p_template_id;
 -- dbms_output.put_line('IN AMS_List_running_total_pvt----------------------- ');
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'Start : Recalculate Process at '||to_char(sysdate,'dd/mm/yyyy hh:mi:ss'),
              p_msg_type        => 'DEBUG');
open c_master_ds_rec_numbers;
fetch c_master_ds_rec_numbers into l_sample_pct, l_master_ds_rec_numbers,l_sample_pct_recrods;
close c_master_ds_rec_numbers;

-- Get the total # of sqls
l_sql_count := p_sql_string.count;
-- dbms_output.put_line('l_sql_count = '||to_char(l_sql_count));
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'l_sql_count :=  '||l_sql_count,
              p_msg_type        => 'DEBUG');
LOOP
  if l_i > l_sql_count then
	exit;
  end if;

  l_count := 0;
-- Get the total # of attributes for each sql
  l_total_param := p_total_parameters(l_i);
 -- dbms_output.put_line('l_total_param = '||to_char(l_total_param));
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'l_total_param :=  '||l_total_param||' l_i:'||l_i,
              p_msg_type        => 'DEBUG');

  cur := DBMS_SQL.OPEN_CURSOR;

             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => substr('SQL_QUERY:= '||p_sql_string(l_i),1,255),
              p_msg_type        => 'DEBUG');

  DBMS_SQL.PARSE (cur, p_sql_string(l_i), DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN (cur, 1, l_count);

  FOR i IN 1..l_total_param
  LOOP
    --bind variables
    DBMS_SQL.BIND_VARIABLE (cur, ''||i||'', p_string_parameters(l_param_start));
    l_param_start:=l_param_start+1;
  END LOOP;

  l_exec := DBMS_SQL.EXECUTE(cur);

  IF DBMS_SQL.FETCH_ROWS (cur) > 0 THEN
    DBMS_SQL.COLUMN_VALUE (cur, 1, l_count);
  ELSE
    l_count := 0;
  END IF;

  DBMS_SQL.CLOSE_CURSOR (cur);

 -- dbms_output.put_line('Total from query -- l_total = '|| to_char(l_total));
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'l_total :=  '||l_count,
              p_msg_type        => 'DEBUG');
if l_sample_pct = 0 then
   p_sql_results(l_i) := l_count;
 -- dbms_output.put_line('p_sql_results(l_i) = '|| p_sql_results(l_i));
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'Result going bcak -- p_sql_results(l_i) :=  '||p_sql_results(l_i),
              p_msg_type        => 'DEBUG');
end if;
if l_sample_pct > 0 then
   p_sql_results(l_i) :=  round((l_count / l_sample_pct_recrods) * l_master_ds_rec_numbers) ;
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'Results with sampling p_sql_results(l_i) :=  '||p_sql_results(l_i)
	                           ||'-'||to_char(l_sample_pct_recrods)||'-'||to_char(l_master_ds_rec_numbers),
              p_msg_type        => 'DEBUG');
end if;

  if l_total_param = 0 then
     l_param_start := 0;
  end if;
  l_i := l_i +1;
  l_total_param := null;
--  l_param_start := l_param_start + 1;
  l_total       := null;
  l_create_string := null;
/*
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'Last line  l_param_start :=  '||l_param_start,
              p_msg_type        => 'DEBUG');
*/
-- dbms_output.put_line('l_param_start = '||to_char(l_param_start));
END LOOP;
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'End : Recalculate process ',
              p_msg_type        => 'DEBUG');
--  dbms_output.put_line('IN AMS_List_running_total_pvt---------------------------------------  ');

EXCEPTION
       WHEN  others THEN
             AMS_Utility_PVT.Create_Log (
              x_return_status   => l_return_status,
              p_arc_log_used_by => 'RECL',
              p_log_used_by_id  => p_template_id,
              p_msg_data        => 'Error in process_query for recalculate  '|| SQLERRM||' '||SQLCODE,
              p_msg_type        => 'DEBUG');
	raise;
end process_query;

-- ---------------------------------------------------------


PROCEDURE gen_lov_filter_for_templmv (
                            x_filter_sql    OUT NOCOPY     VARCHAR2,
                            x_string_params OUT NOCOPY sql_string_4k,
                            x_num_params    OUT NOCOPY            NUMBER,
                            p_template_id   IN   NUMBER
                            ) IS

  cursor c_qualify_conds is
    select distinct cond.query_condition_id cond_id
    from AMS_QUERY_CONDITION cond, AMS_QUERY_COND_DISP_STRUCT_all struct,
          AMS_COND_STRUCT_RESTRICT_VALUE res_values
    where cond.template_id = p_template_id
    and cond.value1_type = 'LOV'
    and struct.QUERY_CONDITION_ID = cond.query_condition_id
    and struct.QUERY_COND_DISP_STRUCT_ID = res_values.query_cond_disp_struct_id(+)
    and struct.token_type= 'OPERATOR'
    and cond.mandatory_flag = 'Y'
    UNION
    select distinct cond.query_condition_id cond_id
    from AMS_QUERY_CONDITION cond, AMS_QUERY_COND_DISP_STRUCT_all struct,
          AMS_COND_STRUCT_RESTRICT_VALUE res_values
    where cond.template_id = p_template_id
    and cond.value1_type = 'LOV'
    and struct.QUERY_CONDITION_ID = cond.query_condition_id
    and struct.QUERY_COND_DISP_STRUCT_ID = res_values.query_cond_disp_struct_id
    and struct.token_type= 'OPERATOR'
    and cond.mandatory_flag = 'Y'
    and  ( ( upper(res_values.code) in ('IS', 'IN', 'LIKE') and upper(res_values.code) not in ('IS NOT', 'NOT IN', 'NOT LIKE'))
        or  ( upper(res_values.code) in ('IS NOT', 'NOT IN', 'NOT LIKE') and upper(res_values.code) not in ('IS', 'IN', 'LIKE'))
       )
    and upper(res_values.code) not in ('>', '>=', 'BETWEEN', '<', '<=');

  cursor c_left_oprand (p_cond_id NUMBER) is
    select  struct.non_variant_value  attr_name, source_object_name table_name,src_types.list_source_type_id
-- || alias.ALIAS_SEQ table_name
    from AMS_QUERY_COND_DISP_STRUCT_all struct, AMS_QUERY_ALIAS alias, ams_list_src_types src_types
    where struct.query_condition_id = p_cond_id
    and struct.token_type = 'ATTRIBUTE'
    and alias.query_alias_id = struct.query_alias_id
                and alias.OBJECT_NAME = src_types.SOURCE_TYPE_CODE;
  cursor c_operator (p_cond_id NUMBER) is
    select upper(res_values.code) operator
    from AMS_QUERY_COND_DISP_STRUCT_all struct, AMS_COND_STRUCT_RESTRICT_VALUE res_values
    where struct.query_condition_id = p_cond_id and
    struct.token_type = 'OPERATOR'
    and struct.QUERY_COND_DISP_STRUCT_ID = res_values.query_cond_disp_struct_id;

  cursor c_lov_values (p_cond_id NUMBER) is
    select upper(res_values.code) lov_value
    from AMS_QUERY_COND_DISP_STRUCT_all struct, AMS_COND_STRUCT_RESTRICT_VALUE res_values
    where struct.query_condition_id = p_cond_id and
    struct.token_type = 'VALUE1'
    and struct.QUERY_COND_DISP_STRUCT_ID = res_values.query_cond_disp_struct_id;


  cursor c_lov_sql (l_list_source_type_id NUMBER,l_source_field varchar2) is
  select qu.QUERY --sql_string is obsolete bug 4604653
  from ams_list_src_fields flds,ams_attb_lov_b lovb, ams_list_queries_all qu
  where flds.LIST_SOURCE_TYPE_ID = l_list_source_type_id
  and flds.SOURCE_COLUMN_NAME = l_source_field
  and flds.attb_lov_id = lovb.attb_lov_id
  and lovb.CREATION_TYPE = 'SQL'
  and qu.ACT_LIST_QUERY_USED_BY_ID = lovb.attb_lov_id
  and qu.ARC_ACT_LIST_QUERY_USED_BY = 'LOV' ;

l_lov_sql   varchar2(32767);
l_final_lov_sql   varchar2(32767);
l_qa_id   	number;
l_object_name 	varchar2(60);
l_object_alias	varchar2(30);

  cursor c_lov_type (l_list_source_type_id NUMBER,l_source_field varchar2) is
  select lovb.CREATION_TYPE
  from ams_list_src_fields flds ,ams_attb_lov_b lovb
  where flds.LIST_SOURCE_TYPE_ID = l_list_source_type_id
  and flds.SOURCE_COLUMN_NAME = l_source_field
  and flds.attb_lov_id = lovb.attb_lov_id;
l_lov_type  varchar2(60);


 cursor c_lov_user (l_list_source_type_id NUMBER,l_source_field varchar2) is
 select valb.value_code
  from ams_list_src_fields flds ,ams_attb_lov_b lovb, ams_attb_lov_values_b valb
  where flds.LIST_SOURCE_TYPE_ID = l_list_source_type_id
  and flds.SOURCE_COLUMN_NAME = l_source_field
  and flds.attb_lov_id = lovb.attb_lov_id
  and lovb.CREATION_TYPE = 'USER'
  and lovb.attb_lov_id = valb.attb_lov_id;
l_lov_code  varchar2(60);
l_numb number := 1;
cursor c_alias is
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id;

  l_operator VARCHAR2(255);
  l_position  number;
  l_left_operand_rec c_left_oprand%rowtype;
  l_left_operand VARCHAR2(2000);
  l_cond_count number := 0;
  l_value_count number := 0;

  l_param_count number := 0;
  l_cond_conn varchar2(20);
  l_or  	varchar2(30) := ' OR ';
  l_test	varchar2(100);
  l_count	number := 0;
  l_code_tbl    JTF_VARCHAR2_TABLE_100;
  l_meaning_tbl JTF_VARCHAR2_TABLE_100;
  l_param_remove_count number := 0;
  l_p_count number := 0;
  l_tot_count	number := 0;
  l_tot_loop	number := 0;

begin

  Ams_Utility_Pvt.Write_Conc_log('start gen_lov_filter_for_templmv');
  for l_qualify_cond_rec IN c_qualify_conds
        loop
          begin
      Ams_Utility_Pvt.Write_Conc_log('l_cond_count =  '||l_cond_count);
      if l_cond_count > 0 then
        -- x_filter_sql := x_filter_sql || 'and (';
        x_filter_sql := x_filter_sql || 'OR (';
        Ams_Utility_Pvt.Write_Conc_log('x_filter_sql =  '||x_filter_sql);
      else
        x_filter_sql := x_filter_sql || '(';
        Ams_Utility_Pvt.Write_Conc_log('x_filter_sql =  '||x_filter_sql);
      end if;
      l_cond_count := l_cond_count + 1;

      l_value_count := 0;

      open c_left_oprand (l_qualify_cond_rec.cond_id);
      fetch c_left_oprand into l_left_operand_rec;
      close c_left_oprand;
      Ams_Utility_Pvt.Write_Conc_log('After c_left_oprand list_source_type_id =  '||l_left_operand_rec.list_source_type_id);

      l_qa_id           := null;
      l_object_name 	:= null;
      l_object_alias	:= null;

      open c_alias;
      Loop
	fetch c_alias into l_qa_id,l_object_name,l_object_alias;
        exit when c_alias%notfound;
        if l_object_name =  l_left_operand_rec.table_name then
		exit;
        end if;
      End loop;
      close c_alias;

      l_left_operand := ' UPPER('||l_object_alias || '.' || l_left_operand_rec.attr_name||')';
        Ams_Utility_Pvt.Write_Conc_log('l_left_operand =  '||l_left_operand);
     --  l_left_operand := l_left_operand_rec.table_name || '.' || l_left_operand_rec.attr_name;
      open c_operator (l_qualify_cond_rec.cond_id);
     loop
      fetch c_operator into l_operator;
      exit when c_operator%notfound;
      Ams_Utility_Pvt.Write_Conc_log('After c_operator-- l_operator =  '||l_operator);

      if l_operator in ('IS', 'IN', 'LIKE','=') then
        l_operator := ' LIKE ';
        l_cond_conn := ' or ';
      end if;
     end loop;
      if l_operator is null and l_cond_conn is null then
        -- l_operator := ' NOT IN ';
        -- l_cond_conn := ' and ';
        l_operator := ' LIKE ';
        l_cond_conn := ' or ';
      end if;
      close c_operator;
      Ams_Utility_Pvt.Write_Conc_log('After c_operator LOOP -- l_operator =  '||l_operator);
      Ams_Utility_Pvt.Write_Conc_log('After c_operator LOOP -- l_cond_conn=  '||l_cond_conn);


      open c_lov_values (l_qualify_cond_rec.cond_id);
      loop
          fetch c_lov_values into l_test;
          exit when c_lov_values%notfound ;
          -- l_count := l_count + 1;
          l_tot_count := l_tot_count + 1;
      end loop;
      close c_lov_values;
      Ams_Utility_Pvt.Write_Conc_log('***** After c_lov_values LOOP -- l_count =  '||l_count);
      Ams_Utility_Pvt.Write_Conc_log('***** After c_lov_values LOOP -- l_tot_count =  '||l_tot_count);

      -- if l_count = 0 then
      if l_tot_count = 0 then
         Ams_Utility_Pvt.Write_Conc_log('After c_lov_values --SELECT ALL is used for lov values ');
         open c_lov_type(l_left_operand_rec.list_source_type_id,l_left_operand_rec.attr_name);
 	 fetch c_lov_type into l_lov_type;
         close c_lov_type;
         Ams_Utility_Pvt.Write_Conc_log('LOV type -- l_lov_type  =  '||l_lov_type);
         if l_lov_type = 'SQL' then
             open c_lov_sql(l_left_operand_rec.list_source_type_id,l_left_operand_rec.attr_name);
             fetch c_lov_sql into l_lov_sql;
             close c_lov_sql;
             Ams_Utility_Pvt.Write_Conc_log(' l_lov_sql =  '||l_lov_sql);
             l_position := instrb(upper(l_lov_sql),'FROM');
             Ams_Utility_Pvt.Write_Conc_log(' l_position =  '||l_position);
             l_final_lov_sql := substr(l_lov_sql,1,l_position - 1)||' BULK COLLECT INTO :1 ,:2 '||substr(l_lov_sql,l_position);
             Ams_Utility_Pvt.Write_Conc_log(' l_final_lov_sql =  '||l_final_lov_sql);
             EXECUTE IMMEDIATE 'BEGIN '||l_final_lov_sql||' ; END; '  USING OUT l_code_tbl ,OUT l_meaning_tbl;
             Ams_Utility_Pvt.Write_Conc_log(' l_code_tbl.count =  '||l_code_tbl.count);
         end if;
         if l_lov_type = 'USER' then
            Ams_Utility_Pvt.Write_Conc_log(' (l_left_operand_rec.list_source_type_id  =  '||l_left_operand_rec.list_source_type_id);
            Ams_Utility_Pvt.Write_Conc_log(' (l_left_operand_rec.attr_name  =  '||l_left_operand_rec.attr_name);

            EXECUTE IMMEDIATE ' BEGIN  select valb.value_code '||' BULK COLLECT INTO :1 '||
            ' from ams_list_src_fields flds ,ams_attb_lov_b lovb, ams_attb_lov_values_b valb'||
            ' where flds.LIST_SOURCE_TYPE_ID = :2'||
            ' and flds.SOURCE_COLUMN_NAME = :3 '||
            ' and flds.attb_lov_id = lovb.attb_lov_id and lovb.CREATION_TYPE = '||''''|| 'USER'||''''||
            ' and lovb.attb_lov_id = valb.attb_lov_id ; END; ' USING OUT l_code_tbl, IN l_left_operand_rec.list_source_type_id, l_left_operand_rec.attr_name;
         end if;
         Ams_Utility_Pvt.Write_Conc_log(' l_code_tbl.count =  '||l_code_tbl.count);
         for i in 1 .. l_code_tbl.count
         loop
            Ams_Utility_Pvt.Write_Conc_log(' l_code_tbl(i) =  '||l_code_tbl(i));
         end loop;
-- [[[[[[[[[[[[[[[[[[
         l_tot_loop := 0;
         for i in 1 .. l_code_tbl.count
         loop
--         Ams_Utility_Pvt.Write_Conc_log(' coming in l_code_tbl.count LOOP ');
           l_tot_loop := l_tot_loop + 1;
           begin
           x_string_params (l_param_count + 1) :=  l_code_tbl(i);
            -- dbms_output.put_line('l_param_count  = '|| l_param_count);
            -- if l_param_count = l_count then
            -- if l_param_count+1 = l_code_tbl.count then
            Ams_Utility_Pvt.Write_Conc_log(' l_p_count =  '||l_p_count);
            Ams_Utility_Pvt.Write_Conc_log(' l_tot_loop =  '||l_tot_loop);
            if (l_param_count+1 = l_code_tbl.count + l_p_count) or (l_tot_count = l_tot_loop) then
            Ams_Utility_Pvt.Write_Conc_log(' l_param_count+1 '||to_char(l_param_count+1));
              l_or := ' ';
            else
              l_or := ' OR ';
            end if;
            if l_value_count > 0 then
              x_filter_sql := x_filter_sql ||  l_cond_conn || l_left_operand || l_operator
              || ' UPPER( :' || to_char(l_param_count+1)||' ) '||l_or;
               -- dbms_output.put_line('>0 x_filter_sql = '|| x_filter_sql);
            else
              x_filter_sql := x_filter_sql || l_left_operand || l_operator
              || ' UPPER( :' || to_char(l_param_count+1)|| ' ) '||l_or;
              -- dbms_output.put_line('0else x_filter_sql = '|| x_filter_sql);
            end if;

            l_param_count := l_param_count + 1;
            -- dbms_output.put_line('l_param_count = '|| l_param_count);
           end;
          end loop;
          l_p_count := l_param_count;
          Ams_Utility_Pvt.Write_Conc_log('x_num_params = '||x_num_params);
-- [[[[[[[[[[[[[[[[
          -- l_param_remove_count := l_param_remove_count + l_param_count;
          -- l_param_remove_count := l_param_remove_count + l_p_count ;
          l_param_remove_count :=  l_p_count ;
            Ams_Utility_Pvt.Write_Conc_log('in 000 l_param_remove_count =  '||l_param_remove_count);
      end if; -- l_count = 0

     -- if l_count > 0 then
     if l_tot_count > 0 then
      l_tot_loop := 0;
      for l_lov_values_rec in c_lov_values (l_qualify_cond_rec.cond_id)
      loop
        begin
          l_tot_loop := l_tot_loop +1;
          x_string_params (l_param_count + 1) := l_lov_values_rec.lov_value;
          -- if l_param_count = l_count then
           -- if l_param_count+1 - l_param_remove_count = l_count then
            Ams_Utility_Pvt.Write_Conc_log(' l_param_remove_count =  '||l_param_remove_count);
            Ams_Utility_Pvt.Write_Conc_log(' l_param_count =  '||l_param_count);
            Ams_Utility_Pvt.Write_Conc_log(' l_p_count =  '||l_p_count);
            Ams_Utility_Pvt.Write_Conc_log(' l_tot_loop =  '||l_tot_loop );
           -- if l_param_count+1 - l_param_remove_count = l_count  then
           if (l_param_count+1 - l_param_remove_count = l_tot_count) or (l_tot_count = l_tot_loop) then
             l_or := ' ';
           else
	     l_or := ' OR ';
          end if;
          if l_value_count > 0 then
            x_filter_sql := x_filter_sql ||  l_cond_conn || l_left_operand || l_operator
              || ' UPPER(  :' || to_char(l_param_count+1)||' ) '||l_or;
            -- dbms_output.put_line('>0 x_filter_sql = '|| x_filter_sql);
          else
            x_filter_sql := x_filter_sql || l_left_operand || l_operator
              || ' UPPER( :' || to_char(l_param_count+1)|| ' ) '||l_or;
            -- dbms_output.put_line('0else x_filter_sql = '|| x_filter_sql);
          end if;

          l_param_count := l_param_count + 1;
          -- dbms_output.put_line('l_param_count = '|| l_param_count);
        end;
      end loop;
      l_p_count := l_param_count;
     end if; -- l_count > 0
     l_tot_count := 0;
  --    x_filter_sql := '('||x_filter_sql || '))';
      x_filter_sql := x_filter_sql || ')';
    end;
  end loop; -- c_qualify_conds
  x_filter_sql := '('||x_filter_sql || ')';
  x_num_params := l_param_count ;
  Ams_Utility_Pvt.Write_Conc_log('Final x_num_params = '||x_num_params);
  Ams_Utility_Pvt.Write_Conc_log('end gen_lov_filter_for_templmv');

EXCEPTION
 WHEN OTHERS THEN
  Ams_Utility_Pvt.Write_Conc_log('Exception in gen_lov_filter_for_templmv : '||SQLERRM);
   -- errbuf:= substr(SQLERRM,1,254);
   --retcode:= 2;
   raise;
end;
-- ---------------------------------------------------------

PROCEDURE gen_constant_filter (
                            x_filter_sql    IN OUT NOCOPY      VARCHAR2,
                            x_string_params IN OUT NOCOPY sql_string_4k,
                            x_num_params    IN OUT NOCOPY        NUMBER,
                            p_template_id   IN   NUMBER
                            ) IS
--Query conditions
CURSOR C_query_cond_main IS
select cond.query_condition_id cond_id, count(*)
  from AMS_QUERY_CONDITION cond, AMS_QUERY_COND_DISP_STRUCT_all struct,
       AMS_COND_STRUCT_RESTRICT_VALUE res_values
 where cond.template_id = p_template_id
   and cond.value1_type = 'CONSTANT'
   and struct.QUERY_CONDITION_ID = cond.query_condition_id
   and struct.QUERY_COND_DISP_STRUCT_ID = res_values.query_cond_disp_struct_id
   and struct.token_type= 'OPERATOR'
   and cond.mandatory_flag = 'Y'
 group by cond.query_condition_id
having count(*) = 1;

--Operand
  CURSOR C_left_oprand (p_cond_id NUMBER) IS
    select  struct.non_variant_value  attr_name, source_object_name table_name, src_types.list_source_type_id
    from AMS_QUERY_COND_DISP_STRUCT_all struct, AMS_QUERY_ALIAS alias, ams_list_src_types src_types
    where struct.query_condition_id = p_cond_id
    and struct.token_type = 'ATTRIBUTE'
    and alias.query_alias_id = struct.query_alias_id
    and alias.OBJECT_NAME = src_types.SOURCE_TYPE_CODE;

--Operator
CURSOR C_operator(p_query_cond_id NUMBER) IS
    select upper(res_values.code) operator, count(*)
    from AMS_QUERY_COND_DISP_STRUCT_all struct, AMS_COND_STRUCT_RESTRICT_VALUE res_values
    where struct.query_condition_id = p_query_cond_id and
    struct.token_type = 'OPERATOR'
    and struct.QUERY_COND_DISP_STRUCT_ID = res_values.query_cond_disp_struct_id
	group by upper(res_values.code)
	having count(*) = 1; --has only one operator

--Values
CURSOR C_display_values(p_query_cond_id NUMBER) IS
    select display_text
    from AMS_QUERY_COND_DISP_STRUCT_vl struct
    where struct.query_condition_id = p_query_cond_id and
    struct.token_type in ('VALUE1');

CURSOR C_display_value2(p_query_cond_id NUMBER) IS
    select display_text
    from AMS_QUERY_COND_DISP_STRUCT_vl struct
    where struct.query_condition_id = p_query_cond_id and
    struct.token_type in ('VALUE2');

--Alias
CURSOR C_alias(p_template_id NUMBER) IS
select distinct alias2.query_alias_id,alias2.source_object_name, alias2.line_num
from
(SELECT  distinct non_variant_value, query_alias_id
 from AMS_QUERY_COND_DISP_STRUCT_vl
  where query_template_id = p_template_id and token_type in ('ATTRIBUTE','VALUE1','VALUE2')
     and query_alias_id is not null) alias1,
(select alias.query_alias_id, types.source_object_name, types.master_source_type_flag,types.source_object_pk_field,
'A'||to_char(rownum) line_num
from AMS_QUERY_ALIAS alias,ams_list_src_types types
where alias.template_id = p_template_id
  and alias.object_name = types.source_type_code
order by alias.query_alias_id) alias2
where alias1.query_alias_id = alias2.query_alias_id;

  l_dummy number;
  l_query_cond_id number;
  l_cond_count number := 0;
  l_num_params number := 0;
  l_left_operand_rec C_left_oprand%rowtype;
  l_left_operand VARCHAR2(2000);
  l_operator varchar2(255);

  l_qa_id   	number;
  l_object_name 	varchar2(60);
  l_object_alias	varchar2(30);

  l_value1 varchar2(2000);
  l_value2 varchar2(2000);

BEGIN
  Ams_Utility_Pvt.Write_Conc_log('Start gen_constant_filter');

  l_num_params := x_num_params;
  l_cond_count := x_num_params;

  if l_cond_count = 0 then
     x_filter_sql := null;
  end if;

  --Loop thru each mandatory condition having one operator
  --and a value associated with it
  FOR cond_rec IN C_query_cond_main LOOP

    Ams_Utility_Pvt.Write_Conc_log('Processing cond_id: '||cond_rec.cond_id);

    --resetting variables
    l_value1 := null;
    l_value2 := null;
    l_operator := null;
    l_left_operand := null;

      -------
      --start building the filter_sql
      if l_cond_count > 0 then
         x_filter_sql := x_filter_sql || ' AND (';
         Ams_Utility_Pvt.Write_Conc_log('x_filter_sql =  '||x_filter_sql);
      else
         x_filter_sql := x_filter_sql || '(';
         Ams_Utility_Pvt.Write_Conc_log('x_filter_sql =  '||x_filter_sql);
      end if;

      l_cond_count := l_cond_count + 1;
      -------
      --Get the letf operand value
      open C_left_oprand (cond_rec.cond_id);
      fetch C_left_oprand into l_left_operand_rec;
      close C_left_oprand;
      Ams_Utility_Pvt.Write_Conc_log('Left Operand: '||l_left_operand_rec.table_name||'.'||l_left_operand_rec.attr_name
	                                  ||' list_source_type_id =  '||l_left_operand_rec.list_source_type_id);

      l_qa_id           := null;
      l_object_name 	:= null;
      l_object_alias	:= null;
      -------
      --Get attribute and table name and alias
      OPEN C_alias(p_template_id);
      LOOP
        fetch C_alias into l_qa_id,l_object_name,l_object_alias;
        exit when C_alias%notfound;
          if l_object_name =  l_left_operand_rec.table_name then
		exit;
        end if;
      END LOOP;
      CLOSE C_alias;

      l_left_operand := 'UPPER('||l_object_alias || '.' || l_left_operand_rec.attr_name||') ';
      Ams_Utility_Pvt.Write_Conc_log('l_left_operand =  '||l_left_operand);

      -------
      --Get Operator
      OPEN C_operator(cond_rec.cond_id);
      FETCH C_operator INTO l_operator, l_dummy;
      CLOSE C_operator;

      Ams_Utility_Pvt.Write_Conc_log('Operator =  '||l_operator);

      IF l_operator is not null THEN

         IF l_operator <> 'IN' THEN
            OPEN C_display_values(cond_rec.cond_id);
            FETCH C_display_values INTO l_value1;
            CLOSE C_display_values;
            Ams_Utility_Pvt.Write_Conc_log('Value1 = '||l_value1);
	 END IF;

         IF l_operator = 'BETWEEN' THEN

           OPEN C_display_value2(cond_rec.cond_id);
           FETCH C_display_value2 INTO l_value2;
           CLOSE C_display_value2;
           Ams_Utility_Pvt.Write_Conc_log('Value2 = '||l_value2);

         END IF;
      ELSE --if l_operator is not null
        Ams_Utility_Pvt.Write_Conc_log('** Operator is null.. **');
      END IF;

      --Build filter clause
      -------
      IF l_operator is not null then
      if l_value1 is not null and l_operator <> 'BETWEEN' then
         l_num_params := l_num_params + 1;
         x_filter_sql := x_filter_sql || l_left_operand || ' ' ||l_operator
                         || ' UPPER(:'|| to_char(l_num_params) ||')) ';
         x_string_params (l_num_params) := l_value1;

      elsif l_value2 is not null and l_operator = 'BETWEEN' then
         l_num_params := l_num_params + 2;
         x_filter_sql := x_filter_sql ||l_left_operand || ' ' ||l_operator
                         || ' UPPER(:'|| to_char(l_num_params-1) ||') AND UPPER(:'|| to_char(l_num_params) ||')) ' ;
         x_string_params (l_num_params-1) := l_value1;
         x_string_params (l_num_params) := l_value2;
      end if;
      end if;

  END LOOP;
      x_num_params := l_num_params;
      Ams_Utility_Pvt.Write_Conc_log('Final param count: '||to_char(x_num_params));
      Ams_Utility_Pvt.Write_Conc_log('Final filter sql : '||x_filter_sql);
      Ams_Utility_Pvt.Write_Conc_log('End gen_constant_filter.');

EXCEPTION
 WHEN OTHERS THEN
  Ams_Utility_Pvt.Write_Conc_log('Exception in gen_constant_filter : '||SQLERRM);
  Raise;

END gen_constant_filter;
------------------------------------

END AMS_List_running_total_pvt;

/
