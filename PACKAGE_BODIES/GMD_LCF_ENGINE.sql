--------------------------------------------------------
--  DDL for Package Body GMD_LCF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LCF_ENGINE" AS
/* $Header: GMDLCFPB.pls 120.3 2006/02/24 09:46:02 rajreddy noship $ */

  l_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
  l_log_level CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_LEVEL'), '6');

  l_LGP_EPS_ZERO   CONSTANT NUMBER := 0.00000001; -- test for zero (1e-8)
  l_LGP_BIG  CONSTANT NUMBER := 1E10;    -- infinity
  l_LGP_BIGGER CONSTANT NUMBER := 1e20;  -- bigger than big
  l_MAX_ROW   CONSTANT NUMBER := 102;    -- corresponds to nCon <=100
  l_MAX_COL   CONSTANT NUMBER := 301;    -- corresponds to nVar <=300

  l_clob CLOB;
  l_package_name CONSTANT VARCHAR2(40) := 'GMD_LCF_ENGINE';
  l_new_line_str CONSTANT VARCHAR2(100) := '
';


  /*====================================================================
  --  PROCEDURE:
  --    insert_clob
  --
  --  DESCRIPTION:
  --    This procedure is used to insert the clob as a blob into FND_LOBS
  --
  --  PARAMETERS:
  --
  --  HISTORY
  --====================================================================*/

  PROCEDURE insert_clob (p_spec_id IN NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
    l_blob BLOB;

    l_des_offset INTEGER;
    l_src_offset INTEGER;
    l_lang_context INTEGER;
    l_warning INTEGER;
    l_api_name VARCHAR2(40) := 'INSERT_CLOB';
    l_spec_id NUMBER(15);
  BEGIN
    l_des_offset := 1;
    l_src_offset := 1;
    l_lang_context := 0;

    l_spec_id := -1 * p_spec_id;
    DELETE FROM FND_LOBS WHERE FILE_ID = l_spec_id;

    INSERT INTO FND_LOBS (FILE_ID, FILE_NAME, FILE_CONTENT_TYPE,
                         FILE_DATA, LANGUAGE, ORACLE_CHARSET, FILE_FORMAT)
    VALUES (l_spec_id, 'lcf.sql', 'text/plain', EMPTY_BLOB(), USERENV('LANG'), 'UTF8', 'text');

    SELECT file_data INTO l_blob
    FROM   fnd_lobs
    WHERE  file_id = l_spec_id
    FOR UPDATE NOWAIT;

    dbms_lob.convertToBlob(dest_lob => l_blob,
                           src_clob => l_clob,
                           amount   => DBMS_LOB.LOBMAXSIZE,
                           dest_offset => l_des_offset,
                           src_offset => l_src_offset,
                           blob_csid => 0,
                           lang_context => l_lang_context,
                           warning => l_warning);
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Warning:ConvertToBlob:'||l_warning);
    END IF;
    COMMIT;
    dbms_lob.FreeTemporary(l_clob);
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 'Y' THEN
        gmd_debug.put_line(l_api_name||':'||sqlerrm);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg(l_package_name, l_api_name);
  END insert_clob;


  /*====================================================================
  --  PROCEDURE:
  --    print_data
  --
  --  DESCRIPTION:
  --    This procedure is used to print the data in the log file.
  --
  --  PARAMETERS:
  --
  --  HISTORY
  --====================================================================*/
  PROCEDURE print_data    ( p_constraints IN NUMBER
                         , p_variables IN NUMBER
                         , p_matrix IN matrix
                         , p_basic IN row
                         , p_reenter IN row
                         , p_var IN char_row
                         , p_cons IN char_row
                         , p_return_code IN NUMBER) IS

    l_print_line VARCHAR2(4000);

    l_bool_char VARCHAR2(20);
    l_value NUMBER;
    l_print_value VARCHAR2(40);

    l_string VARCHAR2(4000);

    CURSOR Cur_get_tech_data IS
      SELECT DISTINCT tech_parm_id, tech_parm_name
      FROM   GMD_LCF_TECH_DATA_GTMP
      ORDER BY tech_parm_id;

    CURSOR Cur_get_data IS
      SELECT d.LINE_NO, d.line_id, SUBSTR(d.CONCATENATED_SEGMENTS,1, 36) item, d.PRIMARY_UOM, t.VALUE
      FROM GMD_LCF_DETAILS_GTMP d, GMD_LCF_TECH_DATA_GTMP t
      WHERE d.line_id = t.line_id
      ORDER BY d.line_no, t.tech_parm_id;

    CURSOR Cur_get_cat_data (V_line_id NUMBER) IS
      SELECT category_name
      FROM   gmd_lcf_category_hdr_gtmp h
      WHERE EXISTS (SELECT 1
                    FROM gmd_lcf_category_dtl_gtmp d
                    WHERE d.line_id = V_line_id
                    AND   NVL(value_ind, 0) = 1
                    AND   d.category_id = h.category_id);

    l_item VARCHAR2(40);
    l_line_str VARCHAR2(4000);
    l_cat_string VARCHAR2(4000);
    l_api_name VARCHAR2(40) := 'PRINT_DATA';
  BEGIN
    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.call);
    dbms_lob.open(l_clob, DBMS_LOB.lob_readwrite);
    FND_MESSAGE.SET_NAME('GMD', 'GMD_LCF_LOG_DATA');
    l_string := FND_MESSAGE.GET||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := RPAD('   Item',41,' ')||RPAD('Category', 30);
    FOR l_rec IN Cur_get_tech_data LOOP
      l_string := l_string||LPAD(l_rec.tech_parm_name, 10, ' ');
    END LOOP;
    l_string := l_string||l_new_line_str;

    l_line_str := RPAD('=', length(l_string), '=')||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_line_str), l_line_str);
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    dbms_lob.writeAppend(l_clob, length(l_line_str), l_line_str);

    l_string := NULL;
    FOR l_rec IN Cur_get_data LOOP
      IF NVL(l_item, ' ') <> l_rec.item THEN
        IF l_string IS NOT NULL THEN
          l_string := l_string || l_new_line_str;
          dbms_lob.writeAppend(l_clob, length(l_string), l_string);
          l_string := NULL;
        END IF;
      END IF;
      IF l_string IS NULL THEN
        l_cat_string := NULL;
        FOR l_cat IN Cur_get_cat_data(l_rec.line_id) LOOP
          IF l_cat_string IS NULL THEN
            l_cat_string := l_cat.category_name;
          ELSE
            l_cat_string := l_cat_string||','||l_cat.category_name;
          END IF;
        END LOOP;
        l_cat_string := RPAD(NVL(l_cat_string, ' '), 30);
        l_string := LPAD(l_rec.line_no,3,' ')||'.'||RPAD(l_rec.item, 37, ' ')||l_cat_string;
      END IF;
      l_string := l_string||LPAD(TO_CHAR(l_rec.value, '9990.99999'), 10, ' ');
      l_item := l_rec.item;
    END LOOP;
    l_string := l_string || l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    dbms_lob.writeAppend(l_clob, length(l_line_str), l_line_str);
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 'Y' THEN
        gmd_debug.put_line(l_api_name||':'||sqlerrm);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg(l_package_name, l_api_name);
  END print_data;

  /*====================================================================
  --  PROCEDURE:
  --    print_constraints
  --
  --  DESCRIPTION:
  --    This procedure is used to print the data in the log file.
  --
  --  PARAMETERS:
  --
  --  HISTORY
  --====================================================================*/
  PROCEDURE print_constraints ( p_constraints IN NUMBER
                         , p_variables IN NUMBER
                         , p_matrix IN matrix
                         , p_basic IN row
                         , p_reenter IN row
                         , p_var IN char_row
                         , p_cons IN char_row
                         , p_solved_matrix IN matrix
                         , p_solved_basic IN row
                         , p_return_code IN NUMBER) IS

    l_print_line VARCHAR2(4000);

    l_bool_char VARCHAR2(20);
    l_value NUMBER;
    l_print_value VARCHAR2(40);

    l_string VARCHAR2(4000);


    l_api_name VARCHAR2(40) := 'PRINT_CONSTRAINTS';
  BEGIN
    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := '# Constraints: '||p_constraints||'  # Variables: '||p_variables||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := 'Basic Constraint set:'||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := RPAD(p_cons(1), 25, ' ')||' = '||RPAD(ROUND(p_matrix(1)(0), 5),20);
    IF (ABS(p_solved_matrix(1)(0)) > l_LGP_EPS_ZERO) AND p_reenter(p_basic(1)) = 0 THEN
      l_string := l_string||'**** Infeasible ****';
    END IF;
    l_string := l_string||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    FOR i IN 2..p_constraints LOOP
      IF p_reenter(p_basic(i)) = 0 THEN
        l_string := RPAD(p_cons(i), 25, ' ')||' <= '||RPAD(ROUND(p_matrix(i)(0), 5), 20);
      ELSE
        l_string := RPAD(p_cons(i), 25, ' ')||' >= '||RPAD(ROUND(p_matrix(i)(0), 5), 20);
      END IF;
      IF (ABS(p_solved_matrix(i)(0)) > l_LGP_EPS_ZERO) AND p_reenter(p_solved_basic(i)) = 0 THEN
        l_string := l_string||'**** Infeasible ****';
      END IF;
      l_string := l_string||l_new_line_str;
      dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    END LOOP;

    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 'Y' THEN
        gmd_debug.put_line(l_api_name||':'||sqlerrm);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg(l_package_name, l_api_name);
  END print_constraints;


  /*====================================================================
  --  PROCEDURE:
  --    print_debug
  --
  --  DESCRIPTION:
  --    This procedure is used to print the output of the matrix.
  --
  --  PARAMETERS:
  --    P_matrix              - Matrix.
  --
  --  HISTORY
  --====================================================================*/
  PROCEDURE print_debug  ( p_constraints IN NUMBER
                         , p_variables IN NUMBER
                         , p_matrix IN matrix
                         , p_basic IN row
                         , p_reenter IN row
                         , p_var IN char_row
                         , p_cons IN char_row
                         , p_return_code IN NUMBER) IS
    l_print_line VARCHAR2(4000);
    l_bool_char VARCHAR2(20);
    l_value NUMBER;
    l_print_value VARCHAR2(40);

    l_string VARCHAR2(4000);

    l_item VARCHAR2(40);
    l_line_str VARCHAR2(4000);
    l_cat_string VARCHAR2(4000);
    l_api_name VARCHAR2(40) := 'PRINT_DEBUG';
  BEGIN
    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    l_string := '*** Debugging Information (Printed only if log level set to statement) ***';
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    l_string := 'Functional: '||-1*p_matrix(0)(0)||' Error code: '||p_return_code||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := 'Basic set:'||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    FOR i IN 1..p_constraints LOOP
      l_string := RPAD(p_cons(i), 25, ' ')||' '||p_basic(i)||'. '||RPAD(p_var(p_basic(i)), 25, ' ')||' '||ROUND(p_matrix(i)(0), 5)||l_new_line_str;
      dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    END LOOP;

    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := 'Shadow costs:'||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);


    FOR j IN 1..p_variables LOOP
      IF p_reenter(j) = 1 THEN
        l_bool_char := 'True';
      ELSE
        l_bool_char := 'False';
      END IF;
      l_value := ROUND(p_matrix(0)(j),5);
      l_print_value := RPAD(TO_CHAR(l_value, '9990.99999'), 10);

      l_string := j||'. '||RPAD(p_var(j),30, ' ')||' '||l_print_value||' '||l_bool_char||l_new_line_str;
      dbms_lob.writeAppend(l_clob, length(l_string), l_string);
    END LOOP;

    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

    l_string := 'Matrix:'||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);


    FOR i IN 0..p_constraints+1 LOOP
      l_value := ROUND(p_matrix(i)(0),5);
      l_print_value := RPAD(TO_CHAR(l_value, '9990.99999'), 10);

      l_string := RPAD(i,4, ' ')||' '||l_print_value||' '||l_new_line_str;
      dbms_lob.writeAppend(l_clob, length(l_string), l_string);

      l_print_line := NULL;
      FOR j IN 1..p_variables LOOP
        l_value := ROUND(p_matrix(i)(j),5);
        l_print_value := RPAD(TO_CHAR(l_value, '9990.99999'), 10);
        l_print_line := l_print_line||l_print_value||' ';
      END LOOP;
      l_print_line := l_print_line||l_new_line_str;
      dbms_lob.writeAppend(l_clob, length(l_print_line),  l_print_line);
    END LOOP;

    l_string := ' '||l_new_line_str;
    dbms_lob.writeAppend(l_clob, length(l_string), l_string);

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 'Y' THEN
        gmd_debug.put_line(l_api_name||':'||sqlerrm);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg(l_package_name, l_api_name);
  END print_debug;

