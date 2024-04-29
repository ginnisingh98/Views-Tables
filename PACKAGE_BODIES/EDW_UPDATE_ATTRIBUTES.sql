--------------------------------------------------------
--  DDL for Package Body EDW_UPDATE_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_UPDATE_ATTRIBUTES" AS
/* $Header: EDWVCONB.pls 120.0 2005/06/01 16:00:15 appldev noship $ */
---+==========================================================================+
---|  Copyright (c) 1995 Oracle Corporation Belmont, California, USA          |
---|                       All rights reserved                                |
---+==========================================================================+
---|                                                                          |
---| FILENAME                                                                 |
---|      EDWVCONB.pls                                                        |
---|                                                                          |
---| DESCRIPTION                                                              |
---|                                                                          |
---| PUBLIC PROCEDURES                                                        |
---|                                                                          |
---| PUBLIC FUNCTIONS                                                         |
---|                                                                          |
---| PRIVATE PROCEDURES                                                       |
---|                                                                          |
---| PRIVATE FUNCTIONS                                                        |
---|                                                                          |
---| HISTORY                                                                  |
---|    15-01-2000 Walid.Nasrallah started logging changes per management     |
---|               directive.  Removed restriction to 11i version to allow    |
---|               back-porting.                                              |
---|                                                                          |
---|    smulye						     04-Sep-03	      |
---|	Changed   API update_stg to use profile option UTL_FILE_LOG           |
---|	Bug 2903252    							      |
---|    smulye						     17-Nov-03	      |
---|	changed API update_stg to use AD APIs to get temporary tablespace name|
---|	Bug 2759144    							      |
---|    amitgupt                                                 13-FEB-2004  |
---|     changed queries involiving data dictionary for Bug 3431744           |
---|    14-12-04   Amitgupt   bug fix 4080618                                 |
---+==========================================================================*



g_where_clause dbms_sql.varchar2_table;

g_total_seconds number := 0;
g_time_start date;
g_time_end date;

g_separate_logging boolean := false;

TYPE tableInfo is RECORD(
	column_name	VARCHAR2(150),
	table_name	VARCHAR2(150));

TYPE tab_info is TABLE of tableInfo
	INDEX BY BINARY_INTEGER;
g_counter number := 0;

Procedure writelog(p_msg IN VARCHAR2) IS

l_count number;
l_length number;

begin
	IF (not g_separate_logging) THEN
		edw_owb_collection_util.write_to_log_file(p_msg);
		return;
	END IF;

	l_count := 0;
	l_length := length(p_msg);
	loop
		utl_file.put_line(g_file, substr(p_msg,l_count * 255+1, 255 ));
		l_count := l_count +1 ;
		exit when ((l_count*255) > l_length) OR l_count > 4;
	end loop;
	utl_file.fflush(g_file);

end;

Procedure drop_temp_tables(l_table_list in dbms_sql.varchar2_table) IS

l_count number := 0;
BEGIN

	IF (l_table_list.count = 0) THEN
		return;
	END IF;

	l_count := l_table_list.first;

	LOOP
		BEGIN
		  execute immediate 'drop table '||l_table_list(l_count);
		  EXIT when l_count = l_table_list.last;
		  l_count := l_table_list.next(l_count);

		EXCEPTION WHEN OTHERS THEN
			null;
		END;
	END LOOP;

END;

FUNCTION mapping_exists(l_object_name IN VARCHAR2, l_level_name IN VARCHAR2) return BOOLEAN IS

l_map_count number := 0;
BEGIN

	SELECT count (1) into l_map_count
	FROM EDW_ATTRIBUTE_MAPPINGS ATTR, EDW_FLEX_ATTRIBUTE_MAPPINGS FLEX
	WHERE ATTR.ATTR_MAPPING_PK = FLEX.ATTR_MAPPING_FK
	AND ATTR.OBJECT_SHORT_NAME = l_object_name
	AND NVL(ATTR.LEVEL_NAME, 'null') = NVL(l_level_name, 'null')
	AND FLEX.VALUE_SET_TYPE = 'F';

	IF (l_map_count > 0) then
		return true;
	END IF;
	return false;
END;


FUNCTION add_db_links_to_string(p_table IN VARCHAR2, p_link IN VARCHAR2) return VARCHAR2 IS

bSingleTable boolean := false;

l_pos1 number := null;
l_pos2 number := null;

--p_link varchar2(100) := 'apps_to_apps';
--p_table varchar2(1000) := 'per_people_f ppf   ,  per_person_types   ppt  ,   hr_all_organization_units    , hello_world     hw';

l_current_table varchar2(200);
l_count number := 0;

l_input_table varchar2(3000);

l_tables dbms_sql.varchar2_table;
l_alias  dbms_sql.varchar2_table;

l_output_table varchar2(3000);

