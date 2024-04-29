--------------------------------------------------------
--  DDL for Package Body HRI_BPL_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_CURRENCY" AS
/* $Header: hribcrnc.pkb 120.3 2006/10/09 15:18:21 jtitmas noship $ */

TYPE g_varchar_tabtype IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
g_rate_type_tab      g_varchar_tabtype;
g_default_rate_type  VARCHAR2(30) := fnd_profile.value('BIS_PRIMARY_RATE_TYPE');

/******************************************************************************/
/* Function to convert an amount from one currency to another, given a        */
/* specified conversion rate type                                             */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_rate_type        IN VARCHAR2)
            RETURN NUMBER IS

  l_converted_amount    NUMBER;

BEGIN

-- Check all required parameters are passed in
  IF (p_from_currency IS NOT NULL AND
      p_to_currency IS NOT NULL AND
      p_amount IS NOT NULL)
  THEN
  -- If from currency is unassigned don't convert amount
    IF (p_from_currency = 'NA_EDW')
    THEN
      l_converted_amount := p_amount ;
    ELSE
    -- Call API to convert currency
      l_converted_amount := hr_currency_pkg.convert_amount(
           p_from_currency        => p_from_currency
          ,p_to_currency          => p_to_currency
          ,p_conversion_date      => p_conversion_date
          ,p_amount               => p_amount
          ,p_rate_type            => NVL(p_rate_type, g_default_rate_type));
    END IF;
  ELSE
  -- No salary for this assignment
    l_converted_amount := 0;
  END IF;

-- Return result
  RETURN l_converted_amount;
/*
EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);
*/
EXCEPTION
    WHEN gl_currency_api.invalid_currency THEN
      --g_rate_conversion_tab(hash_number) := -2;
      RETURN ( -2 );

    WHEN gl_currency_api.NO_RATE THEN
      --g_rate_conversion_tab(hash_number) := -1;
      RETURN ( -1 );

    WHEN OTHERS THEN
      RETURN ( 0 );


END convert_currency_amount;

/******************************************************************************/
/* Function to convert an amount from one currency to another without a rate  */
/* type given (uses the default from the bis profile option) but specifying   */
/* a number of decimal places for the result                                  */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency      IN VARCHAR2,
                                 p_to_currency        IN VARCHAR2,
                                 p_conversion_date    IN DATE,
                                 p_amount             IN NUMBER,
                                 p_precision          IN NUMBER)
            RETURN NUMBER IS

  l_result     NUMBER;
  l_rate_type  VARCHAR2(30);

BEGIN

  l_result := hr_currency_pkg.convert_amount
                (p_from_currency => p_from_currency,
                 p_to_currency => p_to_currency,
                 p_conversion_date => TRUNC(p_conversion_date),
                 p_amount => p_amount,
                 p_rate_type => g_default_rate_type,
                 p_round => p_precision);

  RETURN l_result;
EXCEPTION
    WHEN gl_currency_api.invalid_currency THEN
      --g_rate_conversion_tab(hash_number) := -2;
      RETURN ( -2 );

    WHEN gl_currency_api.NO_RATE THEN
      --g_rate_conversion_tab(hash_number) := -1;
      RETURN ( -1 );

    WHEN OTHERS THEN
      RETURN ( 0 );
END convert_currency_amount;

/******************************************************************************/
/* Function to convert an amount from one currency to another without a rate  */
/* type given (uses the default from the bis profile option)                  */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency      IN VARCHAR2,
                                 p_to_currency        IN VARCHAR2,
                                 p_conversion_date    IN DATE,
                                 p_amount             IN NUMBER)
            RETURN NUMBER IS

  l_result     NUMBER;
  l_rate_type  VARCHAR2(30);

BEGIN

  l_result := hr_currency_pkg.convert_amount
                (p_from_currency => p_from_currency,
                 p_to_currency => p_to_currency,
                 p_conversion_date => TRUNC(p_conversion_date),
                 p_amount => p_amount,
                 p_rate_type => g_default_rate_type);

  RETURN l_result;
EXCEPTION
    WHEN gl_currency_api.invalid_currency THEN
      --g_rate_conversion_tab(hash_number) := -2;
      RETURN ( -2 );

    WHEN gl_currency_api.NO_RATE THEN
      --g_rate_conversion_tab(hash_number) := -1;
      RETURN ( -1 );

    WHEN OTHERS THEN
      RETURN ( 0 );
END convert_currency_amount;


-- -----------------------------------------------------------------------------
-- Converts currency amount to DBI primary currency using other parameters
--    - conversion date:  sysdate
--    - rate type:        DBI primary rate type
-- -----------------------------------------------------------------------------
FUNCTION convert_to_primary_crnc(p_from_currency     IN VARCHAR2
                                ,p_amount            IN NUMBER)
            RETURN NUMBER IS

  l_result    NUMBER;

BEGIN

  l_result := convert_currency_amount
               (p_from_currency   => p_from_currency
               ,p_to_currency     => bis_common_parameters.get_currency_code
               ,p_conversion_date => TRUNC(SYSDATE)
               ,p_amount          => p_amount
               ,p_rate_type       => bis_common_parameters.get_rate_type);

  RETURN l_result;

END convert_to_primary_crnc;

-- -----------------------------------------------------------------------------
-- Converts currency amount to DBI secondary currency using other parameters
--    - conversion date:  sysdate
--    - rate type:        DBI secondary rate type
-- -----------------------------------------------------------------------------
FUNCTION convert_to_secondary_crnc(p_from_currency     IN VARCHAR2
                                  ,p_amount            IN NUMBER)
            RETURN NUMBER IS

  l_result    NUMBER;

BEGIN

  l_result := convert_currency_amount
               (p_from_currency   => p_from_currency
               ,p_to_currency     => bis_common_parameters.get_secondary_currency_code
               ,p_conversion_date => TRUNC(SYSDATE)
               ,p_amount          => p_amount
               ,p_rate_type       => bis_common_parameters.get_secondary_rate_type);

  RETURN l_result;

END convert_to_secondary_crnc;

END hri_bpl_currency;

/
