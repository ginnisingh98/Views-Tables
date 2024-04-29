--------------------------------------------------------
--  DDL for Package IGS_FI_WAIVER_PGMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_WAIVER_PGMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF6S.pls 120.0 2005/09/09 20:30:22 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  FUNCTION get_pk_for_validation (
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_waiver_name                       IN     VARCHAR2    DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_waiver_desc                       IN     VARCHAR2    DEFAULT NULL,
    x_waiver_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_credit_type_id                    IN     NUMBER      DEFAULT NULL,
    x_adjustment_fee_type               IN     VARCHAR2    DEFAULT NULL,
    x_target_fee_type                   IN     VARCHAR2    DEFAULT NULL,
    x_waiver_method_code                IN     VARCHAR2    DEFAULT NULL,
    x_waiver_mode_code                  IN     VARCHAR2    DEFAULT NULL,
    x_waiver_criteria_code              IN     VARCHAR2    DEFAULT NULL,
    x_waiver_percent_alloc              IN     NUMBER      DEFAULT NULL,
    x_rule_fee_type                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_waiver_pgms_pkg;

 

/
