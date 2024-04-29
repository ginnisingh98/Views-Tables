--------------------------------------------------------
--  DDL for Package Body PA_MULTI_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MULTI_CURRENCY" AS
--$Header: PAXTMCTB.pls 120.3.12010000.2 2009/03/12 14:25:06 spasala ship $

P_DEBUG_MODE BOOLEAN     := pa_cc_utils.g_debug_mode;
------------------------------------------------------------------------------
-- Function pa_multi_currency.check_rate_date_code.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
FUNCTION check_rate_date_code
RETURN varchar2 IS

l_rate_date_code  VARCHAR2(1) := 'E';

BEGIN

  SELECT default_rate_date_code
  INTO   l_rate_date_code
  FROM   pa_implementations ;

  RETURN l_rate_date_code ;
END check_rate_date_code ;

------------------------------------------------------------------------------
-- Function pa_multi_currency.get_rate_type.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
FUNCTION get_rate_type
RETURN VARCHAR2 IS

l_rate_type      VARCHAR2(30);

BEGIN

  SELECT   default_rate_type
  INTO     l_rate_type
  FROM     pa_implementations ;

  RETURN  l_rate_type ;

  END get_rate_type ;

------------------------------------------------------------------------------
-- Function pa_multi_currency.get_acct_currency_code.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
FUNCTION get_acct_currency_code
RETURN varchar2 IS

l_acct_currency_code  VARCHAR2(15);

BEGIN

  l_acct_currency_code := PA_CURRENCY.get_currency_code;

  RETURN l_acct_currency_code ;

END get_acct_currency_code ;

------------------------------------------------------------------------------
-- Function pa_multi_currency.is_user_rate_type_allowed.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------

FUNCTION  is_user_rate_type_allowed (P_from_currency    VARCHAR2,
                                     P_to_currency      VARCHAR2,
                                     P_conversion_date  DATE )
RETURN VARCHAR2 IS

l_fixed_rate                     VARCHAR2(1) ;
l_allow_user_rate_type           VARCHAR2(1) ;
l_mesg                           VARCHAR2(30) ;
invalid_currency                 EXCEPTION ;

BEGIN
/* Calling GL API which returns 'Y'if a fixed rate exists */

l_fixed_rate := GL_CURRENCY_API.is_fixed_rate(  P_from_currency    ,
                                                P_to_currency      ,
                                                P_conversion_date  ) ;

/* The above API raises an INVALID_CURRENCY which is not handled here.
   It is passed on to the calling program */

IF   l_fixed_rate = 'Y' THEN
     l_allow_user_rate_type := 'N';

ELSE l_allow_user_rate_type := 'Y';

END IF ;

RETURN l_allow_user_rate_type ;

EXCEPTION
  WHEN others THEN
  RAISE ;

END is_user_rate_type_allowed ;

------------------------------------------------------------------------------
-- Function pa_multi_currency.convert_amount.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
PROCEDURE convert_amount (
                    P_from_currency         IN VARCHAR2,
		            P_to_currency           IN VARCHAR2,
		            P_conversion_date       IN OUT NOCOPY DATE ,
		            P_conversion_type       IN OUT NOCOPY VARCHAR2,
		            P_amount                IN NUMBER,
			        P_user_validate_flag    IN VARCHAR2 ,
			        P_handle_exception_flag IN VARCHAR2 ,
		            P_converted_amount      IN OUT NOCOPY NUMBER,
		            P_denominator           IN OUT NOCOPY NUMBER,
		            P_numerator             IN OUT NOCOPY NUMBER,
		            P_rate                  IN OUT NOCOPY NUMBER,
                    X_status                OUT NOCOPY VARCHAR2)  IS

V_allow_user_rate_type   VARCHAR2(1) ;
V_converted_amount       NUMBER ;
V_numerator	         NUMBER ;
V_denominator            NUMBER ;
V_rate			 NUMBER ;

/* Added for Bug2419636 */
V_factor                 NUMBER ;
V_amount                 NUMBER ;

l_call_closest_flag varchar2(1) := 'F';


BEGIN

X_status := null ;
P_conversion_date := NVL(P_conversion_date, sysdate);

IF (P_from_currency = P_to_currency) THEN

    P_conversion_date := null;
    P_conversion_type := null;
    P_rate            := null;
    P_converted_amount:= P_amount;
    RETURN;

END IF;

