--------------------------------------------------------
--  DDL for Package CST_JOB_SM_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_JOB_SM_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: CSTPSMOS.pls 115.3 2002/11/11 21:26:06 awwang ship $ */

    PROCEDURE COST_PROCESSOR(err_code out NOCOPY number,
		 			err_mesg out NOCOPY varchar2);
    PROCEDURE COST_UPDATE (x_cost_update_id IN number,
				   err_code out NOCOPY number,
		 		   err_mesg out NOCOPY varchar2);
END CST_JOB_SM_PROCESSOR;

 

/
