--------------------------------------------------------
--  DDL for Package IGS_UC_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_DEFAULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI17S.pls 115.12 2003/12/04 11:48:00 rbezawad noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  DEFAULT 'R',
    x_decision_make_id                  IN     NUMBER    DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER    DEFAULT NULL,
    x_obsolete_outcome_status           IN     VARCHAR2  DEFAULT NULL,
    x_pending_outcome_status            IN     VARCHAR2  DEFAULT NULL,
    x_rejected_outcome_status           IN     VARCHAR2  DEFAULT NULL,
    x_system_code                       IN     VARCHAR2   DEFAULT NULL,
    x_ni_number_alt_pers_type           IN     VARCHAR2   DEFAULT NULL,
    x_application_type                  IN     VARCHAR2   DEFAULT NULL,
    x_name                              IN     VARCHAR2   DEFAULT NULL ,
    x_description                       IN     VARCHAR2   DEFAULT NULL,
    x_ucas_security_key                 IN     VARCHAR2   DEFAULT NULL,
    x_current_cycle                     IN     VARCHAR2   DEFAULT NULL,
    x_configured_cycle                  IN     VARCHAR2   DEFAULT NULL,
    x_prev_inst_left_date               IN     DATE       DEFAULT NULL
  );

  PROCEDURE get_fk_igs_ad_ou_stat( x_adm_outcome_status IN VARCHAR2);

  PROCEDURE get_fk_igs_ad_code_classes( x_code_id IN NUMBER  );

  PROCEDURE get_fk_igs_ad_ss_appl_typ (     x_application_type IN VARCHAR2   );

  FUNCTION get_pk_for_validation (     x_system_code         IN    VARCHAR2  ) RETURN BOOLEAN;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER   DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER   DEFAULT NULL,
    x_obsolete_outcome_status           IN     VARCHAR2 DEFAULT NULL,
    x_pending_outcome_status            IN     VARCHAR2 DEFAULT NULL,
    x_rejected_outcome_status           IN     VARCHAR2 DEFAULT NULL,
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ni_number_alt_pers_type           IN     VARCHAR2  DEFAULT NULL,
    x_application_type                  IN     VARCHAR2  DEFAULT NULL,
    x_name                              IN     VARCHAR2   DEFAULT NULL ,
    x_description                       IN     VARCHAR2   DEFAULT NULL,
    x_ucas_security_key                 IN     VARCHAR2   DEFAULT NULL,
    x_current_cycle                     IN     VARCHAR2   DEFAULT NULL,
    x_configured_cycle                  IN     VARCHAR2   DEFAULT NULL,
    x_prev_inst_left_date               IN     DATE       DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  DEFAULT 'R' ,
    x_decision_make_id                  IN     NUMBER    DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER    DEFAULT NULL,
    x_obsolete_outcome_status           IN     VARCHAR2  DEFAULT NULL,
    x_pending_outcome_status            IN     VARCHAR2  DEFAULT NULL,
    x_rejected_outcome_status           IN     VARCHAR2  DEFAULT NULL,
    x_system_code                       IN     VARCHAR2  DEFAULT NULL,
    x_ni_number_alt_pers_type           IN     VARCHAR2  DEFAULT NULL,
    x_application_type                  IN     VARCHAR2  DEFAULT NULL,
    x_name                              IN     VARCHAR2   DEFAULT NULL ,
    x_description                       IN     VARCHAR2   DEFAULT NULL,
    x_ucas_security_key                 IN     VARCHAR2   DEFAULT NULL,
    x_current_cycle                     IN     VARCHAR2   DEFAULT NULL,
    x_configured_cycle                  IN     VARCHAR2   DEFAULT NULL,
    x_prev_inst_left_date               IN     DATE       DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2   DEFAULT 'R',
    x_decision_make_id                  IN     NUMBER     DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER     DEFAULT NULL,
    x_obsolete_outcome_status           IN     VARCHAR2   DEFAULT NULL,
    x_pending_outcome_status            IN     VARCHAR2   DEFAULT NULL,
    x_rejected_outcome_status           IN     VARCHAR2   DEFAULT NULL,
    x_system_code                       IN     VARCHAR2   DEFAULT NULL,
    x_ni_number_alt_pers_type           IN     VARCHAR2   DEFAULT NULL,
    x_application_type                  IN     VARCHAR2   DEFAULT NULL,
    x_name                              IN     VARCHAR2   DEFAULT NULL ,
    x_description                       IN     VARCHAR2   DEFAULT NULL,
    x_ucas_security_key                 IN     VARCHAR2   DEFAULT NULL,
    x_current_cycle                     IN     VARCHAR2   DEFAULT NULL,
    x_configured_cycle                  IN     VARCHAR2   DEFAULT NULL,
    x_prev_inst_left_date               IN     DATE       DEFAULT NULL
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_current_inst_code                 IN     VARCHAR2    DEFAULT NULL,
    x_ucas_id_format                    IN     VARCHAR2    DEFAULT NULL,
    x_test_app_no                       IN     NUMBER      DEFAULT NULL,
    x_test_choice_no                    IN     NUMBER      DEFAULT NULL,
    x_test_transaction_type             IN     VARCHAR2    DEFAULT NULL,
    x_copy_ucas_id                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_obsolete_outcome_status           IN     VARCHAR2    DEFAULT NULL,
    x_pending_outcome_status            IN     VARCHAR2    DEFAULT NULL,
    x_rejected_outcome_status           IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_ni_number_alt_pers_type           IN     VARCHAR2    DEFAULT NULL,
    x_application_type                  IN     VARCHAR2    DEFAULT NULL,
    x_name                              IN     VARCHAR2   DEFAULT NULL ,
    x_description                       IN     VARCHAR2   DEFAULT NULL,
    x_ucas_security_key                 IN     VARCHAR2   DEFAULT NULL,
    x_current_cycle                     IN     VARCHAR2   DEFAULT NULL,
    x_configured_cycle                  IN     VARCHAR2   DEFAULT NULL,
    x_prev_inst_left_date               IN     DATE       DEFAULT NULL
  );

END igs_uc_defaults_pkg;

 

/
