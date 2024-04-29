--------------------------------------------------------
--  DDL for Package IGS_ST_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSST03S.pls 115.8 2003/05/13 09:01:13 kkillams ship $ */
/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        05-MAR-2002     Bug NO: 2224621
  ||                                 Modified P_GOVT_EXEMPTION_INST_CD from NUMBER to VARCHAR2 in STAP_GET_SCA_DATA. Since its source
  ||                                 IGS_OR_INSTITUTION.GOVT_INSTITUTION_CD is modified from NUMBER to VARCHAR2.
  ||  (reverse chronological order - newest change first)
  ||  kkillams       11-MAY-2003    Added new parameter p_uoo_id to the  Stap_Get_Rptbl_Govt and Stap_Get_Rptbl_Sbmsn functions
  ||
  ||                                w.r.t. bug number 2829262
  ||  (reverse chronological order - newest change first)
*/


Function Stap_Get_Prsn_Dsblty(
  p_person_id IN NUMBER )
RETURN VARCHAR2;

Procedure Stap_Get_Prsn_Names(
  p_person_id           IN NUMBER ,
  p_given_name          OUT NOCOPY VARCHAR2 ,
  p_other_names         OUT NOCOPY VARCHAR2 );

Function Stap_Get_Rptbl_Benc(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_crv_version_number          IN NUMBER ,
  p_govt_reportable_ind         IN VARCHAR2 DEFAULT 'N',
  p_enrolled_dt                 IN DATE ,
  p_submission_cutoff_dt        IN DATE )
RETURN VARCHAR2;

FUNCTION Stap_Get_Rptbl_Govt(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_crv_version_number          IN NUMBER ,
  p_unit_cd                     IN VARCHAR2 ,
  p_uv_version_number           IN NUMBER ,
  p_teach_cal_type              IN VARCHAR2 ,
  p_teach_ci_sequence_number    IN NUMBER ,
  p_tr_org_unit_cd              IN VARCHAR2 ,
  p_tr_ou_start_dt              IN DATE ,
  p_eftsu                       IN NUMBER ,
  p_effective_dt                IN DATE ,
  p_exclusion_level             OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN VARCHAR2;

FUNCTION Stap_Get_Rptbl_Sbmsn(
  p_submission_yr               IN NUMBER ,
  p_submission_number           IN NUMBER ,
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_crv_version_number          IN NUMBER ,
  p_unit_cd                     IN VARCHAR2 ,
  p_uv_version_number           IN NUMBER ,
  p_teach_cal_type              IN VARCHAR2 ,
  p_teach_ci_sequence_number    IN NUMBER ,
  p_tr_org_unit_cd              IN VARCHAR2 ,
  p_tr_ou_start_dt              IN DATE ,
  p_eftsu                       IN NUMBER ,
  p_enrolled_dt                 IN DATE ,
  p_discontinued_dt             IN DATE ,
  p_govt_semester               IN NUMBER ,
  p_teach_census_dt             IN DATE ,
  p_load_cal_type               IN VARCHAR2 ,
  p_load_ci_sequence_number     IN NUMBER,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN VARCHAR2;

Procedure Stap_Get_Sca_Data(
  p_submission_yr  NUMBER ,
  p_submission_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_crv_version_number IN NUMBER ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N',
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_logged_ind IN OUT NOCOPY BOOLEAN ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  p_govt_semester IN NUMBER ,
  p_award_course_ind IN VARCHAR2 DEFAULT 'N',
  p_govt_citizenship_cd IN VARCHAR2 ,
  p_prior_seced_tafe IN VARCHAR2 ,
  p_prior_seced_school IN VARCHAR2 ,
  p_sca_commencement_dt OUT NOCOPY DATE ,
  p_prior_studies_exemption OUT NOCOPY NUMBER ,
  p_exemption_institution_cd OUT NOCOPY VARCHAR2 ,
  p_govt_exemption_inst_cd OUT NOCOPY VARCHAR2 ,
  p_tertiary_entrance_score OUT NOCOPY NUMBER ,
  p_basis_for_admission_type OUT NOCOPY VARCHAR2 ,
  p_govt_basis_for_adm_type OUT NOCOPY VARCHAR2 ,
  p_hecs_amount_pd OUT NOCOPY NUMBER ,
  p_hecs_payment_option OUT NOCOPY VARCHAR2 ,
  p_govt_hecs_payment_option OUT NOCOPY VARCHAR2 ,
  p_tuition_fee OUT NOCOPY NUMBER ,
  p_hecs_fee OUT NOCOPY NUMBER ,
  p_differential_hecs_ind OUT NOCOPY VARCHAR2 );

Function Stap_Get_Sch_Leaver(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N',
  p_collection_yr IN NUMBER )
RETURN NUMBER;

Function Stap_Get_Spclstn(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2;


END IGS_ST_GEN_003;

 

/
