--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_AS_RT_HT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_AS_RT_HT_PKG" AS
 /* $Header: IGSSI22B.pls 115.7 2003/02/11 06:49:37 pathipat ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_AS_RT_HT_ALL%RowType;
  new_references IGS_FI_FEE_AS_RT_HT_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_chg_rate IN NUMBER DEFAULT NULL,
    x_lower_nrml_rate_ovrd_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_AS_RT_HT_ALL
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.fee_type := x_fee_type;
    new_references.start_dt := x_start_dt;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.end_dt := x_end_dt;
    new_references.location_cd := x_location_cd;
    new_references.attendance_type := x_attendance_type;
    new_references.attendance_mode := x_attendance_mode;
    new_references.chg_rate := x_chg_rate;
    new_references.lower_nrml_rate_ovrd_ind := x_lower_nrml_rate_ovrd_ind;
    new_references.org_id := x_org_id ;
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
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        17-May-2002     removed upper check constraint on fee_type column.bug#2344826.
  ----------------------------------------------------------------------------*/

  BEGIN
  IF Column_Name is NULL THEN
  	NULL;
  ELSIF upper(Column_Name) = 'ATTENDANCE_MODE' then
  	new_references.attendance_mode := Column_Value;
  ELSIF upper(Column_Name) = 'ATTENDANCE_TYPE' then
  	new_references.attendance_type := Column_Value;
  ELSIF upper(Column_Name) = 'COURSE_CD' then
  	new_references.course_cd := Column_Value;
  ELSIF upper(Column_Name) = 'LOCATION_CD' then
  	new_references.location_cd:= Column_Value;
  ELSIF upper(Column_Name) = 'LOWER_NRML_RATE_OVRD_IND' then
  	new_references.lower_nrml_rate_ovrd_ind := Column_Value;
  ELSIF upper(Column_Name) = 'CHG_RATE' then
  	new_references.chg_rate := igs_ge_number.to_num(Column_Value);
  END IF;

	IF upper(Column_Name) = 'ATTENDANCE_MODE' OR
  		column_name is NULL THEN
		IF new_references.attendance_mode <> UPPER(new_references.attendance_mode) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'ATTENDANCE_TYPE' OR
  		column_name is NULL THEN
		IF new_references.attendance_type <> UPPER(new_references.attendance_type) THEN
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
	IF upper(Column_Name) = 'LOCATION_CD' OR
  		column_name is NULL THEN
		IF new_references.location_cd <> UPPER(new_references.location_cd) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'LOWER_NRML_RATE_OVRD_IND' OR
  		column_name is NULL THEN
		IF new_references.lower_nrml_rate_ovrd_ind <> 'Y' AND new_references.lower_nrml_rate_ovrd_ind <> 'N'THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'CHG_RATE' OR
	  		column_name is NULL THEN
			IF new_references.chg_rate < 0 OR new_references.chg_rate > 99999.99 THEN
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                  IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
	END IF;

  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_type IS NULL))) THEN
      		NULL;
    ELSIF NOT IGS_FI_FEE_TYPE_PKG.Get_PK_For_Validation ( new_references.fee_type ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
    	NULL;
    ELSIF NOT  IGS_PE_PERSON_PKG.Get_PK_For_Validation ( new_references.person_id ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_fee_type IN VARCHAR2,
    x_start_dt IN DATE,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN
	AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT_HT_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      fee_type = x_fee_type
      AND      start_dt = x_start_dt
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


  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT_HT_ALL
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_CFARH_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_chg_rate IN NUMBER DEFAULT NULL,
    x_lower_nrml_rate_ovrd_ind IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_course_cd,
      x_fee_type,
      x_start_dt,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_end_dt,
      x_location_cd,
      x_attendance_type,
      x_attendance_mode,
      x_chg_rate,
      x_lower_nrml_rate_ovrd_ind,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation (
	  		new_references.person_id,
    		new_references.course_cd,
		    new_references.fee_type,
    		new_references.start_dt,
		    new_references.hist_start_dt ) THEN
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
		  IF Get_PK_For_Validation (
	  		new_references.person_id,
    		new_references.course_cd,
		    new_references.fee_type,
    		new_references.start_dt,
		    new_references.hist_start_dt ) THEN
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_FEE_AS_RT_HT_ALL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and FEE_TYPE = X_FEE_TYPE
      and START_DT = X_START_DT
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
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_chg_rate=>X_CHG_RATE,
  x_course_cd=>X_COURSE_CD,
  x_end_dt=>X_END_DT,
  x_fee_type=>X_FEE_TYPE,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_location_cd=>X_LOCATION_CD,
  x_lower_nrml_rate_ovrd_ind=>X_LOWER_NRML_RATE_OVRD_IND,
  x_person_id=>X_PERSON_ID,
  x_start_dt=>X_START_DT,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_FI_FEE_AS_RT_HT_ALL (
    PERSON_ID,
    COURSE_CD,
    FEE_TYPE,
    START_DT,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    END_DT,
    LOCATION_CD,
    ATTENDANCE_TYPE,
    ATTENDANCE_MODE,
    CHG_RATE,
    LOWER_NRML_RATE_OVRD_IND,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.CHG_RATE,
    NEW_REFERENCES.LOWER_NRML_RATE_OVRD_IND,
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      END_DT,
      LOCATION_CD,
      ATTENDANCE_TYPE,
      ATTENDANCE_MODE,
      CHG_RATE,
      LOWER_NRML_RATE_OVRD_IND
    from IGS_FI_FEE_AS_RT_HT_ALL
    where ROWID = X_ROWID
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
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.CHG_RATE = X_CHG_RATE)
           OR ((tlinfo.CHG_RATE is null)
               AND (X_CHG_RATE is null)))
      AND ((tlinfo.LOWER_NRML_RATE_OVRD_IND = X_LOWER_NRML_RATE_OVRD_IND)
           OR ((tlinfo.LOWER_NRML_RATE_OVRD_IND is null)
               AND (X_LOWER_NRML_RATE_OVRD_IND is null)))
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2,
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
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_chg_rate=>X_CHG_RATE,
  x_course_cd=>X_COURSE_CD,
  x_end_dt=>X_END_DT,
  x_fee_type=>X_FEE_TYPE,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_location_cd=>X_LOCATION_CD,
  x_lower_nrml_rate_ovrd_ind=>X_LOWER_NRML_RATE_OVRD_IND,
  x_person_id=>X_PERSON_ID,
  x_start_dt=>X_START_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_FI_FEE_AS_RT_HT_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    END_DT = NEW_REFERENCES.END_DT,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    CHG_RATE = NEW_REFERENCES.CHG_RATE,
    LOWER_NRML_RATE_OVRD_IND = NEW_REFERENCES.LOWER_NRML_RATE_OVRD_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_END_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CHG_RATE in NUMBER,
  X_LOWER_NRML_RATE_OVRD_IND in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_FEE_AS_RT_HT_ALL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and FEE_TYPE = X_FEE_TYPE
     and START_DT = X_START_DT
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_FEE_TYPE,
     X_START_DT,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_END_DT,
     X_LOCATION_CD,
     X_ATTENDANCE_TYPE,
     X_ATTENDANCE_MODE,
     X_CHG_RATE,
     X_LOWER_NRML_RATE_OVRD_IND,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
 X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_FEE_TYPE,
   X_START_DT,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_END_DT,
   X_LOCATION_CD,
   X_ATTENDANCE_TYPE,
   X_ATTENDANCE_MODE,
   X_CHG_RATE,
   X_LOWER_NRML_RATE_OVRD_IND,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  delete from IGS_FI_FEE_AS_RT_HT_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_FEE_AS_RT_HT_PKG;

/
