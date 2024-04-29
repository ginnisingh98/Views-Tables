--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_CCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_CCI" AS
/* $Header: IGSCO06B.pls 115.5 2002/11/28 23:04:09 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cort_closed"
  -------------------------------------------------------------------------------------------

  -- Validate that the correspondence type is  eligible for the category
  FUNCTION corp_val_cci_elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_correspondence_type IN VARCHAR2 ,
  p_job_name IN VARCHAR2 ,
  p_output_num IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	e_required_parameters		EXCEPTION;
  	e_both_must_be_set		EXCEPTION;
  	v_correspondence_cat		IGS_EN_STDNT_PS_ATT.correspondence_cat%TYPE;
  	v_correspondence_type		IGS_CO_TYPE_JO.correspondence_type%TYPE;
  	CURSOR c_sca IS
  		SELECT	sca.correspondence_cat
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd AND
  			sca.correspondence_cat = p_correspondence_cat;
  	CURSOR c_cortjo IS
  		SELECT	cortjo.correspondence_type
  		FROM	IGS_CO_TYPE_JO	cortjo
  		WHERE	cortjo.s_job_name = p_job_name AND
  			cortjo.output_num = p_output_num;
  	CURSOR c_sca2 IS
  		SELECT	sca.correspondence_cat
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd;
  	FUNCTION corpl_val_cci (
  		p_course_cd		IN	IGS_PS_COURSE.course_cd%TYPE,
  		p_correspondence_cat	IN	IGS_CO_CAT.correspondence_cat%TYPE,
  		p_correspondence_type	IN	IGS_CO_TYPE.correspondence_type%TYPE,
  		p_message_name 		OUT NOCOPY	varchar2)
  	RETURN
  		BOOLEAN
  	AS
  	BEGIN
  	DECLARE
  		v_block_when_encumbered_ind
  			IGS_CO_CAT_ITM.block_when_encumbered_ind%TYPE;
  		CURSOR c_cci IS
  			SELECT	cci.block_when_encumbered_ind
  			FROM	IGS_CO_CAT_ITM	cci
  			WHERE	cci.correspondence_cat = p_correspondence_cat AND
  				cci.correspondence_type = p_correspondence_type AND
  				cci.logical_delete_dt IS NULL;
  		CURSOR c_cortjo IS
  			SELECT	cortjo.correspondence_type
  			FROM	IGS_CO_TYPE_JO	cortjo
  			WHERE	cortjo.s_job_name = p_job_name AND
  				cortjo.output_num = p_output_num AND
  				cortjo.correspondence_type IN (
  						SELECT	cci.correspondence_type
  						FROM	IGS_CO_CAT_ITM	cci
  						WHERE 	cci.correspondence_type =
  							cortjo.correspondence_type  AND
  							cci.logical_delete_dt IS NULL);
  	BEGIN
  		-- Check the item is valid for the corresponding category, and if so
  		-- that the person is not blocked by an encumbrance.
  		OPEN	c_cci;
  		FETCH	c_cci 	INTO	v_block_when_encumbered_ind;
  		IF (c_cci%NOTFOUND) THEN
  			CLOSE	c_cci;
  			IF (p_correspondence_type IS NOT NULL) THEN
  				p_message_name := 'IGS_CO_CORTYPE_NOTALLOCATED';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE	c_cci;
  		IF (v_block_when_encumbered_ind = 'Y') THEN
  			IF (IGS_EN_VAL_ENCMB.enrp_val_blk_sys_cor(
  						p_person_id,
  						p_course_cd,
  						p_effective_dt,
  						p_message_name) = FALSE) THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  		p_message_name := Null;
  		RETURN TRUE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
  			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
  			Fnd_Message.Set_Token('NAME','IGS_CO_VAL_CCI.CORPL_VAL_CCI');
  			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END corpl_val_cci;
  BEGIN
  	-- This module checks is a person is eligible for an item of correspondence.
  	-- 1. Check required parameters have been passed
  	IF (p_correspondence_cat IS NULL AND
  			p_correspondence_type IS NULL AND
  			p_job_name IS NULL AND
  			p_output_num IS NULL) THEN
  		RAISE e_required_parameters;
  	END IF;
  	-- To determine the correspondence type, it is either specified or
  	-- determined via the job producing it.
  	IF (p_correspondence_type IS NULL AND
  			(p_job_name IS NULL OR
  			p_output_num IS NULL)) THEN
  		RAISE e_both_must_be_set;
  	END IF;
  	-- 2. Depending upon the actual parameters passed, the correspondence
  	-- category and correspondence type can be derived in a number of
  	-- different ways.
  	IF (p_correspondence_cat IS NOT NULL) THEN
  		OPEN	c_sca;
  		FETCH	c_sca	INTO	v_correspondence_cat;
  		IF (c_sca%NOTFOUND) THEN
  			CLOSE	c_sca;
  			p_message_name := 'IGS_CO_PRSN_NOTENR_CORCAT';
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_sca;
  		IF (p_correspondence_type IS NOT NULL) THEN
  			IF (corpl_val_cci(
  					p_course_cd,
  					p_correspondence_cat,
  					p_correspondence_type,
  					p_message_name) = FALSE) THEN
  				RETURN FALSE;
  			END IF;
  		ELSE
  			OPEN	c_cortjo;
  			FETCH	c_cortjo	INTO	v_correspondence_type;
  			IF (c_cortjo%NOTFOUND) THEN
  				CLOSE	c_cortjo;
  				p_message_name := 'IGS_CO_SYSJOB_RCGN_CORTYPE';
  				RETURN FALSE;
  			END IF;
  			CLOSE	c_cortjo;
  			FOR v_cortjo_rec IN c_cortjo LOOP
  				IF (corpl_val_cci(
  						p_course_cd,
  						p_correspondence_cat,
  						v_cortjo_rec.correspondence_type,
  						p_message_name) = FALSE) THEN
  					RETURN FALSE;
  				END IF;
  			END LOOP;
  		END IF;
  	ELSE
  		-- p_correspondence_cat IS NULL
  		OPEN	c_sca2;
  		FETCH	c_sca2	INTO	v_correspondence_cat;
  		IF (c_sca2%NOTFOUND) THEN
  			CLOSE	c_sca2;
  			p_message_name := 'IGS_CO_PRSN_NOTENR_CORCAT';
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_sca2;
  		IF (p_correspondence_type IS NOT NULL) THEN
  			IF (corpl_val_cci(
  					p_course_cd,
  					v_correspondence_cat,
  					p_correspondence_type,
  					p_message_name) = FALSE) THEN
  				RETURN FALSE;
  			END IF;
  		ELSE
  			-- Get the correspondence type when it is not specified.
  			OPEN	c_cortjo;
  			FETCH	c_cortjo	INTO	v_correspondence_type;
  			IF (c_cortjo%NOTFOUND) THEN
  				CLOSE	c_cortjo;
  				p_message_name := 'IGS_CO_SYSJOB_RCGN_CORTYPE';
  				RETURN FALSE;
  			END IF;
  			CLOSE	c_cortjo;
  			FOR v_cortjo_rec IN c_cortjo LOOP
  				IF (corpl_val_cci(
  						p_course_cd,
  						v_correspondence_cat,
  						v_cortjo_rec.correspondence_type,
  						p_message_name) = FALSE) THEN
  					RETURN FALSE;
  				END IF;
  			END LOOP;
  		END IF;
  	END IF;
  	p_message_name := Null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN e_required_parameters THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  	WHEN e_both_must_be_set THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
  		Fnd_Message.Set_Token('NAME','IGS_CO_VAL_CCI.CORPL_VAL_CCI_ELGBL');
  		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END corp_val_cci_elgbl;
  --
  -- Validate for correspondence category item duplicates.
  FUNCTION corp_val_cci_duplict(
  p_correspondence_cat IN VARCHAR2 ,
  p_correspondence_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_closed_ind	IGS_CO_TYPE.closed_ind%TYPE;
  	CURSOR 	c_cci(
  			cp_correspondence_cat IGS_CO_CAT_ITM.correspondence_cat%TYPE,
  			cp_correspondence_type IGS_CO_CAT_ITM.correspondence_type%TYPE,
  			cp_create_dt IGS_CO_CAT_ITM.create_dt%TYPE) IS
  		SELECT	cci.correspondence_cat
  		FROM	IGS_CO_CAT_ITM cci
  		WHERE	cci.correspondence_cat = cp_correspondence_cat AND
  			cci.correspondence_type = cp_correspondence_type AND
  			cci.create_dt <> cp_create_dt AND
  			cci.logical_delete_dt IS NULL;
  BEGIN
  	--  Validate the correspondence category item table to ensure that a
  	--  correspondence type may only be duplicated where the previous
  	--  entry has been logically deleted.
  	--  That is, the same correspondence type may be added multiple times
  	--  for a correspondence category but only one may have the deletion
  	--  date set to null.
  	p_message_name := Null;
  	FOR v_cci_rec IN c_cci(
  				p_correspondence_cat,
  				p_correspondence_type,
  				p_create_dt) LOOP
  		p_message_name := 'IGS_CO_DUPL_CORCAT_ITEM_EXIST';
  		RETURN FALSE;
  	END LOOP;
  	RETURN TRUE;

  END;
  END corp_val_cci_duplict;
END IGS_CO_VAL_CCI;

/
