--------------------------------------------------------
--  DDL for Package Body IGS_AS_COURSE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_COURSE_TYPE_PKG" as
 /* $Header: IGSDI01B.pls 115.6 2003/06/05 12:56:57 sarakshi ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AS_COURSE_TYPE_ALL%RowType;
  new_references IGS_AS_COURSE_TYPE_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_COURSE_TYPE_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
     fnd_message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.ass_id := x_ass_id;
    new_references.course_type := x_course_type;
    new_references.org_id := x_org_id;
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
  -- "OSS_TST".trg_acot_br_i
  -- BEFORE INSERT
  -- ON IGS_AS_COURSE_TYPE
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts are allowed
	IF  p_inserting THEN
	    -- Validate IGS_PS_COURSE type closed indicator
	    IF	IGS_AS_VAL_ACOT.crsp_val_cty_closed(new_references.course_type,
						  v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	END IF;
  END BeforeRowInsert1;
  -- Trigger description :-
  -- "OSS_TST".trg_acot_br_id_upd
  -- BEFORE INSERT OR DELETE
  -- ON IGS_AS_COURSE_TYPE
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertDelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
	v_ass_id		IGS_AS_UNITASS_ITEM.ass_id%TYPE;
  BEGIN
 	-- Update action date when adding/p_deleting an ACOT record
	IF  p_inserting OR p_deleting THEN
	    IF  p_inserting THEN
		v_ass_id := new_references.ass_id;
	    ELSE
		v_ass_id := old_references.ass_id;
	    END IF;
	    IF	IGS_AS_GEN_005.ASSP_UPD_UAI_ACTION (
				v_ass_id,
				v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	END IF;
   END BeforeRowInsertDelete2;
PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)AS
	BEGIN
	IF  column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'COURSE_TYPE' then
	    new_references.COURSE_TYPE := column_value;
	 END IF;
IF upper(column_name) = 'COURSE_TYPE' OR
     column_name is null Then
     IF new_references.COURSE_TYPE <> UPPER(new_references.COURSE_TYPE) Then
      fnd_message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.ass_id = new_references.ass_id)) OR
        ((new_references.ass_id IS NULL))) THEN
      NULL;
    ELSIF  NOT IGS_AS_ASSESSMNT_ITM_PKG.Get_PK_For_Validation (
        new_references.ass_id ) THEN
         FND_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PS_TYPE_PKG.Get_PK_For_Validation (
        new_references.course_type
        )THEN
        FND_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_ass_id IN NUMBER,
    x_course_type IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_COURSE_TYPE_ALL
      WHERE    ass_id = x_ass_id
      AND      course_type = x_course_type
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      RETURN (TRUE);
    ELSE
      Close cur_rowid;
      RETURN (FALSE);
    END IF;
  END Get_PK_For_Validation;
  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_ITM (
    x_ass_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_COURSE_TYPE_ALL
      WHERE    ass_id = x_ass_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.Set_Name ('IGS', 'IGS_AS_ACOT_AI_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_ASSESSMNT_ITM;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
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
      x_ass_id,
      x_course_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsert1 ( p_inserting => TRUE );
      BeforeRowInsertDelete2 ( p_inserting => TRUE );
	IF  Get_PK_For_Validation ( NEW_REFERENCES.ass_id ,
    NEW_REFERENCES.course_type
) THEN
         fnd_message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	     Check_Constraints;
		 Check_Parent_Existance;
ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      	     Check_Constraints;
      Check_Parent_Existance;
ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertDelete2 ( p_deleting => TRUE );
ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	        new_references.ass_id ,
               new_references.course_type) THEN
         fnd_message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  X_ASS_ID in NUMBER,
  X_COURSE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_COURSE_TYPE_all
      where ASS_ID = X_ASS_ID
      and COURSE_TYPE = X_COURSE_TYPE;
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
 x_ass_id=>X_ASS_ID,
 x_course_type=>X_COURSE_TYPE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_COURSE_TYPE_ALL (
    ASS_ID,
    ORG_ID,
    COURSE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.COURSE_TYPE,
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
  X_COURSE_TYPE in VARCHAR2
) AS
  cursor c1 is select
    ROWID
    from IGS_AS_COURSE_TYPE_ALL
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
  delete from IGS_AS_COURSE_TYPE_ALL
   where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_AS_COURSE_TYPE_PKG;

/
