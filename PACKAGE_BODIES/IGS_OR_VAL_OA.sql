--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_OA" AS
/* $Header: IGSOR08B.pls 115.9 2003/11/19 10:40:03 gmaheswa ship $ */

--
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_pc_closed
--

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function orgp_val_addr_type removed
  --gmaheswa    12-Nov-2003     Bug no. 3227107 .Address ralated changes Modified the cursors related to
  --                            Address,start_dt and end_dt as to select only active addresses.
  -------------------------------------------------------------------------------------------

   -- Validate that there is only one cor address per org unit
  FUNCTION orgp_val_oa_cor_addr(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_oa_count	NUMBER(5);
  	CURSOR c_oa_count IS
  		SELECT	count(*)
  		FROM	IGS_CO_ADDR_TYPE	adt
  		WHERE	adt.addr_type = p_addr_type;

  	CURSOR c_oa IS
  		SELECT	oa.addr_type,
  			oa.start_dt,
  			oa.end_dt
  		FROM	IGS_OR_ADDR	oa
  		WHERE	oa.org_unit_cd = p_org_unit_cd AND
		        oa.status = 'A' AND
		        oa.ou_start_dt = p_ou_start_dt AND
  			oa.addr_type <> p_addr_type AND
  			oa.correspondence_ind = 'Y';
  BEGIN
  	-- Validate that an organisational unit only has one active
  	-- correspondant address in any present or future time frame.
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_oa_count;
  	FETCH c_oa_count INTO v_oa_count;
  	CLOSE c_oa_count;
  	-- Check if the parameter address type has the correspondence
  	-- indicator set to 'TRUE'.
  	IF v_oa_count = 0 THEN
  		RETURN TRUE;
  	END IF;
  	-- The addr_type passed in as a parameter has the correspondence_ind
  	-- set. Now loop through the IGS_OR_ADDR records for the IGS_AD_LOCATION to
  	-- determine if they have any other active records with an IGS_CO_ADDR_TYPE
  	-- (apart from the IGS_CO_ADDR_TYPE passed in as a parameter) which also has
  	-- the correspondence_ind set.  If so set the error message.
  	FOR v_oa IN c_oa LOOP
  	--validate for date overlaps against the parameter details passed in.
  	--Validation will fail if any of the following are true:
  		-- a) The parameter start date is between the fetched record date
  			--range.
  		-- b) The parameter end date is between the fetched record date
  			--range.
  		-- c) The paramter dates overlap the entire fetched record range.
  		-- d) The parameter dates overlap the fetched record open_ended
  			--date range.
  		-- e) The parameter dates overlap the fetched record start date.
  		-- f) The parameter dates overlap the fetched record open_ended
  			--start date.
  	-- An exception is when the fetched record end date is less than the current
  	-- date (ie SYSDATE). The reason for this is that even though the parameter
  	-- dates may overlap the dates of this record, the end date has already passed
  	-- and this date will not be used.
  		IF (v_oa.end_dt >= SYSDATE OR
  				v_oa.end_dt IS NULL) THEN
  			IF v_oa.end_dt IS NOT NULL THEN
  				IF (p_start_dt >= v_oa.start_dt AND
  						p_start_dt <= v_oa.end_dt)THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  					RETURN FALSE;
  				END IF;
  				IF p_end_dt IS NOT NULL THEN
  					IF (p_end_dt >= v_oa.start_dt AND
  							p_end_dt <= v_oa.end_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  						RETURN FALSE;
  					END IF;
  					IF (p_start_dt <= v_oa.start_dt AND
  							p_end_dt >= v_oa.end_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  						RETURN FALSE;
  					END IF;
  				ELSE
  					IF (p_start_dt <= v_oa.start_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  						RETURN FALSE;
  					END IF;
  				END IF;
  			ELSE
  				IF p_end_dt IS NOT NULL THEN
  					IF ( v_oa.start_dt >= p_start_dt AND
  							v_oa.start_dt <= p_end_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  						RETURN FALSE;
  					END IF;
  					IF (v_oa.start_dt <= p_start_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  						RETURN FALSE;
  					END IF;
  				END IF;
  				IF (p_end_dt IS NULL) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ORG_ACTIVE';
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
  	END LOOP;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END orgp_val_oa_cor_addr;
  --
  -- Validate that only one org IGS_PS_UNIT address is open per address type
  FUNCTION orgp_val_oa_one_open(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_count		NUMBER(5);
  	CURSOR c_oa IS
  		SELECT	count(*)
  		FROM	IGS_OR_ADDR	oa
  		WHERE	oa.org_unit_cd = p_org_unit_cd AND
  			oa.ou_start_dt = p_ou_start_dt AND
			oa.status = 'A' AND
  			oa.start_dt <> p_start_dt AND
  			oa.addr_type = p_addr_type AND
  			oa.end_dt IS NULL;
  BEGIN
  	--Validate the IGS_OR_ADDR table to ensure that only one record is open
  	--(ie; has a null end date).
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_oa;
  	FETCH c_oa into v_count;
  	CLOSE c_oa;
  	--If more than one-open ended record, then return error.
  	IF v_count > 0 THEN
  		p_message_name := 'IGS_OR_MULTIPLE_ORG_UNIT_ADDR';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END orgp_val_oa_one_open;
  --
  -- Validate that date overlaps do not exist for an org IGS_PS_UNIT
  FUNCTION orgp_val_oa_ovrlp(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_oa (
  		cp_org_unit_cd		IGS_OR_ADDR.org_unit_cd%TYPE,
  		cp_ou_start_dt		IGS_OR_ADDR.ou_start_dt%TYPE,
  		cp_addr_type		IGS_OR_ADDR.addr_type%TYPE) IS
  		SELECT	oa.start_dt,
  			oa.end_dt
  		FROM	IGS_OR_ADDR oa
  		WHERE	oa.org_unit_cd = cp_org_unit_cd AND
  			oa.ou_start_dt = cp_ou_start_dt AND
  			oa.addr_type = cp_addr_type AND
			oa.status = 'A' AND
  			oa.start_dt <> p_start_dt;
  	v_end_dt	IGS_OR_ADDR.end_dt%TYPE;
  BEGIN
  	-- This module checks that the IGS_OR_ADDR record, which is being
  	-- created or updated, does not overlap with an existing adress
  	-- record of the same type for the organisational IGS_PS_UNIT.
  	-- Set the default message number
  	p_message_name := NULL;
  	-- set p_end_dt to a high date if null
  	IF (p_end_dt IS NULL) THEN
  		v_end_dt := IGS_GE_DATE.IGSDATE('9999/01/01');
  	ELSE
  		v_end_dt := p_end_dt;
  	END IF;
  	-- Loop through the selected IGS_OR_ADDR records,
  	-- validating each record for date overlaps.
  	-- Do not validate against the record passed in.
  	-- Validation will fail if any of the following are true -
  	--	a. The current start date is between an existing date range.
  	-- 	b. The current end date is between an existing date range.
  	-- 	c. The current dates overlap an entire existing date range.
  	FOR	v_oa_rec	IN	c_oa(
  						p_org_unit_cd,
  						p_ou_start_dt,
  						p_addr_type) LOOP
  		-- check if p_start_dt between existing date range.
  		IF (p_start_dt >= v_oa_rec.start_dt) AND
  			(p_start_dt <= NVL(v_oa_rec.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
  				p_message_name := 'IGS_EN_ADDRESS_DATES_OVERLAP';
  				RETURN FALSE;
  		END IF;
  		-- check if p_end_date between existing date range.
  		IF (v_end_dt >= v_oa_rec.start_dt) AND
  			(v_end_dt <= NVL(v_oa_rec.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
  				p_message_name := 'IGS_EN_ADDRESS_DATES_OVERLAP';
  				RETURN FALSE;
  		END IF;
  		-- check if input dates overlap entire existing
  		-- date range.
  		IF (p_start_dt <= v_oa_rec.start_dt) AND
  			(v_end_dt >= NVL(v_oa_rec.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
  				p_message_name := 'IGS_EN_ADDRESS_DATES_OVERLAP';
  				RETURN FALSE;
  		END IF;
  	END LOOP;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END orgp_val_oa_ovrlp;
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
  ) AS
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

END IGS_OR_VAL_OA;

/
