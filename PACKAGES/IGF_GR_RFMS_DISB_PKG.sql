--------------------------------------------------------
--  DDL for Package IGF_GR_RFMS_DISB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_RFMS_DISB_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI06S.pls 115.10 2002/11/28 14:16:35 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmd_id                           IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_ed_use_flags                      IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rfmd_id                           IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rfmd_id                           IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_ed_use_flags                      IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmd_id                           IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_ed_use_flags                      IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rfmd_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_disb_ref_num                      IN     VARCHAR2,
    x_origination_id                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_gr_rfms_batch (
    x_rfmb_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_gr_rfms (
    x_origination_id                    IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rfmd_id                           IN     NUMBER      DEFAULT NULL,
    x_origination_id                    IN     VARCHAR2    DEFAULT NULL,
    x_disb_ref_num                      IN     VARCHAR2    DEFAULT NULL,
    x_disb_dt                           IN     DATE        DEFAULT NULL,
    x_disb_amt                          IN     NUMBER      DEFAULT NULL,
    x_db_cr_flag                        IN     VARCHAR2    DEFAULT NULL,
    x_disb_ack_act_status               IN     VARCHAR2    DEFAULT NULL,
    x_disb_status_dt                    IN     DATE        DEFAULT NULL,
    x_accpt_disb_dt                     IN     DATE        DEFAULT NULL,
    x_disb_accpt_amt                    IN     NUMBER      DEFAULT NULL,
    x_accpt_db_cr_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_disb_ytd_amt                      IN     NUMBER      DEFAULT NULL,
    x_pymt_prd_start_dt                 IN     DATE        DEFAULT NULL,
    x_accpt_pymt_prd_start_dt           IN     DATE        DEFAULT NULL,
    x_edit_code                         IN     VARCHAR2    DEFAULT NULL,
    x_rfmb_id                           IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_ed_use_flags                      IN     VARCHAR2    DEFAULT NULL
  );

END igf_gr_rfms_disb_pkg;

 

/
