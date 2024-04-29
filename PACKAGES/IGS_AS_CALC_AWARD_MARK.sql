--------------------------------------------------------
--  DDL for Package IGS_AS_CALC_AWARD_MARK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_CALC_AWARD_MARK" AUTHID CURRENT_USER AS
/* $Header: IGSAS57S.pls 120.1 2006/07/31 07:31:41 ijeddy noship $ */

  /*************************************************************
  Created By : smanglm
  Date Created on : 10-Oct-2003
  Purpose : This package is created as part iof Summary Measurement
            of attainment build.
	    This will have program unit to calculate
	    unit level marks,
	    award marks and honors level.
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

FUNCTION fn_calc_award_mark (p_person_id IN NUMBER,
                             p_course_cd IN VARCHAR2,
                             p_award_cd  IN VARCHAR2,
                             X_RETURN_STATUS OUT NOCOPY    VARCHAR2,
                             X_MSG_DATA      OUT NOCOPY    VARCHAR2,
                             X_MSG_COUNT     OUT NOCOPY    NUMBER) RETURN NUMBER ;

FUNCTION fn_derive_honors_level (p_person_id IN NUMBER,
                                 p_course_cd IN VARCHAR2,
			         p_award_cd  IN VARCHAR2 ) RETURN VARCHAR2;

PROCEDURE pr_calc_award_mark (p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
			      p_award_cd  IN VARCHAR2,
			      p_award_mark    OUT NOCOPY    NUMBER,
			      p_honors_level  OUT NOCOPY    VARCHAR2,
                   p_grading_schema_cd OUT NOCOPY    VARCHAR2,
                              p_version_number OUT NOCOPY NUMBER,
    		              X_RETURN_STATUS OUT NOCOPY    VARCHAR2,
                              X_MSG_DATA      OUT NOCOPY    VARCHAR2,
                              X_MSG_COUNT     OUT NOCOPY    NUMBER);

FUNCTION fn_calc_unit_lvl_mark (p_person_id     IN NUMBER,
                                 p_course_cd     IN VARCHAR2,
				 p_unit_level    IN VARCHAR2,
       		                 X_RETURN_STATUS OUT NOCOPY    VARCHAR2,
                                 X_MSG_DATA      OUT NOCOPY    VARCHAR2,
                                 X_MSG_COUNT     OUT NOCOPY    NUMBER) RETURN NUMBER;

FUNCTION get_mark (p_grading_schema_cd igs_as_su_stmptout.grading_schema_cd%TYPE,
                   p_gs_version_number igs_as_su_stmptout.version_number%TYPE,
		   p_grade             igs_as_su_stmptout.grade%TYPE) RETURN NUMBER;

FUNCTION get_earned_cp (p_person_id       igs_as_su_stmptout.person_id%TYPE,
                        p_course_cd       igs_as_su_stmptout.course_cd%TYPE,
			p_unit_cd         igs_as_su_stmptout.unit_cd%TYPE,
			p_version_number  igs_ps_unit_ver.version_number%TYPE,
			p_unit_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE,
			p_teach_cal_type  igs_ca_inst.cal_type%TYPE,
			p_teach_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
			p_uoo_id          igs_ps_unit_ofr_opt.uoo_id%TYPE,
			p_override_achievable_cp NUMBER DEFAULT NULL,
			p_override_enrolled_cp   NUMBER DEFAULT NULL) RETURN NUMBER;

Procedure upgrade_awards
( errbuff OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY NUMBER,
p_award_cd igs_ps_awd.AWARD_CD%TYPE

);
FUNCTION fn_ret_unit_lvl_mark (p_person_id     IN NUMBER,
                                 p_course_cd     IN VARCHAR2,
                                 p_unit_level    IN VARCHAR2
                                 ) RETURN NUMBER;

FUNCTION chk_if_excluded_unit (  p_uoo_id          IN igs_en_su_attempt_all.uoo_id%TYPE,
                                 p_unit_cd         IN  igs_en_su_attempt_all.unit_cd%TYPE,
                                 p_version_number  IN  igs_en_su_attempt_all.version_number%TYPE
                              ) RETURN VARCHAR2;


END igs_as_calc_award_mark;

 

/
