--------------------------------------------------------
--  DDL for Package IGS_AD_SS_APPL_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SS_APPL_TYP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF8S.pls 120.1 2005/07/27 02:42:43 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_system_default                    IN     VARCHAR2    DEFAULT NULL,
    x_enroll_deposit_amount             IN     NUMBER      DEFAULT NULL,
    x_enroll_deposit_level              IN     VARCHAR2    DEFAULT NULL,
    x_use_in_appl_self_srvc             IN     VARCHAR2    DEFAULT NULL,
    x_crt_rev_instr                     IN     VARCHAR2    DEFAULT NULL,
    x_submit_instr                      IN     VARCHAR2    DEFAULT NULL,
    x_submit_err_instr                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_system_default                    IN     VARCHAR2    DEFAULT NULL,
    x_enroll_deposit_amount             IN     NUMBER      DEFAULT NULL,
    x_enroll_deposit_level              IN     VARCHAR2    DEFAULT NULL,
    x_use_in_appl_self_srvc             IN     VARCHAR2    DEFAULT NULL,
    x_crt_rev_instr                     IN     VARCHAR2    DEFAULT NULL,
    x_submit_instr                      IN     VARCHAR2    DEFAULT NULL,
    x_submit_err_instr                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_system_default                    IN     VARCHAR2    DEFAULT NULL,
    x_enroll_deposit_amount             IN     NUMBER      DEFAULT NULL,
    x_enroll_deposit_level              IN     VARCHAR2    DEFAULT NULL,
    x_use_in_appl_self_srvc             IN     VARCHAR2    DEFAULT NULL,
    x_crt_rev_instr                     IN     VARCHAR2    DEFAULT NULL,
    x_submit_instr                      IN     VARCHAR2    DEFAULT NULL,
    x_submit_err_instr                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_system_default                    IN     VARCHAR2    DEFAULT NULL,
    x_enroll_deposit_amount             IN     NUMBER      DEFAULT NULL,
    x_enroll_deposit_level              IN     VARCHAR2    DEFAULT NULL,
    x_use_in_appl_self_srvc             IN     VARCHAR2    DEFAULT NULL,
    x_crt_rev_instr                     IN     VARCHAR2    DEFAULT NULL,
    x_submit_instr                      IN     VARCHAR2    DEFAULT NULL,
    x_submit_err_instr                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_admission_application_type               IN     VARCHAR2 ,
    x_closed_ind                               IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  Procedure Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);


  PROCEDURE get_fk_igs_ad_prcs_cat (
      x_admission_cat            IN VARCHAR2,
      x_s_admission_process_type IN VARCHAR2
      );



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_s_admission_process_type          IN     VARCHAR2    DEFAULT NULL,
    x_configurability_func_name         IN     VARCHAR2    DEFAULT NULL,
    x_application_fee_amount            IN     NUMBER      DEFAULT NULL,
    x_gl_rev_acct_ccid                  IN     NUMBER      DEFAULT NULL,
    x_gl_cash_acct_ccid                 IN     NUMBER      DEFAULT NULL,
    x_rev_account_code                  IN     VARCHAR2    DEFAULT NULL,
    x_cash_account_code                 IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_system_default                    IN     VARCHAR2    DEFAULT NULL,
    x_enroll_deposit_amount             IN     NUMBER      DEFAULT NULL,
    x_enroll_deposit_level              IN     VARCHAR2    DEFAULT NULL,
    x_use_in_appl_self_srvc             IN     VARCHAR2    DEFAULT NULL,
    x_crt_rev_instr                     IN     VARCHAR2    DEFAULT NULL,
    x_submit_instr                      IN     VARCHAR2    DEFAULT NULL,
    x_submit_err_instr                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE check_child_existance_apc (
    p_admission_application_type IN VARCHAR2,
    p_message_name OUT NOCOPY VARCHAR2) ;

END igs_ad_ss_appl_typ_pkg;

 

/
