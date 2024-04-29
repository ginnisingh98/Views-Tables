--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSAS03S.pls 120.0 2005/07/05 12:12:27 appldev noship $ */

 FUNCTION assp_get_ai_ref(
            usaii in igs_ps_unitass_item.unit_section_ass_item_id%type,
            uaii in igs_as_unitass_item.unit_ass_item_id%type
 )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_ai_ref,WNDS,WNPS);

 FUNCTION assp_get_ai_reldate(
            usaii in igs_ps_unitass_item.unit_section_ass_item_id%type,
            uaii in igs_as_unitass_item.unit_ass_item_id%type
 )
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(assp_get_ai_reldate,WNDS,WNPS);


 FUNCTION assp_get_sua_exam_tp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_sua_exam_tp,WNDS,WNPS);
 FUNCTION assp_get_sua_exloc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(assp_get_sua_exloc,WNDS,WNPS);
FUNCTION assp_get_sua_grade(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_sua_grade,WNDS,WNPS);
 FUNCTION assp_get_sua_gs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_grading_schema OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER )
RETURN boolean ;
PRAGMA RESTRICT_REFERENCES(assp_get_sua_gs,WNDS);
 FUNCTION assp_get_sua_outcome(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_outcome_dt OUT NOCOPY DATE ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  p_mark OUT NOCOPY NUMBER ,
  p_origin_course_cd OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER ,
  p_use_released_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_sua_outcome,WNDS,WNPS);
 FUNCTION assp_get_supp_cal(
  p_exam_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_exam_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_person_id IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_version_number IN IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_cal_type IN IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_unit_attempt_status IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_location_cd IN IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_unit_mode IN IGS_AS_UNIT_CLASS_ALL.unit_mode%TYPE ,
  p_unit_class IN IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE ,
  p_ass_id IN IGS_AS_UNITASS_ITEM_ALL.ass_id%TYPE )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_supp_cal,WNDS,WNPS);
 FUNCTION assp_get_trn_sua_out(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_final_outcome IN VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;

 FUNCTION assp_get_uai_due_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(assp_get_uai_due_dt,WNDS,WNPS);
 FUNCTION assp_get_uai_ref(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_uai_ref,WNDS,WNPS);

FUNCTION assp_get_spcl_needs(
  p_person_id IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_spcl_needs,WNDS);

PROCEDURE get_default_grds(
    x_unit_cd                      IN  VARCHAR2,
    x_version_number               IN  NUMBER,
    x_assessment_type              IN  VARCHAR2,
    x_grading_schema_cd		   OUT NOCOPY VARCHAR2,
    x_gs_version_number		   OUT NOCOPY NUMBER,
    x_description		   OUT NOCOPY VARCHAR2,
    x_approved		           OUT NOCOPY VARCHAR2
  );
PROCEDURE assp_get_suaai_gs(
    p_person_id                 IN  NUMBER,
    p_course_cd                 IN  VARCHAR2,
    p_unit_cd                   IN  VARCHAR2,
    p_cal_type                  IN  VARCHAR2,
    p_ci_sequence_number        IN  NUMBER,
    p_ass_id                    IN  VARCHAR2,
    p_grading_schema_cd         OUT NOCOPY VARCHAR2,
    p_gs_version_number         OUT NOCOPY NUMBER,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                    IN  NUMBER );

FUNCTION getStdntCareerPrograms(
   P_PERSON_ID IN IGS_EN_STDNT_PS_ATT.person_id%TYPE ,
   P_PROGRAM_TYPE IN IGS_PS_VER_ALL.course_type%TYPE ) RETURN VARCHAR2 ;

FUNCTION getStdntCareerProgsBetween(
   P_PERSON_ID IN igs_en_stdnt_ps_att.person_id%TYPE ,
   P_COURSE_CD IN igs_en_stdnt_ps_att.course_cd%TYPE ,
   P_TERM_START_DATE IN DATE ,
   P_TERM_END_DATE IN DATE ) RETURN VARCHAR2 ;

FUNCTION getStdntPrograms(
   P_PERSON_ID IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE ,
   P_PROGRAM_CD IGS_PS_VER_ALL.COURSE_CD%TYPE ) RETURN VARCHAR2 ;

FUNCTION getStdntProgsBetween(
        P_PERSON_ID igs_en_stdnt_ps_att.person_id%type ,
        P_program_cd igs_ps_ver_all.course_type%type ,
        p_term_start_date DATE ,
        p_term_end_date DATE ) RETURN VARCHAR2 ;

PROCEDURE get_current_term (
   p_person_id   IN              NUMBER,
   p_course_cd   IN              VARCHAR2,
   p_cal_type    OUT NOCOPY      VARCHAR2,
   p_seq_num     OUT NOCOPY      NUMBER
);
FUNCTION get_spat_att_type_desc (
            p_person_id IN NUMBER,
            p_program_cd IN VARCHAR2
	    ) RETURN VARCHAR2;


FUNCTION get_spat_att_mode_desc(
	p_person_id IN NUMBER,
	p_program_cd IN VARCHAR2
	) RETURN VARCHAR2;

FUNCTION get_spat_location_desc(
	p_person_id IN NUMBER,
	p_program_cd IN VARCHAR2
	) RETURN VARCHAR2;
FUNCTION assp_get_sua_rel_grade(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(assp_get_sua_rel_grade,WNDS,WNPS);
FUNCTION assp_get_sua_rel_marks(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  p_uoo_id IN NUMBER )
RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(assp_get_sua_rel_marks,WNDS,WNPS);
END  IGS_AS_GEN_003 ;

 

/
