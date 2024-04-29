--------------------------------------------------------
--  DDL for Package Body EDW_GEN_VIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_GEN_VIEW" AS
/* $Header: EDWVGENB.pls 115.41 2003/11/06 11:48:14 smulye ship $ */
---+==========================================================================+
---|  Copyright (c) 1995 Oracle Corporation Belmont, California, USA          |
---|                       All rights reserved                                |
---+==========================================================================+
---|                                                                          |
---| FILENAME                                                                 |
---|      EDWVGENB.pls                                                        |
---|                                                                          |
---| DESCRIPTION                                                              |
---|                                                                          |
---| PUBLIC PROCEDURES                                                        |
---|    writeLog                                                              |
---|    writeOut                                                              |
---|    writeOutLine                                                          |
---|    buildViewStmt                                                         |
---|    createView                                                            |
---|    createLongView                                                        |
---|    getColumnMappings                                                     |
---|    update_generation_status                                              |
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
---|    16-sep-03 smulye						      |
---|        Changed   API getUtlFileDir to use alias for view v$parameter     |
---|        Bug 2860354                                                       |
---|    06-Nov-03 smulye						      |
---|        Changed   API checkWhereClause to handle the situation when where |
---|         cluase is null.						      |
---|        Bug 3194751                                                       |
---+==========================================================================*

	cid number;

	newline varchar2(10) := '
';
	g_generated_view_name varchar2(40) := null;
	g_log boolean := false;


Procedure indentBegin IS

BEGIN

		g_indenting := g_indenting || g_spacing;


END;

Procedure indentEnd IS

BEGIN
  g_indenting := substr(g_indenting, 0, length(g_indenting)-length(g_spacing)) ;
END;


/*---------------------------------------------------------------------
 Get the actual schema name for the 'APPS' schema as it could be different
 in different implementations.
 Have asked infoad if its ok to hardcode 900...

---------------------------------------------------------------------*/


Function getAppsSchema  RETURN VARCHAR2 IS
	l_schema varchar2(100);
	stmt varchar2(1000);
	l_count number;
	l_dummy integer;
	l_cid number;
BEGIN
	IF (g_log) THEN
		indentBegin;
		writelog('Inside getAppsSchema for dblink:'||g_source_db_link);
	END IF;


	stmt := 'SELECT ORACLE_USERNAME from fnd_oracle_userid@'||g_source_db_link|| '  where oracle_id=900';

   	IF (g_log) THEN
		writelog('Executing following SQL to get the APPS schema :');
		writelog(stmt);
	END IF;

	cid := DBMS_SQL.open_cursor;

	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.DEFINE_COLUMN(cid, 1, l_schema, 100);

	l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);

	DBMS_SQL.COLUMN_VALUE(cid, 1, l_schema);
	DBMS_SQL.close_cursor(cid);


	IF (g_log) THEN
		writelog('Completed getAppsSchema, returning:'||l_schema);
		writelog('');
		indentEnd;
	END IF;

	return l_schema;

END;

/*---------------------------------------------------------------------

 In case the log directory isnt passed and the EDW_LOGFILE_DIR profile
 option has also not been set, where do I write the log file ?

 Doing so by parsing the 'utl_file_dir' init.ora parameter and scanning
 for the word log and getting that string out.

---------------------------------------------------------------------*/


Function getUtlFileDir return VARCHAR2 IS
	l_dir VARCHAR2(1000);
	l_utl_dir VARCHAR2(100);
	l_count	  NUMBER := 0;
	l_log_begin	  NUMBER := 0;
	l_log_end	  NUMBER := 0;
	l_comma_pos	  NUMBER := 0;
	stmt		 VARCHAR2(200);
	cid		 NUMBER;
	l_dummy		 NUMBER;

BEGIN
	SELECT param.value into l_dir
	FROM v$parameter param where upper(param.name) = 'UTL_FILE_DIR';

	l_log_begin := INSTR(l_dir, '/log');

    IF (l_log_begin = 0) THEN /* then get the first string */
        l_utl_dir := substr(l_dir, 1, INSTR(l_dir, ',') - 1);
        return l_utl_dir;
    END IF;
	l_log_end  := INSTR(l_dir, ',', l_log_begin) - 1;
	IF (l_log_end <= 0) THEN
		l_log_end := length(l_dir);
	END IF;

	--have now determined the first occurrence of '/log' and the end pos
	-- now to determine the start position of the log directory

	l_dir := substr(l_dir, 0, l_log_end);

	LOOP
	l_comma_pos := INSTR(l_dir, ',', l_comma_pos+1);
	IF (l_comma_pos <> 0) THEN
		l_count :=   l_comma_pos + 1;
	END IF;

	EXIT WHEN l_comma_pos = 0;
	END LOOP;
	l_utl_dir := substr(l_dir, l_count+1, l_log_end);


	RETURN l_utl_dir;

END;

/*---------------------------------------------------------------------

  Used to be checking for upper(characters) to be between 'A' to 'Z'
  or 0 to 9 but thats not NLS compliant. So following exact BIS
  view gen logic in generating column names.

---------------------------------------------------------------------*/

Function formSegmentName(p_prefix 	IN VARCHAR2,
			p_segment_name  IN VARCHAR2,
		 	p_struct_num 	IN NUMBER,
			p_Id_Flex_Code 	IN VARCHAR2,
			p_flex_type 	IN VARCHAR2) RETURN VARCHAR2 IS

	l_newstring varchar2(100);
	l_length number := 0;
	l_string varchar2(100);
	l_trunc_segment varchar2(30);
	v_segment_list	DBMS_SQL.VARCHAR2_TABLE;

	CURSOR C_Key_Segment_List(p_id_flex_code VARCHAR2, p_struct_num NUMBER, p_trunc_segment VARCHAR2) IS
	select segment_name
	from fnd_id_flex_segments_vl
	where 	upper(id_flex_code) = p_id_flex_code
	and id_flex_num = p_struct_num
	and upper(segment_name) like p_trunc_segment
	order by creation_date;

	l_orig_length NUMBER := 0;

	l_segment_name VARCHAR2(100);
	l_count INTEGER :=0;
	l_list_count INTEGER :=0;
	l_last_index Integer := 0;
	l_seg_length Integer :=0;

	CURSOR C_Application_Id(p_obj_name VARCHAR2) IS
	select distinct application_id
	from edw_attribute_mappings attr, edw_flex_attribute_mappings flex
	where attr.attr_mapping_pk = flex.attr_mapping_fk
	and object_short_name = p_obj_name;

	CURSOR C_Context_Code(p_id_flex_code VARCHAR2, p_application_id NUMBER, p_struct_num NUMBER) IS
	select  descriptive_flex_context_code
	FROM
	(select descriptive_flex_context_code
	from fnd_descr_flex_contexts_vl
	where upper(descriptive_flexfield_name)  = p_id_flex_code
	and application_id = p_application_id
	order by creation_date )
	where rownum < p_struct_num
	order by rownum desc;

	CURSOR C_Desc_Segment_List(p_id_flex_code VARCHAR2, p_context_code VARCHAR2, p_trunc_segment VARCHAR2) IS
	select end_user_column_name
	from fnd_descr_flex_col_usage_vl
	where descriptive_flexfield_name = p_id_flex_code
	and descriptive_flex_context_code = p_context_code
	and end_user_column_name like p_trunc_segment
	order by creation_date;

	l_application_id NUMBER;
	l_context_code VARCHAR2(100);
