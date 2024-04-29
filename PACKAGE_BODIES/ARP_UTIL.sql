--------------------------------------------------------
--  DDL for Package Body ARP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_UTIL" AS
/*$Header: ARCUTILB.pls 120.20.12010000.5 2009/05/11 10:18:50 mpsingh ship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
-----------------------------------------------------------------------------
-- Debugging functions
-----------------------------------------------------------------------------
PROCEDURE enable_debug is
BEGIN
   arp_standard.enable_debug;
END;
--
--
PROCEDURE enable_debug( buffer_size NUMBER ) is
BEGIN
   arp_standard.enable_debug( buffer_size );
END;
--
--
--
PROCEDURE disable_debug is
BEGIN
   arp_standard.disable_debug;
END;
--
--
--
PROCEDURE debug( line in varchar2 ) is
BEGIN
  arp_debug.debug(line);
END;
--
--
--
PROCEDURE debug( str VARCHAR2, print_level NUMBER ) IS
BEGIN

	debug( str );

END debug;
--
--
--
PROCEDURE print_fcn_label( p_label VARCHAR2 ) IS
BEGIN

    debug( p_label || ' ' || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));

END print_fcn_label;
--
--
--
PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN

    debug( p_label || ' ' || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));

END print_fcn_label2;
--
--
--


-----------------------------------------------------------------------------
-- Amount functions
-----------------------------------------------------------------------------
FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER IS

BEGIN
	RETURN( arp_standard.functional_amount(amount,currency_code,
				exchange_rate,
				precision,
				min_acc_unit ));
END functional_amount;


-- Bug5041260
FUNCTION func_amount(amount        IN NUMBER,
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

END func_amount;


--
-- This function returns the amount to the correct presicion
-- for the currency code you passed in.
-- If P_exchange_rate is not passed, it would be default to 1
-- If P_currency_code is not passed, it would be default to its
-- functional currency.
--

FUNCTION calc_dynamic_amount(
                      P_amount IN NUMBER,
	              P_exchange_rate IN NUMBER,
	              P_currency_code IN fnd_currencies.currency_code%TYPE )
  RETURN NUMBER IS

    l_precision fnd_currencies.precision%TYPE;
    l_ext_precision fnd_currencies.extended_precision%TYPE;
    l_min_acct_unit fnd_currencies.minimum_accountable_unit%TYPE;
    l_format_mask   VARCHAR2(45);

BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_util.calc_dynamic_amount()+' );
   END IF;

/*
   FND_CURRENCY.get_info( nvl(P_currency_code,ARP_GLOBAL.functional_currency),
                          l_precision, l_ext_precision, l_min_acct_unit );

   FND_CURRENCY.build_format_mask( l_format_mask,45,l_precision,
				   l_min_acct_unit,FALSE,'-XXX','XXX');
*/

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_util.calc_dynamic_amount()-' );
   END IF;

   return( TO_NUMBER( TO_CHAR( P_amount*nvl(P_exchange_rate,1),
			       l_format_mask ) ) );

EXCEPTION
     WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     debug(   'Exception: arp_util.calc_dynamic_amount' );
	  END IF;
          RAISE;

END calc_dynamic_amount;
--
--
--
FUNCTION CurrRound( p_amount IN NUMBER,
                    p_currency_code IN VARCHAR2)
  RETURN NUMBER IS
