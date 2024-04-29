--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CGM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CGM" AS
/* $Header: IGSPS20B.pls 115.4 2002/11/29 02:58:17 nsidana ship $ */

  --
  -- Validate the IGS_PS_COURSE group member IGS_PS_COURSE group code.
  FUNCTION crsp_val_cgm_crs_grp(
  p_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_GRP.closed_ind%TYPE;
  	CURSOR	c_course_group IS
  		SELECT closed_ind
  		FROM   IGS_PS_GRP
  		WHERE  course_group_cd = p_course_group_cd;
  BEGIN
  	OPEN c_course_group;
  	FETCH c_course_group INTO v_closed_ind;
  	IF c_course_group%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_course_group;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_course_group;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_PRGGRP_CODE_CLOSED';
  		CLOSE c_course_group;
  		RETURN FALSE;
  	END IF;
  END crsp_val_cgm_crs_grp;
END IGS_PS_VAL_CGM;

/
