--------------------------------------------------------
--  DDL for Package Body PER_US_EMPLOYEE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EMPLOYEE_LEG_HOOK" AS
/* $Header: perusgenempval.pkb 120.1 2006/01/16 15:06 ssattini noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_NEW_HIRE                                      --
-- Type           : PROCEDURE                                           --
-- Description    : Checks for the New Hire Default value               --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_per_information_category  VARCHAR2                --
--                : p_per_information7          VARCHAR2                --
--            OUT :                                                     --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Jan-06  SSattini    Created this procedure                  --
--------------------------------------------------------------------------

PROCEDURE CHECK_NEW_HIRE( p_person_id per_all_people_f.person_id%type
                         ,p_per_information7 per_all_people_f.per_information7%type
                        ) IS

l_per_information7 varchar2(240);

BEGIN
      /* hr_utility.trace_on(null,'TESTNEWHIRE'); */
      hr_utility.trace('p_person_id value: '||to_char(p_person_id));
      hr_utility.trace('New Hire Status before default value: '||p_per_information7 );

   IF ((p_per_information7 = hr_api.g_varchar2) OR (p_per_information7 is null)) THEN

      hr_utility.trace('p_per_information7 = hr_api.g_varchar2 Satisfied ');
      hr_utility.trace('New Hire Status before default value: '||p_per_information7 );

      update per_all_people_f
      set per_information7 = 'INCL'
      where person_id = p_person_id;

      hr_utility.trace('New Hire Status is Set to default value: INCL ');
   END IF;

   /* hr_utility.trace_off; */
   return;

END  CHECK_NEW_HIRE;

END  PER_US_EMPLOYEE_LEG_HOOK;

/
