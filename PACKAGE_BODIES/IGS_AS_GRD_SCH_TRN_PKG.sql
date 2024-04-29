--------------------------------------------------------
--  DDL for Package Body IGS_AS_GRD_SCH_TRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GRD_SCH_TRN_PKG" AS
 /* $Header: IGSDI15B.pls 115.6 2003/12/09 11:29:51 ijeddy ship $ */
l_rowid VARCHAR2(25);
  old_references IGS_AS_GRD_SCH_TRN_ALL%RowType;
  new_references IGS_AS_GRD_SCH_TRN_ALL%RowType;
 PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_to_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_to_version_number IN NUMBER DEFAULT NULL,
    x_to_grade IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_GRD_SCH_TRN_ALL
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
    new_references.org_id := x_org_id;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.version_number := x_version_number;
    new_references.grade := x_grade;
    new_references.to_grading_schema_cd := x_to_grading_schema_cd;
    new_references.to_version_number := x_to_version_number;
    new_references.to_grade := x_to_grade;
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
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
		--<GSGT0002>
		-- Validate grade may not be translated against another grade in same ver
		IF  IGS_AS_VAL_GSGT.assp_val_gsgt_gs_gs (
						new_references.grading_schema_cd,
						new_references.version_number,
						new_references.to_grading_schema_cd,
						new_references.to_version_number,
						v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		--<GSGT0004>
		-- Validate rslt type for grade is same as rslt type for xlation grade
--ijeddy, this is now treated as a warning instead of an error, bug no 3216979
--		IF  IGS_AS_VAL_GSGT.assp_val_gsgt_result (
--						new_references.grading_schema_cd,
--						new_references.version_number,
--						new_references.grade,
--						new_references.to_grading_schema_cd,
--						new_references.to_version_number,
--						new_references.to_grade,
--						v_message_name) = FALSE THEN
--			FND_MESSAGE.SET_NAME('IGS',v_message_name);
--                        IGS_GE_MSG_STACK.ADD;
--			APP_EXCEPTION.RAISE_EXCEPTION;
--		END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_gsgt_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_GRD_SCH_TRN
  -- FOR EACH ROW
  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
    v_message_name	VARCHAR2(30);
  BEGIN
	IF  p_inserting OR p_updating THEN
      	IF IGS_AS_VAL_GSGT.assp_val_gsgt_multi (
  				new_references.grading_schema_cd,
  				new_references.version_number,
  				new_references.grade,
  				new_references.to_grading_schema_cd,
  				new_references.to_version_number,
  				new_references.to_grade,
  					v_message_name) = FALSE THEN
  		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
	END IF;
  END AfterRowInsertUpdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_gsgt_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_GRD_SCH_TRN
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.grade = new_references.grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.grade IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_GRD_SCH_GRADE_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.version_number,
        new_references.grade
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.to_grading_schema_cd = new_references.to_grading_schema_cd) AND
         (old_references.to_version_number = new_references.to_version_number) OR
         (old_references.to_grade = new_references.to_grade)) OR
        ((new_references.to_grading_schema_cd IS NULL) OR
         (new_references.to_version_number IS NULL) OR
         (new_references.to_grade IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_GRD_SCH_GRADE_PKG.Get_PK_For_Validation (
        new_references.to_grading_schema_cd,
        new_references.to_version_number,
        new_references.to_grade
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2,
    x_to_grading_schema_cd IN VARCHAR2,
    x_to_version_number IN NUMBER,
    x_to_grade IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_GRD_SCH_TRN_ALL
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      version_number = x_version_number
      AND      grade = x_grade
      AND      to_grading_schema_cd = x_to_grading_schema_cd
      AND      to_version_number = x_to_version_number
      AND      to_grade = x_to_grade
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
  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_GRD_SCH_TRN_ALL
      WHERE    to_grading_schema_cd = x_grading_schema_cd
      AND      to_version_number = x_version_number
      AND      to_grade = x_grade  OR
                (grading_schema_cd = x_grading_schema_cd
                  AND      version_number = x_version_number
                  AND      grade = x_grade ) ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_GSGT_GSG_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_GRD_SCH_GRADE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_to_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_to_version_number IN NUMBER DEFAULT NULL,
    x_to_grade IN VARCHAR2 DEFAULT NULL,
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
      x_org_id,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
      x_to_grading_schema_cd,
      x_to_version_number,
      x_to_grade,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      	IF  Get_PK_For_Validation (
	         NEW_REFERENCES.grading_schema_cd ,
    NEW_REFERENCES.version_number ,
    NEW_REFERENCES.grade ,
    NEW_REFERENCES.to_grading_schema_cd ,
    NEW_REFERENCES.to_version_number,
    NEW_REFERENCES.to_grade) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;


      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;


	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
       NEW_REFERENCES.grading_schema_cd ,
    NEW_REFERENCES.version_number ,
    NEW_REFERENCES.grade ,
    NEW_REFERENCES.to_grading_schema_cd ,
    NEW_REFERENCES.to_version_number,
    NEW_REFERENCES.to_grade) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  X_ORG_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_TO_GRADING_SCHEMA_CD in VARCHAR2,
  X_TO_VERSION_NUMBER in NUMBER,
  X_TO_GRADE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_GRD_SCH_TRN_ALL
      where GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and GRADE = X_GRADE
      and TO_GRADING_SCHEMA_CD = X_TO_GRADING_SCHEMA_CD
      and TO_VERSION_NUMBER = X_TO_VERSION_NUMBER
      and TO_GRADE = X_TO_GRADE;
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
  x_org_id => igs_ge_gen_003.get_org_id,
  x_grade=>X_GRADE,
  x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
  x_to_grade=>X_TO_GRADE,
  x_to_grading_schema_cd=>X_TO_GRADING_SCHEMA_CD,
  x_to_version_number=>X_TO_VERSION_NUMBER,
  x_version_number=>X_VERSION_NUMBER,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AS_GRD_SCH_TRN_ALL (
    ORG_ID,
    GRADING_SCHEMA_CD,
    VERSION_NUMBER,
    GRADE,
    TO_GRADING_SCHEMA_CD,
    TO_VERSION_NUMBER,
    TO_GRADE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.GRADE,
    NEW_REFERENCES.TO_GRADING_SCHEMA_CD,
    NEW_REFERENCES.TO_VERSION_NUMBER,
    NEW_REFERENCES.TO_GRADE,
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
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_TO_GRADING_SCHEMA_CD in VARCHAR2,
  X_TO_VERSION_NUMBER in NUMBER,
  X_TO_GRADE in VARCHAR2
) AS
  cursor c1 is select
    ROWID
    from IGS_AS_GRD_SCH_TRN_ALL
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
  return;
end LOCK_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_GRD_SCH_TRN_ALL
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
	ELSIF upper(Column_name) = 'GRADE' THEN
	    new_references.GRADE :=COLUMN_VALUE;
	ELSIF upper(Column_name) = 'GRADING_SCHEMA_CD' then
	    new_references.GRADING_SCHEMA_CD := column_value;
	ELSIF upper(Column_name) = 'TO_GRADE' then
	    new_references.TO_GRADE := column_value;
	ELSIF upper(Column_name) = 'TO_GRADING_SCHEMA_CD' then
	    new_references.TO_GRADING_SCHEMA_CD := column_value;
      END IF ;

      IF upper(column_name) = 'GRADE' OR
     column_name is null Then
     IF new_references.GRADE <> UPPER(new_references.GRADE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'GRADING_SCHEMA_CD' OR
     column_name is null Then
     IF new_references.GRADING_SCHEMA_CD <> UPPER(new_references.GRADING_SCHEMA_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'TO_GRADE' OR
     column_name is null Then
     IF new_references.TO_GRADE <> UPPER(new_references.TO_GRADE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'TO_GRADING_SCHEMA_CD' OR
     column_name is null Then
     IF new_references.TO_GRADING_SCHEMA_CD <> UPPER(new_references.TO_GRADING_SCHEMA_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
	END Check_Constraints;




end IGS_AS_GRD_SCH_TRN_PKG;

/