/* Added for Bug2419636 as sometimes  the reurned amount from the GL_CURRENCY_API.convert_amount_sql call is actually
 -1 or -2 and it is being treated as an error so the fix involves first we always pass a positive amount to the call
 and later convert back the changed amount into its proper sign, this allows us to assume that -1 and -2 are always
 errors and not other wise. */

IF P_amount < 0  THEN
    V_factor := -1;
ELSE
    V_factor := 1;
END IF;

IF ( P_conversion_type = 'User') THEN
  IF( P_user_validate_flag = 'Y') THEN

     V_allow_user_rate_type := is_user_rate_type_allowed (P_from_currency ,
                                                          P_to_currency   ,
                                                          P_conversion_date)  ;

      IF ( V_allow_user_rate_type = 'Y')  then
	    /* Bug fix for bug 2753298 Starts Here */
	    IF (P_Rate IS NULL) THEN
		RAISE pa_multi_currency.no_rate ;
	    END IF;
    	    /* Bug fix for bug 2753298 Ends Here Here */
            P_converted_amount := PA_CURRENCY.round_trans_currency_amt
                                      (P_amount * NVL(P_Rate,1),P_to_currency) ;
            P_denominator := 1 ;
            P_numerator   := NVL(P_rate,1) ;
      ELSE
             X_status := 'PA_USR_RATE_NOT_ALLOWED';
             RETURN ;
      END IF;

   ELSE P_converted_amount := PA_CURRENCY.round_trans_currency_amt
                              (P_amount * P_Rate, P_to_currency) ;
                              P_denominator := 1 ;
                              P_numerator := P_rate ;
   END IF;

ELSE
      V_amount := p_amount * v_factor;  -- Make amount positive Bug 2419636
      V_converted_amount := GL_CURRENCY_API.convert_amount_sql
				     (  P_from_currency      ,
  	                                P_to_currency        ,
				        P_conversion_date    ,
				        P_conversion_type    ,
				        V_amount            )  ;
    IF ( V_converted_amount = -1 ) THEN

       /* Bug 6058074 code begins */
	--Bug 8243561: Modified below If condition to call convert_closest_amount_sql
       IF (pa_multi_currency_txn.G_calling_module = 'WORKPLAN') OR (pa_multi_currency_txn.G_calling_module = 'ASSIGNMENT') OR (pa_multi_currency_txn.G_calling_module = 'UNASSIGNED') OR (pa_multi_currency_txn.G_calling_module = 'ROLE') then

            V_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql
				     (  x_from_currency => P_from_currency ,
  	                                x_to_currency => P_to_currency        ,
				        x_conversion_date => P_conversion_date    ,
				        x_conversion_type => P_conversion_type    ,
                                        x_user_rate => 1,
				        x_amount => V_amount ,
                                        x_max_roll_days => -1           )  ;
           l_call_closest_flag := 'T';
       END IF;

      /* Bug 6058074 code begins */
       IF ( V_converted_amount = -1 ) THEN
          RAISE pa_multi_currency.no_rate ;
       END IF ;
    ELSIF ( V_converted_amount = -2 ) THEN
	RAISE pa_multi_currency.invalid_currency ;
    END IF ;
--   P_converted_amount := V_converted_amount ;
     P_converted_amount := V_converted_amount * v_factor ; -- Changing Converted Amount to Original Sign Bug 2419636

    /* Bug 6058074 begin */
    If l_call_closest_flag = 'T' then

       V_numerator :=  GL_CURRENCY_API.get_closest_rate_numerator_sql( P_from_currency,
                                           P_to_currency,
                                           P_conversion_date,
                                           P_conversion_type ,
                                           -1);
       /* Bug 6058074 end */

    else
       V_numerator :=  GL_CURRENCY_API.get_rate_numerator_sql( P_from_currency,
                                           P_to_currency,
                                           P_conversion_date,
                                           P_conversion_type );
    end if;

    P_numerator := V_numerator ;

    If l_call_closest_flag = 'T' then

    /* Bug 6058074 begin */
        V_denominator :=  GL_CURRENCY_API.get_closest_rate_denom_sql( P_from_currency,
                                                P_to_currency,
                                                P_conversion_date,
                                                P_conversion_type,
                                                -1 );
       /* Bug 6058074 end */

    else
        V_denominator :=  GL_CURRENCY_API.get_rate_denominator_sql( P_from_currency,
                                                P_to_currency,
                                                P_conversion_date,
                                                P_conversion_type );
    end if;

    P_denominator := V_denominator ;
 -- Get conversion rate by using the x_numerator and x_denominator
    IF (( P_numerator > 0 ) AND ( P_denominator > 0 )) THEN
      P_rate := P_numerator / P_denominator;

    ELSE
      IF (( P_numerator = -2 ) OR (P_denominator = -2 )) THEN
        raise pa_multi_currency.invalid_currency;

      ELSE
        raise pa_multi_currency.no_rate;
      END IF;
    END IF;