BEGIN


  l_input_table := p_table||',';
  IF (instr(l_input_table, ',') = 0 ) THEN
	bSingleTable := true;
  ELSE

	 l_input_table := replace (l_input_table, ' ,', ',');
	 l_input_table := replace (l_input_table, '  ', ' ');
	 l_input_table := replace (l_input_table, ', ', ',');
	 l_pos1 := instr(l_input_table, ' ,');
	 l_pos2 := instr(l_input_table, '  ');

  END IF;

  l_count := 0;


  loop

	exit when l_input_table is null or l_count > 6;
	l_count := l_count + 1;

	l_current_table := substr(l_input_table, 0, instr(l_input_table, ','));
	IF (l_current_table IS NULL) then -- last table
		l_current_table := l_input_table;
	EnD IF;

	l_pos1 := instr(l_current_table, ' '); -- check if alias exists
	l_pos2 := instr(l_current_table, ',');


	IF (l_pos1 > 0) THEN -- alias exists
		l_tables(l_count) := trim(substr(l_current_table, 0, instr(l_current_table, ' ')));
		l_alias(l_count) := trim(substr(l_current_table, l_pos1, length(l_current_table)-l_pos1));
	ELSE
		l_tables(L_count) := trim(substr(l_current_table, 0, instr(l_current_Table, ',')-1));
		l_alias(l_count) := null;
	END IF;
	l_input_table := trim(substr(l_input_table, l_pos2+1, length(l_input_table) - l_pos2));


	IF (l_count > 1) THEN
		l_output_table := l_output_table||', ';
	END IF;
	IF (l_tables(l_count)<>',') THEN
		l_output_table := l_output_table||l_tables(l_count)||'@'||p_link||' '||l_alias(l_count);
	END IF;
  end loop;

	return l_output_table;

END;





Function add_links_to_where(p_where IN VARCHAR2, p_link IN VARCHAR2) RETURN VARCHAR2 IS
l_newline varchar2(10):='
';

l_temp varchar2(1000);
l_from number := 0;
l_open number := 0;
l_close number := 0;
l_where number := 0;

l_end number := 0;

l_buffer varchar2(32000);
l_input varchar2(30000);
l_output varchar2(32000):= null;
l_count number:=0;

l_attach varchar2(1000) := null;

l_file  utl_file.file_type;

l_tables varchar2(1000);


BEGIN

		l_input := p_where;
		l_input  := replace(l_input, l_newline, ' ');

		loop
		        l_input := replace(l_input, '	', ' ');
			exit when instr(l_input, '	')=0;
		end loop;

		l_output := null;
		l_buffer := l_input;

		LOOP

			writelog( l_newline);
			writelog('l_buffer0 = '||l_buffer);

			l_from := instr(lower(l_buffer), ' from ');

			writelog( 'l_buffer='||l_buffer);
			writelog( 'l_from = '||l_from);

			IF (l_from = 0 ) THEN
				l_output := l_output||l_buffer;
				exit;
			END IF;


			l_output := l_output||' '||substr(l_buffer, 0, l_from+5);

			l_buffer := substr(l_buffer, l_from+6, length(l_buffer));

			l_open := instr(l_buffer, '(');
			l_close := instr (l_buffer, ')');
			l_where := instr(l_buffer, ' where ');

			IF (l_open = 0) THEN l_open := 1000000; END IF;
			IF (l_close = 0) THEN l_close := 1000000; END IF;
			IF (l_where = 0) THEN l_where := 1000000; END IF;



			l_end := l_open;

			IF (l_end > l_close) THEN l_end := l_close; END IF;
			IF (l_end > l_where ) THEN l_end := l_where; END IF;


			writelog( 'l_open='||l_open||', l_close='||l_close
					||', l_where='||l_where ||', l_end='||l_end);

			l_tables := substr(l_buffer, 0,  l_end-1);

			writelog( 'l_tables = '||l_tables);
			l_tables := edw_update_attributes.add_db_links_to_string(l_tables, p_link);
			l_output := l_output||l_tables;

			l_buffer := substr(l_buffer, l_end, length(l_buffer));

			writelog('l_buffer at the end of loop = '||l_buffer);
			writelog( 'Output String so far is '||l_newline||l_output);

			l_count := l_count+1;
		END LOOP;

	writelog('Final Output = '||l_output);
	return l_output;


END;


Function checkWhereClause(p_value_set_id in NUMBER, p_link in varchar2) return boolean IS

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;

l_cursor number;
l_chunk_size          number:=30000;
l_chunk_size_returned number;
l_stmt                varchar2(2000);
l_cur_pos             number:=0;
l_rows                number;
l_dummy               number;
l_data_chunk          varchar2(30000);
l_count number := 0;
l_newline varchar2(10):='
';

l_temp varchar2(1000);
l_pos1 number := 0;
l_pos2 number := 0;

