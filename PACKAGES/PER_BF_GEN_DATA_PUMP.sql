--------------------------------------------------------
--  DDL for Package PER_BF_GEN_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_GEN_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pebgendp.pkh 115.4 2002/09/06 16:07:29 apholt noship $ */

-- -------------------------------------------------------------------------
-- --------------------< get_input_value_id >-------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the input_value_id for the backfeed APIs
--   It will be used by the datapump API for PER_BF_BALANCE_TYPES
--   The reporting name is can be considered unique due to a constraint in the
--   database. This maps onto the input value that is used.
--
FUNCTION get_input_value_id
  (p_reporting_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER
  ,p_effective_date     IN DATE)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_input_value_id, WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_balance_type_id >------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the balance_type_id for the backfeed APIs
--
FUNCTION get_balance_type_id
  (p_balance_type_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER
  ,p_effective_date     IN DATE)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_balance_type_id, WNDS);
--
-- -------------------------------------------------------------------------
-- --------------------< get_payroll_id >-----------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--    get_payroll_id
--  DESCRIPTION
--    Returns a Payroll ID.
FUNCTION get_payroll_id
(
   p_payroll_name      IN VARCHAR2,
   p_business_group_id IN NUMBER,
   p_effective_date    IN DATE
)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_payroll_id, WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_payroll_run_id >-------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the payroll_run_id for the backfeed APIs
--
FUNCTION get_payroll_run_id
  (p_payroll_run_user_key     IN VARCHAR2)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_payroll_run_id, WNDS);
--
-- -------------------------------------------------------------------------
-- --------------------< get_assignment_id >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the assignment_id for the backfeed APIs
--   For the Generic implementation, we are assuming that the user is
--   only working with the primary assignment so the Employee
--   number (which is unique in a business group)is all that is required
--   to obtain the ID.
--
FUNCTION get_assignment_id
  (p_employee_number          IN VARCHAR2
  ,p_business_group_id        IN NUMBER
  ,p_effective_date           IN DATE)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_assignment_id, WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_personal_payment_method_id >---------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the personal_payment_method_id for the backfeed APIs
--   For the generic implementation, we are only working with the primary
--   assignment so the Employee number (which is unique in a business group)
--   is enough to obtain the assignment_id. The rule is that the highest
--   priority personal payment method for the primary assignment for the
--   organization payment method (which is passed in) will be selected.
--   This means that whilst it is possible to have multiple payment methods
--   per primary assignment, the highest priority one will be selected to
--   resolve the ID.
FUNCTION get_personal_payment_method_id
  (p_employee_number          IN VARCHAR2
  ,p_business_group_id        IN NUMBER
  ,p_effective_date           IN DATE
  ,p_org_payment_method_name  IN VARCHAR2)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_personal_payment_method_id, WNDS);
END PER_BF_GEN_DATA_PUMP;

 

/
