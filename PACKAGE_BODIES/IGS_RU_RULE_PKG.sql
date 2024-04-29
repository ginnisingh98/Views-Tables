--------------------------------------------------------
--  DDL for Package Body IGS_RU_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_RULE_PKG" as
/* $Header: IGSUI11B.pls 115.12 2002/11/29 04:27:46 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RU_RULE%RowType;
  new_references IGS_RU_RULE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_RULE
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_RULE  : P_ACTION INSERT VALIDATE_INSERT   : IGSUI11B.PLS');
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.sequence_number := x_sequence_number;
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
   Column_Name IN VARCHAR2 ,
   Column_Value IN VARCHAR2
 )
  as
  BEGIN
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' Then
     		new_references.sequence_number := igs_ge_number.to_num(COLUMN_VALUE);
	END IF;
	IF upper(Column_Name) = 'SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.sequence_number < 0 OR new_references.sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			 IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;


FUNCTION Get_PK_For_Validation (
    x_sequence_number IN NUMBER
)return BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_RULE
      WHERE    sequence_number = x_sequence_number
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );


    IF (p_action = 'INSERT') THEN

	  IF Get_PK_For_Validation (
		new_references.sequence_number
	  ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	  END IF;
	  Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
	  Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
--
-- svenkata - This table handler is released as part of IGS specific forms in SEED . As a consequence ,
-- the procedure Check_Child_Existance originally a part of this  package , has been moved to Igs_Ru_Gen_005 .
-- This was done 'cos Check_Child_Existance makes calls to other procedures which are not being shipped !
-- Check_Child_Existance is called only when the user is not DATAMERGE . Hence , the proc.
-- Check_Child_Existance_ru_rule is being called using execute immediate only if the user is not DATAMERGE .
-- Bug # 2233951
--
       IF (fnd_global.user_id <>  1) THEN
       -- do execute immediate
            EXECUTE IMMEDIATE 'BEGIN  Igs_Ru_Gen_005.Check_Child_Existance_ru_rule(:1); END;'
	       USING   old_references.sequence_number;
       END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	  IF Get_PK_For_Validation (
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
--
-- svenkata - This table handler is released as part of IGS specific forms in SEED . As a consequence ,
-- the procedure Check_Child_Existance originally a part of this  package , has been moved to Igs_Ru_Gen_005 .
-- This was done 'cos Check_Child_Existance makes calls to other procedures which are not being shipped !
-- Check_Child_Existance is called only when the user is not DATAMERGE . Hence , the proc.
-- Check_Child_Existance_ru_rule is being called using execute immediate only if the user is not DATAMERGE .
-- Bug # 2233951
--
       IF (fnd_global.user_id <>  1) THEN
       -- do execute immediate
            EXECUTE IMMEDIATE 'BEGIN  Igs_Ru_Gen_005.Check_Child_Existance_ru_rule(:1); END;'
	       USING   old_references.sequence_number;
       END IF;
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as

--svenkata -	The cursor C is being modified and cursor cur_max_plus_one is being created . This is to ensure that
--		when a user defined rule is created , it picks up a sequence number more than 50000 . Bug # 2233951
  l_sequence_number NUMBER;
     cursor C is select ROWID from IGS_RU_RULE
     where SEQUENCE_NUMBER = L_SEQUENCE_NUMBER;


  -- this cursor has been modified to lock the record so that parallel processing is avoided
   -- rnirwani - 15.mar.02-  2233951
    CURSOR cur_max_plus_one IS
      SELECT   (sequence_number + 1) sequence_number
      FROM     IGS_RU_RULE
       WHERE sequence_number = (SELECT MAX(sequence_number) + 1 FROM igs_ru_rule
      where sequence_number < 499999 ) FOR UPDATE OF sequence_number NOWAIT;

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
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  --
  --  If the sequence number is passed as a NULL value then generate it.
  --
  IF (fnd_global.user_id = 1) THEN
    --
    --  If the sequence number is passed as a NULL value then generate it.
    --  If the User creating this record is DATAMERGE (id = 1) then
    --  Get the sequence as the existing maximum value + 1
    --
    IF (x_sequence_number IS NULL) THEN
      OPEN cur_max_plus_one;
      FETCH cur_max_plus_one INTO l_sequence_number;
      CLOSE cur_max_plus_one;
    ELSE
      l_sequence_number := x_sequence_number;
    END IF;
     --
      --  Seeded Sequences can go upto 499999 only else raise an error
      --
      IF (l_sequence_number > 499999) THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
      END IF;
  ELSE
    l_sequence_number := NEW_REFERENCES.SEQUENCE_NUMBER;
  END IF;

  insert into IGS_RU_RULE (
    SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SEQUENCE_NUMBER,
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
  X_SEQUENCE_NUMBER in NUMBER
) as
  cursor c1 is select ROWID
    from IGS_RU_RULE
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_RULE  : P_ACTION LOCK_ROW   : IGSUI11B.PLS');
   IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
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
    x_rowid => X_ROWID);

  delete from IGS_RU_RULE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_RULE_PKG;

/
