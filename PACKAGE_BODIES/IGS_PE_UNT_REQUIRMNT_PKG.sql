--------------------------------------------------------
--  DDL for Package Body IGS_PE_UNT_REQUIRMNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_UNT_REQUIRMNT_PKG" AS
  /* $Header: IGSNI34B.pls 115.4 2002/11/29 01:22:21 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PE_UNT_REQUIRMNT%RowType;
  new_references IGS_PE_UNT_REQUIRMNT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_pen_start_dt IN DATE DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_pee_start_dt IN DATE DEFAULT NULL,
    x_pee_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_pur_start_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_UNT_REQUIRMNT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN( 'INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.encumbrance_type := x_encumbrance_type;
    new_references.pen_start_dt := x_pen_start_dt;
    new_references.s_encmb_effect_type := x_s_encmb_effect_type;
    new_references.pee_start_dt := x_pee_start_dt;
    new_references.pee_sequence_number := x_pee_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.pur_start_dt := x_pur_start_dt;
    new_references.expiry_dt := x_expiry_dt;
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
v_message_name  varchar2(30);
  BEGIN
	-- Validate that start date is not less than the current date.
	IF (new_references.pur_start_dt IS NOT NULL) THEN
		IF p_inserting OR (p_updating AND
		(NVL(old_references.pur_start_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
		<> new_references.pur_start_dt))
		THEN
		IF IGS_EN_VAL_PCE.enrp_val_encmb_dt (
			 	new_references.pur_start_dt,
			 	v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
		END IF;
	END IF;
	-- Validate that start date is not less than the parent IGS_PE_PERSON
	-- Encumbrance Effect start date.
	IF p_inserting THEN
		IF IGS_EN_VAL_PCE.enrp_val_encmb_dts (
			 	new_references.pee_start_dt,
			 	new_references.pur_start_dt,
			 	v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate that if expiry date is specified, then expiry date  is not
	-- less than the start date.
	IF (new_references.expiry_dt IS NOT NULL) THEN
		IF p_inserting OR (p_updating AND
		(NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
		<> new_references.expiry_dt))
		THEN
		IF IGS_EN_VAL_PCE.enrp_val_strt_exp_dt (
			 	new_references.pur_start_dt,
			 	new_references.expiry_dt,
			 	v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
		IF IGS_EN_VAL_PCE.enrp_val_encmb_dt (
			 	new_references.expiry_dt,
			 	v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
		END IF;
	END IF;
	-- Validate that records for this table can be created for the encumbrance
	-- effect type.
	IF p_inserting THEN
		IF IGS_EN_VAL_PCE.enrp_val_pee_table (
			 	new_references.s_encmb_effect_type,
			 	'IGS_PE_UNT_REQUIRMNT',
			 	v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_pur_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PE_UNT_REQUIRMNT
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name  varchar2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- Validate for open ended IGS_PE_PERSON IGS_PS_UNIT requirement records.
	IF new_references.expiry_dt IS NULL THEN
		 -- Save the rowid of the current row.
  		-- Validate for open ended IGS_PE_UNT_REQUIRMNT records.
  		IF new_references.expiry_dt IS NULL THEN
  			IF IGS_EN_VAL_PUR.enrp_val_pur_open (
  					new_references.person_id,
  					new_references.encumbrance_type,
  					new_references.pen_start_dt,
  					new_references.s_encmb_effect_type,
  					new_references.pee_start_dt,
  					new_references.unit_cd,
  					new_references.pur_start_dt,
  					v_message_name ) = FALSE THEN
  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
  			END IF;
  		END IF;
	END IF;


  END AfterRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_pur_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PE_UNT_REQUIRMNT


     PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;

 ELSIF upper(Column_name) = 'ENCUMBRANCE_TYPE' then
     new_references.encumbrance_type := column_value;
ELSIF upper(Column_name) = 'S_ENCMB_EFFECT_TYPE' then
     new_references.s_encmb_effect_type := column_value;
ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd:= column_value;
  END IF;
IF upper(column_name) = 'ENCUMBRANCE_TYPE' OR
     column_name is null Then
     IF new_references.encumbrance_type  <>UPPER(new_references.encumbrance_type)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
         END IF;
 IF upper(column_name) = 'S_ENCMB_EFFECT_TYPE' OR
     column_name is null Then
     IF new_references.s_encmb_effect_type <>UPPER(new_references.s_encmb_effect_type)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.unit_cd <>UPPER(new_references.unit_cd)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

 END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.encumbrance_type = new_references.encumbrance_type) AND
         (old_references.pen_start_dt = new_references.pen_start_dt) AND
         (old_references.s_encmb_effect_type = new_references.s_encmb_effect_type) AND
         (old_references.pee_start_dt = new_references.pee_start_dt) AND
         (old_references.pee_sequence_number = new_references.pee_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.encumbrance_type IS NULL) OR
         (new_references.pen_start_dt IS NULL) OR
         (new_references.s_encmb_effect_type IS NULL) OR
         (new_references.pee_start_dt IS NULL) OR
         (new_references.pee_sequence_number IS NULL))) THEN
      NULL;
    ELSE
        IF  NOT IGS_PE_PERSENC_EFFCT_PKG.Get_PK_For_Validation (
         new_references.person_id,
        new_references.encumbrance_type,
        new_references.pen_start_dt,
        new_references.s_encmb_effect_type,
        new_references.pee_start_dt,
        new_references.pee_sequence_number ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd)) OR
        ((new_references.unit_cd IS NULL))) THEN
      NULL;
    ELSE

       IF  NOT IGS_PS_UNIT_PKG.Get_PK_For_Validation (
         new_references.unit_cd ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_s_encmb_effect_type IN VARCHAR2,
    x_pen_start_dt IN DATE,
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_pee_start_dt IN DATE,
    x_pee_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_pur_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_UNT_REQUIRMNT
      WHERE    s_encmb_effect_type = x_s_encmb_effect_type
      AND      pen_start_dt = x_pen_start_dt
      AND      person_id = x_person_id
      AND      encumbrance_type = x_encumbrance_type
      AND      pee_start_dt = x_pee_start_dt
      AND      pee_sequence_number = x_pee_sequence_number
      AND      unit_cd = x_unit_cd
      AND      pur_start_dt = x_pur_start_dt
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

  PROCEDURE GET_FK_IGS_PE_PERSENC_EFFCT (
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_pen_start_dt IN DATE,
    x_s_encmb_effect_type IN VARCHAR2,
    x_pee_start_dt IN DATE,
    x_pee_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_UNT_REQUIRMNT
      WHERE    person_id = x_person_id
      AND      encumbrance_type = x_encumbrance_type
      AND      pen_start_dt = x_pen_start_dt
      AND      s_encmb_effect_type = x_s_encmb_effect_type
      AND      pee_start_dt = x_pee_start_dt
      AND      pee_sequence_number = x_pee_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PUR_PEE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
       App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSENC_EFFCT;

  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_UNT_REQUIRMNT
      WHERE    unit_cd = x_unit_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PUR_UN_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_pen_start_dt IN DATE DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_pee_start_dt IN DATE DEFAULT NULL,
    x_pee_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_pur_start_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
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
      x_encumbrance_type,
      x_pen_start_dt,
      x_s_encmb_effect_type,
      x_pee_start_dt,
      x_pee_sequence_number,
      x_unit_cd,
      x_pur_start_dt,
      x_expiry_dt,
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
    new_references.s_encmb_effect_type ,
    new_references.pen_start_dt ,
    new_references.person_id ,
    new_references.encumbrance_type ,
    new_references.pee_start_dt ,
    new_references.pee_sequence_number ,
    new_references.unit_cd ,
    new_references.pur_start_dt ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 ( p_updating => TRUE );

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.

       NULL;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.s_encmb_effect_type ,
    new_references.pen_start_dt ,
    new_references.person_id ,
    new_references.encumbrance_type ,
    new_references.pee_start_dt ,
    new_references.pee_sequence_number ,
    new_references.unit_cd ,
    new_references.pur_start_dt ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints; -- if procedure present
     ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
 END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_PUR_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PE_UNT_REQUIRMNT
      where PERSON_ID = X_PERSON_ID
      and ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE
      and PEN_START_DT = X_PEN_START_DT
      and S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE
      and PEE_START_DT = X_PEE_START_DT
      and PEE_SEQUENCE_NUMBER = X_PEE_SEQUENCE_NUMBER
      and UNIT_CD = X_UNIT_CD
      and PUR_START_DT = X_PUR_START_DT;
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
   x_encumbrance_type=>X_ENCUMBRANCE_TYPE,
   x_expiry_dt=>X_EXPIRY_DT,
   x_pee_sequence_number=>X_PEE_SEQUENCE_NUMBER,
   x_pee_start_dt=>X_PEE_START_DT,
   x_pen_start_dt=>X_PEN_START_DT,
   x_person_id=>X_PERSON_ID,
   x_pur_start_dt=>X_PUR_START_DT,
   x_s_encmb_effect_type=>X_S_ENCMB_EFFECT_TYPE,
   x_unit_cd=>X_UNIT_CD,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_PE_UNT_REQUIRMNT (
    PERSON_ID,
    ENCUMBRANCE_TYPE,
    PEN_START_DT,
    S_ENCMB_EFFECT_TYPE,
    PEE_START_DT,
    PEE_SEQUENCE_NUMBER,
    UNIT_CD,
    PUR_START_DT,
    EXPIRY_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ENCUMBRANCE_TYPE,
    NEW_REFERENCES.PEN_START_DT,
    NEW_REFERENCES.S_ENCMB_EFFECT_TYPE,
    NEW_REFERENCES.PEE_START_DT,
    NEW_REFERENCES.PEE_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.PUR_START_DT,
    NEW_REFERENCES.EXPIRY_DT,
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
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_PUR_START_DT in DATE,
  X_EXPIRY_DT in DATE
) AS
  cursor c1 is select
      EXPIRY_DT
    from IGS_PE_UNT_REQUIRMNT
    where  ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_PUR_START_DT in DATE,
  X_EXPIRY_DT in DATE,
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
   x_encumbrance_type=>X_ENCUMBRANCE_TYPE,
   x_expiry_dt=>X_EXPIRY_DT,
   x_pee_sequence_number=>X_PEE_SEQUENCE_NUMBER,
   x_pee_start_dt=>X_PEE_START_DT,
   x_pen_start_dt=>X_PEN_START_DT,
   x_person_id=>X_PERSON_ID,
   x_pur_start_dt=>X_PUR_START_DT,
   x_s_encmb_effect_type=>X_S_ENCMB_EFFECT_TYPE,
   x_unit_cd=>X_UNIT_CD,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_PE_UNT_REQUIRMNT set
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_PUR_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PE_UNT_REQUIRMNT
     where PERSON_ID = X_PERSON_ID
     and ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE
     and PEN_START_DT = X_PEN_START_DT
     and S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE
     and PEE_START_DT = X_PEE_START_DT
     and PEE_SEQUENCE_NUMBER = X_PEE_SEQUENCE_NUMBER
     and UNIT_CD = X_UNIT_CD
     and PUR_START_DT = X_PUR_START_DT
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ENCUMBRANCE_TYPE,
     X_PEN_START_DT,
     X_S_ENCMB_EFFECT_TYPE,
     X_PEE_START_DT,
     X_PEE_SEQUENCE_NUMBER,
     X_UNIT_CD,
     X_PUR_START_DT,
     X_EXPIRY_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ENCUMBRANCE_TYPE,
   X_PEN_START_DT,
   X_S_ENCMB_EFFECT_TYPE,
   X_PEE_START_DT,
   X_PEE_SEQUENCE_NUMBER,
   X_UNIT_CD,
   X_PUR_START_DT,
   X_EXPIRY_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_PE_UNT_REQUIRMNT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PE_UNT_REQUIRMNT_PKG;

/
