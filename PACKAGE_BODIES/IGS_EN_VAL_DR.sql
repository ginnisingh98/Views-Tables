--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_DR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_DR" AS
/* $Header: IGSEN33B.pls 120.1 2006/02/15 23:08:12 ctyagi noship $ */
  --
  -- Validate system  default indicator anddiscont reason type.
  FUNCTION enrp_val_dr_sysdflt(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_sys_dflt_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_dr_sysdflt
  	-- This module validates that the IGS_EN_DCNT_REASONCD.sys_dflt_ind can
  	-- only be set to
  	-- 'Y' when IGS_EN_DCNT_REASONCD.s_discontinuation_reason_type is not set.
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_sys_dflt_ind = 'Y' THEN
  		IF p_s_discontin_reason_type IS NULL THEN
  			p_message_name := 'IGS_EN_SYSDFLT_IND_SET';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DR.enrp_val_dr_sysdflt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_dr_sysdflt;
  --
  -- Validate sys discontinuation reason code closed indicator
  FUNCTION enrp_val_sdrt_closed(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_sdrt_closed
  	-- This module validates that s_discontinuation_reason_type is not closed.
  DECLARE
  	v_closed_ind		IGS_LOOKUPS_VIEW.closed_ind%TYPE;
  	CURSOR	c_sdrt IS
  		SELECT 	closed_ind
  		FROM	IGS_LOOKUPS_VIEW sdrt
  		WHERE	lookup_type = 'DISCONTINUATION_REASON_TYPE' and
			lookup_code = p_s_discontin_reason_type;
  BEGIN
  	p_message_name := null;
  	OPEN c_sdrt;
  	FETCH c_sdrt INTO v_closed_ind;
  	IF (c_sdrt%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_sdrt;
  			p_message_name := 'IGS_EN_SYS_DISCONT_RESTYPE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sdrt;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sdrt%ISOPEN) THEN
  			CLOSE c_sdrt;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DR.enrp_val_sdrt_closed');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_sdrt_closed;
  --
  -- Validate system  default indicator (at least one).
  FUNCTION enrp_val_dr_sysdflt2(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN 	-- enrp_val_dr_sysdflt2
  	-- This module validates that the system default indicator has to be set
  	-- for at least one IGS_EN_DCNT_REASONCD mapped to a
  	-- s_discontinuation_reason_type. This routine will be called when all
  	-- records are posted to the database.
  DECLARE
  	v_dr_count		NUMBER;
  	CURSOR c_dr IS
  		SELECT	COUNT(*)
  		FROM	IGS_EN_DCNT_REASONCD		dr
  		WHERE	dr.s_discontinuation_reason_type	= p_s_discontin_reason_type AND
  			dr.closed_ind = 'N' AND
  			dr.sys_dflt_ind = 'Y';
  BEGIN
  	p_message_name := null;
  	IF p_s_discontin_reason_type IS NOT NULL THEN
  		OPEN c_dr;
  		FETCH c_dr INTO v_dr_count;
  		CLOSE c_dr;
  		IF v_dr_count = 0 THEN
  			p_message_name := 'IGS_EN_ONE_DISCONT_DEFNED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_dr%ISOPEN) THEN
  			CLOSE c_dr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DR.enrp_val_dr_sysdflt2');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_dr_sysdflt2;
  --
  -- Validate system  default indicator (>one).
  FUNCTION enrp_val_dr_sysdflt1(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN 	-- enrp_val_dr_sysdflt1
  	-- This module validates that the system default indicator is not set
  	-- for more than one IGS_EN_DCNT_REASONCD maped to a
  	-- s_discontinuation_reason_type. This routine will be called when all
  	-- records are posted to the database.
  DECLARE
  	v_dr_count		NUMBER;
  	CURSOR c_dr IS
  		SELECT 	COUNT(*)
  		FROM	IGS_EN_DCNT_REASONCD		dr
  		WHERE	dr.s_discontinuation_reason_type	= p_s_discontin_reason_type AND
  			dr.closed_ind				= 'N' AND
  			dr.sys_dflt_ind				= 'Y';
  BEGIN
  	p_message_name := null;
  	IF p_s_discontin_reason_type IS NOT NULL THEN
  		OPEN c_dr;
  		FETCH c_dr INTO v_dr_count;
  		CLOSE c_dr;
  		IF v_dr_count > 1 THEN
  			p_message_name := 'IGS_EN_ONE_DISCONT_REASONCD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_dr%ISOPEN) THEN
  			CLOSE c_dr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DR.enrp_val_dr_sysdflt1');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_dr_sysdflt1;

  --
  -- Validate the discontinuation reason code default.
  --
  FUNCTION enrp_val_dr_dflt(
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  --
  --  This function has been changed to fix Bug# 2053999
  --
      CURSOR cur_c1 IS
      SELECT count(*) cnt
      FROM igs_en_dcnt_reasoncd_v
      WHERE dcnt_unit_ind = 'Y'
      AND dflt_ind = 'Y'
      AND closed_ind = 'N';
      --modified cursor for perf bug 3712579
      CURSOR cur_c2 IS
      SELECT count(*) cnt
      FROM igs_en_dcnt_reasoncd
      WHERE  dcnt_program_ind = 'Y'
      AND dflt_ind = 'Y'
      AND closed_ind = 'N';

      l_unit_cnt   NUMBER(8) := 0;
      l_prgm_cnt   NUMBER(8) := 0;
      rec_cur_c1   cur_c1%ROWTYPE;
      rec_cur_c2   cur_c2%ROWTYPE;

  BEGIN

      OPEN cur_c1;
      FETCH cur_c1 INTO rec_cur_c1;
        l_unit_cnt := rec_cur_c1.cnt;
      CLOSE cur_c1;

      IF l_unit_cnt = 0 THEN
        --
        --  If no records found then return message saying that no
        --  Dafaulted value for unit.
        --
        p_message_name := 'IGS_EN_DFLT_DISC_RECD_UNIT';
        RETURN FALSE;
      ELSIF l_unit_cnt > 1 THEN
        --
        --  If more than one records found then return message saying
        --  that there are more than one Dafaulted value for unit.
        --
        p_message_name := 'IGS_EN_MORE_REASON_CD_UNIT';
        RETURN FALSE;
      ELSE
        --
        -- If only one record found than do not return any message,
        -- check defaulted value for Program.
        --
        p_message_name := null;
      END IF;

      OPEN cur_c2;
      FETCH cur_c2 INTO rec_cur_c2;
        l_prgm_cnt := rec_cur_c2.cnt;
      CLOSE cur_c2;

      IF l_prgm_cnt = 0 THEN
        --
        --  If no records found then return message saying that no
        --  Dafaulted value for Program.
        --
        p_message_name := 'IGS_EN_DFLT_DISC_RECD_PRGM';
        RETURN FALSE;
      ELSIF l_prgm_cnt > 1 THEN
        --
        --  If more than one records found then return message saying
        --  that there are more than one Dafaulted value for Program.
        --
        p_message_name := 'IGS_EN_MORE_REASON_CD_PRGM';
        RETURN FALSE;
      ELSE
        --
        -- If only one record found than do not set any message, and return TRUE
        -- which indicates successful validation.
        --
        p_message_name := null;
        RETURN TRUE;
      END IF;


  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DR.enrp_val_dr_dflt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_dr_dflt;
END IGS_EN_VAL_DR;

/
