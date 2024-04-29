--------------------------------------------------------
--  DDL for Package Body IGS_EN_UNIT_SET_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_UNIT_SET_CAT_PKG" AS
/* $Header: IGSEI02B.pls 115.5 2003/03/25 08:42:08 nalkumar ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_UNIT_SET_CAT%RowType;
  new_references IGS_EN_UNIT_SET_CAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  )AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_UNIT_SET_CAT
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
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_set_cat := x_unit_set_cat;
    new_references.description := x_description;
    new_references.s_unit_set_cat := x_s_unit_set_cat;
    new_references.rank := x_rank;
    new_references.closed_ind := x_closed_ind;
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
 ) as

  BEGIN

  -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CAT' THEN
        new_references.unit_set_cat := column_value;
    ELSIF  UPPER(column_name) = 'S_UNIT_SET_CAT' THEN
        new_references.s_unit_set_cat := column_value;
    ELSIF  UPPER(column_name) = 'CLOSED_IND' THEN
        new_references.closed_ind := column_value;
    ELSIF  UPPER(column_name) = 'RANK' THEN
        new_references.rank := IGS_GE_NUMBER.TO_NUM(column_value);

    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_CAT') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_cat <> UPPER (new_references.unit_set_cat)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'S_UNIT_SET_CAT') OR (column_name IS NULL)) THEN
      IF (new_references.s_unit_set_cat IS NULL ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MANDATORY_FLD');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'CLOSED_IND') OR (column_name IS NULL)) THEN
      IF new_references.closed_ind  NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'RANK') OR (column_name IS NULL)) THEN
      IF new_references.rank < 0  OR
         new_references.rank > 999  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_EN_UNIT_SET_PKG.GET_FK_IGS_EN_UNIT_SET_CAT (
      old_references.unit_set_cat
      );
    igs_da_setup_pkg.get_fk_igs_en_unit_set_cat(old_references.unit_set_cat);

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_set_cat IN VARCHAR2
    )  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_CAT
      WHERE    unit_set_cat = x_unit_set_cat
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_unit_set_cat,
      x_description,
      x_s_unit_set_cat,
      x_rank,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

	IF Get_PK_For_Validation(
		 new_references.unit_set_cat
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;

	END IF;

	Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
		          new_references.unit_set_cat
				 ) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
		          App_Exception.Raise_Exception;
     	        END IF;
      		Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      		  Check_Constraints;
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
  X_UNIT_SET_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_UNIT_SET_CAT in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_UNIT_SET_CAT
      where UNIT_SET_CAT = X_UNIT_SET_CAT;
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
      p_action => 'INSERT' ,
      x_rowid => x_rowid ,
      x_unit_set_cat => x_unit_set_cat ,
      x_description => x_description ,
      x_s_unit_set_cat => x_s_unit_set_cat ,
      x_rank => NVL(x_rank,1) ,
      x_closed_ind => NVL(x_closed_ind,'N') ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by  ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );

  insert into IGS_EN_UNIT_SET_CAT (
    UNIT_SET_CAT,
    DESCRIPTION,
    S_UNIT_SET_CAT,
    RANK,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_SET_CAT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_UNIT_SET_CAT,
    NEW_REFERENCES.RANK,
    NEW_REFERENCES.CLOSED_IND,
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
  X_UNIT_SET_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_UNIT_SET_CAT in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      S_UNIT_SET_CAT,
      RANK,
      CLOSED_IND
    from IGS_EN_UNIT_SET_CAT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if (
      (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.S_UNIT_SET_CAT = X_S_UNIT_SET_CAT)
           OR ((tlinfo.S_UNIT_SET_CAT IS NULL)
               AND (X_S_UNIT_SET_CAT IS NULL)))
      AND (tlinfo.RANK = X_RANK)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_UNIT_SET_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_UNIT_SET_CAT in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2,
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
      p_action => 'UPDATE' ,
      x_rowid => x_rowid ,
      x_unit_set_cat => x_unit_set_cat ,
      x_description => x_description ,
      x_s_unit_set_cat => x_s_unit_set_cat ,
      x_rank => x_rank ,
      x_closed_ind => x_closed_ind ,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );

  update IGS_EN_UNIT_SET_CAT set
    S_UNIT_SET_CAT = NEW_REFERENCES.S_UNIT_SET_CAT,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    RANK = NEW_REFERENCES.RANK,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
  X_UNIT_SET_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_UNIT_SET_CAT in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_UNIT_SET_CAT
     where UNIT_SET_CAT = X_UNIT_SET_CAT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_SET_CAT,
     X_DESCRIPTION,
     X_S_UNIT_SET_CAT,
     X_RANK,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_SET_CAT,
   X_DESCRIPTION,
   X_S_UNIT_SET_CAT,
   X_RANK,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
begin

  Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_EN_UNIT_SET_CAT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );


end DELETE_ROW;

end IGS_EN_UNIT_SET_CAT_PKG;

/