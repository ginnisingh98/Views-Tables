--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_AS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_AS_PKG" AS
/* $Header: IGSSI18B.pls 115.25 2003/02/12 06:16:35 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_AS_ALL%RowType;
  new_references IGS_FI_FEE_AS_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_transaction_id IN NUMBER ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_fee_cat IN VARCHAR2 ,
    x_s_transaction_type IN VARCHAR2 ,
    x_transaction_dt IN DATE ,
    x_transaction_amount IN NUMBER ,
    x_currency_cd IN VARCHAR2 ,
    x_exchange_rate IN NUMBER ,
    x_chg_elements IN NUMBER ,
    x_effective_dt IN DATE ,
    x_course_cd IN VARCHAR2 ,
    x_notification_dt IN DATE ,
    x_logical_delete_dt IN DATE ,
    x_comments IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk         02-Sep-2002        Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
  ||                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ----------------------------------------------------------------------------*/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_AS_ALL
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
    new_references.person_id := x_person_id;
    new_references.transaction_id := x_transaction_id;
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_cat := x_fee_cat;
    new_references.s_transaction_type := x_s_transaction_type;
    new_references.transaction_dt := x_transaction_dt;
    new_references.transaction_amount := x_transaction_amount;
    new_references.currency_cd := x_currency_cd;
    new_references.exchange_rate := x_exchange_rate;
    new_references.chg_elements := x_chg_elements;
    new_references.effective_dt := x_effective_dt;
    new_references.course_cd := x_course_cd;
    new_references.notification_dt := x_notification_dt;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
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
  -- "OSS_TST".trg_fas_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_FEE_AS_ALL
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
 masehgal , IDC   10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
 SCHODAVA	  28-NOV-2001     Enh # 2122257
				  (SFCR015 : Change In Fee Category)
				  Changed the call to
				  IGS_FI_VAL_FAS.finp_val_fas_ass_ind function.
				  Added the params fee_cal_type
				  and fee_ci_sequence_number
  (reverse chronological order - newest change first)
  ***************************************************************/
    v_message_name varchar2(30);

  CURSOR c_sft IS
  SELECT 'x'
  FROM   igs_fi_fee_type fft
  WHERE  fft.s_fee_type = 'EXTERNAL'
  AND    fft.fee_type   = 'x_fee_type';

  BEGIN
	-- Validate Fee Assessment can be created.