BEGIN

	IF (g_log) THEN
		indentBegin;

		writelog('Inside formSegmentName');
		writelog('  Parameter p_prefix:'||p_prefix);
		writelog('  Parameter p_segment_name:'||p_segment_name);
		writelog('  Parameter p_struct_num:'||p_struct_num);
		writelog('  Parameter p_Id_Flex_Code:'||p_Id_Flex_Code);
		writelog('  Parameter p_flex_type:'||p_flex_type);
	END IF;


	l_string := convertString(p_segment_name);
	l_length := length(l_string);

	IF (g_log) THEN
			writelog('l_length is:'||l_length);
	END IF;

	IF (p_segment_name is null) THEN
		return null;
	END IF;

	l_newstring := l_string;

	IF (g_log) THEN
			writelog('l_newstring is:'||l_newstring);
	END IF;

	IF (p_struct_num <> -1) then


		/* this is done because we store -1 if there is only 1 context
		in the df if there is only 1 context in the desc. flex, then it
		does not appenda suffix to the generated column */

	l_length := length(l_newstring)+ length(p_prefix)+1 +length(p_struct_num) + 1;

	ELSE
		l_length := length(l_newstring)+ length(p_prefix)+1 ;
	END IF;

	IF (g_log) THEN
		writelog('l_length is:'||l_length);
	END IF;

	l_newstring := p_prefix||'_'||l_newstring;
	l_orig_length := l_length;


	-- need truncation
	IF (l_length > 30 ) then

		IF( g_log) THEN
		writelog('length is greater than 30 : '||l_length);
		END IF;
	    IF (p_struct_num <> -1)	THEN
		l_length := 30-length(p_prefix)-1-length(p_struct_num)-1;
		l_trunc_segment := substr(l_string, 0, l_length);
	    else
		l_length := 30-length(p_prefix)-1;
		l_trunc_segment := substr(l_string, 0, l_length);
	    end if;

	  IF (g_log) THEN
		writelog('l_length = '||l_length || ',  l_trunc_segment = '|| l_trunc_segment);
	  END IF;

-- we need to consider accounting flex field as well (bug 2245373)
	  IF (p_flex_type = 'K' OR p_flex_type = 'A') then
		-- get list of segments for key flex fields
		OPEN C_Key_Segment_List(p_id_flex_code,
			p_struct_num, substr(p_segment_name, 0, l_length)||'%');
		l_count := 0;
		loop
		  fetch C_key_Segment_List into l_segment_name;
		  exit when C_Key_Segment_List%NOTFOUND;
	          l_count := l_count + 1;
	          v_segment_list (l_count) := l_segment_name;
		end loop;
		CLOSE C_key_Segment_List;
		l_list_count := l_count;
	   ELSE  -- descriptive flex field
		-- get list of segments for desc flex fields

		OPEN C_Application_Id(g_obj_name);
		FETCH C_Application_Id INTO l_application_id;


		if C_Application_Id%FOUND then
		  OPEN C_Context_Code(p_id_flex_code, l_application_id, p_struct_num);
		  FETCH C_Context_Code INTO l_context_code;


		  IF C_Context_Code%FOUND then
		    OPEN C_Desc_Segment_List(p_id_flex_code, l_context_code, substr(p_segment_name, 0, l_length)||'%');
		    l_count := 0;
		    loop
		      fetch C_Desc_Segment_List into l_segment_name;
		      exit when C_Desc_Segment_List%NOTFOUND;
	              l_count := l_count + 1;
	              v_segment_list (l_count) := convertString(l_segment_name);

		    end loop;
		    CLOSE C_Desc_Segment_List;
		    l_list_count := l_count;
		  END IF; --  C_Context_Code%FOUND
		  CLOSE  C_Context_Code;
		END IF;   --  C_Application_Id%FOUND
		CLOSE C_Application_Id;
	    end if;

	--  construct segment name

	if (l_list_count = 1) then
	   -- no naming clashes.

	    IF (p_struct_num <> -1)	THEN
		l_newstring := p_prefix || '_' || l_trunc_segment ||'_'||p_struct_num;
	    else
		l_newstring := p_prefix || '_' || l_trunc_segment;
	    end if;

	elsif (l_list_count > 1) then  -- naming clashes
	    l_last_index := 0;
	    l_count := 0;
	    loop
		l_count := l_count + 1;

		if (l_count = 1) then

		    IF (p_struct_num <> -1)	THEN
			l_newstring := p_prefix || '_' || l_trunc_segment ||'_'||p_struct_num;
		    else
			l_newstring := p_prefix || '_' || l_trunc_segment;
		    end if;

		else

		  if (l_last_index >= 0 and l_last_index <= 8) then
		    l_last_index := l_last_index + 1;
		    l_seg_length := l_length - 2;
		    l_trunc_segment := substr(l_string, 0, l_seg_length);
		    IF (p_struct_num <> -1)	THEN
		      l_newstring := p_prefix || '_' || l_trunc_segment ||'_'||p_struct_num || '_' || l_last_index;
		    else
		      l_newstring := p_prefix || '_' || l_trunc_segment || '_' || l_last_index;
		    end if;

		  else

		    l_last_index := l_last_index + 1;
		    l_seg_length := l_length - 3;
		    l_trunc_segment := substr(l_string, 0, l_seg_length);
		    IF (p_struct_num <> -1)	THEN
		      l_newstring := p_prefix || '_' || l_trunc_segment ||'_'||p_struct_num || '_' || l_last_index;
		    else
		      l_newstring := p_prefix || '_' || l_trunc_segment || '_' || l_last_index;
		    end if;

		  end if;   -- if l_last_index


		end if;     -- if l_count

		exit when (v_segment_list(l_count) = l_string);
	      end loop;
	  else
		 IF (p_struct_num <> -1)	THEN
		      l_newstring := p_prefix || '_' || l_trunc_segment ||'_'||p_struct_num ;
		    else
		      l_newstring := p_prefix || '_' || l_trunc_segment;
		    end if;


	    end if;   -- if l_list_count

	END if;  -- if (l_length>30)



	IF (l_orig_length <= 30 ) THEN
-- for bug 2270960 (when p_struct_num = -1, should not append it to the name)
            if (p_struct_num <> -1) then
		l_newstring := l_newstring ||'_'||p_struct_num;
            end if;
	END IF;




	IF (g_log) THEN
		writelog(g_spacing||'Segment Name formed is :'|| l_newstring);

		writelog('Completed formSegmentName, returning:'||l_newstring);
		indentEnd;
	END IF;


	return l_newstring;


