--------------------------------------------------------
--  DDL for Package Body IGS_PS_OFR_UNIT_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_OFR_UNIT_SET_PKG" AS
 /* $Header: IGSPI26B.pls 120.1 2006/05/29 07:39:18 sarakshi noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_OFR_UNIT_SET%RowType;
  new_references IGS_PS_OFR_UNIT_SET%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
    x_only_as_sub_ind IN VARCHAR2 DEFAULT NULL,
    x_show_on_official_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_OFR_UNIT_SET
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.course_cd := x_course_cd;
    new_references.crv_version_number := x_crv_version_number;
    new_references.cal_type := x_cal_type;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.override_title := x_override_title;
    new_references.only_as_sub_ind := x_only_as_sub_ind;
    new_references.show_on_official_ntfctn_ind := x_show_on_official_ntfctn_ind;
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
  -- "OSS_TST".trg_cous_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PS_OFR_UNIT_SET
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts
	IF  p_inserting THEN
		-- <cous1>
		-- Can only create against ACTIVE or PLANNED IGS_PS_COURSE versions
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl (
						new_references.course_cd,
						new_references.crv_version_number,
						v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		-- <cous2>
		-- Can only create against ACTIVE or PLANNED IGS_PS_UNIT sets
		IF  IGS_PS_VAL_COUSR.crsp_val_iud_us_dtl (
						new_references.unit_set_cd,
						new_references.us_version_number,
						v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
		-- <cous3>
		-- Can only link to courses which do not breach the IGS_PS_COURSE type restrictions
		IF  IGS_PS_VAL_COus.crsp_val_cous_usctv (
						new_references.course_cd,
						new_references.crv_version_number,
						new_references.unit_set_cd,
						new_references.us_version_number,
						v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		-- <cous5>, <cous6>
		-- Validate the 'only as subordinate indicator'
		IF  IGS_PS_VAL_COus.crsp_val_cous_subind (
						new_references.course_cd,
						new_references.crv_version_number,
						new_references.cal_type,
						new_references.unit_set_cd,
						new_references.us_version_number,
						old_references.only_as_sub_ind,
						new_references.only_as_sub_ind,
						v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	)
  AS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'ONLY_AS_SUB_IND' THEN
	   new_references.only_as_sub_ind := column_value;
	ELSIF upper(column_name) = 'SHOW_ON_OFFICIAL_NTFCTN_IND' THEN
	   new_references.show_on_official_ntfctn_ind := column_value;
	ELSIF upper(column_name) = 'CAL_TYPE' THEN
	   new_references.cal_type:= column_value;
	ELSIF upper(column_name) = 'COURSE_CD' THEN
	   new_references.course_cd := column_value;
	ELSIF upper(column_name) = 'UNIT_SET_CD' THEN
	   new_references.unit_set_cd:= column_value;
	END IF;

	IF upper(column_name)= 'CAL_TYPE' OR
		column_name is null THEN
		IF new_references.cal_type <> UPPER(new_references.cal_type)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_CD' OR
		column_name is null THEN
		IF new_references.course_cd <> UPPER(new_references.course_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'UNIT_SET_CD' OR
		column_name is null THEN
		IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'ONLY_AS_SUB_IND' OR
		column_name is null THEN
		IF new_references.only_as_sub_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'SHOW_ON_OFFICIAL_NTFCTN_IND' OR
		column_name is null THEN
		IF new_references.show_on_official_ntfctn_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number) AND
         (old_references.cal_type = new_references.cal_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL) OR
         (new_references.cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.crv_version_number,
        new_references.cal_type
        )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
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
      IF NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.us_version_number
        )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
   END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  /*************************************************************
  Created By :sarakshi
  Date Created By :27-APR-2006
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  sarakshi  27-APR-2006  Bug#5165619, added child existance for IGS_PS_ENT_PT_REF_CD and IGS_PS_COO_AD_UNIT_S
  ***************************************************************/
  BEGIN

    IGS_PS_OF_OPT_UNT_ST_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.cal_type,
      old_references.unit_set_cd,
      old_references.us_version_number
      );
   IGS_PS_OF_UNT_SET_RL_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
    old_references.course_cd,
    old_references.crv_version_number,
    old_references.cal_type,
    old_references.unit_set_cd,
    old_references.us_version_number
     );

     --Added following child table check for bug#5165619
     --IGS_PS_ENT_PT_REF_CD (program entry point reference codes)
     IGS_PS_ENT_PT_REF_CD_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.cal_type,
      old_references.unit_set_cd,
      old_references.us_version_number
      );


     --IGS_PS_COO_AD_UNIT_S (Program Offering option admission categories)
     IGS_PS_COO_AD_UNIT_S_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.cal_type,
      old_references.unit_set_cd,
      old_references.us_version_number
      );

     --IGS_HE_POOUS_ALL
     IGS_HE_POOUS_ALL_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.cal_type,
      old_references.unit_set_cd,
      old_references.us_version_number
      );

     --IGS_HE_POOUS_OU
     IGS_HE_POOUS_OU_ALL_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.cal_type,
      old_references.unit_set_cd,
      old_references.us_version_number
      );

     --IGS_HE_POOUS_OU
     IGS_AS_SU_SETATMPT_PKG.GET_FK_IGS_PS_OFR_UNIT_SET (
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.cal_type,
      old_references.unit_set_cd,
      old_references.us_version_number
      );



  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_UNIT_SET
      WHERE    course_cd = x_course_cd
      AND      crv_version_number = x_crv_version_number
      AND      cal_type = x_cal_type
      AND      unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_us_version_number
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

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_UNIT_SET
      WHERE    course_cd = x_course_cd
      AND      crv_version_number = x_version_number
      AND      cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COUS_CO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_UNIT_SET
      WHERE    unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COUS_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
    x_only_as_sub_ind IN VARCHAR2 DEFAULT NULL,
    x_show_on_official_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
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
      x_crv_version_number,
      x_cal_type,
      x_unit_set_cd,
      x_us_version_number,
      x_override_title,
      x_only_as_sub_ind,
      x_show_on_official_ntfctn_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.crv_version_number ,
    		new_references.cal_type ,
    		new_references.unit_set_cd ,
    		new_references.us_version_number
	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
	BeforeRowInsertUpdate1 ( p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.crv_version_number ,
    		new_references.cal_type ,
    		new_references.unit_set_cd ,
    		new_references.us_version_number
	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_ONLY_AS_SUB_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_OFR_UNIT_SET
      where COURSE_CD = X_COURSE_CD
      and CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
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
    x_course_cd => X_COURSE_CD,
    x_crv_version_number => X_CRV_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_unit_set_cd => X_UNIT_SET_CD,
    x_us_version_number => X_US_VERSION_NUMBER,
    x_override_title => X_OVERRIDE_TITLE,
    x_only_as_sub_ind => NVL(X_ONLY_AS_SUB_IND,'N'),
    x_show_on_official_ntfctn_ind => NVL(X_SHOW_ON_OFFICIAL_NTFCTN_IND,'Y'),
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_OFR_UNIT_SET (
    COURSE_CD,
    CRV_VERSION_NUMBER,
    CAL_TYPE,
    UNIT_SET_CD,
    US_VERSION_NUMBER,
    OVERRIDE_TITLE,
    ONLY_AS_SUB_IND,
    SHOW_ON_OFFICIAL_NTFCTN_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.CRV_VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.US_VERSION_NUMBER,
    NEW_REFERENCES.OVERRIDE_TITLE,
    NEW_REFERENCES.ONLY_AS_SUB_IND,
    NEW_REFERENCES.SHOW_ON_OFFICIAL_NTFCTN_IND,
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
After_DML (
	p_action => 'INSERT',
	x_rowid => X_ROWID
);
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_ONLY_AS_SUB_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2
) AS
  cursor c1 is select
      OVERRIDE_TITLE,
      ONLY_AS_SUB_IND,
      SHOW_ON_OFFICIAL_NTFCTN_IND
    from IGS_PS_OFR_UNIT_SET
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

      if ( ((tlinfo.OVERRIDE_TITLE = X_OVERRIDE_TITLE)
           OR ((tlinfo.OVERRIDE_TITLE is null)
               AND (X_OVERRIDE_TITLE is null)))
      AND (tlinfo.ONLY_AS_SUB_IND = X_ONLY_AS_SUB_IND)
      AND (tlinfo.SHOW_ON_OFFICIAL_NTFCTN_IND = X_SHOW_ON_OFFICIAL_NTFCTN_IND)
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
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_ONLY_AS_SUB_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
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
    x_course_cd => X_COURSE_CD,
    x_crv_version_number => X_CRV_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_unit_set_cd => X_UNIT_SET_CD,
    x_us_version_number => X_US_VERSION_NUMBER,
    x_override_title => X_OVERRIDE_TITLE,
    x_only_as_sub_ind => X_ONLY_AS_SUB_IND,
    x_show_on_official_ntfctn_ind => X_SHOW_ON_OFFICIAL_NTFCTN_IND ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );
  update IGS_PS_OFR_UNIT_SET set
    OVERRIDE_TITLE = NEW_REFERENCES.OVERRIDE_TITLE,
    ONLY_AS_SUB_IND = NEW_REFERENCES.ONLY_AS_SUB_IND,
    SHOW_ON_OFFICIAL_NTFCTN_IND = NEW_REFERENCES.SHOW_ON_OFFICIAL_NTFCTN_IND,
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
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_ONLY_AS_SUB_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_OFR_UNIT_SET
     where COURSE_CD = X_COURSE_CD
     and CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER
     and CAL_TYPE = X_CAL_TYPE
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
     X_COURSE_CD,
     X_CRV_VERSION_NUMBER,
     X_CAL_TYPE,
     X_UNIT_SET_CD,
     X_US_VERSION_NUMBER,
     X_OVERRIDE_TITLE,
     X_ONLY_AS_SUB_IND,
     X_SHOW_ON_OFFICIAL_NTFCTN_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_CRV_VERSION_NUMBER,
   X_CAL_TYPE,
   X_UNIT_SET_CD,
   X_US_VERSION_NUMBER,
   X_OVERRIDE_TITLE,
   X_ONLY_AS_SUB_IND,
   X_SHOW_ON_OFFICIAL_NTFCTN_IND,
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
  delete from IGS_PS_OFR_UNIT_SET
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_OFR_UNIT_SET_PKG;

/
