--------------------------------------------------------
--  DDL for Package Body GMD_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_UTILITY_PKG" AS
/* $Header: GMDUTLPB.pls 120.2 2006/08/22 07:45:14 rlnagara noship $ */
  PROCEDURE check_if_oprnd_exist(x_exptab IN exptab,
                      	         x_operand IN VARCHAR2,
                                 x_value OUT NOCOPY  NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2) IS
  l_exist BOOLEAN := FALSE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR i IN 1..x_exptab.count LOOP
      IF (x_exptab(i).pvalue_type = 'O') THEN
        IF (x_exptab(i).poperand = x_operand) THEN
          x_value := x_exptab(i).pvalue;
          l_exist := TRUE;
          RETURN;
        END IF;
      END IF;
    END LOOP;
    IF (not l_exist) THEN
      x_value := null;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
  END check_if_oprnd_exist;

  PROCEDURE parse(x_exp             IN   VARCHAR2,
                  x_exptab          OUT NOCOPY  exptab,
                  x_return_status   OUT NOCOPY  VARCHAR2) IS
    q_count   integer  := 0;
    ob_count integer := 0;
    cb_count integer := 0;
    l_exptab  exptab;
    x_len       INTEGER;
    x_value    NUMBER;
    x_result   NUMBER;
  BEGIN
    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (x_exp IS NOT NULL) THEN
      x_len := length(x_exp);
      FOR i IN 1..x_len LOOP
        IF (substr(x_exp,i,1) = '"') THEN
  	  q_count := q_count + 1;
  	ELSIF (substr(x_exp,i,1) = '(') THEN
  	  ob_count := ob_count + 1;
  	ELSIF (substr(x_exp,i,1) = ')') THEN
  	  cb_count := cb_count + 1;
  	END IF;
      END LOOP;

      IF q_count > 0 THEN
        SELECT MOD(q_count,2) into x_result from sys.dual;
  	IF x_result > 0 THEN
  	   FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_OPERANDS');
  	   FND_MSG_PUB.ADD;
  	   x_return_status := FND_API.G_RET_STS_ERROR;
  	   RETURN;
  	END IF;
      END IF;
      IF (ob_count <> cb_count) THEN
  	 FND_MESSAGE.SET_NAME('GMD','GMD_WRONG_PARENTHESIS');
  	 FND_MSG_PUB.ADD;
  	 x_return_status := FND_API.G_RET_STS_ERROR;
  	 RETURN;
      END IF;
      tokenize_exp(x_exp,x_exptab);
      IF (x_exptab.count > 0 ) THEN
        evaluate_exp(x_exptab,
                     TRUE,
                     x_value,
                     x_return_status);
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
  END parse;


  PROCEDURE tokenize_exp(pexp    IN  VARCHAR2,
                         x_exptab OUT NOCOPY exptab) IS
    i    NUMBER := 1;
    j    NUMBER := 1;
    k    NUMBER := 1;
    len  NUMBER      := 0;
    x_exp VARCHAR2(4000);--BUG#3173796 Increased to 4000 from 2000
    x_operand VARCHAR2(200);--BUG#3256165 Increased from 50 to 200
    x_expression VARCHAR2(4000);--BUG#3173796 Increased to 4000 from 2000
    x_value NUMBER := 1;
    l_value NUMBER;
    l_return_status VARCHAR2(3);
  BEGIN
    x_exp := pexp;
    len := length(x_exp);
    WHILE i <= len LOOP
      IF (substr(x_exp,i,1) = '"') THEN
        j := i + 1;
        IF (j > len) THEN
          i := i + 1;
        END IF;
  	WHILE j <= len LOOP
	  IF (substr(x_exp,j,1) <> '"') THEN
  	    x_operand := x_operand||substr(x_exp,j,1);
  	    j:= j+1;
  	  ELSE
 	    i := j+1;
  	    j:= 0;
  	    IF (x_operand IS NOT NULL) THEN
  	      -- Check if this is a repeated operand
  	      check_if_oprnd_exist(x_exptab,x_operand,l_value,l_return_Status);
  	      x_exptab(k).poperand := x_operand;
  	      x_exptab(k).pvalue  := nvl(l_value,x_value);
  	      x_exptab(k).pvalue_type := 'O';
  	      k := k + 1;
  	      x_operand := null;
  	      x_value := x_value + 1;
  	    END IF;
  	    EXIT;
  	  END IF;
        END LOOP;
      ELSE
        x_exptab(k).poperand := substr(x_exp,i,1);
        x_exptab(k).pvalue  := NULL;
        x_exptab(k).pvalue_type := 'S';
        k := k + 1;
  	i := i + 1;
      END IF;
    END LOOP;
   END tokenize_exp;


  PROCEDURE evaluate_exp(pexptab         IN exptab,
                         pexp_test       IN BOOLEAN,
                         x_value         OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2) IS
    x_result NUMBER;
    x_expression  VARCHAR2(4000);--BUG#3173796 Increased to 4000 from 2000
    INVALID_EXPRESSION EXCEPTION;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (pexptab.count = 0) THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_NO_EXPRESSION');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    FOR i in 1..pexptab.count LOOP
      IF (pexptab(i).pvalue_type = 'S') THEN
        x_expression := x_expression||pexptab(i).poperand;
      ELSIF(pexptab(i).pvalue_type = 'O') THEN

        -- B3199585 START
        -- x_expression := x_expression||' '||to_char(nvl(pexptab(i).pvalue,1));
        if pexptab(i).pvalue IS NOT NULL THEN
          x_expression := x_expression||' '||to_char(pexptab(i).pvalue);
        ELSE
          x_expression := x_expression||' '|| 'NULL';
        END IF;
        -- B3199585 END
      END IF;

    END LOOP;
       -- dbms_output.put_line(' expression before execute '||x_expression);
       gmd_debug.put_line ('Expression to be executed:' || x_expression);
       --RLNAGARA Bug5473185 Pass in pexp_test from input parameter so that correct error handling occurs
       -- No longer hard code a TRUE for this input parameter.
       execute_exp(x_expression,pexp_test,x_value,x_return_Status);
       --dbms_output.put_line(' after execute '||to_char(x_value)||'  '||x_return_Status);
    EXCEPTION
      WHEN INVALID_EXPRESSION THEN
      	FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_EXPRESSION');
      	FND_MSG_PUB.ADD;
      	x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END evaluate_exp;


  PROCEDURE execute_exp(pexp       IN  VARCHAR2,
                        pexp_test  IN  BOOLEAN,
                        x_result   OUT NOCOPY NUMBER,
  		        x_return_status OUT NOCOPY VARCHAR2) IS
    cur_hdl         INTEGER;
    stmt_str        VARCHAR2(4000);--BUG#3173796 Increased to 4000 from 200
    rows_processed  BINARY_INTEGER;
    l_result        NUMBER;
    l_dummy         INTEGER;
    format_profile  VARCHAR2(30);
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--RLNAGARA Bug 5006158

    format_profile := FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS');
    IF substr(format_profile,0,1) <> '.' THEN
       stmt_str := 'SELECT '||replace(pexp,substr(format_profile,0,1),'.')||' from dual ';
    ELSE
       stmt_str := 'SELECT '||pexp||' from dual ';
    END IF;

