--------------------------------------------------------
--  DDL for Package Body PER_DRT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_RULES" AS
/* $Header: pedrtrul.pkb 120.0.12010000.15 2019/07/01 12:37:57 hardeeps noship $ */

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> RANSTR : Generate new value for given String              |
  -- +--------------------------------------------------------------------+

  function ranstr (start_of_range pls_integer, end_of_range pls_integer)
  return varchar2
  is
    l_size integer ;
  begin
    l_size := round(DBMS_RANDOM.value(start_of_range,end_of_range));
    return DBMS_RANDOM.STRING('x',l_size);
  end ranstr;
  --
  -- Maps to Rule Type Random Number
  --
  function rannum(start_of_range pls_integer, end_of_range pls_integer)
  return number
  is
  begin
    return round(DBMS_RANDOM.value(start_of_range,end_of_range));
  end rannum;

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> GETLONG : Returns NULL for Long datatype	              |
  -- +--------------------------------------------------------------------+

  function getlong (p_table_name varchar2, p_column_name varchar2, p_schema varchar2) return varchar2
  as
    l_data_type varchar2(20);
    cursor dtype is select DATA_TYPE from all_tab_columns
      where table_name=upper(p_table_name) and COLUMN_NAME=upper(p_column_name) and OWNER=upper(p_schema);
  begin
    open dtype;
    fetch dtype into l_data_type;
    if dtype%notfound then
       close dtype;
       raise_application_error(-20010,'Invalid Table Column combination');
    end if;
    close dtype;
    if l_data_type = 'LONG' then
      return 'NULL';
    else
      return p_column_name;
    end if;
  end;

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> RANSTR : Generate new value for given Number              |
  -- +--------------------------------------------------------------------+

	function rannum(start_of_range number, end_of_range number)
	return varchar2
	is
	begin
	  return to_char(round(DBMS_RANDOM.value(start_of_range,end_of_range)));
	end rannum;

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> RANNUM : Generate new value for given Number              |
  -- +--------------------------------------------------------------------+

  function rannum
  return number
  is
  begin
    return round(DBMS_CRYPTO.RANDOMNUMBER);
  end rannum;
  --
  -- Variation of Random Number
  -- Returns integer in the complete range available for BINARY_INTEGER datatype.
  --
  function ranint return integer
  is
  begin
    return DBMS_CRYPTO.RANDOMINTEGER;
  end ranint;

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> RANBYT : Generate new value for given Byte                |
  -- +--------------------------------------------------------------------+

  function ranbyt (p_positive_num positive)
  return raw
  is
  begin
    return DBMS_CRYPTO.RANDOMBYTES(p_positive_num);
  end ranbyt;

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> RANDAT : Generate new value for given date                |
  -- +--------------------------------------------------------------------+

  function randat (p_date_val date)
  return date
  is
    l_increment integer := DBMS_CRYPTO.RANDOMINTEGER;
    l_date_val date;
  begin
    --
    -- Ensure date is increased by no more than a years
    --
    l_date_val := p_date_val + mod(l_increment,365);
    return l_date_val;
  end randat;

  -- +------------------------------------------------------------------------------+
  -- |BEGIN >>> NAME2MAIL : Generate 2 sub-strings linked with dot for given string |
  -- +------------------------------------------------------------------------------+

  FUNCTION name2mail
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 as
    PRAGMA AUTONOMOUS_TRANSACTION;
    encrypted_string varchar2(40);
    i pls_integer := 0;
    l_name varchar2(150);
  begin
    execute immediate 'select ' || column_name || ' from ' || table_name ||
      ' where rowid = :row_id ' into l_name using rid ;
		if l_name is null then
			return null;
		end if;
    encrypted_string := dbms_crypto.hash(cast(l_name as clob), dbms_crypto.hash_sh1);
    while length(encrypted_string) > 15 and i < 10 loop
      encrypted_string := replace(encrypted_string,to_char(i),NULL);
      i := i + 1;
    end loop;
    i := per_drt_rules.rannum(5,16);
    encrypted_string := initcap(substr(encrypted_string,1,i))||'.'||initcap(substr(encrypted_string,i+1));
    return encrypted_string||'@example.invalid';
  end name2mail;

  -- +--------------------------------------------------------------------+
  -- |	get_cols_for_upd : replacement of listagg, returns clob           |
  -- +--------------------------------------------------------------------+

	FUNCTION get_cols_for_upd (p_table_id in per_drt_tables.table_id%TYPE, p_column_phase  in  per_drt_columns.column_phase%TYPE,
	p_context in  per_drt_col_contexts.context_name%TYPE,
	p_ffn in  per_drt_columns.ff_type%TYPE)
	  RETURN CLOB
	IS
	  l_text  clob := NULL;
	  l_table_name varchar2(128);
	  l_schema varchar2(50);

		CURSOR validate_table IS
		  SELECT  table_name
		         ,schema
		  FROM    per_drt_tables
		  WHERE   table_id = p_table_id;

	BEGIN

		open validate_table;
	  	fetch validate_table into l_table_name, l_schema;
	  close validate_table;

	  FOR cur_rec IN (SELECT  column_phase
	       ,decode (ff_type
	               ,'NONE'
	               ,'NONE'
	               ,'FF') ff_type
	       ,(column_name
	        || '='
	        || 'nvl2('
	        || column_name
	        || ','
	        || decode (upper (rule_type)
	                  ,'FIXED STRING'
	                  ,''''
	                   || nvl (parameter_1
	                          ,'***')
	                   || ''''
	                  ,'RANDOM STRING'
	                  ,'per_drt_rules.ranstr'
	                   || per_drt_rules.get_param (nvl (parameter_1
	                                                   ,1)
	                                              ,nvl (parameter_2
	                                                   ,10))
	                  ,'RANDOM NUMBER'
	                  ,'per_drt_rules.rannum'
	                   || per_drt_rules.get_param (nvl (parameter_1
	                                                   ,1)
	                                              ,nvl (parameter_2
	                                                   ,1000))
	                  ,'USER DEFINED FUNCTION'
	                  ,parameter_1
	                   || '.'
	                   || parameter_2
	                   || '('
	                   || 'ROWID'
	                   || ','''
	                   || l_table_name
	                   || ''','''
	                   || column_name
	                   || ''','
	                   || 'l_person_id'
	                   || ')'
	                  ,rule_type)
	        || ','
	        || per_drt_rules.getlong(l_table_name,column_name,l_schema)
	        || ')') cols_for_upd
	FROM    per_drt_all_columns
	WHERE   (
	                nvl2 (p_context
	                     ,nvl (context_name
	                          ,'x')
	                     ,ff_type) = nvl2 (p_context
	                                      ,nvl2 (context_name
	                                            ,p_context
	                                            ,'z')
	                                      ,'NONE')
	        OR      context_name = 'Global Data Elements'
	        )
	AND     nvl2 (p_ffn
	             ,nvl (ff_name
	                  ,'x')
	             ,ff_type) = nvl2 (p_ffn
	                              ,nvl2 (ff_name
	                                    ,p_ffn
	                                    ,'z')
	                              ,'NONE')
	AND     table_id = p_table_id
	AND     column_phase = p_column_phase
	AND     upper (rule_type) NOT IN ('POST PROCESS','DELETE')
	ORDER BY column_phase
	        ,column_name) LOOP
	    l_text := l_text || ',' || fnd_global.local_chr(10) || cur_rec.cols_for_upd;
	  END LOOP;
	  RETURN LTRIM(l_text, ','||fnd_global.local_chr(10));
	END get_cols_for_upd;


  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> RANDAT : Generate new value for given date                |
  -- +--------------------------------------------------------------------+

  procedure validate_dml_or_query (dml_or_query clob, sql_type varchar2 default 'DML')
  as
  refc sys_refcursor;
  INVALID_COLUMN exception;
  INVALID_TERMINATOR exception;
  PRAGMA EXCEPTION_INIT(INVALID_TERMINATOR,-933);
  PRAGMA EXCEPTION_INIT(INVALID_COLUMN,-904);
  begin
  savepoint test_only;
  if sql_type = 'DML' then
    begin
      execute immediate dml_or_query;
    exception
      when INVALID_COLUMN then
        raise_application_error(-20001,'Invalid Column entered. Describe Table to check valid columns');
      when INVALID_TERMINATOR then
        raise_application_error(-20001,'Don''t end the query with semicolon or other character');
      when others then
        raise_application_error(-20001, SQLERRM);
    end;
  elsif sql_type = 'SQL' then
    begin
      open refc for dml_or_query;
      close refc;
    exception
      when INVALID_COLUMN then
        raise_application_error(-20001,'Invalid Column entered. Describe Table to check valid columns');
      when INVALID_TERMINATOR then
        raise_application_error(-20001,'Don''t end the query with semicolon or other character');
      when others then
        close refc;
        raise_application_error(-20001, SQLERRM);
    end;
  else
    raise_application_error(-20001,'Un-Supported statement. Only DML and Query are allowed');
  end if;
  rollback to test_only;
  end validate_dml_or_query;

  -- +--------------------------------------------------------------------+
  -- |BEGIN >>> GET_PARAM : Return formatted parameter                     |
  -- +--------------------------------------------------------------------+

  FUNCTION get_param (p1 varchar2 default null,p2 varchar2 default null) return varchar2 is
    p varchar2(100);
  BEGIN
    if p1 is not null and p2 is not null then
       p := '('||p1||','||p2||')';
    elsif p1 is not null then
       p := '('||p1||','||'NULL'||')';
    elsif p2 is not null then
       p := '('||'NULL'||','||p2||')';
    else
       p := NULL;
    end if;
    return p;
  END get_param;

  --  +------------------------------------------------------------------+
  --  |BEGIN >>> GETDML : Generate UPDATE and DELETE staements           |
  --  +------------------------------------------------------------------+

  procedure getdml(p_table_id number, p_ffn varchar2 default NULL, p_context varchar2 default NULL, dml_stmt OUT NOCOPY clob)
  as
  where_clause varchar2(4000);
  delrow number;
  l_rule_type varchar2(30);
  invalid_sub_query exception;
  invalid_rule_type exception;
  table_not_exist EXCEPTION;
  wrong_context exception;
  PRAGMA EXCEPTION_INIT (wrong_context, -20002);
  PRAGMA EXCEPTION_INIT (invalid_sub_query, -20003);
  PRAGMA EXCEPTION_INIT (table_not_exist, -44002);
  PRAGMA EXCEPTION_INIT (invalid_sub_query, -20001);
  dict_table_name varchar2(128);
  l_table_name varchar2(128);
  l_schema varchar2(50);
  --
  -- Verify table is seeded
  --
  cursor validate_table is
     SELECT table_name, schema
      FROM per_drt_tables
      WHERE table_id = p_table_id;
  --
  -- One delete per table
  --
  cursor get_tab_cols (drtt varchar2) is SELECT  NULL
     FROM per_drt_all_columns
     WHERE table_id = drtt
     and upper(rule_type) = 'DELETE'
     and decode(FF_TYPE,'NONE','x',FF_NAME) = decode(FF_TYPE,'NONE','x',p_ffn)
     and decode(FF_TYPE,'NONE','x',CONTEXT_NAME) = decode(FF_TYPE,'NONE','x',p_context)
     and rownum = 1;
  --
  -- Rule type shall be one of the following
  -- Delete, Post Process, Fixed String, Random String, Random Number, User Defined Function and Null
  --
  cursor chk_rule_type (tbl varchar2) is
     SELECT  null
     FROM per_drt_all_columns
     WHERE table_id = tbl
	 AND upper(rule_type) NOT IN ('DELETE','POST PROCESS','FIXED STRING','RANDOM NUMBER','RANDOM STRING','USER DEFINED FUNCTION','NULL');
  --
  -- Retrive Record Identifier for the given table
  --
  CURSOR extract_rec_identifier IS
  SELECT  trim(replace(upper(RECORD_IDENTIFIER)
                  ,'<:PERSON_ID>'
                  ,'L_PERSON_ID'))
  FROM    per_drt_tables
  WHERE   table_id = p_table_id;
  ---
  kffnum number := NULL;
  l_ret_code varchar2(30) := NULL;
  upd_stmt clob;
  del_stmt clob;
  --
  -- Verify that a valid context is passed if passed
  --
  FUNCTION invalid_context (ffn varchar2, ffcontext varchar2) return boolean
  as
  begin
     if ffcontext is not null then
        SELECT  d.context_column_name
        INTO    l_ret_code
        FROM    fnd_descriptive_flexs d
               ,fnd_descr_flex_contexts c
        WHERE   d.application_id = c.application_id
        AND     d.descriptive_flexfield_name = c.descriptive_flexfield_name
		    AND     d.descriptive_flexfield_name = ffn
        AND     c.descriptive_flex_context_code = ffcontext
        AND     rownum = 1;
     end if;
	   RETURN FALSE;
  exception
     WHEN NO_DATA_FOUND then
	      begin
		       SELECT  context_column_name
			     INTO    l_ret_code
           FROM    per_drt_kffs
           WHERE   flexfield_name = ffn
           AND     context_code = ffcontext
			     AND     rownum = 1;
			     ---
			     SELECT ID_FLEX_NUM
			     INTO   kffnum
			     FROM   FND_ID_FLEX_STRUCTURES
			     WHERE  ID_FLEX_CODE = ffn
			     AND    ID_FLEX_STRUCTURE_CODE = ffcontext
			     AND    rownum = 1;
  	       RETURN FALSE;
		    exception
           WHEN NO_DATA_FOUND then
	         RETURN TRUE;
		    end;
  end INVALID_CONTEXT;
begin
  --
  -- Check correctness of metadata
  --
  open validate_table;
  fetch validate_table into l_table_name, l_schema;
  close validate_table;
  --
  -- Check that table accessible to APPS
  --
  dict_table_name := DBMS_ASSERT.sql_object_name(l_table_name);
  --
  if INVALID_CONTEXT (p_ffn,p_context) then
     raise wrong_context;
  end if;
  --
  -- Create WHERE CLAUSE from Sub-Query (Record Identifier)
  --
  open extract_rec_identifier;
  fetch extract_rec_identifier into where_clause;
  close extract_rec_identifier;
  --
  -- Ensure all colunms associated to valid rules
  --
  open chk_rule_type(p_table_id);
  fetch chk_rule_type into l_rule_type;
  if chk_rule_type%found then
     raise invalid_rule_type;
  end if;
  close chk_rule_type;
  --
  where_clause := 'WHERE (' ||
				  replace(replace(replace(where_clause,'<PERSON_ID>','L_PERSON_ID'),'  ',' '),'IN(','IN (')||
				  ')';
  --
  If instr(where_clause,'L_PERSON_ID',1) = 0 then
     raise invalid_sub_query;
  else
     -- Add predicate for KFF
     if kffnum is NOT NULL and l_ret_code is NOT NULL then
        where_clause := where_clause || ' ' || fnd_global.local_chr(10) || 'AND ' || l_ret_code || ' = ' || kffnum ;
	 -- Add predicate for DFF/DDF
	 	 elsif l_ret_code is NOT NULL then
				if p_context = 'Global Data Elements' then
					where_clause := where_clause || ' ' || fnd_global.local_chr(10) || 'AND ' || l_ret_code || ' is NULL ';
				else
        	where_clause := where_clause || ' ' || fnd_global.local_chr(10) || 'AND ' || l_ret_code || ' = ''' || p_context || '''';
				end if;
     end if;
  end if;
  /*
  --+ Added code to validate syntax of record identifier
  --+ Begin
  validate_dml_or_query('SQL','SELECT NULL FROM ' || l_table_name || ' ' || where_clause || ' AND ROWNUM=1');
  --+ End
  */
  --
  <<GENERATE_UPD_STMT>>
  FOR i in
  (
    SELECT  column_phase,decode(ff_type,'NONE','NONE','FF')
       ,get_cols_for_upd (table_id
                              ,column_phase,p_context,p_ffn)  cols_for_upd
    FROM    per_drt_all_columns
    WHERE   (nvl2 (p_context
             ,nvl (context_name
                  ,'x')
             ,ff_type) = nvl2 (p_context
                              ,nvl2 (context_name
                                    ,p_context
                                    ,'z')
                              ,'NONE') or context_name = 'Global Data Elements')
    AND     nvl2 (p_ffn
             ,nvl (ff_name
                  ,'x')
             ,ff_type) = nvl2 (p_ffn
                              ,nvl2 (ff_name
                                    ,p_ffn
                                    ,'z')
                              ,'NONE')
    AND     table_id = p_table_id
    AND     upper (rule_type) NOT IN ('POST PROCESS','DELETE')
    GROUP BY table_id,column_phase,decode(ff_type,'NONE','NONE','FF')
    ORDER BY column_phase
  )
  LOOP
     upd_stmt := 'UPDATE '|| l_table_name || ' SET ' || fnd_global.local_chr(10);
     upd_stmt := upd_stmt || i.cols_for_upd || fnd_global.local_chr(10) || where_clause ;
     /*
     --+ Added code to validate syntax of UPDATE DML
     --+ Begin
     validate_dml_or_query('DML',upd_stmt || ' AND ROWNUM=1');
     --+ End
     */
     upd_stmt := upd_stmt || ';' || fnd_global.local_chr(10);
     dml_stmt := dml_stmt || fnd_global.local_chr(10) || '-- UPDATE (' || i.column_phase || '.' || nvl(p_ffn, 'None') || '.' || nvl(p_context,'None') || ')' || fnd_global.local_chr(10) || upd_stmt;
  END LOOP GENERATE_UPD_STMT;
  --
  open get_tab_cols(p_table_id);
  fetch get_tab_cols into delrow;
  if get_tab_cols%found then
     del_stmt := 'DELETE FROM ' || l_table_name || fnd_global.local_chr(10) || where_clause;
     /*
     --+ Added code to validate syntax of DELETE DML
     --+ Begin
     validate_dml_or_query('DML',del_stmt || ' AND ROWNUM=1');
     --+ End
     */
     del_stmt := del_stmt || ';' || fnd_global.local_chr(10);
     dml_stmt := fnd_global.local_chr(10) || '-- DELETE Statement' || fnd_global.local_chr(10) || del_stmt;
  end if;
  close get_tab_cols;
exception
  when wrong_context then
     dml_stmt := 'Structure ' || p_context || ' is undefined for flexfield ' || p_ffn || ' and table ' || l_table_name || ' #' || to_char(p_table_id);
     raise_application_error(-20001,dml_stmt);
  when invalid_rule_type then
     dml_stmt := 'Invalid Rule type associated to at least one of the columns of ' || l_table_name || ' #' || to_char(p_table_id) ;
     raise_application_error(-20001,dml_stmt);
  when invalid_sub_query then
     dml_stmt := 'Record Identifier of ' || l_table_name || ' #' || to_char(p_table_id) || 'doesn''t have predicate PERSON_ID=<PERSON_ID>';
     raise_application_error(-20001,dml_stmt);
  when table_not_exist then
     dml_stmt := 'Table ' || l_table_name || ' isn''t accessible to ' || USER;
     raise_application_error(-20001,dml_stmt);
  when too_many_rows then
     dml_stmt := 'Multiple entry found for table ' || l_table_name || ' #' || to_char(p_table_id) || ' in metadata table';
     raise_application_error(-20001,dml_stmt);
  when no_data_found then
     dml_stmt := 'No entry found for table ' || l_table_name || ' #' || to_char(p_table_id) || ' in metadata table';
     raise_application_error(-20001,dml_stmt);
  end getdml ;
  --
  --  +------------------------------------------------------------------+
  --  |BEGIN >>> GETSQL : Generate Query and execute to produce row count|
  --  +------------------------------------------------------------------+

  procedure getsql (p_table_name varchar2, p_person_id number, sql_stmt OUT NOCOPY varchar2) as
  table_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT (table_not_exist, -44002);
  table_name varchar2(128);
  l_count number;
  l_bind_cnt PLS_INTEGER;
  l_query varchar2(4000);
  where_clause varchar2(4000);
  CURSOR validate_table IS
  SELECT  trim(replace (RECORD_IDENTIFIER
                  ,'<:person_id>'
                  ,':l_person_id'))
  FROM    per_drt_tables
  WHERE   table_name = p_table_name;
  begin
  table_name := DBMS_ASSERT.sql_object_name(p_table_name);
  open validate_table;
  fetch validate_table into where_clause;
  close validate_table;
  where_clause := replace(where_clause,'<person_id>',':l_person_id');
  l_bind_cnt := REGEXP_COUNT(where_clause,':l_person_id');
  l_query := 'SELECT count(*) FROM ' || p_table_name || ' WHERE ' || where_clause ;
  if l_bind_cnt = 1 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id;
  elsif l_bind_cnt = 2 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id;
  elsif l_bind_cnt = 3 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 4 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 5 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 6 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 7 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 8 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 9 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id;
  elsif l_bind_cnt = 10 then
     EXECUTE IMMEDIATE l_query INTO l_count
	 using p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id,p_person_id;
  else
     raise_application_error(-20001,'Maximum 10 bind variables are allowed in record identifier');
  end if;
  sql_stmt := '-- Query' || fnd_global.local_chr(10) || fnd_global.local_chr(10) || l_query || fnd_global.local_chr(10);
  sql_stmt := 'Returns ' || l_count ||' row(s)';
  exception
  when table_not_exist then
     sql_stmt :=  'Table doesn''t exist for logged in user';
  when too_many_rows then
     sql_stmt := 'Multiple entry found for table ' || p_table_name || ' in metadata table';
  when no_data_found then
     sql_stmt := 'No entry found for table ' || p_table_name || ' in metadata table PER_DRT_TABLES';
  end getsql;
  --
  --  +---------------------------------------------------------------------------------------------------------------------+
  --  |BEGIN >>> RECOMPILE_PROC : Regenerate Procedure each time Metadata is changed. Parameter determines Proc to recompile|
  --  +---------------------------------------------------------------------------------------------------------------------+
  --
  procedure recompile_proc (etype varchar2)
  as
  ERROR_STACK VARCHAR2(32767);
  cursor entity_dml is
  SELECT  DISTINCT
          table_id
         ,decode (ff_type
                 ,'NONE'
                 ,'N'
                 ,'Y') is_it_ff
         ,column_phase
         ,ff_name
         ,context_name
  FROM    per_drt_all_columns
  WHERE   entity_type = etype
  ORDER BY table_id,decode (ff_type,'NONE','N','Y'),column_phase;
  l_dml_stmt clob;
  psc clob default NULL;
  proc_name varchar2(20);
  begin
  for i in entity_dml loop
    if i.IS_IT_FF='N' then
      per_drt_rules.getdml(P_TABLE_ID=>i.TABLE_ID, DML_STMT=>l_dml_stmt);
      psc := psc || l_dml_stmt ;
    else
      per_drt_rules.getdml(P_TABLE_ID=>i.TABLE_ID,P_FFN=>i.FF_NAME,P_CONTEXT=>i.CONTEXT_NAME, DML_STMT=>l_dml_stmt);
      psc := psc || l_dml_stmt;
    end if;
  end loop;
  if etype = 'HR' then
     proc_name := 'REMOVE_HR_PERSON';
  elsif etype = 'TCA' then
     proc_name := 'REMOVE_TCA_PARTY';
  else
     proc_name := 'REMOVE_FND_USER';
  end if;
  psc := 'CREATE OR REPLACE PROCEDURE ' || proc_name || ' (l_person_id number) AS'
         || fnd_global.local_chr(10) || 'BEGIN' || fnd_global.local_chr(10)
         || nvl(psc,'NULL;')
         || fnd_global.local_chr(10) || 'END;'
         || fnd_global.local_chr(10);
  execute immediate psc;
  exception
  when others then
    ERROR_STACK := proc_name ;
    for z in (SELECT rpad(line || ',' || position,14,'.') || text error_line
              FROM user_errors
              WHERE type = 'PROCEDURE' AND name = proc_name) LOOP
      ERROR_STACK := ERROR_STACK || fnd_global.local_chr(10) || z.error_line;
    END LOOP;
	ERROR_STACK := SQLERRM || fnd_global.local_chr(10) || ERROR_STACK;
   raise_application_error(-20001,ERROR_STACK);
  end;

  --
  --  +---------------------------------------------------------------------------------------------------------------------+
  --  |BEGIN >>> SUBMIT_REQUEST : Submit requests for recompiling DML procedures for all entity types                       |
  --  +---------------------------------------------------------------------------------------------------------------------+
  --

  procedure submit_request(errbuf out NOCOPY varchar2, retcode out NOCOPY number, p_entity_type varchar2)
  is
  l_proc varchar2(60) := 'PER_DRT_RULES.submit_request';
  begin
  fnd_file.put_line(fnd_file.log, 'Re-Compile Entity :' || p_entity_type);
  ---
  if p_entity_type = 'ALL' then
     fnd_file.put_line(fnd_file.log, 'Compiling : HR');
     per_drt_rules.recompile_proc('HR');
     fnd_file.put_line(fnd_file.log, 'Compiling : TCA');
     per_drt_rules.recompile_proc('TCA');
     fnd_file.put_line(fnd_file.log, 'Compiling : FND');
     per_drt_rules.recompile_proc('FND');
  else
     fnd_file.put_line(fnd_file.log, 'Compiling :' || p_entity_type);
     per_drt_rules.recompile_proc(p_entity_type);
  end if;
  ---
  fnd_file.put_line(fnd_file.log, 'Re-Compiled Entity :' || p_entity_type);
  end submit_request;

  --
  --  +---------------------------------------------------------------------------------------------------------------------+
  --  |BEGIN >>> DRT_RECOMPILE : Recompile Metadata for Data Removal Tool                                                   |
  --  +---------------------------------------------------------------------------------------------------------------------+
  --

  PROCEDURE drt_compile(entity_type IN  VARCHAR2, request_id OUT NOCOPY number)
  is
  l_request_id number(15) := 0;
  BEGIN
  --
  --- Submitting Recompile Metadata for Data Removal Tool Concurrent Request
  --
  l_request_id := fnd_request.submit_request (
                            application   => 'PER',
                            program       => 'RECOMPILE_DRT_METADATA',
                            description   => 'Recompile Metadata for Data Removal Tool',
                            start_time    => sysdate,
                            sub_request   => FALSE,
                            argument1    => entity_type);
  --
  -- Retrun the concurrent request ID
  --
  request_id := l_request_id;
  END drt_compile;

end PER_DRT_RULES;

/
