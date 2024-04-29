--------------------------------------------------------
--  DDL for Package Body IGS_EN_CAT_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_CAT_MAPPING_PKG" AS
/* $Header: IGSEI23B.pls 115.6 2003/10/30 13:28:24 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_EN_CAT_MAPPING%RowType;
  new_references IGS_EN_CAT_MAPPING%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_dflt_cat_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_CAT_MAPPING
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
    new_references.enrolment_cat := x_enrolment_cat;
    new_references.admission_cat := x_admission_cat;
    new_references.dflt_cat_ind := x_dflt_cat_ind;
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
  -- "OSS_TST".trg_ecm_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_CAT_MAPPING
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_admission_cat	IGS_EN_CAT_MAPPING.admission_cat%TYPE;
	v_message_name	varchar2(30);
  BEGIN
	IF p_inserting THEN
		-- Validate the enrolment category closed indicator.
		IF IGS_AD_VAL_ECM.enrp_val_ec_closed (
				new_references.enrolment_cat,
				v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
		END IF;
	END IF;
	-- Set the Admission Category value.
	IF p_deleting THEN
		v_admission_cat := old_references.admission_cat;
	ELSE
		v_admission_cat := new_references.admission_cat;
	END IF;
	-- Validate the admission category closed indicator.
	IF IGS_AD_VAL_ACCT.admp_val_ac_closed (
			v_admission_cat,
			v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
	   NULL;
	ELSIF upper(column_name) = 'DFLT_CAT_IND' then
		new_references.dflt_cat_ind := column_value;
	ELSIF upper(column_name) = 'ADMISSION_CAT' then
		new_references.admission_cat := column_value;
	ELSIF upper(column_name) = 'ENROLMENT_CAT' then
		new_references.enrolment_cat := column_value;
	END IF;

	IF upper(column_name) = 'DFLT_CAT_IND' OR
	 column_name is null then
	  if new_references.dflt_cat_ind NOT IN ('Y','N') OR
	    new_references.dflt_cat_ind <> upper(new_references.dflt_cat_ind) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
	IF upper(column_name) = 'ADMISSION_CAT'  OR
	 column_name is null then
	  if new_references.admission_cat <> upper(new_references.admission_cat) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
	IF upper(column_name) = 'ENROLMENT_CAT'   OR
	 column_name is null then
	  if new_references.enrolment_cat <> upper(new_references.enrolment_cat) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
      if not IGS_AD_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat ,
        'N'
        )then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.enrolment_cat = new_references.enrolment_cat)) OR
        ((new_references.enrolment_cat IS NULL))) THEN
      NULL;
    ELSE
      if not IGS_EN_ENROLMENT_CAT_PKG.Get_PK_For_Validation (
        new_references.enrolment_cat
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
    END IF;

  END Check_Parent_Existance;

 FUNCTION Get_PK_For_Validation (
    x_enrolment_cat IN VARCHAR2,
    x_admission_cat IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_MAPPING
      WHERE    enrolment_cat = x_enrolment_cat
      AND      admission_cat = x_admission_cat
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

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_MAPPING
      WHERE    admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ECM_AC_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CAT;

  PROCEDURE GET_FK_IGS_EN_ENROLMENT_CAT (
    x_enrolment_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_MAPPING
      WHERE    enrolment_cat = x_enrolment_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ECM_EC_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ENROLMENT_CAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_dflt_cat_ind IN VARCHAR2 DEFAULT NULL,
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
      x_enrolment_cat,
      x_admission_cat,
      x_dflt_cat_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	if Get_PK_For_Validation (
	    new_references.enrolment_cat,
	    new_references.admission_cat
    	) then

 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') then
	if Get_PK_For_Validation (
	    new_references.enrolment_cat,
	    new_references.admission_cat
    	) then

 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
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
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_CAT_MAPPING
      where ENROLMENT_CAT = X_ENROLMENT_CAT
      and ADMISSION_CAT = X_ADMISSION_CAT;
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
    x_rowid =>   X_ROWID,
    x_enrolment_cat => X_ENROLMENT_CAT,
    x_admission_cat => X_ADMISSION_CAT,
    x_dflt_cat_ind => NVL(X_DFLT_CAT_IND,'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_CAT_MAPPING (
    ENROLMENT_CAT,
    ADMISSION_CAT,
    DFLT_CAT_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ENROLMENT_CAT,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.DFLT_CAT_IND,
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
    x_rowid =>   X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2
) AS
  cursor c1 is select
      DFLT_CAT_IND
    from IGS_EN_CAT_MAPPING
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

  if ( (tlinfo.DFLT_CAT_IND = X_DFLT_CAT_IND)
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
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
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
    x_rowid =>   X_ROWID,
    x_enrolment_cat => X_ENROLMENT_CAT,
    x_admission_cat => X_ADMISSION_CAT,
    x_dflt_cat_ind => X_DFLT_CAT_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_CAT_MAPPING set
    DFLT_CAT_IND = NEW_REFERENCES.DFLT_CAT_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'UPDATE',
    x_rowid =>   X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_CAT_MAPPING
     where ENROLMENT_CAT = X_ENROLMENT_CAT
     and ADMISSION_CAT = X_ADMISSION_CAT
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ENROLMENT_CAT,
     X_ADMISSION_CAT,
     X_DFLT_CAT_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ENROLMENT_CAT,
   X_ADMISSION_CAT,
   X_DFLT_CAT_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
  delete from IGS_EN_CAT_MAPPING
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
end DELETE_ROW;

end IGS_EN_CAT_MAPPING_PKG;

/
