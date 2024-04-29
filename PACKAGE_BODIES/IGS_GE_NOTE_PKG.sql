--------------------------------------------------------
--  DDL for Package Body IGS_GE_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_NOTE_PKG" as
/* $Header: IGSMI03B.pls 120.1 2006/01/25 09:19:00 skpandey noship $ */

 l_rowid VARCHAR2(25);
  old_references IGS_GE_NOTE%RowType;
  new_references IGS_GE_NOTE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_s_note_format_type IN VARCHAR2 DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_NOTE
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
    new_references.reference_number := x_reference_number;
    new_references.s_note_format_type := x_s_note_format_type;
    new_references.note_text := x_note_text;
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
	ELSIF upper(Column_name) = 'S_NOTE_FORMAT_TYPE' then
		new_references.s_note_format_type := UPPER(new_references.s_note_format_type);
	END IF;
	IF upper(Column_name) = 'S_NOTE_FORMAT_TYPE' OR column_name is null then
		IF new_references.s_note_format_type <> UPPER(new_references.s_note_format_type) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

   END Check_Constraints;


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.s_note_format_type = new_references.s_note_format_type)) OR
        ((new_references.s_note_format_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_view_Pkg.Get_PK_For_Validation (
	  'NOTE_FORMAT_TYPE',
        new_references.s_note_format_type
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_PS_OFR_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_OFR_OPT_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_OFR_PAT_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_VER_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_GR_CRMN_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PE_PERS_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_AS_SC_ATMPT_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_TR_GROUP_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_TR_ITEM_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_TR_STEP_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_TR_TYP_STEP_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_UNIT_OFR_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_UNT_OFR_OPT_N_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_UNT_OFR_PAT_N_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_EN_UNIT_SET_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_PS_UNIT_VER_NOTE_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

    IGS_FI_P_SA_NOTES_PKG.GET_FK_IGS_GE_NOTE (
      old_references.reference_number
      );

  END Check_Child_Existance;

  FUNCTION GET_PK_FOR_VALIDATION (
    x_reference_number IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_NOTE
      WHERE    reference_number = x_reference_number
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

--skpandey; Bug#3686538: Stubbed as a part of query optimization
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_note_format_type IN VARCHAR2
    ) as
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_s_note_format_type IN VARCHAR2 DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
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
      x_reference_number,
      x_s_note_format_type,
      x_note_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
	 IF GET_PK_FOR_VALIDATION (new_references.reference_number) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      -- Call all the procedures related to Before Insert.
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF GET_PK_FOR_VALIDATION (new_references.reference_number) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  ) as
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
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_GE_NOTE
      where REFERENCE_NUMBER = X_REFERENCE_NUMBER;
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
    x_reference_number => X_REFERENCE_NUMBER,
    x_s_note_format_type => X_S_NOTE_FORMAT_TYPE,
    x_note_text => X_NOTE_TEXT,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

  insert into IGS_GE_NOTE (
    REFERENCE_NUMBER,
    S_NOTE_FORMAT_TYPE,
    NOTE_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.REFERENCE_NUMBER,
    NEW_REFERENCES.S_NOTE_FORMAT_TYPE,
    NEW_REFERENCES.NOTE_TEXT,
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
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2
) as
  cursor c1 is select
      S_NOTE_FORMAT_TYPE,
      NOTE_TEXT
    from IGS_GE_NOTE
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

  if ( (tlinfo.S_NOTE_FORMAT_TYPE = X_S_NOTE_FORMAT_TYPE)

      AND ((tlinfo.NOTE_TEXT = X_NOTE_TEXT)
           OR ((tlinfo.NOTE_TEXT is null)
               AND (X_NOTE_TEXT is null)))
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
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2,
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
    x_reference_number => X_REFERENCE_NUMBER,
    x_s_note_format_type => X_S_NOTE_FORMAT_TYPE,
    x_note_text => X_NOTE_TEXT,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);
  update IGS_GE_NOTE set
    S_NOTE_FORMAT_TYPE = NEW_REFERENCES.S_NOTE_FORMAT_TYPE,
    NOTE_TEXT = NEW_REFERENCES.NOTE_TEXT,
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
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_GE_NOTE
     where REFERENCE_NUMBER = X_REFERENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_REFERENCE_NUMBER,
     X_S_NOTE_FORMAT_TYPE,
     X_NOTE_TEXT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_REFERENCE_NUMBER,
   X_S_NOTE_FORMAT_TYPE,
   X_NOTE_TEXT,
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
  delete from IGS_GE_NOTE
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_GE_NOTE_PKG;

/
