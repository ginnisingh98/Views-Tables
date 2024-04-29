--------------------------------------------------------
--  DDL for Package Body IGS_AD_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CAT_PKG" As
/* $Header: IGSAI07B.pls 115.11 2003/10/30 13:10:10 akadam ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_CAT_ALL%RowType;
  new_references IGS_AD_CAT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_s_citizenship_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_CAT_ALL
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
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.admission_cat := x_admission_cat;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
    new_references.s_citizenship_type := x_s_citizenship_type;
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
	v_message_name   VARCHAR2(30);
  BEGIN
	-- Validate the update.
	IF old_references.s_citizenship_type <> new_references.s_citizenship_type THEN
		IF IGS_AD_VAL_AC.admp_val_ac_upd (
				new_references.admission_cat,
				v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
		         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
    Column_Name	IN	VARCHAR2	DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  BEGIN
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'S_CITIZENSHIP_TYPE' Then
     		new_references.s_citizenship_type := column_value;
	ELSIF upper(Column_name) = 'ADMISSION_CAT' Then
     		new_references.admission_cat := column_value;
	ELSIF upper(Column_name) = 'CLOSED_IND' Then
     		new_references.closed_ind := column_value;
	END IF;

	IF upper(column_name) = 'S_CITIZENSHIP_TYPE' OR column_name is null Then
     		IF new_references.s_citizenship_type  NOT IN ('ALL','DOMESTIC','INTRNTNL') Then
       		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;
     		END IF;
	END IF;
	IF upper(column_name) = 'ADMISSION_CAT' OR column_name is null Then
     		IF new_references.admission_cat <> UPPER(new_references.admission_cat) Then
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
  END Check_Constraints;


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PRCS_CAT_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_AD_CAT_PS_TYPE_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_AD_CT_HECS_PAYOP_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_AD_PERD_AD_CAT_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_CO_CAT_MAP_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_PS_OF_OPT_AD_CAT_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_EN_CAT_MAPPING_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_FI_FEE_CAT_MAP_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_PS_PAT_OF_STUDY_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

    IGS_AD_APCTR_RU_PKG.GET_FK_IGS_AD_CAT (
      old_references.admission_cat
      );

  END Check_Child_Existance;

  Function Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_closed_ind IN VARCHAR2 )
  RETURN BOOLEAN  AS
	gv_other_detail		VARCHAR2(255);
	CURSOR cur_rowid IS
      	SELECT   rowid
      	FROM     IGS_AD_CAT_ALL
      	WHERE  admission_cat = x_admission_cat AND
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_s_citizenship_type IN VARCHAR2 DEFAULT NULL,
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
      x_admission_cat,
      x_description,
      x_closed_ind,
      x_s_citizenship_type,
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
          		new_references.admission_cat ) THEN
         		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         		IGS_GE_MSG_STACK.ADD;
          		App_Exception.Raise_Exception;
      	END IF;
      	Check_Constraints;
 	ELSIF (p_action = 'UPDATE') THEN
       	-- Call all the procedures related to Before Update.
       	BeforeRowInsertUpdate1 ( p_updating => TRUE );
       	Check_Constraints;
 	ELSIF (p_action = 'DELETE') THEN
       	-- Call all the procedures related to Before Delete.
       	Check_Child_Existance;
 	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      	IF  Get_PK_For_Validation (
          		new_references.admission_cat  ) THEN
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

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_CAT_ALL
      where ADMISSION_CAT = X_ADMISSION_CAT;
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
   x_org_id => igs_ge_gen_003.get_org_id,
   x_admission_cat=>X_ADMISSION_CAT,
   x_closed_ind=>Nvl(X_CLOSED_IND, 'N'),
   x_description=>X_DESCRIPTION,
   x_s_citizenship_type=>X_S_CITIZENSHIP_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_CAT_ALL (
    ORG_ID,
    ADMISSION_CAT,
    DESCRIPTION,
    S_CITIZENSHIP_TYPE,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_CITIZENSHIP_TYPE,
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
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      S_CITIZENSHIP_TYPE,
      CLOSED_IND
    from IGS_AD_CAT_ALL
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
      AND (tlinfo.S_CITIZENSHIP_TYPE = X_S_CITIZENSHIP_TYPE)
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
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
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
   x_admission_cat=>X_ADMISSION_CAT,
   x_closed_ind=>X_CLOSED_IND,
   x_description=>X_DESCRIPTION,
   x_s_citizenship_type=>X_S_CITIZENSHIP_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_AD_CAT_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_CITIZENSHIP_TYPE = NEW_REFERENCES.S_CITIZENSHIP_TYPE,
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
  X_ORG_ID in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_CAT_ALL
     where ADMISSION_CAT = X_ADMISSION_CAT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_ADMISSION_CAT,
     X_DESCRIPTION,
     X_S_CITIZENSHIP_TYPE,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADMISSION_CAT,
   X_DESCRIPTION,
   X_S_CITIZENSHIP_TYPE,
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

  delete from IGS_AD_CAT_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_CAT_PKG;

/
