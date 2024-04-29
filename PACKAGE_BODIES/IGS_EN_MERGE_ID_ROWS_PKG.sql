--------------------------------------------------------
--  DDL for Package Body IGS_EN_MERGE_ID_ROWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_MERGE_ID_ROWS_PKG" AS
/* $Header: IGSEI29B.pls 115.4 2002/11/28 23:38:55 nsidana ship $ */

l_rowid VARCHAR2(25);
  old_references IGS_EN_MERGE_ID_ROWS%RowType;
  new_references IGS_EN_MERGE_ID_ROWS%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_smir_id IN NUMBER DEFAULT NULL,
    x_table_alias IN VARCHAR2 DEFAULT NULL,
    x_obsolete_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_obsolete_id_rowid IN ROWID DEFAULT NULL,
    x_obsolete_update_on IN DATE DEFAULT NULL,
    x_current_person_id IN NUMBER DEFAULT NULL,
    x_current_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_current_id_rowid IN ROWID DEFAULT NULL,
    x_current_update_on IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_MERGE_ID_ROWS
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
    new_references.smir_id := x_smir_id;
    new_references.table_alias := x_table_alias;
    new_references.obsolete_person_id := x_obsolete_person_id;
    new_references.obsolete_id_row_info := x_obsolete_id_row_info;
    new_references.obsolete_id_rowid := x_obsolete_id_rowid;
    new_references.obsolete_update_on := x_obsolete_update_on;
    new_references.current_person_id := x_current_person_id;
    new_references.current_id_row_info := x_current_id_row_info;
    new_references.current_id_rowid := x_current_id_rowid;
    new_references.current_update_on := x_current_update_on;
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
   )AS
