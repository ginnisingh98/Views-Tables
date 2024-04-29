--------------------------------------------------------
--  DDL for Package Body IGS_FI_FUND_SRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FUND_SRC_PKG" AS
/* $Header: IGSSI42B.pls 115.9 2003/01/06 15:18:02 smvk ship $ */
 l_rowid VARCHAR2(25);
  old_references IGS_FI_FUND_SRC_ALL%RowType;
  new_references IGS_FI_FUND_SRC_ALL%RowType;
  PROCEDURE beforerowdelete;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_funding_source IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FUND_SRC_ALL
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
    new_references.funding_source := x_funding_source;
    new_references.description := x_description;
    new_references.govt_funding_source := x_govt_funding_source;
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
  -- "OSS_TST".trg_fs_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_FUND_SRC_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		varchar2(30);
	v_description		IGS_FI_FUND_SRC_ALL.description%TYPE;
	v_govt_funding_source	IGS_FI_FUND_SRC_ALL.govt_funding_source%TYPE;
	v_closed_ind		IGS_FI_FUND_SRC_ALL.closed_ind%TYPE;
	lv_org_id		IGS_FI_FUND_SRC_HIST.org_id%TYPE := igs_ge_gen_003.get_org_id;
	x_rowid		VARCHAR2(25);
	CURSOR SFFSH_CUR IS
			SELECT Rowid
			FROM IGS_FI_FUND_SRC_HIST
			WHERE	funding_source = old_references.funding_source;
   BEGIN
	-- Validate DEET funding source.
	IF p_inserting OR
		(p_updating AND
		((old_references.govt_funding_source <> new_references.govt_funding_source) OR
		 (old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N'))) THEN
		IF IGS_PS_VAL_FS.crsp_val_fs_govt (
				new_references.govt_funding_source,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Create history record.
	IF p_updating THEN
		IF old_references.description <> new_references.description OR
				old_references.govt_funding_source <> new_references.govt_funding_source OR
				old_references.closed_ind <> new_references.closed_ind THEN
			SELECT	DECODE (old_references.description,  new_references.description, NULL, old_references.description),
				DECODE (old_references.govt_funding_source,  new_references.govt_funding_source, NULL,
					old_references.govt_funding_source),
				DECODE (old_references.closed_ind, new_references.closed_ind, NULL, old_references.closed_ind)
			INTO	v_description,
				v_govt_funding_source,
				v_closed_ind
			FROM	dual;
			BEGIN
				IGS_FI_FUND_SRC_HIST_PKG.Insert_Row(
						 X_ROWID                =>	x_rowid,
						 X_FUNDING_SOURCE       =>	old_references.funding_source,
						 X_HIST_START_DT        =>	old_references.last_update_date,
						 X_HIST_END_DT          =>	new_references.last_update_date,
						 X_HIST_WHO             =>	old_references.last_updated_by,
						 X_DESCRIPTION          =>	v_description,
						 X_GOVT_FUNDING_SOURCE  =>	v_govt_funding_source,
						 X_CLOSED_IND           =>	v_closed_ind,
						 X_ORG_ID               =>  lv_org_id,
						 X_MODE                 =>	'R');
			END ;
	END IF;
	END IF;
	-- Delete history records.
	IF p_deleting THEN
		FOR SFFSH_Rec in SFFSH_CUR
		Loop
			IGS_FI_FUND_SRC_HIST_PKG.Delete_Row(X_ROWID => SFFSH_Rec.Rowid);
		End Loop;
	END IF;
  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Constraints (
     Column_Name	IN	VARCHAR2	DEFAULT NULL,
     Column_Value 	IN	VARCHAR2	DEFAULT NULL
     )AS
BEGIN

IF Column_Name is NULL THEN
       	NULL;
ELSIF upper(Column_Name) = 'FUNDING_SOURCE' then
   	new_references.funding_source := Column_Value;
ELSIF upper(Column_Name) = 'CLOSED_IND' then
   	new_references.closed_ind := Column_Value;
END IF;
IF upper(Column_Name) = 'CLOSED_IND' OR 	column_name is NULL THEN
       		IF new_references.closed_ind <> 'Y' AND
  			   new_references.closed_ind <> 'N'
  			   THEN
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
       		END IF;
END IF;
IF upper(Column_Name) = 'FUNDING_SOURCE' OR
    		column_name is NULL THEN
  		IF new_references.funding_source <> UPPER(new_references.funding_source) THEN
  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
  		END IF;
END IF;

END Check_Constraints;

PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.govt_funding_source = new_references.govt_funding_source)) OR
        ((new_references.govt_funding_source IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_GOVT_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.govt_funding_source ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_FI_FND_SRC_RSTN_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_FI_FD_SRC_RSTN_H_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_AD_SBMAO_FN_AMTT_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_AD_SBMAO_FN_CTTT_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_AD_SBM_AOU_FNDTT_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_AD_SBMAO_FN_UITT_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_AD_SBM_PS_FNTRGT_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
    IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_FI_FUND_SRC (
      old_references.funding_source
      );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_funding_source IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FUND_SRC_ALL
      WHERE    funding_source = x_funding_source;
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

  PROCEDURE GET_FK_IGS_FI_GOVT_FUND_SRC (
    x_govt_funding_source IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FUND_SRC_ALL
      WHERE    govt_funding_source = x_govt_funding_source ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FS_GFS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_GOVT_FUND_SRC;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_funding_source IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id  IN NUMBER DEFAULT NULL,
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
      x_funding_source,
      x_description,
      x_govt_funding_source,
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
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	  IF Get_PK_For_Validation ( new_references.funding_source) THEN
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
        beforerowdelete;
      	BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      	Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation ( new_references.funding_source) THEN
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'

  ) as
 /*---------------------------------------------------------------------------------------------
 --Who		when		What
 --sbaliga	13-feb-2002	Assigned igs_ge_gen_003.get_org_id to x_org_id in call to
 --				before_dml as part of SWCR006 build.
 ---------------------------------------------------------------------------------------*/
    cursor C is select ROWID from IGS_FI_FUND_SRC_ALL
      where FUNDING_SOURCE = X_FUNDING_SOURCE;
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
 x_description=>X_DESCRIPTION,
 x_funding_source=>X_FUNDING_SOURCE,
 x_govt_funding_source=>X_GOVT_FUNDING_SOURCE,
 x_org_id =>igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_FUND_SRC_ALL (
    FUNDING_SOURCE,
    DESCRIPTION,
    GOVT_FUNDING_SOURCE,
    CLOSED_IND,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_FUNDING_SOURCE,
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
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      DESCRIPTION,
      GOVT_FUNDING_SOURCE,
      CLOSED_IND
    from IGS_FI_FUND_SRC_ALL
    where ROWID=X_ROWID
    for update nowait;
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
      AND (tlinfo.GOVT_FUNDING_SOURCE = X_GOVT_FUNDING_SOURCE)
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
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'

  ) as
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
 x_description=>X_DESCRIPTION,
 x_funding_source=>X_FUNDING_SOURCE,
 x_govt_funding_source=>X_GOVT_FUNDING_SOURCE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_FUND_SRC_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_FUNDING_SOURCE = NEW_REFERENCES.GOVT_FUNDING_SOURCE,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'

  ) as
  cursor c1 is select rowid from IGS_FI_FUND_SRC_ALL
     where FUNDING_SOURCE = X_FUNDING_SOURCE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FUNDING_SOURCE,
     X_DESCRIPTION,
     X_GOVT_FUNDING_SOURCE,
     X_CLOSED_IND,
     X_ORG_ID,
     X_MODE
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FUNDING_SOURCE,
   X_DESCRIPTION,
   X_GOVT_FUNDING_SOURCE,
   X_CLOSED_IND,
   X_MODE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_FUND_SRC_ALL
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

  PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : smvk, Oracle India
  --Date created: 03-Jan-2003
  --
  --Purpose: Funding source records can be deleted logically by setting the closed_ind as 'Y'
  --         No physical deletion is allowed. As a part of Bug # 2729917
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    -- Preventing deletion of the Funding source records. As a part of Bug # 2729917
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_DEL_NOT_ALLWD');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END beforerowdelete;

end IGS_FI_FUND_SRC_PKG;

/
