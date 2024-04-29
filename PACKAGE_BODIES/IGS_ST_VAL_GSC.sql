--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_GSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_GSC" AS
 /* $Header: IGSST08B.pls 115.5 2002/11/29 04:12:00 nsidana ship $ */
--

  -- Validate the government snapshot control snapshot date time.
  FUNCTION stap_val_gsc_sdt(
  p_submission_yr IN NUMBER ,
  p_snapshot_dt_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_delete_snapshot_ind	IGS_EN_ST_SPSHT_CTL.delete_snapshot_ind%TYPE;
  	v_submission_yr		IGS_ST_GVT_SPSHT_CTL.submission_yr%TYPE;
  	CURSOR 	c_essc(
  			cp_snapshot_dt_time IGS_ST_GVT_SPSHT_CTL.ess_snapshot_dt_time%TYPE) IS
  		SELECT	essc.delete_snapshot_ind
  		FROM	IGS_EN_ST_SPSHT_CTL essc
  		WHERE	essc.snapshot_dt_time = cp_snapshot_dt_time;
  	CURSOR 	c_gsc(
  			cp_snapshot_dt_time IGS_ST_GVT_SPSHT_CTL.ess_snapshot_dt_time%TYPE,
  			cp_submission_yr IGS_ST_GVT_SPSHT_CTL.submission_yr%TYPE) IS
  		SELECT	gsc.submission_yr
  		FROM	IGS_ST_GVT_SPSHT_CTL gsc
  		WHERE	gsc.ess_snapshot_dt_time = cp_snapshot_dt_time AND
  			gsc.submission_yr <> cp_submission_yr;
  BEGIN
  	--  Validate the IGS_ST_GVT_SPSHT_CTL.snapshot_dt_time.
  	--  An Enrolment Statistics Snapshot which is marked for delete cannot
  	--  be used by a Government Snapshot.
  	--  An Enrolment Statistics Snapshot which is used by another Government
  	--  Snapshot submission in another year cannot be used by a Government
  	--  Snapshot.
  	p_message_name := NULL;
  	-- Retrieve the Enrolment Statistics Snapshot Control data.
  	OPEN	c_essc(
  			p_snapshot_dt_time);
  	FETCH	c_essc INTO v_delete_snapshot_ind;
  	IF(c_essc%FOUND = TRUE) THEN
  		-- Validate the Enrolment Statistics Snapshot.
  		IF(v_delete_snapshot_ind = 'Y') THEN
  			CLOSE c_essc;
  			p_message_name := 'IGS_ST_CANT_USE_ENRL_STATIST';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_essc;
  	-- Retrieve the Government Snapshot Control data.
  	OPEN	c_gsc(
  			p_snapshot_dt_time,
  			p_submission_yr);
  	FETCH	c_gsc INTO v_submission_yr;
  	IF(c_gsc%FOUND = TRUE) THEN
  		CLOSE c_gsc;
  		p_message_name := 'IGS_ST_ENRL_STAT_SNAP_IN_USE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gsc;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GSC.stap_val_gsc_sdt');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  END;
  END stap_val_gsc_sdt;
  --
  -- Validate the update of government snapshot control snapshot date time.
  FUNCTION stap_val_gsc_sdt_upd(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_submission_yr		IGS_ST_GVT_SPSHT_CTL.submission_yr%TYPE;
  	CURSOR 	c_gsc(
  			cp_submission_yr IGS_ST_GVT_SPSHT_CTL.submission_yr%TYPE,
  			cp_submission_number IGS_ST_GVT_SPSHT_CTL.submission_number%TYPE) IS
  		SELECT	gsc.submission_yr
  		FROM	IGS_ST_GVT_SPSHT_CTL gsc
  		WHERE	gsc.submission_yr = cp_submission_yr AND
  			gsc.submission_number = cp_submission_number AND
  			gsc.completion_dt IS NOT NULL;
  BEGIN
  	--  Validate update of the IGS_ST_GVT_SPSHT_CTL.ess_snapshot_dt_time.
  	--  The IGS_ST_GVT_SPSHT_CTL.ess_snapshot_dt_time cannot be updated if the
  	--  govt_snapshot_ctlcompletion_dt is set.
  	p_message_name := NULL;
  	-- Retrieve the Government Snapshot control data.
  	OPEN	c_gsc(
  			p_submission_yr,
  			p_submission_number);
  	FETCH	c_gsc INTO v_submission_yr;
  	IF(c_gsc%FOUND = TRUE) THEN
  		CLOSE c_gsc;
  		p_message_name := 'IGS_ST_GOVT_SNAPSHOT_COMPLETE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gsc;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GSC.stap_val_gsc_sdt_upd');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  END;
  END stap_val_gsc_sdt_upd;
END IGS_ST_VAL_GSC;

/
