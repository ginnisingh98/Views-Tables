--------------------------------------------------------
--  DDL for Package Body IGS_PE_VAL_PIGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_VAL_PIGS" AS
  /* $Header: IGSPE02B.pls 120.1 2006/01/18 22:41:39 skpandey noship $ */

  --
  -- Validate IGS_PE_PERSON id group security ins/upd/del security
  FUNCTION idgp_val_pigs_iud(
  p_group_id IN IGS_PE_PERSID_GROUP_ALL.group_id%TYPE ,
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- idgp_val_pigs_iud
  	-- Validate that only the group creator and application owner can
  	--  insert, update and delete IGS_PE_PERSON ID Group Security records.
  DECLARE
  	v_creator_person_id	NUMBER;
  	v_user			VARCHAR2(30);

-- skpandey, Bug#4937960: changed the definition of cursor
	CURSOR c_pig IS
		SELECT pig.creator_person_id
		FROM IGS_PE_PERSID_GROUP_ALL pig, igs_pe_hz_parties pe, hz_parties hp
		WHERE pig.group_id  = p_group_id AND
		pig.creator_person_id = hp.party_id AND
		hp.party_id = pe.party_id (+) AND
		pig.creator_person_id = pe.party_id AND
		(pe.oracle_username = fnd_global.user_name OR pe.oracle_username IS NULL);

  BEGIN
  	-- 1.
  	IF (p_group_id IS NULL) THEN
  		 p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- 2. Check if the user is the application owner.

  	-- 3. Check if the current user is the group creator.
  	-- The group_creator has full insert/update/delete priviledges.
  	OPEN c_pig;
  	FETCH c_pig INTO v_creator_person_id;
  	IF (c_pig%NOTFOUND) THEN
  		CLOSE c_pig;
  		 p_message_name := 'IGS_PE_GRP_CREATOR_CANNOT_IUD';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pig;
  	-- 4.  Check if the security record is being created for the group creator
  	IF v_creator_person_id = p_person_id THEN
  		p_message_name := 'IGS_PE_GRP_SEC_REC_CANNOT_INS';
  		RETURN FALSE;
  	END IF;
  	 p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_pig%ISOPEN) THEN
  			CLOSE c_pig;
  		END IF;
  END;
  EXCEPTION
      	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  	 IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
  END idgp_val_pigs_iud;
END IGS_PE_VAL_PIGS;

/
