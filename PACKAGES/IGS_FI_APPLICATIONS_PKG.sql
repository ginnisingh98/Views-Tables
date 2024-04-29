--------------------------------------------------------
--  DDL for Package IGS_FI_APPLICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_APPLICATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI94S.pls 115.8 2003/02/17 08:45:06 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_application_id                    IN OUT NOCOPY NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_application_id                    IN OUT NOCOPY NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_application_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_credits_all (
    x_credit_id                         IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_cr_activities (
    x_credit_activity_id                IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_posting_int_all (
    x_posting_id                        IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_a_hierarchies (
    x_appl_hierarchy_id                 IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_inv_int_all (
    x_invoice_id                        IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_invln_int_all (
    x_invoice_lines_id                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_application_id                    IN     NUMBER      DEFAULT NULL,
    x_application_type                  IN     VARCHAR2    DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_credit_id                         IN     NUMBER      DEFAULT NULL,
    x_credit_activity_id                IN     NUMBER      DEFAULT NULL,
    x_amount_applied                    IN     NUMBER      DEFAULT NULL,
    x_apply_date                        IN     DATE        DEFAULT NULL,
    x_link_application_id               IN     NUMBER      DEFAULT NULL,
    x_dr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_cr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_dr_gl_code_ccid                   IN     NUMBER      DEFAULT NULL,
    x_cr_gl_code_ccid                   IN     NUMBER      DEFAULT NULL,
    x_applied_invoice_lines_id          IN     NUMBER      DEFAULT NULL,
    x_appl_hierarchy_id                 IN     NUMBER      DEFAULT NULL,
    x_posting_id                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

END igs_fi_applications_pkg;

 

/
