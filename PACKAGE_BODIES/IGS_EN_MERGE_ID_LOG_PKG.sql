--------------------------------------------------------
--  DDL for Package Body IGS_EN_MERGE_ID_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_MERGE_ID_LOG_PKG" AS
/* $Header: IGSEI28B.pls 120.1 2005/09/08 15:27:58 appldev noship $ */

l_rowid VARCHAR2(25);
  old_references IGS_EN_MERGE_ID_LOG%RowType;
  new_references IGS_EN_MERGE_ID_LOG%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_SMIL_ID IN NUMBER DEFAULT NULL,
    x_obsolete_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_current_person_id IN NUMBER DEFAULT NULL,
    x_current_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_table_alias IN VARCHAR2 DEFAULT NULL,
    x_action_id IN NUMBER DEFAULT NULL,
    x_perform_action_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_MERGE_ID_LOG
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ( 'INSERT','VALIDATE_INSERT' )) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.SMIL_ID := x_SMIL_ID;
    new_references.obsolete_person_id := x_obsolete_person_id;
    new_references.obsolete_id_row_info := x_obsolete_id_row_info;
    new_references.current_person_id := x_current_person_id;
    new_references.current_id_row_info := x_current_id_row_info;
    new_references.table_alias := x_table_alias;
    new_references.action_id := x_action_id;
    new_references.perform_action_ind := x_perform_action_ind;
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

  procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
      		NULL;
         ELSIF upper(column_name) = 'PERFORM_ACTION_IND' THEN
              new_references.perform_action_ind := column_value;
          ELSIF upper(column_name) = 'TABLE_ALIAS' THEN
              new_references.table_alias := column_value;
	END IF;