begin
	IF column_name is null then
     		NULL;
         ELSIF upper(column_name) = 'TABLE_ALIAS' THEN
              new_references.table_alias := column_value;
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

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.current_person_id = new_references.current_person_id)) OR
        ((new_references.current_person_id IS NULL))) THEN
      NULL;
    ELSE
       IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.current_person_id
        ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.obsolete_person_id = new_references.obsolete_person_id)) OR
        ((new_references.obsolete_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.obsolete_person_id
        ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_EN_MRG_ID_ACT_CH_PKG.GET_FK_IGS_EN_MERGE_ID_ROWS (
      old_references.smir_id
      );

  END Check_Child_Existance;

 FUNCTION Get_PK_For_Validation (
    x_smir_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_MERGE_ID_ROWS
      WHERE    smir_id = x_smir_id
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

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_MERGE_ID_ROWS
      WHERE    current_person_id = x_person_id
         OR    obsolete_person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SMIR_PE_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_smir_id IN NUMBER DEFAULT NULL,
    x_table_alias IN VARCHAR2 DEFAULT NULL,
    x_obsolete_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_obsolete_id_rowid IN VARCHAR2 DEFAULT NULL,
    x_obsolete_update_on IN DATE DEFAULT NULL,
    x_current_person_id IN NUMBER DEFAULT NULL,
    x_current_id_row_info IN VARCHAR2 DEFAULT NULL,
    x_current_id_rowid IN VARCHAR2 DEFAULT NULL,
    x_current_update_on IN DATE DEFAULT NULL,
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
      x_smir_id,
      x_table_alias,
      x_obsolete_person_id,
      x_obsolete_id_row_info,
      CHARTOROWID(x_obsolete_id_rowid),
      x_obsolete_update_on,
      x_current_person_id,
      x_current_id_row_info,
      CHARTOROWID(x_current_id_rowid),
      x_current_update_on,
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
 	   new_references.smir_id
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
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
      Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') then
	IF Get_PK_For_Validation (
 	   new_references.smir_id
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 Check_constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
	Check_Child_Existance;
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
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_OBSOLETE_ID_ROWID in VARCHAR2,
  X_OBSOLETE_UPDATE_ON in DATE,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_ID_ROWID in VARCHAR2,
  X_CURRENT_UPDATE_ON in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_MERGE_ID_ROWS
      where SMIR_ID = X_SMIR_ID;
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
    x_rowid => X_ROWID,
    x_smir_id => X_SMIR_ID,
    x_table_alias =>  X_TABLE_ALIAS,
    x_obsolete_person_id =>  X_OBSOLETE_PERSON_ID,
    x_obsolete_id_row_info =>  X_OBSOLETE_ID_ROW_INFO,
    x_obsolete_id_rowid =>  chartorowid(X_OBSOLETE_ID_ROWID),
    x_obsolete_update_on =>  X_OBSOLETE_UPDATE_ON,
    x_current_person_id =>  X_CURRENT_PERSON_ID,
    x_current_id_row_info =>  X_CURRENT_ID_ROW_INFO,
    x_current_id_rowid =>  chartorowid(X_CURRENT_ID_ROWID),
    x_current_update_on =>  X_CURRENT_UPDATE_ON,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_MERGE_ID_ROWS (
    SMIR_ID,
    TABLE_ALIAS,
    OBSOLETE_PERSON_ID,
    OBSOLETE_ID_ROW_INFO,
    OBSOLETE_ID_ROWID,
    OBSOLETE_UPDATE_ON,
    CURRENT_PERSON_ID,
    CURRENT_ID_ROW_INFO,
    CURRENT_ID_ROWID,
    CURRENT_UPDATE_ON,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SMIR_ID,
    NEW_REFERENCES.TABLE_ALIAS,
    NEW_REFERENCES.OBSOLETE_PERSON_ID,
    NEW_REFERENCES.OBSOLETE_ID_ROW_INFO,
    NEW_REFERENCES.OBSOLETE_ID_ROWID,
    NEW_REFERENCES.OBSOLETE_UPDATE_ON,
    NEW_REFERENCES.CURRENT_PERSON_ID,
    NEW_REFERENCES.CURRENT_ID_ROW_INFO,
    NEW_REFERENCES.CURRENT_ID_ROWID,
    NEW_REFERENCES.CURRENT_UPDATE_ON,
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
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_OBSOLETE_ID_ROWID in VARCHAR2,
  X_OBSOLETE_UPDATE_ON in DATE,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_ID_ROWID in VARCHAR2,
  X_CURRENT_UPDATE_ON in DATE
) AS
  cursor c1 is select
      TABLE_ALIAS,
      OBSOLETE_PERSON_ID,
      OBSOLETE_ID_ROW_INFO,
      OBSOLETE_ID_ROWID,
      OBSOLETE_UPDATE_ON,
      CURRENT_PERSON_ID,
      CURRENT_ID_ROW_INFO,
      CURRENT_ID_ROWID,
      CURRENT_UPDATE_ON
    from IGS_EN_MERGE_ID_ROWS
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

  if ( (tlinfo.TABLE_ALIAS = X_TABLE_ALIAS)
      AND (tlinfo.OBSOLETE_PERSON_ID = X_OBSOLETE_PERSON_ID)
      AND ((tlinfo.OBSOLETE_ID_ROW_INFO = X_OBSOLETE_ID_ROW_INFO)
           OR ((tlinfo.OBSOLETE_ID_ROW_INFO is null)
               AND (X_OBSOLETE_ID_ROW_INFO is null)))
      AND ((tlinfo.OBSOLETE_ID_ROWID = X_OBSOLETE_ID_ROWID)
           OR ((tlinfo.OBSOLETE_ID_ROWID is null)
               AND (X_OBSOLETE_ID_ROWID is null)))
      AND ((tlinfo.OBSOLETE_UPDATE_ON = X_OBSOLETE_UPDATE_ON)
           OR ((tlinfo.OBSOLETE_UPDATE_ON is null)
               AND (X_OBSOLETE_UPDATE_ON is null)))
      AND (tlinfo.CURRENT_PERSON_ID = X_CURRENT_PERSON_ID)
      AND ((tlinfo.CURRENT_ID_ROW_INFO = X_CURRENT_ID_ROW_INFO)
           OR ((tlinfo.CURRENT_ID_ROW_INFO is null)
               AND (X_CURRENT_ID_ROW_INFO is null)))
      AND ((tlinfo.CURRENT_ID_ROWID = X_CURRENT_ID_ROWID)
           OR ((tlinfo.CURRENT_ID_ROWID is null)
               AND (X_CURRENT_ID_ROWID is null)))
      AND ((tlinfo.CURRENT_UPDATE_ON = X_CURRENT_UPDATE_ON)
           OR ((tlinfo.CURRENT_UPDATE_ON is null)
               AND (X_CURRENT_UPDATE_ON is null)))
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
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_OBSOLETE_ID_ROWID in VARCHAR2,
  X_OBSOLETE_UPDATE_ON in DATE,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_ID_ROWID in VARCHAR2,
  X_CURRENT_UPDATE_ON in DATE,
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
  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_smir_id => X_SMIR_ID,
    x_table_alias =>  X_TABLE_ALIAS,
    x_obsolete_person_id =>  X_OBSOLETE_PERSON_ID,
    x_obsolete_id_row_info =>  X_OBSOLETE_ID_ROW_INFO,
    x_obsolete_id_rowid =>  CHARTOROWID(X_OBSOLETE_ID_ROWID),
    x_obsolete_update_on =>  X_OBSOLETE_UPDATE_ON,
    x_current_person_id =>  X_CURRENT_PERSON_ID,
    x_current_id_row_info =>  X_CURRENT_ID_ROW_INFO,
    x_current_id_rowid =>  CHARTOROWID(X_CURRENT_ID_ROWID),
    x_current_update_on =>  X_CURRENT_UPDATE_ON,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_MERGE_ID_ROWS set
    TABLE_ALIAS = NEW_REFERENCES.TABLE_ALIAS,
    OBSOLETE_PERSON_ID = NEW_REFERENCES.OBSOLETE_PERSON_ID,
    OBSOLETE_ID_ROW_INFO = NEW_REFERENCES.OBSOLETE_ID_ROW_INFO,
    OBSOLETE_ID_ROWID = NEW_REFERENCES.OBSOLETE_ID_ROWID,
    OBSOLETE_UPDATE_ON = NEW_REFERENCES.OBSOLETE_UPDATE_ON,
    CURRENT_PERSON_ID = NEW_REFERENCES.CURRENT_PERSON_ID,
    CURRENT_ID_ROW_INFO = NEW_REFERENCES.CURRENT_ID_ROW_INFO,
    CURRENT_ID_ROWID = NEW_REFERENCES.CURRENT_ID_ROWID,
    CURRENT_UPDATE_ON = NEW_REFERENCES.CURRENT_UPDATE_ON,
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
    x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_OBSOLETE_PERSON_ID in NUMBER,
  X_OBSOLETE_ID_ROW_INFO in VARCHAR2,
  X_OBSOLETE_ID_ROWID in VARCHAR2,
  X_OBSOLETE_UPDATE_ON in DATE,
  X_CURRENT_PERSON_ID in NUMBER,
  X_CURRENT_ID_ROW_INFO in VARCHAR2,
  X_CURRENT_ID_ROWID in VARCHAR2,
  X_CURRENT_UPDATE_ON in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_MERGE_ID_ROWS
     where SMIR_ID = X_SMIR_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SMIR_ID,
     X_TABLE_ALIAS,
     X_OBSOLETE_PERSON_ID,
     X_OBSOLETE_ID_ROW_INFO,
     X_OBSOLETE_ID_ROWID,
     X_OBSOLETE_UPDATE_ON,
     X_CURRENT_PERSON_ID,
     X_CURRENT_ID_ROW_INFO,
     X_CURRENT_ID_ROWID,
     X_CURRENT_UPDATE_ON,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SMIR_ID,
   X_TABLE_ALIAS,
   X_OBSOLETE_PERSON_ID,
   X_OBSOLETE_ID_ROW_INFO,
   X_OBSOLETE_ID_ROWID,
   X_OBSOLETE_UPDATE_ON,
   X_CURRENT_PERSON_ID,
   X_CURRENT_ID_ROW_INFO,
   X_CURRENT_ID_ROWID,
   X_CURRENT_UPDATE_ON,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
)AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_MERGE_ID_ROWS
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_EN_MERGE_ID_ROWS_PKG;

/
