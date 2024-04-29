--------------------------------------------------------
--  DDL for Package IGS_FI_SS_ACCT_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_SS_ACCT_PAYMENT" AUTHID CURRENT_USER AS
/* $Header: IGSFI63S.pls 120.0 2005/06/01 14:16:35 appldev noship $ */
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --vvutukur    26-Sep-2003     Enh#3045007.Payment Plans Build.Changes specific to TD.
  --pathipat    04-Jun-2003     Enh 2831584 - SS Enhancements Build - Modified create_cc_credit()
  --                            Added 2 new out parameters x_Credit_number, x_transaction_date
  --smadathi   03-jun-2002     Enh. Bug 2831584. Added new function get_msg_text
  --smadathi   06-Nov-2002     Enh. Bug 2584986. Removed procedure create_posting_int.
  --vvutukur    16-Sep-2002     Enh#2564643.Removed references to subaccount_id from create_cc_credit,
  --                            finp_set_optional_fee_flag.
  --smadathi    25-Mar-2002     Bug 2280971. Added new procedure finp_calc_fees_todo
  --jbegum      25 Feb 02       As part of Enh bug #2238226
  --                            Added the local procedure create_posting_int
  -------------------------------------------------------------------

PROCEDURE create_cc_credit(
             p_party_id IN VARCHAR2,
             p_description IN VARCHAR2,
             p_amount IN VARCHAR,
             p_credit_card_code IN VARCHAR2,
             p_credit_card_holder_name IN VARCHAR2,
             p_credit_card_number IN VARCHAR2,
             p_credit_card_expiration_date IN VARCHAR2,
             p_credit_card_approval_code IN VARCHAR2,
	     p_credit_card_tangible_cd IN VARCHAR2,
             x_credit_id          OUT NOCOPY NUMBER,
             x_credit_activity_id OUT NOCOPY NUMBER,
             x_return_status      OUT NOCOPY VARCHAR2,
             x_msg_count          OUT NOCOPY NUMBER,
             x_msg_data           OUT NOCOPY VARCHAR2,
             x_credit_number      OUT NOCOPY VARCHAR2,
             x_transaction_date   OUT NOCOPY DATE,
	     p_credit_class       IN  VARCHAR2 DEFAULT NULL
             ) ;

PROCEDURE update_cc_credit(
             p_credit_card_approval_code IN NUMBER,
             p_credit_id     IN  NUMBER,
             x_return_status OUT NOCOPY VARCHAR2,
             x_msg_count     OUT NOCOPY NUMBER,
             x_msg_data      OUT NOCOPY VARCHAR2
	     );

PROCEDURE finp_decline_Optional_fee(
             p_invoice_id IN VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2,
             p_message_count OUT NOCOPY NUMBER,
             p_message_data  OUT NOCOPY VARCHAR2
             );

PROCEDURE finp_set_optional_fee_flag(
             p_person_id IN VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2,
             p_message_count OUT NOCOPY NUMBER,
             p_message_data  OUT NOCOPY VARCHAR2
             );

-- procedure checks for any pending todo records of type fee_recalc.
-- If any entry isfound,process calls the fee assessment routine for the FCI
PROCEDURE  finp_calc_fees_todo(
             p_person_id     IN  igs_pe_std_todo_ref.person_id%TYPE,
             p_init_msg_list IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
             p_return_status OUT NOCOPY VARCHAR2,
             p_message_count OUT NOCOPY NUMBER,
             p_message_data  OUT NOCOPY VARCHAR2
             );

FUNCTION get_msg_text(
             p_v_message_name  IN  fnd_new_messages.message_name%TYPE
             ) RETURN VARCHAR2;

END igs_fi_ss_acct_payment;

 

/