END;

/*---------------------------------------------------------------------

	Write to the log file using utl_file. Write only if the logging
	flag is true.

---------------------------------------------------------------------*/



Procedure writeLog(p_message IN VARCHAR2) IS
BEGIN
	IF (g_log) THEN
          IF (p_message like 'Inside%') THEN
		  utl_file.put_line(l_file, newline);
		  utl_file.put_line(l_file, g_indenting||p_message);
          ELSIF ( p_message like 'Completed%') THEN
		utl_file.put_line(l_file, g_indenting||p_message);
		utl_file.put_line(l_file, newline);
	  ELSE
            utl_file.put_line(l_file, g_indenting||'	'||p_message);
          END IF;
	ELSE
		return;
	END IF;
END;

Procedure writeOut(p_message IN VARCHAR2) IS
BEGIN
	IF (g_log) THEN
		utl_file.put(l_out_file, p_message);
	ELSE
		return;
	END IF;
END;

Procedure writeOutLine(p_message IN VARCHAR2) IS
BEGIN
	IF (g_log) THEN
		utl_file.put_line(l_out_file, p_message);
	ELSE
		return;
	END IF;
END;

/*---------------------------------------------------------------------

	Get the # of columns given a view name. This will query for
	the owner APPS as the APPS and APPS_MRC schema may sometimes
	be out of sync and may return extra columns which are
	in APPS_MRC but not in APPS.

---------------------------------------------------------------------*/


Function getColumnCountForView(view_name in varchar2) RETURN INTEGER IS
	stmt varchar2(1000);
	l_count number;
	l_dummy integer;
BEGIN
	IF (g_log) THEN
		indentBegin;
		writelog('Inside getColumnCountForView for :'||view_name);
	END IF;


	stmt := ' SELECT count(distinct(column_name)) FROM all_tab_columns@'||g_source_db_link;
	stmt := stmt||' WHERE table_name = :view_name AND owner = :owner';
	cid := DBMS_SQL.open_cursor;
	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);

	DBMS_SQL.BIND_VARIABLE(cid, ':view_name', upper(view_name), 50);
	DBMS_SQL.BIND_VARIABLE(cid, ':owner', g_apps_schema, 50);

	DBMS_SQL.DEFINE_COLUMN(cid, 1, l_count);
	l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);
	DBMS_SQL.COLUMN_VALUE(cid, 1, l_count);
	DBMS_SQL.close_cursor(cid);

	IF (g_log) THEN
		writelog('Completed getColumnCountForView, Column count is : '||l_count);
		indentEnd;

	END IF;
	RETURN l_count;
END;

function getApplsysSchema return varchar2 is
dummy1			VARCHAR2(32)	:= null;
dummy2			VARCHAR2(32)	:= null;
l_applsys_schema	VARCHAR2(32)	:= null;
apiClause               varchar2(1000) ;
l_dummy  number;
begin
	apiClause :=  'BEGIN
	IF (FND_INSTALLATION.GET_APP_INFO@'||edw_gen_view.g_source_db_link||'(''FND'', :dummy1, :dummy2, :l_applsys_schema)) THEN NULL; END IF; END;';
	cid :=  DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cid, apiClause, DBMS_SQL.NATIVE);
	DBMS_SQL.BIND_VARIABLE(cid, ':dummy1', dummy1, 32);
	DBMS_SQL.BIND_VARIABLE(cid, ':dummy2', dummy2, 32);
	DBMS_SQL.BIND_VARIABLE(cid, ':l_applsys_schema', l_applsys_schema, 32);

	l_dummy := DBMS_SQL.EXECUTE(cid);
	DBMS_SQL.VARIABLE_VALUE(cid, ':l_applsys_schema', l_applsys_schema);
	DBMS_SQL.CLOSE_CURSOR(cid);
        return l_applsys_schema;
exception
  when others then
    if g_log then
      writelog('Error : inside getApplsysSchema');
    END IF;

end getApplsysSchema;

Procedure BuildViewStmt(p_view_text in varchar2, p_line_num in number) is
begin

execute IMMEDIATE
    'begin ad_ddl.build_statement@'||g_source_db_link||' (:s1,:s2) ; end; '
       using p_view_text,p_line_num;

exception
  when others then
    if g_log then
      writelog('Error : Inside BuildView_stmt');
      writelog('view text is : '|| p_view_text ||'. Line number is : '|| p_line_num);
    END IF;
end;


FUNCTION getViewStatus(view_name IN VARCHAR2) return VARCHAR2 IS
status VARCHAR2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
stmt varchar2(1000);
l_schema varchar2(100);
BEGIN
	IF (g_log) THEN
		writelog('Inside getViewStatus for '||view_name);
	END IF;

    status := null;
    l_schema := getAppsSchema;
    stmt := 'SELECT text FROM all_errors@'||g_source_db_link||' WHERE NAME = :s1 and type = :s2 and owner = :s3';
    open cv for stmt using upper(view_name), 'VIEW', l_schema;
    fetch cv into status;
    close cv;

	IF (g_log) THEN
		writelog('stmt is');
		writelog(stmt);
	END IF;

    IF (status is null) THEN
        status := 'VALID';
    END IF;
    IF (g_log) THEN
		writelog('Status is : '||status);
        writelog('Completed getViewStatus');
	indentEnd;
    END IF;
    return status;
END;

/*---------------------------------------------------------------------

	Given a source view, deploy this on the Apps Schema on the
	remote database thru the db link g_source_db_link.

---------------------------------------------------------------------*/


