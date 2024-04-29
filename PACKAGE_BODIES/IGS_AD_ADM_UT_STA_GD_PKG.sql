--------------------------------------------------------
--  DDL for Package Body IGS_AD_ADM_UT_STA_GD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ADM_UT_STA_GD_PKG" AS
/* $Header: IGSAI02B.pls 115.6 2003/10/30 13:18:35 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_ADM_UT_STA_GD%RowType;
  new_references IGS_AD_ADM_UT_STA_GD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_ADM_UT_STA_GD
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
    new_references.administrative_unit_status := x_administrative_unit_status;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.version_number := x_version_number;
    new_references.grade := x_grade;
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
    ) IS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_AUS_CLOSED(new_references.administrative_unit_status
						,v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_AUS_DISCONT(new_references.administrative_unit_status
						,v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_AUSG.ENRP_VAL_AUSG_GS(new_references.grading_schema_cd
						,new_references.version_number
						,v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	    END IF;
	END IF;

  END BeforeRowInsertUpdate1;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.administrative_unit_status = new_references.administrative_unit_status)) OR
        ((new_references.administrative_unit_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_ADM_UNIT_STAT_PKG.Get_PK_For_Validation (new_references.administrative_unit_status,'N')  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.grade = new_references.grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.grade IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_GRD_SCH_GRADE_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.version_number,
        new_references.grade ) THEN
        Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Constraints (
			Column_Name IN VARCHAR2 DEFAULT NULL,
			Column_Value IN VARCHAR2 DEFAULT NULL
			) AS

  BEGIN
      IF Column_Name IS NULL THEN
	   NULL;
	ELSIF upper(Column_Name) = 'VERSION_NUMBER' THEN
	   new_references.version_number := igs_ge_number.to_num(column_value) ;
      ELSIF upper(Column_Name) = 'ADMINISTRATIVE_UNIT_STATUS' THEN
	   new_references.administrative_unit_status := column_value ;
      ELSIF upper(Column_Name) = 'GRADE' THEN
	   new_references.grade := column_value ;
      ELSIF upper(Column_Name) = 'GRADING_SCHEMA_CD' THEN
	   new_references.grading_schema_cd := column_value ;
  	END IF;

	IF upper(Column_Name) = 'VERSION_NUMBER' OR
	   Column_name IS NULL THEN
         IF new_references.version_number < 0 OR
            new_references.version_number > 999 THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
	   END IF;
	END IF;
      IF upper(Column_Name) = 'ADMINISTRATIVE_UNIT_STATUS' OR
	   Column_name IS NULL THEN
         IF new_references.administrative_unit_status <> upper(new_references.administrative_unit_status) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;
      IF upper(Column_Name) = 'GRADE' OR
	   Column_name IS NULL THEN
         IF new_references.grade <> upper(new_references.grade) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;
      IF upper(Column_Name) = 'GRADING_SCHEMA_CD' OR
	   Column_name IS NULL THEN
         IF new_references.grading_schema_cd <> upper(new_references.grading_schema_cd ) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;

  END Check_Constraints;

  FUNCTION Get_PK_For_Validation ( x_administrative_unit_status IN VARCHAR2,
					     x_grading_schema_cd IN VARCHAR2,
					     x_version_number IN NUMBER,
					     x_grade IN VARCHAR2) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_ADM_UT_STA_GD
      WHERE    administrative_unit_status = x_administrative_unit_status
      AND      grading_schema_cd = x_grading_schema_cd
      AND      version_number = x_version_number
      AND      grade = x_grade
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (True) ;
    ELSE
      Close cur_rowid;
      Return (False) ;
    END IF;

  END Get_PK_For_Validation;


  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_ADM_UT_STA_GD
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      version_number = x_version_number
      AND      grade = x_grade ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUSG_GSG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_GRD_SCH_GRADE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
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
      x_administrative_unit_status,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
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
         new_references.administrative_unit_status ,
         new_references.grading_schema_cd ,
         new_references.version_number ,
         new_references.grade ) THEN

         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
         new_references.administrative_unit_status ,
         new_references.grading_schema_cd ,
         new_references.version_number ,
         new_references.grade ) THEN

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
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_ADM_UT_STA_GD
      where ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS
      and GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and GRADE = X_GRADE;
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
    x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
    x_grading_schema_cd => X_GRADING_SCHEMA_CD,
    x_version_number => X_VERSION_NUMBER,
    x_grade => X_GRADE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AD_ADM_UT_STA_GD (
    ADMINISTRATIVE_UNIT_STATUS,
    GRADING_SCHEMA_CD,
    VERSION_NUMBER,
    GRADE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ADMINISTRATIVE_UNIT_STATUS,
    X_GRADING_SCHEMA_CD,
    X_VERSION_NUMBER,
    X_GRADE,
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
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2
) AS
  cursor c1 is select ROWID
    from IGS_AD_ADM_UT_STA_GD
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

  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_AD_ADM_UT_STA_GD
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_AD_ADM_UT_STA_GD_PKG;

/
