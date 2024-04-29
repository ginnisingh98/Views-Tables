--------------------------------------------------------
--  DDL for Package Body CS_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CTX_PKG" AS
 /* $Header: cscuctxb.pls 115.1 99/07/16 08:56:19 porting ship  $  */

/***********************************************************************
-- Get_Query_Word
--	- Parse string
-- 	- Ignores stop-words.
***********************************************************************/

  FUNCTION Get_Query_Word(keywords VARCHAR2,
			  operator VARCHAR2,
			  stop_words VARCHAR2) RETURN VARCHAR2 IS
    len 	 INTEGER;
    flag_first   INTEGER;
    remain_words VARCHAR2(2000);
    word 	 VARCHAR2(200);
    q_word 	 VARCHAR2(2000);
  BEGIN

    remain_words := keywords;
    len := length(keywords);
    -- Pad blank so that you can get the last word
    remain_words := RPAD(remain_words, len+1);
    remain_words := LTRIM(remain_words,' ');

    --
    flag_first := 0;

    -- Parse string for AND / OR condition.

    len := instr(remain_words, ' ');

    WHILE (len > 0) LOOP
	word := substr(remain_words, 1, len-1);

      IF (operator <> 'PHRASE') THEN
        -- If the word is a stop word then ignore it.
        IF instr(stop_words,upper(word)) = 0 THEN
           IF (flag_first = 0) THEN
             q_word := '{' || word || '}';
           ELSE
             q_word := q_word || operator || '{' || word || '}';
           END IF;
           --
           flag_first := 1;
           --
        END IF;
      ELSE
        IF (flag_first = 0) THEN
          q_word := '{' || word || '}';
        ELSE
        q_word := q_word || ' {' || word || '}';
        END IF;
        --
        flag_first := 1;
        --
      END IF;
      remain_words := substr(remain_words,len);
      remain_words := LTRIM(remain_words, ' ');
      len:= instr(remain_words, ' ');

    END LOOP;

    RETURN q_word;

  END get_query_word;


 /***********************************************************************
    Get_Context_Stop_Words: Returns a list of stop words.
  ***********************************************************************/

  PROCEDURE Get_Context_Stop_Words(stop_word_list OUT VARCHAR2,
					policy1 IN VARCHAR2 default NULL,
					policy2 IN VARCHAR2 default NULL,
					policy3 IN VARCHAR2 default NULL,
					policy4 IN VARCHAR2 default NULL)
  IS
      cursor_name INTEGER;
      string      VARCHAR2(500);
      rows_processed INTEGER;
      stop_word VARCHAR2(100);
      policies    VARCHAR2(2000);
      all_stop_words VARCHAR2(2000) := NULL;
  BEGIN
      policies:= ''''||upper(policy1)||''', '''||upper(policy2)||''', '''||upper(policy3)||''', '''||upper(policy4)||'''' ;

      string := 'Select unique pa.pat_value From ctxsys.dr$preference_attribute
	 pa, ctxsys.dr$preference pr, ctxsys.dr$policy po,
	 ctxsys.dr$preference_usage pu Where pa.pat_name = ''STOP_WORD''
	 AND pa.pat_pre_id = pu.pus_pre_id AND pu.pus_pol_id = po.pol_id
	 AND po.pol_name in (' || policies || ')' ;

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
  END; -- Get_Context_Stop_Words.


 /***********************************************************************
     Run_Ctx_Query:

 ***********************************************************************/

  PROCEDURE Run_Ctx_Query(policy1 	    IN VARCHAR2,
					policy2 	    IN VARCHAR2,
					policy3	    IN VARCHAR2,
					policy4 	    IN VARCHAR2,
					search_string  IN VARCHAR2,
					results_table IN VARCHAR2,
					conid1        IN NUMBER,-- unique id for policy1
					conid2        IN NUMBER,-- unique id for policy2
					conid3        IN NUMBER,-- unique id for policy3
					conid4        IN NUMBER-- unique id for policy4
					)
  IS
	 str1 VARCHAR2(2000) := NULL ;
	 str2 VARCHAR2(2000) := NULL ;
	 str3 VARCHAR2(2000) := NULL ;
	 str4 VARCHAR2(2000) := NULL ;
	 cursor_name INTEGER;
      rows_processed INTEGER; -- Not used currently
  BEGIN

   -- Create query strings:

   IF (policy1 is not null) THEN
	str1 := 'BEGIN  CTX_QUERY.CONTAINS('''||policy1||'''  ,''' || search_string
		   || ''',  '''||results_table || ''', 1, ' || conid1 ||',NULL); END;';

       --  The above string will really execute procedure:
       --      execute CTX_QUERY.CONTAINS('policy1','search_string',
	  --                                 'results_table', 1, condid1,NULL);

   END IF;

   IF (policy2 is not null) THEN
	str2 := 'BEGIN  CTX_QUERY.CONTAINS('''||policy2||'''  ,''' || search_string
		   || ''',  '''||results_table || ''', 1, ' || conid2 ||',NULL); END;';
   END IF;

   IF (policy3 is not null) THEN
	str3 := 'BEGIN  CTX_QUERY.CONTAINS('''||policy3||'''  ,''' || search_string
		   || ''',  '''||results_table || ''', 1, ' || conid3 ||',NULL); END;';
   END IF;

   IF (policy4 is not null) THEN
	str4 := 'BEGIN  CTX_QUERY.CONTAINS('''||policy4||'''  ,''' || search_string
		   || ''',  '''||results_table || ''', 1, ' || conid4 ||',NULL); END;';
   END IF;


   -- Call ctx's contains

    IF  str1 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str1,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF  str2 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str2,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;


    IF  str3 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str3,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

    IF  str4 is NOT NULL THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,str4,dbms_sql.v7);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
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
        END IF;

  END;


 /***********************************************************************
     Update_Context_Index: Reindex a policy for the given key.
  ***********************************************************************/

  PROCEDURE Update_Context_Index(policy_name IN VARCHAR2,
                                 primary_key IN VARCHAR2)
  IS
      cursor_name INTEGER;
      string      VARCHAR2(200);
      rows_processed INTEGER; -- Not used currently
  BEGIN
      string := 'BEGIN ctx_dml.reindex('''||policy_name||''','''||primary_key||'
