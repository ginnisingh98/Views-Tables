--------------------------------------------------------
--  DDL for Package Body IGS_AD_LOCATION_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_LOCATION_REL_PKG" as
/* $Header: IGSAI44B.pls 115.4 2003/10/30 13:20:39 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_LOCATION_REL%RowType;
  new_references IGS_AD_LOCATION_REL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_sub_location_cd IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_LOCATION_REL
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
    new_references.location_cd := x_location_cd;
    new_references.sub_location_cd := x_sub_location_cd;
    new_references.dflt_ind := x_dflt_ind;
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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
	-- Validate that inserts are allowed
	IF  p_inserting OR p_updating THEN
		--<Start lr2>
		-- Cannot make a campus (s_location_type = 'CAMPUS') a child of
		-- an exam centre (s_location_type = 'EXAM_CTR')
		IF  IGS_OR_VAL_LR.assp_val_lr_lr (
						new_references.location_cd,
						new_references.sub_location_cd,
						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN

	-- Validate location relationship.
  		IF IGS_OR_VAL_LR.orgp_val_lr (new_references.location_cd,
  				new_references.sub_location_cd,
  				v_message_name) = FALSE THEN
  			Fnd_Message.Set_Name('IGS',v_message_name);
  			IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  		END IF;
  		--<Start lr1>
  		-- Can only set default indicator when parent location is a campus and
  		-- child location is an exam location. This is not really a mutating
  		-- trigger but as <lr3> depends on the result and <lr3> is mutating then
  		-- handle as such.
  		IF  IGS_OR_VAL_LR.assp_val_lr_dfltslot (
  						new_references.location_cd,
  						new_references.sub_location_cd,
  						new_references.dflt_ind,
  						v_message_name) = FALSE THEN
  		     Fnd_Message.Set_Name('IGS',v_message_name);
  		     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  		END IF;


	-- Validate IGS_AD_LOCATION relationship.
	 -- Save the rowid of the current row.
	--IGS_OR_VAL_LR.genp_set_rowid(l_rowid);
	--v_rowid_saved := TRUE;   /* This line was commented becuase the variable v_rowid_saved is to be set true */
                                 /* only if the record has been inserted into the pl/sql table */
	-- Cannot call orgp_val_lr because trigger mayl be mutating.


  END AfterRowInsertUpdate2;

  procedure Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  AS
  BEGIN
	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'DFLT_IND' then
		new_references.dflt_ind := column_value;
	ELSIF upper(Column_Name) = 'LOCATION_CD' then
		new_references.location_cd := column_value;
	ELSIF upper(Column_Name) = 'SUB_LOCATION_CD' then
		new_references.sub_location_cd := column_value;
	END IF;

	IF upper(Column_Name) = 'DFLT_IND' OR Column_Name IS NULL THEN
		IF new_references.dflt_ind NOT IN ('Y','N') THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'LOCATION_CD' OR Column_Name IS NULL THEN
		IF new_references.location_cd <> UPPER(new_references.location_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUB_LOCATION_CD' OR Column_Name IS NULL THEN
		IF new_references.sub_location_cd <> UPPER(new_references.sub_location_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.sub_location_cd = new_references.sub_location_cd)) OR
        ((new_references.sub_location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.sub_location_cd,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_location_cd IN VARCHAR2,
    x_sub_location_cd IN VARCHAR2
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_LOCATION_REL
      WHERE    location_cd = x_location_cd
      AND      sub_location_cd = x_sub_location_cd
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

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_LOCATION_REL
      WHERE    location_cd = x_location_cd
         OR    sub_location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_LR_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_sub_location_cd IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
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
      x_location_cd,
      x_sub_location_cd,
      x_dflt_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.location_cd,
		new_references.sub_location_cd
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.location_cd,
		new_references.sub_location_cd
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      AfterRowInsertUpdate2 ( p_updating => TRUE );
      --AfterStmtInsertUpdate3 ( p_updating => TRUE );
    END IF;

  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_LOCATION_REL
      where LOCATION_CD = X_LOCATION_CD
      and SUB_LOCATION_CD = X_SUB_LOCATION_CD;
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
    p_action=>'INSERT' ,
    x_rowid=>X_ROWID ,
    x_location_cd => X_LOCATION_CD ,
    x_sub_location_cd => X_SUB_LOCATION_CD ,
    x_dflt_ind => NVL(X_DFLT_IND,'N') ,
    x_creation_date=>X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );


  insert into IGS_AD_LOCATION_REL (
    LOCATION_CD,
    SUB_LOCATION_CD,
    DFLT_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.SUB_LOCATION_CD,
    NEW_REFERENCES.DFLT_IND,
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
  p_action=>'INSERT',
  x_rowid=> X_ROWID
         );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2 ,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2
) AS
  cursor c1 is select
      DFLT_IND
    from IGS_AD_LOCATION_REL
    WHERE  ROWID = X_ROWID  for update nowait ;
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

  if ( (tlinfo.DFLT_IND = X_DFLT_IND)
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
  X_ROWID in VARCHAR2 ,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
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
    p_action=>'UPDATE' ,
    x_rowid=>X_ROWID ,
    x_location_cd => X_LOCATION_CD ,
    x_sub_location_cd => X_SUB_LOCATION_CD ,
    x_dflt_ind => X_DFLT_IND ,
    x_creation_date=>X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );


  update IGS_AD_LOCATION_REL set
    DFLT_IND = NEW_REFERENCES.DFLT_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;


After_DML(
  p_action=>'UPDATE',
  x_rowid=> X_ROWID
         );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_LOCATION_REL
     where LOCATION_CD = X_LOCATION_CD
     and SUB_LOCATION_CD = X_SUB_LOCATION_CD
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_LOCATION_CD,
     X_SUB_LOCATION_CD,
     X_DFLT_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID  ,
   X_LOCATION_CD,
   X_SUB_LOCATION_CD,
   X_DFLT_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

 Before_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );

  delete from IGS_AD_LOCATION_REL
  where  ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


 After_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );

end DELETE_ROW;

end IGS_AD_LOCATION_REL_PKG;

/
