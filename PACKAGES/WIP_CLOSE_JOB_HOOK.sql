--------------------------------------------------------
--  DDL for Package WIP_CLOSE_JOB_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CLOSE_JOB_HOOK" AUTHID CURRENT_USER AS
 /* $Header: wipcljhs.pls 115.7 2002/11/28 19:25:20 rmahidha ship $ */

/* WIP_CLOSE_JOB_HOOK_PRC
 DESCRIPTION:
   This is a dummy procedure which returns success
 RETURNS:
        0 upon success
*/

  PROCEDURE WIP_CLOSE_JOB_HOOK_PRC
   (P_group_id IN NUMBER,
    P_org_id IN NUMBER,
    P_acct_per_id IN NUMBER,
    P_ret_code OUT NOCOPY NUMBER,
    P_err_buf OUT NOCOPY VARCHAR2);

END WIP_CLOSE_JOB_HOOK;



 

/