PROCEDURE createView(src_view IN VARCHAR2, view_name IN VARCHAR2) IS
apiClause 		VARCHAR2(3000)	:= null;
l_applsys_schema	VARCHAR2(32)	:= null;
l_dummy			NUMBER		:= 0;
status VARCHAR2(4000);
BEGIN
	IF (g_log) THEN

		indentBegin;
		writelog('Inside createView ');
        	writelog('View Text is : ');
		writelog(src_view);
		writelog(newline);
	END IF;

        l_applsys_schema:= getApplsysSchema;

	IF (g_log) THEN
		writelog('l_applsys_schema is : '|| l_applsys_schema);
		writelog('Calling ad_ddl.do_ddl to deploy view on the source');
	END IF;

	  apiClause  :=  'BEGIN
		ad_ddl.do_ddl@'||g_source_db_link;
	  apiClause  := apiClause ||'(APPLSYS_SCHEMA => '''||l_applsys_schema||'''';
	  apiClause := apiClause|| ', APPLICATION_SHORT_NAME => ''FND''';
	  apiClause := apiClause||newline||',  STATEMENT_TYPE => 2, STATEMENT => :source_view ';
	  apiClause := apiClause||' , OBJECT_NAME => '''||view_name||'''); END;';

  	  cid :=  DBMS_SQL.open_cursor;
	  dbms_sql.parse(cid, apiClause,  dbms_sql.native);
	  DBMS_SQL.BIND_VARIABLE(cid, ':source_view', src_view, 32760);
	  l_dummy := DBMS_SQL.EXECUTE(cid);
	  DBMS_SQL.close_cursor(cid);

	IF (g_log) THEN
		writelog('Going to check view status of deployed view');
	END IF;

    status := getViewStatus(view_name);
    IF (status <> 'VALID') THEN

	IF (g_log) THEN
	       	writelog(newline||newline);
		writelog('View creation Failed...');
        	writelog('Error is '||status||newline);
	END IF;
        g_error := status;
        raise viewgen_exception;

    ELSE
	IF (g_log) THEN
		writelog(newline);
		writelog('View status is valid.');
	END IF;
    END IF;

    IF (g_log) THEN
		writelog(g_spacing||'View created!');

		writelog(g_spacing||'Completed createView');
		indentEnd;


	END IF;
END;

PROCEDURE createLongView(view_name IN VARCHAR2, p_first_line_num IN NUMBER, p_last_line_num IN NUMBER) IS
  apiClause 		VARCHAR2(3000)	:= null;
  l_applsys_schema	VARCHAR2(32)	:= null;
  l_dummy			NUMBER		:= 0;
  status		VARCHAR2(4000) := null;
BEGIN
	IF (g_log) THEN

		indentBegin;
	        writelog(newline||newline);
		writelog('Inside create Long View '||newline);
	END IF;

        l_applsys_schema:= getApplsysSchema;

	IF (g_log) THEN
		writelog(g_spacing||'l_applsys_schema is : '|| l_applsys_schema);
		writelog(g_spacing||'Calling ad_ddl.do_ddl to deploy view on the source');

	END IF;

	  apiClause  :=  'BEGIN
		ad_ddl.do_array_ddl@'||g_source_db_link;
	  apiClause  := apiClause ||'(APPLSYS_SCHEMA => '''||l_applsys_schema||'''';
	  apiClause := apiClause|| ', APPLICATION_SHORT_NAME => ''FND''';
	  apiClause := apiClause||newline||',  STATEMENT_TYPE => 2, lb => :first_line , ub=>:last_line';
	  apiClause := apiClause||' , OBJECT_NAME => :object_name); END;';

  	  cid :=  DBMS_SQL.open_cursor;
	  dbms_sql.parse(cid, apiClause,  dbms_sql.native);
	  DBMS_SQL.BIND_VARIABLE(cid, ':first_line', p_first_line_num);
	  DBMS_SQL.BIND_VARIABLE(cid, ':last_line', p_last_line_num);
	  DBMS_SQL.BIND_VARIABLE(cid, ':object_name',view_name ,30);

	  l_dummy := DBMS_SQL.EXECUTE(cid);
	  DBMS_SQL.close_cursor(cid);

	 status := getViewStatus(view_name);
    IF (status <> 'VALID') THEN

	IF (g_log) THEN
	       	writelog(newline||newline||'View creation Failed...');
	        writelog(newline||'Error is '||status||newline);
	END IF;
        g_error := status;
        raise viewgen_exception;

    ELSE
	IF (g_log) THEN
		writelog(newline||newline||'View status is valid.');
	END IF;

    END IF;



	IF (g_log) THEN
		writelog(g_spacing||'View created.');
		writelog(g_spacing||'Completed createLongView');
		indentEnd;

	END IF;

END;

/* ------------------------------------------------------------------------

	Create the column map vectors for a given object. Will split it into
	counts for the following :

	1. Simple Attribute Mappings
	2. Multiple Attributes mapped to a single target column (OPI req.)
	3. Attributes mapped to Flexfields
	4. Foreign Keys to Flexfield dimensions

------------------------------------------------------------------------  */

PROCEDURE getColumnMaps(object_name IN VARCHAR2, attMaps OUT NOCOPY tab_att_maps, multiAttList OUT NOCOPY tab_multi_att_list, flexMaps OUT NOCOPY tab_flex_att_maps, fkMaps OUT NOCOPY tab_fact_flex_fk_maps, p_level IN VARCHAR2 default null) IS

	colList varchar2(500);
	temp 	varchar2(50);
	flex	c_getFlexAttributeMappings%ROWTYPE;
	att	c_getAttributeMappings%ROWTYPE;
	multiatt c_getMultiAttributeList%ROWTYPE;
	fk      c_getFactFlexFKMaps%ROWTYPE;
	l_count number;

BEGIN
	/* access edw_attribute mappings and get the list */

	IF (g_log) THEN

		indentBegin;
	        writelog(newline||newline);
		writelog('Inside getColumnMaps');
	END IF;

	/* -------------------------------------------------

		Get the straight attribute mappings

	----------------------------------------------------*/


	l_count := 1;
	IF (g_log) THEN
		writelog(g_spacing||'Opening cursor c_getAttributeMappings with object_name = '||
			object_name||', g_instance = '||g_instance||', p_level = '||p_level);
	END IF;


	open c_getAttributeMappings(object_name, g_instance, p_level);
	LOOP
		FETCH  c_getAttributeMappings INTO att;
		EXIT WHEN c_getAttributeMappings%NOTFOUND;
		IF (g_log) THEN
			writelog(g_spacing||'Target attribute: '||att.attribute_name ||
			' <=  Source Attribute: '||att.source_attribute);
		END IF;

		attMaps(l_count).attribute_name 	:= att.attribute_name;
		attMaps(l_count).source_attribute 	:= att.source_attribute;
		attMaps(l_count).datatype	 	:= att.datatype;
		l_count 				:= l_count+1;
	END LOOP;
	close c_getAttributeMappings;

	IF (g_log) THEN
		writelog(g_spacing||'Attributes with single column mappings : '||(l_count-1));
	END IF;

	/* -------------------------------------------------

		Get attributes with multiple mappings

	----------------------------------------------------*/


	l_count := 1;
	IF (g_log) THEN
		writelog(g_spacing||'Opening cursor c_getMultiAttributeList with object_name = '||
			object_name||', g_instance = '||g_instance||', p_level = '||p_level);
	END IF;

	open c_getMultiAttributeList(object_name, g_instance, p_level);


	LOOP
		FETCH c_getMultiAttributeList into multiatt;
		EXIT WHEN c_getMultiAttributeList%NOTFOUND;
		multiAttList(l_count).attribute_name 	:= multiatt.attribute_name;
		l_count 				:= l_count + 1;

	END LOOP;

	close c_getMultiAttributeList;

	IF (g_log) THEN
		writelog(g_spacing||'Attributes with multiple column mappings : '||(l_count-1));
	END IF;

	/* -------------------------------------------------

		Get attributes with flexfield mappings

	----------------------------------------------------*/


	l_count := 1;

	IF (g_log) THEN
		writelog(g_spacing||'Opening cursor  c_getFlexAttributeMappings  with object_name = '||
			object_name||', g_instance = '||g_instance||', p_level = '||p_level);
	END IF;

	open c_getFlexAttributeMappings(object_name, g_instance, p_level);
	LOOP
		FETCH  c_getFlexAttributeMappings INTO flex;
		EXIT WHEN c_getFlexAttributeMappings%NOTFOUND;

		flexMaps(l_count).attribute_name 	:= flex.attribute_name;
		flexMaps(l_count).source_view 		:= flex.source_view;
		flexMaps(l_count).id_flex_code 		:= flex.id_flex_code;
		flexMaps(l_count).flex_field_type	:= flex.flex_field_type;

		l_count 				:= l_count+1;
	END LOOP;
	close c_getFlexAttributeMappings;

	IF (g_log) THEN
		writelog(g_spacing||'Attributes with flexfield mappings : '||(l_count-1));
	END IF;


	/* -------------------------------------------------

		Get FKs mapped to Flex Dimensions

	----------------------------------------------------*/

	l_count := 1;
	IF (g_log) THEN
		writelog(g_spacing||'Opening cursor c_getFactFlexFKMaps  with object_name = '||
			object_name||', g_instance = '||g_instance||', p_level = '||p_level);
	END IF;

	open c_getFactFlexFKMaps(object_name, g_instance);
	LOOP
		FETCH  c_getFactFlexFKMaps INTO fk;
		EXIT WHEN c_getFactFlexFKMaps%NOTFOUND;

		fkMaps(l_count).fk_physical_name 	:= fk.fk_physical_name;
		l_count 				:= l_count+1;
	END LOOP;
	close c_getFactFlexFKMaps;
	IF (g_log) THEN
		writelog(g_spacing||'Attributes with Foreign Key mappings : '||(l_count-1));
	END IF;


	IF (g_log) THEN
		writelog( 'Completed getColumnMaps');
		indentEnd;

	END IF;

	EXCEPTION WHEN OTHERS THEN
		attMaps.delete;
		multiAttList.delete;
		flexMaps.delete;
		fkMaps.delete;


