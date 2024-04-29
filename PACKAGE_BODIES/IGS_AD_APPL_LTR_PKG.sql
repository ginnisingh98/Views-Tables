--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_LTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_LTR_PKG" as
/* $Header: IGSAI06B.pls 115.4 2002/11/28 21:54:11 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_APPL_LTR%RowType;
  new_references IGS_AD_APPL_LTR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_composed_ind IN VARCHAR2 DEFAULT NULL,
    x_letter_reference_number IN NUMBER DEFAULT NULL,
    x_spl_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APPL_LTR
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
    new_references.sequence_number := x_sequence_number;
    new_references.composed_ind := x_composed_ind;
    new_references.letter_reference_number := x_letter_reference_number;
    new_references.spl_sequence_number := x_spl_sequence_number;
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
  -- "OSS_TST".trg_aal_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AD_APPL_LTR
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
	v_admission_cat			IGS_AD_APPL.admission_cat%TYPE;
	v_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE;
	v_acad_cal_type			IGS_AD_APPL.acad_cal_type%TYPE;
	v_acad_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE;
	v_adm_cal_type			IGS_AD_APPL.adm_cal_type%TYPE;
	v_adm_ci_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE;
	v_appl_dt				IGS_AD_APPL.appl_dt%TYPE;
	v_adm_appl_status		IGS_AD_APPL.adm_appl_status%TYPE;
	v_adm_fee_status			IGS_AD_APPL.adm_fee_status%TYPE;
	v_message_name			VARCHAR2(30);
	v_issue_dt			DATE;
  BEGIN
	-- Validate correspondence type
	IF p_inserting THEN
		IF IGS_AD_VAL_AAL.corp_val_cort_closed(new_references.correspondence_type,
						v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		IF IGS_AD_VAL_AAL.admp_val_aal_exists(new_references.person_id,
						new_references.admission_appl_number,
						new_references.correspondence_type,
						v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                 IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		IGS_AD_GEN_002.ADMP_GET_AA_DTL(new_references.person_id,
				new_references.admission_appl_number,
				v_admission_cat,
				v_s_admission_process_type,
				v_acad_cal_type,
				v_acad_ci_sequence_number,
				v_adm_cal_type,
				v_adm_ci_sequence_number,
				v_appl_dt	,
				v_adm_appl_status,
				v_adm_fee_status);
		IF IGS_AD_VAL_AAL.admp_val_aal_cort(new_references.correspondence_type,
						v_admission_cat,
						v_s_admission_process_type,
						v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF ( new_references.composed_ind <> old_references.composed_ind) AND
	      new_references.spl_sequence_number IS NOT NULL THEN
		--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(3086));
            FND_MESSAGE.SET_NAME('IGS','IGS_AD_CANNOT_ALTER_LETTER');
            IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.correspondence_type = new_references.correspondence_type)) OR
        ((new_references.correspondence_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CO_TYPE_PKG.Get_PK_For_Validation (
        new_references.correspondence_type
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number) AND
         (old_references.spl_sequence_number = new_references.spl_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL) OR
         (new_references.spl_sequence_number IS NULL))) THEN
      NULL;
     ELSE
       IF NOT IGS_CO_S_PER_LTR_PKG.Get_PK_For_Validation(
         new_references.person_id,new_references.correspondence_type,new_references.letter_reference_number,
      new_references.spl_sequence_number )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

    END IF;


  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AD_APPL_LTR_PHR_PKG.GET_FK_IGS_AD_APPL_LTR (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.correspondence_type,
      old_references.sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    )
   RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      correspondence_type = x_correspondence_type
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

  PROCEDURE GET_FK_IGS_AD_APPL (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAL_AA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_APPL;

  PROCEDURE GET_FK_IGS_CO_TYPE (
    x_correspondence_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR
      WHERE    correspondence_type = x_correspondence_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAL_CORT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_TYPE;

  PROCEDURE GET_FK_IGS_CO_S_PER_LTR  (
    x_person_id IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_letter_reference_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_LTR
      WHERE    person_id = x_person_id
      AND      correspondence_type = x_correspondence_type
      AND      letter_reference_number = x_letter_reference_number
      AND      spl_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAL_SPL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_S_PER_LTR ;

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'COMPOSED_IND' THEN
      new_references.composed_ind := column_value;
     ELSIF upper(column_name) = 'CORRESPONDENCE_TYPE' THEN
      new_references.correspondence_type := column_value;
     ELSIF upper(column_name) = 'SPL_SEQUENCE_NUMBER' THEN
      new_references.spl_sequence_number := igs_ge_number.to_num(column_value);
     END IF;

     IF upper(column_name) = 'COMPOSED_IND' OR column_name IS NULL THEN
      IF new_references.composed_ind NOT IN ('Y','N')  THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'SPL_SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.spl_sequence_number < 1 OR new_references.spl_sequence_number > 9999999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

     IF upper(column_name) = 'COMPOSED_IND' OR column_name IS NULL THEN
      IF new_references.composed_ind <> UPPER(new_references.composed_ind) THEN
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
  END CHECK_CONSTRAINTS;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_composed_ind IN VARCHAR2 DEFAULT NULL,
    x_letter_reference_number IN NUMBER DEFAULT NULL,
    x_spl_sequence_number IN NUMBER DEFAULT NULL,
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
      x_sequence_number,
      x_composed_ind,
      x_letter_reference_number,
      x_spl_sequence_number,
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.correspondence_type,
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
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AD_APPL_LTR
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
      and CORRESPONDENCE_TYPE = X_CORRESPONDENCE_TYPE
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
    if (X_REQUEST_ID = -1) then
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

Before_DML (
    p_action => 'INSERT',
    x_rowid  => X_ROWID,
    x_person_id=> X_PERSON_ID,
    x_admission_appl_number=> X_ADMISSION_APPL_NUMBER,
    x_correspondence_type =>X_CORRESPONDENCE_TYPE,
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_composed_ind=> Nvl(X_COMPOSED_IND, 'Y'),
    x_letter_reference_number =>X_LETTER_REFERENCE_NUMBER,
    x_spl_sequence_number =>X_SPL_SEQUENCE_NUMBER,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_APPL_LTR (
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    CORRESPONDENCE_TYPE,
    SEQUENCE_NUMBER,
    COMPOSED_IND,
    LETTER_REFERENCE_NUMBER,
    SPL_SEQUENCE_NUMBER,
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
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.CORRESPONDENCE_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.COMPOSED_IND,
    NEW_REFERENCES.LETTER_REFERENCE_NUMBER,
    NEW_REFERENCES.SPL_SEQUENCE_NUMBER,
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
    x_rowid  => X_ROWID
);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER
) as
  cursor c1 is select
      COMPOSED_IND,
      LETTER_REFERENCE_NUMBER,
      SPL_SEQUENCE_NUMBER
    from IGS_AD_APPL_LTR
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

  if ( (tlinfo.COMPOSED_IND = X_COMPOSED_IND)
      AND ((tlinfo.LETTER_REFERENCE_NUMBER = X_LETTER_REFERENCE_NUMBER)
           OR ((tlinfo.LETTER_REFERENCE_NUMBER is null)
               AND (X_LETTER_REFERENCE_NUMBER is null)))
      AND ((tlinfo.SPL_SEQUENCE_NUMBER = X_SPL_SEQUENCE_NUMBER)
           OR ((tlinfo.SPL_SEQUENCE_NUMBER is null)
               AND (X_SPL_SEQUENCE_NUMBER is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_composed_ind=> X_COMPOSED_IND,
    x_letter_reference_number =>X_LETTER_REFERENCE_NUMBER,
    x_spl_sequence_number =>X_SPL_SEQUENCE_NUMBER,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );


  if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
   if (X_REQUEST_ID = -1) then
    X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
    X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
   else
    X_PROGRAM_UPDATE_DATE := SYSDATE;
   end if;
  end if;
  update IGS_AD_APPL_LTR set
    COMPOSED_IND = NEW_REFERENCES.COMPOSED_IND,
    LETTER_REFERENCE_NUMBER = NEW_REFERENCES.LETTER_REFERENCE_NUMBER,
    SPL_SEQUENCE_NUMBER = NEW_REFERENCES.SPL_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AD_APPL_LTR
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
     and CORRESPONDENCE_TYPE = X_CORRESPONDENCE_TYPE
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
     X_SEQUENCE_NUMBER,
     X_COMPOSED_IND,
     X_LETTER_REFERENCE_NUMBER,
     X_SPL_SEQUENCE_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_CORRESPONDENCE_TYPE,
   X_SEQUENCE_NUMBER,
   X_COMPOSED_IND,
   X_LETTER_REFERENCE_NUMBER,
   X_SPL_SEQUENCE_NUMBER,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
)as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );

  delete from IGS_AD_APPL_LTR
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );

end DELETE_ROW;

end IGS_AD_APPL_LTR_PKG;

/
