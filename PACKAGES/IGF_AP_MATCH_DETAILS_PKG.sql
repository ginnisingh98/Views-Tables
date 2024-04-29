--------------------------------------------------------
--  DDL for Package IGF_AP_MATCH_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_MATCH_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI38S.pls 120.0 2005/06/01 15:27:54 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_amd_id                            IN OUT NOCOPY NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_ssn_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_given_name_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_sur_name_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_address_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_city_txt                          IN     VARCHAR2    DEFAULT NULL,
    x_zip_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_gender_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_email_id_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_email_id_match                    IN     NUMBER      DEFAULT NULL,
    x_gender_match                      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_amd_id                            IN     NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_ssn_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_given_name_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_sur_name_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_address_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_city_txt                          IN     VARCHAR2    DEFAULT NULL,
    x_zip_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_gender_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_email_id_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_email_id_match                    IN     NUMBER      DEFAULT NULL,
    x_gender_match                      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_amd_id                            IN     NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_ssn_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_given_name_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_sur_name_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_address_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_city_txt                          IN     VARCHAR2    DEFAULT NULL,
    x_zip_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_gender_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_email_id_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_email_id_match                    IN     NUMBER      DEFAULT NULL,
    x_gender_match                      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_amd_id                            IN OUT NOCOPY NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_ssn_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_given_name_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_sur_name_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_address_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_city_txt                          IN     VARCHAR2    DEFAULT NULL,
    x_zip_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_gender_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_email_id_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_email_id_match                    IN     NUMBER      DEFAULT NULL,
    x_gender_match                      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_amd_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_person_match_all (
    x_apm_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_amd_id                            IN     NUMBER      DEFAULT NULL,
    x_apm_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_ssn_match                         IN     NUMBER      DEFAULT NULL,
    x_given_name_match                  IN     NUMBER      DEFAULT NULL,
    x_surname_match                     IN     NUMBER      DEFAULT NULL,
    x_dob_match                         IN     NUMBER      DEFAULT NULL,
    x_address_match                     IN     NUMBER      DEFAULT NULL,
    x_city_match                        IN     NUMBER      DEFAULT NULL,
    x_zip_match                         IN     NUMBER      DEFAULT NULL,
    x_match_score                       IN     NUMBER      DEFAULT NULL,
    x_record_status                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_ssn_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_given_name_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_sur_name_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_address_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_city_txt                          IN     VARCHAR2    DEFAULT NULL,
    x_zip_txt                           IN     VARCHAR2    DEFAULT NULL,
    x_gender_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_email_id_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_email_id_match                    IN     NUMBER      DEFAULT NULL,
    x_gender_match                      IN     NUMBER      DEFAULT NULL
  );

END igf_ap_match_details_pkg;

 

/
