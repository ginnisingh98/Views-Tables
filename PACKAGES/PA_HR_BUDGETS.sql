--------------------------------------------------------
--  DDL for Package PA_HR_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_BUDGETS" AUTHID CURRENT_USER AS
/* $Header: PAHRBUDS.pls 120.1 2005/08/19 16:33:39 mwasowic noship $ */
--
  PROCEDURE check_person_reference (p_person_id     IN  number,
                                    Error_Message   OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist OUT NOCOPY varchar2); --File.Sql.39 bug 4440895

  PROCEDURE check_job_reference    (p_job_id         IN number,
                                    Error_Message   OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist OUT NOCOPY varchar2); --File.Sql.39 bug 4440895
--
END pa_hr_budgets      ;

 

/
