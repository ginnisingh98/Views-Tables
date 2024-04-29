--------------------------------------------------------
--  DDL for Package IGS_FI_CRDAPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CRDAPI_UTIL" AUTHID CURRENT_USER AS
/* $Header: IGSFI84S.pls 120.2 2005/11/22 22:00:39 appldev ship $ */
/***********************************************************************************************

  Created By     :  shtatiko
  Date Created By:  01-APR-2003 (Created as part of Enh# 2831554, Internal Credits API)
  Purpose        :  This is a new package for centralizing all parameter validations that needs
                    to be done a new credit or deposit transaction is created in the system.


  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  sapanigr   22-Nov-2005   Bug#4675424.Added function val_cal_inst
  vvutukur   13-Sep-2003   Enh#3045007.Payment Plans Build. Added procedures apply_installments,validate_plan_balance.
  vvutukur   14-Jul-2003   Enh#3038511.FICR106 Build. Added procedure get_award_year_status.
  vvutukur   18-Jun-2003   Enh#2831582.Lockbox Build. Removed function validate_lockbox.
  schodava   11-Jun-03     Enh # 2831587. Credit Card Fund Transfer. Added new functions:
                           validate_credit_card_payee
***********************************************************************************************/

/*
 * Procedure VALIDATE_PARAMETERS is the main procedure which has calls to
 * individual procedures or functions. When this procedure is invoked with FULL
 * validation level then all parameter validations will take place.
 */
PROCEDURE validate_parameters (
            p_n_validation_level IN NUMBER DEFAULT fnd_api.g_valid_level_full,
            p_credit_rec IN igs_fi_credit_pvt.credit_rec_type,
            p_attribute_rec IN igs_fi_credits_api_pub.attribute_rec_type,
            p_b_return_status OUT NOCOPY BOOLEAN
);

-- This function checks if transaction status is valid
FUNCTION validate_credit_status ( p_v_crd_status IN VARCHAR2 ) RETURN BOOLEAN;

-- This procedure validates a credit type is active and effective as on the current system.
PROCEDURE validate_credit_type (
            p_n_credit_type_id IN PLS_INTEGER,
            p_v_credit_class OUT NOCOPY VARCHAR2,
            p_b_return_stat OUT NOCOPY BOOLEAN
);

-- This function checks if the IGS lookup code is valid for the lookup type.
FUNCTION validate_igs_lkp (
           p_v_lookup_type IN VARCHAR2,
           p_v_lookup_code IN VARCHAR2
) RETURN BOOLEAN;

-- This function checks if the IGF lookup code is valid for the lookup type.
FUNCTION validate_igf_lkp (
           p_v_lookup_type IN VARCHAR2,
           p_v_lookup_code IN VARCHAR2
) RETURN BOOLEAN;

-- This function checks if the currency code is active in the system.
FUNCTION validate_curr ( p_v_currency_cd IN VARCHAR2 ) RETURN BOOLEAN;

-- This function checks if the Calendar Instance is active in the system.
FUNCTION validate_cal_inst (
           p_v_cal_type IN VARCHAR2,
           p_n_ci_sequence_number IN PLS_INTEGER,
           p_v_s_cal_cat IN VARCHAR2
) RETURN BOOLEAN;

-- This function is similar to validate_cal_inst but returns VARCHAR TRUE or FALSE
FUNCTION val_cal_inst (
           p_v_cal_type IN VARCHAR2,
           p_n_ci_sequence_number IN NUMBER,
           p_v_s_cal_cat IN VARCHAR2
) RETURN VARCHAR2;

-- This procedure checks if there exists a relation between Fee and Load calendar instance
-- and checks if the Load Calendar Instance is active in the system.
PROCEDURE validate_fci_lci_reln (
            p_v_fee_cal_type IN VARCHAR2,
            p_n_fee_ci_sequence_number IN PLS_INTEGER,
            p_v_ld_cal_type OUT NOCOPY VARCHAR2,
            p_n_ld_ci_sequence_number OUT NOCOPY PLS_INTEGER,
            p_v_message_name OUT NOCOPY VARCHAR2,
            p_b_return_stat OUT NOCOPY BOOLEAN
);

/*
 * This procedure checks if the payment credit type attached to the Enrollment Deposit or
 * Other Deposit credit type is active in the system as on the current system date.
 * When Payment Credit Type is found to be active then this procedure returns this payment
 * credit type as OUT variable.
 */
