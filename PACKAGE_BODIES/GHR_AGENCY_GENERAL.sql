--------------------------------------------------------
--  DDL for Package Body GHR_AGENCY_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_AGENCY_GENERAL" AS
  /* $Header: ghagngen.pkb 120.0 2005/12/08 15:41:02 vravikan noship $ */

  --
  -- Package Variables
  --
  g_package  varchar2(100) := 'ghr_agency_general.';
  --
  --
     -- This function would return the check date for the effectiev date passed
     function get_agency_check_date( p_person_id         in Number
                                    ,p_asg_id            in Number
                                    ,p_effective_date    in Date
                                    ,p_payroll_id        in Number)
            RETURN DATE is
    Begin
       Return null;
    End get_agency_check_date;

     -- this function would return the last check date of the year of the effective date passed
     function get_agency_last_check_date( p_person_id         in Number
                                         ,p_asg_id            in Number
                                         ,p_effective_date    in Date
                                         ,p_payroll_id        in Number)
            RETURN DATE is
    Begin
       Return null;
    End get_agency_last_check_date;

End ghr_agency_general;

/