BEGIN

    RETURN( arpcurr.CurrRound( p_amount, p_currency_code ) );

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calc_acctd_amount                               			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Converts a 'detail' amount to a foreign currency.                     |
 |     The basis of the calculation is that the accounted equivalent of a    |
 |     'detail' amount is the change in the accounted amount that the detail |
 |     produced in some 'master' record.                                     |
 |                                                                           |
 |     eg an adjustment is a 'detail' amount that results in a change to     |
 |         the amount_due_remaining in the 'master' record                   |
 |         (ar_payment_schedules)                                            |
 |                                                                           |
 |     the routine can take a currency as a parameter, in which case the     |
 |     precision and minimum_accountable_unit for that currency will be used |
 |                                                                           |
 |     if no currency is sent, the routine can use the precision and         |
 |         minimum_accountable_unit if sent                                  |
 |                                                                           |
 |     if the precision and minimum_accountable_unit are not sent, then      |
 |         the routine will use the precision and minimum_accountable_unit   |
 |         of the set of books currency                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |     p_currency     	  - the currency to be converted to (optional)       |
 |     p_precision        - the precision                   (optional)       |
 |     p_mau              - the minimum accountable unit    (optional)       |
 |     p_rate             - the exchange rate               (mandatory)      |
 |     p_type             - takes value '+' or '-' defaults to '+'. '+'      |
 |                          means that the detail amount will be used to     |
 |                          increase the master amount.                      |
 |                          '-' means that the detail amount will be used to |
 |                          decrease the master amount                       |
 |     p_master_from      - the original amount on the master record (in     |
 |                          foreign currency                                 |
 |     p_detail           - the foreign amount on the detail                 |
 |                              record                      (mandatory)      |
 |    IN OUT:                                                                |
 |     p_acctd_master_from                                                   |
 |                        - the accounted equivalent of the master record    |
 |                                                          (optional)       |
 |    OUT:						                     |
 |     p_master_to        - returns the new foreign value of the master      |
 |                              record. ie master_from +- detail             |
 |     p_acctd_master_to  - returns the master_to converted to accounted     |
 |                             currency                                      |
 |     p_acctd_detail     - returns the accounted equivalent of detail       |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |   Unlike the Pro*C equivalent of this function, aracc(), this PL/SQL      |
 |   function has no optional output parameters, i.e., in function calls     |
 |   NULL cannot be specified for the IN OUT NOCOPY or OUT NOCOPY variables.               |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    21-AUG-95	OSTEINME	created					     |
 |    2/22/1996 H.Kaukovuo	Added debug messages to print out NOCOPY parameters
 |				Modified procedure to use standard functional
 |				amount procedure.
 |				Changed procedure to consider p_rate = 1 as
 |				functional currency (was 0 before).
 |    2/23/1996 H.Kaukovuo	Fixed own bug, was returing ORA6512.
 |    3/1/1996  H.Kaukovuo	Fixed bug where p_master_from was null and
 |				caused ORA6512
 |    8/28/1996	H.Kaukovuo	Added parameters p_precision and p_mau to
 |				call to arp_util.functional_amount().
 |    7/26/2000 skoukunt        Fix 1353061, comment code which assume
 |                              If a rate <> 1 is given, the currency to be
 |                              foreign
 +===========================================================================*/

PROCEDURE calc_acctd_amount(
	p_currency		IN	VARCHAR2,
	p_precision		IN	NUMBER,
	p_mau			IN	NUMBER,
	p_rate			IN	NUMBER,
	p_type			IN	VARCHAR2,
	p_master_from		IN	NUMBER,
	p_acctd_master_from	IN OUT NOCOPY	NUMBER,
	p_detail		IN	NUMBER,
	p_master_to		IN OUT NOCOPY 	NUMBER,
	p_acctd_master_to	IN OUT NOCOPY	NUMBER,
	p_acctd_detail		IN OUT NOCOPY	NUMBER
			) IS
--
-- Local Variables:
--
l_functional	BOOLEAN;           -- flag: TRUE if functional currency
l_mau		NUMBER;		   -- minimum accounting unit
l_precision	NUMBER;		   -- precision
lc_currency_code	VARCHAR2(20);
ln_detail_amount	NUMBER;
ln_exchange_rate	NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     debug(  'arp_util.calc_acctd_amount()+');
     debug(  '-- p_currency = '||p_currency);
     debug(  '-- p_precision = '||to_number(p_precision));
     debug(  '-- p_mau = '||TO_NUMBER(p_mau));
     debug(  '-- p_rate = '||TO_NUMBER(p_rate));
     debug(  '-- p_type = '||p_type);
     debug(  '-- p_master_from = '||TO_NUMBER(p_master_from));
     debug(  '-- p_acctd_master_from = '||TO_NUMBER(p_acctd_master_from));
     debug(  '-- p_detail= '||TO_NUMBER(p_detail));
     debug(  '-- p_master_to = '||TO_NUMBER(p_master_to));
     debug(  '-- p_acctd_master_to = '||TO_NUMBER(p_acctd_master_to));
     debug(  '-- p_acctd_detail = '||TO_NUMBER(p_acctd_detail));
  END IF;

  -- If detail not passed default to zero
  ln_detail_amount := NVL(p_detail,0);
  ln_exchange_rate := NVL(p_rate,1);

  -- Determine if currency is functional currency.
  -- If a rate <> 1 is given, assume the currency to be
  -- foreign.
/*
  -- comment to fix bug 1353061
  IF (ln_exchange_rate = 1) THEN
    l_functional := TRUE;
  ELSE
    l_functional := FALSE;
  END IF;
*/
/*
  IF (NOT l_functional) THEN
    IF (NOT(p_currency IS NULL)) THEN
      SELECT minimum_accountable_unit,
             precision
      INTO   l_mau,
	     l_precision
      FROM   fnd_currencies
      WHERE  currency_code = p_currency;
    ELSE
      IF (NOT( (p_precision IS NULL ) AND (p_mau IS NULL))) THEN
        l_precision := p_precision;
        l_mau := p_mau;
      ELSE
        SELECT	c.minimum_accountable_unit,
		c.precision
        INTO	l_mau,
		l_precision
        FROM 	fnd_currencies		c,
		gl_sets_of_books	sob,
		ar_system_parameters	sp
        WHERE	sob.set_of_books_id	= sp.set_of_books_id
	  AND	c.currency_code		= sob.currency_code;
      END IF;
    END IF;
  END IF;
*/

  lc_currency_code := NVL(p_currency, arpcurr.FunctionalCurrency);

  -- all variables are now initialized.
  -- calculate the new p_master_to amount:

/*
  IF (p_type = '+') THEN
    p_master_to := p_master_from + p_detail;
  ELSE
    p_master_to := p_master_from - p_detail;
  END IF;
*/

  IF (p_type = '+') THEN
    p_master_to := p_master_from + ln_detail_amount;
  ELSE
    p_master_to := p_master_from - ln_detail_amount;
  END IF;


  -- now calculate the accounted version of master_to:

/*
  IF (l_functional) THEN
    p_acctd_master_to := p_master_to;
  ELSE
    p_acctd_master_to := p_master_to * p_rate;
  END IF;
*/

  IF PG_DEBUG in ('Y', 'C') THEN
     debug(  'First functional_amount call');
     debug(  '-- lc_currency_code = '|| lc_currency_code);
     debug(  '-- p_master_to = '|| to_char(p_master_to));
     debug(  '-- p_rate = '|| to_char(p_rate));
  END IF;

  IF (p_master_to IS NOT NULL)
  THEN
    p_acctd_master_to := arp_util.functional_amount(
	  amount	=> p_master_to
	, currency_code => lc_currency_code
	, exchange_rate => ln_exchange_rate
	, precision	=> p_precision
	, min_acc_unit	=> p_mau);
  END IF;

  -- calculate the accounted version of master_from:

  IF PG_DEBUG in ('Y', 'C') THEN
     debug(  'After First functional_amount call');
  END IF;

  IF (p_master_from IS NULL)
  THEN
    p_acctd_master_from := NULL;

  ELSIF (p_acctd_master_from IS NULL and p_master_from IS NOT NULL)
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(  'Second functional_amount call');
    END IF;
    p_acctd_master_from := arp_util.functional_amount(
          amount        => p_master_from
        , currency_code => lc_currency_code
        , exchange_rate => ln_exchange_rate
        , precision     => p_precision
        , min_acc_unit  => p_mau);
  END IF;


/*
  IF (p_acctd_master_from IS NULL) THEN
    IF (l_functional = TRUE) THEN
      p_acctd_master_from := p_master_from;
    ELSE
      p_acctd_master_from := p_rate * p_master_from;
    END IF;
  END IF;
*/

  -- round the amounts

/*
  IF (l_functional = FALSE) THEN
    IF (l_mau IS NULL) THEN
      p_acctd_master_to := ROUND(p_acctd_master_to, l_precision);
      p_acctd_master_from := ROUND(p_acctd_master_from, l_precision);
    ELSE
      p_acctd_master_to := round(p_acctd_master_to/l_mau,0)*l_mau;
      p_acctd_master_from := round(p_acctd_master_from/l_mau,0)*l_mau;
    END IF;
  END IF;
*/

  IF (l_functional = TRUE) THEN
    p_acctd_detail := p_detail;
  ELSE
    /*4084266*/
    IF p_detail = 0 AND p_master_to=p_master_from THEN
       p_acctd_master_to:=p_acctd_master_from;
    END IF;
    IF (p_type = '+') THEN
      p_acctd_detail := p_acctd_master_to - p_acctd_master_from;
    ELSE
      p_acctd_detail := p_acctd_master_from - p_acctd_master_to;
    END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     debug(  '-- ** Procedure returns values:');
     debug(  '-- p_master_to : '||to_char(p_master_to));
     debug(  '-- p_acctd_master_to : '||to_char(p_acctd_master_to));
     debug(  '-- p_acctd_detail : '||to_char(p_acctd_detail));
     debug(  'arp_util.calc_acctd_amount()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         debug(  'Exception: arp_util.calc_acctd_amount()');
      END IF;
      RAISE;

END; -- calc_acctd_amount()



-- Bug5041260
PROCEDURE calc_accounted_amount(
	p_currency		IN	VARCHAR2,
	p_precision		IN	NUMBER,
	p_mau			IN	NUMBER,
	p_rate			IN	NUMBER,
	p_type			IN	VARCHAR2,
	p_master_from		IN	NUMBER,
	p_acctd_master_from	IN OUT NOCOPY	NUMBER,
	p_detail		IN	NUMBER,
	p_master_to		IN OUT NOCOPY 	NUMBER,
	p_acctd_master_to	IN OUT NOCOPY	NUMBER,
	p_acctd_detail		IN OUT NOCOPY	NUMBER
			) IS
--
-- Local Variables:
--
l_functional	BOOLEAN;           -- flag: TRUE if functional currency
l_mau		NUMBER;		   -- minimum accounting unit
l_precision	NUMBER;		   -- precision
lc_currency_code	VARCHAR2(20);
ln_detail_amount	NUMBER;
ln_exchange_rate	NUMBER;

BEGIN
  -- If detail not passed default to zero
  ln_detail_amount := NVL(p_detail,0);
  ln_exchange_rate := NVL(p_rate,1);

--Need to pass the currency code as the functional currency
   lc_currency_code := p_currency;


  -- all variables are now initialized.
  -- calculate the new p_master_to amount:


  IF (p_type = '+') THEN
    p_master_to := p_master_from + ln_detail_amount;
  ELSE
    p_master_to := p_master_from - ln_detail_amount;
  END IF;


  IF (p_master_to IS NOT NULL)
  THEN
    p_acctd_master_to := arp_util.func_amount(
	  amount	=> p_master_to
	, currency_code => lc_currency_code
	, exchange_rate => ln_exchange_rate
	, precision	=> p_precision
	, min_acc_unit	=> p_mau);
  END IF;

  -- calculate the accounted version of master_from:
/*
  IF PG_DEBUG in ('Y', 'C') THEN
     debug(  'After First functional_amount call');
  END IF;
*/
  IF (p_master_from IS NULL)
  THEN
    p_acctd_master_from := NULL;

  ELSIF (p_acctd_master_from IS NULL and p_master_from IS NOT NULL)
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(  'Second functional_amount call');
    END IF;

    p_acctd_master_from := arp_util.func_amount(
          amount        => p_master_from
        , currency_code => lc_currency_code
        , exchange_rate => ln_exchange_rate
        , precision     => p_precision
        , min_acc_unit  => p_mau);


  END IF;



  IF (l_functional = TRUE) THEN
    p_acctd_detail := p_detail;
  ELSE
    /*4084266*/
    IF p_detail = 0 AND p_master_to=p_master_from THEN
       p_acctd_master_to:=p_acctd_master_from;
    END IF;
    IF (p_type = '+') THEN
      p_acctd_detail := p_acctd_master_to - p_acctd_master_from;
    ELSE
      p_acctd_detail := p_acctd_master_from - p_acctd_master_to;
    END IF;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         debug(  'Exception: arp_util.calc_accounted_amount()');
      END IF;
      RAISE;

END; -- calc_accounted_amount()


-- ########################## TEST FUNCTION ###############################
-- This function contains tests for calc_acctd_amount.  It is NOT used for
-- the actual product.

PROCEDURE calc_acctd_amount_test IS
--
acctd_master_from	NUMBER;
master_to		NUMBER;
acctd_master_to		NUMBER;
acctd_detail		NUMBER;
--
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     debug(  'arp_util.calc_amount_test()+');
     debug(  'Test 1:');
  END IF;

  acctd_master_from := NULL;
  master_to := NULL;
  acctd_master_to := NULL;
  acctd_detail := NULL;

--  calc_acctd_amount(NULL, 2, NULL, NULL, '-', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);


--  calc_acctd_amount(NULL, 2, NULL, .33333333, '-', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);


--  calc_acctd_amount(NULL, 2, NULL, .3333333333, '+', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);


-- calc_acctd_amount(NULL, NULL, NULL, .3333333333, '+', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);

-- calc_acctd_amount('ITL', NULL, NULL, .3333333333, '+', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);


-- calc_acctd_amount(NULL, NULL, 0.25, .3333333333, '+', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);


--  calc_acctd_amount(NULL, 1, 0.25, .3333333333, '+', 50, acctd_master_from,
--		    50, master_to, acctd_master_to, acctd_detail);

acctd_master_from := 18;

 calc_acctd_amount(NULL, NULL, NULL, .3333333333, '+', 50, acctd_master_from,  50, master_to, acctd_master_to, acctd_detail);



END; -- test()




-----------------------------------------------------------------------------
-- Date functions
-----------------------------------------------------------------------------
--
--
--  FUNCTION NAME validate_and_default_gl_date
--
--  DESCRIPTION
-- This is a just a stub to call the validate_and_default_gl_date in
-- ARP_STANDARD package
--
--  PUBLIC PROCEDURES/FUNCTIONS
--
--  PRIVATE PROCEDURES/FUNCTIONS
--
--  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
--  PARAMETERS - Look at ARP_STANDARD.validate_and_default_gl_date
--
--  HISTORY
--  10-OCT-95      G vaidees Created
--
--
FUNCTION validate_and_default_gl_date(
                                       gl_date                in date,
                                       trx_date               in date,
                                       validation_date1       in date,
                                       validation_date2       in date,
                                       validation_date3       in date,
                                       default_date1          in date,
                                       default_date2          in date,
                                       default_date3          in date,
                                       p_allow_not_open_flag  in varchar2,
                                       p_invoicing_rule_id    in varchar2,
                                       p_set_of_books_id      in number,
                                       p_application_id       in number,
                                       default_gl_date       out NOCOPY date,
                                       defaulting_rule_used  out NOCOPY varchar2,
                                       error_message         out NOCOPY varchar2
                                     ) RETURN BOOLEAN IS
l_result BOOLEAN;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_and_default_gl_date()+' );
    END IF;
    --
    l_result := arp_standard.validate_and_default_gl_date(
                        gl_date, trx_date,
                        validation_date1, validation_date2, validation_date3,
                        default_date1, default_date2, default_date3,
                        p_allow_not_open_flag, p_invoicing_rule_id,
                        p_set_of_books_id, p_application_id,
                        default_gl_date, defaulting_rule_used, error_message );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_and_default_gl_date()-' );
    END IF;
    --
    RETURN l_result;
    --
    EXCEPTION
         WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             debug(   'EXCEPTION: arp_util.validate_and_default_gl_date' );
          END IF;
              RAISE;
END validate_and_default_gl_date;


--
--  FUNCTION NAME validate_and_default_gl_date
--
--  DESCRIPTION
--    Procedure to validate and default gl date for a given date and also
--    return the period name corresponding to the validated gl date.
--
--  PUBLIC PROCEDURES/FUNCTIONS
--
--  PRIVATE PROCEDURES/FUNCTIONS
--
--  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--               arp_standard.validate_and_default_gl_date
--               arp_standard.gl_period_name
--
--  PARAMETERS - Look at ARP_STANDARD.validate_and_default_gl_date
--               p_period_name
--  HISTORY
--  21-NOV-95      Subash C     Created
--
--

FUNCTION validate_and_default_gl_date(
                                       gl_date                in date,
                                       trx_date               in date,
                                       validation_date1       in date,
                                       validation_date2       in date,
                                       validation_date3       in date,
                                       default_date1          in date,
                                       default_date2          in date,
                                       default_date3          in date,
                                       p_allow_not_open_flag  in varchar2,
                                       p_invoicing_rule_id    in varchar2,
                                       p_set_of_books_id      in number,
                                       p_application_id       in number,
                                       default_gl_date       out NOCOPY date,
                                       defaulting_rule_used  out NOCOPY varchar2,
                                       error_message         out NOCOPY varchar2,
                                       p_period_name         out NOCOPY varchar2
                                     ) RETURN BOOLEAN IS
l_result BOOLEAN;
l_default_gl_date  date;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_and_default_gl_date()+' );
    END IF;
    --
    l_result := arp_standard.validate_and_default_gl_date(
                       gl_date, trx_date,
                       validation_date1, validation_date2, validation_date3,
                       default_date1, default_date2, default_date3,
                       p_allow_not_open_flag, p_invoicing_rule_id,
                       p_set_of_books_id, p_application_id,
                       l_default_gl_date, defaulting_rule_used, error_message );

    default_gl_date := l_default_gl_date;

    --
    -- get period name for the gl date
    --
    p_period_name := arp_standard.gl_period_name(l_default_gl_date);

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_and_default_gl_date()-' );
    END IF;
    --
    RETURN l_result;
    --

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'EXCEPTION: arp_util.validate_and_default_gl_date' );
    END IF;
    RAISE;

END validate_and_default_gl_date;

--
--
--
FUNCTION is_gl_date_valid( p_gl_date IN DATE )
  RETURN BOOLEAN IS

    l_num_return_value 	NUMBER;
    l_bool		BOOLEAN;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug(   'arp_util.is_gl_date_valid()+' );
   END IF;

   IF ( p_gl_date is NULL ) THEN

    	IF PG_DEBUG in ('Y', 'C') THEN
    	   debug(   'arp_util.is_gl_date_valid()-' );
    	END IF;
        RETURN FALSE;

   END IF;

    l_bool := arp_standard.is_gl_date_valid( p_gl_date,
				  	 NULL,   -- trx_date
					 NULL,   -- validation_date1
					 NULL,   -- validation_date2
					 NULL,   -- validation_date3
					 'N',    -- allow_not_open_flag
				  	 arp_global.set_of_books_id,
				  	 arp_global.g_ar_app_id,
					 TRUE    -- check_period_status
                                       );

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.is_gl_date_valid()-' );
    END IF;
    RETURN l_bool;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'EXCEPTION: arp_util.is_gl_date_valid()' );
    END IF;
    RAISE;
