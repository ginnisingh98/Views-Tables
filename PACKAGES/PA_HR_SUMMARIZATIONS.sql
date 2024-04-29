--------------------------------------------------------
--  DDL for Package PA_HR_SUMMARIZATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_SUMMARIZATIONS" AUTHID CURRENT_USER AS
/* $Header: PAHRSUMS.pls 115.0 99/07/16 15:06:48 porting shi $ */
--
  PROCEDURE check_person_reference (p_person_id     IN  number,
                                    Error_Message   OUT varchar2,
                                    Reference_Exist OUT varchar2);

  PROCEDURE check_job_reference    (p_job_id         IN number,
                                    Error_Message   OUT varchar2,
                                    Reference_Exist OUT varchar2);
--
END pa_hr_summarizations;

 

/
