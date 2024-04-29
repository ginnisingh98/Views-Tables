--------------------------------------------------------
--  DDL for Package JAI_AR_VALIDATE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_VALIDATE_DATA_PKG" 
   /*  $Header: jai_ar_val_data.pls 120.1 2007/06/08 08:39:59 bgowrava ship $  */
AUTHID CURRENT_USER AS
   /*
   CREATED BY       : Bgowrava
   CREATED DATE     : 08-JUN-2007
   BUG              : 5484865
   PURPOSE          : package spec for datafix to fix data corruption issues in AR base tables.
   */

/* START, Added by Bgowrava for Bug#5484865 */
CURSOR cur_curr_precision(cp_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE)
  IS
  SELECT  NVL(minimum_accountable_unit,NVL(precision,2))
  FROM    fnd_currencies
  WHERE   currency_code IN
              (
              SELECT  Currency_code
              FROM    gl_sets_of_books
              WHERE   set_of_books_id = cp_set_of_books_id
              );
 /* END, Added by Bgowrava for Bug#5484865 */

  TYPE r_error_record IS RECORD
                        ( type_of_error       VARCHAR2(20),
                          error_description   VARCHAR2(200),
                          error_record_count  NUMBER DEFAULT 0,
                          enable              VARCHAR2(1) DEFAULT 'N');

  TYPE t_error_table IS TABLE of r_error_record INDEX BY BINARY_INTEGER;

  gn_bug_no   NUMBER:= -4703909;

  PROCEDURE pre_validation( p_customer_trx_id IN  ra_customer_trx_all.customer_trx_id%TYPE,
                            p_process_status  OUT NOCOPY  VARCHAR2,
                            p_process_message OUT NOCOPY  VARCHAR2);

  PROCEDURE post_validation(p_start_date          IN  DATE      DEFAULT NULL,
                            p_end_date            IN  DATE      DEFAULT NULL,
                            p_customer_trx_id     IN  NUMBER    DEFAULT NULL,
                            p_validate_first      IN  VARCHAR2  DEFAULT 'N',
                            p_validate_all        IN  VARCHAR2  DEFAULT 'N',
                            p_generate_log        IN  VARCHAR2  DEFAULT 'N',
                            p_generate_detail_log IN  VARCHAR2  DEFAULT 'N',
                            p_fix_data            IN  VARCHAR2  DEFAULT 'N',
                            p_commit              IN  VARCHAR2  DEFAULT 'N',
                            p_log_filename        IN  VARCHAR2  DEFAULT NULL,
                            p_debug               IN  VARCHAR2  DEFAULT 'N',
                            p_process_status      OUT NOCOPY VARCHAR2,
                            p_process_message     OUT NOCOPY VARCHAR2);

  PROCEDURE populate_error_table (p_error_table     OUT NOCOPY  jai_ar_validate_data_pkg.t_error_table,
                                  p_process_status  OUT NOCOPY  VARCHAR2,
                                  p_process_message OUT NOCOPY  VARCHAR2);

  PROCEDURE display_error_summary(p_error_table     IN  jai_ar_validate_data_pkg.t_error_table,
                                  p_total_count     IN  NUMBER,
                                  p_filename        IN  VARCHAR2,
                                  p_process_status  OUT NOCOPY  VARCHAR2,
                                  p_process_message OUT NOCOPY  VARCHAR2);

  PROCEDURE  calc_term_apportion_ratio( p_invoice_type              IN  ar_payment_schedules_all.class%TYPE,
                                        p_term_id                   IN  ar_payment_schedules_all.term_id%TYPE,
                                        p_terms_sequence_number     IN  ar_payment_schedules_all.terms_sequence_number%TYPE,
                                        p_apportion_ratio           OUT NOCOPY NUMBER,
                                        p_first_installment_code    OUT NOCOPY ra_terms.first_installment_code%TYPE,
                                        p_process_status            OUT NOCOPY VARCHAR2,
                                        p_process_message           OUT NOCOPY VARCHAR2
                                         );

  PROCEDURE rectify_ar_pay_sch(
                              p_customer_trx_id     IN  ar_payment_schedules_all.customer_trx_id%TYPE,
                              p_gl_rec_amount       IN  NUMBER DEFAULT NULL,
                              p_gl_tax_amount       IN  NUMBER DEFAULT NULL,
                              p_gl_freight_amount   IN  NUMBER DEFAULT NULL,
                              p_datafix_filename    IN  VARCHAR2,
                              p_process_status      OUT NOCOPY VARCHAR2,
                              p_process_message     OUT NOCOPY VARCHAR2);

  PROCEDURE rectify_ar_rec_appl(
                              p_customer_trx_id     IN  ar_payment_schedules_all.customer_trx_id%TYPE,
                              p_previous_trx_id     IN  ar_payment_schedules_all.customer_trx_id%TYPE,
                              p_arps_ado            IN  NUMBER DEFAULT NULL,
                              p_arps_to             IN  NUMBER DEFAULT NULL,
                              p_arps_fo             IN  NUMBER DEFAULT NULL,
                              p_datafix_filename    IN  VARCHAR2,
                              p_process_status      OUT NOCOPY VARCHAR2,
                              p_process_message     OUT NOCOPY VARCHAR2);


END jai_ar_validate_data_pkg;

/
