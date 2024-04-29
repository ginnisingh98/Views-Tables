--------------------------------------------------------
--  DDL for Package Body ARPCURR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARPCURR" AS
/* $Header: ARPLCURB.pls 120.9.12010000.2 2009/01/06 00:40:53 vpusulur ship $ */

    TYPE CurrencyCodeType  IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
    TYPE PrecisionType     IS TABLE OF NUMBER(1)     INDEX BY BINARY_INTEGER;
    TYPE MauType           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
    NextElement            BINARY_INTEGER := 0;
    CurrencyCode           CurrencyCodeType;
    Precision              PrecisionType;
    Mau                    MauType;
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

   /* 5468091 - cache sob_id for getfunccurr() function */
   g_sob_id                NUMBER := -2;  -- init to known value
   g_func_currency         VARCHAR2(15);

    CURSOR CurrencyCursor( cp_currency_code VARCHAR2 ) IS
    SELECT  precision,
            minimum_accountable_unit
    FROM    fnd_currencies
    WHERE   currency_code = cp_currency_code;
--
    PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                                  p_precision     OUT NOCOPY NUMBER,
                                  p_mau           OUT NOCOPY NUMBER ) IS
        i BINARY_INTEGER := 0;
    BEGIN
        WHILE i < NextElement
        LOOP
            EXIT WHEN CurrencyCode(i) = p_currency_code;
            i := i + 1;
        END LOOP;
--
        IF i = NextElement
        THEN
            OPEN CurrencyCursor( p_currency_code );
            DECLARE
                l_Precision NUMBER;
                l_Mau       NUMBER;
            BEGIN
                FETCH CurrencyCursor
                INTO    l_Precision,
                        l_Mau;
                IF CurrencyCursor%NOTFOUND THEN
                    RAISE NO_DATA_FOUND;
                END IF;
                Precision(i)    := l_Precision;
                Mau(i)          := l_Mau;
            END;
            CLOSE CurrencyCursor;
            CurrencyCode(i) := p_currency_code;
            NextElement     := i + 1;
        END IF;
        p_precision := Precision(i);
        p_mau       := Mau(i);
    EXCEPTION
        WHEN OTHERS THEN
            -- bug 2191876
            IF CurrencyCursor%ISOPEN THEN
               CLOSE CurrencyCursor;
            END IF;
            RAISE;
    END;
--
    FUNCTION CurrRound( p_amount IN NUMBER, p_currency_code IN VARCHAR2 := FunctionalCurrency) RETURN NUMBER IS
        l_precision NUMBER(1);
        l_mau       NUMBER;
    BEGIN
        GetCurrencyDetails( p_currency_code, l_precision, l_mau );
        IF l_mau IS NOT NULL
        THEN
            RETURN( ROUND( p_amount / l_mau) * l_mau );
        ELSE
            RETURN( ROUND( p_amount, l_precision ));
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
--
    /*
    -- This procedure is designed to help in calculating acctd equivalents,
    -- and reconciling the sum of accounted equivalents
    --
    -- The basis of this routine is that the accounted equivalent of a 'child'
    --     amount is the difference in the accounted amount produced by the
    --     child on the 'parent' record
    --
    -- Additionally, at any point when the sum of the 'child' amounts is
    --     equal to a reconcile amount on the parent, the sum of 'child'
    --     accounted amounts should be equal to the accounted reconcile
    --     amount of the 'parent'
    --
    -- The routine assumes that the amounts are being converted to the
    --     Set of Books functional currency
    --
    -- Sample Implementation in calling context
    --
    --     The procedure takes an exchange rate and currency as parameters
    --     It converts the entered values 1,2,3 to accounted, and reconciles
    --         the accounted amount
    --
    --     PROCEDURE TestReconcile( p_ExchangeRate IN NUMBER ) IS
               l_RunningTotalAmount        NUMBER := 0;
               l_RunningTotalAcctdAmount   NUMBER := 0;
               l_ReconcileAmount           NUMBER;
               l_ReconcileAcctdAmount      NUMBER;
           BEGIN
               l_ReconcileAmount      := 6;   -- 1 + 2 + 3
               l_ReconcileAcctdAmount := CurrRound( ReconcileAmount * p_ExchangeRate );
               dbms_output.put_line( ReconcileAcctdAmount( p_ExchangeRate,
                                     l_ReconcileAmount, l_ReconcileAcctdAmount,
                                     1,
                                     l_RunningTotalAmount, l_RunningTotalAcctdAmount ));
               dbms_output.put_line( ReconcileAcctdAmount( p_ExchangeRate,
                                     l_ReconcileAmount, l_ReconcileAcctdAmount,
                                     2,
                                     l_RunningTotalAmount, l_RunningTotalAcctdAmount ));
               dbms_output.put_line( ReconcileAcctdAmount( p_ExchangeRate,
                                     l_ReconcileAmount, l_ReconcileAcctdAmount,
                                     3,
                                     l_RunningTotalAmount, l_RunningTotalAcctdAmount ));
            END;
    */
    FUNCTION ReconcileAcctdAmounts( p_ExchangeRate             IN NUMBER,
                                     p_ReconcileAmount          IN NUMBER,
                                     p_ReconcileAcctdAmount     IN NUMBER,
                                     p_ChildAmount              IN NUMBER,
                                     p_RunningTotalAmount       IN OUT NOCOPY NUMBER,
                                     p_RunningTotalAcctdAmount  IN OUT NOCOPY NUMBER ) RETURN NUMBER IS
        l_AcctdChildAmount NUMBER;
    BEGIN
        p_RunningTotalAmount := p_RunningTotalAmount + p_ChildAmount;
        IF p_RunningTotalAmount = p_ReconcileAmount
        THEN
            l_AcctdChildAmount := p_ReconcileAcctdAmount - p_RunningTotalAcctdAmount;
        ELSE
            l_AcctdChildAmount := CurrRound( p_RunningTotalAmount * p_ExchangeRate ) - p_RunningTotalAcctdAmount;
        END IF;
