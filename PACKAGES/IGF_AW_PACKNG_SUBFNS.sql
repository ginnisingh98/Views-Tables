--------------------------------------------------------
--  DDL for Package IGF_AW_PACKNG_SUBFNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_PACKNG_SUBFNS" AUTHID CURRENT_USER AS
/* $Header: IGFAW09S.pls 120.2 2006/08/04 07:38:32 veramach ship $ */

-- who          when             what
-- museshad     15-Jun-2005      Build# FA157 - Bug# 4382371.
--                               Added the parameters - l_awd_period,  l_called_from
--                               to check_loan_limits() and get_class_stnd() procedures.
-- veramach      11-Oct-2004     Obsoleted get_coa_months,stud_elig_chk
-- bkkumar       14-Jan-04       Bug# 3360702 In the get_class_stnd
--                               Added one new award_id parameter and changed the fund_id parameter to adplans_id
-- veramach      11-NOV-2003     FA 125 Multiple distribution methods
--                               1.Changed function signature of get_class_stnd,check_loan_limits to take adplans_id instead of fund_id
-- bkkumar      31-oct-2003      Bug# 3229935 Changed the declaration of the
--                               fed_fund_code,fund_code,award_amount,award_date


TYPE std_loan_rec IS RECORD(fed_fund_code    igf_aw_fund_cat_all.fed_fund_code%TYPE,
                            fund_code        igf_aw_fund_cat_all.fund_code%TYPE,
                            award_amount     igf_aw_award_all.offered_amt%TYPE,
                            award_date       igf_aw_award_all.award_date%TYPE);

TYPE std_loan_tab IS TABLE OF std_loan_rec;

PROCEDURE check_loan_limits( l_base_id        IN NUMBER,
                             fund_type        IN VARCHAR2,
                             l_award_id       IN NUMBER,
                             l_adplans_id        IN NUMBER,
                             l_aid            IN OUT NOCOPY NUMBER,
                             l_std_loan_tab   IN std_loan_tab DEFAULT NULL,
                             p_msg_name       OUT NOCOPY VARCHAR2,
                             l_awd_period     IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                             l_called_from    IN VARCHAR2 DEFAULT 'NON-PACKAGING',
                             p_chk_aggr_limit IN VARCHAR2 DEFAULT 'Y'
                             ) ;

PROCEDURE get_fed_efc( l_base_id IN          NUMBER,
                       l_awd_prd_code IN     igf_aw_awd_prd_term.award_prd_cd%TYPE,
                       l_efc_f OUT NOCOPY    NUMBER,
                       l_pell_efc OUT NOCOPY NUMBER,
                       l_efc_ay       OUT NOCOPY  NUMBER
                       ) ;

FUNCTION get_class_stnd(
                        p_base_id     IN  igf_ap_fa_base_rec.base_id%TYPE,
                        p_person_id   IN  igf_ap_fa_base_rec.person_id%TYPE,
                        p_adplans_id  IN  NUMBER,
                        p_award_id    IN  igf_aw_award_all.award_id%TYPE,
                        p_course_type OUT NOCOPY igs_ps_ver_all.course_type%TYPE,
                        p_awd_period     IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                        p_called_from    IN VARCHAR2 DEFAULT 'NON-PACKAGING'
                       ) RETURN CHAR;

FUNCTION is_over_award_occured(
                               p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_mthd_type    VARCHAR2 DEFAULT NULL,
                               p_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                              ) RETURN BOOLEAN;

END igf_aw_packng_subfns;

 

/
