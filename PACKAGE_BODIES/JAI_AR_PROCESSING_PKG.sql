--------------------------------------------------------
--  DDL for Package Body JAI_AR_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_PROCESSING_PKG" 
   /* $Header: jai_ar_prc.plb 120.0 2006/03/27 14:02:19 hjujjuru noship $  */
AS

  PROCEDURE process_batch(
                                ERRBUF                        OUT NOCOPY  VARCHAR2,
                                RETCODE                       OUT NOCOPY  VARCHAR2,
                                p_org_id                      IN          NUMBER,
                                p_all_orgs                    IN          VARCHAR2,
                                p_debug                       IN          VARCHAR2  DEFAULT NULL)
  IS
  BEGIN
    null ;
  END ;


  --This procedure deletes the data from ra_cust_trx_line_gl_dist_all, ra_customer_trx_lines_all
  --Also deletes the MRC data from ra_cust_trx_line_gl_dist
  PROCEDURE delete_trx_data(
                              p_customer_trx_id             IN          ra_customer_trx_all.customer_trx_id%TYPE,
                              p_link_to_cust_trx_line_id    IN          ra_customer_trx_lines_all.link_to_cust_trx_line_id%TYPE DEFAULT NULL,
                              p_process_status              OUT NOCOPY  VARCHAR2,
                              p_process_message             OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    null ;
  END ;


  --This procedure inserts the data into ra_customer_trx_lines_all
  PROCEDURE insert_trx_lines(
                              p_extended_amount             IN          ra_customer_trx_lines_all.extended_amount%TYPE,
                              p_taxable_amount              IN          ra_customer_trx_lines_all.taxable_amount%TYPE,
                              p_customer_trx_line_id        IN          ra_customer_trx_lines_all.customer_trx_line_id%TYPE,
                              p_last_update_date            IN          ra_customer_trx_lines_all.last_update_date%TYPE,
                              p_last_updated_by             IN          ra_customer_trx_lines_all.last_updated_by%TYPE,
                              p_creation_date               IN          ra_customer_trx_lines_all.creation_date%TYPE,
                              p_created_by                  IN          ra_customer_trx_lines_all.created_by%TYPE,
                              p_last_update_login           IN          ra_customer_trx_lines_all.last_update_login%TYPE,
                              p_customer_trx_id             IN          ra_customer_trx_lines_all.customer_trx_id%TYPE,
                              p_line_number                 IN          ra_customer_trx_lines_all.line_number%TYPE,
                              p_set_of_books_id             IN          ra_customer_trx_lines_all.set_of_books_id%TYPE,
                              p_link_to_cust_trx_line_id    IN          ra_customer_trx_lines_all.link_to_cust_trx_line_id%TYPE,
                              p_line_type                   IN          ra_customer_trx_lines_all.line_type%TYPE,
                              p_org_id                      IN          ra_customer_trx_lines_all.org_id%TYPE,
                              p_uom_code                    IN          ra_customer_trx_lines_all.uom_code%TYPE,
                              p_autotax                     IN          ra_customer_trx_lines_all.autotax%TYPE,
                              p_vat_tax_id                  IN          ra_customer_trx_lines_all.vat_tax_id%TYPE,
                              p_interface_line_context      IN          ra_customer_trx_lines_all.interface_line_context%TYPE DEFAULT NULL,
                              p_interface_line_attribute6   IN          ra_customer_trx_lines_all.interface_line_attribute6%TYPE DEFAULT NULL,
                              p_interface_line_attribute3   IN          ra_customer_trx_lines_all.interface_line_attribute3%TYPE DEFAULT NULL,
                              p_process_status              OUT NOCOPY VARCHAR2,
                              p_process_message             OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    null ;
  END ;


  --This procedure inserts the data into ra_cust_trx_line_gl_dist_all
  PROCEDURE insert_trx_line_gl_dist(
                              p_account_class               IN          ra_cust_trx_line_gl_dist_all.account_class%TYPE,
                              p_account_set_flag            IN          ra_cust_trx_line_gl_dist_all.account_set_flag%TYPE,
                              p_acctd_amount                IN          ra_cust_trx_line_gl_dist_all.acctd_amount%TYPE,
                              p_amount                      IN          ra_cust_trx_line_gl_dist_all.amount%TYPE,
                              p_code_combination_id         IN          ra_cust_trx_line_gl_dist_all.code_combination_id%TYPE,
                              p_cust_trx_line_gl_dist_id    IN          ra_cust_trx_line_gl_dist_all.cust_trx_line_gl_dist_id%TYPE,
                              p_cust_trx_line_salesrep_id   IN          ra_cust_trx_line_gl_dist_all.cust_trx_line_salesrep_id%TYPE,
                              p_customer_trx_id             IN          ra_cust_trx_line_gl_dist_all.customer_trx_id%TYPE,
                              p_customer_trx_line_id        IN          ra_cust_trx_line_gl_dist_all.customer_trx_line_id%TYPE,
                              p_gl_date                     IN          ra_cust_trx_line_gl_dist_all.gl_date%TYPE,
                              p_last_update_date            IN          ra_cust_trx_line_gl_dist_all.last_update_date%TYPE,
                              p_last_updated_by             IN          ra_cust_trx_line_gl_dist_all.last_updated_by%TYPE,
                              p_creation_date               IN          ra_cust_trx_line_gl_dist_all.creation_date%TYPE,
                              p_created_by                  IN          ra_cust_trx_line_gl_dist_all.created_by%TYPE,
                              p_last_update_login           IN          ra_cust_trx_line_gl_dist_all.last_update_login%TYPE,
                              p_org_id                      IN          ra_cust_trx_line_gl_dist_all.org_id%TYPE,
                              p_percent                     IN          ra_cust_trx_line_gl_dist_all.percent%TYPE,
                              p_posting_control_id          IN          ra_cust_trx_line_gl_dist_all.posting_control_id%TYPE,
                              p_set_of_books_id             IN          ra_cust_trx_line_gl_dist_all.set_of_books_id%TYPE,
                              p_process_status              OUT NOCOPY  VARCHAR2,
                              p_process_message             OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    null ;
  END ;


  --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
  PROCEDURE maintain_schedules(
                              p_customer_trx_id             IN          ra_customer_trx_all.customer_trx_id%TYPE,
                              p_payment_schedule_id         IN          ar_payment_schedules_all.payment_schedule_id%TYPE DEFAULT NULL,
                              p_cm_customer_trx_id          IN          ra_customer_trx_all.customer_trx_id%TYPE DEFAULT NULL,
                              p_invoice_customer_trx_id     IN          ra_customer_trx_all.customer_trx_id%TYPE,
                              p_concurrent_req_num          IN          NUMBER,
                              p_request_id                  IN          NUMBER,
                              p_operation_type              IN          VARCHAR2,
                                p_payment_audit_id          IN OUT NOCOPY NUMBER, -- jai_ar_payment_audits.payment_audit_id%TYPE, -- Harshita for Bug
                              p_process_status              OUT NOCOPY  VARCHAR2,
                              p_process_message             OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    null ;
  END ;

  --This procedure maintains the history of ar_receivable_applications_all in jai_ar_rec_appl_audits
  PROCEDURE maintain_applications(
                              p_customer_trx_id             IN          ra_customer_trx_all.customer_trx_id%TYPE,
                              p_receivable_application_id   IN          jai_ar_rec_appl_audits.receivable_application_id%TYPE,
                              p_concurrent_req_num          IN          NUMBER,
                              p_request_id                  IN          NUMBER,
                              p_operation_type              IN          VARCHAR2,
                              p_rec_appl_audit_id           IN OUT NOCOPY NUMBER,
                              p_process_status              OUT NOCOPY  VARCHAR2,
                              p_process_message             OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    null ;
  END ;

  --This procedure updates the MRC data for ra_cust_trx_line_gl_dist_all, ar_payment_schedules_all, ar_receivable_applications_all
  /* This may be obsolete in R12. We want to retain this procedure
     to avoid spec. change in future.
   */
  PROCEDURE maintain_mrc(
                              p_customer_trx_id             IN          ra_customer_trx_all.customer_trx_id%TYPE,
                              p_previous_cust_trx_id        IN          ra_customer_trx_all.customer_trx_id%TYPE DEFAULT NULL,
                              p_called_from                 IN          VARCHAR2,
                              p_process_status              OUT NOCOPY  VARCHAR2,
                              p_process_message             OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    null ;
  END ;

  --This procedure do the processing for imported invoice
  PROCEDURE process_imported_invoice(
                              p_customer_trx_id             IN          NUMBER,
                              p_debug                       IN          VARCHAR2 DEFAULT NULL,
                              p_process_status              OUT NOCOPY  VARCHAR2,
                              p_process_message             OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    null ;
  END ;

  --This procedure do the processing for manual invoice
  --This is being called from concurrent - "AR Tax and Freight Defaultation"
  PROCEDURE process_manual_invoice(
                              errbuf                        OUT NOCOPY  VARCHAR2,
                              retcode                       OUT NOCOPY  VARCHAR2,
                              p_customer_trx_id             IN          NUMBER,
                              p_link_line_id                IN          NUMBER)
  IS
  BEGIN
    null ;
  END ;

END jai_ar_processing_pkg;

/
