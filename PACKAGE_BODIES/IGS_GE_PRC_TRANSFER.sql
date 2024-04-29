--------------------------------------------------------
--  DDL for Package Body IGS_GE_PRC_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_PRC_TRANSFER" AS
/* $Header: IGSGE07B.pls 115.5 2002/11/29 00:32:33 nsidana ship $ */
/* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
*/
	l_rowid  varchar2(25);
  --
  -- To get the alternate  person ids for the data transfer mechanism.
  FUNCTION GENP_GET_ALT_PE_ID(
  p_person_id IN NUMBER ,
  p_person_id_type IN VARCHAR2 )
  RETURN VARCHAR2 AS
  	v_alt_person_id		VARCHAR2(20);
  	CURSOR c_get_alt_pe_id IS
  		SELECT	api_person_id
  		FROM	IGS_PE_ALT_PERS_ID
  		WHERE	person_id_type = p_person_id_type AND
  			pe_person_id = p_person_id;
  BEGIN
  	OPEN c_get_alt_pe_id;
  	FETCH c_get_alt_pe_id INTO v_alt_person_id;
  	IF c_get_alt_pe_id%NOTFOUND THEN
  		CLOSE c_get_alt_pe_id;
  		RETURN NULL;
  	ELSE
  		CLOSE c_get_alt_pe_id;
  		RETURN v_alt_person_id;
  	END IF;
  END genp_get_alt_pe_id;
  --
  -- To get the person statistics location description for the data transf.
  FUNCTION GENP_GET_PS_LOCATION(
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_location_type IN VARCHAR2 )
  RETURN VARCHAR2 AS
  	v_location_country		IGS_PE_STATISTICS.term_location_country%TYPE;
  	v_location_postcode		IGS_PE_STATISTICS.term_location_postcode%TYPE;
  	CURSOR c_get_term_location_data IS
  		SELECT	term_location_country, term_location_postcode
  		FROM	IGS_PE_STATISTICS
  		WHERE	person_id = p_person_id AND
  			start_dt = p_start_dt;
  	CURSOR c_get_home_location_data IS
  		SELECT	home_location_country, home_location_postcode
  		FROM	IGS_PE_STATISTICS
  		WHERE	person_id = p_person_id AND
  			start_dt = p_start_dt;
  BEGIN
  	IF p_location_type = cst_term_location_type THEN
  		OPEN c_get_term_location_data;
  		FETCH c_get_term_location_data  INTO v_location_country, v_location_postcode;
  		CLOSE c_get_term_location_data;
  		IF v_location_country IS NOT NULL THEN
  			RETURN v_location_country;
  		ELSE
  			IF v_location_postcode IS NOT NULL THEN
  				RETURN v_location_postcode;
  			END IF;
  		END IF;
  		RETURN NULL;
  	END IF;
  	IF p_location_type = cst_home_location_type THEN
  		OPEN c_get_home_location_data;
  		FETCH c_get_home_location_data  INTO v_location_country, v_location_postcode;
  		CLOSE c_get_home_location_data;
  		IF v_location_country IS NOT NULL THEN
  			RETURN v_location_country;
  		ELSE
  			IF v_location_postcode IS NOT NULL THEN
  				RETURN v_location_postcode;
  			END IF;
  		END IF;
  		RETURN NULL;
  	END IF;
  END genp_get_ps_location;
  --
  -- To insert data transfer IGS_PE_STD_TODO entries
  PROCEDURE GENP_INS_TRNSFR_TODO(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_todo_dt IN DATE )
  AS
  	e_resource_busy		EXCEPTION;
  	PRAGMA	EXCEPTION_INIT(e_resource_busy, -54);
  	gv_other_details		VARCHAR2(255);
	l_val number;
  BEGIN
  DECLARE
  	v_st_sequence_number		IGS_PE_STD_TODO.sequence_number%TYPE;
  	v_insert_not_req_flag		BOOLEAN DEFAULT FALSE;
  	CURSOR c_chk_todo_dt_exists  (
  		cp_person_id		IGS_PE_STD_TODO.person_id%TYPE,
  		cp_s_student_todo_type  IGS_PE_STD_TODO.s_student_todo_type%TYPE ) IS
  		SELECT	sequence_number
  		FROM	IGS_PE_STD_TODO
  		WHERE	person_id = cp_person_id			AND
  			s_student_todo_type = cp_s_student_todo_type	AND
  			logical_delete_dt IS NULL;
  	CURSOR c_get_todo_rec_for_update (
  		cp_person_id		IGS_PE_STD_TODO.person_id%TYPE,
  		cp_s_student_todo_type  IGS_PE_STD_TODO.s_student_todo_type%TYPE,
  		cp_sequence_number	NUMBER ) IS
  		SELECT	IGS_PE_STD_TODO.* , ROWID
  		FROM	IGS_PE_STD_TODO
  		WHERE	person_id = cp_person_id			AND
  			s_student_todo_type = cp_s_student_todo_type	AND
  			sequence_number = cp_sequence_number
  		FOR UPDATE OF todo_dt
  		NOWAIT;
  	v_existing_st_record		C_GET_TODO_REC_FOR_UPDATE%ROWTYPE;
  BEGIN
  	--- Check for previous insertion during transaction as multiple records
  	--- for a given person/todo_type aren't necessary.  If one is found and it
  	--- isn't logically deleted, then update the todo_dt to postpone processing
  	--- (10 minutes is added).
  	OPEN c_chk_todo_dt_exists(p_person_id, p_s_student_todo_type);
  	FETCH c_chk_todo_dt_exists INTO v_st_sequence_number;
  	LOOP
  		EXIT WHEN c_chk_todo_dt_exists%NOTFOUND;
  		-- The following block selects the record for updating.  If a lock is present,
  		-- then the record isn't updated and processing continues.
  		BEGIN
  			OPEN c_get_todo_rec_for_update( p_person_id,
  							p_s_student_todo_type,
  							v_st_sequence_number );
  			FETCH c_get_todo_rec_for_update INTO v_existing_st_record;
  			LOOP
  				EXIT WHEN c_get_todo_rec_for_update%NOTFOUND;
  				v_insert_not_req_flag := TRUE;
				SELECT IGS_PE_STD_TODO_SEQ_NUM_S.NEXTVAL INTO L_VAL
				FROM DUAL ;
				IGS_PE_STD_TODO_PKG.UPDATE_ROW(
						x_rowid => v_existing_st_record.ROWID ,
						X_PERSON_ID  =>  v_existing_st_record.PERSON_ID,
						X_S_STUDENT_TODO_TYPE =>  v_existing_st_record.S_STUDENT_TODO_TYPE,
						X_SEQUENCE_NUMBER => L_VAL,
						X_TODO_DT =>  SYSDATE + 1/144 ,
						X_LOGICAL_DELETE_DT => v_existing_st_record.LOGICAL_DELETE_DT,
						X_MODE=> 'R'
						);
  				FETCH c_get_todo_rec_for_update INTO v_existing_st_record;
  			END LOOP;
  			CLOSE c_get_todo_rec_for_update;
  		EXCEPTION
  			WHEN e_resource_busy THEN
  				NULL;
  			WHEN OTHERS THEN
  				RAISE;
  		END;
  		FETCH c_chk_todo_dt_exists INTO v_st_sequence_number;
  	END LOOP;
  	CLOSE c_chk_todo_dt_exists;
  	--- If an update was performed or a previous record exists then exit
  	--  the procedure.
  	IF v_insert_not_req_flag THEN
  		RETURN;
  	END IF;
  	--- Insert a record into the IGS_PE_STD_TODO table using the parameters.
	SELECT IGS_PE_STD_TODO_SEQ_NUM_S.nextval INTO L_VAL
	FROM DUAL ;
	IGS_PE_STD_TODO_PKG.INSERT_ROW (
		X_ROWID => L_ROWID,
  		x_person_id  =>p_person_id,
  		x_s_student_todo_type  =>p_s_student_todo_type,
  		x_sequence_number => L_VAL ,
  		x_todo_dt  => p_todo_dt,
		x_logical_delete_dt => NULL,
		x_mode => 'R'
 );

  END;
  EXCEPTION
  WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception ;
  END genp_ins_trnsfr_todo;
  --

  -- Process PE rowids in a PL/SQL TABLE for the current commit.
  FUNCTION genp_prc_pe_rowids (
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name IN OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_index		BINARY_INTEGER;
  	v_other_detail	VARCHAR2(255);
  	r_pe		IGS_PE_PERSON%ROWTYPE;
  	v_todo_dt	DATE;

  CURSOR  per_cur (lcrowid VARCHAR2) IS
	SELECT	* FROM IGS_PE_PERSON
        WHERE rowid = lcrowid;

  BEGIN
  	-- Process saved rows.
  	FOR  v_index IN 1..gv_table_index - 1
  	LOOP

     begin
      OPEN per_cur (gt_rowid_table(v_index));
      FETCH per_cur INTO r_pe;
      IF per_cur%NOTFOUND THEN
	  RAISE no_data_found ;
      ELSE
  		-- Allow for a 10 minute interval
  		v_todo_dt := SYSDATE + 1/144;
  		-- Insert person into IGS_PE_STD_TODO table
  		IGS_GE_PRC_TRANSFER.genp_ins_trnsfr_todo(r_pe.person_id,
  						'PERS_TRANS',
  						v_todo_dt);


      END IF;
      CLOSE Per_Cur;
      EXCEPTION
	    WHEN no_data_found THEN
 		CLOSE per_cur;
	    WHEN others THEN
              IF per_cur%ISOPEN THEN
            	  CLOSE per_cur;
              END IF;
              Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
              IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception ;

	END;

  	END LOOP;
  	RETURN TRUE;
  END genp_prc_pe_rowids;
END IGS_GE_PRC_TRANSFER;

/
