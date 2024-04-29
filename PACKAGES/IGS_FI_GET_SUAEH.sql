--------------------------------------------------------
--  DDL for Package IGS_FI_GET_SUAEH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GET_SUAEH" AUTHID CURRENT_USER AS
/* $Header: IGSFI07S.pls 115.8 2003/05/16 10:52:40 knaraset ship $ */
--
-- Who         When            What
-- knaraset  29-Apr-03   Modified r_t_suaeh_dtl to add uoo_id, as part of MUS build bug 2829262
--


  TYPE r_t_suaeh_dtl IS RECORD
  (			PERSON_ID                IGS_EN_SU_ATTEMPT_H_ALL.PERSON_ID%type,
			COURSE_CD                IGS_EN_SU_ATTEMPT_H_ALL.COURSE_CD%type,
			UNIT_CD                  IGS_EN_SU_ATTEMPT_H_ALL.UNIT_CD%type,
			VERSION_NUMBER           IGS_EN_SU_ATTEMPT_H_ALL.VERSION_NUMBER%type,
			CAL_TYPE                 IGS_EN_SU_ATTEMPT_H_ALL.CAL_TYPE%type,
			CI_SEQUENCE_NUMBER       IGS_EN_SU_ATTEMPT_H_ALL.CI_SEQUENCE_NUMBER%type,
			HIST_START_DT            IGS_EN_SU_ATTEMPT_H_ALL.HIST_START_DT%type,
			HIST_END_DT              IGS_EN_SU_ATTEMPT_H_ALL.HIST_END_DT%type,
			HIST_WHO                 IGS_EN_SU_ATTEMPT_H_ALL.HIST_WHO%type,
			LOCATION_CD              IGS_EN_SU_ATTEMPT_H_ALL.LOCATION_CD%type,
			UNIT_CLASS               IGS_EN_SU_ATTEMPT_H_ALL.UNIT_CLASS%type,
			ENROLLED_DT              IGS_EN_SU_ATTEMPT_H_ALL.ENROLLED_DT%type,
			UNIT_ATTEMPT_STATUS      IGS_EN_SU_ATTEMPT_H_ALL.UNIT_ATTEMPT_STATUS%type,
			ADMINISTRATIVE_UNIT_STATUS     IGS_EN_SU_ATTEMPT_H_ALL.ADMINISTRATIVE_UNIT_STATUS%type,
			AUS_DESCRIPTION                IGS_EN_SU_ATTEMPT_H_ALL.AUS_DESCRIPTION%type,
			DISCONTINUED_DT                IGS_EN_SU_ATTEMPT_H_ALL.DISCONTINUED_DT%type,
			RULE_WAIVED_DT                 IGS_EN_SU_ATTEMPT_H_ALL.RULE_WAIVED_DT%type,
			RULE_WAIVED_PERSON_ID          IGS_EN_SU_ATTEMPT_H_ALL.RULE_WAIVED_PERSON_ID%type,
			NO_ASSESSMENT_IND              IGS_EN_SU_ATTEMPT_H_ALL.NO_ASSESSMENT_IND%type,
			EXAM_LOCATION_CD               IGS_EN_SU_ATTEMPT_H_ALL.EXAM_LOCATION_CD%type,
			ELO_DESCRIPTION                IGS_EN_SU_ATTEMPT_H_ALL.ELO_DESCRIPTION%type,
			SUP_UNIT_CD                    IGS_EN_SU_ATTEMPT_H_ALL.SUP_UNIT_CD%type,
			SUP_VERSION_NUMBER             IGS_EN_SU_ATTEMPT_H_ALL.SUP_VERSION_NUMBER%type,
			ALTERNATIVE_TITLE              IGS_EN_SU_ATTEMPT_H_ALL.ALTERNATIVE_TITLE%type,
			OVERRIDE_ENROLLED_CP           IGS_EN_SU_ATTEMPT_H_ALL.OVERRIDE_ENROLLED_CP%type,
			OVERRIDE_EFTSU                 IGS_EN_SU_ATTEMPT_H_ALL.OVERRIDE_EFTSU%type,
			OVERRIDE_ACHIEVABLE_CP         IGS_EN_SU_ATTEMPT_H_ALL.OVERRIDE_ACHIEVABLE_CP%type,
			OVERRIDE_OUTCOME_DUE_DT        IGS_EN_SU_ATTEMPT_H_ALL.OVERRIDE_OUTCOME_DUE_DT%type,
			OVERRIDE_CREDIT_REASON         IGS_EN_SU_ATTEMPT_H_ALL.OVERRIDE_CREDIT_REASON%type,
			CREATED_BY                     IGS_EN_SU_ATTEMPT_H_ALL.CREATED_BY%type,
			CREATION_DATE                  IGS_EN_SU_ATTEMPT_H_ALL.CREATION_DATE%type,
			LAST_UPDATED_BY                IGS_EN_SU_ATTEMPT_H_ALL.LAST_UPDATED_BY%type,
			LAST_UPDATE_DATE               IGS_EN_SU_ATTEMPT_H_ALL.LAST_UPDATE_DATE%type,
			LAST_UPDATE_LOGIN              IGS_EN_SU_ATTEMPT_H_ALL.LAST_UPDATE_LOGIN%type,
			DCNT_REASON_CD                 IGS_EN_SU_ATTEMPT_H_ALL.DCNT_REASON_CD%type,
			ORG_ID                         IGS_EN_SU_ATTEMPT_H_ALL.ORG_ID%type,
            UOO_ID                         IGS_EN_SU_ATTEMPT_H_ALL.UOO_ID%type
  );



  TYPE t_suaeh_dtl IS TABLE OF r_t_suaeh_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  gt_empty_table t_suaeh_dtl;
  --
  --
  gt_suaeh_table t_suaeh_dtl;
  --
  --
  gv_table_index BINARY_INTEGER;
  --
  --
  gv_person_id igs_pe_person.person_id%TYPE;
  --
  --
  gv_course_cd IGS_PS_COURSE.COURSE_CD%TYPE;
  --
  --
  gv_unit_cd IGS_PS_UNIT.UNIT_CD%TYPE;
  --
  --
  gv_effective_dt DATE;
  --
  -- Routine to save SUA effective history data in a PL/SQL TABLE.
  PROCEDURE FINP_GET_SUAEH(
  p_person_id IN NUMBER ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_unit_cd IN IGS_PS_UNIT.unit_cd%TYPE ,
  p_effective_dt IN DATE ,
  p_table_index IN OUT NOCOPY BINARY_INTEGER ,
  p_suaeh_table IN OUT NOCOPY IGS_FI_GET_SUAEH.t_suaeh_dtl)
;
END IGS_FI_GET_SUAEH;

 

/
