--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_015
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_015" AUTHID CURRENT_USER AS
/* $Header: IGSADC4S.pls 115.2 2003/10/01 08:18:17 nsinha noship $ */
/******************************************************************
Created By: Navin Sinha
Date Created By: 07-Oct-2002
Purpose: New Package to Insert record in the table IGS_AD_APP_REQ
         (Application Fee )  whenever an Enrollment Deposit is
	 Recorded in the Student Finance .
Known limitations,enhancements,remarks:
Change History
Who        When          What
Navin Sinha 10/1/2003    BUG NO : 3160036 : OSSTST15: enrollment deposit fee error in sf gl interface process
                         Added New procedure to updare record in the table IGS_AD_APP_REQ.
******************************************************************/
g_chk_ad_app_req	VARCHAR2(1);               -- This variable is called from the igs_ad_app_req_pkg (bug#2901627 -- rghosh)

PROCEDURE Create_Enrollment_Deposit(
  p_person_id			IN 	NUMBER,
  p_admission_appl_number	IN	NUMBER,
  p_enrollment_deposit_amount	IN	NUMBER,
  p_payment_date		IN 	DATE,
  p_fee_payment_method		IN	VARCHAR2,
  p_reference_number		IN	VARCHAR2 );

 PROCEDURE update_igs_ad_app_req (
       p_rowid                          IN VARCHAR2,
       p_app_req_id                     IN NUMBER,
       p_person_id                      IN NUMBER,
       p_admission_appl_number          IN NUMBER,
       p_applicant_fee_type             IN NUMBER,
       p_applicant_fee_status           IN NUMBER,
       p_fee_date                       IN DATE,
       p_fee_payment_method             IN NUMBER,
       p_fee_amount                     IN NUMBER,
       p_reference_num                  IN VARCHAR2 DEFAULT NULL,
       p_credit_card_code               IN VARCHAR2 DEFAULT NULL,
       p_credit_card_holder_name        IN VARCHAR2 DEFAULT NULL,
       p_credit_card_number             IN VARCHAR2 DEFAULT NULL,
       p_credit_card_expiration_date    IN DATE DEFAULT NULL,
       p_rev_gl_ccid                    IN NUMBER DEFAULT NULL,
       p_cash_gl_ccid                   IN NUMBER DEFAULT NULL,
       p_rev_account_cd                 IN VARCHAR2 DEFAULT NULL,
       p_cash_account_cd                IN VARCHAR2 DEFAULT NULL,
       p_posting_control_id             IN NUMBER DEFAULT NULL,
       p_gl_date                        IN DATE DEFAULT NULL,
       p_gl_posted_date                 IN DATE DEFAULT NULL,
       p_credit_card_tangible_cd        IN VARCHAR2 DEFAULT NULL,
       p_credit_card_payee_cd           IN VARCHAR2 DEFAULT NULL,
       p_credit_card_status_code        IN VARCHAR2 DEFAULT NULL,
       p_mode                           IN VARCHAR2
  );


END IGS_AD_GEN_015;

 

/
