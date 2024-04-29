--------------------------------------------------------
--  DDL for Package Body IGS_AV_STND_ALT_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_STND_ALT_UNIT_PKG" AS
/* $Header: IGSBI07B.pls 120.0 2005/07/05 12:24:53 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AV_STND_ALT_UNIT%RowType;
  new_references IGS_AV_STND_ALT_UNIT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_av_stnd_unit_id IN NUMBER DEFAULT NULL,
    x_alt_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_alt_version_number IN NUMBER DEFAULT NULL,
    x_optional_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AV_STND_ALT_UNIT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      Igs_Ge_Msg_Stack.Add;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.av_stnd_unit_id := x_av_stnd_unit_id;
    new_references.alt_unit_cd := x_alt_unit_cd;
    new_references.alt_version_number := x_alt_version_number;
    new_references.optional_ind := x_optional_ind;
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
  -- "OSS_TST".trg_asau_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AV_STND_ALT_UNIT
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name  varchar2(30);
   cursor cur is select * from IGS_AV_STND_UNIT_ALL
              where av_stnd_unit_id =new_references.av_stnd_unit_id;
   rec    cur%rowtype;
  BEGIN
        OPEN CUR;
	FETCH CUR INTO REC;
	-- Validate Advanced Standing Recognition Type IS 'PRECLUDE'.
	IF p_inserting THEN
		IF IGS_AV_VAL_ASAU.advp_val_alt_unit (
					rec.person_id,                      --new_references.person_id,
					rec.as_course_cd,                --new_references.as_course_cd,
					rec.as_version_number,        --new_references.as_version_number,
					rec.s_adv_stnd_type,            --new_references.s_adv_stnd_type,
					rec.unit_cd,                           --new_references.unit_cd,
					rec.version_number,              --new_references.version_number,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			Igs_Ge_Msg_Stack.Add;
                         App_Exception.Raise_Exception;
                END IF;
	END IF;
	-- Validate Alternate IGS_PS_UNIT IS different from Precluded IGS_PS_UNIT.
	IF (p_inserting OR (old_references.alt_unit_cd) <> (new_references.alt_unit_cd)) THEN
		IF IGS_AV_VAL_ASAU.advp_val_prclde_unit (
					 rec.unit_cd,                                  --new_references.unit_cd,
					new_references.alt_unit_cd,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			Igs_Ge_Msg_Stack.Add;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate Optional Indicators are the same.
	CLOSE CUR;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
   )
   AS
   BEGIN
    IF  column_name IS null then
       NULL;
    ELSIF upper(Column_name) = 'ALT_UNIT_CD' then
       new_references.alt_unit_cd := column_value;
    ELSIF upper(Column_name) = 'OPTIONAL_IND' then
       new_references.optional_ind := column_value;
    END IF;
   IF upper(column_name) = 'ALT_UNIT_CD' OR
	     column_name IS null Then
	     IF new_references.ALT_UNIT_CD <>
		UPPER(new_references.ALT_UNIT_CD) Then
	       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	       Igs_Ge_Msg_Stack.Add;
	       App_Exception.Raise_Exception;
	     END IF;
END IF;
IF upper(column_name) = 'OPTIONAL_IND' OR
     column_name IS null Then
     IF new_references.OPTIONAL_IND <>
	UPPER(new_references.OPTIONAL_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'OPTIONAL_IND' OR
     column_name IS null Then
     IF (new_references.optional_ind not in ('Y', 'N')) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END Check_Constraints;

PROCEDURE Check_Parent_Existance AS
BEGIN

    IF ((old_references.av_stnd_unit_id= new_references.av_stnd_unit_id) OR
        (new_references.av_stnd_unit_id IS NULL) ) THEN
      NULL;
    ELSE
      IF  NOT IGS_AV_STND_UNIT_PKG.Get_PK_For_Validation (
        new_references.av_stnd_unit_id
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     Igs_Ge_Msg_Stack.Add;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.alt_unit_cd = new_references.alt_unit_cd) AND
         (old_references.alt_version_number = new_references.alt_version_number)) OR
        ((new_references.alt_unit_cd IS NULL) AND
         (new_references.alt_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (
        new_references.alt_unit_cd,
        new_references.alt_version_number
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     Igs_Ge_Msg_Stack.Add;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  Function Get_PK_For_Validation (
    x_av_stnd_unit_id IN NUMBER,
    x_alt_unit_cd IN VARCHAR2,
    x_alt_version_number IN NUMBER
    ) Return Boolean
	AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_ALT_UNIT
      WHERE av_stnd_unit_id =  x_av_stnd_unit_id
      AND      alt_unit_cd = x_alt_unit_cd
      AND      alt_version_number = x_alt_version_number
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

  PROCEDURE GET_FK_IGS_AV_STND_UNIT(
     x_av_stnd_unit_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_ALT_UNIT
      WHERE    av_stnd_unit_id = x_av_stnd_unit_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASAU_ASU_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AV_STND_UNIT;

  PROCEDURE GET_FK_IGS_PS_UNIT_VER(
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_ALT_UNIT
      WHERE    alt_unit_cd = x_unit_cd
      AND      alt_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASAU_UV_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_VER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_av_stnd_unit_id IN NUMBER DEFAULT NULL,
    x_alt_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_alt_version_number IN NUMBER DEFAULT NULL,
    x_optional_ind IN VARCHAR2 DEFAULT NULL,
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
      x_av_stnd_unit_id,
      x_alt_unit_cd,
      x_alt_version_number,
      x_optional_ind,
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
	    	    new_references.av_stnd_unit_id,
		    new_references.alt_unit_cd,
                    new_references.alt_version_number
		    ) THEN
	  	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	  	         Igs_Ge_Msg_Stack.Add;
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
      Null;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	      IF  Get_PK_For_Validation (
	    	       new_references.av_stnd_unit_id,
                       new_references.alt_unit_cd,
                       new_references.alt_version_number
			) THEN
	            Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	            Igs_Ge_Msg_Stack.Add;
	            App_Exception.Raise_Exception;
	      END IF;
	      Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	       Check_Constraints;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
	      null;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C IS select ROWID from IGS_AV_STND_ALT_UNIT
      where AV_STND_UNIT_ID = X_AV_STND_UNIT_ID
      and ALT_UNIT_CD = X_ALT_UNIT_CD
      and ALT_VERSION_NUMBER = X_ALT_VERSION_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY IS NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN IS NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_av_stnd_unit_id =>X_AV_STND_UNIT_ID,
 x_alt_unit_cd=>X_ALT_UNIT_CD,
 x_alt_version_number=>X_ALT_VERSION_NUMBER,
 x_optional_ind=>NVL(X_OPTIONAL_IND,'N'),
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_AV_STND_ALT_UNIT (
    AV_STND_UNIT_ID,
    ALT_UNIT_CD,
    ALT_VERSION_NUMBER,
    OPTIONAL_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.AV_STND_UNIT_ID,
    NEW_REFERENCES.ALT_UNIT_CD,
    NEW_REFERENCES.ALT_VERSION_NUMBER,
    NEW_REFERENCES.OPTIONAL_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2
) AS
  cursor c1 IS select
      OPTIONAL_IND
    from IGS_AV_STND_ALT_UNIT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    Igs_Ge_Msg_Stack.Add;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.OPTIONAL_IND = X_OPTIONAL_IND)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2,
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
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY IS NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN IS NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_av_stnd_unit_id=>X_AV_STND_UNIT_ID,
 x_alt_unit_cd=>X_ALT_UNIT_CD,
 x_alt_version_number=>X_ALT_VERSION_NUMBER,
 x_optional_ind=>X_OPTIONAL_IND,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_AV_STND_ALT_UNIT set
    OPTIONAL_IND = NEW_REFERENCES.OPTIONAL_IND,
    LAST_UPDATE_DATE = LAST_UPDATE_DATE,
    LAST_UPDATED_BY =  LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 IS select rowid from IGS_AV_STND_ALT_UNIT
     where AV_STND_UNIT_ID =X_AV_STND_UNIT_ID
     and ALT_UNIT_CD = X_ALT_UNIT_CD
     and ALT_VERSION_NUMBER = X_ALT_VERSION_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_AV_STND_UNIT_ID,
     X_ALT_UNIT_CD,
     X_ALT_VERSION_NUMBER,
     X_OPTIONAL_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_AV_STND_UNIT_ID,
   X_ALT_UNIT_CD,
   X_ALT_VERSION_NUMBER,
   X_OPTIONAL_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 ) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_AV_STND_ALT_UNIT
  where ROWID = X_ROWID ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

end DELETE_ROW;

end IGS_AV_STND_ALT_UNIT_PKG;

/
