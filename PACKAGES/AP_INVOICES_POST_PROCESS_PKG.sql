--------------------------------------------------------
--  DDL for Package AP_INVOICES_POST_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICES_POST_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: apinvpps.pls 120.12.12010000.3 2010/02/10 08:52:04 asansari ship $ */

  procedure create_holds (X_invoice_id           IN number,
                          X_event                IN varchar2 default 'UPDATE',
                          X_update_base          IN varchar2 default 'N',
                          X_vendor_changed_flag  IN varchar2 default 'N',
                          X_calling_sequence     IN varchar2);

  procedure insert_children (
             X_invoice_id               IN            number,
             X_Payment_Priority         IN            number,
             X_Hold_count               IN OUT NOCOPY number,
             X_Line_count               IN OUT NOCOPY number,
             X_Line_Total               IN OUT NOCOPY number,
             X_calling_sequence         IN            varchar2,
             X_Sched_Hold_count         IN OUT NOCOPY NUMBER);  -- bug 5334577


  procedure invoice_pre_update  (
               X_invoice_id              IN            number,
               X_invoice_amount          IN            number,
               X_payment_status_flag     IN OUT NOCOPY varchar2,
               X_invoice_type_lookup_code IN           varchar2,
               X_last_updated_by         IN            number,
               X_accts_pay_ccid          IN            number,
               X_terms_id                IN            number,
               X_terms_date              IN            date,
               X_discount_amount         IN            number,
               X_exchange_rate_type      IN            varchar2,
               X_exchange_date           IN            date,
               X_exchange_rate           IN            number,
               X_vendor_id               IN            number,
               X_payment_method_code     IN         varchar2, --4393358
               X_message1                IN OUT NOCOPY varchar2,
               X_message2                IN OUT NOCOPY varchar2,
               X_reset_match_status      IN OUT NOCOPY varchar2,
               X_vendor_changed_flag     IN OUT NOCOPY varchar2,
               X_recalc_pay_sched        IN OUT NOCOPY varchar2,
               X_liability_adjusted_flag IN OUT NOCOPY varchar2,
	       X_external_bank_account_id   IN	       NUMBER, 	 --bug 7714053
               X_payment_currency_code	    IN	       VARCHAR2, --Bug9294551
               X_calling_sequence        IN            varchar2,
               X_revalidate_ps           IN OUT NOCOPY varchar2);

  procedure invoice_post_update (
               X_invoice_id          IN number,
               X_payment_priority    IN number,
               X_recalc_pay_sched    IN OUT NOCOPY varchar2,
               X_Hold_count          IN OUT NOCOPY number,
               X_update_base         IN varchar2,
               X_vendor_changed_flag IN varchar2,
               X_calling_sequence    IN varchar2,
               X_Sched_Hold_count    IN OUT NOCOPY number); -- bug 5334577


  --Invoice Lines: Distributions
  procedure post_forms_commit
                (X_invoice_id                   IN            number,
	         X_line_number			IN	      number,
                 X_type_1099                    IN            varchar2,
                 X_income_tax_region            IN            varchar2,
                 X_vendor_changed_flag          IN OUT NOCOPY varchar2,
                 X_update_base                  IN OUT NOCOPY varchar2,
                 X_reset_match_status           IN OUT NOCOPY varchar2,
                 X_update_occurred              IN OUT NOCOPY varchar2,
                 X_approval_status_lookup_code  IN OUT NOCOPY varchar2,
                 X_holds_count                  IN OUT NOCOPY number,
                 X_posting_flag                 IN OUT NOCOPY varchar2,
                 X_amount_paid                  IN OUT NOCOPY number,
                 X_highest_line_num             IN OUT NOCOPY number,
                 X_line_total                   IN OUT NOCOPY number,
                 X_actual_invoice_count         IN OUT NOCOPY number,
                 X_actual_invoice_total         IN OUT NOCOPY number,
                 X_calling_sequence             IN            varchar2,
                 X_sched_holds_count            IN OUT NOCOPY number);   -- bug 5334577

 PROCEDURE Select_Summary(
               X_Batch_ID         IN            NUMBER,
               X_Total            IN OUT NOCOPY NUMBER,
               X_Total_Rtot_DB    IN OUT NOCOPY NUMBER,
               X_Calling_Sequence IN            VARCHAR2);

END AP_INVOICES_POST_PROCESS_PKG;

/
