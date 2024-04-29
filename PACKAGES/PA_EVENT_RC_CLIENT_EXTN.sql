--------------------------------------------------------
--  DDL for Package PA_EVENT_RC_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EVENT_RC_CLIENT_EXTN" AUTHID CURRENT_USER AS
/* $Header: PAEVTRCS.pls 120.1 2005/08/19 16:22:46 mwasowic noship $ */


  TYPE event_record IS RECORD (
                        task_id                         pa_events.task_id%TYPE,
 			event_num                       NUMBER(15),
			last_update_date                DATE,
 			last_updated_by                 NUMBER,
 			creation_date                   DATE,
 			created_by                      NUMBER(15),
 			last_update_login               NUMBER(15),
 			event_type                      VARCHAR2(30),
 			description                     VARCHAR2(240),
 			bill_amount                     NUMBER,
 			revenue_amount                  NUMBER,
 			revenue_distributed_flag        VARCHAR2(1),
 			bill_hold_flag                  pa_events.bill_hold_flag%TYPE,
 			completion_date                 pa_events.completion_date%TYPE,
 			rev_dist_rejection_code         pa_events.rev_dist_rejection_code%TYPE,
 			request_id                      pa_events.request_id%TYPE,
 			program_application_id          pa_events.program_application_id%TYPE,
 			program_id                      pa_events.program_id%TYPE,
 			program_update_date             pa_events.program_update_date%TYPE,
 			attribute_category              pa_events.attribute_category%TYPE,
 			attribute1                      pa_events.attribute1%TYPE,
 			attribute2                      pa_events.attribute2%TYPE,
 			attribute3                      pa_events.attribute3%TYPE,
 			attribute4                      pa_events.attribute4%TYPE,
 			attribute5                      pa_events.attribute5%TYPE,
 			attribute6                      pa_events.attribute6%TYPE,
 			attribute7                      pa_events.attribute7%TYPE,
 			attribute8                      pa_events.attribute8%TYPE,
 			attribute9                      pa_events.attribute9%TYPE,
 			attribute10                     pa_events.attribute10%TYPE,
 			project_id                      NUMBER(15),
 			organization_id                 NUMBER(15),
 			billing_assignment_id           pa_events.billing_assignment_id%TYPE,
 			event_num_reversed              pa_events.event_num_reversed%TYPE,
 			calling_place                   pa_events.calling_place%TYPE,
 			calling_process                 pa_events.calling_process%TYPE,
 			audit_cost_budget_type_code     pa_events.audit_cost_budget_type_code%TYPE,
 			audit_rev_budget_type_code      pa_events.audit_rev_budget_type_code%TYPE,
 			audit_amount1                   pa_events.audit_amount1%TYPE,
 			audit_amount2                   pa_events.audit_amount2%TYPE,
 			audit_amount3                   pa_events.audit_amount3%TYPE,
 			audit_amount4                   pa_events.audit_amount4%TYPE,
 			audit_amount5                   pa_events.audit_amount5%TYPE,
 			audit_amount6                   pa_events.audit_amount6%TYPE,
 			audit_amount7                   pa_events.audit_amount7%TYPE,
 			audit_amount8                   pa_events.audit_amount8%TYPE,
 			audit_amount9                   pa_events.audit_amount9%TYPE,
 			audit_amount10                  pa_events.audit_amount10%TYPE,
 			event_id                        NUMBER,
 			inventory_org_id                pa_events.inventory_org_id%TYPE,
 			inventory_item_id               pa_events.inventory_item_id%TYPE,
 			quantity_billed                 pa_events.quantity_billed%TYPE,
 			uom_code                        pa_events.uom_code%TYPE,
 			unit_price                      pa_events.unit_price%TYPE,
 			reference1                      pa_events.reference1%TYPE,
 			reference2                      pa_events.reference2%TYPE,
 			reference3                      pa_events.reference3%TYPE,
 			reference4                      pa_events.reference4%TYPE,
 			reference5                      pa_events.reference5%TYPE,
 			reference6                      pa_events.reference6%TYPE,
 			reference7                      pa_events.reference7%TYPE,
 			reference8                      pa_events.reference8%TYPE,
 			reference9                      pa_events.reference9%TYPE,
 			reference10                     pa_events.reference10%TYPE,
 			billed_flag                     pa_events.billed_flag%TYPE,
 			bill_trans_currency_code        pa_events.bill_trans_currency_code%TYPE,
 			bill_trans_bill_amount          pa_events.bill_trans_bill_amount%TYPE,
 			bill_trans_rev_amount           pa_events.bill_trans_rev_amount%TYPE,
 			project_currency_code           pa_events.project_currency_code%TYPE,
 			project_rate_type               pa_events.project_rate_type%TYPE,
 			project_rate_date               pa_events.project_rate_date%TYPE,
 			project_exchange_rate           pa_events.project_exchange_rate%TYPE,
 			project_rev_rate_date           pa_events.project_rev_rate_date%TYPE,
 			project_rev_exchange_rate       pa_events.project_rev_exchange_rate%TYPE,
 			project_revenue_amount          pa_events.project_revenue_amount%TYPE,
 			project_inv_rate_date           pa_events.project_inv_rate_date%TYPE,
 			project_inv_exchange_rate       pa_events.project_inv_exchange_rate%TYPE,
 			project_bill_amount             pa_events.project_bill_amount%TYPE,
 			projfunc_currency_code          pa_events.projfunc_currency_code%TYPE,
 			projfunc_rate_type              pa_events.projfunc_rate_type%TYPE,
 			projfunc_rate_date              pa_events.projfunc_rate_date%TYPE,
 			projfunc_exchange_rate          pa_events.projfunc_exchange_rate%TYPE,
 			projfunc_rev_rate_date          pa_events.projfunc_rev_rate_date%TYPE,
 			projfunc_rev_exchange_rate      pa_events.projfunc_rev_exchange_rate%TYPE,
 			projfunc_revenue_amount         pa_events.projfunc_revenue_amount%TYPE,
 			projfunc_inv_rate_date          pa_events.projfunc_inv_rate_date%TYPE,
 			projfunc_inv_exchange_rate      pa_events.projfunc_inv_exchange_rate%TYPE,
 			projfunc_bill_amount            pa_events.projfunc_bill_amount%TYPE,
 			funding_rate_type               pa_events.funding_rate_type%TYPE,
 			funding_rate_date               pa_events.funding_rate_date%TYPE,
 			funding_exchange_rate           pa_events.funding_exchange_rate%TYPE,
 			revproc_currency_code           pa_events.revproc_currency_code%TYPE,
 			revproc_rate_type               pa_events.revproc_rate_type%TYPE,
 			revproc_rate_date               pa_events.revproc_rate_date%TYPE,
 			revproc_exchange_rate           pa_events.revproc_exchange_rate%TYPE,
 			invproc_currency_code           pa_events.invproc_currency_code%TYPE,
 			invproc_rate_type               pa_events.invproc_rate_type%TYPE,
 			invproc_rate_date               pa_events.invproc_rate_date%TYPE,
 			invproc_exchange_rate           pa_events.invproc_exchange_rate%TYPE,
 			inv_gen_rejection_code          pa_events.inv_gen_rejection_code%TYPE,
 			adjusting_revenue_flag          VARCHAR2(1),
 			adjust_revenue_flag             VARCHAR2(1),
 			non_updateable_flag             VARCHAR2(1),
 			project_funding_id              NUMBER(15),
 			revenue_hold_flag               VARCHAR2(1),
 			zero_revenue_amount_flag        VARCHAR2(1)
                     );



   PROCEDURE override_rsob_event_amount(
             p_calling_mode                      IN    VARCHAR2,
             p_event_rec_old                     IN    event_record,
             p_event_rec_new                     IN    event_record,
             p_primary_set_of_books_id           IN    NUMBER,
             p_primary_currency_code             IN    VARCHAR2,
             p_reporting_set_of_books_id         IN    NUMBER,
             p_reporting_currency_code           IN    VARCHAR2,
             p_event_currency_code               IN    VARCHAR2,
             p_rev_conversion_type               IN    VARCHAR2,
             p_rev_conversion_date               IN    DATE,
             p_rev_exchange_rate                 IN    NUMBER,
             p_bill_conversion_type              IN    VARCHAR2,
             p_bill_conversion_date              IN    DATE,
             p_bill_exchange_rate                IN    NUMBER,
             p_rc_reval_revenue_amount           IN    NUMBER,
             x_override_rev_amt_flag             OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_rev_amt_rate_type                 OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_rev_amt_rate_date                 OUT   NOCOPY DATE, --File.Sql.39 bug 4440895
             x_rev_amt_exchange_rate             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_rc_revenue_amount                 OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_override_bill_amt_flag            OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_bill_amt_rate_type                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_bill_amt_rate_date                OUT   NOCOPY DATE, --File.Sql.39 bug 4440895
             x_bill_amt_exchange_rate            OUT   NOCOPY NUMBER,    --File.Sql.39 bug 4440895
             x_rc_bill_amount                    OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             x_event_description                 OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_error_message                     OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_status                            OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
            );

END pa_event_rc_client_extn;

 

/
