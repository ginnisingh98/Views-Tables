--------------------------------------------------------
--  DDL for Package IGF_SL_LAR_CREATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_LAR_CREATION" AUTHID CURRENT_USER AS
/* $Header: IGFSL01S.pls 120.0 2005/06/01 14:16:15 appldev noship $ */

/***************************************************************
   Created By		:	mesriniv
   Date Created By	:	2000/11/13
   Purpose		:	To Insert Loan Records into
   				IGF_SL_LOANS
   Known Limitations,Enhancements or Remarks
   Change History	:
   Bug ID : 1818617
   Who	          When		  What
------------------------------------------------------------------------
-- veramach      July 2004             FA 151 HR Integration (bug 3709292)
--                                     Published get_loan_start_dt and get_loan_end_dt in the spec
------------------------------------------------------------------------
-- rasahoo             02-Sep-2003     Replaced igf_ap_fa_base_h.class_standing%TYPE with
--                                     igs_pr_css_class_std_v.class_standing%TYPE and
--                                     igf_ap_fa_base_h.enrl_program_type%TYPE with igs_ps_ver_all.course_type%TYPE.
-- sjadhav             24-jul-2001     added parameter p_get_recent_info
--
------------------------------------------------------------------------
 ***************************************************************/

  PROCEDURE  get_dl_cl_std_code ( p_base_id         IN   igf_ap_fa_base_rec_all.base_id%TYPE ,
                                  p_class_standing  IN   igs_pr_css_class_std_v.class_standing%TYPE ,
                                  p_program_type    IN   igs_ps_ver_all.course_type%TYPE ,
                                  p_dl_std_code     OUT NOCOPY  igf_ap_class_std_map.dl_std_code%TYPE ,
                                  p_cl_std_code     OUT NOCOPY  igf_ap_class_std_map.cl_std_code%TYPE ) ;

  PROCEDURE insert_loan_records(
  ERRBUF             OUT NOCOPY  VARCHAR2,
  RETCODE            OUT NOCOPY  NUMBER,
  p_award_year       IN          VARCHAR2,
  p_run_mode         IN          VARCHAR2,
  p_fund_id          IN          NUMBER,
  p_dummy_1          IN          NUMBER,
  p_base_id          IN          NUMBER,
  p_dummy_2          IN          NUMBER,
  p_award_id         IN          NUMBER,
  p_dummy_3          IN          NUMBER,
  p_dyn_pid_grp      IN          NUMBER ) ;

  FUNCTION get_loan_start_dt ( p_award_id  igf_aw_award_all.award_id%TYPE)
  RETURN DATE;

  FUNCTION get_loan_end_dt ( p_award_id  igf_aw_award_all.award_id%TYPE)
  RETURN DATE;

END igf_sl_lar_creation;

 

/