END IF ;

EXCEPTION
    WHEN pa_multi_currency.no_rate THEN
      IF (P_handle_exception_flag = 'Y') THEN
         X_status := 'PA_NO_EXCH_RATE_EXISTS';
      ELSE
         RAISE;
      END IF;
    WHEN pa_multi_currency.invalid_currency THEN
      IF (P_handle_exception_flag = 'Y') THEN
         X_status := 'PA_CURR_NOT_VALID';
      ELSE
         RAISE;
      END IF;
    WHEN others THEN
    RAISE;

END convert_amount;

------------------------------------------------------------------------------
-- Function pa_multi_currency.convert_amount_sql.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
--
-- Function
--   convert_amount_sql
--
-- Purpose
--    Returns the amount converted from the from currency into the
--    functional currency of that set of books by calling convert_amount().
--    The amount returned is rounded to the precision and minimum account
--    unit of the to currency.
--
 FUNCTION convert_amount_sql (
                              P_from_currency         VARCHAR2,
                              P_to_currency           VARCHAR2,
                              P_conversion_date       DATE,
                              P_conversion_type       VARCHAR2 ,
                              P_Rate                  NUMBER,
                              P_amount                NUMBER ) RETURN NUMBER IS

    v_converted_amount            NUMBER;
    v_conversion_date             Date;
    v_conversion_type             Varchar2(30);
    v_denominator            	  NUMBER;
    v_numerator                   NUMBER;
    v_rate                        NUMBER;
    v_status	      		  Varchar2(100);

  BEGIN

    v_conversion_date := P_conversion_date;
    v_conversion_type := P_conversion_type;
    v_rate            := P_Rate;
    convert_amount (  P_from_currency	      => P_from_currency,
		      P_to_currency           => P_to_currency,
		      P_conversion_date       => v_conversion_date,
		      P_conversion_type       => v_conversion_type,
		      P_amount                => P_amount,
		      P_user_validate_flag    => 'N',
		      P_handle_exception_flag => 'N',
		      P_converted_amount      => v_converted_amount,
		      P_denominator           => v_denominator,
		      P_numerator             => v_numerator,
		      P_rate                  => v_rate,
                      X_status                => v_status);
    return( v_converted_amount );

    EXCEPTION

        WHEN pa_multi_currency.NO_RATE THEN
          v_converted_amount := -1;
          return( v_converted_amount );

        WHEN pa_multi_currency.INVALID_CURRENCY THEN
          v_converted_amount := -2;
          return( v_converted_amount );

  END convert_amount_sql;


------------------------------------------------------------------------------
-- Function pa_multi_currency.convert_closest_amount.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------

PROCEDURE convert_closest_amount
			 (  P_from_currency         IN VARCHAR2,
                P_to_currency           IN VARCHAR2,
                P_conversion_date       IN OUT NOCOPY DATE ,
                P_conversion_type       IN OUT NOCOPY VARCHAR2,
                P_amount                IN NUMBER,
                P_user_validate_flag    IN VARCHAR2 ,
                P_handle_exception_flag IN VARCHAR2,
			    P_maxroll_days	        IN NUMBER ,
                P_converted_amount      IN OUT NOCOPY NUMBER,
                P_denominator           IN OUT NOCOPY NUMBER,
                P_numerator             IN OUT NOCOPY NUMBER,
                P_rate                  IN OUT NOCOPY NUMBER,
                X_status                OUT NOCOPY VARCHAR2)  IS

V_allow_user_rate_type   VARCHAR2(1) ;
V_converted_amount       NUMBER ;

BEGIN
    pa_cc_utils.set_curr_function('convert_closest_amount');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('convert_closest_amount: ' || 'Start ');
    END IF;

X_status := null ;
P_conversion_date := NVL(P_conversion_date, sysdate);

