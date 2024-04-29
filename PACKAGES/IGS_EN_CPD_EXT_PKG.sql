--------------------------------------------------------
--  DDL for Package IGS_EN_CPD_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_CPD_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI50S.pls 115.4 2002/11/28 23:44:51 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_cpd_ext_id                 IN OUT NOCOPY NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_STUD_AUDIT_LIM                    IN     NUMBER DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_cpd_ext_id                 IN     NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_STUD_AUDIT_LIM                    IN     NUMBER DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_cpd_ext_id                 IN     NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_STUD_AUDIT_LIM                    IN     NUMBER DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_cpd_ext_id                 IN OUT NOCOPY NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_STUD_AUDIT_LIM                    IN     NUMBER DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_en_cpd_ext_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_enrolment_cat (
    x_enrolment_cat                     IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_en_method_type (
    x_enr_method_type                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ru_call (
    x_s_rule_call_cd                    IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ru_rule (
    x_sequence_number                   IN     NUMBER
  );


  PROCEDURE get_fk_igs_lookups_view_1 (
    x_s_student_comm_type               IN     VARCHAR2
  );
  PROCEDURE get_fk_igs_lookups_view_2 (
    x_s_enrolment_step_type             IN     VARCHAR2
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_cpd_ext_id                 IN     NUMBER      DEFAULT NULL,
    x_enrolment_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_enr_method_type                   IN     VARCHAR2    DEFAULT NULL,
    x_s_student_comm_type               IN     VARCHAR2    DEFAULT NULL,
    x_step_order_num                    IN     NUMBER      DEFAULT NULL,
    x_s_enrolment_step_type             IN     VARCHAR2    DEFAULT NULL,
    x_notification_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_STUD_AUDIT_LIM                    IN     NUMBER      DEFAULT NULL
  );

END igs_en_cpd_ext_pkg;

 

/
