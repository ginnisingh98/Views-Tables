--------------------------------------------------------
--  DDL for Package HR_EFC_STUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EFC_STUBS" AUTHID CURRENT_USER AS
/* $Header: hrefcstb.pkh 115.2 2002/12/05 11:38:37 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< cust_valid_budget_unit >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Validates that budget_unit passed in has been defined as a customer
--  specific budget unit of measure, indicating money.
--
-- ----------------------------------------------------------------------------
FUNCTION cust_valid_budget_unit(p_uom               IN VARCHAR2
                               ,p_business_group_id IN NUMBER) RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |--------------------< cust_validate_hr_summary >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Validates that the column in the hr_summary table should be converted.
-- This function must be modified to include all customer defined lookup
-- values for num_value1 (p_colname = 'NUM_VALUE1') and num_value2
-- (p_colname = 'NUM_VALUE2').
--
-- This function should return 'Y' if the monetary type matches, otherwise
-- it should return 'N'.
--
-- ----------------------------------------------------------------------------
FUNCTION cust_validate_hr_summary(p_colname            VARCHAR2
                                 ,p_item               VARCHAR2
                                 ,p_business_group_id  NUMBER) RETURN VARCHAR2;
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
                              ,p_new_territory_code OUT NOCOPY varchar2);
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
FUNCTION cust_find_row_size(p_table IN varchar2) RETURN number;
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
FUNCTION cust_process_cross_bg_data RETURN varchar2;
--
END hr_efc_stubs;

 

/
