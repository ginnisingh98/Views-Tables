--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_OUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_OUR" AS
/* $Header: IGSOR11B.pls 115.7 2002/11/29 01:48:17 nsidana ship $ */

  --
  -- Validate the organisational IGS_PS_UNIT relationship.
  FUNCTION orgp_val_our(
  p_parent_org_unit_cd IN VARCHAR2 ,
  p_parent_start_dt IN DATE ,
  p_child_org_unit_cd IN VARCHAR2 ,
  p_child_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
	CURSOR  c_ou (
		cp_org_unit_cd  IGS_OR_UNIT.org_unit_cd%TYPE,
		cp_start_dt     IGS_OR_UNIT.start_dt%TYPE) IS
	SELECT  org_unit_cd
	FROM    IGS_OR_UNIT
	WHERE   org_unit_cd = cp_org_unit_cd
	AND     start_dt = cp_start_dt;
	--
	CURSOR  c_ou_os (
		cp_org_unit_cd  IGS_OR_UNIT.org_unit_cd%TYPE,
		cp_start_dt     IGS_OR_UNIT.start_dt%TYPE) IS
	SELECT  s_org_status
	FROM    IGS_OR_UNIT,
		IGS_OR_STATUS
	WHERE   org_unit_cd = cp_org_unit_cd
	AND     start_dt = cp_start_dt
	AND     IGS_OR_STATUS.org_status = IGS_OR_UNIT.org_status
	AND     s_org_status = 'INACTIVE';
	--
	v_org_unit_exists       BOOLEAN DEFAULT FALSE;
	v_other_detail  VARCHAR2(255);
	--
	-- Local function to perform recursive loop.
	FUNCTION orgp_val_our_loop (
		p_org_unit_cd   IN      IGS_OR_UNIT.org_unit_cd%TYPE,
		p_start_dt      IN      IGS_OR_UNIT.start_dt%TYPE)
	RETURN BOOLEAN
	IS
		CURSOR c_our IS
		SELECT  parent_org_unit_cd,
			parent_start_dt
		FROM    IGS_OR_UNIT_REL
		WHERE   child_org_unit_cd = p_org_unit_cd
		AND     child_start_dt = p_start_dt
		AND     logical_delete_dt IS NULL;
		--
		v_valid BOOLEAN DEFAULT TRUE;
	BEGIN
		FOR our IN c_our LOOP
			IF (our.parent_org_unit_cd = p_child_org_unit_cd AND
			      our.parent_start_dt = p_child_start_dt) THEN
				v_valid := FALSE;
				EXIT;
			END IF;
			IF orgp_val_our_loop (our.parent_org_unit_cd,
					     our.parent_start_dt) = FALSE THEN
				v_valid := FALSE;
				EXIT;
			END IF;
		END LOOP;
		RETURN v_valid;
		EXCEPTION
		WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       App_Exception.Raise_Exception ;
	END orgp_val_our_loop;
	--
  BEGIN
	p_message_name := NULL;
	-- Validate the parent org IGS_PS_UNIT exists.
	FOR ou IN c_ou (p_parent_org_unit_cd, p_parent_start_dt) LOOP
		v_org_unit_exists := TRUE;
	END LOOP;
	IF v_org_unit_exists = FALSE THEN
		p_message_name := 'IGS_OR_PARENT_UNIT_NOT_EXIST';
		RETURN FALSE;
	END IF;
	-- Validate the child org IGS_PS_UNIT exists.
	v_org_unit_exists := FALSE;
	FOR ou IN c_ou (p_child_org_unit_cd, p_child_start_dt) LOOP
		v_org_unit_exists := TRUE;
	END LOOP;
	IF v_org_unit_exists = FALSE THEN
		p_message_name := 'IGS_OR_CHILD_UNIT_NOT_EXIST';
		RETURN FALSE;
	END IF;
	-- Validate the system status for the parent organisational IGS_PS_UNIT.
--ssawhney 2040057. message changed from invalid value to something meaningful.
	FOR ou_os IN c_ou_os (p_parent_org_unit_cd, p_parent_start_dt) LOOP
		p_message_name := 'IGS_OR_INACTIVE_REL';
		RETURN FALSE;
	END LOOP;
	-- Validate the system status for the child organisational IGS_PS_UNIT.
	FOR ou_os IN c_ou_os (p_child_org_unit_cd, p_child_start_dt) LOOP
		p_message_name := 'IGS_OR_INACTIVE_REL';
		RETURN FALSE;
	END LOOP;
	-- Validate the child and parent organisational units are not the same.
	IF p_parent_org_unit_cd = p_child_org_unit_cd AND
	   p_parent_start_dt = p_child_start_dt THEN
		p_message_name := 'IGS_OR_SUP_SUB_REL_XS';
		RETURN FALSE;
	END IF;
	-- Validate the organisational structure to ensure the child
	-- organisational IGS_PS_UNIT does not appear further up the tree.
	IF orgp_val_our_loop (p_parent_org_unit_cd,
			      p_parent_start_dt) = FALSE THEN
		p_message_name := 'IGS_OR_SUP_SUB_REL_XS';
		RETURN FALSE;
	END IF;
	RETURN TRUE;
	EXCEPTION
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       App_Exception.Raise_Exception ;
  END orgp_val_our;
END IGS_OR_VAL_OUR;

/
