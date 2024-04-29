--------------------------------------------------------
--  DDL for Package GHR_VALIDATE_PAYWSMEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_VALIDATE_PAYWSMEE" AUTHID CURRENT_USER AS
/* $Header: ghrwsmee.pkh 120.0.12010000.3 2009/05/26 12:07:04 utokachi noship $ */
  --
  -- Pass in WGI due date and this function will return the WGI Pay date
  -- The WGI Pay date is the same as the due date if the due date is the
  -- start of a pay period otherwise it is the start of the next pay period.
  FUNCTION get_wgi_pay_date (p_wgi_due_date IN DATE
                            ,p_payroll_id   IN NUMBER)
    return DATE;
  --
  -- This function checks if the date passed in is the sart of a pay_period
  -- for the given payroll
  -- Returns TRUE if it is.
  FUNCTION check_date_start_of_pay_period (p_date       IN DATE
                                          ,p_payroll_id IN NUMBER)
    RETURN BOOLEAN;
  --
END ghr_validate_paywsmee;

/
