--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CGT" AS
/* $Header: IGSPS22B.pls 115.4 2002/11/29 02:58:59 nsidana ship $ */

  -- Validate the IGS_PS_COURSE group type system IGS_PS_COURSE group type.
  FUNCTION crsp_val_cgt_sys_cgt(
  p_s_course_group_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_LOOKUPS_VIEW.closed_ind%TYPE;
  	CURSOR	c_s_course_group_type IS
  		SELECT closed_ind
  		FROM   IGS_LOOKUPS_VIEW
  		WHERE  lookup_code = p_s_course_group_type AND
			 lookup_type = 'COURSE_GROUP_TYPE';
  BEGIN
  	OPEN c_s_course_group_type;
  	FETCH c_s_course_group_type INTO v_closed_ind;
  	IF c_s_course_group_type%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_s_course_group_type;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_s_course_group_type;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_SYSGRP_TYPE_CLOSED';
  		CLOSE c_s_course_group_type;
  		RETURN FALSE;
  	END IF;
  END crsp_val_cgt_sys_cgt;
END IGS_PS_VAL_CGT;

/
