--------------------------------------------------------
--  DDL for Package Body IGS_OR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_GEN_001" AS
/* $Header: IGSOR01B.pls 120.2 2005/09/27 06:55:36 appldev ship $ */

/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || pkpatel         12-MAY-2002      Bug No: 2266315
  ||                                  Added the Procedure update_org. Modified orgp_upd_ins_ou_sts AND
  ||                                  orgp_upd_ou_sts to propagate the STATUS through Organizational Structure.
  || ssawhney        11-jun-2002      BUG : 2408794
  ||                                  ORGP_GET_WITHIN_OU, c_our cursor added check for LOGICAL_DELETE_DT IS NULL;
  || pkpatel         25-OCT-2002      Bug No: 2613704
  ||                                  Replaced column inst_priority_code_id with inst_priority_cd in igs_pe_hz_parties_pkg
  || pkpatel          2-DEC-2002      Bug No: 2599109
  ||                                  Added column birth_city, birth_country in the call to TBH igs_pe_hz_parties_pkg
  || ssawhney        30-apr-2003      V2API OVN implementation, change to call to IGS_OR_GEN_012
  || gmaheswa        15-sep-2003      changed orgp_get_local_inst to get local active institution from the profile.
  ||                                  Bug No: 2863933
  || mmkumar        18-Jul-2005       Party_Number impact, inside update_org , modified cursor hz_parties_cur,
  ||                                  igs_or_unit_hist_pkg.insert_row call and call to igs_pe_hz_parties_pkg.update_row
*/

PROCEDURE orgp_del_instn_hist(
  p_institution_cd IN VARCHAR2 )
IS
	v_other_detail	VARCHAR(255);
BEGIN
	DELETE
	FROM 	IGS_OR_INST_HIST
	WHERE	institution_cd = p_institution_cd;
	EXCEPTION
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
END orgp_del_instn_hist;


PROCEDURE orgp_del_ou_hist(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE )
IS
	v_other_detail	VARCHAR(255);
BEGIN
	DELETE
	FROM 	IGS_OR_UNIT_HIST
	WHERE	org_unit_cd = p_org_unit_cd
	AND	ou_start_dt = p_start_dt;
	EXCEPTION
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
END orgp_del_ou_hist;


FUNCTION orgp_get_local_inst
RETURN VARCHAR2 IS
BEGIN	-- orgp_get_local_inst
	-- This module retrieves local active IGS_OR_INSTITUTION from profile value.
DECLARE

	v_institution_cd	IGS_OR_INSTITUTION.institution_cd%TYPE;
BEGIN
	v_institution_cd := NULL;
	v_institution_cd := FND_PROFILE.VALUE('IGS_OR_LOCAL_INST');
	RETURN v_institution_cd;
END;

EXCEPTION
   WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;

END orgp_get_local_inst;


FUNCTION orgp_get_s_loc_type(
 p_location_cd  IGS_AD_LOCATION_ALL.location_cd%TYPE )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- orgp_get_s_loc_type
	-- This module fetches the value for s_location_type for a IGS_AD_LOCATION
	-- from the IGS_AD_LOCATION_TYPE table.
DECLARE
	CURSOR c_lot IS
	SELECT	lot.s_location_type
	FROM	IGS_AD_LOCATION_TYPE	lot,
		IGS_AD_LOCATION	loc
	WHERE	lot.location_type	= loc.location_type AND
		loc.location_cd 	= p_location_cd;
	v_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
BEGIN
	-- Set the default value
	v_s_location_type := NULL;
	OPEN c_lot;
	FETCH c_lot INTO v_s_location_type;
	IF (c_lot%FOUND) THEN
		CLOSE c_lot;
		RETURN v_s_location_type;
	END IF;
	CLOSE c_lot;
	RETURN v_s_location_type;
END;

EXCEPTION
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
	   App_Exception.Raise_Exception ;

END orgp_get_s_loc_type;


FUNCTION orgp_get_s_loc_type2(
  p_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE )
RETURN VARCHAR2  IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- orgp_get_s_loc_type2
	-- This module fetches the value for s_location_type for a
	-- IGS_AD_LOCATION?s IGS_AD_LOCATION type from the IGS_AD_LOCATION_TYPE table.
	-- It is similar to ORGP_GET_S_LOC_TYPE except that it fetches the record
	-- using the IGS_AD_LOCATION type instead of the IGS_AD_LOCATION code as a parameter.
