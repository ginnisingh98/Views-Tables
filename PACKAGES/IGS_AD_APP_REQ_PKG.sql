--------------------------------------------------------
--  DDL for Package IGS_AD_APP_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APP_REQ_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIA2S.pls 120.0 2005/06/01 21:01:20 appldev noship $ */

 g_pkg_cst_completed_chk	VARCHAR2(1);		--added this variable that will be populated with a value of 'N' . This variable will be called from the procedure
                                                                                                -- igs_ad_gen_002.check_adm_appl_inst_stat  -- rghosh (bug#2901627)

 PROCEDURE insert_row (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APP_REQ_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2 DEFAULT NULL,
       X_MODE                           IN  VARCHAR2 DEFAULT 'R'  ,
       x_credit_card_code		IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_holder_name        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_number             IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_expiration_date    IN  DATE     DEFAULT NULL,
       x_rev_gl_ccid                    IN  NUMBER   DEFAULT NULL,
       x_cash_gl_ccid                   IN  NUMBER   DEFAULT NULL,
       x_rev_account_cd                 IN  VARCHAR2 DEFAULT NULL,
       x_cash_account_cd                IN  VARCHAR2 DEFAULT NULL,
       x_gl_date                        IN  DATE     DEFAULT NULL,
       x_gl_posted_date                 IN  DATE     DEFAULT NULL,
       x_posting_control_id             IN  NUMBER   DEFAULT NULL,
       x_credit_card_tangible_cd        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_payee_cd           IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_status_code        IN  VARCHAR2 DEFAULT NULL
  );

 PROCEDURE lock_row (
      X_ROWID in  VARCHAR2,
       x_APP_REQ_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM                  IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_code		IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_holder_name        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_number             IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_expiration_date    IN  DATE     DEFAULT NULL,
       x_rev_gl_ccid                    IN  NUMBER   DEFAULT NULL,
       x_cash_gl_ccid                   IN  NUMBER   DEFAULT NULL,
       x_rev_account_cd                 IN  VARCHAR2 DEFAULT NULL,
       x_cash_account_cd                IN  VARCHAR2 DEFAULT NULL,
       x_gl_date                        IN  DATE     DEFAULT NULL,
       x_gl_posted_date                 IN  DATE     DEFAULT NULL,
       x_posting_control_id             IN  NUMBER   DEFAULT NULL,
       x_credit_card_tangible_cd        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_payee_cd           IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_status_code        IN  VARCHAR2 DEFAULT NULL
       );



 PROCEDURE update_row (
      X_ROWID in  VARCHAR2,
       x_APP_REQ_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2 DEFAULT NULL,
       X_MODE                           IN  VARCHAR2 DEFAULT 'R'  ,
       x_credit_card_code		IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_holder_name        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_number             IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_expiration_date    IN  DATE     DEFAULT NULL,
       x_rev_gl_ccid                    IN  NUMBER   DEFAULT NULL,
       x_cash_gl_ccid                   IN  NUMBER   DEFAULT NULL,
       x_rev_account_cd                 IN  VARCHAR2 DEFAULT NULL,
       x_cash_account_cd                IN  VARCHAR2 DEFAULT NULL,
       x_gl_date                        IN  DATE     DEFAULT NULL,
       x_gl_posted_date                 IN  DATE     DEFAULT NULL,
       x_posting_control_id             IN  NUMBER   DEFAULT NULL,
       x_credit_card_tangible_cd        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_payee_cd           IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_status_code        IN  VARCHAR2 DEFAULT NULL
  );

 PROCEDURE add_row (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APP_REQ_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2 DEFAULT NULL,
       X_MODE IN VARCHAR2 DEFAULT 'R'  ,
       x_credit_card_code		IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_holder_name        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_number             IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_expiration_date    IN  DATE     DEFAULT NULL,
       x_rev_gl_ccid                    IN  NUMBER   DEFAULT NULL,
       x_cash_gl_ccid                   IN  NUMBER   DEFAULT NULL,
       x_rev_account_cd                 IN  VARCHAR2 DEFAULT NULL,
       x_cash_account_cd                IN  VARCHAR2 DEFAULT NULL,
       x_gl_date                        IN  DATE     DEFAULT NULL,
       x_gl_posted_date                 IN  DATE     DEFAULT NULL,
       x_posting_control_id             IN  NUMBER   DEFAULT NULL,
       x_credit_card_tangible_cd        IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_payee_cd           IN  VARCHAR2 DEFAULT NULL,
       x_credit_card_status_code        IN  VARCHAR2 DEFAULT NULL
  ) ;

PROCEDURE delete_row (
  X_ROWID IN VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION get_pk_for_validation (
    x_app_req_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Appl (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    );


  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_app_req_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_applicant_fee_type IN NUMBER DEFAULT NULL,
    x_applicant_fee_status IN NUMBER DEFAULT NULL,
    x_fee_date IN DATE DEFAULT NULL,
    x_fee_payment_method IN NUMBER DEFAULT NULL,
    x_fee_amount IN NUMBER DEFAULT NULL,
    x_reference_num IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_credit_card_code		     IN  VARCHAR2 DEFAULT NULL,
    x_credit_card_holder_name        IN  VARCHAR2 DEFAULT NULL,
    x_credit_card_number             IN  VARCHAR2 DEFAULT NULL,
    x_credit_card_expiration_date    IN  DATE     DEFAULT NULL,
    x_rev_gl_ccid                    IN  NUMBER   DEFAULT NULL,
    x_cash_gl_ccid                   IN  NUMBER   DEFAULT NULL,
    x_rev_account_cd                 IN  VARCHAR2 DEFAULT NULL,
    x_cash_account_cd                IN  VARCHAR2 DEFAULT NULL,
    x_gl_date                        IN  DATE     DEFAULT NULL,
    x_gl_posted_date                 IN  DATE     DEFAULT NULL,
    x_posting_control_id             IN  NUMBER   DEFAULT NULL,
    x_credit_card_tangible_cd        IN  VARCHAR2 DEFAULT NULL,
    x_credit_card_payee_cd           IN  VARCHAR2 DEFAULT NULL,
    x_credit_card_status_code        IN  VARCHAR2 DEFAULT NULL
 );

END igs_ad_app_req_pkg;

 

/
