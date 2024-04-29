--------------------------------------------------------
--  DDL for Package HR_JOB_API_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JOB_API_BE3" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:56
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_job_a (
p_validate                     boolean,
p_job_id                       number,
p_object_version_number        number);
end hr_job_api_be3;

/