END;

/*---------------------------------------------------------------------

	If multiple columns are mapped to the same attribute, then we
	need to do a NVL and get the columns out.
	eg. if ColA, ColB and ColC are mapped this is what is generated

	NVL(ColA, NVL(ColB, NVL(ColC,null)))

---------------------------------------------------------------------*/

FUNCTION getNvlClause(p_object IN VARCHAR2, p_level IN VARCHAR2, p_instance IN VARCHAR2,
	p_column IN VARCHAR2) return VARCHAR2 IS

	endOfCol	VARCHAR2(200);
	nvlColumn	VARCHAR2(2000);
	srcCol		VARCHAR2(200);
	l_count		NUMBER := 0;

BEGIN
	IF (g_log) THEN

		indentBegin;
		writelog('Inside getNvlClause');
	END IF;


	endOfCol := 'NULL';
	open c_getMultiAttributeMappings(p_object, p_instance, p_level, p_column);

	LOOP
		FETCH c_getMultiAttributeMappings INTO srcCol;
		EXIT WHEN c_getMultiAttributeMappings%NOTFOUND;

		nvlColumn:= nvlColumn||' NVL('||srcCol ||', ';
		endOfCol := endOfCol || ')';
	END LOOP;

	close c_getMultiAttributeMappings;

	IF (g_log) THEN
		writelog('Completed getNvlClause');
		indentEnd;

	END IF;

	RETURN nvlColumn||endOfCol;

END;


/*---------------------------------------------------------------------

     Given a view name and a flex, get the flex prefix from the seed data

---------------------------------------------------------------------*/

Function getFlexPrefix( pViewName IN VARCHAR2, pIdFlexCode IN VARCHAR2) RETURN VARCHAR2 IS

	sPrefix 	VARCHAR2(20) := NULL;

	CURSOR 		c1(pViewName VARCHAR2, pIdFlexCode VARCHAR2) IS
			SELECT flex_field_prefix FROM edw_sv_flex_assignments
			WHERE upper(flex_field_code) = upper(pIdFlexCode)
			AND upper(flex_view_name) = upper(pViewName) ;

BEGIN

	IF (g_log) THEN

		indentBegin;
		writelog('Inside getFlexPrefix');
		 writelog('Parameter pViewName:'||pViewName);
		 writelog('Parameter pIdFlexCode:'||pIdFlexCode );
	END IF;

	OPEN c1(pViewName , pIdFlexCode);
	FETCH c1 into sPrefix;
	CLOSE c1;

	IF (g_log) THEN
		writelog(g_spacing||'Prefix is :'||sPrefix);
		writelog( 'Completed getFlexPrefix ');
		indentEnd;

	END IF;

	IF (sPrefix is null) THEN
		g_error := 'Prefix is null. Data Seeded Incorrectly';
		IF(g_log) THEN
			writelog(g_spacing||'Data Seeded Incorrectly... Quitting');
		END IF;
		g_success := false;
		raise viewgen_exception;
	END IF;

	RETURN sPrefix;
END;


Function getAppsVersion return VARCHAR2 is
l_schema varchar2(100);

	l_count number;
	l_dummy integer;
	l_cid number;

-- for bug 2228532
 stmt  VARCHAR2(500) := 'select substr(RELEASE_NAME, 1,8) from fnd_product_groups@'
                              || g_source_db_link;

BEGIN

   	IF (g_log) THEN
		indentBegin;
		writelog('Inside getAppsVersion');
	END IF;

	cid := DBMS_SQL.open_cursor;

	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.DEFINE_COLUMN(cid, 1, g_version, 100);

	l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);

	DBMS_SQL.COLUMN_VALUE(cid, 1, g_version);
	DBMS_SQL.close_cursor(cid);

	IF (g_version like '10.7%') THEN
		g_version := '10.7';
	ELSIF (g_version like '11.0%') THEN
		g_version := '11.0';
	ELSE
		g_version := '11i';
	END IF;

    IF (g_log) THEN
	    writelog ('returning from getAppsVersion, version is :'||g_version);

	writelog('Completed getAppsVersion');
	indentEnd;

	END IF;


	return g_version;

END;

/*Function getAppsVersion(p_instance IN VARCHAR2) return VARCHAR2 is

	l_count number;
	l_dummy integer;
	l_cid number;

-- for bug 2228532
 stmt  VARCHAR2(500) ;:= 'select substr(RELEASE_NAME, 1,8) from fnd_product_groups@'
                              || g_source_db_link;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;

l_db_link varchar2(200);

BEGIN

	SELECT warehouse_to_instance_link into l_db_link
	from EDW_SOURCE_INSTANCES_VL
	WHERE instance_code = p_instance;

	stmt := := 'select substr(RELEASE_NAME, 1,8) from fnd_product_groups@|| l_db_link;
   	IF (g_log) THEN
		indentBegin;
		writelog('Inside getAppsVersion with instance='||p_instance);
	END IF;

	cid := DBMS_SQL.open_cursor;

	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.DEFINE_COLUMN(cid, 1, g_version, 100);

	l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);

	DBMS_SQL.COLUMN_VALUE(cid, 1, g_version);
	DBMS_SQL.close_cursor(cid);

	IF (g_version like '10.7%') THEN
		g_version := '10.7';
	ELSIF (g_version like '11.0%') THEN
		g_version := '11.0';
	ELSE
		g_version := '11i';
	END IF;

    IF (g_log) THEN
	    writelog ('returning from getAppsVersion, version is :'||g_version);

	writelog('Completed getAppsVersion');
	indentEnd;

	END IF;


	return g_version;

END;

*/

