--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BE9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BE9" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:59
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_previous_job_usage_a (
p_previous_job_usage_id        number,
p_object_version_number        number);
end hr_previous_employment_be9;

/