--
        p_RunningTotalAcctdAmount := p_RunningTotalAcctdAmount + l_AcctdChildAmount;
        RETURN l_AcctdChildAmount;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'arpcurr.ReconcileAcctdAmounts: $Revision: 120.9.12010000.2 $' );
            arp_standard.debug( 'l_AcctdChildAmount:'||l_AcctdChildAmount );
            RAISE;
    END;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    functional_amount                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function returns the functional amount for a given foreign amount. |
 |    THe functional amount is rounded to the correct precision.              |
 |                                                                            |
 | REQUIRES                                                                   |
 |    Amount - the foreign amount                                             |
 |    Exchange Rate - to use when converting to functional amount             |
 |   one of:                                                                  |
 |    Currency Code            - of the functional amount                     |
 |    Precision                - of the functional amount                     |
 |    minimum accountable unit - of the functional amount                     |
 |                                                                            |
 | RETURNS                                                                    |
 |    amount * exchange_rate to correct rounding for currency                 |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    Oracle Error      If Currency Code, Precision and minimum accountable   |
 |                      are all NULL                                          |
 |                                                                            |
 |    Oracle Error      If can not find information for Currency Code         |
 |                      supplied                                              |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |    <none>                                                                  |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/10/93         Martin Morris           Created                       |
 |      7/21/95         Martin Johnson          Replaced fnd_message with     |
 |                                              user-defined exception so that|
 |                                              pragma restrict_references    |
 |                                              does not fail                 |
 |                                                                            |
 *----------------------------------------------------------------------------*/


FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER IS

/*----------------------------------------------------------------------------*
 | PRIVATE CURSOR                                                             |
 |      curr_info                                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |      Gets the precision and the minimum accountable unit for the currency  |
 |      Supplied                                                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/

    CURSOR curr_info (cc FND_CURRENCIES.CURRENCY_CODE%TYPE) IS
        SELECT PRECISION,
               MINIMUM_ACCOUNTABLE_UNIT,
               CURRENCY_CODE
        FROM   FND_CURRENCIES
        WHERE  CURRENCY_CODE = cc;

/*---------------------------------------------------------------------------*
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 *---------------------------------------------------------------------------*/


    curr       curr_info%ROWTYPE;
    loc_amount NUMBER;
    invalid_params EXCEPTION;

