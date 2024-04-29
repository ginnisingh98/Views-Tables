--------------------------------------------------------
--  DDL for Package Body IGS_ST_UNT_LOAD_APPO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_UNT_LOAD_APPO_PKG" as
/* $Header: IGSVI12B.pls 115.4 2002/11/29 04:33:50 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_ST_UNT_LOAD_APPO%RowType;
  new_references IGS_ST_UNT_LOAD_APPO%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dla_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_second_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_UNT_LOAD_APPO
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND p_action NOT IN ('INSERT','VALIDATE_INSERT') THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.dla_cal_type := x_dla_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.teach_cal_type := x_teach_cal_type;
    new_references.percentage := x_percentage;
    new_references.second_percentage := x_second_percentage;
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
    ) as
	v_message_name VARCHAR2(30);
	v_dla_cal_type		IGS_ST_UNT_LOAD_APPO.dla_cal_type%TYPE;
	v_ci_sequence_number	IGS_ST_UNT_LOAD_APPO.ci_sequence_number%TYPE;
  BEGIN
	IF p_inserting OR p_updating THEN
		v_dla_cal_type := new_references.dla_cal_type;
		v_ci_sequence_number := new_references.ci_sequence_number;
	ELSE
		v_dla_cal_type := old_references.dla_cal_type;
		v_ci_sequence_number := old_references.ci_sequence_number;
	END IF;
	-- Validate if insert, update or delete is allowed.
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_ST_VAL_ULA.STAP_VAL_CI_STATUS" to program unit "IGS_EN_VAL_DLA.STAP_VAL_CI_STATUS". -- kdande
*/
	IF IGS_EN_VAL_DLA.stap_val_ci_status (
			v_dla_cal_type,
			v_ci_sequence_number,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS', v_message_name);
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	-- Validate the unit version status.
	IF p_inserting OR
	    (p_updating AND
		(old_references.unit_cd <> new_references.unit_cd AND
		  old_references.version_number <> new_references.version_number)) THEN
		IF IGS_ST_VAL_ULA.stap_val_ula_uv_sts (
				new_references.unit_cd,
				new_references.version_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  procedure Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  as
  BEGIN

	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'CI_SEQUENCE_NUMBER' then
		new_references.ci_sequence_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'SECOND_PERCENTAGE' then
		new_references.second_percentage := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'DLA_CAL_TYPE' then
		new_references.dla_cal_type := column_value;
	ELSIF upper(Column_Name) = 'TEACH_CAL_TYPE' then
		new_references.teach_cal_type := column_value;
	ELSIF upper(Column_Name) = 'UNIT_CD' then
		new_references.unit_cd := column_value;
	ELSIF upper(Column_Name) = 'PERCENTAGE' then
		new_references.percentage := IGS_GE_NUMBER.to_num(column_value);
	END IF;

	IF upper(Column_Name) = 'CI_SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.ci_sequence_number < 1 OR new_references.ci_sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SECOND_PERCENTAGE' OR Column_Name IS NULL THEN
		IF new_references.second_percentage < 0 OR new_references.second_percentage > 100 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'DLA_CAL_TYPE' OR Column_Name IS NULL THEN
		IF new_references.dla_cal_type <> UPPER(new_references.dla_cal_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'TEACH_CAL_TYPE' OR Column_Name IS NULL THEN
		IF new_references.teach_cal_type <> UPPER(new_references.teach_cal_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'UNIT_CD' OR Column_Name IS NULL THEN
		IF new_references.unit_cd <> UPPER(new_references.unit_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'PERCENTAGE' OR Column_Name IS NULL THEN
		IF new_references.percentage < 0 OR new_references.percentage > 100 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.dla_cal_type = new_references.dla_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.teach_cal_type = new_references.teach_cal_type)) OR
        ((new_references.dla_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.teach_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_ST_DFT_LOAD_APPO_PKG.Get_PK_For_Validation (
        new_references.dla_cal_type,
        new_references.ci_sequence_number,
        new_references.teach_cal_type
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.teach_cal_type = new_references.teach_cal_type)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.teach_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_OFR_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.teach_cal_type
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
 	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

function Get_PK_For_Validation (
    x_dla_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
)return BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_UNT_LOAD_APPO
      WHERE    dla_cal_type = x_dla_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      teach_cal_type = x_teach_cal_type
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

  PROCEDURE get_fk_igs_st_dft_load_appo (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_UNT_LOAD_APPO
      WHERE    dla_cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      teach_cal_type = x_teach_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_ULA_DLA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_igs_st_dft_load_appo;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_UNT_LOAD_APPO
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      teach_cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_ULA_UO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dla_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_second_percentage IN NUMBER DEFAULT NULL,
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
      x_dla_cal_type,
      x_ci_sequence_number,
      x_unit_cd,
      x_version_number,
      x_teach_cal_type,
      x_percentage,
      x_second_percentage,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.dla_cal_type,
		new_references.ci_sequence_number,
		new_references.unit_cd,
		new_references.version_number,
		new_references.teach_cal_type
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.dla_cal_type,
		new_references.ci_sequence_number,
		new_references.unit_cd,
		new_references.version_number,
		new_references.teach_cal_type
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
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
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_ST_UNT_LOAD_APPO
      where DLA_CAL_TYPE = X_DLA_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and TEACH_CAL_TYPE = X_TEACH_CAL_TYPE;
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
     x_dla_cal_type => X_DLA_CAL_TYPE,
     x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
     x_unit_cd => X_UNIT_CD,
     x_version_number => X_VERSION_NUMBER,
     x_teach_cal_type => X_TEACH_CAL_TYPE,
     x_percentage => NVL(X_PERCENTAGE,100),
     x_second_percentage => X_SECOND_PERCENTAGE,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_ST_UNT_LOAD_APPO (
    DLA_CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    UNIT_CD,
    VERSION_NUMBER,
    TEACH_CAL_TYPE,
    PERCENTAGE,
    SECOND_PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.DLA_CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.TEACH_CAL_TYPE,
    NEW_REFERENCES.PERCENTAGE,
    NEW_REFERENCES.SECOND_PERCENTAGE,
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
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER
) as
  cursor c1 is select
      PERCENTAGE,
      SECOND_PERCENTAGE
    from IGS_ST_UNT_LOAD_APPO
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

  if ( (tlinfo.PERCENTAGE = X_PERCENTAGE)
      AND ((tlinfo.SECOND_PERCENTAGE = X_SECOND_PERCENTAGE)
           OR ((tlinfo.SECOND_PERCENTAGE is null)
               AND (X_SECOND_PERCENTAGE is null)))
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
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
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
     x_dla_cal_type => X_DLA_CAL_TYPE,
     x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
     x_unit_cd => X_UNIT_CD,
     x_version_number => X_VERSION_NUMBER,
     x_teach_cal_type => X_TEACH_CAL_TYPE,
     x_percentage => X_PERCENTAGE,
     x_second_percentage => X_SECOND_PERCENTAGE,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_ST_UNT_LOAD_APPO set
    PERCENTAGE = NEW_REFERENCES.PERCENTAGE,
    SECOND_PERCENTAGE = NEW_REFERENCES.SECOND_PERCENTAGE,
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
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_ST_UNT_LOAD_APPO
     where DLA_CAL_TYPE = X_DLA_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and TEACH_CAL_TYPE = X_TEACH_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DLA_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_TEACH_CAL_TYPE,
     X_PERCENTAGE,
     X_SECOND_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DLA_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_TEACH_CAL_TYPE,
   X_PERCENTAGE,
   X_SECOND_PERCENTAGE,
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
  delete from IGS_ST_UNT_LOAD_APPO
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_ST_UNT_LOAD_APPO_PKG;

/
