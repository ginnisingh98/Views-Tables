--------------------------------------------------------
--  DDL for Package PA_INVOICE_XFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_XFER" AUTHID CURRENT_USER as
/* $Header: PAXITCAS.pls 120.2.12010000.2 2009/12/10 10:49:18 rmandali ship $ */

TYPE var_arr_30  is TABLE of VARCHAR2(30) index by BINARY_INTEGER;
TYPE var_arr_80  is TABLE of VARCHAR2(80) index by BINARY_INTEGER;
--
-- This procedure will convert the interface line amount of the crediting
-- invoices from the project functional currency to the invoice currency
-- of the original invoice credited if both are not same.
-- Parameter  :
--	 P_Project_Id     - Project Id
--       P_Project_Num    - Project Number
--       P_Request_Id     - Request Id
--       P_Proj_Func_Cur  - Project Functional currency
--       P_Batch_Src      - Project Batch Source
--       P_WO_Ccid        - Write-Off Ccid
--       P_UBR_Ccid       - UBR Ccid
--       P_UER_Ccid       - UER Ccid
--       P_REC_Ccid       - REC Ccid
--


/* This overloaded function was added to provide for compilation of older
        version of files like patopt.lpc. In these older versions, call to procedure
        Convert_Amt is made with older, different signature. This procedure is not
        suposed to be called, hence the body consists of code to raise an exception
        if called. -- bug 2615572*/

PROCEDURE Convert_Amt ( P_Project_Id         IN   NUMBER,
                        P_Project_Num        IN   VARCHAR2,
                        P_Request_Id         IN   NUMBER,
                        P_Proj_Func_Cur      IN   VARCHAR2,
                        P_Batch_Src          IN   VARCHAR2,
                        P_WO_Ccid            IN   NUMBER,
                        P_UBR_Ccid           IN   NUMBER,
                        P_UER_Ccid           IN   NUMBER,
                        P_REC_Ccid           IN   NUMBER,
                        P_RND_Ccid           IN   NUMBER,
                        P_Transfer_Mode      IN   VARCHAR2);



PROCEDURE Convert_Amt ( P_Project_Id         IN   NUMBER,
                        P_Project_Num        IN   VARCHAR2,
                        P_Request_Id         IN   NUMBER,
                        P_Proj_Func_Cur      IN   VARCHAR2,
                        P_Batch_Src          IN   VARCHAR2,
                        P_WO_Ccid            IN   NUMBER,
                        P_UBR_Ccid           IN   NUMBER,
                        P_UER_Ccid           IN   NUMBER,
                        P_REC_Ccid           IN   NUMBER,
                        P_RND_Ccid           IN   NUMBER,
                        P_UNB_ret_Ccid       IN   NUMBER,
                        P_Transfer_Mode      IN   VARCHAR2,
                        P_Retn_Acct_Flag     IN   VARCHAR2);
--
-- This procedure will check whether any autoaccounting function transaction
-- is disabled for the input function transaction code.
--
-- Parameter  :
--	 P_Func_code      - Function Transaction Code
--       X_Status         - Output Status Code

PROCEDURE Check_Invoice_acct_setup ( P_Func_code          IN  VARCHAR2,
                                     P_ou_retn_acct_flag  IN  VARCHAR2,
                                     X_Status             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- This procedure will check whether any input account is invalid
--
-- Parameter  :
--      P_Rec_ccid            - Receivable Ccid
--      P_UBR_ccid            - Unbilled Receivable Ccid
--      P_UER_ccid            - Unearned Revenue Ccid
--      P_WO_ccid             - Write Off Ccid
--      P_RND_ccid            - Rounding Ccid
--      X_Status              - Output Status - 'Y' - Valid
--                                            - 'N' - Invalid
--


/* Retention Enahncement : Adding the new param unbilled retention cc id  and P_ou_retn_acct_flag*/

PROCEDURE Check_ccid ( P_Rec_ccid IN  NUMBER,
                       P_UBR_ccid IN  NUMBER,
                       P_UER_ccid IN  NUMBER,
                       P_WO_ccid  IN  NUMBER,
                       P_RND_ccid IN  NUMBER,
                       P_ou_retn_acct_flag IN  VARCHAR2,
                       P_UNB_ret_ccid  IN    NUMBER,
                       X_Status  OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- This procedure will return rejection reason
--
-- Parameter  :
--      P_reject_code         - Rejection Code
--      P_num_rec             - Number of record
--      X_reject_reason       - Rejection reason
--
PROCEDURE get_reject_reason ( P_reject_code    IN var_arr_30,
                              P_num_rec        IN NUMBER,
                              X_reject_reason OUT NOCOPY var_arr_80); --File.Sql.39 bug 4440895

/* Added p_trans_date in below procedure for bug 8687883*/
PROCEDURE  GET_TRX_CRMEMO_TYPES (P_business_group_id           IN   NUMBER,
                                 P_carrying_out_org_id         IN   NUMBER,
                                 P_proj_org_struct_version_id  IN   NUMBER,
				                         p_basic_language              IN   VARCHAR2,
				                         p_trans_date		               IN   DATE,
                                 P_trans_type                    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 P_crmo_trx_type                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 P_error_status                OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 P_error_message               OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

---
--- This procedure checks if its an Internal Customer
--- for Interproject Billing
---

PROCEDURE  CHECK_TRXTYPE_INTERNAL (
                                 P_Proj_id         IN   NUMBER,
                                 P_trans_type      IN   VARCHAR2,
                                 P_crmo_trx_type   IN   VARCHAR2,
                                 P_reject_mesg     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 P_error_status    OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 P_error_message   OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- This procedure is added for bug 2958951
-- This procedure returns the current GL date and GL period for a given date
--

PROCEDURE GET_GL_DATE_PERIOD (P_inv_date         IN  DATE DEFAULT SYSDATE,
                              P_ar_install_flag  IN  VARCHAR2,
                              P_gl_date          OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                              P_gl_period_name   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              P_pa_date          OUT NOCOPY DATE,  --File.Sql.39 bug 4440895
                              P_pa_period_name   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                              P_error_stage      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              P_error_msg_code   OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END PA_INVOICE_XFER;

/
