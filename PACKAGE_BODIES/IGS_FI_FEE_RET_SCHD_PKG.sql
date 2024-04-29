--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_RET_SCHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_RET_SCHD_PKG" AS
 /* $Header: IGSSI33B.pls 120.1 2006/05/26 10:55:26 sapanigr noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_RET_SCHD%RowType;
  new_references IGS_FI_FEE_RET_SCHD%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_schedule_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retention_percentage IN NUMBER DEFAULT NULL,
    x_retention_amount IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        24-Jul-2002  Bug#2425767.removed parameter x_deduction_amount and its reference in
  ||                               copying old_references value into new_references.value.
  ----------------------------------------------------------------------------*/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_RET_SCHD
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
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.sequence_number := x_sequence_number;
    new_references.fee_cat := x_fee_cat;
    new_references.fee_type := x_fee_type;
    new_references.schedule_number := x_schedule_number;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.retention_percentage := x_retention_percentage;
    new_references.retention_amount := x_retention_amount;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END Set_Column_Values;
  -- Trigger description :-
  -- "OSS_TST".trg_frtns_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_FI_FEE_RET_SCHD
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the fee relationship
	IF (p_inserting) THEN
		IF IGS_FI_VAL_FE.finp_val_sched_mbrs (
				new_references.s_relation_type,
				new_references.fee_cat,
				new_references.fee_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the Fee Type Fee Trigger Cat
	IF (p_inserting) THEN
		IF IGS_FI_VAL_FRTNS.finp_val_frtns_ft (
				new_references.fee_type,
				new_references.s_relation_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the retention amount and percentage
	IF (p_inserting OR
		nvl(old_references.retention_amount,0) <> nvl(new_references.retention_amount,0) OR
		nvl(old_references.retention_percentage,0) <> nvl(new_references.retention_percentage,0)) THEN
		IF IGS_FI_VAL_FRTNS.finp_val_frtns_amt (
				new_references.retention_amount,
				new_references.retention_percentage,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Check related fee cat fee liabilities do not clash with the local currency
	IF p_inserting THEN
		IF IGS_FI_VAL_FRTNS.finp_val_frtns_cur (
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.fee_type,
				new_references.s_relation_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_frtns_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_FI_FEE_RET_SCHD
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        24-Jul-2002  Bug#2425767.removed references to deduction_amount from call to
  ||                               IGS_FI_GEN_002.FINP_INS_FRTNS_HIST.
  ----------------------------------------------------------------------------*/
  BEGIN
	-- create a history
	IGS_FI_GEN_002.FINP_INS_FRTNS_HIST( old_references.fee_cal_type,
		old_references.fee_ci_sequence_number,
		old_references.s_relation_type,
		old_references.sequence_number,
		new_references.fee_type,
		old_references.fee_type,
		new_references.fee_cat,
		old_references.fee_cat,
		new_references.schedule_number,
		old_references.schedule_number,
		new_references.dt_alias,
		old_references.dt_alias,
		new_references.dai_sequence_number,
		old_references.dai_sequence_number,
		new_references.retention_percentage,
		old_references.retention_percentage,
		new_references.retention_amount,
		old_references.retention_amount,
		new_references.last_updated_by,
		old_references.last_updated_by,
		new_references.last_update_date,
		old_references.last_update_date);
  END AfterRowUpdate3;
  -- Trigger description :-
  -- "OSS_TST".trg_frtns_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_FEE_RET_SCHD
  PROCEDURE AfterStmtInsertUpdate4(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
  	-- Validate the dt alias.
  	IF p_inserting OR p_updating THEN
  		IF IGS_FI_VAL_FRTNS.finp_val_frtns_creat (
  		    	              new_references.fee_type,
  			              new_references.fee_cal_type,
  			              new_references.fee_ci_sequence_number,
  		    	              new_references.s_relation_type,
  			              v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdate4;
  PROCEDURE Check_Constraints (
   	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr        26-May-2006  Enh 5217319. Removed highest value criteria for item 'CHG_RATE'
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed reference to deduction_amount.
  ||  agairola        14-Jun-2002  Bug 2403209: Removed the validation for deduction amount
  ||  vvutukur        17-May-2002  removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF Column_Name is NULL THEN
       	NULL;
    ELSIF upper(Column_Name) = 'S_RELATION_TYPE' then
       	new_references.s_relation_type := Column_Value;
    ELSIF upper(Column_Name) = 'SCHEDULE_NUMBER' then
       	new_references.schedule_number := igs_ge_number.to_num(Column_Value);
    ELSIF upper(Column_Name) = 'SEQUENCE_NUMBER' then
       	new_references.sequence_number := igs_ge_number.to_num(Column_Value);
    ELSIF upper(Column_Name) = 'DAI_SEQUENCE_NUMBER' then
       	new_references.dai_sequence_number := igs_ge_number.to_num(Column_Value);
    ELSIF upper(Column_Name) = 'DT_ALIAS' then
       	new_references.dt_alias:= Column_Value;
    ELSIF upper(Column_Name) = 'FEE_CAL_TYPE' then
       	new_references.fee_cal_type := Column_Value;
    ELSIF upper(Column_Name) = 'RETENTION_AMOUNT' then
       	new_references.retention_amount := igs_ge_number.to_num(Column_Value);
    ELSIF upper(Column_Name) = 'RETENTION_PERCENTAGE' then
       	new_references.retention_percentage := igs_ge_number.to_num(Column_Value);
    ELSIF upper(Column_Name) = 'FEE_CI_SEQUENCE_NUMBER' then
       	new_references.fee_ci_sequence_number := igs_ge_number.to_num(Column_Value);
    END IF;


  IF upper(Column_Name) = 'FEE_CI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.fee_ci_sequence_number < 1 OR
		   new_references.fee_ci_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
  END IF;

    -- The following code checks for check constraints on the Columns.
  IF upper(Column_Name) = 'SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.sequence_number < 1 OR
		   new_references.sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
  END IF;

    -- The following code checks for check constraints on the Columns.
  IF upper(Column_Name) = 'DAI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.dai_sequence_number < 1 OR
		   new_references.dai_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
  END IF;
    -- The following code checks for check constraints on the Columns.
  IF upper(Column_Name) = 'SCHEDULE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.schedule_number < 1 OR
		   new_references.schedule_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
  END IF;
  IF upper(Column_Name) = 'S_RELATION_TYPE' OR 	column_name is NULL THEN
       		IF new_references.S_RELATION_TYPE <> 'FTCI' AND
  			   new_references.S_RELATION_TYPE <> 'FCCI' AND
  			   new_references.S_RELATION_TYPE <> 'FCFL'
  			   THEN
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
       		END IF;
  END IF;
  IF upper(Column_Name) = 'DT_ALIAS' OR
    		column_name is NULL THEN
  		IF new_references.dt_alias <> UPPER(new_references.dt_alias) THEN
  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
  		END IF;
  END IF;
  IF upper(Column_Name) = 'FEE_CAL_TYPE' OR
    		column_name is NULL THEN
  		IF new_references.fee_cal_type <> UPPER(new_references.fee_cal_type) THEN
  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
  		END IF;
  END IF;

  IF upper(Column_Name) = 'RETENTION_AMOUNT' OR
	     		column_name is NULL THEN
	   		IF new_references.retention_amount < 0 THEN
	   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
	   			App_Exception.Raise_Exception;
	   		END IF;
  END IF;
  IF upper(Column_Name) = 'RETENTION_PERCENTAGE' OR
	     		column_name is NULL THEN
	   		IF new_references.retention_percentage < 0 OR
			   new_references.retention_percentage > 100 THEN
	   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  IGS_GE_MSG_STACK.ADD;
	   			App_Exception.Raise_Exception;
	   		END IF;
  END IF;
  END Check_Constraints;
FUNCTION Get_UK1_For_Validation (
	      x_fee_cal_type IN VARCHAR2,
	      x_fee_ci_sequence_number IN NUMBER,
	      x_fee_cat		IN VARCHAR2,
  	      x_fee_type		IN VARCHAR2,
  	      x_dt_alias		IN VARCHAR2,
              x_s_relation_type IN VARCHAR2,
              x_dai_sequence_number IN NUMBER
      )RETURN BOOLEAN AS
	  CURSOR cur_rowid IS
	        SELECT   rowid
	        FROM     IGS_FI_FEE_RET_SCHD
         WHERE    fee_cal_type = x_fee_cal_type
         AND      fee_ci_sequence_number = x_fee_ci_sequence_number
         AND      ((fee_cat = x_fee_cat) OR (fee_cat IS NULL AND x_fee_cat IS NULL))
         AND      ((fee_type = x_fee_type) OR (fee_type IS NULL AND x_fee_type IS NULL))
         AND      dt_alias = x_dt_alias
         AND      dai_sequence_number = x_dai_sequence_number
         AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));
   lv_rowid cur_rowid%RowType;
BEGIN

/*x_s_relation_type is not used for UK checks - it is retained as is, in parameter list as of now */

	    Open cur_rowid;
	    Fetch cur_rowid INTO lv_rowid;
	 IF (cur_rowid%FOUND) THEN
	       Close cur_rowid;
	       Return (TRUE);
	 ELSE
	       Close cur_rowid;
	       Return (FALSE);
     END IF;
END   Get_UK1_For_Validation;


FUNCTION Get_UK2_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
  	x_fee_cat		IN VARCHAR2,
  	x_fee_type		IN VARCHAR2,
  	x_schedule_number IN NUMBER
    )RETURN BOOLEAN
	AS
	CURSOR cur_rowid IS
		  SELECT   rowid
	        FROM     IGS_FI_FEE_RET_SCHD
           WHERE    fee_cal_type = x_fee_cal_type
             AND      fee_ci_sequence_number = x_fee_ci_sequence_number
             AND      ((fee_type = x_fee_type) OR (fee_type IS NULL AND x_fee_type IS NULL))
             AND      ((fee_cat = x_fee_cat) OR (fee_cat IS NULL AND x_fee_cat IS NULL))
             AND      schedule_number = x_schedule_number
             AND      ((l_rowid IS NULL) OR (rowid <> l_rowid)) ;
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
END Get_UK2_For_Validation;

PROCEDURE Check_Uniqueness
AS
BEGIN
IF Get_UK1_For_Validation (
	      new_references.fee_cal_type ,
	      new_references.fee_ci_sequence_number ,
	  	  new_references.fee_cat,
  		  new_references.fee_type,
  	      new_references.dt_alias,
          new_references.s_relation_type,
          new_references.dai_sequence_number) THEN
	          Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                  IGS_GE_MSG_STACK.ADD;
	          App_Exception.Raise_Exception;
END IF;
IF Get_UK2_For_Validation (
		    new_references.fee_cal_type,
		    new_references.fee_ci_sequence_number,
		  	new_references.fee_cat,
		  	new_references.fee_type,
  			new_references.schedule_number) THEN
		         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                  IGS_GE_MSG_STACK.ADD;
		         App_Exception.Raise_Exception;
END IF;

END Check_Uniqueness;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_F_CAT_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF ;
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type
        ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
     	 App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_type,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_RET_SCHD
      WHERE    fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      sequence_number = x_sequence_number
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
 END Get_PK_For_Validation;


  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_RET_SCHD
      WHERE    dt_alias = x_dt_alias
      AND      dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FRTNS_DAI_FK');
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
      FROM     IGS_FI_FEE_RET_SCHD
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FRTNS_FCCI_FK');
                  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_F_CAT_CA_INST;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_schedule_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retention_percentage IN NUMBER DEFAULT NULL,
    x_retention_amount IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  shtatiko        13-MAR-2003     Bug# 2473845, Added statement l_rowid := null; because, this
  ||                                  is creating problems when get_uk_for_validation is directly
  ||                                  from pld.
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed references of deduction_amount(from call to
  ||                               set_column_values procedure).
  ----------------------------------------------------------------------------*/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_sequence_number,
      x_fee_cat,
      x_fee_type,
      x_schedule_number,
      x_dt_alias,
      x_dai_sequence_number,
      x_retention_percentage,
      x_retention_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	  IF Get_PK_For_Validation (
    			new_references.fee_cal_type,
			    new_references.fee_ci_sequence_number,
			    new_references.s_relation_type,
			    new_references.sequence_number ) THEN
	         		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                  IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	  END IF;
      Check_Uniqueness;
	  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Uniqueness;
	  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation (
    			new_references.fee_cal_type,
			    new_references.fee_ci_sequence_number,
			    new_references.s_relation_type,
			    new_references.sequence_number ) THEN
	         		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                  IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	  END IF;
      Check_Uniqueness;
	  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
			Check_Uniqueness;
		 	Check_Constraints;
    END IF;
    l_rowid := NULL;
  END Before_DML;

  PROCEDURE after_dml (
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
  ||  smadathi        18-FEB-2003     Bug 2473845.Added logic to re initialize l_rowid to null.
  ||  shtatiko        07-FEB-2003     Removed the statement l_rowid := x_rowid; as
  ||                                  l_rowid is not at all used after assignment.
  ||                                  And this assignment is causing the problems
  ||                                  when get_uk is called directly from the pld.
    ----------------------------------------------------------------------------*/
  BEGIN
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterStmtInsertUpdate4 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate3 ( p_updating => TRUE );
      AfterStmtInsertUpdate4 ( p_updating => TRUE );
    END IF;
    l_rowid := NULL;
  END after_dml;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed references to deduction_amount(from call to
  ||                               before_dml and from insert statement).
  ----------------------------------------------------------------------------*/
    cursor C is select ROWID from IGS_FI_FEE_RET_SCHD
      where FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and S_RELATION_TYPE = X_S_RELATION_TYPE;
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
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := NULL;
      X_PROGRAM_ID := NULL;
      X_PROGRAM_APPLICATION_ID := NULL;
      X_PROGRAM_UPDATE_DATE := NULL;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
                  IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_retention_amount=>X_RETENTION_AMOUNT,
 x_retention_percentage=>X_RETENTION_PERCENTAGE,
 x_s_relation_type=>X_S_RELATION_TYPE,
 x_schedule_number=>X_SCHEDULE_NUMBER,
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_FI_FEE_RET_SCHD (
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    SEQUENCE_NUMBER,
    FEE_CAT,
    FEE_TYPE,
    SCHEDULE_NUMBER,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    RETENTION_PERCENTAGE,
    RETENTION_AMOUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.SCHEDULE_NUMBER,
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RETENTION_PERCENTAGE,
    NEW_REFERENCES.RETENTION_AMOUNT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER
) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed references to deduction_amount(from cursor c1 and
  ||                               from if condition).
  ----------------------------------------------------------------------------*/
  cursor c1 is select
      FEE_CAT,
      FEE_TYPE,
      SCHEDULE_NUMBER,
      DT_ALIAS,
      DAI_SEQUENCE_NUMBER,
      RETENTION_PERCENTAGE,
      RETENTION_AMOUNT
    from IGS_FI_FEE_RET_SCHD
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
      if ( ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
      AND ((tlinfo.FEE_TYPE = X_FEE_TYPE)
           OR ((tlinfo.FEE_TYPE is null)
               AND (X_FEE_TYPE is null)))
      AND (tlinfo.SCHEDULE_NUMBER = X_SCHEDULE_NUMBER)
      AND (tlinfo.DT_ALIAS = X_DT_ALIAS)
      AND (tlinfo.DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER)
      AND ((tlinfo.RETENTION_PERCENTAGE = X_RETENTION_PERCENTAGE)
           OR ((tlinfo.RETENTION_PERCENTAGE is null)
               AND (X_RETENTION_PERCENTAGE is null)))
      AND ((tlinfo.RETENTION_AMOUNT = X_RETENTION_AMOUNT)
           OR ((tlinfo.RETENTION_AMOUNT is null)
               AND (X_RETENTION_AMOUNT is null)))
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
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed references to deduction_amount(from call to
  ||                               before_dml and from update statement).
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
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
                  IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_retention_amount=>X_RETENTION_AMOUNT,
 x_retention_percentage=>X_RETENTION_PERCENTAGE,
 x_s_relation_type=>X_S_RELATION_TYPE,
 x_schedule_number=>X_SCHEDULE_NUMBER,
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_FI_FEE_RET_SCHD set
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    FEE_TYPE = NEW_REFERENCES.FEE_TYPE,
    SCHEDULE_NUMBER = NEW_REFERENCES.SCHEDULE_NUMBER,
    DT_ALIAS = NEW_REFERENCES.DT_ALIAS,
    DAI_SEQUENCE_NUMBER = NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    RETENTION_PERCENTAGE = NEW_REFERENCES.RETENTION_PERCENTAGE,
    RETENTION_AMOUNT = NEW_REFERENCES.RETENTION_AMOUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;
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
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed references to deduction_amount(from calls to
  ||                               insert_row and update_row).
  ----------------------------------------------------------------------------*/
  cursor c1 is select rowid from IGS_FI_FEE_RET_SCHD
     where FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and S_RELATION_TYPE = X_S_RELATION_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAL_TYPE,
     X_SEQUENCE_NUMBER,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_S_RELATION_TYPE,
     X_FEE_CAT,
     X_FEE_TYPE,
     X_SCHEDULE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_RETENTION_PERCENTAGE,
     X_RETENTION_AMOUNT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
  X_ROWID,
   X_FEE_CAL_TYPE,
   X_SEQUENCE_NUMBER,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_S_RELATION_TYPE,
   X_FEE_CAT,
   X_FEE_TYPE,
   X_SCHEDULE_NUMBER,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_RETENTION_PERCENTAGE,
   X_RETENTION_AMOUNT,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
     );
  delete from IGS_FI_FEE_RET_SCHD
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_FEE_RET_SCHD_PKG;

/
