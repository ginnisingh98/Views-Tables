--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FTCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FTCI" AS
/* $Header: IGSFI34B.pls 120.1 2005/07/28 07:41:33 appldev ship $ */
/*
Who          When                     What
pmarada      28-jul-2005              Enh 3392095, Added waiver_calc_flag cloumn to the IGS_FI_F_CAT_FEE_LBL_Pkg.Update_Row
shtatiko     04-FEB-2004              Enh# 3167098, Removed validation of Retro Date Alias from finp_val_ftci_dates.
vvutukur     29-Jul-2002              Bug#2425767. Removed payment_hierarchy_rank column references as this
                                      is obsoleted(from call to IGS_FI_F_CAT_FEE_LBL_Pkg.Update_Row in
				      FUNCTION finp_upd_fcfl_status.Removed function finp_val_ftci_rank
				      as this function validates payment_hierarchy_rank,an obsoleted column.)
vchappid     25-Apr-2002              Bug# 2329407, Removed the parameters account_cd, fin_cal_type
                                      and fin_ci_sequence_number from the function call finp_val_ftci_rqrd

vchappid     04-Feb-2002            As per Enh#2187247, procedure finp_val_ftci_rqrd is modofied to include new validations
*/

 /* Bug 1966961
    Who schodava
    When 5 Sept,2001
    What Obsolete the account code link with Financial Calendar
 */
 /* Bug 1956374
    Who msrinivi
    When 25 Aug,2001
    What Duplicate code removal finp_val_ft_closed
 */

 /*  Who          When                     What
     vivuyyur     10-sep-2001		   Bug No :1966961
                                           PROCEDURE finp_val_ftci_ac is changed  */
  -- Validate the IGS_FI_ACC has the correct calendar relations.
  FUNCTION finp_val_ftci_ac(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_ftci_account
  	-- Validate the IGS_FI_F_TYP_CA_INST calendar instance
  	-- is a subordinate of the IGS_FI_ACC finace calendar instance.
  DECLARE
  	v_sub_cal_type	IGS_CA_INST_REL.sub_cal_type%TYPE;
  	CURSOR c_cir IS
  		SELECT	sub_cal_type
  		FROM	IGS_CA_INST_REL
  		WHERE	sub_cal_type		= p_fee_cal_type		AND
  			sub_ci_sequence_number	= p_fee_ci_sequence_number ;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check parameters
  	IF (
  		p_fee_cal_type IS NULL			OR
  		p_fee_ci_sequence_number IS NULL)		THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the IGS_FI_F_TYP_CA_INST fee calendar
  	-- is a subordinate of the IGS_FI_ACC finace calendar.
  	OPEN c_cir;
  	FETCH c_cir INTO v_sub_cal_type;
  	IF (c_cir%FOUND) THEN
  		CLOSE c_cir;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cir;
  	-- Return error
  	p_message_name := 'IGS_FI_FEECAL_TYPE_SUBORD';
  	RETURN FALSE;
  END;
  END finp_val_ftci_ac;
  --
  -- Ensure Fee calendar has relationship to Teaching Calendar
  FUNCTION finp_chk_tchng_prds(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_sub_cal_type		IGS_CA_INST_REL.sub_cal_type%TYPE;
  	cst_cal_cat 	CONSTANT	VARCHAR2(8):= 'TEACHING';
  	CURSOR c_cir IS
  		SELECT	cir.sub_cal_type
  		FROM	IGS_CA_INST_REL	cir
  		WHERE	cir.sub_cal_type = p_fee_cal_type AND
  			cir.sub_ci_sequence_number = p_fee_ci_sequence_number AND
  			cir.sup_cal_type IN (	SELECT	ct.CAL_TYPE
  						FROM	IGS_CA_TYPE	ct
  						WHERE	ct.CAL_TYPE = cir.sup_cal_type AND
  							ct.S_CAL_CAT = cst_cal_cat AND
  							ct.closed_ind = 'N');
  BEGIN
  	--  Validate IGS_FI_F_CAT_FEE_LBL calender instance has
  	--subordinate relationships to 'TEACHING PERIOD' calender
  	--instances.  IGS_GE_NOTE: IGS_FI_F_CAT_FEE_LBL calender instances
  	--must be of category 'FEE'.
  	--1.	Check parameters
  	IF (p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	--2.	Check if superior relationships exist with calender
  	--instances which have a system calender category of 'TEACHING'.
  	OPEN c_cir;
  	FETCH c_cir INTO v_sub_cal_type;
  	IF (c_cir%FOUND) THEN
  		CLOSE c_cir;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cir;
  	--3.	Return Error
  	p_message_name := 'IGS_FI_REQ_RELATION_DONOT_EXS';
  	RETURN FALSE;
  END;
  END finp_chk_tchng_prds;
  --
  -- Update the status of related FCFL records.
  FUNCTION finp_upd_fcfl_status(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type_ci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	e_resource_busy		EXCEPTION;
  	PRAGMA	EXCEPTION_INIT(e_resource_busy, -54);
  	v_s_fee_structure_status	IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
  	v_fee_liability_status		IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE;
  	CURSOR c_fss IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss
  		WHERE	fss.fee_structure_status = p_fee_type_ci_status;
  	CURSOR c_fcfl IS
 		SELECT	fcfl.*, fcfl.rowid  -- kdande -> rowid was added to make a call to Update_Row TBH.
  		FROM	IGS_FI_F_CAT_FEE_LBL	fcfl
  		WHERE	fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			fcfl.fee_type =p_fee_type
  		FOR UPDATE OF fcfl.fee_liability_status NOWAIT;
   	fcfl_rec  c_fcfl%ROWTYPE; -- kdande -> Added while converting DMLs.
  BEGIN
  	-- When the fee_cal_instance.fee_type_ci_status is changed
  	-- to 'INACTIVE' update the IGS_FI_F_CAT_FEE_LBL.fee_liability_status
  	-- in related records to 'INACTIVE'.
  	p_message_name := NULL;
  	-- 1. Check if the fee_type_ci_status relates to a system
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
        		x_fee_liability_status => p_fee_type_ci_status,
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
		APP_EXCEPTION.RAISE_EXCEPTION;
  END;
  END finp_upd_fcfl_status;
  --
  -- Ensure calendar instance is FEE and ACTIVE.
  -- Duplicate Code Removal, msrinivi Removed proc finp_val_ci_fee
  -- Validate the fee structure status closed indicator
  -- Duplicate Code Removal, msrinivi Removed func  finp_val_fss_closed
  --
  -- Validate the IGS_FI_F_TYP_CA_INST s_chg_method_type.
  FUNCTION finp_val_ftci_c_mthd(
  p_fee_type IN VARCHAR ,
  p_chg_method IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	cst_hecs	CONSTANT	IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'HECS';
  	cst_eftsu	CONSTANT	VARCHAR2(10) := 'EFTSU';
  	v_s_fee_type			IGS_FI_FEE_TYPE.s_fee_type%TYPE;
  	CURSOR c_ft IS
  		SELECT	ft.s_fee_type
  		FROM	IGS_FI_FEE_TYPE	ft
  		WHERE	ft.fee_type = p_fee_type;
  BEGIN
  	-- Validate if IGS_FI_F_TYP_CA_INST.s_chg_method_type
  	-- is correct for the IGS_FI_FEE_TYPE.s_fee_type
  	p_message_name := NULL;
  	-- 1. Check parameters
  	IF (p_fee_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. The p_chg_method must be 'EFTSU' if the
  	-- s_fee_type is 'HECS' or 'TUITION'.
  	OPEN c_ft;
  	FETCH c_ft INTO v_s_fee_type;
  	CLOSE c_ft;
  	IF (v_s_fee_type = cst_hecs  AND p_chg_method <> cst_eftsu) THEN
  		p_message_name := 'IGS_FI_CHGMTH_SETTO_EFTSU';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_ftci_c_mthd;
  --
  -- Validate the IGS_FI_F_TYP_CA_INST date aliases
  FUNCTION finp_val_ftci_dates(
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
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_start_alias_val	IGS_CA_DA_INST_V.alias_val%TYPE;
  	v_end_alias_val		IGS_CA_DA_INST_V.alias_val%TYPE;
  	v_retro_alias_val	IGS_CA_DA_INST_V.alias_val%TYPE;
  	CURSOR c_daiv (
  		cp_dt_alias		IGS_CA_DA_INST_V.DT_ALIAS%TYPE,
  		cp_dai_sequence_number	IGS_CA_DA_INST_V.sequence_number%TYPE) IS
  		SELECT	daiv.alias_val
  		FROM	IGS_CA_DA_INST_V	daiv
  		WHERE	daiv.CAL_TYPE = p_fee_cal_type AND
  			daiv.ci_sequence_number = p_fee_ci_sequence_number AND
  			daiv.DT_ALIAS = cp_dt_alias AND
  			daiv.sequence_number = cp_dai_sequence_number;
  BEGIN
  	-- Validate IGS_FI_F_TYP_CA_INST dates.
  	-- Validate that start_dt is less then or equal to end_dt and
  	-- that end_dt is less than or equal to retro_dt.
  	p_message_name := NULL;
  	-- 1. Check parameters (function must be called with at least
  	-- 2 pairs of date alias specified - start and end or end and
  	-- retro or all three (start and retro is not valid):
  	IF (p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_end_dt_alias IS NULL OR
  			p_end_dai_sequence_number IS NULL OR
  			((p_start_dt_alias IS NULL OR p_start_dai_sequence_number IS NULL) AND
  			(p_retro_dt_alias IS NULL OR p_retro_dai_sequence_number IS NULL))) THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. Obtain the actual value for the aliases (Steps 3 thru 5)
  	-- 3. Get start date alias value (if parameter value not null)
  	IF (p_start_dt_alias IS NOT NULL AND
  			p_start_dai_sequence_number IS NOT NULL) THEN
  		OPEN c_daiv(
  				p_start_dt_alias,
  				p_start_dai_sequence_number);
  		FETCH c_daiv INTO v_start_alias_val;
  		CLOSE c_daiv;
  	END IF;
  	-- 4. Get end date alias value. (this one will always be specified)
  	OPEN c_daiv(
  			p_end_dt_alias,
  			p_end_dai_sequence_number);
  	FETCH c_daiv INTO v_end_alias_val;
  	CLOSE c_daiv;
  	-- 5. Get retro date alias value (if parameter value not null)
  	IF (p_retro_dt_alias IS NOT NULL AND
  			p_retro_dai_sequence_number IS NOT NULL) THEN
  		OPEN c_daiv(
  				p_retro_dt_alias,
  				p_retro_dai_sequence_number);
  		FETCH c_daiv INTO v_retro_alias_val;
  		CLOSE c_daiv;
  	END IF;
  	-- 6. Check the dates values:
  	IF (p_start_dt_alias IS NOT NULL) THEN
  		IF (v_start_alias_val > v_end_alias_val) THEN
  			p_message_name := 'IGS_FI_STDT_LE_END_DT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_ftci_dates;
  --
  -- Validate the IGS_FI_F_TYP_CA_INST required data
  FUNCTION finp_val_ftci_rqrd(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_old_chg_method IN VARCHAR2 ,
  p_old_rule_sequence IN NUMBER ,
  p_chg_method IN VARCHAR2 ,
  p_rule_sequence IN NUMBER ,
  p_fee_type_ci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*
   WHO          WHEN                     WHAT
   vchappid     25-Apr-2002              Bug# 2329407, Removed the parameters account_cd, fin_cal_type
                                         and fin_ci_sequence_number from the function call finp_val_ftci_rqrd
   vchappid     04-Feb-2002              As per Enh#2187247, procedure finp_val_ftci_rqrd is modofied to include new validations
  */

  gv_other_detail			VARCHAR2(255);
  BEGIN	-- finp_val_ftci_rqrd
  	-- When the system status is ACTIVE validate if
  	-- IGS_FI_F_TYP_CA_INST.s_chg_method_type and
  	-- IGS_FI_F_TYP_CA_INST.rul_sequence_number are required or not, depending
  	-- on related values.
  	-- Ensure that the FINANCE calendar_instance is
  	-- ACTIVE.
  DECLARE
  	cst_hecs	CONSTANT	IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'HECS';
  	cst_institutn	CONSTANT	IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE := 'INSTITUTN';
  	cst_active	CONSTANT	IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE := 'ACTIVE';
  	v_s_fee_type			IGS_FI_FEE_TYPE.s_fee_type%TYPE;
  	v_s_fee_trigger_cat		IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
  	v_fee_type			IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE;
  	v_s_fee_structure_status		IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE;
  	v_acc_closed_ind	IGS_FI_ACC.closed_ind%TYPE;
  	v_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	v_s_cal_cat		IGS_CA_TYPE.S_CAL_CAT%TYPE;
  	CURSOR c_fss (
  		cp_fee_type_ci_status		IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE) IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss
  		WHERE	fss.fee_structure_status = cp_fee_type_ci_status;
  	CURSOR c_ft IS
  		SELECT	ft.s_fee_type,
  			ft.s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE	ft
  		WHERE	ft.fee_type = p_fee_type;
  	CURSOR c_fcfl IS
  		SELECT	fcfl.fee_type
  		FROM	IGS_FI_F_CAT_FEE_LBL	fcfl
  		WHERE	fcfl.fee_type = p_fee_type AND
  			fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number;
  	CURSOR c_fee_ci IS
  		SELECT	cs.s_cal_status,
  			ct.S_CAL_CAT
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_TYPE	ct,
  			IGS_CA_STAT	cs
  		WHERE	ci.CAL_TYPE	= p_fee_cal_type	AND
  			ci.sequence_number = p_fee_ci_sequence_number AND
  			ci.CAL_TYPE		= ct.CAL_TYPE		AND
  			ci.CAL_STATUS		= cs.CAL_STATUS;

        -- Start of Modifications Enh# 2187247
        -- Parameter to the function igs_fi_gen_001.finp_get_lfci_reln,
        -- suggesting the input parameters are of FEE Calendar Category
        -- OUT NOCOPY parameters are of LOAD Calendar Category
        cst_fee CONSTANT igs_ca_type.s_cal_cat%TYPE :='FEE';

        -- Variables to storing Load Calendar Instance
        l_c_load_cal_type    igs_ca_inst_all.cal_type%TYPE;
        l_n_load_seq_num     igs_ca_inst_all.sequence_number%TYPE;

        l_c_message_name     fnd_new_messages.message_name%TYPE;

        -- Check the system status of the load calendar instance, should be ACTIVE before a FTCI is created
        CURSOR cur_load_cal_status (cp_load_cal_type igs_ca_inst_all.cal_type%TYPE ,
                                    cp_load_cal_seq_num igs_ca_inst_all.sequence_number%TYPE)
        IS
        SELECT s.s_cal_status
        FROM   igs_ca_inst i,
               igs_ca_stat s
        WHERE  s.cal_status = i.cal_status
        AND    i.cal_type = cp_load_cal_type
        AND    i.sequence_number = cp_load_cal_seq_num;

        l_cur_load_cal_status cur_load_cal_status%ROWTYPE;
        -- End of Modifications Enh# 2187247

  BEGIN
  	-- Validate if IGS_FI_F_TYP_CA_INST.s_chg_method_type and
  	-- IGS_FI_F_TYP_CA_INST.rul_sequence_number are required
  	-- or not, depending on related values.
  	p_message_name := NULL;
  	-- 1. Check parameters
  	IF (p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- 2.1 Check if the system status is ACTIVE before testing for required data
  	OPEN c_fss(p_fee_type_ci_status);
  	FETCH c_fss INTO v_s_fee_structure_status;
  	CLOSE c_fss;
  	IF (v_s_fee_structure_status <> cst_active) THEN
  		RETURN TRUE;
  	END IF;
  	-- 2.2 If p_chg_method is not null pr p_rul_sequence is not null, then
  	-- validate the IGS_FI_FEE_TYPE to see if it is permissible for these values to be
  	-- specified.  Required when IGS_FI_FEE_TYPE.s_fee_trigger_cat = 'INSTITUTN' or
  	-- s_fee_type = 'HECS'.
  	OPEN c_ft;
  	FETCH c_ft INTO	v_s_fee_type,
  			v_s_fee_trigger_cat;
  	CLOSE c_ft;
  	IF (v_s_fee_type = cst_hecs AND
  			p_chg_method IS NULL) THEN
  		p_message_name := 'IGS_FI_CHGMTH_SPECIFY_FEETYPE';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_fee_type = cst_hecs AND
  			p_rule_sequence IS NULL) THEN
  		p_message_name := 'IGS_FI_RULSEQ_FEETYPE_HECS';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_fee_trigger_cat = cst_institutn AND
  			p_chg_method IS NULL) THEN
  		p_message_name := 'IGS_FI_CHGMTH_FEETYPE_INSTITU';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_fee_trigger_cat = cst_institutn AND
  			p_rule_sequence IS NULL) THEN
  		p_message_name := 'IGS_FI_RULSEQ_FEETYPE_INSTITU';
  		RETURN FALSE;
  	END IF;
  	-- 2.3	Check if the account_cd, fin_cal_type and fin_ci_sequence_number
  	-- have been set.
  	-- If they are set check that the account_cd is linked to an active Finance
  	-- calendar instance.
	-- This part f the code is removed as a part of Enh # 1966961 : Obsolete Items CCR

  	-- 2.4	Check if the  fee_cal_type and fee_ci_sequence_number
  	-- are linked to an active Fee calendar instance.
  	OPEN c_fee_ci;
  	FETCH c_fee_ci INTO
  			v_s_cal_status,
  			v_s_cal_cat;
  	IF (c_fee_ci%NOTFOUND) THEN
  		CLOSE c_fee_ci;
		Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
        RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_fee_ci;
  	IF v_s_cal_status <> cst_active THEN
  		p_message_name := 'IGS_FI_CALINST_FEETYPE_CALINS';
  		RETURN FALSE;
  	END IF;
  	IF v_s_cal_cat <> 'FEE' THEN
  		p_message_name := 'IGS_FI_CALINST_LINKED_FEETYPE';
  		RETURN FALSE;
  	END IF;

        -- Start of Modifications Enh# 2187247
        -- Get the Related Load Calendar Instance for the Fee Calendar Instance
        IF (igs_fi_gen_001.finp_get_lfci_reln( p_fee_cal_type,
                                               p_fee_ci_sequence_number,
		         		       cst_fee,
			         	       l_c_load_cal_type,
				               l_n_load_seq_num,
				               l_c_message_name)) THEN
          -- For the Load Calendar Instance identified, check the System Load Calendar Status
          -- Status should be Active
          OPEN cur_load_cal_status (l_c_load_cal_type, l_n_load_seq_num);
          FETCH cur_load_cal_status INTO l_cur_load_cal_status;
          IF cur_load_cal_status%NOTFOUND THEN
            CLOSE cur_load_cal_status;
            FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
            RAISE NO_DATA_FOUND;
          ELSE
            CLOSE cur_load_cal_status;
            IF (l_cur_load_cal_status.s_cal_status <> cst_active) THEN
              p_message_name := 'IGS_FI_LOAD_CAL_NOT_ACTIVE';
              RETURN FALSE;
            END IF;
          END IF;
        ELSE
          p_message_name := l_c_message_name;
          RETURN FALSE;
        END IF;
        -- End of Modifications Enh# 2187247

        -- 3. If there are related IGS_FI_F_CAT_FEE_LBL records the s_chg_method_type
  	-- or  rul_sequence_number cannot be added or removed (can however be changed)
  	IF (p_chg_method IS NULL AND p_old_chg_method IS NOT NULL) OR
  			(p_chg_method IS NOT NULL AND p_old_chg_method IS NULL) OR
  			(p_rule_sequence IS NULL AND p_old_rule_sequence IS NOT NULL) OR
  			(p_rule_sequence IS NOT NULL AND p_old_rule_sequence IS NULL) THEN
  		OPEN c_fcfl;
  		FETCH c_fcfl INTO v_fee_type;
  		IF (c_fcfl%FOUND) THEN
  			CLOSE c_fcfl;
  			p_message_name := 'IGS_FI_CHGMTH_OR_RULSEQ';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_fcfl;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_ftci_rqrd;
  --
  -- Validate the IGS_FI_F_TYP_CA_INST status
  FUNCTION finp_val_ftci_status(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_new_ftci_status IN VARCHAR2 ,
  p_old_ftci_status IN VARCHAR2 ,
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
  	v_fee_type			IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE;
  	CURSOR c_fss (
  		cp_ftci_status		IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE) IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss
  		WHERE	fss.fee_structure_status = cp_ftci_status;
  	CURSOR c_fcfl IS
  		SELECT	fcfl.fee_type
  		FROM	IGS_FI_F_CAT_FEE_LBL	fcfl
  		WHERE	fcfl.fee_type = p_fee_type AND
  			fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number;
  	CURSOR c_fcfl_fss IS
  		SELECT	fcfl.fee_type
  		FROM	IGS_FI_F_CAT_FEE_LBL		fcfl,
  			IGS_FI_FEE_STR_STAT	fss
  		WHERE	fcfl.fee_type = p_fee_type AND
  			fcfl.fee_cal_type = p_fee_cal_type AND
  			fcfl.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			fcfl.fee_liability_status = fss.fee_structure_status AND
  			fss.s_fee_structure_status = cst_active;
  BEGIN
  	-- Validate the IGS_FI_F_TYP_CA_INST.fee_type_ci_status. The checks are:
  	-- Fee_type_ci_status can only be set back to a system status of
  	-- 'PLANNED' from 'ACTIVE' if it has no associated
  	--  IGS_FI_F_CAT_FEE_LBL records.
  	-- Fee_type_ci_status can only be set to a system status of 'INACTIVE' from
  	-- 'ACTIVE' if it has no 'ACTIVE' associated IGS_FI_F_CAT_FEE_LBL records.
  	-- 1. If the status has been changed get the system status:
  	IF (p_new_ftci_status <> p_old_ftci_status) THEN
  		OPEN c_fss(p_new_ftci_status);
  		FETCH c_fss INTO v_new_system_status;
  		CLOSE c_fss;
  		OPEN c_fss(p_old_ftci_status);
  		FETCH c_fss INTO v_old_system_status;
  		CLOSE c_fss;
  	END IF;
  	-- 2. If the new system status is planned check that there is no related
  	-- fee_cat_fee_aliability records
  	IF (v_new_system_status <> v_old_system_status) THEN
  		IF (v_new_system_status = cst_planned) THEN
  			OPEN c_fcfl;
  			FETCH c_fcfl INTO v_fee_type;
  			IF (c_fcfl%FOUND) THEN
  				CLOSE c_fcfl;
  				p_message_name := 'IGS_FI_FEETYPECAL_NOTBE_PLANN';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_fcfl;
  		END IF;
  		-- 3. If the new system status is inactive check that there is no
  		-- ACTIVE related IGS_FI_F_CAT_FEE_LBL records
  		IF (v_new_system_status = cst_inactive) THEN
  			OPEN c_fcfl_fss;
  			FETCH c_fcfl_fss INTO v_fee_type;
  			IF (c_fcfl_fss%FOUND) THEN
  				CLOSE c_fcfl_fss;
  				p_message_name := 'IGS_FI_FEETYPECAL_NOTBE_INACT';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_fcfl_fss;
  		END IF;
  	END IF;
  	-- 4. validation successful
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END finp_val_ftci_status;
  --
  -- Validate the IGS_FI_FEE_TYPE in the fee_type_account is not closed.
  -- Bug 1956374 Removed duplicate code finp_val_ft_closed
  -- Validate PAYMENT HIERARCHY RAN
  --As part of bugfix#2425767, removed function finp_val_ftci_rank,as this validates obsoleted column,
  --payment_hierarchy_rank.
END IGS_FI_VAL_FTCI;

/
