--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_GDHC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_GDHC" AS
 /* $Header: IGSST07B.pls 115.4 2002/11/29 04:11:45 nsidana ship $ */
 --
  -- Ensure the start and end dates don't overlap with other records.
  FUNCTION stap_val_gdhc_ovrlp(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR  c_gdhc_rec IS
  	SELECT	gdhc.start_dt,
  		gdhc.end_dt
  	FROM	IGS_FI_GV_DSP_HEC_CN gdhc
  	WHERE	gdhc.govt_discipline_group_cd = p_govt_discipline_group_cd AND
  		gdhc.start_dt <> p_start_dt;
  BEGIN
  	-- this module validates the IGS_FI_GV_DSP_HEC_CN table
  	-- to ensure that for records with the same
  	-- govt_discipline_group_cd and govt_hecs_cntrbtn_band that
  	-- the data ranges don't overlap
  	--- Set the default message number
  	p_message_name := NULL;
  	-- looping through the records validating for data overlaps
  	-- do not validate against the record passed in
  	FOR v_gdhc_rec IN c_gdhc_rec LOOP
  		IF (v_gdhc_rec.end_dt IS NOT NULL) THEN
  			IF (p_start_dt BETWEEN v_gdhc_rec.start_dt AND v_gdhc_rec.end_dt) THEN
  				p_message_name := 'IGS_ST_ST_DT_BETW_ST_END_DATE';
  				RETURN FALSE;
  			END IF;
  			IF (p_end_dt IS NOT NULL) THEN
  				IF (p_end_dt BETWEEN v_gdhc_rec.start_dt AND v_gdhc_rec.end_dt) THEN
  					p_message_name := 'IGS_ST_END_DT_BETW_ST_END_DT';
  					RETURN FALSE;
  				END IF;
  				IF (p_start_dt <= v_gdhc_rec.start_dt AND
  						p_end_dt >= v_gdhc_rec.end_dt) THEN
  					p_message_name := 'IGS_ST_DT_OVERLAP_GROUP_CODE';
  					RETURN FALSE;
  				END IF;
  			ELSE -- p_end_dt IS NULL
  				IF (p_start_dt <= v_gdhc_rec.start_dt OR
  						p_start_dt <= v_gdhc_rec.end_dt) THEN
  					p_message_name := 'IGS_ST_OPEN_DT_RANGE_OVERLAPS';
  					RETURN FALSE;
  				END IF;
  			END IF;
  		ELSE
  			IF (p_start_dt >= v_gdhc_rec.start_dt OR
  					p_end_dt >= v_gdhc_rec.start_dt) THEN
  				p_message_name := 'IGS_ST_DT_OVERLAP_WITH_ST_DT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GDHC.stap_val_gdhc_ovrlp');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  END;
  END stap_val_gdhc_ovrlp;
  --
  --
  -- Validate that only one record has an open end date.
  FUNCTION stap_val_gdhc_open(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	-- this module validates the IGS_FI_GV_DSP_HEC_CN table
  	-- to ensure that for records with the same
  	-- govt_discipline_group_cd and govt_hecs_cntrbtn_band that
  	-- only one record has a NULL end_dt
  DECLARE
  	v_start_dt		DATE;
  	CURSOR 	c_gdhc_rec IS
  	SELECT	gdhc.start_dt
  	FROM	IGS_FI_GV_DSP_HEC_CN gdhc
  	WHERE	gdhc.govt_discipline_group_cd = p_govt_discipline_group_cd AND
  		gdhc.start_dt <> p_start_dt AND
  		gdhc.end_dt IS NULL;
  BEGIN
  	-- set the default message number
  	p_message_name := NULL;
  	-- select all organisational units
  	OPEN  c_gdhc_rec;
  	FETCH c_gdhc_rec INTO v_start_dt;
  	IF (c_gdhc_rec%NOTFOUND) THEN
  		CLOSE c_gdhc_rec;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_gdhc_rec;
  		p_message_name := 'IGS_ST_ENTER_END_DATE';
  		RETURN FALSE;
  	END IF;
  	-- set the default return type
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GDHC.stap_val_gdhc_open');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
     END;
  END stap_val_gdhc_open;
  --
  -- Ensure the govt discipline group id not closed.
  FUNCTION stap_val_gdhc_gd(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR c_gd IS
  		SELECT	gd.closed_ind
  		FROM	IGS_PS_GOVT_DSCP gd
  		WHERE	gd.govt_discipline_group_cd = p_govt_discipline_group_cd;
  	v_closed_ind		IGS_PS_GOVT_DSCP.closed_ind%TYPE;
  BEGIN
  	--- Validate the govt_discipline_group_cd in the IGS_FI_GV_DSP_HEC_CN is
  	--- not closed.
  	--- Set the message number and return false to indicate that the government
  	--- discipline group is closed.
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_gd;
  	FETCH c_gd INTO v_closed_ind;
  	IF c_gd%NOTFOUND THEN
  		CLOSE c_gd;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_gd;
  	IF v_closed_ind = 'Y' THEN
  		p_message_name := 'IGS_FI_GOVTDISC_GRPCD_CLOSED' ;
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GDHC.stap_val_gdhc_gd');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
      END stap_val_gdhc_gd;
  --
  -- Validate that end date is null or >= start date.
  FUNCTION stap_val_gdhc_end_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	-- this module validates the IGS_FI_GV_DSP_HEC_CN table
  	-- to ensure that if the end_dt is not null, it is greater
  	-- than or equal to the start_dt
  DECLARE
  BEGIN
  	-- set the default message number
  	p_message_name := NULL;
  	IF (p_end_dt IS NOT NULL) THEN
  		-- checking if the end_dt is less
  		-- than the start_dt, and if it is,
  		-- set the message number
  		IF (p_end_dt < p_start_dt) THEN
  			p_message_name := 'IGS_GE_END_DT_GE_ST_DATE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- set the default return type
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GDHC.stap_val_gdhc_end_dt');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  END;
  END stap_val_gdhc_end_dt;
END IGS_ST_VAL_GDHC;

/