DECLARE
	CURSOR c_lot IS
	SELECT	s_location_type
	FROM	IGS_AD_LOCATION_TYPE
	WHERE	location_type	= p_location_type;
	v_s_location_type	IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
BEGIN
	-- Set the default value
	v_s_location_type := NULL;
	OPEN c_lot;
	FETCH c_lot INTO v_s_location_type;
	IF (c_lot%FOUND) THEN
		CLOSE c_lot;
		RETURN v_s_location_type;
	END IF;
	CLOSE c_lot;
	RETURN v_s_location_type;
END;
EXCEPTION
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
END orgp_get_s_loc_type2;


FUNCTION ORGP_GET_WITHIN_OU(
  p_parent_org_unit_cd IN VARCHAR2 ,
  p_parent_start_dt IN DATE ,
  p_child_org_unit_cd IN VARCHAR2 ,
  p_child_start_dt IN DATE ,
  p_direct_match_ind IN VARCHAR2)
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
	FUNCTION orgpl_get_superiors(
			p_child_org_unit_cd	IN	IGS_OR_UNIT.org_unit_cd%TYPE,
			p_child_start_dt	IN	IGS_OR_UNIT.start_dt%TYPE)
	RETURN VARCHAR2
	IS
	BEGIN
	DECLARE
		CURSOR c_our (
			cp_org_unit_cd		IGS_OR_UNIT.org_unit_cd%TYPE,
			cp_start_dt		IGS_OR_UNIT.start_dt%TYPE) IS
			SELECT	our.parent_org_unit_cd,
				our.parent_start_dt
			FROM	IGS_OR_UNIT_REL	our
			WHERE	our.child_org_unit_cd = cp_org_unit_cd and
				our.child_start_dt = cp_start_dt and
				our.logical_delete_dt IS NULL ; -- new validation as part of bug 2408794
	BEGIN
		-- If records found
		FOR v_our_row IN c_our(
				p_child_org_unit_cd,
				p_child_start_dt) LOOP
			IF (v_our_row.parent_org_unit_cd = p_parent_org_unit_cd) AND
					(v_our_row.parent_start_dt = p_parent_start_dt) THEN
				-- Direct match
				RETURN 'Y';
			ELSIF p_direct_match_ind = 'N' THEN
				-- Recursive - call function again, passing the parent
				-- as the new child.
				IF (orgpl_get_superiors(
						v_our_row.parent_org_unit_cd,
						v_our_row.parent_start_dt) = 'Y') THEN
					RETURN 'Y';
				END IF;
			END IF;
		END LOOP;
		RETURN 'N';
	END;
	END orgpl_get_superiors;
BEGIN
	-- This module determines whether the nominated organisational IGS_PS_UNIT is within
	-- the nominated superior OU. A recursive search is done of all superior org
	-- IGS_PS_UNIT relationships searching for a match with the superior anywhere in the
	-- parent tree.
	-- If p_direct_match_ind is set the the return will only return Y if the
	-- superior  org IGS_PS_UNIT is found as an immediate superior.
	IF (orgpl_get_superiors(
			p_child_org_unit_cd,
			p_child_start_dt) = 'N') THEN
		RETURN 'N';
	ELSE
		RETURN 'Y';
	END IF;
END;
END orgp_get_within_ou;

PROCEDURE orgp_ins_ou_hist(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_hist_start_dt IN DATE ,
  p_hist_end_dt IN DATE ,
  p_hist_who IN VARCHAR2 ,
  p_ou_end_dt IN DATE ,
  p_description IN VARCHAR2 ,
  p_org_status IN VARCHAR2 ,
  p_org_type IN VARCHAR2 ,
  p_member_type IN VARCHAR2 ,
  p_institution_cd IN VARCHAR2 )
IS
	v_name		IGS_OR_UNIT_HIST.name%TYPE;
	v_other_detail	VARCHAR(255);

BEGIN
	-- Determine the value of the IGS_OR_UNIT_HIST.name
	IF p_institution_cd IS NULL THEN
		v_name := NULL;
	ELSE
		SELECT	name
		INTO	v_name
		FROM	IGS_OR_INSTITUTION
		WHERE	institution_cd = p_institution_cd;
	END IF;
	-- Insert the IGS_OR_UNIT_HIST record.
	INSERT INTO IGS_OR_UNIT_HIST
		(org_unit_cd,
		ou_start_dt,
		hist_start_dt,
		hist_end_dt,
		hist_who,
		ou_end_dt,
		description,
		org_status,
		org_type,
		member_type,
		institution_cd,
		name,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE)
	VALUES (	p_org_unit_cd,
		p_ou_start_dt,
		p_hist_start_dt,
		p_hist_end_dt,
		p_hist_who,
		p_ou_end_dt,
		p_description,
		p_org_status,
		p_org_type,
		p_member_type,
		p_institution_cd,
		v_name,
		1,
		SYSDATE,
		1,
		SYSDATE);
	EXCEPTION
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
END orgp_ins_ou_hist;


