--------------------------------------------------------
--  DDL for Package Body IGS_PE_VAL_PIGM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_VAL_PIGM" AS
  /* $Header: IGSPE01B.pls 120.1 2006/01/18 22:50:56 skpandey noship $ */

  ------------------------------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi  27-sep-2001    Added function merged_ind as a part of person Detail build.bug no:2000408
  ----------------------------------------------------------------------------------------------
  -- Validate IGS_PE_PERSON id group member ins/upd/del security
  FUNCTION idgp_val_pigm_iud(
  p_group_id IN IGS_PE_PERSID_GROUP_ALL.group_id%TYPE ,
  p_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- idgp_val_pigm_iud
  	-- Validate that the current user has permission to insert/update/delete
  	-- IGS_PE_PRSID_GRP_MEM records for the IGS_PE_PERSID_GROUP specified by the
  	-- group_id. The application owner has full permissions. The IGS_PE_PERSID_GROUP
  	-- creator identified by IGS_PE_PERSID_GROUP.creator_person_id also has full
  	-- permissions. Any other users must have a record in the
  	-- IGS_PE_PRSID_GRP_SEC table with the insert, update and delete
  	-- permissions specified.
  DECLARE
  	cst_person_id_group	CONSTANT
  						user_synonyms.synonym_name%TYPE := 'IGS_PE_PERSID_GROUP';
  	cst_insert		CONSTANT	VARCHAR2(10) := 'INSERT';
  	cst_update		CONSTANT	VARCHAR2(10) := 'UPDATE';
  	cst_delete		CONSTANT	VARCHAR2(10) := 'DELETE';
  	v_dummy			IGS_PE_PERSID_GROUP_ALL.creator_person_id%TYPE;
  	v_user			VARCHAR2(30);
  	v_insert_ind		IGS_PE_PRSID_GRP_SEC.insert_ind%TYPE;
  	v_update_ind		IGS_PE_PRSID_GRP_SEC.update_ind%TYPE;
  	v_delete_ind		IGS_PE_PRSID_GRP_SEC.delete_ind%TYPE;

--skpandey, Bug#4937960: Changed c_pig cursor definition to optimize query
	CURSOR c_pig(cp_group_id IGS_PE_PERSID_GROUP_ALL.group_id%TYPE) IS
		SELECT pig.creator_person_id
		FROM IGS_PE_PERSID_GROUP_ALL pig, igs_pe_hz_parties pe
		WHERE pig.group_id  = cp_group_id
		AND pig.creator_person_id = pe.party_id
		AND pe.oracle_username = fnd_global.user_name;

--skpandey, Bug#4937960: Changed c_pigs cursor definition to optimize query
  	CURSOR c_pigs(cp_group_id IGS_PE_PRSID_GRP_SEC.group_id%TYPE) IS
		SELECT pigs.insert_ind,
		 pigs.update_ind,
		 pigs.delete_ind
		FROM IGS_PE_PRSID_GRP_SEC pigs,
			IGS_PE_HZ_PARTIES pe
		WHERE pigs.group_id = cp_group_id
		AND pigs.person_id = pe.party_id
		AND pe.oracle_username = fnd_global.user_name;

  BEGIN
  	-- 1.
  	IF (p_group_id IS NULL) THEN
  		 p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- 2. Check if the user is the application owner.

  	-- 3. Check if the current user is the group creator.
  	-- The group_creator has full insert/update/delete priviledges.
  	OPEN c_pig(p_group_id);
  	FETCH c_pig INTO v_dummy;
  	IF (c_pig%FOUND) THEN
  		CLOSE c_pig;
  		 p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_pig;
  	-- 4. Get the permissions of the current user.
  	OPEN c_pigs(p_group_id);
  	FETCH c_pigs INTO	v_insert_ind,
  				v_update_ind,
  				v_delete_ind;
  	IF (c_pigs%NOTFOUND) THEN
  		CLOSE c_pigs;
  		 p_message_name := 'IGS_PE_NO_PRIV_INS_UPD_DEL';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pigs;
  	IF (p_transaction_type = cst_insert AND
  			v_insert_ind = 'N') THEN
  		 p_message_name:= 'IGS_PE_NO_PRIV_INS';
  		RETURN FALSE;
  	END IF;
  	IF (p_transaction_type = cst_update AND
  			v_update_ind = 'N') THEN
  		 p_message_name:= 'IGS_PE_NO_PRIV_UPD';
  		RETURN FALSE;
  	END IF;
  	IF (p_transaction_type = cst_delete AND
  			v_delete_ind = 'N') THEN
  		p_message_name:= 'IGS_PE_NO_PRIV_DEL';
  		RETURN FALSE;
  	END IF;
  	 p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_pig%ISOPEN) THEN
  			CLOSE c_pig;
  		END IF;
  		IF (c_pigs%ISOPEN) THEN
  			CLOSE c_pigs;
  		END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  	IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
  END idgp_val_pigm_iud;

  FUNCTION merged_ind(p_person_id NUMBER) RETURN VARCHAR2 IS
  ------------------------------------------------------------------------------------------
  --Created by  : sarakshi
  --Date created:27-sep-2001
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
 ----------------------------------------------------------------------------------------------

  CURSOR cur_pers_obsolete IS
  SELECT 'X'
  FROM    IGS_PE_ALT_PERS_ID pa,IGS_PE_PERSON_ID_TYP pt
  WHERE   pa.PE_PERSON_ID=p_person_id
  AND     pa.person_id_type=pt.person_id_type
  AND     pt.s_person_id_type='MERGE-INTO';
  l_cur_pers_obsolete VARCHAR2(1);

  BEGIN
    OPEN cur_pers_obsolete;
    FETCH cur_pers_obsolete INTO l_cur_pers_obsolete;
    IF cur_pers_obsolete%FOUND THEN
      CLOSE cur_pers_obsolete;
      RETURN 'Y';
    ELSE
      CLOSE cur_pers_obsolete;
      RETURN 'N';
    END IF;
  END merged_ind;

END IGS_PE_VAL_PIGM;

/
