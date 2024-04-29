--------------------------------------------------------
--  DDL for Package Body QA_CORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CORE_PKG" as
/* $Header: qltcoreb.plb 120.0 2005/05/24 17:08:49 appldev noship $ */

FUNCTION get_result_column_name (ELEMENT_ID IN NUMBER, P_ID IN NUMBER) RETURN VARCHAR2 IS
--
-- This is a function that returns the unique column name in the table
-- qa_results given an element_id, plan_id combination.
--

   name      	VARCHAR2(2400);
   hardcoded	VARCHAR2(240);


 /* Bug 3754667. Commenting out the below cursors as it is no longer used.

   CURSOR c1   (P_ID NUMBER) IS

		select hardcoded_column
        	from qa_chars
        	where char_id = P_ID;

   CURSOR c2   (E_ID NUMBER) IS

		select developer_name
        	from qa_chars
        	where char_id = E_ID;

   CURSOR c3   (pl_id NUMBER,
		ch_id    NUMBER)  IS

		select result_column_name
        	from qa_plan_chars
       		where plan_id = pl_id
         	and char_id = ch_id;
 */

    BEGIN

     -- Bug 3754667. We'll use the qa_chars_api and qa_plan_element_api
     -- functions to use the cache instead of the cursors that fetches
     -- from the DB each time.
     -- kabalakr. Wed Jul 28 03:06:38 PDT 2004.

     /* OPEN c1 (ELEMENT_ID);
        FETCH c1 INTO hardcoded;
        CLOSE c1;
     */

        hardcoded :=  qa_chars_api.hardcoded_column(ELEMENT_ID);

        if (hardcoded is not null) then

	     /* OPEN c2 (ELEMENT_ID);
		FETCH c2 INTO name;
		CLOSE c2;
             */

             name := qa_chars_api.developer_name(ELEMENT_ID);

        else

	     /* OPEN c3 (P_ID, ELEMENT_ID);
        	FETCH c3 INTO name;
        	CLOSE c3;
             */

             name := qa_plan_element_api.qpc_result_column_name(P_ID, ELEMENT_ID);

        end if;

        return name;

  EXCEPTION  when others then
    raise;

END get_result_column_name;


FUNCTION get_element_id (ELEMENT_NAME IN VARCHAR2) RETURN NUMBER IS
--
-- This is a function that returns the element id (char_id) given
-- an element name.
--

   ID NUMBER;

BEGIN

   	select char_id into ID
   	from qa_chars
   	where upper(Name) = upper(ELEMENT_NAME);

   	return ID;

 EXCEPTION  when others then
    raise;

END get_element_id;


FUNCTION get_plan_id ( PLAN_NAME IN VARCHAR2) RETURN NUMBER   IS
--
-- This is a function that returns the plan id given a plan name.
--
--

   ID NUMBER;

BEGIN

        select plan_id into ID
   	from qa_plans
   	where Name = PLAN_NAME;

   	return ID;


 EXCEPTION  when others then
    raise;

END get_plan_id;


FUNCTION get_plan_name (GIVEN_PLAN_ID IN NUMBER) RETURN VARCHAR2  IS
--
-- This is a function that returns the plan name givn a plan id
--

   PLAN_NAME VARCHAR2(240);

BEGIN

   /* Bug 3754667. We would use the cache implementation in qa_plans_api
      rather than fetching plan_name from DB each time. kabalakr

	select name into PLAN_NAME
   	from qa_plans
   	where plan_id = GIVEN_PLAN_ID;
   */

        PLAN_NAME := qa_plans_api.plan_name(GIVEN_PLAN_ID);

   	return PLAN_NAME;

 EXCEPTION  when others then
    raise;

END get_plan_name;


FUNCTION is_mandatory (GIVEN_PLAN_ID IN NUMBER, ELEMENT_ID IN NUMBER) RETURN BOOLEAN  IS
--
-- This is a function that determines if an element is mandatory for a plan.
-- Calling program must supply a plan_id and the element_id for the element
-- in question.
--

    result 	NUMBER;

BEGIN

  /* Bug 3754667. We would use the cache implementation in qa_plan_element_api
     rather than fetching the mandatory flag from the DB each time. kabalakr.

    select mandatory_flag into result
    from qa_plan_chars
    where plan_id = GIVEN_PLAN_ID and char_id = ELEMENT_ID;

  */

    result := qa_plan_element_api.qpc_mandatory_flag(GIVEN_PLAN_ID, ELEMENT_ID);

    if (result = 1) then
       return true;
    else
       return false;
    end if;


 EXCEPTION  when others then
    raise;

END is_mandatory;


FUNCTION get_element_data_type (ELEMENT_ID IN NUMBER) RETURN NUMBER  IS
--
-- This is a function that determines the data type of a collection element.
-- This is a overloaded function.  This function takes element id as the
-- parameter.
--
-- The possible data type are:
--
--	datatype 1 is Character
-- 	datatype 2 is Number
-- 	datatype 3 is Date

    atype    number;

BEGIN

    select datatype into atype from qa_chars where char_id = ELEMENT_ID;

    return atype;

 EXCEPTION  when others then
    raise;


END get_element_data_type;


FUNCTION get_element_data_type (ELEMENT_NAME IN VARCHAR2) RETURN NUMBER  IS
--
-- This is a function that determines the data type of a collection element.
-- This is a overloaded function.  This function takes element name as the
-- parameter.
--
-- The possible data type are:
--
--	datatype 1 is Character
-- 	datatype 2 is Number
-- 	datatype 3 is Date

    atype    number;

    BEGIN

    -- datatype 1 is Character
    -- datatype 2 is Number
    -- datatype 3 is Date

    select datatype into atype from qa_chars where name = ELEMENT_NAME;

    return atype;

  EXCEPTION  when others then
    raise;

