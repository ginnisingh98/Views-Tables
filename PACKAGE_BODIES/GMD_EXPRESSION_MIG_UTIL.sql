--------------------------------------------------------
--  DDL for Package Body GMD_EXPRESSION_MIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_EXPRESSION_MIG_UTIL" AS
/* $Header: GMDPEXMB.pls 120.0 2005/08/11 08:56:35 txdaniel noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_EXPRESSION_UTIL';

P_Ingr_line_tab	line_tab;
P_Byp_line_tab	line_tab;
operator_tab	Operator_Table := Operator_Table('+', '-', '/', '*', '(', ')', 'SUM', 'ISUM', 'BSUM',
                                                 'POWER', 'ABS', 'SQRT', 'EXP', 'LOG', 'LN', 'MOD',
                                                 'ROUND', 'CEIL', ',');

  /*******************************************************************************
  * Procedure parse_expression
  *
  * Procedure:-  This procedure parses the expression passed in into tokens.
  *              Raju Cursor has been modified due to connect by errors in 8i env
  *
  *********************************************************************************/
  PROCEDURE parse_expression
  (     p_orgn_code		IN	       VARCHAR2	,
        p_tech_parm_id		IN	       NUMBER	,
        p_expression		IN	       VARCHAR2	,
        x_return_status         OUT NOCOPY     VARCHAR2
  ) IS

    CURSOR Cur_check_loop (V_tech_parm_id NUMBER) IS
      SELECT max(level)
          FROM   gmd_parsed_expression p
          WHERE  expression_type <> -1
          START WITH p.tech_parm_id = V_tech_parm_id
          CONNECT BY PRIOR expression_parm_id = p.tech_parm_id
          AND (p.data_type <> 11 OR p.tech_parm_id <> p.expression_parm_id);

      /*SELECT max(level)
      FROM   gmd_parsed_expression p, gmd_tech_parameters_b b
      WHERE  expression_type <> -1
      AND    p.tech_parm_id = b.tech_parm_id (+)
      START WITH p.tech_parm_id = V_tech_parm_id
      CONNECT BY PRIOR expression_parm_id = p.tech_parm_id
      AND (b.data_type <> 11 or p.tech_parm_id <> expression_parm_id);*/

    L_length		NUMBER;
    L_str		VARCHAR2(200);
    L_char		VARCHAR2(10);
    L_expr		VARCHAR2(200);
    L_return_status	VARCHAR2(1);
    L_level		NUMBER(5);

    EXPRESSION_KEY_ERR	EXCEPTION;
    CIRCULAR_REFERENCE	EXCEPTION;
    PRAGMA EXCEPTION_INIT(circular_reference, -01436);
  BEGIN
    /* Establish the savepoint initially */
    SAVEPOINT parse_expression;

    /* First let us assign the return status to success */
    X_return_status := FND_API.g_ret_sts_success;

    /* Delete any parsed expression which was existing already */
    DELETE FROM gmd_parsed_expression
    WHERE tech_parm_id = p_tech_parm_id;

    L_length := LENGTH(P_expression);
    FOR i IN 1..L_length LOOP
      L_char := SUBSTR(P_expression, i, 1);
      /*Check if the character is an operator */
      IF is_operator (P_operator => L_char) THEN
        /* If we have an operator then lets see if their are any preceding keys */
        IF L_str IS NOT NULL THEN
          /*If their is a preceding string then insert it as either an operator or operand */
          insert_expression_key (P_orgn_code		=> P_orgn_code,
                                 P_tech_parm_id 	=> P_tech_parm_id,
                                 P_key 			=> L_str,
                                 X_return_status 	=> L_return_status);
          IF l_return_status <> x_return_status THEN
            RAISE expression_key_err;
          END IF;
          L_str := NULL;
        END IF;
        /* Add the operator row */
        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> L_char,
                            P_Type 		=> 1,
                            P_exp_parm_id	=> NULL,
                            X_return_status 	=> l_return_status);
        IF l_return_status <> x_return_status THEN
          RAISE expression_key_err;
        END IF;
      ELSE
        L_str := RTRIM(L_str || L_char);
      END IF;
    END LOOP;
    /* We have traversed through the expression, now lets see if we */
    /* have a key which was not enclosed by an operator             */
    IF L_str IS NOT NULL THEN
      insert_expression_key (P_orgn_code	=> P_orgn_code,
                             P_tech_parm_id	=> P_tech_parm_id,
                             P_key 		=> L_str,
                             X_return_status 	=> L_return_status);
      IF l_return_status <> x_return_status THEN
        RAISE expression_key_err;
      END IF;
    END IF;

    /* Now let us update all the existing parsed expressions which are referrring to this parameter */
    UPDATE gmd_parsed_expression a
    SET expression_type = -1,
        expression_parm_id = P_tech_parm_id
    WHERE expression_type = 0
    AND   EXISTS (SELECT 1
                  FROM gmd_tech_parameters_b b
                  WHERE b.tech_parm_name = a.expression_key
                  AND   b.tech_parm_id = p_tech_parm_id)
    AND  EXISTS (SELECT 1
                 FROM  gmd_tech_parameters_b c
                 WHERE NVL(c.orgn_code, 'zzzzz') = NVL(p_orgn_code, 'zzzzz')
                 AND   c.tech_parm_id =  a.tech_parm_id);

    /* We have parsed the expression now, lets check if their are any circular references */
    OPEN Cur_check_loop (p_tech_parm_id);
    FETCH Cur_check_loop  INTO l_level;
    CLOSE Cur_check_loop;

  EXCEPTION
    WHEN expression_key_err THEN
      x_return_status := l_return_status;
      ROLLBACK TO SAVEPOINT parse_expression;
    WHEN circular_reference THEN
      GMD_API_GRP.log_message ('GMD_EXP_CIRC_REF');
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT parse_expression;
      fnd_msg_pub.add_exc_msg ('GMD_EXPRESSION_UTIL', 'Parse_Expression');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END parse_expression;

  /*******************************************************************************
  * Procedure insert_expression_key
  *
  * Procedure:-  This procedure evaluates the key and inserts it as an operator or
  *              a parameter based on its value.
  *
  *********************************************************************************/
  PROCEDURE insert_expression_key
  (     p_orgn_code		IN	       VARCHAR2,
        p_tech_parm_id		IN	       NUMBER,
        p_key			IN	       VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2
  ) IS

    L_expression	VARCHAR2(80);
    L_parm_id		NUMBER(15);
    L_data_type		NUMBER(5);
    L_return_status	VARCHAR2(1);

    INSERT_EXPRESSION_ERR	EXCEPTION;
  BEGIN
    /* First let us assign the return status to success */
    X_return_status := FND_API.g_ret_sts_success;

    /* Lets initialize the message stack */
    FND_MSG_PUB.initialize;

    /* First lets check if the passed in key is a technical parameter */
    IF is_parameter (P_orgn_code	=> P_orgn_code,
                     P_parameter 	=> P_key,
                     X_parm_id		=> l_parm_id,
                     X_data_type	=> l_data_type) THEN
      /* Yes the key is a parameter, now let us check if this parameter */
      /* is of type expression which needs to be exploded               */
      IF L_data_type IN (4,11) THEN
        /* First insert the enclosing bracket to evaluate the expression piece seperately */
        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> '(',
                            P_Type 		=> 1,
                            P_exp_parm_id	=> NULL,
                            X_return_status 	=> l_return_status);
        IF l_return_status <> X_return_status THEN
          RAISE insert_expression_err;
        END IF;

        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> P_key,
                            P_Type 		=> -1,
                            p_data_type 	=> l_data_type,
                            P_exp_parm_id	=> l_parm_id,
                            X_return_status 	=> l_return_status);
        IF l_return_status <> X_return_status THEN
          RAISE insert_expression_err;
        END IF;

        /* Add the closing bracket for the parsed expression */
        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> ')',
                            P_Type 		=> 1,
                            P_exp_parm_id	=> NULL,
                            X_return_status 	=> l_return_status);
        IF l_return_status <> X_return_status THEN
          RAISE insert_expression_err;
        END IF;

      ELSE
        /* This is a pure techical parameter so lets insert it as an operand */
        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> P_key,
                            P_Type 		=> 0,
                            P_exp_parm_id	=> NULL,
                            X_return_status 	=> l_return_status);
        IF l_return_status <> X_return_status THEN
          RAISE insert_expression_err;
        END IF;
      END IF;
    /*The key is not a technical parameter, it should be an operator */
    ELSIF is_operator (P_operator => P_key) THEN
      /* Insert rollup type operators with a different p type */
      IF P_key IN ('ISUM', 'BSUM') THEN
        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> P_key,
                            P_Type 		=> 2,
                            P_exp_parm_id	=> NULL,
                            X_return_status 	=> l_return_status);
        IF l_return_status <> X_return_status THEN
          RAISE insert_expression_err;
        END IF;
      ELSE
        add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                            P_key 		=> P_key,
                            P_Type 		=> 1,
                            P_exp_parm_id	=> NULL,
                            X_return_status 	=> X_return_status);
        IF l_return_status <> X_return_status THEN
          RAISE insert_expression_err;
        END IF;
      END IF;
    ELSIF is_number(p_token => p_key) THEN
      add_expression_row (P_tech_parm_id	=> P_tech_parm_id,
                          P_key 		=> P_key,
                          P_Type 		=> 1,
                          P_exp_parm_id		=> NULL,
                          X_return_status 	=> X_return_status);
      IF l_return_status <> X_return_status THEN
        RAISE insert_expression_err;
      END IF;
    ELSE
      GMD_API_GRP.log_message ('GMD_EXP_PARM_NOT_DEF', 'PARAMETER', P_key);
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN insert_expression_err THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_EXPRESSION_UTIL', 'Insert_Expression_Key');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END insert_expression_key;

  /*******************************************************************************
  * Function is_operator
  *
  * Function:-  This function checks if the passed in token is an operator
  *
  *
  *********************************************************************************/

  FUNCTION is_operator
  (     p_operator		IN	VARCHAR2
  ) RETURN BOOLEAN IS

  BEGIN
    FOR i IN 1..Operator_Tab.COUNT LOOP
      IF Operator_Tab(i) = P_Operator THEN
        RETURN (TRUE);
      END IF;
    END LOOP;
    RETURN(FALSE);
  END is_operator;


  /*******************************************************************************
  * Function is_parameter
  *
  * Function:-  This function checks if the passed in token is a parameter
  *
  *
  *********************************************************************************/

  FUNCTION is_parameter
  (     p_orgn_code		IN	   VARCHAR2	,
        p_parameter		IN	   VARCHAR2	,
        x_parm_id		OUT NOCOPY NUMBER	,
        x_data_type		OUT NOCOPY NUMBER
  ) RETURN BOOLEAN IS

    CURSOR Cur_parameter (V_orgn_code VARCHAR2, V_parameter VARCHAR2) IS
      SELECT tech_parm_id, data_type
      FROM   gmd_tech_parameters_b
      WHERE  tech_parm_name = V_parameter
      AND    NVL(orgn_code, 'zzzzz') = NVL(v_orgn_code, 'zzzzz')
      AND    delete_mark = 0;
  BEGIN
    IF p_parameter IN ('QTY$', 'VOL$') THEN
      X_data_type := 0;
      RETURN(TRUE);
    ELSE
      /* Check if the passed in parameter is a technical parameter */
      OPEN Cur_parameter (P_orgn_code, P_Parameter);
      FETCH Cur_parameter INTO X_parm_id, X_data_type;
      IF Cur_parameter%NOTFOUND THEN
        CLOSE Cur_parameter;
        RETURN (FALSE);
      ELSE
        CLOSE Cur_parameter;
        RETURN (TRUE);
      END IF;
    END IF;
  END is_parameter;


  /*******************************************************************************
  * Function is_number
  *
  * Function:-  This function checks if the passed in token is a number
  *
  *
  *********************************************************************************/

  FUNCTION is_number
  (     p_token			IN	   VARCHAR2
  ) RETURN BOOLEAN IS
    l_number	NUMBER;
  BEGIN
    l_number := TO_NUMBER(p_token);
    RETURN (TRUE);
  EXCEPTION
    WHEN others THEN
      RETURN (FALSE);
  END is_number;


  /*******************************************************************************
  * Procedure add_expression_row
  *
  * Procedure:-  This procedure inserts the key to the temporary table
  *
  *********************************************************************************/
  PROCEDURE add_expression_row
  (     p_tech_parm_id		IN	        NUMBER,
        p_key			IN	        VARCHAR2,
        p_type		        IN     	        VARCHAR2,
	p_data_type		IN		NUMBER,
        p_exp_parm_id		IN	        NUMBER,
        x_return_status		OUT NOCOPY	VARCHAR2
  ) IS
    l_user_id		NUMBER(15) DEFAULT FND_PROFILE.VALUE('USER_ID');
  BEGIN
    /* First let us assign the return status to success */
    X_return_status := FND_API.g_ret_sts_success;

    INSERT INTO GMD_PARSED_EXPRESSION (tech_exp_seq_id, tech_parm_id, expression_key, expression_type,
                                       expression_parm_id, creation_date, created_by, last_updated_by,
                                       last_update_date,data_type)
    VALUES (gmd_tech_exp_seq_id_s.nextval, p_tech_parm_id, p_key, p_type, p_exp_parm_id, sysdate, l_user_id,
            l_user_id, sysdate,p_data_type);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_EXPRESSION_UTIL', 'Add_Expression_Row');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END add_expression_row;

  /*******************************************************************************
  * Procedure evaluate_expression_value
  *
  * Procedure:-  This procedure evaluates the value for the expression passed in
  *              p_expression_tab.
  *********************************************************************************/

  PROCEDURE evaluate_expression_value
  (     p_line_id		IN		NUMBER,
        P_expression_tab	IN		EXPRESSION_TAB,
        x_value			OUT NOCOPY	VARCHAR2,
        x_return_status		OUT NOCOPY	VARCHAR2
  ) IS
    l_exp_tab		EXPRESSION_TAB;
    l_expression_tab	EXPRESSION_TAB;
    l_expr      	VARCHAR2(2000);
    l_value		VARCHAR2(2000);
    l_tot_value		NUMBER DEFAULT 0;
    l_bracket_count	NUMBER(5) DEFAULT 0;
    l_start		NUMBER(5);
    l_end		NUMBER(5);
    l_count		NUMBER(5) DEFAULT 0;
    l_table_count	NUMBER(5);
    i			BINARY_INTEGER DEFAULT 1;
    l_temp 		VARCHAR2(2000);
    l_return_status	VARCHAR2(1);

    EXPRESSION_EVAL_ERR	EXCEPTION;
  BEGIN
    /* First let us assign the return status to success */
    X_return_status := FND_API.g_ret_sts_success;

    gmd_debug.put_line('Evaluating....Line:'||p_line_id);
    FOR m IN 1..p_expression_tab.COUNT LOOP
      l_temp := l_temp||p_expression_tab(m).expression_key;
    END LOOP;
    gmd_debug.put_line('Expr:'||l_temp);

    l_expression_tab := P_expression_tab;
    l_table_count := l_expression_tab.COUNT;
    WHILE i <= l_table_count LOOP
      gmd_debug.put_line('Key:'||l_expression_tab(i).expression_key);
      /*Bug 4082268 - Value should be fetched also for expression type -1*/
      IF l_expression_tab(i).expression_type IN (0, -1) THEN
        l_expr := l_expr||get_value (p_line_id => p_line_id
                                    ,p_parameter => l_expression_tab(i).expression_key);
      ELSIF l_expression_tab(i).expression_type = 2 THEN
        l_start := i + 1;
        l_bracket_count := 0;
	/*Bug 4082268 - Count should be initialized to set the expression properly */
	l_count := 0;
        FOR k in i+2..l_expression_tab.COUNT LOOP
          l_end := k;
          IF l_expression_tab(k).expression_key = ')' THEN
            IF l_bracket_count = 0 THEN
              EXIT;
            ELSE
              l_bracket_count := l_bracket_count - 1;
            END IF;
          ELSIF l_expression_tab(k).expression_key = '(' THEN
            l_bracket_count := l_bracket_count + 1;
          END IF;
	  /*Bug 4082268 - Closed the above Else to include the bracketes in the expression*/
          l_count := l_count + 1;
          l_exp_tab(l_count).expression_key := l_expression_tab(k).expression_key;
          l_exp_tab(l_count).expression_type := l_expression_tab(k).expression_type;
        END LOOP;
        l_tot_value := 0;
        IF l_expression_tab(i).expression_key = 'ISUM' THEN
          FOR j in 1..P_ingr_line_tab.COUNT LOOP
            evaluate_expression_value (P_line_id => p_ingr_line_tab(j),
                                       P_expression_tab => l_exp_tab,
                                       x_value	=> l_value,
                                       x_return_status => l_return_status);
            IF l_return_status <> x_return_status THEN
              RAISE expression_eval_err;
            END IF;
            gmd_debug.put_line('In ISUM procedure value:'||l_value||' Tot Value:'||l_tot_value);
            IF NVL(l_value, 'NULL') <> 'NULL' THEN
              l_tot_value := l_tot_value + l_value;
            END IF;
          END LOOP;
        ELSE
          FOR j in 1..P_byp_line_tab.COUNT LOOP
            evaluate_expression_value (P_line_id => p_byp_line_tab(j),
                                       P_expression_tab => l_exp_tab,
                                       x_value	=> l_value,
                                       x_return_status => l_return_status);
            IF l_return_status <> x_return_status THEN
              RAISE expression_eval_err;
            END IF;
            gmd_debug.put_line('Not In ISUM Value:'||l_value);
            IF NVL(l_value, 'NULL') <> 'NULL' THEN
              l_tot_value := l_tot_value + l_value;
            END IF;
          END LOOP;
        END IF;
	/*Bug 4082268 - The following statements will corrupt the expression table */
	/*while the procedure is being called recursively and is not needed */
        -- l_expression_tab(i).expression_key := l_tot_value;
        -- l_expression_tab(i).expression_type := 1;
        -- l_expression_tab.delete (l_start, l_end);
        IF l_tot_value IS NULL THEN
          l_expr := l_expr||'NULL';
        ELSE
          l_expr := l_expr||l_tot_value;
        END IF;
        i := l_end;
        gmd_debug.put_line('Total:'||l_tot_value||' Start:'||l_start||' End:'||l_end||' Expr:'||l_expr);
      ELSE
        l_expr := l_expr||p_expression_tab(i).expression_key;
      END IF;
      i := i + 1;
    END LOOP;
    gmd_debug.put_line('Final Expr:'||l_expr);
    IF l_expr IS NOT NULL THEN
      GMD_UTILITY_PKG.execute_exp (pexp => l_expr,
                                   pexp_test => FALSE,
                                   x_result => x_value,
                                   x_return_status => l_return_status);
      IF l_return_status <> x_return_status THEN
        RAISE expression_eval_err;
      END IF;
      gmd_debug.put_line('Value:'||x_value);
    END IF;
  EXCEPTION
    WHEN expression_eval_err THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      gmd_debug.put_line('ERROR:'||sqlerrm);
      fnd_msg_pub.add_exc_msg ('GMD_EXPRESSION_UTIL', 'Evaluate_Expression_Value');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END evaluate_expression_value;


  /*******************************************************************************
  * Function get_value
  *
  * Function:-  This procedure returns the technical parameter value.
  *********************************************************************************/

  FUNCTION get_value
  (     p_line_id		IN	NUMBER,
        p_parameter		IN	VARCHAR2
  ) RETURN VARCHAR2 IS

    CURSOR Cur_get_line_qty (V_line_id NUMBER) IS
      SELECT qty_mass, qty_vol
      FROM   gmd_material_details_gtmp
      WHERE  line_id = V_line_id;

    CURSOR Cur_value (V_line_id NUMBER, V_parameter VARCHAR2) IS
      SELECT value
      FROM gmd_technical_data_gtmp
      WHERE line_id = v_line_id
      AND   tech_parm_name = V_parameter;
    l_value NUMBER;
    l_mass_qty	NUMBER;
    l_vol_qty	NUMBER;
  BEGIN
    gmd_debug.put_line(' In Get Value:'||p_parameter);
    IF p_parameter IN ('QTY$', 'VOL$') THEN
      OPEN Cur_get_line_qty (p_line_id);
      FETCH Cur_get_line_qty INTO l_mass_qty, l_vol_qty;
      CLOSE Cur_get_line_qty;
      IF p_parameter = 'QTY$' THEN
        l_value := l_mass_qty;
      ELSE
        l_value := l_vol_qty;
      END IF;
    ELSE
      OPEN Cur_value (P_line_id, P_parameter);
      FETCH Cur_value INTO l_value;
      CLOSE Cur_value;
    END IF;
    gmd_debug.put_line('Returning:'||l_value);
    IF l_value IS NULL THEN
    gmd_debug.put_line(' Returning NULL');
      RETURN('NULL');
    ELSE
      RETURN(l_value);
    END IF;
  END get_value;



  /*******************************************************************************
  * Procedure evaluate_expression
  *
  * Procedure:-  This procedure evaluates the expression.
  *********************************************************************************/

  PROCEDURE evaluate_expression
  (     p_entity_id		IN		NUMBER,
        p_line_id		IN		NUMBER,
        p_tech_parm_id		IN		NUMBER,
        x_value			OUT NOCOPY	NUMBER,
        x_expression		OUT NOCOPY	VARCHAR2,
        x_return_status		OUT NOCOPY	VARCHAR2
  ) IS

    CURSOR Cur_get_expr (V_parm_id NUMBER) IS
      SELECT expression_key, expression_type
      FROM   gmd_parsed_expression p
      WHERE  p.tech_parm_id = V_parm_id;
      /*Bug 4082268 - Commented the following where clause as there is no need */
      /*to split all the expressions a pure select should be enough for evaluating */
      /*WHERE  (expression_type <> -1 or
              p.tech_parm_id = expression_parm_id)
      START WITH p.tech_parm_id = V_parm_id
      CONNECT BY PRIOR expression_parm_id = p.tech_parm_id
      AND PRIOR p.tech_parm_id <> PRIOR expression_parm_id;
      */

    CURSOR Cur_get_line (V_line_type NUMBER) IS
      SELECT line_id
      FROM   gmd_material_details_gtmp a
      WHERE  entity_id = p_entity_id
      AND    rollup_ind = 1
      AND    EXISTS (SELECT 1
                     FROM gmd_material_details_gtmp b
                     WHERE  line_type = V_line_type
                     AND    entity_id = p_entity_id
                     AND    a.parent_line_id = b.parent_line_id);

    l_expression_tab	EXPRESSION_TAB;
    i			BINARY_INTEGER := 0;
    l_value		VARCHAR2 (2000);

    CIRCULAR_REFERENCE	EXCEPTION;
    PRAGMA EXCEPTION_INIT(circular_reference, -01436);
  BEGIN
    /* First let us assign the return status to success */
    X_return_status := FND_API.g_ret_sts_success;

    /* Lets initialize the message stack */
    FND_MSG_PUB.initialize;

    /* Fetch the expression associated with the technical parameter */
    FOR l_rec IN Cur_get_expr(P_tech_parm_id) LOOP
      i := i + 1;
      l_expression_tab(i).expression_key  := l_rec.expression_key;
      l_expression_tab(i).expression_type := l_rec.expression_type;
      x_expression := x_expression||l_rec.expression_key;
    END LOOP;

    IF l_expression_tab.COUNT > 0 THEN
      OPEN Cur_get_line(-1);
      FETCH Cur_get_line BULK COLLECT INTO P_ingr_line_tab;
      CLOSE Cur_get_line;

      OPEN Cur_get_line(2);
      FETCH Cur_get_line BULK COLLECT INTO P_byp_line_tab;
      CLOSE Cur_get_line;

      evaluate_expression_value (p_line_id =>  p_line_id,
                                 p_expression_tab => l_expression_tab,
                                 x_value => l_value,
                                 x_return_status => x_return_status);
      IF x_return_status = FND_API.g_ret_sts_success THEN
        X_value := l_value;
      END IF;
    END IF;
  EXCEPTION
    WHEN circular_reference THEN
      GMD_API_GRP.log_message ('GMD_EXP_CIRC_REF');
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_EXPRESSION_UTIL', 'Evaluate_Expression');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END evaluate_expression;


END GMD_EXPRESSION_MIG_UTIL;

/