IF (P_from_currency = P_to_currency) THEN
    P_conversion_date := null;
    P_conversion_type := null;
    P_rate            := null;
    P_converted_amount:= P_amount;
    pa_cc_utils.reset_curr_function ;
    RETURN;
END IF;

IF ( P_conversion_type = 'User') THEN
  IF( P_user_validate_flag = 'Y') THEN
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('convert_closest_amount: ' || 'Before calling is_user_rate_type_allowed');
     END IF;
     V_allow_user_rate_type := is_user_rate_type_allowed (P_from_currency ,
                                                          P_to_currency   ,
                                                          P_conversion_date)  ;


      IF ( V_allow_user_rate_type = 'Y')  then
            P_converted_amount := PA_CURRENCY.round_trans_currency_amt
                                      (P_amount * NVL(P_Rate,1),P_to_currency) ;
            P_denominator := 1 ;
            P_numerator   := NVL(P_rate,1) ;
      ELSE
             X_status := 'PA_USR_RATE_NOT_ALLOWED';
             pa_cc_utils.reset_curr_function ;
             RETURN ;
      END IF;

   ELSE P_converted_amount := PA_CURRENCY.round_trans_currency_amt
                              (P_amount * P_Rate, P_to_currency) ;
                              P_denominator := 1 ;
                              P_numerator := P_rate ;
   END IF;

ELSE
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('Before Calling GL_CURRENCY_API.convert_closest_amount');
      END IF;
      GL_CURRENCY_API.convert_closest_amount
				     (  P_from_currency      ,
                                        P_to_currency        ,
                                        P_conversion_date    ,
                                        P_conversion_type    ,
					P_rate		     ,
                                        P_amount             ,
					P_maxroll_days	     ,
                                        P_converted_amount   ,
                                        P_denominator        ,
                                        P_numerator          ,
                                        P_rate               )  ;
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('After Calling GL_CURRENCY_API.convert_closest_amount');
      END IF;
      P_converted_amount  := PA_CURRENCY.round_trans_currency_amt
				 ( P_converted_amount, P_to_currency);