--RLNAGARA Bug5006158

    --dbms_output.put_line(pexp);
    -- open cursor
    cur_hdl := dbms_sql.open_cursor;
    -- parse cursor
    dbms_sql.parse(cur_hdl, stmt_str,dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(cur_hdl,1,l_result);
    l_dummy :=  DBMS_SQL.EXECUTE(cur_hdl);
    IF (DBMS_SQL.FETCH_ROWS(cur_hdl) <> 0) THEN
   -- dbms_output.put_line(' row fetched ');
      DBMS_SQL.COLUMN_VALUE(cur_hdl,1,l_result);
   --dbms_output.put_line(' value is '||to_char(l_result));
    END IF;
    -- close cursor
    dbms_sql.close_cursor(cur_hdl);
    x_result := l_result;
  EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE = -1476 AND NOT pexp_test) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD','GMD_EVAL_DIVIDE_BY_ZERO');
      FND_MSG_PUB.ADD;
    ELSIF(SQLCODE <> -1476) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_EXPRESSION');
      FND_MSG_PUB.ADD;
    ELSE
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    --dbms_output.put_line(SQLCODE||'-'||SQLERRM);
  END execute_exp;

  PROCEDURE variable_value(pvar_name   IN VARCHAR2,
                           pvar_value  IN NUMBER,
                           p_exptab IN OUT NOCOPY  exptab,
                           x_return_Status OUT NOCOPY VARCHAR2) IS
    l_var_assign NUMBER := 0;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.INITIALIZE;

    -- B3199585
    -- IF (pvar_name IS NULL OR pvar_value IS NULL) THEN
    --   x_return_status := FND_API.G_RET_STS_ERROR;
    --   FND_MESSAGE.SET_NAME('GMD','GMD_NO_PARAMETER_VALUES');
    --   FND_MESSAGE.SET_TOKEN('VARNAME',pvar_name);
    --   FND_MSG_PUB.ADD;
    --   RETURN;
    -- END IF;

    IF (p_exptab.count = 0) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD','GMD_NO_EXPRESSION');
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;

    FOR i in 1..p_exptab.count LOOP
      IF (p_exptab(i).pvalue_type = 'O') THEN
        IF (p_exptab(i).poperand = pvar_name) THEN
          p_exptab(i).pvalue := pvar_value;
          l_var_assign := l_var_assign + 1;
        END IF;
      END IF;
    END LOOP;
    IF (l_var_assign = 0) THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_VARIABLE');
      FND_MESSAGE.SET_TOKEN('VARNAME',pvar_name);
      FND_MSG_PUB.ADD;
      x_return_Status := FND_API.G_RET_STS_ERROR;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END variable_value;

END GMD_UTILITY_PKG;

/
