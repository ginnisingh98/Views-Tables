--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_VEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_VEA" AS
/* $Header: IGSAS38B.pls 115.7 2002/11/28 22:48:44 nsidana ship $ */

--
-- bug id : 1956374
-- sjadhav ,29-aug-2001
-- removed function enrp_val_pc_closed
--
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 . The function genp_val_strt_end_dt removed
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function orgp_val_addr_type removed
  -------------------------------------------------------------------------------------------
  -- Retrofitted
  FUNCTION assp_val_vea_coraddr(
  p_venue_cd  IGS_AD_LOCVENUE_ADDR.LOCATION_venue_cd%TYPE ,
  p_addr_type  FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE ,
  p_start_dt  HZ_LOCATIONS.ADDRESS_EFFECTIVE_DATE%TYPE ,
  p_end_dt  HZ_LOCATIONS.ADDRESS_EXPIRATION_DATE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  	return_val		BOOLEAN;
  BEGIN	--assp_val_vea_coraddr
  	--This module validates that a IGS_GR_VENUE has only one active correspondence
  	--address in any parent or future time frame
  DECLARE
  	v_adt_rec		VARCHAR2(1);
  	CURSOR c_adt IS
  		SELECT 	'X'
  		FROM	IGS_CO_ADDR_TYPE
  		WHERE	addr_type			= p_addr_type;
  	CURSOR c_vea IS
  		SELECT	vea.start_dt,
  			vea.end_dt
  		FROM	IGS_GR_VENUE_ADDR	vea
  		WHERE	vea.correspondence_ind	= 'Y'		AND
  			vea.addr_type		<> p_addr_type	AND
  			vea.venue_cd		= p_venue_cd;
  BEGIN
  	--- Set the default message number
  	 p_message_name := null;
  	-- Set the default return value
  	return_val := TRUE;
  	--Check if the parameter address type has the correpondence indicator set to
  	--'TRUE'
  	OPEN c_adt;
  	FETCH c_adt INTO v_adt_rec;
  	IF (c_adt%NOTFOUND) THEN
  		CLOSE c_adt;
  		RETURN return_val;
  	END IF;
  	CLOSE c_adt;
  	--The IGS_CO_ADDR_TYPE passed in as a parameter has the correspondence_ind set.
  	--Now loop through the IGS_GR_VENUE_ADDR records for the IGS_GR_VENUE to determine if they
  	--have any other active records with an IGS_CO_ADDR_TYPE
  	--(apart from the IGS_CO_ADDR_TYPE passed in as a parameter)
  	--which also has the correspondence_ind set. If so, set the error message.
  	FOR v_vea_rec IN c_vea LOOP
  		IF (v_vea_rec.end_dt >= SYSDATE  OR
  				v_vea_rec.end_dt IS NULL) THEN
  			--Validate for date overlaps against the parameter details passed in
  			--Validation will fail if any of the following numbered points are true
  			IF (v_vea_rec.end_dt IS NOT NULL) THEN
  				--1. The parameter start date is between the fetched record date range
  				IF (p_start_dt BETWEEN v_vea_rec.start_dt AND v_vea_rec.end_dt) THEN
  					p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  					return_val := FALSE;
  					EXIT;
  				END IF;
  				IF (p_end_dt IS NOT NULL) THEN
  					--2. The parameter end date is between the fetched record date range
  					IF (p_end_dt BETWEEN v_vea_rec.start_dt AND v_vea_rec.end_dt) THEN
  						p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  						return_val := FALSE;
  						EXIT;
  					END IF;
  					--3. The parameter dates overlap the entire fetched record date range
  					IF (p_start_dt <= v_vea_rec.start_dt	AND
  							p_end_dt >= v_vea_rec.end_dt) THEN
  						p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  						return_val := FALSE;
  						EXIT;
  					END IF;
  				END IF;
  				IF (p_end_dt IS NULL) THEN
  					--4. The parameter date range overlaps the fetched record open-ended date
  					--range
  					IF (p_start_dt <= v_vea_rec.start_dt) THEN
  						p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  						return_val := FALSE;
  						EXIT;
  					END IF;
  				END IF;
  			END IF;
  			IF (v_vea_rec.end_dt IS NULL) THEN
  				IF (p_end_dt IS NOT NULL) THEN
  					--5. The parameter dates overlap the fetched record start date
  					IF (v_vea_rec.start_dt BETWEEN p_start_dt AND p_end_dt) THEN
  						p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  						return_val := FALSE;
  						EXIT;
  					END IF;
  					--6 The parameter dates overlap the fetched record open-ended start date
  					IF (v_vea_rec.start_dt <= p_start_dt) THEN
  						p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  						return_val := FALSE;
  						EXIT;
  					END IF;
  				END IF;
  				IF ( p_end_dt IS NULL) THEN
  					p_message_name := 'IGS_AS_ADDTYPE_USED_COR_PURPO';
  					return_val := FALSE;
  					EXIT;
  				END IF;
  			END IF;
  		END IF;
  	END LOOP;
  	RETURN return_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_VEA.ASSP_VAL_VEA_CORADDR');
         Igs_Ge_Msg_stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_vea_coraddr;
  --
  -- Retrofitted
  FUNCTION ASSP_VAL_VEA_OVRLP(
  p_venue_cd  IGS_AD_LOCVENUE_ADDR.location_venue_cd%TYPE ,
  p_addr_type  FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE ,
  p_start_dt  HZ_LOCATIONs.ADDRESS_EFFECTIVE_DATE%TYPE ,
  p_end_dt  HZ_LOCATIONS.ADDRESS_EXPIRATION_DATE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_vea_ovrlp
  	-- Validate that the IGS_GR_VENUE_ADDR record being created or updated does not
  	-- overlap with an existing address record of the same type for the IGS_GR_VENUE.
  DECLARE
  	v_start_dt	IGS_GR_VENUE_ADDR.start_dt%TYPE;
  	v_end_dt	IGS_GR_VENUE_ADDR.end_dt%TYPE;
  	v_p_end_dt	IGS_GR_VENUE_ADDR.end_dt%TYPE;
  	CURSOR c_va IS
  		SELECT  IGS_GR_VENUE_ADDR.start_dt,
                NVL(IGS_GR_VENUE_ADDR.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		FROM	IGS_GR_VENUE_ADDR
  		WHERE	venue_cd	= p_venue_cd  AND
  			addr_type	= p_addr_type AND
  			start_dt	<> p_start_dt;
  BEGIN
  	 p_message_name := null;
  	-- set p_end_dt to a high date if null

      v_p_end_dt := NVL(p_end_dt,IGS_GE_DATE.IGSDATE('YYYY/MM/DD'));
--  	v_p_end_dt := NVL(p_end_dt, TO_DATE('01/01/9999','DD/MM/YYYY'));
  	OPEN c_va;
  	-- Validation will fail if any of the following are true
  	LOOP
  		EXIT WHEN (c_va%NOTFOUND);
  		FETCH c_va INTO v_start_dt,
  				v_end_dt;
  		-- (a)  The current start date is between an existing date range.
  		IF (p_start_dt >= v_start_dt AND
  				p_start_dt <= v_end_dt) THEN
  			CLOSE c_va;
  			p_message_name := 'IGS_EN_ADO_STDT_BTWN_STDT';
  			RETURN FALSE;
  		END IF;
  		-- (b)  The current end date is between an existing date range.
  		IF (v_p_end_dt >= v_start_dt AND
  				v_p_end_dt <= v_end_dt) THEN
  			CLOSE c_va;
  			p_message_name := 'IGS_EN_ADO_ENDDT_BTWN_ENDDT';
  			RETURN FALSE;
  		END IF;
  		-- (c)  The current dates overlap an entire existing date range.
  		IF (p_start_dt <= v_start_dt AND
  				v_p_end_dt >= v_end_dt) THEN
  			CLOSE c_va;
  			p_message_name := 'IGS_EN_ADO_DT_OVERLAP';
  			Return FALSE;
  		END IF;
  	END LOOP;
  	CLOSE c_va;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_VEA.ASSP_VAL_VEA_OVRLP');
         Igs_Ge_Msg_stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_vea_ovrlp;
  --
  --
  --
  PROCEDURE Validate_Address
  (
    p_city IN VARCHAR2,
    p_state IN VARCHAR2,
    p_province IN VARCHAR2,
    p_county IN VARCHAR2,
    p_country IN VARCHAR2,
    p_postcode IN VARCHAR2,
    p_valid_address OUT NOCOPY BOOLEAN,
    p_error_msg OUT NOCOPY VARCHAR2
  ) IS
  BEGIN

    -- Custom Validation Logic Implemented by the user.
    -- After Validation, if the user finds this address is valid, do the following.
    -- p_valid_address := TRUE;
    -- p_error_msg := NULL;

    -- If the address is not valid, the do the following.
    -- p_valid_address := FALSE;
    -- p_error_msg := p_city; -- The Parameter which is not valid. (e.g., p_city)

    p_valid_address := TRUE;
    p_error_msg := NULL;

  END Validate_Address;

END IGS_AS_VAL_VEA;

/
