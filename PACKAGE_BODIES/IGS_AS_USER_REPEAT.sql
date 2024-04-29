--------------------------------------------------------
--  DDL for Package Body IGS_AS_USER_REPEAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_USER_REPEAT" AS
/* $Header: IGSAS46B.pls 115.1 2003/05/28 08:17:56 anilk noship $ */

PROCEDURE user_repeat_process (	 p_person_id			IN NUMBER,
			       	 p_course_cd			IN VARCHAR2,
  			       	 p_unit_cd			IN VARCHAR2,
 			       	 p_teach_cal_type		IN VARCHAR2,
				 p_teach_ci_sequence_number	IN NUMBER,
				 p_outcome_dt			IN DATE,
				 p_grading_schema_cd		IN VARCHAR2,
				 p_version_number		IN NUMBER,
				 p_grade			IN VARCHAR2,
                                 -- anilk, 22-Apr-2003, Bug# 2829262
				 p_uoo_id                       IN NUMBER)
IS
BEGIN -- user_repeat_processS
	-- User Hook procedure to allow users to use their own logic for repeat processing.
	-- If there is no Institution specific repeat processing this procedure should remain empty

	RETURN;

END user_repeat_process;

END IGS_AS_USER_REPEAT;

/
