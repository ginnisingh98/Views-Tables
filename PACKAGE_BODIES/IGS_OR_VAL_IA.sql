--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_IA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_IA" AS
/* $Header: IGSOR02B.pls 115.8 2003/11/19 10:40:09 gmaheswa ship $ */
--
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_pc_closed
--

  -----------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function orgp_val_addr_type removed
  --gmaheswa    18-Nov-2003     Bug No. 3227107 .Address Changes. modified cursors related to
  --                            address,start_dt and end_dt as to select only active address records.
  -----------------------------------------------------------------------------------------
  -- Validate that there is only one cor address per IGS_OR_INSTITUTION
  FUNCTION orgp_val_ia_cor_addr(
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_ia_count	NUMBER(5);
  	CURSOR c_ia_count IS
  		SELECT	count(*)
  		FROM	IGS_CO_ADDR_TYPE	adt
  		WHERE	adt.addr_type = p_addr_type;
  	CURSOR c_ia IS
  		SELECT	ia.addr_type,
  			ia.start_dt,
  			ia.end_dt
  		FROM	IGS_OR_INST_ADDR	ia
  		WHERE	ia.institution_cd = p_institution_cd AND
  			ia.addr_type <> p_addr_type AND
			ia.status = 'A' AND
  			ia.correspondence_ind = 'Y';
  BEGIN
  	-- Validate that an organisational unit only has one active correspondant
  	--  address in any present or future time frame.
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_ia_count;
  	FETCH c_ia_count INTO v_ia_count;
  	CLOSE c_ia_count;
  	-- Check if the parameter address type has the correspondence indicator set
  	-- to 'TRUE'.
  	IF v_ia_count = 0 THEN
  		RETURN TRUE;
  	END IF;
  	-- The addr_type passed in as a parameter has the correspondence_ind set.
  	--  Now loop through the institution_addr records for the location to
  	-- determine if they have any other active records with an addr_type
  	--  (apart from the addr_type passed in as a parameter) which also has
  	--  the correspondence_ind set.  If so set the error message.
  	FOR v_ia IN c_ia LOOP
  	--validate for date overlaps against the parameter details passed in.
  	--Validation will fail if any of the following are true:
  		-- a) The parameter start date is between the fetched record date range.
  		-- b) The parameter end date is between the fetched record date range.
  		-- c) The paramter dates overlap the entire fetched record range.
  		-- d) The parameter dates overlap the fetched record open_ended
  			-- date range.
  		-- e) The parameter dates overlap the fetched record start date.
  		-- f) The parameter dates overlap the fetched record open_ended
  			-- start date.
  	--An exception is when the fetched record end date is less than the current
  	-- date (ie SYSDATE). The reason for this is that even though the parameter
  	-- dates may overlap the dates of this record, the end date has already passed
  	-- and this date will not be used.
  		IF (v_ia.end_dt >= SYSDATE OR
  				v_ia.end_dt IS NULL) THEN
  			IF v_ia.end_dt IS NOT NULL THEN
  				IF (p_start_dt >= v_ia.start_dt AND
  						p_start_dt <= v_ia.end_dt)THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
  					RETURN FALSE;
  				END IF;
  				IF p_end_dt IS NOT NULL THEN
  					IF (p_end_dt >= v_ia.start_dt AND
  							p_end_dt <= v_ia.end_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
  						RETURN FALSE;
  					END IF;
  					IF (p_start_dt <= v_ia.start_dt AND
  							p_end_dt >= v_ia.end_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
  						RETURN FALSE;
  					END IF;
  				ELSE
  					IF (p_start_dt <= v_ia.start_dt) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
  						RETURN FALSE;
  					END IF;
  				END IF;
  			ELSE
  				IF p_end_dt IS NOT NULL THEN
  					IF ( v_ia.start_dt >= p_start_dt AND
  							v_ia.start_dt <= p_end_dt) THEN
       					p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
  						RETURN FALSE;
  					END IF;
  					IF (v_ia.start_dt <= p_start_dt) THEN
  					    p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
  						RETURN FALSE;
  					END IF;
  				END IF;
  				IF (p_end_dt IS NULL) THEN
  					p_message_name := 'IGS_OR_ONE_CORR_ADDR_ACTIVE';
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
  END orgp_val_ia_cor_addr;
  --
  -- Validate that only one IGS_OR_INSTITUTION address is open per address type
  FUNCTION orgp_val_ia_one_open(
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2  )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_count		NUMBER(5);
  	CURSOR c_ia IS
  		SELECT	count(*)
  		FROM	IGS_OR_INST_ADDR	ia
  		WHERE	ia.institution_cd = p_institution_cd AND
  			ia.addr_type = p_addr_type AND
			ia.status = 'A' AND
  			ia.start_dt <> p_start_dt AND
  			ia.end_dt IS NULL;
  BEGIN
  	--Validate the institution_addr table to ensure that only one record is open
  	--(ie; has a null end date).
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_ia;
  	FETCH c_ia into v_count;
  	CLOSE c_ia;
  	--If any open ended records, then return error.
  	IF v_count > 0 THEN
  		p_message_name := 'IGS_OR_MULTIPLE_INST_ADDR';
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
  END orgp_val_ia_one_open;
  --
  -- Validate that address dates do not overlap for an institution
  FUNCTION orgp_val_ia_ovrlp(
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2  )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_ia (
  		cp_institution_cd	IGS_OR_INST_ADDR.institution_cd%TYPE,
  		cp_addr_type		IGS_OR_INST_ADDR.addr_type%TYPE) IS
  		SELECT	ia.start_dt,
  			ia.end_dt
  		FROM	IGS_OR_INST_ADDR ia
  		WHERE	ia.institution_cd = cp_institution_cd AND
  			ia.addr_type = cp_addr_type AND
			ia.status = 'A' AND
  			ia.start_dt <> p_start_dt;
  	v_end_dt	IGS_OR_INST_ADDR.end_dt%TYPE;
  BEGIN
  	-- This module checks that the institution_addr record,
  	-- which is being created or updated, does not overlap
  	-- with an existing record of the same type for the institution.
  	-- Set the default message number
  	p_message_name := null;
  	-- set p_end_dt to a high date if null
  	IF (p_end_dt IS NULL) THEN
  		v_end_dt := IGS_GE_DATE.IGSDATE('9999/01/01');
  	ELSE
  		v_end_dt := p_end_dt;
  	END IF;
  	-- Loop through the selected institution_addr records,
  	-- validating each record for date overlaps.
  	-- Do not validate against the record passed in.
  	-- Validation will fail if any of the following are true -
  	--	a. The current start date is between an existing date range.
  	-- 	b. The current end date is between an existing date range.
  	-- 	c. The current dates overlap an entire existing date range.
  	FOR	v_ia_rec	IN	c_ia(
  						p_institution_cd,
  						p_addr_type) LOOP
  		-- check if p_start_dt between existing date range.
  		IF (p_start_dt >= v_ia_rec.start_dt) AND
    		   	(p_start_dt <= NVL(v_ia_rec.end_dt,IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
  				p_message_name:= 'IGS_EN_ADDRESS_DATES_OVERLAP';
  				RETURN FALSE;
  		END IF;
  		-- check if p_end_date between existing date range.
  		IF (v_end_dt >= v_ia_rec.start_dt) AND
  			(v_end_dt <= NVL(v_ia_rec.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
  				p_message_name:= 'IGS_EN_ADDRESS_DATES_OVERLAP';
  				RETURN FALSE;
  		END IF;
  		-- check if input dates overlap entire existing
  		-- date range.
  		IF (p_start_dt <= v_ia_rec.start_dt) AND
  			(v_end_dt >= NVL(v_ia_rec.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
  				p_message_name:= 'IGS_EN_ADDRESS_DATES_OVERLAP';
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
  END orgp_val_ia_ovrlp;
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

END IGS_OR_VAL_IA;

/
