--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERS_RELATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERS_RELATION_PKG" AS
  /* $Header: IGSNI31B.pls 120.0 2005/06/01 20:57:59 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PE_PERS_RELATION%RowType;
  new_references IGS_PE_PERS_RELATION%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_person_id_also_related_to IN NUMBER DEFAULT NULL,
    x_person_relation_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERS_RELATION
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
    new_references.person_id_also_related_to := x_person_id_also_related_to;
    new_references.person_relation_type := x_person_relation_type;
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

 ELSIF upper(Column_name) = 'PERSON_RELATION_TYPE' then
     new_references.person_relation_type := column_value;

  END IF;
IF upper(column_name) = 'PERSON_RELATION_TYPE' OR
     column_name is null Then
     IF new_references.person_relation_type  <>UPPER(new_references.person_relation_type )Then
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

      IF  NOT  IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.person_id) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.person_id_also_related_to = new_references.person_id_also_related_to)) OR
        ((new_references.person_id_also_related_to IS NULL))) THEN
      NULL;
    ELSE
     IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.person_id_also_related_to ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.person_relation_type = new_references.person_relation_type)) OR
        ((new_references.person_relation_type IS NULL))) THEN
      NULL;
    ELSE

      IF  NOT IGS_PE_PERS_RELN_TYP_PKG.Get_PK_For_Validation (
         new_references.person_relation_type ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_person_id_also_related_to IN NUMBER,
    x_person_relation_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_RELATION
      WHERE    person_id = x_person_id
      AND      person_id_also_related_to = x_person_id_also_related_to
      AND      person_relation_type = x_person_relation_type
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
      FROM     IGS_PE_PERS_RELATION
      WHERE    person_id = x_person_id  OR
               person_id_also_related_to = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PR_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;



  PROCEDURE GET_FK_IGS_PE_PERS_RELN_TYP (
    x_person_relation_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_RELATION
      WHERE    person_relation_type = x_person_relation_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PR_PRT_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERS_RELN_TYP;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_person_id_also_related_to IN NUMBER DEFAULT NULL,
    x_person_relation_type IN VARCHAR2 DEFAULT NULL,
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
      x_person_id_also_related_to,
      x_person_relation_type,
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
            new_references.person_id_also_related_to ,
            new_references.person_relation_type
			) THEN
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
           new_references.person_id ,
            new_references.person_id_also_related_to ,
            new_references.person_relation_type ) THEN
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
  X_PERSON_ID_ALSO_RELATED_TO in NUMBER,
  X_PERSON_RELATION_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PE_PERS_RELATION
      where PERSON_ID = X_PERSON_ID
      and PERSON_ID_ALSO_RELATED_TO = X_PERSON_ID_ALSO_RELATED_TO
      and PERSON_RELATION_TYPE = X_PERSON_RELATION_TYPE;
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
  x_person_id=>X_PERSON_ID,
  x_person_id_also_related_to=>X_PERSON_ID_ALSO_RELATED_TO,
  x_person_relation_type=>X_PERSON_RELATION_TYPE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_PERS_RELATION (
    PERSON_ID,
    PERSON_ID_ALSO_RELATED_TO,
    PERSON_RELATION_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.PERSON_ID_ALSO_RELATED_TO,
    NEW_REFERENCES.PERSON_RELATION_TYPE,
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
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
  close c;

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
  X_PERSON_ID_ALSO_RELATED_TO in NUMBER,
  X_PERSON_RELATION_TYPE in VARCHAR2
) AS
  cursor c1 is select ROWID
    from IGS_PE_PERS_RELATION
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

   return;
end LOCK_ROW;


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
 delete from IGS_PE_PERS_RELATION
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

end IGS_PE_PERS_RELATION_PKG;

/