END get_element_data_type;


PROCEDURE EXEC_SQL (STRING IN VARCHAR2) IS
--
-- This is a procedure that executes a sql script.  Calling program must
-- supply a valid sql statement.
--
-- This is a duplicate procedure, I will remove it as soon as
-- I can get a chance -OB


   CUR INTEGER;
   RET INTEGER;

BEGIN

   CUR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(CUR, STRING, DBMS_SQL.NATIVE);
   RET := DBMS_SQL.EXECUTE(CUR);
   DBMS_SQL.CLOSE_CURSOR(CUR);

exception when others then
   IF dbms_sql.is_open(cur) THEN
       dbms_sql.close_cursor(cur);
   END IF;
   raise;
END EXEC_SQL;

--------------------------------------------
-- Copying Bryans function from qltvcreb here
-- isivakum : this is a useful function in core pkg

FUNCTION dequote(s1 in varchar2) RETURN varchar2 IS
--
-- The string s1 may be used in a dynamically constructed SQL
-- statement.  If s1 contains a single quote, there will be syntax
-- error.  This function returns a string s2 that is same as s1
-- except each single quote is replaced with two single quotes.
-- Put in for NLS fix.  Previously if plan name or element name
-- contains a single quote, that will cause problem when creating
-- views.
-- bso
--
BEGIN
    RETURN replace(s1, '''', '''''');
END;
--------------------------------------------------------


-- Bug 3777530
/* --------------------------------------------------------------- */
/* PROC exec_sql_with_bind                                         */
/* This is a generic procedure for executing dynamic SQL with      */
/* dynamic BIND variables.                                         */
/* IN parameters -                                                 */
/* p_sql -  Dynamic sql string with bind variables in the string   */
/* vars_in - bind parameters occuring in the SQL string exactly    */
/*           should be paased in order of occurence in SQL in this */
/*           table.                                                */
/* values_in - Values correcsponding to the bind parameters in     */
/*             same orderand index  as bind variables              */
/* saugupta Wed, 01 Dec 2004 23:03:20 -0800 PDT                    */
/* --------------------------------------------------------------- */

PROCEDURE exec_sql_with_binds(p_sql in varchar2,
                              vars_in IN var_in_tab,
                              values_in IN value_in_tab) IS
cursor_handle INTEGER;
status INTEGER;
counter INTEGER;
count_var INTEGER;
count_val INTEGER;

BEGIN

    IF (vars_in.COUNT() <> values_in.count()) THEN
       RAISE_APPLICATION_ERROR(-20999,'Bind variables and values does not match');
       RETURN;
    END IF ;

    cursor_handle := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(cursor_handle,p_sql,dbms_sql.native);

    FOR i IN vars_in.FIRST .. vars_in.LAST
    LOOP
    DBMS_SQL.BIND_VARIABLE (cursor_handle, vars_in(i), values_in(i));
    END LOOP;

    status := DBMS_SQL.EXECUTE(cursor_handle);

    DBMS_SQL.CLOSE_CURSOR (cursor_handle);

EXCEPTION
    WHEN OTHERS
    THEN
       IF DBMS_SQL.IS_OPEN(cursor_handle) THEN
           DBMS_SQL.CLOSE_CURSOR (cursor_handle);
       END IF;
    RAISE;
END exec_sql_with_binds;



-- Bug 4270911. CU2 SQL Literal fix.
-- Set of procedures to execute a dynamic sql from forms.
-- Wrapper for fnd_dsql procedures.
-- Use restricted to DDL.
-- srhariha. Mon Apr 18 06:11:06 PDT 2005.

-- Simple Wrappers around fnd_dsql

PROCEDURE dsql_init IS

BEGIN

  fnd_dsql.init;

END dsql_init;



PROCEDURE dsql_add_text(p_text IN VARCHAR2) IS

BEGIN

 fnd_dsql.add_text(p_text);
END dsql_add_text;


PROCEDURE dsql_add_bind(p_value       IN VARCHAR2) IS

BEGIN

  fnd_dsql.add_bind(p_value);
END dsql_add_bind;

PROCEDURE dsql_add_bind(p_value       IN DATE) IS

BEGIN

  fnd_dsql.add_bind(p_value);
END dsql_add_bind;

PROCEDURE dsql_add_bind(p_value       IN NUMBER) IS

BEGIN

  fnd_dsql.add_bind(p_value);
END dsql_add_bind;



-- Execute procedure. Executes the SQL built by the
-- add_text and add_bind calls.

PROCEDURE dsql_execute IS

cursor_handle NUMBER;
sql_text VARCHAR2(32000);
ret_value NUMBER;

BEGIN

  cursor_handle := dbms_sql.open_cursor;

  fnd_dsql.set_cursor(cursor_handle);

  sql_text := fnd_dsql.get_text;

  -- qa_skiplot_utility.insert_error_log(p_module_name => 'cu2.qlttxn.100', p_error_message => sql_text);

  dbms_sql.parse(cursor_handle,sql_text,dbms_sql.NATIVE);

  -- bind the variable
  fnd_dsql.do_binds;

  ret_value := dbms_sql.execute(cursor_handle);

  dbms_sql.close_cursor(cursor_handle);

EXCEPTION
    WHEN OTHERS
    THEN
       IF dbms_sql.is_open(cursor_handle) THEN
           dbms_sql.close_cursor (cursor_handle);
       END IF;
    RAISE; -- dont know what to do with exception. So just propagate it.


END dsql_execute;



end QA_CORE_PKG;


/