END is_gl_date_valid;
--
--
FUNCTION is_gl_date_valid( p_gl_date IN DATE,
			   p_allow_not_open_flag IN VARCHAR )
  RETURN BOOLEAN IS

    l_num_return_value NUMBER;
    l_bool		BOOLEAN;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug(   'arp_util.is_gl_date_valid()+' );
   END IF;

   IF( p_gl_date is NULL ) THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           debug(   'arp_util.is_gl_date_valid()-' );
        END IF;
        RETURN FALSE;

   END IF;

   l_bool := arp_standard.is_gl_date_valid( p_gl_date,
				  	 NULL,   -- trx_date
					 NULL,   -- validation_date1
					 NULL,   -- validation_date2
					 NULL,   -- validation_date3
					 p_allow_not_open_flag,
				  	 arp_global.set_of_books_id,
				  	 arp_global.g_ar_app_id,
					 TRUE    -- check_period_status
                                       );

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.is_gl_date_valid()-' );
    END IF;
    RETURN l_bool;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'EXCEPTION: arp_util.is_gl_date_valid()' );
    END IF;
    RAISE;
END is_gl_date_valid;
--
--
--
--  PROCEDURE NAME validate_gl_date
--
--  DESCRIPTION
--         Validates GL date. This procedure just calls the is_gl_date_valid
--         function and raises an exception depending on the return value
--
--  PUBLIC PROCEDURES/FUNCTIONS
--
--  PRIVATE PROCEDURES/FUNCTIONS
--
--  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
--  PARAMETERS
--        p_gl_date - Input GL date
--
--  HISTORY
--  14-JUL-95      G vaidees Created
--
PROCEDURE validate_gl_date( p_gl_date IN DATE,
                            p_module_name IN VARCHAR2,
                            p_module_version IN VARCHAR2 ) IS
    l_ret_code     BOOLEAN;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_gl_date()+' );
    END IF;
    --
    l_ret_code := is_gl_date_valid( p_gl_date );
    IF ( l_ret_code = FALSE ) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
        FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_gl_date ) );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_gl_date()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                debug(   'EXCEPTION: arp_util.validate_gl_date' );
             END IF;
             RAISE;
