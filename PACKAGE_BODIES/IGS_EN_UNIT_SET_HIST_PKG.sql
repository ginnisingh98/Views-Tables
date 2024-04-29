--------------------------------------------------------
--  DDL for Package Body IGS_EN_UNIT_SET_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_UNIT_SET_HIST_PKG" AS
/* $Header: IGSEI04B.pls 115.6 2003/01/27 06:53:47 nalkumar ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_UNIT_SET_HIST_ALL%RowType;
  new_references IGS_EN_UNIT_SET_HIST_ALL%RowType;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_unit_set_status IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_review_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviation IN VARCHAR2 DEFAULT NULL,
    x_responsible_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_responsible_ou_start_dt IN DATE DEFAULT NULL,
    x_ou_description IN VARCHAR2 DEFAULT NULL,
    x_administrative_ind IN VARCHAR2 DEFAULT NULL,
    x_authorisation_rqrd_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_UNIT_SET_HIST_ALL
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
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.org_id := x_org_id;
    new_references.version_number := x_version_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.unit_set_status := x_unit_set_status;
    new_references.unit_set_cat := x_unit_set_cat;
    new_references.start_dt := x_start_dt;
    new_references.review_dt := x_review_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.end_dt := x_end_dt;
    new_references.title := x_title;
    new_references.short_title := x_short_title;
    new_references.abbreviation := x_abbreviation;
    new_references.responsible_org_unit_cd := x_responsible_org_unit_cd;
    new_references.responsible_ou_start_dt := x_responsible_ou_start_dt;
    new_references.ou_description := x_ou_description;
    new_references.administrative_ind := x_administrative_ind;
    new_references.authorisation_rqrd_ind := x_authorisation_rqrd_ind;
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
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'UNIT_SET_STATUS' THEN
        new_references.unit_set_status := column_value;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CD' THEN
        new_references.unit_set_cd := column_value;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CAT' THEN
        new_references.unit_set_cat := column_value;
    ELSIF  UPPER(column_name) = 'RESPONSIBLE_ORG_UNIT_CD' THEN
        new_references.responsible_org_unit_cd := column_value;
    ELSIF  UPPER(column_name) = 'AUTHORISATION_RQRD_IND' THEN
        new_references.authorisation_rqrd_ind := column_value;
    ELSIF  UPPER(column_name) = 'ADMINISTRATIVE_IND' THEN
        new_references.administrative_ind := column_value;
    ELSIF  UPPER(column_name) = 'ABBREVIATION' THEN
        new_references.abbreviation := column_value;
    END IF;


    IF ((UPPER (column_name) = 'ABBREVIATION') OR (column_name IS NULL)) THEN
      IF (new_references.abbreviation <> UPPER (new_references.abbreviation)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'ADMINISTRATIVE_IND') OR (column_name IS NULL)) THEN
      IF new_references.administrative_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'AUTHORISATION_RQRD_IND') OR (column_name IS NULL)) THEN
      IF new_references.authorisation_rqrd_ind NOT  IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_CAT') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_cat <> UPPER (new_references.unit_set_cat)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_cd <> UPPER (new_references.unit_set_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_STATUS') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_status <> UPPER (new_references.unit_set_status)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;


  FUNCTION Get_PK_For_Validation (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_hist_start_dt IN DATE
    )  RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_HIST_ALL
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number
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
    x_rowid IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_unit_set_status IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_review_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviation IN VARCHAR2 DEFAULT NULL,
    x_responsible_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_responsible_ou_start_dt IN DATE DEFAULT NULL,
    x_ou_description IN VARCHAR2 DEFAULT NULL,
    x_administrative_ind IN VARCHAR2 DEFAULT NULL,
    x_authorisation_rqrd_ind IN VARCHAR2 DEFAULT NULL,
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
      x_unit_set_cd,
      x_version_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_unit_set_status,
      x_unit_set_cat,
      x_start_dt,
      x_review_dt,
      x_expiry_dt,
      x_end_dt,
      x_title,
      x_short_title,
      x_abbreviation,
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_ou_description,
      x_administrative_ind,
      x_authorisation_rqrd_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN

	IF Get_PK_For_Validation(
		new_references.unit_set_cd,
 		new_references.version_number,
                new_references.hist_start_dt
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;

	END IF;

	Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
			new_references.unit_set_cd,
 			new_references.version_number,
                	new_references.hist_start_dt
				 ) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
		          App_Exception.Raise_Exception;
     	        END IF;
      		Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      		  Check_Constraints;
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
  X_ORG_ID in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_UNIT_SET_HIST_ALL
      where UNIT_SET_CD = X_UNIT_SET_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
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
      p_action => 'INSERT' ,
      x_rowid => x_rowid ,
      x_org_id => igs_ge_gen_003.get_org_id,
      x_unit_set_cd => x_unit_set_cd ,
      x_version_number => x_version_number ,
      x_hist_start_dt => x_hist_start_dt ,
      x_hist_end_dt => x_hist_end_dt ,
      x_hist_who => x_hist_who ,
      x_unit_set_status => x_unit_set_status ,
      x_unit_set_cat => x_unit_set_cat ,
      x_start_dt => x_start_dt ,
      x_review_dt => x_review_dt ,
      x_expiry_dt => x_expiry_dt ,
      x_end_dt => x_end_dt ,
      x_title => x_title ,
      x_short_title => x_short_title ,
      x_abbreviation => x_abbreviation,
      x_responsible_org_unit_cd => x_responsible_org_unit_cd ,
      x_responsible_ou_start_dt => x_responsible_ou_start_dt ,
      x_ou_description => x_ou_description ,
      x_administrative_ind => NVL(x_administrative_ind,'N') ,
      x_authorisation_rqrd_ind => NVL(x_authorisation_rqrd_ind,'N') ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );

  insert into IGS_EN_UNIT_SET_HIST_ALL (
    org_id,
    UNIT_SET_CD,
    VERSION_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    UNIT_SET_STATUS,
    UNIT_SET_CAT,
    START_DT,
    REVIEW_DT,
    EXPIRY_DT,
    END_DT,
    TITLE,
    SHORT_TITLE,
    ABBREVIATION,
    RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT,
    OU_DESCRIPTION,
    ADMINISTRATIVE_IND,
    AUTHORISATION_RQRD_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    new_references.org_id,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.UNIT_SET_STATUS,
    NEW_REFERENCES.UNIT_SET_CAT,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.REVIEW_DT,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.SHORT_TITLE,
    NEW_REFERENCES.ABBREVIATION,
    NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    NEW_REFERENCES.OU_DESCRIPTION,
    NEW_REFERENCES.ADMINISTRATIVE_IND,
    NEW_REFERENCES.AUTHORISATION_RQRD_IND,
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

  After_DML(
    p_action => 'INSERT',
    x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      UNIT_SET_STATUS,
      UNIT_SET_CAT,
      START_DT,
      REVIEW_DT,
      EXPIRY_DT,
      END_DT,
      TITLE,
      SHORT_TITLE,
      ABBREVIATION,
      RESPONSIBLE_ORG_UNIT_CD,
      RESPONSIBLE_OU_START_DT,
      OU_DESCRIPTION,
      ADMINISTRATIVE_IND,
      AUTHORISATION_RQRD_IND
    from IGS_EN_UNIT_SET_HIST_ALL
    where ROWID = X_ROWID
    for update nowait;
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.UNIT_SET_STATUS = X_UNIT_SET_STATUS)
           OR ((tlinfo.UNIT_SET_STATUS is null)
               AND (X_UNIT_SET_STATUS is null)))
      AND ((tlinfo.UNIT_SET_CAT = X_UNIT_SET_CAT)
           OR ((tlinfo.UNIT_SET_CAT is null)
               AND (X_UNIT_SET_CAT is null)))
      AND ((tlinfo.START_DT = X_START_DT)
           OR ((tlinfo.START_DT is null)
               AND (X_START_DT is null)))
      AND ((tlinfo.REVIEW_DT = X_REVIEW_DT)
           OR ((tlinfo.REVIEW_DT is null)
               AND (X_REVIEW_DT is null)))
      AND ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.TITLE = X_TITLE)
           OR ((tlinfo.TITLE is null)
               AND (X_TITLE is null)))
      AND ((tlinfo.SHORT_TITLE = X_SHORT_TITLE)
           OR ((tlinfo.SHORT_TITLE is null)
               AND (X_SHORT_TITLE is null)))
      AND ((tlinfo.ABBREVIATION = X_ABBREVIATION)
           OR ((tlinfo.ABBREVIATION is null)
               AND (X_ABBREVIATION is null)))
      AND ((tlinfo.RESPONSIBLE_ORG_UNIT_CD = X_RESPONSIBLE_ORG_UNIT_CD)
           OR ((tlinfo.RESPONSIBLE_ORG_UNIT_CD is null)
               AND (X_RESPONSIBLE_ORG_UNIT_CD is null)))
      AND ((tlinfo.RESPONSIBLE_OU_START_DT = X_RESPONSIBLE_OU_START_DT)
           OR ((tlinfo.RESPONSIBLE_OU_START_DT is null)
               AND (X_RESPONSIBLE_OU_START_DT is null)))
      AND ((tlinfo.OU_DESCRIPTION = X_OU_DESCRIPTION)
           OR ((tlinfo.OU_DESCRIPTION is null)
               AND (X_OU_DESCRIPTION is null)))
      AND (tlinfo.ADMINISTRATIVE_IND = X_ADMINISTRATIVE_IND)
      AND (tlinfo.AUTHORISATION_RQRD_IND = X_AUTHORISATION_RQRD_IND)
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
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
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
      p_action => 'UPDATE' ,
      x_rowid => x_rowid ,
      x_unit_set_cd => x_unit_set_cd ,
      x_version_number => x_version_number ,
      x_hist_start_dt => x_hist_start_dt ,
      x_hist_end_dt => x_hist_end_dt ,
      x_hist_who => x_hist_who ,
      x_unit_set_status => x_unit_set_status ,
      x_unit_set_cat => x_unit_set_cat ,
      x_start_dt => x_start_dt ,
      x_review_dt => x_review_dt ,
      x_expiry_dt => x_expiry_dt ,
      x_end_dt => x_end_dt ,
      x_title => x_title ,
      x_short_title => x_short_title ,
      x_abbreviation => x_short_title ,
      x_responsible_org_unit_cd => x_responsible_org_unit_cd ,
      x_responsible_ou_start_dt => x_responsible_ou_start_dt ,
      x_ou_description => x_ou_description ,
      x_administrative_ind => x_administrative_ind ,
      x_authorisation_rqrd_ind => x_authorisation_rqrd_ind ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );



  update IGS_EN_UNIT_SET_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    UNIT_SET_STATUS = NEW_REFERENCES.UNIT_SET_STATUS,
    UNIT_SET_CAT = NEW_REFERENCES.UNIT_SET_CAT,
    START_DT = NEW_REFERENCES.START_DT,
    REVIEW_DT = NEW_REFERENCES.REVIEW_DT,
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    END_DT = NEW_REFERENCES.END_DT,
    TITLE = NEW_REFERENCES.TITLE,
    SHORT_TITLE = NEW_REFERENCES.SHORT_TITLE,
    ABBREVIATION = NEW_REFERENCES.ABBREVIATION,
    RESPONSIBLE_ORG_UNIT_CD = NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT = NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    OU_DESCRIPTION = NEW_REFERENCES.OU_DESCRIPTION,
    ADMINISTRATIVE_IND = NEW_REFERENCES.ADMINISTRATIVE_IND,
    AUTHORISATION_RQRD_IND = NEW_REFERENCES.AUTHORISATION_RQRD_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_UNIT_SET_HIST_ALL
     where UNIT_SET_CD = X_UNIT_SET_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and HIST_START_DT = X_HIST_START_DT
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
      x_org_id,
     X_UNIT_SET_CD,
     X_VERSION_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_UNIT_SET_STATUS,
     X_UNIT_SET_CAT,
     X_START_DT,
     X_REVIEW_DT,
     X_EXPIRY_DT,
     X_END_DT,
     X_TITLE,
     X_SHORT_TITLE,
     X_ABBREVIATION,
     X_RESPONSIBLE_ORG_UNIT_CD,
     X_RESPONSIBLE_OU_START_DT,
     X_OU_DESCRIPTION,
     X_ADMINISTRATIVE_IND,
     X_AUTHORISATION_RQRD_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_SET_CD,
   X_VERSION_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_UNIT_SET_STATUS,
   X_UNIT_SET_CAT,
   X_START_DT,
   X_REVIEW_DT,
   X_EXPIRY_DT,
   X_END_DT,
   X_TITLE,
   X_SHORT_TITLE,
   X_ABBREVIATION,
   X_RESPONSIBLE_ORG_UNIT_CD,
   X_RESPONSIBLE_OU_START_DT,
   X_OU_DESCRIPTION,
   X_ADMINISTRATIVE_IND,
   X_AUTHORISATION_RQRD_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
begin

  Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_EN_UNIT_SET_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );


end DELETE_ROW;

end IGS_EN_UNIT_SET_HIST_PKG;

/
