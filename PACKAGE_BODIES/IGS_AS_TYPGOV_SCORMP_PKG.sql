--------------------------------------------------------
--  DDL for Package Body IGS_AS_TYPGOV_SCORMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_TYPGOV_SCORMP_PKG" AS
/* $Header: IGSDI24B.pls 115.4 2003/10/30 13:27:46 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AS_TYPGOV_SCORMP%RowType;
  new_references IGS_AS_TYPGOV_SCORMP%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_institution_score IN NUMBER DEFAULT NULL,
    x_govt_score IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_TYPGOV_SCORMP
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action  NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	        Close cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.scndry_edu_ass_type := x_scndry_edu_ass_type;
    new_references.result_obtained_yr := x_result_obtained_yr;
    new_references.institution_score := x_institution_score;
    new_references.govt_score := x_govt_score;
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
    IF (((old_references.scndry_edu_ass_type = new_references.scndry_edu_ass_type)) OR
        ((new_references.scndry_edu_ass_type IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AD_AUSE_ED_AS_TY_PKG.Get_PK_For_Validation (
        new_references.scndry_edu_ass_type ,
            'N'
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
  END Check_Parent_Existance;

  FUNCTION  Get_PK_For_Validation (
    x_scndry_edu_ass_type IN VARCHAR2,
    x_result_obtained_yr IN NUMBER,
    x_institution_score IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_TYPGOV_SCORMP
      WHERE    scndry_edu_ass_type = x_scndry_edu_ass_type
      AND      result_obtained_yr = x_result_obtained_yr
      AND      institution_score = x_institution_score
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
END IF;  END Get_PK_For_Validation;



  PROCEDURE GET_FK_IGS_AD_AUSE_ED_AS_TY (
    x_aus_scndry_edu_ass_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_TYPGOV_SCORMP
      WHERE    scndry_edu_ass_type = x_aus_scndry_edu_ass_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_ATGSM_ASEAT_FK');
      IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_AUSE_ED_AS_TY;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_institution_score IN NUMBER DEFAULT NULL,
    x_govt_score IN NUMBER DEFAULT NULL,
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
      x_scndry_edu_ass_type,
      x_result_obtained_yr,
      x_institution_score,
      x_govt_score,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

	IF  Get_PK_For_Validation (
NEW_REFERENCES.scndry_edu_ass_type,
NEW_REFERENCES.result_obtained_yr ,
    NEW_REFERENCES.institution_score) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;

      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

	     Check_Constraints;
      Check_Parent_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	         NEW_REFERENCES.scndry_edu_ass_type,
NEW_REFERENCES.result_obtained_yr ,
    NEW_REFERENCES.institution_score) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	      Check_Constraints;




    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_TYPGOV_SCORMP
      where SCNDRY_EDU_ASS_TYPE = X_SCNDRY_EDU_ASS_TYPE
      and RESULT_OBTAINED_YR = X_RESULT_OBTAINED_YR
      and INSTITUTION_SCORE = X_INSTITUTION_SCORE;
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_govt_score=>X_GOVT_SCORE,
 x_institution_score=>X_INSTITUTION_SCORE,
 x_result_obtained_yr=>X_RESULT_OBTAINED_YR,
 x_scndry_edu_ass_type=>X_SCNDRY_EDU_ASS_TYPE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_TYPGOV_SCORMP (
    SCNDRY_EDU_ASS_TYPE,
    RESULT_OBTAINED_YR,
    INSTITUTION_SCORE,
    GOVT_SCORE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SCNDRY_EDU_ASS_TYPE,
    NEW_REFERENCES.RESULT_OBTAINED_YR,
    NEW_REFERENCES.INSTITUTION_SCORE,
    NEW_REFERENCES.GOVT_SCORE,
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

end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER
) AS
  cursor c1 is select
      GOVT_SCORE
    from IGS_AS_TYPGOV_SCORMP
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.GOVT_SCORE = X_GOVT_SCORE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER,
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_govt_score=>X_GOVT_SCORE,
 x_institution_score=>X_INSTITUTION_SCORE,
 x_result_obtained_yr=>X_RESULT_OBTAINED_YR,
 x_scndry_edu_ass_type=>X_SCNDRY_EDU_ASS_TYPE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_AS_TYPGOV_SCORMP set
    GOVT_SCORE = NEW_REFERENCES.GOVT_SCORE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_TYPGOV_SCORMP
     where SCNDRY_EDU_ASS_TYPE = X_SCNDRY_EDU_ASS_TYPE
     and RESULT_OBTAINED_YR = X_RESULT_OBTAINED_YR
     and INSTITUTION_SCORE = X_INSTITUTION_SCORE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SCNDRY_EDU_ASS_TYPE,
     X_RESULT_OBTAINED_YR,
     X_INSTITUTION_SCORE,
     X_GOVT_SCORE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SCNDRY_EDU_ASS_TYPE,
   X_RESULT_OBTAINED_YR,
   X_INSTITUTION_SCORE,
   X_GOVT_SCORE,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_TYPGOV_SCORMP
 where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	AS
	BEGIN
	IF  column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'SCNDRY_EDU_ASS_TYPE' then
	    new_references.SCNDRY_EDU_ASS_TYPE := column_value;
      END IF;


IF upper(column_name) = 'SCNDRY_EDU_ASS_TYPE'  OR
     column_name is null Then
     IF new_references.SCNDRY_EDU_ASS_TYPE <> UPPER(new_references.SCNDRY_EDU_ASS_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


	END Check_Constraints;

end IGS_AS_TYPGOV_SCORMP_PKG;

/
