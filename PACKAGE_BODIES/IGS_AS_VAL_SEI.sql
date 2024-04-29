--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_SEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_SEI" AS
/* $Header: IGSAS29B.pls 115.6 2003/05/27 18:45:20 anilk ship $ */

  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Validate IGS_AS_STD_EXM_INSTN teaching calendar instance
  FUNCTION ASSP_VAL_SEI_CI(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_sei_ci

  	-- Validate the teaching calendar instance of the IGS_AS_STD_EXM_INSTN record
  	-- being created.  Check for, EXIT WHEN condition_is_true ; -- To exit out NOCOPY of
  	-- loop The teaching calendar instance must be a subordinate calendar to
  	-- the specified examination calendar instance.
  DECLARE
  BEGIN
  	p_message_name := null;

  	-- Check that the teaching calendar is within the examination calendar instance
  	IF IGS_EN_GEN_008.ENRP_GET_WITHIN_CI(
  			p_exam_cal_type,
  			p_exam_ci_sequence_number,
  			p_cal_type,
  			p_ci_sequence_number,
  			FALSE) = FALSE THEN
  		p_message_name := 'IGS_AS_TEACHCAL_SAI_RELATED';
  		RETURN FALSE;
  	END IF;

  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SEI.assp_val_sei_ci');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_sei_ci;
  --
  -- Validate for IGS_AS_STD_EXM_INSTN duplicate within exam period
  FUNCTION ASSP_VAL_SEI_DPLCT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_ass_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN boolean IS
  	gv_other_detail		VARCHAR2(255);

  BEGIN	-- assp_val_sei_dplct

  	-- Validate that the student examination instance isn?t a duplicate for
  	-- the related IGS_AS_SU_ATMPT_ITM record. A student cannot be
  	-- timetabled more than once within an examination calendar. IGS_GE_NOTE:
  	-- A student can possibly be timetabled in more than one calendar ;
  	-- once for the normal examination and once for a supplementary/special
  	-- examination.
  DECLARE
  	v_x		VARCHAR2(1) DEFAULT NULL;
  	v_ret_val	BOOLEAN	DEFAULT TRUE;

  	CURSOR c_sei IS
  		SELECT 'x'
  		FROM	IGS_AS_STD_EXM_INSTN
  		WHERE	person_id 		= p_person_id 	AND
  			course_cd 		= p_course_cd 	AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
  			uoo_id          	= p_uoo_id      AND
  			exam_cal_type 		= p_exam_cal_type AND
  			exam_ci_sequence_number = p_exam_ci_sequence_number AND
  			ass_id 			= p_ass_id 	AND
  			(venue_cd 		<> p_venue_cd 		OR
  			dt_alias 		<> p_dt_alias 		OR
  			dai_sequence_number 	<> p_dai_sequence_number OR
  			start_time 		<> p_start_time 	OR
  			end_time 		<> p_end_time);
  BEGIN
  	p_message_name := null;

  	OPEN c_sei;
  	FETCH c_sei INTO v_x;

  	-- 1. Search for another timetabled student exam instance in the same
  	-- examination calendar.

  	IF (c_sei%FOUND) THEN
  		p_message_name := 'IGS_AS_SAI_ALREADY_SCHEDULED';
  		v_ret_val := FALSE;
  	END IF;

  	CLOSE c_sei;

  	RETURN v_ret_val;
  END;

  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SEI.assp_val_sei_dplct');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;

  END assp_val_sei_dplct;
  --
  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  --
  -- Validate seat not allocated twice within an examination and IGS_GR_VENUE.
  FUNCTION ASSP_VAL_SEI_SEAT(
  p_ese_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_person_id OUT NOCOPY NUMBER ,
  p_seat_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);

  BEGIN	-- assp_val_sei_seat
  	-- Description: This module checks that there does not exist two students
  	-- with the same seat allocation within an exam instance and IGS_GR_VENUE.
  DECLARE

  	v_sei_person_id		IGS_AS_STD_EXM_INSTN.person_id%TYPE;
  	v_sei_seat_number	IGS_AS_STD_EXM_INSTN.seat_number%TYPE;

  	CURSOR	c_sei IS
  		SELECT 		sei.person_id,
  				sei.seat_number
  		FROM		IGS_AS_STD_EXM_INSTN	sei
  		WHERE		sei.ese_id 		= p_ese_id  AND
  				sei.venue_cd		= p_venue_cd AND
  				EXISTS(
  				SELECT	'x'
  				FROM	IGS_AS_STD_EXM_INSTN 	sei2
  				WHERE	sei2.ese_id 		= sei.ese_id  AND
  					sei2.venue_cd		= sei.venue_cd AND
  					sei2.person_id		<> sei.person_id AND
  					sei2.seat_number	= sei.seat_number);

  BEGIN
  	p_message_name := null;

  	OPEN c_sei;
  	FETCH c_sei INTO v_sei_person_id,
  			v_sei_seat_number;

  	IF (c_sei%FOUND) THEN
  		CLOSE c_sei;
  		p_person_id := v_sei_person_id;
  		p_seat_number := v_sei_seat_number;
  		p_message_name := 'IGS_AS_SEAT_ALREADY_ALLOCATED';
  		RETURN FALSE;
  	ELSE
  		p_person_id := NULL;
  		p_seat_number := NULL;
  	END IF;

  	CLOSE c_sei;

  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sei%ISOPEN) THEN
  			CLOSE c_sei;
  		END IF;
  	RAISE;
  END;

  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SEI.assp_val_sei_seat');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;

  END assp_val_sei_seat;
END IGS_AS_VAL_SEI;

/