BEGIN


	writelog('Inside checkWhereClause');
	l_stmt := 'select additional_where_clause from fnd_flex_validation_tables@'||
		p_link||' where flex_value_set_id = :vsid';

	writelog(l_stmt);

	l_cursor:=dbms_sql.open_cursor;
	dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
  	dbms_sql.bind_variable(l_cursor, ':vsid', p_value_set_id);
	dbms_sql.define_column_long(l_cursor,1);

	  l_dummy:=dbms_sql.execute(l_cursor);
	  l_rows:=dbms_sql.fetch_rows(l_cursor);

	  loop
	    -- fetch 'chunks' of the long until we have got the lot


	    dbms_sql.column_value_long(l_cursor,1,l_chunk_size,l_cur_pos,l_data_chunk,l_chunk_size_returned);

	    IF (upper(l_data_chunk) like '%$FLEX$' OR l_data_chunk like '%$PROFILE$%') THEN
		return false;
	    END IF;


	    l_cur_pos:=l_cur_pos+l_chunk_size;
	    exit when l_chunk_size_returned=0;
	    l_data_chunk := replace(l_data_chunk, l_newline, ' ');
	    l_data_chunk := replace(l_data_chunk, '	', ' ');


		-- from clause exists
 		IF (lower(l_data_chunk) like '% from %') THEN
			writelog('From exists in the where clause');
			l_data_chunk := add_links_to_where(l_data_chunk, p_link);
			writelog('Modified data chunk is : '||l_data_chunk);
		END IF;

	    g_where_clause(l_count):=l_data_chunk;
		l_count:= l_count +1;
	  end loop;
  g_where_clause(0) := ltrim(g_where_clause(0));


  writelog('WHERE Clause is '||g_where_clause(0));

  IF (lower(substr(g_where_clause(0), 0, 5) ) = 'where') THEN
	null;
  ELSIF (lower(substr(g_where_clause(0), 0, 8) ) = 'order by') THEN
	--g_where_clause(0) := null;
	null;
  ELSE

	g_where_clause(0) := ' where '||g_where_clause(0);
  END IF;

  dbms_sql.close_cursor(l_cursor);

  return true;

END;





FUNCTION getDBLink(p_instance IN VARCHAR2) RETURN VARCHAR2 IS
l_dblink varchar2(100);
BEGIN

	SELECT warehouse_to_instance_link INTO l_dblink
	FROM   edw_source_instances_vl
	WHERE  instance_code = p_instance;
	return l_dblink;
END;

FUNCTION findColumn(p_object IN VARCHAR2, p_column_like IN VARCHAR2, p_link IN VARCHAR2)
RETURN VARCHAR2 IS
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2 (1000);
l_col varchar2(200);
BEGIN
	writelog('');
	writelog ('Inside findColumn');

	l_stmt := 'select column_name from user_tab_columns';
	IF (p_link is not null) then
		l_stmt := l_stmt ||'@'||p_link;
	END IF;

        l_stmt := l_stmt || ' where table_name = :s1 and column_name like :s2';

	OPEN CV for l_stmt using p_object, '%'||p_column_like;
	FETCH cv into l_col;
	CLOSE CV;

	writelog('Returning column='||l_col);
	writelog('');
	return l_col;

END;


PROCEDURE drop_temp_table (p_schema IN VARCHAR2, p_table_name IN VARCHAR2) IS

BEGIN
	execute immediate 'drop table '||p_schema||'.'||p_table_name;
	exception when others then
		null;

END;



PROCEDURE get_table_validated_clause(p_vsid IN VARCHAR2, p_link IN VARCHAR2, p_tab_clause OUT NOCOPY VARCHAR2, p_id_col_exists OUT NOCOPY boolean) IS
l_clause varchar2(4000);
l_stmt varchar2(4000);

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_table_name varchar2(1000);
l_value_col  varchar2(100);
l_meaning_col varchar2(100);
l_id_col      varchar2(100);
l_where_clause varchar2(3000);
l_where_count number := 0;

BEGIN

	writelog('');
	writelog('Inside get_table_Validated_clause');
	writelog('vsid = '||p_vsid||', p_link = '||p_link);
	writelog('');
	g_where_clause.delete;

	l_stmt :=  'SELECT APPLICATION_TABLE_NAME, value_column_name, '||
		' meaning_column_name, id_column_name FROM '||
		' fnd_flex_validation_tables@' ||p_link||
		' a WHERE a.flex_value_set_id =  '||p_vsid;

	--writelog('l_stmt is '||l_stmt);
	open cv for l_stmt;
	fetch cv into l_table_name, l_value_col, l_meaning_col, l_id_col;
	close cv;

	writelog('Calling add_db_links');

	IF (upper(l_table_name) like 'SELECT %' OR upper(l_table_name) like '% SELECT %') THEN
		writelog('Inline tables not supported. Tables defined in the value set need to be database objects');
	END IF;

	l_table_name := add_db_links_to_string(l_table_name, p_link);


	l_clause := 'SELECT '||l_id_col||' id_column_name, '||
		nvl(l_meaning_col, nvl(l_value_col, 'null'))
		||' meaning_column_name, '||
		nvl(l_value_col, nvl(l_meaning_col, 'null')) ||
		' value_column_name from '||l_table_name ;

	IF (l_id_col IS NULL) THEN
		writelog('');
		writelog('There is no ID column for this attribute... returning....');
		writelog('');
		p_id_col_exists := false;
		return;
	END IF;
	p_id_col_exists := true;

	writelog('Calling checkWhereClause');

	IF (not checkWhereClause(p_vsid, p_link)) THEN
		fnd_message.set_name('BIS', 'EDW_BIND_VARIABLES_FOUND');
		raise flex_variables_exception;
	END IF;


	l_where_count := g_where_clause.first;

	IF (g_where_clause.count > 0) THEN
	l_clause := l_clause|| ' ';
	loop
		l_clause := l_clause || g_where_clause(l_where_count);
		exit when l_where_count = g_where_clause.last ;
		l_where_count := g_where_clause.next(l_where_count);

		writelog('where count is '||l_where_count);
	end loop;
	END IF;
	p_tab_clause := l_clause;
	writelog('');
	writelog('Table val. clause is :'||p_tab_clause);
	writelog('');