/*	IF p_inserting THEN
		-- Validate current date not greater than Retrospective assessment period.
		IF IGS_FI_VAL_FAS.finp_val_fas_retro (
				new_references.fee_type,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.fee_cat,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;  */
	-- Validate that appropriate fields are set depending on the fee type.
	IF p_inserting OR
		(p_updating AND (new_references.course_cd <> old_references.course_cd OR
				new_references.fee_cat <> old_references.fee_cat)) THEN
		-- Validate that IGS_PS_COURSE code can be specified.
		IF IGS_FI_VAL_FAS.finp_val_fas_create (
				new_references.fee_type,
				new_references.fee_cat,
				new_references.course_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		-- Validate that course code can be specified.
		-- Enh # 2122257 (SFCR015 : Change In Fee Category)
		-- Changed the call to this function.
		-- Added params fee_cal_type and fee_ci_sequence_number
		IF IGS_FI_VAL_FAS.finp_val_fas_ass_ind (
				new_references.person_id,
				new_references.course_cd,
				new_references.fee_cat,
				new_references.effective_dt,
				new_references.s_transaction_type,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate effective date.
        -- Only for fee types other than 'EXTERNAL' SYSTEM FEE TYPE
        OPEN  c_sft;
        IF c_sft%FOUND THEN
          CLOSE c_sft;
        ELSIF c_sft%NOTFOUND THEN
          CLOSE c_sft;
          IF p_inserting OR
		(new_references.effective_dt <> old_references.effective_dt) THEN
		IF IGS_FI_VAL_FAS.finp_val_fas_eff_dt (
				new_references.fee_type,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.fee_cat,
				new_references.effective_dt,
				new_references.s_transaction_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
          END IF;
        END IF;  -- For External System Fee Type NOT FOUND
	IF p_inserting OR p_updating THEN
		-- Validate that course code is fee assessable for manual entries.
		IF IGS_FI_VAL_FAS.finp_val_fas_com (
				new_references.s_transaction_type,
				new_references.comments,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_updating THEN
		-- Validate the columns being changed are allowed to be
		IF IGS_FI_VAL_FAS.finp_val_fas_upd (
				new_references.person_id,
				old_references.person_id,
				new_references.transaction_id,
				old_references.transaction_id,
				new_references.fee_type,
				old_references.fee_type,
				new_references.fee_cal_type,
				old_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				old_references.fee_ci_sequence_number,
				new_references.fee_cat,
				old_references.fee_cat,
				new_references.s_transaction_type,
				old_references.s_transaction_type,
				new_references.transaction_dt,
				old_references.transaction_dt,
				new_references.transaction_amount,
				old_references.transaction_amount,
				new_references.currency_cd,
				old_references.currency_cd,
				new_references.exchange_rate,
				old_references.exchange_rate,
				new_references.chg_elements,
				old_references.chg_elements,
				new_references.effective_dt,
				old_references.effective_dt,
				new_references.course_cd,
				old_references.course_cd,
				new_references.notification_dt,
				old_references.notification_dt,
				new_references.logical_delete_dt,
				old_references.logical_delete_dt,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

   PROCEDURE Check_Uniqueness AS
   Begin
   IF  Get_UK_For_Validation (
	new_references.transaction_id
	) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END IF;
   End Check_Uniqueness;

PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
 ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        30-Aug-2002     Bug#2531390. Removed default values of parameters column_name,
  ||                                  column_value to avoid gscc warnings.
  ||  vvutukur        17-May-2002     removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'TRANSACTION_ID' then
     new_references.transaction_id := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
  ELSIF upper(Column_name) = 'CURRENCY_CD' then
     new_references.currency_cd := column_value;
  ELSIF upper(Column_name) = 'FEE_CAL_TYPE' then
     new_references.fee_cal_type := column_value;
  ELSIF upper(Column_name) = 'S_TRANSACTION_TYPE' then
     new_references.s_transaction_type := column_value;
  ELSIF upper(Column_name) = 'CHG_ELEMENTS' then
     new_references.chg_elements := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'EXCHANGE_RATE' then
     new_references.exchange_rate := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'TRANSACTION_AMOUNT' then
     new_references.transaction_amount := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'FEE_CI_SEQUENCE_NUMBER' then
     new_references.fee_ci_sequence_number := igs_ge_number.to_num(column_value);
  End if;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.COURSE_CD <>
	UPPER(new_references.COURSE_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'CURRENCY_CD' OR
     column_name is null Then
     IF new_references.CURRENCY_CD <>
	UPPER(new_references.CURRENCY_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'FEE_CAL_TYPE' OR
     column_name is null Then
     IF new_references.FEE_CAL_TYPE <>
	UPPER(new_references.FEE_CAL_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'S_TRANSACTION_TYPE' OR
     column_name is null Then
     IF new_references.S_TRANSACTION_TYPE <>
	UPPER(new_references.S_TRANSACTION_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'TRANSACTION_ID' OR
     column_name is null Then
     IF new_references.transaction_id  < 1 OR
          new_references.transaction_id > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'CHG_ELEMENTS' OR
     column_name is null Then
     IF new_references.chg_elements  < 0 OR
          new_references.chg_elements > 9999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'EXCHANGE_RATE' OR
     column_name is null Then
     IF new_references.exchange_rate  < 0.0001 OR
          new_references.exchange_rate > 9999.9999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'TRANSACTION_AMOUNT' OR
     column_name is null Then
     IF new_references.transaction_amount  < -999990.00 OR
          new_references.transaction_amount > 999990.00 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.fee_ci_sequence_number  < 1 OR
          new_references.fee_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END Check_CONSTRAINTS;

 PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_FI_FEE_AS_ITEMS_PKG.GET_FK_IGS_FI_FEE_AS (
      old_references.person_id,
      old_references.transaction_id);

  END Check_Child_Existance;


  PROCEDURE check_parent_existance AS
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smadathi  06-Nov-2002     Enh. Bug 2584986. removed igs_fi_cur_pkg.get_pk_for_validation
  -------------------------------------------------------------------
  BEGIN
    IF (((old_references.course_cd = new_references.course_cd)) OR
        ((new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PS_COURSE_PKG.Get_PK_For_Validation (
        new_references.course_cd
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type
        )	THEN
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
      IF  NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_type,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF (((old_references.s_transaction_type = new_references.s_transaction_type)) OR
        ((new_references.s_transaction_type IS NULL))) THEN
      NULL;
    ELSE
	IF  NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	  'TRANSACTION_TYPE',
        new_references.s_transaction_type
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
  END check_parent_existance;

--removed local procedure check_uk_child_existance. Bug#2531390.

  Function Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_transaction_id IN NUMBER
    ) Return Boolean
	AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_ALL
      WHERE    person_id = x_person_id
      AND      transaction_id = x_transaction_id
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

  FUNCTION Get_UK_For_Validation (
    x_transaction_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_ALL
         WHERE    transaction_id = new_references.transaction_id
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
  END Get_UK_For_Validation;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_ALL
      WHERE    course_cd = x_course_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAS_CRS_FK');
            IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_COURSE;


  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_ALL
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAS_PE_FK');
            IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_transaction_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_ALL
      WHERE    s_transaction_type = x_s_transaction_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FAS_STRTY_FK');
            IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_person_id IN NUMBER,
    x_transaction_id IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_cat IN VARCHAR2,
    x_s_transaction_type IN VARCHAR2,
    x_transaction_dt IN DATE,
    x_transaction_amount IN NUMBER,
    x_currency_cd IN VARCHAR2,
    x_exchange_rate IN NUMBER,
    x_chg_elements IN NUMBER,
    x_effective_dt IN DATE,
    x_course_cd IN VARCHAR2,
    x_notification_dt IN DATE,
    x_logical_delete_dt IN DATE,
    x_comments IN VARCHAR2,
    x_org_id IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk            02-Sep-2002  Modified the call to beforerowinsertupdatedelete1 procedure as per apps standards.
  ||                               As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ||  vvutukur        30-Aug-2002  Bug#2531390.Removed calls to check_uk_child_existance local procedure
  ||                               as this procedure is removed as part of this bugfix.Also removed default
  ||                               null from before_dml procedure parameters to avoid gscc warnings.
  ----------------------------------------------------------------------------*/
    BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_transaction_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_cat,
      x_s_transaction_type,
      x_transaction_dt,
      x_transaction_amount,
      x_currency_cd,
      x_exchange_rate,
      x_chg_elements,
      x_effective_dt,
      x_course_cd,
      x_notification_dt,
      x_logical_delete_dt,
      x_comments,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 (p_inserting => TRUE , p_updating =>FALSE , p_deleting =>FALSE);
	  	IF  Get_PK_For_Validation (
		new_references.person_id ,
    	new_references.transaction_id
        ) THEN
	  	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                           IGS_GE_MSG_STACK.ADD;
	  	          App_Exception.Raise_Exception;
	  	END IF;
	  	Check_Constraints;
	          Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 (p_inserting => FALSE, p_updating => TRUE, p_deleting =>FALSE);
	  	Check_Constraints;
	          Check_Uniqueness;
      Check_Parent_Existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
      BeforeRowInsertUpdateDelete1 (p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE);
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	      IF  Get_PK_For_Validation (
			new_references.person_id ,
    		new_references.transaction_id
			) THEN
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
            IGS_GE_MSG_STACK.ADD;
	          App_Exception.Raise_Exception;
	      END IF;
	      Check_Constraints;
	      Check_Uniqueness;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	       Check_Constraints;
	       Check_Uniqueness;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
            Check_Child_Existance;

    END IF;
  END Before_DML;

  /****************ADDED BY SYAM ON 21_DEC_2000***************/

  PROCEDURE After_DML (
      p_action IN VARCHAR2,
      x_rowid IN VARCHAR2
    ) IS
    /*************************************************************
    Created By :
    Date Created By :
    Purpose :
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    masehgal        10-JAN-2002     Enh # 2170429
                                    Obsoletion of SPONSOR_CD
 (reverse chronological order - newest change first)
    ***************************************************************/

    BEGIN

      l_rowid := x_rowid;

      IF (p_action = 'INSERT') THEN
        -- Call all the procedures related to After Insert.
        Null;
      ELSIF (p_action = 'UPDATE') THEN
        -- Call all the procedures related to After Update.
        Null;
      ELSIF (p_action = 'DELETE') THEN
        -- Call all the procedures related to After Delete.
        Null;
      END IF;

    l_rowid := NULL;

    END After_DML;

  /****************ADDED BY SYAM ON 21_DEC_2000***************/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSACTION_ID in out NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_S_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_DT in DATE,
  X_TRANSACTION_AMOUNT in NUMBER,
  X_CURRENCY_CD in VARCHAR2,
  X_EXCHANGE_RATE in NUMBER,
  X_CHG_ELEMENTS in NUMBER,
  X_EFFECTIVE_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_NOTIFICATION_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2,
  x_org_id IN NUMBER,
  X_MODE in VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        30-Aug-2002  Bug#2531390.Removed default value of x_mode parameter to avoid gscc
  ||                               warnings.
  ----------------------------------------------------------------------------*/
    cursor C is select ROWID from IGS_FI_FEE_AS_ALL
      where PERSON_ID = X_PERSON_ID
      and TRANSACTION_ID = X_TRANSACTION_ID;
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
    ---added by syam on 23-aug-2000
	SELECT igs_fi_fee_as_trn_id_s.nextval
	INTO   x_transaction_id
	FROM DUAL;
     ---added by syam on 23-aug-2000

 Before_DML(
    p_action => 'INSERT',
    x_rowid => x_rowid,
    x_person_id => x_person_id,
    x_transaction_id => x_transaction_id,
    x_fee_type => x_fee_type,
    x_fee_cal_type => x_fee_cal_type,
    x_fee_ci_sequence_number => x_fee_ci_sequence_number,
    x_fee_cat => x_fee_cat,
    x_s_transaction_type => x_s_transaction_type,
    x_transaction_dt => x_transaction_dt,
    x_transaction_amount => x_transaction_amount,
    x_currency_cd => x_currency_cd,
    x_exchange_rate => x_exchange_rate,
    x_chg_elements => x_chg_elements,
    x_effective_dt => x_effective_dt,
    x_course_cd => x_course_cd,
    x_notification_dt => x_notification_dt,
    x_logical_delete_dt => x_logical_delete_dt,
    x_comments => x_comments,
    x_org_id => igs_ge_gen_003.get_org_id,
x_creation_date => X_LAST_UPDATE_DATE,
x_created_by => X_LAST_UPDATED_BY,
x_last_update_date => X_LAST_UPDATE_DATE,
x_last_updated_by => X_LAST_UPDATED_BY,
x_last_update_login => X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_FEE_AS_ALL (
    PERSON_ID,
    TRANSACTION_ID,
    FEE_TYPE,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_CAT,
    S_TRANSACTION_TYPE,
    TRANSACTION_DT,
    TRANSACTION_AMOUNT,
    CURRENCY_CD,
    EXCHANGE_RATE,
    CHG_ELEMENTS,
    EFFECTIVE_DT,
    COURSE_CD,
    NOTIFICATION_DT,
    LOGICAL_DELETE_DT,
    COMMENTS,
    ORG_ID,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.TRANSACTION_ID,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.S_TRANSACTION_TYPE,
    NEW_REFERENCES.TRANSACTION_DT,
    NEW_REFERENCES.TRANSACTION_AMOUNT,
    NEW_REFERENCES.CURRENCY_CD,
    NEW_REFERENCES.EXCHANGE_RATE,
    NEW_REFERENCES.CHG_ELEMENTS,
    NEW_REFERENCES.EFFECTIVE_DT,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.NOTIFICATION_DT,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.ORG_ID,
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
 /****************ADDED BY SYAM ON 21_DEC_2000***************/
   After_DML (
 		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
/****************ADDED BY SYAM ON 21_DEC_2000***************/
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSACTION_ID in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_S_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_DT in DATE,
  X_TRANSACTION_AMOUNT in NUMBER,
  X_CURRENCY_CD in VARCHAR2,
  X_EXCHANGE_RATE in NUMBER,
  X_CHG_ELEMENTS in NUMBER,
  X_EFFECTIVE_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_NOTIFICATION_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      FEE_TYPE,
      FEE_CAL_TYPE,
      FEE_CI_SEQUENCE_NUMBER,
      FEE_CAT,
      S_TRANSACTION_TYPE,
      TRANSACTION_DT,
      TRANSACTION_AMOUNT,
      CURRENCY_CD,
      EXCHANGE_RATE,
      CHG_ELEMENTS,
      EFFECTIVE_DT,
      COURSE_CD,
      NOTIFICATION_DT,
      LOGICAL_DELETE_DT,
      COMMENTS
    from IGS_FI_FEE_AS_ALL
    where ROWID = X_ROWID
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
      if (
          ((tlinfo.FEE_TYPE = X_FEE_TYPE)
           OR ((tlinfo.FEE_TYPE is null)
               AND (X_FEE_TYPE is null)))
      AND ((tlinfo.FEE_CAL_TYPE = X_FEE_CAL_TYPE)
           OR ((tlinfo.FEE_CAL_TYPE is null)
               AND (X_FEE_CAL_TYPE is null)))
      AND ((tlinfo.FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.FEE_CI_SEQUENCE_NUMBER is null)
                 AND X_FEE_CI_SEQUENCE_NUMBER is null))
      AND ( (tlinfo.FEE_CAT = X_FEE_CAT)
             OR ( (tlinfo.FEE_CAT is null)
                   AND X_FEE_CAT is null  ) )
      AND ((tlinfo.S_TRANSACTION_TYPE = X_S_TRANSACTION_TYPE)
           OR( (tlinfo.S_TRANSACTION_TYPE is null)
                AND X_S_TRANSACTION_TYPE is null))
      AND (( Trunc(tlinfo.TRANSACTION_DT) = trunc(X_TRANSACTION_DT) )
            OR (( tlinfo.TRANSACTION_DT is null)
                 AND  X_TRANSACTION_DT is null  ))
      AND (  (tlinfo.TRANSACTION_AMOUNT = X_TRANSACTION_AMOUNT)
           OR( (tlinfo.TRANSACTION_AMOUNT is null)
                AND
               ( X_TRANSACTION_AMOUNT is null)
             )
          )
      AND (    (tlinfo.CURRENCY_CD = X_CURRENCY_CD)
            OR ( (tlinfo.CURRENCY_CD is null )
                AND
                (X_CURRENCY_CD is null)
               )
          )
      AND (     (tlinfo.EXCHANGE_RATE = X_EXCHANGE_RATE)
            OR( (tlinfo.EXCHANGE_RATE is null )
                AND
                (X_EXCHANGE_RATE is null )
              )
          )
      AND ((tlinfo.CHG_ELEMENTS = X_CHG_ELEMENTS)
           OR ((tlinfo.CHG_ELEMENTS is null)
               AND (X_CHG_ELEMENTS is null)))
      AND ((Trunc(tlinfo.EFFECTIVE_DT) = Trunc(X_EFFECTIVE_DT) )
           OR ((tlinfo.EFFECTIVE_DT is null)
               AND (X_EFFECTIVE_DT is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((Trunc(tlinfo.NOTIFICATION_DT) = Trunc(X_NOTIFICATION_DT))
           OR ((tlinfo.NOTIFICATION_DT is null)
               AND (X_NOTIFICATION_DT is null)))
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_PERSON_ID in NUMBER,
  X_TRANSACTION_ID in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_S_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_DT in DATE,
  X_TRANSACTION_AMOUNT in NUMBER,
  X_CURRENCY_CD in VARCHAR2,
  X_EXCHANGE_RATE in NUMBER,
  X_CHG_ELEMENTS in NUMBER,
  X_EFFECTIVE_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_NOTIFICATION_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        30-Aug-2002  Bug#2531390.Removed default value of x_mode parameter to avoid gscc
  ||                               warnings.
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
 Before_DML(
    p_action => 'UPDATE',
    x_rowid => x_rowid,
    x_person_id => x_person_id,
    x_transaction_id => x_transaction_id,
    x_fee_type => x_fee_type,
    x_fee_cal_type => x_fee_cal_type,
    x_fee_ci_sequence_number => x_fee_ci_sequence_number,
    x_fee_cat => x_fee_cat,
    x_s_transaction_type => x_s_transaction_type,
    x_transaction_dt => x_transaction_dt,
    x_transaction_amount => x_transaction_amount,
    x_currency_cd => x_currency_cd,
    x_exchange_rate => x_exchange_rate,
    x_chg_elements => x_chg_elements,
    x_effective_dt => x_effective_dt,
    x_course_cd => x_course_cd,
    x_notification_dt => x_notification_dt,
    x_logical_delete_dt => x_logical_delete_dt,
    x_comments => x_comments,
x_creation_date => X_LAST_UPDATE_DATE,
x_created_by => X_LAST_UPDATED_BY,
x_last_update_date => X_LAST_UPDATE_DATE,
x_last_updated_by => X_LAST_UPDATED_BY,
x_last_update_login => X_LAST_UPDATE_LOGIN
);
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
  update IGS_FI_FEE_AS_ALL set
    FEE_TYPE = NEW_REFERENCES.FEE_TYPE,
    FEE_CAL_TYPE = NEW_REFERENCES.FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER = NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    S_TRANSACTION_TYPE = NEW_REFERENCES.S_TRANSACTION_TYPE,
    TRANSACTION_DT = NEW_REFERENCES.TRANSACTION_DT,
    TRANSACTION_AMOUNT = NEW_REFERENCES.TRANSACTION_AMOUNT,
    CURRENCY_CD = NEW_REFERENCES.CURRENCY_CD,
    EXCHANGE_RATE = NEW_REFERENCES.EXCHANGE_RATE,
    CHG_ELEMENTS = NEW_REFERENCES.CHG_ELEMENTS,
    EFFECTIVE_DT = NEW_REFERENCES.EFFECTIVE_DT,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    NOTIFICATION_DT = NEW_REFERENCES.NOTIFICATION_DT,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
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

  /****************ADDED BY SYAM ON 21_DEC_2000***************/
 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
/****************ADDED BY SYAM ON 21_DEC_2000***************/
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSACTION_ID in out NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_S_TRANSACTION_TYPE in VARCHAR2,
  X_TRANSACTION_DT in DATE,
  X_TRANSACTION_AMOUNT in NUMBER,
  X_CURRENCY_CD in VARCHAR2,
  X_EXCHANGE_RATE in NUMBER,
  X_CHG_ELEMENTS in NUMBER,
  X_EFFECTIVE_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_NOTIFICATION_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        30-Aug-2002  Bug#2531390.Removed default value of x_mode parameter to avoid gscc
  ||                               warnings.
  ----------------------------------------------------------------------------*/

  cursor c1 is select rowid from IGS_FI_FEE_AS_ALL
     where PERSON_ID = X_PERSON_ID
     and TRANSACTION_ID = X_TRANSACTION_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_TRANSACTION_ID,
     X_FEE_TYPE,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_FEE_CAT,
     X_S_TRANSACTION_TYPE,
     X_TRANSACTION_DT,
     X_TRANSACTION_AMOUNT,
     X_CURRENCY_CD,
     X_EXCHANGE_RATE,
     X_CHG_ELEMENTS,
     X_EFFECTIVE_DT,
     X_COURSE_CD,
     X_NOTIFICATION_DT,
     X_LOGICAL_DELETE_DT,
     X_COMMENTS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
  X_ROWID,
   X_PERSON_ID,
   X_TRANSACTION_ID,
   X_FEE_TYPE,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_CAT,
   X_S_TRANSACTION_TYPE,
   X_TRANSACTION_DT,
   X_TRANSACTION_AMOUNT,
   X_CURRENCY_CD,
   X_EXCHANGE_RATE,
   X_CHG_ELEMENTS,
   X_EFFECTIVE_DT,
   X_COURSE_CD,
   X_NOTIFICATION_DT,
   X_LOGICAL_DELETE_DT,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid  => X_ROWID
);
  delete from IGS_FI_FEE_AS_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  /****************ADDED BY SYAM ON 21_DEC_2000***************/
 After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID

);
/****************ADDED BY SYAM ON 21_DEC_2000***************/
end DELETE_ROW;
end IGS_FI_FEE_AS_PKG;

/
