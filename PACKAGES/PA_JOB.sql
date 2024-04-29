--------------------------------------------------------
--  DDL for Package PA_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_JOB" AUTHID CURRENT_USER AS
/* $Header: PAJOBS.pls 115.0 99/07/16 15:07:58 porting ship $ */
  PROCEDURE pa_predel_validation (p_job_id   IN number);
--
END pa_job;

 

/
