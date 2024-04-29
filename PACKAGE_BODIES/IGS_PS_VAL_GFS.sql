--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_GFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_GFS" AS
/* $Header: IGSPS49B.pls 115.3 2002/11/29 03:05:45 nsidana ship $ */
  --
  -- To validate the update of a government funding source record
  FUNCTION crsp_val_gfs_upd(
  p_govt_funding_source IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR	c_check_fs_rec IS
  		SELECT 'x'
  		FROM IGS_FI_FUND_SRC
  		WHERE	govt_funding_source	= p_govt_funding_source AND
  			closed_ind		= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_fs_rec;
  		FETCH c_check_fs_rec INTO v_check;
  		IF c_check_fs_rec%FOUND THEN
  			CLOSE c_check_fs_rec;
  			p_message_name := 'IGS_PS_CANCLS_GOVT_FUNDSRC';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_fs_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_GFS.CRSP_VAL_GFS_UPD');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_gfs_upd;
END IGS_PS_VAL_GFS;

/
