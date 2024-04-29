--------------------------------------------------------
--  DDL for Package Body IGS_AS_ITEM_ASSESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ITEM_ASSESSOR_PKG" AS
 /* $Header: IGSDI02B.pls 120.0 2005/07/05 12:14:17 appldev noship $ */
 --msrinivi    24-AUG-2001     Bug No. 1956374. Repointed genp_val_prsn_id
 l_rowid VARCHAR2(25);
  old_references IGS_AS_ITEM_ASSESSOR%RowType;
  new_references IGS_AS_ITEM_ASSESSOR%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_assessor_type IN VARCHAR2 DEFAULT NULL,
    x_primary_assessor_ind IN VARCHAR2 DEFAULT NULL,
    x_item_limit IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_ITEM_ASSESSOR
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
    new_references.person_id := x_person_id;
    new_references.sequence_number := x_sequence_number;
    new_references.ass_assessor_type := x_ass_assessor_type;
    new_references.primary_assessor_ind := x_primary_assessor_ind;
    new_references.item_limit := x_item_limit;
    new_references.location_cd := x_location_cd;
    new_references.unit_mode := x_unit_mode;
    new_references.unit_class := x_unit_class;
    new_references.comments := x_comments;
    new_references.ass_id := x_ass_id;
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
  -- "OSS_TST".trg_aia_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AS_ITEM_ASSESSOR
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    -- <aia1>
	    -- Validate IGS_PE_PERSON exists
	    IF	IGS_CO_VAL_OC.genp_val_prsn_id(new_references.person_id,
					      v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	    -- <aia2>
	    -- Validate assessment assessor type closed indicator
	    IF	IGS_AS_VAL_AIA.assp_val_asst_closed(new_references.ass_assessor_type,
					      v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	    -- <aia3>
	    -- Validate IGS_AD_LOCATION closed indicator
	    -- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_AIA.crsp_val_loc_cd
	    IF	IGS_PS_VAL_UOO.crsp_val_loc_cd(new_references.location_cd,
					      v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	    -- <aia4>
	    -- Validate IGS_PS_UNIT mode closed indicator
	    -- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_AIA.crsp_val_um_closed
	    IF	IGS_AS_VAL_UAI.crsp_val_um_closed(new_references.unit_mode,
					      v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	    -- <aia5>
	    -- Validate IGS_PS_UNIT class indicator
	    -- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_AIA.crsp_val_ucl_closed
	    IF	IGS_AS_VAL_UAI.crsp_val_ucl_closed(new_references.unit_class,
					      v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_aia_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_ITEM_ASSESSOR
  -- FOR EACH ROW
  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
     v_message_name	VARCHAR2(30);
  BEGIN
	IF  p_inserting OR p_updating THEN
         	IF  new_references.primary_assessor_ind = 'Y' THEN
  		    IF  IGS_AS_VAL_AIA.assp_val_aia_primary (
  					new_references.ass_id,
  					new_references.person_id,
  					new_references.sequence_number,
  					v_message_name) = FALSE THEN
  			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
  		    END IF;
  		END IF;
  		-- Validate assessor links for invalid combinations
  		IF  IGS_AS_VAL_AIA.assp_val_aia_links (
  					new_references.ass_id,
  					new_references.person_id,
  					new_references.sequence_number,
  					new_references.location_cd,
  					new_references.unit_mode,
  					new_references.unit_class,
  					new_references.ass_assessor_type ,
  					v_message_name) = FALSE THEN
  		  	FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
	    -- Save the rowid of the current row.
	END IF;
  END AfterRowInsertUpdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_aia_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_ITEM_ASSESSOR

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.ass_id = new_references.ass_id)) OR
        ((new_references.ass_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_ASSESSMNT_ITM_PKG.Get_PK_For_Validation (
        new_references.ass_id ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
                         APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.ass_assessor_type = new_references.ass_assessor_type)) OR
        ((new_references.ass_assessor_type IS NULL))) THEN
      NULL;
    ELSIF  NOT IGS_AS_ASSESSOR_TYPE_PKG.Get_PK_For_Validation (
        new_references.ass_assessor_type )THEN
	 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	 APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT  IGS_AD_LOCATION_PKG.Get_PK_For_Validation (         new_references.location_cd,
            'N'
        ) THEN
 	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT   IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ) THEN
  	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSIF NOT  IGS_AS_UNIT_CLASS_PKG.Get_PK_For_Validation (
        new_references.unit_class
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.unit_mode = new_references.unit_mode)) OR
        ((new_references.unit_mode IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_UNIT_MODE_PKG.Get_PK_For_Validation (
        new_references.unit_mode
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_ass_id IN NUMBER,
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITEM_ASSESSOR
      WHERE    ass_id = x_ass_id
      AND      person_id = x_person_id
      AND      sequence_number = x_sequence_number
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
      FROM     IGS_AS_ITEM_ASSESSOR
      WHERE    ass_id = x_ass_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIA_AI_FK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_ASSESSMNT_ITM;
  PROCEDURE GET_FK_IGS_AS_ASSESSOR_TYPE (
    x_ass_assessor_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITEM_ASSESSOR
      WHERE    ass_assessor_type = x_ass_assessor_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIA_ASST_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_ASSESSOR_TYPE;
  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITEM_ASSESSOR
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIA_LOC_FK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITEM_ASSESSOR
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIA_PE_FK');
IGS_GE_MSG_STACK.ADD;
	     Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ITEM_ASSESSOR
      WHERE    unit_mode = x_unit_mode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AIA_UM_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_UNIT_MODE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_assessor_type IN VARCHAR2 DEFAULT NULL,
    x_primary_assessor_ind IN VARCHAR2 DEFAULT NULL,
    x_item_limit IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
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
      x_ass_assessor_type,
      x_primary_assessor_ind,
      x_item_limit,
      x_location_cd,
      x_unit_mode,
      x_unit_class,
      x_comments,
      x_ass_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE ) ;
 IF  Get_PK_For_Validation ( new_references.ass_id ,
    new_references.person_id ,
    new_references.sequence_number  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
	     IF  Get_PK_For_Validation ( new_references.ass_id ,
    new_references.person_id ,
    new_references.sequence_number  ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
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
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );

    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_ITEM_ASSESSOR
      where ASS_ID = X_ASS_ID
      and PERSON_ID = X_PERSON_ID
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    gv_other_detail VARCHAR2(255);
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
 x_ass_assessor_type=>X_ASS_ASSESSOR_TYPE,
 x_ass_id=>X_ASS_ID,
 x_comments=>X_COMMENTS,
 x_item_limit=>X_ITEM_LIMIT,
 x_location_cd=>X_LOCATION_CD,
 x_person_id=>X_PERSON_ID,
 x_primary_assessor_ind=> NVL(X_PRIMARY_ASSESSOR_IND,'Y'),
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_unit_class=>X_UNIT_CLASS,
 x_unit_mode=>X_UNIT_MODE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_ITEM_ASSESSOR (
    ASS_ID,
    PERSON_ID,
    SEQUENCE_NUMBER,
    ASS_ASSESSOR_TYPE,
    PRIMARY_ASSESSOR_IND,
    ITEM_LIMIT,
    LOCATION_CD,
    UNIT_MODE,
    UNIT_CLASS,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.ASS_ASSESSOR_TYPE,
    NEW_REFERENCES.PRIMARY_ASSESSOR_IND,
    NEW_REFERENCES.ITEM_LIMIT,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_MODE,
    NEW_REFERENCES.UNIT_CLASS,
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
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      ASS_ASSESSOR_TYPE,
      PRIMARY_ASSESSOR_IND,
      ITEM_LIMIT,
      LOCATION_CD,
      UNIT_MODE,
      UNIT_CLASS,
      COMMENTS
    from IGS_AS_ITEM_ASSESSOR
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
  if ( (tlinfo.ASS_ASSESSOR_TYPE = X_ASS_ASSESSOR_TYPE)
      AND (tlinfo.PRIMARY_ASSESSOR_IND = X_PRIMARY_ASSESSOR_IND)
      AND ((tlinfo.ITEM_LIMIT = X_ITEM_LIMIT)
           OR ((tlinfo.ITEM_LIMIT is null)
               AND (X_ITEM_LIMIT is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_MODE = X_UNIT_MODE)
           OR ((tlinfo.UNIT_MODE is null)
               AND (X_UNIT_MODE is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
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
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
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
 x_ass_assessor_type=>X_ASS_ASSESSOR_TYPE,
 x_ass_id=>X_ASS_ID,
 x_comments=>X_COMMENTS,
 x_item_limit=>X_ITEM_LIMIT,
 x_location_cd=>X_LOCATION_CD,
 x_person_id=>X_PERSON_ID,
 x_primary_assessor_ind=>X_PRIMARY_ASSESSOR_IND,
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_unit_class=>X_UNIT_CLASS,
 x_unit_mode=>X_UNIT_MODE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_AS_ITEM_ASSESSOR set
    ASS_ASSESSOR_TYPE = NEW_REFERENCES.ASS_ASSESSOR_TYPE,
    PRIMARY_ASSESSOR_IND = NEW_REFERENCES.PRIMARY_ASSESSOR_IND,
    ITEM_LIMIT = NEW_REFERENCES.ITEM_LIMIT,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_MODE = NEW_REFERENCES.UNIT_MODE,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
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
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_ITEM_ASSESSOR
     where ASS_ID = X_ASS_ID
     and PERSON_ID = X_PERSON_ID
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ASS_ID,
     X_PERSON_ID,
     X_SEQUENCE_NUMBER,
     X_ASS_ASSESSOR_TYPE,
     X_PRIMARY_ASSESSOR_IND,
     X_ITEM_LIMIT,
     X_LOCATION_CD,
     X_UNIT_MODE,
     X_UNIT_CLASS,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ASS_ID,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_ASS_ASSESSOR_TYPE,
   X_PRIMARY_ASSESSOR_IND,
   X_ITEM_LIMIT,
   X_LOCATION_CD,
   X_UNIT_MODE,
   X_UNIT_CLASS,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_ITEM_ASSESSOR
 where ROWID = X_ROWID;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
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
	ELSIF upper(Column_name) = 'PRIMARY_ASSESSOR_IND' then
	    new_references.primary_assessor_ind := column_value;
      ELSIF upper(Column_name) = 'ASS_ASSESSOR_TYPE'  then
	    new_references.ass_assessor_type := column_value;
      ELSIF upper(Column_name) = 'LOCATION_CD' then
	    new_references.location_cd := column_value;
      ELSIF upper(Column_name) = 'UNIT_CLASS' then
	    new_references.unit_class := column_value;
      ELSIF upper(Column_name) = 'UNIT_MODE' then
	    new_references.unit_mode := column_value;
      ELSIF upper(Column_name) = 'ITEM_LIMIT' then
          new_references.item_limit := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
          new_references.item_limit := igs_ge_number.to_num(column_value);
      END IF;


IF upper(column_name) = 'PRIMARY_ASSESSOR_IND'  OR
     column_name is null Then
IF new_references.primary_assessor_ind NOT IN ('Y' , 'N')  Then
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      END IF;


IF upper(column_name) = 'ASS_ASSESSOR_TYPE' OR
     column_name is null Then
IF new_references.ass_assessor_type <> UPPER(new_references.ass_assessor_type) Then
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      END IF;

IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
IF new_references.location_cd <>
UPPER(new_references.location_cd) Then
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      END IF;

IF upper(column_name) = 'PRIMARY_ASSESSOR_IND' OR
     column_name is null Then
     IF new_references.primary_assessor_ind  <>
UPPER(new_references.primary_assessor_ind) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
      END IF;
    IF upper(column_name) = 'UNIT_CLASS' OR
     column_name is null Then
     IF new_references.unit_class <>
UPPER(new_references.unit_class) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
    IF upper(column_name) = 'UNIT_MODE' OR
     column_name is null Then
     IF new_references.unit_mode <>
UPPER(new_references.unit_mode) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
                         END IF;

     IF upper(column_name) = 'ITEM_LIMIT' OR
     column_name is null Then
     IF new_references.item_limit < 0 OR new_references.item_limit > 99999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
                         END IF;


          IF upper(column_name) = 'SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.sequence_number <  1 OR new_references.sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
                         END IF;


	     END Check_Constraints;
end IGS_AS_ITEM_ASSESSOR_PKG;

/
