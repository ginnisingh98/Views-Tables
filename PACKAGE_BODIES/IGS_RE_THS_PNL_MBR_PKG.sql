--------------------------------------------------------
--  DDL for Package Body IGS_RE_THS_PNL_MBR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THS_PNL_MBR_PKG" as
/* $Header: IGSRI21B.pls 120.1 2005/07/04 00:42:48 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_tpm.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_RE_THS_PNL_MBR%RowType;
  new_references IGS_RE_THS_PNL_MBR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ca_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_panel_member_type IN VARCHAR2 DEFAULT NULL,
    x_confirmed_dt IN DATE DEFAULT NULL,
    x_declined_dt IN DATE DEFAULT NULL,
    x_anonymity_ind IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_paid_dt IN DATE DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_recommendation_summary IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_THS_PNL_MBR
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.ca_person_id := x_ca_person_id;
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.the_sequence_number := x_the_sequence_number;
    new_references.creation_dt := x_creation_dt;
    new_references.person_id := x_person_id;
    new_references.panel_member_type := x_panel_member_type;
    new_references.confirmed_dt := x_confirmed_dt;
    new_references.declined_dt := x_declined_dt;
    new_references.anonymity_ind := x_anonymity_ind;
    new_references.thesis_result_cd := x_thesis_result_cd;
    new_references.paid_dt := x_paid_dt;
    new_references.tracking_id := x_tracking_id;
    new_references.recommendation_summary := x_recommendation_summary;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name			VARCHAR2(30);
	v_transaction_type		VARCHAR2(10);
  BEGIN
	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
		IF p_inserting OR
		   ( p_updating AND
		     ( NVL(old_references.thesis_result_cd,' ') <> NVL(new_references.thesis_result_cd,' ') OR
		   old_references.panel_member_type <> new_references.panel_member_type OR
		   NVL(old_references.confirmed_dt, igs_ge_date.igsdate('1900/01/01')) <>
		   				NVL(new_references.confirmed_dt, igs_ge_date.igsdate('1900/01/01')))) THEN
			IF p_inserting THEN
				v_transaction_type := 'INSERT';
			ELSIF p_updating THEN
				v_transaction_type := 'UPDATE';
			END IF;
			-- Validate whether insert or update is permitted.
			IF IGS_RE_VAL_TPM.resp_val_tpm_upd(	new_references.ca_person_id,
							new_references.ca_sequence_number,
							new_references.the_sequence_number,
							new_references.creation_dt,
							v_transaction_type,
							old_references.thesis_result_cd,
							new_references.thesis_result_cd,
							old_references.panel_member_type,
							new_references.panel_member_type,
							old_references.confirmed_dt,
							new_references.confirmed_dt,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		ELSIF p_deleting THEN
			-- Validate whether insert or update is permitted.
			IF IGS_RE_VAL_TPM.resp_val_tpm_upd(	old_references.ca_person_id,
							old_references.ca_sequence_number,
							old_references.the_sequence_number,
							old_references.creation_dt,
							'DELETE',
							old_references.thesis_result_cd,
							new_references.thesis_result_cd,
							old_references.panel_member_type,
							new_references.panel_member_type,
							old_references.confirmed_dt,
							new_references.confirmed_dt,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting THEN
			-- Validate examiner IGS_PE_PERSON ID - only on insert as pk field.
			IF IGS_RE_VAL_TPM.resp_val_tpm_pe(	new_references.ca_person_id,
							new_references.ca_sequence_number,
							new_references.person_id,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting OR
		   ( p_updating AND
	 	    (old_references.panel_member_type <> new_references.panel_member_type)) THEN
			-- Validate panel member type if p_inserting or changed.
			IF IGS_RE_VAL_TPM.resp_val_tpm_tpmt(	new_references.panel_member_type,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF (p_inserting AND new_references.thesis_result_cd IS NOT NULL) OR
	  	 ( p_updating AND
	  	   (NVL(old_references.thesis_result_cd,' ') <> NVL(new_references.thesis_result_cd,' '))) THEN
			-- Validate IGS_RE_THESIS result code on p_inserting or change.
			IF IGS_RE_VAL_TPM.resp_val_tpm_thr(	new_references.ca_person_id,
							new_references.ca_sequence_number,
							new_references.the_sequence_number,
							new_references.creation_dt,
							new_references.thesis_result_cd,
							new_references.recommendation_summary,
							new_references.confirmed_dt,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting OR
		   ( p_updating AND
	  	   (NVL(old_references.confirmed_dt,igs_ge_date.igsdate('1900/01/01')) <>
		 			NVL(new_references.confirmed_dt,igs_ge_date.igsdate('1900/01/01')) OR
		 	 NVL(old_references.declined_dt,igs_ge_date.igsdate('1900/01/01')) <>
		  			NVL(new_references.declined_dt,igs_ge_date.igsdate('1900/01/01')))) THEN
			-- Validate declined date and confirmed dates.
			IF IGS_RE_VAL_TPM.resp_val_tpm_dcln(	new_references.declined_dt,
							new_references.confirmed_dt,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
			IF IGS_RE_VAL_TPM.resp_val_tpm_cnfrm(	new_references.confirmed_dt,
							new_references.thesis_result_cd,
							new_references.paid_dt,
							new_references.declined_dt,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF ( p_inserting AND new_references.paid_dt IS NOT NULL ) OR
		   ( p_updating AND
	 	    NVL(old_references.paid_dt,igs_ge_date.igsdate('1900/01/01')) <>
		 				NVL(new_references.paid_dt,igs_ge_date.igsdate('1900/01/01'))) THEN
			-- Validate the paid date.
			IF IGS_RE_VAL_TPM.resp_val_tpm_paid(	new_references.paid_dt,
							new_references.confirmed_dt,
							v_message_name ) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowUpdateDelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  BEGIN

  	IF p_updating OR p_deleting THEN
  		IGS_RE_GEN_003.RESP_INS_TPM_HIST(old_references.ca_person_id,
  			old_references.ca_sequence_number,
  			old_references.the_sequence_number,
  			old_references.creation_dt,
  			old_references.person_id,
  			old_references.panel_member_type,
  			new_references.panel_member_type,
  			old_references.confirmed_dt,
  			new_references.confirmed_dt,
  			old_references.declined_dt,
  			new_references.declined_dt,
  			old_references.anonymity_ind,
  			new_references.anonymity_ind,
  			old_references.thesis_result_cd,
  			new_references.thesis_result_cd,
  			old_references.paid_dt,
  			new_references.paid_dt,
  			old_references.tracking_id,
  			new_references.tracking_id,
  			old_references.recommendation_summary,
  			new_references.recommendation_summary,
  			old_references.last_updated_by,
  			new_references.last_updated_by,
  			old_references.last_update_date,
  			new_references.last_update_date);
  	END IF;


  END AfterRowUpdateDelete2;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 ) AS
  BEGIN
   IF column_name is null then
	NULL;
   ELSIF upper(Column_name) = 'ANONYMITY_IND' then
	new_references.anonymity_ind := column_value ;
   ELSIF upper(Column_name) = 'PANEL_MEMBER_TYPE' then
	new_references.panel_member_type:= column_value ;
   ELSIF upper(Column_name) = 'THESIS_RESULT_CD' then
	new_references.thesis_result_cd:= column_value ;
   ELSIF upper(Column_name) = 'THE_SEQUENCE_NUMBER'then
	new_references.the_sequence_number  := column_value ;
   ELSIF upper(Column_name) ='CA_SEQUENCE_NUMBER' then
	new_references.ca_sequence_number := column_value ;
   END IF;

	IF upper(Column_name) = 'ANONYMITY_IND' OR column_name is null then
		IF new_references.anonymity_ind <> UPPER(new_references.anonymity_ind ) OR
			new_references.anonymity_ind NOT IN ( 'Y' , 'N' ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'THESIS_RESULT_CD' OR column_name is null then
		IF new_references.THESIS_RESULT_CD <> UPPER(new_references.THESIS_RESULT_CD ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'PANEL_MEMBER_TYPE' OR column_name is null then
		IF new_references.PANEL_MEMBER_TYPE <> UPPER(new_references.PANEL_MEMBER_TYPE ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF upper(Column_name) = 'THE_SEQUENCE_NUMBER' OR  column_name is null then
	   IF new_references.the_sequence_number  < 1 OR new_references.the_sequence_number  > 999999 THEN
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
	END IF;

	IF upper(Column_name) = 'CA_SEQUENCE_NUMBER' OR  column_name is null then
	   IF new_references.ca_sequence_number < 1 OR new_references.ca_sequence_number > 999999 THEN
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
	END IF;

END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.ca_person_id = new_references.ca_person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number) AND
         (old_references.the_sequence_number = new_references.the_sequence_number) AND
         (old_references.creation_dt = new_references.creation_dt)) OR
        ((new_references.ca_person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL) OR
         (new_references.the_sequence_number IS NULL) OR
         (new_references.creation_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_THESIS_EXAM_PKG.Get_PK_For_Validation (
        new_references.ca_person_id,
        new_references.ca_sequence_number,
        new_references.the_sequence_number,
        new_references.creation_dt
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.thesis_result_cd = new_references.thesis_result_cd)) OR
        ((new_references.thesis_result_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_THESIS_RESULT_PKG.Get_PK_For_Validation (
        new_references.thesis_result_cd
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.panel_member_type = new_references.panel_member_type)) OR
        ((new_references.panel_member_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_THS_PNL_MR_TP_PKG.Get_PK_For_Validation (
        new_references.panel_member_type
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_ca_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_the_sequence_number IN NUMBER,
    x_creation_dt IN DATE,
    x_person_id IN NUMBER
    )
    RETURN BOOLEAN
   AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MBR
      WHERE    ca_person_id = x_ca_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      the_sequence_number = x_the_sequence_number
      AND      creation_dt = x_creation_dt
      AND      person_id = x_person_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
        Return(TRUE);
    ELSE
       Close cur_rowid;
       Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MBR
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_TPM_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_RE_THESIS_EXAM (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_the_sequence_number IN NUMBER,
    x_creation_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MBR
      WHERE    ca_person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      the_sequence_number = x_the_sequence_number
      AND      creation_dt = x_creation_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_TPM_TEX_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_THESIS_EXAM;

  PROCEDURE GET_FK_IGS_RE_THESIS_RESULT (
    x_thesis_result_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MBR
      WHERE    thesis_result_cd = x_thesis_result_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_TPM_THR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_THESIS_RESULT;

  PROCEDURE GET_FK_IGS_RE_THS_PNL_MR_TP (
    x_panel_member_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MBR
      WHERE    panel_member_type = x_panel_member_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_TPM_TPMT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_THS_PNL_MR_TP;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ca_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_panel_member_type IN VARCHAR2 DEFAULT NULL,
    x_confirmed_dt IN DATE DEFAULT NULL,
    x_declined_dt IN DATE DEFAULT NULL,
    x_anonymity_ind IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_paid_dt IN DATE DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_recommendation_summary IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_ca_person_id,
      x_ca_sequence_number,
      x_the_sequence_number,
      x_creation_dt,
      x_person_id,
      x_panel_member_type,
      x_confirmed_dt,
      x_declined_dt,
      x_anonymity_ind,
      x_thesis_result_cd,
      x_paid_dt,
      x_tracking_id,
      x_recommendation_summary,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
	    new_references.ca_person_id ,
	    new_references.ca_sequence_number ,
	    new_references.the_sequence_number ,
	    new_references.creation_dt ,
	    new_references.person_id
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(
	    new_references.ca_person_id ,
	    new_references.ca_sequence_number ,
	    new_references.the_sequence_number ,
	    new_references.creation_dt ,
	    new_references.person_id
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	NULL;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdateDelete2 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete2 ( p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_RE_THS_PNL_MBR
      where CA_PERSON_ID = X_CA_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and THE_SEQUENCE_NUMBER = X_THE_SEQUENCE_NUMBER
      and CREATION_DT = X_CREATION_DT
      and PERSON_ID = X_PERSON_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_ca_person_id => X_CA_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_the_sequence_number => X_THE_SEQUENCE_NUMBER,
    x_creation_dt => X_CREATION_DT,
    x_person_id => X_PERSON_ID,
    x_panel_member_type => X_PANEL_MEMBER_TYPE,
    x_confirmed_dt => X_CONFIRMED_DT,
    x_declined_dt => X_DECLINED_DT,
    x_anonymity_ind => NVL(X_ANONYMITY_IND, 'N'),
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_paid_dt => X_PAID_DT,
    x_tracking_id => X_TRACKING_ID,
    x_recommendation_summary => X_RECOMMENDATION_SUMMARY,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_RE_THS_PNL_MBR (
    CA_PERSON_ID,
    CA_SEQUENCE_NUMBER,
    THE_SEQUENCE_NUMBER,
    CREATION_DT,
    PERSON_ID,
    PANEL_MEMBER_TYPE,
    CONFIRMED_DT,
    DECLINED_DT,
    ANONYMITY_IND,
    THESIS_RESULT_CD,
    PAID_DT,
    TRACKING_ID,
    RECOMMENDATION_SUMMARY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CA_PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.THE_SEQUENCE_NUMBER,
    NEW_REFERENCES.CREATION_DT,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.PANEL_MEMBER_TYPE,
    NEW_REFERENCES.CONFIRMED_DT,
    NEW_REFERENCES.DECLINED_DT,
    NEW_REFERENCES.ANONYMITY_IND,
    NEW_REFERENCES.THESIS_RESULT_CD,
    NEW_REFERENCES.PAID_DT,
    NEW_REFERENCES.TRACKING_ID,
    NEW_REFERENCES.RECOMMENDATION_SUMMARY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


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


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2
) as
  cursor c1 is select
      PANEL_MEMBER_TYPE,
      CONFIRMED_DT,
      DECLINED_DT,
      ANONYMITY_IND,
      THESIS_RESULT_CD,
      PAID_DT,
      TRACKING_ID,
      RECOMMENDATION_SUMMARY
    from IGS_RE_THS_PNL_MBR
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.PANEL_MEMBER_TYPE = X_PANEL_MEMBER_TYPE)
      AND ((tlinfo.CONFIRMED_DT = X_CONFIRMED_DT)
           OR ((tlinfo.CONFIRMED_DT is null)
               AND (X_CONFIRMED_DT is null)))
      AND ((tlinfo.DECLINED_DT = X_DECLINED_DT)
           OR ((tlinfo.DECLINED_DT is null)
               AND (X_DECLINED_DT is null)))
      AND (tlinfo.ANONYMITY_IND = X_ANONYMITY_IND)
      AND ((tlinfo.THESIS_RESULT_CD = X_THESIS_RESULT_CD)
           OR ((tlinfo.THESIS_RESULT_CD is null)
               AND (X_THESIS_RESULT_CD is null)))
      AND ((tlinfo.PAID_DT = X_PAID_DT)
           OR ((tlinfo.PAID_DT is null)
               AND (X_PAID_DT is null)))
      AND ((tlinfo.TRACKING_ID = X_TRACKING_ID)
           OR ((tlinfo.TRACKING_ID is null)
               AND (X_TRACKING_ID is null)))
      AND ((tlinfo.RECOMMENDATION_SUMMARY = X_RECOMMENDATION_SUMMARY)
           OR ((tlinfo.RECOMMENDATION_SUMMARY is null)
               AND (X_RECOMMENDATION_SUMMARY is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_ca_person_id => X_CA_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_the_sequence_number => X_THE_SEQUENCE_NUMBER,
    x_creation_dt => X_CREATION_DT,
    x_person_id => X_PERSON_ID,
    x_panel_member_type => X_PANEL_MEMBER_TYPE,
    x_confirmed_dt => X_CONFIRMED_DT,
    x_declined_dt => X_DECLINED_DT,
    x_anonymity_ind => X_ANONYMITY_IND,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_paid_dt => X_PAID_DT,
    x_tracking_id => X_TRACKING_ID,
    x_recommendation_summary => X_RECOMMENDATION_SUMMARY,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_RE_THS_PNL_MBR set
    PANEL_MEMBER_TYPE = NEW_REFERENCES.PANEL_MEMBER_TYPE,
    CONFIRMED_DT = NEW_REFERENCES.CONFIRMED_DT,
    DECLINED_DT = NEW_REFERENCES.DECLINED_DT,
    ANONYMITY_IND = NEW_REFERENCES.ANONYMITY_IND,
    THESIS_RESULT_CD = NEW_REFERENCES.THESIS_RESULT_CD,
    PAID_DT = NEW_REFERENCES.PAID_DT,
    TRACKING_ID = NEW_REFERENCES.TRACKING_ID,
    RECOMMENDATION_SUMMARY = NEW_REFERENCES.RECOMMENDATION_SUMMARY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


 After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_RE_THS_PNL_MBR
     where CA_PERSON_ID = X_CA_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and THE_SEQUENCE_NUMBER = X_THE_SEQUENCE_NUMBER
     and CREATION_DT = X_CREATION_DT
     and PERSON_ID = X_PERSON_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CA_PERSON_ID,
     X_CA_SEQUENCE_NUMBER,
     X_THE_SEQUENCE_NUMBER,
     X_CREATION_DT,
     X_PERSON_ID,
     X_PANEL_MEMBER_TYPE,
     X_CONFIRMED_DT,
     X_DECLINED_DT,
     X_ANONYMITY_IND,
     X_THESIS_RESULT_CD,
     X_PAID_DT,
     X_TRACKING_ID,
     X_RECOMMENDATION_SUMMARY,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CA_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_THE_SEQUENCE_NUMBER,
   X_CREATION_DT,
   X_PERSON_ID,
   X_PANEL_MEMBER_TYPE,
   X_CONFIRMED_DT,
   X_DECLINED_DT,
   X_ANONYMITY_IND,
   X_THESIS_RESULT_CD,
   X_PAID_DT,
   X_TRACKING_ID,
   X_RECOMMENDATION_SUMMARY,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
  ) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_RE_THS_PNL_MBR
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


 After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_RE_THS_PNL_MBR_PKG;

/
