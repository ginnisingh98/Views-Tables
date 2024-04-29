--------------------------------------------------------
--  DDL for Package Body IGS_AD_AUS_SEC_EDU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_AUS_SEC_EDU_PKG" AS
/* $Header: IGSAI39B.pls 115.5 2003/10/30 13:20:24 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_AUS_SEC_EDU%RowType;
  new_references IGS_AD_AUS_SEC_EDU%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_score IN NUMBER DEFAULT NULL,
    x_aus_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_candidate_number IN NUMBER DEFAULT NULL,
    x_secondary_school_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_AUS_SEC_EDU
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
    new_references.person_id := x_person_id;
    new_references.sequence_number := x_sequence_number;
    new_references.state_cd := x_state_cd;
    new_references.result_obtained_yr := x_result_obtained_yr;
    new_references.score := x_score;
    new_references.aus_scndry_edu_ass_type := x_aus_scndry_edu_ass_type;
    new_references.candidate_number := x_candidate_number;
    new_references.secondary_school_cd := x_secondary_school_cd;
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
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate if result_obtained_yr is specified then score and
	-- IGS_AS_ASSESSMNT_TYP must be specified.
	IF p_inserting OR p_updating THEN
		IF IGS_AD_VAL_ASE.admp_val_ase_scoreat(
					new_references.result_obtained_yr,
					new_references.score,
					new_references.aus_scndry_edu_ass_type,
					v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
                         IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;






		END IF;
	END IF;
	-- Validate that the state_cd is the same as the state_cd of
	-- the aus_scndry_edu_ass_type state_cd.
	IF p_inserting
	OR (old_references.state_cd <> new_references.state_cd)
	OR (old_references.aus_scndry_edu_ass_type <> new_references.aus_scndry_edu_ass_type)
	OR (old_references.aus_scndry_edu_ass_type IS NULL AND
		new_references.aus_scndry_edu_ass_type IS NOT NULL) THEN
		IF IGS_AD_VAL_ASE.admp_val_ase_atstate(
					new_references.state_cd,
					new_references.aus_scndry_edu_ass_type,
					v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
		         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate that the state_cd is the same as the state_cd of
	-- the secondary_school_cd state_cd.
	IF p_inserting
	OR (old_references.state_cd <> new_references.state_cd)
	OR (old_references.secondary_school_cd <> new_references.secondary_school_cd)
	OR (old_references.secondary_school_cd IS NULL AND
		new_references.secondary_school_cd IS NOT NULL) THEN
		IF IGS_AD_VAL_ASE.admp_val_ase_scstate(
					new_references.state_cd,
					new_references.secondary_school_cd,
					v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
                         IGS_GE_MSG_STACK.ADD;





                     App_Exception.Raise_Exception;






		END IF;
	END IF;
	-- Validate that the aus_scndry_edu_ass_type in not closed.
	IF p_inserting
	OR (old_references.aus_scndry_edu_ass_type <> new_references.aus_scndry_edu_ass_type)
	OR (old_references.aus_scndry_edu_ass_type IS NULL AND
		new_references.aus_scndry_edu_ass_type IS NOT NULL) THEN
		IF IGS_AD_VAL_ASE.admp_val_aseatclosed(
					new_references.aus_scndry_edu_ass_type,
					v_message_name) = FALSE THEN
			         Fnd_Message.Set_Name('IGS',v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  Begin
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' Then
     		new_references.sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'RESULT_OBTAINED_YR' Then
     		new_references.result_obtained_yr := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'STATE_CD' Then
     		new_references.state_cd := column_value;
	ELSIF upper(Column_name) = 'AUS_SCNDRY_EDU_ASS_TYPE' Then
     		new_references.aus_scndry_edu_ass_type := column_value;
	ELSIF upper(Column_name) = 'SECONDARY_SCHOOL_CD' Then
     		new_references.secondary_school_cd := column_value;
	ELSIF upper(Column_name) = 'SCORE' Then
     		new_references.score := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'CANDIDATE_NUMBER' Then
     		new_references.candidate_number := igs_ge_number.to_num(column_value);
	END IF;
   IF ((UPPER (column_name) = 'SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.sequence_number < 1) OR (new_references.sequence_number > 9999999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RESULT_OBTAINED_YR ') OR (column_name IS NULL)) THEN
      IF ((new_references.result_obtained_yr  < 1900) OR (new_references.result_obtained_yr  > 2050)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'AUS_SCNDRY_EDU_ASS_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.aus_scndry_edu_ass_type <> UPPER (new_references.aus_scndry_edu_ass_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SECONDARY_SCHOOL_CD') OR (column_name IS NULL)) THEN
      IF (new_references.secondary_school_cd <> UPPER (new_references.secondary_school_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'STATE_CD') OR (column_name IS NULL)) THEN
      IF (new_references.state_cd <> UPPER (new_references.state_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SCORE') OR (column_name IS NULL)) THEN
      IF ((new_references.score < 0) OR (new_references.score > 999.999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'CANDIDATE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.candidate_number < 1) OR (new_references.candidate_number > 999999999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
   End Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.aus_scndry_edu_ass_type = new_references.aus_scndry_edu_ass_type)) OR
        ((new_references.aus_scndry_edu_ass_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_AUSE_ED_AS_TY_PKG.Get_PK_For_Validation (
        new_references.aus_scndry_edu_ass_type,
        'N'
        ) THEN
    		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
    		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.secondary_school_cd = new_references.secondary_school_cd)) OR
        ((new_references.secondary_school_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_AUS_SEC_ED_SC_PKG.Get_PK_For_Validation (
        new_references.secondary_school_cd,
        'N'
        ) THEN
     		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ) THEN
     		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_AUSE_ED_OT_SC_PKG.GET_FK_IGS_AD_AUS_SEC_EDU (
      old_references.person_id,
      old_references.sequence_number
      );

    IGS_AD_AUS_SEC_ED_SU_PKG.GET_FK_IGS_AD_AUS_SEC_EDU (
      old_references.person_id,
      old_references.sequence_number
      );

  END Check_Child_Existance;

  Function Get_PK_For_Validation (







    x_person_id IN NUMBER,







    x_sequence_number IN NUMBER)







  RETURN BOOLEAN  AS







	CURSOR cur_rowid IS







      	SELECT   rowid







      	FROM     IGS_AD_AUS_SEC_EDU







      	WHERE    person_id = x_person_id







      	AND      sequence_number = x_sequence_number







      	FOR UPDATE NOWAIT;















	lv_rowid cur_rowid%RowType;







  BEGIN  -- Get_PK_For_Validation







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















  PROCEDURE GET_FK_IGS_AD_AUSE_ED_AS_TY (
    x_aus_scndry_edu_ass_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_EDU
      WHERE    aus_scndry_edu_ass_type = x_aus_scndry_edu_ass_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASE_ASEAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_AUSE_ED_AS_TY;

  PROCEDURE GET_FK_IGS_AD_AUS_SEC_ED_SC (
    x_secondary_school_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_EDU
      WHERE    secondary_school_cd = x_secondary_school_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASE_ASES_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_AUS_SEC_ED_SC;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_EDU
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASE_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_score IN NUMBER DEFAULT NULL,
    x_aus_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_candidate_number IN NUMBER DEFAULT NULL,
    x_secondary_school_cd IN VARCHAR2 DEFAULT NULL,
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
      x_sequence_number,
      x_state_cd,
      x_result_obtained_yr,
      x_score,
      x_aus_scndry_edu_ass_type,
      x_candidate_number,
      x_secondary_school_cd,
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
		new_references.person_id,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_STATE_CD in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE in NUMBER,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_AUS_SEC_EDU
      where PERSON_ID = X_PERSON_ID
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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

 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_aus_scndry_edu_ass_type=>X_AUS_SCNDRY_EDU_ASS_TYPE,
  x_candidate_number=>X_CANDIDATE_NUMBER,
  x_person_id=>X_PERSON_ID,
  x_result_obtained_yr=>X_RESULT_OBTAINED_YR,
  x_score=>X_SCORE,
  x_secondary_school_cd=>X_SECONDARY_SCHOOL_CD,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_state_cd=>X_STATE_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_AUS_SEC_EDU (
    PERSON_ID,
    SEQUENCE_NUMBER,
    STATE_CD,
    RESULT_OBTAINED_YR,
    SCORE,
    AUS_SCNDRY_EDU_ASS_TYPE,
    CANDIDATE_NUMBER,
    SECONDARY_SCHOOL_CD,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.STATE_CD,
    NEW_REFERENCES.RESULT_OBTAINED_YR,
    NEW_REFERENCES.SCORE,
    NEW_REFERENCES.AUS_SCNDRY_EDU_ASS_TYPE,
    NEW_REFERENCES.CANDIDATE_NUMBER,
    NEW_REFERENCES.SECONDARY_SCHOOL_CD,
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
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_STATE_CD in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE in NUMBER,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SECONDARY_SCHOOL_CD in VARCHAR2
) AS
  cursor c1 is select
      STATE_CD,
      RESULT_OBTAINED_YR,
      SCORE,
      AUS_SCNDRY_EDU_ASS_TYPE,
      CANDIDATE_NUMBER,
      SECONDARY_SCHOOL_CD
    from IGS_AD_AUS_SEC_EDU
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

  if ( (tlinfo.STATE_CD = X_STATE_CD)
      AND ((tlinfo.RESULT_OBTAINED_YR = X_RESULT_OBTAINED_YR)
           OR ((tlinfo.RESULT_OBTAINED_YR is null)
               AND (X_RESULT_OBTAINED_YR is null)))
      AND ((tlinfo.SCORE = X_SCORE)
           OR ((tlinfo.SCORE is null)
               AND (X_SCORE is null)))
      AND ((tlinfo.AUS_SCNDRY_EDU_ASS_TYPE = X_AUS_SCNDRY_EDU_ASS_TYPE)
           OR ((tlinfo.AUS_SCNDRY_EDU_ASS_TYPE is null)
               AND (X_AUS_SCNDRY_EDU_ASS_TYPE is null)))
      AND ((tlinfo.CANDIDATE_NUMBER = X_CANDIDATE_NUMBER)
           OR ((tlinfo.CANDIDATE_NUMBER is null)
               AND (X_CANDIDATE_NUMBER is null)))
      AND ((tlinfo.SECONDARY_SCHOOL_CD = X_SECONDARY_SCHOOL_CD)
           OR ((tlinfo.SECONDARY_SCHOOL_CD is null)
               AND (X_SECONDARY_SCHOOL_CD is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_STATE_CD in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE in NUMBER,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
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

 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_aus_scndry_edu_ass_type=>X_AUS_SCNDRY_EDU_ASS_TYPE,
  x_candidate_number=>X_CANDIDATE_NUMBER,
  x_person_id=>X_PERSON_ID,
  x_result_obtained_yr=>X_RESULT_OBTAINED_YR,
  x_score=>X_SCORE,
  x_secondary_school_cd=>X_SECONDARY_SCHOOL_CD,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_state_cd=>X_STATE_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

update IGS_AD_AUS_SEC_EDU set
    STATE_CD = NEW_REFERENCES.STATE_CD,
    RESULT_OBTAINED_YR = NEW_REFERENCES.RESULT_OBTAINED_YR,
    SCORE = NEW_REFERENCES.SCORE,
    AUS_SCNDRY_EDU_ASS_TYPE = NEW_REFERENCES.AUS_SCNDRY_EDU_ASS_TYPE,
    CANDIDATE_NUMBER = NEW_REFERENCES.CANDIDATE_NUMBER,
    SECONDARY_SCHOOL_CD = NEW_REFERENCES.SECONDARY_SCHOOL_CD,
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
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_STATE_CD in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE in NUMBER,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_CANDIDATE_NUMBER in NUMBER,
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_AUS_SEC_EDU
     where PERSON_ID = X_PERSON_ID
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_SEQUENCE_NUMBER,
     X_STATE_CD,
     X_RESULT_OBTAINED_YR,
     X_SCORE,
     X_AUS_SCNDRY_EDU_ASS_TYPE,
     X_CANDIDATE_NUMBER,
     X_SECONDARY_SCHOOL_CD,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_STATE_CD,
   X_RESULT_OBTAINED_YR,
   X_SCORE,
   X_AUS_SCNDRY_EDU_ASS_TYPE,
   X_CANDIDATE_NUMBER,
   X_SECONDARY_SCHOOL_CD,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_AUS_SEC_EDU
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_AUS_SEC_EDU_PKG;

/
