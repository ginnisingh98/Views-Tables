--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_INS" AS
 /* $Header: IGSOR03B.pls 115.9 2003/10/31 12:35:29 gmaheswa ship $ */

/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO           WHEN          WHAT
  ||  pkpatel     5-MAR-2002     Bug NO: 2224621
  ||                             MOdified the field GOVT_INSTITUTION_CD from NUMBER to VARCHAR2
  ||                             in Procedure ORGP_VAL_GOVT_CD
  ||  pkpatel     27-OCT-2002    Bug No: 2613704
  ||                             Modified for lookup migration of GOVT_INSTITUTION_CD
  ||  gmaheswa    12-SEP-2003    Bug No: 2863933
  ||                             Modified orgp_val_ins_local to return False as default.
  ||  (reverse chronological order - newest change first)
  */

  -- Validate the delete of an instn code on records with no foreign key.

  FUNCTION orgp_val_instn_del(

  p_institution_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  	gv_other_detail		VARCHAR2(255);

  BEGIN

  DECLARE

  	v_person_id			IGS_PE_STATISTICS.person_id%TYPE;

  	v_course_cd			IGS_AV_ADV_STANDING.course_cd%TYPE;

  	CURSOR c_person_stats (

  			cp_institution_cd	IGS_OR_INSTITUTION.institution_cd%TYPE) IS

  		SELECT	ps.person_id

  		FROM	IGS_PE_STATISTICS ps

  		WHERE	ps.prior_ug_inst = cp_institution_cd;

  	CURSOR c_advanced_stand (

  			cp_institution_cd	IGS_OR_INSTITUTION.institution_cd%TYPE) IS

  		SELECT	advs.course_cd

  		FROM	IGS_AV_ADV_STANDING advs

  		WHERE	advs.exemption_institution_cd = cp_institution_cd;

  BEGIN

  	-- This module validates the deletion of an institution record.

  	-- Ensure the record is not used on a table that uses institution

  	-- codes, but does not have a foreign key to the institution table.

  	-- Some tables have been designed like this to allow for the entry

  	-- of an institution code or a valid DEETYA value.

  	-- Set the default message number

  	p_message_name := NULL;

  	-- VALIDATE THE IGS_PE_STATISTICS TABLE

  	-- Get the person_id based on the institution

  	-- code entered

  	OPEN	c_person_stats(

  			p_institution_cd);

  	FETCH	c_person_stats INTO v_person_id;

  	-- Check if a record was found.  If so, the

  	-- institution record trying to be deleted was

  	-- being used by the prior_ug_inst column on the

  	-- IGS_PE_STATISTICS table

  	IF (c_person_stats%FOUND) THEN

  		CLOSE c_person_stats;

  		p_message_name := 'IGS_GE_PER_STATS_EXISTS';

  		RETURN FALSE;

  	END IF;

  	CLOSE c_person_stats;

  	-- VALIDATE THE ADVANCED STANDING TABLE

  	-- Get the course_cd based on the institution

  	-- code entered

  	OPEN	c_advanced_stand(

  			p_institution_cd);

  	FETCH	c_advanced_stand INTO v_course_cd;

  	-- Check if a record was found.  If so, the

  	-- institution record trying to be deleted was

  	-- being used by the exemption_institution_cd

  	-- column on the IGS_AV_ADV_STANDING table

  	IF (c_advanced_stand%FOUND) THEN

  		CLOSE c_advanced_stand;

  		p_message_name := 'IGS_GE_ADV_STANDING_EXISTS';

  		RETURN FALSE;

  	END IF;

  	CLOSE c_advanced_stand;

  	-- Return the default value

  	RETURN TRUE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN

       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

  END orgp_val_instn_del;

  --

  -- Validate the government institution code.

  FUNCTION orgp_val_govt_cd(

  p_govt_institution_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN Boolean AS

  	CURSOR	c_gic IS

  	SELECT	enabled_flag

  	FROM	igs_lookup_values

  	WHERE	lookup_type = 'OR_INST_GOV_CD'

  	AND	enabled_flag = 'N'

	AND     lookup_code  = p_govt_institution_cd;

  	v_other_detail	VARCHAR2(255);

  BEGIN

  	p_message_name := NULL;

  	FOR gic IN c_gic LOOP

  		p_message_name := 'IGS_OR_GOV_INST_CANT_CLOSED';

  		RETURN FALSE;

  	END LOOP;

  	RETURN TRUE;

  	EXCEPTION

  	WHEN OTHERS THEN

       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

  END orgp_val_govt_cd;

  --

  -- Validate the institution status.

  FUNCTION orgp_val_instn_sts(

  p_institution_cd IN VARCHAR2 ,

  p_institution_status IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN Boolean AS

  	v_closed_ind		IGS_OR_INST_STAT.closed_ind%TYPE;

  	v_s_institution_status	IGS_OR_INST_STAT.s_institution_status%TYPE;

  	v_message_name		VARCHAR2(30);

  	v_other_detail		VARCHAR2(255);

  BEGIN

  	SELECT	closed_ind,

  		s_institution_status

  	INTO	v_closed_ind,

  		v_s_institution_status

  	FROM	IGS_OR_INST_STAT

  	WHERE	institution_status = p_institution_status;

  	-- Validate the closed indicator.

  	IF v_closed_ind = 'Y' THEN

  		p_message_name := 'IGS_OR_INS_STAT_CANT_CLOSED';

  		RETURN FALSE;

  	END IF;

  	-- If INACTIVE, validate there are no ACTIVE associated org units

  	IF v_s_institution_status = 'INACTIVE' THEN

  		IF IGS_OR_VAL_INS.orgp_val_no_actv_ou (

  				p_institution_cd,

  				v_message_name) = FALSE THEN

  			p_message_name := v_message_name ;

  			return FALSE;

  		END IF;

  	END IF;

  	RETURN TRUE;

  	EXCEPTION

  	WHEN OTHERS THEN

       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

  END orgp_val_instn_sts;

  --

  -- Validate no active org units are associated with the specified instn.

  FUNCTION orgp_val_no_actv_ou(

  p_institution_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN Boolean AS

  	CURSOR c_ou IS

  	SELECT	org_unit_cd

  	FROM	IGS_OR_UNIT,

  		IGS_OR_STATUS

  	WHERE	institution_cd = p_institution_cd

  	AND	IGS_OR_UNIT.org_status = IGS_OR_STATUS.org_status

  	AND	IGS_OR_STATUS.s_org_status = 'ACTIVE';

  	v_org_unit_cd	IGS_OR_UNIT.org_unit_cd%TYPE;

  	v_other_detail	VARCHAR2(255);

  BEGIN

  	OPEN c_ou;

  	FETCH c_ou  INTO v_org_unit_cd;

   	IF c_ou%NOTFOUND THEN

  		CLOSE c_ou;

  		p_message_name := NULL;

  		RETURN TRUE;

  	ELSE

  		CLOSE c_ou;

  		p_message_name := 'IGS_OR_INST_STAT_CANT_CHANGED';

  		RETURN FALSE;

  	END IF;

  	EXCEPTION

  	WHEN OTHERS THEN

       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

  END orgp_val_no_actv_ou;

  --
  -- Modified to return false as per Bug:2863933
  FUNCTION orgp_val_ins_local(

  p_institution_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS
  v_institution_cd	IGS_OR_INSTITUTION.institution_cd%TYPE := NULL;
  BEGIN
        v_institution_cd := FND_PROFILE.VALUE('IGS_OR_LOCAL_INST');
        IF (p_institution_cd <> NVL(v_institution_cd,'') ) THEN
       	   RETURN FALSE;
        ELSE
	   RETURN TRUE;
	END IF;
  END orgp_val_ins_local;

END IGS_OR_VAL_INS;

/
