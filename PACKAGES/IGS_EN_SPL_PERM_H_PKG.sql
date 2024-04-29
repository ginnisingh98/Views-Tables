--------------------------------------------------------
--  DDL for Package IGS_EN_SPL_PERM_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPL_PERM_H_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI54S.pls 115.3 2002/11/28 23:46:03 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_h_id             IN OUT NOCOPY NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_h_id             IN     NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_h_id             IN     NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_h_id             IN OUT NOCOPY NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_spl_perm_request_h_id             IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_spl_perm (
    x_spl_perm_request_id               IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_spl_perm_request_h_id             IN     NUMBER      DEFAULT NULL,
    x_spl_perm_request_id               IN     NUMBER      DEFAULT NULL,
    x_date_submission                   IN     DATE        DEFAULT NULL,
    x_audit_the_course                  IN     VARCHAR2    DEFAULT NULL,
    x_approval_status                   IN     VARCHAR2    DEFAULT NULL,
    x_reason_for_request                IN     VARCHAR2    DEFAULT NULL,
    x_instructor_more_info              IN     VARCHAR2    DEFAULT NULL,
    x_instructor_deny_info              IN     VARCHAR2    DEFAULT NULL,
    x_student_more_info                 IN     VARCHAR2    DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_hist_start_dt                     IN     DATE        DEFAULT NULL,
    x_hist_end_dt                       IN     DATE        DEFAULT NULL,
    x_hist_who                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_spl_perm_h_pkg;

 

/
