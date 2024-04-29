--------------------------------------------------------
--  DDL for Package Body IGS_FI_F_CAT_FEE_LBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_F_CAT_FEE_LBL_PKG" AS
/* $Header: IGSSI45B.pls 120.1 2005/07/28 07:04:52 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_F_CAT_FEE_LBL_ALL%RowType;
  new_references IGS_FI_F_CAT_FEE_LBL_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_fee_type IN VARCHAR2 ,
    x_fee_liability_status IN VARCHAR2 ,
    x_start_dt_alias IN VARCHAR2 ,
    x_start_dai_sequence_number IN NUMBER ,
    x_s_chg_method_type IN VARCHAR2 ,
    x_rul_sequence_number IN NUMBER ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER,
    x_waiver_calc_flag IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk            02-Sep-2002  Default values are removed from the signature of this procedure to overcome
  ||                               File.Pkg.22 gscc warning.As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and its reference in copying old_references value
  ||                               into new_references value.
  ----------------------------------------------------------------------------*/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_type := x_fee_type;
    new_references.fee_liability_status := x_fee_liability_status;
    new_references.start_dt_alias := x_start_dt_alias;
    new_references.start_dai_sequence_number := x_start_dai_sequence_number;
    new_references.s_chg_method_type := x_s_chg_method_type;
    new_references.rul_sequence_number := x_rul_sequence_number;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.org_id := x_org_id;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.waiver_calc_flag := x_waiver_calc_flag;
  END Set_Column_Values;

  -- Trigger description :-
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_F_CAT_FEE_LBL_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  shtatiko        10-FEB-2003     Enh# 2747325, Removed the code of handling p_deleting = 'TRUE' case as deletion of
                                  Fee Category Fee Liability records is not allowed.
  smvk            02-Sep-2002     Default values are removed from the signature of this procedure to overcome
                                  File.Pkg.22 gscc warning.As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  smvk            14-Mar-2002     Check for system fee type refund
                                  as its invalid for Fee Category Fee
				  Liability w.r.t Bug # 2144600
  SCHODAVA	  13-OCT-2001     Bug # 2021281
				  Added IF condition for
				  p_deleting
  (reverse chronological order - newest change first)
  ***************************************************************/

	-- Returns the system fee trigger category of a fee type
	CURSOR c_ft(cp_fee_type IN igs_fi_fee_type.fee_type%TYPE ) IS
	SELECT s_fee_trigger_cat
	FROM   igs_fi_fee_type
	WHERE  fee_type = cp_fee_type;

	-- checks if there are records in the IGS_FI_FEE_AS table
	-- for the input FTCI and a NULL fee Category.
	CURSOR c_ftci(cp_fee_type IN igs_fi_fee_as.fee_type%TYPE,
		      cp_fee_cal_type IN igs_fi_fee_as.fee_cal_type%TYPE,
		      cp_fee_ci_sequence_number IN igs_fi_fee_as.fee_ci_sequence_number%TYPE
		     ) IS
	SELECT 'x'
	FROM   igs_fi_fee_as
	WHERE  fee_type = cp_fee_type
	AND    fee_cal_type = cp_fee_cal_type
	AND    fee_ci_sequence_number = cp_fee_ci_sequence_number
	AND    fee_cat IS NULL;

	-- Returns the system fee type of a fee type w.r.t Bug # 2144600
	CURSOR c_sft(cp_fee_type IN igs_fi_fee_type.fee_type%TYPE) IS
	SELECT s_fee_type
	FROM  igs_fi_fee_type
	WHERE fee_type = cp_fee_type;

	v_message_name varchar2(30);
	l_s_fee_trigger_cat igs_fi_fee_type.s_fee_trigger_cat%TYPE;
	l_s_fee_type igs_fi_fee_type.s_fee_type%TYPE;   -- added for Bug # 2144600
	l_institution  CONSTANT VARCHAR2(30)  := 'INSTITUTN';
  BEGIN
	-- Validate system fee type associated with this fee type is not refund w.r.t. Bug # 2144600
        IF( p_inserting OR p_updating) THEN
                OPEN c_sft(new_references.fee_type);
                FETCH c_sft INTO l_s_fee_type;
                CLOSE c_sft;
                IF( l_s_fee_type = 'REFUND') THEN
                        Fnd_Message.Set_Name('IGS','IGS_FI_INVALID_REFUND_FCFL');
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
	END IF;
	-- Validate Fee Liability Status.
	IF (p_inserting OR (old_references.fee_liability_status) <>
			(new_references.fee_liability_status)) THEN
		IF IGS_FI_VAL_FCCI.finp_val_fss_closed (
					new_references.fee_liability_status,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		-- Validate status can be set to 'ACTIVE'
		IF IGS_FI_VAL_FCFL.finp_val_fcfl_active (
				new_references.fee_liability_status,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		IF IGS_FI_VAL_FCFL.finp_val_fcfl_status (
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.fee_cat,
				new_references.fee_type,
				new_references.fee_liability_status,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate Fee Liability Charge Method Type and Rule Sequence Number.
	IF p_inserting OR p_updating THEN
		IF IGS_FI_VAL_FCFL.finp_val_fcfl_rqrd (
					new_references.fee_cal_type,
					new_references.fee_ci_sequence_number,
					new_references.fee_type,
					new_references.s_chg_method_type,
					new_references.rul_sequence_number,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate fee category currency with details inherited from FTCI
	IF p_inserting THEN
		IF IGS_FI_VAL_FCFL.finp_val_fcfl_cur (
					new_references.fee_cal_type,
					new_references.fee_ci_sequence_number,
					new_references.fee_type,
					new_references.fee_cat,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

          -- Enh# 2747325, Removed the case for p_deleting as deletion is disabled as part of Locking Issues Build.
	  -- Bug # 2021281
	  -- added by schodava
	  -- If the system Fee trigger category is 'INSTITUTION' then,
	  -- Check whether the fee type calendar instance is present in the Fee Assessment table.
	  -- If it is, then restrict deletion of the Fee type from the IGS_FI_F_CAT_FEE_LBL_ALL table.
	  -- This is introduced to implement the foreign key IGS_FI_FEE_AS_PKG.GET_FK_IGS_FI_F_CAT_FEE_LBL
	  -- for a null fee_cat in the IGS_FI_FEE_AS table.

  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- AFTER UPDATE
  -- ON IGS_FI_F_CAT_FEE_LBL_ALL
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk            02-Sep-2002  Default values are removed from the signature of this procedure to overcome
  ||                               File.Pkg.22 gscc warning.As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameters new_references.payment_hierarchy_rank,
  ||                               new_references.payment_hierarchy_rank,from the call to
  ||                               IGS_FI_GEN_002.FINP_INS_FCFL_HIST.
  ----------------------------------------------------------------------------*/
  BEGIN
	-- create a history
	IGS_FI_GEN_002.FINP_INS_FCFL_HIST (old_references.fee_cat,
		old_references.fee_cal_type,
		old_references.fee_ci_sequence_number,
		old_references.fee_type,
		new_references.fee_liability_status,
		old_references.fee_liability_status,
		new_references.start_dt_alias,
		old_references.start_dt_alias,
		new_references.start_dai_sequence_number,
		old_references.start_dai_sequence_number,
		new_references.s_chg_method_type,
		old_references.s_chg_method_type,
		new_references.rul_sequence_number,
		old_references.rul_sequence_number,
		new_references.last_updated_by,
		old_references.last_updated_by,
		new_references.last_update_date,
		old_references.last_update_date);
  END AfterRowUpdate3;

 -- Following procedure commented as part of bug#2403209

  -- Trigger description :-
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_F_CAT_FEE_LBL_ALL

  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF Get_UK1_For_Validation (
         new_references.fee_cat,
         new_references.fee_cal_type,
         new_references.fee_ci_sequence_number,
         new_references.fee_type,
         new_references.s_chg_method_type
         ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2,
    column_value IN  VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        20-May-2002  removed upper check on fee_type,fee_cat,
  ||                               fee_liability_status(alias of fee_structure_status) columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'START_DAI_SEQUENCE_NUMBER') THEN
      new_references.start_dai_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'RUL_SEQUENCE_NUMBER') THEN
      new_references.rul_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'START_DT_ALIAS') THEN
      new_references.start_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'S_CHG_METHOD_TYPE') THEN
      new_references.s_chg_method_type := column_value;
    END IF;
    IF ((UPPER (column_name) = 'START_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.start_dai_sequence_number < 1) OR (new_references.start_dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RUL_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.rul_sequence_number < 1) OR (new_references.rul_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.fee_ci_sequence_number < 1) OR (new_references.fee_ci_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'START_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.start_dt_alias <> UPPER (new_references.start_dt_alias)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'S_CHG_METHOD_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_chg_method_type <> UPPER (new_references.s_chg_method_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.start_dt_alias = new_references.start_dt_alias) AND
         (old_references.start_dai_sequence_number = new_references.start_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.start_dt_alias IS NULL) OR
         (new_references.start_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.start_dt_alias,
        new_references.start_dai_sequence_number,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_CAT_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_liability_status = new_references.fee_liability_status)) OR
        ((new_references.fee_liability_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_STR_STAT_PKG.Get_PK_For_Validation (
        new_references.fee_liability_status
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_type,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
        new_references.rul_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;

  -- Removed FOR UPDATE NOWAIT clause from the cur_rowid to avoid locking problems.
  -- This has been done as part of Enh# 2747325, Locking Issues.
  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_PK_For_Validation;

  FUNCTION Get_UK1_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_s_chg_method_type IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      s_chg_method_type = x_s_chg_method_type
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_UK1_For_Validation;
  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    start_dt_alias = x_dt_alias
      AND      start_dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCFL_DAI_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_DA_INST;
  PROCEDURE GET_FK_IGS_FI_F_CAT_CA_INST (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCFL_FCCI_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_F_CAT_CA_INST;
  PROCEDURE GET_FK_IGS_FI_FEE_STR_STAT (
    x_fee_structure_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    fee_liability_status = x_fee_structure_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCFL_FSST_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_STR_STAT;

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    rul_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCFL_RUL_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_RU_RULE;
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_chg_method_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_FEE_LBL_ALL
      WHERE    s_chg_method_type = x_s_chg_method_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCFL_LKUP_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_liability_status IN VARCHAR2,
    x_start_dt_alias IN VARCHAR2,
    x_start_dai_sequence_number IN NUMBER,
    x_s_chg_method_type IN VARCHAR2,
    x_rul_sequence_number IN NUMBER,
    x_org_id IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_waiver_calc_flag  IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  shtatiko        10-FEB-2003     Enh# 2747325, Removed cases for p_action = 'DELETE' and
                                  p_action = 'VALIDATE_DELETE'
  vvutukur        19-Jul-2002     Bug#2425767.removed parameter x_payment_hierarchy_rank and its reference
                                  from the call to set_column_values.
  SCHODAVA	  13-OCT-2001     Bug # 2021281
				  Added the call to
				  BeforeRowInsertUpdateDelete1
				  for p_action = 'VALIDATE_DELETE'
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type,
      x_fee_liability_status,
      x_start_dt_alias,
      x_start_dai_sequence_number,
      x_s_chg_method_type,
      x_rul_sequence_number,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_waiver_calc_flag
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE, p_updating =>FALSE ,  p_deleting => FALSE );
      IF (Get_PK_For_Validation (
            x_fee_cat,
            x_fee_cal_type,
            x_fee_ci_sequence_number,
            x_fee_type
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating => TRUE ,  p_deleting => FALSE );
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            x_fee_cat,
            x_fee_cal_type,
            x_fee_ci_sequence_number,
            x_fee_type
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk            02-Sep-2002  Call to AfterRowUpdate3 is updated to pass all the parameter as per the Apps
  ||                               standard. As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed (earlier commented) calls to AfterStmtInsertUpdate4
  ||                               procedure if p_action='INSERT' or 'UPDATE' as this procedure itself is
  ||                               removed from this package body.Removed if conditions i)if p_action='INSERT'
  ||                               ii)p_action='DELETE' as no code exists in those conditions.
  ----------------------------------------------------------------------------*/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate3 (p_inserting  => FALSE, p_updating => TRUE, p_deleting =>FALSE );
    END IF;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2,
  X_WAIVER_CALC_FLAG IN VARCHAR2
  ) is
  /************************************************************************************
  vvutukur      19-Jul-2002     Bug#2425767.removed parameter x_payment_hierarchy_rank and from call to
                                before_dml and from insert statement.
  sbaliga 	13-feb-2002	Assigned igs_ge_gen_003.get_org_id  to x_org_id
  				in call to before_dml as part of SWCR006 build.
  *****************************************************************************/
    cursor C is select ROWID from IGS_FI_F_CAT_FEE_LBL_ALL
      where FEE_CAT = X_FEE_CAT
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and FEE_TYPE = X_FEE_TYPE
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
    X_REQUEST_ID:=FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID:=FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID:=FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1 ) then
      X_REQUEST_ID:=NULL;
      X_PROGRAM_ID:=NULL;
      X_PROGRAM_APPLICATION_ID:=NULL;
      X_PROGRAM_UPDATE_DATE:=NULL;
    else
      X_PROGRAM_UPDATE_DATE:=SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
 end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_liability_status=>X_FEE_LIABILITY_STATUS,
 x_fee_type=>X_FEE_TYPE,
 x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
 x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_org_id=>igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_waiver_calc_flag => X_WAIVER_CALC_FLAG
);
  insert into IGS_FI_F_CAT_FEE_LBL_ALL (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE,
    FEE_LIABILITY_STATUS,
    START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER,
    S_CHG_METHOD_TYPE,
    RUL_SEQUENCE_NUMBER,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    WAIVER_CALC_FLAG
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_LIABILITY_STATUS,
    NEW_REFERENCES.START_DT_ALIAS,
    NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_CHG_METHOD_TYPE,
    NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.WAIVER_CALC_FLAG
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML (
 p_action => 'INSERT',
 x_rowid => X_ROWID
);
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_WAIVER_CALC_FLAG IN VARCHAR2
) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and its reference from cursor c1 and from if condition.
  ----------------------------------------------------------------------------*/
  cursor c1 is select
      FEE_LIABILITY_STATUS,
      START_DT_ALIAS,
      START_DAI_SEQUENCE_NUMBER,
      S_CHG_METHOD_TYPE,
      RUL_SEQUENCE_NUMBER,
      WAIVER_CALC_FLAG
    from IGS_FI_F_CAT_FEE_LBL_ALL
    where ROWID=X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
  if ( (tlinfo.FEE_LIABILITY_STATUS = X_FEE_LIABILITY_STATUS)
      AND ((tlinfo.START_DT_ALIAS = X_START_DT_ALIAS)
           OR ((tlinfo.START_DT_ALIAS is null)
               AND (X_START_DT_ALIAS is null)))
      AND ((tlinfo.START_DAI_SEQUENCE_NUMBER = X_START_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.START_DAI_SEQUENCE_NUMBER is null)
               AND (X_START_DAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.S_CHG_METHOD_TYPE = X_S_CHG_METHOD_TYPE)
           OR ((tlinfo.S_CHG_METHOD_TYPE is null)
               AND (X_S_CHG_METHOD_TYPE is null)))
      AND ((tlinfo.RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER)
           OR ((tlinfo.RUL_SEQUENCE_NUMBER is null)
               AND (X_RUL_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.WAIVER_CALC_FLAG = X_WAIVER_CALC_FLAG)
           OR ((tlinfo.WAIVER_CALC_FLAG is null)
               AND (X_WAIVER_CALC_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2,
  X_WAIVER_CALC_FLAG IN VARCHAR2
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and from call to before_dml and from update statement.
  ----------------------------------------------------------------------------*/
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
    X_REQUEST_ID:=FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID:=FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID:=FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1 ) then
      X_REQUEST_ID:=OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID:=OLD_REFERENCES.PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID:=OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE:=OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE:=SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_liability_status=>X_FEE_LIABILITY_STATUS,
 x_fee_type=>X_FEE_TYPE,
 x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
 x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_waiver_calc_flag => X_WAIVER_CALC_FLAG
);
  update IGS_FI_F_CAT_FEE_LBL_ALL set
    FEE_LIABILITY_STATUS = NEW_REFERENCES.FEE_LIABILITY_STATUS,
    START_DT_ALIAS = NEW_REFERENCES.START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    S_CHG_METHOD_TYPE = NEW_REFERENCES.S_CHG_METHOD_TYPE,
    RUL_SEQUENCE_NUMBER = NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID=X_REQUEST_ID,
    PROGRAM_ID=X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE=X_PROGRAM_UPDATE_DATE,
    WAIVER_CALC_FLAG=X_WAIVER_CALC_FLAG
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'UPDATE',
 x_rowid => X_ROWID
);
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2,
  X_WAIVER_CALC_FLAG IN VARCHAR2
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and from calls to insert_row and update_row.
  ----------------------------------------------------------------------------*/
  cursor c1 is select rowid from IGS_FI_F_CAT_FEE_LBL_ALL
     where FEE_CAT = X_FEE_CAT
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and FEE_TYPE = X_FEE_TYPE
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_FEE_TYPE,
     X_FEE_CAL_TYPE,
     X_FEE_LIABILITY_STATUS,
     X_START_DT_ALIAS,
     X_START_DAI_SEQUENCE_NUMBER,
     X_S_CHG_METHOD_TYPE,
     X_RUL_SEQUENCE_NUMBER,
     X_ORG_ID,
     X_MODE,
     X_WAIVER_CALC_FLAG
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_TYPE,
   X_FEE_CAL_TYPE,
   X_FEE_LIABILITY_STATUS,
   X_START_DT_ALIAS,
   X_START_DAI_SEQUENCE_NUMBER,
   X_S_CHG_METHOD_TYPE,
   X_RUL_SEQUENCE_NUMBER,
   X_MODE,
   X_WAIVER_CALC_FLAG
   );
end ADD_ROW;

end IGS_FI_F_CAT_FEE_LBL_PKG;

/
