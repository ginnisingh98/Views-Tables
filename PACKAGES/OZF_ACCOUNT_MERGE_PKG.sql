--------------------------------------------------------
--  DDL for Package OZF_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACCOUNT_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: ozfvcmrs.pls 115.7 2004/05/07 05:22:28 samaresh ship $ */

--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_acct_alloc
--   Purpose :  Merges duplicate customer accounts in
--              ozf_account_allocations table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_acct_alloc (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_claim_lines
--   Purpose :  Merges duplicate customer accounts in
--              ozf_claim_lines_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_claim_lines (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_claim_lines_hist
--   Purpose :  Merges duplicate customer accounts in
--              ozf_claim_lines_hist_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_claim_lines_hist (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_claims
--   Purpose :  Merges duplicate customer accounts in
--              ozf_claims_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_claims (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_claims_history
--   Purpose :  Merges duplicate customer accounts in
--              ozf_claims_history_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_claims_history (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_code_conversions
--   Purpose :  Merges duplicate customer accounts in
--              ozf_code_conversions_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_code_conversions (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_cust_daily_facts
--   Purpose :  Merges duplicate customer accounts in
--              ozf_cust_daily_facts table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_cust_daily_facts (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_fund_utilization
--   Purpose :  Merges duplicate customer accounts in
--              ozf_funds_utilized_all_b table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_fund_utilization (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_offer_denorm
--   Purpose :  Merges duplicate customer accounts in
--              ozf_activity_customers table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_offer_denorm (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_offer_header
--   Purpose :  Merges duplicate customer accounts in
--              ozf_offers table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_offer_header (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_request_header
--   Purpose :  Merges duplicate customer accounts in
--              ozf_request_headers_all_b table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_request_header (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_retail_price_points
--   Purpose :  Merges duplicate customer accounts in
--              ozf_retail_price_points table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_retail_price_points (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


--------------------------------------------------------------------------------
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  merge_trade_profiles
--   Purpose :  Merges duplicate customer accounts in
--              ozf_cust_trd_prfls_all table.
--   Type    :  Private
--   Pre-Req :  None.
--   Parameters:
--   IN
--       p_request_id              IN   NUMBER     Required
--       p_set_number              IN   NUMBER     Required
--       p_process_mode            IN   VARCHAR2   Optional  Default = 'LOCK'
--   OUT:
--
--   Version : Current version 1.0
--
--   End of Comments
--
--------------------------------------------------------------------------------
PROCEDURE merge_trade_profiles (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2
);


END OZF_ACCOUNT_MERGE_PKG;

 

/
