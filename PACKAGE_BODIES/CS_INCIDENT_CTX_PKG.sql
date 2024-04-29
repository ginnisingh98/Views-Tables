--------------------------------------------------------
--  DDL for Package Body CS_INCIDENT_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENT_CTX_PKG" AS
/* $Header: cssrctxb.pls 115.1 99/07/16 09:02:08 porting ship  $ */

  PROCEDURE Execute_Query_Contains(str1 IN VARCHAR2,str2 IN VARCHAR2,
			str3 IN VARCHAR2,str4 IN VARCHAR2,result_table IN VARCHAR2)
  IS
      cursor_name INTEGER;
	 rows_processed INTEGER; -- Not used currently
  BEGIN

    IF result_table is not NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,'TRUNCATE TABLE '||result_table,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF str1 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str1,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF str2 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str2,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF str3 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str3,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF str4 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str4,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
--        IF instr(sqlerrm,'DRG-10817') <>0 THEN (This errror is returned if
--			query string contains any stop words. Not required as we are
--			now filterung off stop words.)

        IF instr(sqlerrm,'DRG-10308') <>0 THEN
		 IF dbms_sql.is_open(cursor_name) THEN
               dbms_sql.close_cursor(cursor_name);
  		 END IF;
  	      fnd_message.set_name('CS','CS_INC_CTX_NO_SERVER');
  	      app_exception.raise_exception;
        ELSE
           dbms_sql.close_cursor(cursor_name);
           fnd_message.set_name('CS','CS_SR_CONTEXT_ERROR');
           fnd_message.set_token('ERRORM',sqlerrm);
           app_exception.raise_exception;
		 --raise;
        END IF;
  END; -- Execute_query_contains.



  PROCEDURE Update_Context_Index(policy_name IN VARCHAR2,primary_key IN VARCHAR2)
  IS
      cursor_name INTEGER;
      string      VARCHAR2(200);
	 rows_processed INTEGER; -- Not used currently
  BEGIN
      string := 'BEGIN ctx_dml.reindex('''||policy_name||''','''||primary_key||'''); END;';
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,string,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
  EXCEPTION
     WHEN OTHERS THEN
	 IF dbms_sql.is_open(cursor_name) THEN
         dbms_sql.close_cursor(cursor_name);
  	 END IF;
	 raise;
  END; -- update_context_index.

  --
  -- Get_stop_words
  --
  PROCEDURE Get_Context_Stop_Words(stop_word_list OUT VARCHAR2)
  IS
      cursor_name INTEGER;
      string      VARCHAR2(500);
	 rows_processed INTEGER;
	 stop_word VARCHAR2(100);
	 all_stop_words VARCHAR2(2000) := NULL;
  BEGIN

      string := 'Select unique pa.pat_value
	 From ctxsys.dr$preference_attribute pa,
	 ctxsys.dr$preference pr,
	 ctxsys.dr$policy po,
	 ctxsys.dr$preference_usage pu
	 Where pa.pat_name = ''STOP_WORD''
	 AND pa.pat_pre_id = pu.pus_pre_id
	 AND pu.pus_pol_id = po.pol_id
	 AND po.pol_name in
	 (''CS_INCIDENTS_SUMMARY'',''CS_INCIDENTS_COMMENTS'',
	 ''CS_INCIDENTS_PROBLEM_DESC'', ''CS_INCIDENTS_RESOLUTION_DESC'')';

      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,string,dbms_sql.v7);
	 dbms_sql.define_column(cursor_name,1,stop_word,100);
      rows_processed := dbms_sql.execute(cursor_name);
	 LOOP
		IF dbms_sql.fetch_rows(cursor_name) >0 THEN
		    -- get column values of the row.
		    dbms_sql.column_value(cursor_name,1,stop_word);
		    all_stop_words := all_stop_words || stop_word || ' ';
		ELSE
		    EXIT;
		END IF;
	 END LOOP;
      dbms_sql.close_cursor(cursor_name);
	 stop_word_list:=all_stop_words;
  EXCEPTION
     WHEN OTHERS THEN
	   IF dbms_sql.is_open(cursor_name) THEN
           dbms_sql.close_cursor(cursor_name);
  	   END IF;
	   raise;
  END; -- Get_Stop_Words.

/***********************************************************************
 Get_Result_Table: Gets a results table for context search from the pool.
***********************************************************************/

 PROCEDURE Get_Result_Table(result_table  OUT VARCHAR2) IS
   str VARCHAR2(2000) := NULL ;
   cursor_name INTEGER;
   rows_processed INTEGER; -- Not used currently
 BEGIN
      str := 'BEGIN CTX_QUERY.GETTAB(CTX_QUERY.hittab,:res_tab); END;';

      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str,dbms_sql.v7);
      dbms_sql.bind_variable(cursor_name,':res_tab',null,100);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.variable_value(cursor_name,':res_tab',result_table);
      dbms_sql.close_cursor(cursor_name);

 END Get_Result_Table;

/***********************************************************************
 Release_Result_Table: Releases the passed results table from the pool.
***********************************************************************/

 PROCEDURE Release_Result_Table(result_table IN VARCHAR2) IS
   str VARCHAR2(2000) := NULL ;
   cursor_name INTEGER;
   rows_processed INTEGER; -- Not used currently
 BEGIN
      str := 'BEGIN CTX_QUERY.RELTAB('''|| result_table || '''); END;';

      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
 END Release_Result_Table;


END;

/