/*====================================================================
--  PROCEDURE:
--    evaluate
--
--  DESCRIPTION:
--    This is the main procedure that is invoked from the form to solve
--    the give problem.
--
--  PARAMETERS:
--    P_constraints         - Number of constraints in the problem.
--    P_variables           - Number of variables in the problem.
--    x_return              - Status of the call
--                              0 - Optimum Found,
--                              1 - Unbounded
--                              2 - Max Iterations
--                              3 - Infeasible
--
--  SYNOPSIS:
--    GMD_LCF_ENGINE.evaluate (p_constraints    => l_constraints,
--                             p_variables      => l_variables,
--                             x_return         => l_return);
--
--  HISTORY
--====================================================================*/

  PROCEDURE evaluate (P_spec_id IN NUMBER,
                      P_constraints IN NUMBER,
                      P_variables IN NUMBER,
                      P_matrix IN matrix,
                      p_rhs_matrix IN char_matrix,
                      p_var_row IN char_row,
                      X_solved_tab OUT NOCOPY solved_tab,
                      X_return OUT NOCOPY NUMBER) IS
    l_matrix matrix;
    l_solved_matrix matrix;
    l_basic  row;
    l_out_basic row;
    l_reenter row;
    l_variables NUMBER;
    l_return_status VARCHAR2(1);
    l_print_line VARCHAR2(2000);
    l_var char_row;
    l_cons char_row;
    l_row_count BINARY_INTEGER := 0;
  BEGIN
    /* Initialize the return code */
    x_return := 0;

    Read_Table (p_constraints => p_constraints,
                p_variables => p_variables,
                p_matrix => p_matrix,
                p_rhs_matrix => p_rhs_matrix,
                p_var => p_var_row,
                x_matrix => l_matrix,
                x_basic => l_basic,
                x_reenter => l_reenter,
                x_variables => l_variables,
                x_con => l_cons,
                x_var => l_var,
                x_return_status => l_return_status);

    IF l_debug = 'Y' THEN
      Print_Data ( p_constraints => p_constraints
                 , p_variables => l_variables
                 , p_matrix => l_matrix
                 , p_basic => l_basic
                 , p_reenter => l_reenter
                 , p_var => l_var
                 , p_cons => l_cons
                 , p_return_code => x_return);
    END IF;


    Solve_lgp (P_constraints => P_constraints
              ,P_variables => l_variables
              ,P_matrix => l_matrix
              ,p_reenter => l_reenter
              ,p_basic => l_basic
              ,x_matrix => l_solved_matrix
              ,x_basic => l_out_basic
              ,X_return => X_return);

    IF l_debug = 'Y' THEN
      Print_Constraints ( p_constraints => p_constraints
                 , p_variables => l_variables
                 , p_matrix => l_matrix
                 , p_basic => l_basic
                 , p_reenter => l_reenter
                 , p_var => l_var
                 , p_cons => l_cons
                 , p_solved_matrix => l_solved_matrix
                 , p_solved_basic => l_out_basic
                 , p_return_code => x_return);
    END IF;


    FOR i IN 1..p_constraints LOOP
      IF l_out_basic(i) <= p_variables THEN
        l_row_count := l_row_count + 1;
        x_solved_tab(l_row_count).item := l_var(l_out_basic(i));
        x_solved_tab(l_row_count).qty := ROUND(l_solved_matrix(i)(0), 5);
      END IF;
    END LOOP;

    /* If the log level is set to statement then print the debug information */
    IF l_log_level = 1 AND l_debug = 'Y' THEN
      Print_Debug( p_constraints => p_constraints
                 , p_variables => l_variables
                 , p_matrix => l_matrix
                 , p_basic => l_basic
                 , p_reenter => l_reenter
                 , p_var => l_var
                 , p_cons => l_cons
                 , p_return_code => x_return);
    END IF;

    IF l_debug = 'Y' THEN
      insert_clob (p_spec_id => p_spec_id);
    END IF;
  END evaluate;