PROCEDURE orgp_upd_ins_ou_sts(
  p_institution_cd IN VARCHAR2 ,
  p_org_status  VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
IS
/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose : This procedure updates the INST record while status is made ACTIVE to INACTIVE
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
	v_complete	BOOLEAN;
	v_other_detail	VARCHAR(255);
	v_message_name	VARCHAR2(30);
    v_active_parent_exists BOOLEAN := FALSE;

	-- Define a PL/SQL table to hold the Org Unit Code that are already processed
   TYPE  t_temp_table IS TABLE OF hz_parties.party_number%TYPE
        INDEX BY BINARY_INTEGER;

   temp_table    t_temp_table;
   l_index       binary_integer := 0;
   l_check       NUMBER := 0;
   l_count       NUMBER := 0;

	-- Cursor to find out NOCOPY the Active Organization Units attached with the Institution
	CURSOR c_ou_instn
	IS
	SELECT IGS_OR_UNIT.org_unit_cd,
		   IGS_OR_UNIT.start_dt
	FROM   IGS_OR_UNIT,
		   IGS_OR_STATUS
	WHERE  IGS_OR_UNIT.institution_cd = p_institution_cd
	AND	   IGS_OR_STATUS.org_status = IGS_OR_UNIT.org_status
	AND	   IGS_OR_STATUS.s_org_status = 'ACTIVE'
	ORDER BY IGS_OR_UNIT.institution_cd;

       CURSOR	c_ou_parent (
			cp_org_unit_cd	IGS_OR_UNIT_REL.parent_org_unit_cd%TYPE,
			cp_start_dt	    IGS_OR_UNIT_REL.parent_start_dt%TYPE) IS
		SELECT	parent_org_unit_cd,
			    parent_start_dt
		FROM  IGS_OR_UNIT_REL,
			  IGS_OR_UNIT,
			  IGS_OR_STATUS
		WHERE	child_org_unit_cd = cp_org_unit_cd
		AND	child_start_dt = cp_start_dt
		AND	logical_delete_dt IS NULL
		AND	org_unit_cd = parent_org_unit_cd
		AND	start_dt = parent_start_dt
		AND	IGS_OR_STATUS.org_status = IGS_OR_UNIT.org_status
		AND	IGS_OR_STATUS.s_org_status = 'ACTIVE';

        ou_parent   c_ou_parent%ROWTYPE;

	-- Local function
	FUNCTION orgp_upd_ins_ou_sts_loop (
		p_org_unit_cd	IN	IGS_OR_UNIT.org_unit_cd%TYPE,
		p_start_dt	IN	IGS_OR_UNIT.start_dt%TYPE,
		p_org_instn_cd	IN	IGS_OR_UNIT.institution_cd%TYPE,
		p_institution_cd	IN	IGS_OR_UNIT.institution_cd%TYPE,
		p_new_org_status	IN	IGS_OR_STATUS.s_org_status%TYPE,
		p_complete	OUT NOCOPY	BOOLEAN)
			RETURN BOOLEAN  IS

		v_update_ou		BOOLEAN;
		v_other_active_parent	BOOLEAN;

        -- Cursor to find all the Child Org Unit Code of the Org Units related to the Org Unit.
		CURSOR c_our_child
		IS
		SELECT IGS_OR_UNIT_REL.child_org_unit_cd,
		   	   IGS_OR_UNIT_REL.child_start_dt,
			   IGS_OR_UNIT.institution_cd
		FROM   IGS_OR_UNIT_REL,
			   IGS_OR_UNIT,
			   IGS_OR_STATUS
		WHERE  IGS_OR_UNIT_REL.parent_org_unit_cd = p_org_unit_cd
		AND	IGS_OR_UNIT_REL.parent_start_dt       = p_start_dt
		AND	  IGS_OR_UNIT_REL.logical_delete_dt IS NULL
		AND	  IGS_OR_UNIT.org_unit_cd             = IGS_OR_UNIT_REL.child_org_unit_cd
		AND	  IGS_OR_UNIT.start_dt                = IGS_OR_UNIT_REL.child_start_dt
		AND	  IGS_OR_STATUS.org_status            = IGS_OR_UNIT.org_status
		AND	  IGS_OR_STATUS.s_org_status          = 'ACTIVE';

		-- Fetch other active parents.
		CURSOR	c_our_ou_os_parent (
			cp_parent_org_unit_cd	IGS_OR_UNIT_REL.parent_org_unit_cd%TYPE,
			cp_parent_start_dt	    IGS_OR_UNIT_REL.parent_start_dt%TYPE,
			cp_child_org_unit_cd	IGS_OR_UNIT_REL.child_org_unit_cd%TYPE,
			cp_child_start_dt	IGS_OR_UNIT_REL.child_start_dt%TYPE) IS
		SELECT	parent_org_unit_cd,
			    parent_start_dt
		FROM  IGS_OR_UNIT_REL,
			  IGS_OR_UNIT,
			  IGS_OR_STATUS
		WHERE	child_org_unit_cd = cp_child_org_unit_cd
		AND	child_start_dt = cp_child_start_dt
		AND	NOT (
			parent_org_unit_cd = cp_parent_org_unit_cd AND
			parent_start_dt = cp_parent_start_dt)
		AND	logical_delete_dt IS NULL
		AND	org_unit_cd = parent_org_unit_cd
		AND	start_dt = parent_start_dt
		AND	IGS_OR_STATUS.org_status = IGS_OR_UNIT.org_status
		AND	IGS_OR_STATUS.s_org_status = 'ACTIVE';


		v_rowid VARCHAR2(25);

	BEGIN
		-- Default v_update_ou to true so that if no children exist
		-- then possible to update the current OU.
		v_update_ou := TRUE;
		p_complete := TRUE;
		v_other_active_parent := FALSE;

		l_index := l_index + 1;
		temp_table(l_index) := p_org_unit_cd;

		-- have a cursor to select all active children(Org Unit attached with the Parent Org Unit)
		FOR our_child IN c_our_child LOOP

         	-- Validate if child has other active parents.
			FOR our_ou_os_parent IN c_our_ou_os_parent (
					p_org_unit_cd,
					p_start_dt,
					our_child.child_org_unit_cd,
					our_child.child_start_dt) LOOP
				v_other_active_parent := TRUE;
				EXIT;
			END LOOP;

			-- If child has other active parent then don't update.
			IF v_other_active_parent = TRUE THEN
				v_update_ou := FALSE;
				EXIT;
			END IF;

			-- if any children found then
			-- call orgp_upd_ins_ou_sts_loop to process children

			IF orgp_upd_ins_ou_sts_loop(our_child.child_org_unit_cd,
				our_child.child_start_dt,
				our_child.institution_cd,
				p_institution_cd,
				p_new_org_status,
				p_complete) = FALSE THEN

				-- if orgp_upd_ins_ou_sts_loop returns false
				-- indicates that the current OU is not to be updated as
				-- it has active children.
				-- set a flag to indicate this.
				v_update_ou := FALSE;
				EXIT;
			END IF;

		END LOOP;

		-- check the results of processing as to whether to update current Org Unit

	IF  v_update_ou AND
		   (p_institution_cd = p_org_instn_cd) THEN
			-- If no active children, and
			-- IGS_OR_INSTITUTION codes match then update the org IGS_OR_UNIT
			-- and return true to indicate to the calling parent
			-- that there is no active child.

 		 IF TRUNC(SYSDATE) >= p_start_dt THEN

             -- Check whether the Org Unit is already processed. If it is already processed once
			 -- then do not update it again
			 FOR l_count IN 1..l_index LOOP
		       IF temp_table(l_count) = p_org_unit_cd THEN
			         l_check := l_check +1;
               END IF;
 		     END LOOP ;

		       IF l_check = 1 THEN
                 igs_or_gen_001.update_org(p_org_unit_cd,
 				                             p_new_org_status,
						                     TRUNC(SYSDATE));

  	 	       END IF;
			    l_check := 0;
				RETURN TRUE;
		 ELSE
				-- End date cannot be less than start date.
				v_message_name := 'IGS_OR_CHECK_ST_END_DATES';
				p_complete := FALSE;
				RETURN FALSE;
		 END IF;
	ELSE

            -- If Children of the Current Org Unit has different ACTIVE parents.
			IF p_institution_cd = p_org_instn_cd THEN

				IF v_message_name = 'IGS_OR_INS_STAT_PROPOGATED' THEN
					v_message_name := 'IGS_OR_CHK_ORG_STAT_PROPOGA';
				END IF;

            ELSE
            -- If the Current Org Unit is also attached with a different Institution.
			    IF v_message_name = 'IGS_OR_INS_STAT_PROPOGATED' THEN
					v_message_name := 'IGS_OR_CHK_INST_NOT_PROPOGATE';
				END IF;

			END IF;

			-- Set the flag to indicate the propagation was not complete
			p_complete := FALSE;

			-- Return false to indicate to the calling parent that the child is still active.
			RETURN FALSE;

		END IF;
	END orgp_upd_ins_ou_sts_loop; -- Local function ORGP_UPD_INS_OU_STS_LOOP

BEGIN  -- ORGP_UPD_INS_OU_STS

	-- default message to say complete propagation.
	v_message_name := 'IGS_OR_INS_STAT_PROPOGATED';
	v_complete := TRUE;

	-- Select all active org units with the IGS_OR_INSTITUTION whose status has changed to inactive.
	SAVEPOINT do_propagation;

	FOR ou_instn IN c_ou_instn LOOP

      OPEN   c_ou_parent(ou_instn.org_unit_cd, ou_instn.start_dt);
	  FETCH  c_ou_parent INTO ou_parent;
	     IF c_ou_parent%FOUND THEN
		    CLOSE c_ou_parent;
		    v_active_parent_exists := TRUE;
			v_complete := FALSE;
			EXIT;
		 END IF;
      CLOSE  c_ou_parent;

		-- if any org units found then
		-- call orgp_upd_ins_ou_sts_loop to process its children
		IF orgp_upd_ins_ou_sts_loop(ou_instn.org_unit_cd,
			ou_instn.start_dt,
			p_institution_cd,
			p_institution_cd,
			p_org_status,
			v_complete) = TRUE THEN
			-- not interested in the value orgp_upd_ins_ou_sts_loop returns
			-- as this value is used within the recursive function to indicate
			-- if active child records exist.
			NULL;

		END IF;
		IF v_complete = FALSE THEN
			EXIT;
		END IF;
	END LOOP;

    IF v_active_parent_exists THEN
		v_message_name := 'IGS_OR_CHK_ORG_STAT_PROPOGA';
	END IF;

	IF v_complete = FALSE THEN
		ROLLBACK TO do_propagation;
	END IF;
	p_message_name := v_message_name;

	EXCEPTION
  	 WHEN OTHERS THEN
 	   ROLLBACK TO do_propagation;
       FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;

END orgp_upd_ins_ou_sts;


PROCEDURE orgp_upd_ou_sts(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_org_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
IS
/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose : This procedure updates the ORG record while status is made ACTIVE to INACTIVE
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
	v_complete	BOOLEAN;
	v_message_name	VARCHAR2(30);

	-- Local function.
	FUNCTION orgp_upd_ou_sts_loop (
		p_org_unit_cd	IN	IGS_OR_UNIT.org_unit_cd%TYPE,
		p_start_dt	IN	IGS_OR_UNIT.start_dt%TYPE,
		p_end_dt	IN	IGS_OR_UNIT.end_dt%TYPE,
		p_complete	OUT NOCOPY	BOOLEAN)
	RETURN BOOLEAN IS
		-- Fetch active children.
		CURSOR	c_our_ou_os_child IS
		SELECT	child_org_unit_cd,
	  		    child_start_dt
		FROM  IGS_OR_UNIT_REL,
			  IGS_OR_UNIT,
			  IGS_OR_STATUS
		WHERE	parent_org_unit_cd = p_org_unit_cd
		AND	parent_start_dt = p_start_dt
		AND	logical_delete_dt IS NULL
		AND	org_unit_cd = child_org_unit_cd
		AND	start_dt = child_start_dt
		AND	IGS_OR_STATUS.org_status = IGS_OR_UNIT.org_status
		AND	IGS_OR_STATUS.s_org_status = 'ACTIVE';

		-- Fetch other active parents.
		CURSOR	c_our_ou_os_parent (
			cp_parent_org_unit_cd	IGS_OR_UNIT_REL.parent_org_unit_cd%TYPE,
			cp_parent_start_dt	    IGS_OR_UNIT_REL.parent_start_dt%TYPE,
			cp_child_org_unit_cd	IGS_OR_UNIT_REL.child_org_unit_cd%TYPE,
			cp_child_start_dt	IGS_OR_UNIT_REL.child_start_dt%TYPE) IS
		SELECT	parent_org_unit_cd,
			    parent_start_dt
		FROM  IGS_OR_UNIT_REL,
			  IGS_OR_UNIT,
			  IGS_OR_STATUS
		WHERE	child_org_unit_cd = cp_child_org_unit_cd
		AND	child_start_dt = cp_child_start_dt
		AND	NOT (
			parent_org_unit_cd = cp_parent_org_unit_cd AND
			parent_start_dt = cp_parent_start_dt)
		AND	logical_delete_dt IS NULL
		AND	org_unit_cd = parent_org_unit_cd
		AND	start_dt = parent_start_dt
		AND	IGS_OR_STATUS.org_status = IGS_OR_UNIT.org_status
		AND	IGS_OR_STATUS.s_org_status = 'ACTIVE';

		v_update_ou 		    BOOLEAN;
		v_other_active_parent	BOOLEAN;
		v_other_detail		    VARCHAR2(255);
	BEGIN
		v_update_ou := TRUE;
		v_other_active_parent := FALSE;

		-- Fetch active children for the organisational IGS_OR_UNIT.
		FOR our_ou_os_child IN c_our_ou_os_child LOOP

			 -- Validate if child has other active parents.
			FOR our_ou_os_parent IN c_our_ou_os_parent (
					p_org_unit_cd,
					p_start_dt,
					our_ou_os_child.child_org_unit_cd,
					our_ou_os_child.child_start_dt) LOOP
				v_other_active_parent := TRUE;
				EXIT;
			END LOOP;

			-- If child has other active parent then don't update.
			IF v_other_active_parent = TRUE THEN
				v_update_ou := FALSE;
				EXIT;
			END IF;

			-- Process active children for the child.
			IF orgp_upd_ou_sts_loop (
					our_ou_os_child.child_org_unit_cd,
					our_ou_os_child.child_start_dt,
					p_end_dt,
					p_complete) = FALSE THEN
	  			     v_update_ou := FALSE;
				EXIT;
			END IF;
		END LOOP;

		IF v_update_ou = TRUE THEN
			IF p_end_dt >= p_start_dt THEN

              -- The Updation of the Most Parent Org Unit should be prevented. Th Updation this Org Unit should
			  -- happen in the Form.
              IF g_org_unit_cd <> p_org_unit_cd THEN

			    igs_or_gen_001.update_org(p_org_unit_cd,
 				                          p_org_status,
					    	              p_end_dt);

              END IF;
		      RETURN TRUE;
			ELSE
				p_message_name := 'IGS_OR_CHILD_ORG_UNIT_EXISTS';
				p_complete := FALSE;
				RETURN FALSE;
			END IF;
		ELSE
			IF v_other_active_parent = TRUE THEN
				p_message_name := 'IGS_OR_CHK_ORG_STAT_PROPOGA';
				p_complete := FALSE;
			END IF;
			RETURN FALSE;
		END IF;

 EXCEPTION
	WHEN OTHERS THEN
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
	END orgp_upd_ou_sts_loop;

BEGIN
	p_message_name := 'IGS_OR_STAT_SUCCESS_PROPOGATE';
	v_complete := TRUE;
	SAVEPOINT do_propagation;

    -- This global variable holds the Parent Org Unit.
	g_org_unit_cd := p_org_unit_cd;

	IF orgp_upd_ou_sts_loop (
			p_org_unit_cd,
			p_start_dt,
			p_end_dt,
			v_complete) = TRUE THEN

		-- orgp_upd_ou_sts_loop is only concerned with
		-- the return value when called by itself.
		NULL;
	END IF;

	IF v_complete = FALSE THEN
		ROLLBACK TO do_propagation;
	END IF;

EXCEPTION
   WHEN OTHERS THEN
   	   ROLLBACK TO do_propagation;
       FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
END orgp_upd_ou_sts;

PROCEDURE  update_org(p_org_unit_cd  hz_parties.party_number%TYPE,
                      p_org_status   igs_pe_hz_parties.ou_org_status%TYPE,
					  p_end_date     igs_pe_hz_parties.ou_end_dt%TYPE)
IS
/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose : This procedure updates the ORG record and creates its history.
  ||            The TCA API is being called to refresh the last_update_date. So that the History would be created properly
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When           What
  ||  skpandey   27-SEP-2005    Bug: 3663505
  ||                            Description: Added ATTRIBUTES 21 TO 24 to store additional information in IGS_OR_GEN_012_PKG call
  || pkpatel     25-OCT-2002    Bug No: 2613704
  ||                            Modified signature of igs_pe_hz_parties_pkg to refer inst_priority_cd instead of inst_priority_code_id
  || mmkumar     18-Jul-2005    Party_Number impact, modified cursor hz_parties_cur, igs_or_unit_hist_pkg.insert_row call
  ||                            and call to igs_pe_hz_parties_pkg.update_row
  ||  (reverse chronological order - newest change first)
*/

l_return_status       VARCHAR2(1);
l_msg_data            VARCHAR2(2000);
lv_rowid              VARCHAR2(30);
l_org_id              VARCHAR2(25);
l_hist_start_dt       DATE;
l_hist_end_dt         DATE;

CURSOR  hz_parties_cur
IS
SELECT hp.*, ihp.oss_org_unit_cd
FROM   hz_parties hp, igs_pe_hz_parties ihp
WHERE  ihp.oss_org_unit_cd = p_org_unit_cd and
       ihp.party_id = hp.party_id;

CURSOR  igs_org_cur(cp_party_id  igs_pe_hz_parties.party_id%TYPE)
IS
SELECT rowid, pe.*
FROM   igs_pe_hz_parties pe
WHERE  party_id = cp_party_id
FOR UPDATE OF ou_end_dt, ou_org_status NOWAIT;

hz_parties_rec   hz_parties_cur%ROWTYPE;
igs_org_rec      igs_org_cur%ROWTYPE;

BEGIN

    OPEN   hz_parties_cur;
	FETCH  hz_parties_cur  INTO hz_parties_rec;
	CLOSE  hz_parties_cur;

      -- The Record in HZ_PARTIES was still updated with STATUS 'A'(Active), since it was decided not to
	  -- touch the record in HZ_PARTIES since other products may also be using this TCA record.
	  -- This call is made so that the last update date is refreshed and the History would show the proper Start and End Date.

      igs_or_gen_012_pkg.update_organization (
      p_party_id                          => hz_parties_rec.party_id,
      p_institution_cd                    => hz_parties_rec.party_number,
      p_name                              => hz_parties_rec.party_name,
      p_status                            => 'A',
      p_last_update                       => hz_parties_rec.last_update_date,
      p_attribute_category                => hz_parties_rec.attribute_category,
      p_attribute1                        => hz_parties_rec.attribute1,
      p_attribute2                        => hz_parties_rec.attribute2,
      p_attribute3                        => hz_parties_rec.attribute3,
      p_attribute4                        => hz_parties_rec.attribute4,
      p_attribute5                        => hz_parties_rec.attribute5,
      p_attribute6                        => hz_parties_rec.attribute6,
      p_attribute7                        => hz_parties_rec.attribute7,
      p_attribute8                        => hz_parties_rec.attribute8,
      p_attribute9                        => hz_parties_rec.attribute9,
      p_attribute10                       => hz_parties_rec.attribute10,
      p_attribute11                       => hz_parties_rec.attribute11,
      p_attribute12                       => hz_parties_rec.attribute12,
      p_attribute13                       => hz_parties_rec.attribute13,
      p_attribute14                       => hz_parties_rec.attribute14,
      p_attribute15                       => hz_parties_rec.attribute15,
      p_attribute16                       => hz_parties_rec.attribute16,
      p_attribute17                       => hz_parties_rec.attribute17,
      p_attribute18                       => hz_parties_rec.attribute18,
      p_attribute19                       => hz_parties_rec.attribute19,
      p_attribute20                       => hz_parties_rec.attribute20,
      p_return_status                     => l_return_status,
      p_msg_data                          => l_msg_data,
      p_object_version_number             => hz_parties_rec.object_version_number,
      p_attribute21                       => hz_parties_rec.attribute21,
      p_attribute22                       => hz_parties_rec.attribute22,
      p_attribute23                       => hz_parties_rec.attribute23,
      p_attribute24                       => hz_parties_rec.attribute24
    ) ;


    IF l_return_status = 'S' THEN

      -- To check whether the Record is locked.
	  OPEN  igs_org_cur(hz_parties_rec.party_id);
      FETCH igs_org_cur INTO igs_org_rec;
	  IF igs_org_cur%NOTFOUND THEN
          CLOSE igs_org_cur;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
	  CLOSE igs_org_cur;

	 igs_pe_hz_parties_pkg.update_row (
        x_mode                              => 'R',
        x_rowid                             => igs_org_rec.rowid,
        x_party_id                          => igs_org_rec.party_id,
        x_deceased_ind                      => igs_org_rec.deceased_ind,
        x_archive_exclusion_ind             => igs_org_rec.archive_exclusion_ind,
        x_archive_dt                        => igs_org_rec.archive_dt,
        x_purge_exclusion_ind               => igs_org_rec.purge_exclusion_ind,
        x_purge_dt                          => igs_org_rec.purge_dt,
        x_oracle_username                   => igs_org_rec.oracle_username,
        x_proof_of_ins                      => igs_org_rec.proof_of_ins,
        x_proof_of_immu                     => igs_org_rec.proof_of_immu,
        x_level_of_qual                     => igs_org_rec.level_of_qual,
        x_military_service_reg              => igs_org_rec.military_service_reg,
        x_veteran                           => igs_org_rec.veteran,
        x_institution_cd                    => igs_org_rec.institution_cd,
        x_oi_local_institution_ind          => igs_org_rec.oi_local_institution_ind,
        x_oi_os_ind                         => igs_org_rec.oi_os_ind,
        x_oi_govt_institution_cd            => igs_org_rec.oi_govt_institution_cd,
        x_oi_inst_control_type              => igs_org_rec.oi_inst_control_type,
        x_oi_institution_type               => igs_org_rec.oi_institution_type,
        x_oi_institution_status             => igs_org_rec.oi_institution_status,
        x_ou_start_dt                       => igs_org_rec.ou_start_dt,
        x_ou_end_dt                         => p_end_date,
        x_ou_member_type                    => igs_org_rec.ou_member_type,
        x_ou_org_status                     => p_org_status,
        x_ou_org_type			    => igs_org_rec.ou_org_type,
        x_inst_org_ind                      => igs_org_rec.inst_org_ind,
        x_inst_priority_cd                  => igs_org_rec.inst_priority_cd,
        x_inst_eps_code                     => igs_org_rec.inst_eps_code,
        x_inst_phone_country_code           => igs_org_rec.inst_phone_country_code,
        x_inst_phone_area_code              => igs_org_rec.inst_phone_area_code,
        x_inst_phone_number                 => igs_org_rec.inst_phone_number,
        x_adv_studies_classes               => igs_org_rec.adv_studies_classes,
        x_honors_classes                    => igs_org_rec.honors_classes,
        x_class_size                        => igs_org_rec.class_size,
        x_sec_school_location_id            => igs_org_rec.sec_school_location_id,
        x_percent_plan_higher_edu           => igs_org_rec.percent_plan_higher_edu,
        x_fund_authorization		    => igs_org_rec.fund_authorization,
        x_pe_info_verify_time               => igs_org_rec.pe_info_verify_time,
	x_birth_city                        => igs_org_rec.birth_city,
	x_birth_country                     => igs_org_rec.birth_country,
	x_oss_org_unit_cd                   => hz_parties_rec.oss_org_unit_cd  --mmkumar , party_number impact

      );

         l_org_id    := igs_ge_gen_003.get_org_id ;

          -- 1 Second is deducted, to prevent the PK validation. The Hisory Start Date is part of PK.
         l_hist_start_dt :=  hz_parties_rec.last_update_date - 1/(60*24*60);
         l_hist_end_dt :=    SYSDATE;

          igs_or_unit_hist_pkg.insert_row (
                 X_ROWID         => lv_rowid,
                 X_ORG_UNIT_CD   => hz_parties_rec.oss_org_unit_cd,
                 X_OU_START_DT   => igs_org_rec.ou_start_dt,
                 X_HIST_START_DT => l_hist_start_dt,
                 X_HIST_END_DT   => l_hist_end_dt,
                 X_HIST_WHO      => hz_parties_rec.last_updated_by,
                 X_OU_END_DT     => igs_org_rec.ou_end_dt,
                 X_DESCRIPTION   => hz_parties_rec.party_name,
                 X_ORG_STATUS    => igs_org_rec.ou_org_status,
                 X_ORG_TYPE      => igs_org_rec.ou_org_type,
                 X_MEMBER_TYPE   => igs_org_rec.ou_member_type,
                 X_INSTITUTION_CD => igs_org_rec.institution_cd,
                 X_NAME          => NULL,
                 X_MODE          => 'R' ,
                 X_ORG_ID        => l_org_id
            );
    ELSE

          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

-- Exception Section was not kept. All the Exceptions will be handled in the calling procedures and further in the FORM
END update_org;

END IGS_OR_GEN_001 ;

/
