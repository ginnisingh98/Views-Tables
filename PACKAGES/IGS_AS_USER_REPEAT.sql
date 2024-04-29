--------------------------------------------------------
--  DDL for Package IGS_AS_USER_REPEAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_USER_REPEAT" AUTHID CURRENT_USER AS
/* $Header: IGSAS46S.pls 115.1 2003/05/28 08:17:38 anilk noship $ */
PROCEDURE user_repeat_process(	p_person_id			IN NUMBER,
				p_course_cd			IN VARCHAR2,
				p_unit_cd			IN VARCHAR2,
				p_teach_cal_type		IN VARCHAR2,
				p_teach_ci_sequence_number	IN NUMBER,
				p_outcome_dt			IN DATE,
				p_grading_schema_cd		IN VARCHAR2,
				p_version_number		IN NUMBER,
				p_grade				IN VARCHAR2,
                                -- anilk, 22-Apr-2003, Bug# 2829262
				p_uoo_id                        IN NUMBER);
END IGS_AS_USER_REPEAT;

 

/