/*====================================================================
--  PROCEDURE:
--    read_table
--
--  DESCRIPTION:
--    This procedure is used to read the constraints and build the
--    tables needed for solving the problem.
--
--  PARAMETERS:
--    P_constraints         - Number of constraints in the problem.
--    P_variables           - Number of variables in the problem.
--    P_matrix              - Set of constraints in matrix format.
--    P_rhs_matrix          - Right hand side values for the constraints
--    X_matrix              - Out matrix
--    X_basic               - Out row
--    X_reenter             - Out row
--    X_variables           - Actual number of variables
--    x_return_status       - Status of the call
--                              S - SUCCESS,
--                              E,U - Error
--
--  HISTORY
--====================================================================*/
  PROCEDURE read_table(P_constraints IN NUMBER,
                       P_variables IN NUMBER,
                       P_matrix IN matrix,
                       P_rhs_matrix IN char_matrix,
                       p_var IN char_row,
                       X_matrix OUT NOCOPY matrix,
                       X_basic OUT NOCOPY row,
                       X_reenter OUT NOCOPY row,
                       X_variables OUT NOCOPY NUMBER,
                       X_con OUT NOCOPY char_row,
                       X_var OUT NOCOPY char_row,
                       X_return_status OUT NOCOPY VARCHAR2) IS
    l_y         ROW;
    l_iLo	NUMBER;
    l_iHi	NUMBER;
    l_pen_low    NUMBER;
    l_pen_high   NUMBER;
    l_rhs	NUMBER;
    l_temp      NUMBER;
  BEGIN
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('LPReadTable:');
    END IF;

    /* initialize return status */
    x_return_status := FND_API.g_ret_sts_success;
    x_var := p_var;

    /* calculate the actual number of variables */
    x_variables := P_variables + 2*P_constraints;

    IF l_debug = 'Y' THEN
      gmd_debug.put_line('LGP:Cons:'||P_constraints||' Var:'||P_variables||' Total Var:'||x_variables);
    END IF;

    /* Initialize the arrays */
    FOR i IN 0..P_constraints + 1 LOOP
      X_basic(i) := 0;
      FOR j IN 0..x_variables LOOP
        X_matrix(i)(j) := 0;
      END LOOP;
    END LOOP;

    FOR j IN 0..x_variables LOOP
      IF j BETWEEN 1 AND p_variables THEN
        X_reenter(j) := 1;
      ELSE
        X_reenter(j):= 0;
      END IF;
    END LOOP;

    FOR j IN 1..p_variables LOOP
      /* Read the optimizing constraint row */
      X_matrix(0)(j) := P_matrix(0)(j);
    END LOOP;

    /* read matrix, rows 1 ... ncon+1 are constraints */
    x_con(p_constraints + 1) := 'ArtCosts';
    FOR i IN 1..P_constraints LOOP
      /* index of slack for row */
      l_iLo := P_variables+ 2*i-1;
      /* index of excess for row */
      l_iHi := P_variables +2*i;

      x_con(i) := p_rhs_matrix(i)(0);
      /* Assign the righ hand side value */
      l_rhs := P_rhs_matrix(i)(1);
      x_matrix(i)(0) := l_rhs;
      /* Assign the penalties */
      l_pen_low := P_rhs_matrix(i)(2);
      l_pen_high := P_rhs_matrix(i)(3);

      FOR j IN 1..P_variables LOOP
        x_matrix(i)(j) := p_matrix(i)(j);
      END LOOP;

      /* Reverse the signs */
      IF l_rhs < 0 THEN
        FOR j IN 0..x_variables LOOP
          x_matrix(i)(j) := -1 * x_matrix(i)(j);
          l_temp := l_pen_low;
          l_pen_low := l_pen_high;
          l_pen_high := l_temp;
        END LOOP;
      END IF; /* IF l_rhs < 0 */

      IF l_log_level = 1 THEN
        gmd_debug.put_line('i:'||'Low:'||l_iLo||' High:'||l_iHi||'Cons:'||x_con(i)||' Pen Low:'||l_pen_low||' Pen Hi:'||l_pen_high);
      END IF;

      X_var(l_iLo) := X_con(i)||'+';

      IF l_pen_low < l_LGP_BIG THEN
        X_reenter(l_iLo) := 1;
        x_matrix(0)(l_iLo) := l_pen_low; -- Save slack cost
      ELSE
        x_matrix(0)(l_iLo) := 0; -- artificial cost
        X_reenter(l_iLo) := 0; -- don't allow entering
      END IF;
      x_matrix(i)(l_iLo) := 1; -- Slack cooefficient
      x_basic(i) := l_iLo; -- Slack in initial basis

      x_var(l_iHi) := x_con(i)||'-';

      IF l_pen_high < l_LGP_BIG THEN
        X_reenter(l_iHi) := 1;
        x_matrix(0)(l_iHi) := l_pen_high; -- Save excess cost
      ELSE
        x_matrix(0)(l_iHi) := 0; -- artificial cost
        X_reenter(l_iHi) := 0; -- don't allow entering
      END IF;
      x_matrix(i)(l_iHi) := -1; -- Excess cooefficient
    END LOOP;

    /* adjust costs for basic vars */
    FOR i IN 1..p_constraints LOOP
      l_y(i) := x_matrix(0)(x_basic(i));
    END LOOP;

    FOR j IN 1..x_variables LOOP
      FOR i IN 1..p_constraints LOOP
        x_matrix(0)(j) := x_matrix(0)(j) - l_y(i) * x_matrix(i)(j);
      END LOOP;
    END LOOP;
  END read_table;


