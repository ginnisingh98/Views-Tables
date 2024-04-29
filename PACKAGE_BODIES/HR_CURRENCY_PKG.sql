--------------------------------------------------------
--  DDL for Package Body HR_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CURRENCY_PKG" AS
/* $Header: pyemucnv.pkb 120.2.12010000.2 2008/08/06 07:11:02 ubhat ship $ */
  --
  -- The following type and global declarations are only to be used by
  -- the add_to_efc_currency_list procedure, efc_convert_number_amount,
  -- efc_convert_varchar2_amount and efc_is_ncu_currency functions. This
  -- provides a cache of values required by the EFC conversion process.
  --
  TYPE tl_efc_currency_code IS TABLE OF fnd_currencies.currency_code%TYPE
    INDEX BY BINARY_INTEGER;
  g_efc_currency_code        tl_efc_currency_code;
  g_rate_currency_code_tab   tl_efc_currency_code;
  g_rate_empty_currency_tab  tl_efc_currency_code;
  --
  TYPE tl_efc_derive_factor IS TABLE OF fnd_currencies.derive_factor%TYPE
    INDEX BY BINARY_INTEGER;
  g_efc_derive_factor tl_efc_derive_factor;
  --
  TYPE tl_efc_is_ncu_sysdate IS TABLE OF boolean INDEX BY BINARY_INTEGER;
  g_efc_is_ncu_sysdate tl_efc_is_ncu_sysdate;
  --
  TYPE tl_conversion_rate IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_rate_conversion_tab        tl_conversion_rate;
  g_rate_empty_rate_tab        tl_conversion_rate;
  --
  g_efc_eur_mau        number default null;
  --
  -- The following global variables are used like local variables in
  -- the add_to_efc_currency_list procedure, efc_convert_number_amount
  -- and efc_is_ncu_currency functions. Defined as global variables for
  -- performance reasons.
  --
  g_hash_number binary_integer;  -- Value used to hash on the currency cache
  g_rounding    number;          -- Factor to use in rounding the EUR amount
  g_derive_effective fnd_currencies.derive_effective%TYPE; -- Value from table
  g_derive_type      fnd_currencies.derive_type%TYPE;      -- Value from table
  g_derive_factor    fnd_currencies.derive_factor%TYPE;    -- Value from table
  --
  -- The following global variables are used for chaching in function
  -- get_other_rate
  --
  g_from_currency     	gl_daily_rates.from_currency%TYPE   := null;
  g_to_currency		gl_daily_rates.to_currency%TYPE     := null;
  g_conversion_date   	gl_daily_rates.conversion_date%TYPE := null;
  g_conversion_type    	gl_daily_rates.conversion_type%TYPE := null;
  g_conversion_rate	gl_daily_rates.conversion_rate%TYPE := null;
  --
  -- The following global variables are used for caching in function
  -- convert_amount
  --
  g_rate_conversion_date   gl_daily_rates.conversion_date%TYPE;
  g_rate_to_currency       gl_daily_rates.to_currency%TYPE;
  g_rate_rate_type         gl_daily_rates.conversion_type%TYPE;
  g_rate_rounding          NUMBER;
  g_rate_to_rate           NUMBER;
  g_rate_to_mau            NUMBER;
  g_rate_to_type           VARCHAR2(8);
  --
-- --------------------------------------------------------------------------
-- |----------------------------< get_info >--------------------------------|
-- --------------------------------------------------------------------------
 --
 -- Purpose
 --    Gets the currency type information about given currency.
 --    Also set the p_invalid_currency flag if the given currency is invalid.
 --
 -- Arguments
 --   p_currency               Currency to be checked
 --   p_eff_date               Effective date
 --   p_conversion_rate        Fixed rate for conversion
 --   p_mau                    Minimum accountable unit
 --   p_currency_type          Type of currency specified in p_currency
 --
 -- ----------------------------------------------------------------------------
    PROCEDURE get_info(
               p_currency   VARCHAR2,
               p_eff_date   DATE,
	       p_conversion_rate IN OUT NOCOPY NUMBER,
	       p_mau             IN OUT NOCOPY NUMBER,
               p_currency_type   IN OUT NOCOPY VARCHAR2) IS
 --
  BEGIN
 -- Get currency information from FND_CURRENCIES table
  SELECT   DECODE(
             fc.derive_type,
	       'EURO', 'EURO',
		  'EMU', DECODE(
		   SIGN(TRUNC(p_eff_date) - TRUNC(fc.derive_effective)),
		   -1, 'OTHER',
		  'EMU'),
		  'OTHER'),
		  DECODE(
		  fc.derive_type,
		  'EURO', 1,
	          'EMU', fc.derive_factor,
		  'OTHER', -1),
	        NVL(fc.minimum_accountable_unit,
             POWER(10, (-1 * fc.precision)))
	  INTO     p_currency_type,
                p_conversion_rate,
                p_mau
	  FROM     fnd_currencies fc
	 WHERE     fc.currency_code = p_currency;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RAISE invalid_currency;
   END get_info;

