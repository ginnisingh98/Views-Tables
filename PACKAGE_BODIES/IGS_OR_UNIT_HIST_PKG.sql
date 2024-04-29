--------------------------------------------------------
--  DDL for Package Body IGS_OR_UNIT_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_UNIT_HIST_PKG" AS
 /* $Header: IGSOI12B.pls 115.8 2002/11/29 01:40:03 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_OR_UNIT_HIST_ALL%RowType;
  new_references IGS_OR_UNIT_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_ou_end_dt IN DATE DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_org_status IN VARCHAR2 DEFAULT NULL,
    x_org_type IN VARCHAR2 DEFAULT NULL,
    x_member_type IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_name IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    X_ORG_ID in NUMBER  DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_UNIT_HIST_ALL
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
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.ou_start_dt := x_ou_start_dt;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.ou_end_dt := x_ou_end_dt;
    new_references.description := x_description;
    new_references.org_status := x_org_status;
    new_references.org_type := x_org_type;
    new_references.member_type := x_member_type;
    new_references.institution_cd := x_institution_cd;
    new_references.name := x_name;
    new_references.org_id := x_org_id;
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

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_hist_start_dt IN DATE
    )RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_UNIT_HIST_ALL
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_ou_start_dt
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
 		RETURN(TRUE);
	ELSE
        Close cur_rowid;
	    RETURN(FALSE);
	END IF;

  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_ou_end_dt IN DATE DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_org_status IN VARCHAR2 DEFAULT NULL,
    x_org_type IN VARCHAR2 DEFAULT NULL,
    x_member_type IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_name IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER  DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_unit_cd,
      x_ou_start_dt,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_ou_end_dt,
      x_description,
      x_org_status,
      x_org_type,
      x_member_type,
      x_institution_cd,
      x_name,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
    IF Get_PK_For_Validation (
    	new_references.org_unit_cd ,
	    new_references.ou_start_dt ,
	    new_references.hist_start_dt
    	)THEN
	   Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	   IGS_GE_MSG_STACK.ADD;
	   App_Exception.Raise_Exception ;

	END IF;
     Check_Constraints ;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
     Check_Constraints ;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN

    IF Get_PK_For_Validation (
    	new_references.org_unit_cd ,
	    new_references.ou_start_dt ,
	    new_references.hist_start_dt
    	)THEN
	   Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	   IGS_GE_MSG_STACK.ADD;
	   App_Exception.Raise_Exception ;
    end if;
     Check_Constraints ;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

     Check_Constraints ;

	ELSIF (p_action = 'VALIDATE_DELETE') THEN
         null;

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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_OU_END_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_STATUS in VARCHAR2,
  X_ORG_TYPE in VARCHAR2,
  X_MEMBER_TYPE in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_NAME in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_OR_UNIT_HIST_ALL
      where ORG_UNIT_CD = X_ORG_UNIT_CD
      and OU_START_DT = X_OU_START_DT
      and HIST_START_DT = X_HIST_START_DT;
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
    x_description=>X_DESCRIPTION,
    x_hist_end_dt=>X_HIST_END_DT,
    x_hist_start_dt=>X_HIST_START_DT,
    x_hist_who=>X_HIST_WHO,
    x_institution_cd=>X_INSTITUTION_CD,
    x_member_type=>X_MEMBER_TYPE,
    x_name=>X_NAME,
    x_org_status=>X_ORG_STATUS,
    x_org_type=>X_ORG_TYPE,
    x_org_unit_cd=>X_ORG_UNIT_CD,
    x_ou_end_dt=>X_OU_END_DT,
    x_ou_start_dt=>X_OU_START_DT,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,
    x_org_id=>igs_ge_gen_003.get_org_id
    );
  insert into IGS_OR_UNIT_HIST_ALL (
    ORG_UNIT_CD,
    OU_START_DT,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    OU_END_DT,
    DESCRIPTION,
    ORG_STATUS,
    ORG_TYPE,
    MEMBER_TYPE,
    INSTITUTION_CD,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.ORG_UNIT_CD,
    NEW_REFERENCES.OU_START_DT,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.OU_END_DT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.ORG_STATUS,
    NEW_REFERENCES.ORG_TYPE,
    NEW_REFERENCES.MEMBER_TYPE,
    NEW_REFERENCES.INSTITUTION_CD,
    NEW_REFERENCES.NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID
    );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_OU_END_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_STATUS in VARCHAR2,
  X_ORG_TYPE in VARCHAR2,
  X_MEMBER_TYPE in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_NAME in VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      OU_END_DT,
      DESCRIPTION,
      ORG_STATUS,
      ORG_TYPE,
      MEMBER_TYPE,
      INSTITUTION_CD,
      NAME
    from IGS_OR_UNIT_HIST_ALL
    where ROWID = X_ROWID
    for update nowait ;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.OU_END_DT = X_OU_END_DT)
           OR ((tlinfo.OU_END_DT is null)
               AND (X_OU_END_DT is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.ORG_STATUS = X_ORG_STATUS)
           OR ((tlinfo.ORG_STATUS is null)
               AND (X_ORG_STATUS is null)))
      AND ((tlinfo.ORG_TYPE = X_ORG_TYPE)
           OR ((tlinfo.ORG_TYPE is null)
               AND (X_ORG_TYPE is null)))
      AND ((tlinfo.MEMBER_TYPE = X_MEMBER_TYPE)
           OR ((tlinfo.MEMBER_TYPE is null)
               AND (X_MEMBER_TYPE is null)))
      AND ((tlinfo.INSTITUTION_CD = X_INSTITUTION_CD)
           OR ((tlinfo.INSTITUTION_CD is null)
               AND (X_INSTITUTION_CD is null)))
      AND ((tlinfo.NAME = X_NAME)
           OR ((tlinfo.NAME is null)
               AND (X_NAME is null)))

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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_OU_END_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_STATUS in VARCHAR2,
  X_ORG_TYPE in VARCHAR2,
  X_MEMBER_TYPE in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_NAME in VARCHAR2,
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
    x_description=>X_DESCRIPTION,
    x_hist_end_dt=>X_HIST_END_DT,
    x_hist_start_dt=>X_HIST_START_DT,
    x_hist_who=>X_HIST_WHO,
    x_institution_cd=>X_INSTITUTION_CD,
    x_member_type=>X_MEMBER_TYPE,
    x_name=>X_NAME,
    x_org_status=>X_ORG_STATUS,
    x_org_type=>X_ORG_TYPE,
    x_org_unit_cd=>X_ORG_UNIT_CD,
    x_ou_end_dt=>X_OU_END_DT,
    x_ou_start_dt=>X_OU_START_DT,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
  update IGS_OR_UNIT_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    OU_END_DT = NEW_REFERENCES.OU_END_DT,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    ORG_STATUS = NEW_REFERENCES.ORG_STATUS,
    ORG_TYPE = NEW_REFERENCES.ORG_TYPE,
    MEMBER_TYPE = NEW_REFERENCES.MEMBER_TYPE,
    INSTITUTION_CD = NEW_REFERENCES.INSTITUTION_CD,
    NAME = NEW_REFERENCES.NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID
    );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_OU_END_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_STATUS in VARCHAR2,
  X_ORG_TYPE in VARCHAR2,
  X_MEMBER_TYPE in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_NAME in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_OR_UNIT_HIST_ALL
     where ORG_UNIT_CD = X_ORG_UNIT_CD
     and OU_START_DT = X_OU_START_DT
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_UNIT_CD,
     X_OU_START_DT,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_OU_END_DT,
     X_DESCRIPTION,
     X_ORG_STATUS,
     X_ORG_TYPE,
     X_MEMBER_TYPE,
     X_INSTITUTION_CD,
     X_NAME,
     X_MODE,
      x_org_id);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ORG_UNIT_CD,
   X_OU_START_DT,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_OU_END_DT,
   X_DESCRIPTION,
   X_ORG_STATUS,
   X_ORG_TYPE,
   X_MEMBER_TYPE,
   X_INSTITUTION_CD,
   X_NAME,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
    X_ROWID in VARCHAR2
    ) AS
begin
  Before_DML(
   p_action=>'DELETE',
   x_rowid=>X_ROWID
   );
  delete from IGS_OR_UNIT_HIST_ALL
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'DELETE',
    x_rowid=>X_ROWID
    );
end DELETE_ROW;

procedure Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
   /*----------------------------------------------------------------------------
  ||  Created By : pkpatel
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel    29-JUL-2002   Bug No: 2461744
  ||                           Removed the upper check constraint on org_unit_cd, institution_cd and hist_who
  ----------------------------------------------------------------------------*/

 begin
IF Column_Name is null THEN
  NULL;

ELSIF upper(Column_name) = 'MEMBER_TYPE' THEN
  new_references.MEMBER_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'NAME' THEN
  new_references.NAME:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ORG_STATUS' THEN
  new_references.ORG_STATUS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ORG_TYPE' THEN
  new_references.ORG_TYPE:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'MEMBER_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.MEMBER_TYPE<> upper(new_references.MEMBER_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

-- Bug : 2040069. REmoved the check that checks for the Upper Case of field 'Name'

IF upper(Column_name) = 'ORG_STATUS' OR COLUMN_NAME IS NULL THEN
  IF new_references.ORG_STATUS<> upper(new_references.ORG_STATUS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'ORG_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.ORG_TYPE<> upper(new_references.ORG_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints ;

END IGS_OR_UNIT_HIST_PKG;

/
