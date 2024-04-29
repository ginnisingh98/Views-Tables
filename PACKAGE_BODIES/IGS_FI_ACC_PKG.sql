--------------------------------------------------------
--  DDL for Package Body IGS_FI_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ACC_PKG" AS
/* $Header: IGSSI02B.pls 115.20 2003/02/17 05:22:31 pathipat ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_ACC_ALL%RowType;
  new_references IGS_FI_ACC_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_account_cd IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_org_id  IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ACC_ALL
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
    new_references.account_cd := x_account_cd;
    new_references.description := x_description;
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

PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	,
 Column_Value 	IN	VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        12-May-2002     removed upper check constraint on account_cd column.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN

    IF  column_name is null then
       NULL;
    ELSIF upper(Column_name) = 'CLOSED_IND' then
       new_references.closed_ind := column_value;
    END IF;

    IF upper(column_name) = 'CLOSED_IND' OR
       column_name is null Then
      IF (new_references.closed_ind not in ('Y', 'N')) Then
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

END Check_Constraints;


  FUNCTION Get_PK_For_Validation (
       x_account_cd IN VARCHAR2
    ) Return Boolean AS
  /*--------------------------------------------------------------------
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        17-Feb-2003     Enh 2747325 - Locking Issues build
  ||                                  Removed FOR UPDATE NOWAIT clause in cur_rowid
  ----------------------------------------------------------------------*/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ACC_ALL
      WHERE      account_cd = x_account_cd;

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
    x_account_cd IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
/*--------------------------------------------------------------------
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        17-Feb-2003     Enh 2747325 - Locking Issues build
  ||                                  Removed code for p_action = DELETE and
  ||                                  VALIDATE_DELETE
  ----------------------------------------------------------------------*/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_account_cd,
      x_description,
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
	  IF  Get_PK_For_Validation (
	   	new_references.account_cd
	  	) THEN
	  	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                          IGS_GE_MSG_STACK.ADD;
	  	          App_Exception.Raise_Exception;
	  	END IF;
	  Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
  	  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	      IF  Get_PK_For_Validation (
			 	new_references.account_cd
	           ) THEN
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                IGS_GE_MSG_STACK.ADD;
	          App_Exception.Raise_Exception;
	      END IF;
	      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	       Check_Constraints;
    END IF;
  END Before_DML;

  PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER ,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_FI_ACC_ALL
      where  ACCOUNT_CD = X_ACCOUNT_CD;
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
    x_account_cd => X_ACCOUNT_CD,
    x_description => X_DESCRIPTION,
    x_closed_ind => X_CLOSED_IND,
    X_org_id => igs_ge_gen_003.get_org_id,
x_creation_date => X_LAST_UPDATE_DATE,
x_created_by => X_LAST_UPDATED_BY,
x_last_update_date => X_LAST_UPDATE_DATE,
x_last_updated_by => X_LAST_UPDATED_BY,
x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_FI_ACC_ALL (
    ACCOUNT_CD,
    DESCRIPTION,
    CLOSED_IND,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
   NEW_REFERENCES.ACCOUNT_CD,
   NEW_REFERENCES.DESCRIPTION,
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
  CLOSE c;
END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2 -- this was not there before.
) AS
  cursor c1 is select
      DESCRIPTION,
      CLOSED_IND
    from IGS_FI_ACC_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
BEGIN
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND  (tlinfo.CLOSED_IND = X_CLOSED_IND)
    )
 then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_account_cd => X_ACCOUNT_CD,
    x_description => X_DESCRIPTION,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_FI_ACC_ALL set
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;

PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER ,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_FI_ACC_ALL
     where  ACCOUNT_CD = X_ACCOUNT_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ACCOUNT_CD,
     X_DESCRIPTION,
     X_CLOSED_IND,
     X_ORG_ID,
     X_MODE
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ACCOUNT_CD,
   X_DESCRIPTION,
   X_CLOSED_IND,
   X_MODE
   );
END ADD_ROW;

END IGS_FI_ACC_PKG;

/