IF upper(column_name) = 'PERFORM_ACTION_IND' OR
       Column_name is null THEN
       IF new_references.perform_action_ind NOT IN ('Y','N') THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'TABLE_ALIAS' OR
       Column_name is null THEN
       IF new_references.table_alias <>
                    upper(new_references.table_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;


END check_constraints;

  FUNCTION Get_PK_For_Validation (
    x_SMIL_ID IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_MERGE_ID_LOG
      WHERE    SMIL_ID = x_SMIL_ID
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;
  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.table_alias = new_references.table_alias) AND
         (old_references.action_id = new_references.action_id)) OR
        ((new_references.table_alias IS NULL) OR
         (new_references.action_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_MRG_ID_ACTION_PKG.Get_PK_For_Validation (
        new_references.table_alias,
        new_references.action_id
        )THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE GET_FK_IGS_EN_MRG_ID_ACTION (
    x_table_alias IN VARCHAR2,
    x_action_id IN NUMBER
    )AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_MERGE_ID_LOG
      WHERE    table_alias = x_table_alias
      AND      action_id = x_action_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SMIL_SMIA_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_MRG_ID_ACTION;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_SMIL_ID IN NUMBER DEFAULT NULL,
    x_obsolete_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_current_person_id IN NUMBER DEFAULT NULL,
    x_current_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_table_alias IN VARCHAR2 DEFAULT NULL,
    x_action_id IN NUMBER DEFAULT NULL,
    x_perform_action_ind IN VARCHAR2 DEFAULT NULL,
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
      x_SMIL_ID,
      x_obsolete_person_id,
      x_obsolete_id_row_info,
      x_current_person_id,
      x_current_id_row_info,
      x_table_alias,
      x_action_id,
      x_perform_action_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	IF Get_PK_For_Validation (
 	   new_references.SMIL_ID
    	) THEN
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
   ELSIF (p_action = 'VALIDATE_INSERT') then
	IF Get_PK_For_Validation (
 	   new_references.SMIL_ID
    	) THEN
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 Check_constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
	null;
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
  X_SMIL_ID in  out NOCOPY NUMBER,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_MERGE_ID_LOG
      where SMIL_ID = X_SMIL_ID;
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

      SELECT  IGS_EN_MERGE_ID_LOG_SMIL_ID_S.Nextval
      INTO    X_SMIL_ID
      FROM    DUAL;

 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_action_id=>X_ACTION_ID,
  x_current_id_row_info=>X_CURRENT_ID_ROW_INFO,
  x_current_person_id=>X_CURRENT_PERSON_ID,
  x_obsolete_id_row_info=>X_OBSOLETE_ID_ROW_INFO,
  x_obsolete_person_id=>X_OBSOLETE_PERSON_ID,
  x_perform_action_ind=>NVL(X_PERFORM_ACTION_IND,'N'),
  x_SMIL_ID=>X_SMIL_ID,
  x_table_alias=>X_TABLE_ALIAS,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_EN_MERGE_ID_LOG (
    OBSOLETE_PERSON_ID,
    OBSOLETE_ID_ROW_INFO,
    CURRENT_PERSON_ID,
    CURRENT_ID_ROW_INFO,
    TABLE_ALIAS,
    ACTION_ID,
    PERFORM_ACTION_IND,
    SMIL_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.OBSOLETE_PERSON_ID,
    NEW_REFERENCES.OBSOLETE_ID_ROW_INFO,
    NEW_REFERENCES.CURRENT_PERSON_ID,
    NEW_REFERENCES.CURRENT_ID_ROW_INFO,
    NEW_REFERENCES.TABLE_ALIAS,
    NEW_REFERENCES.ACTION_ID,
    NEW_REFERENCES.PERFORM_ACTION_IND,
    NEW_REFERENCES.SMIL_ID,
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

  After_DML(
    p_action => 'INSERT',
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_SMIL_ID in NUMBER,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2
) AS
  cursor c1 is select
      OBSOLETE_PERSON_ID,
      OBSOLETE_ID_ROW_INFO,
      CURRENT_PERSON_ID,
      CURRENT_ID_ROW_INFO,
      TABLE_ALIAS,
      ACTION_ID,
      PERFORM_ACTION_IND
    from IGS_EN_MERGE_ID_LOG
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.OBSOLETE_PERSON_ID = X_OBSOLETE_PERSON_ID)
      AND ((tlinfo.OBSOLETE_ID_ROW_INFO = X_OBSOLETE_ID_ROW_INFO)
           OR ((tlinfo.OBSOLETE_ID_ROW_INFO is null)
               AND (X_OBSOLETE_ID_ROW_INFO is null)))
      AND (tlinfo.CURRENT_PERSON_ID = X_CURRENT_PERSON_ID)
      AND ((tlinfo.CURRENT_ID_ROW_INFO = X_CURRENT_ID_ROW_INFO)
           OR ((tlinfo.CURRENT_ID_ROW_INFO is null)
               AND (X_CURRENT_ID_ROW_INFO is null)))
      AND (tlinfo.TABLE_ALIAS = X_TABLE_ALIAS)
      AND (tlinfo.ACTION_ID = X_ACTION_ID)
      AND (tlinfo.PERFORM_ACTION_IND = X_PERFORM_ACTION_IND)
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
  X_ROWID IN VARCHAR2,
  X_SMIL_ID in NUMBER,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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

 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_action_id=>X_ACTION_ID,
  x_current_id_row_info=>X_CURRENT_ID_ROW_INFO,
  x_current_person_id=>X_CURRENT_PERSON_ID,
  x_obsolete_id_row_info=>X_OBSOLETE_ID_ROW_INFO,
  x_obsolete_person_id=>X_OBSOLETE_PERSON_ID,
  x_perform_action_ind=>X_PERFORM_ACTION_IND,
  x_SMIL_ID=>X_SMIL_ID,
  x_table_alias=>X_TABLE_ALIAS,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_MERGE_ID_LOG set
    OBSOLETE_PERSON_ID = new_references.OBSOLETE_PERSON_ID,
    OBSOLETE_ID_ROW_INFO = new_references.OBSOLETE_ID_ROW_INFO,
    CURRENT_PERSON_ID = new_references.CURRENT_PERSON_ID,
    CURRENT_ID_ROW_INFO = new_references.CURRENT_ID_ROW_INFO,
    TABLE_ALIAS = new_references.TABLE_ALIAS,
    ACTION_ID = new_references.ACTION_ID,
    PERFORM_ACTION_IND = new_references.PERFORM_ACTION_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

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
  X_SMIL_ID in out NOCOPY NUMBER,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_MERGE_ID_LOG
     where SMIL_ID = X_SMIL_ID;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SMIL_ID,
     X_OBSOLETE_PERSON_ID,
     X_OBSOLETE_ID_ROW_INFO,
     X_CURRENT_PERSON_ID,
     X_CURRENT_ID_ROW_INFO,
     X_TABLE_ALIAS,
     X_ACTION_ID,
     X_PERFORM_ACTION_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SMIL_ID,
   X_OBSOLETE_PERSON_ID,
   X_OBSOLETE_ID_ROW_INFO,
   X_CURRENT_PERSON_ID,
   X_CURRENT_ID_ROW_INFO,
   X_TABLE_ALIAS,
   X_ACTION_ID,
   X_PERFORM_ACTION_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (X_ROWID IN VARCHAR2) AS
begin
Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_MERGE_ID_LOG
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_EN_MERGE_ID_LOG_PKG;

/
