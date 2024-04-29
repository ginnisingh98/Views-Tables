--------------------------------------------------------
--  DDL for Package Body IGS_AS_UNT_PATRN_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_UNT_PATRN_ITM_PKG" as
/* $Header: IGSDI32B.pls 120.0 2005/07/05 13:00:43 appldev noship $ */

--

  l_rowid VARCHAR2(25);
  old_references IGS_AS_UNT_PATRN_ITM%RowType;
  new_references IGS_AS_UNT_PATRN_ITM%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_uai_sequence_number IN NUMBER DEFAULT NULL,
    x_apportionment_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_UNT_PATRN_ITM
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type:= x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ass_pattern_id := x_ass_pattern_id;
    new_references.ass_id := x_ass_id;
    new_references.uai_sequence_number := x_uai_sequence_number;
    new_references.apportionment_percentage := x_apportionment_percentage;
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
  -- "OSS_TST".trg_uapi_br_id
  -- BEFORE INSERT OR DELETE
  -- ON IGS_AS_UNT_PATRN_ITM
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
	v_message_name  varchar2(30);
	CURSOR	c_uap	(cp_unit_cd		IGS_AS_UNTAS_PATTERN.unit_cd%TYPE,
			cp_version_number	IGS_AS_UNTAS_PATTERN.version_number%TYPE,
			cp_cal_type		IGS_AS_UNTAS_PATTERN.cal_type%TYPE,
			cp_ci_sequence_number	IGS_AS_UNTAS_PATTERN.ci_sequence_number%TYPE,
			cp_ass_pattern_id		IGS_AS_UNTAS_PATTERN.ass_pattern_id%TYPE) IS
		SELECT	uap.action_dt
		FROM	IGS_AS_UNTAS_PATTERN uap
		WHERE	uap.unit_cd		= cp_unit_cd 		AND
			uap.version_number	= cp_version_number	AND
			uap.cal_type		= cp_cal_type		AND
			uap.ci_sequence_number 	= cp_ci_sequence_number 	AND
			uap.ass_pattern_id		= cp_ass_pattern_id 	AND
			uap.action_dt		IS NULL
		FOR UPDATE OF uap.action_dt NOWAIT;
  BEGIN
	-- Validate IGS_AD_LOCATION code, IGS_PS_UNIT class and IGS_PS_UNIT mode must match at the item and
	-- pattern level.
	IF  p_inserting THEN
		IF  IGS_AS_VAL_UAPI.assp_val_uapi_uoo (	new_references.unit_cd,
						new_references.version_number,
						new_references.cal_type,
						new_references.ci_sequence_number,
						new_references.ass_pattern_id,
						new_references.ass_id,
						new_references.uai_sequence_number,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting THEN
		-- Update the action date of the IGS_AS_UNTAS_PATTERN table
		FOR v_uap_rec IN c_uap(	new_references.unit_cd,
					new_references.version_number,
					new_references.cal_type,
					new_references.ci_sequence_number,
					new_references.ass_pattern_id) LOOP
			UPDATE 	IGS_AS_UNTAS_PATTERN uap
			SET	uap.action_dt = SYSDATE
			WHERE CURRENT OF c_uap;
		END LOOP;
	END IF;
	IF p_deleting THEN
		-- Update the action date of the IGS_AS_UNTAS_PATTERN table
		FOR v_uap_rec IN c_uap(	old_references.unit_cd,
					old_references.version_number,
					old_references.cal_type,
					old_references.ci_sequence_number,
					old_references.ass_pattern_id) LOOP
			UPDATE 	IGS_AS_UNTAS_PATTERN uap
			SET	uap.action_dt = SYSDATE
			WHERE CURRENT OF c_uap;
		END LOOP;
	END IF;


  END BeforeRowInsertDelete1;


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type= new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.ass_id = new_references.ass_id) AND
         (old_references.uai_sequence_number = new_references.uai_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.ass_id IS NULL) OR
         (new_references.uai_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF IGS_AS_UNITASS_ITEM_PKG.Get_UK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.ass_id,
        new_references.uai_sequence_number
        )THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type= new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.ass_pattern_id = new_references.ass_pattern_id)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.ass_pattern_id IS NULL))) THEN
      NULL;
    ELSE
        IF NOT(IGS_AS_UNTAS_PATTERN_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.ass_pattern_id
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) as
BEGIN

      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
         new_references.ci_sequence_number:= igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'APPORTIONMENT_PERCENTAGE' then
         new_references.apportionment_percentage:= igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'UAI_SEQUENCE_NUMBER' then
         new_references.uai_sequence_number:= igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'CAL_TYPE' then
         new_references.cal_type:= column_value;
      ELSIF upper(Column_name) = 'UNIT_CD' then
         new_references.unit_cd:= column_value;
      END IF;
     IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
        column_name is null Then
        IF  new_references.ci_sequence_number < 1  AND   new_references.ci_sequence_number > 999999 Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'APPORTIONMENT_PERCENTAGE' OR
        column_name is null Then
        IF new_references.apportionment_percentage < 0  AND   new_references.apportionment_percentage > 100 Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'UAI_SEQUENCE_NUMBER' OR
        column_name is null Then
        IF  new_references.uai_sequence_number < 1  AND   new_references.uai_sequence_number > 999999 Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'CAL_TYPE' OR
        column_name is null Then
        IF new_references.cal_type <> UPPER(new_references.cal_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'UNIT_CD' OR
        column_name is null Then
        IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;


END Check_Constraints;


  FUNCTION   Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_pattern_id IN NUMBER,
    x_ass_id IN NUMBER,
    x_uai_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNT_PATRN_ITM
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      ass_pattern_id = x_ass_pattern_id
      AND      ass_id = x_ass_id
      AND      uai_sequence_number = x_uai_sequence_number
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

  PROCEDURE GET_FK_IGS_AS_UNITASS_ITEM (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNT_PATRN_ITM
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      ass_id = x_ass_id
      AND      uai_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UAPI_UAI_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_UNITASS_ITEM;

  PROCEDURE GET_FK_IGS_AS_UNTAS_PATTERN (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_pattern_id IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_UNT_PATRN_ITM
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      ass_pattern_id = x_ass_pattern_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_UAPI_UAP_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_UNTAS_PATTERN;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_uai_sequence_number IN NUMBER DEFAULT NULL,
    x_apportionment_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_pattern_id,
      x_ass_id,
      x_uai_sequence_number,
      x_apportionment_percentage,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
             new_references.unit_cd ,
             new_references.version_number ,
             new_references.cal_type,
             new_references.ci_sequence_number,
             new_references.ass_pattern_id ,
             new_references.ass_id ,
             new_references.uai_sequence_number
		             ) THEN
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
     END IF;
  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
             new_references.unit_cd ,
             new_references.version_number,
             new_references.cal_type ,
             new_references.ci_sequence_number,
             new_references.ass_pattern_id ,
             new_references.ass_id ,
             new_references.uai_sequence_number
		             ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
           NULL;
    END IF;

  END Before_DML;

--
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AS_UNT_PATRN_ITM
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and ASS_PATTERN_ID = X_ASS_PATTERN_ID
      and ASS_ID = X_ASS_ID
      and UAI_SEQUENCE_NUMBER = X_UAI_SEQUENCE_NUMBER;
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
--
  Before_DML(
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_apportionment_percentage=>X_APPORTIONMENT_PERCENTAGE,
   x_ass_id=>X_ASS_ID,
   x_ass_pattern_id=>X_ASS_PATTERN_ID,
   x_cal_type=>X_CAL_TYPE,
   x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
   x_uai_sequence_number=>X_UAI_SEQUENCE_NUMBER,
   x_unit_cd=>X_UNIT_CD,
   x_version_number=>X_VERSION_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
--
  insert into IGS_AS_UNT_PATRN_ITM (
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    ASS_PATTERN_ID,
    ASS_ID,
    UAI_SEQUENCE_NUMBER,
    APPORTIONMENT_PERCENTAGE,
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
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ASS_PATTERN_ID,
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.UAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.APPORTIONMENT_PERCENTAGE,
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
--
--
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER
) as
  cursor c1 is select
      APPORTIONMENT_PERCENTAGE
    from IGS_AS_UNT_PATRN_ITM
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.APPORTIONMENT_PERCENTAGE = X_APPORTIONMENT_PERCENTAGE)
           OR ((tlinfo.APPORTIONMENT_PERCENTAGE is null)
               AND (X_APPORTIONMENT_PERCENTAGE is null)))
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
  X_ROWID in  VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_apportionment_percentage=>X_APPORTIONMENT_PERCENTAGE,
   x_ass_id=>X_ASS_ID,
   x_ass_pattern_id=>X_ASS_PATTERN_ID,
   x_cal_type=>X_CAL_TYPE,
   x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
   x_uai_sequence_number=>X_UAI_SEQUENCE_NUMBER,
   x_unit_cd=>X_UNIT_CD,
   x_version_number=>X_VERSION_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

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
--

--
end if;
  update IGS_AS_UNT_PATRN_ITM set
    APPORTIONMENT_PERCENTAGE = NEW_REFERENCES.APPORTIONMENT_PERCENTAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
--
--
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AS_UNT_PATRN_ITM
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and ASS_PATTERN_ID = X_ASS_PATTERN_ID
     and ASS_ID = X_ASS_ID
     and UAI_SEQUENCE_NUMBER = X_UAI_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_ASS_PATTERN_ID,
     X_ASS_ID,
     X_UAI_SEQUENCE_NUMBER,
     X_APPORTIONMENT_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_ASS_PATTERN_ID,
   X_ASS_ID,
   X_UAI_SEQUENCE_NUMBER,
   X_APPORTIONMENT_PERCENTAGE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2) as
begin
--
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
--
  delete from IGS_AS_UNT_PATRN_ITM
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
--
--
end DELETE_ROW;

end IGS_AS_UNT_PATRN_ITM_PKG;

/
