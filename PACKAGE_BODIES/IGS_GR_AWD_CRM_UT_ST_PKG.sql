--------------------------------------------------------
--  DDL for Package Body IGS_GR_AWD_CRM_UT_ST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_AWD_CRM_UT_ST_PKG" as
/* $Header: IGSGI05B.pls 115.4 2002/11/29 00:34:43 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_GR_AWD_CRM_UT_ST%RowType;
  new_references IGS_GR_AWD_CRM_UT_ST%RowType;

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
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_order_in_group IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_AWD_CRM_UT_ST
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
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.order_in_group := x_order_in_group;
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
  -- "OSS_TST".trg_acus_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_GR_AWD_CRM_UT_ST
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the award ceremony unit set group is not closed
	IF p_inserting THEN
		IF IGS_GR_VAL_ACUS.grdp_val_crv_us(
				new_references.award_course_cd,
				new_references.award_crs_version_number,
				new_references.unit_set_cd,
				new_references.us_version_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
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
		IF IGS_GR_VAL_ACUS.grdp_val_awc_closed(
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
	-- Validate the award ceremony unit set group is not closed
	IF p_inserting OR p_updating THEN
		IF IGS_GR_VAL_ACUS.grdp_val_acusg_close(
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
	END IF;

	IF p_inserting THEN
  			-- Validate award ceremony us group order in award
  			IF IGS_GR_VAL_AWC.grdp_val_acusg_order(
  					NEW_REFERENCES.grd_cal_type,
  					NEW_REFERENCES.grd_ci_sequence_number,
  					NEW_REFERENCES.ceremony_number,
  					NEW_REFERENCES.award_course_cd,
  					NEW_REFERENCES.award_crs_version_number,
  					NEW_REFERENCES.award_cd,
  					NEW_REFERENCES.us_group_number,
  					v_message_name) = FALSE THEN
  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
  			END IF;
	END IF;
	IF p_deleting THEN
  			-- Validate award ceremony us group order in award
  			IF IGS_GR_VAL_AWC.grdp_val_acusg_order(
  					NEW_REFERENCES.grd_cal_type,
  					NEW_REFERENCES.grd_ci_sequence_number,
  					NEW_REFERENCES.ceremony_number,
  					NEW_REFERENCES.award_course_cd,
  					NEW_REFERENCES.award_crs_version_number,
  					NEW_REFERENCES.award_cd,
  					NEW_REFERENCES.us_group_number,
  					v_message_name) = FALSE THEN
  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
  			END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Uniqueness AS
BEGIN

IF GET_UK_FOR_VALIDATION(NEW_REFERENCES.grd_cal_type,
              NEW_REFERENCES.grd_ci_sequence_number,
              NEW_REFERENCES.ceremony_number,
              NEW_REFERENCES.award_course_cd ,
              NEW_REFERENCES.award_crs_version_number,
              NEW_REFERENCES.award_cd,
              NEW_REFERENCES.us_group_number,
              NEW_REFERENCES.order_in_group) THEN
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
         (old_references.award_cd = new_references.award_cd) AND
         (old_references.us_group_number = new_references.us_group_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL) OR
         (new_references.ceremony_number IS NULL) OR
         (new_references.award_course_cd IS NULL) OR
         (new_references.award_crs_version_number IS NULL) OR
         (new_references.award_cd IS NULL) OR
         (new_references.us_group_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_AWD_CRM_US_GP_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number,
        new_references.ceremony_number,
        new_references.award_course_cd,
        new_references.award_crs_version_number,
        new_references.award_cd,
        new_references.us_group_number
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
     END IF;

   END IF;
    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT  IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.us_version_number
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
     END IF;
   END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2,
    x_us_group_number IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_UT_ST
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd
      AND      us_group_number = x_us_group_number
      AND      unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_us_version_number
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

  PROCEDURE GET_FK_IGS_GR_AWD_CRM_US_GP (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2,
    x_us_group_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_UT_ST
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd
      AND      us_group_number = x_us_group_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_ACUS_ACUSG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_AWD_CRM_US_GP;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_UT_ST
      WHERE    unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_ACUS_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET;

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
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_order_in_group IN NUMBER DEFAULT NULL,
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
      x_unit_set_cd,
      x_us_version_number,
      x_order_in_group,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
			IF Get_PK_For_Validation (
			    NEW_REFERENCES.grd_cal_type,
			    NEW_REFERENCES.grd_ci_sequence_number,
			    NEW_REFERENCES.ceremony_number,
			    NEW_REFERENCES.award_course_cd,
			    NEW_REFERENCES.award_crs_version_number,
			    NEW_REFERENCES.award_cd,
			    NEW_REFERENCES.us_group_number,
			    NEW_REFERENCES.unit_set_cd,
			    NEW_REFERENCES.us_version_number
			 ) THEN
					Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
			check_constraints;
			check_uniqueness;
			Check_Parent_Existance;

 ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Uniqueness;
      Check_Parent_Existance;
	check_constraints;
ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );

ELSIF (p_action = 'VALIDATE_INSERT') THEN
			IF Get_PK_For_Validation (
			    NEW_REFERENCES.grd_cal_type,
			    NEW_REFERENCES.grd_ci_sequence_number,
			    NEW_REFERENCES.ceremony_number,
			    NEW_REFERENCES.award_course_cd,
			    NEW_REFERENCES.award_crs_version_number,
			    NEW_REFERENCES.award_cd,
			    NEW_REFERENCES.us_group_number,
			    NEW_REFERENCES.unit_set_cd,
			    NEW_REFERENCES.us_version_number
			 ) THEN
					Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
			check_constraints;
			check_uniqueness;

ELSIF (p_action = 'VALIDATE_UPDATE') THEN
			check_constraints;
			check_uniqueness;
END IF;




  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_ORDER_IN_GROUP in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_GR_AWD_CRM_UT_ST
      where GRD_CAL_TYPE = X_GRD_CAL_TYPE
      and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
      and CEREMONY_NUMBER = X_CEREMONY_NUMBER
      and AWARD_COURSE_CD = X_AWARD_COURSE_CD
      and AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER
      and AWARD_CD = X_AWARD_CD
      and US_GROUP_NUMBER = X_US_GROUP_NUMBER
      and UNIT_SET_CD = X_UNIT_SET_CD
      and US_VERSION_NUMBER = X_US_VERSION_NUMBER;
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
    x_unit_set_cd => X_UNIT_SET_CD,
    x_us_version_number => X_US_VERSION_NUMBER,
    x_order_in_group => X_ORDER_IN_GROUP,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_GR_AWD_CRM_UT_ST (
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    US_GROUP_NUMBER,
    UNIT_SET_CD,
    US_VERSION_NUMBER,
    ORDER_IN_GROUP,
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
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.US_VERSION_NUMBER,
    NEW_REFERENCES.ORDER_IN_GROUP,
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
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_ORDER_IN_GROUP in NUMBER
) AS
  cursor c1 is select
      ORDER_IN_GROUP
    from IGS_GR_AWD_CRM_UT_ST
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

  if ( (tlinfo.ORDER_IN_GROUP = X_ORDER_IN_GROUP)
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
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_ORDER_IN_GROUP in NUMBER,
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
    x_unit_set_cd => X_UNIT_SET_CD,
    x_us_version_number => X_US_VERSION_NUMBER,
    x_order_in_group => X_ORDER_IN_GROUP,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_AWD_CRM_UT_ST set
    ORDER_IN_GROUP = NEW_REFERENCES.ORDER_IN_GROUP,
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
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_ORDER_IN_GROUP in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_GR_AWD_CRM_UT_ST
     where GRD_CAL_TYPE = X_GRD_CAL_TYPE
     and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
     and CEREMONY_NUMBER = X_CEREMONY_NUMBER
     and AWARD_COURSE_CD = X_AWARD_COURSE_CD
     and AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER
     and AWARD_CD = X_AWARD_CD
     and US_GROUP_NUMBER = X_US_GROUP_NUMBER
     and UNIT_SET_CD = X_UNIT_SET_CD
     and US_VERSION_NUMBER = X_US_VERSION_NUMBER
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
     X_UNIT_SET_CD,
     X_US_VERSION_NUMBER,
     X_ORDER_IN_GROUP,
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
   X_UNIT_SET_CD,
   X_US_VERSION_NUMBER,
   X_ORDER_IN_GROUP,
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

  delete from IGS_GR_AWD_CRM_UT_ST
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

FUNCTION Get_UK_For_Validation (
		  X_grd_cal_type IN VARCHAR2,
              X_grd_ci_sequence_number IN NUMBER,
              X_ceremony_number IN NUMBER,
              X_award_course_cd IN VARCHAR2,
              X_award_crs_version_number IN NUMBER,
              X_award_cd IN VARCHAR2,
              X_us_group_number IN NUMBER,
              X_order_in_group IN NUMBER
    ) RETURN BOOLEAN AS
 CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRM_UT_ST
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd
      AND      us_group_number = x_us_group_number
      AND	   order_in_group = X_order_in_group
	AND	   (l_rowid IS NULL or ROWID <> l_rowid)
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
	ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE' then
	    new_references.grd_ci_sequence_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'US_GROUP_NUMBER' then
	    new_references. us_group_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'US_VERSION_NUMBER' then
	    new_references.us_version_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'ORDER_IN_GROUP' then
	    new_references.order_in_group := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'AWARD_CD' then
	    new_references.award_cd:= column_value;
	ELSIF upper(Column_name) = 'AWARD_COURSE_CD' then
	    new_references.award_course_cd:= column_value;
	ELSIF upper(Column_name) = 'GRD_CAL_TYPE' then
	    new_references.grd_cal_type:= column_value;
	ELSIF upper(Column_name) = 'UNIT_SET_CD' then
	    new_references.unit_set_cd:= column_value;
END IF;


IF upper(Column_name) = 'GRD_CI_SEQUENCE'  OR column_name IS NULL then
	IF new_references.grd_ci_sequence_number < 1 AND
      	   new_references.grd_ci_sequence_number > 999999 THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
END IF;

IF upper(Column_name) = 'US_GROUP_NUMBER' OR column_name IS NULL then
	IF new_references.us_group_number < 0 AND
	   new_references.us_group_number > 999999 THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
END IF;

IF upper(Column_name) = 'US_VERSION_NUMBER'  OR column_name IS NULL then
	IF new_references.us_version_number < 0 AND
	   new_references.us_version_number > 999 THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
END IF;

IF upper(Column_name) = 'ORDER_IN_GROUP'  OR column_name IS NULL then
	IF new_references.order_in_group < 0 AND
	   new_references.order_in_group > 999 THEN
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
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	 END IF;
END IF;

IF upper(Column_name) = 'UNIT_SET_CD' OR column_name IS NULL then
	 IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	 END IF;
END IF;

END Check_Constraints;

end IGS_GR_AWD_CRM_UT_ST_PKG;

/
