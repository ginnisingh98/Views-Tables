--------------------------------------------------------
--  DDL for Package Body FND_DSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DSQL" AS
/* $Header: AFUTSQLB.pls 120.1.12010000.7 2015/08/06 22:05:22 emiranda ship $ */

TYPE VARCHAR2_TBL_TYPE IS VARRAY(512) OF VARCHAR2(4000);
TYPE DATE_TBL_TYPE     IS VARRAY(512) OF DATE;
TYPE NUMBER_TBL_TYPE   IS VARRAY(512) OF NUMBER;

subtype t_bigvc2    IS VARCHAR2(32767);

SUBTYPE MAX_VC2_T   IS VARCHAR2(6000); -- Maximum varchar2 table-field
SUBTYPE SMALL_KEY_T IS VARCHAR2(50);   -- Small Key

TYPE t_bind_internal IS TABLE OF t_bind_rec INDEX BY BINARY_INTEGER;

g_maximum_varray_size CONSTANT pls_integer := 512;

--
-- Global Variables:
--
g_dsql_text          VARCHAR2(32000);
g_cursor_id          INTEGER;
g_nbinds             PLS_INTEGER;
g_bind_ttbl          VARCHAR2_TBL_TYPE; -- bind types
g_bind_vtbl          VARCHAR2_TBL_TYPE; -- varchar2 type bind values
g_bind_dtbl          DATE_TBL_TYPE;     -- date type bind values
g_bind_ntbl          NUMBER_TBL_TYPE;   -- number type bind values

chr_newline          VARCHAR2(8);
g_package_name       VARCHAR2(30) := 'fnd_dsql';

--
-- Scoping Rules Types and arrays
--
  subtype typ_vsmall IS VARCHAR2(200);

  TYPE typ_rc_num IS RECORD(
    f_key       varchar2(40),
    f_value      NUMBER);
  TYPE t_rec_num IS TABLE OF typ_rc_num INDEX BY VARCHAR2(40);

  TYPE typ_rc_var IS RECORD(
    f_key       varchar2(40),
    f_value     typ_vsmall
   );

  TYPE t_rec_data is RECORD(
      psql_query MAX_VC2_T,
      psql_1bind typ_vsmall
  );


  TYPE t_rec_var IS TABLE OF typ_rc_var INDEX BY VARCHAR2(40);

  TYPE t_bind_num IS TABLE OF number INDEX BY PLS_INTEGER;

  TYPE t_bind_var IS TABLE OF typ_vsmall INDEX BY PLS_INTEGER;

  TYPE t_flags is table of boolean index by varchar2(30);

  TYPE t_rec IS TABLE OF t_rec_data INDEX BY SMALL_KEY_T;


  z_init_value t_flags;  -- initialize values

  v_pair_num  t_rec_num;  -- vector of pair-values with numbers
  v_pair_var  t_rec_var;  -- vector of pair-values with varchar2

  v_bind_num  t_bind_num;  -- vector of pair-values with numbers
  v_bind_var  t_bind_var;  -- vector of pair-values with varchar2

   v_sql       t_rec;


-- ======================================================================
-- Utility Functions
-- ======================================================================

  PROCEDURE ol(vvar VARCHAR2) IS
    tmp_r t_bigvc2;
  BEGIN
    null;
    -- Uncomment the follow for debug print
    /*
    tmp_r := RTRIM(LTRIM(vvar));
    WHILE LENGTH(tmp_r) > 253 LOOP
      DBMS_OUTPUT.put_line(SUBSTR(tmp_r, 1, 253));
      tmp_r := SUBSTR(tmp_r, 254);
    END LOOP;
    DBMS_OUTPUT.put_line(tmp_r);
    */
  END ol;

  PROCEDURE oldbg(p_val      VARCHAR2,
                  p_variable VARCHAR2,
                  p_len      NUMBER DEFAULT 0) AS

    l_tmp    t_bigvc2;
    l_subset BOOLEAN;
  BEGIN
    null;
    -- Uncomment the follow for debug print
    /*
    l_subset := ( (NVL(p_len, 0) > 0) AND (LENGTH(p_variable) > p_len) );
    IF l_subset = TRUE THEN
      l_tmp := SUBSTR(p_variable, 1, p_len);
    ELSE
      l_tmp := SUBSTR(p_variable, 1, 32767);
    END IF;
    IF p_variable IS NOT NULL THEN
      IF l_subset = TRUE THEN
        ol(p_val || ',subset-len(' || p_len || '): [ ' || l_tmp ||
           ' ], len(' || LENGTH(p_variable) || ')');
      ELSE
        ol(p_val || ' :[ ' || l_tmp || ' ], len(' ||
           LENGTH(p_variable) || ')');
      END IF;
    ELSE
      ol(p_val || ' :[' || l_tmp || '], len(0)');
    END IF;
    */

  END oldbg;

  -- Field-Clean
  --  This implementations removes Escape-extra(left/righ) spaces-
  --  tab-character, chr(10) and colon-character
  FUNCTION fClean( p_val VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
  RETURN LTRIM(RTRIM(
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p_val,
                                                  fnd_global.Local_Chr(9)),
                                          fnd_global.Local_Chr(10)),
                                  fnd_global.Local_Chr(13)),
                          fnd_global.Local_Chr(27)),
                  fnd_global.Local_Chr(59))
               ));
   END fClean;

PROCEDURE report_error(p_routine IN VARCHAR2,
		       p_reason  IN VARCHAR2)
  IS
BEGIN
   fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
   fnd_message.set_token('ROUTINE', p_routine);
   fnd_message.set_token('REASON', p_reason);
END report_error;

-- ======================================================================
-- Public Functions
-- ======================================================================
PROCEDURE init
  IS
BEGIN
   fnd_dsql.g_dsql_text  := NULL;
   fnd_dsql.g_cursor_id  := NULL;
   fnd_dsql.g_nbinds     := 0;
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.init' , Sqlerrm);
      RAISE;
END init;


PROCEDURE add_text(p_text IN VARCHAR2) IS
BEGIN
   fnd_dsql.g_dsql_text := fnd_dsql.g_dsql_text || p_text;
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.add_text()', Sqlerrm);
      RAISE;
END add_text;


