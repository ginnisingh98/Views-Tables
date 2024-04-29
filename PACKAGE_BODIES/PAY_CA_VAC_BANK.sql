--------------------------------------------------------
--  DDL for Package Body PAY_CA_VAC_BANK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_VAC_BANK" AS
/* $Header: pycavbvb.pkb 120.0 2005/05/29 03:53:36 appldev noship $ */

-------------------------- calc_years_of_service ---------------------------
/*
 * NAME
 *   calc_years_of_service
 * DESCRIPTION
 *   This is a function that calculates the effective years of service,
 *   rounded down to a whole year, based on the entered DATE_TYPE.
 *   'Hire Date' - The years of service is calculated using the hire date on
 *                 PER_PERIODS_OF_SERVICE as the starting_point
 */
FUNCTION calc_years_of_service(p_assignment_id  NUMBER,
                               p_date_earned    DATE,
                               p_date_type      VARCHAR2)
  RETURN NUMBER IS

CURSOR c_years_of_service IS
  SELECT TRUNC(MONTHS_BETWEEN(p_date_earned, pds.date_start)/12)
  FROM   per_all_assignments_f   asg,
         per_periods_of_service  pds
  WHERE  asg.assignment_id = p_assignment_id
  AND    p_date_earned BETWEEN asg.effective_start_date
                           AND asg.effective_end_date
  AND    pds.person_id     = asg.person_id;

l_years_of_service  NUMBER := 0;

BEGIN

  hr_utility.set_location('Starting calc_years_of_service', 10);
  IF p_date_type = 'HD' THEN
    hr_utility.set_location('calc_years_of_service', 20);
    OPEN c_years_of_service;
    FETCH c_years_of_service INTO l_years_of_service;
    CLOSE c_years_of_service;
  END IF;
  hr_utility.set_location('Ending calc_years_of_service', 40);

  RETURN l_years_of_service;

END;

END pay_ca_vac_bank;

/
