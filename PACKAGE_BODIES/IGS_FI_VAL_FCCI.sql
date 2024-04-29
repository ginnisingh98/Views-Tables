--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FCCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FCCI" AS
/* $Header: IGSFI25B.pls 120.1 2005/07/28 07:38:00 appldev ship $ */
/*----------------------------------------------------------------------------
||  Created By :
||  Created On :
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
||  shtatiko        04-FEB-2004  Enh# 3167098, Removed validation of Retro Date Alias from FINP_VAL_FCCI_DATES.
||  vvutukur        23-Jul-2002  Bug#2425767.Modified FUNCTION finp_upd_fcci_status to remove references to
||                               payment_hierarchy_rank.
----------------------------------------------------------------------------*/
  --
  -- Validate FCCI can be made ACTIVE.
  FUNCTION finp_val_fcci_active(
  p_fee_cat_ci_status IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_fcci_active
  	-- Validates that IGS_FI_F_CAT_CA_INST has a system calendar category of
  	-- 'FEE' and that the calendar instance is active when setting the
  	-- IGS_FI_F_CAT_CA_INST status to active.
  DECLARE
  	cst_active			CONSTANT VARCHAR2(6) := 'ACTIVE';
  	cst_fee				CONSTANT VARCHAR2(3) := 'FEE';
  	v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_s_cal_status			IGS_CA_STAT.s_cal_status%TYPE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_fss (
  			cp_fee_cat_ci_status		IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_STR_STAT		fss
  		WHERE	fss.fee_structure_status	= cp_fee_cat_ci_status AND
  			fss.s_fee_structure_status	= cst_active;
  	CURSOR c_cict (
  			cp_cal_type 			IGS_CA_INST.cal_type%TYPE,
  			cp_sequence_number		IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	cat.s_cal_cat,
  			cs.s_cal_status
  		FROM	IGS_CA_INST			ci,
  			IGS_CA_STAT			cs,
  			IGS_CA_TYPE			cat
  		WHERE	ci.cal_type			= cp_cal_type AND
  			ci.sequence_number		= cp_sequence_number AND
  			ci.cal_type			= cat.cal_type AND
  			ci.cal_status			= cs.cal_status;
  BEGIN
  	p_message_name := NULL;
  	-- Check parameters
  	IF(p_fee_cat_ci_status IS NULL OR
  			p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check system value of status.
  	-- If not 'ACTIVE', no further processing is required.
  	OPEN	c_fss(
  			p_fee_cat_ci_status);
  	FETCH	c_fss INTO v_dummy;
  	IF(c_fss%NOTFOUND) THEN
  		CLOSE c_fss;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_fss;
  	-- Check the calendar system category
  	OPEN	c_cict(
  			p_fee_cal_type,
  			p_fee_ci_sequence_number);
  	FETCH	c_cict INTO 	v_s_cal_cat,
  				v_s_cal_status;
  	CLOSE	c_cict;
  	IF(v_s_cal_cat <> cst_fee) THEN
  		p_message_name := 'IGS_FI_CAL_MUSTBE_CAT_AS_FEE';
  		RETURN FALSE;
  	END IF;
  	IF(v_s_cal_status <> cst_active) THEN
  		p_message_name := 'IGS_FI_CALINST_ACTIVE_FEECAT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_fcci_active;
  --
  -- Update the status of related FCFL records.
  FUNCTION finp_upd_fcci_status(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat_ci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pmarada         28-jul-2005  Enh 3392095, Added waiver_calc_flag column to the IGS_FI_F_CAT_FEE_LBL_Pkg.Update_Row
  ||  vvutukur        23-Jul-2002  Bug#2425767.Removed references to payment_hierarchy_rank(from the call
  ||                               to IGS_FI_F_CAT_FEE_LBL_Pkg.Update_Row).
  ----------------------------------------------------------------------------*/
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	e_resource_busy		EXCEPTION;
  	PRAGMA	EXCEPTION_INIT(e_resource_busy, -54);
  	v_s_fee_structure_status	IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
  	CURSOR c_fss IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss
  		WHERE	fss.fee_structure_status = p_fee_cat_ci_status;
  	CURSOR c_fcfl IS
 		SELECT	fcfl.*, fcfl.rowid  -- kdande -> rowid was added to make a call to Update_Row TBH.
  		FROM	IGS_FI_F_CAT_FEE_LBL	fcfl
  		WHERE	fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number AND
    			fcfl.fee_cat =p_fee_cat AND
  			fcfl.fee_liability_status in
  				(select fss.fee_structure_status
  				 from   IGS_FI_FEE_STR_STAT fss
  				 where  fss.fee_structure_status = fcfl.fee_liability_status
  				 and    fss.s_fee_structure_status = 'ACTIVE')
  		FOR UPDATE OF fcfl.fee_liability_status NOWAIT;
   	fcfl_rec  c_fcfl%ROWTYPE; -- kdande -> Added while converting DMLs.

  BEGIN
  	-- When the IGS_FI_F_CAT_CA_INST.fee_cat_ci_status is changed
  	-- to 'INACTIVE' update the IGS_FI_F_CAT_FEE_LBL.fee_liability_status
  	-- in related records to 'INACTIVE'.
  	p_message_name := NULL;
  	-- 1. Check if the fee_cat_ci_status relates to a system
  	-- status in IGS_FI_FEE_STR_STAT of 'INACTIVE'.
  	OPEN c_fss;
  	FETCH c_fss INTO v_s_fee_structure_status;
  	CLOSE c_fss;
  	IF (v_s_fee_structure_status <> 'INACTIVE') THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. Update any related IGS_FI_F_CAT_FEE_LBL records.
  	OPEN c_fcfl;
  	LOOP
   	FETCH c_fcfl INTO fcfl_rec; -- kdande -> Added fcfl_rec for use in Update_Row DML.
  	IF (c_fcfl%NOTFOUND) THEN
  		CLOSE c_fcfl;
  		RETURN TRUE;
  	END IF;

        /* Call server side TBH package procedure */
        IGS_FI_F_CAT_FEE_LBL_Pkg.Update_Row (
          x_rowid => fcfl_rec.rowid,
          x_fee_cat => fcfl_rec.fee_cat,
          x_fee_ci_sequence_number => fcfl_rec.fee_ci_sequence_number,
          x_fee_type => fcfl_rec.fee_type,
          x_fee_cal_type => fcfl_rec.fee_cal_type,
          x_fee_liability_status => p_fee_cat_ci_status,
          x_start_dt_alias => fcfl_rec.start_dt_alias,
          x_start_dai_sequence_number => fcfl_rec.start_dai_sequence_number,
          x_s_chg_method_type => fcfl_rec.s_chg_method_type,
          x_rul_sequence_number => fcfl_rec.rul_sequence_number,
          x_waiver_calc_flag => fcfl_rec.waiver_calc_flag
        );

  	-- If record is locked exception will be handled
  	END LOOP;
  	-- 4. Update Successful
  	RETURN TRUE;
  EXCEPTION
  	WHEN e_resource_busy THEN
  		p_message_name := 'IGS_FI_FEECATFEELIAB_LOCKED';
  		RETURN FALSE;
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
 		 Fnd_Message.Set_Token('NAME','IGS_FI_VAL_FCCI.finp_upd_fcci_status');
 		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END finp_upd_fcci_status;
  --
  -- Validate the IGS_FI_F_CAT_CA_INST status
  FUNCTION finp_val_fcci_status(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_new_fcci_status IN VARCHAR2 ,
  p_old_fcci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN
  DECLARE
  	cst_active	CONSTANT	IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE := 'ACTIVE';
  	cst_planned	CONSTANT
  				IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE := 'PLANNED';
  	cst_inactive	CONSTANT
  			IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE := 'INACTIVE';
  	v_new_system_status		IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
  	v_old_system_status		IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
  	v_fee_cat			IGS_FI_F_CAT_FEE_LBL.fee_cat%TYPE;
  	CURSOR c_fss (
  		cp_fcci_status		IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE) IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss
  		WHERE	fss.FEE_STRUCTURE_STATUS = cp_fcci_status;
  	CURSOR c_fcfl IS
  		SELECT	fcfl.fee_cat
  		FROM	IGS_FI_F_CAT_FEE_LBL	fcfl
  		WHERE	fcfl.fee_cat = p_fee_cat AND
  			fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number;
  	CURSOR c_fcfl_fss IS
  		SELECT	fcfl.fee_cat
  		FROM	IGS_FI_F_CAT_FEE_LBL		fcfl,
  			IGS_FI_FEE_STR_STAT	fss
  		WHERE	fcfl.fee_cat = p_fee_cat AND
  			fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			fcfl.fee_liability_status = fss.fee_structure_status AND
  			fss.s_fee_structure_status = cst_active;
  BEGIN
  	-- Validate the IGS_FI_F_CAT_CA_INST.fee_cat_ci_status. The checks are:
  	-- Fee_cat_ci_status can only be set back to a system status of
  	-- 'PLANNED' from 'ACTIVE' if it has no associate
  	--  IGS_FI_F_CAT_FEE_LBL records.
  	-- Fee_cat_ci_status can only be set to a system status of 'INACTIVE' from
  	-- 'ACTIVE' if it has no 'ACTIVE' associated IGS_FI_F_CAT_FEE_LBL records.
  	-- 1. If the status has been changed get the system status:
  	IF (p_new_fcci_status <> p_old_fcci_status) THEN
  		OPEN c_fss(p_new_fcci_status);
  		FETCH c_fss INTO v_new_system_status;
  		CLOSE c_fss;
  		OPEN c_fss(p_old_fcci_status);
  		FETCH c_fss INTO v_old_system_status;
  		CLOSE c_fss;
  	END IF;
  	-- 2. If the new system status is planned check that there is no related
  	-- fee_cat_fee_aliability records
  	IF (v_new_system_status <> v_old_system_status) THEN
  		IF (v_new_system_status = cst_planned) THEN
  			OPEN c_fcfl;
  			FETCH c_fcfl INTO v_fee_cat;
  			IF (c_fcfl%FOUND) THEN
  				CLOSE c_fcfl;
  				p_message_name := 'IGS_FI_FEECAT_CAL_PLANNED';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_fcfl;
  		END IF;
  		-- 3. If the new system status is planned check that there is no
  		-- ACTIVE related IGS_FI_F_CAT_FEE_LBL records
  		IF (v_new_system_status = cst_inactive) THEN
  			OPEN c_fcfl_fss;
  			FETCH c_fcfl_fss INTO v_fee_cat;
  			IF (c_fcfl_fss%FOUND) THEN
  				CLOSE c_fcfl_fss;
  				p_message_name := 'IGS_FI_FEECAT_CALINST_PLANNED';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_fcfl_fss;
  		END IF;
  	END IF;
  	-- 4. validation successful
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END finp_val_fcci_status;
  --
  -- Ensure cal instance dates are consistent.
  FUNCTION finp_val_fcci_dates(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_start_dt_alias IN VARCHAR2 ,
  p_start_dai_sequence_number IN NUMBER ,
  p_end_dt_alias IN VARCHAR2 ,
  p_end_dai_sequence_number IN NUMBER ,
  p_retro_dt_alias IN VARCHAR2 ,
  p_retro_dai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_fcci_dates
  DECLARE
  	CURSOR c_dai(
  			cp_fee_cal_type		VARCHAR2,
  			cp_fee_ci_sequence_number	NUMBER,
  			cp_dt_alias			VARCHAR2,
  			cp_dai_sequence_number	NUMBER)  IS
  		SELECT	alias_val
  		FROM	IGS_CA_DA_INST_V
  		WHERE	cal_type = cp_fee_cal_type AND
  			ci_sequence_number = cp_fee_ci_sequence_number AND
  			dt_alias = cp_dt_alias AND
  			sequence_number = cp_dai_sequence_number;
  	v_dai_start_rec			c_dai%ROWTYPE;
  	v_dai_end_rec			c_dai%ROWTYPE;
  	v_dai_retro_rec			c_dai%ROWTYPE;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	-- Check parameters, at least 2 pairs of date aliases must be specified,
  	-- not including the start and retro combination
  	IF (p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_end_dt_alias IS NULL OR
  			p_end_dai_sequence_number IS NULL OR
  			((p_start_dt_alias IS NULL OR
  			p_start_dai_sequence_number IS NULL) AND
  			(p_retro_dt_alias IS NULL OR
  			p_retro_dai_sequence_number IS NULL))) THEN
  		RETURN TRUE;
  	END IF;
  	-- Get start date alias value if parameter values are not null
  	IF (p_start_dt_alias IS NOT NULL AND
  			p_start_dai_sequence_number IS NOT NULL) THEN
  		OPEN c_dai(
  				p_fee_cal_type,
  				p_fee_ci_sequence_number,
  				p_start_dt_alias,
  				p_start_dai_sequence_number);
  		FETCH c_dai INTO v_dai_start_rec;
  		CLOSE c_dai;
  	END IF;
  	-- Get end date alias value
  	OPEN c_dai(
  			p_fee_cal_type,
  			p_fee_ci_sequence_number,
  			p_end_dt_alias,
  			p_end_dai_sequence_number);
  	FETCH c_dai INTO v_dai_end_rec;
  	CLOSE c_dai;
  	-- Get retro date alias value if parameter values are not null
  	IF (p_retro_dt_alias IS NOT NULL AND
  			p_retro_dai_sequence_number IS NOT NULL) THEN
  		OPEN c_dai(
  				p_fee_cal_type,
  				p_fee_ci_sequence_number,
  				p_retro_dt_alias,
  				p_retro_dai_sequence_number);
  		FETCH c_dai INTO v_dai_retro_rec;
  		CLOSE c_dai;
  	END IF;
  	-- Check the date values
  	IF (p_start_dt_alias IS NOT NULL AND
  			p_start_dai_sequence_number IS NOT NULL) THEN
  		IF (v_dai_start_rec.alias_val > v_dai_end_rec.alias_val) THEN
  			p_message_name := 'IGS_FI_STDT_LE_END_DT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_fcci_dates;
  --
  -- Validate the fee structure status closed indicator
  FUNCTION finp_val_fss_closed(
  p_fee_structure_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_other_detail		VARCHAR2(255);
  	v_closed_ind		CHAR;
  	CURSOR c_fee_structure_status IS
  		SELECT	closed_ind
  		FROM	IGS_FI_FEE_STR_STAT
  		WHERE	fee_structure_status = p_fee_structure_status;
  BEGIN
  	-- Check if the IGS_FI_FEE_STR_STAT is closed
  	p_message_name := NULL;
  	OPEN c_fee_structure_status;
  	FETCH c_fee_structure_status INTO v_closed_ind;
  	IF (c_fee_structure_status%NOTFOUND) THEN
  		CLOSE c_fee_structure_status;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_FI_FEESTRUCT_STATUSCLOSED';
  		CLOSE c_fee_structure_status;
  		RETURN FALSE;
  	END IF;
  	-- record is not closed
  	CLOSE c_fee_structure_status;
  	RETURN TRUE;
  END;
  END finp_val_fss_closed;
  --
  -- Ensure calendar instance is FEE and ACTIVE.
  FUNCTION finp_val_ci_fee(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_s_cal_status			IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR c_ci_cat_cs IS
  		SELECT	cat.s_cal_cat,
  			cs.s_cal_status
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_TYPE	cat,
  			IGS_CA_STAT	cs
  		WHERE	ci.cal_type = p_fee_cal_type AND
  			ci.sequence_number = p_fee_ci_sequence_number AND
  			ci.cal_type = cat.CAL_TYPE AND
  			ci.cal_status  = cs.CAL_STATUS;
  BEGIN
  	-- Validate the calendar instance to check it is calendar system category
  	-- FEE and has a system status of ACTIVE or PLANNED.
  	OPEN	c_ci_cat_cs;
  	FETCH	c_ci_cat_cs	INTO	v_s_cal_cat,
  					v_s_cal_status;
  	CLOSE	c_ci_cat_cs;
  	-- Check the calendar system category.
  	IF (v_s_cal_cat <> 'FEE') THEN
  		p_message_name := 'IGS_FI_CAL_MUSTBE_CAT_AS_FEE';
  		RETURN FALSE;
  	END IF;
  	-- Check the calendar system status.
  	IF (v_s_cal_status not in ('ACTIVE','PLANNED')) THEN
  		p_message_name := 'IGS_CA_CAL_INST_MUST_BE_ACTIV';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END finp_val_ci_fee;
END IGS_FI_VAL_FCCI;

/
