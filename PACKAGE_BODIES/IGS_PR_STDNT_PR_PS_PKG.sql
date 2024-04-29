--------------------------------------------------------
--  DDL for Package Body IGS_PR_STDNT_PR_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_STDNT_PR_PS_PKG" AS
/* $Header: IGSQI16B.pls 120.0 2005/07/05 13:03:18 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_STDNT_PR_PS%RowType;
  new_references IGS_PR_STDNT_PR_PS%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_spo_course_cd IN VARCHAR2 DEFAULT NULL,
    x_spo_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_STDNT_PR_PS
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.spo_course_cd := x_spo_course_cd;
    new_references.spo_sequence_number := x_spo_sequence_number;
    new_references.course_cd := x_course_cd;
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
  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd)) OR
        ((new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_COURSE_PKG.Get_PK_For_Validation (
        new_references.course_cd
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.spo_course_cd = new_references.spo_course_cd) AND
         (old_references.spo_sequence_number = new_references.spo_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.spo_course_cd IS NULL) OR
         (new_references.spo_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_STDNT_PR_OU_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.spo_course_cd,
        new_references.spo_sequence_number
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_spo_course_cd IN VARCHAR2,
    x_spo_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_PS
      WHERE    person_id = x_person_id
      AND      spo_course_cd = x_spo_course_cd
      AND      spo_sequence_number = x_spo_sequence_number
      AND      course_cd = x_course_cd
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

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_PS
      WHERE    course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPC_CRS_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_COURSE;

  PROCEDURE GET_FK_IGS_PR_STDNT_PR_OU (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_STDNT_PR_PS
      WHERE    person_id = x_person_id
      AND      spo_course_cd = x_course_cd
      AND      spo_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPC_SPO_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_STDNT_PR_OU;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_spo_course_cd IN VARCHAR2 DEFAULT NULL,
    x_spo_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_spo_course_cd,
      x_spo_sequence_number,
      x_course_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       Check_Parent_Existance;
	IF GET_PK_FOR_VALIDATION(
		    new_references.person_id,
		    new_references.spo_course_cd,
		    new_references.spo_sequence_number,
		    new_references.course_cd)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       Check_Parent_Existance;
	CHECK_CONSTRAINTS;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		    new_references.person_id,
		    new_references.spo_course_cd,
		    new_references.spo_sequence_number,
		    new_references.course_cd)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	CHECK_CONSTRAINTS;

    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PR_STDNT_PR_PS
      where PERSON_ID = X_PERSON_ID
      and SPO_COURSE_CD = X_SPO_COURSE_CD
      and SPO_SEQUENCE_NUMBER = X_SPO_SEQUENCE_NUMBER
      and COURSE_CD = X_COURSE_CD;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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
    x_rowid => x_rowid ,
    x_person_id => x_person_id ,
    x_spo_course_cd => x_spo_course_cd ,
    x_spo_sequence_number => x_spo_sequence_number ,
    x_course_cd => x_course_cd ,
    x_creation_date => x_last_update_date ,
    x_created_by => X_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => X_last_updated_by ,
    x_last_update_login =>x_last_update_login
  ) ;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_PR_STDNT_PR_PS (
    PERSON_ID,
    SPO_COURSE_CD,
    SPO_SEQUENCE_NUMBER,
    COURSE_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SPO_COURSE_CD,
    NEW_REFERENCES.SPO_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2
) AS
  cursor c1 is select
    rowid,
    PERSON_ID ,
    SPO_COURSE_CD ,
    SPO_SEQUENCE_NUMBER ,
    COURSE_CD
    from IGS_PR_STDNT_PR_PS
    where  ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	close c1;
    app_exception.raise_exception;

    return;
  end if;
  close c1;


  if (
  (tlinfo.PERSON_ID = X_PERSON_ID) AND
  (tlinfo.SPO_COURSE_CD =X_SPO_COURSE_CD) AND
  (tlinfo.SPO_SEQUENCE_NUMBER = X_SPO_SEQUENCE_NUMBER) AND
  (tlinfo.COURSE_CD = X_COURSE_CD)
  )
  then
  	null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;

end LOCK_ROW;




procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_PR_STDNT_PR_PS
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'SPO_SEQUENCE_NUMBER' THEN
  new_references.SPO_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
ELSIF upper(Column_name) = 'SPO_COURSE_CD' THEN
  new_references.SPO_COURSE_CD:= COLUMN_VALUE ;
ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;
END IF ;

IF upper(Column_name) = 'SPO_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SPO_SEQUENCE_NUMBER < 1 or new_references.SPO_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'SPO_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SPO_COURSE_CD<> upper(new_references.SPO_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
  END IF;
IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints;


end IGS_PR_STDNT_PR_PS_PKG;

/
