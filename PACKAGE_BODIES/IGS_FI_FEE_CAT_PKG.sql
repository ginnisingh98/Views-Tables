--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_CAT_PKG" AS
 /* $Header: IGSSI23B.pls 115.19 2003/12/05 05:45:48 ckasu ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_CAT_ALL%RowType;
  new_references IGS_FI_FEE_CAT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_currency_cd IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_CAT_ALL
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
    new_references.description := x_description;
    new_references.currency_cd := x_currency_cd;
    new_references.closed_ind := x_closed_ind;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.org_id := x_org_id;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END Set_Column_Values;
  -- Trigger description :-
  -- "OSS_TST".trg_fc_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_FEE_CAT_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate Fee Category can be closed.
	IF (p_updating AND (old_references.closed_ind <> new_references.closed_ind)) THEN
		IF IGS_FI_VAL_FC.finp_val_fc_clsd_upd (
					new_references.fee_cat,
					new_references.closed_ind,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

    -- Fee Category records can be deleted logically by  making closed_ind as 'Y'
    --    No physical deletion is allowed. As a part of Bug # 2729919
    -- Preventing deletion of the Fee Category records.
    IF p_deleting = TRUE THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_DEL_NOT_ALLWD');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END BeforeRowInsertUpdateDelete1;

   PROCEDURE Check_Constraints (
     Column_Name	IN	VARCHAR2	,
     Column_Value 	IN	VARCHAR2
     )AS
   /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        12-May-2002     removed upper check constraint on fee category column.bug#2344826.
  ----------------------------------------------------------------------------*/
   BEGIN
     IF Column_Name is NULL THEN
       NULL;
     ELSIF upper(Column_Name) = 'CLOSED_IND' then
       new_references.closed_ind := Column_Value;
     ELSIF upper(Column_Name) = 'CURRENCY_CD' then
       new_references.currency_cd := Column_Value;
     END IF;

     IF upper(Column_Name) = 'CLOSED_IND' OR
        column_name is NULL THEN
       IF new_references.closed_ind <> 'N' AND new_references.closed_ind <> 'Y' THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
	 App_Exception.Raise_Exception;
       END IF;
     END IF;

     IF upper(Column_Name) = 'CURRENCY_CD' OR
        column_name is NULL THEN
        IF new_references.currency_cd <> UPPER(new_references.currency_cd) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception;
	END IF;
     END IF;

   END Check_Constraints;


  PROCEDURE Check_Child_Existance AS
  ------------------------------------------------------------------
  --Change History:

  --Who         When            What
  --ckasu     04-Dec-2003      Added IGS_EN_SPA_TERMS_PKG.GET_FK_IGS_FI_FEE_CAT
  --                           for Term Records Build Bug# 2829263

  -------------------------------------------------------------------

  BEGIN
    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_FI_FEE_CAT (
      old_references.fee_cat
      );
    IGS_FI_F_CAT_CA_INST_PKG.GET_FK_IGS_FI_FEE_CAT (
      old_references.fee_cat
      );
    IGS_FI_FEE_CAT_MAP_PKG.GET_FK_IGS_FI_FEE_CAT (
      old_references.fee_cat
      );
    IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_FI_FEE_CAT (
      old_references.fee_cat
      );
    IGS_EN_SPA_TERMS_PKG.GET_FK_IGS_FI_FEE_CAT (
      old_references.fee_cat
      );
  END check_child_existance;


  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2
    ) RETURN BOOLEAN AS
    -- Bug# 2729919, removed 'FOR UPDATE NOWAIT' clause is removed from the cursor.
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_CAT_ALL
      WHERE    fee_cat = x_fee_cat;
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_currency_cd IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  ------------------------------------------------------------------
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smadathi    06-Nov-2002     Enh. Bug 2584986.Removed refereces to check_parent_existance.
  --                            procedure call.
  -------------------------------------------------------------------
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cat,
      x_description,
      x_currency_cd,
      x_closed_ind,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
                                     p_deleting  => FALSE
                                   );
      IF Get_PK_For_Validation ( new_references.fee_cat ) THEN
	  	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
	  END IF;
	  Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => TRUE,
                                     p_deleting  => FALSE
                                   );
	  Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE
                                   );
      Check_Child_Existance;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation ( new_references.fee_cat ) THEN
	  	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
	  END IF;
      Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before UPdate.
      Check_Constraints;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE
                                   );
      Check_Child_Existance;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER ,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_FI_FEE_CAT_ALL
      where FEE_CAT = X_FEE_CAT;
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
 x_closed_ind=>NVL(X_CLOSED_IND,'N'),
 x_currency_cd=>X_CURRENCY_CD,
 x_description=>X_DESCRIPTION,
 x_fee_cat=>X_FEE_CAT,
 x_org_id=>igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_FI_FEE_CAT_ALL (
    FEE_CAT,
    DESCRIPTION,
    CURRENCY_CD,
    CLOSED_IND,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.CURRENCY_CD,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.ORG_ID,
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
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      CURRENCY_CD,
      CLOSED_IND
    from IGS_FI_FEE_CAT_ALL
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
  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.CURRENCY_CD = X_CURRENCY_CD)
           OR ((tlinfo.CURRENCY_CD is null)
               AND (X_CURRENCY_CD is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2

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
 x_closed_ind=>X_CLOSED_IND,
 x_currency_cd=>X_CURRENCY_CD,
 x_description=>X_DESCRIPTION,
 x_fee_cat=>X_FEE_CAT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_FI_FEE_CAT_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    CURRENCY_CD = NEW_REFERENCES.CURRENCY_CD,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER ,
  X_MODE in VARCHAR2

  ) AS
  cursor c1 is select rowid from IGS_FI_FEE_CAT_ALL
     where FEE_CAT = X_FEE_CAT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_DESCRIPTION,
     X_CURRENCY_CD,
     X_CLOSED_IND,
     X_ORG_ID,
     X_MODE
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_DESCRIPTION,
   X_CURRENCY_CD,
   X_CLOSED_IND,
   X_MODE
   );
end ADD_ROW;
PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
BEfore_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_FEE_CAT_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
END delete_row;

END igs_fi_fee_cat_pkg;

/
