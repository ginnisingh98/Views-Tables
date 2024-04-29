--------------------------------------------------------
--  DDL for Package Body IGS_AS_ITM_EXAM_MTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ITM_EXAM_MTRL_PKG" AS
 /* $Header: IGSDI03B.pls 115.5 2003/05/19 09:56:07 ijeddy ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AS_ITM_EXAM_MTRL%RowType;
  new_references IGS_AS_ITM_EXAM_MTRL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_material_type IN VARCHAR2 DEFAULT NULL,
    x_s_material_cat IN VARCHAR2 DEFAULT NULL,
    x_quantity_per_student IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_ITM_EXAM_MTRL
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
    new_references.ass_id := x_ass_id;
    new_references.exam_material_type := x_exam_material_type;
    new_references.s_material_cat := x_s_material_cat;
    new_references.quantity_per_student := x_quantity_per_student;
    new_references.comments := x_comments;
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
  -- "OSS_TST".trg_aiem_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AS_ITM_EXAM_MTRL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts are allowed
	IF  p_inserting THEN
	    -- <aiem1>
	    -- Cannot create against closed examination_material_type
	    IF	IGS_AS_VAL_AIEM.assp_val_exmt_closed(
						new_references.exam_material_type,
						v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',V_MESSAGE_NAME);
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	    -- <aiem2>
	    -- Can only create against IGS_AS_ASSESSMNT_ITM records which are
	    -- examinations
	    IF	IGS_AS_VAL_AIEM.assp_val_ai_exmnbl(
						new_references.ass_id,
						v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',V_MESSAGE_NAME);
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	END IF;
	IF  p_inserting OR p_updating THEN
	    -- <aiem3>
	    -- Can only set quantity_per_student when s_material_type = 'SUPPLIED'
	    IF	IGS_AS_VAL_AIEM.assp_val_aiem_catqty(
						new_references.s_material_cat,
						new_references.quantity_per_student,
						v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',V_MESSAGE_NAME);
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.ass_id = new_references.ass_id)) OR
        ((new_references.ass_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_ASSESSMNT_ITM_PKG.Get_PK_For_Validation (
        new_references.ass_id
        )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.exam_material_type = new_references.exam_material_type)) OR
        ((new_references.exam_material_type IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXM_MTRL_TYPE_PKG.Get_PK_For_Validation (
        new_references.exam_material_type
        )THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation ( x_ass_id IN NUMBER,
    x_exam_material_type IN VARCHAR2)RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITM_EXAM_MTRL
      WHERE    ass_id = x_ass_id
      AND      exam_material_type = x_exam_material_type
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
  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_ITM (
    x_ass_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITM_EXAM_MTRL
      WHERE    ass_id = x_ass_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIEM_AI_FK');
       IGS_GE_MSG_STACK.ADD;
       Close cur_rowid;
       APP_EXCEPTION.RAISE_EXCEPTION;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_ASSESSMNT_ITM;
  PROCEDURE GET_FK_IGS_AS_EXM_MTRL_TYPE (
    x_exam_material_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITM_EXAM_MTRL
      WHERE    exam_material_type = x_exam_material_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIEM_EXMT_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_EXM_MTRL_TYPE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_material_type IN VARCHAR2 DEFAULT NULL,
    x_s_material_cat IN VARCHAR2 DEFAULT NULL,
    x_quantity_per_student IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_ass_id,
      x_exam_material_type,
      x_s_material_cat,
      x_quantity_per_student,
      x_comments,
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
	             new_references.ass_id ,
   		    new_references.exam_material_type ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	 IGS_GE_MSG_STACK.ADD;
	 APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       Check_Constraints;
       Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Parent_Existance;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	         new_references.ass_id ,
                 new_references.exam_material_type  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_AS_MATERIAL_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
	APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
        Check_Constraints;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
        Check_Constraints;
    END IF;

/*
The (L_ROWID := null) was added by ijeddy on 19-May-2003 as
part of the bug fix for bug no 2868726, (Uniqueness Check at Item Level)
*/
L_ROWID := null;

 END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_ITM_EXAM_MTRL
      where ASS_ID = X_ASS_ID
      and EXAM_MATERIAL_TYPE = X_EXAM_MATERIAL_TYPE;
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
 x_ass_id=>X_ASS_ID,
 x_comments=>X_COMMENTS,
 x_exam_material_type=>X_EXAM_MATERIAL_TYPE,
 x_quantity_per_student=>X_QUANTITY_PER_STUDENT,
 x_s_material_cat=>NVL(X_S_MATERIAL_CAT,'ALLOWABLE'),
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_ITM_EXAM_MTRL (
    ASS_ID,
    EXAM_MATERIAL_TYPE,
    S_MATERIAL_CAT,
    QUANTITY_PER_STUDENT,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.EXAM_MATERIAL_TYPE,
    NEW_REFERENCES.S_MATERIAL_CAT,
    NEW_REFERENCES.QUANTITY_PER_STUDENT,
    NEW_REFERENCES.COMMENTS,
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
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      S_MATERIAL_CAT,
      QUANTITY_PER_STUDENT,
      COMMENTS
    from IGS_AS_ITM_EXAM_MTRL
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
  if ( (tlinfo.S_MATERIAL_CAT = X_S_MATERIAL_CAT)
      AND ((tlinfo.QUANTITY_PER_STUDENT = X_QUANTITY_PER_STUDENT)
           OR ((tlinfo.QUANTITY_PER_STUDENT is null)
               AND (X_QUANTITY_PER_STUDENT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2,
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
 x_ass_id=>X_ASS_ID,
 x_comments=>X_COMMENTS,
 x_exam_material_type=>X_EXAM_MATERIAL_TYPE,
 x_quantity_per_student=>X_QUANTITY_PER_STUDENT,
 x_s_material_cat=>X_S_MATERIAL_CAT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_AS_ITM_EXAM_MTRL set
    S_MATERIAL_CAT = NEW_REFERENCES.S_MATERIAL_CAT,
    QUANTITY_PER_STUDENT = NEW_REFERENCES.QUANTITY_PER_STUDENT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
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
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_ITM_EXAM_MTRL
     where ASS_ID = X_ASS_ID
     and EXAM_MATERIAL_TYPE = X_EXAM_MATERIAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ASS_ID,
     X_EXAM_MATERIAL_TYPE,
     X_S_MATERIAL_CAT,
     X_QUANTITY_PER_STUDENT,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ASS_ID,
   X_EXAM_MATERIAL_TYPE,
   X_S_MATERIAL_CAT,
   X_QUANTITY_PER_STUDENT,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) is
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_ITM_EXAM_MTRL
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
	ELSIF upper(Column_name) = 'EXAM_MATERIAL_TYPE' then
	    new_references.EXAM_MATERIAL_TYPE := column_value;
      ELSIF upper(Column_name) = 'S_MATERIAL_CAT' then
	    new_references.S_MATERIAL_CAT := column_value;
      END IF;

IF upper(column_name) = 'EXAM_MATERIAL_TYPE'  OR
     column_name is null Then
     IF new_references.EXAM_MATERIAL_TYPE <> UPPER(new_references.EXAM_MATERIAL_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'S_MATERIAL_CAT' OR
     column_name is null Then
     IF new_references.S_MATERIAL_CAT NOT IN ( 'ALLOWABLE' , 'NON-ALLOW' , 'SUPPLIED' ) then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
      END IF;



END Check_Constraints;

 end IGS_AS_ITM_EXAM_MTRL_PKG;

/
