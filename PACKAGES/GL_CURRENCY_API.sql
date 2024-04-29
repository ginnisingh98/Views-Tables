--------------------------------------------------------
--  DDL for Package GL_CURRENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CURRENCY_API" AUTHID CURRENT_USER AS
/* $Header: glustcrs.pls 120.5 2005/05/05 01:44:22 kvora ship $ */
--
-- Package
--   gl_currency_api
--
-- Purpose
--
--   This package will provide PL/SQL APIs for the following purposes:
--   o Determine if there is a fixed conversion rate between any two currencies
--   o Determine relationship between any two currencies
--   o Determine the currency code for the EURO currency
--   o Determine daily rate based on any two currencies, conversion type,
--     and conversion date information
--   o Determine the closest daily rate based on any two currencies,
--     conversion type, conversion date, and maximum number of days to roll
--     back
--   o Convert an amount to a different currency based on any two currencies,
--     conversion type, and conversion date information
--
-- History
--   15-JUL-97 	W Wong		Created
--

  --
  -- Exceptions
  --
  -- User defined exceptions for gl_currency_api:
  -- o INVALID_CURRENCY - One of the two currencies is invalid.
  -- o NO_RATE          - No rate exists between the two currencies for the
  --                      given date and conversion type.
  -- o NO_DERIVE_TYPE   - No derive type found for the specified currency
  --                      during the specified period.
  --
  INVALID_CURRENCY 	EXCEPTION;
  NO_RATE		EXCEPTION;
  NO_DERIVE_TYPE        EXCEPTION;

  --
  -- Function
  --   is_fixed_rate
  --
  -- Purpose
  -- 	Returns 'Y' if there is a fixed rate between the two currencies;
  --            'N' otherwise.
  --
  -- History
  --   15-JUL-97  W Wong 	Created
  --
  -- Arguments
  --   x_from_currency		From currency
  --   x_to_currency		To currency
  --   x_effective_date		Effective date
  --
  FUNCTION is_fixed_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_effective_date	DATE      ) RETURN VARCHAR2;
  PRAGMA   RESTRICT_REFERENCES(is_fixed_rate,WNDS,WNPS,RNPS);

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
		x_relationship		IN OUT NOCOPY	VARCHAR2 );

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
  FUNCTION get_euro_code RETURN VARCHAR2;
  PRAGMA   RESTRICT_REFERENCES(get_euro_code,WNDS,WNPS,RNPS);

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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate,WNDS,WNPS,RNPS);

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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate,WNDS,WNPS,RNPS);


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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate_sql,WNDS,WNPS,RNPS);

  --
  -- Function
  --   get_rate_sql
  --
  -- Purpose
  -- 	Returns the rate between the from currency and the functional
  --    currency of the ledger by calling get_rate().
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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate_sql,WNDS,WNPS,RNPS);

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
	        x_max_roll_days         NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_closest_rate,WNDS,WNPS,RNPS);

  --
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
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --   x_max_roll_days		Number of days to rollback for a rate
  --
  FUNCTION get_closest_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_closest_rate,WNDS,WNPS,RNPS);


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
	        x_max_roll_days         NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_closest_rate_sql,WNDS,WNPS,RNPS);


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
  -- 		     get_closest_rate().
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
	        x_max_roll_days         NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_closest_rate_sql,WNDS,WNPS,RNPS);

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
		x_amount		NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(convert_amount,WNDS,WNPS,RNPS);

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
		x_amount		NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(convert_amount,WNDS,WNPS,RNPS);


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
  --    Return -1 if the NO_RATE exception is raised in convert_amount().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --                 convert_amount().
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
		x_amount		NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(convert_amount_sql,WNDS,WNPS,RNPS);

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
  --    Return -1 if the NO_RATE exception is raised in convert_amount().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --                 convert_amount().
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
		x_amount		NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(convert_amount_sql,WNDS,WNPS,RNPS);


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
  --		(:Parameter.ledger_id, :OPTIONS.period_name,
  --		 :Parameter.func_curr_code);
  -- Notes
  --
  FUNCTION get_derive_type (ledger_id NUMBER, period VARCHAR2, curr_code VARCHAR2)
	RETURN VARCHAR2;
  PRAGMA   RESTRICT_REFERENCES(get_derive_type,WNDS,WNPS,RNPS);


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
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  PRAGMA   RESTRICT_REFERENCES(rate_exists,WNDS,WNPS,RNPS);

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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate_numerator_sql,WNDS,WNPS,RNPS);

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
  --   x_set_of_books_id	Ledger id
  --   x_from_currency		From currency
  --   x_conversion_date	Conversion date
  --   x_conversion_type	Conversion type
  --
  FUNCTION get_rate_numerator_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate_numerator_sql,WNDS,WNPS,RNPS);

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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate_denominator_sql,WNDS,WNPS,RNPS);

  --
  -- Function
  --   get_rate_denominator_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use to calculate the conversion rate
  --    between the from currency and the functional currency of the
  --    Ledgers.
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
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_rate_denominator_sql,WNDS,WNPS,RNPS);

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
  Procedure get_triangulation_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_denominator		IN OUT NOCOPY	NUMBER,
	        x_numerator		IN OUT NOCOPY 	NUMBER,
		x_rate                  IN OUT NOCOPY  NUMBER );

  --
  -- Procedure
  --   get_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator and denominator we should use to calculate
  --    the conversion rate, and the actual conversion rate between the
  --    from currency and the functional currency of the Ledgers.
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
  Procedure get_triangulation_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_denominator		IN OUT NOCOPY	NUMBER,
                x_numerator		IN OUT NOCOPY 	NUMBER,
		x_rate                  IN OUT NOCOPY  NUMBER );

  --
  -- Function
  --   get_closest_rate_numerator_sql
  --
  -- Purpose
  -- 	Returns the numerator we should use between the two currencies for
  --    a given conversion date and conversion type.
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
	        x_max_roll_days         NUMBER) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_closest_rate_numerator_sql,WNDS,WNPS,RNPS);

  --
  -- Function
  --   get_closest_rate_numerator_sql
  --
  -- Purpose
  -- 	Returns the numerator we should use to get the conversion rate
  --    between the from currency and the functional currency of the
  --    Ledgers.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
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
	        x_max_roll_days         NUMBER) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(get_closest_rate_numerator_sql,WNDS,WNPS,RNPS);

  --
  -- Function
  --   get_closest_rate_denom_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use between the two currencies for
  --    a given conversion date and conversion type.
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
	        x_max_roll_days         NUMBER) RETURN NUMBER;
  PRAGMA  RESTRICT_REFERENCES(get_closest_rate_denom_sql,WNDS,WNPS,RNPS);

  --
  -- Function
  --   get_closest_rate_denom_sql
  --
  -- Purpose
  -- 	Returns the denominator we should use to get the conversion rate
  --    between the from currency and the functional currency of the
  --    Ledgers.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
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
  FUNCTION get_closest_rate_denom_sql (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
	        x_max_roll_days         NUMBER) RETURN NUMBER;
  PRAGMA  RESTRICT_REFERENCES(get_closest_rate_denom_sql,WNDS,WNPS,RNPS);

  --
  -- Procedure
  --   get_closest_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator, denominator and the conversion rate between
  --    the two currencies for a given conversion date and conversion type.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
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
		x_rate                  IN OUT NOCOPY  NUMBER );

  --
  -- Procedure
  --   get_closest_triangulation_rate
  --
  -- Purpose
  -- 	Returns the numerator, denominator and the conversion rate
  --    between the from currency and the functional currency of the
  --    Ledgers.
  --
  --    If such a rate is not defined for the specified conversion_date, it
  --    searches backward for a rate defined for the same currencies and
  --    conversion type.  It searches backward up to x_max_roll_days prior
  --    to the specified x_conversion_date.
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
		x_rate                  IN OUT NOCOPY  NUMBER );

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
		x_rate			IN OUT NOCOPY NUMBER );

  --
  -- Procedure
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the numerator and denominator we should use to calculate
  --    the conversion rate, and the actual conversion rate between the
  --    from currency and the functional currency of the Ledgers,
  -- 	and the amount converted from the from currency into the
  --    functional currency of that Ledgers.
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
		x_rate			IN OUT NOCOPY NUMBER );

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
	        x_max_roll_days         NUMBER ) RETURN NUMBER;
  PRAGMA   RESTRICT_REFERENCES(convert_closest_amount_sql,WNDS,WNPS,RNPS);

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
		x_user_rate             NUMBER,
		x_amount		NUMBER,
		x_max_roll_days         NUMBER,
		x_converted_amount      IN OUT NOCOPY NUMBER,
		x_denominator           IN OUT NOCOPY NUMBER,
		x_numerator  		IN OUT NOCOPY NUMBER,
		x_rate			IN OUT NOCOPY NUMBER );



END gl_currency_api;

 

/
