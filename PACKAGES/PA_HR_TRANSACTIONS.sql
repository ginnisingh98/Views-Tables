--------------------------------------------------------
--  DDL for Package PA_HR_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: PAHRTRXS.pls 120.1 2005/08/17 12:56:52 ramurthy noship $ */
--
  PROCEDURE check_person_reference (p_person_id     IN  number,
                                    Error_Message   OUT NOCOPY varchar2,
                                    Reference_Exist OUT NOCOPY varchar2);

  PROCEDURE check_job_reference    (p_job_id         IN number,
                                    Error_Message   OUT NOCOPY varchar2,
                                    Reference_Exist OUT NOCOPY varchar2);
--
END pa_hr_transactions ;

 

/
