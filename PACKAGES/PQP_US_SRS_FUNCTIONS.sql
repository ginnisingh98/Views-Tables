--------------------------------------------------------
--  DDL for Package PQP_US_SRS_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_US_SRS_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: pqussrfn.pkh 115.1 2002/07/08 19:06:18 tmehra noship $ */
----------------------------------------------------------------------------+
-- FUNCTION GET_SRS_LIMIT
----------------------------------------------------------------------------+
FUNCTION  get_srs_limit(p_payroll_action_id IN NUMBER
                       ,p_limit             IN VARCHAR2)
   RETURN NUMBER;
----------------------------------------------------------------------------+
-- FUNCTION get_date_paid
----------------------------------------------------------------------------+
FUNCTION get_date_paid (p_payroll_action_id IN  NUMBER)

         RETURN DATE;
----------------------------------------------------------------------------+
-- FUNCTION get_srs_plan_type
----------------------------------------------------------------------------+
FUNCTION get_srs_plan_type (p_element_type_id   IN  NUMBER)

RETURN VARCHAR2;

----------------------------------------------------------------------------+
-- FUNCTION check_srs_enrollment
----------------------------------------------------------------------------+
FUNCTION check_srs_enrollment (p_element_type_id   IN NUMBER
                              ,p_assignment_id     IN NUMBER
                              ,p_payroll_action_id IN NUMBER
                              ,p_enrollment_type   IN VARCHAR2
                              )
RETURN VARCHAR2;
----------------------------------------------------------------------------+

END pqp_us_srs_functions;

 

/
