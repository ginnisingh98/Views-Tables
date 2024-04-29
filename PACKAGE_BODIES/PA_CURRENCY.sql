--------------------------------------------------------
--  DDL for Package Body PA_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CURRENCY" AS
/* $Header: PAXGCURB.pls 120.5 2008/03/17 13:58:29 rvelusam ship $ */

-- ==========================================================================
-- = PRIVATE PROCEDURE Get_Currency_Info
-- ==========================================================================

  PROCEDURE Get_Currency_Info (l_curr_code out NOCOPY varchar2,
                               l_mau       out NOCOPY number,
                               l_sp        out NOCOPY number,
                               l_ep        out NOCOPY number) IS
  BEGIN

  IF G_curr_code IS NULL THEN

   If G_org_id is NULL then
    SELECT FC.Currency_Code,
           FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
      INTO l_curr_code,
           l_mau,
           l_sp,
           l_ep
      FROM FND_CURRENCIES FC,
           GL_SETS_OF_BOOKS GB,
           PA_IMPLEMENTATIONS IMP
     WHERE FC.Currency_Code =
               DECODE(IMP.Set_Of_Books_ID, Null, Null,GB.CURRENCY_CODE)
       AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID;
   Else
     SELECT FC.Currency_Code,
           FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
      INTO l_curr_code,
           l_mau,
           l_sp,
           l_ep
      FROM FND_CURRENCIES FC,
           GL_SETS_OF_BOOKS GB,
           PA_IMPLEMENTATIONS_ALL IMP
     WHERE FC.Currency_Code =
               DECODE(IMP.Set_Of_Books_ID, Null, Null,GB.CURRENCY_CODE)
       AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID
       AND IMP.org_id = G_org_id;
   END IF;

  ELSE

     l_curr_code := G_curr_code;
     l_mau       := G_mau;
     l_sp        := G_sp;
     l_ep        := G_ep;

   END IF;

 EXCEPTION

   WHEN OTHERS THEN
        l_curr_code := Null;
        l_mau := Null;
        l_sp := Null;
        l_ep := Null;
        RAISE;

END Get_Currency_Info;

-- ===========================================================================
--  PROCEDURE Set_Currency_Info
-- ===========================================================================

  PROCEDURE Set_Currency_Info IS
  BEGIN

    SELECT FC.Currency_Code,
           FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
      INTO G_curr_code,
           G_mau,
           G_sp,
           G_ep
      FROM FND_CURRENCIES FC,
           GL_SETS_OF_BOOKS GB,
           PA_IMPLEMENTATIONS IMP
     WHERE FC.Currency_Code =
               DECODE(IMP.Set_Of_Books_ID, Null, Null,GB.CURRENCY_CODE)
       AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID;

  EXCEPTION
   WHEN OTHERS THEN RAISE;

  END Set_Currency_Info;

-- ==========================================================================
-- = PRIVATE PROCEDURE Get_Trans_Currency_Info
-- ==========================================================================
  PROCEDURE Get_Trans_Currency_Info (l_curr_code IN varchar2,
                                     l_mau       out NOCOPY number,
                                     l_sp        out NOCOPY number,
                                     l_ep        out NOCOPY number) IS
  BEGIN

   /* Modified for the bug 4292770 (Basebug# 3848201) */
   /* Bug#4428414 */
    IF (nvl(G_curr_code,'*') <> l_curr_code) THEN
      SELECT FC.Minimum_Accountable_Unit,
             FC.Precision,
             FC.Extended_Precision
        INTO l_mau,
             l_sp,
             l_ep
        FROM FND_CURRENCIES FC
       WHERE FC.Currency_Code = l_curr_code;
    ELSIF G_curr_code IS NOT NULL THEN
           l_mau := G_mau;
           l_sp  := G_sp;
           l_ep  := G_ep;
    END IF;


  Exception
     When Others then
          l_mau := Null;
          l_sp := Null;
          l_ep := Null;
          Raise;

  END Get_Trans_Currency_Info;
-- ==========================================================================
-- = FUNCTION  get_currency_code
-- ==========================================================================

  FUNCTION get_currency_code RETURN VARCHAR2
  IS
     l_curr_code     fnd_currencies.currency_code%TYPE;
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;
  BEGIN
     Get_Currency_Info(l_curr_code, l_mau, l_sp, l_ep);
     return(l_curr_code);
  END get_currency_code;

-- ==========================================================================
-- = FUNCTION  round_currency_amt
-- ==========================================================================

  FUNCTION round_currency_amt ( X_amount  IN NUMBER ) RETURN NUMBER
  IS
     l_curr_code     fnd_currencies.currency_code%TYPE;
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;
  BEGIN

    Get_Currency_Info(l_curr_code, l_mau, l_sp, l_ep);

    IF l_mau IS NOT NULL THEN

       IF l_mau < 0.00001 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount/l_mau) * l_mau );
       END IF;

    ELSIF l_sp IS NOT NULL THEN

       IF l_sp > 5 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount, l_sp));
       END IF;

    ELSE

         RETURN( round(X_Amount, 5));

    END IF;

  END round_currency_amt;