PROCEDURE add_bind(p_value IN VARCHAR2)
  IS
BEGIN
   if (fnd_dsql.g_nbinds = g_maximum_varray_size) then
      raise_application_error(-20001, 'Bind arrays are full. ' ||
       'Maximum Number of Binds: ' || g_maximum_varray_size);
   end if;
   fnd_dsql.g_nbinds := fnd_dsql.g_nbinds + 1;

   fnd_dsql.g_bind_ttbl(fnd_dsql.g_nbinds) := 'C';
   fnd_dsql.g_bind_vtbl(fnd_dsql.g_nbinds) := p_value;

   fnd_dsql.g_dsql_text := (fnd_dsql.g_dsql_text ||
			    ':FND_BIND' || To_char(fnd_dsql.g_nbinds));
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.add_bind(VARCHAR2)', Sqlerrm);
      RAISE;
END add_bind; --VARCHAR2


PROCEDURE add_bind(p_value IN DATE)
  IS
BEGIN
   if (fnd_dsql.g_nbinds = g_maximum_varray_size) then
      raise_application_error(-20001, 'Bind arrays are full. ' ||
       'Maximum Number of Binds: ' || g_maximum_varray_size);
   end if;
   fnd_dsql.g_nbinds := fnd_dsql.g_nbinds + 1;

   fnd_dsql.g_bind_ttbl(fnd_dsql.g_nbinds) := 'D';
   fnd_dsql.g_bind_dtbl(fnd_dsql.g_nbinds) := p_value;

   fnd_dsql.g_dsql_text := (fnd_dsql.g_dsql_text ||
			    ':FND_BIND' || To_char(fnd_dsql.g_nbinds));
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.add_bind(DATE)', Sqlerrm);
      RAISE;
END add_bind; --DATE

PROCEDURE add_bind(p_value IN NUMBER)
  IS
BEGIN
   if (fnd_dsql.g_nbinds = g_maximum_varray_size) then
      raise_application_error(-20001, 'Bind arrays are full. ' ||
       'Maximum Number of Binds: ' || g_maximum_varray_size);
   end if;
   fnd_dsql.g_nbinds := fnd_dsql.g_nbinds + 1;

   fnd_dsql.g_bind_ttbl(fnd_dsql.g_nbinds) := 'N';
   fnd_dsql.g_bind_ntbl(fnd_dsql.g_nbinds) := p_value;

   fnd_dsql.g_dsql_text := (fnd_dsql.g_dsql_text ||
		 	    ':FND_BIND' || To_char(fnd_dsql.g_nbinds));
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.add_bind(NUMBER)', Sqlerrm);
      RAISE;
END add_bind; --NUMBER


PROCEDURE set_cursor(p_cursor_id IN INTEGER)
  IS
BEGIN
   fnd_dsql.g_cursor_id := p_cursor_id;
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.set_cursor_id()', Sqlerrm);
      RAISE;
END set_cursor;

PROCEDURE do_binds
  IS
BEGIN
   FOR i IN 1..fnd_dsql.g_nbinds LOOP
      IF (fnd_dsql.g_bind_ttbl(i) = 'D') THEN
	 dbms_sql.bind_variable(fnd_dsql.g_cursor_id,
				':FND_BIND' || To_char(i),
				fnd_dsql.g_bind_dtbl(i));
       ELSIF (fnd_dsql.g_bind_ttbl(i) = 'N') THEN
	 dbms_sql.bind_variable(fnd_dsql.g_cursor_id,
				':FND_BIND' || To_char(i),
				fnd_dsql.g_bind_ntbl(i));
       ELSE
	 dbms_sql.bind_variable(fnd_dsql.g_cursor_id,
				':FND_BIND' || To_char(i),
				fnd_dsql.g_bind_vtbl(i));
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.do_binds()', Sqlerrm);
      RAISE;
END do_binds;


