--------------------------------------------------------
--  DDL for Package Body IGS_FI_FD_SRC_RSTN_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FD_SRC_RSTN_H_PKG" as
 /* $Header: IGSSI41B.pls 115.5 2002/11/29 03:47:10 nsidana ship $*/
 l_rowid VARCHAR2(25);
  old_references IGS_FI_FD_SRC_RSTN_H_ALL%RowType;
  new_references IGS_FI_FD_SRC_RSTN_H_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_restricted_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FD_SRC_RSTN_H_ALL
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.funding_source := x_funding_source;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.dflt_ind := x_dflt_ind;
    new_references.restricted_ind := x_restricted_ind;
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

   PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
   )AS
   BEGIN

  IF Column_Name is NULL THEN
  	NULL;
  ELSIF upper(Column_Name) = 'DFLT_IND' then
  	new_references.dflt_ind := Column_Value;
  ELSIF upper(Column_Name) = 'RESTRICTED_IND' then
  	new_references.restricted_ind := Column_Value;
  ELSIF upper(Column_Name) = 'COURSE_CD' then
  	new_references.course_cd := Column_Value;
  ELSIF upper(Column_Name) = 'FUNDING_SOURCE' then
    	new_references.funding_source := Column_Value;
  END IF;
  IF upper(Column_Name) = 'RESTRICTED_IND' OR 	column_name is NULL THEN
     		IF new_references.restricted_ind <> 'Y' AND
			   new_references.restricted_ind <> 'N'
			   THEN
     				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
     				App_Exception.Raise_Exception;
     		END IF;
  END IF;

  IF upper(Column_Name) = 'DFLT_IND' OR 	column_name is NULL THEN
       		IF new_references.dflt_ind <> 'Y' AND
  			   new_references.dflt_ind <> 'N'
  			   THEN
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
       		END IF;
  END IF;
  IF upper(Column_Name) = 'COURSE_CD' OR
    		column_name is NULL THEN
  		IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
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
    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
			IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_funding_source IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FD_SRC_RSTN_H_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      funding_source = x_funding_source
      AND      hist_start_dt = x_hist_start_dt
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
  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FD_SRC_RSTN_H_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FSRH_CV_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_VER;
  PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FD_SRC_RSTN_H_ALL
      WHERE    funding_source = x_funding_source ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FSRH_FS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FUND_SRC;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_restricted_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_funding_source,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_dflt_ind,
      x_restricted_ind,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation ( new_references.course_cd, new_references.version_number,
	  						    new_references.funding_source, new_references.hist_start_dt) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	  END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation ( new_references.course_cd, new_references.version_number,
	  						    new_references.funding_source, new_references.hist_start_dt) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_FI_FD_SRC_RSTN_H_ALL
      where COURSE_CD = X_COURSE_CD
      and HIST_START_DT = X_HIST_START_DT
      and VERSION_NUMBER = X_VERSION_NUMBER
      and FUNDING_SOURCE = X_FUNDING_SOURCE;
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
 x_course_cd=>X_COURSE_CD,
 x_dflt_ind=>X_DFLT_IND,
 x_funding_source=>X_FUNDING_SOURCE,
 x_hist_end_dt=>X_HIST_END_DT,
 x_hist_start_dt=>X_HIST_START_DT,
 x_hist_who=>X_HIST_WHO,
 x_restricted_ind=>X_RESTRICTED_IND,
 x_version_number=>X_VERSION_NUMBER,
 x_org_id => igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_FD_SRC_RSTN_H_ALL (
    COURSE_CD,
    VERSION_NUMBER,
    FUNDING_SOURCE,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    DFLT_IND,
    RESTRICTED_IND,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.DFLT_IND,
    NEW_REFERENCES.RESTRICTED_IND,
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
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      DFLT_IND,
      RESTRICTED_IND
    from IGS_FI_FD_SRC_RSTN_H_ALL
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
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.DFLT_IND = X_DFLT_IND)
           OR ((tlinfo.DFLT_IND is null)
               AND (X_DFLT_IND is null)))
      AND ((tlinfo.RESTRICTED_IND = X_RESTRICTED_IND)
           OR ((tlinfo.RESTRICTED_IND is null)
               AND (X_RESTRICTED_IND is null)))
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
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
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
 x_course_cd=>X_COURSE_CD,
 x_dflt_ind=>X_DFLT_IND,
 x_funding_source=>X_FUNDING_SOURCE,
 x_hist_end_dt=>X_HIST_END_DT,
 x_hist_start_dt=>X_HIST_START_DT,
 x_hist_who=>X_HIST_WHO,
 x_restricted_ind=>X_RESTRICTED_IND,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_FD_SRC_RSTN_H_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    DFLT_IND = NEW_REFERENCES.DFLT_IND,
    RESTRICTED_IND = NEW_REFERENCES.RESTRICTED_IND,
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
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_FI_FD_SRC_RSTN_H_ALL
     where COURSE_CD = X_COURSE_CD
     and HIST_START_DT = X_HIST_START_DT
     and VERSION_NUMBER = X_VERSION_NUMBER
     and FUNDING_SOURCE = X_FUNDING_SOURCE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_HIST_START_DT,
     X_VERSION_NUMBER,
     X_FUNDING_SOURCE,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_DFLT_IND,
     X_RESTRICTED_IND,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_HIST_START_DT,
   X_VERSION_NUMBER,
   X_FUNDING_SOURCE,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_DFLT_IND,
   X_RESTRICTED_IND,
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

  delete from IGS_FI_FD_SRC_RSTN_H_ALL
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_FD_SRC_RSTN_H_PKG;

/
