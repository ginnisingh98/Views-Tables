--------------------------------------------------------
--  DDL for Package Body IGS_AD_ADM_UNIT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ADM_UNIT_STAT_PKG" AS
/* $Header: IGSAI01B.pls 115.12 2003/10/30 13:09:45 akadam ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_ADM_UNIT_STAT_ALL%RowType;
  new_references IGS_AD_ADM_UNIT_STAT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_show_on_offic_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_effective_progression_ind IN VARCHAR2 DEFAULT NULL,
    x_effective_time_elapsed_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_ADM_UNIT_STAT_ALL
      WHERE    rowid = x_rowid;
  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.administrative_unit_status := x_administrative_unit_status;
    new_references.unit_attempt_status := x_unit_attempt_status;
    new_references.description := x_description;
    new_references.show_on_offic_ntfctn_ind := x_show_on_offic_ntfctn_ind;
    new_references.effective_progression_ind := x_effective_progression_ind;
    new_references.effective_time_elapsed_ind := x_effective_time_elapsed_ind;
    new_references.closed_ind := x_closed_ind;
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
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    IF  new_references.unit_attempt_status <> 'DISCONTIN' THEN
		IF  IGS_EN_VAL_AUS.ENRP_VAL_AUS_AUSG(new_references.administrative_unit_status
						  ,v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
   	            IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
		END IF;
	    END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.unit_attempt_status = new_references.unit_attempt_status)) OR
        ((new_references.unit_attempt_status IS NULL))) THEN
      NULL;
    ELSE
 	IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
		'UNIT_ATTEMPT_STATUS', new_references.unit_attempt_status  ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Constraints (
		Column_Name IN VARCHAR2 DEFAULT NULL,
		Column_Value IN VARCHAR2 DEFAULT NULL ) AS

  BEGIN

      IF Column_Name IS NULL THEN
	   NULL;
	ELSIF upper(Column_Name) = 'EFFECTIVE_PROGRESSION_IND' THEN
	   new_references.effective_progression_ind := column_value ;
      ELSIF upper(Column_Name) = 'CLOSED_IND' THEN
	   new_references.closed_ind := column_value ;
      ELSIF upper(Column_Name) = 'ADMINISTRATIVE_UNIT_STATUS' THEN
	   new_references.administrative_unit_status := column_value ;
      ELSIF upper(Column_Name) = 'EFFECTIVE_TIME_ELAPSED_IND' THEN
	   new_references.effective_time_elapsed_ind := column_value ;
      ELSIF upper(Column_Name) = 'SHOW_ON_OFFIC_NTFCTN_IND' THEN
	   new_references.show_on_offic_ntfctn_ind := column_value ;
      ELSIF upper(Column_Name) = 'UNIT_ATTEMPT_STATUS' THEN
	   new_references.unit_attempt_status := column_value ;
  	END IF;

	IF upper(column_name) = 'EFFECTIVE_PROGRESSION_IND' OR
         column_name IS NULL THEN
	   IF new_references.effective_progression_ind NOT IN ( 'Y' , 'N' ) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;
	IF upper(column_name) = 'CLOSED_IND' OR
         column_name IS NULL THEN
	   IF new_references.closed_ind NOT IN ( 'Y' , 'N' ) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;
	IF upper(column_name) = 'ADMINISTRATIVE_UNIT_STATUS' OR
         column_name IS NULL THEN
	   IF new_references.administrative_unit_status <> UPPER(new_references.administrative_unit_status) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;

	IF upper(column_name) = 'EFFECTIVE_TIME_ELAPSED_IND' OR
         column_name IS NULL THEN
	   IF new_references.effective_time_elapsed_ind  NOT IN ( 'Y' , 'N' ) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;
      IF upper(column_Name) = 'SHOW_ON_OFFIC_NTFCTN_IND' OR
         column_name IS NULL THEN
	   IF new_references.show_on_offic_ntfctn_ind NOT IN ( 'Y' , 'N' ) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;
      IF upper(Column_Name) = 'UNIT_ATTEMPT_STATUS' OR
         column_name IS NULL THEN
	   IF new_references.unit_attempt_status <> upper(new_references.unit_attempt_status) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	   END IF;
      END IF;

  END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_administrative_unit_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_ADM_UNIT_STAT_ALL
      WHERE    administrative_unit_status = x_administrative_unit_status AND
               closed_ind = NVL(x_closed_ind,closed_ind);


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
	Return True;
    ELSE
      Close cur_rowid;
	Return False;
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_unit_attempt_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_ADM_UNIT_STAT_ALL
      WHERE    unit_attempt_status = x_unit_attempt_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUS_LKUPV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_show_on_offic_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_effective_progression_ind IN VARCHAR2 DEFAULT NULL,
    x_effective_time_elapsed_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_administrative_unit_status,
      x_unit_attempt_status,
      x_description,
      x_show_on_offic_ntfctn_ind,
      x_effective_progression_ind,
      x_effective_time_elapsed_ind,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
     IF Get_PK_For_Validation (new_references.administrative_unit_status  ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
    Check_Constraints ;
     Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
     IF Get_PK_For_Validation (new_references.administrative_unit_status  ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
     Check_Constraints ;
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

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_ADM_UNIT_STAT_ALL
      where ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS;
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

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
    x_unit_attempt_status => X_UNIT_ATTEMPT_STATUS,
    x_description => X_DESCRIPTION,
    x_show_on_offic_ntfctn_ind => Nvl(X_SHOW_ON_OFFIC_NTFCTN_IND, 'Y'),
    x_effective_progression_ind => Nvl(X_EFFECTIVE_PROGRESSION_IND, 'Y'),
    x_effective_time_elapsed_ind => Nvl(X_EFFECTIVE_TIME_ELAPSED_IND, 'Y'),
    x_closed_ind => Nvl(X_CLOSED_IND, 'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_ADM_UNIT_STAT_ALL (
    ORG_ID,
    ADMINISTRATIVE_UNIT_STATUS,
    UNIT_ATTEMPT_STATUS,
    DESCRIPTION,
    SHOW_ON_OFFIC_NTFCTN_IND,
    EFFECTIVE_PROGRESSION_IND,
    EFFECTIVE_TIME_ELAPSED_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ADMINISTRATIVE_UNIT_STATUS,
    NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.SHOW_ON_OFFIC_NTFCTN_IND,
    NEW_REFERENCES.EFFECTIVE_PROGRESSION_IND,
    NEW_REFERENCES.EFFECTIVE_TIME_ELAPSED_IND,
    NEW_REFERENCES.CLOSED_IND,
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
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      UNIT_ATTEMPT_STATUS,
      DESCRIPTION,
      SHOW_ON_OFFIC_NTFCTN_IND,
      EFFECTIVE_PROGRESSION_IND,
      EFFECTIVE_TIME_ELAPSED_IND,
      CLOSED_IND
    from IGS_AD_ADM_UNIT_STAT_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.UNIT_ATTEMPT_STATUS = X_UNIT_ATTEMPT_STATUS)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.SHOW_ON_OFFIC_NTFCTN_IND = X_SHOW_ON_OFFIC_NTFCTN_IND)
      AND (tlinfo.EFFECTIVE_PROGRESSION_IND = X_EFFECTIVE_PROGRESSION_IND)
      AND (tlinfo.EFFECTIVE_TIME_ELAPSED_IND = X_EFFECTIVE_TIME_ELAPSED_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
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

  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
    x_unit_attempt_status => X_UNIT_ATTEMPT_STATUS,
    x_description => X_DESCRIPTION,
    x_show_on_offic_ntfctn_ind => X_SHOW_ON_OFFIC_NTFCTN_IND,
    x_effective_progression_ind => X_EFFECTIVE_PROGRESSION_IND,
    x_effective_time_elapsed_ind => X_EFFECTIVE_TIME_ELAPSED_IND,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_ADM_UNIT_STAT_ALL set
    UNIT_ATTEMPT_STATUS = NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    SHOW_ON_OFFIC_NTFCTN_IND = NEW_REFERENCES.SHOW_ON_OFFIC_NTFCTN_IND,
    EFFECTIVE_PROGRESSION_IND = NEW_REFERENCES.EFFECTIVE_PROGRESSION_IND,
    EFFECTIVE_TIME_ELAPSED_IND = NEW_REFERENCES.EFFECTIVE_TIME_ELAPSED_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_ADM_UNIT_STAT_ALL
     where ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_ADMINISTRATIVE_UNIT_STATUS,
     X_UNIT_ATTEMPT_STATUS,
     X_DESCRIPTION,
     X_SHOW_ON_OFFIC_NTFCTN_IND,
     X_EFFECTIVE_PROGRESSION_IND,
     X_EFFECTIVE_TIME_ELAPSED_IND,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADMINISTRATIVE_UNIT_STATUS,
   X_UNIT_ATTEMPT_STATUS,
   X_DESCRIPTION,
   X_SHOW_ON_OFFIC_NTFCTN_IND,
   X_EFFECTIVE_PROGRESSION_IND,
   X_EFFECTIVE_TIME_ELAPSED_IND,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;
end IGS_AD_ADM_UNIT_STAT_PKG;

/