-- -------------------------------------------------------------------------
-- |--------------------------< is_fixed_rate >----------------------------|
-- -------------------------------------------------------------------------
  -- History
  --  15/11/00   Kev Koh 	created
  --
  -- Purpose
  --  Returns if there is a fixed rate between the two currencies.
  --
  -- Arguments
  --   p_from_currency    From currency
  --   p_to_currency      To currency
  --   p_effective_date   Effective date
  --
-- -------------------------------------------------------------------------
  FUNCTION is_fixed_rate(
    p_from_currency  VARCHAR2,
    p_to_currency    VARCHAR2,
    p_effective_date DATE)
    RETURN VARCHAR2 IS
    --
  --
  BEGIN
    -- Check if both currencies are identical
    IF (p_from_currency = p_to_currency) THEN
      RETURN 'Y';
    END IF;
    --
    RETURN gl_currency_api.is_fixed_rate(p_from_currency,
                                         p_to_currency,
                                         p_effective_date
                                         ) ;
  --
  END is_fixed_rate;

  --
  -- FUNCTION
  --   get_euro_code
  --
  -- Purpose
  --      Returns the currency code for the EURO currency.  We need to
  --    select this currency code from fnd_currencies table because
  --    the currency code for EURO has not been fixed at this time.
  --
  -- History
  --   24-JUL-97  W Wong      Created
  --
  -- Arguments
  --   None.
  --
  FUNCTION get_euro_code RETURN VARCHAR2 IS
 euro_code  VARCHAR2(15);

  BEGIN
  -- Get currency code of the EURO currency
 SELECT     currency_code
 INTO       euro_code
 FROM       FND_CURRENCIES
 WHERE derive_type = 'EURO';

  return( euro_code );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  raise INVALID_CURRENCY;

 END get_euro_code;