Function getContextColForFlex(p_flex in varchar2, p_flex_type IN VARCHAR2) RETURN VARCHAR2 IS
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
stmt varchar2(200) := 'select context_column_name from fnd_descriptive_flexs_vl@'||edw_gen_view.g_source_db_link||
                       ' where descriptive_flexfield_name =:s1 ';
l_structure_col varchar2(100);
BEGIN
    IF (p_flex_type = 'D') THEN
        stmt := 'select context_column_name from fnd_descriptive_flexs_vl@'||edw_gen_view.g_source_db_link||
                       ' where descriptive_flexfield_name =:s1 ';
    ELSE
        stmt := 'select set_defining_column_name from fnd_id_flexs@'||edw_gen_view.g_source_db_link||
                       ' where id_Flex_code =:s1 ';
    END IF;
    open cv for stmt using p_flex ;
    fetch cv into l_structure_col;
    close cv;
    return l_structure_col;
END;

/*---------------------------------------------------------------------

	For columns mapped to flexfields, get the decode clause.

---------------------------------------------------------------------*/


FUNCTION getDecodeClauseForFlexCol( pSourceView IN VARCHAR2,
	pAttributeName IN VARCHAR2, pIdFlexCode IN VARCHAR2,
	pFlexType IN VARCHAR2) RETURN  VARCHAR2 IS

CURSOR 		c1(pView IN varchar2, pAttr IN varchar2) IS
		SELECT distinct structure_num, segment_name, structure_name, VALUE_SET_DATATYPE
		from edw_attribute_mappings a, edw_flex_attribute_mappings b
		where upper(a.source_view) = upper(pView)
		and upper(a.attribute_name) = upper(pAttr)
		and a.attr_mapping_pk = b.attr_mapping_fk;

	sPrefix 	VARCHAR2(100) := NULL;
	sDecodeClause 	VARCHAR2(3000) := NULL;
	cRow 		c1%ROWTYPE;
	l_length	NUMBER:=0;
	tempvar		VARCHAR2(100) := NULL;
	nCount 		NUMBER := 1;
	stmt1 		VARCHAR2(1500) := 'select replace(SEGMENT_NAME, '||''' '||
			''','||'''_'||''''||')||'||''''||'_'||''''||'||
			a.id_flex_num FROM fnd_id_flex_structures_vl@'||g_source_db_link
			||' b, fnd_id_flex_segments_vl@'||g_source_db_link||
			' a WHERE a.segment_name = :seg_name';

	stmt2 		VARCHAR2(500) := ' AND a.id_flex_code = b.id_flex_code '||
					 ' AND a.id_flex_num = b.id_flex_num';

	descStmt	VARCHAR2(1500) ;
	l_gen_seg_name 	VARCHAR2(100):= NULL;
	cid 		NUMBER := 0;
	l_dummy 	NUMBER := 0;

	cursor C_Replace_Apos(p_name VARCHAR2) is
	select replace(p_name, '''', '''''') from dual;
	l_structure_name VARCHAR2(1000);

BEGIN

	IF (g_log) THEN

	        writelog(newline);
		indentBegin;
		writelog('Inside getDecodeClauseForFlexCol');
		writelog('Parameter pSourceView:'||pSourceView);
		writelog('Parameter pAttributeName:'||pAttributeName);
		writelog('Parameter pIdFlexCode:'|| pIdFlexCode);
		writelog('Parameter pFlexType:'||pFlexType);

	END IF;


	sPrefix := getFlexPrefix(pSourceView, pIdFlexCode);

	sDecodeClause := ' DECODE('||sPrefix||'_CONTEXT, ';
	open c1(pSourceView, pAttributeName);


	LOOP
		fetch c1 into cRow;
		EXIT WHEN c1%NOTFOUND;
		IF(nCount > 1) THEN
			sDecodeClause := sDecodeClause ||','||newline||'	';
		END IF;


		------------------------------------------------

		IF (g_log) THEN
			writelog(g_spacing||'l_gen_seg_name is :'|| l_gen_seg_name);
			writelog(g_spacing|| 'calling formSegmentName');
		END IF;

		l_gen_seg_name := formSegmentName(sPrefix, cRow.segment_name, cRow.structure_num, pIdFlexCode, pFlexType);


		-------------------------------------------------


-- we need to consider accounting flex field as well (bug 2245373)
		IF (pFlexType = 'K' OR  pFlexType = 'A') THEN
			sDecodeClause := sDecodeClause||''''||cRow.structure_num||''''||', ';

		ELSE /* Descr Flex */
/*
	open C_Replace_Apos(cRow.structure_name);
	fetch C_Replace_Apos into l_structure_name;
	close C_Replace_Apos;
		IF (g_log) THEN
			writelog('cRow.structure_name = '||cRow.structure_name);
			writelog('l_structure_name = '||l_structure_name);
		END IF;
*/
		IF (g_log) THEN
			writelog('in descr flex condition');
		END IF;
		tempvar := replace(cRow.structure_name, '''', '''''') ;

		IF (g_log) THEN
			writelog('temp var is : '||tempvar);
		END IF;
		sDecodeClause := sDecodeClause||''''||tempvar ||''', ';
		IF (g_log) THEN
			writelog('decode clause is : '||sDecodeClause);
		END IF;

		END IF;


		IF (pAttributeName like 'USER_ATTRIBUTE%' and cRow.VALUE_SET_DATATYPE='N') THEN

		/* ----------------------------------------------------------------------------

			For bug 1723461, need to work around as the OWB UI will assume any
			segment is a VARCHAR2
		   	Hence a column which is actually a number is mapped to a USER_ATTRIBUTE
		   	and so we need to do a type cast

		------------------------------------------------------------------------------*/

			sDecodeClause := sDecodeClause|| 'TO_CHAR("'||l_gen_seg_name||'")';

		ELSE
			sDecodeClause := sDecodeClause|| '"'||l_gen_seg_name||'"';
		END IF;

		nCount := nCount + 1;
	END LOOP;


	sDecodeClause := sDecodeClause||', NULL)';

	/* --------------------------------------------------------------------------------------
	If the flexfield is one of the following, then we should NOT generate
	a decode clause(bug 2340462)

	MSTK : 401/INV - System Items.
	MTLL : 401/INV - Stock Locators
	MICG : 401/INV - Item Catalogs
	MDSP : 401/INV - Account Aliases
	----------------------------------------------------------------------------------------*/

	IF (pIdFlexCode in ('MSTK', 'MTLL', 'MICG', 'MDSP')) THEN
		sDecodeClause := 	 '"'||l_gen_seg_name||'"';
	END IF;

	/* if the context is global data elements then we should NOT generate
	   a  decode clause (bug 1463064) as this context is never stored in
	   the attribute_category field as it is a global context and will
	   exist even if other contexts are present */


	IF (upper(cRow.structure_name)='GLOBAL DATA ELEMENTS') THEN
            IF (pAttributeName like 'USER_ATTRIBUTE%' and cRow.VALUE_SET_DATATYPE='N') THEN
                sDecodeClause := 'TO_CHAR("'||l_gen_seg_name||'")';
            ELSE
			   sDecodeClause := '"'||l_gen_seg_name||'"';
            END IF;
	END IF;


	close c1;


	IF (g_log) THEN
		writelog(g_spacing||'Decode Clause is : ' || sDecodeClause);
		writelog('Completed getDecodeClauseForFlexCol');
		indentEnd;
	END IF;

	return sDecodeClause;

