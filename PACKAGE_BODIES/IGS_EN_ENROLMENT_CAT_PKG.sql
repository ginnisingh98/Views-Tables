--------------------------------------------------------
--  DDL for Package Body IGS_EN_ENROLMENT_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ENROLMENT_CAT_PKG" AS
/* $Header: IGSEI22B.pls 120.1 2005/09/08 14:48:02 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_EN_ENROLMENT_CAT%RowType;
  new_references IGS_EN_ENROLMENT_CAT%RowType;

  PROCEDURE beforerowdelete;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ENROLMENT_CAT
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
    new_references.enrolment_cat := x_enrolment_cat;
    new_references.description := x_description;
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
  -- "OSS_TST".trg_ec_br_u
  -- BEFORE UPDATE
  -- ON IGS_EN_ENROLMENT_CAT
  -- FOR EACH ROW

  PROCEDURE BeforeRowUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name			varchar2(30);
  BEGIN
	-- Validate update of closed indicator.
	IF old_references.closed_ind <> new_references.closed_ind THEN
		IF IGS_EN_VAL_EC.enrp_val_ec_clsd_upd (
				new_references.enrolment_cat,
				new_references.closed_ind,
				v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
		END IF;
	END IF;


  END BeforeRowUpdate1;

procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
	   NULL;
	ELSIF upper(column_name) = 'CLOSED_IND' then
		new_references.closed_ind := column_value;
	ELSIF upper(column_name) = 'ENROLMENT_CAT' then
		new_references.enrolment_cat := column_value;
	END IF;

	IF upper(column_name) = 'CLOSED_IND' OR
	  column_name is null then
	   if new_references.closed_ind NOT IN ('Y','N') OR
	    new_references.closed_ind <> upper(new_references.closed_ind) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;

	IF upper(column_name) = 'ENROLMENT_CAT' OR
	  column_name is null then
	   if  new_references.enrolment_cat <> upper(new_references.enrolment_cat) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	   end if;
	end if;

END check_constraints;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_EN_ENROLMENT_CAT (
      old_references.enrolment_cat
      );

    IGS_EN_CAT_MAPPING_PKG.GET_FK_IGS_EN_ENROLMENT_CAT (
      old_references.enrolment_cat
      );

    IGS_EN_CAT_PRC_DTL_PKG.GET_FK_IGS_EN_ENROLMENT_CAT (
      old_references.enrolment_cat
      );

    IGS_AS_SC_ATMPT_ENR_PKG.GET_FK_IGS_EN_ENROLMENT_CAT (
      old_references.enrolment_cat
      );
    igs_en_cpd_ext_pkg.get_fk_igs_en_enrolment_cat(
      old_references.enrolment_cat
      );
    IGS_PS_TYPE_PKG.GET_FK_IGS_EN_ENROLMENT_CAT(
        old_references.enrolment_cat
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_enrolment_cat IN VARCHAR2
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ENROLMENT_CAT
      WHERE    enrolment_cat = x_enrolment_cat;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
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
      x_enrolment_cat,
      x_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
	    new_references.enrolment_cat
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowUpdate1 ( p_updating => TRUE );
      Check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowdelete;
      Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') then
	IF Get_PK_For_Validation (
	    new_references.enrolment_cat
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 Check_constraints;
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_ENROLMENT_CAT
      where ENROLMENT_CAT = X_ENROLMENT_CAT;
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
    x_rowid =>   X_ROWID,
    x_enrolment_cat => X_ENROLMENT_CAT,
    x_description => X_DESCRIPTION,
    x_closed_ind => NVL(X_CLOSED_IND,'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_ENROLMENT_CAT (
    ENROLMENT_CAT,
    DESCRIPTION,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ENROLMENT_CAT,
    NEW_REFERENCES.DESCRIPTION,
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
    x_rowid =>   X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      CLOSED_IND
    from IGS_EN_ENROLMENT_CAT
    where ROWID = X_ROWID for update  nowait;
  tlinfo c1%rowtype;

begin
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
  X_ENROLMENT_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
    x_rowid =>   X_ROWID,
    x_enrolment_cat => X_ENROLMENT_CAT,
    x_description => X_DESCRIPTION,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_ENROLMENT_CAT set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'UPDATE',
    x_rowid =>   X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_ENROLMENT_CAT
     where ENROLMENT_CAT = X_ENROLMENT_CAT
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ENROLMENT_CAT,
     X_DESCRIPTION,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ENROLMENT_CAT,
   X_DESCRIPTION,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2) AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
  delete from IGS_EN_ENROLMENT_CAT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
end DELETE_ROW;

PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : rnirwani
  --Date created: 03-Jan-03
  --
  --Purpose: Validation to ensure that delation is not allowed
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

BEGIN

-- Deletion is not allowed in this table.
-- this change has been done since in the PK check the lock has been
-- removed. Hence to avoid data inconsistency the deletion should not
-- be done. The record should be closed instead by checking the closed
-- indicator.

  FND_MESSAGE.SET_NAME('IGS','IGS_FI_DEL_NOT_ALLWD');
  igs_ge_msg_stack.add;
  APP_EXCEPTION.RAISE_EXCEPTION;

END beforerowdelete;


end IGS_EN_ENROLMENT_CAT_PKG;

/
