--------------------------------------------------------
--  DDL for Package XTR_WRAPPER_API_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_WRAPPER_API_P" AUTHID CURRENT_USER as
/* $Header: xtrwraps.pls 120.4.12010000.2 2009/11/04 20:02:42 srsampat ship $ */


--
-- Package

      PROCEDURE XTR_WRAPPER_API(P_XTR_PROCEDURE_CODE IN VARCHAR2,
                P_SETTLEMENT_SUMMARY_ID IN NUMBER,
                P_TASK IN VARCHAR2,
                P_RECONCILED_METHOD IN CHAR,
                P_ORG_ID IN NUMBER,
                P_ce_bank_account_id IN NUMBER,
                P_CURRENCY_CODE IN VARCHAR2,
                P_SEC_BANK_ACCOUNT_ID IN NUMBER DEFAULT NULL,
                P_TRANS_AMOUNT IN NUMBER,
                P_BALANCE_DATE IN DATE,
                P_BALANCE_AMOUNT_A IN NUMBER,
                P_BALANCE_AMOUNT_B IN NUMBER,
                P_BALANCE_AMOUNT_C IN NUMBER,
                P_ONE_DAY_FLOAT IN NUMBER,
                P_TWO_DAY_FLOAT IN NUMBER,
                P_RESULT OUT NOCOPY VARCHAR2,
                P_ERROR_MSG OUT NOCOPY VARCHAR2);

      PROCEDURE BANK_ACCOUNT_VERIFICATION(P_ORG_ID IN NUMBER,
                P_ce_bank_account_id IN NUMBER,
                P_CURRENCY_CODE IN VARCHAR2,
                P_RESULT OUT NOCOPY VARCHAR2,
                P_ERROR_MSG OUT NOCOPY VARCHAR2);

      PROCEDURE RECONCILIATION(P_SETTLEMENT_SUMMARY_ID IN NUMBER,
                P_TASK IN VARCHAR2,
                P_RECONCILED_METHOD IN CHAR,
                P_RESULT OUT NOCOPY VARCHAR2,
		P_RECON_AMT IN NUMBER,
		P_VAL_DATE IN DATE);

     PROCEDURE BANK_BALANCE_UPLOAD(P_ORG_ID IN NUMBER,
                P_ce_bank_account_id IN NUMBER,
                P_CURRENCY_CODE IN VARCHAR2,
                P_BALANCE_DATE IN DATE,
                P_BALANCE_AMOUNT_A IN NUMBER,
                P_BALANCE_AMOUNT_B IN NUMBER DEFAULT NULL,
                P_BALANCE_AMOUNT_C IN NUMBER DEFAULT NULL,
                P_ONE_DAY_FLOAT IN NUMBER,
                P_TWO_DAY_FLOAT IN NUMBER,
                P_RESULT OUT NOCOPY VARCHAR2,
                P_ERROR_MSG OUT NOCOPY VARCHAR2);

     PROCEDURE SETTLEMENT_VALIDATION(P_SETTLEMENT_SUMMARY_ID IN NUMBER,
                P_RESULT OUT NOCOPY VARCHAR2);


     ----------------------------------------------------------------------------------------------------
     -- 3800146 Global Parameter used by FIND_SPECIFIC_GLOBAL_RATE
     ----------------------------------------------------------------------------------------------------
        G_rate_ref_code  VARCHAR2(10) default 'IG_PRO1075';       -- currently only 'IG_PRO1075' is used


     ----------------------------------------------------------------------------------------------------
     -- 3800146 This procedure verifies the type of account: XTR only or AP/XTR Shared
     ----------------------------------------------------------------------------------------------------
     PROCEDURE ZBA_BANK_ACCOUNT_VERIFICATION
          (P_ORG_ID    IN  NUMBER,  -- org_id of the company for 'Shared'
          P_ce_bank_account_id IN  NUMBER,  -- ap_bank_Account_id for 'Shared or 'AP-only'
          P_ACCOUNT_NUMBER IN  VARCHAR2,-- account_number in XTR_BANK_ACCOUNTS
          P_CURRENCY           IN  VARCHAR2,-- currency of transaction
          P_BANK_ACCOUNT_ID    OUT NOCOPY NUMBER,  -- ap_bank_account_id 'Shared' or dummy_bank_account_id 'XTR-only'
          P_RESULT             OUT NOCOPY VARCHAR2,-- 'PASS' or 'FAIL'
          P_ERROR_MSG          OUT NOCOPY VARCHAR2);

     ------------------------------------------------------------------------------------------------------------------------------
     --  3800146 Procedure to find the Specific/Global/LatestTransaction interest rate from interest rate ranges for this account.
     ------------------------------------------------------------------------------------------------------------------------------
     PROCEDURE FIND_SPECIFIC_GLOBAL_RATE (
				p_company_code     IN VARCHAR2,
                                p_party_code       IN VARCHAR2,
                                p_currency         IN VARCHAR2,
                                p_balance_out      IN NUMBER,
                                p_principal_adjust IN NUMBER,
                                p_transfer_date    IN DATE,
                                p_block            IN VARCHAR2,
                                p_ref_code         IN VARCHAR2,    -- currently only 'IG_PRO1075' is used
                                p_interest_rate    OUT NOCOPY NUMBER,
                                p_warn_message     OUT NOCOPY VARCHAR2 );


     --------------------------------------------------------------------------------------------
     -- 3800146 This procedure is used by Cash Leveling and ZBA processes to derive the IG Rate.
     --------------------------------------------------------------------------------------------
     PROCEDURE DERIVE_LATEST_TRAN (p_company_code     IN  VARCHAR2,
                                   p_party_code       IN  VARCHAR2,
                                   p_currency         IN  VARCHAR2,
                                   p_transfer_date    IN  DATE,
                                   p_principal_adjust IN  NUMBER,
                                   p_principal_action IN  VARCHAR2,
                                   p_interest_rate    OUT NOCOPY NUMBER,
                                   p_rounding_type    OUT NOCOPY VARCHAR2,
                                   p_day_count_type   OUT NOCOPY VARCHAR2,
                                   p_pricing_model    OUT NOCOPY VARCHAR2,
                                   p_balance_out      OUT NOCOPY NUMBER );


     PROCEDURE CHK_ZBA_IG_DUPLICATE (
			p_company_code              IN  VARCHAR2,
			p_intercompany_code         IN  VARCHAR2,
			p_currency                  IN  VARCHAR2,
			p_transfer_amount           IN  NUMBER,
			p_transfer_date             IN  DATE,
			p_action_code               IN  VARCHAR2,
			p_company_portfolio         IN  VARCHAR2,
			p_company_product_type      IN  VARCHAR2,
			p_intercompany_portfolio    IN  VARCHAR2,
			p_intercompany_product_type IN  VARCHAR2,
			p_company_account_no        IN  VARCHAR2,
			p_party_account_no          IN  VARCHAR2,
			p_zba_duplicate             OUT NOCOPY BOOLEAN);


     PROCEDURE CHK_ZBA_IAC_DUPLICATE (
				l_company_code        IN  VARCHAR2,
                                l_transfer_amount     IN  NUMBER,
                                l_transfer_date       IN  DATE,
                                l_from_account_no     IN  VARCHAR2,
                                l_to_account_no       IN  VARCHAR2,
                                l_portfolio           IN  VARCHAR2,
                                l_product_type        IN  VARCHAR2,
                                l_duplicate           OUT NOCOPY BOOLEAN);

     -------------------------------------------------------------------------------------------------------------------
     -- 3800146 This procedure derives the validate and settlement status of IAC when calling ZBA, Cash Leveling or Form
     -------------------------------------------------------------------------------------------------------------------
     PROCEDURE SET_IAC_VALIDATE_SETTLE(
				p_product          IN  VARCHAR2,
                                p_dealer           IN  VARCHAR2,
                                p_called_by_flag   IN  VARCHAR2,  -- pass null for form
                                p_auth_validate    OUT NOCOPY BOOLEAN,
                                p_auth_settlement  OUT NOCOPY BOOLEAN);

     FUNCTION A_COMP(l_comp IN VARCHAR2) return boolean;

     PROCEDURE IG_ZBA_CL_DEFAULT (
			p_company_code               IN  VARCHAR2,
                        p_intercompany_code          IN  VARCHAR2,
                        p_currency                   IN  VARCHAR2,
                        p_transfer_date              IN  DATE,
                        p_transfer_amount            IN  NUMBER,
                        p_action_code                IN  VARCHAR2,
                        p_interest_rounding          IN  VARCHAR2,
                        p_interest_includes          IN  VARCHAR2,
                        p_company_pricing_model      IN  VARCHAR2,
                        p_intercompany_pricing_model IN  VARCHAR2,
                        l_interest_rate              OUT NOCOPY NUMBER,
                        l_rounding_type              OUT NOCOPY VARCHAR2,
                        l_day_count_type             OUT NOCOPY VARCHAR2,
                        l_pricing_model              OUT NOCOPY VARCHAR2,
                        l_mirror_pricing_model       OUT NOCOPY VARCHAR2);

     -------------------------------------------------------
     -- 3800146 Main IG API called by ZBA and Cash Leveling
     -------------------------------------------------------

