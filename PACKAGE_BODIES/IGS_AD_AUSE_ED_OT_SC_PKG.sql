--------------------------------------------------------
--  DDL for Package Body IGS_AD_AUSE_ED_OT_SC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_AUSE_ED_OT_SC_PKG" as
/* $Header: IGSAI50B.pls 115.4 2002/11/28 22:07:50 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_AUSE_ED_OT_SC%RowType;
  new_references IGS_AD_AUSE_ED_OT_SC%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_score_type IN VARCHAR2 DEFAULT NULL,
    x_score IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ase_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_AUSE_ED_OT_SC
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.result_obtained_yr := x_result_obtained_yr;
    new_references.score_type := x_score_type;
    new_references.score := x_score;
    new_references.person_id := x_person_id;
    new_references.ase_sequence_number := x_ase_sequence_number;
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

  PROCEDURE Check_Constraints (






    Column_Name IN VARCHAR2 DEFAULT NULL,






    Column_Value IN VARCHAR2 DEFAULT NULL






  )






  AS






  BEGIN






	IF Column_Name is null then






		NULL;






	ELSIF upper(Column_Name) = 'SCORE_TYPE' then






		new_references.score_type := column_value;






	ELSIF upper(Column_Name) = 'ASE_SEQUENCE_NUMBER' then






		new_references.ase_sequence_number := igs_ge_number.to_num(column_value);






	ELSIF upper(Column_Name) = 'RESULT_OBTAINED_YR' then






		new_references.result_obtained_yr := igs_ge_number.to_num(column_value);






	END IF;













    IF ((UPPER (column_name) = 'SCORE_TYPE') OR (column_name IS NULL)) THEN






      IF (new_references.score_type <> UPPER (new_references.score_type)) THEN






        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;





        App_Exception.Raise_Exception;






      END IF;






    END IF;






   IF ((UPPER (column_name) = 'ASE_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN






      IF ((new_references.ase_sequence_number < 1) OR (new_references.ase_sequence_number > 9999999999)) THEN






        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;






        App_Exception.Raise_Exception;






      END IF;






    END IF;






    IF ((UPPER (column_name) = 'RESULT_OBTAINED_YR') OR (column_name IS NULL)) THEN






      IF ((new_references.result_obtained_yr < 1900) OR (new_references.result_obtained_yr  > 2050)) THEN






        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;






        App_Exception.Raise_Exception;






      END IF;






    END IF;













  END Check_Constraints;







  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ase_sequence_number = new_references.ase_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ase_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_AUS_SEC_EDU_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.ase_sequence_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ase_sequence_number IN NUMBER,
    x_result_obtained_yr IN NUMBER,
    x_score_type IN VARCHAR2
)return BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUSE_ED_OT_SC
      WHERE    person_id = x_person_id
      AND      ase_sequence_number = x_ase_sequence_number
      AND      result_obtained_yr = x_result_obtained_yr
      AND      score_type = x_score_type
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

  PROCEDURE GET_FK_IGS_AD_AUS_SEC_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUSE_ED_OT_SC
      WHERE    person_id = x_person_id
      AND      ase_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASEOS_ASE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_AUS_SEC_EDU;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_score_type IN VARCHAR2 DEFAULT NULL,
    x_score IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ase_sequence_number IN NUMBER DEFAULT NULL,
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
      x_result_obtained_yr,
      x_score_type,
      x_score,
      x_person_id,
      x_ase_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.ase_sequence_number,
		new_references.result_obtained_yr,
		new_references.score_type
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.ase_sequence_number,
		new_references.result_obtained_yr,
		new_references.score_type
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_AUSE_ED_OT_SC
      where PERSON_ID = X_PERSON_ID
      and ASE_SEQUENCE_NUMBER = X_ASE_SEQUENCE_NUMBER
      and RESULT_OBTAINED_YR = X_RESULT_OBTAINED_YR
      and SCORE_TYPE = X_SCORE_TYPE;
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
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_ase_sequence_number=>X_ASE_SEQUENCE_NUMBER,
   x_person_id=>X_PERSON_ID,
   x_result_obtained_yr=>X_RESULT_OBTAINED_YR,
   x_score=>X_SCORE,
   x_score_type=>X_SCORE_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_AUSE_ED_OT_SC (
    PERSON_ID,
    ASE_SEQUENCE_NUMBER,
    RESULT_OBTAINED_YR,
    SCORE_TYPE,
    SCORE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ASE_SEQUENCE_NUMBER,
    NEW_REFERENCES.RESULT_OBTAINED_YR,
    NEW_REFERENCES.SCORE_TYPE,
    NEW_REFERENCES.SCORE,
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
    x_rowid => X_ROWID);


end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2
) AS
  cursor c1 is select
      SCORE
    from IGS_AD_AUSE_ED_OT_SC
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.SCORE = X_SCORE)
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
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2,
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

  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_ase_sequence_number=>X_ASE_SEQUENCE_NUMBER,
   x_person_id=>X_PERSON_ID,
   x_result_obtained_yr=>X_RESULT_OBTAINED_YR,
   x_score=>X_SCORE,
   x_score_type=>X_SCORE_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_AD_AUSE_ED_OT_SC set
    SCORE = NEW_REFERENCES.SCORE,
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
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_AUSE_ED_OT_SC
     where PERSON_ID = X_PERSON_ID
     and ASE_SEQUENCE_NUMBER = X_ASE_SEQUENCE_NUMBER
     and RESULT_OBTAINED_YR = X_RESULT_OBTAINED_YR
     and SCORE_TYPE = X_SCORE_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ASE_SEQUENCE_NUMBER,
     X_RESULT_OBTAINED_YR,
     X_SCORE_TYPE,
     X_SCORE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ASE_SEQUENCE_NUMBER,
   X_RESULT_OBTAINED_YR,
   X_SCORE_TYPE,
   X_SCORE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_AUSE_ED_OT_SC
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_AUSE_ED_OT_SC_PKG;

/
