--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_CAT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_CAT_MAP_PKG" AS
 /* $Header: IGSSI25B.pls 115.6 2003/10/30 13:31:57 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_CAT_MAP%RowType;
  new_references IGS_FI_FEE_CAT_MAP%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_dflt_cat_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_CAT_MAP
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.fee_cat := x_fee_cat;
    new_references.admission_cat := x_admission_cat;
    new_references.dflt_cat_ind := x_dflt_cat_ind;
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
  -- "OSS_TST".trg_fcm_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_FEE_CAT_MAP
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_admission_cat	IGS_FI_FEE_CAT_MAP.admission_cat%TYPE;
	v_message_name varchar2(30);
  BEGIN
	IF p_inserting THEN
		-- Validate the fee category closed indicator.
		IF IGS_AD_VAL_FCM.finp_val_fc_closed (
				new_references.fee_cat,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Set the Admission Category value.
	IF p_deleting THEN
		v_admission_cat := old_references.admission_cat;
	ELSE
		v_admission_cat := new_references.admission_cat;
	END IF;
	-- Validate the admission category closed indicator.
	IF IGS_AD_VAL_ACCT.admp_val_ac_closed (
			v_admission_cat,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
  END BeforeRowInsertUpdateDelete1;



  PROCEDURE Check_Constraints (
     Column_Name	IN	VARCHAR2	DEFAULT NULL,
     Column_Value 	IN	VARCHAR2	DEFAULT NULL
     )AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        17-May-2002     removed upper check constraint on fee_cat column.bug#2344826.
  ----------------------------------------------------------------------------*/
   BEGIN
   IF Column_Name is NULL THEN
     	NULL;
   ELSIF upper(Column_Name) = 'ADMISSION_CAT' then
     	new_references.admission_cat := Column_Value;
   ELSIF upper(Column_Name) = 'DFLT_CAT_IND' then
     	new_references.dflt_cat_ind := Column_Value;
   END IF;

   IF upper(Column_Name) = 'ADMISSION_CAT' OR
     		column_name is NULL THEN
   		IF new_references.admission_cat <> UPPER(new_references.admission_cat) THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
   END IF;
   IF upper(Column_Name) = 'DFLT_CAT_IND' OR
        		column_name is NULL THEN
      		IF new_references.dflt_cat_ind <> 'Y' AND new_references.dflt_cat_ind <> 'N' THEN
      			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
      			App_Exception.Raise_Exception;
      		END IF;
   END IF;
   END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AD_CAT_PKG.Get_PK_For_Validation ( new_references.admission_cat, 'N' ) THEN
		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
    	App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_FEE_CAT_PKG.Get_PK_For_Validation (new_references.fee_cat ) THEN
		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
    	App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_admission_cat IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_CAT_MAP
      WHERE    fee_cat = x_fee_cat
      AND      admission_cat = x_admission_cat
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

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_CAT_MAP
      WHERE    admission_cat = x_admission_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCM_AC_FK');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_CAT;
  PROCEDURE GET_FK_IGS_FI_FEE_CAT (
    x_fee_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_CAT_MAP
      WHERE    fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCM_FC_FK');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_CAT;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_dflt_cat_ind IN VARCHAR2 DEFAULT NULL,
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
      x_fee_cat,
      x_admission_cat,
      x_dflt_cat_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
		IF Get_PK_For_Validation ( new_references.fee_cat,
				new_references.admission_cat  )
				THEN
			  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                                IGS_GE_MSG_STACK.ADD;
	          		App_Exception.Raise_Exception;
		END IF;
	    Check_Constraints;
        Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
    	BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
		Check_Constraints;
		Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
		IF Get_PK_For_Validation ( new_references.fee_cat,
			new_references.admission_cat  )
			THEN
		  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                                IGS_GE_MSG_STACK.ADD;
          		App_Exception.Raise_Exception;
		END IF;
		Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 	Check_Constraints;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_FEE_CAT_MAP
      where FEE_CAT = X_FEE_CAT
      and ADMISSION_CAT = X_ADMISSION_CAT;
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
  x_admission_cat=>X_ADMISSION_CAT,
  x_dflt_cat_ind=>NVL(X_DFLT_CAT_IND,'N'),
  x_fee_cat=>X_FEE_CAT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_FEE_CAT_MAP (
    FEE_CAT,
    ADMISSION_CAT,
    DFLT_CAT_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.DFLT_CAT_IND,
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
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2
) AS
  cursor c1 is select
      DFLT_CAT_IND
    from IGS_FI_FEE_CAT_MAP
    where ROWID = X_ROWID
    for update nowait;
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
  if ( (tlinfo.DFLT_CAT_IND = X_DFLT_CAT_IND)
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
  X_FEE_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
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
  x_admission_cat=>X_ADMISSION_CAT,
  x_dflt_cat_ind=>X_DFLT_CAT_IND,
  x_fee_cat=>X_FEE_CAT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_FEE_CAT_MAP set
    DFLT_CAT_IND = NEW_REFERENCES.DFLT_CAT_IND,
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
  X_FEE_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_FEE_CAT_MAP
     where FEE_CAT = X_FEE_CAT
     and ADMISSION_CAT = X_ADMISSION_CAT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_ADMISSION_CAT,
     X_DFLT_CAT_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_ADMISSION_CAT,
   X_DFLT_CAT_IND,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_FEE_CAT_MAP
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_FEE_CAT_MAP_PKG;

/
