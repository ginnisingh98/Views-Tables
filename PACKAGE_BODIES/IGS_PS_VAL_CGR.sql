--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CGR" AS
/* $Header: IGSPS21B.pls 115.5 2002/11/29 02:58:38 nsidana ship $ */

  --
  -- Validate the IGS_PS_COURSE group type for the IGS_PS_COURSE group.
  FUNCTION crsp_val_cgr_type(
  p_course_group_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_GRP_TYPE.closed_ind%TYPE;
  	CURSOR	c_course_group_type IS
  		SELECT closed_ind
  		FROM   IGS_PS_GRP_TYPE
  		WHERE  course_group_type = p_course_group_type;
  BEGIN
  	OPEN c_course_group_type;
  	FETCH c_course_group_type INTO v_closed_ind;
  	IF c_course_group_type%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_course_group_type;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_course_group_type;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_PRGGRP_TYPE_CLOSED';
  		CLOSE c_course_group_type;
  		RETURN FALSE;
  	END IF;
  END crsp_val_cgr_type;

END IGS_PS_VAL_CGR;

/
