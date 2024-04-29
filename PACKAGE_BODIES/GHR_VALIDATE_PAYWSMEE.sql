--------------------------------------------------------
--  DDL for Package Body GHR_VALIDATE_PAYWSMEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_VALIDATE_PAYWSMEE" AS
/* $Header: ghrwsmee.pkb 120.0.12010000.2 2009/05/26 10:54:16 vmididho noship $ */
--
-- Pass in WGI due date and this function will return the WGI Pay date
-- The WGI Pay date is the same as the due date if the due date is the
-- start of a pay period otherwise it is the start of the next pay period.
FUNCTION get_wgi_pay_date (p_wgi_due_date IN DATE
                          ,p_payroll_id   IN NUMBER)
  return DATE IS
CURSOR cur_tpe IS
  SELECT tpe.start_date
  FROM   per_time_periods tpe
  WHERE  tpe.payroll_id = p_payroll_id
  AND    tpe.start_date >= p_wgi_due_date
  ORDER BY tpe.start_date;
--
BEGIN
  FOR cur_tpe_rec IN cur_tpe LOOP
    RETURN(cur_tpe_rec.start_date);
  END LOOP;
  --
  RETURN (NULL);
END get_wgi_pay_date;
--
-- This function checks if the date passed in is the sart of a pay_period
-- for the given payroll
-- Returns TRUE if it is.
FUNCTION check_date_start_of_pay_period (p_date       IN DATE
                                        ,p_payroll_id IN NUMBER)
  RETURN BOOLEAN IS
CURSOR cur_tpe IS
  SELECT 1
  FROM   per_time_periods tpe
  WHERE  tpe.payroll_id = p_payroll_id
  AND    tpe.start_date = p_date;
--
BEGIN
  FOR cur_tpe_rec IN cur_tpe LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN (FALSE);
END check_date_start_of_pay_period;
--
END ghr_validate_paywsmee;

/