/*
     PROCEDURE IG_GENERATION(p_company_code               IN VARCHAR2,
                             p_intercompany_code          IN VARCHAR2,
                             p_currency                   IN VARCHAR2,
                             p_transfer_date              IN DATE,
                             p_company_account_no         IN VARCHAR2,
                             p_party_account_no           IN VARCHAR2,
                             p_action_code                IN VARCHAR2,
                             p_transfer_amount            IN NUMBER,
                             p_company_dealer             IN VARCHAR2,
                             p_company_portfolio          IN VARCHAR2,
                             p_company_product_type       IN VARCHAR2,
                             p_company_pricing_model      IN VARCHAR2,
                             p_company_fund_limit         IN VARCHAR2,
                             p_company_inv_limit          IN VARCHAR2,
                             p_intercompany_dealer        IN VARCHAR2,
                             p_intercompany_portfolio     IN VARCHAR2,
                             p_intercompany_product_type  IN VARCHAR2,
                             p_intercompany_pricing_model IN VARCHAR2,
                             p_intercompany_fund_limit    IN VARCHAR2,
                             p_intercompany_inv_limit     IN VARCHAR2,
                             p_accept_limit_error         IN VARCHAR2,  -- see Override_limit on IG p.40
                             p_company_rounding_type      IN VARCHAR2,  -- NOTE: only use for new deal
                             p_company_day_count_type     IN VARCHAR2,  -- NOTE: only use for new deal
                             p_deal_no                    OUT NOCOPY NUMBER,
                             p_tran_no                    OUT NOCOPY NUMBER,
                             p_mirror_deal_no             OUT NOCOPY NUMBER,
                             p_mirror_tran_no             OUT NOCOPY NUMBER,
                             p_success_flag               OUT NOCOPY VARCHAR2,
                             p_process_flag               IN  VARCHAR2);
*/

     PROCEDURE IG_GENERATION(p_cash_pool_id               IN NUMBER,
                             p_company_bank_id            IN NUMBER,
                             p_party_bank_id              IN NUMBER,
                             p_currency                   IN VARCHAR2,
                             p_transfer_date              IN DATE,
                             p_transfer_amount            IN NUMBER,
                             p_action_code                IN VARCHAR2,
                             p_accept_limit_error         IN VARCHAR2,  -- see Override_limit on IG p.40
                             p_deal_no                    OUT NOCOPY NUMBER,
                             p_tran_no                    OUT NOCOPY NUMBER,
                             p_mirror_deal_no             OUT NOCOPY NUMBER,
                             p_mirror_tran_no             OUT NOCOPY NUMBER,
                             p_success_flag               OUT NOCOPY VARCHAR2,
                             p_process_flag               IN  VARCHAR2);

     PROCEDURE IAC_GENERATION(p_cash_pool_id       IN NUMBER,
                              p_from_bank_acct_id  IN NUMBER,
                              p_to_bank_acct_id    IN NUMBER,
                              p_transfer_date      IN DATE,
                              p_transfer_amount    IN NUMBER,
                              p_tran_no            OUT NOCOPY NUMBER,
                              p_success_flag       OUT NOCOPY VARCHAR2,
                              p_process_flag       IN  VARCHAR2);

End XTR_WRAPPER_API_P;

/
