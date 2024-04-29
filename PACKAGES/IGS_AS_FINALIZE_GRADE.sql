--------------------------------------------------------
--  DDL for Package IGS_AS_FINALIZE_GRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_FINALIZE_GRADE" AUTHID CURRENT_USER AS
/* $Header: IGSAS47S.pls 120.0 2005/07/05 12:15:42 appldev noship $ */
PROCEDURE finalize_process( p_uoo_id			IN NUMBER,
			    p_person_id			IN NUMBER,
			    p_course_cd			IN VARCHAR2,
			    p_unit_cd			IN VARCHAR2,
			    p_teach_cal_type		IN VARCHAR2,
			    p_teach_ci_sequence_number	IN NUMBER);
PROCEDURE finalize_process_no_commit( p_uoo_id			IN NUMBER,
			    p_person_id			IN NUMBER,
			    p_course_cd			IN VARCHAR2,
			    p_unit_cd			IN VARCHAR2,
			    p_teach_cal_type		IN VARCHAR2,
			    p_teach_ci_sequence_number	IN NUMBER);
PROCEDURE get_translated_grade(	p_person_id			IN NUMBER,
				p_course_cd			IN VARCHAR2,
				p_unit_cd			IN VARCHAR2,
				p_teach_cal_type		IN VARCHAR2,
				p_teach_ci_sequence_number	IN NUMBER,
				p_grading_schema_cd		IN VARCHAR2,
				p_version_number		IN NUMBER,
				p_grade				IN VARCHAR2,
				p_mark				IN NUMBER,
				p_translated_grading_schema_cd	OUT NOCOPY VARCHAR2,
				p_translated_version_number	OUT NOCOPY NUMBER,
				p_translated_grade		OUT NOCOPY VARCHAR2,
				p_translated_dt			OUT NOCOPY DATE,
                                -- anilk, 22-Apr-2003, Bug# 2829262
				p_uoo_id                        IN NUMBER );
END IGS_AS_FINALIZE_GRADE ;

 

/
