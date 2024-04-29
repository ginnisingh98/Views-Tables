--------------------------------------------------------
--  DDL for Package IGF_DB_YTD_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_YTD_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFDI11S.pls 115.3 2003/02/26 03:52:22 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytdd_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_loan_bkd_dt                       IN     DATE,
    x_disb_bkd_dt                       IN     DATE,
    x_disb_gross                        IN     NUMBER,
    x_disb_fee                          IN     NUMBER,
    x_disb_int_rebate                   IN     NUMBER,
    x_disb_net                          IN     NUMBER,
    x_disb_net_adj                      IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_trans_type                        IN     VARCHAR2,
    x_trans_dt                          IN     DATE,
    x_total_gross                       IN     NUMBER,
    x_total_fee                         IN     NUMBER,
    x_total_int_rebate                  IN     NUMBER,
    x_total_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ytdd_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_loan_bkd_dt                       IN     DATE,
    x_disb_bkd_dt                       IN     DATE,
    x_disb_gross                        IN     NUMBER,
    x_disb_fee                          IN     NUMBER,
    x_disb_int_rebate                   IN     NUMBER,
    x_disb_net                          IN     NUMBER,
    x_disb_net_adj                      IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_trans_type                        IN     VARCHAR2,
    x_trans_dt                          IN     DATE,
    x_total_gross                       IN     NUMBER,
    x_total_fee                         IN     NUMBER,
    x_total_int_rebate                  IN     NUMBER,
    x_total_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ytdd_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_loan_bkd_dt                       IN     DATE,
    x_disb_bkd_dt                       IN     DATE,
    x_disb_gross                        IN     NUMBER,
    x_disb_fee                          IN     NUMBER,
    x_disb_int_rebate                   IN     NUMBER,
    x_disb_net                          IN     NUMBER,
    x_disb_net_adj                      IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_trans_type                        IN     VARCHAR2,
    x_trans_dt                          IN     DATE,
    x_total_gross                       IN     NUMBER,
    x_total_fee                         IN     NUMBER,
    x_total_int_rebate                  IN     NUMBER,
    x_total_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytdd_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_loan_bkd_dt                       IN     DATE,
    x_disb_bkd_dt                       IN     DATE,
    x_disb_gross                        IN     NUMBER,
    x_disb_fee                          IN     NUMBER,
    x_disb_int_rebate                   IN     NUMBER,
    x_disb_net                          IN     NUMBER,
    x_disb_net_adj                      IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_trans_type                        IN     VARCHAR2,
    x_trans_dt                          IN     DATE,
    x_total_gross                       IN     NUMBER,
    x_total_fee                         IN     NUMBER,
    x_total_int_rebate                  IN     NUMBER,
    x_total_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ytdd_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ytdd_id                           IN     NUMBER      DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_record_type                       IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_school_code                       IN     VARCHAR2    DEFAULT NULL,
    x_stat_end_dt                       IN     DATE        DEFAULT NULL,
    x_process_dt                        IN     DATE        DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_loan_bkd_dt                       IN     DATE        DEFAULT NULL,
    x_disb_bkd_dt                       IN     DATE        DEFAULT NULL,
    x_disb_gross                        IN     NUMBER      DEFAULT NULL,
    x_disb_fee                          IN     NUMBER      DEFAULT NULL,
    x_disb_int_rebate                   IN     NUMBER      DEFAULT NULL,
    x_disb_net                          IN     NUMBER      DEFAULT NULL,
    x_disb_net_adj                      IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
    x_trans_type                        IN     VARCHAR2    DEFAULT NULL,
    x_trans_dt                          IN     DATE        DEFAULT NULL,
    x_total_gross                       IN     NUMBER      DEFAULT NULL,
    x_total_fee                         IN     NUMBER      DEFAULT NULL,
    x_total_int_rebate                  IN     NUMBER      DEFAULT NULL,
    x_total_net                         IN     NUMBER      DEFAULT NULL,
    x_region_code                       IN     VARCHAR2    DEFAULT NULL,
    x_state_code                        IN     VARCHAR2    DEFAULT NULL,
    x_rec_count                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_db_ytd_dtl_pkg;

 

/