PROCEDURE validate_dep_crtype (
            p_n_credit_type_id IN PLS_INTEGER,
            p_n_pay_credit_type_id OUT NOCOPY PLS_INTEGER,
            p_b_return_stat OUT NOCOPY BOOLEAN
);

-- This procedure checks if the passed party id and credit class combination is valid.
FUNCTION validate_party_id (
           p_n_party_id IN PLS_INTEGER,
           p_v_credit_class IN VARCHAR2
) RETURN BOOLEAN;

-- This procedure checks if the GL Date is valid in the system.
PROCEDURE validate_gl_date (
            p_d_gl_date IN DATE,
            p_v_credit_class IN VARCHAR2,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
);

-- This procedure checks if the combination of Source Transaction Type, Credit Class is valid.
PROCEDURE validate_source_tran_type (
            p_v_source_tran_type IN VARCHAR2,
            p_v_credit_class IN VARCHAR2,
            p_v_credit_instrument IN VARCHAR2,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
);

-- This function checks if the Source Reference Number is valid in the system.
FUNCTION validate_source_tran_ref_num (
           p_n_party_id IN PLS_INTEGER,
           p_n_source_tran_ref_num IN PLS_INTEGER
) RETURN BOOLEAN;

-- This procedure will validates Amount
PROCEDURE validate_amount (
            p_n_amount IN NUMBER,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
);

-- Function for validating Descriptive Flex-Field combination.
FUNCTION validate_desc_flex (
           p_v_attribute_category IN VARCHAR2,
           p_v_attribute1 IN VARCHAR2,
           p_v_attribute2 IN VARCHAR2,
           p_v_attribute3 IN VARCHAR2,
           p_v_attribute4 IN VARCHAR2,
           p_v_attribute5 IN VARCHAR2,
           p_v_attribute6 IN VARCHAR2,
           p_v_attribute7 IN VARCHAR2,
           p_v_attribute8 IN VARCHAR2,
           p_v_attribute9 IN VARCHAR2,
           p_v_attribute10 IN VARCHAR2,
           p_v_attribute11 IN VARCHAR2,
           p_v_attribute12 IN VARCHAR2,
           p_v_attribute13 IN VARCHAR2,
           p_v_attribute14 IN VARCHAR2,
           p_v_attribute15 IN VARCHAR2,
           p_v_attribute16 IN VARCHAR2,
           p_v_attribute17 IN VARCHAR2,
           p_v_attribute18 IN VARCHAR2,
           p_v_attribute19 IN VARCHAR2,
           p_v_attribute20 IN VARCHAR2,
           p_v_desc_flex_name IN VARCHAR2
) RETURN BOOLEAN;

-- This function checks if the Invoice ID exists in the system.
FUNCTION validate_invoice_id ( p_n_invoice_id IN PLS_INTEGER ) RETURN BOOLEAN;

-- This procedure will determine the transaction amount in terms of the functional currency.
PROCEDURE translate_local_currency (
            p_n_amount IN OUT NOCOPY NUMBER,
            p_v_currency_cd IN OUT NOCOPY VARCHAR2,
            p_n_exchange_rate IN  NUMBER,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
);

FUNCTION validate_credit_card_payee (
           p_v_credit_card_payee_cd IN VARCHAR2
           ) RETURN BOOLEAN;
PROCEDURE get_award_year_status(p_v_awd_cal_type     IN VARCHAR2,
                                p_n_awd_seq_number   IN PLS_INTEGER,
                                p_v_awd_yr_status    OUT NOCOPY VARCHAR2,
                                p_v_message_name     OUT NOCOPY VARCHAR2);

--This procedure verifies if the Installment balance for the person is greater than
--or equal to the amount of the receipt that is being created.
PROCEDURE validate_plan_balance(p_n_person_id     IN PLS_INTEGER,
                                p_n_amount        IN NUMBER,
                                p_b_status        OUT NOCOPY BOOLEAN,
                                p_v_message_name  OUT NOCOPY VARCHAR2
                                );

--This procedure applies an Installment Payment Transaction against the student's Active
--Payment Plan installments in the FIFO basis.
PROCEDURE apply_installments(p_n_person_id      IN NUMBER,
                             p_n_amount         IN NUMBER,
                             p_n_credit_id      IN igs_fi_credits.credit_id%TYPE,
                             p_n_cr_activity_id IN igs_fi_cr_activities.credit_activity_id%TYPE);
END igs_fi_crdapi_util;

 

/
