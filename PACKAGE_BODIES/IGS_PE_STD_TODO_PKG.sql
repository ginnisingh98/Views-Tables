--------------------------------------------------------
--  DDL for Package Body IGS_PE_STD_TODO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_STD_TODO_PKG" AS
   /* $Header: IGSNI38B.pls 120.2 2006/01/25 09:21:18 skpandey ship $ */

  g_debug_level   CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_rowid VARCHAR2(25);
  old_references IGS_PE_STD_TODO%RowType;
  new_references IGS_PE_STD_TODO%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_s_student_todo_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_todo_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_STD_TODO
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN( 'INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.s_student_todo_type := x_s_student_todo_type;
    new_references.sequence_number := x_sequence_number;
    new_references.todo_dt := x_todo_dt;
    new_references.logical_delete_dt := x_logical_delete_dt;
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
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;

 ELSIF upper(Column_name) = 'S_STUDENT_TODO_TYPE' then
     new_references.s_student_todo_type:= column_value;
  END IF;
IF upper(column_name) = 'S_STUDENT_TODO_TYPE' OR
     column_name is null Then
     IF new_references.s_student_todo_type <>UPPER(new_references.s_student_todo_type)Then
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
         new_references.person_id ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;
    IF (((old_references.s_student_todo_type = new_references.s_student_todo_type)) OR
        ((new_references.s_student_todo_type IS NULL))) THEN
      NULL;
    ELSE

       IF  NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
        'STUDENT_TODO_TYPE',
        new_references.s_student_todo_type ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_PE_STD_TODO_REF_PKG.GET_FK_IGS_PE_STD_TODO (
      old_references.person_id,
      old_references.s_student_todo_type,
      old_references.sequence_number
      );
  END Check_Child_Existance;
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_s_student_todo_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_STD_TODO
      WHERE    person_id = x_person_id
      AND      s_student_todo_type = x_s_student_todo_type
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
  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_pe_std_todo_pkg.get_pk_for_validation :',SQLERRM);
      END IF;
      RAISE;
  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_STD_TODO
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_ST_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

--skpandey 24-JAN-2006     Bug#3686686: Stubbed as a part of query optimization
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_student_todo_type IN VARCHAR2
    ) AS
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_s_student_todo_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_todo_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
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
      x_s_student_todo_type,
      x_sequence_number,
      x_todo_dt,
      x_logical_delete_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.

      IF  Get_PK_For_Validation (
          new_references.person_id ,
          new_references.s_student_todo_type ,
         new_references.sequence_number ) THEN
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

       Check_Child_Existance; -- if procedure present
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.person_id ,
          new_references.s_student_todo_type ,
         new_references.sequence_number ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints; -- if procedure present

ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance; -- if procedure present
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
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TODO_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PE_STD_TODO
      where PERSON_ID = X_PERSON_ID
      and S_STUDENT_TODO_TYPE = X_S_STUDENT_TODO_TYPE
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
 Before_DML(
  p_action=>'INSERT',
  x_rowid=> X_ROWID,
  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
  x_person_id=>X_PERSON_ID,
  x_s_student_todo_type=>X_S_STUDENT_TODO_TYPE,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_todo_dt=>X_TODO_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_PE_STD_TODO (
    PERSON_ID,
    S_STUDENT_TODO_TYPE,
    SEQUENCE_NUMBER,
    TODO_DT,
    LOGICAL_DELETE_DT,
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
    NEW_REFERENCES.S_STUDENT_TODO_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.TODO_DT,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
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
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TODO_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      TODO_DT,
      LOGICAL_DELETE_DT
    from IGS_PE_STD_TODO
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
      if ( ((tlinfo.TODO_DT = X_TODO_DT)
           OR ((tlinfo.TODO_DT is null)
               AND (X_TODO_DT is null)))
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
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
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TODO_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
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
 x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
 x_person_id=>X_PERSON_ID,
 x_s_student_todo_type=>X_S_STUDENT_TODO_TYPE,
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_todo_dt=>X_TODO_DT,
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
  update IGS_PE_STD_TODO set
    TODO_DT = NEW_REFERENCES.TODO_DT,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
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
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TODO_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PE_STD_TODO
     where PERSON_ID = X_PERSON_ID
     and S_STUDENT_TODO_TYPE = X_S_STUDENT_TODO_TYPE
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
     X_S_STUDENT_TODO_TYPE,
     X_SEQUENCE_NUMBER,
     X_TODO_DT,
     X_LOGICAL_DELETE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_S_STUDENT_TODO_TYPE,
   X_SEQUENCE_NUMBER,
   X_TODO_DT,
   X_LOGICAL_DELETE_DT,
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
  delete from IGS_PE_STD_TODO
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;
end IGS_PE_STD_TODO_PKG;

/
