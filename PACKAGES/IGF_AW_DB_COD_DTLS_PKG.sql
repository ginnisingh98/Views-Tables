--------------------------------------------------------
--  DDL for Package IGF_AW_DB_COD_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_DB_COD_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI65S.pls 120.0 2005/06/01 12:58:31 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER ,
    x_disb_seq_num                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_document_id_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
    x_disb_accepted_amt                 IN     NUMBER      DEFAULT NULL,
    x_orig_fee_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_disb_rel_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_first_disb_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_interest_rebate_amt               IN     NUMBER      DEFAULT NULL,
    x_disb_conf_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_pymnt_per_start_date              IN     DATE        DEFAULT NULL,
    x_note_message                      IN     VARCHAR2    DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_db_cod_dtls_pkg;

 

/