FUNCTION get_text(p_with_debug IN BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2
  IS
     l_return    VARCHAR2(32000);
BEGIN
   l_return := Rtrim(Ltrim(fnd_dsql.g_dsql_text));
   IF (p_with_debug) THEN
      l_return := l_return || chr_newline;
      FOR i IN 1..fnd_dsql.g_nbinds LOOP
	 l_return := (l_return || fnd_dsql.g_bind_ttbl(i) ||
		      ':FND_BIND' || To_char(i) || '=' );
	 IF (fnd_dsql.g_bind_ttbl(i) = 'D') THEN
	    l_return := l_return || To_char(fnd_dsql.g_bind_dtbl(i),
					    'YYYY/MM/DD HH24:MI:SS');
	  ELSIF (fnd_dsql.g_bind_ttbl(i) = 'N') THEN
	    l_return := l_return || fnd_dsql.g_bind_ntbl(i);
	  ELSE
	    l_return := l_return || fnd_dsql.g_bind_vtbl(i);
	 END IF;
	 l_return := l_return || chr_newline;
      END LOOP;
   END IF;
   RETURN (l_return);
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.get_text()', Sqlerrm);
      RAISE;
END get_text;

PROCEDURE dbms_debug(p_debug IN VARCHAR2)
  IS
     i INTEGER;
     m INTEGER;
     c INTEGER := 75;
BEGIN
   execute immediate ('begin dbms' ||
		      '_output' ||
		      '.enable(1000000); end;');
   m := Ceil(Length(p_debug)/c);
   FOR i IN 1..m LOOP
      execute immediate ('begin dbms' ||
			 '_output' ||
			 '.put_line(''' ||
			 REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''') ||
			 '''); end;');
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END dbms_debug;

PROCEDURE fnd_dsql_test
  IS
     i INTEGER;
     m INTEGER;
     l_dsql VARCHAR2(32000);
     l_debug VARCHAR2(32000);
BEGIN
   fnd_dsql.init;
   fnd_dsql.add_text('Start:' || chr_newline);
   i := 0;
   LOOP
      i := i + 1;
      IF i > g_maximum_varray_size THEN
	 EXIT;
      END IF;
      m := MOD(i,3);
      fnd_dsql.add_text(' i:' || To_char(i));
      IF m = 0 THEN
	 fnd_dsql.add_text('varchar2=');
	 fnd_dsql.add_bind('test' || To_char(i));
       ELSIF m = 1 THEN
	 fnd_dsql.add_text('date=');
	 fnd_dsql.add_bind(Sysdate);
       ELSE
	 fnd_dsql.add_text('number=');
	 fnd_dsql.add_bind(i);
      END IF;
   END LOOP;
   l_dsql := fnd_dsql.get_text;
   l_debug := fnd_dsql.get_text(TRUE);
   dbms_debug(l_dsql);
   dbms_debug(l_debug);
EXCEPTION
   WHEN OTHERS THEN
      l_dsql := 'SQLERRM:' || Sqlerrm;
      l_debug := 'i:' || To_char(i) || '  ' || fnd_message.get;
      dbms_debug(l_dsql);
      dbms_debug(l_debug);
END fnd_dsql_test;

  /*
  ** Function: DSQL_IntBinds
  **       Uses the DBMS_SQL Built-in package
  **       to eliminate PLSQL compile-time dependencies
  **       introduced by the dynamic code-block (p_plsql variable).
  **
  ** Included with the fix for BUG 19531101
  **
  */
  FUNCTION DSQL_IntBinds(p_plsql       VARCHAR2,
                         p_params      IN OUT NOCOPY t_bind_internal,
                         p_trap_errors BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 AS
    c_cursor    PLS_INTEGER;
    c_exec      PLS_INTEGER;
    l_plsql     t_bigvc2;
    l_trace     t_bigvc2;
    l_error_flg BOOLEAN;

    l_continue_flg BOOLEAN;

    -- Binds
    l_rtn VARCHAR2(100); -- Bind :r Return value


    l_bind_list     t_bind_internal;

    -- DBMS_SQL: states for dynamic PLSQL-API parsing
    ls_OPEN           pls_integer := 1; -- OPEN
    ls_PARSE          pls_integer := 2; -- PARSE
    ls_BIND_PRE_EXE   pls_integer := 3; -- BIND_PRE_EXE
    ls_EXECUTE        pls_integer := 4; -- EXECUTE
    ls_VARIABLE_VALUE pls_integer := 5; -- VARIABLE_VALUE

    TYPE processlist_t IS TABLE OF pls_integer;

    process_steps processlist_t := -- Max of 5 elements currently
                  processlist_t (ls_OPEN,
                                 ls_PARSE,
                                 ls_BIND_PRE_EXE,
                                 ls_EXECUTE ,
                                 ls_VARIABLE_VALUE);

    FUNCTION INIT_SET_ERROR( p_msg VARCHAR2 ) RETURN VARCHAR2 AS
      loc_rtn varchar2(1);
    BEGIN
      loc_rtn := 'N'; -- Only if we TRAP the error it returns 'E'
      IF p_trap_errors = TRUE THEN
        loc_rtn := 'E';
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', p_msg );
        fnd_message.set_token('ERRNO', SQLCODE);
        fnd_message.set_token('REASON', SQLERRM || ' - ' || l_trace);
      END IF;
      RETURN loc_rtn;
    END INIT_SET_ERROR;

    PROCEDURE internal_dsql(p_type     pls_integer,
                            p_continue IN OUT NOCOPY BOOLEAN ,
                            p_int_trap_errors BOOLEAN DEFAULT FALSE) AS
       l_bind_name varchar2(32);
       l_int_err_flg varchar2(1);
    BEGIN
      IF p_int_trap_errors = TRUE THEN
         ol('DBG-int-1: internal_dsql : msg1');
      END IF;

      IF p_continue = TRUE THEN
        l_trace     := l_trace || p_type || '.';
        -- Emulate CASE ...
        IF p_type = ls_OPEN THEN
          -- open cursor
          c_cursor := DBMS_SQL.OPEN_CURSOR;
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : OPEN : msg2');
          END IF;


        ELSIF p_type = ls_PARSE  THEN
          -- Parse
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : PARSE :msg3');
          END IF;
          DBMS_SQL.parse(c_cursor, l_plsql, DBMS_SQL.NATIVE);
          IF p_int_trap_errors = TRUE THEN
            ol('DBG-int-1: internal_dsql : PARSE :msg4');
          END IF;

        ELSIF p_type = ls_BIND_PRE_EXE  THEN
          -- Bind pre-execution or Define value-types
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : BIND-PRE-EXE :msg5');
          end if;

          for i in 1.. l_bind_list.COUNT loop
            l_bind_name := ':'||l_bind_list(i).bind_name;

            IF p_int_trap_errors = TRUE THEN
              oldbg('  DBG-int-1: internal_dsql : BIND-PRE-EXE :msg5.1 name', l_bind_name);
              oldbg('  DBG-int-1: internal_dsql : BIND-PRE-EXE :msg5.2 value', l_bind_list(i).bind_value);
              oldbg('  DBG-int-1: internal_dsql : BIND-PRE-EXE :msg5.3 size', l_bind_list(i).bind_size);
            END IF;

            DBMS_SQL.bind_variable(c_cursor,
                        l_bind_name,
                        l_bind_list(i).bind_value,
                        l_bind_list(i).bind_size);

          end loop i;
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : BIND-PRE-EXE :msg6');
          END IF;

        ELSIF p_type = ls_EXECUTE THEN
          -- EXECUTION
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : EXECUTE :msg7');
          END IF;

          c_exec  := DBMS_SQL.EXECUTE(c_cursor);
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : EXECUTE :msg8');
          END IF;

        ELSIF p_type = ls_VARIABLE_VALUE THEN
          -- VARIABLE_VALUE
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : VARIABLE_VALUE :msg9');
          END IF;

          for i in 1.. l_bind_list.COUNT loop
            if l_bind_list(i).bind_type_arg = 'O' then
               l_bind_name := ':'||l_bind_list(i).bind_name;
               DBMS_SQL.variable_value(c_cursor,
                  l_bind_name,
                  l_bind_list(i).bind_return);
              IF p_int_trap_errors = TRUE THEN
                 oldbg('  DBG-int-1: internal_dsql : BIND-PRE-EXE :msg9.1 name', l_bind_name);
                 oldbg('  DBG-int-1: internal_dsql : BIND-PRE-EXE :msg9.2 return', l_bind_list(i).bind_return);
              END IF;

            end if;
          end loop i;
          IF p_int_trap_errors = TRUE THEN
             ol('DBG-int-1: internal_dsql : VARIABLE_VALUE :msg10');
          END IF;

        END IF;
      END IF; -- end check for continue
    EXCEPTION
      WHEN OTHERS THEN
        IF p_int_trap_errors = TRUE THEN
           ol('DBG-int-1: internal_dsql : msg11 - Error');
        END IF;
        l_trace     := l_trace || 'Error-at-'|| p_type ||'.';
        l_error_flg := TRUE;
        p_continue  := FALSE;

        l_int_err_flg := INIT_SET_ERROR( l_trace );

    END internal_dsql;

  BEGIN
    l_plsql := LTRIM(RTRIM(p_plsql));
    l_continue_flg := TRUE;

    IF p_trap_errors = TRUE THEN
       oldbg('DBG DSQL_IntBind: P_Params.Count', p_params.COUNT);
    END IF;

    for i in 1.. p_params.COUNT loop

      l_bind_list(i).bind_name        := p_params(i).bind_name;
      l_bind_list(i).bind_Type_value  := p_params(i).bind_Type_value;
      l_bind_list(i).bind_Type_arg    := p_params(i).bind_Type_arg;
      l_bind_list(i).bind_value       := p_params(i).bind_value;
      l_bind_list(i).bind_return      := null;
      l_bind_list(i).bind_size        := p_params(i).bind_size;
    end loop i;
    IF p_trap_errors = TRUE THEN
       oldbg('DBG DSQL_IntBind: l_bind_list.Count', l_bind_list.COUNT);
    END IF;

    -- Check if length < 5 because
    --   there is no possible plsql with lenght < 5 that
    --   can be a valid PLSQL-block using N-binds
    IF NVL(LENGTH(l_plsql), 0) < 5 THEN
      l_trace        := 'Parameter-Error.';
      l_error_flg    := TRUE;
      l_continue_flg := FALSE;
    END IF;

    IF l_continue_flg = TRUE THEN
      l_trace     := '[';
      l_error_flg := FALSE;

      --
      -- Execute DBMS_SQL processes and TRAP the errors
      -- if the parameter p_trap_errors is TRUE
      --
      FOR indx IN 1 .. process_steps.COUNT
        LOOP
          internal_dsql( process_steps( indx )  , l_continue_flg , p_trap_errors);
      END LOOP indx;

    END IF;

    IF l_continue_flg = TRUE THEN
      l_trace := l_trace || 'execute-Normal';
    END IF;

    IF DBMS_SQL.is_open(c_cursor) = TRUE THEN
      DBMS_SQL.CLOSE_CURSOR(c_cursor);
    END IF;

    IF l_error_flg = TRUE THEN
      l_rtn := INIT_SET_ERROR( 'DSQL_IntBinds' );
    ELSE
      l_rtn :=  'Y';

      IF l_continue_flg = TRUE THEN

        IF p_trap_errors = TRUE THEN
           ol('DBG DSQL_IntBind: Before Assign m1');
        END IF;

        -- Assign the RETURN value back to the original vector
        -- in the FIELDS with bind_type_arg='O' => means OUTPUT
        for i in 1.. p_params.COUNT loop
          if l_bind_list(i).bind_type_arg = 'O' then
             p_params(i).bind_return  :=
                 substr( l_bind_list(i).bind_return , 1,
                    l_bind_list(i).bind_size  );
          end if;
        end loop i;
        IF p_trap_errors = TRUE THEN
           ol('DBG DSQL_IntBind: After Assign m2');
        END IF;

      END IF; -- end check l_continue_flg = true

    END IF; -- end check l_error_flg

    l_bind_list.DELETE;

    --
    -- EXIT - Return local variable l_rtn
    --
    RETURN l_rtn;

  EXCEPTION
    WHEN OTHERS THEN
      --
      -- Trap any unexpected ERROR
      --
      l_rtn := INIT_SET_ERROR( 'DSQL_IntBinds - When-OTHERS' );
      IF DBMS_SQL.is_open(c_cursor) = TRUE THEN
        DBMS_SQL.CLOSE_CURSOR(c_cursor);
      END IF;
      RETURN l_rtn;
  END DSQL_IntBinds;


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
    RETURN VARCHAR2 AS
    loc_params t_bind_internal; -- This is a RECORD type defined on this file
    l_rtn_int VARCHAR2(200); -- Return value from Internal function ( Y/N/E)
    l_rtn_loc t_bigvc2; -- Bind :r Return value
  BEGIN
    l_rtn_loc := null;

    -- RETURN value of the function
    loc_params(1).bind_name       := 'r';
    loc_params(1).bind_type_value := 'V';
    loc_params(1).bind_type_arg   := 'O';
    loc_params(1).bind_value      := '';
    loc_params(1).bind_return     := '';
    loc_params(1).bind_size       := 100;

    -- 1 bind input
    loc_params(2).bind_name       := 'a';
    loc_params(2).bind_type_value := 'V';
    loc_params(2).bind_type_arg   := 'I';
    loc_params(2).bind_value      := p_value1;
    loc_params(2).bind_return     := '';
    loc_params(2).bind_size       := 100;

    -- 2 bind input
    loc_params(3).bind_name       := 'b';
    loc_params(3).bind_type_value := 'V';
    loc_params(3).bind_type_arg   := 'I';
    loc_params(3).bind_value      := p_value2;
    loc_params(3).bind_return     := '';
    loc_params(3).bind_size       := 100;

    -- 1 bind output
    loc_params(4).bind_name       := 'm';
    loc_params(4).bind_type_value := 'V';
    loc_params(4).bind_type_arg   := 'O';
    loc_params(4).bind_value      := '';
    loc_params(4).bind_return     := '';
    loc_params(4).bind_size       := 2000;

    IF p_trap_errors_dyn = TRUE THEN
      ol('DBG-int: msg1');
      oldbg('DBG-int: p_plsql_dyn', p_plsql_dyn);
      ol('DBG-int: msg2');
    END IF;

    l_rtn_int := DSQL_IntBinds(p_plsql       => p_plsql_dyn,
                               p_params      => loc_params,
                               p_trap_errors => p_trap_errors_dyn);
    IF p_trap_errors_dyn = TRUE THEN
       ol('DBG-int: msg3');
    END IF;

    p_value_out1 := loc_params(4).bind_return;

    IF l_rtn_int = 'Y' THEN
      l_rtn_loc    := loc_params(1).bind_return;
    END IF;

    loc_params.DELETE;
    --
    -- EXIT - Return local variable l_rtn
    --
    RETURN l_rtn_loc;

  EXCEPTION
    WHEN OTHERS THEN
      --
      -- Trap any unexpected ERROR
      --
      l_rtn_loc := 'Function_exec_4binds - When-OTHERS';
      RETURN l_rtn_loc;
  END Function_exec_4binds;

--
-- Scoping Rules - Definition
--
--  These functions are written with minimum or none validation
--  intentionaly to avoid performance penalties.
--  The minimum error-handle will return 'N' or NULL
--  depending on the function.
--
--    Create by : Enrique Miranda ( ATG-CORE)
--         Date : May 11 2015
--

  FUNCTION setScopingRule_num( p_name varchar2, p_value number ) return VARCHAR2 DETERMINISTIC AS
    l_rtn varchar2(1) := 'N';
  BEGIN
    IF p_name is not null THEN
      v_pair_num(p_name).f_key   := p_name  ;
      v_pair_num(p_name).f_value := p_value ;
      l_rtn := 'Y';
    END IF;
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END setScopingRule_num;

  FUNCTION setScopingRule_var( p_name varchar2, p_value varchar2 ) return VARCHAR2 DETERMINISTIC AS
    l_rtn varchar2(1) := 'N';
  BEGIN
    IF p_name is not null THEN
      v_pair_var(p_name).f_key   := p_name  ;
      v_pair_var(p_name).f_value := p_value ;
      l_rtn := 'Y';
    END IF;
    RETURN l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END setScopingRule_var;

  FUNCTION setSR_Bindnum( p_pos number, p_value number ) return VARCHAR2 DETERMINISTIC AS
    l_rtn varchar2(1) := 'N';
  BEGIN
    IF p_pos is not null THEN
      v_bind_num(p_pos) := p_value ;
      l_rtn := 'Y';
    END IF;
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END setSR_Bindnum;

  FUNCTION setSR_Bindvar( p_pos number, p_value varchar2 ) return VARCHAR2 DETERMINISTIC AS
    l_rtn varchar2(1) := 'N';
  BEGIN
    IF p_pos is not null THEN
      v_bind_var(p_pos) := p_value ;
      l_rtn := 'Y';
    END IF;
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END setSR_Bindvar;

  FUNCTION getScopingRule_num( p_name varchar2 ) return NUMBER DETERMINISTIC AS
    l_rtn number := null;
  BEGIN
    IF v_pair_num(p_name).f_key = p_name THEN
      l_rtn := v_pair_num(p_name).f_value;
    END IF;
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getScopingRule_num;

  FUNCTION getScopingRule_var( p_name varchar2 ) return VARCHAR2 DETERMINISTIC AS
    l_rtn typ_vsmall := null;
  BEGIN
    IF v_pair_var(p_name).f_key = p_name THEN
      l_rtn := v_pair_var(p_name).f_value;
    END IF;
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getScopingRule_var;

  FUNCTION getSR_Bindnum( p_pos number ) return NUMBER DETERMINISTIC AS
    l_rtn NUMBER := null;
  BEGIN
    l_rtn := v_bind_num(p_pos);
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getSR_Bindnum;

  FUNCTION getSR_Bindvar( p_pos number ) return VARCHAR2 DETERMINISTIC AS
    l_rtn typ_vsmall := null;
  BEGIN
    l_rtn := v_bind_var(p_pos);
    return l_rtn;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getSR_Bindvar;


   procedure load_queries AS
     l_key SMALL_KEY_T;
   begin
     -- Key for a query to FIND all the responsibilities
     -- associated with a FORM-NAME design for OAM patch-report
     l_key := 'OAM_FRM_RESPS';

/*
** BUG 21481393
**    Code created by Enrique Miranda - Aug-4-2015
**    ( The following code is Oracle 10gR2 compatible
**      as it is the minimum DB-base at Aug-4-2015 for EBS)
**
** The pipelined function fnd_dsql.OAM_FORM_NAV_SET
** uses the follow query to retrieve the Menu->Responsibility
** path that is attached to a specific 1-form. It is divided
** into the following subqueries :
**
** inter_m1: Retrieve main form/function IDs
**
** inter_q1: Base on the subquery inter_m1 connected to the menu_entries
**             information and the translation table
**
** menu_filter1: Base on the subquery inter_m1 obtain the longest
**               menu-path available base on menu_id
**
** Rset_q1: Base on menu_filter1 connects with inter_q1 and the responsibility
**          table with translations for function that are directly connect
**          to 1-menu and that menu included in a responsibility
**
** inter_q2: Retrieve the menu_entries information and the translation table
**           to be use later inside all_menu_paths.
**
** all_menu_paths: Constructs the menu_path using sys_connect_by_path and
**                 "CONNECT BY" with sub_menu_id -> menu_id
**                 starting with the ROW from inter_q1 as base.
**
** menu_filter2: Base on the subquery all_menu_paths obtain the longest
**               menu-path available base on menu_id
**
** Rset_q2: Base on menu_filter2 connects with inter_q1 and the responsibility
**          table with translations for function that are directly connect
**          to 1-menu and that menu included in a responsibility
**
** Rev_data1: Base on the prompt-field from Rset_q2 Separates
**            the prompts(Tokens) to be use in the subquery Reverse_prompt
**
** Reverse_prompt: Base on the Rev_data1 subquery it reverse the order of
**                 construction from the field prompt.
**
** Main-Query: The union of Rset_q1 and Rset_q2 connected to the
**             Reverse_prompt subquery.
**
**
** NOTES:
** ======
**
** The function: CONNECT BY LEVEL has been around since Oracle-7
**
** The following 10g functions are used here:
**    REGEXP_SUBSTR: Regular expression substring
**    REGEXP_REPLACE: Regular expression replace
**    ROW_NUMBER: Analytic function used with PARTITION BY to
**                return a deterministic value.
**    MULTISET operator: combine nested tables into a single nested table
**    CAST operator: converts one built-in datatype or collection-typed value
**      into another built-in datatype or collection-typed value
**
** The subquery Reverse_prompt can be rewrite(simplified) to use
** LISTAGG and remove the need of rev_data1 but that function is
** only available from 11gR2 and up.
**
*/

     -- This query uses 1 bind name -> :f
v_sql(l_key).psql_query :=
   'WITH '
||   'inter_m1 AS '
||    '( SELECT m1.form_id, '
||             'M1.form_name, '
||             'M1.application_id, '
||             'm2.function_id '
||      'FROM fnd_form m1, '
||           'fnd_form_functions m2 '
||     'WHERE M1.form_name = :f '
||       'AND m2.form_id   = m1.form_id '
||     ') '
||   ', '
||   'inter_q1 AS '
||   '( '
||    'SELECT fme.function_id, '
||           'fme.menu_id, '
||           'fme.sub_menu_id, '
||           'fmtl.user_menu_name, '
||           'fmtl.description, '
||           'fme.entry_sequence, '
||           'fmetl.prompt '
||      'FROM inter_m1 m1, '
||           'fnd_menu_entries fme , '
||           'fnd_menus_tl fmtl , '
||           'fnd_menu_entries_tl fmetl '
||     'WHERE fme.function_id = m1.function_id '
||       'AND fmtl.menu_id = fme.menu_id '
||       'AND fmtl.LANGUAGE = userenv(''LANG'') '
||       'AND fmetl.menu_id        = fme.menu_id '
||       'AND fmetl.entry_sequence = fme.entry_sequence '
||       'AND fmetl.LANGUAGE       = fmtl.LANGUAGE '
||       'AND fmetl.prompt IS NOT NULL '
||     ') '
||     ', '
||     'menu_filter1 AS '
||     '( '
||    'SELECT DISTINCT mp.menu_id, '
||                    'MAX( mp.entry_sequence) mx_ent_seq '
||      'FROM inter_q1 mp '
||    'GROUP BY mp.menu_id '
||  '), '
||  'Rset_q1 AS '
||  '( '
||    'SELECT fr.menu_id, '
||           'q1.prompt, '
||           'fr.responsibility_id, '
||           'frtl.responsibility_name '
||     'FROM menu_filter1 mf1, '
||          'inter_q1 q1, '
||          'fnd_responsibility fr, '
||          'fnd_responsibility_tl frtl '
||     'WHERE fr.menu_id  = mf1.menu_id '
||       'AND q1.menu_id        = mf1.menu_id '
||       'AND q1.entry_sequence = mf1.mx_ent_seq '
||       'AND NVL(fr.end_date,SYSDATE ) >= SYSDATE '
||       'AND frtl.application_id    = fr.application_id '
||       'AND frtl.responsibility_id = fr.responsibility_id '
||       'AND frtl.LANGUAGE          = userenv(''LANG'') '
||  '), '
||   'inter_q2 AS '
||  '( '
||  'SELECT fme.menu_id, '
||         'fme.sub_menu_id, '
||         'fme.function_id, '
||         'fmtl.user_menu_name, '
||         'fmtl.description, '
||         'fme.entry_sequence, '
||         'fmetl.prompt '
||    'FROM fnd_menus_tl        fmtl, '
||         'fnd_menu_entries    fme, '
||         'fnd_menu_entries_tl fmetl '
||   'WHERE fmtl.menu_id  = fme.menu_id '
||     'AND fmtl.LANGUAGE = userenv(''LANG'') '
||     'AND fme.menu_id   = fmetl.menu_id '
||     'AND fme.entry_sequence = fmetl.entry_sequence '
||     'AND fmetl.LANGUAGE  = userenv(''LANG'') '
||     'AND fmetl.prompt IS NOT NULL '
||  '), '
||  'all_menu_paths AS '
||  '( '
||  'SELECT menu_id, '
||         'entry_sequence, '
||         'nvl(sub_menu_id, -1) sub_menu_id, '
||         'nvl(function_id, -1) function_id, '
||         'sys_connect_by_path(prompt, '','') prompt1 '
||    'FROM inter_q2 fmev '
||       'CONNECT BY  fmev.SUB_MENU_ID = prior fmev.MENU_ID '
||         'START WITH ( EXISTS '
||                        '( SELECT 0 '
||                            'FROM inter_q1 mn1 '
||                           'WHERE mn1.menu_id = fmev.sub_menu_id '
||                        ') '
||                   ') '
||  ') '
||  ', '
||  'menu_filter2 AS '
||  '( '
||    'SELECT DISTINCT mp.menu_id, '
||                    'MAX( mp.entry_sequence) mx_ent_seq '
||      'FROM all_menu_paths mp '
||    'GROUP BY mp.menu_id '
||  '), '
||  'Rset_q2 AS '
||  '( '
||  'SELECT fr.menu_id, '
||         'ma.prompt1 prompt, '
||         'fr.responsibility_id, '
||         'frtl.responsibility_name '
||   'FROM menu_filter2    mf2, '
||        'all_menu_paths  ma, '
||        'fnd_responsibility fr, '
||        'fnd_responsibility_tl frtl '
||   'WHERE ma.menu_id        = mf2.menu_id '
||     'AND ma.entry_sequence = mf2.mx_ent_seq '
||     'AND fr.MENU_ID = mf2.menu_id '
||     'AND NVL(fr.end_date,SYSDATE ) >= SYSDATE '
||     'AND frtl.application_id    = fr.application_id '
||     'AND frtl.responsibility_id = fr.responsibility_id '
||     'AND frtl.LANGUAGE          = userenv(''LANG'') '
||  '), '
||  'Rev_data1 AS '
||  '( '
||  'SELECT '
||         'menu_id, '
||         'responsibility_id, '
||         'rn, '
||         'r_prompt '
||    'FROM '
||          '(SELECT t.menu_id, '
||                 'responsibility_id, '
||                 'rownum rn, '
||                 'TRIM(regexp_substr(t.prompt, ''[^,]+'', 1, LINES.COLUMN_VALUE) '
||                      ') r_prompt '
||            'FROM Rset_q2 t, '
||                 'TABLE(CAST( '
||                            'MULTISET '
||                              '(SELECT LEVEL '
||                                 'FROM dual '
||                               'CONNECT BY LEVEL <= NVL( LENGTH( REGEXP_REPLACE( t.prompt, '','' , NULL ) ), 0 ) + 1 '
||                               ') AS  sys.odciNumberList '
||                            ') '
||                       ') LINES '
||           'ORDER BY menu_id, responsibility_id '
||         ') '
||      'ORDER BY menu_id, responsibility_id, rn DESC '
||  '), '
||  'Reverse_prompt AS '
||  '( '
||    'SELECT menu_id , '
||           'responsibility_id, '
||            'LTRIM( '
||                   'MAX( '
||                        'SYS_CONNECT_BY_PATH ( r_prompt, '','') '
||                      '), '
||                         ''','' '
||                 ') r_prompt1 '
||     'FROM '
||         '(SELECT menu_id, '
||                 'responsibility_id, '
||                 'r_prompt, '
||                 'ROW_NUMBER() OVER ( PARTITION BY menu_id, responsibility_id '
||                                         'ORDER BY rn DESC '
||                                   ') rn1 '
||            'FROM Rev_data1 '
||         ') '
||     'CONNECT BY menu_id           = PRIOR menu_id '
||            'AND responsibility_id = PRIOR responsibility_id '
||            'AND PRIOR rn1+1 = rn1 '
||     'START WITH rn1 = 1 '
||     'GROUP BY menu_id, responsibility_id '
||    'ORDER BY menu_id, responsibility_id '
||  ') '
||  '/* MAIN QUERY */ '
||  'SELECT q1.menu_id, '
||         'q1.prompt, '
||         'q1.responsibility_id, '
||         'q1.responsibility_name '
||    'FROM Rset_q1 q1 '
||  'UNION '
||  'SELECT '
||         'q2.menu_id, '
||         'replace(rp.r_prompt1,'','','' => '') prompt, '
||         'q2.responsibility_id, '
||         'q2.responsibility_name '
||    'FROM Rset_q2 q2, '
||         'Reverse_prompt rp '
||   'WHERE q2.menu_id           = rp.menu_id '
||     'AND q2.responsibility_id = rp.responsibility_id ';

      v_sql(l_key).psql_1bind := null;

   end load_queries;

/*
** The following 2 functions are  - Pipelined Table Functions
**
**  cur_4cols_1bind   - generic ANY Dynamic query solution
**
**  OAM_FORM_NAV_GET  - Specific query for OAM module
**                      name OAM_FRM_RESPS( return MENU PATHS for
**                      an specific FORM-NAME )
**
** The - Pipelined Table Functions - are  available since
** version 9i of the Oracle Database.
**
** From the Oracle manual:
** http://docs.oracle.com/cd/B19306_01/appdev.102/b14289/dcitblfns.htm#CHDJEGHC
**
** From ASK-TOM ( Oracle site ) examples:
**  https://asktom.oracle.com/pls/asktom/f?p=100:11:::::P11_QUESTION_ID:19481671347143
**
*/


  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  /*
  ** Function set_query ( Created by emiranda - Jun-11-2015 )
  **           Assign the bind-value for a Dynamic SQL inside
  **           the v_sql vector, accesed by p_key name
  **    Usage example.
  **
  ** Example:
  **  select A.*
  **   from table( fnd_dsql.OAM_FORM_NAV_GET ) A
  **  WHERE fnd_dsql.OAM_FORM_NAV_SET('CSFSKMGT') = 'Y';
  **
  ** INPUT
  **  p_key    - Query-Name to be used as index to access
  **             the vector v_sql
  **
  **  p_bind1  - Value to bind into the query
  **
  **  RETURN
  **    (Y/N) - Y if the assignment was successful
  **          - N if the assignment was unsuccessful ie
  **              query did not exist.
  **      E   - Error
  **
  **  created under BUG 20730237
  */
   FUNCTION set_query(p_key   VARCHAR2,
                      p_bind1 VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
     l_key SMALL_KEY_T;
     l_rtn VARCHAR2(1);
   BEGIN
     l_rtn := 'N';

     IF z_init_value('LOAD_QUERIES') = TRUE THEN
       /* Initialize queries only once */
       z_init_value('LOAD_QUERIES') := FALSE;
       load_queries;
     END if;

     l_key := upper(fClean( p_key ));

     IF l_key is not null
        AND v_sql(l_key).psql_query IS NOT NULL THEN

       v_sql(l_key).psql_1bind := p_bind1;
       l_rtn := 'Y';
     END IF;
     RETURN l_rtn;

   EXCEPTION
     WHEN OTHERS THEN
       -- If it FIND the query but it can not assing the bind-value,
       -- it cleans the bind-value and returns NULL
       IF v_sql(l_key).psql_query IS NOT NULL THEN
         v_sql(l_key).psql_1bind := NULL;
       END IF;
       RETURN 'E';
   END set_query;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  /*
  ** Function cur_4cols_1bind ( Created by emiranda - Jun-11-2015 )
  **    Emulates a SELECT with 4 columns return from a Dynamic query
  **    This function is executed after the call function Set_query
  **    as shows from the example.
  **
  ** Example:
  **  select A.*
  **   from table( fnd_dsql.cur_4cols_1bind('OAM_FRM_RESPS') ) A
  **  WHERE fnd_dsql.set_query('OAM_FRM_RESPS','CSFSKMGT') = 'Y';
  **
  **
  ** INPUT
  **  p_key    - Query-Name to be used as index to access
  **             the vector v_sql
  **
  **  RETURN
  **    4 columns with static names ( col_name1, col_name2, col_name3, col_name4 )
  **    and type VARCHAR2(500)
  **
  **  created under BUG 20730237
  */
   FUNCTION cur_4cols_1bind(p_key VARCHAR2 )
     RETURN t_rtn_4srecs
     PIPELINED IS
     cc    SYS_REFCURSOR;

     T_row t_rec_4cols;
     l_key SMALL_KEY_T;
   BEGIN

     IF z_init_value('LOAD_QUERIES') = TRUE THEN
       /* Initialize queries only once */
       z_init_value('LOAD_QUERIES') := FALSE;
       load_queries;
     END if;

     l_key := upper(fClean( p_key ));

     IF l_key is not null
        AND v_sql(l_key).psql_query IS NOT NULL THEN

       OPEN cc FOR v_sql(l_key).psql_query
         USING v_sql(l_key).psql_1bind;
       LOOP
         FETCH cc
           INTO T_row;
         EXIT WHEN cc%NOTFOUND;

         -- Sent the Dynamic Records T_row as a Return ROW
         PIPE ROW(T_row);
       END LOOP;
       CLOSE CC;

     END IF;
     RETURN;
   END cur_4cols_1bind;

  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
   /* Function OAM_FORM_NAV_GET
   **    Copy the logic of cur_4cols_1bind but only for
   **    one query OAM_FRM_RESPS (load into memory by load_queries)
   **
   ** Example:
   **   SELECT A.menu_id,
   **          A.prompt,
   **          A.responsibility_id,
   **          A.responsibility_name
   **     FROM TABLE( fnd_dsql.OAM_FORM_NAV_GET ) A
   **    WHERE fnd_dsql.OAM_FORM_NAV_SET('CSFDCMAI')  = 'Y';
   **
   **  RETURN
   **    4 columns using the structure T_REC_OAM_FORM
   **    that matches the expected column-names and types
   **    for the query OAM_FRM_RESPS
   **
   */
   FUNCTION OAM_FORM_NAV_GET RETURN t_rtn_OAM_FORM PIPELINED IS
     cc    SYS_REFCURSOR;

     T_row T_REC_OAM_FORM;
     l_key SMALL_KEY_T;
   BEGIN

     IF z_init_value('LOAD_QUERIES') = TRUE THEN
       /* Initialize queries only once */
       z_init_value('LOAD_QUERIES') := FALSE;
       load_queries;
     END if;

     -- Fixed Logic to return the QUERY -> EM_FRM_RESPS
     l_key := upper(fClean( 'OAM_FRM_RESPS' ));

     IF l_key is not null
        AND v_sql(l_key).psql_query IS NOT NULL THEN

       OPEN cc FOR v_sql(l_key).psql_query
         USING v_sql(l_key).psql_1bind;
       LOOP
         FETCH cc
           INTO T_row;
         EXIT WHEN cc%NOTFOUND;

         -- Sent the Dynamic Records T_row as a Return ROW
         PIPE ROW(T_row);
       END LOOP;
       CLOSE CC;

     END IF;
     RETURN;
   EXCEPTION
     WHEN OTHERS THEN

       oldbg('DBG1: ERROR: dyn-query ',v_sql(l_key).psql_query ) ;
       RETURN;
   END OAM_FORM_NAV_GET;


  -- This routine is for AOL INTERNAL USE ONLY !!!!!!!
  -- Function OAM_FORM_NAV_SET
  --    Copy the logic of set_query but only for
  --    one query OAM_FRM_RESPS (load into memory by load_queries)
  --
  /*
  ** Function OAM_FORM_NAV_SET ( Created by emiranda - Jun-11-2015 )
  **    Assign the BIND value for the QUERY stored in v_sql
  **    this version is FIXED to use query named OAM_FRM_RESPS
  **    Usage example.
  **
  ** Example:
  **   SELECT A.menu_id,
  **          A.prompt,
  **          A.responsibility_id,
  **          A.responsibility_name
  **     FROM TABLE( fnd_dsql.OAM_FORM_NAV_GET ) A
  **    WHERE fnd_dsql.OAM_FORM_NAV_SET('CSFDCMAI')  = 'Y';
  **
  ** INPUT
  **  p_bind1    - Bind value that represents the FORM-NAME
  **
  **  RETURN
  **    (Y/N) - Y if the assignment was successful
  **          - N if the assignment was unsuccessful ie
                  query did not exist.
  **      E   - Error
  **  created under BUG 20730237
  */
   FUNCTION OAM_FORM_NAV_SET( p_bind1 VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
     l_key SMALL_KEY_T;
     l_rtn VARCHAR2(1);
   BEGIN
     l_rtn := 'N';

     IF z_init_value('LOAD_QUERIES') = TRUE THEN
       /* Initialize queries only once */
       z_init_value('LOAD_QUERIES') := FALSE;
       load_queries;
     END if;

        -- Fixed Logic to return the QUERY -> OAM_FRM_RESPS
     l_key := upper(fClean( 'OAM_FRM_RESPS' ));

     IF l_key is not null
        AND v_sql(l_key).psql_query IS NOT NULL THEN

       v_sql(l_key).psql_1bind := p_bind1;
       l_rtn := 'Y';
     END IF;
     RETURN l_rtn;

   EXCEPTION
     WHEN OTHERS THEN
       -- If it FIND the query but it can not assing the bind-value,
       -- it cleans the bind-value by asigned NULL.
       IF v_sql(l_key).psql_query IS NOT NULL THEN
         v_sql(l_key).psql_1bind := NULL;
       END IF;
       RETURN 'E';
   END OAM_FORM_NAV_SET;

--
-- Package Initialization.
--
BEGIN
   fnd_dsql.chr_newline  := fnd_global.newline;
   fnd_dsql.g_dsql_text  := NULL;
   fnd_dsql.g_cursor_id  := NULL;
   fnd_dsql.g_nbinds     := 0;

   z_init_value('LOAD_QUERIES') := TRUE;

   --
   -- Call varray constructors. Otherwise it gives
   -- ORA-06531: Reference to uninitialized collection
   --
   fnd_dsql.g_bind_ttbl := varchar2_tbl_type();
   fnd_dsql.g_bind_vtbl := varchar2_tbl_type();
   fnd_dsql.g_bind_dtbl := date_tbl_type();
   fnd_dsql.g_bind_ntbl := number_tbl_type();

   --
   -- Extend the varrays. Otherwise it gives
   -- ORA-06533: Subscript beyond count
   --
   fnd_dsql.g_bind_ttbl.EXTEND(g_maximum_varray_size);
   fnd_dsql.g_bind_vtbl.EXTEND(g_maximum_varray_size);
   fnd_dsql.g_bind_dtbl.EXTEND(g_maximum_varray_size);
   fnd_dsql.g_bind_ntbl.EXTEND(g_maximum_varray_size);
EXCEPTION
   WHEN OTHERS THEN
      report_error(g_package_name || '.Package Initialization', Sqlerrm);
      RAISE;
END fnd_dsql;

/
