--------------------------------------------------------
--  DDL for Package IGF_DB_AWD_DISB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_AWD_DISB_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFDI01S.pls 120.1 2006/06/06 07:30:58 akomurav noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			IN     NUMBER,
    x_spnsr_charge_id			IN     NUMBER,
    x_sf_credit_id				IN     NUMBER,
    x_error_desc			IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_notification_date                 IN     DATE        DEFAULT NULL,
    x_interest_rebate_amt               IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			IN     NUMBER,
    x_spnsr_charge_id			IN     NUMBER,
    x_sf_credit_id				IN     NUMBER,
    x_error_desc			IN     VARCHAR2,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt               IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id		     IN     NUMBER,
    x_spnsr_charge_id		     IN     NUMBER,
    x_sf_credit_id			     IN     NUMBER,
    x_error_desc			     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_notification_date                 IN     DATE        DEFAULT NULL,
    x_interest_rebate_amt               IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			IN     NUMBER,
    x_spnsr_charge_id			IN     NUMBER,
    x_sf_credit_id				IN     NUMBER,
    x_error_desc			IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_notification_date                 IN     DATE        DEFAULT NULL,
    x_interest_rebate_amt               IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_adj_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_disb_activity                     IN     VARCHAR2    DEFAULT NULL,
    x_disb_batch_id                     IN     VARCHAR2    DEFAULT NULL,
    x_disb_ack_date                     IN     DATE        DEFAULT NULL,
    x_booking_batch_id                  IN     VARCHAR2    DEFAULT NULL,
    x_booked_date                       IN     DATE        DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_disb_status_date                  IN     DATE        DEFAULT NULL,
    x_sf_status                         IN     VARCHAR2    DEFAULT NULL,
    x_sf_status_date                    IN     DATE        DEFAULT NULL,
    x_sf_invoice_num                    IN     NUMBER      DEFAULT NULL,
    x_spnsr_credit_id		     IN     NUMBER      DEFAULT NULL,
    x_spnsr_charge_id		     IN     NUMBER      DEFAULT NULL,
    x_sf_credit_id			     IN     NUMBER      DEFAULT NULL,
    x_error_desc			     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL ,
    x_notification_date                 IN     DATE        DEFAULT NULL,
    x_interest_rebate_amt               IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL
  );

END igf_db_awd_disb_dtl_pkg;

 

/
