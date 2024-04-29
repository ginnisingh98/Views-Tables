--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_OU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_OU" AS
/* $Header: IGSOR09B.pls 115.4 2002/11/29 01:48:02 nsidana ship $ */

/* HISTORY
   WHO           WHEN          WHAT
   pkpatel     27-OCT-2002     Bug NO: 2613704
                               Changed for lookup migration of ORG_TYPE and MEMBER_TYPE
*/
  --


  -- Validate the organisational IGS_PS_UNIT end date.


  FUNCTION orgp_val_ou_end_dt(


  p_org_unit_cd IN VARCHAR2 ,


  p_start_dt IN DATE ,


  p_end_dt IN DATE ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN Boolean AS


  BEGIN


  	p_message_name := NULL;


  	-- Perform validation when end date is set.


  	IF p_end_dt IS NOT NULL THEN


  		-- Validate end date is less than or equal to the current date.


  		IF p_end_dt > SYSDATE THEN


  			p_message_name := 'IGS_OR_UNIT_END_DT_LE_CURR_DT';


  			RETURN FALSE;


  		END IF;


  		-- Validate end date is greater than or equal to the start date.


  		IF p_end_dt < p_start_dt THEN


  			p_message_name := 'IGS_OR_UNIT_END_DT_GE_CURR_DT';


  			RETURN FALSE;


  		END IF;


  	ELSE	-- Perform validation when end date is not set


  		-- Validate no other open ended org units.


  		IF IGS_OR_VAL_OU.orgp_val_open_ou (


  			p_org_unit_cd,


  			p_start_dt,


  			p_message_name) = FALSE THEN


  			RETURN FALSE;


  		END IF;


  	END IF;


  	RETURN TRUE;


  END orgp_val_ou_end_dt;


  --


  -- Validate if any open ended org units exist for the current org IGS_PS_UNIT.


  FUNCTION orgp_val_open_ou(


  p_org_unit_cd IN VARCHAR2 ,


  p_start_dt IN DATE ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR	c_ou IS


  	SELECT	org_unit_cd


  	FROM	IGS_OR_UNIT


  	WHERE	org_unit_cd = p_org_unit_cd


  	AND	start_dt <> p_start_dt


  	AND	end_dt IS NULL;


  	v_other_detail	VARCHAR2(255);


  BEGIN


  	p_message_name := NULL;


  	FOR ou IN c_ou LOOP


  		p_message_name := 'IGS_OR_UNIT_ALREADY_EXISTS';


  		RETURN FALSE;


  	END LOOP;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;


  END orgp_val_open_ou;


  --


  -- Validate the organisational status.


  FUNCTION orgp_val_org_status(


  p_org_status IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR c_os IS


  	SELECT	closed_ind


  	FROM	IGS_OR_STATUS


  	WHERE	org_status = p_org_status


  	AND	closed_ind = 'Y';


  	v_other_detail	VARCHAR2(255);


  BEGIN


  	p_message_name := NULL;


  	FOR os IN c_os LOOP


  		p_message_name := 'IGS_OR_STAT_CANT_CLOSED';


  		RETURN FALSE;


  	END LOOP;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;


  END orgp_val_org_status;


  --


  -- Ensure an organisational IGS_PS_UNIT status change is valid.


  FUNCTION orgp_val_ou_sts_chng(


  p_org_unit_cd IN VARCHAR2 ,


  p_start_dt IN DATE ,


  p_org_status IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	-- Fetch the system status.


  	CURSOR	c_os  IS


  	SELECT	s_org_status


  	FROM	IGS_OR_STATUS


  	WHERE	org_status = p_org_status;


  	-- Fetch parent records.


  	CURSOR	c_our_ou_os_parent (


  		cp_org_unit_cd	IGS_OR_UNIT.org_unit_cd%TYPE,


  		cp_start_dt	IGS_OR_UNIT.start_dt%TYPE) IS


  	SELECT	parent_org_unit_cd,


  		parent_start_dt,


  		s_org_status


  	FROM	IGS_OR_UNIT_REL,


  		IGS_OR_UNIT,


  		IGS_OR_STATUS


  	WHERE	child_org_unit_cd = cp_org_unit_cd


  	AND	child_start_dt = cp_start_dt


  	AND	logical_delete_dt IS NULL


  	AND	org_unit_cd = parent_org_unit_cd


  	AND	start_dt = parent_start_dt


  	AND	IGS_OR_UNIT.org_status = IGS_OR_STATUS.org_status;


  	-- Fetch active child records.


  	CURSOR	c_our_ou_os_child IS


  	SELECT	child_org_unit_cd,


  		child_start_dt


  	FROM	IGS_OR_UNIT_REL,


  		IGS_OR_UNIT,


  		IGS_OR_STATUS


  	WHERE	parent_org_unit_cd = p_org_unit_cd


  	AND	parent_start_dt = p_start_dt


  	AND	logical_delete_dt IS NULL


  	AND	org_unit_cd = child_org_unit_cd


  	AND	start_dt = child_start_dt


  	AND	IGS_OR_UNIT.org_status = IGS_OR_STATUS.org_status


  	AND	s_org_status = 'ACTIVE';


  	v_s_org_status	IGS_OR_STATUS.s_org_status%TYPE;


  	v_active_parents	BOOLEAN	DEFAULT FALSE;


  	v_active_children	BOOLEAN	DEFAULT FALSE;


  	v_parents_exist	BOOLEAN	DEFAULT FALSE;


  	v_other_detail	VARCHAR(255);


  BEGIN


  	-- Fetch the system status for the p_org_status.


  	OPEN c_os;


  	FETCH c_os INTO v_s_org_status;


  	CLOSE c_os;


  	IF v_s_org_status = 'ACTIVE' THEN


  		-- If parents exist then validate at least one is active.


  		FOR our_ou_os_parent IN c_our_ou_os_parent (p_org_unit_cd, p_start_dt) LOOP


  			v_parents_exist := TRUE;


  			IF our_ou_os_parent.s_org_status = 'ACTIVE' THEN


  				v_active_parents := TRUE;


  				EXIT;


  			END IF;


  		END LOOP;


  		IF v_parents_exist = TRUE THEN


  			IF v_active_parents = FALSE THEN


  				-- No active parents exist.


  				p_message_name := 'IGS_OR_CANT_UPD_DUE_TO_PARENT';


  				RETURN FALSE;


  			END IF;


  		END IF;


  	END IF;


  	IF v_s_org_status = 'INACTIVE' THEN


  		-- Validate all children are inactive.


  		FOR our_ou_os_child IN c_our_ou_os_child LOOP


  			v_active_parents := FALSE;


  			v_parents_exist := FALSE;


  			v_active_children := TRUE;


  			-- Check if the active child has other active parents.


  			FOR our_ou_os_parent IN c_our_ou_os_parent (


  					our_ou_os_child.child_org_unit_cd,


  					our_ou_os_child.child_start_dt) LOOP


  				IF NOT (our_ou_os_parent.parent_org_unit_cd = p_org_unit_cd AND


  						our_ou_os_parent.parent_start_dt = p_start_dt) THEN


  					v_parents_exist := TRUE;


  					IF our_ou_os_parent.s_org_status = 'ACTIVE' THEN


  						v_active_parents := TRUE;


  						EXIT;


  					END IF;


  				END IF;


  			END LOOP;


  			IF v_parents_exist = TRUE THEN


  				IF v_active_parents = TRUE THEN


  					v_active_children := FALSE;


  				END IF;


  			END IF;


  			IF v_active_children = TRUE THEN


  				-- Acitve children exist.


  				p_message_name := 'IGS_OR_CANT_UPD_DUE_TO_CHILD';


  				RETURN FALSE;


  			END IF;


  		END LOOP;


  	END IF;


  	p_message_name := NULL;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;


  END orgp_val_ou_sts_chng;


  --


  -- Validate the organisational type.


  FUNCTION orgp_val_org_type(


  p_org_type IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR c_ot IS


  	SELECT	enabled_flag


  	FROM	IGS_LOOKUP_VALUES

        WHERE   lookup_type = 'OR_ORG_TYPE'

  	AND	lookup_code = p_org_type

  	AND	enabled_flag = 'N';


  	v_other_detail	VARCHAR2(255);


  BEGIN


  	p_message_name := NULL;


  	FOR ot IN c_ot LOOP


  		p_message_name := 'IGS_OR_TYPE_CANT_CLOSED';


  		RETURN FALSE;


  	END LOOP;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;


  END orgp_val_org_type;


  --


  -- Validate the member type.


  FUNCTION orgp_val_mbr_type(


  p_member_type IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR	c_mt IS


  	SELECT	enabled_flag


  	FROM	IGS_LOOKUP_VALUES

        WHERE   lookup_type = 'OR_MEMBER_TYPE'


  	AND 	lookup_code = p_member_type


  	AND	enabled_flag = 'N';


  	v_other_detail	VARCHAR2(255);


  BEGIN


  	p_message_name := NULL;


  	FOR mt IN c_mt LOOP


  		p_message_name := 'IGS_OR_MEM_TYPE_CANT_CLOSED';


  		RETURN FALSE;


  	END LOOP;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

  END orgp_val_mbr_type;


  --


  -- Validate the organisational IGS_PS_UNIT IGS_OR_INSTITUTION code is active.


  FUNCTION orgp_val_ou_instn_cd(


  p_institution_cd IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR c_ins_ist IS


  	SELECT	s_institution_status


  	FROM	IGS_OR_INSTITUTION,


  		IGS_OR_INST_STAT


  	WHERE	IGS_OR_INSTITUTION.institution_cd = p_institution_cd


  	AND	IGS_OR_INST_STAT.institution_status = IGS_OR_INSTITUTION.institution_status


  	AND	s_institution_status <> 'ACTIVE';


  	v_other_detail		VARCHAR2(255);


  BEGIN


  	p_message_name := NULL;


  	FOR ins_ist IN c_ins_ist LOOP


  		p_message_name := 'IGS_OR_CANT_CREATE_ORG_UNIT';


  		RETURN FALSE;


  	END LOOP;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;


  END orgp_val_ou_instn_cd;


  --


  -- Validate for date overlaps for a specific organisational IGS_PS_UNIT.


  FUNCTION orgp_val_ou_ovrlp(


  p_org_unit_cd IN VARCHAR2 ,


  p_start_dt IN DATE ,


  p_end_dt IN DATE ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR	c_ou IS


  	SELECT	start_dt,


  		end_dt


  	FROM	IGS_OR_UNIT


  	WHERE	org_unit_cd = p_org_unit_cd


  	AND	start_dt <> p_start_dt;


  	v_other_detail	VARCHAR2(255);


  	v_end_dt	IGS_OR_UNIT.end_dt%TYPE;


  BEGIN


  	p_message_name := NULL;


  	-- set p_end_dt to a high date if null


  	IF (p_end_dt IS NULL) THEN


  		v_end_dt := IGS_GE_DATE.IGSDATE('9999/01/01');


  	ELSE


  		v_end_dt := p_end_dt;


  	END IF;


  	FOR ou IN c_ou LOOP


  		-- Validate the start date is not between an existing date range.


  		IF (p_start_dt >= ou.start_dt) AND


  		     (p_start_dt <= NVL(ou.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN


  			p_message_name := 'IGS_OR_ORG_UNIT_OVERLAPS';


  			RETURN FALSE;


  		END IF;


  		-- Validate the end date is not between an existing date range.


  		IF (v_end_dt >= ou.start_dt) AND


  		     (v_end_dt <= NVL(ou.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN


  			p_message_name := 'IGS_OR_ORG_UNIT_OVERLAPS';


  			RETURN FALSE;


  		END IF;


  		-- Validate the current dates do not overlap and entire exisitng date range.


  		IF (p_start_dt <= ou.start_dt AND


  		     v_end_dt >= NVL(ou.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN


  			p_message_name := 'IGS_OR_ORG_UNIT_OVERLAPS';


  			RETURN FALSE;


  		END IF;


  	END LOOP;


  	RETURN TRUE;


  EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;


  END orgp_val_ou_ovrlp;


  --


  -- Cross-field validation of the org IGS_PS_UNIT end date and status.


  FUNCTION orgp_val_ou_end_sts(


  p_end_dt IN DATE ,


  p_org_status IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN AS


  	CURSOR	c_os IS


  	SELECT	s_org_status


  	FROM	IGS_OR_STATUS


  	WHERE	org_status = p_org_status;


  	cst_inactive	CONSTANT VARCHAR2(8) := 'INACTIVE';


  	v_other_detail	VARCHAR2(255);


  BEGIN


  	p_message_name := NULL;


  	FOR os IN c_os LOOP


  		IF p_end_dt IS NOT NULL THEN


  			IF os.s_org_status <> cst_inactive THEN


  				p_message_name := 'IGS_OR_SYS_STAT_MUST_BE_INACT';


  				RETURN FALSE;


  			END IF;


  		ELSE -- end date is null


  			IF os.s_org_status = cst_inactive THEN


  				p_message_name := 'IGS_OR_SYS_STAT_MUST_BE_ACTIV';


  				RETURN FALSE;


  			END IF;


  		END IF;


  	END LOOP;


  	RETURN TRUE;


  	EXCEPTION


  	WHEN OTHERS THEN


       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

  END orgp_val_ou_end_sts;


END IGS_OR_VAL_OU;

/
