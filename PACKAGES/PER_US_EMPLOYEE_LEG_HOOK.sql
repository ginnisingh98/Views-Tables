--------------------------------------------------------
--  DDL for Package PER_US_EMPLOYEE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_EMPLOYEE_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: perusgenempval.pkh 120.1 2006/01/16 15:04:19 ssattini noship $ */
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_NEW_HIRE                                      --
-- Type           : PROCEDURE                                           --
-- Description    : Checks for the New Hire default value               --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category  VARCHAR2                --
--                  p_per_information7          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------

PROCEDURE CHECK_NEW_HIRE( p_person_id per_all_people_f.person_id%type
                         ,p_per_information7 per_all_people_f.per_information7%type
                        );


END  PER_US_EMPLOYEE_LEG_HOOK;

 

/
