--------------------------------------------------------
--  DDL for Package DPP_ACCOUNT_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_ACCOUNT_MERGE_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvamgs.pls 120.0 2007/11/27 09:29:09 sdasan noship $ */

--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_claim_account
--   Purpose :  Merges duplicate customer accounts in
--              dpp_customer_claims_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_claim_account (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_claim_account_log
--   Purpose :  Merges duplicate customer accounts in
--              dpp_customer_claims_log table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_claim_account_log (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);

END DPP_ACCOUNT_MERGE_PVT;

/