-- ==========================================================================
-- = FUNCTION  round_trans_currency_amt
-- ==========================================================================

  FUNCTION round_trans_currency_amt ( X_amount  IN NUMBER,
				      X_Curr_Code IN VARCHAR2 ) RETURN NUMBER
  IS
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;
  BEGIN

    Get_Trans_Currency_Info(X_curr_code, l_mau, l_sp, l_ep);

    IF l_mau IS NOT NULL THEN

       IF l_mau < 0.00001 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount/l_mau) * l_mau );
       END IF;

    ELSIF l_sp IS NOT NULL THEN

       IF l_sp > 5 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount, l_sp));
       END IF;

    ELSE

         RETURN( round(X_Amount, 5));

    END IF;

  END round_trans_currency_amt;


-- ==========================================================================
-- = FUNCTION  currency_fmt_mask
-- ==========================================================================

  FUNCTION currency_fmt_mask(X_length IN NUMBER) RETURN VARCHAR2
  IS
     l_curr_code     fnd_currencies.currency_code%TYPE;
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;

     fmt_mask VARCHAR2(80);
     len      number;
  BEGIN

--  Maximum Length Allowed is 80 characters

    IF X_length > 80 THEN
       return(NULL);
    END IF;

    Get_Currency_Info(l_curr_code, l_mau, l_sp, l_ep);

    len := 0;
    fmt_mask := NULL;

    IF l_sp > 0 THEN
/**Bug#1142122
 **The mask dot (.) was replaced with 'D' to handle grouping and decimal delimiters accordingly.
**/
       fmt_mask := 'D';
       len := 1;

      FOR counter in 1..l_sp LOOP
        fmt_mask := fmt_mask || '9';
        len := len + 1;
      END LOOP;

--    Length of the field should at least be equal to std precision
      IF len > X_Length THEN
        return (NULL);
      END IF;

    ELSE
       fmt_mask := '9';
    END IF;

-- X-length - 1 : for the minus sign, in case of negative values
    return(lpad(fmt_mask, X_length - 1, '9'));


  END currency_fmt_mask;

-- ==========================================================================
-- = FUNCTION  rpt_currency_fmt_mask
-- ==========================================================================

  FUNCTION rpt_currency_fmt_mask(X_org_id IN NUMBER, X_length IN NUMBER) RETURN VARCHAR2
  IS
     l_curr_code     fnd_currencies.currency_code%TYPE;
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;

     fmt_mask VARCHAR2(80);
     len      number;
  BEGIN

--  Maximum Length Allowed is 80 characters

    IF X_length > 80 THEN
       return(NULL);
    END IF;

    SELECT FC.Currency_Code,
           FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
      INTO l_curr_code,
           l_mau,
           l_sp,
           l_ep
      FROM FND_CURRENCIES FC,
           GL_SETS_OF_BOOKS GB,
           PA_IMPLEMENTATIONS_ALL IMP
     WHERE FC.Currency_Code =
               DECODE(IMP.Set_Of_Books_ID, Null, Null,GB.CURRENCY_CODE)
       AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID
       --AND nvl(IMP.Org_ID,-99) = nvl(X_Org_ID, -99);
	  AND IMP.org_id = nvl(X_Org_ID, -99);

    len := 0;
    fmt_mask := NULL;

    IF l_sp > 0 THEN
       fmt_mask := '.';
       len := 1;

      FOR counter in 1..l_sp LOOP
        fmt_mask := fmt_mask || '9';
        len := len + 1;
      END LOOP;

--    Length of the field should at least be equal to std precision
      IF len > X_Length THEN
        return (NULL);
      END IF;

    ELSE
       fmt_mask := '9';
    END IF;

-- X-length - 1 : for the minus sign, in case of negative values
    return(lpad(fmt_mask, X_length - 1, '9'));


  END rpt_currency_fmt_mask;


 FUNCTION trans_currency_fmt_mask(X_Curr_Code IN VARCHAR2,
                                  X_length IN NUMBER) RETURN VARCHAR2
  IS
     l_curr_code     fnd_currencies.currency_code%TYPE;
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;

     fmt_mask VARCHAR2(80);
     len      number;
  BEGIN

