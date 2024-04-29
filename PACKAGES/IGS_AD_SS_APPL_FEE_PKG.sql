--------------------------------------------------------
--  DDL for Package IGS_AD_SS_APPL_FEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SS_APPL_FEE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADB7S.pls 115.8 2003/06/17 09:05:24 pathipat noship $ */

PROCEDURE check_offer_update(
         p_person_id IN NUMBER,
	 p_admission_application_number IN NUMBER,
	 p_nominated_course_cd IN VARCHAR2,
	 p_sequence_number IN NUMBER,
	 x_return_status OUT NOCOPY VARCHAR2,
	 x_msg_count OUT NOCOPY NUMBER,
	 x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE check_offer_resp_update(
         p_person_id IN NUMBER,
	 p_admission_application_number IN NUMBER,
	 p_nominated_course_cd IN VARCHAR2,
	 p_sequence_number IN NUMBER,
	 x_return_status OUT NOCOPY VARCHAR2,
	 x_msg_count OUT NOCOPY NUMBER,
	 x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE check_update_aeps_acs(
         p_person_id  IN NUMBER,
         p_admission_application_number  IN NUMBER,
         p_nominated_course_cd    IN VARCHAR2,
         p_sequence_number        IN NUMBER,
         x_return_status          OUT NOCOPY VARCHAR2,
         x_msg_count              OUT NOCOPY NUMBER,
         x_msg_data               OUT NOCOPY VARCHAR2);

PROCEDURE get_appl_type_fee_details(
         p_person_id             IN NUMBER,
         p_admission_appl_number IN NUMBER,
         appl_fee_amt            OUT NOCOPY NUMBER,
         revenue_acct_code       OUT NOCOPY VARCHAR2,
         cash_acct_code          OUT NOCOPY VARCHAR2,
         revenue_acct_ccid       OUT NOCOPY NUMBER,
         cash_acct_ccid          OUT NOCOPY NUMBER,
         x_return_status         OUT NOCOPY VARCHAR2,
         x_msg_count             OUT NOCOPY NUMBER,
         x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE upd_fee_details(
         p_person_id                        IN NUMBER,
         p_admission_appl_number            IN NUMBER,
         p_app_fee_amt                      IN NUMBER,
         p_authorization_number             IN VARCHAR2,
         p_sys_fee_status                   IN VARCHAR2,
         p_sys_fee_type                     IN VARCHAR2,
         p_sys_fee_method                   IN VARCHAR2,
         x_return_status                    OUT NOCOPY VARCHAR2,
         x_msg_count                        OUT NOCOPY NUMBER,
         x_msg_data                         OUT NOCOPY VARCHAR2,
         p_credit_card_code                 IN VARCHAR2,
         p_credit_card_holder_name          IN VARCHAR2,
         p_credit_card_number               IN VARCHAR2,
         p_credit_card_expiration_date      IN DATE,
         p_gl_date                          IN DATE,
         p_rev_gl_ccid                      IN NUMBER,
         p_cash_gl_ccid                     IN NUMBER,
         p_rev_account_cd                   IN VARCHAR2,
         p_cash_account_cd                  IN VARCHAR2,
         p_credit_card_tangible_cd          IN VARCHAR2
         );

END igs_ad_ss_appl_fee_pkg;

 

/
