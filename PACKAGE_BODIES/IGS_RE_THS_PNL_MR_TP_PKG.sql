--------------------------------------------------------
--  DDL for Package Body IGS_RE_THS_PNL_MR_TP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THS_PNL_MR_TP_PKG" as
/* $Header: IGSRI23B.pls 115.6 2003/02/19 12:27:23 kpadiyar ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RE_THS_PNL_MR_TP_ALL%RowType;
  new_references IGS_RE_THS_PNL_MR_TP_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_panel_member_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_panel_chair_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_THS_PNL_MR_TP_ALL
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
    new_references.panel_member_type := x_panel_member_type;
    new_references.description := x_description;
    new_references.panel_chair_ind := x_panel_chair_ind;
    new_references.closed_ind := x_closed_ind;
    new_references.tracking_type := x_tracking_type;
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
    new_references.org_id := x_org_id;

  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE
    ) as
     v_message_name                  VARCHAR2(30);
  BEGIN
        IF (p_inserting OR (p_updating AND (old_references.tracking_type <> new_references.tracking_type))) THEN
	 IF NOT IGS_TR_VAL_TRI.TRKP_VAL_TRI_TYPE (new_references.tracking_type,
	                                          v_message_name) THEN
             Fnd_Message.Set_Name('IGS', v_message_name);
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
	 END IF;
        END IF;
  END BeforeRowInsertUpdate;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 ) AS
  BEGIN
	IF column_name is null then
		NULL;
	ELSIF upper(Column_name) = 'CLOSED_IND' then
		new_references.closed_ind := column_value;
	ELSIF upper(Column_name) = 'PANEL_CHAIR_IND' then
		new_references.panel_chair_ind:= column_value;
	ELSIF upper(Column_name) = 'PANEL_MEMBER_TYPE' then
		new_references.panel_member_type:= column_value;
	ELSIF upper(Column_name) = 'TRACKING_TYPE' then
		new_references.tracking_type:= column_value;
	END IF;

	IF upper(Column_name) = 'PANEL_MEMBER_TYPE'  OR column_name is null then
		IF new_references.panel_member_type <> UPPER(new_references.panel_member_type ) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'TRACKING_TYPE'  OR column_name is null then
		IF new_references.tracking_type <> UPPER(new_references.tracking_type ) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'PANEL_CHAIR_IND' OR column_name is null then
		IF new_references.panel_chair_ind <> UPPER(new_references.panel_chair_ind) OR
			new_references.panel_chair_ind NOT IN ( 'Y' , 'N' ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'CLOSED_IND' OR column_name is null THEN
		IF new_references.closed_ind <> UPPER(new_references.closed_ind ) OR
			new_references.closed_ind NOT IN ( 'Y' , 'N' ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.tracking_type = new_references.tracking_type)) OR
        ((new_references.tracking_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_TR_TYPE_PKG.Get_PK_For_Validation (
        new_references.tracking_type
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance aS
  BEGIN

    IGS_RE_THS_PNL_MBR_PKG.GET_FK_IGS_RE_THS_PNL_MR_TP (
      old_references.panel_member_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_panel_member_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MR_TP_ALL
      WHERE    panel_member_type = x_panel_member_type
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
    x_panel_member_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_panel_chair_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_panel_member_type,
      x_description,
      x_panel_chair_ind,
      x_closed_ind,
      x_tracking_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
        BeforeRowInsertUpdate ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
		new_references.panel_member_type
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
        BeforeRowInsertUpdate ( p_updating => TRUE );
      -- Call all the procedures related to Before Update.
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(
		new_references.panel_member_type
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PANEL_CHAIR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_TRACKING_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_THS_PNL_MR_TP_ALL
      where PANEL_MEMBER_TYPE = X_PANEL_MEMBER_TYPE;
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
    x_panel_member_type => X_PANEL_MEMBER_TYPE,
    x_description => X_DESCRIPTION,
    x_panel_chair_ind => NVL(X_PANEL_CHAIR_IND, 'N'),
    x_closed_ind => NVL(X_CLOSED_IND, 'N'),
    x_tracking_type => X_TRACKING_TYPE,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );

  insert into IGS_RE_THS_PNL_MR_TP_ALL (
    PANEL_MEMBER_TYPE,
    DESCRIPTION,
    PANEL_CHAIR_IND,
    CLOSED_IND,
    TRACKING_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PANEL_MEMBER_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.PANEL_CHAIR_IND,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.TRACKING_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PANEL_CHAIR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_TRACKING_TYPE in VARCHAR2
) as
  cursor c1 is select
      DESCRIPTION,
      PANEL_CHAIR_IND,
      CLOSED_IND,
      TRACKING_TYPE
    from IGS_RE_THS_PNL_MR_TP_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.PANEL_CHAIR_IND = X_PANEL_CHAIR_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.TRACKING_TYPE = X_TRACKING_TYPE)
           OR ((tlinfo.TRACKING_TYPE is null)
               AND (X_TRACKING_TYPE is null)))
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
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PANEL_CHAIR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_TRACKING_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
    x_panel_member_type => X_PANEL_MEMBER_TYPE,
    x_description => X_DESCRIPTION,
    x_panel_chair_ind => X_PANEL_CHAIR_IND,
    x_closed_ind => X_CLOSED_IND,
    x_tracking_type => X_TRACKING_TYPE,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );
  update IGS_RE_THS_PNL_MR_TP_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    PANEL_CHAIR_IND = NEW_REFERENCES.PANEL_CHAIR_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    TRACKING_TYPE = NEW_REFERENCES.TRACKING_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PANEL_CHAIR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_TRACKING_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_THS_PNL_MR_TP_ALL
     where PANEL_MEMBER_TYPE = X_PANEL_MEMBER_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PANEL_MEMBER_TYPE,
     X_DESCRIPTION,
     X_PANEL_CHAIR_IND,
     X_CLOSED_IND,
     X_TRACKING_TYPE,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PANEL_MEMBER_TYPE,
   X_DESCRIPTION,
   X_PANEL_CHAIR_IND,
   X_CLOSED_IND,
   X_TRACKING_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );

  delete from IGS_RE_THS_PNL_MR_TP_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_RE_THS_PNL_MR_TP_PKG;

/
