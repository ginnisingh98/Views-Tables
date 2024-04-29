--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_008" AUTHID CURRENT_USER AS
/* $Header: IGSAS48S.pls 115.3 2003/11/04 13:41:19 msrinivi noship $ */

FUNCTION student_cohort(grading_period  	in varchar2,
			person_id 		in number,
			unit_cd 		in varchar2,
			course_cd 		in varchar2,
			load_cal_type		in varchar2,
			load_ci_sequence_number in number) RETURN VARCHAR2;

FUNCTION repeat_grades_exist( 	p_person_id		IGS_AS_SU_STMPTOUT_ALL.person_id%TYPE,
			 	p_unit_cd		IGS_AS_SU_STMPTOUT_ALL.unit_cd%TYPE,
			   	p_course_cd		IGS_AS_SU_STMPTOUT_ALL.course_cd%TYPE,
			   	p_cal_type		IGS_AS_SU_STMPTOUT_ALL.cal_type%TYPE,
			   	p_ci_sequence_number	IGS_AS_SU_STMPTOUT_ALL.ci_sequence_number%TYPE,
                                -- anilk, 22-Apr-2003, Bug# 2829262
				p_uoo_id                IGS_AS_SU_STMPTOUT_ALL.uoo_id%TYPE) RETURN VARCHAR2;

FUNCTION Get_Occur_details
(
    p_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE,
    p_occurs_id IGS_PS_USEC_OCCURS.UNIT_SECTION_OCCURRENCE_ID%TYPE
)
RETURN VARCHAR2 ;

END IGS_AS_GEN_008;

 

/
