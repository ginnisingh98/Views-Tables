--------------------------------------------------------
--  DDL for Package IGF_AW_PACKAGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_PACKAGING" AUTHID CURRENT_USER AS
/* $Header: IGFAW03S.pls 120.3 2006/08/04 07:37:39 veramach ship $ */

  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose    :  Does the main packaging in awards
  ||  Known limitations, enhancements or remarks :
  ||  who            when            what
  ||  museshad       29-Jun-2005    Build# FA157 - Bug# 4382371.
  ||                                Added the functions 'get_term_start_date()' and
  ||                                'get_disb_round_factor()'
  ||  veramach       30-Jun-2004    bug 3709109 - Added function check_disb
  ||  cdcruz         03-Dec-2003    FA 131 COD Updates
  ||                                The Type disb_dt_rec had a typo in the column name
  ||                                base_attendance_type  changed to base_attendance_type_code
  ||  veramach       03-Dec-2003    FA 131 COD Updates
  ||                                Adds base_attendance_type to disb_dt_rec
  ||  veramach       20-NOV-2003    FA 125 Multiple Distribution method
  ||                                1.Added g_plan_id,g_plan_cd global variables
  ||                                2.Changed TYPE disb_dt_rec to have attendance_type_code
  ||                                3.Added p_dist_id as parameter to pkg_single_fund
  ||  veramach      13-OCT-2003     FA 124 Remove ISIR Requirement for Awarding
  ||                                1.Removed obsoleted parameters of procedure run from the spec
  ||                                2.Removed parameter p_grp_code from pkg_single_fund and added parameters p_sf_min_amount,
  ||                                  p_sf_max_amount,p_allow_to_exceed
  ||  rasahoo       23-Apl-2003     Bug # 2860836 a parmeter added in the post_award procedure
  ||  brajendr      24-Oct-2002     FA105 / FA108 Builds
  ||                                Refer TDs for the changes
  ||
  ||  sjadhav       24-jul-2001     Bug ID : 1818617
  ||                                added parameter p_get_recent_info
  ||
  ||  sjadhav       21-May-2001     Bug ID : 1747948
  ||                                Added one more parameter Group Code
  ||
  ||  pmarada       14-feb-2002     Added p_upd_awd_notif_status parameter.
  */

 PROCEDURE clear_simulation( l_base_id IN NUMBER );

 PROCEDURE run(
               errbuf                 OUT NOCOPY VARCHAR2,
               retcode                OUT NOCOPY NUMBER,
               l_award_year           IN  VARCHAR2 DEFAULT NULL, -- 10
               p_awd_prd_code         IN  VARCHAR2 DEFAULT NULL,
               l_grp_code             IN  VARCHAR2 DEFAULT NULL, -- 20
               l_base_id              IN  NUMBER   DEFAULT NULL, -- 30
               l_sim_mode             IN  VARCHAR2 DEFAULT NULL,  -- 40
               p_upd_awd_notif_status IN  VARCHAR2 DEFAULT NULL, -- 50
               l_run_mode             IN  VARCHAR2 DEFAULT NULL, -- 60
               p_fund_id              IN  NUMBER   DEFAULT NULL, -- 70
               l_run_type             IN  VARCHAR2 DEFAULT NULL, -- 80  Obsoleted parameter, retaining for backward COMPATIBILITY
               p_publish_in_ss_flag   IN  VARCHAR2 DEFAULT NULL,
               l_run_code             IN  VARCHAR2 DEFAULT NULL, -- 90  Obsoleted parameter, retaining for backward compatibility
               l_individual_pkg       IN  VARCHAR2 DEFAULT NULL  -- 100 Obsoleted parameter, retaining for backward COMPATIBILITY
              );

