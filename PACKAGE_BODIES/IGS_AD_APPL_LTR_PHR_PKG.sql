--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_LTR_PHR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_LTR_PHR_PKG" as
/* $Header: IGSAI11B.pls 115.5 2002/11/28 21:55:37 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_APPL_LTR_PHR%RowType;
  new_references IGS_AD_APPL_LTR_PHR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_aal_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_phrase_cd IN VARCHAR2 DEFAULT NULL,
    x_phrase_order_number IN NUMBER DEFAULT NULL,
    x_letter_parameter_type IN VARCHAR2 DEFAULT NULL,
    x_phrase_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APPL_LTR_PHR
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.correspondence_type := x_correspondence_type;
    new_references.aal_sequence_number := x_aal_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.phrase_cd := x_phrase_cd;
    new_references.phrase_order_number := x_phrase_order_number;
    new_references.letter_parameter_type := x_letter_parameter_type;
    new_references.phrase_text := x_phrase_text;
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
  -- "OSS_TST".trg_aalp_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AD_APPL_LTR_PHR
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name			VARCHAR2(30);
	v_issue_dt	DATE;
  BEGIN
	-- Validate letter parameter type
	IF p_inserting OR
	(old_references.letter_parameter_type <> new_references.letter_parameter_type) THEN
		IF IGS_AD_VAL_AALP.corp_val_lpt_closed(new_references.letter_parameter_type,
						v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		IF IGS_AD_VAL_AALP.corp_val_lpt_phrase(new_references.letter_parameter_type,
						v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate letter phrase
	IF p_inserting OR
	(old_references.phrase_cd <> new_references.phrase_cd) THEN
		IF IGS_AD_VAL_AALP.corp_val_ltp_closed(new_references.phrase_cd,
						v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF new_references.phrase_cd IS NULL AND new_references.phrase_text IS NULL THEN
		--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(3153));
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_PHRASECD_TXT_ENTERED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	v_issue_dt := IGS_AD_GEN_002.ADMP_GET_AAL_SENT_DT(new_references.person_id,
					new_references.admission_appl_number,
					new_references.correspondence_type,
					new_references.aal_sequence_number);
	IF v_issue_dt IS NOT NULL THEN
		--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(3086));
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_CANNOT_ALTER_LETTER');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;


  END BeforeRowInsertUpdate1;



  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.aal_sequence_number = new_references.aal_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.correspondence_type IS NULL) OR
         (new_references.aal_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_LTR_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.correspondence_type,
        new_references.aal_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.letter_parameter_type = new_references.letter_parameter_type)) OR
        ((new_references.letter_parameter_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CO_LTR_PARM_TYPE_PKG.Get_PK_For_Validation (
        new_references.letter_parameter_type
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.phrase_cd = new_references.phrase_cd)) OR
        ((new_references.phrase_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CO_LTR_PHR_PKG.Get_PK_For_Validation (
        new_references.phrase_cd
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_aal_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    )
   RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR_PHR
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      correspondence_type = x_correspondence_type
      AND      aal_sequence_number = x_aal_sequence_number
      AND      sequence_number = x_sequence_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return TRUE;
    ELSE
      Close cur_rowid;
      Return FALSE;
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_AD_APPL_LTR (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR_PHR
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      correspondence_type = x_correspondence_type
      AND      aal_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AALP_AAL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_APPL_LTR;

  PROCEDURE GET_FK_IGS_CO_LTR_PARM_TYPE (
    x_letter_parameter_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR_PHR
      WHERE    letter_parameter_type = x_letter_parameter_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AALP_LPT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_LTR_PARM_TYPE;

  PROCEDURE GET_FK_IGS_CO_LTR_PHR (
    x_phrase_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR_PHR
      WHERE    phrase_cd = x_phrase_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AALP_LTP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_LTR_PHR;


  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'CORRESPONDENCE_TYPE' THEN
      new_references.correspondence_type := column_value;
     ELSIF upper(column_name) = 'LETTER_PARAMETER_TYPE' THEN
      new_references.letter_parameter_type := column_value;
     ELSIF upper(column_name) = 'PHRASE_CD' THEN
      new_references.phrase_cd := column_value;
     ELSIF upper(column_name) = 'SEQUENCE_NUMBER' THEN
      new_references.sequence_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'AAL_SEQUENCE_NUMBER' THEN
      new_references.aal_sequence_number := igs_ge_number.to_num(column_value);
     END IF;

     IF upper(column_name) = 'AAL_SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.aal_sequence_number < 1 OR new_references.aal_sequence_number > 999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.sequence_number < 1 OR new_references.sequence_number > 999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

     IF upper(column_name) = 'LETTER_PARAMETER_TYPE' OR column_name IS NULL THEN
      IF new_references.letter_parameter_type <> UPPER(new_references.letter_parameter_type) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'CORRESPONDENCE_TYPE' OR column_name IS NULL THEN
      IF new_references.correspondence_type <> UPPER(new_references.correspondence_type) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'PHRASE_CD' OR column_name IS NULL THEN
      IF new_references.phrase_cd <> UPPER(new_references.phrase_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
  END CHECK_CONSTRAINTS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_aal_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_phrase_cd IN VARCHAR2 DEFAULT NULL,
    x_phrase_order_number IN NUMBER DEFAULT NULL,
    x_letter_parameter_type IN VARCHAR2 DEFAULT NULL,
    x_phrase_text IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_admission_appl_number,
      x_correspondence_type,
      x_aal_sequence_number,
      x_sequence_number,
      x_phrase_cd,
      x_phrase_order_number,
      x_letter_parameter_type,
      x_phrase_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.correspondence_type,
        new_references.aal_sequence_number,
    	  new_references.sequence_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.correspondence_type,
        new_references.aal_sequence_number,
    	  new_references.sequence_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as

    cursor C is select ROWID from IGS_AD_APPL_LTR_PHR
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
      and CORRESPONDENCE_TYPE = X_CORRESPONDENCE_TYPE
      and AAL_SEQUENCE_NUMBER = X_AAL_SEQUENCE_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

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
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

Before_DML (
    p_action => 'INSERT',
    x_rowid  => X_ROWID,
    x_person_id=> X_PERSON_ID,
    x_admission_appl_number=> X_ADMISSION_APPL_NUMBER,
    x_correspondence_type =>X_CORRESPONDENCE_TYPE,
    x_aal_sequence_number =>X_AAL_SEQUENCE_NUMBER,
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_phrase_cd =>X_PHRASE_CD,
    x_phrase_order_number =>X_PHRASE_ORDER_NUMBER,
    x_letter_parameter_type =>X_LETTER_PARAMETER_TYPE,
    x_phrase_text =>X_PHRASE_TEXT,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_APPL_LTR_PHR (
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    CORRESPONDENCE_TYPE,
    AAL_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    PHRASE_CD,
    PHRASE_ORDER_NUMBER,
    LETTER_PARAMETER_TYPE,
    PHRASE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.CORRESPONDENCE_TYPE,
    NEW_REFERENCES.AAL_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.PHRASE_CD,
    NEW_REFERENCES.PHRASE_ORDER_NUMBER,
    NEW_REFERENCES.LETTER_PARAMETER_TYPE,
    NEW_REFERENCES.PHRASE_TEXT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
    x_rowid  => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2
) as
  cursor c1 is select
      PHRASE_CD,
      PHRASE_ORDER_NUMBER,
      LETTER_PARAMETER_TYPE,
      PHRASE_TEXT
    from IGS_AD_APPL_LTR_PHR
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

      if ( ((tlinfo.PHRASE_CD = X_PHRASE_CD)
           OR ((tlinfo.PHRASE_CD is null)
               AND (X_PHRASE_CD is null)))
      AND ((tlinfo.PHRASE_ORDER_NUMBER = X_PHRASE_ORDER_NUMBER)
           OR ((tlinfo.PHRASE_ORDER_NUMBER is null)
               AND (X_PHRASE_ORDER_NUMBER is null)))
      AND (tlinfo.LETTER_PARAMETER_TYPE = X_LETTER_PARAMETER_TYPE)
      AND ((tlinfo.PHRASE_TEXT = X_PHRASE_TEXT)
           OR ((tlinfo.PHRASE_TEXT is null)
               AND (X_PHRASE_TEXT is null)))
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
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2,
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
  elsif (X_MODE = 'R') then
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
    x_rowid  => X_ROWID,
    x_person_id=> X_PERSON_ID,
    x_admission_appl_number=> X_ADMISSION_APPL_NUMBER,
    x_correspondence_type =>X_CORRESPONDENCE_TYPE,
    x_aal_sequence_number =>X_AAL_SEQUENCE_NUMBER,
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_phrase_cd =>X_PHRASE_CD,
    x_phrase_order_number =>X_PHRASE_ORDER_NUMBER,
    x_letter_parameter_type =>X_LETTER_PARAMETER_TYPE,
    x_phrase_text =>X_PHRASE_TEXT,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );


  update IGS_AD_APPL_LTR_PHR set
    PHRASE_CD = NEW_REFERENCES.PHRASE_CD,
    PHRASE_ORDER_NUMBER = NEW_REFERENCES.PHRASE_ORDER_NUMBER,
    LETTER_PARAMETER_TYPE = NEW_REFERENCES.LETTER_PARAMETER_TYPE,
    PHRASE_TEXT = NEW_REFERENCES.PHRASE_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML (
    p_action => 'UPDATE',
    x_rowid  => X_ROWID
 );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AD_APPL_LTR_PHR
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
     and CORRESPONDENCE_TYPE = X_CORRESPONDENCE_TYPE
     and AAL_SEQUENCE_NUMBER = X_AAL_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ADMISSION_APPL_NUMBER,
     X_CORRESPONDENCE_TYPE,
     X_AAL_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_PHRASE_CD,
     X_PHRASE_ORDER_NUMBER,
     X_LETTER_PARAMETER_TYPE,
     X_PHRASE_TEXT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_CORRESPONDENCE_TYPE,
   X_AAL_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_PHRASE_CD,
   X_PHRASE_ORDER_NUMBER,
   X_LETTER_PARAMETER_TYPE,
   X_PHRASE_TEXT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
);
  delete from IGS_AD_APPL_LTR_PHR
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
);
end delete_row;

end IGS_AD_APPL_LTR_PHR_PKG;

/
