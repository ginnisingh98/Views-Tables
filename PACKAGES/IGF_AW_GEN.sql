--------------------------------------------------------
--  DDL for Package IGF_AW_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_GEN" AUTHID CURRENT_USER AS
/* $Header: IGFAW02S.pls 120.1 2005/06/08 00:42:45 appldev  $ */

-- All commonly used functions and procedures can be created in this package
-- mnade        6/6/2005           FA 157 - 4382371 - Added
--                                 get_notification_status update_notification_status
--                                 update_awd_notification_status get_concurrent_prog_name
--                                 is_fund_locked_for_awd_period
-- veramach    Oct 2004            FA 152/FA 137 - Obsoleted efc_coa,efc_resource,rem_need_fm,rem_need_im
-- veramach      11-NOV-2003       Changed the signature of check_ld_cal_tps -adplans_id is passed instead of fund_id and out variable is VARCHAR2
--                                 instead of BOOLEAN
--adhawan        25-oct-2002       ALT_PELL_SCHEDULE added for FA108 Awarding Enhancements
--                               efc_coa --Modified the coa_total_cur to select from directly for term load calendar
--                                   efc_coa --Obsoleted the usage of p_flag , it is kept only for backward compatibility
--                                   efc_resource Modified the award_total_cur to select from igf_aw_adisb_coa_match_v instead of igf_aw_coa_citsn
--                                   efc_resource Obsoleted the usage of p_flag , it is kept only for backward compatibility
--Bug ID #2613546
-- sjadhav
-- Bug 2216956
-- Feb 13,2002
-- added function to get version number
--

FUNCTION LOOKUP_DESC( l_type in VARCHAR2 ,
                      l_code in VARCHAR2 ) RETURN VARCHAR2  ;

--
-- Use this function to get Version Number for the File Processing
-- p_process
-- D - DL
-- F - FFEL
-- P - PELL
-- I - ISIR
-- R - PROFILE
--
FUNCTION get_ver_num ( p_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                       p_seq_num  IN igs_ca_inst_all.sequence_number%TYPE,
                       p_process  IN VARCHAR2) RETURN VARCHAR2;


PROCEDURE update_disb( p_disb_old_rec igf_aw_awd_disb_all%ROWTYPE,
                       p_disb_new_rec igf_aw_awd_disb_all%ROWTYPE );

PROCEDURE update_fabase_awds ( p_base_id in igf_ap_fa_base_rec_all.base_id%type,
                          p_pack_status igf_ap_fa_base_rec.packaging_status%TYPE) ;

FUNCTION get_org_id
         RETURN NUMBER;

PROCEDURE set_org_id(p_context IN VARCHAR2 );

PRAGMA RESTRICT_REFERENCES (LOOKUP_DESC,WNDS,WNPS);

PROCEDURE update_fmast( x_old_ref in igf_aw_award_all%ROWTYPE,
                        x_new_ref in igf_aw_award_all%ROWTYPE,
                        flag in Varchar ) ;

PROCEDURE update_award( p_award_id    IN igf_aw_award_all.award_id%TYPE,
                        p_disb_num    IN igf_aw_awd_disb_all.disb_num%TYPE,
                        p_disb_amt    IN igf_aw_awd_disb_all.disb_net_amt%TYPE,
                        p_disb_dt     IN igf_aw_awd_disb_all.disb_date%TYPE,
                        p_action      IN VARCHAR2,
                        x_called_from IN VARCHAR2 DEFAULT NULL
                        );

PROCEDURE check_ld_cal_tps( p_adplans_id       igf_aw_awd_dist_plans.adplans_id%TYPE,
                            p_found OUT NOCOPY VARCHAR2 ) ;

