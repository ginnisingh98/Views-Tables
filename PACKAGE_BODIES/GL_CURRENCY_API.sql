--------------------------------------------------------
--  DDL for Package Body GL_CURRENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CURRENCY_API" AS
/* $Header: glustcrb.pls 120.7 2005/05/05 01:44:15 kvora ship $ */

  ---
  --- PRIVATE VARIABLES
  ---

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   get_info
  --
  -- Purpose
  -- 	Gets the currency type information about given currency.
  --    Also set the x_invalid_currency flag if the given currency is invalid.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   x_currency		Currency to be checked
  --   x_eff_date		Effecitve date
  --   x_conversion_rate	Fixed rate for conversion
  --   x_mau                    Minimum accountable unit
  --   x_currency_type		Type of currency specified in x_currency
  --
  PROCEDURE get_info(
		x_currency			VARCHAR2,
		x_eff_date			DATE,
		x_conversion_rate	IN OUT NOCOPY	NUMBER,
		x_mau			IN OUT NOCOPY	NUMBER,
		x_currency_type	 	IN OUT NOCOPY	VARCHAR2 ) IS

  BEGIN
     -- Get currency information from FND_CURRENCIES table
     SELECT decode( derive_type,
  	            'EURO', 'EURO',
	            'EMU', decode( sign( trunc(x_eff_date) -
					 trunc(derive_effective)),
	  	                   -1, 'OTHER',
			           'EMU'),
                    'OTHER' ),
            decode( derive_type, 'EURO', 1,
		  	         'EMU', derive_factor,
		  	         'OTHER', -1 ),
	    nvl( minimum_accountable_unit, power( 10, (-1 * precision)))
     INTO   x_currency_type,
	    x_conversion_rate,
	    x_mau
     FROM   FND_CURRENCIES
     WHERE  currency_code = x_currency;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	raise INVALID_CURRENCY;

  END get_info;

  --
  -- Function
  --   get_fixed_conv_rate
  --
  -- Purpose
  -- 	Returns Fixed conversion rate between two currencies
  --    where both currencies are not the EURO, or EMU currencies.
  --    This routine hits the GL_FIXED_CONV_RATES.
  --
  -- History
  --    01-Mar-2005   Srini Pala    Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   l_fixed_conv_rate        Fixed conversion rate.
  --

  PROCEDURE get_fixed_conv_rate(x_from_currency	 IN OUT NOCOPY 	VARCHAR2,
		x_to_currency	IN OUT NOCOPY	VARCHAR2,
		x_conversion_date	Date,
		x_conversion_type	VARCHAR2 ,
                x_fixed_conv_rate OUT NOCOPY NUMBER) IS

    direct_from_fix_rate    NUMBER;
    l_fix_rate              NUMBER;

    inverse_to_fix_rate   NUMBER;
    new_from_currency  VARCHAR2(15);
    new_to_currency    VARCHAR2(15);
    l_fixed_relation   VARCHAR2(15);
    l_currency_from    VARCHAR2(15);
    l_currency_to      VARCHAR2(15);
    l_continue         BOOLEAN := FALSE;
    l_final_rate       NUMBER;

    CURSOR is_there_fixed_rate(l_from_curr VARCHAR2,
                                     l_to_curr VARCHAR2,
                                     l_eff_date DATE) IS
           SELECT old_currency,
                  replacement_currency,
                  fixed_conversion_rate
           FROM   GL_FIXED_CONV_RATES
           WHERE  old_currency IN (l_from_curr,l_to_curr)
           AND    effective_start_date <= trunc(l_eff_date)
           ORDER BY DECODE(old_currency, l_from_curr,0,1);
BEGIN
         l_currency_from := x_from_currency;
         l_currency_to   := x_to_currency;
         direct_from_fix_rate   := 1;
         inverse_to_fix_rate    := 1;

    IF(x_from_currency = x_to_currency) THEN
       x_fixed_conv_rate := 1;
    END IF;

   /*-----------------------------------------------------------------------+
      This routine should check whether there is a fixed rate relationship
      exist between the from currency and the to_currency  in the
      GL_FIXED_CONV_RATES table.
      Some EUROPEAN countries are getting rid of ending zero's
      from their currency. In this case those countries define
      a fixed rate relationship between the old currency and the new
      replacement currency starting from an effective date.
      For example Turky replaced thier old currency with the new currency
      and effective from 01-01-2005.
        If we want to find a conversion between old Turky currency and
        USD, then we need to follow the following rule after 01-01-2005.
            First find rate  between
            OLD Turky Currency -> New Turky Currency in GL_FIXED_CONV_RATES
            Then
            New Turky Currency -> USD in GL_DAILY_RATES table.
        The following code added to do this job.
   +-----------------------------------------------------------------------*/

   /* ********************************************************************+
   |  A few possible different scenarios                                  |
   |  The rate may be calculated between two currencies as follows        |
   |                                                                      |
   |  1) Old Currency to French Franks                                    |
   |  Old Currency -> New Currency from the GL_FIXED_CONV_RATES table     |
   |  New Currency -> EURO from the GL_DAILY_RATES                        |
   |  EURO -> FRENCH FRANK  fixed rate from the FND_CURRENCIES            |
   |                                                                      |
   |  2) USD to New Currency                                              |
   |     USD -> New CURRENCY from the GL Daily Rates Table.               |
   |                                                                      |
   |  3) USD to Old Currency                                              |
   |     USD -> New CURRENCY from the GL Daily Rates Table.               |
   |     New curency -> Old Currency fixed rate                           |
   |                         from GL Fixed Conv Rates                     |
   |                                                                      |
   |   4) Old Currency to CAD                                             |
   |      Old Currency -> New Currency from                               |
   |                          the GL_FIXED_CONV_RATES table               |
   |      New Currency -> CAD from the GL_DAILY_RATES                     |
   |                                                                      |
   +######################################################################*/
   -- Check the passed currencies have any fixed relationships exist or not.
   -- This check avoids unnecssary processing if there is no fixed
   -- rate relationship.

     OPEN  is_there_fixed_rate(l_currency_from,
                                     l_currency_to,
                                     x_conversion_date);

     FETCH  is_there_fixed_rate INTO new_from_currency,
                                     new_to_currency,
                                     l_fix_rate;

     IF (is_there_fixed_rate%FOUND) THEN
         l_continue := TRUE;
     ELSE
         l_continue             := FALSE;
         direct_from_fix_rate   := 1;
         inverse_to_fix_rate    := 1;
         x_fixed_conv_rate      := 1;
         CLOSE is_there_fixed_rate;
     END IF;

    /*---------------------------------------------------------------------+
     | First try finding a fixed conversion from the old currency column.  |
     | If there is a rate, then it is fine, otherwise try to find the      |
     | inverse  rate by querying on replacement currency.                  |
     | If there exists a fixed conversion relationship, then set the       |
     | x_from_currency to retrive the rate between the new currency to the |
     | x_to_currency from GL_DAILY_RATES table.                            |
     |                                                                     |
     | ************THIS PART HANDLES ON THE FROM CURRENCY SIDE.*********   |
     |                                                                     |
     |      IF x_from_currency = OLD TURKY currency                        |
     |       Then it finds   OLD TURKY CURRENCY to NEW TURKEY CURRENCY     |
     |       If x_to_currency = NEW TURKY CURRENCY then this part          |
     |           alone returns the final rate.                             |
     |       Else It will find the other part of the rate from             |
     |         GL Daily Rates table.                                       |
     |            New Turky Currency to USD                                |
     +---------------------------------------------------------------------*/

     IF ( l_continue) THEN

       IF (l_currency_from = new_from_currency) THEN
               direct_from_fix_rate:= l_fix_rate;
               x_from_currency := new_to_currency;

          ELSIF (l_currency_to = new_from_currency) THEN
               inverse_to_fix_rate := 1/l_fix_rate;
               x_to_currency := new_to_currency;

       END IF;

    /*---------------------------------------------------------------------+
     | This part handles when we are trying to find a rate from            |
     | one coutries old currency to another coutries old currency.         |
     | For example Find a rate between Old1->Old2                          |
     | Then  Old1-> NEW1 from GL_FIXED_CONV_RATES,                         |
     |       New1->New2   from GL_DAILY_RATE                               |
     |       New2->Old2  from  GL_FIXED_CONV_RATES The following code      |
     | handles this calculation.                                           |
     +---------------------------------------------------------------------*/
        -- Fetch the second row if there exists one.

       FETCH  is_there_fixed_rate INTO new_from_currency,
                                     new_to_currency,
                                     l_fix_rate;

        If (is_there_fixed_rate%FOUND) THEN


           IF  (l_currency_to = new_from_currency) THEN
             inverse_to_fix_rate :=1/l_fix_rate;
             x_to_currency := new_to_currency;

           END IF;

        End If;


      CLOSE is_there_fixed_rate;

       l_final_rate := (direct_from_fix_rate* inverse_to_fix_rate);
       x_fixed_conv_rate := l_final_rate;

      END IF;  -- End of if (l_continue)
