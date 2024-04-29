--------------------------------------------------------
--  DDL for Package Body IGS_PE_PRSID_GRP_SEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PRSID_GRP_SEC_PKG" AS
  /* $Header: IGSNI23B.pls 115.5 2003/02/18 08:48:02 npalanis ship $ */



  l_rowid VARCHAR2(25);
  old_references IGS_PE_PRSID_GRP_SEC%RowType;
  new_references IGS_PE_PRSID_GRP_SEC%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_group_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_insert_ind IN VARCHAR2 DEFAULT NULL,
    x_update_ind IN VARCHAR2 DEFAULT NULL,
    x_delete_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PRSID_GRP_SEC
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
    new_references.group_id := x_group_id;
    new_references.person_id := x_person_id;
    new_references.insert_ind := x_insert_ind;
    new_references.update_ind := x_update_ind;
    new_references.delete_ind := x_delete_ind;
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
	v_message_name  varchar2(30);
  BEGIN
	-- Validate the insert or update
	IF p_inserting OR p_updating THEN
		IF IGS_PE_VAL_PIGS.idgp_val_pigs_iud (
				new_references.group_id,
				new_references.person_id,
				v_message_name ) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the delete
	IF p_deleting THEN
		IF IGS_PE_VAL_PIGS.idgp_val_pigs_iud (
				old_references.group_id,
				old_references.person_id,
				v_message_name ) = FALSE THEN
                                  Fnd_Message.Set_Name('IGS', v_message_name);
                                  IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
         	END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE BeforeInsertUpdate(p_inserting BOOLEAN , p_updating BOOLEAN) AS
  p_message_name VARCHAR2(30);
  BEGIN
   IF ( p_inserting = TRUE OR (p_updating = TRUE AND new_references.group_id <> old_references.group_id ) ) THEN
    IF  NOT IGS_PE_PERSID_GROUP_PKG.val_persid_group(new_references.group_id,p_message_name) THEN
        Fnd_Message.Set_Name('IGS', p_message_name);
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
   END IF;
  END BeforeInsertUpdate;

   PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) =  'INSERT_IND' then
     new_references.insert_ind:= column_value;
 ELSIF upper(Column_name) = 'UPDATE_IND' then
     new_references.update_ind:= column_value;
 ELSIF upper(Column_name) = 'DELETE_IND' then
     new_references.delete_ind:= column_value;
 ELSIF upper(Column_name) = 'GROUP_ID' then
     new_references.group_id := IGS_GE_NUMBER.to_num(column_value);


END IF;

IF upper(column_name) = 'INSERT_IND' OR
     column_name is null Then
     IF   new_references.insert_ind NOT IN ( 'Y' , 'N' ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

IF upper(column_name) = 'UPDATE_IND' OR
     column_name is null Then
     IF new_references.update_ind NOT IN ( 'Y' , 'N' ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 IF upper(column_name) = 'DELETE_IND' OR
     column_name is null Then
     IF  new_references.delete_ind  NOT IN ( 'Y' , 'N' )   Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'GROUP_ID' OR
     column_name is null Then
     IF    new_references.group_id < 1 OR new_references.group_id  > 999999 Then
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
      IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.person_id  ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.group_id = new_references.group_id)) OR
        ((new_references.group_id IS NULL))) THEN
      NULL;
    ELSE

      IF  NOT IGS_PE_PERSID_GROUP_PKG.Get_PK_For_Validation (
         new_references.group_id ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_group_id IN NUMBER,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PRSID_GRP_SEC
      WHERE    group_id = x_group_id
      AND      person_id = x_person_id
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

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PRSID_GRP_SEC
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PIGS_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_group_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_insert_ind IN VARCHAR2 DEFAULT NULL,
    x_update_ind IN VARCHAR2 DEFAULT NULL,
    x_delete_ind IN VARCHAR2 DEFAULT NULL,
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
      x_group_id,
      x_person_id,
      x_insert_ind,
      x_update_ind,
      x_delete_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeInsertUpdate(TRUE,FALSE);
     BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
          new_references.group_id ,
             new_references.person_id) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeInsertUpdate(FALSE,TRUE);
       BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
       NULL;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
           new_references.group_id ,
             new_references.person_id) THEN
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
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PE_PRSID_GRP_SEC
      where GROUP_ID = X_GROUP_ID
      and PERSON_ID = X_PERSON_ID;
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
  Before_DML(
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_delete_ind=>  NVL(X_DELETE_IND,'N'),
   x_group_id=>X_GROUP_ID,
   x_insert_ind=> NVL(X_INSERT_IND,'N'),
   x_person_id=>X_PERSON_ID,
   x_update_ind=> NVL(X_UPDATE_IND,'N'),
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  insert into IGS_PE_PRSID_GRP_SEC (
    GROUP_ID,
    PERSON_ID,
    INSERT_IND,
    UPDATE_IND,
    DELETE_IND,
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
    NEW_REFERENCES.GROUP_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.INSERT_IND,
    NEW_REFERENCES.UPDATE_IND,
    NEW_REFERENCES.DELETE_IND,
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

 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2
) AS
  cursor c1 is select
      INSERT_IND,
      UPDATE_IND,
      DELETE_IND
    from IGS_PE_PRSID_GRP_SEC
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

  if ( (tlinfo.INSERT_IND = X_INSERT_IND)
      AND (tlinfo.UPDATE_IND = X_UPDATE_IND)
      AND (tlinfo.DELETE_IND = X_DELETE_IND)
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
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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

  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_delete_ind=>X_DELETE_IND,
   x_group_id=>X_GROUP_ID,
   x_insert_ind=>X_INSERT_IND,
   x_person_id=>X_PERSON_ID,
   x_update_ind=>X_UPDATE_IND,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

   if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;
  update IGS_PE_PRSID_GRP_SEC set
    INSERT_IND = NEW_REFERENCES.INSERT_IND,
    UPDATE_IND = NEW_REFERENCES.UPDATE_IND,
    DELETE_IND = NEW_REFERENCES.DELETE_IND,
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
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PE_PRSID_GRP_SEC
     where GROUP_ID = X_GROUP_ID
     and PERSON_ID = X_PERSON_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GROUP_ID,
     X_PERSON_ID,
     X_INSERT_IND,
     X_UPDATE_IND,
     X_DELETE_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GROUP_ID,
   X_PERSON_ID,
   X_INSERT_IND,
   X_UPDATE_IND,
   X_DELETE_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_PE_PRSID_GRP_SEC
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PE_PRSID_GRP_SEC_PKG;

/
