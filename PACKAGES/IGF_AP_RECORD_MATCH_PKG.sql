--------------------------------------------------------
--  DDL for Package IGF_AP_RECORD_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_RECORD_MATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI40S.pls 120.0 2005/06/02 15:49:00 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_arm_id                            IN OUT NOCOPY NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_arm_id                            IN     NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_arm_id                            IN     NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_arm_id                            IN OUT NOCOPY NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_arm_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation(
    x_match_code                        IN     VARCHAR2
    )RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_arm_id                            IN     NUMBER      DEFAULT NULL,
    x_ssn                               IN     NUMBER      DEFAULT NULL,
    x_given_name                        IN     NUMBER      DEFAULT NULL,
    x_surname                           IN     NUMBER      DEFAULT NULL,
    x_birth_dt                          IN     NUMBER      DEFAULT NULL,
    x_address                           IN     NUMBER      DEFAULT NULL,
    x_city                              IN     NUMBER      DEFAULT NULL,
    x_zip                               IN     NUMBER      DEFAULT NULL,
    x_min_score_auto_fa                 IN     NUMBER      DEFAULT NULL,
    x_min_score_rvw_fa                  IN     NUMBER      DEFAULT NULL,
    x_admn_term                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  );

END igf_ap_record_match_pkg;

 

/
