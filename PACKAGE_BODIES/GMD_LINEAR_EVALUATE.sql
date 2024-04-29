--------------------------------------------------------
--  DDL for Package Body GMD_LINEAR_EVALUATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LINEAR_EVALUATE" AS
/* $Header: GMDLPEXB.pls 115.1 2004/02/25 17:10:29 nsrivast noship $ */

/* Holds the number of columns in the matrix */
l_col	NUMBER(5);

--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward decl.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST,END

/*======================================================================
--  PROCEDURE :
--   Substitute
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--    p_mx	 Matrix (Required).
--    p_n  	 Number of equations (Required).
--  SYNOPSIS:
--    sbustitute(X_matrix, P_count);
--
--  This procedure calls:
--
--===================================================================== */

PROCEDURE Substitute (P_mx 	IN OUT NOCOPY   Matrix
                     ,P_n 	IN           	Number
                     ,x_status  OUT NOCOPY   	VARCHAR2) IS
  X_sum NUMBER;
  i	BINARY_INTEGER;
BEGIN
  /*Initialize return status to success */
  X_status := FND_API.g_ret_sts_success;

  IF l_debug = 'Y' THEN
    gmd_debug.put_line('In Substitute routine: Count:'||P_n);
  END IF;
  /*IF P_mx(P_n)(P_n) = 0 THEN*/
  IF P_mx(l_col*(P_n-1) + P_n) = 0 THEN
    IF l_debug = 'Y' THEN
      gmd_debug.put_line(' Cannot evaluate as the divisor is zero at i:'||P_n||' j:'||P_n);
    END IF;
    GMD_API_GRP.log_message('GMD_NO_SOLUTION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  /*P_mx(P_n)(P_n + 1) := ROUND(P_mx(P_n)(P_n+1)/P_mx(P_n)(P_n), 9);*/
  P_mx(l_col*(P_n-1)+ P_n+1) := ROUND(P_mx(l_col*(P_n-1) + P_n+1)/P_mx(l_col*(P_n-1) + P_n), 9);
  IF l_debug = 'Y' THEN
    gmd_debug.put_line(' Last row value:'||P_mx(l_col*(P_n-1) + P_n+1));
  END IF;
  i := P_n - 1;
  WHILE i > 0 LOOP
    X_sum := 0;
    FOR j IN i+1..P_n LOOP
      IF l_debug = 'Y' THEN
        gmd_debug.put_line('i:'||i||' j:'||j||' Sum:'||X_sum);
      END IF;
      /*X_sum := X_sum + P_mx(i)(j) * P_mx(j)(P_n+1);*/
      X_sum := X_sum + P_mx(l_col*(i-1) + j) * P_mx(l_col*(j-1) + P_n+1);
    END LOOP;
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Out of Loop: Sum:'||X_sum||' '||i||'th row:'||p_mx(l_col*(i-1) + i));
    END IF;

    /*IF P_mx(i)(i) = 0 THEN*/
    IF P_mx(l_col*(i-1) + i) = 0 THEN
      IF l_debug = 'Y' THEN
        gmd_debug.put_line(' Cannot evaluate as the divisor is zero at i:'||i||' j:'||i);
      END IF;
      GMD_API_GRP.log_message('GMD_NO_SOLUTION');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    P_mx(l_col*(i-1)+ P_n+1) := ROUND((P_mx(l_col*(i-1)+ P_n+1) - X_sum) / P_mx(l_col*(i-1) + i), 9);
    i := i - 1;
  END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF  l_debug = 'Y' THEN
      gmd_debug.put_line('Error in Substitute');
    END IF;
    X_status := FND_API.g_ret_sts_error;
  WHEN OTHERS THEN
    X_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Add_Exc_Msg('GMD_LINEAR_EVALUATE', 'SUBSTITUTE');
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Exception:'||sqlerrm);
    END IF;
END Substitute;


/*======================================================================
--  PROCEDURE :
--   Calc_Mags
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--    p_mx	 Matrix (Required).
--    p_count  	 Number of equations (Required).
--  SYNOPSIS:
--    Calc_Mags(X_matrix, P_count, X_row);
--
--  This procedure calls:
--
--===================================================================== */
PROCEDURE Calc_Mags (P_Mx 	IN  		Matrix
                    ,P_count 	IN  		Number
                    ,X_row 	OUT NOCOPY	Row
                    ,x_status  	OUT NOCOPY   	VARCHAR2) IS
BEGIN
  /*Initialize return status to success */
  X_status := FND_API.g_ret_sts_success;

  IF l_debug = 'Y' THEN
    gmd_debug.put_line('In Calc Mags Routine: Count:'||P_count);
  END IF;
  FOR i IN 1..P_Count LOOP
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('i:'||i||' Abs Value:'||ABS(P_mx(l_col*(i-1)+ 1)));
    END IF;
    X_row(i) := ABS(P_Mx(l_col*(i-1)+ 1));
    FOR j IN 1..P_Count LOOP
      IF l_debug = 'Y' THEN
        gmd_debug.put_line('j:'||j||' Abs Value:'||ABS(P_mx(l_col*(i-1)+ j))||' Row Value:'||X_row(i));
      END IF;
      /*IF ABS(P_Mx(i)(j)) > X_row(i) THEN*/
      IF ABS(P_Mx(l_col*(i-1)+ j)) > X_row(i) THEN
        /*X_row(i) := ABS(P_Mx(i)(j));*/
        X_row(i) := ABS(P_Mx(l_col*(i-1)+ j));
      END IF;
    END LOOP;
    X_row(i) := 1/X_row(i);
  END LOOP;
  IF l_debug = 'Y' THEN
    gmd_debug.put_line(' Arry out of Calc Mags...');
    FOR i IN 1..X_row.COUNT LOOP
      gmd_debug.put_line(i||':'||X_row(i));
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    X_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Add_Exc_Msg('GMD_LINEAR_EVALUATE', 'CALC_MAGS');
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Exception:'||sqlerrm);
    END IF;
END calc_mags;

/*======================================================================
--  PROCEDURE :
--   Find_Max
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--    p_mx	 Matrix (Required).
--    p_n  	 Number of equations (Required).
--  SYNOPSIS:
--    Find_Max(X_matrix, P_row, P_current, P_count);
--
--  This procedure calls:
--
--===================================================================== */
PROCEDURE Find_Max (P_mx 	IN 		Matrix
                   ,P_s 	IN 		row
                   ,P_j 	IN		NUMBER
                   ,P_n 	IN 		NUMBER
                   ,X_result	OUT NOCOPY	Row
                   ,X_row	OUT NOCOPY	NUMBER
                   ,x_status  	OUT NOCOPY   	VARCHAR2)  IS
  i NUMBER;
  X_big NUMBER;
  X_single NUMBER;
  X_current NUMBER;
BEGIN
  /*Initialize return status to success */
  X_status := FND_API.g_ret_sts_success;

  IF l_debug = 'Y' THEN
    gmd_debug.put_line('In Find Max routine : P_j:'||P_j||' n:'||P_n);
  END IF;
  X_current := P_j;
  /*X_big := ABS(P_mx(X_current)(1) * P_s(1));*/
  X_big := ABS(P_mx(l_col*(X_current-1) + 1) * P_s(1));
  IF l_debug = 'Y' THEN
    gmd_debug.put_line('Big:'||X_big);
  END IF;
  /*X_result := P_mx(X_current);*/
  FOR k IN 1..l_col LOOP
    X_result(k) := P_mx(l_col*(X_current-1) + k);
  END LOOP;

  X_row := X_current;
  i:=1;
  WHILE i <= P_n LOOP
    X_current := X_current + 1;
    /*IF ABS(P_mx(X_current)(1) * P_s(i)) > X_big THEN*/
    IF ABS(P_mx(l_col*(X_current-1) + 1) * P_s(i)) > X_big THEN
      /*X_big := ABS(P_mx(X_current)(1) * P_s(i));*/
      X_big := ABS(P_mx(l_col*(X_current-1) + 1) * P_s(i));

      /*X_result := P_mx(X_current);*/
      FOR k IN 1..l_col LOOP
        X_result(k) := P_mx(l_col*(X_current-1) + k);
      END LOOP;

      X_row := X_current;
    END IF;
    i := i + 1;
  END LOOP;
  IF l_debug = 'Y' THEN
    gmd_debug.put_line('Find Max Result:');
    FOR j IN 1..X_result.COUNT LOOP
      gmd_debug.put_line(j||':'||X_result(j));
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    X_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Add_Exc_Msg('GMD_LINEAR_EVALUATE', 'FIND_MAX');
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Exception:'||sqlerrm);
    END IF;
END Find_Max;

/*======================================================================
--  PROCEDURE :
--   Gauss_Pivot
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--    p_mx	 Matrix (Required).
--    p_n  	 Number of equations (Required).
--  SYNOPSIS:
--    Gauss_Pivot(X_matrix, P_row, P_current, P_count);
--
--  This procedure calls:
--
--===================================================================== */
PROCEDURE Gauss_Pivot(P_mx 		IN OUT NOCOPY	Matrix
                     ,P_s 		IN 		row
                     ,P_current 	IN 		NUMBER
                     ,P_n 		IN 		NUMBER
                     ,x_status  	OUT NOCOPY   	VARCHAR2) IS
   i       INTEGER;
   X_big   NUMBER;
   X_dummy NUMBER;
   X_pivot Row;
   X_n	NUMBER;
   X_row NUMBER;
BEGIN
  /*Initialize return status to success */
  X_status := FND_API.g_ret_sts_success;

  IF l_debug = 'Y' THEN
    gmd_debug.put_line('In Gauss_Pivot routine: P_current:'||p_current);
  END IF;
  Find_Max(P_mx 	=> P_mx
          ,P_s 		=> P_s
          ,P_j 		=> P_current
          ,P_n 		=> P_n - P_current
          ,X_result  	=> X_pivot
          ,X_row    	=> X_row
          ,X_status	=> X_status);
  IF X_status <> FND_API.g_ret_sts_success THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  i:=1;

  WHILE i <= P_n+1 LOOP
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('i:'||i||' Mxi:'||p_mx(l_col*(p_current-1) + i));
    END IF;
    /*X_dummy := P_mx(p_current)(i);*/
    X_dummy := P_mx(l_col*(p_current-1) + i);

    /*P_mx(P_current)(i) := X_pivot(i);*/
    P_mx(l_col*(P_current-1) + i) := X_pivot(i);

    /*P_mx(X_row)(i) := X_dummy;*/
    P_mx(l_col*(X_row-1) + i) := X_dummy;
    i := i + 1;
  END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF  l_debug = 'Y' THEN
      gmd_debug.put_line('Error in Gauss Pivot');
    END IF;
    X_status := FND_API.g_ret_sts_error;
  WHEN OTHERS THEN
    X_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Add_Exc_Msg('GMD_LINEAR_EVALUATE', 'GAUSS_PIVOT');
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Exception:'||sqlerrm);
    END IF;
END Gauss_Pivot;

/*======================================================================
--  PROCEDURE :
--   Eliminate
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--    p_mx	 Matrix (Required).
--    p_n  	 Number of equations (Required).
--  SYNOPSIS:
--    Eliminate(X_matrix, P_row, P_count);
--
--  This procedure calls:
--
--===================================================================== */
PROCEDURE Eliminate (P_mx 	IN OUT NOCOPY	Matrix
                    ,P_s 	IN 		Row
                    ,P_n 	IN 		NUMBER
                    ,x_status  	OUT NOCOPY   	VARCHAR2) IS
  i	Integer;
  j	Integer;
  k	Integer;
  X_scale	NUMBER;
  X_divisor	NUMBER;
  X_mxj	Row;
  X_mxk	Row;
  l_debug_row	VARCHAR2(2000);
BEGIN
  /*Initialize return status to success */
  X_status := FND_API.g_ret_sts_success;

  IF l_debug = 'Y' THEN
    gmd_debug.put_line('In Eliminate: P_n'||P_n);
  END IF;
  k := 1;
  WHILE k < P_n LOOP
    Gauss_Pivot(P_mx 		=> P_mx
               ,P_s 		=> P_s
               ,P_current 	=> k
               ,P_n 		=> P_n
               ,X_status	=> X_status);
    IF X_status <> FND_API.g_ret_sts_success THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug = 'Y' THEN
      gmd_debug.put_line(' After Pivoting for :'||k);
      FOR m IN 1..P_n LOOP
        l_debug_row := '(';
        FOR n IN 1..p_n+1 LOOP
          l_debug_row := l_debug_row||p_mx(l_col*(m-1) + n)||',';
        END LOOP;
        gmd_debug.put_line(l_debug_row||')');
      END LOOP;
    END IF;

    /*X_mxk := P_mx(k);  -- Get row k*/
    FOR l IN 1..l_col LOOP
      X_mxk(l) := P_mx(l_col*(k-1) + l);
    END LOOP;


    j:=k+1;
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Row for k:'||k||' j:'||j);
      l_debug_row := '(';
      FOR m IN 1..P_n+1 LOOP
        l_debug_row := l_debug_row||X_mxk(m)||',';
      END LOOP;
      gmd_debug.put_line(l_debug_row||')');
    END IF;
    IF X_mxk(k) = 0 THEN
      IF l_debug = 'Y' THEN
        gmd_debug.put_line(' Cannot evaluate as the divisor is zero at i:'||k||' j:'||k);
      END IF;
      GMD_API_GRP.log_message('GMD_NO_SOLUTION');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    X_divisor := 1/X_mxk(k);
    WHILE j <= P_n LOOP

      /*X_mxj := P_mx(j);  -- Get row j*/
      FOR l IN 1..l_col LOOP
        X_mxj(l) := P_mx(l_col*(j-1) + l);
      END LOOP;

      X_scale := X_mxj(k) * X_divisor;

      IF l_debug = 'Y' THEN
        gmd_debug.put_line('Row for J:'||j||' Scale:'||X_scale);
        l_debug_row := '(';
        FOR m IN 1..P_n+1 LOOP
          l_debug_row := l_debug_row||X_mxj(m)||',';
        END LOOP;
        gmd_debug.put_line(l_debug_row||')');
      END IF;

      i := k;
      WHILE i <= P_n+1 LOOP
        X_mxj(i) := X_mxj(i) - (X_Scale * X_mxk(i));
        i := i + 1;
      END LOOP;

      /*P_mx(j) := X_mxj; */
      FOR l IN 1..l_col LOOP
        P_mx(l_col*(j-1) + l) := X_mxj(l);
      END LOOP;

      j := j + 1;
    END LOOP;
    IF l_debug = 'Y' THEN
      gmd_debug.put_line(' After elimination for :'||k);
      FOR i IN 1..P_n LOOP
        l_debug_row := '(';
        FOR j IN 1..p_n+1 LOOP
          l_debug_row := l_debug_row||p_mx(l_col*(i-1)+ j)||',';
        END LOOP;
        gmd_debug.put_line(l_debug_row||')');
      END LOOP;
    END IF;
    k := k + 1;
  END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    X_status := FND_API.g_ret_sts_error;
    IF  l_debug = 'Y' THEN
      gmd_debug.put_line('Error in Eliminate');
    END IF;
  WHEN OTHERS THEN
    X_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Add_Exc_Msg('GMD_LINEAR_EVALUATE', 'ELIMINATE');
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Exception:'||sqlerrm);
    END IF;
END Eliminate;

/*======================================================================
--  PROCEDURE :
--   Gauss
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--    p_mx	 Matrix (Required).
--    p_n  	 Number of equations (Required).
--  SYNOPSIS:
--    Gauss(X_matrix, P_row, P_count);
--
--  This procedure calls:
--
--===================================================================== */
PROCEDURE Gauss (P_mx 		IN  		Matrix
                ,P_n 		IN  		NUMBER
                ,X_result 	OUT NOCOPY	Row
                ,x_status  	OUT NOCOPY   	VARCHAR2) IS
  X_mags Row;
  X_matrix Matrix;
BEGIN
  /*Initialize return status to success */
  X_status := FND_API.g_ret_sts_success;
  /* Let us store the number of columns in the matrix */
  l_col := P_n + 1;

  X_matrix := P_mx;
  Calc_Mags (P_mx 	=> X_matrix,
             P_count 	=> P_n,
             X_row 	=> X_mags,
             X_status	=> X_status);
  IF X_status <> FND_API.g_ret_sts_success THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  Eliminate (P_mx 	=> X_matrix,
             P_s 	=> X_mags,
             P_n 	=> P_n,
             X_status	=> X_status);
  IF X_status <> FND_API.g_ret_sts_success THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  Substitute (P_mx 	=> X_matrix,
              P_n 	=> P_n,
              X_status	=> X_status);
  IF X_status <> FND_API.g_ret_sts_success THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  FOR i IN 1..P_n LOOP
    /*X_result(i) := X_matrix(i)(P_n+1);*/
    X_result(i) := X_matrix(l_col*(i-1) + P_n+1);
  END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    X_status := FND_API.g_ret_sts_error;
    IF  l_debug = 'Y' THEN
      gmd_debug.put_line('Error in Gauss');
    END IF;
  WHEN OTHERS THEN
    IF l_debug = 'Y' THEN
      gmd_debug.put_line('Exception:'||sqlerrm);
    END IF;
    X_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Add_Exc_Msg('GMD_LINEAR_EVALUATE', 'GAUSS');
END Gauss;

/*======================================================================
--  PROCEDURE :
--   Test_Gauss
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    Test_Gauss;
--
--  This procedure calls:
--
--===================================================================== */
PROCEDURE Test_Gauss IS
  X_matrix Matrix;
  X_result Row;
  j BINARY_INTEGER := 0;
  X_status VARCHAR2(1);
BEGIN
  FND_PROFILE.PUT('AFLOG_ENABLED', 'Y');
  FND_PROFILE.PUT('AFLOG_LEVEL', 0);
  l_debug := 'Y';
  GMD_DEBUG.LOG_INITIALIZE(NULL);

  X_matrix(1) := 3;
  X_matrix(2) := -4;
  X_matrix(3) := 5;
  X_matrix(4) := -1;

  X_matrix(5) := -3;
  X_matrix(6) := 2;
  X_matrix(7) := 1;
  X_matrix(8) := 1;

  X_matrix(9) := 6;
  X_matrix(10) := 8;
  X_matrix(11) := -1;
  X_matrix(12) := 35;

  -- answers: 2, 3, 1*/

 /* X_matrix(1)(1) := 1;
  X_matrix(1)(2) := -1;
  X_matrix(1)(3) := 1;
  X_matrix(1)(4) := 0;

  X_matrix(2)(1) := 1;
  X_matrix(2)(2) := 0;
  X_matrix(2)(3) := -3;
  X_matrix(2)(4) := 10;

  X_matrix(3)(1) := 0;
  X_matrix(3)(2) := -2;
  X_matrix(3)(3) := -3;
  X_matrix(3)(4) := 20;

  -- answers: -40/11, -50/11, -10/11*/


/*  X_matrix(1)(1) := -0.072;
  X_matrix(1)(2) := 0.300;
  X_matrix(1)(3) := -0.210;
  X_matrix(1)(4) := 1.7667;
  --X_matrix(1)(5) := 100;

  X_matrix(2)(1) := 0.874;
  X_matrix(2)(2) := -0.267;
  X_matrix(2)(3) := 0.133;
  X_matrix(2)(4) := -1.7411;
  --X_matrix(2)(5) := 0;

  X_matrix(3)(1) := -0.501;
  X_matrix(3)(2) := -0.123;
  X_matrix(3)(3) := 0.125;
  X_matrix(3)(4) := -0.6046;
  --X_matrix(3)(5) := 0;


 /* X_matrix(4)(1) := 1;
  X_matrix(4)(2) := 1;
  X_matrix(4)(3) := 0;
  X_matrix(4)(4) := 1;
  X_matrix(4)(5) := 0;
  -- answers: 2, 3, 1*/

/*  X_matrix(1)(1) := 1;
  X_matrix(1)(2) := 1;
  X_matrix(1)(3) := 98;

  X_matrix(2)(1) := 1;
  X_matrix(2)(2) := -20;
  X_matrix(2)(3) := -10;*/

/*  X_matrix(1) := 0.2;
  X_matrix(2) := -15.5;
  X_matrix(3) := 4.5;
  X_matrix(4) := 0;

  X_matrix(5) :=1;
  X_matrix(6) := 1;
  X_matrix(7) := 1;
  X_matrix(8) := 100;

  X_matrix(9) := 0.3;
  X_matrix(10) := -26.5;
  X_matrix(11) := 8.5;
  X_matrix(12) := 0;*/

l_debug := 'N';
  Gauss(P_mx		=> X_matrix
       ,X_result	=> X_result
       ,P_n		=> 3
       ,X_status	=> X_status);
  IF X_status = FND_API.g_ret_sts_success THEN
    FOR i IN 1..3 LOOP
      gmd_debug.put_line(i||':'||X_result(i));
    END LOOP;
  END IF;
END Test_Gauss;

END GMD_LINEAR_EVALUATE;

/
