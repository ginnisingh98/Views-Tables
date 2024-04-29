--------------------------------------------------------
--  DDL for Package Body IGS_OR_INST_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_INST_HIST_PKG" AS
/* $Header: IGSOI04B.pls 115.12 2002/11/29 01:39:15 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_OR_INST_HIST_ALL%RowType;
  new_references IGS_OR_INST_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_institution_cd IN VARCHAR2,
    x_hist_start_dt IN DATE,
    x_hist_end_dt IN DATE,
    x_hist_who IN VARCHAR2,
    x_name IN VARCHAR2,
    x_inst_phone_country_code IN VARCHAR2,
    x_inst_phone_area_code IN VARCHAR2,
    x_inst_phone_number IN VARCHAR2,
    x_inst_priority_cd in VARCHAR2,
    x_eps_code IN VARCHAR2,
    x_institution_status IN VARCHAR2,
    x_local_institution_ind IN VARCHAR2,
    x_os_ind IN VARCHAR2,
    x_govt_institution_cd IN VARCHAR2,
    x_institution_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_inst_control_type IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    X_ORG_ID in NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_INST_HIST_ALL
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
    new_references.institution_cd := x_institution_cd;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.name := x_name;


    new_references.inst_phone_country_code	:= x_inst_phone_country_code;
    new_references.inst_phone_area_code		:= x_inst_phone_area_code;
    new_references.inst_phone_number		:= x_inst_phone_number;
    new_references.inst_priority_cd	:= x_inst_priority_cd;
    new_references.eps_code			:= x_eps_code;



    new_references.institution_status := x_institution_status;
    new_references.local_institution_ind := x_local_institution_ind;
    new_references.os_ind := x_os_ind;
    new_references.govt_institution_cd := x_govt_institution_cd;
    new_references.institution_type := x_institution_type;
    new_references.description := x_description;
    new_references.inst_control_type := x_inst_control_type;
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
    x_institution_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    )
    RETURN BOOLEAN
    AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_INST_HIST_ALL
      WHERE    institution_cd = x_institution_cd
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
    x_rowid IN VARCHAR2,
    x_institution_cd IN VARCHAR2,
    x_hist_start_dt IN DATE,
    x_hist_end_dt IN DATE,
    x_hist_who IN VARCHAR2,
    x_name IN VARCHAR2,


    x_inst_phone_country_code IN VARCHAR2,
    x_inst_phone_area_code IN VARCHAR2,
    x_inst_phone_number IN VARCHAR2,
    x_inst_priority_cd IN VARCHAR2,
    x_eps_code IN VARCHAR2,



    x_institution_status IN VARCHAR2,
    x_local_institution_ind IN VARCHAR2,
    x_os_ind IN VARCHAR2,
    x_govt_institution_cd IN VARCHAR2,
    x_institution_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_inst_control_type IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    X_ORG_ID in NUMBER
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_institution_cd,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_name,
      x_inst_phone_country_code,
      x_inst_phone_area_code,
      x_inst_phone_number,
      x_inst_priority_cd,
      x_eps_code,
      x_institution_status,
      x_local_institution_ind,
      x_os_ind,
      x_govt_institution_cd,
      x_institution_type,
      x_description,
      x_inst_control_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
  if Get_PK_For_Validation (
    new_references.institution_cd,
    new_references.hist_start_dt
    ) then
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  end if;
 Check_Constraints ;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
 Check_Constraints ;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
    if Get_PK_For_Validation (
      new_references.institution_cd,
      new_references.hist_start_dt
      ) then
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    end if;
     Check_Constraints ;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     Check_Constraints ;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
     null ;
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
  X_INSTITUTION_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_NAME in VARCHAR2,


  X_INST_PHONE_COUNTRY_CODE in VARCHAR2,
  X_INST_PHONE_AREA_CODE in VARCHAR2,
  X_INST_PHONE_NUMBER in VARCHAR2,
  X_inst_priority_cd in VARCHAR2,
  X_EPS_CODE in VARCHAR2,



  X_INSTITUTION_STATUS in VARCHAR2,
  X_LOCAL_INSTITUTION_IND in VARCHAR2,
  X_OS_IND in VARCHAR2,
  X_GOVT_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INST_CONTROL_TYPE in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_OR_INST_HIST_ALL
      where INSTITUTION_CD = X_INSTITUTION_CD
      and HIST_START_DT = X_HIST_START_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    v_other_detail VARCHAR2(255);
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
   x_institution_type=>X_INSTITUTION_TYPE,
   x_description=>X_DESCRIPTION,
   x_inst_control_type=>X_INST_CONTROL_TYPE,
   x_govt_institution_cd=>X_GOVT_INSTITUTION_CD,
   x_hist_end_dt=>X_HIST_END_DT,
   x_hist_start_dt=>X_HIST_START_DT,
   x_hist_who=>X_HIST_WHO,
   x_institution_cd=>X_INSTITUTION_CD,
   x_institution_status=>X_INSTITUTION_STATUS,
   x_local_institution_ind=>X_LOCAL_INSTITUTION_IND,
   x_name=>X_NAME,


   x_inst_phone_country_code => X_INST_PHONE_COUNTRY_CODE,
   x_inst_phone_area_code => X_INST_PHONE_AREA_CODE,
   x_inst_phone_number => X_INST_PHONE_NUMBER,
   x_inst_priority_cd => X_inst_priority_cd,
   x_eps_code => X_EPS_CODE,

   x_os_ind=>X_OS_IND,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN,
   x_org_id=>igs_ge_gen_003.get_org_id
   );
  insert into IGS_OR_INST_HIST_ALL (
    INSTITUTION_CD,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    NAME,

    INST_PHONE_COUNTRY_CODE,
    INST_PHONE_AREA_CODE,
    INST_PHONE_NUMBER,
    inst_priority_cd,
    EPS_CODE,

    INSTITUTION_STATUS,
    LOCAL_INSTITUTION_IND,
    OS_IND,
    GOVT_INSTITUTION_CD,
    INSTITUTION_TYPE,
    DESCRIPTION,
    INST_CONTROL_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.INSTITUTION_CD,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.NAME,

    NEW_REFERENCES.INST_PHONE_COUNTRY_CODE,
    NEW_REFERENCES.INST_PHONE_AREA_CODE,
    NEW_REFERENCES.INST_PHONE_NUMBER,
    NEW_REFERENCES.inst_priority_cd,
    NEW_REFERENCES.EPS_CODE,


    NEW_REFERENCES.INSTITUTION_STATUS,
    NEW_REFERENCES.LOCAL_INSTITUTION_IND,
    NEW_REFERENCES.OS_IND,
    NEW_REFERENCES.GOVT_INSTITUTION_CD,
    NEW_REFERENCES.INSTITUTION_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.INST_CONTROL_TYPE,
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
  X_INSTITUTION_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_NAME in VARCHAR2,


  X_INST_PHONE_COUNTRY_CODE in VARCHAR2,
  X_INST_PHONE_AREA_CODE in VARCHAR2,
  X_INST_PHONE_NUMBER in VARCHAR2,
  X_inst_priority_cd in VARCHAR2,
  X_EPS_CODE in VARCHAR2,



  X_INSTITUTION_STATUS in VARCHAR2,
  X_LOCAL_INSTITUTION_IND in VARCHAR2,
  X_OS_IND in VARCHAR2,
  X_GOVT_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INST_CONTROL_TYPE in VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      NAME,

      INST_PHONE_COUNTRY_CODE,
      INST_PHONE_AREA_CODE,
      INST_PHONE_NUMBER,
      inst_priority_cd,
      EPS_CODE,


      INSTITUTION_STATUS,
      LOCAL_INSTITUTION_IND,
      OS_IND,
      GOVT_INSTITUTION_CD,
      INSTITUTION_TYPE,
      DESCRIPTION,
      INST_CONTROL_TYPE
    from IGS_OR_INST_HIST_ALL
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
      AND ((tlinfo.NAME = X_NAME)
           OR ((tlinfo.NAME is null)
               AND (X_NAME is null)))
      AND ((tlinfo.INST_PHONE_COUNTRY_CODE = X_INST_PHONE_COUNTRY_CODE)
           OR ((tlinfo.INST_PHONE_COUNTRY_CODE is null)
               AND (X_INST_PHONE_COUNTRY_CODE is null)))
      AND ((tlinfo.INST_PHONE_AREA_CODE = X_INST_PHONE_AREA_CODE)
           OR ((tlinfo.INST_PHONE_AREA_CODE is null)
               AND (X_INST_PHONE_AREA_CODE is null)))
      AND ((tlinfo.INST_PHONE_NUMBER = X_INST_PHONE_NUMBER)
           OR ((tlinfo.INST_PHONE_NUMBER is null)
               AND (X_INST_PHONE_NUMBER is null)))
      AND ((tlinfo.inst_priority_cd = X_inst_priority_cd)
           OR ((tlinfo.inst_priority_cd is null)
               AND (X_inst_priority_cd is null)))
      AND ((tlinfo.EPS_CODE = X_EPS_CODE)
           OR ((tlinfo.EPS_CODE is null)
               AND (X_EPS_CODE is null)))
      AND ((tlinfo.INSTITUTION_STATUS = X_INSTITUTION_STATUS)
           OR ((tlinfo.INSTITUTION_STATUS is null)
               AND (X_INSTITUTION_STATUS is null)))
      AND ((tlinfo.LOCAL_INSTITUTION_IND = X_LOCAL_INSTITUTION_IND)
           OR ((tlinfo.LOCAL_INSTITUTION_IND is null)
               AND (X_LOCAL_INSTITUTION_IND is null)))
      AND ((tlinfo.OS_IND = X_OS_IND)
           OR ((tlinfo.OS_IND is null)
               AND (X_OS_IND is null)))
      AND ((tlinfo.GOVT_INSTITUTION_CD = X_GOVT_INSTITUTION_CD)
           OR ((tlinfo.GOVT_INSTITUTION_CD is null)
               AND (X_GOVT_INSTITUTION_CD is null)))
      AND ((tlinfo.INSTITUTION_TYPE = X_INSTITUTION_TYPE)
           OR ((tlinfo.INSTITUTION_TYPE is null)
               AND (X_INSTITUTION_TYPE is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.INST_CONTROL_TYPE = X_INST_CONTROL_TYPE)
           OR ((tlinfo.INST_CONTROL_TYPE is null)
               AND (X_INST_CONTROL_TYPE is null)))

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
  X_INSTITUTION_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_NAME in VARCHAR2,

  X_INST_PHONE_COUNTRY_CODE in VARCHAR2,
  X_INST_PHONE_AREA_CODE in VARCHAR2,
  X_INST_PHONE_NUMBER in VARCHAR2,
  X_inst_priority_cd in VARCHAR2,
  X_EPS_CODE in VARCHAR2,

  X_INSTITUTION_STATUS in VARCHAR2,
  X_LOCAL_INSTITUTION_IND in VARCHAR2,
  X_OS_IND in VARCHAR2,
  X_GOVT_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INST_CONTROL_TYPE in VARCHAR2,
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
   x_institution_type=>X_INSTITUTION_TYPE,
   x_description=>X_DESCRIPTION,
   x_inst_control_type=>X_INST_CONTROL_TYPE,
   x_govt_institution_cd=>X_GOVT_INSTITUTION_CD,
   x_hist_end_dt=>X_HIST_END_DT,
   x_hist_start_dt=>X_HIST_START_DT,
   x_hist_who=>X_HIST_WHO,
   x_institution_cd=>X_INSTITUTION_CD,
   x_institution_status=>X_INSTITUTION_STATUS,
   x_local_institution_ind=>X_LOCAL_INSTITUTION_IND,

   x_inst_phone_country_code  => X_INST_PHONE_COUNTRY_CODE ,
   x_inst_phone_area_code => X_INST_PHONE_AREA_CODE ,
   x_inst_phone_number => X_INST_PHONE_NUMBER ,
   x_inst_priority_cd => X_inst_priority_cd,
   x_eps_code => X_EPS_CODE,


   x_name=>X_NAME,
   x_os_ind=>X_OS_IND,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  update IGS_OR_INST_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    NAME = NEW_REFERENCES.NAME,

    INST_PHONE_COUNTRY_CODE	= NEW_REFERENCES.INST_PHONE_COUNTRY_CODE,
    INST_PHONE_AREA_CODE	= NEW_REFERENCES.INST_PHONE_AREA_CODE,
    INST_PHONE_NUMBER		= NEW_REFERENCES.INST_PHONE_NUMBER,
    inst_priority_cd	= NEW_REFERENCES.inst_priority_cd,
    EPS_CODE			= NEW_REFERENCES.EPS_CODE,


    INSTITUTION_STATUS = NEW_REFERENCES.INSTITUTION_STATUS,
    LOCAL_INSTITUTION_IND = NEW_REFERENCES.LOCAL_INSTITUTION_IND,
    OS_IND = NEW_REFERENCES.OS_IND,
    GOVT_INSTITUTION_CD = NEW_REFERENCES.GOVT_INSTITUTION_CD,
    INSTITUTION_TYPE=NEW_REFERENCES.INSTITUTION_TYPE,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    INST_CONTROL_TYPE=NEW_REFERENCES.INST_CONTROL_TYPE,
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
  X_INSTITUTION_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_NAME in VARCHAR2,

  X_INST_PHONE_COUNTRY_CODE in VARCHAR2,
  X_INST_PHONE_AREA_CODE in VARCHAR2,
  X_INST_PHONE_NUMBER in VARCHAR2,
  X_inst_priority_cd in VARCHAR2,
  X_EPS_CODE in VARCHAR2,

  X_INSTITUTION_STATUS in VARCHAR2,
  X_LOCAL_INSTITUTION_IND in VARCHAR2,
  X_OS_IND in VARCHAR2,
  X_GOVT_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INST_CONTROL_TYPE in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_OR_INST_HIST_ALL
     where INSTITUTION_CD = X_INSTITUTION_CD
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_INSTITUTION_CD,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_NAME,

     X_INST_PHONE_COUNTRY_CODE ,
     X_INST_PHONE_AREA_CODE ,
     X_INST_PHONE_NUMBER ,
     X_inst_priority_cd,
     X_EPS_CODE ,

     X_INSTITUTION_STATUS,
     X_LOCAL_INSTITUTION_IND,
     X_OS_IND,
     X_GOVT_INSTITUTION_CD,
     X_INSTITUTION_TYPE,
     X_DESCRIPTION,
     X_INST_CONTROL_TYPE,
     X_MODE,
     x_org_id);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_INSTITUTION_CD,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_NAME,

   X_INST_PHONE_COUNTRY_CODE ,
   X_INST_PHONE_AREA_CODE ,
   X_INST_PHONE_NUMBER ,
   X_inst_priority_cd,
   X_EPS_CODE ,

   X_INSTITUTION_STATUS,
   X_LOCAL_INSTITUTION_IND,
   X_OS_IND,
   X_GOVT_INSTITUTION_CD,
   X_INSTITUTION_TYPE,
   X_DESCRIPTION,
   X_INST_CONTROL_TYPE,
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
  delete from IGS_OR_INST_HIST_ALL
  where ROWID = X_ROWID ;
  After_DML(
    p_action=>'DELETE',
    x_rowid=>X_ROWID
    );
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure Check_Constraints (
  Column_Name in VARCHAR2,
  Column_Value in VARCHAR2
  ) AS
 begin
 if Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'LOCAL_INSTITUTION_IND' THEN
   new_references.LOCAL_INSTITUTION_IND := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'OS_IND' THEN
   new_references.OS_IND := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INSTITUTION_TYPE' THEN
   new_references.INSTITUTION_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INST_PHONE_COUNTRY_CODE' THEN
   new_references.INST_PHONE_COUNTRY_CODE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INST_PHONE_AREA_CODE' THEN
   new_references.INST_PHONE_AREA_CODE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INST_PHONE_NUMBER' THEN
   new_references.INST_PHONE_NUMBER := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'EPS_CODE' THEN
   new_references.EPS_CODE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'DESCRIPTION' THEN
   new_references.DESCRIPTION := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INST_CONTROL_TYPE' THEN
   new_references.INST_CONTROL_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INSTITUTION_CD' THEN
   new_references.INSTITUTION_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'INSTITUTION_STATUS' THEN
   new_references.INSTITUTION_STATUS := COLUMN_VALUE ;
 end if;

--Bug : 2040069.Removed the check that checks for Upper Case of Description
-- bug: 2425349 Removed the code that checked the institution_cd and hist_who

IF upper(Column_name) = 'INSTITUTION_STATUS' OR COLUMN_NAME IS NULL THEN
  IF new_references.INSTITUTION_STATUS<> upper(new_references.INSTITUTION_STATUS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;
IF upper(Column_name) = 'LOCAL_INSTITUTION_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.LOCAL_INSTITUTION_IND<> upper(new_references.LOCAL_INSTITUTION_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
  IF new_references.LOCAL_INSTITUTION_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;
IF upper(Column_name) = 'OS_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.OS_IND<> upper(new_references.OS_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
  IF new_references.OS_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;
end Check_Constraints ;
end IGS_OR_INST_HIST_PKG;

/
