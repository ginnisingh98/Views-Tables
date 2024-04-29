--------------------------------------------------------
--  DDL for Package Body IGS_PS_STDNT_UNT_TRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_STDNT_UNT_TRN_PKG" as
/* $Header: IGSPI67B.pls 115.7 2003/07/23 07:11:34 kkillams ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_en_val_sut.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  --svanukur    29-apr-03       Added uoo-id as part of MUS build #2829262
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_PS_STDNT_UNT_TRN%RowType;
  new_references IGS_PS_STDNT_UNT_TRN%RowType;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_dt IN DATE DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_STDNT_UNT_TRN
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.transfer_course_cd := x_transfer_course_cd;
    new_references.transfer_dt := x_transfer_dt;
    new_references.unit_cd := x_unit_cd;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.uoo_id := x_uoo_id;
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
-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    Passed uoo_id to IGS_EN_VAL_SUT.enrp_val_sut_insert , IGS_EN_VAL_SUT.enrp_val_sut_delete
  --                           as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  PROCEDURE BeforeRowInsertDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_PS_STDNT_UNT_TRN') THEN
		-- Insert validation
		IF	p_inserting THEN
			IF IGS_EN_VAL_SUT.enrp_val_sut_insert (
				new_references.person_id,
				new_references.course_cd,
				new_references.transfer_course_cd,
				new_references.unit_cd,
				new_references.cal_type,
				new_references.ci_sequence_number,
				v_message_name,
                new_references.uoo_id) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
		--Delete validation
		IF	p_deleting THEN
			IF IGS_EN_VAL_SUT.enrp_val_sut_delete (
				old_references.person_id,
				old_references.course_cd,
				old_references.unit_cd,
				old_references.cal_type,
				old_references.ci_sequence_number,
				v_message_name,
                old_references.uoo_id) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'TRANSFER_COURSE_CD' then
     new_references.transfer_course_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd:= column_value;
 ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
 END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'TRANSFER_COURSE_CD' OR
     column_name is null Then
     IF new_references.transfer_course_cd <> UPPER(new_references.transfer_course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.cal_type <> UPPER(new_references.cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END check_constraints;


 PROCEDURE Check_Parent_Existance AS
 -------------------------------------------------------------------------------------------
 --Change History:
 --Who         When            What
 --KKILLAMS    27-07-2003      Passing transfer_course_cd instead of course_cd while call
 --                            IGS_EN_SU_ATTEMPT_PKG.Get_PK_For_Validation api w.r.t. bug 3064355
 -------------------------------------------------------------------------------------------
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.transfer_course_cd = new_references.transfer_course_cd) AND
         (old_references.transfer_dt = new_references.transfer_dt)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.transfer_course_cd IS NULL) OR
         (new_references.transfer_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_STDNT_TRN_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd,
        new_references.transfer_course_cd,
        new_references.transfer_dt
        ) THEN
		  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.transfer_course_cd = new_references.transfer_course_cd) AND
         (old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.transfer_course_cd IS NULL) OR
         (new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_SU_ATTEMPT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.transfer_course_cd,
        new_references.uoo_id
         ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_transfer_course_cd IN VARCHAR2,
    x_transfer_dt IN DATE,
    x_uoo_id IN NUMBER
     ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_UNT_TRN
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      transfer_course_cd = x_transfer_course_cd
      AND      transfer_dt = x_transfer_dt
      AND      uoo_id = x_uoo_id
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

  PROCEDURE GET_FK_IGS_PS_STDNT_TRN (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_transfer_course_cd IN VARCHAR2,
    x_transfer_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_UNT_TRN
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      transfer_course_cd = x_transfer_course_cd
      AND      transfer_dt = x_transfer_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SUT_SCT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_STDNT_TRN;

  PROCEDURE GET_FK_IGS_EN_SU_ATTEMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
     ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_UNT_TRN
      WHERE    person_id = x_person_id
      AND      transfer_course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
       ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SUT_SUA_TRANSFER_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_SU_ATTEMPT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_dt IN DATE DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_transfer_course_cd,
      x_transfer_dt,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_uoo_id
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
			    new_references.person_id,
			    new_references.course_cd,
			    new_references.transfer_course_cd,
			    new_references.transfer_dt,
			    new_references.uoo_id
			    	) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertDelete1 ( p_deleting => TRUE );
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
			    new_references.person_id,
			    new_references.course_cd,
			    new_references.transfer_course_cd,
			    new_references.transfer_dt,
			    new_references.uoo_id
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


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_PS_STDNT_UNT_TRN
      where PERSON_ID = X_PERSON_ID
      and TRANSFER_COURSE_CD = X_TRANSFER_COURSE_CD
      and COURSE_CD = X_COURSE_CD
      and UOO_ID = X_UOO_ID
      and TRANSFER_DT = X_TRANSFER_DT;
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
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_person_id => X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_transfer_course_cd => X_TRANSFER_COURSE_CD,
  x_transfer_dt => X_TRANSFER_DT,
  x_unit_cd => X_UNIT_CD,
  x_cal_type => X_CAL_TYPE,
  x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_uoo_id =>X_UOO_ID
  );

  insert into IGS_PS_STDNT_UNT_TRN (
    PERSON_ID,
    COURSE_CD,
    TRANSFER_COURSE_CD,
    TRANSFER_DT,
    UNIT_CD,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    UOO_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.TRANSFER_COURSE_CD,
    NEW_REFERENCES.TRANSFER_DT,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.UOO_ID
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
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_UOO_ID in NUMBER
) as
  cursor c1 is select ROWID
    from IGS_PS_STDNT_UNT_TRN
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
  X_ROWID IN VARCHAR2
) as
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_PS_STDNT_UNT_TRN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PS_STDNT_UNT_TRN_PKG;

/
