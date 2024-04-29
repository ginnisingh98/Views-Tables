--------------------------------------------------------
--  DDL for Package Body IGS_PS_FIELD_STUDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_FIELD_STUDY_PKG" AS
 /* $Header: IGSPI13B.pls 120.1 2006/07/25 15:11:10 sommukhe noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_FIELD_STUDY%RowType;
  new_references IGS_PS_FIELD_STUDY%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_major_field_ind IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_FIELD_STUDY
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.field_of_study := x_field_of_study;
    new_references.major_field_ind := x_major_field_ind;
    new_references.percentage := x_percentage;
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
  -- "OSS_TST".trg_cfos_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PS_FIELD_STUDY
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
	v_course_cd	IGS_PS_FIELD_STUDY.course_cd%TYPE;
	v_version_number	IGS_PS_FIELD_STUDY.version_number%TYPE;
	v_major_field_ind	IGS_PS_FIELD_STUDY.major_field_ind%TYPE;
	v_percentage	IGS_PS_FIELD_STUDY.percentage%TYPE;
  BEGIN

	-- Set variables.
	IF p_deleting THEN
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl (
			v_course_cd,
			v_version_number,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	-- Validate field of study.  Field of study is not updateable.
	IF p_inserting THEN
		IF IGS_PS_VAL_CFOS.crsp_val_cfos_fos (
				new_references.field_of_study,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Insert history record on update.
	IF p_updating THEN
		IF old_references.percentage <> new_references.percentage OR
				old_references.major_field_ind <> new_references.major_field_ind THEN
			SELECT	DECODE(old_references.percentage,new_references.percentage,NULL,old_references.percentage),
				DECODE(old_references.major_field_ind,new_references.major_field_ind,NULL,old_references.major_field_ind)
			INTO	v_percentage,
				v_major_field_ind
			FROM	dual;
			-- Create history record for update
			IGS_PS_GEN_002.CRSP_INS_CFOS_HIST(
				old_references.course_cd,
				old_references.version_number,
				old_references.field_of_study,
				old_references.last_update_date,
				new_references.last_update_date,
				old_references.last_updated_by,
				v_percentage,
				v_major_field_ind);
		END IF;
	END IF;
	IF p_deleting THEN
		-- Create history record for deletion
		IGS_PS_GEN_002.CRSP_INS_CFOS_HIST(
			old_references.course_cd,
			old_references.version_number,
			old_references.field_of_study,
			old_references.last_update_date,
			SYSDATE,
			old_references.last_updated_by,
			old_references.percentage,
			old_references.major_field_ind);
	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	DEFAULT NULL,
 Column_Value 	IN VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

	IF column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.course_cd := column_value;
	ELSIF upper(Column_name) = 'FIELD_OF_STUDY' then
	    new_references.field_of_study := column_value;
	ELSIF upper(Column_name) = 'MAJOR_FIELD_IND' then
	    new_references.major_field_ind := column_value;
	ELSIF upper(Column_name) = 'PERCENTAGE' then
	    new_references.percentage := IGS_GE_NUMBER.TO_NUM(column_value);
     END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
        ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.field_of_study = new_references.field_of_study)) OR
        ((new_references.field_of_study IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_FLD_OF_STUDY_PKG.Get_PK_For_Validation (
        new_references.field_of_study
        ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_field_of_study IN VARCHAR2
    )
    RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FIELD_STUDY
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      field_of_study = x_field_of_study
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

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FIELD_STUDY
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CFOS_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_major_field_ind IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_field_of_study,
      x_major_field_ind,
      x_percentage,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
      new_references.course_cd ,
      new_references.version_number ,
      new_references.field_of_study) THEN
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
	IF  Get_PK_For_Validation (
      new_references.course_cd ,
      new_references.version_number ,
      new_references.field_of_study) THEN
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

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MAJOR_FIELD_IND in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_FIELD_STUDY
      where COURSE_CD = X_COURSE_CD
      and FIELD_OF_STUDY = X_FIELD_OF_STUDY
      and VERSION_NUMBER = X_VERSION_NUMBER;
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
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_major_field_ind => NVL(X_MAJOR_FIELD_IND,'Y') ,
    x_percentage => X_PERCENTAGE ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_FIELD_STUDY (
    COURSE_CD,
    VERSION_NUMBER,
    FIELD_OF_STUDY,
    MAJOR_FIELD_IND,
    PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.FIELD_OF_STUDY,
    NEW_REFERENCES.MAJOR_FIELD_IND,
    NEW_REFERENCES.PERCENTAGE,
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
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MAJOR_FIELD_IND in VARCHAR2,
  X_PERCENTAGE in NUMBER
) AS
  cursor c1 is select
      MAJOR_FIELD_IND,
      PERCENTAGE
    from IGS_PS_FIELD_STUDY
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

  if ( (tlinfo.MAJOR_FIELD_IND = X_MAJOR_FIELD_IND)
       AND(tlinfo.PERCENTAGE IS NULL OR tlinfo.PERCENTAGE = X_PERCENTAGE)
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
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MAJOR_FIELD_IND in VARCHAR2,
  X_PERCENTAGE in NUMBER,
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
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_major_field_ind => X_MAJOR_FIELD_IND ,
    x_percentage => X_PERCENTAGE ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_PS_FIELD_STUDY set
    MAJOR_FIELD_IND = NEW_REFERENCES.MAJOR_FIELD_IND,
    PERCENTAGE = NEW_REFERENCES.PERCENTAGE,
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
  X_COURSE_CD in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MAJOR_FIELD_IND in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_FIELD_STUDY
     where COURSE_CD = X_COURSE_CD
     and FIELD_OF_STUDY = X_FIELD_OF_STUDY
     and VERSION_NUMBER = X_VERSION_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_FIELD_OF_STUDY,
     X_VERSION_NUMBER,
     X_MAJOR_FIELD_IND,
     X_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_FIELD_OF_STUDY,
   X_VERSION_NUMBER,
   X_MAJOR_FIELD_IND,
   X_PERCENTAGE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
  delete from IGS_PS_FIELD_STUDY
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_FIELD_STUDY_PKG;

/
