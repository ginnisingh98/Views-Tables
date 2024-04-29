--------------------------------------------------------
--  DDL for Package PQP_US_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_US_FF_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: pqusfffn.pkh 115.15 2002/12/03 00:13:58 sshetty ship $ */
---------------------------------------------------------------------------+
-- GET_COL_VAL
---------------------------------------------------------------------------+
FUNCTION  get_col_val(p_assignment_id      IN NUMBER
                     ,p_payroll_action_id  IN NUMBER
                     ,p_column_name        IN VARCHAR2
                     ,p_income_code        IN VARCHAR2)
  RETURN varchar2;
----------------------------------------------------------------------------+
-- STATE_HONORS_TREATY
----------------------------------------------------------------------------+
FUNCTION state_honors_treaty (p_payroll_action_id  IN NUMBER
                             ,p_ele_iv_jur_code    IN VARCHAR2
                             ,p_override_loc_state IN VARCHAR2 )
  RETURN varchar2;
----------------------------------------------------------------------------+
-- ALIEN_TREATY_VALID
----------------------------------------------------------------------------+
FUNCTION alien_treaty_valid (p_assignment_id     IN NUMBER
                            ,p_payroll_action_id IN NUMBER
                            ,p_income_code       IN VARCHAR2 )
   RETURN varchar2;
----------------------------------------------------------------------------+
-- GET_ALIEN_BAL
----------------------------------------------------------------------------+
FUNCTION get_alien_bal(p_assignment_id     IN NUMBER
                      ,p_effective_date    IN DATE
                      ,p_payroll_action_id IN NUMBER   DEFAULT NULL
                      ,p_tax_unit_id       IN NUMBER   DEFAULT NULL
                      ,p_income_code       IN VARCHAR2 DEFAULT NULL
                      ,p_balance_name      IN VARCHAR2 DEFAULT NULL
                      ,p_dimension_name    IN VARCHAR2 DEFAULT NULL
                      ,p_state_code        IN VARCHAR2 DEFAULT NULL
                      ,p_fit_wh_bal_flag   IN VARCHAR2 DEFAULT 'N')

   RETURN NUMBER;
----------------------------------------------------------------------------+
-- FUNCTION IS_WINDSTAR
----------------------------------------------------------------------------+
FUNCTION is_windstar(p_person_id        IN NUMBER  DEFAULT NULL
                    ,p_assignment_id    IN NUMBER  DEFAULT NULL)
   --+
   --+ Function to return a true/false value if the assignment was/is being
   --+ processed by windstar
   --+
   RETURN VARCHAR2;

----------------------------------------------------------------------------+
-- FUNCTION PQP_IS_WINDSTAR
----------------------------------------------------------------------------+
FUNCTION pqp_is_windstar( p_assignment_id    IN NUMBER  DEFAULT NULL)
   --+
   --+ Function to return a true/false value if the assignment was/is being
   --+ processed by windstar. Function has been added as person_id
   --+ is not available as a CTX. This calls the function IS_WINDSTAR
   --+
   RETURN VARCHAR2;
   --+
----------------------------------------------------------------------------+
-- FUNCTION GET_NONW2_BAL
----------------------------------------------------------------------------+
FUNCTION get_nonw2_bal (p_balance_name		IN VARCHAR2,
                        p_period		IN VARCHAR2,
                        p_assignment_action_id	IN NUMBER,
                        p_jurisdiction_code	IN VARCHAR2 DEFAULT NULL,
                        p_tax_unit_id		IN NUMBER)
         RETURN NUMBER;

   --+ Function to return a 'Non W2' withheld balances for FIT and SIT
   --+
   --+

----------------------------------------------------------------------------+
-- FUNCTION GET_PREV_CONTRIB
----------------------------------------------------------------------------+
FUNCTION get_prev_contrib(p_assignment_id     IN NUMBER
                         ,p_payroll_action_id IN NUMBER
                         ,p_income_code       IN VARCHAR2 )
   --+
   --+ Function to return the previous contribution of the employee for the
   --+ income code
   --+
RETURN NUMBER;
--+
----------------------------------------------------------------------------+
-- FUNCTION PQP_PROCESS_EVENTS_EXISTS
----------------------------------------------------------------------------+
FUNCTION pqp_process_events_exist(p_assignment_id     IN NUMBER
                                 ,p_income_code       IN VARCHAR2 )
   --+
   --+ Function to check whether there are any changes to the alien data that
   --+ are not analyzed by Windstar
   --+
RETURN VARCHAR2;
----------------------------------------------------------------------------+
-- FUNCTION PQP_ALIEN_TAX_ELE_EXIST
----------------------------------------------------------------------------+
FUNCTION pqp_alien_tax_ele_exist (p_assignment_id     IN NUMBER
                                  ,p_effective_date   IN DATE)
   --+
   --+ Function to check whether the ALIEN_TAXATION element is attached if
   --+ there are earnings for classification Alien Earnings.
   --+
RETURN VARCHAR2;
----------------------------------------------------------------------------+
-- FUNCTION GET_TRR_NONW2_BAL
--
-- Function to return the GRE level balances, Since we do no store
-- GRE level balances, we compute this by adding balances of all the
-- assignments for a given GRE. Function written to compute 'Non W2'
-- FIT and SIT balances at the 'GRE' level.
----------------------------------------------------------------------------+
FUNCTION get_trr_nonw2_bal (p_gre         IN NUMBER,
                            p_jd          IN VARCHAR2 DEFAULT NULL,
                            p_start_date  IN DATE,
                            p_end_date    IN DATE,
                            p_bal_name    IN VARCHAR2,
                            p_dim         IN VARCHAR2)
RETURN NUMBER;
END pqp_us_ff_functions;

 

/
