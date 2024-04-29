--------------------------------------------------------
--  DDL for Package IGS_ST_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSST02S.pls 115.7 2002/11/29 04:10:05 nsidana ship $ */

/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        05-MAR-2002     Bug NO: 2224621
  ||                                 Modified P_GOVT_PRIOR_UG_INST from NUMBER to VARCHAR2 in STAP_GET_PERSON_DATA. Since its source
  ||                                 IGS_OR_INSTITUTION.GOVT_INSTITUTION_CD is modified from NUMBER to VARCHAR2.
  ||  (reverse chronological order - newest change first)
*/

Function Stap_Get_Course_Lvl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_govt_course_type IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(STAP_GET_COURSE_LVL,WNDS);

Procedure Stap_Get_Crs_Study(
  p_course_cd  IGS_PS_VER_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_VER_ALL.version_number%TYPE ,
  p_reference_cd OUT NOCOPY IGS_PS_REF_CD.reference_cd%TYPE ,
  p_description OUT NOCOPY IGS_PS_VER_ALL.title%TYPE );

Function Stap_Get_Govt_Ou_Cd(
  p_org_unit_cd IN VARCHAR2 )
RETURN VARCHAR2;

Function Stap_Get_Govt_Sem(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(STAP_GET_GOVT_SEM,WNDS);

Function Stap_Get_New_Hgh_Edu(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER;

Procedure Stap_Get_Pcc_Pe_Dtl(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_birth_dt OUT NOCOPY DATE ,
  p_sex OUT NOCOPY VARCHAR2 ,
  p_govt_aborig_torres_cd OUT NOCOPY NUMBER ,
  p_govt_citizenship_cd OUT NOCOPY NUMBER ,
  p_govt_birth_country_cd OUT NOCOPY VARCHAR2 ,
  p_yr_arrival OUT NOCOPY VARCHAR2 ,
  p_govt_home_language_cd OUT NOCOPY NUMBER );

Procedure Stap_Get_Person_Data(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N',
  p_logged_ind IN OUT NOCOPY BOOLEAN ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  p_birth_dt OUT NOCOPY DATE ,
  p_sex OUT NOCOPY VARCHAR2 ,
  p_aborig_torres_cd OUT NOCOPY VARCHAR2 ,
  p_govt_aborig_torres_cd OUT NOCOPY NUMBER ,
  p_citizenship_cd OUT NOCOPY VARCHAR2 ,
  p_govt_citizenship_cd OUT NOCOPY NUMBER ,
  p_perm_resident_cd OUT NOCOPY VARCHAR2 ,
  p_govt_perm_resident_cd OUT NOCOPY NUMBER ,
  p_home_location_cd OUT NOCOPY VARCHAR2 ,
  p_govt_home_location_cd OUT NOCOPY VARCHAR2 ,
  p_term_location_cd OUT NOCOPY VARCHAR2 ,
  p_govt_term_location_cd OUT NOCOPY VARCHAR2 ,
  p_birth_country_cd OUT NOCOPY VARCHAR2 ,
  p_govt_birth_country_cd OUT NOCOPY VARCHAR2 ,
  p_yr_arrival OUT NOCOPY VARCHAR2 ,
  p_home_language_cd OUT NOCOPY VARCHAR2 ,
  p_govt_home_language_cd OUT NOCOPY NUMBER ,
  p_prior_ug_inst OUT NOCOPY VARCHAR2 ,
  p_govt_prior_ug_inst OUT NOCOPY VARCHAR2 ,
  p_prior_other_qual OUT NOCOPY VARCHAR2 ,
  p_prior_post_grad OUT NOCOPY VARCHAR2 ,
  p_prior_degree OUT NOCOPY VARCHAR2 ,
  p_prior_subdeg_notafe OUT NOCOPY VARCHAR2 ,
  p_prior_subdeg_tafe OUT NOCOPY VARCHAR2 ,
  p_prior_seced_tafe OUT NOCOPY VARCHAR2 ,
  p_prior_seced_school OUT NOCOPY VARCHAR2 ,
  p_prior_tafe_award OUT NOCOPY VARCHAR2 ,
  p_govt_disability OUT NOCOPY VARCHAR2 );


END IGS_ST_GEN_002;

 

/
