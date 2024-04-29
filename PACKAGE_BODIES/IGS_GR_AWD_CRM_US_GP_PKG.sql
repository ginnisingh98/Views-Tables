--------------------------------------------------------
--  DDL for Package Body IGS_GR_AWD_CRM_US_GP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_AWD_CRM_US_GP_PKG" as
/* $Header: IGSGI06B.pls 115.5 2002/11/29 00:35:00 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_AWD_CRM_US_GP%RowType;
  new_references IGS_GR_AWD_CRM_US_GP%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_us_group_number IN NUMBER DEFAULT NULL,
    x_order_in_award IN NUMBER DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_AWD_CRM_US_GP
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
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.ceremony_number := x_ceremony_number;
    new_references.award_course_cd := x_award_course_cd;
    new_references.award_crs_version_number := x_award_crs_version_number;
    new_references.award_cd := x_award_cd;
    new_references.us_group_number := x_us_group_number;
    new_references.order_in_award := x_order_in_award;
    new_references.override_title := x_override_title;
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
  -- "OSS_TST".trg_acusg_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_AWD_CRM_US_GP
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the graduation ceremony ceremony date is not passed
	IF p_inserting OR p_updating THEN
		IF IGS_GR_VAL_GC.grdp_val_gc_iud(
				new_references.grd_cal_type,
				new_references.grd_ci_sequence_number,
				new_references.ceremony_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the award ceremony is not closed
	IF p_inserting OR p_updating THEN
		IF igs_gr_val_acus.grdp_val_awc_closed(
				new_references.grd_cal_type,
				new_references.grd_ci_sequence_number,
				new_references.ceremony_number,
				new_references.award_course_cd,
				new_references.award_crs_version_number,
				new_references.award_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_acusg_ar_u
  -- AFTER UPDATE
  -- ON IGS_GR_AWD_CRM_US_GP
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	IF (p_updating AND
	   (new_references.order_in_award <> old_references.order_in_award OR
	   (new_references.closed_ind <> old_references.closed_ind AND new_references.closed_ind = 'N'))) THEN
  			-- validate award ceremony us group order in award
  			IF IGS_GR_VAL_AWC.grdp_val_acusg_order(
  					new_references.grd_cal_type,
  					new_references.grd_ci_sequence_number,
  					new_references.ceremony_number,
  					new_references.award_course_cd,
  					new_references.award_crs_version_number,
  					new_references.award_cd,
  					new_references.us_group_number,
  					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
		v_rowid_saved := TRUE;
	END IF;


  END AfterRowUpdate2;

PROCEDURE Check_Uniqueness AS
    BEGIN
IF get_uk_for_validation(
			NEW_REFERENCES.grd_cal_type,
		        NEW_REFERENCES.grd_ci_sequence_number,
         		NEW_REFERENCES.ceremony_number,
         		NEW_REFERENCES.award_course_cd,
         		NEW_REFERENCES.award_crs_version_number,
         		NEW_REFERENCES.award_cd,
         		NEW_REFERENCES.order_in_award
	) THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
END IF;
END Check_Uniqueness;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number) AND
         (old_references.ceremony_number = new_references.ceremony_number) AND
         (old_references.award_course_cd = new_references.award_course_cd) AND
         (old_references.award_crs_version_number = new_references.award_crs_version_number) AND
         (old_references.award_cd = new_references.award_cd)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL) OR
         (new_references.ceremony_number IS NULL) OR
         (new_references.award_course_cd IS NULL) OR
         (new_references.award_crs_version_number IS NULL) OR
         (new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF not IGS_GR_AWD_CEREMONY_PKG.Get_UK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number,
        new_references.ceremony_number,
        new_references.award_course_cd,
        new_references.award_crs_version_number,
        new_references.award_cd
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
 END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_GR_AWD_CRM_UT_ST_PKG.GET_FK_IGS_GR_AWD_CRM_US_GP (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number,
      old_references.award_course_cd,
      old_references.award_crs_version_number,
      old_references.award_cd,
      old_references.us_group_number
      );

    IGS_GR_AWD_CRMN_PKG.GET_FK_IGS_GR_AWD_CRM_US_GP (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number,
      old_references.award_course_cd,
      old_references.award_crs_version_number,
      old_references.award_cd,
      old_references.us_group_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2,
    x_us_group_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_US_GP
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd
      AND      us_group_number = x_us_group_number
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

  PROCEDURE GET_UFK_IGS_GR_AWD_CEREMONY (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_US_GP
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_ACUSG_AWC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_GR_AWD_CEREMONY;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_us_group_number IN NUMBER DEFAULT NULL,
    x_order_in_award IN NUMBER DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
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
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_ceremony_number,
      x_award_course_cd,
      x_award_crs_version_number,
      x_award_cd,
      x_us_group_number,
      x_order_in_award,
      x_override_title,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
		IF Get_PK_For_Validation (
		    NEW_REFERENCES.grd_cal_type,
		    NEW_REFERENCES.grd_ci_sequence_number,
		    NEW_REFERENCES.ceremony_number,
		    NEW_REFERENCES.award_course_cd,
		    NEW_REFERENCES.award_crs_version_number,
		    NEW_REFERENCES.award_cd,
		    NEW_REFERENCES.us_group_number
		    ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

		END IF;

	Check_Constraints;
	Check_uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	Check_Constraints;
	Check_uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
		IF Get_PK_For_Validation (
		    NEW_REFERENCES.grd_cal_type,
		    NEW_REFERENCES.grd_ci_sequence_number,
		    NEW_REFERENCES.ceremony_number,
		    NEW_REFERENCES.award_course_cd,
		    NEW_REFERENCES.award_crs_version_number,
		    NEW_REFERENCES.award_cd,
		    NEW_REFERENCES.us_group_number
		    ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

		END IF;
		Check_Constraints;
		Check_uniqueness;

	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

			Check_Constraints;
			Check_uniqueness;

	ELSIF (p_action = 'VALIDATE_DELETE') THEN
		Check_Child_Existance;

    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate2 ( p_updating => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_GR_AWD_CRM_US_GP
      where GRD_CAL_TYPE = X_GRD_CAL_TYPE
      and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
      and CEREMONY_NUMBER = X_CEREMONY_NUMBER
      and AWARD_COURSE_CD = X_AWARD_COURSE_CD
      and AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER
      and AWARD_CD = X_AWARD_CD
      and US_GROUP_NUMBER = X_US_GROUP_NUMBER;
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
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_us_group_number => X_US_GROUP_NUMBER,
    x_order_in_award => X_ORDER_IN_AWARD,
    x_override_title => X_OVERRIDE_TITLE,
    x_closed_ind => NVL(X_CLOSED_IND, 'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_GR_AWD_CRM_US_GP (
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    US_GROUP_NUMBER,
    ORDER_IN_AWARD,
    OVERRIDE_TITLE,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CEREMONY_NUMBER,
    NEW_REFERENCES.AWARD_COURSE_CD,
    NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.US_GROUP_NUMBER,
    NEW_REFERENCES.ORDER_IN_AWARD,
    NEW_REFERENCES.OVERRIDE_TITLE,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      ORDER_IN_AWARD,
      OVERRIDE_TITLE,
      CLOSED_IND
    from IGS_GR_AWD_CRM_US_GP
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.ORDER_IN_AWARD = X_ORDER_IN_AWARD)
      AND ((tlinfo.OVERRIDE_TITLE = X_OVERRIDE_TITLE)
           OR ((tlinfo.OVERRIDE_TITLE is null)
               AND (X_OVERRIDE_TITLE is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
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
     x_rowid => X_ROWID,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_us_group_number => X_US_GROUP_NUMBER,
    x_order_in_award => X_ORDER_IN_AWARD,
    x_override_title => X_OVERRIDE_TITLE,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_AWD_CRM_US_GP set
    ORDER_IN_AWARD = NEW_REFERENCES.ORDER_IN_AWARD,
    OVERRIDE_TITLE = NEW_REFERENCES.OVERRIDE_TITLE,
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
     x_rowid => X_ROWID
    );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_GR_AWD_CRM_US_GP
     where GRD_CAL_TYPE = X_GRD_CAL_TYPE
     and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
     and CEREMONY_NUMBER = X_CEREMONY_NUMBER
     and AWARD_COURSE_CD = X_AWARD_COURSE_CD
     and AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER
     and AWARD_CD = X_AWARD_CD
     and US_GROUP_NUMBER = X_US_GROUP_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_CEREMONY_NUMBER,
     X_AWARD_COURSE_CD,
     X_AWARD_CRS_VERSION_NUMBER,
     X_AWARD_CD,
     X_US_GROUP_NUMBER,
     X_ORDER_IN_AWARD,
     X_OVERRIDE_TITLE,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_CEREMONY_NUMBER,
   X_AWARD_COURSE_CD,
   X_AWARD_CRS_VERSION_NUMBER,
   X_AWARD_CD,
   X_US_GROUP_NUMBER,
   X_ORDER_IN_AWARD,
   X_OVERRIDE_TITLE,
   X_CLOSED_IND,
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

  delete from IGS_GR_AWD_CRM_US_GP
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

FUNCTION get_uk_for_validation(
		      x_grd_cal_type IN VARCHAR2,
         		x_grd_ci_sequence_number IN NUMBER,
         		x_ceremony_number IN NUMBER,
         		x_award_course_cd IN VARCHAR2,
         		x_award_crs_version_number IN NUMBER,
         		x_award_cd IN VARCHAR2,
         		x_order_in_award IN VARCHAR2
	) RETURN BOOLEAN AS
CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_US_GP
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd
      AND      order_in_award = x_order_in_award
	  AND      (l_rowid is null or rowid <> l_rowid )
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
END GET_UK_FOR_VALIDATION;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN
	IF column_value IS NULL THEN
		NULL;
	ELSIF upper(Column_name) = 'US_GROUP_NUMBER' then
	    new_references.us_group_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'CLOSED_IND' then
	    new_references.closed_ind := column_value;
	ELSIF upper(Column_name) = 'ORDER_IN_AWARD' then
	    new_references.order_in_award  := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'AWARD_CD' then
	    new_references.award_cd:= column_value;
	ELSIF upper(Column_name) = 'AWARD_COURSE_CD' then
	    new_references.award_course_cd:= column_value;
	ELSIF upper(Column_name) = 'GRD_CAL_TYPE' then
	    new_references.grd_cal_type:= column_value;
	END IF;

IF upper(Column_name) = 'US_GROUP_NUMBER' OR column_name IS NULL then
			IF new_references.us_group_number < 0 OR
      				   new_references.us_group_number > 999999 THEN
						Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
					END IF;
				END IF;
IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
    				  IF new_references.closed_ind NOT IN('Y','N') THEN
						Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
				  END IF;
END IF;

IF upper(Column_name) = 'ORDER_IN_AWARD' OR column_name IS NULL then
					IF new_references.ORDER_IN_AWARD < 0 OR
      				   new_references.ORDER_IN_AWARD > 999 THEN
						Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
					END IF;
END IF;


IF upper(Column_name) = 'AWARD_CD' OR COLUMN_NAME IS NULL THEN
    				  IF new_references.award_cd <> UPPER(new_references.award_cd) THEN
						Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
				  END IF;
END IF;



IF upper(Column_name) = 'AWARD_COURSE_CD' OR column_name IS NULL then
					 IF new_references.award_course_cd <> UPPER(new_references.award_course_cd) THEN
						Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
					  END IF;
END IF;

IF upper(Column_name) = 'GRD_CAL_TYPE' OR column_name IS NULL then
					 IF new_references.grd_cal_type <> UPPER(new_references.grd_cal_type) THEN
						Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
						App_Exception.Raise_Exception;
					  END IF;
END IF;

END Check_Constraints;

end IGS_GR_AWD_CRM_US_GP_PKG;

/
