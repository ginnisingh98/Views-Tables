--------------------------------------------------------
--  DDL for Package Body IGS_AD_ADM_UT_STT_LD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ADM_UT_STT_LD_PKG" as
/* $Header: IGSAI03B.pls 115.7 2003/10/30 13:18:43 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_ADM_UT_STT_LD%RowType;
  new_references IGS_AD_ADM_UT_STT_LD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_load_incurred_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) IS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_ADM_UT_STT_LD
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
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.teach_cal_type := x_teach_cal_type;
    new_references.load_incurred_ind := x_load_incurred_ind;
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
  -- "OSS_TST".TRG_AUSL_BR_IUD
  -- BEFORE  INSERT  OR UPDATE  OR DELETE  ON IGS_AD_ADM_UT_STT_LD
  -- REFERENCING
  --  NEW AS NEW
  --  OLD AS OLD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) IS
	v_message_name		VARCHAR2(30);
	v_cal_type		IGS_AD_ADM_UT_STT_LD.cal_type%TYPE;
	v_ci_sequence_number	IGS_AD_ADM_UT_STT_LD.ci_sequence_number%TYPE;
  BEGIN
	IF p_inserting OR p_updating THEN
		v_cal_type := new_references.cal_type;
		v_ci_sequence_number := new_references.ci_sequence_number;
	ELSE
		v_cal_type := old_references.cal_type;
		v_ci_sequence_number := old_references.ci_sequence_number;
	END IF;
	-- Validate if insert, update or delete is allowed.
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_EN_VAL_AUSL.STAP_VAL_CI_STATUS" to program unit "IGS_EN_VAL_DLA.STAP_VAL_CI_STATUS". -- kdande
*/
	IF IGS_EN_VAL_DLA.stap_val_ci_status (
			v_cal_type,
			v_ci_sequence_number,
			v_message_name) = FALSE THEN

		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_AUS_CLOSED(new_references.administrative_unit_status
						,v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_AUSL.ENRP_VAL_AUSL_AUS(new_references.administrative_unit_status
						,v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	    END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;


  PROCEDURE Check_Parent_Existance IS
  BEGIN

    IF (((old_references.administrative_unit_status =
          new_references.administrative_unit_status)) OR
        ((new_references.administrative_unit_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_ADM_UNIT_STAT_PKG.Get_PK_For_Validation (
        new_references.administrative_unit_status,'N' ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.teach_cal_type = new_references.teach_cal_type)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.teach_cal_type IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_ST_DFT_LOAD_APPO_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.teach_cal_type       ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
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
      ELSIF upper(Column_Name) = 'ADMINISTRATIVE_UNIT_STATUS' THEN
	   new_references.administrative_unit_status := column_value ;
      ELSIF upper(Column_Name) = 'CAL_TYPE' THEN
	   new_references.cal_type := column_value ;
      ELSIF upper(Column_Name) = 'LOAD_INCURRED_IND' THEN
	   new_references.load_incurred_ind := column_value ;
      ELSIF upper(Column_Name) = 'TEACH_CAL_TYPE' THEN
	   new_references.teach_cal_type := column_value ;
  	END IF;

      IF upper(Column_Name) = 'ADMINISTRATIVE_UNIT_STATUS' OR
	   Column_name IS NULL THEN
         IF new_references.administrative_unit_status <> upper(new_references.administrative_unit_status) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;
      IF upper(Column_Name) = 'CAL_TYPE' OR
	   Column_name IS NULL THEN
         IF new_references.cal_type <> upper(new_references.cal_type) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;
      IF upper(Column_Name) = 'TEACH_CAL_TYPE' OR
	   Column_name IS NULL THEN
         IF new_references.teach_cal_type <> upper(new_references.teach_cal_type) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;
	IF upper(Column_Name) = 'LOAD_INCURRED_IND' OR
	   Column_name IS NULL THEN
         IF new_references.load_incurred_ind NOT IN ('Y','N') THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
	   END IF;
      END IF;
 END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_administrative_unit_status IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_ADM_UT_STT_LD
      WHERE    administrative_unit_status = x_administrative_unit_status
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      teach_cal_type = x_teach_cal_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (True);
    ELSE
      Close cur_rowid;
      Return (False);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_ST_DFT_LOAD_APPO (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    ) IS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_ADM_UT_STT_LD
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      teach_cal_type = x_teach_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUSL_DLA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_DFT_LOAD_APPO;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_load_incurred_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) IS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_administrative_unit_status,
      x_cal_type,
      x_ci_sequence_number,
      x_teach_cal_type,
      x_load_incurred_ind,
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
         new_references.administrative_unit_status ,
         new_references.cal_type,
         new_references.ci_sequence_number,
         new_references.teach_cal_type ) THEN

         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
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

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
    	IF Get_PK_For_Validation (
         new_references.administrative_unit_status ,
         new_references.cal_type,
         new_references.ci_sequence_number,
         new_references.teach_cal_type ) THEN

         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_constraints;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGS_AD_ADM_UT_STT_LD
      where ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
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
    x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
    x_teach_cal_type => X_TEACH_CAL_TYPE,
    x_load_incurred_ind => Nvl(X_LOAD_INCURRED_IND, 'Y'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AD_ADM_UT_STT_LD (
    ADMINISTRATIVE_UNIT_STATUS,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    TEACH_CAL_TYPE,
    LOAD_INCURRED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ADMINISTRATIVE_UNIT_STATUS,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.TEACH_CAL_TYPE,
    NEW_REFERENCES.LOAD_INCURRED_IND,
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
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2
) is
  cursor c1 is select
      LOAD_INCURRED_IND
    from IGS_AD_ADM_UT_STT_LD
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

  if ( (tlinfo.LOAD_INCURRED_IND = X_LOAD_INCURRED_IND)
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
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
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
    x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
    x_teach_cal_type => X_TEACH_CAL_TYPE,
    x_load_incurred_ind => X_LOAD_INCURRED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_ADM_UT_STT_LD set
    LOAD_INCURRED_IND = NEW_REFERENCES.LOAD_INCURRED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID ;
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
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
  cursor c1 is select rowid from IGS_AD_ADM_UT_STT_LD
     where ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS
     and CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and TEACH_CAL_TYPE = X_TEACH_CAL_TYPE  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ADMINISTRATIVE_UNIT_STATUS,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_TEACH_CAL_TYPE,
     X_LOAD_INCURRED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADMINISTRATIVE_UNIT_STATUS,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_TEACH_CAL_TYPE,
   X_LOAD_INCURRED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) is
begin

Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
 );
  delete from IGS_AD_ADM_UT_STT_LD
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
 );
end DELETE_ROW;

end IGS_AD_ADM_UT_STT_LD_PKG;

/