END;

/*---------------------------------------------------------
generate_pruned_view
-----------------------------------------------------------*/
PROCEDURE GeneratePrunedBisView(p_obj_name in varchar2) IS
  l_generated_view_name varchar2(30);
  l_flex_view_name varchar2(30);
  l_stmt varchar2(1000);
  l_cursor_id number;
  l_dummy number;
  l_status varchar2(30);
  l_errmesg varchar2(1000);
  type curType is ref cursor;
  c_failed_bg_view curType;
  c_failed_pruned_view curType;

  BEGIN
   l_stmt:='select distinct a.flex_view_name from edw_source_views a, edw_local_generation_status@'||g_source_db_link
    ||' b where a.object_name=:s1 and a.version= :s2 and b.generate_status =:s3 and a.flex_view_name = b.flex_view_name';

    IF g_log THEN
        writelog('going to execute :'||l_stmt);
    END IF;

    OPEN c_failed_bg_view FOR l_stmt USING p_obj_name, g_version, g_status_failed_all;
    LOOP

      FETCH c_failed_bg_view INTO l_flex_view_name;
      EXIT WHEN c_failed_bg_view%NOTFOUND;

      IF g_log THEN
          writelog('Needs to generate pruned '|| l_flex_view_name||' in '|| g_instance);
          writelog('Parameters passed to bis_view_generator_pvt.generate_pruned_view:'||l_flex_view_name||':'|| p_obj_name);
      END IF;


       l_stmt:='begin bis_view_generator_pvt.generate_pruned_view@'||g_source_db_link||' (:s1,:s2) ; end; ';

       IF g_log THEN
            writelog('going to execute :'||l_stmt);
       END IF;

     EXECUTE IMMEDIATE l_stmt USING l_flex_view_name, p_obj_name;

     l_stmt:= 'select generate_status, error_message from edw_local_generation_status@'|| g_source_db_link ||' where flex_view_name=:s1';

     OPEN c_failed_pruned_view FOR l_stmt  USING l_flex_view_name;

     FETCH c_failed_pruned_view INTO l_status, l_errmesg;

     CLOSE c_failed_pruned_view ;

	IF (g_log) THEN
	     writelog('l_status:'||l_status||'  g_status:'|| g_status_generated_pruned);
	END IF;

     IF l_status<> g_status_generated_pruned THEN
       IF g_log THEN
         writelog('Failed to generate pruned '|| l_flex_view_name||' in '|| g_instance);
         writelog('Error Message: ' || l_errmesg);
       END IF;
       g_error := l_errmesg;
       g_success := false;
       raise viewgen_exception;

	IF (g_log) THEN
	        writelog('Generated pruned '|| l_flex_view_name||' in '|| g_instance);
	END IF;
     END IF;
   END LOOP;
   CLOSE c_failed_bg_view;

exception
  when others then
    IF (g_log) THEN
      writelog('Exception!!! '|| sqlerrm);
      writelog('Inside GeneratePrunedBisView');
    END IF;
    g_success := false;
    raise viewgen_exception;
end;

Procedure Generate(p_obj_name in varchar2,
                  p_obj_type in varchar2,
                  p_instance in varchar2,
                  p_db_link in varchar2,
		  p_log_dir in varchar2 default null
                ) IS

	l_counter NUMBER:=-1;
	stmt  varchar2(3000);
	l_dummy integer;
	l_dir  VARCHAR2(100);
        l_view_name varchar2(30);

	TYPE CurTyp IS REF CURSOR;
	cv   CurTyp;
	l_count integer;
	l_validated_obj_type VARCHAR2(100);

