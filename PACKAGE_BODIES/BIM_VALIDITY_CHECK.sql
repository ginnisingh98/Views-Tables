--------------------------------------------------------
--  DDL for Package Body BIM_VALIDITY_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_VALIDITY_CHECK" AS
/* $Header: bimvalcb.pls 120.1 2005/06/14 15:44:53 appldev  $*/

G_PKG_NAME  CONSTANT  VARCHAR2(20) :='BIM_VALIDITY_CHECK';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimvalcb.pls';

---------------------------------------------------------------------
-- FUNCTION
--    validate_periods
-- NOTE
-- PARAMETER
--   p_date      IN  DATE
-- RETURN   VARCHAR2
---------------------------------------------------------------------
FUNCTION  validate_periods(
   p_input_date       DATE) return VARCHAR2
IS

BEGIN

   return('SUCCESS');

END validate_periods;

---------------------------------------------------------------------
-- FUNCTION
--    call_currency
-- NOTE
-- PARAMETER
--   p_from_currency      IN  VARCHAR2
-- RETURN   VARCHAR2
---------------------------------------------------------------------
FUNCTION  call_currency(
   p_from_currency IN    VARCHAR2) return VARCHAR2
IS
   l_to_amount                  NUMBER;
   l_from_amount                NUMBER;
   l_to_currency                VARCHAR2(100) ;
   x_return_status              varchar2(1);


BEGIN

   return('SUCCESS');

END call_currency;

---------------------------------------------------------------------
-- FUNCTION
--    validate_currency
-- NOTE
-- PARAMETER
-- RETURN   VARCHAR2
---------------------------------------------------------------------
FUNCTION  validate_currency(
   p_start_date    IN    DATE
   ,p_end_date     IN    DATE) return VARCHAR2
IS

BEGIN

   return('SUCCESS');

END validate_currency;


---------------------------------------------------------------------
-- FUNCTION
--    validate_campaigns
-- NOTE
-- PARAMETERS
-- p_input_date      IN DATE  -- starting date of the validity
-- x_period_errror   OUT NOCOPY VARCHAR2 -- error message for period validation
-- x_currency_errror OUT NOCOPY VARCHAR2 -- error message for cuurency validation
-- RETURN   NUMBER
--          0 if both validations succeed,
--          1 if both validations failed,
--          2 only if period validaion failed,
--          3 only if currency validation failed
---------------------------------------------------------------------
FUNCTION  validate_campaigns(
   p_start_date       IN    DATE
   ,p_end_date       IN    DATE
   ,x_period_error    OUT NOCOPY   VARCHAR2
   ,x_currency_error  OUT  NOCOPY  VARCHAR2
   ) return NUMBER
IS

BEGIN

    return (0);


END validate_campaigns;

---------------------------------------------------------------------
-- FUNCTION
--    validate_events
-- NOTE
-- PARAMETERS
-- p_start_date      IN DATE  -- starting date of the validity
-- x_period_errror   OUT NOCOPY VARCHAR2 -- error message for period validation
-- x_currency_errror OUT NOCOPY VARCHAR2 -- error message for cuurency validation
-- RETURN   NUMBER
--          0 if both validations succeed,
--          1 if both validations failed,
--          2 only if period validaion failed,
--          3 only if currency validation failed
---------------------------------------------------------------------
FUNCTION  validate_events(
   p_start_date       IN    DATE
   ,p_end_date       IN    DATE
   ,x_period_error    OUT  NOCOPY  VARCHAR2
   ,x_currency_error  OUT   NOCOPY VARCHAR2
   ) return NUMBER
IS

BEGIN

    return (0);

END validate_events;

---------------------------------------------------------------------
-- FUNCTION
--    validate_budgets
-- NOTE
-- PARAMETERS
-- p_start_date      IN DATE  -- starting date of the validity
-- x_period_errror   OUT NOCOPY VARCHAR2 -- error message for period validation
-- x_currency_errror OUT NOCOPY VARCHAR2 -- error message for cuurency validation
-- RETURN   NUMBER
--          0 if both validations succeed,
--          1 if both validations failed,
--          2 only if period validaion failed,
--          3 only if currency validation failed
---------------------------------------------------------------------
FUNCTION  validate_budgets(
   p_start_date       IN    DATE
   ,p_end_date       IN    DATE
   ,x_period_error    OUT  NOCOPY  VARCHAR2
   ,x_currency_error  OUT  NOCOPY  VARCHAR2
   ) return NUMBER
IS

BEGIN

    return (0);

END validate_budgets;

END BIM_VALIDITY_CHECK;

/
