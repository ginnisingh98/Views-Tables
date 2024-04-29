--------------------------------------------------------
--  DDL for Package IGF_SL_AWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_AWARD" AUTHID CURRENT_USER AS
/* $Header: IGFSL13S.pls 120.0 2005/06/01 15:39:23 appldev noship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/12/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  -----------------------------------------------------------------------------------
-- mnade        8-Feb-2005       Bug 4127250 chk_disb_date call changed to pass the dates being set
--                               for checking if that is covering all the disbursements.
----------------------------------------------------------------------------------------
-- bkkumar       05-04-04        FACR116 - Added p_alt_rel_code as paramter and added
--                               new function get_alt_rel_code()
-- bkkumar       07-oct-2003     Bug 3104228  removed the select_org procedure.
-- bkkumar       Sep 30,2003     FA 122 Loan Enhancents
--                                Added new function get_cl_auto_late_ind,
--                                pick_setup and changed  get_loan_fee1,get_loan_fee2,
                                  get_cl_hold_rel_ind, recalc_fees
-----------------------------------------------------------------------------------

  (reverse chronological order - newest change first)
  ***************************************************************/

g_base_id     igf_aw_award_all.base_id%TYPE;
g_rel_code    igf_sl_cl_setup.relationship_cd%TYPE;
g_person_id   igf_sl_cl_pref_lenders.person_id%TYPE;
g_party_id    igf_sl_cl_setup.party_id%TYPE;

PROCEDURE  get_loan_amts(p_ci_cal_type     IN   igs_ca_inst_all.cal_type%TYPE,
                         p_ci_seq_num      IN   igs_ca_inst_all.sequence_number%TYPE,
                         p_fed_fund_code   IN   igf_aw_fund_cat_all.fed_fund_code%TYPE,
                         p_gross_amt       IN   igf_aw_awd_disb_all.disb_gross_amt%TYPE,
                         p_rebate_amt      OUT NOCOPY  igf_aw_awd_disb_all.int_rebate_amt%TYPE,
                         p_loan_fee_amt    OUT NOCOPY  igf_aw_awd_disb_all.fee_1%TYPE,
                         p_net_amt         OUT NOCOPY  igf_aw_awd_disb_all.disb_net_amt%TYPE);
-----------------------------------------------------------------------------------
--
-- sjadhav, Jan 23,2002
-- This procedure calculates loan fee amount, interest rebate amount
-- combined fee int rebate anount and disb net amonut for Direct Loans
--
-----------------------------------------------------------------------------------
PROCEDURE pick_setup(
                       p_base_id           IN  igf_aw_award_all.base_id%TYPE,
                       p_cal_type          IN  igs_ca_inst_all.cal_type%TYPE,
                       p_sequence_number   IN  igs_ca_inst_all.sequence_number%TYPE,
                       p_rel_code          OUT NOCOPY  igf_sl_cl_setup.relationship_cd%TYPE,
                       p_person_id         OUT NOCOPY  igf_sl_cl_pref_lenders.person_id%TYPE,
                       p_party_id          OUT NOCOPY  igf_sl_cl_setup.party_id%TYPE,
                       p_alt_rel_code      IN  igf_aw_fund_cat_all.alt_rel_code%TYPE DEFAULT NULL
                    );

FUNCTION get_loan_fee1(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                       p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                       p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                       p_base_id        igf_aw_award_all.base_id%TYPE DEFAULT NULL,
                       p_rel_code       VARCHAR2 DEFAULT NULL,
                       p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE DEFAULT NULL)
RETURN NUMBER;

FUNCTION get_loan_fee2(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                       p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                       p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                       p_base_id        igf_aw_award_all.base_id%TYPE DEFAULT NULL,
                       p_rel_code       VARCHAR2 DEFAULT NULL,
                       p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE DEFAULT NULL)
RETURN NUMBER;

FUNCTION get_cl_hold_rel_ind(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                             p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                             p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                             p_base_id        igf_aw_award_all.base_id%TYPE DEFAULT NULL,
                             p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE DEFAULT NULL)
RETURN VARCHAR2;
FUNCTION get_cl_auto_late_ind(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                              p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                              p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                              p_base_id        igf_aw_award_all.base_id%TYPE DEFAULT NULL,
                              p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE DEFAULT NULL)
RETURN VARCHAR2;


FUNCTION chk_disb_date(p_award_id               igf_sl_loans.award_id%TYPE,
                       p_loan_per_begin_date    igf_sl_loans_all.loan_per_begin_date%TYPE   DEFAULT NULL,
                       p_loan_per_end_date      igf_sl_loans_all.loan_per_end_date%TYPE     DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION chk_loan_upd_lock(p_award_id  igf_sl_loans.award_id%TYPE)
RETURN VARCHAR2;
FUNCTION get_alt_rel_code(p_fund_code  igf_aw_fund_cat_all.fund_code%TYPE)
RETURN VARCHAR2;

PROCEDURE recalc_fees(
                       p_base_id           IN  igf_aw_award_all.base_id%TYPE,
                       p_cal_type          IN  igs_ca_inst_all.cal_type%TYPE,
                       p_sequence_number   IN  igs_ca_inst_all.sequence_number%TYPE,
                       p_rel_code          IN  igf_sl_cl_setup.relationship_cd%TYPE,
                       p_award_id          IN  igf_sl_loans.award_id%TYPE
                     );


FUNCTION chk_chg_enable (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN   BOOLEAN;

FUNCTION chk_add_new_disb (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN   BOOLEAN;

FUNCTION chk_loan_increase (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN   BOOLEAN;

FUNCTION get_loan_cl_version (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN igf_sl_cl_setup_all.cl_version%TYPE;

FUNCTION chk_fund_st_chg ( p_n_award_id   IN igf_aw_award_all.award_id%TYPE,
                           p_n_disb_num   IN igf_aw_awd_disb_all.disb_num%TYPE
                         )
RETURN BOOLEAN;

END igf_sl_award;

 

/
