--------------------------------------------------------
--  DDL for Package AME_ABSOLUTE_JOB_LEVEL_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ABSOLUTE_JOB_LEVEL_HANDLER" AUTHID CURRENT_USER as
/* $Header: ameeajha.pkh 120.0.12000000.1 2007/01/17 23:44:52 appldev noship $ */
  procedure getJobLevelAndSupervisor(personIdIn in integer,
                                     jobLevelOut out nocopy integer,
                                     supervisorIdOut out nocopy integer);
  procedure handler;
end ame_absolute_job_level_handler;

 

/
