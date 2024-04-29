--------------------------------------------------------
--  DDL for Package IGF_AW_FISAP_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FISAP_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI74S.pls 120.0 2005/09/13 09:52:53 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fisap_dtls_id                     IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fisap_dtls_id                     IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fisap_dtls_id                     IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fisap_dtls_id                     IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fisap_dtls_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_fisap_batch (
    x_batch_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fisap_dtls_id                     IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_isir_id                           IN     NUMBER      DEFAULT NULL,
    x_dependency_status                 IN     VARCHAR2    DEFAULT NULL,
    x_career_level                      IN     VARCHAR2    DEFAULT NULL,
    x_auto_zero_efc_flag                IN     VARCHAR2    DEFAULT NULL,
    x_fisap_income_amt                  IN     NUMBER      DEFAULT NULL,
    x_enrollment_status                 IN     VARCHAR2    DEFAULT NULL,
    x_perkins_disb_amt                  IN     NUMBER      DEFAULT NULL,
    x_fws_disb_amt                      IN     NUMBER      DEFAULT NULL,
    x_fseog_disb_amt                    IN     NUMBER      DEFAULT NULL,
    x_part_ii_section_f_flag            IN     VARCHAR2    DEFAULT NULL,
    x_part_vi_section_a_flag            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_fisap_rep_pkg;

 

/
