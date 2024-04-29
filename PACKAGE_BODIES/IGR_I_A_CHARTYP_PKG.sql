--------------------------------------------------------
--  DDL for Package Body IGR_I_A_CHARTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_A_CHARTYP_PKG" as
/* $Header: IGSRH14B.pls 120.0 2005/06/01 20:48:18 appldev noship $ */


  l_rowid VARCHAR2(25);
  old_references IGR_I_A_CHARTYP%RowType;
  new_references IGR_I_A_CHARTYP%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_enquiry_characteristic_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_A_CHARTYP
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.enquiry_appl_number := x_enquiry_appl_number;
    new_references.ENQUIRY_CHARACTERISTIC_TYPE:= x_enquiry_characteristic_type;
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
  -- "OSS_TST".trg_eapect_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGR_I_A_CHARTYP
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
   CURSOR c_deceased(cp_party_id igs_pe_hz_parties.party_id%TYPE) IS
     SELECT deceased_ind
     FROM igs_pe_hz_parties
     WHERE party_id = cp_party_id;
   v_deceased_ind igs_pe_hz_parties.deceased_ind%TYPE;
   v_message_name  varchar2(30);
  BEGIN
    -- Fetch the Deceased Indicator
    OPEN c_deceased(new_references.person_id);
    FETCH c_deceased INTO v_deceased_ind;
    CLOSE c_deceased;
        -- Validate that the person is not deceased
    -- No insert, update, delete if a person is deceased
        IF v_deceased_ind = 'Y' THEN
           Fnd_Message.Set_Name('IGS', 'IGS_IN_DEC_NO_INQ');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
    END IF;

    -- Validate that inserts/updates are allowed
    IF  p_inserting OR p_updating THEN

        -- Validate enquiry characteristic type closed indicator
        IF IGR_VAL_ECT.admp_val_ect_closed(new_references.ENQUIRY_CHARACTERISTIC_TYPE,
                      v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
             IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
        END IF;
    END IF;


  END BeforeRowInsertUpdate1;


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.enquiry_appl_number = new_references.enquiry_appl_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.enquiry_appl_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGR_I_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.enquiry_appl_number
        ))THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENQ_APPL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.ENQUIRY_CHARACTERISTIC_TYPE= new_references.ENQUIRY_CHARACTERISTIC_TYPE)) OR
        ((new_references.ENQUIRY_CHARACTERISTIC_TYPE IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGR_I_E_CHARTYP_PKG.Get_PK_For_Validation (
        new_references.ENQUIRY_CHARACTERISTIC_TYPE,
        'N'
        ))THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENQ_CHR_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF    ;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name IN  VARCHAR2    DEFAULT NULL,
Column_Value    IN  VARCHAR2    DEFAULT NULL
    ) as
BEGIN
      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'ENQUIRY_CHARACTERISTIC_TYPE' then
         new_references.enquiry_characteristic_type:= column_value;
      END IF;
     IF upper(column_name) = 'ENQUIRY_CHARACTERISTIC_TYPE' OR
        column_name is null Then
        IF new_references.enquiry_characteristic_type <> UPPER(new_references.enquiry_characteristic_type) Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENQ_CHR_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
     END IF;

END Check_Constraints;


  FUNCTION   Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER,
    x_enquiry_characteristic_type IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_A_CHARTYP
      WHERE    person_id = x_person_id
      AND      enquiry_appl_number = x_enquiry_appl_number
      AND      ENQUIRY_CHARACTERISTIC_TYPE = x_enquiry_characteristic_type
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
    Close cur_rowid;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGR_I_APPL (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_A_CHARTYP
      WHERE    person_id = x_person_id
      AND      enquiry_appl_number = x_enquiry_appl_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAPECT_EAP_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGR_I_APPL;

  PROCEDURE IGR_I_E_CHARTYP (
    x_enquiry_characteristic_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_A_CHARTYP
      WHERE    ENQUIRY_CHARACTERISTIC_TYPE = x_enquiry_characteristic_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAPECT_ECT_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END IGR_I_E_CHARTYP;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_enquiry_characteristic_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_enquiry_appl_number,
      x_enquiry_characteristic_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
IF  Get_PK_For_Validation (
             new_references.person_id   ,
             new_references.enquiry_appl_number ,
             new_references.enquiry_characteristic_type

                         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
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
      BeforeRowInsertUpdate1(p_deleting=>TRUE);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.person_id   ,
             new_references.enquiry_appl_number ,
             new_references.enquiry_characteristic_type

                         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGR_I_A_CHARTYP
      where PERSON_ID = X_PERSON_ID
      and ENQUIRY_APPL_NUMBER = X_ENQUIRY_APPL_NUMBER
      and ENQUIRY_CHARACTERISTIC_TYPE = X_ENQUIRY_CHARACTERISTIC_TYPE;
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
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_enquiry_appl_number=>X_ENQUIRY_APPL_NUMBER,
  x_enquiry_characteristic_type=>X_ENQUIRY_CHARACTERISTIC_TYPE,
  x_person_id=>X_PERSON_ID,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGR_I_A_CHARTYP (
    PERSON_ID,
    ENQUIRY_APPL_NUMBER,
    ENQUIRY_CHARACTERISTIC_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ENQUIRY_APPL_NUMBER,
    NEW_REFERENCES.ENQUIRY_CHARACTERISTIC_TYPE,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2
) as
  cursor c1 is select ROWID
    from IGR_I_A_CHARTYP
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  return;
end LOCK_ROW;


procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

  delete from IGR_I_A_CHARTYP
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


end DELETE_ROW;

end IGR_I_A_CHARTYP_PKG;

/
