--------------------------------------------------------
--  DDL for Package Body IGS_ST_DFT_LOAD_APPO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_DFT_LOAD_APPO_PKG" as
 /* $Header: IGSVI02B.pls 115.3 2002/11/29 04:31:06 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_ST_DFT_LOAD_APPO%RowType;
  new_references IGS_ST_DFT_LOAD_APPO%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
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
      FROM     IGS_ST_DFT_LOAD_APPO
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
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
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
	v_message_name		varchar2(30);
	v_cal_type		IGS_ST_DFT_LOAD_APPO.cal_type%TYPE;
	v_ci_sequence_number	IGS_ST_DFT_LOAD_APPO.ci_sequence_number%TYPE;
  BEGIN
	IF p_inserting OR p_updating THEN
		v_cal_type := new_references.cal_type;
		v_ci_sequence_number := new_references.ci_sequence_number;
	ELSE
		v_cal_type := old_references.cal_type;
		v_ci_sequence_number := old_references.ci_sequence_number;
	END IF;
	-- Validate if insert, update or delete is allowed.
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
	    IF	IGS_EN_VAL_DLA.ENRP_VAL_DLA_CAT_LD(new_references.cal_type
						,v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS',v_message_name);
					IGS_GE_MSG_STACK.ADD;
                  			App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_DLA.ENRP_VAL_DLA_CAT(new_references.teach_cal_type
						,v_message_name) = FALSE THEN
				   	Fnd_Message.Set_Name('IGS',v_message_name);
					IGS_GE_MSG_STACK.ADD;
                  			App_Exception.Raise_Exception;
	    END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    DEFAULT NULL ,
                 Column_Value    IN   VARCHAR2    DEFAULT NULL
                                )  as
Begin
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CAL_TYPE' THEN
  new_references.CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'TEACH_CAL_TYPE' THEN
  new_references.TEACH_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PERCENTAGE' THEN
  new_references.PERCENTAGE:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SECOND_PERCENTAGE' THEN
  new_references.SECOND_PERCENTAGE:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.CAL_TYPE<> upper(new_references.CAL_TYPE) then
    	Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
    	App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'TEACH_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.TEACH_CAL_TYPE<> upper(new_references.TEACH_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PERCENTAGE' OR COLUMN_NAME IS NULL THEN
  IF new_references.PERCENTAGE < 0 or new_references.PERCENTAGE > 100 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SECOND_PERCENTAGE' OR COLUMN_NAME IS NULL THEN
  IF new_references.SECOND_PERCENTAGE < 0 or new_references.SECOND_PERCENTAGE > 100 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

 END Check_Constraints;



  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.teach_cal_type = new_references.teach_cal_type)) OR
        ((new_references.teach_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.cal_type
          ) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number
        ) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;
   END IF;
   END IF ;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AD_ADM_UT_STT_LD_PKG.GET_FK_IGS_ST_DFT_LOAD_APPO (
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.teach_cal_type
      );

    IGS_ST_GVTSEMLOAD_OV_PKG.GET_FK_IGS_ST_DFT_LOAD_APPO (
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.teach_cal_type
      );

    IGS_ST_UNT_LOAD_APPO_PKG.GET_FK_IGS_ST_DFT_LOAD_APPO (
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.teach_cal_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    ) RETURN BOOLEAN
  as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_DFT_LOAD_APPO
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      teach_cal_type = x_teach_cal_type
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

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_DFT_LOAD_APPO
      WHERE    teach_cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_DLA_CAT_FK');
		IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_TYPE;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_DFT_LOAD_APPO
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_DLA_CI_FK');
		IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
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
      x_cal_type,
      x_ci_sequence_number,
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
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
       IF  Get_PK_For_Validation (
          new_references.cal_type ,
          new_references.ci_sequence_number ,
          new_references.teach_cal_type
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
      Check_Child_Existance;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
        new_references.cal_type ,
          new_references.ci_sequence_number ,
          new_references.teach_cal_type
           ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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


  END After_DML;



procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_ST_DFT_LOAD_APPO
      where CAL_TYPE = X_CAL_TYPE
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


 Before_DML(
    p_action=>'INSERT' ,
    x_rowid=>X_ROWID ,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER ,
    x_teach_cal_type => X_TEACH_CAL_TYPE,
    x_percentage => NVL(X_PERCENTAGE,100) ,
    x_second_percentage => X_SECOND_PERCENTAGE ,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );

  insert into IGS_ST_DFT_LOAD_APPO (
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    TEACH_CAL_TYPE,
    PERCENTAGE,
    SECOND_PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
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

After_DML(
  p_action=>'INSERT',
  x_rowid=> X_ROWID
         );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER
) as
  cursor c1 is select
      PERCENTAGE,
      SECOND_PERCENTAGE
    from IGS_ST_DFT_LOAD_APPO
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
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
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

 Before_DML(
    p_action=>'UPDATE' ,
    x_rowid=>X_ROWID ,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER ,
    x_teach_cal_type => X_TEACH_CAL_TYPE,
    x_percentage => X_PERCENTAGE ,
    x_second_percentage => X_SECOND_PERCENTAGE ,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );


  update IGS_ST_DFT_LOAD_APPO set
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

After_DML(
  p_action=>'UPDATE',
  x_rowid=> X_ROWID
         );


end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_ST_DFT_LOAD_APPO
     where CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and TEACH_CAL_TYPE = X_TEACH_CAL_TYPE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_TEACH_CAL_TYPE,
     X_PERCENTAGE,
     X_SECOND_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_TEACH_CAL_TYPE,
   X_PERCENTAGE,
   X_SECOND_PERCENTAGE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
   X_ROWID in VARCHAR2
) as
begin

 Before_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );

  delete from IGS_ST_DFT_LOAD_APPO
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


 After_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );


end DELETE_ROW;

end IGS_ST_DFT_LOAD_APPO_PKG;

/