END IF ;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('convert_closest_amount: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

EXCEPTION

    WHEN gl_currency_api.no_rate THEN
      IF (P_handle_exception_flag = 'Y') THEN
         X_status := 'PA_NO_EXCH_RATE_EXISTS';
      ELSE
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('convert_closest_amount: ' || pa_debug.G_err_stack);
            pa_cc_utils.log_message('convert_closest_amount: ' || SQLERRM);
         END IF;
         RAISE;
      END IF;
    WHEN gl_currency_api.invalid_currency THEN
      IF (P_handle_exception_flag = 'Y') THEN
         X_status := 'PA_CURR_NOT_VALID';
      ELSE
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('convert_closest_amount: ' || pa_debug.G_err_stack);
            pa_cc_utils.log_message('convert_closest_amount: ' || SQLERRM);
         END IF;
         RAISE;
      END IF;
    WHEN others THEN
       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('convert_closest_amount: ' || pa_debug.G_err_stack);
          pa_cc_utils.log_message('convert_closest_amount: ' || SQLERRM);
       END IF;
    RAISE;

END convert_closest_amount;


------------------------------------------------------------------------------
-- Procedure pa_multi_currency.format_amount.
-- Comments for the Procedure are at the package specification level
------------------------------------------------------------------------------
PROCEDURE format_amount (P_currency         IN VARCHAR2,
                         P_amount           IN NUMBER,
                         P_field_length     IN NUMBER,
                         P_formatted_amount OUT NOCOPY VARCHAR2 ) IS

l_format_mask     VARCHAR2(1000) DEFAULT NULL;
l_curr_code       VARCHAR2(15);
num_rows          NUMBER ;

BEGIN

    pa_cc_utils.set_curr_function('format_amount');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('format_amount: ' || 'Start ');
    END IF;

num_rows := FormatMaskTab.count ;
-- This gets the Number of Rows in the PL/SQL table.

 FOR i in 1..num_rows LOOP
  IF P_DEBUG_MODE  THEN
     pa_cc_utils.log_message('format_amount: ' || 'Start of Loop');
  END IF;
   IF ( P_currency IS NOT NULL
         AND FormatMaskTab(i).currency_code = P_currency) THEN
         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('format_amount: ' || 'Before retrieving from PLSQL Table');
         END IF;

      l_format_mask := FormatMaskTab(i).format_mask ;
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('format_amount: ' || 'Before exit after getting format mask');
      END IF;

      EXIT ;
   END IF ;
  IF P_DEBUG_MODE  THEN
     pa_cc_utils.log_message('format_amount: ' || 'End of Loop');
  END IF;

 END LOOP ;

-- We first check if the table has the currency code and we fetch the
-- corresponding format mask. This is done by looping thru the table
-- If the required currency code is not there in the table, we call the
-- FND API get_format_mask to get the format_mask. This format_mask and
-- corresponding currency code is then stored in the table.

 IF ( l_format_mask is NULL
       AND P_currency IS NOT NULL )THEN
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('format_amount: ' || 'Before calling FND_CURRENCY.get_format_mask');
    END IF;

    l_format_mask := FND_CURRENCY.get_format_mask (P_currency,
                                                   P_field_length ) ;
     FormatMaskTab(num_rows + 1).currency_code := P_currency ;
     FormatMaskTab(num_rows + 1).format_mask   := l_format_mask ;
 END IF;
 P_formatted_amount := TO_CHAR(P_amount, l_format_mask) ;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('format_amount: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

 -- This applies the format mask to the amount to get the formatted amount.
EXCEPTION
   WHEN OTHERS THEN
      IF P_DEBUG_MODE  THEN
         pa_cc_utils.log_message('format_amount: ' || pa_debug.G_err_stack);
         pa_cc_utils.log_message('format_amount: ' || SQLERRM);
      END IF;
      RAISE ;
END format_amount ;

------------------------------------------------------------------------------
-- Function pa_multi_currency.validate_rate_type.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
FUNCTION validate_rate_type ( P_rate_type VARCHAR2 )
RETURN varchar2 IS

CURSOR C1 IS
       SELECT 'X'
       FROM   dual
       WHERE EXISTS(
       SELECT 'X'
       FROM   pa_conversion_types_v
       WHERE  conversion_type = P_rate_type) ;

l_Rate_type  C1%ROWTYPE;

BEGIN
    pa_cc_utils.set_curr_function('validate_rate_type');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('validate_rate_type: ' || 'Start ');
    END IF;

OPEN C1 ;
IF P_DEBUG_MODE  THEN
   pa_cc_utils.log_message('validate_rate_type: ' || 'After Open Cursor');
END IF;
FETCH C1 INTO l_Rate_type ;
IF P_DEBUG_MODE  THEN
   pa_cc_utils.log_message('validate_rate_type: ' || 'After fetch Cursor');
END IF;
IF C1%NOTFOUND THEN
   CLOSE C1;
    pa_cc_utils.reset_curr_function ;
   RETURN 'N';
ELSE
   CLOSE C1;
    pa_cc_utils.reset_curr_function ;
   RETURN 'Y';
END IF ;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('validate_rate_type: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

EXCEPTION
 WHEN others THEN
 IF P_DEBUG_MODE  THEN
    pa_cc_utils.log_message('validate_rate_type: ' || pa_debug.G_err_stack);
    pa_cc_utils.log_message('validate_rate_type: ' || SQLERRM);
 END IF;
 RAISE ;
END validate_rate_type ;

------------------------------------------------------------------------------
-- Function pa_multi_currency.validate_currency_code.
-- Comments for the function are at the package specification level
------------------------------------------------------------------------------
FUNCTION validate_currency_code ( P_Currency_code VARCHAR2,
                                  P_EI_date       DATE )
RETURN varchar2 IS

--
-- Bug 4352158
-- Changed the following cursor to refer table FND_CURRENCIES
-- instead of fnd_currencies_vl.
--
CURSOR C1 IS
       SELECT 'X'
       FROM   dual
       WHERE EXISTS(
       SELECT 'X'
       FROM   FND_CURRENCIES
       WHERE  currency_code = P_Currency_code
       AND    enabled_flag = 'Y'
       AND    P_EI_date
       BETWEEN NVL(start_date_active, P_EI_date)
       AND     NVL(end_date_active , P_EI_date)) ;

l_currency_code  C1%ROWTYPE;

BEGIN
    pa_cc_utils.set_curr_function('validate_currency_code');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('validate_currency_code: ' || 'Start ');
    END IF;

    If (G_PrevCurr = P_Currency_code and trunc(G_PrevEiDate) = trunc(P_EI_date)) Then

        --Bug 2749049
        pa_cc_utils.reset_curr_function ;
        RETURN G_CurrValid;

    Else

        OPEN C1 ;
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('validate_currency_code: ' || 'After Open Cursor');
        END IF;
        FETCH C1 INTO l_currency_code ;
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('validate_currency_code: ' || 'After fetch Cursor');
        END IF;
        IF C1%NOTFOUND THEN
           CLOSE C1;
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('validate_currency_code: ' || 'After close Cursor when currency is not valid');
           END IF;
           pa_cc_utils.reset_curr_function ;
           G_CurrValid := 'N';
           G_PrevCurr  := P_Currency_code;
           G_PrevEiDate := P_EI_date;
           RETURN 'N';
        ELSE
           CLOSE C1;
           IF P_DEBUG_MODE  THEN
              pa_cc_utils.log_message('validate_currency_code: ' || 'After close Cursor when currency is valid');
           END IF;
           pa_cc_utils.reset_curr_function ;
           G_CurrValid := 'Y';
           G_PrevCurr  := P_Currency_code;
           G_PrevEiDate := P_EI_date;
           RETURN 'Y';
        END IF ;

    End If;

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('validate_currency_code: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

EXCEPTION
WHEN others THEN
 IF P_DEBUG_MODE  THEN
    pa_cc_utils.log_message('validate_currency_code: ' || pa_debug.G_err_stack);
    pa_cc_utils.log_message('validate_currency_code: ' || SQLERRM);
 END IF;
 --Bug 2749049
 pa_cc_utils.reset_curr_function ;
 RAISE ;
END validate_currency_code ;


--PA-K Performance Improvement Changes
--Caching values.
FUNCTION get_conversion_type ( P_user_rate_type VARCHAR2 )
RETURN varchar2 IS

CURSOR C1 IS
       SELECT conversion_type
       FROM  pa_conversion_types_v
       WHERE user_conversion_type = P_user_rate_type;

l_Rate_type  pa_conversion_types_v.conversion_type%TYPE;

BEGIN
    pa_cc_utils.set_curr_function('get_conversion_type');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('get_conversion_type: ' || 'Start ');
    END IF;

   If (G_PrevUserRateType = P_user_rate_type) Then

       pa_cc_utils.reset_curr_function ;		/* Added for Bug 3161853 */
       RETURN G_PrevRateType;

   Else

     OPEN C1 ;
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('get_conversion_type: ' || 'After Opening Cursor');
     END IF;
     FETCH C1 INTO l_Rate_type ;
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('get_conversion_type: ' || 'After Fetching Cursor');
     END IF;

     G_PrevRateType := l_Rate_type;
     G_PrevUserRateType := P_user_rate_type;

     CLOSE C1;
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('get_conversion_type: ' || 'After closing Cursor');
     END IF;
     pa_cc_utils.reset_curr_function ;
     RETURN l_rate_type;

    End If;

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('get_conversion_type: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

EXCEPTION
 WHEN others THEN
 IF P_DEBUG_MODE  THEN
    pa_cc_utils.log_message('get_conversion_type: ' || pa_debug.G_err_stack);
    pa_cc_utils.log_message('get_conversion_type: ' || SQLERRM);
 END IF;
 pa_cc_utils.reset_curr_function ;
 RETURN NULL;
END get_conversion_type ;


------------------------------------------------------------------------------
-- procedure to initialize global variables.
------------------------------------------------------------------------------
PROCEDURE init IS

BEGIN

    pa_cc_utils.set_curr_function('Init');
    pa_cc_utils.log_message('Start ');

G_accounting_currency_code    := get_acct_currency_code ;

G_rate_date_code             := check_rate_date_code ;

G_rate_type                  := get_rate_type ;
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;

END init ;

------------------------------------------------------------------------------
-- Function to get User_Conversion_Type value
------------------------------------------------------------------------------
FUNCTION Get_User_Conversion_Type ( P_Conversion_Type VARCHAR2 )
RETURN VARCHAR2
IS

X_User_Conversion_Type VARCHAR2(200);

BEGIN

  IF P_Conversion_Type IS NOT NULL
  THEN
    GL_DAILY_CONV_TYPES_PKG.select_columns(P_Conversion_Type, X_User_Conversion_Type);

  RETURN X_User_Conversion_Type ;
  ELSE
    RETURN NULL;
  END IF;

END Get_User_Conversion_Type ;

END pa_multi_currency ;

/