/*====================================================================
--  PROCEDURE:
--    solve_lgp
--
--  DESCRIPTION:
--    This procedure is invoked from the main evaluate routine to solve
--    the given problem to find feasible and then optimal solution.
--
--  PARAMETERS:
--    P_constraints         - Number of constraints in the problem.
--    P_variables           - Number of variables in the problem.
--    P_matrix              - Set of constraints in matrix format.
--    P_reenter             - row marking the entry
--    p_basic               - row type
--    x_return              - Status of the call
--                              0 - Optimum Found,
--                              1 - Unbounded
--                              2 - Max Iterations
--                              3 - Infeasible
--
--
--IN:    nCon     = number of constraint rows (costs are row #0)
--       nVar      = # of variables (RHS = 0)
--INOUT: iBasic(0..nCon+1) = basic variable index vecter
--       Tableau(0..nCon+1,0..nVar) = Tableau for LP problem:
--                     1   2           nVar
--0      | Opt       |    |   | ...   |     | Cost row
--1      | RHS(1)    |    |   | ...   |     | 1st constraint row
--...
--nCon   | RHS(nCon) |    |   | ...   |     | nCon constraint row
--nCon+1 |           |    |   | ...   |     | artificial costs for Phase I
--NOTES: Optimum solution is -Tableau(0,0). Shadow costs are in Tableau(0,1..nVar).
--       Solution is in Tableau(1..nCon,0).
--
--  HISTORY
--====================================================================*/
  PROCEDURE solve_lgp (P_constraints IN NUMBER,
                       P_variables IN NUMBER,
                       P_matrix IN matrix,
                       P_reenter IN row,
                       P_basic IN row,
                       X_matrix OUT NOCOPY matrix,
                       X_basic OUT NOCOPY row,
                       X_return OUT NOCOPY NUMBER) IS
    l_max_iterations PLS_INTEGER;
    l_temp_col ROW;
    l_cost_row NUMBER;
    l_iteration NUMBER;
    l_min_cost NUMBER;
    l_enter NUMBER;
    l_print_line VARCHAR2(2000);
    l_leave PLS_INTEGER;
    l_min NUMBER;
    l_var_tie NUMBER;
    l_broken_tie BOOLEAN;
    l_x NUMBER;
    l_diff NUMBER;
    l_row NUMBER;
  BEGIN
    /* initialize global variables and constants */
    X_return := 0; -- No error
    x_matrix := p_matrix;
    x_basic := p_basic;

    /* set maximum number of iterations */
    l_max_iterations := 10 * P_constraints;

    IF l_debug = 'Y' THEN
      gmd_debug.put_line('LPSolve:Cons:'||P_constraints||' Var:'||P_variables||' Max Iter:'||l_max_iterations);
    END IF;

    /* set up artificial costs */
    FOR i IN 1..P_constraints LOOP
      /* infinite penaly, treat as artificial var */
      IF P_reenter(x_basic(i)) = 0 THEN
        FOR j IN 0..P_variables LOOP
          /* cost is neg sum of coefs in column */
          x_matrix(p_constraints + 1)(j) := x_matrix(p_constraints + 1)(j) - x_matrix(i)(j);
        END LOOP;
      END IF;
    END LOOP;

    /* first phase, use artificial costs */
    l_cost_row := P_constraints + 1;

    /* zero iteration counter */
    l_iteration := 0;
    /* simplex iteration loop - endless loop until error or optimal */
    WHILE 1 = 1 LOOP
      /* find variable to enter (minimum (neg) value of reduced cost) */
      l_min_cost := 0;
      /* temp index */
      l_enter := 0;
      FOR j IN 1..P_variables LOOP
        /* cost is negative and can enter */

        IF (x_matrix(l_cost_row)(j) < 0) AND
           (p_reenter(j) = 1) THEN

          /* found a smaller cost */
          IF (l_min_cost > x_matrix(l_cost_row)(j)) THEN
            l_min_cost := x_matrix(l_cost_row)(j);
            l_enter := j;
          END IF;
        END IF;
      END LOOP;

      IF l_enter = 0 THEN
        /* no variable lowers cost: optimal or Non-implementable */
        IF (l_cost_row = 0) THEN
          X_return := 0;
          EXIT;
        END IF;

        /* check for feasibility (iCostRow = ncon+1 here) */
        FOR j IN 1..P_variables LOOP
          IF (x_matrix(l_cost_row)(j) > l_LGP_EPS_ZERO) THEN
            /* Non-implementable */
            X_return := 3;
            EXIT;
          END IF;
        END LOOP;

        /* Quit */
        IF X_return = 3 THEN
          EXIT;
        END IF;

        /*if we get here, solution is implementable */

        IF l_debug = 'Y' THEN
          gmd_debug.put_line('Solution is implementable:');
          FOR i IN 1..P_constraints LOOP
            l_print_line := NULL;
            FOR j IN 1..P_variables LOOP
              l_print_line := l_print_line||x_matrix(i)(j)||' ';
            END LOOP;
            gmd_debug.put_line(l_print_line);
          END LOOP;
        END IF;

        /* set to actual costs */
        l_cost_row := 0;
      ELSE
        /* have entering variable to include */
        l_leave := 0; -- find variable to leave
        l_min := l_LGP_BIG; -- set to infinity initially

        FOR i IN 1..P_constraints LOOP
          /* consider only variables with positive coefficients */
          IF (x_matrix(i)(l_enter) > l_LGP_EPS_ZERO) THEN
            l_var_tie := 0;
            l_broken_tie := FALSE;
            WHILE NOT (l_broken_tie) LOOP
              IF (l_var_tie = 0) THEN -- first time
                /* max amount can change RHS/coef */
                l_x := x_matrix(i)(0) / x_matrix(i)(l_enter);
              ELSE -- have tie
                l_x := x_matrix(i)(x_basic(l_var_tie + 1)) / x_matrix(i)(l_enter);
              END IF;

              l_diff := l_x - l_min;
              /* keep min value esitmate */
              IF (l_diff <= l_LGP_EPS_ZERO) THEN
                /* keep smallest max amt */
                l_min := x_matrix(i)(0) / x_matrix(i)(l_enter);
                l_leave := i; -- and row
                l_broken_tie := TRUE;
              ELSIF (abs(l_diff) < l_LGP_EPS_ZERO) THEN -- have tie
                l_var_tie := l_var_tie + 1;
                l_min := x_matrix(l_leave)(x_basic(l_var_tie + 1)) / x_matrix(i)(l_enter);
              ELSE
                l_broken_tie := TRUE;
              END IF;
            END LOOP; /* WHILE NOT (l_broken_tie) */
          END IF; /* IF (x_matrix(i)(l_enter) > l_LGP_EPS_ZERO) */
        END LOOP; /* FOR i IN 1..P_constraints */

        /* unbounded .. no positive coefficients */
        IF l_leave = 0 THEN
          X_return := 1; -- unbounded solution;
          EXIT;
        END IF;

        /* gaussian elimination to replace iLeave with iEnter */
        x_basic(l_leave) := l_enter; -- keep new variable number
        l_x := x_matrix(l_leave)(l_enter); -- pivot value
        IF (l_cost_row = 0) THEN
          l_row := p_constraints;
        ELSE
          l_row := p_constraints + 1;
        END IF;

        FOR i IN 0..l_row LOOP
          l_temp_col(i) := x_matrix(i)(l_enter);
        END LOOP;

        /* calculate new pivot row */
        FOR j IN 0..P_variables LOOP
          x_matrix(l_leave)(j) := x_matrix(l_leave)(j) / l_x;
        END LOOP;

        FOR i IN 0..l_row LOOP
          IF (i <> l_leave) THEN
            FOR j IN 0..p_variables LOOP
              x_matrix(i)(j) := x_matrix(i)(j) - l_temp_col(i) * x_matrix(l_leave)(j);
            END LOOP;
          END IF;
        END LOOP;

        /* increment iteration count */
        l_iteration := l_iteration + 1;
        -- utl_file.put_line(l_file, 'At Iteration#'||l_iteration||' Value is:'||ROUND((-1*x_matrix(l_cost_row)(0)), 9)||' Entering is:'||x_basic(l_leave));
        IF l_debug = 'Y' THEN
          gmd_debug.put_line('At Iteration#'||l_iteration||' Value is:'||(-1*x_matrix(l_cost_row)(0))||' Entering is:'||x_basic(l_leave));
        END IF;

        IF l_iteration > l_max_iterations THEN
          X_return := 2; -- max iterations
          EXIT;
        END IF;
      END IF; /* IF l_enter = 0 */

    END LOOP; /* WHILE 1 = 1 */
  END solve_lgp;


END GMD_LCF_ENGINE;

/