''); END;';
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


 /***********************************************************************
     Clean_Results_Table: Given a results table name this procedure
    					 will remove the rows from the results table
    				      for given CONIDs
    NOTE: You can call this proc from KEY-EXIT and KEY-CLRFRM triggers.
		Make sure to call forms_ddl('commit') after the call.
 ************************************************************************/

  PROCEDURE Clean_Results_Table(results_table IN VARCHAR2,
					conid1 	     IN NUMBER DEFAULT 0,
					conid2 	     IN NUMBER DEFAULT 0,
					conid3 	     IN NUMBER DEFAULT 0,
					conid4 	     IN NUMBER DEFAULT 0
					)
  IS
      cursor_name INTEGER;
      string      VARCHAR2(200);
      rows_processed INTEGER; -- Not used currently
  BEGIN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,'DELETE FROM '||results_table||' WHERE conid IN (:c1,:c2,:c3,:c4)',dbms_sql.v7);
	 dbms_sql.bind_variable(cursor_name, ':c1',conid1);
	 dbms_sql.bind_variable(cursor_name, ':c2',conid2);
	 dbms_sql.bind_variable(cursor_name, ':c3',conid3);
	 dbms_sql.bind_variable(cursor_name, ':c4',conid4);
      rows_processed := dbms_sql.execute(cursor_name);
      dbms_sql.close_cursor(cursor_name);
  EXCEPTION
     WHEN OTHERS THEN
      IF dbms_sql.is_open(cursor_name) THEN
         dbms_sql.close_cursor(cursor_name);
      END IF;
      raise;

  END;

 /***********************************************************************
     Get_Conids: Given a sequence name and no of con ids, this proc
    		       will return upto 4 unique conids.
  Note: This procedure is not working and is not being used.
  ***********************************************************************/

  PROCEDURE Get_Conids(sequence_name IN VARCHAR2,
                      no_of_conids  IN NUMBER,
                      conid1        OUT NUMBER,
                      conid2        OUT NUMBER,
                      conid3        OUT NUMBER,
                      conid4        OUT NUMBER
                      )
  IS
      seqval VARCHAR2(100);
      cursor_name INTEGER;
      string      VARCHAR2(200);
      rows_processed INTEGER; -- Not used currently
	 c1 number :=0;

  BEGIN

    seqval := sequence_name||'.nextval';

    IF no_of_conids >0 THEN
      cursor_name := dbms_sql.open_cursor;
      dbms_sql.parse(cursor_name,'SELECT CS_INCIDENTS_CTX_S.nextval FROM DUAL', dbms_sql.v7);
	 dbms_sql.define_column(cursor_name,1,c1);
--	 dbms_sql.bind_variable(cursor_name, ':c1',conid1);
      rows_processed := dbms_sql.execute_and_fetch(cursor_name);
      dbms_sql.close_cursor(cursor_name);

	 conid1:=c1;

	 /***
	  SELECT cs_incidents_ctx_s.nextval
	  INTO conid1
	  FROM dual;
	  ****/
    END IF;

/****
    IF no_of_conids >1 THEN
	  SELECT cs_incidents_ctx_s.nextval
	  INTO conid2
	  FROM dual;
    END IF;

    IF no_of_conids >2 THEN
	  SELECT cs_incidents_ctx_s.nextval
	  INTO conid3
	  FROM dual;
    END IF;

    IF no_of_conids >3 THEN
	  SELECT cs_incidents_ctx_s.nextval
	  INTO conid4
	  FROM dual;
    END IF;

****/
    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   raise;

  END;


/***********************************************************************
 Search:
***********************************************************************/

  PROCEDURE  Search(policy1 in  VARCHAR2,
 		    policy2 in  VARCHAR2,
		    policy3 in  VARCHAR2,
		    policy4 in  VARCHAR2,
		    stop_words in VARCHAR2,
		    search_string in  VARCHAR2,
		    search_option in  VARCHAR2,  -- 'AND', 'OR', 'EXACT'
		    results_table in  VARCHAR2,
		    conid1 in NUMBER,-- unique id for policy1
		    conid2 in NUMBER,-- unique id for policy2
		    conid3 in NUMBER,-- unique id for policy3
		    conid4 in NUMBER-- unique id for policy4
		    ) IS
    l_search_string 	VARCHAR2(2000);
    operator 	VARCHAR2(10);

  BEGIN


    IF (search_option in ('AND','OR','PHRASE')) THEN
      IF (search_option = 'AND') THEN
          operator := ' & ';
      ELSIF (search_option = 'OR') THEN
          operator := ' , ';
	 ELSE
		operator := 'PHRASE';
      END IF;
      	-- Get the parsed string.
      l_search_string := Get_Query_Word(search_string, operator, stop_words);
    ELSE
	-- Send the input string as is for phrase and advanced searches.
	l_search_string := search_string;
    END IF;


    -- RUN THE CONTEXT QUERY

    IF l_search_string is NOT NULL THEN
      Run_Ctx_Query(policy1,
			     policy2,
			     policy3,
			     policy4,
			     l_search_string,
			     results_table,
			     conid1,
			     conid2,
			     conid3,
			     conid4
			     );
    END IF;
  END Search;


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
