--------------------------------------------------------
--  DDL for Package PA_FUND_REVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUND_REVAL_PVT" AUTHID CURRENT_USER AS
--$Header: PAXFRPPS.pls 120.1.12010000.3 2008/10/08 09:02:40 dbudhwar ship $

   -- Package Variables
   G_LAST_UPDATE_LOGIN      NUMBER;
   G_REQUEST_ID             NUMBER;
   G_PROGRAM_APPLICATION_ID NUMBER;
   G_PROGRAM_ID             NUMBER;
   G_LAST_UPDATED_BY        NUMBER;
   G_CREATED_BY             NUMBER;
   G_DEBUG_MODE             VARCHAR2(1);
   G_THRU_DATE              DATE;
   G_RATE_TYPE              VARCHAR2(30);
   G_RATE_DATE              DATE;
   G_BASELINE_FLAG          VARCHAR2(1);
   G_REVAL_FLAG             VARCHAR2(1) := 'N';
   G_SET_OF_BOOKS_ID        NUMBER;
   G_AR_INSTALLED_FLAG      VARCHAR2(1);
   G_MRC_FUND_ENABLED_FLAG  VARCHAR2(1) := 'N';
   G_AR_PRIMARY_ONLY        VARCHAR2(1);
   G_PRIMARY_ONLY           VARCHAR2(1);

   TYPE SobRecord is RECORD (
        ReportingCurrencyCode  VARCHAR2(30),
        ConversionType         VARCHAR2(30),
        EnabledFlag            VARCHAR2(1));

   TYPE SobListTabTyp is TABLE of SobRecord INDEX BY BINARY_INTEGER;
   G_SobListTab      SobListTabTyp;

   TYPE RsobRecord is RECORD (
      EnabledFlag             VARCHAR2(1));

   TYPE RsobTabTyp is TABLE of RsobRecord INDEX BY BINARY_INTEGER;

   TYPE ProjRecTyp is RECORD (
        project_id                    NUMBER,
        carrying_out_organization_id  NUMBER,
        gain_event_type               VARCHAR2(30),
        gain_event_desc               VARCHAR2(250),
        loss_event_type               VARCHAR2(30),
        loss_event_desc               VARCHAR2(250),
        baseline_funding_flag         VARCHAR2(1),
        include_gains_losses_flag     VARCHAR2(1),
        projfunc_bil_rate_type        VARCHAR2(30),
        projfunc_bil_exchange_rate    NUMBER,
        revproc_currency_code         VARCHAR2(30),
        invproc_rate_type             VARCHAR2(30),
        invproc_exchange_rate         NUMBER,
        Zero_dollar_reval_flag        VARCHAR2(1));

   G_ProjLvlGlobRec  ProjRecTyp;

   TYPE SPFLineRec is RECORD(
        set_of_books_id              NUMBER,
        agreement_id                 NUMBER,
        task_id                      NUMBER,
        funding_currency_code        VARCHAR2(30),
        projfunc_currency_code       VARCHAR2(30),
        invproc_currency_code        VARCHAR2(30),
        total_baselined_amount       NUMBER,
        projfunc_baselined_amount    NUMBER,
        invproc_baselined_amount     NUMBER,
        realized_gains_amount        NUMBER,
        realized_losses_amount       NUMBER,
        retention_level_code         VARCHAR2(30));

   TYPE SPFTabTyp is TABLE of SPFLineRec  INDEX BY BINARY_INTEGER;

   TYPE RevalCompRec is RECORD(
        project_id                       NUMBER,
        agreement_id                     NUMBER,
        task_id                          NUMBER,
        set_of_books_id                  NUMBER,
        enabled_flag                     VARCHAR2(1),
        funding_currency_code            VARCHAR2(30),
        project_currency_code            VARCHAR2(30),
        projfunc_currency_code           VARCHAR2(30),
        invproc_currency_code            VARCHAR2(30),
        total_baselined_amount           NUMBER,
        projfunc_baselined_amount        NUMBER,
        invproc_baselined_amount         NUMBER,
        realized_gains_amount            NUMBER,
        realized_losses_amount           NUMBER,
        funding_inv_applied_amount       NUMBER,
        funding_inv_due_amount           NUMBER,
        funding_backlog_amount           NUMBER,
        projfunc_realized_gains_amt      NUMBER,
        projfunc_realized_losses_amt     NUMBER,
        projfunc_inv_applied_amount      NUMBER,
        funding_reval_amount             NUMBER,
        projfunc_reval_amount            NUMBER,
        invproc_reval_amount             NUMBER,
        funding_revaluation_factor       NUMBER,
        reval_projfunc_rate_type         VARCHAR2(30),
        reval_projfunc_rate              NUMBER,
        reval_invproc_rate_type          VARCHAR2(30),
        reval_invproc_rate               NUMBER,
        projfunc_inv_due_amount          NUMBER,
        projfunc_backlog_amount          NUMBER,
        invproc_backlog_amount           NUMBER,
        invproc_revalued_amount          NUMBER,
        projfunc_revalued_amount         NUMBER,
        projfunc_allocated_amount        NUMBER,
        invproc_allocated_amount         NUMBER,
        event_amount                     NUMBER,
        projfunc_accrued_amount          NUMBER,
        invproc_billed_amount            NUMBER);

   TYPE RevalCompTabTyp is TABLE of RevalCompRec  INDEX BY BINARY_INTEGER;
   G_RevalCompTab       RevalCompTabTyp;

   TYPE RetnInvRec is RECORD (
        draft_invoice_num       NUMBER,
        set_of_books_id         NUMBER,
        projfunc_currency_code  VARCHAR2(30),
        funding_currency_code   VARCHAR2(30),
        inv_currency_code       VARCHAR2(30),
        system_reference        NUMBER,
        projfunc_bill_amount    NUMBER,
        funding_bill_amount     NUMBER,
        inv_amount              NUMBER);
   TYPE RetnInvTabTyp is TABLE of RetnInvRec  INDEX BY BINARY_INTEGER;


   TYPE InvCompRec is RECORD (
       project_id               NUMBER,
       agreement_id             NUMBER,
       task_id                  NUMBER,
       set_of_books_id          NUMBER,
       invproc_billed_amount    NUMBER,
       funding_billed_amount    NUMBER,
       projfunc_billed_amount    NUMBER,
       funding_applied_amount   NUMBER,
       projfunc_applied_amount  NUMBER,
       projfunc_gain_amount     NUMBER,
       projfunc_loss_amount     NUMBER,
       revald_pf_inv_due_amount  NUMBER,       /* Added for Bug 3221279 */
       funding_adjusted_amount   NUMBER,          /* Added for bug 7237486 */
       projfunc_adjusted_amount  NUMBER);         /* Added for bug 7237486 */

   TYPE InvCompTabTyp is TABLE of InvCompRec INDEX BY BINARY_INTEGER;
   G_InvCompTab  InvCompTabTyp;

   TYPE RetnApplAmtRec is RECORD (
      project_id                  NUMBER,
      agreement_id                NUMBER,
      set_of_books_id             NUMBER,
      funding_applied_amount      NUMBER,
      projfunc_applied_amount     NUMBER,
      projfunc_gain_amount        NUMBER,
      projfunc_loss_amount        NUMBER,
      funding_adj_appl_amount     NUMBER,
      projfunc_adj_appl_amount    NUMBER,
      projfunc_adj_gain_amount    NUMBER,
      projfunc_adj_loss_amount    NUMBER,
      error_status                VARCHAR2(30) );

   TYPE RetnApplAmtTabTyp is TABLE of RetnApplAmtRec INDEX BY BINARY_INTEGER;
   G_RetnApplAmtTab  RetnApplAmtTabTyp;

   TYPE ARAmtRecord is RECORD (
      set_of_books_id       NUMBER,
      inv_applied_amount       NUMBER,
      projfunc_applied_amount  NUMBER,
      projfunc_gain_amount     NUMBER,
      projfunc_loss_amount     NUMBER,
      inv_adjusted_amount      NUMBER,    /* Added for bug 7237486*/
      projfunc_adjusted_amount NUMBER);  /* Added for bug 7237486 */


   TYPE ArAmtsTabTyp is Table of ARAmtRecord INDEX BY BINARY_INTEGER;

   TYPE InvoiceRecord is RECORD(
       set_of_books_id          NUMBER,
       task_id                  NUMBER,
       projfunc_currency_code   VARCHAR2(30),
       funding_currency_code    VARCHAR2(30),
       invproc_currency_code    VARCHAR2(30),
       inv_currency_code        VARCHAR2(30),
       amount                   NUMBER,
       projfunc_bill_amount     NUMBER,
       funding_bill_amount      NUMBER,
       inv_amount               NUMBER,
       retn_amount              NUMBER,
       projfunc_retn_amount     NUMBER,
       funding_retn_amount      NUMBER,
       inv_retn_amount          NUMBER);

   TYPE InvTabTyp is Table of InvoiceRecord INDEX BY BINARY_INTEGER;

   TYPE InvoiceTotal is RECORD(
       set_of_books_id          NUMBER,
       amount                   NUMBER,
       projfunc_bill_amount     NUMBER,
       funding_bill_amount      NUMBER,
       inv_amount               NUMBER);

   TYPE InvTotTabTyp is Table of InvoiceTotal INDEX BY BINARY_INTEGER;

   TYPE RetainedAmtRec is RECORD (
       task_id                    NUMBER,
       set_of_books_id            NUMBER,
       projfunc_retained_amount   NUMBER,
       funding_retained_amount    NUMBER);

   TYPE RetainedAmtTabTyp is Table of RetainedAmtRec INDEX By BINARY_INTEGER;

   PROCEDURE Revaluate_funding(
             p_project_id        IN    NUMBER,
             p_project_type_id   IN    NUMBER,
             p_from_proj_number  IN    VARCHAR2,
             p_to_proj_number    IN    VARCHAR2,
             p_thru_date         IN    DATE,
             p_rate_type         IN    VARCHAR2 ,
             p_rate_date         IN    DATE,
             p_baseline_flag     IN    VARCHAR2,
             p_debug_mode        IN    VARCHAR2,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE validate_project_eligibility(
             p_project_id        IN    NUMBER,
             p_run_mode          IN    VARCHAR2,
             x_eligible_flag     OUT   NOCOPY VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE get_rsob_ids(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   FUNCTION get_ar_installed   RETURN VARCHAR2 ;

   PROCEDURE get_start_end_proj_num(
             p_project_id        IN     NUMBER,
             p_run_mode          IN     VARCHAR2,
             x_from_proj_number  IN OUT NOCOPY VARCHAR2,
             x_to_proj_number    IN OUT NOCOPY VARCHAR2,
             x_project_type_id   IN OUT NOCOPY NUMBER,
             x_return_status     OUT    NOCOPY VARCHAR2,
             x_msg_count         OUT    NOCOPY NUMBER,
             x_msg_data          OUT    NOCOPY VARCHAR2);

   PROCEDURE Check_Unrel_invoice_revenue (
             p_project_id        IN    NUMBER,
             x_exist_flag        OUT   NOCOPY VARCHAR2,
             x_reason_code       OUT   NOCOPY VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   FUNCTION Check_reval_unbaselined_funds (
             p_project_id        IN    NUMBER) RETURN VARCHAR2;

   PROCEDURE Delete_Unbaselined_Adjmts (
             p_project_id        IN    NUMBER,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE Insert_distribution_warnings(
             p_project_id        IN    NUMBER,
             p_agreement_id      IN    NUMBER DEFAULT NULL,
             p_task_id           IN    NUMBER DEFAULT NULL,
             p_reason_code       IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE Initialize;

   PROCEDURE get_reval_projects(
             p_project_id        IN    NUMBER,
             p_project_type_id   IN    NUMBER,
             p_from_proj_number  IN    VARCHAR2,
             p_to_proj_number    IN    VARCHAR2,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE get_spf_lines(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE process_spf_lines(
             p_agreement_id         IN    NUMBER,
             p_task_id              IN    NUMBER,
             p_retention_level_code IN    VARCHAR2,
             x_return_status        OUT   NOCOPY VARCHAR2,
             x_msg_count            OUT   NOCOPY NUMBER,
             x_msg_data             OUT   NOCOPY VARCHAR2);

   PROCEDURE get_retn_appl_amount(
             p_project_id        IN      NUMBER,
             p_agreement_id      IN      NUMBER,
             x_return_status     OUT     NOCOPY VARCHAR2,
             x_msg_count         OUT     NOCOPY NUMBER,
             x_msg_data          OUT     NOCOPY VARCHAR2);

   PROCEDURE process_retention_invoices (
             p_system_reference     IN   NUMBER,
             p_Invoice_Status       IN   VARCHAR2,
             p_adjust_flag          IN    VARCHAR2,
             p_RetnInvTab           IN   RetnInvTabTyp,
             x_return_status        OUT  NOCOPY VARCHAR2,
             x_msg_count            OUT  NOCOPY NUMBER,
             x_msg_data             OUT  NOCOPY VARCHAR2);

   PROCEDURE get_invoice_components(
             p_project_id             IN     NUMBER,
             p_agreement_id           IN     NUMBER,
             p_task_id                IN     NUMBER,
             p_TaskFund_ProjRetn_Flag IN     VARCHAR2,
             x_return_status          OUT    NOCOPY VARCHAR2,
             x_msg_count              OUT    NOCOPY NUMBER,
             x_msg_data               OUT    NOCOPY VARCHAR2);

   PROCEDURE derive_reval_components(
             p_project_id             IN    NUMBER,
             p_task_id                IN    NUMBER,
             p_agreement_id           IN    NUMBER,
             p_draft_inv_num          IN    NUMBER,
             p_system_reference       IN    NUMBER,
             p_invoice_status         IN    VARCHAR2,
             p_adjust_flag            IN    VARCHAR2,
             p_TaskFund_ProjRetn_Flag IN    VARCHAR2,
             p_Invoice_Type           IN    VARCHAR2,
             p_InvTab                 IN    InvTabTyp,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

   PROCEDURE get_invoice_total(
             p_project_id        IN    NUMBER,
             p_agreement_id      IN    NUMBER,
             p_draft_inv_num     IN    NUMBER,
             x_InvTotTab         OUT   NOCOPY InvTotTabTyp,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE get_retained_amount(
             p_project_id        IN    NUMBER,
             p_task_id           IN    VARCHAR2,
             p_draft_inv_num     IN    NUMBER,
             x_RetainedAmtTab    OUT   NOCOPY RetainedAmtTabTyp,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE sum_retained_amount(
             p_task_id           IN      NUMBER,
             p_SetOfBookIdTab    IN      PA_PLSQL_DATATYPES.IdTabTyp,
             p_RetainedAmtPFCTab IN      PA_PLSQL_DATATYPES.NumTabTyp,
             p_RetainedAmtFCTab  IN      PA_PLSQL_DATATYPES.NumTabTyp,
             x_RetainedAmtTab    IN OUT  NOCOPY RetainedAmtTabTyp,
             x_return_status     OUT     NOCOPY VARCHAR2,
             x_msg_count         OUT     NOCOPY NUMBER,
             x_msg_data          OUT     NOCOPY VARCHAR2);

   PROCEDURE adjust_appl_amount(
             p_project_id           IN      NUMBER,
             p_agreement_id         IN      NUMBER,
             p_SobId                IN      NUMBER,
             p_retained_amount_pfc  IN      NUMBER,
             p_retained_amount_fc   IN      NUMBER,
             x_retn_appl_amt_pfc    OUT     NOCOPY NUMBER,
             x_retn_appl_amt_fc     OUT     NOCOPY NUMBER,
             x_retn_gain_amt_pfc    OUT     NOCOPY NUMBER,
             x_retn_loss_amt_pfc    OUT     NOCOPY NUMBER,
             x_return_status        OUT     NOCOPY VARCHAR2,
             x_msg_count            OUT     NOCOPY NUMBER,
             x_msg_data             OUT     NOCOPY VARCHAR2);

   PROCEDURE get_sum_invoice_components(
             p_project_id             IN     NUMBER,
             p_agreement_id           IN     NUMBER,
             p_task_id                IN     NUMBER,
             x_return_status          OUT    NOCOPY VARCHAR2,
             x_msg_count              OUT    NOCOPY NUMBER,
             x_msg_data               OUT    NOCOPY VARCHAR2);

   PROCEDURE populate_invoice_amount(
             p_project_id        IN      NUMBER,
             p_agreement_id      IN      NUMBER,
             p_task_id           IN      NUMBER,
             p_SetOfBookIdTab    IN      PA_PLSQL_DATATYPES.IdTabTyp,
             p_TaskIdTab         IN      PA_PLSQL_DATATYPES.IdTabTyp,
             p_BillAmtIPCTab     IN      PA_PLSQL_DATATYPES.NumTabTyp,
             p_BillAmtFCTab      IN      PA_PLSQL_DATATYPES.NumTabTyp,
             p_BillAmtPFCTab     IN      PA_PLSQL_DATATYPES.NumTabTyp,
             x_return_status     OUT     NOCOPY VARCHAR2,
             x_msg_count         OUT     NOCOPY NUMBER,
             x_msg_data          OUT     NOCOPY VARCHAR2) ;


   PROCEDURE compute_adjustment_amounts(
             p_agreement_id            IN      NUMBER,
             p_task_id                 IN      NUMBER,
             x_return_status           OUT     NOCOPY VARCHAR2,
             x_msg_count               OUT     NOCOPY NUMBER,
             x_msg_data                OUT     NOCOPY VARCHAR2);

   PROCEDURE insert_rejection_reason_spf(
             p_project_id        IN    NUMBER,
             p_agreement_id      IN    VARCHAR2,
             p_task_id           IN    VARCHAR2,
             p_reason_code       IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE create_adjustment_line(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE insert_event_record(
                  p_project_id             IN   NUMBER,
                  p_task_id                IN   NUMBER,
                  p_event_type             IN   VARCHAR2,
                  p_event_desc             IN   VARCHAR2,
                  p_Bill_trans_rev_amount  IN   NUMBER,
                  p_project_funding_id     IN   NUMBER,
                  p_agreement_id           IN   NUMBER,/*Federal*/
                  x_return_status          OUT  NOCOPY VARCHAR2,
                  x_msg_count              OUT  NOCOPY NUMBER,
                  x_msg_data               OUT  NOCOPY VARCHAR2);

   PROCEDURE get_ar_amounts(
                 p_customer_trx_id   IN NUMBER,
                 p_invoice_status    IN VARCHAR2,
                 x_ArAmtsTab         OUT NOCOPY ArAmtsTabTyp,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2) ;

   PROCEDURE clear_distribution_warnings(
             p_request_id        IN    NUMBER,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE get_delete_projects(
             p_project_type_id   IN    NUMBER,
             p_from_proj_number  IN    VARCHAR2,
             p_to_proj_number    IN    VARCHAR2,
             p_run_mode          IN    VARCHAR2,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

   PROCEDURE check_accrued_billed_level(
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);


END PA_FUND_REVAL_PVT;

/
