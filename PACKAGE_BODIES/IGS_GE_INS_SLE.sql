--------------------------------------------------------
--  DDL for Package Body IGS_GE_INS_SLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_INS_SLE" AS
/* $Header: IGSGE05B.pls 115.4 2002/11/29 00:32:03 nsidana ship $ */

l_rowid varchar2(25);
  --
  -- Insert into IGS_GE_S_LOG_ENTRY from a pl/sql table.
  PROCEDURE GENP_INS_SLE(
  p_creation_dt IN OUT NOCOPY DATE )
  AS
  	gv_other_detail		VARCHAR2(255);
	l_rowid 			VARCHAR2(25);

  BEGIN	-- genp_ins_sle
  	-- This module will read IGS_GE_S_LOG_ENTRY records from a pl/sql table and
  	-- insert them into the IGS_GE_S_LOG_ENTRY table. If it is possible that the
  	-- pl/sql table may be populated with differing IGS_GE_S_LOG_ENTRY types within
  	-- the same transaction, this module will check if the creation date
  	-- parameter is set and will use this. If the creation date parameter
  	-- is null, then it will create an IGS_GE_S_LOG record and the returned
  	-- creation date will be used. If no parent is found, due to differing
  	-- s_log_type, then the procedure will create the IGS_GE_S_LOG record using the
  	-- same creation date that has been used previously.
  DECLARE
  	e_no_parent_rec_exception	EXCEPTION;
  	PRAGMA EXCEPTION_INIT(e_no_parent_rec_exception, -2291);
  BEGIN
  	-- Loop though the pl/sql table
  	FOR i IN 1..gv_cntr LOOP
  		r_log_entry := t_log_entry(i);
  		BEGIN
  			-- check that the creation date has been determined
  			IF (p_creation_dt IS NULL) THEN
  				-- This will only be called once as p_creation_dt
  				-- will be set after the call.
  				IGS_GE_GEN_003.GENP_INS_LOG(
  						r_log_entry.s_log_type,
  						r_log_entry.sl_key,
  						p_creation_dt);
  			END IF;
  			IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
  					r_log_entry.s_log_type,
  					p_creation_dt,
  					r_log_entry.sle_key,
  					r_log_entry.sle_message_name,
  					r_log_entry.text);
  		EXCEPTION
  			WHEN e_no_parent_rec_exception THEN
  				-- This exception can arrise when there is a change in s_log_type
  				-- that has been used during the population of the pl/sql table.
  				-- Insert the IGS_GE_S_LOG record using the same creation date.
				IGS_GE_S_LOG_PKG.INSERT_ROW(
					x_rowid => l_rowid ,
  					x_s_log_type => r_log_entry.s_log_type,
  					x_creation_dt => p_creation_dt,
  					x_key =>r_log_entry.sl_key ,
					x_mode => 'R' );
  				IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
  						r_log_entry.s_log_type,
  						p_creation_dt,
  						r_log_entry.sle_key,
  						r_log_entry.sle_message_name,
  						r_log_entry.text);
  			WHEN OTHERS THEN
  				RAISE;
  		END;
  	END LOOP;
  EXCEPTION
  	WHEN NO_DATA_FOUND THEN
  		-- Reset the counter to 1
  		genp_set_log_cntr;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception ;
  END genp_ins_sle;
  --
  -- To insert entry into PL/SQL table to allow log entries after rollback
  PROCEDURE GENP_SET_LOG_ENTRY(
  p_s_log_type IN VARCHAR2 ,
  p_sl_key IN VARCHAR2 ,
  p_sle_key IN VARCHAR2 ,
  p_sle_message_name IN VARCHAR2 ,
  p_text IN VARCHAR2 )
  AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- genp_set_log_entry
  	-- This module will store IGS_GE_S_LOG_ENTRY records in a pl/sql table
  	-- until they are required to be inserted into the IGS_GE_S_LOG_ENTRY table.
  DECLARE
  BEGIN
  	r_log_entry.s_log_type		:= p_s_log_type;
  	r_log_entry.sl_key		:= p_sl_key;
  	r_log_entry.sle_key		:= p_sle_key;
  	r_log_entry.sle_message_name	:= p_sle_message_name;
  	r_log_entry.text		:= p_text;
  	t_log_entry(gv_cntr) := r_log_entry;
  	gv_cntr := gv_cntr + 1;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception ;
  END genp_set_log_entry;
  --
  -- Initialise pl/sql table when creating IGS_GE_S_LOG_ENTRY records.
  PROCEDURE GENP_SET_LOG_CNTR
  AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- genp_set_log_cntr
  	-- This procedure is called to initialise the gv_cntr to 1
  	-- and to clear the pl/sql table. This is needed when the
  	-- package is used more than once within the same session.
  DECLARE
  BEGIN
  	gv_cntr := 1;
  	t_log_entry := t_log_entry_blank;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception ;
  END genp_set_log_cntr;
END IGS_GE_INS_SLE;

/
