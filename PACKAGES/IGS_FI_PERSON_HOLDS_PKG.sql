--------------------------------------------------------
--  DDL for Package IGS_FI_PERSON_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PERSON_HOLDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIB2S.pls 115.12 2003/09/19 12:25:41 smadathi ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_hold_plan (
    x_hold_plan_name                    IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_fi_encmb_type (
    x_encumbrance_type                  IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_hold_plan_name                    IN     VARCHAR2    DEFAULT NULL,
    x_hold_type                         IN     VARCHAR2    DEFAULT NULL,
    x_hold_start_dt                     IN     DATE        DEFAULT NULL,
    x_process_start_dt                  IN     DATE        DEFAULT NULL,
    x_process_end_dt                    IN     DATE        DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_past_due_amount                   IN     NUMBER      DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_fee_type_invoice_amount           IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_release_credit_id                 IN     NUMBER      DEFAULT NULL,
    x_student_plan_id                   IN     NUMBER      DEFAULT NULL,
    x_last_instlmnt_due_date            IN     DATE        DEFAULT NULL
  );

  PROCEDURE get_fk_igs_fi_credits_all (
    x_release_credit_id                 IN     NUMBER
  );


END igs_fi_person_holds_pkg;

 

/
