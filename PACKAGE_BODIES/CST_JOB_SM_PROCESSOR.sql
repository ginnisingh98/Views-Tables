--------------------------------------------------------
--  DDL for Package Body CST_JOB_SM_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_JOB_SM_PROCESSOR" AS
/* $Header: CSTPSMOB.pls 115.3 2002/11/11 21:25:52 awwang ship $ */

    PROCEDURE COST_PROCESSOR( err_code OUT NOCOPY number,
					err_mesg OUT NOCOPY varchar2) IS
    BEGIN
	  err_code := 0;
	  err_mesg := '';
    END COST_PROCESSOR;

    PROCEDURE COST_UPDATE (x_cost_update_id IN number,
				   err_code OUT NOCOPY number,
				   err_mesg OUT NOCOPY varchar2) IS
	  dummy number;
    BEGIN
        dummy := x_cost_update_id;
        err_code := 0;
        err_mesg := '';
    END COST_UPDATE;

END CST_JOB_SM_PROCESSOR;

/