BEGIN

    /*--------------------------------------------------------------------*
     | Validate Parameters                                                |
     *--------------------------------------------------------------------*/

    IF (((currency_code IS NULL) AND
         (precision IS NULL) AND
         (min_acc_unit IS NULL)) OR
        (amount IS NULL) ) THEN
      BEGIN

         /* fnd_message('STD-FUNCT-AMT-INV-PAR'); */

         RAISE invalid_params;

      END;
    END IF;

    /*--------------------------------------------------------------------*
     | Only get currency info from database if not supplied as parameters |
     *--------------------------------------------------------------------*/


    IF ((precision IS NULL) AND (min_acc_unit IS NULL)) THEN
      BEGIN
         OPEN curr_info(currency_code);
         FETCH curr_info INTO curr;
         CLOSE curr_info;

         IF (curr.currency_code IS NULL) THEN

              /* fnd_message('STD-FUNCT-AMT-CURR-NF',
                             'CURR',
                             currency_code); */

              RAISE invalid_params;

         END IF;

      END;
    ELSE
      BEGIN
         curr.precision := precision;
         curr.minimum_accountable_unit := min_acc_unit;
      END;
    END IF;

    loc_amount := amount * NVL(exchange_rate, 1);

    /*-----------------*
     | Round correctly |
     *-----------------*/

    IF (curr.minimum_accountable_unit IS NULL) THEN
       RETURN( ROUND(loc_amount, curr.precision));
    ELSE
       RETURN( ROUND((loc_amount / curr.minimum_accountable_unit)) *
               curr.minimum_accountable_unit);
    END IF;

EXCEPTION
     WHEN OTHERS THEN
         -- Bug 2191876
         IF curr_info%ISOPEN THEN
            CLOSE curr_info;
         END IF;

         RAISE;

END functional_amount;

Function GetFunctCurr(p_set_of_books_id IN  Number) Return Varchar2 IS

    BEGIN

       IF g_sob_id <> p_set_of_books_id
       THEN

        SELECT  currency_code
        INTO    g_func_currency
        FROM    gl_sets_of_books
        WHERE   set_of_books_id = p_set_of_books_id;

       END IF;

       RETURN(g_func_currency);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
END GetFunctCurr;

Function GetConvType(p_conv_type IN  varchar2) RETURN VARCHAR2 IS

    l_user_conversion_type varchar2(30);

    BEGIN

        SELECT  user_conversion_type
        INTO    l_user_conversion_type
        FROM    gl_daily_conversion_types
        WHERE   conversion_type = p_conv_type;

        return(l_user_conversion_type);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
END GetConvType;


Function GetRate(p_from_curr_code IN varchar2,p_to_curr_code IN varchar2,p_conversion_date DATE,p_conversion_type IN varchar2) RETURN NUMBER IS
          l_user_conversion_rate Number;
          l_hash_value NUMBER;
          p_concat_segments     varchar2(100);
          tab_indx          BINARY_INTEGER := 0;
          found             BOOLEAN ;

BEGIN
  /*----------------------------------------------------------------+
   |  Search the cache for the concantenated segments.              |
   |  Return the conversion_rate if it is in the cache.             |
   |                                                                |
   |  If not found in cache, search the linear table (where         |
   |   conversion_rate's                                            |
   |  will go if collision on the hash table occurs).               |
   |                                                                |
   |  If not found above then get it from gl_currency_api.get_rate  |
   +----------------------------------------------------------------*/

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('arpcurr.getrate');
       arp_standard.debug('GetRate: ' || 'p_from_curr_code' || p_from_curr_code);
       arp_standard.debug('GetRate: ' || 'p_to_curr_code' || p_to_curr_code);
       arp_standard.debug('GetRate: ' || 'date ' || to_char(p_conversion_date));
       arp_standard.debug('GetRate: ' || 'type = ' || p_conversion_type);
    END IF;

 IF (p_from_curr_code IS NOT NULL AND
     p_to_curr_code IS NOT NULL   AND
     p_conversion_date IS NOT NULL  ) THEN
--     Bug 2656787:   EUR/EUR derived will always have null conversion type
--     p_conversion_type IS NOT NULL THEN

  p_concat_segments :=  p_from_curr_code||'@*?'||p_to_curr_code||'@*?'||p_conversion_date||'@*?'||p_conversion_type;

    l_hash_value := DBMS_UTILITY.get_hash_value(p_concat_segments,
                                         1000,
                                         25000);
   found := FALSE;
   IF pg_getrate_hash_seg_cache.exists(l_hash_value) THEN
     IF pg_getrate_hash_seg_cache(l_hash_value) = p_concat_segments THEN
        l_user_conversion_rate :=  pg_getrate_hash_id_cache(l_hash_value);
	   found := TRUE;

       ELSE     --- collision has occurred
            tab_indx := 1;  -- start at top of linear table and search for match

            WHILE ((tab_indx < 25000) AND (not FOUND))  LOOP
              IF pg_getrate_line_seg_cache(tab_indx) = p_concat_segments THEN
                  l_user_conversion_rate := pg_getrate_line_id_cache(tab_indx);
                    found := TRUE;
              ELSE
                 tab_indx := tab_indx + 1;
              END IF;
            END LOOP;
       END IF;
   END IF;
  IF found THEN
        RETURN(l_user_conversion_rate);
  ELSE
   l_user_conversion_rate := gl_currency_api.get_rate(p_from_curr_code,p_to_curr_code,p_conversion_date,p_conversion_type);

IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('GetRate: ' || 'after call to gl_currency_api');
END IF;
           IF pg_getrate_hash_seg_cache.exists(l_hash_value) then
              tab_size := tab_size + 1;
              pg_getrate_line_id_cache(tab_size)       := l_user_conversion_rate;
              pg_getrate_line_seg_cache(tab_size)      := p_concat_segments;
           ELSE
              pg_getrate_hash_id_cache(l_hash_value)   := l_user_conversion_rate;
              pg_getrate_hash_seg_cache(l_hash_value)  := p_concat_segments;
              pg_getrate_line_id_cache(tab_size)       := l_user_conversion_rate;
              pg_getrate_line_seg_cache(tab_size)      := p_concat_segments;
           END IF;
          RETURN(l_user_conversion_rate);
   END IF;
 END IF;

 EXCEPTION
 WHEN GL_CURRENCY_API.NO_RATE  THEN
  return -1;
 WHEN OTHERS THEN
  RAISE ;
END GetRate;

Function RateExists(p_set_of_books_id IN NUMBER,p_from_curr_code IN varchar2,p_conversion_date DATE,p_conversion_type IN varchar2) RETURN VARCHAR2 IS
--
          l_user_conversion_rate Number;

BEGIN

    IF (p_from_curr_code IS NULL)
    THEN
         return  'X';
    END IF;
    l_user_conversion_rate := gl_currency_api.get_rate(p_set_of_books_id,p_from_curr_code,p_conversion_date,p_conversion_type);

    IF (l_user_conversion_rate IS NOT NULL)
    THEN
         return  'Y';
    END IF;
    EXCEPTION
    WHEN GL_CURRENCY_API.NO_RATE  THEN
     arp_standard.debug('EXCEPTION: No Rate Exception In arpcurr.rateexists()');
     return 'N';
    WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: Others Exception In arpcurr.rateexists()');
     arp_standard.debug('EXCEPTION: '||SQLERRM);
     RETURN 'N' ;
END RateExists;


Function IsFixedRate(p_rec_curr_code IN varchar2,
                     p_funct_curr_code IN varchar2,
                     p_rec_conversion_date DATE,
                     p_trx_curr_code IN varchar2 Default NULL,
                     p_trx_conversion_date DATE  Default NULL) RETURN VARCHAR2 IS
--

    l_rec_relation  varchar2(1);
    l_trx_relation  varchar2(1);
    l_relation      varchar2(1);


BEGIN


        IF (p_trx_curr_code IS NOT NULL) THEN

          l_rec_relation := gl_currency_api.is_fixed_rate(p_rec_curr_code,p_funct_curr_code,p_rec_conversion_date);
          l_trx_relation := gl_currency_api.is_fixed_rate(p_trx_curr_code,p_funct_curr_code,p_trx_conversion_date);

          IF (l_rec_relation = 'Y' and l_trx_relation = 'Y') Then
                l_relation := 'Y';
          Else
                l_relation := 'N';
          End if;

        ELSE

          l_relation := gl_currency_api.is_fixed_rate(p_rec_curr_code,p_funct_curr_code,p_rec_conversion_date);

        END IF;

        return(l_relation);

    EXCEPTION
        WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
            RETURN 'N';
        WHEN OTHERS THEN
            RAISE;

END IsFixedRate;
--
--
/* Bug 3810649 */
PROCEDURE flush_cached_rates IS
BEGIN
  pg_getrate_hash_seg_cache := pg_init_seg_cache;
END flush_cached_rates;

--
-- constructor section
--
PROCEDURE init IS
    BEGIN
        SELECT  sob.currency_code
       INTO    FunctionalCurrency
        FROM    ar_system_parameters    sp,
                gl_sets_of_books        sob
        WHERE   sob.set_of_books_id = sp.set_of_books_id;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'arpcurr.constructor' );
            RAISE;
END init;

/* 5885313 - call init in constructor code */
BEGIN
   init;
--
END arpcurr;

/