END validate_gl_date;

--
--
--  PROCEDURE NAME validate_gl_date
--
--  DESCRIPTION
--         Overloaded procedure to validate GL date and to get period name
--         corresponding to the GL date.
--
--  PUBLIC PROCEDURES/FUNCTIONS
--
--  PRIVATE PROCEDURES/FUNCTIONS
--
--  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--               arp_standard.gl_period_name
--
--  PARAMETERS
--        p_gl_date        - Input GL date
--        p_module_name    - Input module name
--        p_module_version - Input module version
--        p_period_name    - Output period name
--
--  HISTORY
--  21-NOV-95      Subash C    Created
--

PROCEDURE validate_gl_date( p_gl_date IN DATE,
                            p_module_name IN VARCHAR2,
                            p_module_version IN VARCHAR2,
                            p_period_name OUT NOCOPY varchar2 ) IS
    l_ret_code     BOOLEAN;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_gl_date()+' );
    END IF;
    --
    validate_gl_date(p_gl_date,
                     p_module_name,
                     p_module_version);

    --
    -- get period name
    --
    p_period_name := arp_standard.gl_period_name(p_gl_date);

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.validate_gl_date()-' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                debug(   'EXCEPTION: arp_util.validate_gl_date' );
             END IF;
             RAISE;
END validate_gl_date;

--
--
-----------------------------------------------------------------------------
-- Misc functions
-----------------------------------------------------------------------------
PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY NUMBER ) IS
BEGIN

    IF( dbms_sql.is_open( p_cursor_handle ) ) THEN
        dbms_sql.close_cursor( p_cursor_handle );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_util.close_cursor()', arp_global.MSG_LEVEL_BASIC);
        RAISE;
END close_cursor;

/* ==================================================================================
 | PROCEDURE Set_Buckets
 |
 | DESCRIPTION
 |      Sets accounted amount base for tax, charges, freight, line
 |      from amount buckets of the Receivable application or adjustment.
 |      We do not store accounted amounts for individual buckets in the
 |      payment schedule or on application or adjustment. Hence the accounted
 |      amounts are derived by this routine in order, Tax, Charges, Line and
 |      Freight by using the foreign currency amounts and multiplying with the
 |      exchange rate to get the base or functional currency accounted amounts
 |      with the rounding correction going to the last non zero amount
 |      bucket in that order. This is the standard that has been established and
 |      the same algorithm must be used to retain consistency. The usage came
 |      into being during the Tax accounting for Discounts and Adjustments,
 |      however in future projects this will be required. This could not be
 |      derived as an effect on payment schedule becuause the payment schedules
 |      are update before or after activity by various modules. In addition
 |      depending on the bucket which is first choosen to be calculated the
 |      rounding correction is different and goes to the last bucket. The
 |      approach by this routine is the most desirable way to do things.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_header_acctd_amt   IN      Header accounted amount to reconcile
 |      p_base_currency      IN      Base or functional currency
 |      p_exchange_rate      IN      Exchange rate
 |      p_base_precision     IN      Base precision
 |      p_base_min_acc_unit  IN      Minimum accountable unit
 |      p_tax_amt            IN      Tax amount in currency of Transaction
 |      p_charges_amt        IN      Charges amount in currency of Transaction
 |      p_freight_amt        IN      Freight amount in currency of Transaction
 |      p_line_amt           IN      Line amount in currency of Transaction
 |      p_tax_acctd_amt      IN OUT NOCOPY Tax accounted amount in functional currency
 |      p_charges_acctd_amt  IN OUT NOCOPY Charges accounted amount in functional currency
 |      p_freight_acctd_amt  IN OUT NOCOPY Freight accounted amount in functional currency
 |      p_line_acctd_amt     IN OUT NOCOPY Line accounted amount in functional currency
 |
 | Notes
 |      Introduced for 11.5 Tax accounting - used by ARALLOCB.pls and ARTWRAPB.pls
 *===================================================================================*/
PROCEDURE Set_Buckets(
      p_header_acctd_amt   IN     NUMBER        ,
      p_base_currency      IN     fnd_currencies.currency_code%TYPE,
      p_exchange_rate      IN     NUMBER        ,
      p_base_precision     IN     NUMBER        ,
      p_base_min_acc_unit  IN     NUMBER        ,
      p_tax_amt            IN     NUMBER        ,
      p_charges_amt        IN     NUMBER        ,
      p_line_amt           IN     NUMBER        ,
      p_freight_amt        IN     NUMBER        ,
      p_tax_acctd_amt      IN OUT NOCOPY NUMBER        ,
      p_charges_acctd_amt  IN OUT NOCOPY NUMBER        ,
      p_line_acctd_amt     IN OUT NOCOPY NUMBER        ,
      p_freight_acctd_amt  IN OUT NOCOPY NUMBER         ) IS

l_run_amt_tot         NUMBER;
l_run_acctd_amt_tot   NUMBER;
l_last_bucket         VARCHAR2(1);

/* Bug 2013601
 Variables to hold running total of amount, accounted amount and the
 total adjusted amount */
