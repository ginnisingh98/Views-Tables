--------------------------------------------------------
--  DDL for Package Body IGS_ST_GVTSEMLOAD_CA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GVTSEMLOAD_CA_PKG" as
 /* $Header: IGSVI03B.pls 115.4 2002/11/29 04:31:24 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_ST_GVTSEMLOAD_CA%RowType;
  new_references IGS_ST_GVTSEMLOAD_CA%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_GVTSEMLOAD_CA
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
    new_references.submission_yr := x_submission_yr;
    new_references.submission_number := x_submission_number;
    new_references.govt_semester := x_govt_semester;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
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
	v_submission_yr		IGS_ST_GVTSEMLOAD_CA.submission_yr%TYPE;
	v_submission_number	IGS_ST_GVTSEMLOAD_CA.submission_number%TYPE;
  BEGIN
	IF p_inserting OR p_updating THEN
		v_submission_yr := new_references.submission_yr;
		v_submission_number := new_references.submission_number;
	ELSE
		v_submission_yr := old_references.submission_yr;
		v_submission_number := old_references.submission_number;
	END IF;
	-- Validate if insert, update or delete is allowed.
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_ST_VAL_GSLC.STAP_VAL_GSC_SDT_UPD" to program unit "IGS_ST_VAL_GSC.STAP_VAL_GSC_SDT_UPD". -- kdande
*/
	IF IGS_ST_VAL_GSC.stap_val_gsc_sdt_upd (
			v_submission_yr,
			v_submission_number,
			v_message_name) = FALSE THEN
		--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(2029));
        	  	Fnd_Message.Set_Name('IGS','IGS_EN_PRSN_NOTHAVE_APP_GOVT');
	      		IGS_GE_MSG_STACK.ADD;
                     	App_Exception.Raise_Exception;
	END IF;
	-- Validate the calendar.
	IF p_inserting OR
	    (p_updating AND
		(old_references.cal_type <> new_references.cal_type AND
		  old_references.ci_sequence_number <> new_references.ci_sequence_number)) THEN
		IF IGS_ST_VAL_GSLC.stap_val_gslc (
				new_references.cal_type,
				new_references.ci_sequence_number,
				v_message_name) = FALSE THEN
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

ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' THEN
  new_references.CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SUBMISSION_YR' THEN
  new_references.SUBMISSION_YR:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.CAL_TYPE<> upper(new_references.CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.CI_SEQUENCE_NUMBER < 1 or new_references.CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SUBMISSION_YR' OR COLUMN_NAME IS NULL THEN
  IF new_references.SUBMISSION_YR < 0 or new_references.SUBMISSION_YR > 9999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


 END Check_Constraints;



  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT  IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number
        )  THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.submission_yr = new_references.submission_yr) AND
         (old_references.submission_number = new_references.submission_number) AND
         (old_references.govt_semester = new_references.govt_semester)) OR
        ((new_references.submission_yr IS NULL) OR
         (new_references.submission_number IS NULL) OR
         (new_references.govt_semester IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_ST_GOVT_SEMESTER_PKG.Get_PK_For_Validation (
        new_references.submission_yr,
        new_references.submission_number,
        new_references.govt_semester
        ) THEN
    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;
   END IF;
  END IF;
  END Check_Parent_Existance;

PROCEDURE  CHECK_UNIQUENESS as
   Begin

   IF  GET_UK1_FOR_VALIDATION (
    new_references.submission_yr ,
    new_references.submission_number ,
    new_references.cal_type ,
    new_references.ci_sequence_number
     )  THEN
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
   END IF;
   End  CHECK_UNIQUENESS ;


  FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN
  as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVTSEMLOAD_CA
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      govt_semester = x_govt_semester
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVTSEMLOAD_CA
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSLC_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_ST_GOVT_SEMESTER (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVTSEMLOAD_CA
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      govt_semester = x_govt_semester ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSLC_GSEM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_GOVT_SEMESTER;

FUNCTION  GET_UK1_FOR_VALIDATION (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_cal_type  VARCHAR2,
    x_ci_sequence_number NUMBER )
RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVTSEMLOAD_CA
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      l_rowid  is null or rowid <> l_rowid
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

END  GET_UK1_FOR_VALIDATION ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
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
      x_submission_yr,
      x_submission_number,
      x_govt_semester,
      x_cal_type,
      x_ci_sequence_number,
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
        new_references.submission_yr ,
        new_references.submission_number ,
        new_references.govt_semester ,
        new_references.cal_type ,
        new_references.ci_sequence_number
            ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
      ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
       Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
      ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
        new_references.submission_yr ,
        new_references.submission_number ,
        new_references.govt_semester ,
        new_references.cal_type ,
        new_references.ci_sequence_number
            ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Uniqueness;
       Check_Constraints;

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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_GOVT_SEMESTER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_ST_GVTSEMLOAD_CA
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and GOVT_SEMESTER = X_GOVT_SEMESTER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER;
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
    x_submission_yr => X_SUBMISSION_YR,
    x_submission_number => X_SUBMISSION_NUMBER,
    x_govt_semester => X_GOVT_SEMESTER,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  ) ;

  insert into IGS_ST_GVTSEMLOAD_CA (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    GOVT_SEMESTER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SUBMISSION_YR,
    NEW_REFERENCES.SUBMISSION_NUMBER,
    NEW_REFERENCES.GOVT_SEMESTER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_GOVT_SEMESTER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER
) as
  cursor c1 is select ROWID
    from IGS_ST_GVTSEMLOAD_CA
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

  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

  delete from IGS_ST_GVTSEMLOAD_CA
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_ST_GVTSEMLOAD_CA_PKG;

/