PROCEDURE check_number_format(str VARCHAR2,ret OUT NOCOPY NUMBER) ;

  /*
  ||  Created By : pkpatel
  ||  Created On : 11-DEC-2001
  ||  Purpose : Bug No - 2142666 EFC DLD
  ||            It finds the Dependency Status and eligibility of student for processing Simplified and Auto Zero EFC.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

  PROCEDURE depend_stat_2001
  (         p_base_id           IN   igf_ap_fa_base_rec.base_id%TYPE,      -- Students Base ID
            p_isir_id           IN   igf_ap_isir_matched_all.isir_id%TYPE, -- ISIR ID
            p_method_code       IN   VARCHAR2, -- Need Analysis Methodology Code
      p_category          OUT NOCOPY  NUMBER,                               -- 0 -> Zero EFC, 1 -> A Regular, 2 -> A Simplified, 3 -> B Regular,
                                                                     -- 4 -> B Simplified, 5 -> C Regular, 6 -> C Simplified
      p_dependency_status OUT NOCOPY  VARCHAR2);                            -- Students Dependency Status ie Independent or Dependent

  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Searches for the award notification status for given person for given awarding period the terms for which
  ||  fall under the given awarding period. If all awards carry same notification status in that case carry the same with
  || latest date. In case there are multiple, return the least significant one , with latest date.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  PROCEDURE get_notification_status (
                        p_cal_type                  IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num                   IN igs_ca_inst_all.sequence_number%TYPE,
                        p_awarding_period           IN igf_aw_award_prd.award_prd_cd%TYPE,
                        p_base_id                   IN igf_ap_fa_base_rec_all.base_id%type,
                        p_notification_status_code  OUT NOCOPY igf_aw_award_all.notification_status_code%TYPE,
                        p_notification_status_date  OUT NOCOPY igf_aw_award_all.notification_status_date%TYPE
                        );

  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Searches for awards for given person for given awarding period the terms for which
  ||  fall under the given awarding period. All awards will be updated to carry supplied
  ||  Notification Status and Notification Status Date.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  PROCEDURE update_notification_status (
                        p_cal_type                  IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num                   IN igs_ca_inst_all.sequence_number%TYPE,
                        p_awarding_period           IN igf_aw_award_prd.award_prd_cd%TYPE,
                        p_base_id                   IN igf_ap_fa_base_rec_all.base_id%type,
                        p_notification_status_code  IN igf_aw_award_all.notification_status_code%TYPE,
                        p_notification_status_date  IN igf_aw_award_all.notification_status_date%TYPE,
                        p_called_from               IN VARCHAR2
                        );

  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Updates the Notification Status and Notification Status Date for given award.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  PROCEDURE update_awd_notification_status  (
                        p_award_id                  IN igf_aw_award_all.award_id%TYPE,
                        p_notification_status_code  IN igf_aw_award_all.notification_status_code%TYPE,
                        p_notification_status_date  IN igf_aw_award_all.notification_status_date%TYPE,
                        p_called_from               IN VARCHAR2
                        );


  /*
  ||  Created By : mnade
  ||  Created On : 5/24/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Gets the concurrent program name for the cp id being passed.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  FUNCTION get_concurrent_prog_name (p_program_id   IN fnd_concurrent_programs_tl.concurrent_program_id%TYPE) RETURN VARCHAR2 ;

  /*
  ||  Created By : mnade
  ||  Created On : 6/6/2005
  ||
  ||  Purpose : Bug No - 4382371 FA 157 - Packaging Phase II
  ||  Checks if there is any award locked under given awarding period for the student
  ||  and returns true of there is any award locked for the student.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  FUNCTION is_fund_locked_for_awd_period (
                        p_base_id                   IN igf_ap_fa_base_rec_all.base_id%type,
                        p_cal_type                  IN igs_ca_inst_all.cal_type%TYPE,
                        p_seq_num                   IN igs_ca_inst_all.sequence_number%TYPE,
                        p_awarding_period           IN igf_aw_award_prd.award_prd_cd%TYPE,
                        p_fund_id                   IN igf_aw_award_all.fund_id%TYPE
    ) RETURN BOOLEAN;

END igf_aw_gen;

 

/
