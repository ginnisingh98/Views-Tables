--------------------------------------------------------
--  DDL for Package Body HR_EFC_STUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EFC_STUBS" AS
/* $Header: hrefcstb.pkb 115.3 2002/12/05 11:42:12 apholt noship $ */
--
-- Package variables.
-- lc_process VARCHAR2(1) ; -- to process return flag
--
-- ----------------------------------------------------------------------------
-- |---------------------< cust_valid_budget_unit >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION cust_valid_budget_unit(p_uom               IN VARCHAR2
                               ,p_business_group_id IN NUMBER)
  RETURN VARCHAR2 IS
--
-- Used to check the UOM against customer defined units of measure
--
lc_process varchar2(1) := 'N';  -- Set to 'Y' if unit is valid
--
BEGIN
  --
  -- example shown, remove if not required
  -- IF p_uom = 'MONEY' THEN
  --    lc_process := 'Y';
  -- END IF;
  --
  RETURN lc_process ;
  --
END cust_valid_budget_unit;
--
-- ----------------------------------------------------------------------------
-- |--------------------< cust_validate_hr_summary >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Validates that the column in the hr_summary table should be converted.
-- This function must be modified to include all customer defined lookup
-- values for num_value1 (p_colname = 'NUM_VALUE1') and
-- num_value2 (p_colnname = 'NUM_VALUE2').
--
-- This function should return 'Y' if the monetary type matches, otherwise
-- it should return 'N'.
--
-- ----------------------------------------------------------------------------
FUNCTION cust_validate_hr_summary(p_colname           VARCHAR2
                                 ,p_item              VARCHAR2
                                 ,p_business_group_id NUMBER) RETURN VARCHAR2 IS
--
  lc_process  VARCHAR2(1);
--
BEGIN
  --
  IF (p_colname = 'NUM_VALUE1') THEN
     --
     -- Check whether or not num_value1 should be converted, by matching
     -- the lookup type p_item with the user defined lookup types.
     -- Else return 'N'.
     -- e.g.
     -- IF (p_colname = 'NUM_VALUE1') THEN
     --    -- Oracle defined lookup
     --    IF p_item = 'ANNUAL_REMUNERATION' THEN
     --       lc_process := 'Y'
     --    END IF;
     -- END IF;
     --
     lc_process := 'N';
  ELSIF (p_colname = 'NUM_VALUE2') THEN
     --
     -- Check whether or not num_value12should be converted, by matching
     -- the lookup type p_item with the user defined lookup types.
     -- Else return 'N'.
     lc_process := 'N';
  END IF;
  --
  -- return value.
  RETURN lc_process;
END cust_validate_hr_summary;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_customer_mapping >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- For specific customer payment_types, defined in pay_payment_types, and not
-- seeded by Oracle HRMS, have to define the mapping between the original
-- payment_type and the payment_type to be used after EFC conversion.
--
-- Post Success:
-- Should return the payment_type_name, and territory_code for the new
-- payment_type.  A new payment type should ALWAYS be returned.
--
-- ----------------------------------------------------------------------------
procedure chk_customer_mapping(p_payment_type   IN varchar2
                              ,p_territory_code IN varchar2
                              ,p_new_payment_type   OUT NOCOPY varchar2
                              ,p_new_territory_code OUT NOCOPY varchar2) IS
--
BEGIN
  --
  -- The following is listed as an example only, and should be edited
  -- by the customer to reflect a customer's particular payment types.
  IF ((p_payment_type='BE Cash') AND
      (p_territory_code = 'BE')) THEN
      p_new_payment_type := 'Cash';
      p_new_territory_code := '';
  END IF;
  --
END chk_customer_mapping;
--
-- ----------------------------------------------------------------------------
-- |----------------------< cust_find_row_size >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Customer specific version of a function which will estimate the
--  size of a row.  This will override the function supplied by Oracle to
--  estimate the size of a row.
--  If you wish to use the estimation function supplied by Oracle, this
--  function must return 0.
--
-- ----------------------------------------------------------------------------
FUNCTION cust_find_row_size(p_table IN varchar2) RETURN number IS
--
BEGIN
  RETURN 0;
END cust_find_row_size;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< cust_process_cross_bg_data >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Customer specific version of a function which will determine if data
--  spanning business groups will be converted.  This will override the function
--  supplied by Oracle for this purpose, which by default will convert the data.
--  If you wish NOT to convert on the next run, this function must return 'N'.
--
-- ----------------------------------------------------------------------------
FUNCTION cust_process_cross_bg_data RETURN varchar2 IS
--
BEGIN
--
--
-- Default to always convert global data
--
  RETURN 'Y';
--
-- Uncomment the line below to disable global data conversion
--
--  RETURN 'N';
--
END cust_process_cross_bg_data;
--
END hr_efc_stubs;

/
