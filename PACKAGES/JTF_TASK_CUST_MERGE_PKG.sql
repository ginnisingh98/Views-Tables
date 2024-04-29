--------------------------------------------------------
--  DDL for Package JTF_TASK_CUST_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_CUST_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: jtftkmgs.pls 115.8 2003/02/19 23:20:25 cjang ship $ */
--/**==================================================================*
--|   Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA   |
--|                        All rights reserved.                        |
--+====================================================================+
-- Start of comments
--      API name        : JTF_TASK_CUST_MERGE_PKG
--      Type            : Public.
--      Function        : This is a customer merge package. It performs the merge operation
--                        for Tasks and Escalations modules. It should be called from
--                        the Main customer merege procedures.
--      Pre-reqs        : None.
--      Parameters      :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      request_id              IN      NUMBER    required
--      set_number              IN     NUMBER     required
--      process_mode            IN     VARCHAR2   required
--
--      Version : 1.0
-------------------------------------------------------------------------------------------
--                              History
-------------------------------------------------------------------------------------------
--      01-FEB-01       tivanov         Created.
--      13-AUG-02       chanik jang     Added get_new_address_id() for the bug 2465855
--      12-FEB-03       Chanik Jang     1) Customer Account Merge allows to merge account
--                                         only in the same party
--                                      2) If you want to merge between different parties,
--                                         submit party merge first.
--                                      3) The lock mode is not implemented
--                                      4) For performance, the codes generated the perl script
--                                          is used. Refer http://www-apps.us.oracle.com/~csng/AMInstructions.html
---------------------------------------------------------------------------------
--
-- End of comments
-------------------------------------------------------------------------------------------
--
-- Procedure Task_Account_Merge performs merging of the following foreign keys:
--              jtf_tasks_b.cust_account_id
--              jtf_tasks_audits_b.new_cust_account_id
--              jtf_tasks_audits_b.old_cust_account_id
--              jtf_perz_query_param.parameter_value for account id and account number
--
-- Following rules are applied:
--   1. Customer account merge allows to merge the accounts within the same party.
--   2. If a user wants to merge between different parties, he/she must run party merge first.
--   3. This JTF Task Account merge will update only customer account id and account number only
-------------------------------------------------------------------------------------------

PROCEDURE Task_Account_Merge(
                p_request_id    IN      NUMBER,
                p_set_number    IN      NUMBER,
                p_process_mode  IN      VARCHAR2);

END JTF_TASK_CUST_MERGE_PKG;

 

/
