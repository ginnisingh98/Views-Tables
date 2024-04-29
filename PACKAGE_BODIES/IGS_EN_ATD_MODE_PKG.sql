--------------------------------------------------------
--  DDL for Package Body IGS_EN_ATD_MODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ATD_MODE_PKG" as
/* $Header: IGSEI13B.pls 115.8 2003/02/04 08:24:00 srdirisa ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_ATD_MODE_ALL%RowType;
  new_references IGS_EN_ATD_MODE_ALL%RowType;
  PROCEDURE beforerowdelete;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ATD_MODE_ALL
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
    new_references.org_id := x_org_id;
    new_references.attendance_mode := x_attendance_mode;
    new_references.description := x_description;
    new_references.govt_attendance_mode := x_govt_attendance_mode;
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


  -- Trigger description :-
  -- "OSS_TST".trg_am_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON attendance_mode
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

      v_message_name  varchar2(30);
  BEGIN

	-- Validate Govt attendance mode.
	IF p_inserting OR
		(p_updating AND
		(old_references.govt_attendance_mode <> new_references.govt_attendance_mode OR
		 old_references.closed_ind <> new_references.closed_ind)) THEN
		IF IGS_PS_VAL_AM.crsp_val_am_govt(
			new_references.govt_attendance_mode,
			v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;


END BeforeRowInsertUpdate1;

 procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
      		NULL;
	ELSIF upper(column_name) = 'CLOSED_IND' THEN
      		new_references.closed_ind := column_value;
	ELSIF upper(column_name) = 'ATTENDANCE_MODE' THEN
     		 new_references.attendance_mode := column_value;
	ELSIF upper(column_name) = 'GOVT_ATTENDANCE_MODE' THEN
      		new_references.govt_attendance_mode := column_value;
	END IF;

IF upper(column_name) = 'CLOSED_IND' OR
       Column_name is null THEN
       IF new_references.closed_ind  NOT IN ('Y','N') THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'ATTENDANCE_MODE' OR
       Column_name is null THEN
       IF new_references.attendance_mode <> UPPER(new_references.attendance_mode)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'GOVT_ATTENDANCE_MODE' OR
       Column_name is null THEN
       IF new_references.govt_attendance_mode <> UPPER(new_references.govt_attendance_mode)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

END check_constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.govt_attendance_mode = new_references.govt_attendance_mode)) OR
        ((new_references.govt_attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_GOVT_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.govt_attendance_mode
        ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_AD_PRD_PS_OF_OPT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_AD_PECRS_OFOP_DT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_FI_FEE_AS_RT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_PS_FEE_TRG_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_PS_OFR_OPT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );


    IGS_FI_FEE_AS_RATE_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_PS_PAT_OF_STUDY_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_AD_SBMAO_FN_AMTT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_AD_SBM_PS_FNTRGT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

    IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_EN_ATD_MODE (
      old_references.attendance_mode
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_attendance_mode IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ATD_MODE_ALL
      WHERE    attendance_mode = x_attendance_mode;

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

  PROCEDURE GET_FK_IGS_PS_GOVT_ATD_MODE (
    x_govt_attendance_mode IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ATD_MODE_ALL
      WHERE    govt_attendance_mode = x_govt_attendance_mode ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_AM_GAM_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_GOVT_ATD_MODE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER  DEFAULT NULL,
    x_last_update_date IN DATE  DEFAULT NULL,
    x_last_updated_by IN NUMBER  DEFAULT NULL,
    x_last_update_login IN NUMBER  DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_attendance_mode,
      x_description,
      x_govt_attendance_mode,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
 	   new_references.attendance_mode
    	) Then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowdelete;
      Check_Child_Existance;
  ELSIF (p_action = 'VALIDATE_INSERT') then
	IF Get_PK_For_Validation (
 	   new_references.attendance_mode
    	) Then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
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
  X_ORG_ID in NUMBER,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_ATD_MODE_ALL
      where ATTENDANCE_MODE = X_ATTENDANCE_MODE;
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
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_attendance_mode => X_ATTENDANCE_MODE,
  x_description => X_DESCRIPTION,
  x_govt_attendance_mode => X_GOVT_ATTENDANCE_MODE,
  x_closed_ind => X_CLOSED_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
);

  insert into IGS_EN_ATD_MODE_ALL (
    org_id,
    ATTENDANCE_MODE,
    DESCRIPTION,
    GOVT_ATTENDANCE_MODE,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_ATTENDANCE_MODE,
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
  X_ROWID in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      GOVT_ATTENDANCE_MODE,
      CLOSED_IND
    from IGS_EN_ATD_MODE_ALL
    where ROWID = X_ROWID
    for update  nowait;
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
      AND (tlinfo.GOVT_ATTENDANCE_MODE = X_GOVT_ATTENDANCE_MODE)
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
  X_ATTENDANCE_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
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
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_attendance_mode => X_ATTENDANCE_MODE,
  x_description => X_DESCRIPTION,
  x_govt_attendance_mode => X_GOVT_ATTENDANCE_MODE,
  x_closed_ind => X_CLOSED_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
);

  update IGS_EN_ATD_MODE_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_ATTENDANCE_MODE = NEW_REFERENCES.GOVT_ATTENDANCE_MODE,
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
  X_ORG_ID in NUMBER,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_ATD_MODE_ALL
     where ATTENDANCE_MODE = X_ATTENDANCE_MODE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     x_org_id,
     X_ATTENDANCE_MODE,
     X_DESCRIPTION,
     X_GOVT_ATTENDANCE_MODE,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ATTENDANCE_MODE,
   X_DESCRIPTION,
   X_GOVT_ATTENDANCE_MODE,
   X_CLOSED_IND,
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


  delete from IGS_EN_ATD_MODE_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
);

end DELETE_ROW;

  PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : smvk, Oracle India
  --Date created: 03-Jan-2003
  --
  --Purpose: Attendance Mode records can be deleted logically by setting the closed_ind as 'Y'
  --         No physical deletion is allowed. As a part of Bug # 2729917
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    -- Preventing deletion of the Attendance Mode records. As a part of Bug # 2729917
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_DEL_NOT_ALLWD');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END beforerowdelete;

end IGS_EN_ATD_MODE_PKG;

/
