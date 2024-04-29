--------------------------------------------------------
--  DDL for Package GHR_AGENCY_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_AGENCY_GENERAL" AUTHID CURRENT_USER as
/* $Header: ghagngen.pkh 120.0 2005/12/08 15:42 vravikan noship $*/

   function get_agency_check_date( p_person_id         in Number
                                  ,p_asg_id            in Number
                                  ,p_effective_date    in Date
                                  ,p_payroll_id        in Number)
            RETURN DATE;

  function get_agency_last_check_date( p_person_id         in Number
                                      ,p_asg_id            in Number
                                      ,p_effective_date    in Date
                                      ,p_payroll_id        in Number)
            RETURN DATE;

End ghr_agency_general;

 

/
