--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERS_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERS_NOTE_PKG" AS
  /* $Header: IGSNI27B.pls 120.1 2005/06/28 06:09:32 appldev ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PE_PERS_NOTE%RowType;
  new_references IGS_PE_PERS_NOTE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2, -- DEFAULT NULL,
    x_person_id IN NUMBER, -- DEFAULT NULL,
    x_reference_number IN NUMBER, -- DEFAULT NULL,
    x_pe_note_type IN VARCHAR2,-- DEFAULT NULL,
    X_START_DATE IN DATE,
    X_END_DATE IN DATE,
    x_creation_date IN DATE, -- DEFAULT NULL,
    x_created_by IN NUMBER, -- DEFAULT NULL,
    x_last_update_date IN DATE, -- DEFAULT NULL,
    x_last_updated_by IN NUMBER, -- DEFAULT NULL,
    x_last_update_login IN NUMBER -- DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERS_NOTE
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
    new_references.reference_number := x_reference_number;
    new_references.pe_note_type := x_pe_note_type;
    new_references.start_date := X_START_DATE;
    new_references.end_date := X_END_DATE;
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


   PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) =  'PE_NOTE_TYPE' then
     new_references.pe_note_type:= column_value;
 END IF;

IF upper(column_name) = 'PE_NOTE_TYPE' OR
     column_name is null Then
     IF  new_references.pe_note_type <>UPPER(new_references.pe_note_type)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

 END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.reference_number = new_references.reference_number)) OR
        ((new_references.reference_number IS NULL))) THEN
      NULL;
    ELSE
        IF  NOT IGS_GE_NOTE_PKG.Get_PK_For_Validation (
         new_references.reference_number ) THEN
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
         new_references.person_id ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;

    END IF;

    IF (((old_references.pe_note_type = new_references.pe_note_type)) OR
        ((new_references.pe_note_type IS NULL))) THEN
      NULL;
    ELSE


        -- kumma 2608360, replace the IGS_PE_NOTE_TYPE_PKG.Get_PK_For_Validation with the following
        IF NOT IGS_LOOKUPS_view_Pkg.Get_PK_For_Validation (
	  'PE_NOTE_TYPE',
        new_references.pe_note_type
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
		     App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_reference_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_NOTE
      WHERE    person_id = x_person_id
      AND      reference_number = x_reference_number
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

  PROCEDURE GET_FK_IGS_GE_NOTE (
    x_reference_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_NOTE
      WHERE    reference_number = x_reference_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PN_NOTE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_NOTE;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_NOTE
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PN_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_PE_NOTE_TYPE (
    x_pe_note_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_NOTE
      WHERE    pe_note_type = x_pe_note_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PN_PNT_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_NOTE_TYPE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_person_id IN NUMBER,
    x_reference_number IN NUMBER,
    x_pe_note_type IN VARCHAR2,
    X_START_DATE IN DATE,
    X_END_DATE IN DATE,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER

  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_reference_number,
      x_pe_note_type,
      X_START_DATE,
      X_END_DATE,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.

      IF  Get_PK_For_Validation (
          new_references.person_id,
          new_references.reference_number )THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
                   NULL;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
            new_references.person_id,
          new_references.reference_number ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints; -- if procedure present
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
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_PE_NOTE_TYPE in VARCHAR2,
  X_START_DATE IN DATE,
  X_END_DATE IN DATE,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_PE_PERS_NOTE
      where PERSON_ID = X_PERSON_ID
      and REFERENCE_NUMBER = X_REFERENCE_NUMBER;
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

    Before_DML(
     p_action=>'INSERT',
     x_rowid=>X_ROWID,
     x_pe_note_type=>X_PE_NOTE_TYPE,
     x_person_id=>X_PERSON_ID,
     x_start_date => X_START_DATE,
     x_end_date => X_END_DATE,
     x_reference_number=>X_REFERENCE_NUMBER,
     x_creation_date=>X_LAST_UPDATE_DATE,
     x_created_by=>X_LAST_UPDATED_BY,
     x_last_update_date=>X_LAST_UPDATE_DATE,
     x_last_updated_by=>X_LAST_UPDATED_BY,
     x_last_update_login=>X_LAST_UPDATE_LOGIN
     );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_PERS_NOTE (
    PERSON_ID,
    REFERENCE_NUMBER,
    PE_NOTE_TYPE,
    START_DATE,
    END_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.REFERENCE_NUMBER,
    NEW_REFERENCES.PE_NOTE_TYPE,
    NEW_REFERENCES.START_DATE,
    NEW_REFERENCES.END_DATE,
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

 After_DML(
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
  X_PERSON_ID in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_PE_NOTE_TYPE in VARCHAR2,
  X_START_DATE IN DATE,
  X_END_DATE IN DATE
) AS
  cursor c1 is select
      PE_NOTE_TYPE,
      START_DATE,
      END_DATE
    from IGS_PE_PERS_NOTE
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.PE_NOTE_TYPE = X_PE_NOTE_TYPE)
      AND ((tlinfo.start_date = X_START_DATE) OR ((tlinfo.start_date IS NULL) AND (X_START_DATE IS NULL)))
      AND ((tlinfo.end_date = X_END_DATE) OR ((tlinfo.end_date IS NULL) AND (X_END_DATE IS NULL)))
    ) then
    NULL;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_PE_NOTE_TYPE in VARCHAR2,
  X_START_DATE IN DATE,
  X_END_DATE IN DATE,
  X_MODE in VARCHAR2
  ) AS
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

    Before_DML(
     p_action=>'UPDATE',
     x_rowid=>X_ROWID,
     x_pe_note_type=>X_PE_NOTE_TYPE,
     x_start_date => X_START_DATE,
     x_end_date => X_END_DATE,
     x_person_id=>X_PERSON_ID,
     x_reference_number=>X_REFERENCE_NUMBER,
     x_creation_date=>X_LAST_UPDATE_DATE,
     x_created_by=>X_LAST_UPDATED_BY,
     x_last_update_date=>X_LAST_UPDATE_DATE,
     x_last_updated_by=>X_LAST_UPDATED_BY,
     x_last_update_login=>X_LAST_UPDATE_LOGIN
     );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_PERS_NOTE set
    PE_NOTE_TYPE = NEW_REFERENCES.PE_NOTE_TYPE,
    START_DATE = NEW_REFERENCES.START_DATE,
    END_DATE = NEW_REFERENCES.END_DATE,
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


 After_DML(
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
  X_PERSON_ID in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_PE_NOTE_TYPE in VARCHAR2,
  X_START_DATE IN DATE,
  X_END_DATE IN DATE,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_PE_PERS_NOTE
     where PERSON_ID = X_PERSON_ID
     and REFERENCE_NUMBER = X_REFERENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_REFERENCE_NUMBER,
     X_PE_NOTE_TYPE,
     X_START_DATE ,
     X_END_DATE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_REFERENCE_NUMBER,
   X_PE_NOTE_TYPE,
   X_START_DATE ,
   X_END_DATE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin

 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PE_PERS_NOTE
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


 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PE_PERS_NOTE_PKG;

/
