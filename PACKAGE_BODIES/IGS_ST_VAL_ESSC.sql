--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_ESSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_ESSC" AS
/* $Header: IGSST06B.pls 115.5 2002/11/29 04:11:31 nsidana ship $ */

  --
  -- Validate the setting of the delete of an enrolment statistics snapshot
  FUNCTION stap_val_essc_delete(
  p_snapshot_dt_time IN DATE ,
  p_delete_snapshot_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR 	c_govt_snapshot_ctl(
  			cp_snapshot_dt_time IGS_EN_ST_SNAPSHOT.snapshot_dt_time%TYPE) IS
  		SELECT	gsc.submission_yr
  		FROM	IGS_ST_GVT_SPSHT_CTL gsc
  		WHERE	gsc.ess_snapshot_dt_time = cp_snapshot_dt_time;
  BEGIN
  	--  This module validates the setting of the
  	-- IGS_EN_ST_SPSHT_CTL.delete_snapshot_ind.
  	--  If the enrolment statistics snapshot is used by a government snapshot then
  	--  it cannot be marked for delete.
  	p_message_name := null;
  	-- Validate input parameters.
  	IF(p_snapshot_dt_time IS NULL OR
  		p_delete_snapshot_ind <> 'Y') THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate if the enrolment statistics snapshot is used by a government
  	-- snapshot.
  	FOR v_govt_snapshot_ctl_rec IN c_govt_snapshot_ctl(
  							p_snapshot_dt_time) LOOP
  		p_message_name  := 'IGS_ST_CANT_DEL_ENRL_STAT';
  		RETURN FALSE;
  	END LOOP;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_ESSC.stap_val_essc_deleten');
		IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
  END;
  END stap_val_essc_delete;
END IGS_ST_VAL_ESSC;

/
