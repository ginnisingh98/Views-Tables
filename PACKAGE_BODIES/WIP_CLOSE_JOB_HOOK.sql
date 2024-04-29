--------------------------------------------------------
--  DDL for Package Body WIP_CLOSE_JOB_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CLOSE_JOB_HOOK" AS
 /* $Header: wipcljhb.pls 115.7 2002/11/28 19:25:29 rmahidha ship $ */

PROCEDURE WIP_CLOSE_JOB_HOOK_PRC
  (P_group_id IN NUMBER,
   P_org_id IN NUMBER,
   P_acct_per_id IN NUMBER,
   P_ret_code OUT NOCOPY NUMBER,
   P_err_buf OUT NOCOPY VARCHAR2) IS

BEGIN
/* This is a hook which returns success and can be used to call other
procedures depending on client requirements */

     P_ret_code := 0;
     P_err_buf := '';

EXCEPTION
WHEN OTHERS THEN
     p_ret_code := SQLCODE;
     p_err_buf := 'wipclhjb : ' || SUBSTR(SQLERRM, 1, 240);
END WIP_CLOSE_JOB_HOOK_PRC;


END WIP_CLOSE_JOB_HOOK;

/
