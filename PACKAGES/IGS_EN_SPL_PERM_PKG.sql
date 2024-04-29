--------------------------------------------------------
--  DDL for Package IGS_EN_SPL_PERM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPL_PERM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI53S.pls 115.4 2002/11/28 23:45:47 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_id               IN OUT NOCOPY NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type			IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_id               IN     NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type			IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_id               IN     NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type			IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_id               IN OUT NOCOPY NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type			IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_spl_perm_request_id               IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_spl_perm_request_id               IN     NUMBER      DEFAULT NULL,
    x_student_person_id                 IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_date_submission                   IN     DATE        DEFAULT NULL,
    x_audit_the_course                  IN     VARCHAR2    DEFAULT NULL,
    x_instructor_person_id              IN     NUMBER      DEFAULT NULL,
    x_approval_status                   IN     VARCHAR2    DEFAULT NULL,
    x_reason_for_request                IN     VARCHAR2    DEFAULT NULL,
    x_instructor_more_info              IN     VARCHAR2    DEFAULT NULL,
    x_instructor_deny_info              IN     VARCHAR2    DEFAULT NULL,
    x_student_more_info                 IN     VARCHAR2    DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_request_type			IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_spl_perm_pkg;

 

/
