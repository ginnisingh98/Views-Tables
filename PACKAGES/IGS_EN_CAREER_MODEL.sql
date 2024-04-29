--------------------------------------------------------
--  DDL for Package IGS_EN_CAREER_MODEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_CAREER_MODEL" AUTHID CURRENT_USER AS
/* $Header: IGSEN86S.pls 115.4 2002/11/29 00:12:09 nsidana noship $ */

  FUNCTION ENRP_GET_SEC_SCA_STATUS(
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_course_attempt_status IN VARCHAR2 ,
    p_primary_program_type IN VARCHAR2,
    p_primary_prog_type_source IN VARCHAR2,
    p_course_type IN VARCHAR2 ,
    p_new_primary_course_cd  IN VARCHAR2 DEFAULT NULL
  )RETURN VARCHAR2;


  PROCEDURE SCA_TBH_BEFORE_DML(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_version_number IN NUMBER,
    p_old_course_attempt_status IN VARCHAR2 ,
    p_new_course_attempt_status IN OUT NOCOPY VARCHAR2 ,
    p_primary_program_type IN OUT NOCOPY VARCHAR2,
    p_primary_prog_type_source IN OUT NOCOPY VARCHAR2,
    p_new_key_program  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE SCA_TBH_AFTER_DML(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_version_number IN NUMBER,
    p_old_course_attempt_status IN VARCHAR2 ,
    p_new_course_attempt_status IN VARCHAR2 ,
    p_primary_prog_type_source IN VARCHAR2,
    p_old_pri_prog_type IN VARCHAR2,
    p_new_pri_prog_type IN VARCHAR2 ,
    p_old_key_program  IN  VARCHAR2
   );

  FUNCTION ENRP_CHECK_FOR_ONE_PRIMARY (
    p_person_id IN NUMBER,
	p_course_type IN VARCHAR2,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

END IGS_EN_CAREER_MODEL;

 

/