END;


Function getAppsVersion(p_instance IN VARCHAR2) return VARCHAR2 is

	l_count number;
	l_dummy integer;
	l_cid number;

stmt  VARCHAR2(500) ;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;

l_version varchar2(300) := '11i';
l_db_link varchar2(200);

BEGIN

	SELECT warehouse_to_instance_link into l_db_link
	from EDW_SOURCE_INSTANCES_VL
	WHERE instance_code = p_instance;

	stmt := 'select substr(RELEASE_NAME, 1,8) from fnd_product_groups@'|| l_db_link;
	open cv for stmt;
	fetch cv into l_version;
	close cv;

	IF (l_version like '10.7%') THEN
		l_version := '10.7';
	ELSIF (l_version like '11.0%') THEN
		l_version := '11.0';
	ELSE
		l_version := '11i';
	END IF;

	writelog('Returning version = '||l_version);
	return l_version;

END;

FUNCTION get_ignorable_attributes(p_object_name IN VARCHAR2, p_level_name IN VARCHAR2) RETURN VARCHAR2 IS


CURSOR c_value_sets IS
SELECT
distinct FLEX.instance_code,
FLEX.VALUE_SET_ID,
decode(flex.flex_field_type, 'K', to_char(FLEX.STRUCTURE_NUM), FLEX.STRUCTURE_NAME) struct
FROM EDW_ATTRIBUTE_MAPPINGS ATTR, EDW_FLEX_ATTRIBUTE_MAPPINGS FLEX
WHERE ATTR.ATTR_MAPPING_PK = FLEX.ATTR_MAPPING_FK
AND ATTR.OBJECT_SHORT_NAME = p_object_name
AND NVL(ATTR.LEVEL_NAME, 'null') = NVL(p_level_name, 'null')
AND FLEX.VALUE_SET_TYPE = 'F';

c_row c_value_sets%ROWTYPE;
b_idFlag boolean := false;
l_tab_clause varchar2(4000):= null;

 l_ignore_list  varchar2(1000);

CURSOR c_ignore_attribute(vsid NUMBER) IS
SELECT
distinct attr.attribute_name
FROM EDW_ATTRIBUTE_MAPPINGS ATTR, EDW_FLEX_ATTRIBUTE_MAPPINGS FLEX
WHERE ATTR.ATTR_MAPPING_PK = FLEX.ATTR_MAPPING_FK
AND ATTR.OBJECT_SHORT_NAME = p_object_name
AND NVL(ATTR.LEVEL_NAME, 'null') = NVL(p_level_name, 'null')
AND FLEX.VALUE_SET_TYPE = 'F'
AND FLEX.VALUE_SET_ID = vsid ;

l_attribute VARCHAR2(200);

BEGIN
	l_ignore_list := null;
	OPEN c_value_sets;

	writelog('Inside get_ignorable_attributes');

	LOOP
	FETCH c_value_sets into c_row;
	EXIT WHEN c_value_sets%NOTFOUND;

	BEGIN
	writelog('Checking vsid '||c_row.value_set_id);
	get_table_validated_clause(c_row.value_set_id, getdblink(c_row.instance_code),
			l_tab_clause, b_idFlag);

	IF (not b_idFlag) THEN
		writelog('id flag is false, so ignore');

		OPEN c_ignore_attribute(c_row.value_set_id);

		LOOP
			FETCH c_ignore_attribute INTO l_attribute;
			EXIT when  c_ignore_attribute%NOTFOUND;
			l_ignore_list := l_ignore_list||','||l_attribute;
		END LOOP;
		CLOSE c_ignore_attribute;

	END IF;

	Exception when flex_variables_exception THEN

		OPEN c_ignore_attribute(c_row.value_set_id);
		FETCH c_ignore_attribute INTO l_attribute;
		CLOSE c_ignore_attribute;
		l_ignore_list := l_ignore_list||','||l_attribute;


	END;
	END LOOP;
	l_ignore_list := l_ignore_list||',';
	writelog('Ignore list is '||l_ignore_list);
	return l_ignore_list;
END;


FUNCTION create_first_level_tables (l_object_name IN VARCHAR2, l_level_name IN VARCHAR2)
	return boolean IS
BEGIN
	return true;
END;


/*---------------------------------------------------------------------

Convert Table validated value set IDs to Descriptions. Will be called
from the pre load hook of the Loader Engine.


-----------------------------------------------------------------------*/



