--------------------------------------------------------
--  DDL for Package Body EDW_OPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OPTION" as
/* $Header: EDWCFIGB.pls 115.9 2003/11/18 07:00:05 smulye noship $  */


function get_warehouse_option(p_object_name varchar2, p_object_id number,p_option_code varchar2,
p_option_value out nocopy varchar2) return boolean is
l_object_id number(9);
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
check_tspace_exist varchar(1);
check_ts_mode varchar(1);
physical_tspace_name varchar2(100);

begin
  p_option_value :=null;

  if (p_option_code='DEBUG') then
	p_option_value:=fnd_profile.value('EDW_DEBUG');
  elsif  (p_option_code='TRACE') then
	p_option_value:=fnd_profile.value('EDW_TRACE');
  elsif  (p_option_code='DUPLICATE') then
	p_option_value:=fnd_profile.value('EDW_DUPLICATE_COLLECT');
  elsif  (p_option_code='HASHAREA') then
	p_option_value:=fnd_profile.value('EDW_HASH_AREA_SIZE');
  elsif  (p_option_code='SORTAREA') then
	p_option_value:=fnd_profile.value('EDW_EDW_SORT_AREA_SIZE');
  elsif  (p_option_code='KEYSETSIZE') then
	p_option_value:=fnd_profile.value('EDW_FK_SET_SIZE');
  elsif  (p_option_code='FRESHSTART') then
	p_option_value:=fnd_profile.value('EDW_FRESH_RESTART');
  elsif  (p_option_code='UPDATETYPE') then
	p_option_value:=fnd_profile.value('EDW_UPDATE_TYPE');
  elsif  (p_option_code='OPTABLESPACE') then
	p_option_value:=fnd_profile.value('EDW_OP_TABLE_SPACE');
  elsif  (p_option_code='FK_USE_NL') then
	p_option_value:=fnd_profile.value('EDW_FK_USE_NL');
  elsif  (p_option_code='SMARTUPDATE') then
	p_option_value:=fnd_profile.value('EDW_SMART_UPDATE');
  elsif  (p_option_code='LTC_COPY_MERGE_NL') then
	p_option_value:=fnd_profile.value('EDW_LTC_COPY_MERGE_NL');
  elsif  (p_option_code='COMMITSIZE') then
	p_option_value:=fnd_profile.value('EDW_COLLECTION_SIZE');
  elsif  (p_option_code='PARALLELISM') then
	p_option_value:=fnd_profile.value('EDW_PARALLEL');
  elsif  (p_option_code='DANGLING') then
	p_option_value:=fnd_profile.value('EDW_TEST_MODE');
  elsif  (p_option_code='ROLLBACK') then
	p_option_value:=fnd_profile.value('EDW_LOAD_ROLLBACK');
  end if;

  if (p_option_code='HASHAREA' and p_option_value is null) then
   select  param.value into p_option_value from v$parameter param
     where param.name='hash_area_size';
  end if;

  if (p_option_code='SORTAREA' and p_option_value is null) then
   select param.value into p_option_value from v$parameter param
     where param.name='sort_area_size';
  end if;

  if (p_option_code='OPTABLESPACE' and p_option_value is null) then
    	AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
	If check_ts_mode ='Y' then
		AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
		if check_tspace_exist='Y' and physical_tspace_name is not null then
			p_option_value :=  physical_tspace_name;
		end if;
	end if;
        if p_option_value is null then
	   select default_tablespace into p_option_value from dba_users where
	   username=EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');
        end if;

  end if;

  return true;

Exception when others then
  g_status_message:=sqlerrm;
  edw_owb_collection_util.write_to_log_file_n('Error in get_warehouse_option '||sqlerrm);
  return false;
end get_warehouse_option;

function get_option_columns(p_object_name varchar2, p_object_id number,p_option_code varchar2,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_option_cols out nocopy number) return boolean is
l_object_id number(9);
l_stmt varchar2(5000);
l_option_fk_key number;
l_option_value varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
begin
  p_number_option_cols:=0;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  edw_owb_collection_util.write_to_log_file_n('Error in get_option_columns '||sqlerrm);
  return false;
end get_option_columns;

function get_fk_dangling_load(p_object_id number,p_option_fk_key number,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_option_cols out nocopy number)
return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
l_option_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_option_values EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_option_cols number;
Begin
  p_number_option_cols:=0;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  edw_owb_collection_util.write_to_log_file_n('Error in get_fk_dangling_load '||sqlerrm);
  return false;
End;

function get_level_skip_update(p_object_id number,p_option_fk_key number,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_option_cols out nocopy number)
return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_option_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_option_values EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_option_cols number;
Begin
  p_number_option_cols:=0;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  edw_owb_collection_util.write_to_log_file_n('Error in get_level_skip_update '||sqlerrm);
  return false;
End;


function get_level_skip_delete(p_object_id number,p_option_fk_key number,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_option_cols out nocopy number)
return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_option_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_option_values EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_option_cols number;
Begin
  p_number_option_cols:=0;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  edw_owb_collection_util.write_to_log_file_n('Error in get_level_skip_delete '||sqlerrm);
  return false;
End;

function get_time return varchar2 is
begin
 return '  '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Exception in  get_time '||sqlerrm);
  return null;
End;

procedure write_to_log_file(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('   ');
  write_to_log_file(p_message);
Exception when others then
  null;
End;

procedure set_debug(p_debug boolean) is
Begin
 g_debug:=p_debug;
Exception when others then
  null;
End;

FUNCTION get_object_type (p_object_id IN NUMBER)
      RETURN varchar2
   IS
      l_stmt          VARCHAR2 (5000);
      l_object_type   VARCHAR2 (30);
      TYPE curtyp IS REF CURSOR;
      cv              curtyp;
      l_status        BOOLEAN;
   BEGIN

      l_stmt :=    'select ''DIMENSION'' from cmpwbdimension_v'
                || ' where elementid=:d '
                || ' union '
                || ' select ''FACT'' from cmpwbcube_v'
                || ' where elementid=:f ';
      OPEN cv FOR l_stmt USING p_object_id, p_object_id;
      FETCH cv INTO l_object_type;
      CLOSE cv;

      IF    l_object_type = 'DIMENSION'
         OR l_object_type = 'FACT'
      THEN
	 null;
      ELSE
         l_object_type := 'FACT';
      END IF;

      RETURN l_object_type;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            CLOSE cv;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
         l_object_type := 'FACT';
         RETURN l_object_type;

      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cv;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
         l_object_type := 'FACT';
         RETURN l_object_type;
   END get_object_type;


end;

/
