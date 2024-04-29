--------------------------------------------------------
--  DDL for Package Body IGS_RU_DESCRIPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_DESCRIPTION_PKG" as
/* $Header: IGSUI03B.pls 115.14 2003/01/29 12:01:40 nshee ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RU_DESCRIPTION%RowType;
  new_references IGS_RU_DESCRIPTION%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_s_return_type IN VARCHAR2 ,
    x_rule_description IN VARCHAR2 ,
    x_s_turin_function IN VARCHAR2 ,
    x_parenthesis_ind IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_DESCRIPTION
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN('IGS_RU_DESCRIPTION : P_ACTION  INSERT, VALIDATE_INSERT : IGSUI03B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.sequence_number := x_sequence_number;
    new_references.s_return_type := x_s_return_type;
    new_references.rule_description := x_rule_description;
    new_references.s_turin_function := x_s_turin_function;
    new_references.parenthesis_ind := x_parenthesis_ind;
    new_references.description := x_description;
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
  -- "OSS_TST".trg_rud_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON rule_description
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) as
	v_message_name	Varchar2(30);
  BEGIN
	IF p_inserting OR p_updating
	THEN
		-- validate return type and IGS_RU_RULE description
		IF IGS_RU_VAL_RUD.rulp_val_rud_desc(
				old_references.sequence_number,
				old_references.s_return_type,
				old_references.rule_description,
				old_references.s_turin_function,
				new_references.s_return_type,
				new_references.rule_description,
				v_message_name) = FALSE
		THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_rud_ar_u
  -- AFTER UPDATE
  -- ON rule_description
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) as
  --
  -- if named IGS_RU_RULE then update IGS_RU_RULE text
  -- else retry with parent IGS_RU_RULE
  --
  PROCEDURE do_rule_text (
  	p_rule_number	NUMBER )
  as
  	v_rule_text	IGS_RU_NAMED_RULE.rule_text%TYPE;
  BEGIN
  	FOR nr IN (
  		SELECT	rule_text
  		FROM	IGS_RU_NAMED_RULE
  		WHERE	rul_sequence_number = p_rule_number )
  	LOOP
  		-- if named IGS_RU_RULE then update IGS_RU_RULE text
  		v_rule_text := IGS_RU_GEN_006.RULP_GET_RULE(p_rule_number);-- Changed IGS_RU_GEN_003 to IGS_RU_GEN_006 As part of Seed Migration Build Bug :2233951. This approach is taken to resolve the release issues .
  		UPDATE	IGS_RU_NAMED_RULE
  		SET	rule_text = v_rule_text
  		WHERE	rul_sequence_number = p_rule_number;
  		RETURN;
  	END LOOP;
  	-- else find the calling IGS_RU_RULE and try again
  	FOR rui IN (
  		SELECT	rul_sequence_number
  		FROM	IGS_RU_ITEM
  		WHERE	rule_number = p_rule_number )
  	LOOP
  		do_rule_text(rui.rul_sequence_number);
  	END LOOP;
  END do_rule_text;

  BEGIN
	IF  p_updating AND
	    old_references.rule_description <> new_references.rule_description
	THEN
  		IF New_References.S_TURIN_FUNCTION IS NOT NULL	THEN
  			-- find all rules which use this turing function
  			FOR rui IN (
  				SELECT UNIQUE
  					rul_sequence_number
	  			FROM	IGS_RU_ITEM
  				WHERE	turin_function = New_References.S_TURIN_FUNCTION )
  			LOOP
  				-- update the IGS_RU_RULE text of this named IGS_RU_RULE
	  			do_rule_text(rui.rul_sequence_number);
  			END LOOP;
	  	ELSE
  			-- find all rules which call this named IGS_RU_RULE
  			FOR nr IN (
  				SELECT UNIQUE
	  				rui.rul_sequence_number
  				FROM	IGS_RU_NAMED_RULE	nr,
  					IGS_RU_ITEM	rui
  				WHERE	nr.rud_sequence_number = New_References.sequence_number
	  			AND	rui.named_rule = nr.rul_sequence_number )
  			LOOP
  				-- update the IGS_RU_RULE text of this named IGS_RU_RULE
  				do_rule_text(nr.rul_sequence_number);
	  		END LOOP;
  		END IF;
	END IF;

  END AfterRowUpdate2;



PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    ,
                 Column_Value    IN   VARCHAR2
)  as
Begin

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'S_RETURN_TYPE' THEN
  new_references.S_RETURN_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
  new_references.SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PARENTHESIS_IND' THEN
  new_references.PARENTHESIS_IND:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'S_RETURN_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_RETURN_TYPE<> upper(new_references.S_RETURN_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SEQUENCE_NUMBER < 0 or new_references.SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PARENTHESIS_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.PARENTHESIS_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


 END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.s_return_type = new_references.s_return_type)) OR
        ((new_references.s_return_type IS NULL))) THEN
      NULL;
    ELSE
      IF  not IGS_RU_RET_TYPE_PKG.Get_PK_For_Validation (
        new_references.s_return_type
        )  THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_RU_GEN_006.SET_TOKEN('IGS_RU_RET_TYPE : P_ACTION  Check_Parent_Existance new_references.s_return_type : IGSUI03B.PLS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;
    IF (((old_references.s_turin_function = new_references.s_turin_function)) OR
        ((new_references.s_turin_function IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_TURIN_FNC_PKG.Get_PK_For_Validation (
        new_references.s_turin_function
        ) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_RU_GEN_006.SET_TOKEN('IGS_RU_TURIN_FNC : P_ACTION  Check_Parent_Existance new_references.s_turin_function : IGSUI03B.PLS');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_RU_NAMED_RULE_PKG.GET_FK_IGS_RU_DESCRIPTION (
      old_references.sequence_number
      );

    IGS_RU_GROUP_SET_PKG.GET_FK_IGS_RU_DESCRIPTION (
      old_references.sequence_number
      );

    IGS_RU_CALL_PKG.GET_FK_IGS_RU_DESCRIPTION (
      old_references.sequence_number
      );

    IGS_RU_TURIN_FNC_PKG.GET_FK_IGS_RU_DESCRIPTION (
      old_references.sequence_number
      );

  END Check_Child_Existance;

   PROCEDURE CHECK_UNIQUENESS as
    BEGIN
      IF  GET_UK1_FOR_VALIDATION ( new_references.s_return_type     ,
                                   new_references.rule_description
                                 )  THEN
             Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
             IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

    END CHECK_UNIQUENESS ;

  FUNCTION Get_PK_For_Validation (
    x_sequence_number IN NUMBER
    )  RETURN BOOLEAN
    as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_DESCRIPTION
      WHERE    sequence_number = x_sequence_number
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



FUNCTION  GET_UK1_FOR_VALIDATION ( x_s_return_type    varchar2 ,
                                   x_rule_description  varchar2
                                 )  RETURN BOOLEAN as

 CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_DESCRIPTION
      WHERE    s_return_type    = x_s_return_type
       AND     rule_description  = x_rule_description
       AND     (l_rowid is null or rowid <> l_rowid)
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

   END ;

  PROCEDURE GET_FK_IGS_RU_RET_TYPE (
    x_s_return_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_DESCRIPTION
      WHERE    s_return_type = x_s_return_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUD_SRRT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_RET_TYPE;

  PROCEDURE GET_FK_IGS_RU_TURIN_FNC (
    x_s_turin_function IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_DESCRIPTION
      WHERE    s_turin_function = x_s_turin_function ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUD_STF_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_TURIN_FNC;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_s_return_type IN VARCHAR2 ,
    x_rule_description IN VARCHAR2 ,
    x_s_turin_function IN VARCHAR2 ,
    x_parenthesis_ind IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
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
      x_s_return_type,
      x_rule_description,
      x_s_turin_function,
      x_parenthesis_ind,
      x_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE );
      IF  Get_PK_For_Validation (
       new_references.sequence_number
            ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE, p_updating => TRUE, p_deleting => FALSE );
      check_uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
        IF  Get_PK_For_Validation (
         new_references.sequence_number
        ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
 	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       check_uniqueness;
       Check_Constraints;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate2 ( p_inserting => FALSE, p_updating => TRUE ,p_deleting => FALSE);
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RETURN_TYPE in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_TURIN_FUNCTION in VARCHAR2,
  X_PARENTHESIS_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2001
  --
  --Purpose: INSERT_ROW
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kdande      15-Mar-2002     Bug # 2233951: The cursor C is being modified and cursor
  --                            cur_max_plus_one is being created. This is to ensure that
  --                            when a user defined rule is created,
  --                            it picks up a sequence number more than 500000.
  --  rnirwani - 15-Mar-02 - 2233951 the cursor has been changed to do a select for update
 --              so that parallel processing can be prevented.
  -------------------------------------------------------------------
    l_sequence_number NUMBER;
    cursor C is select ROWID from IGS_RU_DESCRIPTION
      where SEQUENCE_NUMBER = L_SEQUENCE_NUMBER;
    CURSOR cur_max_plus_one IS
      SELECT  (a.sequence_number + 1) sequence_number
      FROM     igs_ru_description a
      WHERE a.sequence_number = (SELECT MAX(b.sequence_number) FROM igs_ru_description b
      WHERE    b.sequence_number < 499999) FOR UPDATE OF a.sequence_number NOWAIT;
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
   x_description=>X_DESCRIPTION,
   x_parenthesis_ind=>X_PARENTHESIS_IND,
   x_rule_description=>X_RULE_DESCRIPTION,
   x_s_return_type=>X_S_RETURN_TYPE,
   x_s_turin_function=>X_S_TURIN_FUNCTION,
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
  insert into IGS_RU_DESCRIPTION (
    SEQUENCE_NUMBER,
    S_RETURN_TYPE,
    RULE_DESCRIPTION,
    DESCRIPTION,
    S_TURIN_FUNCTION,
    PARENTHESIS_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    l_sequence_number,
    NEW_REFERENCES.S_RETURN_TYPE,
    NEW_REFERENCES.RULE_DESCRIPTION,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_TURIN_FUNCTION,
    NEW_REFERENCES.PARENTHESIS_IND,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RETURN_TYPE in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_TURIN_FUNCTION in VARCHAR2,
  X_PARENTHESIS_IND in VARCHAR2
) as
  cursor c1 is select
      S_RETURN_TYPE,
      RULE_DESCRIPTION,
      DESCRIPTION,
      S_TURIN_FUNCTION,
      PARENTHESIS_IND
    from IGS_RU_DESCRIPTION
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_DESCRIPTION : P_ACTION  LOCK_ROW   : IGSUI03B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.S_RETURN_TYPE = X_S_RETURN_TYPE)
      AND (RTRIM(tlinfo.RULE_DESCRIPTION) = X_RULE_DESCRIPTION) --nshee, bug 2774952
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.S_TURIN_FUNCTION = X_S_TURIN_FUNCTION)
           OR ((tlinfo.S_TURIN_FUNCTION is null)
               AND (X_S_TURIN_FUNCTION is null)))
      AND ((tlinfo.PARENTHESIS_IND = X_PARENTHESIS_IND)
           OR ((tlinfo.PARENTHESIS_IND is null)
               AND (X_PARENTHESIS_IND is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_DESCRIPTION : P_ACTION  LOCK_ROW  FORM_RECORD_CHANGED  : IGSUI03B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RETURN_TYPE in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_TURIN_FUNCTION in VARCHAR2,
  X_PARENTHESIS_IND in VARCHAR2,
  X_MODE in VARCHAR2
  )as
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
   x_description=>X_DESCRIPTION,
   x_parenthesis_ind=>X_PARENTHESIS_IND,
   x_rule_description=>X_RULE_DESCRIPTION,
   x_s_return_type=>X_S_RETURN_TYPE,
   x_s_turin_function=>X_S_TURIN_FUNCTION,
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_RU_DESCRIPTION set
    S_RETURN_TYPE = NEW_REFERENCES.S_RETURN_TYPE,
    RULE_DESCRIPTION = NEW_REFERENCES.RULE_DESCRIPTION,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_TURIN_FUNCTION = NEW_REFERENCES.S_TURIN_FUNCTION,
    PARENTHESIS_IND = NEW_REFERENCES.PARENTHESIS_IND,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RETURN_TYPE in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_TURIN_FUNCTION in VARCHAR2,
  X_PARENTHESIS_IND in VARCHAR2,
  X_MODE in VARCHAR2
  )as
  cursor c1 is select rowid from IGS_RU_DESCRIPTION
     where SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SEQUENCE_NUMBER,
     X_S_RETURN_TYPE,
     X_RULE_DESCRIPTION,
     X_DESCRIPTION,
     X_S_TURIN_FUNCTION,
     X_PARENTHESIS_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SEQUENCE_NUMBER,
   X_S_RETURN_TYPE,
   X_RULE_DESCRIPTION,
   X_DESCRIPTION,
   X_S_TURIN_FUNCTION,
   X_PARENTHESIS_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_RU_DESCRIPTION
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_DESCRIPTION_PKG;

/
