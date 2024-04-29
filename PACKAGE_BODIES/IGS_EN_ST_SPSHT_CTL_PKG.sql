--------------------------------------------------------
--  DDL for Package Body IGS_EN_ST_SPSHT_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ST_SPSHT_CTL_PKG" as
/* $Header: IGSEI09B.pls 115.3 2002/11/28 23:33:17 nsidana ship $ */
l_rowid VARCHAR2(25);
  old_references IGS_EN_ST_SPSHT_CTL%RowType;
  new_references IGS_EN_ST_SPSHT_CTL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_snapshot_dt_time IN DATE DEFAULT NULL,
    x_delete_snapshot_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ST_SPSHT_CTL
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
    new_references.snapshot_dt_time := x_snapshot_dt_time;
    new_references.delete_snapshot_ind := x_delete_snapshot_ind;
    new_references.comments := x_comments;
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
  -- "OSS_TST".trg_essc_br_u
  -- BEFORE UPDATE
  -- ON IGS_EN_ST_SPSHT_CTL
  -- FOR EACH ROW

  PROCEDURE BeforeRowUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
      v_message_name  varchar2(30);
  BEGIN
	-- Validate the Delete Snapshot Indicator.
	IF (old_references.delete_snapshot_ind <> new_references.delete_snapshot_ind) AND
	    (new_references.delete_snapshot_ind = 'Y') THEN
		IF IGS_ST_VAL_ESSC.stap_val_essc_delete (
				new_references.snapshot_dt_time,
				new_references.delete_snapshot_ind,
				v_message_name) = FALSE THEN

			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowUpdate1;



  PROCEDURE Check_Constraints(
  	Column_Name in Varchar2 Default NULL,
  	Column_Value in Varchar2 default NULL
  )
  AS
  Begin
	IF column_name is null then
	      NULL;
	ELSIF upper(column_name) = 'DELETE_SNAPSHOT_IND' THEN
	      new_references.delete_snapshot_ind := column_value;
	END IF;

	IF upper(column_name) = 'DELETE_SNAPSHOT_IND' OR
	       Column_name is null THEN
	       IF new_references.delete_snapshot_ind  NOT  IN ( 'Y' , 'N' )  THEN
		      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	       END IF;
	END IF;

  END Check_constraints;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_EN_ST_SNAPSHOT_PKG.GET_FK_IGS_EN_ST_SPSHT_CTL (
      old_references.snapshot_dt_time
      );

    IGS_ST_GVT_SPSHT_CTL_PKG.GET_FK_IGS_EN_ST_SPSHT_CTL (
      old_references.snapshot_dt_time
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_snapshot_dt_time IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ST_SPSHT_CTL
      WHERE    snapshot_dt_time = x_snapshot_dt_time
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
    x_snapshot_dt_time IN DATE DEFAULT NULL,
    x_delete_snapshot_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_snapshot_dt_time,
      x_delete_snapshot_ind,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	If Get_PK_For_Validation(
	new_references.snapshot_dt_time
         ) THEN
         FND_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END if;
      Check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowUpdate1 ( p_updating => TRUE );
      Check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.

      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      If Get_PK_For_Validation(
	new_references.snapshot_dt_time
         ) THEN
         FND_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END if;
      Check_constraints;
    ELSif (p_action = 'VALIDATE_UPDATE') THEN
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      CHECK_CHILD_EXISTANCE;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  )AS
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
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_ST_SPSHT_CTL
      where SNAPSHOT_DT_TIME = X_SNAPSHOT_DT_TIME;
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
    if(X_REQUEST_ID = -1) then
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
    x_rowid => X_ROWID,
    x_snapshot_dt_time => X_SNAPSHOT_DT_TIME,
    x_delete_snapshot_ind => NVL(X_DELETE_SNAPSHOT_IND,'Y'),
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_ST_SPSHT_CTL (
    SNAPSHOT_DT_TIME,
    DELETE_SNAPSHOT_IND,
    COMMENTS,
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
    NEW_REFERENCES.SNAPSHOT_DT_TIME,
    NEW_REFERENCES.DELETE_SNAPSHOT_IND,
    NEW_REFERENCES.COMMENTS,
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
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      DELETE_SNAPSHOT_IND,
      COMMENTS
    from IGS_EN_ST_SPSHT_CTL
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

  if ( (tlinfo.DELETE_SNAPSHOT_IND = X_DELETE_SNAPSHOT_IND)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
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
  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_snapshot_dt_time => X_SNAPSHOT_DT_TIME,
    x_delete_snapshot_ind => X_DELETE_SNAPSHOT_IND,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  if (X_MODE = 'R') then
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if(X_REQUEST_ID = -1) then
       X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
       X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
       X_PROGRAM_APPLICATION_ID :=
            OLD_REFERENCES.PROGRAM_APPLICATION_ID;
       X_PROGRAM_UPDATE_DATE :=
            OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
       X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
    end if;
  update IGS_EN_ST_SPSHT_CTL set
    DELETE_SNAPSHOT_IND = NEW_REFERENCES.DELETE_SNAPSHOT_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
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
    x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_ST_SPSHT_CTL
     where SNAPSHOT_DT_TIME = X_SNAPSHOT_DT_TIME
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SNAPSHOT_DT_TIME,
     X_DELETE_SNAPSHOT_IND,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SNAPSHOT_DT_TIME,
   X_DELETE_SNAPSHOT_IND,
   X_COMMENTS,
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
  delete from IGS_EN_ST_SPSHT_CTL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_EN_ST_SPSHT_CTL_PKG;

/