--  Maximum Length Allowed is 80 characters

    IF X_length > 80 THEN
       return(NULL);
    END IF;

    Get_Trans_Currency_Info(X_Curr_Code, l_mau, l_sp, l_ep);

    len := 0;
    fmt_mask := NULL;

    IF l_sp > 0 THEN
       fmt_mask := '.';
       len := 1;

      FOR counter in 1..l_sp LOOP
        fmt_mask := fmt_mask || '9';
        len := len + 1;
      END LOOP;

--    Length of the field should at least be equal to std precision
      IF len > X_Length THEN
        return (NULL);
      END IF;

    ELSE
       fmt_mask := '9';
    END IF;

-- X-length - 1 : for the minus sign, in case of negative values
    return(lpad(fmt_mask, X_length - 1, '9'));


  END trans_currency_fmt_mask;

  FUNCTION get_mau ( X_Curr_Code IN VARCHAR2 ) RETURN VARCHAR2
  IS
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;
     l_div           NUMBER;
  BEGIN

    IF (G_proj_curr_code IS NULL) OR
       (G_proj_curr_code <> X_curr_code) THEN

       G_proj_curr_code := X_curr_code;
       Get_Trans_Currency_Info(X_curr_code, l_mau, l_sp, l_ep);

       IF l_mau IS NOT NULL THEN
           G_mau_chr := to_char(l_mau);
           RETURN( G_mau_chr );
       ELSIF l_sp IS NOT NULL THEN
          l_div := 1;
          FOR counter in 1..l_sp LOOP
            l_div := l_div* 10;
          END LOOP;
          G_mau_chr := to_char(1/l_div);
          return(G_mau_chr);
       ELSE
          G_mau_chr := '0.01';
          return(G_mau_chr);
       END IF;
    ELSE
         return(G_mau_chr);
    END IF;

  END get_mau;


  /*
    --Pa-K Changes: Transaction Import Enhancements
    --Added for better performance as the existing Round_Currency_Amt that calls
    --Get_Currency_Code does not use caching. Changing the existing functions
    --will result in removing the PRAGMA constraint that has a lot of impact on
    --other functions.
    --Duplicated 4 functions, new ones are:
    --Get_Currency_Info1, round_currency_amt1, Get_Trans_Currency_Info1 and
    --round_currency_amt1
    --These functions will be removed when the division wide the PRAGMA RESTRICT
    --constraint will be removed from all functions.
    --Till then any changes to the above functions will have to be made here also.
  */

  PROCEDURE Get_Currency_Info1 (l_curr_code out nocopy varchar2,
                                l_mau       out nocopy number,
                                l_sp        out nocopy number,
                                l_ep        out nocopy number) IS
  BEGIN

  --Bug 3112441
  --IF G_CurrCode1 <> l_curr_code THEN
  IF G_CurrCode1 IS NULL THEN

    SELECT FC.Currency_Code,
           FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
      INTO l_curr_code,
           l_mau,
           l_sp,
           l_ep
      FROM FND_CURRENCIES FC,
           GL_SETS_OF_BOOKS GB,
           PA_IMPLEMENTATIONS IMP
     WHERE FC.Currency_Code =
               DECODE(IMP.Set_Of_Books_ID, Null, Null,GB.CURRENCY_CODE)
       AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID;

     G_CurrCode1 := l_curr_code;
     G_Mau1       := l_mau;
     G_Sp1        := l_sp;
     G_Ep1        := l_ep;

  ELSE

     l_curr_code := G_CurrCode1;
     l_mau       := G_mau1;
     l_sp        := G_sp1;
     l_ep        := G_ep1;

  END IF;

 EXCEPTION

   WHEN OTHERS THEN
        l_curr_code := Null;
        l_mau := Null;
        l_sp := Null;
        l_ep := Null;
        RAISE;

