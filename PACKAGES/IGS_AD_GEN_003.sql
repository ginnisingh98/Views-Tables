--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSAD03S.pls 120.1 2005/07/21 22:37:03 appldev ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --knag        29-Oct-02       Bug 2647482 : Created the function get_core_or_optional_unit
  --                                          to return CORE_ONLY/Y/N for CORE/CORE_OPTIONAL/no
  --                                          as unit enroll indicator to preenroll process
  --anwest      22-Jul-05       IGS.M (ADTD003) Created get_apc_date for the
  --                                            Submitted Applications Reusuable
  --                                            Component
-------------------------------------------------------------------------------------------

Function Admp_Get_Acai_Aos_Id(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_date OUT NOCOPY DATE )
RETURN NUMBER;

Function Admp_Get_Acai_Crv(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd OUT NOCOPY VARCHAR2 ,
  p_crv_version_number OUT NOCOPY NUMBER )
RETURN VARCHAR2;

Function Admp_Get_Acai_Status(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_adm_outcome_status OUT NOCOPY VARCHAR2 ,
  p_adm_offer_resp_status OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Ac_Bfa(
  p_tac_admission_cd IN VARCHAR2 ,
  p_admission_cd OUT NOCOPY VARCHAR2 ,
  p_basis_for_admission_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Get_Adm_Perd_Dt(
  p_dt_alias IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Admp_Get_Adm_Perd_Dt,WNDS,WNPS);

Procedure Admp_Get_Adm_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_adm_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_adm_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_adm_acad_alternate_code OUT NOCOPY VARCHAR2 ,
  p_adm_acad_abbreviation OUT NOCOPY VARCHAR2 ,
  p_adm_adm_cal_type OUT NOCOPY VARCHAR2 ,
  p_adm_adm_ci_sequence_number OUT NOCOPY NUMBER ,
  p_adm_adm_alternate_code OUT NOCOPY VARCHAR2 ,
  p_adm_adm_abbreviation OUT NOCOPY VARCHAR2 ,
  p_adm_admission_cat OUT NOCOPY VARCHAR2 ,
  p_adm_s_admission_process_type OUT NOCOPY VARCHAR2 ,
  p_adm_ac_description OUT NOCOPY VARCHAR2 );

Procedure Admp_Get_Apcs_Mndtry(
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_mandatory_athletics OUT NOCOPY BOOLEAN,
  p_mandatory_alternate OUT NOCOPY BOOLEAN ,
  p_mandatory_address OUT NOCOPY BOOLEAN ,
  p_mandatory_disability OUT NOCOPY BOOLEAN ,
  p_mandatory_visa OUT NOCOPY BOOLEAN ,
  p_mandatory_finance OUT NOCOPY BOOLEAN ,
  p_mandatory_notes OUT NOCOPY BOOLEAN ,
  p_mandatory_statistics OUT NOCOPY BOOLEAN ,
  p_mandatory_alias OUT NOCOPY BOOLEAN ,
  p_mandatory_tertiary OUT NOCOPY BOOLEAN ,
  p_mandatory_aus_sec_ed OUT NOCOPY BOOLEAN ,
  p_mandatory_os_sec_ed OUT NOCOPY BOOLEAN ,
  p_mandatory_employment OUT NOCOPY BOOLEAN ,
  p_mandatory_membership OUT NOCOPY BOOLEAN ,
  p_mandatory_dob OUT NOCOPY BOOLEAN ,
  p_mandatory_title OUT NOCOPY BOOLEAN ,
  p_mandatory_referee OUT NOCOPY BOOLEAN ,
  p_mandatory_scholarship OUT NOCOPY BOOLEAN ,
  p_mandatory_lang_prof OUT NOCOPY BOOLEAN ,
  p_mandatory_interview OUT NOCOPY BOOLEAN ,
  p_mandatory_exchange OUT NOCOPY BOOLEAN ,
  p_mandatory_adm_test OUT NOCOPY BOOLEAN ,
  p_mandatory_fee_assess OUT NOCOPY BOOLEAN ,
  p_mandatory_cor_category OUT NOCOPY BOOLEAN ,
  p_mandatory_enr_category OUT NOCOPY BOOLEAN ,
  p_mandatory_research OUT NOCOPY BOOLEAN ,
  p_mandatory_rank_app OUT NOCOPY BOOLEAN ,
  p_mandatory_completion OUT NOCOPY BOOLEAN ,
  p_mandatory_rank_set OUT NOCOPY BOOLEAN ,
  p_mandatory_basis_adm OUT NOCOPY BOOLEAN ,
  p_mandatory_crs_international OUT NOCOPY BOOLEAN ,
  p_mandatory_ass_tracking OUT NOCOPY BOOLEAN ,
  p_mandatory_adm_code OUT NOCOPY BOOLEAN ,
  p_mandatory_fund_source OUT NOCOPY BOOLEAN ,
  p_mandatory_location OUT NOCOPY BOOLEAN ,
  p_mandatory_att_mode OUT NOCOPY BOOLEAN ,
  p_mandatory_att_type OUT NOCOPY BOOLEAN ,
  p_mandatory_unit_set OUT NOCOPY BOOLEAN ,
  p_mandatory_evaluation_tab OUT NOCOPY  BOOLEAN,
  p_mandatory_prog_approval  OUT NOCOPY  BOOLEAN,
  p_mandatory_indices        OUT NOCOPY  BOOLEAN,
  p_mandatory_tst_scores     OUT NOCOPY  BOOLEAN,
  p_mandatory_outcome        OUT NOCOPY  BOOLEAN,
  p_mandatory_override       OUT NOCOPY  BOOLEAN,
  p_mandatory_spl_consider   OUT NOCOPY  BOOLEAN,
  p_mandatory_cond_offer     OUT NOCOPY  BOOLEAN,
  p_mandatory_offer_dead     OUT NOCOPY  BOOLEAN,
  p_mandatory_offer_resp     OUT NOCOPY  BOOLEAN,
  p_mandatory_offer_defer    OUT NOCOPY  BOOLEAN,
  p_mandatory_offer_compl    OUT NOCOPY  BOOLEAN,
  p_mandatory_transfer       OUT NOCOPY  BOOLEAN,
  p_mandatory_other_inst     OUT NOCOPY  BOOLEAN,
  p_mandatory_edu_goals      OUT NOCOPY  BOOLEAN,
  p_mandatory_acad_interest  OUT NOCOPY  BOOLEAN,
  p_mandatory_app_intent     OUT NOCOPY  BOOLEAN,
  p_mandatory_spl_interest   OUT NOCOPY  BOOLEAN,
  p_mandatory_spl_talents    OUT NOCOPY  BOOLEAN,
  p_mandatory_miscell        OUT NOCOPY  BOOLEAN,
  p_mandatory_fees           OUT NOCOPY  BOOLEAN,
  p_mandatory_program        OUT NOCOPY  BOOLEAN,
  p_mandatory_completness    OUT NOCOPY  BOOLEAN,
  p_mandatory_creden         OUT NOCOPY  BOOLEAN,
  p_mandatory_review_det     OUT NOCOPY  BOOLEAN,
  p_mandatory_recomm_det     OUT NOCOPY  BOOLEAN,
  p_mandatory_fin_aid        OUT NOCOPY  BOOLEAN,
  p_mandatory_acad_honors    OUT NOCOPY  BOOLEAN,
  p_mandatory_des_unitsets   OUT NOCOPY  BOOLEAN,
  p_mandatory_extrcurr      OUT NOCOPY BOOLEAN );

PROCEDURE get_entr_doc_apc (p_admission_cat IN IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                            p_s_admission_process_type IN IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE,
                            l_adm_doc_status OUT NOCOPY IGS_AD_PS_APPL_INST_ALL.adm_doc_status%TYPE,
                            l_adm_entr_qual_status OUT NOCOPY IGS_AD_PS_APPL_INST_ALL.adm_entry_qual_status%TYPE);

FUNCTION get_core_or_optional_unit (
  p_person_id               igs_ad_appl_all.person_id%TYPE,
  p_admission_appl_number   igs_ad_appl_all.admission_appl_number%TYPE)
RETURN VARCHAR2; -- (Y, CORE_ONLY, N)

-- anwest   22-Jul-05   Created get_apc_step for the
--                      Submitted Applications Reusuable
--                      Component
Function get_apc_date(p_date_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 )
RETURN DATE;

END IGS_AD_GEN_003;

 

/