l_run_oth_amt_tot       NUMBER;
l_run_oth_acctd_amt_tot NUMBER;
l_amt_tot               NUMBER;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        debug(   'ARP_UTIL.Set_Buckets()+');
     END IF;

     l_run_amt_tot       := 0;
     l_run_acctd_amt_tot := 0;

     /* Bug 2013601
        Initialise the variables */
     l_run_oth_amt_tot := 0;
     l_run_oth_acctd_amt_tot := 0;
     l_amt_tot := p_tax_amt + p_charges_amt + p_line_amt + p_freight_amt ;

     l_run_amt_tot                 := l_run_amt_tot + p_tax_amt;
     p_tax_acctd_amt               := arpcurr.functional_amount(
                                          l_run_amt_tot,
                                          p_base_currency,
                                          p_exchange_rate,
                                          p_base_precision,
                                          p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot           := l_run_acctd_amt_tot + p_tax_acctd_amt;

     IF p_tax_acctd_amt <> 0 THEN
        l_last_bucket    := 'T';
     END IF;

     l_run_amt_tot                := l_run_amt_tot + p_charges_amt;
     p_charges_acctd_amt          := arpcurr.functional_amount(
                                         l_run_amt_tot,
                                         p_base_currency,
                                         p_exchange_rate,
                                         p_base_precision,
                                         p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot          := l_run_acctd_amt_tot + p_charges_acctd_amt;

     IF p_charges_acctd_amt <> 0 THEN
        l_last_bucket    := 'C';
     END IF;

     l_run_amt_tot                := l_run_amt_tot + p_line_amt;
     p_line_acctd_amt             := arpcurr.functional_amount(
                                         l_run_amt_tot,
                                         p_base_currency,
                                         p_exchange_rate,
                                         p_base_precision,
                                         p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot          := l_run_acctd_amt_tot + p_line_acctd_amt;

     IF p_line_acctd_amt <> 0 THEN
        l_last_bucket    := 'L';
     END IF;

     l_run_amt_tot                := l_run_amt_tot + p_freight_amt;
     p_freight_acctd_amt          := arpcurr.functional_amount(
                                         l_run_amt_tot,
                                         p_base_currency,
                                         p_exchange_rate,
                                         p_base_precision,
                                         p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot          := l_run_acctd_amt_tot + p_freight_acctd_amt;

     IF p_freight_acctd_amt <> 0 THEN
        l_last_bucket    := 'F';
     END IF;

 /* 2013601
       When none of the buckets have value for the acctd_amt
       by direct multiplication of amount adjusted with the rate,
       recalculate the values from the total accounted amount adjusted */

     IF l_last_bucket IS NULL THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              debug(   'l_last_bucket is null');
           END IF;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_tax_amt;
           p_tax_acctd_amt         := arpcurr.Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot + p_tax_acctd_amt;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_charges_amt;
           p_charges_acctd_amt     := arpcurr.Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot +p_charges_acctd_amt;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_line_amt;
           p_line_acctd_amt        := arpcurr.Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot + p_line_acctd_amt;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_freight_amt;
           p_freight_acctd_amt     := arpcurr.Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot + p_freight_acctd_amt;

           IF PG_DEBUG in ('Y', 'C') THEN
              debug(   'p_tax_acctd_amt = '||p_tax_acctd_amt);
              debug(   'p_charges_acctd_amt = '||p_charges_acctd_amt);
              debug(   'p_line_acctd_amt = '||p_line_acctd_amt);
              debug(   'p_freight_acctd_amt = '||p_freight_acctd_amt);
           END IF;

     ELSIF    l_last_bucket = 'T' THEN
           p_tax_acctd_amt     := p_tax_acctd_amt     - (l_run_acctd_amt_tot - p_header_acctd_amt);
     ELSIF l_last_bucket = 'C' THEN
           p_charges_acctd_amt := p_charges_acctd_amt - (l_run_acctd_amt_tot - p_header_acctd_amt);
     ELSIF l_last_bucket = 'L' THEN
           p_line_acctd_amt    := p_line_acctd_amt    - (l_run_acctd_amt_tot - p_header_acctd_amt);
     ELSIF l_last_bucket = 'F' THEN
           p_freight_acctd_amt := p_freight_acctd_amt - (l_run_acctd_amt_tot - p_header_acctd_amt);
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        debug(   'ARP_UTIL.Set_Buckets()-');
     END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug(  'EXCEPTION: ARP_UTIL.Set_Buckets');
     END IF;
     RAISE;

END Set_Buckets;

--
--
-----------------------------------------------------------------------------
-- Function to support server-side patch-level identification
-----------------------------------------------------------------------------

-- Bug# 1759719

FUNCTION ar_server_patch_level RETURN VARCHAR2 IS
  l_server_patchset_level VARCHAR2(30) ;
BEGIN

  IF PG_AR_SERVER_PATCH_LEVEL IS NULL
  THEN
     BEGIN
       SELECT patch_level
       INTO   l_server_patchset_level
       FROM   FND_PRODUCT_INSTALLATIONS
       WHERE  application_id = 222 ;

       PG_AR_SERVER_PATCH_LEVEL := l_server_patchset_level ;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         PG_AR_SERVER_PATCH_LEVEL := NULL ;

     END ;

  END IF ;

  RETURN PG_AR_SERVER_PATCH_LEVEL ;

END;

PROCEDURE Validate_Desc_Flexfield(
                          p_desc_flex_rec       IN OUT NOCOPY  arp_util.attribute_rec_type,
                          p_desc_flex_name      IN VARCHAR2,
                          p_return_status       IN OUT NOCOPY  varchar2
                         ) IS

l_flex_name     fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name     VARCHAR2(50);
l_flex_exists  VARCHAR2(1);
CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM fnd_descriptive_flexs
  WHERE application_id = 222
    and descriptive_flexfield_name = p_desc_flex_name;
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         debug(  'arp_util.Validate_Desc_Flexfield()+');
      END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN desc_flex_exists;
      FETCH desc_flex_exists INTO l_flex_exists;
      IF desc_flex_exists%NOTFOUND THEN
       CLOSE desc_flex_exists;
       p_return_status :=  FND_API.G_RET_STS_ERROR;
       return;
      END IF;
      CLOSE desc_flex_exists;
     fnd_flex_descval.set_context_value(p_desc_flex_rec.attribute_category);

     fnd_flex_descval.set_column_value('ATTRIBUTE1', p_desc_flex_rec.attribute1);
     fnd_flex_descval.set_column_value('ATTRIBUTE2', p_desc_flex_rec.attribute2);
     fnd_flex_descval.set_column_value('ATTRIBUTE3', p_desc_flex_rec.attribute3);
     fnd_flex_descval.set_column_value('ATTRIBUTE4', p_desc_flex_rec.attribute4);
     fnd_flex_descval.set_column_value('ATTRIBUTE5', p_desc_flex_rec.attribute5);
     fnd_flex_descval.set_column_value('ATTRIBUTE6', p_desc_flex_rec.attribute6);
     fnd_flex_descval.set_column_value('ATTRIBUTE7', p_desc_flex_rec.attribute7);
     fnd_flex_descval.set_column_value('ATTRIBUTE8', p_desc_flex_rec.attribute8);
     fnd_flex_descval.set_column_value('ATTRIBUTE9', p_desc_flex_rec.attribute9);
     fnd_flex_descval.set_column_value('ATTRIBUTE10', p_desc_flex_rec.attribute10);
     fnd_flex_descval.set_column_value('ATTRIBUTE11',p_desc_flex_rec.attribute11);
     fnd_flex_descval.set_column_value('ATTRIBUTE12', p_desc_flex_rec.attribute12);
     fnd_flex_descval.set_column_value('ATTRIBUTE13', p_desc_flex_rec.attribute13);
     fnd_flex_descval.set_column_value('ATTRIBUTE14', p_desc_flex_rec.attribute14);
     fnd_flex_descval.set_column_value('ATTRIBUTE15', p_desc_flex_rec.attribute15);

     /*Changed the 'V' with 'I' in below call for bug3291407 */
    IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') )
     THEN

       FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
       FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name);
       FND_MSG_PUB.ADD ;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

      l_count := fnd_flex_descval.segment_count;

      /*Changed the segment_value with segment_id for bug 3291407 */
      FOR i in 1..l_count LOOP
        l_col_name := fnd_flex_descval.segment_column_name(i);

        IF l_col_name = 'ATTRIBUTE1' THEN
          p_desc_flex_rec.attribute1 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE_CATEGORY'  THEN
          p_desc_flex_rec.attribute_category := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE2' THEN
          p_desc_flex_rec.attribute2 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE3' THEN
          p_desc_flex_rec.attribute3 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE4' THEN
          p_desc_flex_rec.attribute4 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE5' THEN
          p_desc_flex_rec.attribute5 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE6' THEN
          p_desc_flex_rec.attribute6 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE7' THEN
          p_desc_flex_rec.attribute7 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE8' THEN
          p_desc_flex_rec.attribute8 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE9' THEN
          p_desc_flex_rec.attribute9 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE10' THEN
          p_desc_flex_rec.attribute10 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE11' THEN
          p_desc_flex_rec.attribute11 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE12' THEN
          p_desc_flex_rec.attribute12 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE13' THEN
          p_desc_flex_rec.attribute13 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE14' THEN
          p_desc_flex_rec.attribute14 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE15' THEN
          p_desc_flex_rec.attribute15 := fnd_flex_descval.segment_id(i);
        END IF;

        IF i > l_count  THEN
          EXIT;
        END IF;
       END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
           debug(  'attribute_category  : '||p_desc_flex_rec.attribute_category);
           debug(  'attribute1          : '||p_desc_flex_rec.attribute1);
           debug(  'attribute2          : '||p_desc_flex_rec.attribute2);
           debug(  'attribute3          : '||p_desc_flex_rec.attribute3);
           debug(  'attribute4          : '||p_desc_flex_rec.attribute4);
           debug(  'attribute5          : '||p_desc_flex_rec.attribute5);
           debug(  'attribute6          : '||p_desc_flex_rec.attribute6);
           debug(  'attribute7          : '||p_desc_flex_rec.attribute7);
           debug(  'attribute8          : '||p_desc_flex_rec.attribute8);
           debug(  'attribute9          : '||p_desc_flex_rec.attribute9);
           debug(  'attribute10         : '||p_desc_flex_rec.attribute10);
           debug(  'attribute11         : '||p_desc_flex_rec.attribute11);
           debug(  'attribute12         : '||p_desc_flex_rec.attribute12);
           debug(  'attribute13         : '||p_desc_flex_rec.attribute13);
           debug(  'attribute14         : '||p_desc_flex_rec.attribute14);
           debug(  'attribute15         : '||p_desc_flex_rec.attribute15);
           debug(  'arp_util.Validate_Desc_Flexfield()-');
        END IF;
END Validate_Desc_Flexfield;

--
--
--This function will get the ID when you pass the corresponding number/or name
--for an entity.The following entitiy can be passed to get the corresponding ID
--CUSTOMER_NUMBER,CUSTOMER_NAME,RECEIPT_METHOD_NAME,CUST_BANK_ACCOUNT_NUMBER
--CUST_BANK_ACCOUNT_NAME,REMIT_BANK_ACCOUNT_NUMBER,REMIT_BANK_ACCOUNT_NAME,
--CURRENCY_NAME,

FUNCTION Get_Id(
                  p_entity    IN VARCHAR2,
                  p_value     IN VARCHAR2,
                  p_return_status OUT NOCOPY VARCHAR2
               ) RETURN VARCHAR2 IS

l_cached_id    VARCHAR2(100);
l_selected_id  VARCHAR2(100);
l_index        BINARY_INTEGER;

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         debug('Get_Id()+ ');
      END IF;
      IF    ( p_value  IS NULL )
      THEN
           RETURN(NULL);
      ELSE
                IF      ( p_entity = 'CUSTOMER_NUMBER' )
                THEN

                    /* modified for tca uptake */
                   /* fixed bug 1544201:  removed customer_prospect_code
                      decode statement as everyone is now considered a
                      customer */

                    SELECT c.cust_account_id
                    INTO   l_selected_id
                    FROM   hz_cust_accounts c,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  c.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           c.account_number = p_value
                     AND  c.party_id = party.party_id;
                 ELSIF   ( p_entity = 'CUSTOMER_NAME' )
                 THEN

                     /* modified for tca uptake */
                     /* fixed bug 1544201:  removed customer_prospect_code
                        decode statement as everyone is now considered a
                        customer */
                    SELECT cust_acct.cust_account_id
                    INTO   l_selected_id
                    FROM   hz_cust_accounts cust_acct,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust_acct.cust_account_id = cp.cust_account_id (+)
                      and  cust_acct.party_id = party.party_id
                      and  cp.site_use_id is null
                      and  party.party_name = p_value;
                  ELSIF  (p_entity = 'RECEIPT_METHOD_NAME' )

                 THEN

                    SELECT receipt_method_id
                    INTO   l_selected_id
                    FROM   ar_receipt_methods
                    WHERE  name = p_value;

                ELSIF  (p_entity = 'CUST_BANK_ACCOUNT_NUMBER')
                 THEN

                    SELECT ext_bank_account_id
                    INTO   l_selected_id
                    FROM   iby_ext_bank_accounts
                    WHERE ((bank_account_num = p_value) OR
                           (bank_account_num_hash1=
                            iby_security_pkg.Get_Hash(p_value,'F') and
                            bank_account_num_hash2=
                            iby_security_pkg.Get_Hash(p_value,'T')
                           )
                          );

                ELSIF  (p_entity = 'CUST_BANK_ACCOUNT_NAME')
                 THEN

                    SELECT ext_bank_account_id
                    INTO   l_selected_id
                    FROM   iby_ext_bank_accounts
                    WHERE  bank_account_name = p_value;

                ELSIF  (p_entity = 'REMIT_BANK_ACCOUNT_NUMBER')
                 THEN
                    SELECT bank_account_id
                    INTO   l_selected_id
                    FROM   ce_bank_accounts
                    WHERE  bank_account_num = p_value;
                ELSIF  (p_entity = 'REMIT_BANK_ACCOUNT_NAME')
                  THEN
                    SELECT bank_account_id
                    INTO   l_selected_id
                    FROM   ce_bank_accounts
                    WHERE  bank_account_name = p_value;

                ELSIF   (p_entity = 'CURRENCY_NAME')
                   THEN
                     SELECT currency_code
                     INTO   l_selected_id
                     FROM   fnd_currencies_vl
                     WHERE  name = p_value;
                ELSIF   (p_entity = 'EXCHANGE_RATE_TYPE_NAME')
                   THEN
                      SELECT conversion_type
                      INTO   l_selected_id
                      FROM   gl_daily_conversion_types
                      WHERE  user_conversion_type = p_value ;

                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   debug(  'Value selected. Entity: '||
                                                    p_entity || ',' ||
                                     '  Value: ' || p_value  || ',' ||
                                     'ID: ' || l_selected_id);
                   debug('Get_Id()- ');
                END IF;

                RETURN( l_selected_id );



      END IF;  -- end p_value is not null case


      IF PG_DEBUG in ('Y', 'C') THEN
         debug('Get_Id()- ');
      END IF;


EXCEPTION

   WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           debug(  'Value not found. Entity: ' ||
                                   p_entity ||'  Value: ' || p_value);
        END IF;
        return(null);
        IF PG_DEBUG in ('Y', 'C') THEN
           debug('Get_Id()- ');
        END IF;
           WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           debug(  'Value not found. Entity: ' ||
                                   p_entity ||'  Value: ' || p_value);
        END IF;
        RAISE;

END Get_Id;

-- Bug# 1842884
-- This function returns the sum of the promised amounts for commitment
-- invoices.  Since it uses the interface_lines table, it is really
-- only useful within the scope of autoinvoice.
-- p_customer_trx_id = trx_id assigned on interface table
-- p_alloc_tax_freight = trx_type.allocate_tax_freight (Y or null)

FUNCTION Get_Promised_Amount(
                  p_customer_trx_id    IN NUMBER,
                  p_alloc_tax_freight  IN VARCHAR2)
         RETURN NUMBER IS

CURSOR C1 (l_customer_trx_id NUMBER, l_alloc_tax_freight VARCHAR2 ) IS
SELECT l.customer_trx_line_id,
       l.link_to_cust_trx_line_id link_to_line_id,
       l.line_type,
       l.extended_amount,
       il.promised_commitment_amount
FROM   ra_interface_lines_gt il,
       ra_customer_trx_lines l
WHERE  l.customer_trx_id = l_customer_trx_id
AND    l.customer_trx_line_id = il.interface_line_id (+)
ORDER  BY l.line_type ;

TYPE trx_line_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
TYPE line_type   IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER ;

l_cust_trx_line_id   trx_line_id ;
l_link_to_line_id    trx_line_id ;
l_extended_amount    trx_line_id ;
l_promised_comm_amt  trx_line_id ;

l_line_type          line_type   ;

l_promised_amount    NUMBER := 0 ;
l_last_index         NUMBER := 0 ;
l_null_prom_comm_amt NUMBER := 0 ;
l_line_count         NUMBER := 0 ;

BEGIN

   --
   -- Bug# 1842884
   -- The promised_commitment_amount in the line includes the commitment amt
   -- for tax and freight.  If the promised_commitment_amount is NULL for
   -- line_type LINE, then arrive at the promised_commitment_amount by
   -- summing up the amounts of LINE, TAX and FREIGHT.  If for one of the
   -- line, the promised_commitment_amount is NULL and for the rest, it is
   -- NOT NULL, then this is not supported.  In that case, treat the
   -- promised_commitment_amount as NULL
   -- If p_alloc_tax_freight is NULL and the promised_commitment_amount
   -- IS NULL, then it should be arrived with only the LINE amounts.
   --

   FOR get_prom_amt in C1 ( p_customer_trx_id, p_alloc_tax_freight )
   LOOP
       l_last_index := l_last_index + 1 ;

       l_cust_trx_line_id( l_last_index ) :=
                          get_prom_amt.customer_trx_line_id ;
       l_link_to_line_id( l_last_index ) :=
                          get_prom_amt.link_to_line_id ;
       l_extended_amount( l_last_index ) :=
                          get_prom_amt.extended_amount ;
       l_promised_comm_amt( l_last_index ) :=
                            get_prom_amt.promised_commitment_amount ;
       l_line_type( l_last_index ) :=
                            get_prom_amt.line_type ;

       IF l_line_type( l_last_index ) = 'LINE'
       THEN
          l_line_count := l_line_count + 1 ;
          IF l_promised_comm_amt( l_last_index ) IS NULL
          THEN
             l_null_prom_comm_amt := l_null_prom_comm_amt + 1 ;
          END IF ;
       END IF ;

   END LOOP ;

   IF l_null_prom_comm_amt > 0 AND
      l_line_count <> l_null_prom_comm_amt
   THEN
     --  there is atleast one line with NULL promised amount
     --  where for the rest the promised amount IS NOT NULL
     RETURN NULL ;
   END IF ;

   FOR i in 1..l_last_index
   LOOP

       -- If all the lines have null promised amount, then
       -- arrive the promised amount by adding the line amounts
       -- of LINE, TAX and FREIGHT for every line

       IF l_line_count = l_null_prom_comm_amt
       THEN
          IF upper(p_alloc_tax_freight) = 'Y' OR
             l_line_type(i) = 'LINE'
          THEN
             l_promised_amount := l_promised_amount + l_extended_amount(i) ;
          END IF ;
       ELSE
          IF l_line_type(i) = 'LINE'
          THEN
             l_promised_amount := l_promised_amount +
                                    l_promised_comm_amt(i) ;
          END IF ;
       END IF ;

   END LOOP ;

   RETURN l_promised_amount ;

EXCEPTION
  WHEN OTHERS
     then RETURN null;

END Get_Promised_Amount;

/* ==========================================================================
 | PROCEDURE Substitute_Ccid
 |
 | DESCRIPTION
 |    Builds the gain, loss, round account based on input parameters
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_coa_id                IN    Chart of Accounts id
 |    p_original_ccid         IN    Original ccid
 |    p_subs_ccid             IN    Substitute ccid
 |    p_actual_ccid           OUT NOCOPY   Actual or return ccid
 *==========================================================================*/
PROCEDURE Substitute_Ccid(p_coa_id        IN  gl_sets_of_books.chart_of_accounts_id%TYPE        ,
                          p_original_ccid IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_subs_ccid     IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_actual_ccid   OUT NOCOPY ar_system_parameters.code_combination_id_gain%TYPE) IS

l_concat_segs           varchar2(240)                                           ;
l_concat_ids            varchar2(2000)                                          ;
l_concat_descs          varchar2(2000)                                          ;
l_arerror               varchar2(2000)                                          ;
l_actual_gain_loss_ccid ar_system_parameters_all.code_combination_id_gain%TYPE  ;
flex_subs_ccid_error    EXCEPTION;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      debug( 'arp_util.Substitute_Ccid()+');
   END IF;

/*----------------------------------------------------------------------------+
 | Set other in out NOCOPY variables used by flex routine                            |
 +----------------------------------------------------------------------------*/
   p_actual_ccid           := NULL;
   l_actual_gain_loss_ccid := NULL; --must always be derived
   l_concat_segs           := NULL;
   l_concat_ids            := NULL;
   l_concat_descs          := NULL;

/*----------------------------------------------------------------------------+
 | Derive gain loss account using flex routine                                |
 +----------------------------------------------------------------------------*/
   IF l_actual_gain_loss_ccid is NULL THEN

      IF NOT ar_flexbuilder_wf_pkg.substitute_balancing_segment (
                                              x_arflexnum     => p_coa_id                         ,
                                              x_arorigccid    => p_original_ccid                  ,
                                              x_arsubsticcid  => p_subs_ccid                      ,
                                              x_return_ccid   => l_actual_gain_loss_ccid          ,
                                              x_concat_segs   => l_concat_segs                    ,
                                              x_concat_ids    => l_concat_ids                     ,
                                              x_concat_descrs => l_concat_descs                   ,
                                              x_arerror       => l_arerror                          ) THEN

       /*----------------------------------------------------------------------------+
        | Invalid account raise user exception                                       |
        +----------------------------------------------------------------------------*/
         RAISE flex_subs_ccid_error;

      END IF;

    /*----------------------------------------------------------------------------+
     | Cache the gain loss account as it has been successfully derived            |
     +----------------------------------------------------------------------------*/

      IF PG_DEBUG in ('Y', 'C') THEN
         debug(  'Flexbuilder : Chart of Accounts ' || p_coa_id);
         debug(  'Flexbuilder : Original CCID     ' || p_original_ccid);
         debug(  'Flexbuilder : Substitute CCID   ' || p_subs_ccid);
         debug(  'Flexbuilder : Actual CCID       ' || l_actual_gain_loss_ccid);
      END IF;

   END IF;

   p_actual_ccid := l_actual_gain_loss_ccid;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug( 'arp_util.Substitute_Ccid()-');
   END IF;

EXCEPTION
WHEN flex_subs_ccid_error  THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('Flexbuilder error: ARP_ALLOCATION_PKG.Substitute_Ccid');
        debug(  'Flexbuilder error: Chart of Accounts ' || p_coa_id);
        debug(  'Flexbuilder error: Original CCID     ' || p_original_ccid);
        debug(  'Flexbuilder error: Substitute CCID   ' || p_subs_ccid);
        debug(  'Flexbuilder error: Actual CCID       ' || l_actual_gain_loss_ccid);
     END IF;
     fnd_message.set_name('AR','AR_FLEX_CCID_ERROR');
     fnd_message.set_token('COA',TO_CHAR(p_coa_id));
     fnd_message.set_token('ORG_CCID',TO_CHAR(p_original_ccid));
     fnd_message.set_token('SUB_CCID',TO_CHAR(p_subs_ccid));
     RAISE;

WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: ARP_ALLOCATION_PKG.Substitute_Ccid');
        debug(  'Flexbuilder error: Chart of Accounts ' || p_coa_id);
        debug(  'Flexbuilder error: Original CCID     ' || p_original_ccid);
        debug(  'Flexbuilder error: Substitute CCID   ' || p_subs_ccid);
        debug(  'Flexbuilder error: Actual CCID       ' || l_actual_gain_loss_ccid);
     END IF;
     RAISE;

END Substitute_Ccid;

/* ==========================================================================
 | PROCEDURE Dynamic_Select
 |
 | DESCRIPTION
 |    Executes a dynamic select statement
 |    Intended for client side calls where dynamic sql is not supported
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |    p_query                 IN    Dynamically assembled query to be executed
 |    p_result                OUT NOCOPY   Container for result column
 |
 | NOTES
 |    Only one column can be returned
 *==========================================================================*/
PROCEDURE Dynamic_Select(p_query  IN  VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2)
IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug( 'arp_util.Dynamic_Select()+');
   END IF;
      EXECUTE IMMEDIATE p_query INTO p_result;
   IF PG_DEBUG in ('Y', 'C') THEN
      debug( 'arp_util.Dynamic_Select()-');
   END IF;
EXCEPTION
WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: ARP_UTIL.Dynamic_Select');
        debug('Dynamic_Select: ' || 'SELECT stmt : '||p_query);
     END IF;
END Dynamic_Select;

-- kmahajan - 08/11/2003
-- This function will get the Transaction dates for the Txn ID
-- and all its related Transactions identified by the
-- PREVIOUS_CUSTOMER_TRX_ID (Identifier for invoice credited)
-- INITIAL_CUSTOMER_TRX_ID (Identifier of a related commitment)
-- and transactions related, in turn, to these transactions.
-- The earliest of these Transaction dates will be returned as the start_date
-- and the latest / SYSDATE will be returned as the end_date

PROCEDURE Get_Txn_Start_End_Dates (
                 p_customer_trx_id IN NUMBER,
		 p_start_date OUT NOCOPY DATE,
		 p_end_date OUT NOCOPY DATE
               ) IS

  l_start_date DATE;
  l_end_date DATE;
  l_initial_customer_trx_id NUMBER;
  l_previous_customer_trx_id NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.get_txn_start_end_dates()+' );
       debug(   'p_customer_trx_id=' || to_char(p_customer_trx_id));
    END IF;

  p_start_date := null;
  p_end_date := null;

  /*--- Bug 5039192 This query raises No Data Found if no Customer is populated */

  IF p_customer_trx_id IS NOT NULL THEN

    select INITIAL_CUSTOMER_TRX_ID, PREVIOUS_CUSTOMER_TRX_ID, TRX_DATE
    into l_initial_customer_trx_id, l_previous_customer_trx_id, p_start_date
    from RA_CUSTOMER_TRX
    where CUSTOMER_TRX_ID = p_customer_trx_id;

  END IF;


  if p_start_date is null then
    p_start_date := SYSDATE;
  end if;

  if p_start_date > SYSDATE
  then
    p_end_date := p_start_date;
  else
    p_end_date := SYSDATE;
  end if;

  if l_initial_customer_trx_id is not null then
    Get_Txn_Start_End_Dates(l_initial_customer_trx_id, l_start_date, l_end_date);
    if nvl(l_start_date, p_start_date) < p_start_date then
 	p_start_date := l_start_date;
    end if;
    if nvl(l_end_date, p_end_date) > p_end_date then
 	p_end_date := l_end_date;
    end if;
  end if;

  if l_previous_customer_trx_id is not null then
    Get_Txn_Start_End_Dates(l_previous_customer_trx_id, l_start_date, l_end_date);
    if nvl(l_start_date, p_start_date) < p_start_date then
 	p_start_date := l_start_date;
    end if;
    if nvl(l_end_date, p_end_date) > p_end_date then
 	p_end_date := l_end_date;
    end if;
  end if;

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.get_txn_start_end_dates()-' );
    END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
       debug(  'Exception: arp_util.get_txn_start_end_dates');
     END IF;
     RAISE;
END Get_Txn_Start_End_Dates;

-- kmahajan - 25th Aug 2003 - New utility functions that serve as wrappers
-- for the JTF function to return a Default Sales Group given a Sales Rep
-- and effective date
--
FUNCTION Get_Default_SalesGroup (
		 p_salesrep_id IN NUMBER,
                 p_org_id IN NUMBER,
                 p_date IN DATE
               ) RETURN NUMBER IS

  l_group_id	NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.get_default_salesgroup()+' );
    END IF;

   -- here, we need to make the call to the JTF function
   -- jtf_rs_integration_pub.get_default_sales_group
   -- Initially, this is just a stub returning NULL but
   -- going forward (DBI 6.1 onwards), it will pick up
   -- the default Sales Group
   BEGIN
     l_group_id := jtf_rs_integration_pub.get_default_sales_group(
			p_salesrep_id, p_org_id, p_date);
   EXCEPTION
     WHEN OTHERS THEN
	l_group_id := null;
   END;

   return l_group_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.get_default_salesgroup()-' );
    END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
       debug(  'Exception: arp_util.get_default_salesgroup');
     END IF;
     RAISE;
END Get_Default_SalesGroup;

FUNCTION Get_Default_SalesGroup (
		 p_salesrep_id IN NUMBER,
                 p_customer_trx_id IN NUMBER
               ) RETURN NUMBER IS
  l_date DATE;
  l_org_id NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.get_default_salesgroup()+' );
    END IF;

  l_date := null;

  select TRX_DATE, ORG_ID
  into l_date, l_org_id
  from RA_CUSTOMER_TRX
  where CUSTOMER_TRX_ID = p_customer_trx_id;

   return Get_Default_SalesGroup(p_salesrep_id, l_org_id, l_date);

    IF PG_DEBUG in ('Y', 'C') THEN
       debug(   'arp_util.get_default_salesgroup()-' );
    END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
       debug(  'Exception: arp_util.get_default_salesgroup');
       debug(  'NO_DATA_FOUND: p_customer_trx_id=' || to_char(p_customer_trx_id));
     END IF;
     RAISE;
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
       debug(  'Exception: arp_util.get_default_salesgroup');
       debug(  'p_customer_trx_id=' || to_char(p_customer_trx_id));
     END IF;
     RAISE;
END Get_Default_SalesGroup;

/* Bug fix 4942083:
   The accounting reports will be run for a GL date range. If within this date range, there
   is a period which is not Closed or Close Pending, this function will return TRUE. Else
   this function will return FALSE */

FUNCTION Open_Period_Exists(
               p_reporting_level        IN  VARCHAR2,
               p_reporting_entity_id    IN  NUMBER,
               p_gl_date_from           IN  DATE,
               p_gl_date_to             IN  DATE
              ) RETURN BOOLEAN IS

  l_value                  NUMBER := 0;
  l_sysparam_org_where     VARCHAR2(2000);
  l_select_stmt            VARCHAR2(10000);
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug('arp_util.Open_Period_Exists()+');
    END IF;

    IF p_gl_date_from IS NULL and p_gl_date_to IS NULL THEN
           l_value := 1;

    ELSIF p_gl_date_from IS NULL and p_gl_date_to IS NOT NULL THEN
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                          p_reporting_entity_id,
                                          p_gl_date_to) THEN
            l_value := 1;
       END IF;

    ELSIF p_gl_date_from IS NOT NULL and p_gl_date_to IS NULL THEN
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                          p_reporting_entity_id,
                                          p_gl_date_from) THEN
            l_value := 1;
       END IF;
    ELSE
       XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

       l_sysparam_org_where     := XLA_MO_REPORTING_API.Get_Predicate('sp',null);

       l_select_stmt  := 'SELECT 1
                         FROM DUAL
                         WHERE EXISTS( SELECT closing_status
                                       FROM   gl_period_statuses g,
                                              gl_sets_of_books   b,
                                              ar_system_parameters_all sp
                                       WHERE  b.set_of_books_id         = g.set_of_books_id
                                       AND    g.set_of_books_id         = sp.set_of_books_id
                                       AND    g.period_type             = b.accounted_period_type
                                       AND    g.application_id          = 222
                                       AND    g.adjustment_period_flag  = ''N''
                                       AND    g.closing_status not in (''P'', ''C'',''W'')
                                       AND    ((g.end_date BETWEEN :p_gl_date_from AND :p_gl_date_to)
                                       OR     (:p_gl_date_to BETWEEN g.start_date AND g.end_date))
                                       ' ||l_sysparam_org_where || ')';

      IF p_reporting_level = '3000' THEN
          EXECUTE IMMEDIATE l_select_stmt
             INTO l_value
            USING p_gl_date_from,p_gl_date_to,p_gl_date_to,p_reporting_entity_id,p_reporting_entity_id;
      ELSE
          EXECUTE IMMEDIATE  l_select_stmt
             INTO l_value
            USING  p_gl_date_from, p_gl_date_to,p_gl_date_to;
      END IF;
    END IF;

    IF l_value = 1 THEN
       return TRUE;
    ELSE
       return FALSE;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        debug('arp_util.Open_Period_Exists()-');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           debug('arp_util.Open_Period_Exists: Exception');
       END IF;
       return FALSE;
END Open_Period_Exists;

FUNCTION Open_Period_Exists(
                           p_reporting_level        IN  VARCHAR2,
                           p_reporting_entity_id    IN  NUMBER,
                           p_in_as_of_date_low      IN  DATE
                           ) RETURN BOOLEAN IS

  l_value                  NUMBER := 0;
  l_sysparam_org_where     VARCHAR2(2000);
  l_select_stmt            VARCHAR2(10000);
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug('arp_util.Open_Period_Exists()+');
    END IF;

    XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

    l_sysparam_org_where     := XLA_MO_REPORTING_API.Get_Predicate('sp',null);

    l_select_stmt  := 'SELECT 1
                       FROM DUAL
                       WHERE EXISTS( SELECT closing_status
                                     FROM   gl_period_statuses g,
                                            gl_sets_of_books   b,
                                            ar_system_parameters_all sp
                                     WHERE  b.set_of_books_id         = g.set_of_books_id
                                     AND    g.set_of_books_id         = sp.set_of_books_id
                                     AND    g.period_type             = b.accounted_period_type
                                     AND    g.application_id          = 222
                                     AND    g.adjustment_period_flag  = ''N''
                                     AND    g.closing_status not in (''P'', ''C'',''W'')
                                     AND    start_date <= :p_in_as_of_date_low
                                     AND    end_date >= :p_in_as_of_date_low
                                     ' ||l_sysparam_org_where || ')';

    IF p_reporting_level = '3000' THEN
    	EXECUTE IMMEDIATE l_select_stmt
       	   INTO l_value
    	USING p_in_as_of_date_low,p_in_as_of_date_low,p_reporting_entity_id,p_reporting_entity_id;
    ELSE
    	EXECUTE IMMEDIATE  l_select_stmt
           INTO l_value
    	USING  p_in_as_of_date_low,p_in_as_of_date_low;
    END IF;
    IF l_value = 1 THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        debug('arp_util.Open_Period_Exists()-');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           debug('arp_util.Open_Period_Exists: Exception');
       END IF;
       RETURN FALSE;
END Open_Period_Exists;

/* ER Automatch Cash Application START */
  -- Function to restrict the new feature from user.
FUNCTION AUTOMATCH_ENABLED RETURN VARCHAR2 is
 l_automatch_enabled_flag VARCHAR2(1) := 'F';
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       debug('arp_util.automatch_enabled()+');
    END IF;
       begin
        select NVL(automatch_enabled_flag,'F')
	into l_automatch_enabled_flag
	from ar_system_parameters;
       exception
         when others then
	  l_automatch_enabled_flag := 'F';
       end;

       debug('l_automatch_enabled_flag : ' || l_automatch_enabled_flag);

       IF l_automatch_enabled_flag = 'T' THEN
              RETURN 'TRUE';
       ELSE
              RETURN 'FALSE';
       END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       debug('arp_util.automatch_enabled()-');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           debug('arp_util.automatch_enabled: Exception');
       END IF;
       RETURN 'FALSE';
END automatch_enabled;
/* ER Automatch Cash Application END */

END arp_util;

/