FUNCTION update_stg(
p_object_name IN VARCHAR2,
p_start_mode IN VARCHAR2,
p_logfile_dir IN VARCHAR2 default null) return boolean is

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;

check_tspace_exist varchar(1);
check_ts_mode varchar(1);
physical_tspace_name varchar2(100);

CURSOR c_mapped_list(obj_name VARCHAR2, lvl_name VARCHAR2, attr_name VARCHAR2) IS
 SELECT attr.instance_code, attr.attribute_name,
 flex.value_set_id, assg.flex_field_prefix,
 vws.generated_view_name, vws.interface_table_name
 from
  edw_attribute_mappings attr,
  edw_flex_attribute_mappings flex,
  edw_sv_flex_assignments assg,
  edw_source_views vws
 where
  attr.attribute_name = attr_name and
  attr.object_short_name = assg.object_name and
  attr.attr_mapping_pk = flex.attr_mapping_fk and
  attr.object_short_name= obj_name and
  flex.id_flex_code = assg.flex_field_code and
  assg.version = edw_update_attributes.getAppsVersion(attr.instance_code) and
  attr.object_short_name = vws.object_name and
  nvl(attr.level_name, 'xxx') = nvl(vws.level_name, 'xxx') and
  nvl(attr.level_name, 'xxx') = nvl(lvl_name, 'xxx') and
  assg.version = vws.version and
  flex.value_set_type = 'F' and
  attr.flex_flag = 'Y' ;

c_mapped_attr c_mapped_list%rowtype;

CURSOR c_attr_list (obj_name VARCHAR2, lvl_name VARCHAR2) IS
SELECT distinct attribute_name
from edw_attribute_mappings a, edw_flex_attribute_mappings b
where object_short_name = obj_name
and level_name = lvl_name
and a.attr_mapping_pk = b.attr_mapping_fk
and nvl(level_name, 'xxx') = nvl(lvl_name, 'xxx')
and b.value_set_type = 'F'
order by attribute_name ;

--c_mapped_attr_list c_attr_list%rowtype;

b_dim_flag boolean := false;
l_stg_pk varchar2(100):= null;
l_bg_pk varchar2(100) := null;
l_link varchar2(300);
l_object_name varchar2(300);
l_level_name varchar2(255);

l_attribute_name varchar2(100);
b_temp_table_created boolean := false;

l_bis_schema varchar2(100):= EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');
l_op_table_space varchar2(100) := fnd_profile.value('EDW_OP_TABLE_SPACE');

CURSOR c_contexts (c_obj_name VARCHAR2, c_lvl VARCHAR2, c_attr VARCHAR2)  IS
SELECT
FLEX.instance_code,
FLEX.VALUE_SET_ID,
decode(flex.flex_field_type, 'K', to_char(FLEX.STRUCTURE_NUM), FLEX.STRUCTURE_NAME) struct
FROM EDW_ATTRIBUTE_MAPPINGS ATTR, EDW_FLEX_ATTRIBUTE_MAPPINGS FLEX
WHERE ATTR.ATTR_MAPPING_PK = FLEX.ATTR_MAPPING_FK
AND ATTR.OBJECT_SHORT_NAME = c_obj_name
AND NVL(ATTR.LEVEL_NAME, 'null') = NVL(c_lvl, 'null')
AND ATTR.ATTRIBUTE_NAME = c_attr
AND FLEX.VALUE_SET_TYPE = 'F';


ctx_row c_contexts%ROWTYPE;

l_it_name varchar2(150);

l_current_table VARCHAR2(150);
l_current_col varchar2(150);
l_stmt varchar2(4000);

l_tables_created tab_info;
l_count number := 0;


l_set_clause	varchar2(1000);
l_select_clause	varchar2(1000);
l_from_clause	varchar2(1000);
l_where_clause	varchar2(1000);

l_ctr number := 0;
l_instance varchar2(100);

l_tab_clause varchar2(3000) := null;

l_dir varchar2(1000);

b_idFlag  boolean := true;
l_ignorable_attributes varchar2(1000);

l_drop_these dbms_sql.varchar2_table;


l_object_id number := 0;

