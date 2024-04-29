--------------------------------------------------------
--  DDL for Package FND_DSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DSQL" AUTHID CURRENT_USER AS
/* $Header: AFUTSQLS.pls 120.1.12010000.5 2015/08/06 22:03:50 emiranda ship $ */

TYPE t_bind_rec  IS RECORD(
    bind_name       VARCHAR2(30),
    bind_type_value VARCHAR2(1) default 'V',    -- V=Varchar2 , D=Date , N=Number
    bind_type_arg   VARCHAR2(1) default 'I',    -- I=Input , O=Output
    bind_value      VARCHAR2(100),
    bind_return     VARCHAR2(2000),
    bind_size       Number default 100
    );


  TYPE t_rec_4cols IS RECORD(
    col_name1      VARCHAR2(500),
    col_name2      VARCHAR2(500),
    col_name3      VARCHAR2(500),
    col_name4      VARCHAR2(500)
  );

  TYPE T_REC_OAM_FORM IS RECORD(
    menu_id              fnd_responsibility.menu_id%type,
    prompt               fnd_menu_entries_tl.description%type,
    responsibility_id    fnd_responsibility.responsibility_id%TYPE,
    responsibility_name  fnd_responsibility_tl.responsibility_name%type
  );

  TYPE t_rtn_4srecs IS TABLE OF t_rec_4cols;

  TYPE t_rtn_OAM_FORM IS TABLE OF T_REC_OAM_FORM;


