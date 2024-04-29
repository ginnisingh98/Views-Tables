--------------------------------------------------------
--  DDL for Package Body IGS_AD_CNDNL_OFRSTAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CNDNL_OFRSTAT_PKG" AS
/* $Header: IGSAI15B.pls 115.7 2003/10/30 13:11:16 akadam ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_CNDNL_OFRSTAT%RowType;
  new_references IGS_AD_CNDNL_OFRSTAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_adm_cndtnl_offer_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_adm_cndtnl_offer_status IN VARCHAR2 DEFAULT NULL,
    x_system_default_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_CNDNL_OFRSTAT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.adm_cndtnl_offer_status := x_adm_cndtnl_offer_status;
    new_references.description := x_description;
    new_references.s_adm_cndtnl_offer_status := x_s_adm_cndtnl_offer_status;
    new_references.system_default_ind := x_system_default_ind;
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

  -- Trigger description :-
  -- "OSS_TST".trg_acos_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON adm_cndtnl_offer_status
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate Admission conditional offer status closed ind.
	IF p_inserting OR ((old_references.s_adm_cndtnl_offer_status <>
				 new_references.s_adm_cndtnl_offer_status) OR
			(old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N')) THEN
		IF IGS_AD_VAL_ACOS.admp_val_sacoos_clsd(
					new_references.s_adm_cndtnl_offer_status,
					v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
                         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF (new_references.closed_ind = 'Y' AND new_references.system_default_ind = 'Y') THEN
	         Fnd_Message.Set_Name('IGS','IGS_AD_SYS_DFLT_IND_NOTSET_CLS');
	         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
	END IF;


  END BeforeRowInsertUpdate1;


  PROCEDURE Check_Constraints (
    Column_Name	IN	VARCHAR2	DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  BEGIN
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'SYSTEM_DEFAULT_IND' Then
     		new_references.system_default_ind := column_value;
	ELSIF upper(Column_name) = 'ADM_CNDTNL_OFFER_STATUS' Then
     		new_references.adm_cndtnl_offer_status:= column_value;
	ELSIF upper(Column_name) = 'CLOSED_IND' Then
     		new_references.closed_ind := column_value;
	ELSIF upper(Column_name) = 'S_ADM_CNDTNL_OFFER_STATUS'Then
     		new_references.s_adm_cndtnl_offer_status:= column_value;
	END IF;

	IF upper(column_name) = 'ADM_CNDTNL_OFFER_STATUS' OR column_name is null Then
     		IF new_references.adm_cndtnl_offer_status<> UPPER(new_references.adm_cndtnl_offer_status) Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
	IF upper(column_name) = 'CLOSED_IND' OR column_name is null Then
     		IF new_references.closed_ind  NOT IN ( 'Y' , 'N' ) Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
	IF upper(column_name) = 'SYSTEM_DEFAULT_IND' OR column_name is null Then
     		IF new_references.system_default_ind NOT IN ( 'Y' , 'N' ) Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
	IF upper(column_name) = 'S_ADM_CNDTNL_OFFER_STATUS' OR column_name is null Then
     		IF new_references.s_adm_cndtnl_offer_status<> UPPER(new_references.s_adm_cndtnl_offer_status) Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.s_adm_cndtnl_offer_status = new_references.s_adm_cndtnl_offer_status)) OR
        ((new_references.s_adm_cndtnl_offer_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
        'ADM_CNDTNL_OFFER_STATUS',
	  new_references.s_adm_cndtnl_offer_status ) THEN
     		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_AD_CNDNL_OFRSTAT (
      old_references.adm_cndtnl_offer_status
      );

  END Check_Child_Existance;

  Function Get_PK_For_Validation (
    x_adm_cndtnl_offer_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2 )
  RETURN BOOLEAN  AS
	CURSOR cur_rowid IS
      	SELECT   rowid
      	FROM     IGS_AD_CNDNL_OFRSTAT
      	WHERE    adm_cndtnl_offer_status = x_adm_cndtnl_offer_status AND
               closed_ind = NVL(x_closed_ind,closed_ind);

	lv_rowid cur_rowid%RowType;
  BEGIN  -- Get_PK_For_Validation
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

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_adm_cndtnl_offer_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_CNDNL_OFRSTAT
      WHERE    s_adm_cndtnl_offer_status = x_s_adm_cndtnl_offer_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACOS_SLV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_adm_cndtnl_offer_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_adm_cndtnl_offer_status IN VARCHAR2 DEFAULT NULL,
    x_system_default_ind IN VARCHAR2 DEFAULT NULL,
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
      x_adm_cndtnl_offer_status,
      x_description,
      x_s_adm_cndtnl_offer_status,
      x_system_default_ind,
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
      	IF  Get_PK_For_Validation (
          		new_references.adm_cndtnl_offer_status ) THEN
        		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        		IGS_GE_MSG_STACK.ADD;
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
       	Check_Child_Existance;
 	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      	IF  Get_PK_For_Validation (
          		new_references.adm_cndtnl_offer_status ) THEN
         		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         		IGS_GE_MSG_STACK.ADD;
          		App_Exception.Raise_Exception;
      	END IF;
	      Check_Constraints;
 	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	      Check_Constraints;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
      	Check_Child_Existance;
	END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
   NULL;
--   Removed the call to afterrowinsertupdate2.

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_SYSTEM_DEFAULT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_CNDNL_OFRSTAT
      where ADM_CNDTNL_OFFER_STATUS = X_ADM_CNDTNL_OFFER_STATUS;
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
   x_adm_cndtnl_offer_status=>X_ADM_CNDTNL_OFFER_STATUS,
   x_closed_ind=>Nvl(X_CLOSED_IND,'N'),
   x_description=>X_DESCRIPTION,
   x_s_adm_cndtnl_offer_status=>X_S_ADM_CNDTNL_OFFER_STATUS,
   x_system_default_ind=>Nvl(X_SYSTEM_DEFAULT_IND, 'N'),
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_CNDNL_OFRSTAT (
    ADM_CNDTNL_OFFER_STATUS,
    DESCRIPTION,
    S_ADM_CNDTNL_OFFER_STATUS,
    SYSTEM_DEFAULT_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ADM_CNDTNL_OFFER_STATUS,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_ADM_CNDTNL_OFFER_STATUS,
    NEW_REFERENCES.SYSTEM_DEFAULT_IND,
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
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_SYSTEM_DEFAULT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      S_ADM_CNDTNL_OFFER_STATUS,
      SYSTEM_DEFAULT_IND,
      CLOSED_IND
    from IGS_AD_CNDNL_OFRSTAT
    where ROWID = X_ROWID for update nowait;
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
      AND (tlinfo.S_ADM_CNDTNL_OFFER_STATUS = X_S_ADM_CNDTNL_OFFER_STATUS)
      AND (tlinfo.SYSTEM_DEFAULT_IND = X_SYSTEM_DEFAULT_IND)
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
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_SYSTEM_DEFAULT_IND in VARCHAR2,
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

  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_adm_cndtnl_offer_status=>X_ADM_CNDTNL_OFFER_STATUS,
   x_closed_ind=>X_CLOSED_IND,
   x_description=>X_DESCRIPTION,
   x_s_adm_cndtnl_offer_status=>X_S_ADM_CNDTNL_OFFER_STATUS,
   x_system_default_ind=>X_SYSTEM_DEFAULT_IND,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_AD_CNDNL_OFRSTAT set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_ADM_CNDTNL_OFFER_STATUS = NEW_REFERENCES.S_ADM_CNDTNL_OFFER_STATUS,
    SYSTEM_DEFAULT_IND = NEW_REFERENCES.SYSTEM_DEFAULT_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
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
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_SYSTEM_DEFAULT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_CNDNL_OFRSTAT
     where ADM_CNDTNL_OFFER_STATUS = X_ADM_CNDTNL_OFFER_STATUS
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ADM_CNDTNL_OFFER_STATUS,
     X_DESCRIPTION,
     X_S_ADM_CNDTNL_OFFER_STATUS,
     X_SYSTEM_DEFAULT_IND,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADM_CNDTNL_OFFER_STATUS,
   X_DESCRIPTION,
   X_S_ADM_CNDTNL_OFFER_STATUS,
   X_SYSTEM_DEFAULT_IND,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_CNDNL_OFRSTAT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_CNDNL_OFRSTAT_PKG;

/