END;


  --
  -- Function
  --   get_other_rate
  --
  -- Purpose
  -- 	Returns conversion rate between two currencies where both currencies
  --    are not the EURO, or EMU currencies.
  --
  -- History
  --   15-JUL-97      W Wong 	    Created
  --
  --   14-Mar-2005   Srini Pala    Fixed rate relationship enhancements
  --                               are made.
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_other_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	Date,
		x_conversion_type	VARCHAR2 ) RETURN NUMBER IS

    rate NUMBER;
    l_from_currency    VARCHAR2(15);
    l_to_currency      VARCHAR2(15);
    l_fix_rate         NUMBER;

  BEGIN

    l_from_currency := x_from_currency;
    l_to_currency   := x_to_currency;

    IF(x_from_currency = x_to_currency) THEN
       return (1);
    END IF;

   -- Get the Fixed conversion rate if there exists one.

   get_fixed_conv_rate(l_from_currency,
		       l_to_currency,
		       x_conversion_date,
		       x_conversion_type,
                       l_fix_rate);


   IF (l_from_currency = l_to_currency) THEN

      rate := 1;

   ELSE
     -- Get conversion rate between the two currencies from GL_DAILY_RATES
     SELECT 	conversion_rate
     INTO   	rate
     FROM 	GL_DAILY_RATES
     WHERE	from_currency = l_from_currency
     AND	to_currency = l_to_currency
     AND	conversion_date = trunc(x_conversion_date)
     AND	conversion_type = x_conversion_type;
   END IF;

     return(l_fix_rate*rate );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	raise NO_RATE;
  END get_other_rate;


  --
  -- Function
  --   get_other_closest_rate
  --
  -- Purpose
  -- 	Returns conversion rate between two currencies where both currencies
  --    are not the EURO, or EMU currencies.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  --   14-MAR-2005  Srini Pala  Added Fixed conversion rate relationship
  --                            logic.
  --                            More detailed explanation is in the
  --                            get_fixed_conv_rate() routine.
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_other_closest_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	Date,
		x_conversion_type	VARCHAR2,
		x_max_roll_days         NUMBER ) RETURN NUMBER IS

    -- This cursor finds the latest rate defined between the given two
    -- currencies using x_conversion_type within the period between
    -- x_max_roll_days prior to x_conversion_date AND x_conversion_date.
    CURSOR closest_rate_curr(g_from_currency VARCHAR2,
                             g_to_currency VARCHAR2) IS
      SELECT conversion_rate
      FROM   GL_DAILY_RATES
      WHERE  from_currency   = g_from_currency
      AND    to_currency     = g_to_currency
      AND    conversion_type = x_conversion_type
      AND    conversion_date BETWEEN
		( decode( sign (x_max_roll_days),
			  1, trunc(x_conversion_date) - x_max_roll_days,
			  -1, trunc(to_date('1000/01/01', 'YYYY/MM/DD'))))
		AND trunc(x_conversion_date)
      ORDER BY conversion_date DESC;

    rate NUMBER;
    l_from_curr          VARCHAR2(15);
    l_to_curr            VARCHAR2(15);
    l_fixed_conv_rate    NUMBER;

  BEGIN

    l_from_curr   := x_from_currency;
    l_to_curr     := x_to_currency;

    -- Try to search for a rate on the given conversion date
    rate := get_other_rate( x_from_currency,
			    x_to_currency,
 		            x_conversion_date,
		            x_conversion_type );

    return( rate );

  EXCEPTION
     -- No conversion rate was found on the given conversion date.
     -- Try to search for the latest conversion rate with a prior conversion
     -- date then x_conversion_date.
     WHEN NO_RATE THEN
      IF ( x_max_roll_days = 0 ) THEN
	  -- Do not search backwards for the conversion rate.
	  raise NO_RATE;

      ELSE
        -- Get the Fixed conversion rate if there exists one.

         get_fixed_conv_rate(l_from_curr,
		             l_to_curr,
		             x_conversion_date,
		             x_conversion_type,
                             l_fixed_conv_rate);

        IF (l_from_curr <> l_to_curr) THEN
	  -- Search backwards for a conversion rate with the given currencies
          -- and conversion type.
  	  OPEN closest_rate_curr(l_from_curr, l_to_curr);
	  FETCH closest_rate_curr INTO rate;

  	  IF NOT closest_rate_curr%FOUND THEN
	    raise NO_RATE;
	  ELSE
	    return( rate * l_fixed_conv_rate);
	  END IF;
        ELSE
         return (l_fixed_conv_rate);
        END IF;

     END IF;

  END get_other_closest_rate;


  ---
  --- PUBLIC FUNCTIONS
  ---

  --
  -- Function
  --   is_fixed_rate
  --
  -- Purpose
  -- 	Returns if there is a fixed rate between the two currencies.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --   14-MAR-2005  Srini Pala  Added Fixed conversion rate relationship
  --                            logic.
  --                            More detailed explanation is in
  --                            the get_fixed_conv_rate() routine.
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_effective_date		Effective date
  --
  FUNCTION is_fixed_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_effective_date	DATE      ) RETURN VARCHAR2 IS

    to_type      	VARCHAR2(8);
    from_type    	VARCHAR2(8);
    rate		NUMBER;      -- Value ignored in this function
    mau			NUMBER;      -- Value ignored in this function

   /* Fixed conversion relationships enhancements start */
    CURSOR is_there_fix_rate(l_from_curr VARCHAR2,
                                     l_to_curr VARCHAR2,
                                     l_eff_date DATE) IS
           SELECT 'EXIST'
           FROM   GL_FIXED_CONV_RATES
           WHERE  old_currency IN (l_from_curr,l_to_curr)
           AND    ((old_currency = l_from_curr
                      AND replacement_currency = l_to_curr)
                  OR  (replacement_currency = l_from_curr
                      AND old_currency = l_to_curr))
           AND    effective_start_date <= trunc(l_eff_date)
           AND ROWNUM =1;
   l_fix_rate     VARCHAR2(10);

  /* Fixed conversion relationships enhancements End */


  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return 'Y';
     END IF;

     -- Get currency information of the x_from_currency
     get_info( x_from_currency, x_effective_date, rate, mau, from_type );

     -- Get currency information of the x_to_currency
     get_info( x_to_currency, x_effective_date, rate, mau, to_type );

     -- Check if there is a fixed rate between the two given currencies
     IF (( from_type IN ('EMU', 'EURO')) AND
	 ( to_type IN ('EMU', 'EURO'))) THEN
	return 'Y';

     ELSE
  /* Fixed conversion relationships enhancements start */

        OPEN is_there_fix_rate (x_from_currency,
                                x_to_currency,
                                x_effective_date);
        FETCH is_there_fix_rate INTO l_fix_rate;

        IF (is_there_fix_rate%FOUND) THEN

           return 'Y';
  /* Fixed conversion relationships enhancements end */
       ELSE
	return 'N';
       END IF;
     END IF;

  END is_fixed_rate;


  --
  -- Procedure
  --   get_relation
  --
  -- Purpose
  -- 	Returns the relationship between the two currencies given.
  --    Also check if there is a fixed rate between the two currencies
  --    on the effective date.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  --   14-MAR-2005  Srini Pala  Added Fixed conversion rate relationship
  --                            logic.
  --                            More detailed explanation is in the
  --                            get_fixed_conv_rate() routine.
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency 		To currency
  --   x_effective_date		Effective date
  --   x_fixed_rate		TRUE if there is a fixed rate between the
  --                            currencies on the effective date;
  -- 				FALSE otherwise
  --   x_relationship		Relationship between the two currencies
  --
  PROCEDURE get_relation(
		x_from_currency			VARCHAR2,
		x_to_currency			VARCHAR2,
		x_effective_date		DATE,
		x_fixed_rate		IN OUT NOCOPY 	BOOLEAN,
		x_relationship		IN OUT NOCOPY	VARCHAR2 ) IS

    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    rate		NUMBER;       -- Value ignored in this function
    mau			NUMBER;       -- Value ignored in this function

   /* Fixed conversion relationships enhancements start */

    CURSOR is_there_fix_relation(l_from_curr VARCHAR2,
                                 l_to_curr VARCHAR2,
                                 l_eff_date DATE) IS
           SELECT 'EXIST'
           FROM   GL_FIXED_CONV_RATES
           WHERE  old_currency IN (l_from_curr,l_to_curr)
           AND    ((old_currency = l_from_curr
                      AND replacement_currency = l_to_curr)
                  OR  (replacement_currency = l_from_curr
                      AND old_currency = l_to_curr))
           AND    effective_start_date <= trunc(l_eff_date)
           AND ROWNUM =1;
   l_fix_relationship     VARCHAR2(10);

  /* Fixed conversion relationships enhancements End */

  BEGIN
     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_effective_date, rate, mau, from_type );

     -- Get currency information from the x_to_currency
     get_info ( x_to_currency, x_effective_date, rate, mau, to_type );

     -- Check if there is a fixed rate between the two given currencies
     IF ( x_from_currency = x_to_currency ) THEN
         x_fixed_rate := TRUE;

     ELSE
       IF (( from_type IN ('EMU', 'EURO')) AND
	   ( to_type IN ('EMU', 'EURO'))) THEN
         x_fixed_rate := TRUE;

       ELSE
         /* Fixed conversion relationships enhancements start */

             OPEN is_there_fix_relation(x_from_currency,
                                     x_to_currency,
                                     x_effective_date);
             FETCH is_there_fix_relation INTO l_fix_relationship;

            IF (is_there_fix_relation%FOUND) THEN
                 x_fixed_rate := TRUE;
          /* Fixed conversion relationships enhancements end */

            ELSE
	      x_fixed_rate := FALSE;
            END IF;
       END IF;
     END IF;


     -- Get the relationship between the currencies
     x_relationship := from_type || '-' || to_type;

  END get_relation;


  --
  -- FUNCTION
  --   get_euro_code
  --
  -- Purpose
  -- 	Returns the currency code for the EURO currency.  We need to
  --    select this currency code from fnd_currencies table because
  --    the currency code for EURO has not been fixed at this time.
  --
  -- History
  --   24-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   None.
  --
  FUNCTION get_euro_code RETURN VARCHAR2 IS
    euro_code 	VARCHAR2(15);

  BEGIN
    -- Get currency code of the EURO currency
    SELECT 	currency_code
    INTO   	euro_code
    FROM   	FND_CURRENCIES
    WHERE	derive_type = 'EURO';

    return( euro_code );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	raise INVALID_CURRENCY;

  END get_euro_code;

  --
  -- Function
  --   get_rate
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and conversion type.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    euro_code		VARCHAR2(15);
    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    to_rate		NUMBER;
    from_rate		NUMBER;
    other_rate		NUMBER;
    mau			NUMBER;       -- Value ignored in this function

  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( 1 );
     END IF;

     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, mau,
		from_type );

     -- Get currency information from the x_to_currency
     get_info ( x_to_currency, x_conversion_date, to_rate, mau, to_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	IF ( to_type = 'EMU' ) THEN
		return( to_rate / from_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	  	return( 1 / from_rate );

	ELSIF ( to_type = 'OTHER' ) THEN
		-- Find out conversion rate from EURO to x_to_currency
		euro_code := get_euro_code;
		other_rate := get_other_rate( euro_code, x_to_currency,
				              x_conversion_date,
					      x_conversion_type );

		-- Get conversion rate by converting  EMU -> EURO -> OTHER
		return( other_rate / from_rate );
	END IF;

     ELSIF ( from_type = 'EURO' ) THEN
	IF ( to_type = 'EMU' ) THEN
 		return( to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	        -- We should never comes to this case as it should be
                -- caught when we check if both to and from currency
                -- is the same at the beginning of this function
		return( 1 );

	ELSIF ( to_type = 'OTHER' ) THEN
	  	other_rate := get_other_rate( x_from_currency, x_to_currency,
				       	      x_conversion_date,
					      x_conversion_type );
	  	return( other_rate );
	END IF;

     ELSIF ( from_type = 'OTHER' ) THEN
	IF ( to_type = 'EMU' ) THEN
		-- Find out conversion rate from x_from_currency to EURO
		euro_code := get_euro_code;
		other_rate := get_other_rate( x_from_currency, euro_code,
				              x_conversion_date,
					      x_conversion_type );

		-- Get conversion rate by converting OTHER -> EURO -> EMU
	  	return( other_rate * to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
		other_rate := get_other_rate( x_from_currency, x_to_currency,
					      x_conversion_date,
					      x_conversion_type );
	  	return( other_rate );

	ELSIF ( to_type = 'OTHER' ) THEN
		other_rate := get_other_rate( x_from_currency, x_to_currency,
				       	      x_conversion_date,
					      x_conversion_type );
	  	return( other_rate );
	END IF;
     END IF;

  END get_rate;


  --
  -- Function
  --   get_rate
  --
  -- Purpose
  -- 	Returns the rate between the from currency and the functional
  --    currency of the ledgers.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    to_currency 	VARCHAR2(15);
    rate		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call get_rate() with the to_currency we get from the ledger
     rate := get_rate( x_from_currency, to_currency, x_conversion_date,
	   	       x_conversion_type );

     return( rate );

  END get_rate;

  --
  -- Function
  --   get_rate_sql
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and conversion type by calling get_rate().
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    rate		NUMBER;
  BEGIN
    -- Call get_rate() using the given parameters
    rate := get_rate( x_from_currency, x_to_currency, x_conversion_date,
		      x_conversion_type );
    return( rate );

    EXCEPTION
	WHEN NO_RATE THEN
	  rate := -1;
	  return( rate );

	WHEN INVALID_CURRENCY THEN
	  rate := -2;
	  return( rate );

  END get_rate_sql;


  --
  -- Function
  --   get_rate_sql
  --
  -- Purpose
  -- 	Returns the rate between the from currency and the functional
  --    currency of the ledgers by calling get_rate().
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    rate		NUMBER;
  BEGIN

    -- Call get_rate() using the given parameters
    rate := get_rate( x_set_of_books_id, x_from_currency, x_conversion_date,
		      x_conversion_type );
    return( rate );

    EXCEPTION
	WHEN NO_RATE THEN
	  rate := -1;
	  return( rate );

	WHEN INVALID_CURRENCY THEN
	  rate := -2;
	  return( rate );

  END get_rate_sql;

  --
  -- Function
  --   get_closest_rate
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and conversion type.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER ) RETURN NUMBER IS

    euro_code		VARCHAR2(15);
    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    to_rate		NUMBER;
    from_rate		NUMBER;
    other_rate		NUMBER;
    mau			NUMBER;       -- Value ignored in this function

  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( 1 );
     END IF;

     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, mau,
		from_type );

     -- Get currency information from the x_to_currency
     get_info ( x_to_currency, x_conversion_date, to_rate, mau, to_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	IF ( to_type = 'EMU' ) THEN
		return( to_rate / from_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	  	return( 1 / from_rate );

	ELSIF ( to_type = 'OTHER' ) THEN
		-- Find out conversion rate from EURO to x_to_currency
		euro_code := get_euro_code;
		other_rate := get_other_closest_rate( euro_code,
						      x_to_currency,
				                      x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );

		-- Get conversion rate by converting  EMU -> EURO -> OTHER
		return( other_rate / from_rate );
	END IF;

     ELSIF ( from_type = 'EURO' ) THEN
	IF ( to_type = 'EMU' ) THEN
 		return( to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	        -- We should never comes to this case as it should be
                -- caught when we check if both to and from currency
                -- is the same at the beginning of this function
		return( 1 );

	ELSIF ( to_type = 'OTHER' ) THEN
	  	other_rate := get_other_closest_rate( x_from_currency,
						      x_to_currency,
				       	              x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
	  	return( other_rate );
	END IF;

     ELSIF ( from_type = 'OTHER' ) THEN
	IF ( to_type = 'EMU' ) THEN
		-- Find out conversion rate from x_from_currency to EURO
		euro_code := get_euro_code;
		other_rate := get_other_closest_rate( x_from_currency,
						      euro_code,
				                      x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );

		-- Get conversion rate by converting OTHER -> EURO -> EMU
	  	return( other_rate * to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
		other_rate := get_other_closest_rate( x_from_currency,
						      x_to_currency,
					              x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
	  	return( other_rate );

	ELSIF ( to_type = 'OTHER' ) THEN
		other_rate := get_other_closest_rate( x_from_currency,
						      x_to_currency,
				       	              x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
	  	return( other_rate );
	END IF;
     END IF;

  END get_closest_rate;


  -- Function
  --   get_closest_rate
  --
  -- Purpose
  -- 	Returns the rate between the from currency and the functional currency
  --	of the ledgers, for a given conversion date and conversion type.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id        Ledger ID
  --   x_from__currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_max_roll_days         NUMBER ) RETURN NUMBER IS
    to_currency 	VARCHAR2(15);
    rate		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call get_closest_rate() with the to_currency we get from the Ledgers
     rate := get_closest_rate( x_from_currency,
			       to_currency,
			       x_conversion_date,
	   	       	       x_conversion_type,
			       x_max_roll_days );

     return( rate );

  END get_closest_rate;


  --
  -- Function
  --   get_closest_rate_sql
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and conversion type by calling get_closest_rate().
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
  --
  --    Return -1 if the NO_RATE exception is raised in get_closest_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --                 get_closest_rate().
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER ) RETURN NUMBER IS

    rate		NUMBER;
  BEGIN
    rate := get_closest_rate( x_from_currency, x_to_currency,
			      x_conversion_date, x_conversion_type,
			      x_max_roll_days );
    return( rate );

    EXCEPTION
	WHEN NO_RATE THEN
	  rate := -1;
	  return( rate );

	WHEN INVALID_CURRENCY THEN
	  rate := -2;
	  return( rate );

  END get_closest_rate_sql;


  --
  -- Function
  --   get_closest_rate_sql
  --
  -- Purpose
  -- 	Returns the rate between the from currency and the functional currency
  --	of the ledgers, for a given conversion date and conversion type
  --    by calling get_closest_rate().
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
  --
  --    Return -1 if the NO_RATE exception is raised in get_closest_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --              get_closest_rate().
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER ) RETURN NUMBER IS

    rate		NUMBER;
  BEGIN
    rate := get_closest_rate( x_set_of_books_id, x_from_currency,
			      x_conversion_date, x_conversion_type,
			      x_max_roll_days );
    return( rate );

    EXCEPTION
	WHEN NO_RATE THEN
	  rate := -1;
	  return( rate );

	WHEN INVALID_CURRENCY THEN
	  rate := -2;
	  return( rate );

  END get_closest_rate_sql;


  --
  -- Function
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type.
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --
  FUNCTION convert_amount (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER ) RETURN NUMBER IS

    euro_code			VARCHAR2(15);
    to_type   			VARCHAR2(8);
    from_type 			VARCHAR2(8);
    to_rate			NUMBER;
    from_rate			NUMBER;
    other_rate			NUMBER;
    from_mau			NUMBER;
    to_mau			NUMBER;
    converted_amount		NUMBER;

  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( x_amount );
     END IF;

     -- Get currency information from the from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, from_mau,
	        from_type );

     -- Get currency information from the to_currency
     get_info ( x_to_currency, x_conversion_date, to_rate, to_mau, to_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	IF ( to_type = 'EMU' ) THEN
		converted_amount := ( x_amount / from_rate ) * to_rate;

        ELSIF ( to_type = 'EURO' ) THEN
		converted_amount := x_amount / from_rate;

	ELSIF ( to_type = 'OTHER' ) THEN
		-- Find out conversion rate from EURO to x_to_currency
		euro_code := get_euro_code;
		other_rate := get_other_rate( euro_code, x_to_currency,
				              x_conversion_date,
					      x_conversion_type );

		-- Get conversion amt by converting EMU -> EURO -> OTHER
		converted_amount := ( x_amount / from_rate ) * other_rate;
	END IF;

     ELSIF ( from_type = 'EURO' ) THEN
	IF ( to_type = 'EMU' ) THEN
		converted_amount := x_amount * to_rate;

	ELSIF ( to_type = 'EURO' ) THEN
	        -- We should never comes to this case as it should be
                -- caught when we check if both to and from currency
                -- is the same at the beginning of this function
		converted_amount := x_amount;

	ELSIF ( to_type = 'OTHER' ) THEN
	  	other_rate := get_other_rate( x_from_currency, x_to_currency,
				       	      x_conversion_date,
					      x_conversion_type );
		converted_amount := x_amount * other_rate;
	END IF;

     ELSIF ( from_type = 'OTHER' ) THEN
	IF ( to_type = 'EMU' ) THEN
		-- Find out conversion rate from x_from_currency to EURO
		euro_code := get_euro_code;
		other_rate := get_other_rate( x_from_currency, euro_code,
				              x_conversion_date,
					      x_conversion_type );

		-- Get conversion amt by converting OTHER -> EURO -> EMU
		converted_amount := ( x_amount * other_rate ) * to_rate;

	ELSIF ( to_type = 'EURO' ) THEN
		other_rate := get_other_rate( x_from_currency, x_to_currency,
					      x_conversion_date,
					      x_conversion_type );
		converted_amount := x_amount * other_rate;

	ELSIF ( to_type = 'OTHER' ) THEN
		other_rate := get_other_rate( x_from_currency, x_to_currency,
				       	      x_conversion_date,
					      x_conversion_type );
	 	converted_amount := x_amount * other_rate;
	END IF;
     END IF;

     -- Rounding to the correct precision and minumum accountable units
     return( round( converted_amount / to_mau ) * to_mau );

  END convert_amount;

  --
  -- Function
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    functional currency of that ledgers.  The amount returned is
  --    rounded to the precision and minimum account unit of the to currency.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_amount			Amount to be converted from the from currency
  -- 				into the functional currency of the ledgers
  --
  --
  FUNCTION convert_amount (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER ) RETURN NUMBER IS
    to_currency 		VARCHAR2(15);
    converted_amount 		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call convert_amount() with the to_currency we get from the Ledger
     converted_amount := convert_amount( x_from_currency, to_currency,
				  	 x_conversion_date, x_conversion_type,
					 x_amount );

     return( converted_amount );

  END convert_amount;


  --
  -- Function
  --   convert_amount_sql
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type by
  --    calling convert_amount().
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --
  FUNCTION convert_amount_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER ) RETURN NUMBER IS

    converted_amount 		NUMBER;
  BEGIN
    converted_amount := convert_amount( x_from_currency, x_to_currency,
					x_conversion_date, x_conversion_type,
				    	x_amount );
    return( converted_amount );

    EXCEPTION
	WHEN NO_RATE THEN
	  converted_amount := -1;
	  return( converted_amount );

	WHEN INVALID_CURRENCY THEN
	  converted_amount := -2;
	  return( converted_amount );

  END convert_amount_sql;

  --
  -- Function
  --   convert_amount_sql
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    functional currency of that ledgers by calling convert_amount().
  --    The amount returned is rounded to the precision and minimum account
  --    unit of the to currency.
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   04-DEC-97  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_amount			Amount to be converted from the from currency
  -- 				into the functional currency of the ledgers
  --
  --
  FUNCTION convert_amount_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER ) RETURN NUMBER IS

    converted_amount 		NUMBER;
  BEGIN
    converted_amount := convert_amount( x_set_of_books_id, x_from_currency,
					x_conversion_date, x_conversion_type,
				    	x_amount );
    return( converted_amount );

    EXCEPTION
	WHEN NO_RATE THEN
	  converted_amount := -1;
	  return( converted_amount );

	WHEN INVALID_CURRENCY THEN
	  converted_amount := -2;
	  return( converted_amount );

  END convert_amount_sql;

  --
  -- Function
  --   get_derive_type
  -- Purpose
  --   Gets derive type for a currency.
  --
  --   NOTE:  This function is for GL ONLY!
  --          It'll returns GL specific derive type.
  --
  -- History
  --   08/07/97  	K Chen		Created
  -- Arguments
  --   ledger_id	 NUMBER
  --   period	 VARCHAR2
  --   curr_code VARCHAR2
  -- Example
  --   :Parameter.derive_type := glxrvsub_pkg.get_derive_type
  --		(:Parameter.access_set_id, :OPTIONS.period_name,
  --		 :Parameter.func_curr_code);
  -- Notes
  --
  FUNCTION get_derive_type (ledger_id NUMBER, period VARCHAR2, curr_code VARCHAR2)
	RETURN VARCHAR2 IS
    derive_type VARCHAR2(8);
    derive_effective DATE;
  BEGIN

	SELECT 	derive_type, derive_effective
	INTO 	derive_type, derive_effective
	FROM	fnd_currencies
	WHERE	currency_code = curr_code;

	IF (derive_type IS NULL or
	    derive_type = 'OTHER') THEN
		RETURN 'OTHER';
	END IF;

	IF (derive_type = 'EURO') THEN
		RETURN 'EURO';
	END IF;

	IF (derive_effective IS NOT NULL) THEN
		SELECT 	DECODE(SIGN(trunc(derive_effective) -
	                            trunc(GPS.end_date)), 1,
			'OTHER',
			DECODE (SIGN(trunc(GPS.start_date) -
	                             trunc(derive_effective)), 1,
			'EMU',
			'INTER'))
		INTO	derive_type
		FROM	gl_period_statuses GPS
		WHERE 	GPS.application_id = 101
		AND	GPS.ledger_id = ledger_id
		AND	GPS.period_name = period;

		RETURN derive_type;
	ELSE
		RETURN 'ERROR';
	END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	raise NO_DERIVE_TYPE;
  END get_derive_type;

  --
  -- Function
  --   rate_exists
  --
  -- Purpose
  -- 	Returns 'Y' if there is a conversion rate between the two currencies
  --                for a given conversion date and conversion type;
  --            'N' otherwise.
  --
  -- History
  --   03-SEP-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION rate_exists (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 IS
    rate NUMBER;
  BEGIN
    rate := get_rate( x_from_currency, x_to_currency,
	              x_conversion_date, x_conversion_type );

    -- Conversion rates exists between these two currencies for the given
    -- conversion rate and conversion date.
    return( 'Y' );

  EXCEPTION
  WHEN NO_RATE THEN
    -- Conversion rates does not exist between these two currencies for the
    -- given conversion rate and conversion date.
    return( 'N' );

  END rate_exists;

  --
  -- Function
  --   get_rate_numerator_sql
  --
  -- Purpose
  -- 	Returns the numerator we should use to calculate the conversion
  --    rate between the two currencies for a given conversion date and
  --    conversion type.
  --
  --    Return -1 if the NO_RATE exception is raised.
  --           -2 if the INVALID_CURRENCY exception is raised.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_numerator_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    euro_code		VARCHAR2(15);
    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    to_rate		NUMBER;
    from_rate		NUMBER;
    other_rate		NUMBER;
    mau			NUMBER;       -- Value ignored in this function

  BEGIN

     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( 1 );
     END IF;

     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, mau,
		from_type );

     -- Get currency information from the x_to_currency
     get_info ( x_to_currency, x_conversion_date, to_rate, mau, to_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	IF ( to_type = 'EMU' ) THEN
		return( to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	  	return( 1 );

	ELSIF ( to_type = 'OTHER' ) THEN
		-- Find out conversion rate from EURO to x_to_currency
		euro_code := get_euro_code;
		other_rate := get_other_rate( euro_code, x_to_currency,
				              x_conversion_date,
					      x_conversion_type );

		-- Get conversion rate by converting  EMU -> EURO -> OTHER
		return( other_rate );
	END IF;

     ELSIF ( from_type = 'EURO' ) THEN
	IF ( to_type = 'EMU' ) THEN
 		return( to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	        -- We should never comes to this case as it should be
                -- caught when we check if both to and from currency
                -- is the same at the beginning of this function
		return( 1 );

	ELSIF ( to_type = 'OTHER' ) THEN
	  	other_rate := get_other_rate( x_from_currency, x_to_currency,
				       	      x_conversion_date,
					      x_conversion_type );
	  	return( other_rate );
	END IF;

     ELSIF ( from_type = 'OTHER' ) THEN
	IF ( to_type = 'EMU' ) THEN
		-- Find out conversion rate from x_from_currency to EURO
		euro_code := get_euro_code;
		other_rate := get_other_rate( x_from_currency, euro_code,
	   		                      x_conversion_date,
					      x_conversion_type );

		-- Get conversion rate by converting OTHER -> EURO -> EMU
	  	return( other_rate * to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
		other_rate := get_other_rate( x_from_currency, x_to_currency,
					      x_conversion_date,
					      x_conversion_type );
	  	return( other_rate );

	ELSIF ( to_type = 'OTHER' ) THEN
		other_rate := get_other_rate( x_from_currency, x_to_currency,
				       	      x_conversion_date,
					      x_conversion_type );
	  	return( other_rate );
	END IF;
     END IF;

     EXCEPTION
	WHEN NO_RATE THEN
	  return( -1 );

	WHEN INVALID_CURRENCY THEN
	  return( -2 );

  END get_rate_numerator_sql;

  --
  -- Function
  --   get_rate_numerator_sql
  --
  -- Purpose
  -- 	Returns the numerator we should use to calculate the conversion rate
  --    between the from currency and the functional currency of the
  --    ledgers.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger_id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_numerator_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    to_currency 	VARCHAR2(15);
    numerator		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call get_rate_numerator_sql() with the to_currency we get from the Ledger
     numerator := get_rate_numerator_sql( x_from_currency,
					  to_currency,
  		                          x_conversion_date,
					  x_conversion_type );
     return( numerator );

  END get_rate_numerator_sql;

  --
  -- Function
  --   get_rate_denominator_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use to calculate the conversion
  --    rate between the two currencies for a given conversion date and
  --    conversion type.
  --
  --    Return -1 if the NO_RATE exception is raised.
  --           -2 if the INVALID_CURRENCY exception is raised.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_denominator_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL )
  RETURN NUMBER IS

    euro_code		VARCHAR2(15);
    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    to_rate		NUMBER;
    from_rate		NUMBER;
    other_rate		NUMBER;
    mau			NUMBER;       -- Value ignored in this function

  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( 1 );
     END IF;

     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, mau,
		from_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	return( from_rate );

     ELSE

        return( 1 );
     END IF;

     EXCEPTION
	WHEN NO_RATE THEN
	  return( -1 );

	WHEN INVALID_CURRENCY THEN
	  return( -2 );

  END get_rate_denominator_sql;


  --
  -- Function
  --   get_rate_denominator_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use to calculate the conversion rate
  --    between the from currency and the functional currency of the
  --    ledgers.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_denominator_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL )
  RETURN NUMBER IS

    to_currency 	VARCHAR2(15);
    denominator		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call get_rate_denominator_sql() with the to_currency we get from Ledger
     denominator := get_rate_denominator_sql( x_from_currency,
					      to_currency,
  		                              x_conversion_date,
					      x_conversion_type );
     return( denominator );
  END get_rate_denominator_sql;

  --
  -- Procedure
  --   get_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator and denominator we should use to calculate
  --    the conversion rate between the two currencies, and the actual
  --    conversion rate for a given conversion date and conversion type.
  --
  --    Note: When you are calculating the triangulation rate, you should
  --          always divide by the x_denominator before you multiply by
  --          the x_numerator.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --
  PROCEDURE get_triangulation_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_denominator		IN OUT NOCOPY	NUMBER,
	        x_numerator		IN OUT NOCOPY 	NUMBER,
		x_rate                  IN OUT NOCOPY  NUMBER ) IS
  BEGIN
    -- Get value of numerator and denominator
    x_numerator := get_rate_numerator_sql( x_from_currency,
					   x_to_currency,
				  	   x_conversion_date,
					   x_conversion_type );

    x_denominator := get_rate_denominator_sql ( x_from_currency,
						x_to_currency,
              		          		x_conversion_date,
						x_conversion_type );

    -- Get conversion rate by using the x_numerator and x_denominator
    IF (( x_numerator > 0 ) AND ( x_denominator > 0 )) THEN
      x_rate := x_numerator / x_denominator;

    ELSE
      IF (( x_numerator = -2 ) OR (x_denominator = -2 )) THEN
	raise INVALID_CURRENCY;

      ELSE
        raise NO_RATE;
      END IF;
    END IF;

  END get_triangulation_rate;

  --
  -- Procedure
  --   get_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator, denominator and the conversion rate
  --    between the from currency and the functional currency of the
  --    ledgers.
  --
  --    Note: When you are calculating the triangulation rate, you should
  --          always divide by the x_denominator before you multiply by
  --          the x_numerator.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --
  PROCEDURE get_triangulation_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_denominator		IN OUT NOCOPY	NUMBER,
                x_numerator		IN OUT NOCOPY 	NUMBER,
		x_rate                  IN OUT NOCOPY  NUMBER) IS

    to_currency	  VARCHAR2(15);

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

    -- Get value of numerator and denominator
    x_numerator := get_rate_numerator_sql( x_from_currency,
					   to_currency,
				           x_conversion_date,
					   x_conversion_type );

    x_denominator := get_rate_denominator_sql( x_from_currency,
		      			       to_currency,
					       x_conversion_date,
					       x_conversion_type );

    -- Get conversion rate by using the x_numerator and x_denominator
    IF (( x_numerator > 0 ) AND ( x_denominator > 0 )) THEN
      x_rate := x_numerator / x_denominator;

    ELSE
      IF (( x_numerator = -2 ) OR (x_denominator = -2 )) THEN
	raise INVALID_CURRENCY;
      ELSE
        raise NO_RATE;
      END IF;
    END IF;

  END get_triangulation_rate;

  --
  -- Function
  --   get_closest_rate_numerator_sql
  --
  -- Purpose
  -- 	Returns the numerator we should use between the two currencies for
  --    a given conversion date and conversion type.
  --
  --    Return -1 if the NO_RATE exception is raised.
  --           -2 if the INVALID_CURRENCY exception is raised.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate_numerator_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER) RETURN NUMBER IS

    euro_code		VARCHAR2(15);
    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    to_rate		NUMBER;
    from_rate		NUMBER;
    other_rate		NUMBER;
    mau			NUMBER;       -- Value ignored in this function

  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( 1 );
     END IF;

     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, mau,
		from_type );

     -- Get currency information from the x_to_currency
     get_info ( x_to_currency, x_conversion_date, to_rate, mau, to_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	IF ( to_type = 'EMU' ) THEN
		return( to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	  	return( 1 );

	ELSIF ( to_type = 'OTHER' ) THEN
		-- Find out conversion rate from EURO to x_to_currency
		euro_code := get_euro_code;
		other_rate := get_other_closest_rate( euro_code,
						      x_to_currency,
				                      x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
		return( other_rate );
	END IF;

     ELSIF ( from_type = 'EURO' ) THEN
	IF ( to_type = 'EMU' ) THEN
 		return( to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
	        -- We should never comes to this case as it should be
                -- caught when we check if both to and from currency
                -- is the same at the beginning of this function
		return( 1 );

	ELSIF ( to_type = 'OTHER' ) THEN
	  	other_rate := get_other_closest_rate( x_from_currency,
						      x_to_currency,
				       	              x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
	  	return( other_rate );
	END IF;

     ELSIF ( from_type = 'OTHER' ) THEN
	IF ( to_type = 'EMU' ) THEN
		-- Find out conversion rate from x_from_currency to EURO
		euro_code := get_euro_code;
		other_rate := get_other_closest_rate( x_from_currency,
						      euro_code,
				                      x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );

		-- Get conversion rate by converting OTHER -> EURO -> EMU
	  	return( other_rate * to_rate );

	ELSIF ( to_type = 'EURO' ) THEN
		other_rate := get_other_closest_rate( x_from_currency,
						      x_to_currency,
					              x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
	  	return( other_rate );

	ELSIF ( to_type = 'OTHER' ) THEN
		other_rate := get_other_closest_rate( x_from_currency,
						      x_to_currency,
				       	              x_conversion_date,
					              x_conversion_type,
						      x_max_roll_days );
	  	return( other_rate );
	END IF;
     END IF;

     EXCEPTION
	WHEN NO_RATE THEN
	  return( -1 );

	WHEN INVALID_CURRENCY THEN
	  return( -2 );

  END get_closest_rate_numerator_sql;

  --
  -- Function
  --   get_closest_rate_numerator_sql
  --
  -- Purpose
  -- 	Returns the numerator we should use to get the conversion rate
  --    between the from currency and the functional currency of the
  --    ledgers.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate_numerator_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER) RETURN NUMBER IS

    to_currency 	VARCHAR2(15);
    numerator		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call get_closest_rate() with the to_currency we get from the Ledger
     numerator := get_closest_rate_numerator_sql( x_from_currency,
		   	                          to_currency,
 			                          x_conversion_date,
	   	       	                          x_conversion_type,
			                          x_max_roll_days );
     return( numerator );

     EXCEPTION
	WHEN NO_RATE THEN
	  return( -1 );

	WHEN INVALID_CURRENCY THEN
	  return( -2 );

   END get_closest_rate_numerator_sql;

  --
  -- Function
  --   get_closest_rate_denom_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use between the two currencies for
  --    a given conversion date and conversion type.
  --
  --    Return -1 if the NO_RATE exception is raised.
  --           -2 if the INVALID_CURRENCY exception is raised.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate_denom_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER) RETURN NUMBER IS

    euro_code		VARCHAR2(15);
    to_type   		VARCHAR2(8);
    from_type 		VARCHAR2(8);
    to_rate		NUMBER;
    from_rate		NUMBER;
    other_rate		NUMBER;
    mau			NUMBER;       -- Value ignored in this function

  BEGIN
     -- Check if both currencies are identical
     IF ( x_from_currency = x_to_currency ) THEN
	return( 1 );
     END IF;

     -- Get currency information from the x_from_currency
     get_info ( x_from_currency, x_conversion_date, from_rate, mau,
		from_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
	return( from_rate );

     ELSE

	return( 1 );
     END IF;

     EXCEPTION
	WHEN NO_RATE THEN
	  return( -1 );

	WHEN INVALID_CURRENCY THEN
	  return( -2 );

  END get_closest_rate_denom_sql;

  --
  -- Function
  --   get_closest_rate_denom_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use to get the conversion rate
  --    between the from currency and the functional currency of the
  --    ledgers.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate_denom_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER) RETURN NUMBER IS

    to_currency 	VARCHAR2(15);
    denominator		NUMBER;

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

     -- Call get_closest_rate_denom_sql() with the to_currency
     -- we get from the Ledger
     denominator := get_closest_rate_denom_sql( x_from_currency,
        		                 	to_currency,
			                 	x_conversion_date,
	   	       	                 	x_conversion_type,
			                 	x_max_roll_days );

     return( denominator );

  END get_closest_rate_denom_sql;

  --
  -- Procedure
  --   get_closest_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator, denominator and the conversion rate between
  --    the two currencies for a given conversion date and conversion type.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --
  PROCEDURE get_closest_triangulation_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_max_roll_days         NUMBER,
		x_denominator		IN OUT NOCOPY	NUMBER,
	        x_numerator		IN OUT NOCOPY 	NUMBER,
		x_rate                  IN OUT NOCOPY  NUMBER ) IS
  BEGIN
    -- Get value of numerator and denominator
    x_numerator := get_closest_rate_numerator_sql( x_from_currency,
						   x_to_currency,
				  		   x_conversion_date,
						   x_conversion_type,
						   x_max_roll_days );

    x_denominator := get_closest_rate_denom_sql ( x_from_currency,
				                  x_to_currency,
              		                          x_conversion_date,
						  x_conversion_type,
						  x_max_roll_days );

    -- Get conversion rate by using the x_numerator and x_denominator
    IF (( x_numerator > 0 ) AND ( x_denominator > 0 )) THEN
      x_rate := x_numerator / x_denominator;

    ELSE
      IF (( x_numerator = -2 ) OR (x_denominator = -2 )) THEN
	raise INVALID_CURRENCY;
      ELSE
        raise NO_RATE;
      END IF;
    END IF;
  END get_closest_triangulation_rate;

  --
  -- Procedure
  --   get_closest_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator, denominator and the conversion rate
  --    between the from currency and the functional currency of the
  --    ledgers.
  --
  -- History
  --   11-MAY-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --
  PROCEDURE get_closest_triangulation_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER,
		x_denominator		IN OUT NOCOPY	NUMBER,
                x_numerator		IN OUT NOCOPY 	NUMBER,
		x_rate                  IN OUT NOCOPY  NUMBER) IS

    to_currency  VARCHAR2(15);

  BEGIN
     -- Get to_currency from GL_LEDGERS, i.e. the functional currency
     SELECT 	currency_code
     INTO	to_currency
     FROM	GL_LEDGERS
     WHERE	ledger_id = x_set_of_books_id;

    -- Get value of numerator and denominator
    x_numerator := get_closest_rate_numerator_sql( x_from_currency,
						   to_currency,
						   x_conversion_date,
						   x_conversion_type,
						   x_max_roll_days );

    x_denominator := get_closest_rate_denom_sql( x_from_currency,
						 to_currency,
						 x_conversion_date,
						 x_conversion_type,
						 x_max_roll_days );

    -- Get conversion rate by using the x_numerator and x_denominator
    IF (( x_numerator > 0 ) AND ( x_denominator > 0 )) THEN
      x_rate := x_numerator / x_denominator;

    ELSE
      IF (( x_numerator = -2 ) OR (x_denominator = -2 )) THEN
	raise INVALID_CURRENCY;
      ELSE
        raise NO_RATE;
      END IF;
    END IF;

  END get_closest_triangulation_rate;


  --
  -- Procedure
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the numerator and denominator we should use to calculate
  --    the conversion rate between the two currencies, the actual
  --    conversion rate for a given conversion date and conversion type,
  -- 	and the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type.
  --
  -- History
  --   02-JUN-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --   x_converted_amount       Converted amount
  --
  PROCEDURE convert_amount(
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER,
		x_converted_amount      IN OUT NOCOPY NUMBER,
		x_denominator           IN OUT NOCOPY NUMBER,
		x_numerator  		IN OUT NOCOPY NUMBER,
		x_rate			IN OUT NOCOPY NUMBER ) IS

    to_rate			NUMBER;
    to_mau			NUMBER;
    to_type   			VARCHAR2(8);

  BEGIN
    -- Get currency information from the to_currency ( for use in rounding )
    get_info ( x_to_currency, x_conversion_date, to_rate, to_mau, to_type );

    -- Get the conversion information
    get_triangulation_rate( x_from_currency,
			    x_to_currency,
			    x_conversion_date,
   			    x_conversion_type,
			    x_denominator,
			    x_numerator,
			    x_rate );

    -- Calculate the converted amount using triangulation method
    x_converted_amount := ( x_amount / x_denominator ) * x_numerator;

    -- Rounding to the correct precision and minumum accountable units
    x_converted_amount :=  round( x_converted_amount / to_mau ) * to_mau;

  END convert_amount;


  --
  -- Procedure
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the numerator and denominator we should use to calculate
  --    the conversion rate, and the actual conversion rate between the
  --    from currency and the functional currency of the ledgers,
  -- 	and the amount converted from the from currency into the
  --    functional currency of that ledgers.
  --
  -- History
  --   02-JUN-98  W Wong 	Created
  --
  -- Arguments
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --   x_converted_amount       Converted amount
  --
  PROCEDURE convert_amount(
		x_set_of_books_id       NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER,
		x_converted_amount      IN OUT NOCOPY NUMBER,
		x_denominator           IN OUT NOCOPY NUMBER,
		x_numerator  		IN OUT NOCOPY NUMBER,
		x_rate			IN OUT NOCOPY NUMBER ) IS

    to_currency 		VARCHAR2(15);
    to_rate			NUMBER;
    to_mau			NUMBER;
    to_type   			VARCHAR2(8);

  BEGIN
    -- Get to_currency from GL_LEDGERS, i.e. the functional currency
    SELECT 	currency_code
    INTO	to_currency
    FROM	GL_LEDGERS
    WHERE	ledger_id = x_set_of_books_id;

    -- Get currency information from the to_currency ( for use in rounding )
    get_info ( to_currency, x_conversion_date, to_rate, to_mau, to_type );

    -- Get the conversion information
    get_triangulation_rate( x_from_currency,
			    to_currency,
			    x_conversion_date,
   			    x_conversion_type,
			    x_denominator,
			    x_numerator,
			    x_rate );

    -- Calculate the converted amount using triangulation method
    x_converted_amount := ( x_amount / x_denominator ) * x_numerator;

    -- Rounding to the correct precision and minumum accountable units
    x_converted_amount :=  round( x_converted_amount / to_mau ) * to_mau;

  END convert_amount;


  --
  -- Function
  --   convert_closest_amount_sql
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type.
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  --    If x_conversion_type = 'User', and the relationship between the
  --    two currencies is not fixed, x_user_rate will be used as the
  --    conversion rate to convert the amount.
  --
  --    If there is a fixed relationship between the two currencies,
  --    the fixed rate will be used instead of the x_user_rate.
  --
  --    If x_convserion_type is not 'User', the routine will try to
  --    find the conversion rate using the given x_conversion_date and
  --    x_conversion_type.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
  --
  --    Return -1 if the NO_RATE exception is raised.
  --           -2 if the INVALID_CURRENCY exception is raised.
  --
  -- History
  --   10-SEP-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_user_rate		User conversion rate
  --   x_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION convert_closest_amount_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_user_rate             NUMBER,
		x_amount		NUMBER,
	        x_max_roll_days         NUMBER ) RETURN NUMBER IS

    to_rate			NUMBER;
    to_mau			NUMBER;
    to_type   			VARCHAR2(8);
    denominator 		NUMBER;
    numerator 			NUMBER;
    converted_amount  		NUMBER;

  BEGIN

    -- Check if both currencies are identical
    IF ( x_from_currency = x_to_currency ) THEN
	converted_amount := x_amount;
    	return( converted_amount );
    END IF;

    -- Get currency information from the to_currency ( for use in rounding )
    get_info ( x_to_currency, x_conversion_date, to_rate, to_mau, to_type );

    --
    -- Find out the conversion rate that should be used.
    --
    IF ( x_conversion_type = 'User' ) THEN
       IF ( is_fixed_rate( x_from_currency, x_to_currency,
	   		   x_conversion_date ) = 'N' ) THEN
         --
         -- Conversion type is 'User' and the relationship between both
         -- currencies is not a fixed relationship. The given user rate
         -- is used for the conversion.
         --
         denominator := 1;
         numerator   := x_user_rate;

         -- Calculate the converted amount using triangulation method
         converted_amount := ( x_amount / denominator ) * numerator;

         -- Rounding to the correct precision and minumum accountable units
         converted_amount :=  round( converted_amount / to_mau ) * to_mau;
         return( converted_amount );

       END IF;
    END IF;

    --
    -- Conversion type is not 'User', or
    -- there is a fixed relationship between the currencies.
    -- Find out the conversion rate using the given conversion type
    -- and conversion date.
    --
    denominator := get_closest_rate_denom_sql( x_from_currency,
	  		             	       x_to_currency,
					       x_conversion_date,
					       x_conversion_type,
   				               x_max_roll_days );

    numerator   := get_closest_rate_numerator_sql( x_from_currency,
		  			           x_to_currency,
						   x_conversion_date,
						   x_conversion_type,
						   x_max_roll_days );

    IF (( numerator > 0 ) AND ( denominator > 0 )) THEN
      	--
      	-- We have a conversion rate to convert the amount
      	--

      	-- Calculate the converted amount using triangulation method
      	converted_amount := ( x_amount / denominator ) * numerator;

      	-- Rounding to the correct precision and minumum accountable units
    	converted_amount :=  round( converted_amount / to_mau ) * to_mau;
	return( converted_amount );

    ELSE
      IF (( numerator = -2 ) OR ( denominator = -2 )) THEN
          -- Either the x_from_currency or x_to_currency is invalid
    	  converted_amount := -2;
          return( converted_amount );

       ELSE
	  -- No conversion rate was found between the two currencies with
          -- the given conversion type and conversion date
	  converted_amount := -1;
          return( converted_amount );
       END IF;
    END IF;

  EXCEPTION
    WHEN INVALID_CURRENCY THEN
	 converted_amount := -2;
         return( converted_amount );

  END convert_closest_amount_sql;


  --
  -- Procedure
  --   convert_closest_amount
  --
  -- Purpose
  -- 	Returns the rate denominator, rate numerator and conversion rate
  --    the routine has used to convert the given amount.  Also returns
  --    the converted amount.
  --
  --    If x_conversion_type = 'User', and the relationship between the
  --    two currencies is not fixed, x_user_rate will be used as the
  --    conversion rate to convert the amount.
  --
  --    If there is a fixed relationship between the two currencies,
  --    the fixed rate will be used instead of the x_user_rate.
  --
  --    If x_convserion_type is not 'User', the routine will try to
  --    find the conversion rate using the given x_conversion_date and
  --    x_conversion_type.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
  --
  -- History
  --   10-SEP-98  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_user_rate		User conversion rate
  --   x_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   x_max_roll_days		Number of days to rollback for a rate
  --   x_converted_amount       Converted amount
  --   x_denominator            Denominator to get conversion rate
  --   x_numerator              Numerator to get conversion rate
  --   x_rate                   Conversion rate
  --
  PROCEDURE convert_closest_amount(
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_user_rate		NUMBER,
		x_amount		NUMBER,
		x_max_roll_days		NUMBER,
		x_converted_amount      IN OUT NOCOPY NUMBER,
		x_denominator           IN OUT NOCOPY NUMBER,
		x_numerator  		IN OUT NOCOPY NUMBER,
		x_rate			IN OUT NOCOPY NUMBER ) IS
    to_rate			NUMBER;
    to_mau			NUMBER;
    to_type   			VARCHAR2(8);
    denominator                 NUMBER;
    numerator                   NUMBER;
    rate                        NUMBER;
    converted_amount		NUMBER;

  BEGIN

    -- Check if both currencies are identical
    IF ( x_from_currency = x_to_currency ) THEN
	 x_converted_amount := x_amount;
	 x_denominator      := 1;
	 x_numerator        := 1;
         x_rate             := 1;
	 return;
    END IF;

    -- Get currency information from the to_currency ( for use in rounding )
    get_info ( x_to_currency, x_conversion_date, to_rate, to_mau, to_type );

    --
    -- Find out the conversion rate that should be used.
    --
    IF ( x_conversion_type = 'User' ) THEN
      IF ( is_fixed_rate( x_from_currency, x_to_currency,
	                  x_conversion_date ) = 'N' ) THEN
        --
        -- Conversion type is 'USER' and the relationship between both
        -- currencies is not a fixed relationship. The given user rate
        -- is used for the conversion.
        --
	x_denominator := 1;
	x_numerator   := x_user_rate;
	x_rate        := x_user_rate;

        -- Calculate the converted amount using triangulation method
        x_converted_amount := ( x_amount / x_denominator ) * x_numerator;

        -- Rounding to the correct precision and minumum accountable units
        x_converted_amount :=  round( x_converted_amount / to_mau ) * to_mau;
	return;

      END IF;
    END IF;

    --
    -- Conversion type is not 'User', or
    -- there is a fixed relationship between the currencies.
    -- Find out the conversion rate using the given conversion type
    -- and conversion date.
    --
    get_closest_triangulation_rate( x_from_currency,
 			            x_to_currency,
			            x_conversion_date,
   			            x_conversion_type,
	 		            x_max_roll_days,
			            denominator,
			            numerator,
			            rate );

    -- Assign conversion info to output variables
    x_denominator := denominator;
    x_numerator   := numerator;
    x_rate        := rate;

    -- Calculate the converted amount using triangulation method
    x_converted_amount := ( x_amount / x_denominator ) * x_numerator;

    -- Rounding to the correct precision and minumum accountable units
    x_converted_amount :=  round( x_converted_amount / to_mau ) * to_mau;

  END convert_closest_amount;

END gl_currency_api;


/
