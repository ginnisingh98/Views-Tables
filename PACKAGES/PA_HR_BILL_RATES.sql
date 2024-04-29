--------------------------------------------------------
--  DDL for Package PA_HR_BILL_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_BILL_RATES" AUTHID CURRENT_USER AS
/* $Header: PAHRBLRS.pls 120.1 2005/08/16 15:00:46 hsiu noship $ */
--
  PROCEDURE check_person_reference (p_person_id     IN  number,
                                    Error_Message   OUT NOCOPY varchar2,
                                    Reference_Exist OUT NOCOPY varchar2);

  PROCEDURE check_job_reference    (p_job_id         IN number,
                                    Error_Message   OUT NOCOPY varchar2,
                                    Reference_Exist OUT NOCOPY varchar2);
--
END pa_hr_bill_rates;

 

/
