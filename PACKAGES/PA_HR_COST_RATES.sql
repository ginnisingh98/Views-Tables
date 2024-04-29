--------------------------------------------------------
--  DDL for Package PA_HR_COST_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_COST_RATES" AUTHID CURRENT_USER AS
/* $Header: PAHRCRTS.pls 120.1 2005/08/17 12:56:44 ramurthy noship $ */
--
  PROCEDURE check_person_reference (p_person_id     IN  number,
                                    Error_Message   OUT NOCOPY varchar2,
                                    Reference_Exist OUT NOCOPY varchar2);

  PROCEDURE check_job_reference    (p_job_id         IN number,
                                    Error_Message   OUT NOCOPY varchar2,
                                    Reference_Exist OUT NOCOPY varchar2);
--
END pa_hr_cost_rates;

 

/