/* ----------------------------------------------------------------------
EXAMPLE

  Let's say you want to construct

  SELECT my_column1, my_column2
    FROM my_table
   WHERE my_varchar2_column = l_my_varchar2
     AND my_date_column = l_my_date
     AND my_number_column = l_my_number


  If this select statement is used frequently and if l_my_* variables are
  changing each time, you should use binding to improve performance.

  However if your select statement is constructed in different procedures
  you cannot pass all binds between those procedures.

  Here how to use this package. You can call these functions from anywhere you
  want. fnd_dsql package will keep track of bind variables.

  ...
  l_my_varchar2 := 'fnd_dsql test';
  l_my_date := to_date('02-JAN-1980','DD-MON-YYYY');
  l_my_number := 12345;

  fnd_dsql.init;

  fnd_dsql.add_text('SELECT my_column1, my_column2 ' ||
                    'FROM my_table WHERE my_varchar2_column = ');
  fnd_dsql.add_bind(l_my_varchar2);

  fnd_dsql.add_text('AND my_date_column = ');
  fnd_dsql.add_bind(l_my_date);

  fnd_dsql.add_text('AND my_number_column = ');
  fnd_dsql.add_bind(l_my_number);

  l_cursor_id := dbms_sql.open_cursor;
  fnd_dsql.set_cursor(l_cursor_id);

  --
  -- l_dsql_text will be:
  --  SELECT my_column1, my_column2
  --   FROM my_table
  --  WHERE my_varchar2_column = :FND_BIND1
  --    AND my_date_column = :FND_BIND2
  --    AND my_number_column = :FND_BIND3
  --
  l_dsql_text := fnd_dsql.get_text(FALSE);
  dbms_sql.parse(l_cursor_id, l_dsql_text, dbms_sql.native);

  fnd_dsql.do_binds;

  l_num_of_rows := dbms_sql.execute(l_cursor_id);

  l_dsql_debug := fnd_dsql.get_text(TRUE);

  --
  -- l_dsql_debug will be:
  --
  -- SELECT my_column1, my_column2
  --   FROM my_table
  --  WHERE my_varchar2_column = :FND_BIND1
  --    AND my_date_column = :FND_BIND2
  --    AND my_number_column = :FND_BIND3
  -- C:FND_BIND1= fnd_dsql_test
  -- D:FND_BIND2= 1980/01/02 00:00:00
  -- N:FND_BIND3= 12345
  --
  ...
  ---------------------------------------------------------------------- */


 /* ======================================================================
  * ERROR HANDLING
  * ----------------------------------------------------------------------
  * In case of any error, this package will raise exception and will set
  * message through fnd_message.
  * To get this message use FND_MESSAGE utilities.
  * ====================================================================== */


 /* ======================================================================
  * PROCEDURE init:
  * ----------------------------------------------------------------------
  * Initializes the internal structures.
  * ====================================================================== */
  PROCEDURE init;

 /* ======================================================================
  * PROCEDURE add_text:
  * ----------------------------------------------------------------------
  * Appends p_text to the end of current dynamic sql statement.
  * ====================================================================== */
  PROCEDURE add_text(p_text IN VARCHAR2);

 /* ======================================================================
  * PROCEDURE add_bind:
  * ----------------------------------------------------------------------
  * Appends :FND_BINDn to the end of current dynamic sql statement.
  * n is the index of bind variable.
  * p_value will be stored, and it will be binded in do_binds call.
  * Maximum size for p_value in varchar2 case : 2000.
  * Maximum number of binds : 100.
  * Per bug 14385923 Increasing number of binds to 512
  * ====================================================================== */
  PROCEDURE add_bind(p_value       IN VARCHAR2);

  PROCEDURE add_bind(p_value       IN DATE);

  PROCEDURE add_bind(p_value       IN NUMBER);

 /* ======================================================================
  * PROCEDURE set_cursor:
  * ----------------------------------------------------------------------
  * Sets the cursor id for current dynamic sql statment.
  * ====================================================================== */
  PROCEDURE set_cursor(p_cursor_id IN INTEGER);

 /* ======================================================================
  * PROCEDURE do_binds:
  * ----------------------------------------------------------------------
  * Binds the bind variables.
  * ====================================================================== */
  PROCEDURE do_binds;

 /* ======================================================================
  * FUNCTION get_text:
  * ----------------------------------------------------------------------
  * Returns current dynamic sql statement.
  * ====================================================================== */
  FUNCTION get_text(p_with_debug IN BOOLEAN DEFAULT FALSE) RETURN VARCHAR2;

 /* ======================================================================
  * PROCEDURE fnd_dsql_test:
  * ----------------------------------------------------------------------
  * Used to test this package.
  * ====================================================================== */
  PROCEDURE fnd_dsql_test;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  /*
  ** Function Function_Exec_4binds ( Created by emiranda - Nov-06-2014 )
  **           Execute a Dynamic PLSQL block with 3 bind-values
  **           and a return value, expected PLSQL contains
  **           a total of 4-binds, this is including the possible return
  ** INPUT
  **  p_plsql_dyn  - expect a PLSQL-code using a format like this:
  **                 :r := AAAAA.function( :a , :b );
  **                 :m := fnd_message.get; -- Grab the message from plsql-cache
  **                 with the exact names of BINDS ( r , a, b , m )
  **
  **  p_value1 - Second bind :a maximum length 100 characters
  **
  **  p_value2 - Third bind :b maximum length 100 characters
  **
  **  p_value_out1 - Forth bind :m maximum length 2000 characters
  **
  **  p_trap_errors_dyn - Flag to trap error ( TRUE/FALSE )
  **
  **  RETURN
  **  ie :r (First bind)  (Y/N) possible output depends on the API been call
  **                            maximum length 100 characters,
  **         OR  'E' if any error occurs and the FLAG  p_trap_errors
  **             is TRUE then the error is put into the PLSQL-buffer
  **
  **  created under BUG 19531101
  */
  FUNCTION Function_Exec_4binds(p_plsql_dyn       VARCHAR2,
                                p_value1          VARCHAR2,
                                p_value2          VARCHAR2,
                                p_value_out1      OUT NOCOPY VARCHAR2,
                                p_trap_errors_dyn BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2;

/*
**
** Scoping Rule functions
**  Created to avoid the limitation of the 1-level down
**  for subqueries that generates an ORA-904 if the queri
**  is too complex to process. This functions will alow
**  to re-write queries for higher performance.
**    Create by : Enrique Miranda ( ATG-CORE)
**         Date : May 11 2015
**
** Start:
*/

  FUNCTION setScopingRule_num( p_name varchar2, p_value number )
    return VARCHAR2 DETERMINISTIC;
  FUNCTION setScopingRule_var( p_name varchar2, p_value varchar2 )
    return VARCHAR2 DETERMINISTIC;

  FUNCTION getScopingRule_num( p_name varchar2 )
    return NUMBER DETERMINISTIC;
  FUNCTION getScopingRule_var( p_name varchar2 )
    return VARCHAR2 DETERMINISTIC;

  FUNCTION setSR_Bindnum( p_pos number, p_value number )
    return VARCHAR2 DETERMINISTIC;

  FUNCTION setSR_Bindvar( p_pos number, p_value varchar2 )
    return VARCHAR2 DETERMINISTIC;

  FUNCTION getSR_Bindnum( p_pos number )
    return NUMBER DETERMINISTIC;

  FUNCTION getSR_Bindvar( p_pos number )
    return VARCHAR2 DETERMINISTIC;

/*
** End.
**
** Scoping Rule functions
**
*/

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  FUNCTION set_query(p_key   VARCHAR2,
                     p_bind1 VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
   FUNCTION cur_4cols_1bind(p_key VARCHAR2 )
     RETURN t_rtn_4srecs PIPELINED;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
   FUNCTION OAM_FORM_NAV_GET RETURN t_rtn_OAM_FORM PIPELINED;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
   FUNCTION OAM_FORM_NAV_SET( p_bind1 VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

END fnd_dsql;

/
