--------------------------------------------------------
--  DDL for Package WIP_DISCRETE_JOB_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DISCRETE_JOB_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: wipcmpps.pls 115.5 2002/11/28 19:27:36 rmahidha ship $ */
  PROCEDURE completeAssyItem(p_header_id       IN  NUMBER,
                             x_err_msg         OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2);
END wip_discrete_job_processor;

 

/