/*
               l_ci_cal_type        --> Calendar Type
               l_ci_sequence_number --> Calendar Sequence Number
               l_grp_code           --> Target Groups defiend in the system
               l_base_id            --> Student Base ID
               l_run_mode           --> D Detail Model in which all comments printed in the log file
                                        S Summary Mode in which no comments are printed   ) ;
               p_over_awd           --> NA    No Award
                                    --> CH    Create Hold
                                    --> NH    No Hold
*/

 PROCEDURE post_award(
                      l_base_id              IN NUMBER,
                      l_process_id           IN NUMBER,
                      l_post                 IN VARCHAR2,
                      l_called_from          IN VARCHAR2,
                      l_upd_awd_notif_status IN VARCHAR2 DEFAULT NULL,
                      l_ret_status           OUT NOCOPY VARCHAR2   -- Bug # 2860836 parameter added
                     );

 PROCEDURE group_run(
                     l_group_code         IN VARCHAR2,
                     l_ci_cal_type        IN VARCHAR2 ,
                     l_ci_sequence_number IN NUMBER,
                     l_post               IN VARCHAR2,
                     l_run_mode           IN VARCHAR2
                    ) ;

 PROCEDURE stud_run(
                    l_base_id        IN NUMBER,
                    l_post           IN VARCHAR2,
                    l_run_mode       IN VARCHAR2
                   ) ;

 PROCEDURE process_stud(
                        l_fabase          IN igf_ap_fa_base_rec%ROWTYPE,
                        l_use_fixed_costs IN VARCHAR2,
                        l_post            IN VARCHAR2,
                        l_run_mode        IN VARCHAR2,
                        l_fund_id         OUT NOCOPY NUMBER,
                        l_seq_no          OUT NOCOPY NUMBER,
                        l_award_id        OUT NOCOPY NUMBER,
                        l_fund_fail       OUT NOCOPY BOOLEAN
                       ) ;

 PROCEDURE update_fund(
                       l_fund_id    IN NUMBER,
                       l_seq_no     IN NUMBER,
                       l_process_id IN NUMBER,
                       l_base_id    IN NUMBER,
                       l_award_id   IN NUMBER
                      );


 PROCEDURE get_process_id ;

 FUNCTION  get_perct_amt(
                         l_perct_fact IN VARCHAR2,
                         l_perct_val  IN NUMBER ,
                         l_base_id    IN NUMBER,
                         l_efc_f      IN NUMBER,
                         p_awd_prd_code IN VARCHAR2
                        ) RETURN NUMBER;

 TYPE disb_dt_rec IS RECORD(
                            process_id           NUMBER,
                            sl_no                NUMBER,
                            disb_num             NUMBER,
                            nslds_disb_date      DATE,
                            disb_verf_dt         DATE,
                            disb_exp_dt          DATE,
                            min_credit_pts       NUMBER,
                            attendance_type_code igf_aw_awd_disb_all.attendance_type_code%TYPE,
                            base_attendance_type_code igf_aw_awd_disb_all.base_attendance_type_code%TYPE
                           );

 TYPE disb_dt_tab IS TABLE OF disb_dt_rec;

 PROCEDURE get_disbursements(
                             l_fund_id      IN NUMBER,
                             l_offered_amt  IN NUMBER,
                             l_base_id      IN NUMBER,
                             l_process_id   IN NUMBER,
                             l_accepted_amt IN NUMBER,
                             l_called_from  IN VARCHAR2,
                             l_nslds_da     IN VARCHAR2,
                             l_exp_da       IN VARCHAR2,
                             l_verf_da      IN VARCHAR2,
                             l_disb_dt      IN OUT NOCOPY disb_dt_tab,
                             l_adplans_id   IN NUMBER,
                             l_award_id     IN NUMBER
                            );

  PROCEDURE add_todo(
                     p_fund_id  IN igf_aw_fund_mast_all.fund_id%TYPE,
                     p_base_id  IN igf_ap_fa_base_rec_all.base_id%TYPE
                   );

 FUNCTION get_date_instance(
                            p_base_id      IN igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_dt_alias     IN igs_ca_da.dt_alias%TYPE,
                            p_cal_type     IN igs_ca_inst.cal_type%TYPE,
                            p_cal_sequence IN igs_ca_inst.sequence_number%TYPE
                           ) RETURN DATE;

 PROCEDURE process_single_fund(
                               p_grp_code            IN  VARCHAR2,
                               p_ci_cal_type         IN  VARCHAR2,
                               p_ci_sequence_number  IN  NUMBER,
                               p_base_id             IN  NUMBER,
                               p_persid_grp          IN  NUMBER DEFAULT NULL
                              );


  PROCEDURE pkg_single_fund(
                            errbuf                 OUT NOCOPY VARCHAR2,
                            retcode                OUT NOCOPY NUMBER,
                            p_award_year           IN  VARCHAR2 DEFAULT NULL,
                            p_awd_prd_code         IN  VARCHAR2 DEFAULT NULL,
                            p_fund_id              IN  NUMBER   DEFAULT NULL,
                            p_dist_id              IN  NUMBER   DEFAULT NULL,
                            p_base_id              IN  NUMBER   DEFAULT NULL,
                            p_persid_grp           IN  NUMBER   DEFAULT NULL,
                            p_sf_min_amount        IN  NUMBER   DEFAULT NULL,
                            p_sf_max_amount        IN  NUMBER   DEFAULT NULL,
                            p_allow_to_exceed      IN  VARCHAR2 DEFAULT NULL,
                            p_upd_awd_notif_status IN  VARCHAR2 DEFAULT NULL,
                            p_lock_award           IN  VARCHAR2 DEFAULT NULL,
                            p_publish_in_ss_flag   IN  VARCHAR2 DEFAULT NULL
                           );

  FUNCTION check_disb(
                      p_base_id     igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_adplans_id  igf_aw_awd_dist_plans.adplans_id%TYPE,
                      p_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                     ) RETURN BOOLEAN;

  FUNCTION get_term_start_date(
                               p_base_id            IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_ld_cal_type        IN    igs_ca_inst.cal_type%TYPE,
                               p_ld_sequence_number IN    igs_ca_inst.sequence_number%TYPE
                              )RETURN DATE;
  FUNCTION get_disb_round_factor(
                                  p_fund_id   IN igf_aw_fund_mast.fund_id%TYPE
                                )RETURN VARCHAR2;

  FUNCTION chk_gplus_loan_limits (
                                    p_base_id         IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_fed_fund_code   IN          igf_aw_fund_cat_all.fed_fund_code%TYPE,
                                    p_adplans_id      IN          igf_aw_awd_dist_plans.adplans_id%TYPE,
                                    p_aid             IN          NUMBER,
                                    p_std_loan_tab    IN          igf_aw_packng_subfns.std_loan_tab,
                                    p_msg_name        OUT NOCOPY  fnd_new_messages.message_name%TYPE
                                  ) RETURN BOOLEAN;

  FUNCTION get_fed_fund_code(p_fund_id IN NUMBER) RETURN VARCHAR2;

  l_process_id          NUMBER(15);
  l_actual_grant_amt    NUMBER(12,3);
  l_actual_loan_amt     NUMBER(12,3);
  l_actual_work_amt     NUMBER(12,3);
  l_actual_shelp_amt    NUMBER(12,3);
  l_actual_gift_amt     NUMBER(12,3);
  l_actual_schlp_amt    NUMBER(12,3);
  l_max_aid_pkg         NUMBER(12,3);
  l_grant_amt           NUMBER(12,3);
  l_loan_amt            NUMBER(12,3);
  l_work_amt            NUMBER(12,3);
  l_shelp_amt           NUMBER(12,3);
  l_gift_amt            NUMBER(12,3);
  l_schlp_amt           NUMBER(12,3);
  l_gap_amt             NUMBER(12,3);
  l_efc_f               NUMBER(12,3);
  l_efc_i               NUMBER(12,3);
  l_pell_efc            NUMBER(12,3);
  gn_fund_awd_cnt       NUMBER;
  g_alt_pell_schedule   igf_aw_award_all.alt_pell_schedule%TYPE;

  g_plan_id             NUMBER := -1;
  g_method_cd           VARCHAR2(80) ;
  g_lock_award          igf_aw_fund_mast_all.lock_award_flag%TYPE;
  g_awd_prd             igf_aw_awd_prd_term.award_prd_cd%TYPE;
  g_publish_in_ss_flag  igf_aw_award_all.publish_in_ss_flag%TYPE;

  g_phasein_participant BOOLEAN;
  g_req_id              NUMBER;
END IGF_AW_PACKAGING;

 

/
