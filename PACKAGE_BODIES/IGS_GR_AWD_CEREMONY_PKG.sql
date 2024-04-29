--------------------------------------------------------
--  DDL for Package Body IGS_GR_AWD_CEREMONY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_AWD_CEREMONY_PKG" as
/* $Header: IGSGI02B.pls 115.14 2004/01/21 06:44:00 nalkumar ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_AWD_CEREMONY_ALL%RowType;
  new_references IGS_GR_AWD_CEREMONY_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_AWC_ID in NUMBER DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_order_in_ceremony IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    X_ORG_ID in NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_AWD_CEREMONY_ALL
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
    new_references.AWC_ID := x_AWC_ID;
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.ceremony_number := x_ceremony_number;
    new_references.award_course_cd := x_award_course_cd;
    new_references.award_crs_version_number := x_award_crs_version_number;
    new_references.award_cd := x_award_cd;
    new_references.order_in_ceremony := x_order_in_ceremony;
    new_references.closed_ind := x_closed_ind;
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

  -- Trigger description :-
  -- "OSS_TST".trg_awc_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_AWD_CEREMONY_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name VARCHAR2(30);
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
	-- Validate the award is not closed
	IF p_inserting OR (p_updating AND new_references.award_cd <> old_references.award_cd) THEN
		IF IGS_GR_VAL_AWC.crsp_val_aw_closed(
				new_references.award_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
 			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate award is of the correct system award type
	IF p_inserting OR p_updating THEN
		IF new_references.award_course_cd IS NOT NULL THEN
			IF IGS_GR_VAL_AWC.grdp_val_award_type(
					new_references.award_cd,
					'COURSE',
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
 				App_Exception.Raise_Exception;
			END IF;
		ELSE
			IF IGS_GR_VAL_AWC.grdp_val_award_type(
					new_references.award_cd,
					'HONORARY',
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
 				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_awc_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_GR_AWD_CEREMONY_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE) AS

    v_message_name	VARCHAR2(30);
    v_rowid_saved	BOOLEAN := FALSE;

    CURSOR c_awc IS
      SELECT  'X'
      FROM  IGS_GR_AWD_CEREMONY awc
      WHERE awc.grd_cal_type       = NEW_REFERENCES.grd_cal_type           AND
        awc.grd_ci_sequence_number = NEW_REFERENCES.grd_ci_sequence_number AND
        awc.ceremony_number        = NEW_REFERENCES.ceremony_number        AND
        awc.order_in_ceremony      = NEW_REFERENCES.order_in_ceremony      AND
        awc.award_cd              <> NEW_REFERENCES.award_cd               AND
				awc.awc_id                <> NVL(NEW_REFERENCES.awc_id,-1);
    v_awc_exists    VARCHAR2(1);

  BEGIN
	IF p_inserting OR (p_updating AND
	   (new_references.order_in_ceremony <> old_references.order_in_ceremony OR
	   (new_references.closed_ind <> old_references.closed_ind AND new_references.closed_ind = 'N'))) THEN

        -- validate award ceremony order in ceremony
        IF IGS_GR_VAL_AWC.grdp_val_awc_order(
            NEW_REFERENCES.grd_cal_type,
            NEW_REFERENCES.grd_ci_sequence_number,
            NEW_REFERENCES.ceremony_number,
            NEW_REFERENCES.award_course_cd,
            NEW_REFERENCES.award_crs_version_number,
            NEW_REFERENCES.award_cd,
            NEW_REFERENCES.order_in_ceremony,
            v_message_name) = FALSE THEN
					IF NVL(v_message_name, 'NULL') = 'IGS_GR_MUST_BE_SAME_AWRD_CD' THEN
					  OPEN c_awc;
						FETCH c_awc INTO v_awc_exists;
						IF c_awc%FOUND THEN
						  CLOSE c_awc;
              FND_MESSAGE.SET_NAME('IGS', v_message_name);
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
						END IF;
						CLOSE c_awc;
					END IF;
        END IF;
    v_rowid_saved := TRUE;
  END IF;


  END AfterRowInsertUpdate2;

 PROCEDURE before_insert_update(p_inserting IN BOOLEAN DEFAULT FALSE,
                                p_updating  IN BOOLEAN DEFAULT FALSE ) AS
   CURSOR c_closed_ind (cp_c_award_cd IN IGS_PS_AWARD.AWARD_CD%TYPE,
                        cp_c_course_cd IN IGS_PS_AWARD.COURSE_CD%TYPE,
                        cp_n_version_num IN IGS_PS_AWARD.VERSION_NUMBER%TYPE) IS
     SELECT CLOSED_IND
     FROM IGS_PS_AWARD
     WHERE AWARD_CD = cp_c_award_cd
     AND   COURSE_CD = cp_c_course_cd
     AND   VERSION_NUMBER = cp_n_version_num;
     l_c_closed_ind VARCHAR2(1);
  BEGIN
     IF p_inserting OR ( p_updating AND new_references.award_cd <> old_references.award_cd ) THEN
        OPEN c_closed_ind(new_references.award_cd,new_references.award_course_cd, new_references.award_crs_version_number);
        FETCH c_closed_ind INTO l_c_closed_ind;
        CLOSE c_closed_ind;
        IF l_c_closed_ind = 'Y' THEN
           fnd_message.set_name('IGS','IGS_PS_AWD_CD_CLOSED');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
     END IF;
  END before_insert_update;

PROCEDURE Check_Uniqueness AS
    BEGIN

	IF Get_UK_For_Validation (
        	NEW_REFERENCES.grd_cal_type,
	        NEW_REFERENCES.grd_ci_sequence_number,
        	NEW_REFERENCES.ceremony_number,
	        NEW_REFERENCES.award_course_cd,
        	NEW_REFERENCES.Award_crs_version_number,
	        NEW_REFERENCES.award_cd
	    ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END Check_Uniqueness;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWD_PKG.Get_PK_For_Validation (new_references.award_cd ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
    	END IF;
    END IF;

    IF (((old_references.award_course_cd = new_references.award_course_cd) AND
         (old_references.award_crs_version_number = new_references.award_crs_version_number) AND
         (old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_course_cd IS NULL) OR
         (new_references.award_crs_version_number IS NULL) OR
         (new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWARD_PKG.Get_PK_For_Validation (
        new_references.award_course_cd,
        new_references.award_crs_version_number,
        new_references.award_cd
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
    END IF;
    END IF;
    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number) AND
         (old_references.ceremony_number = new_references.ceremony_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL) OR
         (new_references.ceremony_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_CRMN_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number,
        new_references.ceremony_number
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
     END IF;
   END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_GR_AWD_CRM_US_GP_PKG.GET_UFK_IGS_GR_AWD_CEREMONY (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number,
      old_references.award_course_cd,
      old_references.award_crs_version_number,
      old_references.award_cd
      );

    IGS_GR_AWD_CRMN_PKG.GET_UFK_IGS_GR_AWD_CEREMONY (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number,
      old_references.award_course_cd,
      old_references.award_crs_version_number,
      old_references.award_cd
      );

  END Check_Child_Existance;

  PROCEDURE Check_UK_Child_Existance AS
  BEGIN

    IF (((old_references.GRD_CAL_TYPE = new_references.GRD_CAL_TYPE) AND
         (old_references.GRD_CI_SEQUENCE_NUMBER = new_references.GRD_CI_SEQUENCE_NUMBER) AND
	 (old_references.CEREMONY_NUMBER = new_references.CEREMONY_NUMBER) AND
         (old_references.AWARD_COURSE_CD = new_references.AWARD_COURSE_CD) AND
         (old_references.AWARD_CD = new_references.AWARD_CD) AND
	 (old_references.AWARD_CRS_VERSION_NUMBER = new_references.AWARD_CRS_VERSION_NUMBER)) OR
	((old_references.GRD_CAL_TYPE IS NULL) AND
         (old_references.GRD_CI_SEQUENCE_NUMBER IS NULL) AND
	 (old_references.CEREMONY_NUMBER IS NULL) AND
         (old_references.AWARD_COURSE_CD IS NULL) AND
         (old_references.AWARD_CD IS NULL) AND
	 (old_references.AWARD_CRS_VERSION_NUMBER IS NULL))) THEN
      NULL;
    ELSE
    IGS_GR_AWD_CRM_US_GP_PKG.GET_UFK_IGS_GR_AWD_CEREMONY (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number,
      old_references.award_course_cd,
      old_references.award_crs_version_number,
      old_references.award_cd
      );

    IGS_GR_AWD_CRMN_PKG.GET_UFK_IGS_GR_AWD_CEREMONY (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number,
      old_references.ceremony_number,
      old_references.award_course_cd,
      old_references.award_crs_version_number,
      old_references.award_cd
      );
    END IF;
END Check_UK_Child_Existance;

  FUNCTION Get_PK_For_Validation (
        x_AWC_ID IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CEREMONY_ALL
      WHERE    AWC_ID = x_AWC_ID
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

  FUNCTION Get_UK_For_Validation (
        x_grd_cal_type IN VARCHAR2,
        x_grd_ci_sequence_number IN NUMBER,
        x_ceremony_number IN NUMBER,
        x_award_course_cd IN VARCHAR2,
        x_award_crs_version_number IN NUMBER,
        x_award_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CEREMONY_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND	ceremony_number = x_ceremony_number
      AND	award_course_cd = x_award_course_cd
      AND	award_crs_version_number = x_award_crs_version_number
      AND	award_cd = x_award_cd
	  AND (l_rowid is null or rowid <> l_rowid )
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
  END Get_UK_For_Validation;

  PROCEDURE GET_FK_IGS_GR_CRMN (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CEREMONY_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number
      AND      ceremony_number = x_ceremony_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_AWC_GC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_CRMN;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_AWC_ID IN NUMBER DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_order_in_ceremony IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_AWC_ID,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_ceremony_number,
      x_award_course_cd,
      x_award_crs_version_number,
      x_award_cd,
      x_order_in_ceremony,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      before_insert_update( p_inserting => TRUE , p_updating => FALSE);
      IF GET_PK_FOR_VALIDATION(NEW_REFERENCES.AWC_ID) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	check_constraints;
	Check_Parent_Existance;
	check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 (p_inserting =>FALSE, p_updating => TRUE );
      before_insert_update( p_updating => TRUE );
	Check_Uniqueness;
	Check_constraints;
      Check_Parent_Existance;
      Check_UK_Child_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
	check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(NEW_REFERENCES.AWC_ID) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	check_uniqueness;
	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	check_uniqueness;
	check_constraints;
        Check_UK_Child_Existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	check_child_existance;
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
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );
    END IF;

    l_rowid := NULL;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWC_ID in out NOCOPY NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_AWD_CEREMONY_ALL
      where AWC_ID = X_AWC_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin

  SELECT IGS_GR_AWD_CEREMONY_AWC_ID_S.NEXTVAL INTO X_AWC_ID FROM DUAL;

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
    x_AWC_ID => X_AWC_ID,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_order_in_ceremony => X_ORDER_IN_CEREMONY,
    x_closed_ind => NVL(X_CLOSED_IND, 'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_GR_AWD_CEREMONY_ALL (
    AWC_ID,
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    ORDER_IN_CEREMONY,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.AWC_ID,
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CEREMONY_NUMBER,
    NEW_REFERENCES.AWARD_COURSE_CD,
    NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.ORDER_IN_CEREMONY,
    NEW_REFERENCES.CLOSED_IND,
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

  After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
    );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_AWC_ID in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      GRD_CAL_TYPE,
      GRD_CI_SEQUENCE_NUMBER,
      CEREMONY_NUMBER,
      AWARD_COURSE_CD,
      AWARD_CRS_VERSION_NUMBER,
      AWARD_CD,
      ORDER_IN_CEREMONY,
      CLOSED_IND
    from IGS_GR_AWD_CEREMONY_ALL
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

  if ( (tlinfo.GRD_CAL_TYPE = X_GRD_CAL_TYPE)
      AND (tlinfo.GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER)
      AND (tlinfo.CEREMONY_NUMBER = X_CEREMONY_NUMBER)
      AND ((tlinfo.AWARD_COURSE_CD = X_AWARD_COURSE_CD)
           OR ((tlinfo.AWARD_COURSE_CD is null)
               AND (X_AWARD_COURSE_CD is null)))
      AND ((tlinfo.AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER)
           OR ((tlinfo.AWARD_CRS_VERSION_NUMBER is null)
               AND (X_AWARD_CRS_VERSION_NUMBER is null)))
      AND (tlinfo.AWARD_CD = X_AWARD_CD)
      AND (tlinfo.ORDER_IN_CEREMONY = X_ORDER_IN_CEREMONY)
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
  X_AWC_ID in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
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
    x_AWC_ID => X_AWC_ID,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_order_in_ceremony => X_ORDER_IN_CEREMONY,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_AWD_CEREMONY_ALL set
    GRD_CAL_TYPE = NEW_REFERENCES.GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER = NEW_REFERENCES.CEREMONY_NUMBER,
    AWARD_COURSE_CD = NEW_REFERENCES.AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER = NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    AWARD_CD = NEW_REFERENCES.AWARD_CD,
    ORDER_IN_CEREMONY = NEW_REFERENCES.ORDER_IN_CEREMONY,
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
  X_AWC_ID in out NOCOPY NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_AWD_CEREMONY_ALL
     where AWC_ID = X_AWC_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_AWC_ID,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_CEREMONY_NUMBER,
     X_AWARD_COURSE_CD,
     X_AWARD_CRS_VERSION_NUMBER,
     X_AWARD_CD,
     X_ORDER_IN_CEREMONY,
     X_CLOSED_IND,
     X_MODE,
     x_org_id);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_AWC_ID,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_CEREMONY_NUMBER,
   X_AWARD_COURSE_CD,
   X_AWARD_CRS_VERSION_NUMBER,
   X_AWARD_CD,
   X_ORDER_IN_CEREMONY,
   X_CLOSED_IND,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

 Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );

  delete from IGS_GR_AWD_CEREMONY_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN
	IF column_name is NULL THEN
	    NULL;
	ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' then
	    new_references.grd_ci_sequence_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'CLOSED_IND' then
	    new_references. closed_ind := column_value;
	ELSIF upper(Column_name) = 'AWARD_CD' then
	    new_references.award_cd := column_value;
	ELSIF upper(Column_name) = 'AWARD_COURSE_CD' then
	    new_references.award_course_cd := column_value;
	ELSIF upper(Column_name) = 'GRD_CAL_TYPE' then
	    new_references.grd_cal_type := column_value;
	ELSIF upper(Column_name) = 'ORDER_IN_CEREMONY' then
	    new_references.order_in_ceremony := IGS_GE_NUMBER.to_num(column_value);
	END IF;

	IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
		IF new_references.grd_ci_sequence_number < 1 OR
		   new_references.grd_ci_sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
		IF new_references.closed_ind NOT IN ( 'Y' , 'N' ) THEN
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

	IF upper(Column_name) = 'AWARD_COURSE_CD' OR COLUMN_NAME IS NULL  then
		IF new_references.award_course_cd <> UPPER(new_references.award_course_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'GRD_CAL_TYPE' OR COLUMN_NAME IS NULL  then
		IF  new_references.grd_cal_type  <> UPPER(new_references.grd_cal_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_name) = 'ORDER_IN_CEREMONY' OR COLUMN_NAME IS NULL  then
		IF  new_references.order_in_ceremony  < 0 OR
			new_references.order_in_ceremony  > 9999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

END Check_Constraints;

END igs_gr_awd_ceremony_pkg;

/
