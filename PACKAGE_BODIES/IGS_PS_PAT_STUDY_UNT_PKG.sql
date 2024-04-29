--------------------------------------------------------
--  DDL for Package Body IGS_PS_PAT_STUDY_UNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_PAT_STUDY_UNT_PKG" as
/* $Header: IGSPI63B.pls 120.0 2005/06/01 20:09:40 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_PAT_STUDY_UNT%RowType;
  new_references IGS_PS_PAT_STUDY_UNT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2  ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_pos_sequence_number IN NUMBER ,
    x_posp_sequence_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_unit_cd IN VARCHAR2 ,
    x_unit_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    X_CORE_IND IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_PAT_STUDY_UNT
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
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.pos_sequence_number := x_pos_sequence_number;
    new_references.posp_sequence_number := x_posp_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.unit_location_cd := x_unit_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.description := x_description;
	new_references.core_ind := x_core_ind;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate the insert/update/delete
	IF p_inserting OR p_updating THEN
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				new_references.course_cd,
				new_references.version_number,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	ELSE
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				old_references.course_cd,
				old_references.version_number,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the insert/update
	IF p_inserting OR p_updating THEN
		-- Validate the UnitCode
		IF (new_references.unit_cd IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.unit_cd <> old_references.unit_cd))) THEN
			IF IGS_PS_VAL_POSu.crsp_val_uv_active (
					new_references.unit_cd,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the IGS_PS_UNIT IGS_AD_LOCATION Code
		IF (new_references.unit_location_cd IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.unit_location_cd <> old_references.unit_location_cd))) THEN

		   -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_POSu.crsp_val_loc_cd
			IF IGS_PS_VAL_UOO.crsp_val_loc_cd (
					new_references.unit_location_cd,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the IGS_PS_UNIT Class
		IF (new_references.unit_class IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.unit_class<> old_references.unit_class))) THEN
		   -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_POSu.crsp_val_ucl_closed
			IF IGS_AS_VAL_UAI.crsp_val_ucl_closed (
					new_references.unit_class,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the record has the required data
		IF IGS_PS_VAL_POSu.crsp_val_posu_rqrd (
				new_references.unit_cd,
				new_references.unit_location_cd,
				new_references.unit_class,
				new_references.description,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
	cst_error		VARCHAR2(1);
      v_return_type	VARCHAR2(1);
  BEGIN
	cst_error := 'E';
	-- Validate the pattern of study record
	IF IGS_PS_VAL_POSu.crsp_val_posu_iu(
  				new_references.course_cd,
  				new_references.version_number,
  				new_references.cal_type,
  				new_references.pos_sequence_number,
  				new_references.posp_sequence_number,
  				new_references.sequence_number,
  				new_references.unit_cd,
  				v_return_type,
  				v_message_name,
				new_references.unit_location_cd,
				new_references.unit_class) = FALSE THEN
  			IF v_return_type = cst_error THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
  			END IF;
  	END IF;

  END AfterRowInsertUpdate2;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
 )
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'POS_SEQUENCE_NUMBER' then
     new_references.pos_sequence_number :=IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
     new_references.sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'POSP_SEQUENCE_NUMBER' then
     new_references.posp_sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'VERSION_NUMBER' then
     new_references.version_number :=IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_CLASS' then
     new_references.unit_class := column_value;
 ELSIF upper(Column_name) = 'UNIT_LOCATION_CD' then
     new_references.unit_location_cd := column_value;
 ELSIF upper(Column_name) = 'CORE_IND' then
     new_references.core_ind := column_value;
 END IF;

IF upper(column_name) = 'POS_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.pos_sequence_number < 0 OR new_references.pos_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.sequence_number < 0 OR new_references.sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'POSP_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.posp_sequence_number < 0 OR new_references.posp_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'VERSION_NUMBER' OR
     column_name is null Then
     IF new_references.version_number < 0 OR new_references.version_number > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.cal_type <> UPPER(new_references.cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UNIT_CLASS' OR
     column_name is null Then
     IF new_references.unit_class <> UPPER(new_references.unit_class) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UNIT_LOCATION_CD' OR
     column_name is null Then
     IF new_references.unit_location_cd <> UPPER(new_references.unit_location_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CORE_IND' OR
     column_name is null Then
     IF new_references.core_ind NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

END check_constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.unit_location_cd = new_references.unit_location_cd)) OR
        ((new_references.unit_location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.unit_location_cd ,
        'N'
        ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.pos_sequence_number = new_references.pos_sequence_number) AND
         (old_references.posp_sequence_number = new_references.posp_sequence_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.pos_sequence_number IS NULL) OR
         (new_references.posp_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_PAT_STUDY_PRD_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.pos_sequence_number,
        new_references.posp_sequence_number
        ) THEN
		   Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		   IGS_GE_MSG_STACK.ADD;
		   App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_UNIT_CLASS_PKG.Get_PK_For_Validation (
        new_references.unit_class
        ) THEN
    		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
    		IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd)) OR
        ((new_references.unit_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_PKG.Get_PK_For_Validation (
        new_references.unit_cd
        ) THEN
    		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
    		IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_pos_sequence_number IN NUMBER,
    x_posp_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_STUDY_UNT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      pos_sequence_number = x_pos_sequence_number
      AND      posp_sequence_number = x_posp_sequence_number
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_STUDY_UNT
      WHERE    unit_location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POSU_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_PS_PAT_STUDY_PRD (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_pos_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_STUDY_UNT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      pos_sequence_number = x_pos_sequence_number
      AND      posp_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POSU_POSP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_PAT_STUDY_PRD;

  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_STUDY_UNT
      WHERE    unit_cd = x_unit_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POSU_UN_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_pos_sequence_number IN NUMBER ,
    x_posp_sequence_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_unit_cd IN VARCHAR2 ,
    x_unit_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_core_ind IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_course_cd,
      x_version_number,
      x_cal_type,
      x_pos_sequence_number,
      x_posp_sequence_number,
      x_sequence_number,
      x_unit_cd,
      x_unit_location_cd,
      x_unit_class,
      x_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
	  x_core_ind
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
	                                 p_updating => FALSE,
									 p_deleting => FALSE );
      IF  Get_PK_For_Validation (
		    new_references.course_cd,
		    new_references.version_number,
		    new_references.cal_type,
		    new_references.pos_sequence_number,
		    new_references.posp_sequence_number,
		    new_references.sequence_number
			 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdateDelete1 ( p_updating => TRUE,
	                                  p_inserting => FALSE,
									  p_deleting => FALSE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE,
	                                 p_inserting => FALSE,
									 p_updating => FALSE );
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
		    new_references.course_cd,
		    new_references.version_number,
		    new_references.cal_type,
		    new_references.pos_sequence_number,
		    new_references.posp_sequence_number,
		    new_references.sequence_number
			 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
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
      AfterRowInsertUpdate2 ( p_inserting => TRUE,
	                          p_updating => FALSE,
							  p_deleting => FALSE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE,
	                          p_inserting => FALSE,
							  p_deleting => FALSE );

    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_POSP_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_UNIT_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2,
  X_CORE_IND IN VARCHAR2
  ) as
    cursor C is select ROWID from IGS_PS_PAT_STUDY_UNT
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and POS_SEQUENCE_NUMBER = X_POS_SEQUENCE_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and POSP_SEQUENCE_NUMBER = X_POSP_SEQUENCE_NUMBER
      and CAL_TYPE = X_CAL_TYPE;
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

   Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_pos_sequence_number => X_POS_SEQUENCE_NUMBER,
    x_posp_sequence_number => X_POSP_SEQUENCE_NUMBER,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_unit_cd => X_UNIT_CD,
    x_unit_location_cd => X_UNIT_LOCATION_CD,
    x_unit_class => X_UNIT_CLASS,
    x_description => X_DESCRIPTION,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
	x_core_ind => NVL(X_CORE_IND,'N')
  );
  insert into IGS_PS_PAT_STUDY_UNT (
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    POS_SEQUENCE_NUMBER,
    POSP_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    UNIT_CD,
    UNIT_LOCATION_CD,
    UNIT_CLASS,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
	CORE_IND
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.POS_SEQUENCE_NUMBER,
    NEW_REFERENCES.POSP_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.UNIT_LOCATION_CD,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
	NEW_REFERENCES.CORE_IND
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
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_POSP_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_UNIT_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CORE_IND IN VARCHAR2
) as
  cursor c1 is select
      UNIT_CD,
      UNIT_LOCATION_CD,
      UNIT_CLASS,
      DESCRIPTION,
	  CORE_IND
    from IGS_PS_PAT_STUDY_UNT
    where ROWID = X_ROWID for update nowait;
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

      if ( ((tlinfo.UNIT_CD = X_UNIT_CD)
           OR ((tlinfo.UNIT_CD is null)
               AND (X_UNIT_CD is null)))
      AND ((tlinfo.UNIT_LOCATION_CD = X_UNIT_LOCATION_CD)
           OR ((tlinfo.UNIT_LOCATION_CD is null)
               AND (X_UNIT_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.CORE_IND = X_CORE_IND)
           OR ((tlinfo.CORE_IND is null)
               AND (X_CORE_IND is null)))
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
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_POSP_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_UNIT_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2,
  X_CORE_IND IN VARCHAR2
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

   Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_pos_sequence_number => X_POS_SEQUENCE_NUMBER,
    x_posp_sequence_number => X_POSP_SEQUENCE_NUMBER,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_unit_cd => X_UNIT_CD,
    x_unit_location_cd => X_UNIT_LOCATION_CD,
    x_unit_class => X_UNIT_CLASS,
    x_description => X_DESCRIPTION,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
	x_core_ind => NVL(X_CORE_IND,'N')
  );

  update IGS_PS_PAT_STUDY_UNT set
    UNIT_CD = NEW_REFERENCES.UNIT_CD,
    UNIT_LOCATION_CD = NEW_REFERENCES.UNIT_LOCATION_CD,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	CORE_IND = new_references.CORE_IND
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_POSP_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_UNIT_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2,
  X_CORE_IND IN VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_PS_PAT_STUDY_UNT
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and POS_SEQUENCE_NUMBER = X_POS_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and POSP_SEQUENCE_NUMBER = X_POSP_SEQUENCE_NUMBER
     and CAL_TYPE = X_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_POS_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_POSP_SEQUENCE_NUMBER,
     X_CAL_TYPE,
     X_UNIT_CD,
     X_UNIT_LOCATION_CD,
     X_UNIT_CLASS,
     X_DESCRIPTION,
     X_MODE,
	 X_CORE_IND);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_POS_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_POSP_SEQUENCE_NUMBER,
   X_CAL_TYPE,
   X_UNIT_CD,
   X_UNIT_LOCATION_CD,
   X_UNIT_CLASS,
   X_DESCRIPTION,
   X_MODE,
   X_CORE_IND);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
   Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PS_PAT_STUDY_UNT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_PAT_STUDY_UNT_PKG;

/