END Get_Currency_Info1;

  FUNCTION round_currency_amt1 ( X_amount  IN NUMBER ) RETURN NUMBER
  IS
     l_curr_code     fnd_currencies.currency_code%TYPE;
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;
  BEGIN

    Get_Currency_Info1(l_curr_code, l_mau, l_sp, l_ep);

    IF l_mau IS NOT NULL THEN

       IF l_mau < 0.00001 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount/l_mau) * l_mau );
       END IF;

    ELSIF l_sp IS NOT NULL THEN

       IF l_sp > 5 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount, l_sp));
       END IF;

    ELSE

         RETURN( round(X_Amount, 5));

    END IF;

  END round_currency_amt1;

  PROCEDURE Get_Trans_Currency_Info1 (l_curr_code IN varchar2,
                                      l_mau       out NOCOPY number,
                                      l_sp        out NOCOPY number,
                                      l_ep        out NOCOPY number) IS
  BEGIN

    If G_TransCurrCode = l_curr_code Then

       l_mau       := G_TransMau;
       l_sp        := G_TransSp;
       l_ep        := G_TransEp;

    Else

       SELECT FC.Minimum_Accountable_Unit,
              FC.Precision,
              FC.Extended_Precision
         INTO l_mau,
              l_sp,
              l_ep
         FROM FND_CURRENCIES FC
        WHERE FC.Currency_Code = l_curr_code;

        G_TransCurrCode := l_curr_code;
        G_TransMau      := l_mau;
        G_TransSp       := l_sp;
        G_TransEp       := l_ep;

    End If;

  Exception
       When Others Then
            l_mau := Null;
            l_sp := Null;
            l_ep := Null;
            Raise;

  END Get_Trans_Currency_Info1;

  FUNCTION round_trans_currency_amt1 ( X_amount  IN NUMBER,
                                      X_Curr_Code IN VARCHAR2 ) RETURN NUMBER
  IS
     l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
     l_sp            fnd_currencies.precision%TYPE;
     l_ep            fnd_currencies.extended_precision%TYPE;
  BEGIN

    Get_Trans_Currency_Info1(X_curr_code, l_mau, l_sp, l_ep);

    IF l_mau IS NOT NULL THEN

       IF l_mau < 0.00001 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount/l_mau) * l_mau );
       END IF;

    ELSIF l_sp IS NOT NULL THEN

       IF l_sp > 5 THEN
         RETURN( round(X_Amount, 5));
       ELSE
         RETURN( round(X_Amount, l_sp));
       END IF;

    ELSE

         RETURN( round(X_Amount, 5));

    END IF;

  END round_trans_currency_amt1;

  FUNCTION round_currency_amt_blk ( p_amount_tab   PA_PLSQL_DATATYPES.NumTabTyp
                                   ,p_currency_tab PA_PLSQL_DATATYPES.Char30TabTyp
                                  )
  RETURN PA_PLSQL_DATATYPES.NumTabTyp
  IS
       x_amount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
       l_prev_curr_code VARCHAR2(30);

       l_mau            fnd_currencies.minimum_accountable_unit%TYPE;
       l_sp             fnd_currencies.precision%TYPE;
       l_ep             fnd_currencies.extended_precision%TYPE;
  BEGIN
      FOR i IN p_amount_tab.FIRST .. p_amount_tab.LAST
      LOOP
          IF ( l_prev_curr_code IS NULL OR l_prev_curr_code <> p_currency_tab(i) )
          THEN
              PA_CURRENCY.GET_TRANS_CURRENCY_INFO1(p_currency_tab(i), l_mau, l_sp, l_ep);
              l_prev_curr_code := p_currency_tab(i);
          END IF;

          IF ( l_mau IS NOT NULL )
          THEN
              IF l_mau < 0.00001
              THEN
                  x_amount_tab(i):= ROUND(p_amount_tab(i), 5);
              ELSE
                  x_amount_tab(i):= ROUND(p_amount_tab(i)/l_mau) * l_mau;
              END IF;
          ELSIF ( l_sp IS NOT NULL )
          THEN
              IF ( l_sp > 5 )
              THEN
                  x_amount_tab(i):= ROUND(p_amount_tab(i), 5);
              ELSE
                  x_amount_tab(i):= ROUND(p_amount_tab(i), l_sp);
              END IF;
          ELSE
              x_amount_tab(i):= ROUND(p_amount_tab(i), 5);
          END IF;
      END LOOP;
      RETURN x_amount_tab;
  END round_currency_amt_blk;

  FUNCTION round_currency_amt_nested_blk ( p_amount_tbl   SYSTEM.pa_num_tbl_type         DEFAULT SYSTEM.pa_num_tbl_type()
                                          ,p_currency_tbl SYSTEM.pa_varchar2_30_tbl_type DEFAULT SYSTEM.pa_varchar2_30_tbl_type()
                                         ) RETURN SYSTEM.pa_num_tbl_type
  IS
      l_amount_tab          PA_PLSQL_DATATYPES.NumTabTyp;
      l_output_amount_tab   PA_PLSQL_DATATYPES.NumTabTyp;
      l_currency_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

      l_output_amount_tbl   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  BEGIN
       FOR i IN p_amount_tbl.FIRST .. p_amount_tbl.LAST
       LOOP
           l_amount_tab(i) := p_amount_tbl(i);
           l_currency_tab(i) := p_currency_tbl(i);
       END LOOP;
       l_output_amount_tab := PA_CURRENCY.round_currency_amt_blk( p_amount_tab    => l_amount_tab
                                                                 ,p_currency_tab  => l_currency_tab
                                                                );
       FOR i IN l_output_amount_tab.FIRST .. l_output_amount_tab.LAST
       LOOP
           l_output_amount_tbl.EXTEND;
           l_output_amount_tbl(i) := l_output_amount_tab(i);
       END LOOP;
       RETURN l_output_amount_tbl;
  END round_currency_amt_nested_blk;
END pa_currency;

/
