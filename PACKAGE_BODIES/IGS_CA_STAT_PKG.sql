--------------------------------------------------------
--  DDL for Package Body IGS_CA_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_STAT_PKG" AS
/* $Header: IGSCI14B.pls 115.5 2002/11/28 23:03:01 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_STAT%RowType;
  new_references IGS_CA_STAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_cal_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_cal_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_STAT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.cal_status := x_cal_status;
    new_references.description := x_description;
    new_references.s_cal_status := x_s_cal_status;
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
   ) AS
   BEGIN

  IF Column_Name is NULL THEN
  	NULL;
  ELSIF upper(Column_Name) = 'CLOSED_IND' then
  	new_references.closed_ind := Column_Value;
  ELSIF upper(Column_Name) = 'S_CAL_STATUS' then
  	new_references.s_cal_status := Column_Value;
  ELSIF upper(Column_Name) = 'CAL_STATUS' then
    	new_references.cal_status := Column_Value;
  END IF;
  IF upper(Column_Name) = 'S_CAL_STATUS' OR
    	    		column_name is NULL THEN
    	  		IF new_references.s_cal_status <> 'INACTIVE' AND
    			   new_references.s_cal_status <> 'ACTIVE' AND
    			   new_references.s_cal_status <> 'PLANNED'  THEN
    	  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
    	  			IGS_GE_MSG_STACK.ADD;
    	  			App_Exception.Raise_Exception;
    	  		END IF;
  END IF;
  --IF upper(Column_Name) = 'CAL_STATUS' OR
  		--column_name is NULL THEN
		--IF new_references.cal_status <> UPPER(new_references.cal_status) THEN
			--Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			--IGS_GE_MSG_STACK.ADD;
			--App_Exception.Raise_Exception;
		--END IF;
  --END IF;
  IF upper(Column_Name) = 'CLOSED_IND' OR
		  column_name is NULL THEN
		IF new_references.closed_ind <> 'Y' AND
		   new_references.closed_ind <> 'N' THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
  END IF;
END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.cal_status = new_references.cal_status)) OR
        ((new_references.cal_status IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
    	'CALENDAR_STATUS',
        new_references.cal_status
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
    END Check_Parent_Existance;


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_CA_INST_PKG.GET_FK_IGS_CA_STAT (
      old_references.cal_status
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_cal_status IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_STAT
      WHERE    cal_status = x_cal_status
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


    PROCEDURE Get_FK_IGS_LOOKUPS_VIEW (
    x_s_cal_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_STAT
      WHERE    cal_status = x_s_cal_status
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
	 IF (cur_rowid%FOUND) THEN
	      fnd_message.set_name('IGS','IGS_CA_STAT_LKUPV_FK');
	       IGS_GE_MSG_STACK.ADD;
	      Close cur_rowid;
	      App_Exception.Raise_Exception;
	       Return;
	 END IF;
	  Close cur_rowid;
   END GET_FK_IGS_LOOKUPS_VIEW;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_cal_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_cal_status IN VARCHAR2 DEFAULT NULL,
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
      x_cal_status,
      x_description,
      x_s_cal_status,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	  IF Get_PK_For_Validation ( new_references.cal_status)
	  THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
       -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation ( new_references.cal_status)
	  THEN
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

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_STAT
      where CAL_STATUS = X_CAL_STATUS;
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
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_cal_status =>X_CAL_STATUS,
    x_description =>X_DESCRIPTION,
    x_s_cal_status =>X_S_CAL_STATUS,
    x_closed_ind =>NVL(X_CLOSED_IND,'N'),
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_STAT (
    CAL_STATUS,
    DESCRIPTION,
    S_CAL_STATUS,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CAL_STATUS,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_CAL_STATUS,
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
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      S_CAL_STATUS,
      CLOSED_IND
    from IGS_CA_STAT
    where ROWID=X_ROWID
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.S_CAL_STATUS = X_S_CAL_STATUS)
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
  X_ROWID in VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
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
Before_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_cal_status =>X_CAL_STATUS,
    x_description =>X_DESCRIPTION,
    x_s_cal_status =>X_S_CAL_STATUS,
    x_closed_ind =>X_CLOSED_IND,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  update IGS_CA_STAT set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_CAL_STATUS = NEW_REFERENCES.S_CAL_STATUS,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_CA_STAT
     where CAL_STATUS = X_CAL_STATUS
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CAL_STATUS,
     X_DESCRIPTION,
     X_S_CAL_STATUS,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CAL_STATUS,
   X_DESCRIPTION,
   X_S_CAL_STATUS,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_STAT
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_CA_STAT_PKG;

/
