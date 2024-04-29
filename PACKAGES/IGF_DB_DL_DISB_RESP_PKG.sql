--------------------------------------------------------
--  DDL for Package IGF_DB_DL_DISB_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_DL_DISB_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFDI03S.pls 115.5 2002/11/28 14:14:26 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ddrp_id                           IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ddrp_id                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ddrp_id                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ddrp_id                           IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ddrp_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_dl_batch (
    x_dbth_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ddrp_id                           IN     NUMBER      DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_activity                     IN     VARCHAR2    DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_int_rebate_amt                    IN     NUMBER      DEFAULT NULL,
    x_user_ident                        IN     VARCHAR2    DEFAULT NULL,
    x_disb_batch_id                     IN     VARCHAR2    DEFAULT NULL,
    x_school_id                         IN     VARCHAR2    DEFAULT NULL,
    x_sch_code_status                   IN     VARCHAR2    DEFAULT NULL,
    x_loan_num_status                   IN     VARCHAR2    DEFAULT NULL,
    x_disb_num_status                   IN     VARCHAR2    DEFAULT NULL,
    x_disb_activity_status              IN     VARCHAR2    DEFAULT NULL,
    x_trans_date_status                 IN     VARCHAR2    DEFAULT NULL,
    x_disb_seq_num_status               IN     VARCHAR2    DEFAULT NULL,
    x_loc_disb_gross_amt                IN     NUMBER      DEFAULT NULL,
    x_loc_fee_1                         IN     NUMBER      DEFAULT NULL,
    x_loc_disb_net_amt                  IN     NUMBER      DEFAULT NULL,
    x_servicer_refund_amt               IN     NUMBER      DEFAULT NULL,
    x_loc_int_rebate_amt                IN     NUMBER      DEFAULT NULL,
    x_loc_net_booked_loan               IN     NUMBER      DEFAULT NULL,
    x_ack_date                          IN     DATE        DEFAULT NULL,
    x_affirm_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_db_dl_disb_resp_pkg;

 

/
