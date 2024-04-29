--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_GS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_GS" AS
/* $Header: IGSAS23B.pls 115.4 2002/11/28 22:45:11 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  -------------------------------------------------------------------------------------------
  --
  -- Validate for one open version of grading schema
  FUNCTION assp_val_gs_one_open(
  p_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_gs_count(
  			cp_grading_schema_cd		IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE,
  			cp_version_number		IGS_AS_GRD_SCHEMA.version_number%TYPE) IS
  		SELECT 	COUNT(*)
  		FROM 	IGS_AS_GRD_SCHEMA
  		WHERE 	grading_schema_cd = cp_grading_schema_cd AND
  			version_number <> cp_version_number AND
  			end_dt IS NULL;
  	v_gs_count		   	NUMBER;
  BEGIN
  	-- Validate for one open version of a grading schema.
  	-- Ensure that only one version of a grading schema is open, otherwise
  	-- generate an error message.
  	p_message_name := null;
  	v_gs_count := 0;
  	OPEN c_gs_count(
  			p_grading_schema_cd,
  			p_version_number);
  	FETCH c_gs_count INTO v_gs_count;
  	IF c_gs_count%NOTFOUND THEN
  		CLOSE c_gs_count;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_gs_count;
  	IF v_gs_count > 0 THEN
  		p_message_name := 'IGS_AS_MULTIPLE_VER_GRDSCHEMA';
  		RETURN FALSE;
  	END IF;
  	-- Successful completion
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GS.assp_val_gs_one_open');
	       IGS_GE_MSG_STACK.ADD;
       	       App_Exception.Raise_Exception;
  END assp_val_gs_one_open;
  --
  -- Validate for overlapping dates for grading schemas
  FUNCTION assp_val_gs_ovrlp(
  p_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_start_dt IN IGS_AS_GRD_SCHEMA.start_dt%TYPE ,
  p_end_dt IN IGS_AS_GRD_SCHEMA.end_dt%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
    	gv_other_detail		VARCHAR2(255);
    BEGIN
    DECLARE
    	CURSOR c_gs IS
    		SELECT	start_dt,
    			NVL(end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))
    		FROM	IGS_AS_GRD_SCHEMA
    		WHERE	grading_schema_cd = p_grading_schema_cd AND
    			version_number <> p_version_number;
    	v_gs_rec			c_gs%ROWTYPE;
    	v_error_flag		BOOLEAN;
  	v_start_dt	IGS_AS_GRD_SCHEMA.start_dt%TYPE;
  	v_end_dt	IGS_AS_GRD_SCHEMA.end_dt%TYPE;
  	v_p_end_dt	IGS_AS_GRD_SCHEMA.end_dt%TYPE;
  BEGIN
  	p_message_name := null;
  	-- set p_end_dt to a high date if null
  	v_p_end_dt := NVL(p_end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'));
  	OPEN c_gs;
  	-- Validation will fail if any of the following are true
  	LOOP
  		EXIT WHEN (c_gs%NOTFOUND);
  		FETCH c_gs INTO v_start_dt,
  				v_end_dt;
  		-- (a)  The current start date is between an existing date range.
  		IF (p_start_dt >= v_start_dt AND
  				p_start_dt <= v_end_dt) THEN
  			CLOSE c_gs;
  			p_message_name := 'IGS_AS_DO_STDT_EXIST_DT_RANGE';
  			RETURN FALSE;
  		END IF;
  		-- (b)  The current end date is between an existing date range.
  		IF (v_p_end_dt >= v_start_dt AND
  				v_p_end_dt <= v_end_dt) THEN
  			CLOSE c_gs;
  			p_message_name := 'IGS_AS_DO_ENDT_EXIST_DT_RANGE';
  			RETURN FALSE;
  		END IF;
  		-- (c)  The current dates overlap an entire existing date range.
  		IF (p_start_dt <= v_start_dt AND
  				v_p_end_dt >= v_end_dt) THEN
  			CLOSE c_gs;
  			p_message_name := 'IGS_AS_DO_DATE_OVERLAP_DTRANG';
  			Return FALSE;
  		END IF;
  	END LOOP;
  	CLOSE c_gs;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GS.assp_val_gs_ovrlp');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_gs_ovrlp;
  --

END IGS_AS_VAL_GS;

/
