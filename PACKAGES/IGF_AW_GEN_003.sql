--------------------------------------------------------
--  DDL for Package IGF_AW_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGFAW12S.pls 120.1 2005/07/01 06:55:41 appldev ship $ */

PROCEDURE create_auto_disb(  p_fund_id            IN  igf_aw_award.fund_id%TYPE,
                             p_award_id           IN  igf_aw_award.award_id%TYPE,
                             p_offered_amt        IN  igf_aw_award.offered_amt%TYPE,
                             p_award_status       IN  igf_aw_award.award_status%TYPE,
                             p_adplans_id         IN  igf_aw_awd_dist_plans.adplans_id%TYPE,
                             p_method_code        IN  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                             p_awd_prd_code       IN  igf_aw_awd_prd_term.award_prd_cd%TYPE
                            );

PROCEDURE round_off_disbursements(
                                    p_fund_id             IN  igf_aw_award_t_all.fund_id%TYPE,
                                    p_award_id            IN  igf_aw_award_t_all.award_id%TYPE,
                                    p_offered_amt         IN  igf_aw_award_t_all.offered_amt%TYPE,
                                    p_award_status        IN  igf_aw_award_all.award_status%TYPE,
                                    p_dist_plan_code      IN  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                                    p_disb_count          IN  NUMBER
                                  );

PROCEDURE update_accept_amount (
                                    p_award_id    IN  igf_aw_award.award_id%TYPE
                                   );
-- adhawan, May 12th 2002
--This procedure ensures that whenever the Award Status is changed to Accepted from Offered
--and the Accepted amount is null or Zero then updation of the accepted amounts should take
-- place with the offered amounts to the Disbursement table.
--Bug ID :  2332588

PROCEDURE update_awd_cancell_to_offer(p_award_id       IN  igf_aw_award.award_id%TYPE,
                                      p_award_stat     IN  VARCHAR2,
                                      p_fed_fund_code  IN  VARCHAR2,
                                      p_base_id        IN  NUMBER,
                                      p_message        OUT NOCOPY VARCHAR2
                                      );

-- adhawan, May 26th 2002
--This procedure ensures that whenever the Award Status is changed to Accepted OR Offered
--from Cancelled or Declined the Transaction type , eligibility status , elig date,
--and Award amount should get updated
--Bug ID : 2375571


PROCEDURE remove_awd_rules_override(
                                    p_award_id    IN  igf_aw_award.award_id%TYPE
                                   );

PROCEDURE create_over_awd_holds(
                                p_award_id        IN  igf_aw_award.award_id%TYPE
                               );
--To update the Financial Aid base Record with The cost of Attendance
--Fixed Coa , Pell Coa , Coa for Federal , Coa for Institutional
PROCEDURE updating_coa_in_fa_base
                      (p_base_id        igf_ap_fa_base_rec.base_id%TYPE);



--
-- This function returns validation failure message if any
-- The out NOCOPY parameter is indicator if the award is an overAward or not
--

FUNCTION check_amounts ( p_calling_form      IN OUT NOCOPY  VARCHAR2,
                         p_base_id           IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_fund_id           IN      igf_aw_fund_mast_all.fund_id%TYPE,
                         p_fund_code         IN      igf_aw_fund_mast_all.fund_code%TYPE,
                         p_fed_fund_code     IN      igf_aw_fund_cat_all.fed_fund_code%TYPE,
                         p_person_number     IN      igf_aw_award_v.person_number%TYPE,
                         p_award_id          IN      igf_aw_award_all.award_id%TYPE,
                         p_act_isir          IN      VARCHAR2,
                         p_ld_seq_number     IN      NUMBER,
                         p_awd_prd_code      IN      igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                         p_chk_holds         OUT NOCOPY     VARCHAR2)
RETURN VARCHAR2;


--
-- This function returns validation failure message if any
-- The out NOCOPY parameter is indicator if the award is an overAward or not
--

FUNCTION check_disbdts ( p_award_id          IN      igf_aw_award_all.award_id%TYPE,
                         p_ld_seq_number     IN      NUMBER)
RETURN VARCHAR2;

--
-- Procedure to update show_on_bill flag based on the fund manager value
--
PROCEDURE update_bill_flag ( p_fund_id IN igf_aw_award_all.fund_id%TYPE,
                             p_new_val IN igf_aw_fund_mast_all.show_on_bill%TYPE);

FUNCTION delete_awd_disb ( p_award_id    IN     igf_aw_award_all.award_id%TYPE,
                           p_ld_seq_num  IN     igf_aw_awd_disb_all.ld_sequence_number%TYPE DEFAULT NULL,
                           p_disb_num    IN     igf_aw_awd_disb_all.disb_num%TYPE DEFAULT NULL)
RETURN VARCHAR2;


FUNCTION get_total_disb ( p_award_id    IN     igf_aw_award_all.award_id%TYPE,
                          p_ld_seq_num  IN     igf_aw_awd_disb_all.ld_sequence_number%TYPE DEFAULT NULL)
RETURN NUMBER;

PROCEDURE awd_group_freeze(p_award_grp IN VARCHAR2,
                           p_base_id IN NUMBER,
                           p_out OUT NOCOPY VARCHAR2 );

PROCEDURE get_common_perct(
                           p_adplans_id IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                           p_base_id    IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_perct      OUT NOCOPY NUMBER,
                           p_awd_prd_code IN         igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                          );

PROCEDURE check_common_terms(
                             p_adplans_id   IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                             p_base_id      IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                             p_result       OUT NOCOPY NUMBER,
                             p_awd_prd_code IN         igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                            );


-- sjadhav    1-Dec-2003      FA 131 Build
PROCEDURE create_pell_disb(  p_award_id IN NUMBER,
                             p_pell_tab IN igf_gr_pell_calc.pell_tab);

-- sjadhav    1-Dec-2003      FA 131 Build
PROCEDURE update_award_app_trans(  p_award_id      IN NUMBER,
                                   p_base_id       IN NUMBER);

FUNCTION check_coa(
                   p_base_id       IN NUMBER,
                   p_awd_prd_code  IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                  ) RETURN BOOLEAN;

FUNCTION  get_plan_disb_count(p_adplans_id IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                              p_awd_prd_code  IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                             ) RETURN NUMBER;

END igf_aw_gen_003;

 

/
