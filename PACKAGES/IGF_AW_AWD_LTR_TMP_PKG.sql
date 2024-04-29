--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_LTR_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_LTR_TMP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI51S.pls 120.0 2005/06/01 12:56:10 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type     IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number    IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type     IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number    IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type     IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number    IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type     IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number    IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_line_id                            IN     NUMBER,
    x_person_id                          IN     NUMBER,
    x_ci_cal_type                        IN     VARCHAR2,
    x_ci_sequence_number                 IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_line_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type     IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number    IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_awd_ltr_tmp_pkg;

 

/