BEGIN

	g_success 	:= true;
	g_source_db_link := p_db_link;
	g_instance 	:= p_instance;
	g_indenting 	:= '';
	g_obj_name 	:= p_obj_name;
	edw_misc_util.globalNamesOff;
      BEGIN
  	SELECT WAREHOUSE_TO_INSTANCE_LINK INTO g_source_db_link
	FROM edw_source_instances_vl
	WHERE instance_code = p_instance;
      EXCEPTION
        WHEN OTHERS THEN
 	 IF (g_log) THEN
  	    writelog('Exception in Generate!!! ' || sqlerrm);
  	    writelog('   *** ' || p_instance || ' is not defined as a source instance ***');
	 END IF;
	 RAISE;
      END;


        IF (p_log_dir IS NOT NULL ) THEN
            l_dir := p_log_dir;
	       l_file := utl_file.fopen(p_log_dir, p_instance||'_'||p_obj_name||'.log' ,'w');
           l_out_file:=utl_file.fopen(p_log_dir, p_instance||'_'|| p_obj_name||'.sql' ,'w');
    	   g_log := true;
	ELSE
	       l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
        END IF;

        IF (l_dir IS NULL) THEN
            l_dir := getUtlFileDir;
        END IF;

	  IF (l_dir IS NOT NULL ) THEN
	   	  l_file := utl_file.fopen(l_dir, p_instance||'_'||p_obj_name||'.log' ,'w');
          l_out_file := utl_file.fopen(l_dir, p_instance||'_'|| p_obj_name ||'.sql' ,'w');
		  g_log := true;
	   ELSE
	      g_log := false;
	   END IF;
	EDW_DIM_SV.g_log := g_log;
	EDW_FACT_SV.g_log:= g_log;


	IF (g_log) THEN
		writelog('---------------------------------------------------------'||newline);
		writeLog('System date at the time of view generation is '||
		to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
		writelog('View Generation for '||p_obj_type|| ' '||p_obj_name||newline);
                writelog( 'To be deployed on '||p_instance||' through db link '||p_db_link);
		writelog('---------------------------------------------------------'||newline);
    		writelog(newline);

	writelog('Inside Generate procedure');

	END IF;



	g_apps_schema := getAppsSchema;
    IF g_log THEN
        writelog('Apps Schema is : '||g_apps_schema);
    END IF;

	g_version := getAppsVersion;

    IF g_log THEN
        writelog('Apps Version is : '||g_version);
    END IF;

    IF    (p_obj_name LIKE 'EDW_FLEX_DIM%_M' OR p_obj_type LIKE 'EDW_GL_ACCT%_M') THEN
        null;
    ELSE
		IF (g_log) THEN
		       writelog('Going to call generatePrunedBisView to check view generation status');
		END IF;
           generatePrunedBisView(p_obj_name);
    END IF;

	/* Validate Object Type */

	SELECT count(1) into l_dummy from user_views where view_name='EDW_DIMENSIONS_MD_V';

	IF (l_dummy > 0) THEN /* EDW_DIMENSIONS_MD_V exists */
	    open cv for 'select count(1) from edw_dimensions_md_v where dim_name =:s1' using p_obj_name;
	    fetch cv into l_count;
	    close cv;
	    IF (l_count > 0) THEN
		l_validated_obj_type := 'DIMENSION';
	    ELSE
		l_validated_obj_type := 'FACT';
	    END IF;
	END IF;

	IF (g_log) THEN
		writelog('Object type after validation : '||l_validated_obj_type);
	END IF;

	writelog('');
	IF (l_validated_obj_type = 'DIMENSION') THEN
		edw_dim_sv.generateViewForDimension(p_obj_name);
	ELSE
		edw_fact_sv.generateViewForFact(p_obj_name);
	END IF;

	IF (NOT g_success) THEN
		IF (g_log) THEN
		writelog(g_error);
		utl_file.fclose(l_file);
		utl_file.fclose(l_out_file);

		END IF;
	END IF;


	stmt := 'delete from edw_object_deployments where
		 object_short_name = :obj and instance_code = :src';

	cid := DBMS_SQL.open_cursor;
	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
        DBMS_SQL.BIND_VARIABLE(cid, ':obj', p_obj_name, 50);
	DBMS_SQL.BIND_VARIABLE(cid, ':src', p_instance, 50);

	l_dummy := DBMS_SQL.EXECUTE(cid);
	DBMS_SQL.close_cursor(cid);

	cid := DBMS_SQL.open_cursor;
	stmt := 'INSERT INTO edw_object_deployments(object_short_name   ,
        dim_flag                ,
        instance_code           ,
        deployment_date         ,
        change_flag             ,
        last_update_date        ,
        last_updated_by         ,
        last_update_login       ,
        created_by              ,
        creation_date           ) VALUES
        (:obj, :dim_flag, :source, sysdate, ''N'', sysdate, 1, 1, 1, sysdate)';
	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.BIND_VARIABLE(cid, ':obj', p_obj_name, 50);

	IF (p_obj_type = 'DIMENSION') THEN
		DBMS_SQL.BIND_VARIABLE(cid, ':dim_flag', 'Y', 1);
	ELSE
		DBMS_SQL.BIND_VARIABLE(cid, ':dim_flag', 'N', 1);
	END IF;
	DBMS_SQL.BIND_VARIABLE(cid, ':source', p_instance, 50);
	l_dummy := DBMS_SQL.EXECUTE(cid);
	DBMS_SQL.close_cursor(cid);
    commit;


	IF (NOT g_success) THEN
		raise viewgen_exception;
	END IF;

	IF (g_log) THEN
		writelog(newline);
		writelog('Updated entries in edw_object_deployments');
		writelog('Completed view generation successfully.');
		utl_file.fclose(l_file);
		utl_file.fclose(l_out_file);

	END IF;

	EXCEPTION
		WHEN viewgen_exception THEN

		IF (g_log) THEN
			writelog('Exception!!! '||g_error);
			utl_file.fflush(l_file);
			utl_file.fclose(l_file);
			utl_file.fflush(l_out_file);
			utl_file.fclose(l_out_file);
		END IF;

		fnd_message.set_name('BIS', 'EDW_APPS_INT_GENERAL_ERROR');
		fnd_message.set_token('MESSAGE', g_error);
                fnd_message.set_token('LOGFILE',
			l_dir||'/'|| p_instance||'_'||p_obj_name||'.log' , FALSE);
                   app_exception.raise_exception;

	        RAISE;
		WHEN OTHERS THEN

		IF (g_log) THEN
			writelog('Exception!!! '||sqlerrm);
			utl_file.fflush(l_file);
			utl_file.fclose(l_file);
			utl_file.fflush(l_out_file);
			utl_file.fclose(l_out_file);

		END IF;
		RAISE;
END;

FUNCTION convertString(p_string IN VARCHAR2) RETURN VARCHAR2 IS
l_newstring VARCHAR2(100) := null;
l_length INTEGER := 0;
i 	 INTEGER := 0;
l_char	 VARCHAR2(10);

begin
        if (p_string is NULL) then return NULL; end if;

	l_length := length(p_string);
	for i in 1..l_length loop
		l_char := upper(substr(p_string, i, 1));
	        if (l_char = ' ' or l_char = '-' or l_char='&' or l_char='^') then
                         l_newstring := l_newstring||'_';
            else
			 l_newstring := l_newstring||l_char;
	        END IF;
	end loop;
	return l_newstring;
end;


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
l_where_exists boolean := false;

BEGIN

	IF (g_log) THEN
		edw_gen_view.indentBegin;
		edw_gen_view.writelog('Inside checkWhereClause for VS '||p_value_set_id);
	END IF;

	l_stmt := 'select additional_where_clause from fnd_flex_validation_tables@'||
		p_link||' where flex_value_set_id = :vsid';

	IF (g_log) THEN
		edw_gen_view.writelog('Querying where clause : '|| l_stmt);
	END IF;

	l_cursor:=dbms_sql.open_cursor;
	dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
  	dbms_sql.bind_variable(l_cursor, ':vsid', p_value_set_id);
	dbms_sql.define_column_long(l_cursor,1);

	  l_dummy:=dbms_sql.execute(l_cursor);

	  LOOP
	    -- fetch 'chunks' of the long until we have got the lot
	    edw_gen_view.writelog('Checking for bind variables '||l_count);
	    IF (dbms_sql.fetch_rows(l_cursor) = 0) THEN
		EXIT;
	    END IF;

	    dbms_sql.column_value_long(l_cursor,1,l_chunk_size,l_cur_pos,l_data_chunk,l_chunk_size_returned);

	    IF (upper(l_data_chunk) like '%$FLEX$' OR l_data_chunk like '%:%') THEN
		return false;
	    END IF;

	    edw_gen_view.writelog('Chunk size returned is '||l_chunk_size_returned);
	    l_cur_pos:=l_cur_pos+l_chunk_size;
	    exit when l_chunk_size_returned=0;

	    g_where_clause(l_count):=l_data_chunk;
	    l_where_exists := true;
	    l_count:= l_count +1;
	  END LOOP;

   dbms_sql.close_cursor(l_cursor);

   IF (l_where_exists ) THEN
	  g_where_clause(0) := ltrim(g_where_clause(0));
	  IF (lower(substr(g_where_clause(0), 0, 5) ) = 'where') THEN
		null;
	  ELSE
		g_where_clause(0) := ' where '||g_where_clause(0);
	  END IF;
   END IF;

  edw_gen_view.writelog('Completed checkWhereClause');
  edw_gen_view.indentEnd;
  return true;

END;

END EDW_GEN_VIEW;

/
