--------------------------------------------------------
--  DDL for Package Body IGS_ST_GVT_STDNT_LBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GVT_STDNT_LBL_PKG" as
/* $Header: IGSVI11B.pls 115.3 2002/11/29 04:33:33 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_ST_GVT_STDNT_LBL%RowType;
  new_references IGS_ST_GVT_STDNT_LBL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_total_eftsu IN NUMBER DEFAULT NULL,
    x_industrial_eftsu IN NUMBER DEFAULT NULL,
    x_hecs_prexmt_exie IN NUMBER DEFAULT NULL,
    x_hecs_amount_paid IN NUMBER DEFAULT NULL,
    x_tuition_fee IN NUMBER DEFAULT NULL,
    x_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_birth_dt IN DATE DEFAULT NULL,
    x_sex IN VARCHAR2 DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_citizenship_cd IN NUMBER DEFAULT NULL,
    x_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_perm_resident_cd IN NUMBER DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_GVT_STDNT_LBL
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
    new_references.submission_yr := x_submission_yr;
    new_references.submission_number := x_submission_number;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.govt_semester := x_govt_semester;
    new_references.hecs_payment_option := x_hecs_payment_option;
    new_references.govt_hecs_payment_option := x_govt_hecs_payment_option;
    new_references.total_eftsu := x_total_eftsu;
    new_references.industrial_eftsu := x_industrial_eftsu;
    new_references.hecs_prexmt_exie := x_hecs_prexmt_exie;
    new_references.hecs_amount_paid := x_hecs_amount_paid;
    new_references.tuition_fee := x_tuition_fee;
    new_references.differential_hecs_ind := x_differential_hecs_ind;
    new_references.birth_dt := x_birth_dt;
    new_references.sex := x_sex;
    new_references.citizenship_cd := x_citizenship_cd;
    new_references.govt_citizenship_cd := x_govt_citizenship_cd;
    new_references.perm_resident_cd := x_perm_resident_cd;
    new_references.govt_perm_resident_cd := x_govt_perm_resident_cd;
    new_references.commencement_dt := x_commencement_dt;
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
	v_message_name VARCHAR2(30);
	v_transaction_type		VARCHAR2(11);
	v_submission_yr		IGS_ST_GVT_STDNT_LBL.submission_yr%TYPE;
	v_submission_number	IGS_ST_GVT_STDNT_LBL.submission_number%TYPE;
  BEGIN
	IF p_inserting THEN
		v_transaction_type := 'p_inserting';
		v_submission_yr := new_references.submission_yr;
		v_submission_number := new_references.submission_number;
	ELSIF p_updating THEN
		v_transaction_type := 'p_updating';
		v_submission_yr := new_references.submission_yr;
		v_submission_number := new_references.submission_number;
	ELSIF p_deleting THEN
		v_transaction_type := 'p_deleting';
		v_submission_yr := old_references.submission_yr;
		v_submission_number := old_references.submission_number;
	END IF;
	IF IGS_ST_VAL_GSE.stap_val_govt_snpsht (
			v_submission_yr,
			v_submission_number,
			v_transaction_type,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS', v_message_name);
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

  END BeforeRowInsertUpdateDelete1;

  procedure Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  AS
  BEGIN
	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'TOTAL_EFTSU' then
		new_references.total_eftsu := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'HECS_PREXMT_EXIE' then
		new_references.hecs_prexmt_exie := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'TUITION_FEE' then
		new_references.tuition_fee := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'HECS_AMOUNT_PAID' then
		new_references.hecs_amount_paid := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'INDUSTRIAL_EFTSU' then
		new_references.industrial_eftsu := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'SUBMISSION_YR' then
		new_references.submission_yr := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_Name) = 'DIFFERENTIAL_HECS_IND' then
		new_references.differential_hecs_ind := column_value;
	END IF;

	IF upper(Column_Name) = 'TOTAL_EFTSU' OR Column_Name IS NULL THEN
		IF new_references.total_eftsu < 0000.000 OR new_references.total_eftsu > 9999.999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'HECS_PREXMT_EXIE' OR Column_Name IS NULL THEN
		IF new_references.hecs_prexmt_exie < 0000 OR new_references.hecs_prexmt_exie > 9999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'TUITION_FEE' OR Column_Name IS NULL THEN
		IF new_references.tuition_fee < 00000 OR new_references.tuition_fee > 99999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'HECS_AMOUNT_PAID' OR Column_Name IS NULL THEN
		IF new_references.hecs_amount_paid < 0000 OR new_references.hecs_amount_paid > 9999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'INDUSTRIAL_EFTSU' OR Column_Name IS NULL THEN
		IF new_references.industrial_eftsu < 0000.000 OR new_references.industrial_eftsu > 9999.999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUBMISSION_YR' OR Column_Name IS NULL THEN
		IF new_references.submission_yr < 0000 OR new_references.submission_yr > 9999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'DIFFERENTIAL_HECS_IND' OR Column_Name IS NULL THEN
		IF new_references.differential_hecs_ind NOT IN ('Y','N') THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

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
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

function Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_govt_semester IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_STDNT_LBL
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      govt_semester = x_govt_semester
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

  PROCEDURE GET_FK_IGS_ST_GOVT_SEMESTER (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_STDNT_LBL
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      govt_semester = x_govt_semester ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSLI_GSEM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_GOVT_SEMESTER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_total_eftsu IN NUMBER DEFAULT NULL,
    x_industrial_eftsu IN NUMBER DEFAULT NULL,
    x_hecs_prexmt_exie IN NUMBER DEFAULT NULL,
    x_hecs_amount_paid IN NUMBER DEFAULT NULL,
    x_tuition_fee IN NUMBER DEFAULT NULL,
    x_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_birth_dt IN DATE DEFAULT NULL,
    x_sex IN VARCHAR2 DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_citizenship_cd IN NUMBER DEFAULT NULL,
    x_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_perm_resident_cd IN NUMBER DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
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
      x_submission_yr,
      x_submission_number,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_govt_semester,
      x_hecs_payment_option,
      x_govt_hecs_payment_option,
      x_total_eftsu,
      x_industrial_eftsu,
      x_hecs_prexmt_exie,
      x_hecs_amount_paid,
      x_tuition_fee,
      x_differential_hecs_ind,
      x_birth_dt,
      x_sex,
      x_citizenship_cd,
      x_govt_citizenship_cd,
      x_perm_resident_cd,
      x_govt_perm_resident_cd,
      x_commencement_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.submission_yr,
		new_references.submission_number,
		new_references.person_id,
		new_references.course_cd,
		new_references.govt_semester
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
		new_references.submission_yr,
		new_references.submission_number,
		new_references.person_id,
		new_references.course_cd,
		new_references.govt_semester
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
  ) AS
  BEGIN
    l_rowid := x_rowid;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_GOVT_SEMESTER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_TOTAL_EFTSU in NUMBER,
  X_INDUSTRIAL_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_TUITION_FEE in NUMBER,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_COMMENCEMENT_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_ST_GVT_STDNT_LBL
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and GOVT_SEMESTER = X_GOVT_SEMESTER;
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
  Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
     x_submission_yr => X_SUBMISSION_YR,
     x_submission_number => X_SUBMISSION_NUMBER,
     x_person_id => X_PERSON_ID,
     x_course_cd => X_COURSE_CD,
     x_version_number => X_VERSION_NUMBER,
     x_govt_semester => X_GOVT_SEMESTER,
     x_hecs_payment_option => X_HECS_PAYMENT_OPTION,
     x_govt_hecs_payment_option => X_GOVT_HECS_PAYMENT_OPTION,
     x_total_eftsu => X_TOTAL_EFTSU,
     x_industrial_eftsu => X_INDUSTRIAL_EFTSU,
     x_hecs_prexmt_exie => X_HECS_PREXMT_EXIE,
     x_hecs_amount_paid => X_HECS_AMOUNT_PAID,
     x_tuition_fee => X_TUITION_FEE,
     x_differential_hecs_ind => X_DIFFERENTIAL_HECS_IND,
     x_birth_dt => X_BIRTH_DT,
     x_sex => X_SEX,
     x_citizenship_cd => X_CITIZENSHIP_CD,
     x_govt_citizenship_cd => X_GOVT_CITIZENSHIP_CD,
     x_perm_resident_cd => X_PERM_RESIDENT_CD,
     x_govt_perm_resident_cd => X_GOVT_PERM_RESIDENT_CD,
     x_commencement_dt => X_COMMENCEMENT_DT,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_ST_GVT_STDNT_LBL (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    PERSON_ID,
    COURSE_CD,
    VERSION_NUMBER,
    GOVT_SEMESTER,
    HECS_PAYMENT_OPTION,
    GOVT_HECS_PAYMENT_OPTION,
    TOTAL_EFTSU,
    INDUSTRIAL_EFTSU,
    HECS_PREXMT_EXIE,
    HECS_AMOUNT_PAID,
    TUITION_FEE,
    DIFFERENTIAL_HECS_IND,
    BIRTH_DT,
    SEX,
    CITIZENSHIP_CD,
    GOVT_CITIZENSHIP_CD,
    PERM_RESIDENT_CD,
    GOVT_PERM_RESIDENT_CD,
    COMMENCEMENT_DT,
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
    NEW_REFERENCES.SUBMISSION_YR,
    NEW_REFERENCES.SUBMISSION_NUMBER,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.GOVT_SEMESTER,
    NEW_REFERENCES.HECS_PAYMENT_OPTION,
    NEW_REFERENCES.GOVT_HECS_PAYMENT_OPTION,
    NEW_REFERENCES.TOTAL_EFTSU,
    NEW_REFERENCES.INDUSTRIAL_EFTSU,
    NEW_REFERENCES.HECS_PREXMT_EXIE,
    NEW_REFERENCES.HECS_AMOUNT_PAID,
    NEW_REFERENCES.TUITION_FEE,
    NEW_REFERENCES.DIFFERENTIAL_HECS_IND,
    NEW_REFERENCES.BIRTH_DT,
    NEW_REFERENCES.SEX,
    NEW_REFERENCES.CITIZENSHIP_CD,
    NEW_REFERENCES.GOVT_CITIZENSHIP_CD,
    NEW_REFERENCES.PERM_RESIDENT_CD,
    NEW_REFERENCES.GOVT_PERM_RESIDENT_CD,
    NEW_REFERENCES.COMMENCEMENT_DT,
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

  After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
    );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_GOVT_SEMESTER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_TOTAL_EFTSU in NUMBER,
  X_INDUSTRIAL_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_TUITION_FEE in NUMBER,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_COMMENCEMENT_DT in DATE
) AS
  cursor c1 is select
      VERSION_NUMBER,
      HECS_PAYMENT_OPTION,
      GOVT_HECS_PAYMENT_OPTION,
      TOTAL_EFTSU,
      INDUSTRIAL_EFTSU,
      HECS_PREXMT_EXIE,
      HECS_AMOUNT_PAID,
      TUITION_FEE,
      DIFFERENTIAL_HECS_IND,
      BIRTH_DT,
      SEX,
      CITIZENSHIP_CD,
      GOVT_CITIZENSHIP_CD,
      PERM_RESIDENT_CD,
      GOVT_PERM_RESIDENT_CD,
      COMMENCEMENT_DT
    from IGS_ST_GVT_STDNT_LBL
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

  if ( (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.HECS_PAYMENT_OPTION = X_HECS_PAYMENT_OPTION)
      AND (tlinfo.GOVT_HECS_PAYMENT_OPTION = X_GOVT_HECS_PAYMENT_OPTION)
      AND (tlinfo.TOTAL_EFTSU = X_TOTAL_EFTSU)
      AND (tlinfo.INDUSTRIAL_EFTSU = X_INDUSTRIAL_EFTSU)
      AND (tlinfo.HECS_PREXMT_EXIE = X_HECS_PREXMT_EXIE)
      AND (tlinfo.HECS_AMOUNT_PAID = X_HECS_AMOUNT_PAID)
      AND (tlinfo.TUITION_FEE = X_TUITION_FEE)
      AND (tlinfo.DIFFERENTIAL_HECS_IND = X_DIFFERENTIAL_HECS_IND)
      AND ((tlinfo.BIRTH_DT = X_BIRTH_DT)
           OR ((tlinfo.BIRTH_DT is null)
               AND (X_BIRTH_DT is null)))
      AND (tlinfo.SEX = X_SEX)
      AND (tlinfo.CITIZENSHIP_CD = X_CITIZENSHIP_CD)
      AND (tlinfo.GOVT_CITIZENSHIP_CD = X_GOVT_CITIZENSHIP_CD)
      AND (tlinfo.PERM_RESIDENT_CD = X_PERM_RESIDENT_CD)
      AND (tlinfo.GOVT_PERM_RESIDENT_CD = X_GOVT_PERM_RESIDENT_CD)
      AND (tlinfo.COMMENCEMENT_DT = X_COMMENCEMENT_DT)
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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_GOVT_SEMESTER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_TOTAL_EFTSU in NUMBER,
  X_INDUSTRIAL_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_TUITION_FEE in NUMBER,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_COMMENCEMENT_DT in DATE,
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
  Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
     x_submission_yr => X_SUBMISSION_YR,
     x_submission_number => X_SUBMISSION_NUMBER,
     x_person_id => X_PERSON_ID,
     x_course_cd => X_COURSE_CD,
     x_version_number => X_VERSION_NUMBER,
     x_govt_semester => X_GOVT_SEMESTER,
     x_hecs_payment_option => X_HECS_PAYMENT_OPTION,
     x_govt_hecs_payment_option => X_GOVT_HECS_PAYMENT_OPTION,
     x_total_eftsu => X_TOTAL_EFTSU,
     x_industrial_eftsu => X_INDUSTRIAL_EFTSU,
     x_hecs_prexmt_exie => X_HECS_PREXMT_EXIE,
     x_hecs_amount_paid => X_HECS_AMOUNT_PAID,
     x_tuition_fee => X_TUITION_FEE,
     x_differential_hecs_ind => X_DIFFERENTIAL_HECS_IND,
     x_birth_dt => X_BIRTH_DT,
     x_sex => X_SEX,
     x_citizenship_cd => X_CITIZENSHIP_CD,
     x_govt_citizenship_cd => X_GOVT_CITIZENSHIP_CD,
     x_perm_resident_cd => X_PERM_RESIDENT_CD,
     x_govt_perm_resident_cd => X_GOVT_PERM_RESIDENT_CD,
     x_commencement_dt => X_COMMENCEMENT_DT,
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
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  end if;

  update IGS_ST_GVT_STDNT_LBL set
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    HECS_PAYMENT_OPTION = NEW_REFERENCES.HECS_PAYMENT_OPTION,
    GOVT_HECS_PAYMENT_OPTION = NEW_REFERENCES.GOVT_HECS_PAYMENT_OPTION,
    TOTAL_EFTSU = NEW_REFERENCES.TOTAL_EFTSU,
    INDUSTRIAL_EFTSU = NEW_REFERENCES.INDUSTRIAL_EFTSU,
    HECS_PREXMT_EXIE = NEW_REFERENCES.HECS_PREXMT_EXIE,
    HECS_AMOUNT_PAID = NEW_REFERENCES.HECS_AMOUNT_PAID,
    TUITION_FEE = NEW_REFERENCES.TUITION_FEE,
    DIFFERENTIAL_HECS_IND = NEW_REFERENCES.DIFFERENTIAL_HECS_IND,
    BIRTH_DT = NEW_REFERENCES.BIRTH_DT,
    SEX = NEW_REFERENCES.SEX,
    CITIZENSHIP_CD = NEW_REFERENCES.CITIZENSHIP_CD,
    GOVT_CITIZENSHIP_CD = NEW_REFERENCES.GOVT_CITIZENSHIP_CD,
    PERM_RESIDENT_CD = NEW_REFERENCES.PERM_RESIDENT_CD,
    GOVT_PERM_RESIDENT_CD = NEW_REFERENCES.GOVT_PERM_RESIDENT_CD,
    COMMENCEMENT_DT = NEW_REFERENCES.COMMENCEMENT_DT,
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
  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_GOVT_SEMESTER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_TOTAL_EFTSU in NUMBER,
  X_INDUSTRIAL_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_TUITION_FEE in NUMBER,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_COMMENCEMENT_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_ST_GVT_STDNT_LBL
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
     and PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and GOVT_SEMESTER = X_GOVT_SEMESTER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SUBMISSION_YR,
     X_SUBMISSION_NUMBER,
     X_PERSON_ID,
     X_COURSE_CD,
     X_GOVT_SEMESTER,
     X_VERSION_NUMBER,
     X_HECS_PAYMENT_OPTION,
     X_GOVT_HECS_PAYMENT_OPTION,
     X_TOTAL_EFTSU,
     X_INDUSTRIAL_EFTSU,
     X_HECS_PREXMT_EXIE,
     X_HECS_AMOUNT_PAID,
     X_TUITION_FEE,
     X_DIFFERENTIAL_HECS_IND,
     X_BIRTH_DT,
     X_SEX,
     X_CITIZENSHIP_CD,
     X_GOVT_CITIZENSHIP_CD,
     X_PERM_RESIDENT_CD,
     X_GOVT_PERM_RESIDENT_CD,
     X_COMMENCEMENT_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUBMISSION_YR,
   X_SUBMISSION_NUMBER,
   X_PERSON_ID,
   X_COURSE_CD,
   X_GOVT_SEMESTER,
   X_VERSION_NUMBER,
   X_HECS_PAYMENT_OPTION,
   X_GOVT_HECS_PAYMENT_OPTION,
   X_TOTAL_EFTSU,
   X_INDUSTRIAL_EFTSU,
   X_HECS_PREXMT_EXIE,
   X_HECS_AMOUNT_PAID,
   X_TUITION_FEE,
   X_DIFFERENTIAL_HECS_IND,
   X_BIRTH_DT,
   X_SEX,
   X_CITIZENSHIP_CD,
   X_GOVT_CITIZENSHIP_CD,
   X_PERM_RESIDENT_CD,
   X_GOVT_PERM_RESIDENT_CD,
   X_COMMENCEMENT_DT,
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
  delete from IGS_ST_GVT_STDNT_LBL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_ST_GVT_STDNT_LBL_PKG;

/
