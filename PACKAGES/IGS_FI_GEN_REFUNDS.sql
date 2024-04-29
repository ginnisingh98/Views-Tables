--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_REFUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_REFUNDS" AUTHID CURRENT_USER AS
/* $Header: IGSFI68S.pls 115.3 2002/11/29 00:29:23 nsidana noship $ */
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
--  shtatiko	24-Sep-2002	Removed Subaccount_id from the signature of
--				get_fee_prd
  ------------------------------------------------------------------

FUNCTION check_fund_auth( p_person_id igs_fi_parties_v.person_id%TYPE) RETURN BOOLEAN;

PROCEDURE get_fee_prd (p_fee_type               OUT NOCOPY       igs_fi_fee_type.fee_type%TYPE,
                       p_fee_cal_type           IN OUT NOCOPY    igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                       p_fee_ci_sequence_number IN OUT NOCOPY    igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                       p_status                 OUT NOCOPY       BOOLEAN);
FUNCTION get_rfnd_hold (p_person_id igs_pe_person.person_id%TYPE) RETURN BOOLEAN;

PROCEDURE get_borw_det (p_credit_id          igs_fi_credits.credit_id%TYPE,
                        p_determination  OUT NOCOPY igs_lookups_view.lookup_code%TYPE,
                        p_err_message    OUT NOCOPY fnd_new_messages.message_name%TYPE,
                        p_status         OUT NOCOPY BOOLEAN);

FUNCTION val_add_drop (p_fee_cal_type            igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                       p_fee_ci_sequence_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) RETURN BOOLEAN;

PROCEDURE get_refund_acc ( p_dr_gl_ccid     OUT NOCOPY igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE,
                           p_dr_account_cd  OUT NOCOPY igs_fi_f_typ_ca_inst.rec_account_cd%TYPE,
                           p_cr_gl_ccid     OUT NOCOPY igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE,
                           p_cr_account_cd  OUT NOCOPY igs_fi_f_typ_ca_inst.rec_account_cd%TYPE,
                           p_err_message    OUT NOCOPY fnd_new_messages.message_name%TYPE,
                           p_status         OUT NOCOPY BOOLEAN);


END igs_fi_gen_refunds;

 

/