-- --------------------------------------------------------------------------
-- |------------------------< check_rate_type >-----------------------------|
-- --------------------------------------------------------------------------
  --
  -- Purpose
  -- checks that rate type exists in gl_daily_conversion_types
  --
  -- returns -2 if User rate (which we won't to disallow)
  --         -1 if rate type not found
  --          1 if record exists
  --
  -- History
  --  02/02/99   wkerr.uk 	created
  --
  -- Arguments
  -- p_rate_type	The rate type to check
  --
  Function check_rate_type(
		p_rate_type VARCHAR2) RETURN NUMBER IS
     l_conversion_type gl_daily_conversion_types.conversion_type%type;
     l_return_count NUMBER;
  BEGIN
--
     select conversion_type
     into   l_conversion_type
     from gl_daily_conversion_types
     where user_conversion_type = p_rate_type;
--
     if l_conversion_type = 'User' then
        l_return_count := -2;
     else
        l_return_count := 1;
     end if;

    RETURN l_return_count;
--
  EXCEPTION
     WHEN OTHERS THEN
        RETURN -1;
--
  END check_rate_type;
  --
-- --------------------------------------------------------------------------
-- |-----------------------< get_rate_type >--------------------------------|
-- --------------------------------------------------------------------------
  --
  -- Purpose
  --  Returns the rate type given the business group, effective date and
  --  processing type
  --
  --  Current processing types are:-
  --  		            P - Payroll Processing
  --                        R - General HRMS reporting
  --            	    I - Business Intelligence System
  --
  -- History
  --  22/01/99	wkerr.uk	Created
  --
  --  Arguments
  --  p_business_group_id	The business group
  --  p_effective_date		The date for which to return the rate type
  --  p_processing_type		The processing type of which to return the rate
  --
  --  Returns null if no rate type found
  --
  --
  FUNCTION get_rate_type (
		p_business_group_id	NUMBER,
		p_conversion_date	DATE,
		p_processing_type	VARCHAR2 ) RETURN VARCHAR2 IS
--
        l_row_name varchar2(30);
        l_value    pay_user_column_instances_f.value%type;
        l_conversion_type varchar2(30);
  BEGIN
--
        if p_processing_type = 'P' then
           l_row_name := 'PAY' ;
        elsif p_processing_type = 'R' then
           l_row_name := 'HRMS';
        elsif p_processing_type = 'I' then
           l_row_name := 'BIS';
        else
  	   return null;
  	end if;
--
	l_value := hruserdt.get_table_value(p_business_group_id,
                                            'EXCHANGE_RATE_TYPES',
                                            'Conversion Rate Type' ,
					    l_row_name ,
					    p_conversion_date) ;
--
--      l_value is a user_conversion_type
--      we want to return the conversion_type, hence:
--
        select conversion_type
        into l_conversion_type
        from gl_daily_conversion_types
        where user_conversion_type = l_value;
--
        return l_conversion_type;
--
  EXCEPTION
     WHEN OTHERS THEN
	RETURN null;
--         Don't know what the problem was with the user the table.
--         However don't want to percolate an exception from get_table_value
--         Request from payroll team for this to be put in.
  END get_rate_type;

-- --------------------------------------------------------------------------
-- |-----------------------< get_other_rate >-------------------------------|
-- --------------------------------------------------------------------------
  --
  -- Purpose
  --    Returns conversion rate between two currencies where both currencies
  --    are not the EURO, or EMU currencies.
  --
  -- History
  --   16-NOV-00 Kev Koh    Created
  --   11-DEC-02 J Barker   Added caching, bug 2678944
  --   11-MAY-04 mkataria   Trapped NO_DATA_FOUND exception.
  --                        Bug No 3464343.
  -- Arguments
  --   p_from_currency        From currency
  --   p_to_currency          To currency
  --   p_conversion_date      Conversion date
  --   p_conversion_type      Conversion type
  --
  FUNCTION get_other_rate (
          p_from_currency     VARCHAR2,
          p_to_currency       VARCHAR2,
          p_conversion_date   DATE,
          p_conversion_type   VARCHAR2 ) RETURN NUMBER IS

    rate NUMBER;

  BEGIN
    --
    if ( g_conversion_date is not null )
      and ( p_conversion_date = g_conversion_date )
        and ( p_to_currency = g_to_currency )
	  and ( p_from_currency = g_from_currency )
	    and ( p_conversion_type = g_conversion_type ) then
	--
	rate := g_conversion_rate;
hr_utility.trace(' cache '||rate);
	return(rate);
	--
    else
        -- Get conversion rate between the two currencies from GL_DAILY_RATES
        SELECT    conversion_rate
        INTO      rate
        FROM      GL_DAILY_RATES
        WHERE     from_currency = p_from_currency
        AND  to_currency     = p_to_currency
        AND  conversion_date = trunc(p_conversion_date)
        AND  conversion_type = p_conversion_type;
hr_utility.trace('not cache '||rate);
	--
	--  set global cache values
	--
 	g_from_currency := p_from_currency;
	g_to_currency := p_to_currency;
	g_conversion_date := p_conversion_date;
	g_conversion_type := p_conversion_type;
  	g_conversion_rate := rate;
        --
        return(rate);
	--
     end if;

  EXCEPTION
        --  Removed exception gl_currency_api.NO_RATE and trapped
        --  NO_DATA_FOUND. Bug No 3464343.
          WHEN NO_DATA_FOUND THEN
          RAISE gl_currency_api.NO_RATE;
  END get_other_rate;

-- ------------------------------------------------------------------------
-- |----------------------< get_rate >------------------------------------|
-- ------------------------------------------------------------------------
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and rate type.
  --
  -- History
  --   22-APR-1998 	wkerr.uk   	Created
  --
  --
  --
  -- Arguments
  --   p_from_currency          From currency
  --   p_to_currency            To currency
  --   p_conversion_date        Conversion date
  --   p_rate_type              Rate Type
  --
  FUNCTION get_rate (
		p_from_currency	        VARCHAR2,
		p_to_currency    	VARCHAR2,
		p_conversion_date       DATE,
		p_rate_type	        VARCHAR2) RETURN NUMBER IS

  BEGIN
     -- Check if both currencies are identical
     IF ( p_from_currency = p_to_currency ) THEN
	return(1);
     END IF;

     RETURN gl_currency_api.get_rate(p_from_currency,
			            p_to_currency,
			            p_conversion_date,
			            p_rate_type) ;

  END get_rate;

  -- ----------------------------------------------------------------------
  -- |--------------------< get_rate_sql >--------------------------------|
  -- ----------------------------------------------------------------------
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and conversion type by calling get_rate().
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   02-Jun-1998 	wkerr.uk   	Created
  --
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date        Conversion date
  --   p_rate_type              Rate Type
  --
  FUNCTION get_rate_sql (
		p_from_currency   VARCHAR2,
		p_to_currency     VARCHAR2,
		p_conversion_date DATE,
		p_rate_type       VARCHAR2)
                RETURN NUMBER IS
                rate NUMBER;

  BEGIN
    -- Call get_rate() using the given parameters
    rate := get_rate(p_from_currency,
                     p_to_currency,
                     p_conversion_date,
                     p_rate_type );
    return(rate);

    EXCEPTION
	WHEN gl_currency_api.NO_RATE THEN
	  rate := -1;
	  return( rate );

	WHEN gl_currency_api.INVALID_CURRENCY THEN
	  rate := -2;
	  return( rate );

  END get_rate_sql;

-- --------------------------------------------------------------------------
-- |------------------------< is_ncu_currency >-----------------------------|
-- --------------------------------------------------------------------------
  -- Purpose
  --  Returns EMU if currency is a valid NCU code

 FUNCTION is_ncu_currency(
    p_currency VARCHAR2,
    p_date     DATE)
    RETURN VARCHAR2 IS
    --
    l_from_rate NUMBER;
    l_from_type VARCHAR2(8);
    l_from_mau  NUMBER;
  --
  BEGIN
    -- Get currency information from the from_currency
    get_info(p_currency,
             p_date,
	     l_from_rate,
	     l_from_mau,
	     l_from_type);
    RETURN l_from_type;
  END is_ncu_currency;
  --
-- --------------------------------------------------------------------------
-- |------------------------< convert_amount >------------------------------|
-- --------------------------------------------------------------------------
  --
  -- Purpose
  --      Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type.
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  -- History
  --   02-Jun-1998  wkerr.uk       Created
  --   16-Nov-00    Kev Koh        Added round argument
  --   11-MAY-04    mkataria       Added exception block.Bug No 3464343.
  --   14-JUN-04    JTitmas        Added caching.
  --   06-DEC-05    pgongada       Raised the exceptions again Bug # 4530561.
  --
  -- Arguments
  --   p_from_currency        From currency
  --   p_to_currency          To currency
  --   p_conversion_date Conversion date
  --   p_amount               Amount to be converted from the from currency
  --                     into the to currency
  --   p_rate_type            Rate type
  --   p_round                Rounding to decimal places

  FUNCTION convert_amount (
          p_from_currency     VARCHAR2,
          p_to_currency       VARCHAR2,
          p_conversion_date   DATE,
          p_amount            NUMBER,
          p_rate_type         VARCHAR2 DEFAULT NULL,
          p_round             NUMBER DEFAULT NULL)
          RETURN NUMBER IS
    --
    euro_code            VARCHAR2(15);
    to_type              VARCHAR2(8);
    from_type            VARCHAR2(8);
    to_rate              NUMBER;
    from_rate            NUMBER;
    other_rate           NUMBER;
    from_mau             NUMBER;
    to_mau               NUMBER;
    converted_amount     NUMBER;
    rounding             NUMBER;
    hash_number          PLS_INTEGER;

  BEGIN

    hash_number := dbms_utility.get_hash_value
                     (p_from_currency
                     ,1
                     ,32768);

    BEGIN
    /* Can the cache be used? */
    /* Check cache parameters match */
      IF (g_rate_conversion_date = p_conversion_date AND
          g_rate_to_currency = p_to_currency AND
          g_rate_rate_type = p_rate_type) THEN
        to_rate := g_rate_to_rate;
        to_mau := g_rate_to_mau;
        to_type := g_rate_to_type;
    /* Check cache hit */
        IF (g_rate_currency_code_tab(hash_number) = p_from_currency) THEN
          IF (g_rate_conversion_tab(hash_number) > 0) THEN
            converted_amount := g_rate_conversion_tab(hash_number) * p_amount;
            rounding  := g_rate_rounding;
        /* Exception raised previously - return exception code -1 or -2 */
          ELSE
            RETURN g_rate_conversion_tab(hash_number);
          END IF;
    /* Otherwise refresh cache */
        ELSE
          RAISE NO_DATA_FOUND;
        END IF;
    /* If cache parameters do not match then reset cache parameters */
    /* and refresh cache */
      ELSE
        -- set parameters
        g_rate_conversion_tab := g_rate_empty_rate_tab;
        g_rate_currency_code_tab := g_rate_empty_currency_tab;
        g_rate_conversion_date := p_conversion_date;
        g_rate_to_currency := p_to_currency;
        g_rate_rate_type := p_rate_type;
        -- get currency information from the to_currency
        get_info ( p_to_currency, p_conversion_date, to_rate, to_mau, to_type );
        g_rate_to_rate := to_rate;
        g_rate_to_mau := to_mau;
        g_rate_to_type := to_type;
        -- refresh cache
        RAISE NO_DATA_FOUND;
      END IF;
    EXCEPTION WHEN OTHERS THEN
     --
     -- Store currency code in hash table
     --
     g_rate_currency_code_tab(hash_number) := p_from_currency;
     --
     -- Deal with null amounts
     IF (p_amount IS NULL) THEN
       RETURN (NULL);
     END IF;
     -- Check if both currencies are identical
     IF ( p_from_currency = p_to_currency ) THEN
       RETURN( p_amount );
     END IF;

     -- Get currency information from the from_currency
     get_info ( p_from_currency, p_conversion_date, from_rate, from_mau,
             from_type );

     -- Calculate the conversion rate according to both currency types
     IF ( from_type = 'EMU' ) THEN
     IF ( to_type = 'EMU' ) THEN
          converted_amount := ( p_amount / from_rate ) * to_rate;
          g_rate_conversion_tab(hash_number) := to_rate / from_rate;

        ELSIF ( to_type = 'EURO' ) THEN
          converted_amount := p_amount / from_rate;
          g_rate_conversion_tab(hash_number) := 1 / from_rate;

     ELSIF ( to_type = 'OTHER' ) THEN
          -- Find out conversion rate from EURO to p_to_currency
          euro_code := get_euro_code;
          other_rate := get_other_rate( euro_code, p_to_currency,
                                  p_conversion_date,
                               p_rate_type );

          -- Get conversion amt by converting EMU -> EURO -> OTHER
          converted_amount := ( p_amount / from_rate ) * other_rate;
          g_rate_conversion_tab(hash_number) := other_rate / from_rate;
     END IF;

     ELSIF ( from_type = 'EURO' ) THEN
     IF ( to_type = 'EMU' ) THEN
          converted_amount := p_amount * to_rate;
          g_rate_conversion_tab(hash_number) := to_rate;

     ELSIF ( to_type = 'EURO' ) THEN
             -- We should never comes to this case as it should be
                -- caught when we check if both to and from currency
                -- is the same at the beginning of this function
          converted_amount := p_amount;
          g_rate_conversion_tab(hash_number) := 1;

     ELSIF ( to_type = 'OTHER' ) THEN
          other_rate := get_other_rate( p_from_currency,
                                   p_to_currency,
                                   p_conversion_date,
                                   p_rate_type );
          converted_amount := p_amount * other_rate;
          g_rate_conversion_tab(hash_number) := other_rate;
     END IF;

     ELSIF ( from_type = 'OTHER' ) THEN
     IF ( to_type = 'EMU' ) THEN
          -- Find out conversion rate from p_from_currency to EURO
          euro_code := get_euro_code;
          other_rate := get_other_rate( p_from_currency, euro_code,
                                  p_conversion_date,
                                  p_rate_type );

          -- Get conversion amt by converting OTHER -> EURO -> EMU
          converted_amount := ( p_amount * other_rate ) * to_rate;
          g_rate_conversion_tab(hash_number) := other_rate * to_rate;

     ELSIF ( to_type = 'EURO' ) THEN
          other_rate := get_other_rate( p_from_currency, p_to_currency,
                               p_conversion_date,
                               p_rate_type );
          converted_amount := p_amount * other_rate;
          g_rate_conversion_tab(hash_number) := other_rate;

     ELSIF ( to_type = 'OTHER' ) THEN
          other_rate := get_other_rate( p_from_currency, p_to_currency,
                                    p_conversion_date,
                               p_rate_type );
          converted_amount := p_amount * other_rate;
          g_rate_conversion_tab(hash_number) := other_rate;
     END IF;
     END IF;

    -- Check if we are rounding to a certain no. of DP
    IF p_round IS NOT NULL THEN
      -- hr_utility.set_location('Not null', 10);
      rounding  := POWER(10, (-1 * p_round));
    ELSE
      -- hr_utility.set_location('Null', 20);
      -- Use std no. of decimal places
      rounding  := to_mau;
    END IF;

    g_rate_rounding := rounding;

  END;

    -- Rounding to the correct precision and minumum accountable units
    RETURN (ROUND(converted_amount / rounding) * rounding);

--  Added exception block. Bug No 3464343.
EXCEPTION
      -- Bug#4530561. Instead of returning the values raised the
      -- same exceptions.
      WHEN invalid_currency THEN
      g_rate_conversion_tab(hash_number) := -2;
      RAISE gl_currency_api.invalid_currency;

      WHEN gl_currency_api.NO_RATE THEN
      g_rate_conversion_tab(hash_number) := -1;
      RAISE gl_currency_api.NO_RATE;

END convert_amount;

-- --------------------------------------------------------------------------
-- |------------------------< convert_amount_sql >--------------------------|
-- --------------------------------------------------------------------------
  --
  -- Purpose
  --    Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type by
  --    calling convert_amount().
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   02-Jun-1998  wkerr.uk    Created
  --   16-NOV-00    Kev Koh     Added rounding argument
  --
  --
  -- Arguments
  --   p_from_currency        From currency
  --   p_to_currency          To currency
  --   p_conversion_date Conversion date
  --   p_amount               Amount to be converted from the from currency
  --                     into the to currency
  --   p_rate_type            Rate type
  --   p_round                Rounding decimal places
  --
  FUNCTION convert_amount_sql (
          p_from_currency     VARCHAR2,
          p_to_currency       VARCHAR2,
          p_conversion_date   DATE,
          p_amount            NUMBER,
          p_rate_type         VARCHAR2 DEFAULT NULL,
          p_round             NUMBER DEFAULT NULL) RETURN NUMBER IS

    converted_amount          NUMBER;
  BEGIN
    converted_amount := convert_amount( p_from_currency, p_to_currency,
                         p_conversion_date,
                         p_amount, p_rate_type, null);

    -- Bug 7111120
    IF converted_amount = -1 THEN
      converted_amount := -1.000001;
    ELSIF converted_amount = -2 THEN
      converted_amount := -2.000001;
    END if;

    return(converted_amount);

    EXCEPTION
     WHEN gl_currency_api.NO_RATE THEN
       converted_amount := -1;
       return( converted_amount );

     WHEN gl_currency_api.INVALID_CURRENCY THEN
       converted_amount := -2;
       return( converted_amount );

  END convert_amount_sql;

-- --------------------------------------------------------------------------
-- |-----------------------< is_ncu_currency_sql >--------------------------|
-- --------------------------------------------------------------------------
  -- Purpose
  --  Returns EMU if currency is a valid NCU code

  FUNCTION is_ncu_currency_sql(
    p_currency VARCHAR2,
    p_date     DATE)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN (is_ncu_currency(p_currency, p_date));
  EXCEPTION
    WHEN invalid_currency THEN
      RETURN (-2);
  END is_ncu_currency_sql;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< add_to_efc_currency_list >----------------------|
-- -----------------------------------------------------------------------------
--
procedure add_to_efc_currency_list
  (p_from_currency                 in     varchar2
  ,p_hash_number                   in     number
  ) is
  --
  cursor csr_fnd_cur is
    select fcu.derive_type
         , fcu.derive_effective
         , fcu.derive_factor
      from fnd_currencies fcu
     where fcu.currency_code = p_from_currency;
  --
  cursor csr_fnd_eur is
    select NVL(fcu.minimum_accountable_unit, POWER(10, (-1 * fcu.precision)))
      from fnd_currencies fcu
     where fcu.currency_code = 'EUR';
  --
  -- This function uses the g_derive_effective, g_derive_type
  -- and g_derive_factor variables as if they were local variables.
  -- These variables are defined globally to reduce PL/SQL
  -- calling overheads.
  --
begin
  open csr_fnd_cur;
  fetch csr_fnd_cur into g_derive_type
                       , g_derive_effective
                       , g_derive_factor;
  if csr_fnd_cur%notfound then
    close csr_fnd_cur;
    raise invalid_currency;
  else
    close csr_fnd_cur;
    -- Add details to currency list PL/SQL table
    g_efc_currency_code(p_hash_number) := p_from_currency;
    g_efc_derive_factor(p_hash_number) := g_derive_factor;
    -- Work out if the currency is an NCU as of sysdate
    if g_derive_type = 'EMU' and
       trunc(sysdate) >= trunc(g_derive_effective) then
      g_efc_is_ncu_sysdate(p_hash_number) := TRUE;
    else
      g_efc_is_ncu_sysdate(p_hash_number) := FALSE;
    end if;
    --
  end if;
  --
  -- If this procedure has been called for the first time during this database
  -- session the standard number of decimal places for the Euro currency will
  -- be unknown. Set the global variable with these details so the value is
  -- available for use by the efc_convert_number_amount function.
  --
  if g_efc_eur_mau is null then
    open csr_fnd_eur;
    fetch csr_fnd_eur into g_efc_eur_mau;
    if csr_fnd_eur%notfound then
      close csr_fnd_eur;
      raise invalid_currency;
    end if;
    close csr_fnd_eur;
  end if;
end add_to_efc_currency_list;
--
-- -----------------------------------------------------------------------------
-- |------------------------< efc_convert_number_amount >----------------------|
-- -----------------------------------------------------------------------------
--
function efc_convert_number_amount
  (p_from_currency                 in     varchar2
  ,p_amount                        in     number
  ,p_round                         in     number   default null
  ) return number is
  --
  -- This function uses the g_hash_number and g_rounding global
  -- variables as if they were local variables. These variables
  -- are defined globally to reduce PL/SQL calling overheads.
  --
begin
  if p_amount is null then
    return null;
  end if;
  --
  -- The cache searching logic in this function must be kept in sync
  -- with the corresponding logic in the efc_is_ncu_currency
  -- function. The code has been duplicated to avoid the overhead
  -- of a second PL/SQL function call.
  --
  -- Search for p_from_currency in the currency cache in this package
  --
  g_hash_number := dbms_utility.get_hash_value
                     (p_from_currency
                     ,1
                     ,32768
                     );
  --
  begin
    if g_efc_currency_code(g_hash_number) <> p_from_currency then
      -- Hash value has mapped onto another currency which was in the cache.
      -- Re-populate the cache with details required for this currency.
      add_to_efc_currency_list
        (p_from_currency => p_from_currency
        ,p_hash_number   => g_hash_number
        );
    end if;
  exception
    when no_data_found then
      -- Hash value did not map onto an entry in the currency list, so
      -- the currency cannot be in the cache. Populate the cache, so
      -- the values are available for the next call to this function
      -- or efc_is_ncu_currency.
      add_to_efc_currency_list
        (p_from_currency => p_from_currency
        ,p_hash_number   => g_hash_number
        );
  end;
  --
  -- If the p_from_currency is not an NCU as of sysdate then
  -- return the amount passed into this function.
  --
  if not g_efc_is_ncu_sysdate(g_hash_number) then
    return p_amount;
  end if;
  --
  -- Otherwise the p_from_currency is an NCU as of sysdate and the
  -- p_amount value should be converted to EUR using the derived
  -- factor from the FND_CURRENCIES table. Also round the converted
  -- amount to the number of decimal places passed into this function
  -- or the standard number of decimal places for the EUR currency
  -- and minumum accountable units.
  --
  if p_round is not null then
    g_rounding := POWER(10, (-1 * p_round));
    return (round((p_amount / g_efc_derive_factor(g_hash_number))
            / g_rounding) * g_rounding);
  else
    return (round((p_amount / g_efc_derive_factor(g_hash_number))
            / g_efc_eur_mau) * g_efc_eur_mau);
  end if;
  --
end efc_convert_number_amount;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< efc_get_derived_factor >--------------------------|
-- -----------------------------------------------------------------------------
--
function efc_get_derived_factor
(p_from_currency   in varchar2
) return number is
begin
--
  -- The cache searching logic in this function must be kept in sync
  -- with the corresponding logic in the efc_is_ncu_currency
  -- function. The code has been duplicated to avoid the overhead
  -- of a second PL/SQL function call.
  --
  -- Search for p_from_currency in the currency cache in this package
  --
  g_hash_number := dbms_utility.get_hash_value
                     (p_from_currency
                     ,1
                     ,32768
                     );
--
  begin
    if g_efc_currency_code(g_hash_number) <> p_from_currency then
      -- Hash value has mapped onto another currency which was in the cache.
      -- Re-populate the cache with details required for this currency.
      add_to_efc_currency_list
        (p_from_currency => p_from_currency
        ,p_hash_number   => g_hash_number
        );
    end if;
  exception
    when no_data_found then
      -- Hash value did not map onto an entry in the currency list, so
      -- the currency cannot be in the cache. Populate the cache, so
      -- the values are available for the next call to this function
      -- or efc_is_ncu_currency.
      add_to_efc_currency_list
        (p_from_currency => p_from_currency
        ,p_hash_number   => g_hash_number
        );
  end;
  --

  return(g_efc_derive_factor(g_hash_number));
  --
end efc_get_derived_factor;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< efc_convert_varchar2_amount >---------------------|
-- -----------------------------------------------------------------------------
--
function efc_convert_varchar2_amount
  (p_from_currency                 in     varchar2
  ,p_amount                        in     varchar2
  ,p_round                         in     number   default null
  ) return varchar2 is
--
begin
  -- Note: This function does not call changeformat or checkformat because
  --       it can be assumed the values selected from a table have already
  --       been validated and are known to be valid money numbers.
  --
  -- Convert amount to EUR currency
  --
  return to_char(efc_convert_number_amount
                    (p_from_currency => p_from_currency
                    ,p_amount        => to_number(p_amount)
                    ,p_round         => p_round
                    ));
  --
end efc_convert_varchar2_amount;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< efc_is_ncu_currency >-------------------------|
-- -----------------------------------------------------------------------------
--
function efc_is_ncu_currency
  (p_currency                      in     varchar2
  ) return boolean is
  --
  -- This function uses the g_hash_number variable as if it was
  -- a local variable. This variable is defined globally to
  -- reduce PL/SQL calling overheads.
  --
begin
  --
  -- The cache searching logic in this function must be kept in sync
  -- with the corresponding logic in the efc_convert_number_amount
  -- function. The code has been duplicated to avoid the overhead
  -- of a second PL/SQL function call.
  --
  -- Search for p_currency in the currency cache in this package
  --
  g_hash_number := dbms_utility.get_hash_value
                     (p_currency
                     ,1
                     ,32768
                     );
  --
  begin
    if g_efc_currency_code(g_hash_number) <> p_currency then
      -- Hash value has mapped onto another currency which was in the cache.
      -- Re-populate the cache with details required for this currency.
      add_to_efc_currency_list
        (p_from_currency => p_currency
        ,p_hash_number   => g_hash_number
        );
    end if;
  exception
    when no_data_found then
      -- Hash value did not map onto an entry in the currency list, so
      -- the currency cannot be in the cache. Populate the cache, so
      -- the values are available for the next call to this function
      -- or efc_convert_number_amount.
      add_to_efc_currency_list
        (p_from_currency => p_currency
        ,p_hash_number   => g_hash_number
        );
  end;
  --
  -- Return the Is NCU status flag from the cache
  --
  return g_efc_is_ncu_sysdate(g_hash_number);
  --
end efc_is_ncu_currency;
--
END hr_currency_pkg;

/
