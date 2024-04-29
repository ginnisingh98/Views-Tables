--------------------------------------------------------
--  DDL for Package Body IGS_RE_THS_PNL_MR_HS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THS_PNL_MR_HS_PKG" as
/* $Header: IGSRI22B.pls 115.5 2002/11/29 03:37:32 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_RE_THS_PNL_MR_HS_ALL%RowType;
  new_references IGS_RE_THS_PNL_MR_HS_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ca_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_panel_member_type IN VARCHAR2 DEFAULT NULL,
    x_confirmed_dt IN DATE DEFAULT NULL,
    x_declined_dt IN DATE DEFAULT NULL,
    x_anonymity_ind IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_paid_dt IN DATE DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_recommendation_summary IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN VARCHAR2 DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_THS_PNL_MR_HS_ALL
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
    new_references.ca_person_id := x_ca_person_id;
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.the_sequence_number := x_the_sequence_number;
    new_references.creation_dt := x_creation_dt;
    new_references.person_id := x_person_id;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.panel_member_type := x_panel_member_type;
    new_references.confirmed_dt := x_confirmed_dt;
    new_references.declined_dt := x_declined_dt;
    new_references.anonymity_ind := x_anonymity_ind;
    new_references.thesis_result_cd := x_thesis_result_cd;
    new_references.paid_dt := x_paid_dt;
    new_references.tracking_id := x_tracking_id;
    new_references.org_id := x_org_id;
    new_references.recommendation_summary := x_recommendation_summary;
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


 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 ) AS
  BEGIN
   IF column_name is null then
	NULL;
   ELSIF upper(Column_name) = 'THE_SEQUENCE_NUMBER'then
	new_references.the_sequence_number  := column_value ;
   ELSIF upper(Column_name) ='CA_SEQUENCE_NUMBER' then
	new_references.ca_sequence_number := column_value ;
   ELSIF upper(Column_name) = 'ANONYMITY_IND' then
	new_references.anonymity_ind := column_value ;
   ELSIF upper(Column_name) = 'PANEL_MEMBER_TYPE' then
	new_references.panel_member_type:= column_value ;
   ELSIF upper(Column_name) = 'THESIS_RESULT_CD' then
	new_references.thesis_result_cd:= column_value ;
   END IF;

   IF upper(Column_name) = 'THESIS_RESULT_CD' OR column_name is null then
	IF new_references.thesis_result_cd <> UPPER(new_references.thesis_result_cd ) then
   	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
   	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
   END IF;

	IF upper(Column_name) = 'ANONYMITY_IND' OR column_name is null then
		IF new_references.anonymity_ind <> UPPER(new_references.anonymity_ind ) OR
			new_references.anonymity_ind NOT IN ( 'Y' , 'N' ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

   IF upper(Column_name) = 'PANEL_MEMBER_TYPE' OR column_name is null then
	IF new_references.panel_member_type <> UPPER(new_references.panel_member_type ) then
   	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
   	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
   END IF;

   IF upper(Column_name) = 'THE_SEQUENCE_NUMBER' OR  column_name is null then
	   IF new_references.the_sequence_number  < 1 OR new_references.the_sequence_number  > 999999 THEN
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
   END IF;

   IF upper(Column_name) = 'CA_SEQUENCE_NUMBER' OR  column_name is null then
 	  IF new_references.ca_sequence_number < 1 OR new_references.ca_sequence_number > 999999 THEN
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
   END IF;

  END Check_Constraints;


 FUNCTION Get_PK_For_Validation (
    x_ca_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_the_sequence_number IN NUMBER,
    x_creation_dt IN DATE,
    x_person_id IN NUMBER,
    x_hist_start_dt IN DATE
    )
   RETURN BOOLEAN
   AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_PNL_MR_HS_ALL
      WHERE    ca_person_id = x_ca_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      the_sequence_number = x_the_sequence_number
      AND      creation_dt = x_creation_dt
      AND      person_id = x_person_id
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
	IF (cur_rowid%FOUND) THEN
	  Close cur_rowid;
	  Return(TRUE);
	ELSE
	  Close cur_rowid;
	  Return(FALSE);
	END IF;
  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_ca_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_panel_member_type IN VARCHAR2 DEFAULT NULL,
    x_confirmed_dt IN DATE DEFAULT NULL,
    x_declined_dt IN DATE DEFAULT NULL,
    x_anonymity_ind IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_paid_dt IN DATE DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_recommendation_summary IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_ca_person_id,
      x_ca_sequence_number,
      x_the_sequence_number,
      x_creation_dt,
      x_person_id,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_panel_member_type,
      x_confirmed_dt,
      x_declined_dt,
      x_anonymity_ind,
      x_thesis_result_cd,
      x_paid_dt,
      x_tracking_id,
      x_recommendation_summary,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation(
          new_references.ca_person_id,
	    new_references.ca_sequence_number ,
	    new_references.the_sequence_number ,
	    new_references.creation_dt ,
	    new_references.person_id,
	    new_references.hist_start_dt
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(
          new_references.ca_person_id,
	    new_references.ca_sequence_number ,
	    new_references.the_sequence_number ,
	    new_references.creation_dt ,
	    new_references.person_id,
	    new_references.hist_start_dt
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_THS_PNL_MR_HS_ALL
      where CA_PERSON_ID = X_CA_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and THE_SEQUENCE_NUMBER = X_THE_SEQUENCE_NUMBER
      and CREATION_DT = X_CREATION_DT
      and PERSON_ID = X_PERSON_ID
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

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_ca_person_id => X_CA_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_the_sequence_number => X_THE_SEQUENCE_NUMBER,
    x_creation_dt => X_CREATION_DT,
    x_person_id => X_PERSON_ID,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_panel_member_type => X_PANEL_MEMBER_TYPE,
    x_confirmed_dt => X_CONFIRMED_DT,
    x_declined_dt => X_DECLINED_DT,
    x_anonymity_ind => NVL(X_ANONYMITY_IND, 'N'),
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_paid_dt => X_PAID_DT,
    x_tracking_id => X_TRACKING_ID,
    x_recommendation_summary => X_RECOMMENDATION_SUMMARY,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );

  insert into IGS_RE_THS_PNL_MR_HS_ALL (
    CA_PERSON_ID,
    CA_SEQUENCE_NUMBER,
    THE_SEQUENCE_NUMBER,
    CREATION_DT,
    PERSON_ID,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    PANEL_MEMBER_TYPE,
    CONFIRMED_DT,
    DECLINED_DT,
    ANONYMITY_IND,
    THESIS_RESULT_CD,
    PAID_DT,
    TRACKING_ID,
    RECOMMENDATION_SUMMARY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.CA_PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.THE_SEQUENCE_NUMBER,
    NEW_REFERENCES.CREATION_DT,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.PANEL_MEMBER_TYPE,
    NEW_REFERENCES.CONFIRMED_DT,
    NEW_REFERENCES.DECLINED_DT,
    NEW_REFERENCES.ANONYMITY_IND,
    NEW_REFERENCES.THESIS_RESULT_CD,
    NEW_REFERENCES.PAID_DT,
    NEW_REFERENCES.TRACKING_ID,
    NEW_REFERENCES.RECOMMENDATION_SUMMARY,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      PANEL_MEMBER_TYPE,
      CONFIRMED_DT,
      DECLINED_DT,
      ANONYMITY_IND,
      THESIS_RESULT_CD,
      PAID_DT,
      TRACKING_ID,
      RECOMMENDATION_SUMMARY
    from IGS_RE_THS_PNL_MR_HS_ALL
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.PANEL_MEMBER_TYPE = X_PANEL_MEMBER_TYPE)
           OR ((tlinfo.PANEL_MEMBER_TYPE is null)
               AND (X_PANEL_MEMBER_TYPE is null)))
      AND ((tlinfo.CONFIRMED_DT = X_CONFIRMED_DT)
           OR ((tlinfo.CONFIRMED_DT is null)
               AND (X_CONFIRMED_DT is null)))
      AND ((tlinfo.DECLINED_DT = X_DECLINED_DT)
           OR ((tlinfo.DECLINED_DT is null)
               AND (X_DECLINED_DT is null)))
      AND ((tlinfo.ANONYMITY_IND = X_ANONYMITY_IND)
           OR ((tlinfo.ANONYMITY_IND is null)
               AND (X_ANONYMITY_IND is null)))
      AND ((tlinfo.THESIS_RESULT_CD = X_THESIS_RESULT_CD)
           OR ((tlinfo.THESIS_RESULT_CD is null)
               AND (X_THESIS_RESULT_CD is null)))
      AND ((tlinfo.PAID_DT = X_PAID_DT)
           OR ((tlinfo.PAID_DT is null)
               AND (X_PAID_DT is null)))
      AND ((tlinfo.TRACKING_ID = X_TRACKING_ID)
           OR ((tlinfo.TRACKING_ID is null)
               AND (X_TRACKING_ID is null)))
      AND ((tlinfo.RECOMMENDATION_SUMMARY = X_RECOMMENDATION_SUMMARY)
           OR ((tlinfo.RECOMMENDATION_SUMMARY is null)
               AND (X_RECOMMENDATION_SUMMARY is null)))
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
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2,
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

  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_ca_person_id => X_CA_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_the_sequence_number => X_THE_SEQUENCE_NUMBER,
    x_creation_dt => X_CREATION_DT,
    x_person_id => X_PERSON_ID,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_panel_member_type => X_PANEL_MEMBER_TYPE,
    x_confirmed_dt => X_CONFIRMED_DT,
    x_declined_dt => X_DECLINED_DT,
    x_anonymity_ind => X_ANONYMITY_IND,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_paid_dt => X_PAID_DT,
    x_tracking_id => X_TRACKING_ID,
    x_recommendation_summary => X_RECOMMENDATION_SUMMARY,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_RE_THS_PNL_MR_HS_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    PANEL_MEMBER_TYPE = NEW_REFERENCES.PANEL_MEMBER_TYPE,
    CONFIRMED_DT = NEW_REFERENCES.CONFIRMED_DT,
    DECLINED_DT = NEW_REFERENCES.DECLINED_DT,
    ANONYMITY_IND = NEW_REFERENCES.ANONYMITY_IND,
    THESIS_RESULT_CD = NEW_REFERENCES.THESIS_RESULT_CD,
    PAID_DT = NEW_REFERENCES.PAID_DT,
    TRACKING_ID = NEW_REFERENCES.TRACKING_ID,
    RECOMMENDATION_SUMMARY = NEW_REFERENCES.RECOMMENDATION_SUMMARY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_PERSON_ID in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PANEL_MEMBER_TYPE in VARCHAR2,
  X_CONFIRMED_DT in DATE,
  X_DECLINED_DT in DATE,
  X_ANONYMITY_IND in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_PAID_DT in DATE,
  X_TRACKING_ID in NUMBER,
  X_RECOMMENDATION_SUMMARY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_THS_PNL_MR_HS_ALL
     where CA_PERSON_ID = X_CA_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and THE_SEQUENCE_NUMBER = X_THE_SEQUENCE_NUMBER
     and CREATION_DT = X_CREATION_DT
     and PERSON_ID = X_PERSON_ID
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CA_PERSON_ID,
     X_CA_SEQUENCE_NUMBER,
     X_THE_SEQUENCE_NUMBER,
     X_CREATION_DT,
     X_PERSON_ID,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_PANEL_MEMBER_TYPE,
     X_CONFIRMED_DT,
     X_DECLINED_DT,
     X_ANONYMITY_IND,
     X_THESIS_RESULT_CD,
     X_PAID_DT,
     X_TRACKING_ID,
     X_RECOMMENDATION_SUMMARY,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CA_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_THE_SEQUENCE_NUMBER,
   X_CREATION_DT,
   X_PERSON_ID,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_PANEL_MEMBER_TYPE,
   X_CONFIRMED_DT,
   X_DECLINED_DT,
   X_ANONYMITY_IND,
   X_THESIS_RESULT_CD,
   X_PAID_DT,
   X_TRACKING_ID,
   X_RECOMMENDATION_SUMMARY,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  ) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );

  delete from IGS_RE_THS_PNL_MR_HS_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_RE_THS_PNL_MR_HS_PKG;

/
