--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_GSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_GSE" AS
/* $Header: IGSST09B.pls 115.4 2002/11/29 04:12:14 nsidana ship $ */
  --
  -- Validate the government snapshot.
  FUNCTION stap_val_govt_snpsht(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_gsc_count	NUMBER;
  	CURSOR c_gsc IS
  		SELECT	count(*)
  		FROM	IGS_ST_GVT_SPSHT_CTL	gsc
  		WHERE	gsc.submission_yr = p_submission_yr AND
  			gsc.submission_number = p_submission_number AND
  			gsc.completion_dt IS NOT NULL;
  BEGIN
  	--Validate update, insert or delete of the government snapshot tables.
  	--This routine will be called from the triggers for the associated tables.
  	--Check the snapshot is complete.
  	OPEN c_gsc;
  	FETCH c_gsc INTO v_gsc_count;
  	CLOSE c_gsc;
  	IF v_gsc_count > 0 THEN
  		p_message_name := 'IGS_ST_GOVT_SNAP_DET_NOT_ALL';
  		RETURN FALSE;
  	END IF;
  	--- Set the default message number
  	p_message_name := NULL;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GSE.stap_val_govt_snpsht');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  END stap_val_govt_snpsht;
END IGS_ST_VAL_GSE;

/
