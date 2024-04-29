--------------------------------------------------------
--  DDL for Package IGF_AP_APPL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_APPL_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI01S.pls 120.1 2005/08/09 07:42:37 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_question_id                       IN OUT NOCOPY NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_application_code                  IN    VARCHAR2,
    x_application_name                  IN    VARCHAR2,
    x_active_flag                       IN    VARCHAR2	DEFAULT NULL,
    x_answer_type_code                  IN    VARCHAR2,
    x_destination_txt                   IN    VARCHAR2	DEFAULT NULL,
    x_ld_cal_type                       IN    VARCHAR2	DEFAULT NULL,
    x_ld_sequence_number                IN    NUMBER	  DEFAULT NULL,
    x_all_terms_flag                    IN    VARCHAR2	DEFAULT NULL,
    x_override_exist_ant_data_flag      IN    VARCHAR2	DEFAULT NULL,
    x_required_flag                     IN    VARCHAR2	DEFAULT NULL,
    x_minimum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_maximum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_minimum_date                      IN    DATE	    DEFAULT NULL,
    x_maximium_date                     IN    DATE	    DEFAULT NULL,
    x_lookup_code                       IN    VARCHAR2	DEFAULT NULL,
    x_hint_txt                          IN    VARCHAR2  DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_question_id                       IN     NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_application_code                  IN    VARCHAR2,
    x_application_name                  IN    VARCHAR2,
    x_active_flag                       IN    VARCHAR2	DEFAULT NULL,
    x_answer_type_code                  IN    VARCHAR2,
    x_destination_txt                   IN    VARCHAR2	DEFAULT NULL,
    x_ld_cal_type                       IN    VARCHAR2	DEFAULT NULL,
    x_ld_sequence_number                IN    NUMBER	  DEFAULT NULL,
    x_all_terms_flag                    IN    VARCHAR2	DEFAULT NULL,
    x_override_exist_ant_data_flag      IN    VARCHAR2	DEFAULT NULL,
    x_required_flag                     IN    VARCHAR2	DEFAULT NULL,
    x_minimum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_maximum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_minimum_date                      IN    DATE	    DEFAULT NULL,
    x_maximium_date                     IN    DATE	    DEFAULT NULL,
    x_lookup_code                       IN    VARCHAR2	DEFAULT NULL,
    x_hint_txt                          IN    VARCHAR2  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_question_id                       IN     NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_application_code                  IN    VARCHAR2,
    x_application_name                  IN    VARCHAR2,
    x_active_flag                       IN    VARCHAR2	DEFAULT NULL,
    x_answer_type_code                  IN    VARCHAR2,
    x_destination_txt                   IN    VARCHAR2	DEFAULT NULL,
    x_ld_cal_type                       IN    VARCHAR2	DEFAULT NULL,
    x_ld_sequence_number                IN    NUMBER	  DEFAULT NULL,
    x_all_terms_flag                    IN    VARCHAR2	DEFAULT NULL,
    x_override_exist_ant_data_flag      IN    VARCHAR2	DEFAULT NULL,
    x_required_flag                     IN    VARCHAR2	DEFAULT NULL,
    x_minimum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_maximum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_minimum_date                      IN    DATE	    DEFAULT NULL,
    x_maximium_date                     IN    DATE	    DEFAULT NULL,
    x_lookup_code                       IN    VARCHAR2	DEFAULT NULL,
    x_hint_txt                          IN    VARCHAR2  DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_question_id                       IN OUT NOCOPY NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_application_code                  IN    VARCHAR2,
    x_application_name                  IN    VARCHAR2,
    x_active_flag                       IN    VARCHAR2	DEFAULT NULL,
    x_answer_type_code                  IN    VARCHAR2,
    x_destination_txt                   IN    VARCHAR2	DEFAULT NULL,
    x_ld_cal_type                       IN    VARCHAR2	DEFAULT NULL,
    x_ld_sequence_number                IN    NUMBER	  DEFAULT NULL,
    x_all_terms_flag                    IN    VARCHAR2	DEFAULT NULL,
    x_override_exist_ant_data_flag      IN    VARCHAR2	DEFAULT NULL,
    x_required_flag                     IN    VARCHAR2	DEFAULT NULL,
    x_minimum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_maximum_value_num                 IN    NUMBER	  DEFAULT NULL,
    x_minimum_date                      IN    DATE	    DEFAULT NULL,
    x_maximium_date                     IN    DATE	    DEFAULT NULL,
    x_lookup_code                       IN    VARCHAR2	DEFAULT NULL,
    x_hint_txt                          IN    VARCHAR2  DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_question_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  FUNCTION get_uk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_application_code                  IN     VARCHAR2,
    x_question                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_question_id                       IN     NUMBER      DEFAULT NULL,
    x_question                          IN     VARCHAR2    DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_application_code                  IN    VARCHAR2     DEFAULT NULL,
    x_application_name                  IN    VARCHAR2     DEFAULT NULL,
    x_active_flag                       IN    VARCHAR2     DEFAULT NULL,
    x_answer_type_code                  IN    VARCHAR2     DEFAULT NULL,
    x_destination_txt                   IN    VARCHAR2     DEFAULT NULL,
    x_ld_cal_type                       IN    VARCHAR2     DEFAULT NULL,
    x_ld_sequence_number                IN    NUMBER       DEFAULT NULL,
    x_all_terms_flag                    IN    VARCHAR2     DEFAULT NULL,
    x_override_exist_ant_data_flag      IN    VARCHAR2     DEFAULT NULL,
    x_required_flag                     IN    VARCHAR2     DEFAULT NULL,
    x_minimum_value_num                 IN    NUMBER       DEFAULT NULL,
    x_maximum_value_num                 IN    NUMBER       DEFAULT NULL,
    x_minimum_date                      IN    DATE         DEFAULT NULL,
    x_maximium_date                     IN    DATE         DEFAULT NULL,
    x_lookup_code                       IN    VARCHAR2     DEFAULT NULL,
    x_hint_txt                          IN    VARCHAR2     DEFAULT NULL
  );

END igf_ap_appl_setup_pkg;

 

/