BEGIN

	g_separate_logging := false;

	IF (p_start_mode <> 'LOAD') then
		g_separate_logging := true;
		IF (p_logfile_dir IS NOT NULL ) THEN
	       	  g_file := utl_file.fopen(p_logfile_dir, 'EDW_'||p_object_name||'.log' ,'w');
		ELSE
	       	/*l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
	       	  IF (l_dir is null) then
			l_dir := edw_gen_view.getUtlfiledir;
		  END IF;*/

		  l_dir := fnd_profile.value('UTL_FILE_LOG');
			if l_dir is  null  then
			      l_dir := fnd_profile.value('EDW_LOGFILE_DIR');
				 if l_dir is  null  then
					 l_dir:= edw_gen_view.getUtlfiledir;
			          end if;
			 end if;
		g_file := utl_file.fopen(l_dir, 'EDW_'||p_object_name||'.log' ,'w');
	        END IF;
	END IF;

	writelog('Start Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

	if l_op_table_space is null then
		AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
		If check_ts_mode ='Y' then
			AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
			if check_tspace_exist='Y' and physical_tspace_name is not null then
				l_op_table_space :=  physical_tspace_name;
			end if;
		end if;
	   end if;



	IF (l_op_table_space is null) THEN
		l_op_table_space := EDW_OWB_COLLECTION_UTIL.get_table_space(l_bis_schema);
	END IF;

	writelog('Object name is : '||p_object_name);
	writelog('BIS Schema is : '||l_bis_schema);
	writelog('Op table space is : '||l_op_table_space);
	writelog('');

	BEGIN
	select dim_name into l_object_name
	from edw_levels_md_v
	where level_name||'_LTC' = p_object_name;

	writelog('This is a dimension : '||l_object_name);

	b_dim_flag := true;
	l_level_name := substr(p_object_name, 1, instr(p_object_name, '_LTC')-1);

	SELECT level_id INTO l_object_id
	from EDW_LEVELS_MD_V
	WHERE level_name||'_LTC' = p_object_name;

	Exception when no_data_found then
		b_dim_flag := false;
		l_object_name := p_object_name;
		writelog('Going to check if this is a fact');

		BEGIN

		SELECT fact_id INTO l_object_id
		from EDW_FACTS_MD_V
		WHERE fact_name = p_object_name;
		writelog('This is a fact :' ||l_object_name);

		Exception when no_data_found then
		writelog('Object cannot be found');
		return true;
		END;
	END;

	/* Check if anything is mapped at all */

	IF ( NOT mapping_exists(l_object_name, l_level_name)) THEN
		return true;
	END IF;


	/* Create a table for each UA with ROW_ID, VALUE, CONTEXT and INSTANCE Information */

	l_ignorable_attributes := get_ignorable_attributes (l_object_name, l_level_name );


	writelog('Creating First level Table INT_USER_ATTRIBUTEx');

	writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

	OPEN c_attr_list(l_object_name, l_level_name);

	writelog('Opening c_attr_list for for l_obj_name='||l_object_name||', l_level_name='||l_level_name);

	LOOP
	  FETCH c_attr_list into l_attribute_name;
	  EXIT when c_attr_list%notfound;


		writelog('Attribute : '||l_attribute_name );
		writelog('Instance : '||l_instance);

	  drop_temp_table(l_bis_schema, 'INT_'||l_object_id||'_'||l_attribute_name);
	  b_temp_table_created := false;
	  OPEN c_mapped_list (l_object_name, l_level_name, l_attribute_name);

	  LOOP /* Process UA1, then UA2 etc */

		FETCH c_mapped_list INTO c_mapped_attr;
		EXIT when c_mapped_list%NOTFOUND;

		EXIT when instr(l_ignorable_attributes, c_mapped_attr.attribute_name||',')>0;

		l_count:= l_count+1; --bug 4080618

		/* Find DB Link for this Instance Code */
		l_link := getDBLink(c_mapped_attr.instance_code);
		writelog('DB Link is '||l_link);
		/* Find the PK of the staging table */
		l_stmt := 'select cols.column_name from	edw_relations_md_v rel,
			edw_unique_keys_md_v keys, edw_unique_key_columns_md_v cols
			where
			rel.relation_name = :s1
			and rel.relation_id = keys.entity_id
			and keys.key_id = cols.key_id';
		OPEN cv for l_stmt using c_mapped_attr.interface_table_name;
		FETCH cv into l_stg_pk;
		CLOSE cv;

		writelog('Stg PK is '||l_stg_pk);

		/* Find PK of BG View */
		l_bg_pk := findColumn(c_mapped_attr.generated_view_name, '_PK', l_link);

		writelog('BG pk is '||l_bg_pk);

		l_current_table := l_bis_schema||'.INT_'||l_object_id||'_'||C_mapped_attr.attribute_name;

		IF (l_ignorable_attributes NOT like ','||C_mapped_attr.attribute_name||',') THEN

		     writelog('Current table is '|| l_current_table);
		     IF (b_temp_table_created ) THEN
			writelog('Table already created... inserting');
			execute immediate 'INSERT INTO '||l_current_table||
			'(row_id, value, context,instance ) select a.rowid row_id, a.'||
			c_mapped_attr.attribute_name||' value, b.'||c_mapped_attr.flex_field_prefix||
			'_CONTEXT context, '||''''||c_mapped_attr.instance_code|| ''''||' FROM '||c_mapped_attr.interface_table_name || ' a, '||
			c_mapped_attr.generated_view_name || '@'||l_link||' b WHERE a.'
			||c_mapped_attr.attribute_name ||' IS NOT NULL AND A.'||
			l_stg_pk ||' = b.'||l_bg_pk ||' AND A.collection_status ='||''''||'READY'||'''';

		     ELSE
			writelog('Table does not exist... create as select..');
			writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));



		 	l_stmt := ' create table '||l_current_table
			||' tablespace '||l_op_table_space||' as select a.rowid row_id, '||
			c_mapped_attr.attribute_name||' value, b.'||c_mapped_attr.flex_field_prefix||
			'_CONTEXT context, '||''''||c_mapped_attr.instance_code||''''
			 ||' instance FROM '||c_mapped_attr.interface_table_name || ' a, '||
			c_mapped_attr.generated_view_name||'@'||l_link || ' b WHERE a.'
			||c_mapped_attr.attribute_name ||' IS NOT NULL AND A.'||
			l_stg_pk ||' = b.'||l_bg_pk||' AND  A.collection_status ='||''''||'READY'||'''';
			writelog('Going to exec... '||l_stmt);
			execute immediate l_stmt;
			b_temp_table_created := true;

			IF (l_drop_these.count >0 ) THEN
				l_drop_these(l_drop_these.last+1) := l_current_table;
			ELSE
				l_drop_these(1) := l_current_table;
			END IF;

			writelog('Table created successfully');
			writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
		     END IF;
		END IF;
   	  END LOOP;
		l_it_name := c_mapped_attr.interface_table_name;
		close c_mapped_list;
		writelog('Interface table is : '||l_it_name);
	END LOOP;

	close c_attr_list;


	writelog('');
	writelog('');
	writelog('Created first level tables ');


	writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	writelog('####################################################');

	--bug 4080618 -- If all attributes are ignoreable then return.
	IF (l_count = 0) THEN
	  return true;
	END IF;
        l_count := 0;

	writelog('');
	writelog('Creating 2nd level table with ROWID and VALUE');
	writelog('l_object_name is '||l_object_name||', l_level_name is '||l_level_name);

	writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	/* Create 2nd level table for each UA with ROWID and VALUE */

	/* Get list of instance, contexts and the mapped value sets */

	OPEN c_attr_list(l_object_name, l_level_name);
	LOOP
	  FETCH c_attr_list into l_attribute_name;
	  writelog('Atribute name is :'||l_attribute_name);
	  EXIT WHEN c_attr_list%NOTFOUND;


	  OPEN c_contexts(l_object_name, l_level_name, l_attribute_name);

	 b_temp_table_created := false;

	  LOOP /* PROCESS UA1, then UA2 etc */

		writelog('l_count is '||l_count);
		FETCH c_contexts into ctx_row;
		EXIT when c_contexts%notfound;

		EXIT when instr(l_ignorable_attributes, l_attribute_name||',')>0;


		l_link := getdblink (ctx_row.instance_code);
		 get_table_validated_clause(ctx_row.value_set_id, l_link, l_tab_clause, b_idFlag);

		IF (NOT b_idFlag) THEN
			goto skip_processing;
		END IF;

		l_current_table := l_bis_schema
			||'.INTR_'||l_object_id||'_'||l_attribute_name;

		IF (b_temp_table_created) THEN
			writelog('');
			writelog('Going to insert into '||l_current_table);
			writelog('');

			l_stmt :=  ' INSERT INTO '||l_current_table
			||' (ROW_ID, VALUE) select a.row_id row_id, '||
			' decode(b.value_column_name, null, a.value, b.value_column_name) '||
			' FROM '||l_bis_schema||'.INT_'||l_object_id||'_'||l_attribute_name
			|| ' a, ('||
			l_tab_clause || ') b WHERE a.value=to_char(b.id_column_name(+)) and '||
			' a.instance = '||''''||ctx_row.instance_code||''''||
			' and a.context = '||''''||ctx_row.struct||'''';
			writelog(l_stmt);
			execute immediate l_stmt;
		ELSE

			writelog('Dropping table '||l_current_table);
			drop_temp_table(l_bis_schema, 'INTR_'||l_object_id||'_'||l_attribute_name);

			writelog('Dropped table '||l_current_table);
			writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

			l_stmt:= ' create table '||l_current_table
			||' tablespace '||l_op_table_space||' as select a.row_id row_id, '||
			' decode(b.value_column_name, null, a.value, b.value_column_name) VALUE '||
			' FROM '|| l_bis_schema||'.INT_'||l_object_id||'_'||l_attribute_name
			|| ' a, ('||
			l_tab_clause || ') b WHERE a.value=to_char(b.id_column_name(+)) and '||
			' a.instance = '||''''||ctx_row.instance_code||''''||
			' and a.context = '||''''||ctx_row.struct||'''';
			writelog(l_stmt);
			execute immediate l_stmt;
			writelog('Created table '||l_current_table);
			writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

			b_temp_table_created := true;
			l_tables_created(l_count).column_name := l_attribute_name;
			l_tables_created(l_count).table_name := l_current_table;

			IF (l_drop_these.count>0) THEN
				l_drop_these(l_drop_these.last+1) := l_current_table;
			ELSE
				l_drop_these(1) := l_current_table;
			END IF;
			l_count := l_count + 1;
		END IF;
          <<skip_processing>>
			null;
	  END LOOP;
	  close c_contexts;
	END LOOP;
	close c_attr_list;

	writelog('');
	writelog('Completed 2nd level tables ');
	writelog('Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	writelog('Creating Operational table with just Row ids');
	writelog('');




	writelog('Dropping rowid table,  time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	drop_temp_table(l_bis_schema, 'INT_ROWIDS_'||l_object_id);

	l_current_table := l_bis_schema|| '.INT_ROWIDS_'||l_object_id;

	/* Create operational table with just the rowids (this will be the driving table) */
	execute immediate 'create table '||l_current_table
		||' tablespace '||l_op_table_space||' as select rowid row_id from '|| l_it_name||' where collection_status = '||''''||'READY'||'''';

	l_drop_these(l_drop_these.last+1) := l_current_table;
	writelog('Rowid table created, time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

	execute immediate 'create unique index '||l_current_table||'_u1 on '||
			l_current_table||'(row_id)';


	writelog('Unique Index created, Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	 edw_owb_collection_util.analyze_table_stats('INT_ROWIDS_'||l_object_id, l_bis_schema, 1);


	writelog('INT_ROWIDS_'||l_object_id||' analyzed,  Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

	/* Now merge all these smaller tables into one big table needed for bulk update */

	drop_temp_table (l_bis_schema, 'INT_USER_ATTRIBUTES_'||l_object_id);
	l_current_table := l_bis_schema||'.INT_USER_ATTRIBUTES_'||l_object_id;
	l_drop_these(l_drop_these.last+1) := l_current_table;

	l_stmt := 'create table '||l_current_table||' tablespace '||
		l_op_Table_space ||' AS SELECT ';

	l_ctr := 0;

	l_select_clause := null;
	l_from_clause := ' FROM '||l_bis_schema||'.INT_ROWIDS_'||l_object_id ||' a, ';
	l_where_clause := ' WHERE ';


	l_count := l_tables_created.first;

	l_select_clause := l_select_clause|| ' a.row_id, ';
	LOOP
	  IF (l_ctr > 0) THEN
		l_select_clause := l_select_clause || ', ';
		l_from_clause := l_from_clause || ' , ';
		l_where_clause := l_where_clause || ' AND ';
	  END IF;

	  l_current_table := l_tables_created(l_count).table_name;
	  l_current_col := l_tables_created(l_count).column_name;

	  l_select_clause := l_select_clause||l_current_col||'.VALUE '||l_current_col;
	  l_from_clause := l_from_clause ||' '||l_current_table|| ' '||l_current_col;
	  l_where_clause := l_where_clause || ' a.row_id = '||l_current_col||'.row_id(+)';

	  EXIT WHEN l_count = l_tables_created.last;
	  l_count := l_tables_created.next(l_count);
	  l_ctr := l_ctr + 1;

	END LOOP;

	l_stmt := l_stmt || l_select_clause|| l_from_clause||l_where_clause;

	writelog('Select clause is '||l_select_clause);
	writelog('');
	writelog('From clause is '||l_from_clause);
	writelog('');
	writelog('Where clause is '||l_where_clause);
	writelog('');
	writelog('L Statement is '||l_stmt);
	writelog('');
	writelog('Creating INT_USER_ATTRIBUTES,  Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));


	execute immediate l_stmt;
	writelog('Created INT_USER_ATTRIBUTES,  Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));



	writelog('Going to create unique index on INT_USER_ATTRIBUTES, '||
			' Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	l_current_table := l_bis_schema||'.INT_USER_ATTRIBUTES_'||l_object_id;

	execute immediate 'create unique index '||l_current_table||'_u1 on '||
			l_current_table ||'(row_id)';

	writelog('Create unique index on INT_USER_ATTRIBUTES,  '||
			'Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

	 edw_owb_collection_util.analyze_table_stats('INT_USER_ATTRIBUTES_'||l_object_id, l_bis_schema, 1);
	writelog('Analyzed INT_USER_ATTRIBUTES,  Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));




	/* Now UPDATE the staging table using a single update */

	l_stmt := 'UPDATE '||l_it_name|| ' stg SET ';
	l_select_clause := ' (SELECT ';
	l_from_clause := ' FROM '||l_current_table
			||' A where a.row_id = stg.rowid  ';

	l_count := l_tables_created.first;

	writelog('l_stmt = '||l_stmt);
	l_ctr := 0;
	LOOP
		writelog('l_ctr = '||l_ctr);
	  IF (l_ctr > 0) THEN
		l_set_clause := l_set_clause || ', ';
		l_select_clause := l_select_clause||', ';
	  END IF;
	  l_set_clause := l_set_clause ||' '||l_tables_created(l_count).column_name;
	  l_select_clause := l_select_clause||' A.'||
				l_tables_created(l_count).column_name;

  	  EXIT WHEN l_count = l_tables_created.last;
	  l_count := l_tables_created.next(l_count);
	  l_ctr := l_ctr + 1;
		--if (l_ctr > 100 ) then exit; end if;
	END LOOP;



	l_stmt := l_stmt|| '('||l_set_clause ||') = '||l_select_clause|| l_from_clause|| ' )';
	writelog('');
	writelog('');
	writelog('Final update stmt is : ');
	writelog(l_stmt);

writelog('End Time is :'||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));

	execute immediate l_stmt;
	drop_temp_tables(l_drop_these);

	return true;

	Exception when others then
		writelog('Inside Exception ');
		utl_file.fclose(g_file);
		raise;
		return false;


END;

END EDW_UPDATE_ATTRIBUTES ;

/
