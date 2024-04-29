--------------------------------------------------------
--  DDL for Package Body IGS_EN_DCNT_REASONCD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_DCNT_REASONCD_PKG" AS
/* $Header: IGSEI20B.pls 115.8 2003/02/20 08:55:14 prraj ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_EN_DCNT_REASONCD_ALL%RowType;
  new_references IGS_EN_DCNT_REASONCD_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_discontinuation_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_DCNT_PROGRAM_ind IN VARCHAR2 DEFAULT NULL,
    x_DCNT_UNIT_ind IN VARCHAR2 DEFAULT NULL,
    x_s_dcnt_reason_type IN VARCHAR2 DEFAULT NULL,
    x_sys_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_DCNT_REASONCD_ALL
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
    new_references.discontinuation_reason_cd := x_discontinuation_reason_cd;
    new_references.description := x_description;
    new_references.dflt_ind := x_dflt_ind;
    new_references.DCNT_PROGRAM_IND := x_DCNT_PROGRAM_IND;
    new_references.DCNT_UNIT_IND := x_DCNT_UNIT_IND;
    new_references.s_discontinuation_reason_type := x_s_dcnt_reason_type;
    new_references.sys_dflt_ind := x_sys_dflt_ind;
    new_references.closed_ind := x_closed_ind;
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
  -- "OSS_TST".trg_dr_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_EN_DCNT_REASONCD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
	-- Cannot update or insert to a closed s_discontinuation_reason_type
	IF (p_inserting OR
		(p_updating AND
		old_references.s_discontinuation_reason_type <>
					new_references.s_discontinuation_reason_type)) THEN
		IF IGS_EN_VAL_DR.enrp_val_sdrt_closed(
				new_references.s_discontinuation_reason_type,
				v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
		END IF;
	END IF;
	-- Can only set sys_dflt_ind to 'Y' if s_discontinuation_reason_type is set
	IF ((p_inserting OR
		p_updating) AND
		new_references.sys_dflt_ind = 'Y') THEN
		IF IGS_EN_VAL_DR.enrp_val_dr_sysdflt(
					new_references.s_discontinuation_reason_type,
					new_references.sys_dflt_ind,
					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
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
	ELSIF upper(column_name) = 'SYS_DFLT_IND' then
		new_references.sys_dflt_ind := column_value;
	ELSIF upper(column_name) = 'CLOSED_IND' then
		new_references.closed_ind := column_value;
	ELSIF upper(column_name) = 'DFLT_IND' then
		new_references.dflt_ind := column_value;
	ELSIF upper(column_name) = 'DCNT_UNIT_IND' then
		new_references.DCNT_UNIT_IND := column_value;
	ELSIF upper(column_name) = 'DCNT_PROGRAM_IND' then
		new_references.DCNT_PROGRAM_IND := column_value;
	ELSIF upper(column_name) = 'DISCONTINUATION_REASON_CD' then
		new_references.discontinuation_reason_cd := column_value;
	ELSIF upper(column_name) = 'S_DISCONTINUATION_REASON_TYPE' then
		new_references.s_discontinuation_reason_type := column_value;
	END IF;

	IF upper(column_name) = 'SYS_DFLT_IND' OR
	 column_name is NULL then
	  if new_references.sys_dflt_ind NOT IN ('Y','N') OR
	   new_references.sys_dflt_ind <>upper(new_references.sys_dflt_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;
	IF upper(column_name) = 'CLOSED_IND' OR
	 column_name is NULL then
	  if new_references.closed_ind NOT IN ('Y','N') OR
	   new_references.closed_ind <> upper(new_references.closed_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;
	IF upper(column_name) = 'DFLT_IND'  OR
	 column_name is NULL then
	  if new_references.dflt_ind NOT IN ('Y','N') OR
	   new_references.dflt_ind <> upper(new_references.dflt_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;
	IF upper(column_name) = 'DCNT_PROGRAM_IND'  OR
	 column_name is NULL then
	  if new_references.DCNT_PROGRAM_IND NOT IN ('Y','N') OR
	   new_references.DCNT_PROGRAM_IND <> upper(new_references.DCNT_PROGRAM_IND) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;
	IF upper(column_name) = 'DCNT_UNIT_IND'  OR
	 column_name is NULL then
	  if new_references.DCNT_UNIT_IND NOT IN ('Y','N') OR
	   new_references.DCNT_UNIT_IND <> upper(new_references.DCNT_UNIT_IND) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;

	IF upper(column_name) = 'DISCONTINUATION_REASON_CD' OR
	 column_name is NULL then
	  if new_references.discontinuation_reason_cd <>
		upper(new_references.discontinuation_reason_cd) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;
	IF upper(column_name) = 'S_DISCONTINUATION_REASON_TYPE' OR
	 column_name is NULL then
	  if new_references.s_discontinuation_reason_type <>
		upper(new_references.s_discontinuation_reason_type) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;

END check_constraints;

FUNCTION Get_PK_For_Validation (
    x_dcnt_reason_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_DCNT_REASONCD_ALL
      WHERE    discontinuation_reason_cd = x_dcnt_reason_cd;

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

    IF (((old_references.s_discontinuation_reason_type = new_references.s_discontinuation_reason_type)) OR
        ((new_references.s_discontinuation_reason_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
        'DISCONTINUATION_REASON_TYPE',
        new_references.s_discontinuation_reason_type
        )THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      end if;
    END IF;

  END Check_Parent_Existance;


  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_dcnt_reason_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_DCNT_REASONCD_ALL
      WHERE    s_discontinuation_reason_type = x_s_dcnt_reason_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_DR_LKUPV_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_discontinuation_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_dcnt_program_ind IN VARCHAR2 DEFAULT NULL,
    x_dcnt_unit_ind IN VARCHAR2 DEFAULT NULL,
    x_s_dcnt_reason_type IN VARCHAR2 DEFAULT NULL,
    x_sys_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_org_id,
      x_discontinuation_reason_cd,
      x_description,
      x_dflt_ind,
      x_dcnt_program_ind,
      x_dcnt_unit_ind,
      x_s_dcnt_reason_type,
      x_sys_dflt_ind,
      x_closed_ind,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      If Get_PK_For_Validation(
  	 new_references.DISCONTINUATION_REASON_CD
      ) then
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    end if;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_constraints;
      Check_Parent_Existance;

   ELSIF (p_action = 'VALIDATE_INSERT') then
	 If Get_PK_For_Validation(
  	 new_references.DISCONTINUATION_REASON_CD
      	) then
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    end if;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 Check_constraints;

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
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_DCNT_PROGRAM_IND in VARCHAR2,
  X_DCNT_UNIT_IND in VARCHAR2,
  X_S_Dcnt_REASON_TYP in VARCHAR2,
  X_SYS_DFLT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_DCNT_REASONCD_ALL
      where DISCONTINUATION_REASON_CD = X_DISCONTINUATION_REASON_CD;
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
    x_org_id => igs_ge_gen_003.get_org_id,
    x_discontinuation_reason_cd => X_DISCONTINUATION_REASON_CD,
    X_DESCRIPTION => X_DESCRIPTION,
    X_DFLT_IND => NVL(X_DFLT_IND,'N'),
    X_DCNT_PROGRAM_IND => NVL(X_DCNT_PROGRAM_IND,'N'),
    X_DCNT_UNIT_IND => NVL(X_DCNT_UNIT_IND,'N'),
    x_s_dcnt_reason_type => X_S_dcnt_REASON_TYP,
    x_sys_dflt_ind => NVL(X_SYS_DFLT_IND,'N'),
    x_closed_ind => NVL(X_CLOSED_IND,'N'),
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_DCNT_REASONCD_ALL (
    org_id,
    DISCONTINUATION_REASON_CD,
    DESCRIPTION,
    DFLT_IND,
    DCNT_PROGRAM_IND,
    DCNT_UNIT_IND,
    S_DISCONTINUATION_REASON_TYPE,
    SYS_DFLT_IND,
    CLOSED_IND,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.DISCONTINUATION_REASON_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.DFLT_IND,
    NEW_REFERENCES.DCNT_PROGRAM_IND,
    NEW_REFERENCES.DCNT_UNIT_IND,
    NEW_REFERENCES.S_DISCONTINUATION_REASON_TYPE,
    NEW_REFERENCES.SYS_DFLT_IND,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.COMMENTS,
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
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_DCNT_PROGRAM_IND in VARCHAR2,
  X_DCNT_UNIT_IND in VARCHAR2,
  X_S_Dcnt_REASON_TYP in VARCHAR2,
  X_SYS_DFLT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select

      DESCRIPTION,
      DFLT_IND,
      DCNT_PROGRAM_IND,
      DCNT_UNIT_IND,
      S_DISCONTINUATION_REASON_TYPE,
      SYS_DFLT_IND,
      CLOSED_IND,
      COMMENTS
    from IGS_EN_DCNT_REASONCD_ALL
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.DFLT_IND = X_DFLT_IND)
      AND ((tlinfo.DCNT_UNIT_IND = X_DCNT_UNIT_IND)
           OR ((tlinfo.DCNT_UNIT_IND is null)
               AND (X_DCNT_UNIT_IND is null)))
      AND ((tlinfo.DCNT_PROGRAM_IND = X_DCNT_PROGRAM_IND)
           OR ((tlinfo.DCNT_PROGRAM_IND is null)
               AND (X_DCNT_PROGRAM_IND is null)))
      AND ((tlinfo.S_DISCONTINUATION_REASON_TYPE = X_S_Dcnt_REASON_TYP)
           OR ((tlinfo.S_DISCONTINUATION_REASON_TYPE is null)
               AND (X_S_Dcnt_REASON_TYP is null)))
      AND (tlinfo.SYS_DFLT_IND = X_SYS_DFLT_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_DCNT_PROGRAM_IND in VARCHAR2,
  X_DCNT_UNIT_IND in VARCHAR2,
  X_S_Dcnt_REASON_TYP in VARCHAR2,
  X_SYS_DFLT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
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
    x_discontinuation_reason_cd => X_DISCONTINUATION_REASON_CD,
    X_DESCRIPTION => X_DESCRIPTION,
    X_DFLT_IND => X_DFLT_IND,
    X_DCNT_PROGRAM_IND => X_DCNT_PROGRAM_IND,
    X_DCNT_UNIT_IND => X_DCNT_UNIT_IND,
    x_s_dcnt_reason_type => X_S_Dcnt_REASON_TYP,
    x_sys_dflt_ind => X_SYS_DFLT_IND,
    x_closed_ind => X_CLOSED_IND,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_DCNT_REASONCD_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    DFLT_IND = NEW_REFERENCES.DFLT_IND,
    DCNT_PROGRAM_IND = NEW_REFERENCES.DCNT_PROGRAM_IND,
    DCNT_UNIT_IND = NEW_REFERENCES.DCNT_UNIT_IND,
    S_DISCONTINUATION_REASON_TYPE = NEW_REFERENCES.S_DISCONTINUATION_REASON_TYPE,
    SYS_DFLT_IND = NEW_REFERENCES.SYS_DFLT_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

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
  X_ORG_ID in NUMBER,
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_DCNT_PROGRAM_IND in VARCHAR2,
  X_DCNT_UNIT_IND in VARCHAR2,
  X_S_Dcnt_REASON_TYP in VARCHAR2,
  X_SYS_DFLT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_DCNT_REASONCD_ALL
     where DISCONTINUATION_REASON_CD = X_DISCONTINUATION_REASON_CD;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     x_org_id,
     X_DISCONTINUATION_REASON_CD,
     X_DESCRIPTION,
     X_DFLT_IND,
     X_DCNT_PROGRAM_IND,
     X_DCNT_UNIT_IND,
     X_S_Dcnt_REASON_TYP,
     X_SYS_DFLT_IND,
     X_CLOSED_IND,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DISCONTINUATION_REASON_CD,
   X_DESCRIPTION,
   X_DFLT_IND,
   X_DCNT_PROGRAM_IND,
   X_DCNT_UNIT_IND,
   X_S_Dcnt_REASON_TYP,
   X_SYS_DFLT_IND,
   X_CLOSED_IND,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;


END IGS_EN_DCNT_REASONCD_PKG;

/
