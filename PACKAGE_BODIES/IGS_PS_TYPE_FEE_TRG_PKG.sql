--------------------------------------------------------
--  DDL for Package Body IGS_PS_TYPE_FEE_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_TYPE_FEE_TRG_PKG" AS
/* $Header: IGSPI37B.pls 115.7 2003/06/05 12:57:35 sarakshi ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PS_TYPE_FEE_TRG%RowType;
  new_references IGS_PS_TYPE_FEE_TRG%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_TYPE_FEE_TRG
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
    new_references.fee_cat:= x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_type := x_fee_type;
    new_references.course_type := x_course_type;
    new_references.create_dt := x_create_dt;
    new_references.logical_delete_dt := x_logical_delete_dt;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	IF p_inserting THEN
		-- Validate trigger can be defined.
		IF IGS_FI_VAL_CTFT.finp_val_ctft_ins (
				new_references.fee_type,
				v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate IGS_PS_COURSE Type not closed.
	IF p_inserting THEN
		IF IGS_as_VAL_acot.crsp_val_cty_closed (
				new_references.course_type,
				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;

  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- Validate for open IGS_PS_COURSE Type Fee Trig records.
	IF p_inserting OR
	    (new_references.logical_delete_dt IS NULL) THEN
--
  		-- Validate for open ended IGS_PS_TYPE_FEE_TRG records.
  		IF new_references.logical_delete_dt IS NULL THEN
  			IF IGS_FI_VAL_CTFT.finp_val_ctft_open(new_references.fee_cat,
  			    	              new_references.fee_cal_type,
  				              new_references.fee_ci_sequence_number,
  			    	              new_references.fee_type,
                                      new_references.course_type,
  				              new_references.create_dt,
  				              v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  			END IF;
  		END IF;
--
	END IF;

  END AfterRowInsertUpdate2;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     19-May-2002   removed upper check constraint on fee_cat,fee_type columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'COURSE_TYPE' THEN
	   new_references.course_type := column_value;
	ELSIF upper(column_name) = 'FEE_CAL_TYPE' THEN
	   new_references.fee_cal_type := column_value;
	ELSIF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' THEN
	   new_references.fee_ci_sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
	END IF;

	IF upper(column_name)= 'COURSE_TYPE' OR
		column_name is null THEN
		IF new_references.course_type <> UPPER(new_references.course_type )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'FEE_CAL_TYPE' OR
		column_name is null THEN
		IF new_references.fee_cal_type <> UPPER(new_references.fee_cal_type )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
 	IF upper(column_name)= 'FEE_CI_SEQUENCE_NUMBER' OR
		column_name is null THEN
		IF new_references.fee_ci_sequence_number <1 OR
		 new_references.fee_ci_sequence_number > 999999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_TYPE_PKG.Get_PK_For_Validation (
        new_references.course_type
        )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;

    END IF;

    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type
         )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_course_type IN VARCHAR2,
    x_create_dt IN DATE
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TYPE_FEE_TRG
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      course_type = x_course_type
      AND      create_dt = x_create_dt
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
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
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
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type,
      x_course_type,
      x_create_dt,
      x_logical_delete_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
            new_references.fee_cat,
		new_references.fee_cal_type,
		new_references.fee_ci_sequence_number,
		new_references.fee_type,
		new_references.course_type,
		new_references.create_dt
    	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
   	      new_references.fee_cat,
		new_references.fee_cal_type,
		new_references.fee_ci_sequence_number,
		new_references.fee_type,
		new_references.course_type,
		new_references.create_dt
   	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );

    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_CREATE_DT in out NOCOPY DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_TYPE_FEE_TRG
      where FEE_CAT = X_FEE_CAT
      and FEE_TYPE = X_FEE_TYPE
      and CREATE_DT = NEW_REFERENCES.CREATE_DT
      and COURSE_TYPE = X_COURSE_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE;
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
   if (X_REQUEST_ID = -1) then
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
  Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_fee_cat => X_FEE_CAT,
    x_fee_cal_type => X_FEE_CAL_TYPE,
    x_fee_ci_sequence_number => X_FEE_CI_SEQUENCE_NUMBER,
    x_fee_type => X_FEE_TYPE,
    x_course_type => X_COURSE_TYPE,
    x_create_dt => NVL(X_CREATE_DT,SYSDATE),
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

insert into IGS_PS_TYPE_FEE_TRG (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE,
    COURSE_TYPE,
    CREATE_DT,
    LOGICAL_DELETE_DT,
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
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.COURSE_TYPE,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
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

  After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_CREATE_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      LOGICAL_DELETE_DT
    from IGS_PS_TYPE_FEE_TRG
    where ROWID = X_ROWID for update  nowait;
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

      if ( ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_CREATE_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
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

 Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_fee_cat => X_FEE_CAT,
    x_fee_cal_type => X_FEE_CAL_TYPE,
    x_fee_ci_sequence_number => X_FEE_CI_SEQUENCE_NUMBER,
    x_fee_type => X_FEE_TYPE,
    x_course_type => X_COURSE_TYPE,
    x_create_dt => X_CREATE_DT,
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  if (X_MODE = 'R') then
     X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
     X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
  else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
  end if;
  end if;

  update IGS_PS_TYPE_FEE_TRG set
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
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

   After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_CREATE_DT in out NOCOPY DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_TYPE_FEE_TRG
     where FEE_CAT = X_FEE_CAT
     and FEE_TYPE = X_FEE_TYPE
     and CREATE_DT = NVL(X_CREATE_DT, SYSDATE)
     and COURSE_TYPE = X_COURSE_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_FEE_TYPE,
     X_CREATE_DT,
     X_COURSE_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_FEE_CAL_TYPE,
     X_LOGICAL_DELETE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_FEE_TYPE,
   X_CREATE_DT,
   X_COURSE_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_CAL_TYPE,
   X_LOGICAL_DELETE_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
	X_ROWID in VARCHAR2) AS
begin
   Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PS_TYPE_FEE_TRG
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PS_TYPE_FEE_TRG_PKG;

/
