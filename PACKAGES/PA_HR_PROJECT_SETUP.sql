--------------------------------------------------------
--  DDL for Package PA_HR_PROJECT_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_PROJECT_SETUP" AUTHID CURRENT_USER AS
/* $Header: PAHRPRJS.pls 120.1 2005/08/19 16:33:46 mwasowic noship $ */
--
  PROCEDURE check_person_reference (p_person_id     IN  number,
                                    Error_Message   OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist OUT NOCOPY varchar2); --File.Sql.39 bug 4440895

  PROCEDURE check_job_reference    (p_job_id         IN number,
                                    Error_Message   OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist OUT NOCOPY varchar2); --File.Sql.39 bug 4440895
--
END pa_hr_project_setup;

 

/
