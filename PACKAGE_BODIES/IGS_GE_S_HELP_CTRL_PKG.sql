--------------------------------------------------------
--  DDL for Package Body IGS_GE_S_HELP_CTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_S_HELP_CTRL_PKG" as
/* $Header: IGSMI09B.pls 115.3 2002/11/29 01:11:20 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_GE_S_HELP_CTRL%RowType;
  new_references IGS_GE_S_HELP_CTRL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_base_url IN VARCHAR2 DEFAULT NULL,
    x_toc_url IN VARCHAR2 DEFAULT NULL,
    x_index_url IN VARCHAR2 DEFAULT NULL,
    x_link1_button_label IN VARCHAR2 DEFAULT NULL,
    x_link1_base_url IN VARCHAR2 DEFAULT NULL,
    x_link2_button_label IN VARCHAR2 DEFAULT NULL,
    x_link2_base_url IN VARCHAR2 DEFAULT NULL,
    x_link3_button_label IN VARCHAR2 DEFAULT NULL,
    x_link3_base_url IN VARCHAR2 DEFAULT NULL,
    x_ows_enabled_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_S_HELP_CTRL
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
    new_references.s_control_num := x_s_control_num;
    new_references.base_url := x_base_url;
    new_references.toc_url := x_toc_url;
    new_references.index_url := x_index_url;
    new_references.link1_button_label := x_link1_button_label;
    new_references.link1_base_url := x_link1_base_url;
    new_references.link2_button_label := x_link2_button_label;
    new_references.link2_base_url := x_link2_base_url;
    new_references.link3_button_label := x_link3_button_label;
    new_references.link3_base_url := x_link3_base_url;
    new_references.ows_enabled_ind := x_ows_enabled_ind;
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

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 ) as
  BEGIN
	IF column_name is null then
	   NULL;
	ELSIF upper(Column_name) = 'OWS_ENABLED_IND' then
		new_references.ows_enabled_ind := column_value;
	END IF;
	IF upper(Column_name) = 'OWS_ENABLED_IND' OR column_name is null then
		IF new_references.ows_enabled_ind <> UPPER(new_references.ows_enabled_ind ) then
	            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	            IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  FUNCTION GET_PK_FOR_VALIDATION (
    x_s_control_num IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_S_HELP_CTRL
      WHERE    s_control_num = x_s_control_num
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
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_base_url IN VARCHAR2 DEFAULT NULL,
    x_toc_url IN VARCHAR2 DEFAULT NULL,
    x_index_url IN VARCHAR2 DEFAULT NULL,
    x_link1_button_label IN VARCHAR2 DEFAULT NULL,
    x_link1_base_url IN VARCHAR2 DEFAULT NULL,
    x_link2_button_label IN VARCHAR2 DEFAULT NULL,
    x_link2_base_url IN VARCHAR2 DEFAULT NULL,
    x_link3_button_label IN VARCHAR2 DEFAULT NULL,
    x_link3_base_url IN VARCHAR2 DEFAULT NULL,
    x_ows_enabled_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_s_control_num,
      x_base_url,
      x_toc_url,
      x_index_url,
      x_link1_button_label,
      x_link1_base_url,
      x_link2_button_label,
      x_link2_base_url,
      x_link3_button_label,
      x_link3_base_url,
      x_ows_enabled_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

   IF (p_action = 'INSERT') THEN
	IF Get_PK_For_Validation(new_references.s_control_num)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF	;
	Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(new_references.s_control_num)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF	;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
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
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_BASE_URL in VARCHAR2,
  X_OWS_ENABLED_IND in VARCHAR2,
  X_TOC_URL in VARCHAR2,
  X_INDEX_URL in VARCHAR2,
  X_LINK1_BUTTON_LABEL in VARCHAR2,
  X_LINK1_BASE_URL in VARCHAR2,
  X_LINK2_BUTTON_LABEL in VARCHAR2,
  X_LINK2_BASE_URL in VARCHAR2,
  X_LINK3_BUTTON_LABEL in VARCHAR2,
  X_LINK3_BASE_URL in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_GE_S_HELP_CTRL
      where S_CONTROL_NUM = NEW_REFERENCES.S_CONTROL_NUM;
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
    x_s_control_num => NVL(X_S_CONTROL_NUM,1),
    x_base_url => X_BASE_URL,
    x_ows_enabled_ind => NVL(X_OWS_ENABLED_IND,'N'),
    x_toc_url => X_TOC_URL,
    x_index_url => X_INDEX_URL,
    x_link1_button_label => X_LINK1_BUTTON_LABEL,
    x_link1_base_url => X_LINK1_BASE_URL,
    x_link2_button_label => X_LINK2_BUTTON_LABEL,
    x_link2_base_url => X_LINK2_BASE_URL,
    x_link3_button_label => X_LINK3_BUTTON_LABEL,
    x_link3_base_url => X_LINK3_BASE_URL,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

  insert into IGS_GE_S_HELP_CTRL (
    S_CONTROL_NUM,
    BASE_URL,
    OWS_ENABLED_IND,
    TOC_URL,
    INDEX_URL,
    LINK1_BUTTON_LABEL,
    LINK1_BASE_URL,
    LINK2_BUTTON_LABEL,
    LINK2_BASE_URL,
    LINK3_BUTTON_LABEL,
    LINK3_BASE_URL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.S_CONTROL_NUM,
    NEW_REFERENCES.BASE_URL,
    NEW_REFERENCES.OWS_ENABLED_IND,
    NEW_REFERENCES.TOC_URL,
    NEW_REFERENCES.INDEX_URL,
    NEW_REFERENCES.LINK1_BUTTON_LABEL,
    NEW_REFERENCES.LINK1_BASE_URL,
    NEW_REFERENCES.LINK2_BUTTON_LABEL,
    NEW_REFERENCES.LINK2_BASE_URL,
    NEW_REFERENCES.LINK3_BUTTON_LABEL,
    NEW_REFERENCES.LINK3_BASE_URL,
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
  X_S_CONTROL_NUM in NUMBER,
  X_BASE_URL in VARCHAR2,
  X_OWS_ENABLED_IND in VARCHAR2,
  X_TOC_URL in VARCHAR2,
  X_INDEX_URL in VARCHAR2,
  X_LINK1_BUTTON_LABEL in VARCHAR2,
  X_LINK1_BASE_URL in VARCHAR2,
  X_LINK2_BUTTON_LABEL in VARCHAR2,
  X_LINK2_BASE_URL in VARCHAR2,
  X_LINK3_BUTTON_LABEL in VARCHAR2,
  X_LINK3_BASE_URL in VARCHAR2
) as
  cursor c1 is select
      BASE_URL,
      OWS_ENABLED_IND,
      TOC_URL,
      INDEX_URL,
      LINK1_BUTTON_LABEL,
      LINK1_BASE_URL,
      LINK2_BUTTON_LABEL,
      LINK2_BASE_URL,
      LINK3_BUTTON_LABEL,
      LINK3_BASE_URL
    from IGS_GE_S_HELP_CTRL
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

      if ( ((tlinfo.BASE_URL = X_BASE_URL)
           OR ((tlinfo.BASE_URL is null)
               AND (X_BASE_URL is null)))
      AND (tlinfo.OWS_ENABLED_IND = X_OWS_ENABLED_IND)
      AND ((tlinfo.TOC_URL = X_TOC_URL)
           OR ((tlinfo.TOC_URL is null)
               AND (X_TOC_URL is null)))
      AND ((tlinfo.INDEX_URL = X_INDEX_URL)
           OR ((tlinfo.INDEX_URL is null)
               AND (X_INDEX_URL is null)))
      AND ((tlinfo.LINK1_BUTTON_LABEL = X_LINK1_BUTTON_LABEL)
           OR ((tlinfo.LINK1_BUTTON_LABEL is null)
               AND (X_LINK1_BUTTON_LABEL is null)))
      AND ((tlinfo.LINK1_BASE_URL = X_LINK1_BASE_URL)
           OR ((tlinfo.LINK1_BASE_URL is null)
               AND (X_LINK1_BASE_URL is null)))
      AND ((tlinfo.LINK2_BUTTON_LABEL = X_LINK2_BUTTON_LABEL)
           OR ((tlinfo.LINK2_BUTTON_LABEL is null)
               AND (X_LINK2_BUTTON_LABEL is null)))
      AND ((tlinfo.LINK2_BASE_URL = X_LINK2_BASE_URL)
           OR ((tlinfo.LINK2_BASE_URL is null)
               AND (X_LINK2_BASE_URL is null)))
      AND ((tlinfo.LINK3_BUTTON_LABEL = X_LINK3_BUTTON_LABEL)
           OR ((tlinfo.LINK3_BUTTON_LABEL is null)
               AND (X_LINK3_BUTTON_LABEL is null)))
      AND ((tlinfo.LINK3_BASE_URL = X_LINK3_BASE_URL)
           OR ((tlinfo.LINK3_BASE_URL is null)
               AND (X_LINK3_BASE_URL is null)))
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
  X_S_CONTROL_NUM in NUMBER,
  X_BASE_URL in VARCHAR2,
  X_OWS_ENABLED_IND in VARCHAR2,
  X_TOC_URL in VARCHAR2,
  X_INDEX_URL in VARCHAR2,
  X_LINK1_BUTTON_LABEL in VARCHAR2,
  X_LINK1_BASE_URL in VARCHAR2,
  X_LINK2_BUTTON_LABEL in VARCHAR2,
  X_LINK2_BASE_URL in VARCHAR2,
  X_LINK3_BUTTON_LABEL in VARCHAR2,
  X_LINK3_BASE_URL in VARCHAR2,
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
    x_s_control_num => X_S_CONTROL_NUM,
    x_base_url => X_BASE_URL,
    x_ows_enabled_ind => X_OWS_ENABLED_IND,
    x_toc_url => X_TOC_URL,
    x_index_url => X_INDEX_URL,
    x_link1_button_label => X_LINK1_BUTTON_LABEL,
    x_link1_base_url => X_LINK1_BASE_URL,
    x_link2_button_label => X_LINK2_BUTTON_LABEL,
    x_link2_base_url => X_LINK2_BASE_URL,
    x_link3_button_label => X_LINK3_BUTTON_LABEL,
    x_link3_base_url => X_LINK3_BASE_URL,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

  update IGS_GE_S_HELP_CTRL set
    BASE_URL =   NEW_REFERENCES.BASE_URL,
    OWS_ENABLED_IND =   NEW_REFERENCES.OWS_ENABLED_IND,
    TOC_URL =   NEW_REFERENCES.TOC_URL,
    INDEX_URL =   NEW_REFERENCES.INDEX_URL,
    LINK1_BUTTON_LABEL =   NEW_REFERENCES.LINK1_BUTTON_LABEL,
    LINK1_BASE_URL =   NEW_REFERENCES.LINK1_BASE_URL,
    LINK2_BUTTON_LABEL =   NEW_REFERENCES.LINK2_BUTTON_LABEL,
    LINK2_BASE_URL =   NEW_REFERENCES.LINK2_BASE_URL,
    LINK3_BUTTON_LABEL =   NEW_REFERENCES.LINK3_BUTTON_LABEL,
    LINK3_BASE_URL =   NEW_REFERENCES.LINK3_BASE_URL,
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
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_BASE_URL in VARCHAR2,
  X_OWS_ENABLED_IND in VARCHAR2,
  X_TOC_URL in VARCHAR2,
  X_INDEX_URL in VARCHAR2,
  X_LINK1_BUTTON_LABEL in VARCHAR2,
  X_LINK1_BASE_URL in VARCHAR2,
  X_LINK2_BUTTON_LABEL in VARCHAR2,
  X_LINK2_BASE_URL in VARCHAR2,
  X_LINK3_BUTTON_LABEL in VARCHAR2,
  X_LINK3_BASE_URL in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_GE_S_HELP_CTRL
     where S_CONTROL_NUM = NVL(X_S_CONTROL_NUM,1)
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_CONTROL_NUM,
     X_BASE_URL,
     X_OWS_ENABLED_IND,
     X_TOC_URL,
     X_INDEX_URL,
     X_LINK1_BUTTON_LABEL,
     X_LINK1_BASE_URL,
     X_LINK2_BUTTON_LABEL,
     X_LINK2_BASE_URL,
     X_LINK3_BUTTON_LABEL,
     X_LINK3_BASE_URL,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_CONTROL_NUM,
   X_BASE_URL,
   X_OWS_ENABLED_IND,
   X_TOC_URL,
   X_INDEX_URL,
   X_LINK1_BUTTON_LABEL,
   X_LINK1_BASE_URL,
   X_LINK2_BUTTON_LABEL,
   X_LINK2_BASE_URL,
   X_LINK3_BUTTON_LABEL,
   X_LINK3_BASE_URL,
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
  delete from IGS_GE_S_HELP_CTRL
      where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_GE_S_HELP_CTRL_PKG;

/
