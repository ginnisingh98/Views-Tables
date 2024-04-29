--------------------------------------------------------
--  DDL for Package Body IGS_PS_OFR_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_OFR_OPT_PKG" AS
/* $Header: IGSPI23B.pls 120.0 2005/06/01 14:01:40 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_OFR_OPT_ALL%RowType;
  new_references IGS_PS_OFR_OPT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_coo_id IN NUMBER ,
    x_forced_location_ind IN VARCHAR2 ,
    x_forced_att_mode_ind IN VARCHAR2 ,
    x_forced_att_type_ind IN VARCHAR2 ,
    x_time_limitation IN NUMBER ,
    x_enr_officer_person_id IN NUMBER ,
    x_attribute_category in VARCHAR2 ,
    x_attribute1 in VARCHAR2 ,
    x_attribute2 in VARCHAR2 ,
    x_attribute3 in VARCHAR2 ,
    x_attribute4 in VARCHAR2 ,
    x_attribute5 in VARCHAR2 ,
    x_attribute6 in VARCHAR2 ,
    x_attribute7 in VARCHAR2 ,
    x_attribute8 in VARCHAR2 ,
    x_attribute9 in VARCHAR2 ,
    x_attribute10 in VARCHAR2 ,
    x_attribute11 in VARCHAR2 ,
    x_attribute12 in VARCHAR2 ,
    x_attribute13 in VARCHAR2 ,
    x_attribute14 in VARCHAR2 ,
    x_attribute15 in VARCHAR2 ,
    x_attribute16 in VARCHAR2 ,
    x_attribute17 in VARCHAR2 ,
    x_attribute18 in VARCHAR2 ,
    x_attribute19 in VARCHAR2 ,
    x_attribute20 in VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER  ,
    x_org_id IN NUMBER ,
    x_program_length IN NUMBER ,
    x_program_length_measurement IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_OFR_OPT_ALL
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
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.coo_id := x_coo_id;
    new_references.forced_location_ind := x_forced_location_ind;
    new_references.forced_att_mode_ind := x_forced_att_mode_ind;
    new_references.forced_att_type_ind := x_forced_att_type_ind;
    new_references.time_limitation := x_time_limitation;
    new_references.enr_officer_person_id := x_enr_officer_person_id;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.org_id := x_org_id;
    new_references.program_length := x_program_length;
    new_references.program_length_measurement := x_program_length_measurement;


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
  -- "OSS_TST".TRG_COO_BR_IUD
  -- BEFORE  INSERT  OR UPDATE  OR DELETE  ON IGS_PS_OFR_OPT_ALL
  -- REFERENCING
  --  NEW AS NEW
  --  OLD AS OLD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name		VARCHAR2(30);
	v_course_cd		IGS_PS_VER.course_cd%TYPE;
	v_version_number	IGS_PS_VER.version_number%TYPE;
	v_preferred_name	IGS_PE_PERSON.preferred_given_name%TYPE;
  BEGIN

	-- Set variables
	IF p_inserting OR p_updating THEN
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
	ELSE	-- p_deleting
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
	END IF;
	-- Validate that updates are allowed
	IF IGS_PS_VAL_CRS.CRSP_VAL_IUD_CRV_DTL(v_course_cd,
		v_version_number,
		v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	IF p_inserting THEN
		-- Validate calendar type
		IF IGS_PS_VAL_CO.crsp_val_co_cal_type(
			new_references.cal_type,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		-- Validate IGS_AD_LOCATION code

		-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_COO.crsp_val_loc_cd
		IF IGS_PS_VAL_UOO.crsp_val_loc_cd(
			new_references.location_cd,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		-- Validate attendance mode
		IF IGS_PS_VAL_COo.crsp_val_coo_am (
			new_references.attendance_mode,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		-- Validate attendance type
		IF IGS_PS_VAL_COo.crsp_val_coo_att (
			new_references.attendance_type,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR p_updating THEN
		IF new_references.enr_officer_person_id IS NOT NULL THEN
			-- Validate enrolment officer IGS_PE_PERSON id
			IF IGS_GE_MNT_SDTT.PID_VAL_STAFF (
				new_references.enr_officer_person_id,
				v_preferred_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_NOT_STAFF_MEMBER');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
			END IF;
		END IF;

		-- If program length is provided then program length measurement is also required and vice versa, exception being when
                -- progrma length measuremnt is 'Not Applicable'
                IF (new_references.program_length_measurement IS NULL AND new_references.program_length IS NOT NULL ) OR
                   (new_references.program_length_measurement IS NOT NULL AND new_references.program_length IS NULL
                   AND new_references.program_length_measurement <> 'NOT_APPLICABLE' ) THEN
                   fnd_message.set_name('IGS','IGS_PS_PRG_LENGTH_INCLUSIVE');
                   IGS_GE_MSG_STACK.ADD;
		   App_exception.raise_exception;
                END IF;

	END IF;


  END BeforeRowInsertUpdateDelete1; -- updated by ssawhney on 09/08/2k for TCA changes

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	,
 Column_Value 	IN VARCHAR2
 )
 AS
 BEGIN

	IF column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'FORCED_ATT_TYPE_IND' then
	    new_references.forced_att_type_ind := column_value;
	ELSIF upper(Column_name) = 'TIME_LIMITATION' then
	    new_references.time_limitation := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'FORCED_LOCATION_IND' then
	    new_references.forced_location_ind := column_value;
	ELSIF upper(Column_name) = 'FORCED_ATT_MODE_IND' then
	    new_references.forced_att_mode_ind := column_value;
	ELSIF upper(Column_name) = 'ATTENDANCE_MODE' then
	    new_references.attendance_mode := column_value;
	ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' then
	    new_references.attendance_type := column_value;
	ELSIF upper(Column_name) = 'CAL_TYPE' then
	    new_references.cal_type := column_value;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.course_cd := column_value;
	ELSIF upper(Column_name) = 'LOCATION_CD' then
	    new_references.location_cd := column_value;
	END IF;

    IF upper(column_name) = 'FORCED_ATT_TYPE_IND' OR
    column_name is null Then
	   IF ( new_references.forced_att_type_ind NOT IN ( 'Y' , 'N' ) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'TIME_LIMITATION' OR
    column_name is null Then
	   IF ( new_references.time_limitation < 0.01 OR new_references.time_limitation > 99.99 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'FORCED_LOCATION_IND' OR
    column_name is null Then
	   IF ( new_references.forced_location_ind NOT IN ( 'Y' , 'N' ) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'FORCED_ATT_MODE_IND' OR
    column_name is null Then
	   IF ( new_references.forced_att_mode_ind NOT IN ( 'Y' , 'N' ) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'ATTENDANCE_MODE' OR
    column_name is null Then
	   IF ( new_references.attendance_mode <> UPPER(new_references.attendance_mode) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'ATTENDANCE_TYPE' OR
    column_name is null Then
	   IF ( new_references.attendance_type <> UPPER(new_references.attendance_type) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'CAL_TYPE' OR
    column_name is null Then
	   IF ( new_references.cal_type <> UPPER(new_references.cal_type) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'COURSE_CD' OR
    column_name is null Then
	   IF ( new_references.course_cd <> UPPER(new_references.course_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'LOCATION_CD' OR
    column_name is null Then
	   IF ( new_references.location_cd <> UPPER(new_references.location_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Uniqueness AS
  BEGIN

      IF Get_UK_For_Validation (
      new_references.coo_id ) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
  END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.attendance_mode
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.attendance_type
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd ,
        'N'
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.enr_officer_person_id = new_references.enr_officer_person_id)) OR
        ((new_references.enr_officer_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.enr_officer_person_id
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS

       CURSOR c_hesa IS
       SELECT '1' FROM USER_OBJECTS
       WHERE OBJECT_NAME  = 'IGS_HE_POOUS_ALL_PKG'
       AND   object_type = 'PACKAGE BODY';
       l_hesa  VARCHAR2(1);

  /*
    Who	          When	            	What

  --sbaliga     9-May-2002     Added 2 more calls to check for child existence
                 	       as aprt of #2330002
  --ckasu       04-Dec-2003    Added IGS_EN_SPA_TERMS_PKG.GET_UFK_IGS_PS_OFR_OPT
                               for Term Records Build

  */

  BEGIN

    IGS_PS_ENT_PT_REF_CD_PKG.GET_FK_IGS_PS_OFR_OPT (
    old_references.course_cd,
    old_references.version_number,
    old_references.cal_type,
    old_references.location_cd,
    old_references.attendance_mode,
    old_references.attendance_type
    );

    IGS_PS_ENT_PT_REF_CD_PKG.GET_UFK_IGS_PS_OFR_OPT (
      old_references.coo_id
      );

    IGS_PS_OFR_OPT_NOTE_PKG.GET_FK_IGS_PS_OFR_OPT (
    old_references.course_cd,
    old_references.version_number,
    old_references.cal_type,
    old_references.location_cd,
    old_references.attendance_mode,
    old_references.attendance_type
    );

    IGS_PS_OFR_OPT_NOTE_PKG.GET_UFK_IGS_PS_OFR_OPT (
      old_references.coo_id
      );

    IGS_PS_OFR_PAT_PKG.GET_FK_IGS_PS_OFR_OPT (
    old_references.course_cd,
    old_references.version_number,
    old_references.cal_type,
    old_references.location_cd,
    old_references.attendance_mode,
    old_references.attendance_type
    );


    IGS_PS_OFR_PAT_PKG.GET_UFK_IGS_PS_OFR_OPT (
      old_references.coo_id
      );

    IGS_EN_SPA_TERMS_PKG.GET_UFK_IGS_PS_OFR_OPT (
      old_references.coo_id
      );

   IGS_PS_OF_OPT_AD_CAT_PKG.GET_FK_IGS_PS_OFR_OPT (
    old_references.course_cd,
    old_references.version_number,
    old_references.cal_type,
    old_references.location_cd,
    old_references.attendance_mode,
    old_references.attendance_type
    );

 IGS_PS_OF_OPT_AD_CAT_PKG.GET_UFK_IGS_PS_OFR_OPT (
      old_references.coo_id
      );

  IGS_PS_OF_OPT_UNT_ST_PKG.GET_FK_IGS_PS_OFR_OPT (
    old_references.course_cd,
    old_references.version_number,
    old_references.cal_type,
    old_references.location_cd,
    old_references.attendance_mode,
    old_references.attendance_type
    );


    IGS_PS_OF_OPT_UNT_ST_PKG.GET_UFK_IGS_PS_OFR_OPT (
      old_references.coo_id
      );

    IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_PS_OFR_OPT (
      old_references.course_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.location_cd,
      old_references.attendance_mode,
      old_references.attendance_type
      );

   IGS_EN_STDNT_PS_ATT_PKG.GET_UFK_IGS_PS_OFR_OPT (
	old_references.coo_id
	);


  --This procedure call was added as part of #2330002 by sbaliga
     IGS_HE_POOUS_OU_ALL_PKG.GET_FK_IGS_PS_OFR_OPT_ALL
    ( old_references.course_cd,
       old_references.version_number,
       old_references.cal_type,
       old_references.location_cd,
       old_references.attendance_mode,
       old_references.attendance_type
     );


    -- Added the following check chaild existance for the HESA requirment, pmarada
    OPEN c_hesa;
    FETCH c_hesa INTO l_hesa;
    IF c_hesa%FOUND THEN

    EXECUTE IMMEDIATE
      'BEGIN IGS_HE_POOUS_ALL_PKG.GET_FK_IGS_PS_OFR_OPT_ALL(:1,:2,:3,:4,:5,:6);   END;'
     USING
       old_references.course_cd,
       old_references.version_number,
       old_references.cal_type,
       old_references.location_cd,
       old_references.attendance_mode,
       old_references.attendance_type;
       CLOSE c_hesa;
  ELSE
    CLOSE c_hesa;
  END IF;

  END Check_Child_Existance;


PROCEDURE Check_UK_Child_Existance AS

Begin

	IF (old_references.coo_id = new_references.coo_id) OR (old_references.coo_id IS NULL) THEN
		NULL;
	ELSE
		IGS_PS_ENT_PT_REF_CD_PKG.GET_UFK_IGS_PS_OFR_OPT(old_references.coo_id);
		IGS_PS_OFR_OPT_NOTE_PKG.GET_UFK_IGS_PS_OFR_OPT(old_references.coo_id);
		IGS_PS_OFR_PAT_PKG.GET_UFK_IGS_PS_OFR_OPT(old_references.coo_id);
		IGS_PS_OF_OPT_UNT_ST_PKG.GET_UFK_IGS_PS_OFR_OPT(old_references.coo_id);
		IGS_EN_STDNT_PS_ATT_PKG.GET_UFK_IGS_PS_OFR_OPT(old_references.coo_id);
		IGS_PS_OF_OPT_AD_CAT_PKG.GET_UFK_IGS_PS_OFR_OPT(old_references.coo_id);
	END IF;

END Check_UK_Child_Existance;


  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type
      AND      DELETE_FLAG = 'N';

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
    x_coo_id IN NUMBER
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    coo_id = x_coo_id
      AND ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND  DELETE_FLAG = 'N';

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


  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    attendance_mode = x_attendance_mode
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COO_AM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_MODE;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    attendance_type = x_attendance_type
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COO_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COO_CO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    location_cd = x_location_cd
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COO_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2		--ssawhney
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_ALL
      WHERE    enr_officer_person_id = x_person_id
      AND      delete_flag = 'N';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COO_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_coo_id IN NUMBER ,
    x_forced_location_ind IN VARCHAR2 ,
    x_forced_att_mode_ind IN VARCHAR2 ,
    x_forced_att_type_ind IN VARCHAR2 ,
    x_time_limitation IN NUMBER ,
    x_enr_officer_person_id IN NUMBER ,
    x_attribute_category in VARCHAR2 ,
    x_attribute1 in VARCHAR2 ,
    x_attribute2 in VARCHAR2 ,
    x_attribute3 in VARCHAR2 ,
    x_attribute4 in VARCHAR2 ,
    x_attribute5 in VARCHAR2 ,
    x_attribute6 in VARCHAR2 ,
    x_attribute7 in VARCHAR2 ,
    x_attribute8 in VARCHAR2 ,
    x_attribute9 in VARCHAR2 ,
    x_attribute10 in VARCHAR2 ,
    x_attribute11 in VARCHAR2 ,
    x_attribute12 in VARCHAR2 ,
    x_attribute13 in VARCHAR2 ,
    x_attribute14 in VARCHAR2 ,
    x_attribute15 in VARCHAR2 ,
    x_attribute16 in VARCHAR2 ,
    x_attribute17 in VARCHAR2 ,
    x_attribute18 in VARCHAR2 ,
    x_attribute19 in VARCHAR2 ,
    x_attribute20 in VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_program_length IN NUMBER ,
    x_program_length_measurement IN VARCHAR2 ,
    X_DELETE_FLAG IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_course_cd,
      x_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_coo_id,
      x_forced_location_ind,
      x_forced_att_mode_ind,
      x_forced_att_type_ind,
      x_time_limitation,
      x_enr_officer_person_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
      x_program_length,
      x_program_length_measurement
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE , p_updating => FALSE, p_deleting => FALSE );
	IF Get_PK_For_Validation (
          new_references.course_cd,
          new_references.version_number,
	  new_references.cal_type,
	  new_references.location_cd,
	  new_references.attendance_mode,
	  new_references.attendance_type ) THEN
	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	   IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
	Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE, p_inserting => FALSE, p_deleting=> FALSE );
      Check_Constraints;
      Check_Parent_Existance;
	Check_Uniqueness;
	Check_UK_Child_Existance;
     ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE, p_updating => FALSE, p_inserting => FALSE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.cal_type,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type ) THEN
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
	Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Uniqueness;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;

  PROCEDURE dflt_prg_ofropt_ref_code(
    p_n_coo_id IN igs_ps_ofr_opt.coo_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
    ) AS
  /************************************************************************
  Created By                                : rbezawad
  Date Created By                           : 12/06/2001
  Purpose                                   : Insertion into table IGS_PS_PT_REF_CD for mandatory ref code types and default ref codes
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  *************************************************************************/
    CURSOR c_ofr_opt (cp_coo_id igs_ps_ofr_opt.coo_id%TYPE) IS
      SELECT course_cd,
             version_number,
	     cal_type,
	     location_cd,
	     attendance_type,
	     attendance_mode
      FROM   igs_ps_ofr_opt
      WHERE  coo_id = cp_coo_id;

    l_ofr_opt c_ofr_opt%ROWTYPE;

    CURSOR c_igs_ge_ref_cd_type_all  IS
      SELECT reference_cd_type
      FROM   igs_ge_ref_cd_type_all
      WHERE  mandatory_flag ='Y'
      AND    program_offering_option_flag ='Y'
      AND    restricted_flag='Y'
      AND    closed_ind = 'N';

    CURSOR c_igs_ge_ref_cd ( cp_reference_cd_type igs_ge_ref_cd.reference_cd_type%TYPE ) IS
      SELECT reference_cd,
             description
      FROM   igs_ge_ref_cd
      WHERE  reference_cd_type = cp_reference_cd_type
      AND    default_flag = 'Y';

    CURSOR c_seq_no IS
      SELECT igs_ps_ent_pt_ref_cd_seq_num_s.NEXTVAL
      FROM dual;

    l_n_sequence_number NUMBER;
    l_c_rowid VARCHAR2(30);

  BEGIN
    OPEN c_ofr_opt( p_n_coo_id );
    FETCH c_ofr_opt INTO l_ofr_opt;
    CLOSE c_ofr_opt;

    FOR cur_igs_ge_ref_cd_type_all IN c_igs_ge_ref_cd_type_all
      LOOP
        FOR cur_igs_ge_ref_cd IN c_igs_ge_ref_cd(cur_igs_ge_ref_cd_type_all.reference_cd_type)
	  LOOP
	    OPEN c_seq_no;
  	    FETCH c_seq_no INTO l_n_sequence_number;
 	    CLOSE c_seq_no;
  	    -- insert a value in igs_ps_ent_pt_ref_cd for every value of  course_cd and version_number having
            -- a applicable program offering option defined as mandatory  and a default reference code
            BEGIN
               l_c_rowid:=NULL;
	       igs_ps_ent_pt_ref_cd_pkg.insert_row(  x_rowid             =>  l_c_rowid,
	                                             x_course_cd         =>  l_ofr_opt.course_cd,
		  				     x_sequence_number   =>  l_n_sequence_number,
 						     x_reference_cd_type =>  cur_igs_ge_ref_cd_type_all.reference_cd_type,
						     x_attendance_type   =>  l_ofr_opt.attendance_type,
						     x_cal_type          =>  l_ofr_opt.cal_type,
						     x_location_cd       =>  l_ofr_opt.location_cd,
						     x_version_number    =>  l_ofr_opt.version_number,
						     x_attendance_mode   =>  l_ofr_opt.attendance_mode,
						     x_coo_id            =>  p_n_coo_id,
						     x_unit_set_cd       =>  NULL,
						     x_us_version_number =>  NULL,
						     x_reference_cd      =>  cur_igs_ge_ref_cd.reference_cd,
						     x_description       =>  cur_igs_ge_ref_cd.description,
						     x_mode              => 'R' );
	    EXCEPTION
	      -- The failure of insertion of reference code should not stop the creation of new program offering option.
	      -- Hence any exception raised by  the TBH is trapped and the current processing is allowed to proceed.
	       WHEN OTHERS THEN
	         NULL;
	    END ;
        END LOOP;
    END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- If an error occurs during insertion in igs_ps_ent_pt_ref_cd then raise an exception.
	p_message_name := FND_MESSAGE.GET;

  END dflt_prg_ofropt_ref_code;



  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
    l_message_name  VARCHAR2(30) ;
    CURSOR c_coo(cp_rowid igs_ps_ofr_opt.row_id%TYPE) IS
      SELECT coo_id
      FROM   igs_ps_ofr_opt
      WHERE  ROWID = cp_rowid;
    l_coo_id igs_ps_ofr_opt.coo_id%TYPE;
  BEGIN

    l_rowid := x_rowid;

    IF ( p_action = 'INSERT') THEN
      OPEN c_coo(x_rowid);
      FETCH c_coo INTO l_coo_id;
      IF (c_coo%FOUND) THEN
        l_rowid := NULL;
        dflt_prg_ofropt_ref_code( l_coo_id,l_message_name );
	IF l_message_name IS NOT NULL THEN
           app_exception.raise_exception;
	END IF;
      END IF;
      CLOSE c_coo;
    END IF;

    l_rowid:=NULL;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_FORCED_LOCATION_IND in VARCHAR2,
  X_FORCED_ATT_MODE_IND in VARCHAR2,
  X_FORCED_ATT_TYPE_IND in VARCHAR2,
  X_TIME_LIMITATION in NUMBER,
  X_ENR_OFFICER_PERSON_ID in NUMBER,
  x_attribute_category in VARCHAR2 ,
  x_attribute1 in VARCHAR2 ,
  x_attribute2 in VARCHAR2 ,
  x_attribute3 in VARCHAR2 ,
  x_attribute4 in VARCHAR2 ,
  x_attribute5 in VARCHAR2 ,
  x_attribute6 in VARCHAR2 ,
  x_attribute7 in VARCHAR2 ,
  x_attribute8 in VARCHAR2 ,
  x_attribute9 in VARCHAR2 ,
  x_attribute10 in VARCHAR2 ,
  x_attribute11 in VARCHAR2 ,
  x_attribute12 in VARCHAR2 ,
  x_attribute13 in VARCHAR2 ,
  x_attribute14 in VARCHAR2 ,
  x_attribute15 in VARCHAR2 ,
  x_attribute16 in VARCHAR2 ,
  x_attribute17 in VARCHAR2 ,
  x_attribute18 in VARCHAR2 ,
  x_attribute19 in VARCHAR2 ,
  x_attribute20 in VARCHAR2 ,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  x_program_length IN NUMBER ,
  x_program_length_measurement IN VARCHAR2 ,
  X_DELETE_FLAG IN VARCHAR2
  ) AS

    --This cursor is added as a part of locking build
    CURSOR cur_check_for_deleted_rec(cp_course_cd  igs_ps_ofr_opt_all.course_cd%TYPE,
                                     cp_version_number igs_ps_ofr_opt_all.version_number%TYPE,
                                     cp_cal_type       igs_ps_ofr_opt_all.cal_type%TYPE,
                                     cp_location_cd    igs_ps_ofr_opt_all.location_cd%TYPE,
                                     cp_attendance_mode igs_ps_ofr_opt_all.attendance_mode%TYPE,
                                     cp_attendance_type igs_ps_ofr_opt_all.attendance_type%TYPE) IS
    SELECT rowid
    FROM   igs_ps_ofr_opt_all
    WHERE  course_cd=cp_course_cd
    AND    version_number=cp_version_number
    AND    cal_type =cp_cal_type
    AND    location_cd = cp_location_cd
    AND    attendance_type= cp_attendance_type
    AND    attendance_mode = cp_attendance_mode
    AND    delete_flag = 'Y';
    l_rowid  VARCHAR2(25);



    cursor C is select ROWID from IGS_PS_OFR_OPT_ALL
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and ATTENDANCE_MODE = X_ATTENDANCE_MODE
      and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
      and LOCATION_CD = X_LOCATION_CD;
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
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_coo_id => X_COO_ID,
    x_forced_location_ind =>NVL(X_FORCED_LOCATION_IND,'N'),
    x_forced_att_mode_ind => NVL(X_FORCED_ATT_MODE_IND,'N'),
    x_forced_att_type_ind => NVL(X_FORCED_ATT_TYPE_IND,'N'),
    x_time_limitation => X_TIME_LIMITATION ,
    x_enr_officer_person_id => X_ENR_OFFICER_PERSON_ID ,
    x_attribute_category => X_ATTRIBUTE_CATEGORY,
    x_attribute1 => X_ATTRIBUTE1,
    x_attribute2 => X_ATTRIBUTE2,
    x_attribute3 => X_ATTRIBUTE3,
    x_attribute4 => X_ATTRIBUTE4,
    x_attribute5 => X_ATTRIBUTE5,
    x_attribute6 => X_ATTRIBUTE6,
    x_attribute7 => X_ATTRIBUTE7,
    x_attribute8 => X_ATTRIBUTE8,
    x_attribute9 => X_ATTRIBUTE9,
    x_attribute10 => X_ATTRIBUTE10,
    x_attribute11 => X_ATTRIBUTE11,
    x_attribute12 => X_ATTRIBUTE12,
    x_attribute13 => X_ATTRIBUTE13,
    x_attribute14 => X_ATTRIBUTE14,
    x_attribute15 => X_ATTRIBUTE15,
    x_attribute16 => X_ATTRIBUTE16,
    x_attribute17 => X_ATTRIBUTE17,
    x_attribute18 => X_ATTRIBUTE18,
    x_attribute19 => X_ATTRIBUTE19,
    x_attribute20 => X_ATTRIBUTE20,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN ,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_program_length => x_program_length,
    x_program_length_measurement => x_program_length_measurement
);

  --** THis check has been intensionally for locking issue build(bug#2797116)
  --If a logically deleted record is there then update the delete_flag to N with rest of the parameter as passed
  --else insert the record with delete_flag as N

  OPEN cur_check_for_deleted_rec(x_course_cd,x_version_number,x_cal_type,x_location_cd,x_attendance_mode,
                                 x_attendance_type);
  FETCH cur_check_for_deleted_rec INTO l_rowid;
  IF cur_check_for_deleted_rec%NOTFOUND THEN
    CLOSE cur_check_for_deleted_rec;

    insert into IGS_PS_OFR_OPT_ALL (
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    COO_ID,
    FORCED_LOCATION_IND,
    FORCED_ATT_MODE_IND,
    FORCED_ATT_TYPE_IND,
    TIME_LIMITATION,
    ENR_OFFICER_PERSON_ID,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    PROGRAM_LENGTH,
    PROGRAM_LENGTH_MEASUREMENT,
    DELETE_FLAG
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.COO_ID,
    NEW_REFERENCES.FORCED_LOCATION_IND,
    NEW_REFERENCES.FORCED_ATT_MODE_IND,
    NEW_REFERENCES.FORCED_ATT_TYPE_IND,
    NEW_REFERENCES.TIME_LIMITATION,
    NEW_REFERENCES.ENR_OFFICER_PERSON_ID,
    NEW_REFERENCES.attribute_category,
    NEW_REFERENCES.attribute1,
    NEW_REFERENCES.attribute2,
    NEW_REFERENCES.attribute3,
    NEW_REFERENCES.attribute4,
    NEW_REFERENCES.attribute5,
    NEW_REFERENCES.attribute6,
    NEW_REFERENCES.attribute7,
    NEW_REFERENCES.attribute8,
    NEW_REFERENCES.attribute9,
    NEW_REFERENCES.attribute10,
    NEW_REFERENCES.attribute11,
    NEW_REFERENCES.attribute12,
    NEW_REFERENCES.attribute13,
    NEW_REFERENCES.attribute14,
    NEW_REFERENCES.attribute15,
    NEW_REFERENCES.attribute16,
    NEW_REFERENCES.attribute17,
    NEW_REFERENCES.attribute18,
    NEW_REFERENCES.attribute19,
    NEW_REFERENCES.attribute20,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PROGRAM_LENGTH,
    NEW_REFERENCES.PROGRAM_LENGTH_MEASUREMENT,
    'N'
    );
  ELSE
    CLOSE cur_check_for_deleted_rec;

    UPDATE IGS_PS_OFR_OPT_ALL
    SET
    FORCED_LOCATION_IND=NEW_REFERENCES.FORCED_LOCATION_IND,
    FORCED_ATT_MODE_IND=NEW_REFERENCES.FORCED_ATT_MODE_IND,
    FORCED_ATT_TYPE_IND=NEW_REFERENCES.FORCED_ATT_TYPE_IND,
    TIME_LIMITATION=NEW_REFERENCES.TIME_LIMITATION,
    ENR_OFFICER_PERSON_ID=NEW_REFERENCES.ENR_OFFICER_PERSON_ID,
    ATTRIBUTE_CATEGORY = NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 = NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 = NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 = NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 = NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 = NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 = NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 = NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 = NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 = NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 = NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 = NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 = NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 = NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 = NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 = NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 = NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 = NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 = NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 = NEW_REFERENCES.ATTRIBUTE20,
    CREATION_DATE = X_LAST_UPDATE_DATE,
    CREATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ORG_ID = NEW_REFERENCES.ORG_ID,
    PROGRAM_LENGTH = NEW_REFERENCES.PROGRAM_LENGTH,
    PROGRAM_LENGTH_MEASUREMENT = NEW_REFERENCES.PROGRAM_LENGTH_MEASUREMENT,
    DELETE_FLAG = 'N'
    WHERE ROWID = l_rowid;

  END IF;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  --This modification is done as part of locking build
  IF l_rowid IS NULL THEN
     After_DML (
	p_action => 'INSERT',
	x_rowid => X_ROWID
      );
  ELSE
     After_DML (
	p_action => 'UPDATE',
	x_rowid => X_ROWID
      );
  END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_FORCED_LOCATION_IND in VARCHAR2,
  X_FORCED_ATT_MODE_IND in VARCHAR2,
  X_FORCED_ATT_TYPE_IND in VARCHAR2,
  X_TIME_LIMITATION in NUMBER,
  X_ENR_OFFICER_PERSON_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 ,
  X_ATTRIBUTE1 in VARCHAR2 ,
  X_ATTRIBUTE2 in VARCHAR2 ,
  X_ATTRIBUTE3 in VARCHAR2 ,
  X_ATTRIBUTE4 in VARCHAR2 ,
  X_ATTRIBUTE5 in VARCHAR2 ,
  X_ATTRIBUTE6 in VARCHAR2 ,
  X_ATTRIBUTE7 in VARCHAR2 ,
  X_ATTRIBUTE8 in VARCHAR2 ,
  X_ATTRIBUTE9 in VARCHAR2 ,
  X_ATTRIBUTE10 in VARCHAR2 ,
  X_ATTRIBUTE11 in VARCHAR2 ,
  X_ATTRIBUTE12 in VARCHAR2 ,
  X_ATTRIBUTE13 in VARCHAR2 ,
  X_ATTRIBUTE14 in VARCHAR2 ,
  X_ATTRIBUTE15 in VARCHAR2 ,
  X_ATTRIBUTE16 in VARCHAR2 ,
  X_ATTRIBUTE17 in VARCHAR2 ,
  X_ATTRIBUTE18 in VARCHAR2 ,
  X_ATTRIBUTE19 in VARCHAR2 ,
  X_ATTRIBUTE20 in VARCHAR2 ,
  x_program_length IN NUMBER ,
  x_program_length_measurement IN VARCHAR2 ,
  X_DELETE_FLAG IN VARCHAR2
) AS
  cursor c1 is select
      COO_ID,
      FORCED_LOCATION_IND,
      FORCED_ATT_MODE_IND,
      FORCED_ATT_TYPE_IND,
      TIME_LIMITATION,
      ENR_OFFICER_PERSON_ID
    from IGS_PS_OFR_OPT_ALL
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

  if ( (tlinfo.COO_ID = X_COO_ID)
      AND (tlinfo.FORCED_LOCATION_IND = X_FORCED_LOCATION_IND)
      AND (tlinfo.FORCED_ATT_MODE_IND = X_FORCED_ATT_MODE_IND)
      AND (tlinfo.FORCED_ATT_TYPE_IND = X_FORCED_ATT_TYPE_IND)
      AND ((tlinfo.TIME_LIMITATION = X_TIME_LIMITATION)
           OR ((tlinfo.TIME_LIMITATION is null)
               AND (X_TIME_LIMITATION is null)))
      AND ((tlinfo.ENR_OFFICER_PERSON_ID = X_ENR_OFFICER_PERSON_ID)
           OR ((tlinfo.ENR_OFFICER_PERSON_ID is null)
               AND (X_ENR_OFFICER_PERSON_ID is null)))
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
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_FORCED_LOCATION_IND in VARCHAR2,
  X_FORCED_ATT_MODE_IND in VARCHAR2,
  X_FORCED_ATT_TYPE_IND in VARCHAR2,
  X_TIME_LIMITATION in NUMBER,
  X_ENR_OFFICER_PERSON_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 ,
  X_ATTRIBUTE1 in VARCHAR2 ,
  X_ATTRIBUTE2 in VARCHAR2 ,
  X_ATTRIBUTE3 in VARCHAR2 ,
  X_ATTRIBUTE4 in VARCHAR2 ,
  X_ATTRIBUTE5 in VARCHAR2 ,
  X_ATTRIBUTE6 in VARCHAR2 ,
  X_ATTRIBUTE7 in VARCHAR2 ,
  X_ATTRIBUTE8 in VARCHAR2 ,
  X_ATTRIBUTE9 in VARCHAR2 ,
  X_ATTRIBUTE10 in VARCHAR2 ,
  X_ATTRIBUTE11 in VARCHAR2 ,
  X_ATTRIBUTE12 in VARCHAR2 ,
  X_ATTRIBUTE13 in VARCHAR2 ,
  X_ATTRIBUTE14 in VARCHAR2 ,
  X_ATTRIBUTE15 in VARCHAR2 ,
  X_ATTRIBUTE16 in VARCHAR2 ,
  X_ATTRIBUTE17 in VARCHAR2 ,
  X_ATTRIBUTE18 in VARCHAR2 ,
  X_ATTRIBUTE19 in VARCHAR2 ,
  X_ATTRIBUTE20 in VARCHAR2 ,
  X_MODE in VARCHAR2,
  x_program_length IN NUMBER ,
  x_program_length_measurement IN VARCHAR2 ,
  x_delete_flag IN VARCHAR2
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
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_coo_id => X_COO_ID,
    x_forced_location_ind => X_FORCED_LOCATION_IND ,
    x_forced_att_mode_ind => X_FORCED_ATT_MODE_IND,
    x_forced_att_type_ind => X_FORCED_ATT_TYPE_IND,
    x_time_limitation => X_TIME_LIMITATION ,
    x_enr_officer_person_id => X_ENR_OFFICER_PERSON_ID ,
    x_attribute_category => X_ATTRIBUTE_CATEGORY,
    x_attribute1 => X_ATTRIBUTE1,
    x_attribute2 => X_ATTRIBUTE2,
    x_attribute3 => X_ATTRIBUTE3,
    x_attribute4 => X_ATTRIBUTE4,
    x_attribute5 => X_ATTRIBUTE5,
    x_attribute6 => X_ATTRIBUTE6,
    x_attribute7 => X_ATTRIBUTE7,
    x_attribute8 => X_ATTRIBUTE8,
    x_attribute9 => X_ATTRIBUTE9,
    x_attribute10 => X_ATTRIBUTE10,
    x_attribute11 => X_ATTRIBUTE11,
    x_attribute12 => X_ATTRIBUTE12,
    x_attribute13 => X_ATTRIBUTE13,
    x_attribute14 => X_ATTRIBUTE14,
    x_attribute15 => X_ATTRIBUTE15,
    x_attribute16 => X_ATTRIBUTE16,
    x_attribute17 => X_ATTRIBUTE17,
    x_attribute18 => X_ATTRIBUTE18,
    x_attribute19 => X_ATTRIBUTE19,
    x_attribute20 => X_ATTRIBUTE20,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN ,
    x_program_length => X_program_length,
    x_program_length_measurement => X_program_length_measurement
 );

 --Locking issue build(bug#2797116),this check child existance has been put deliberately
 IF NVL(x_delete_flag,'N') = 'Y' THEN
   Check_Child_Existance;
 END IF;

  update IGS_PS_OFR_OPT_ALL set
    COO_ID = NEW_REFERENCES.COO_ID,
    FORCED_LOCATION_IND = NEW_REFERENCES.FORCED_LOCATION_IND,
    FORCED_ATT_MODE_IND = NEW_REFERENCES.FORCED_ATT_MODE_IND,
    FORCED_ATT_TYPE_IND = NEW_REFERENCES.FORCED_ATT_TYPE_IND,
    TIME_LIMITATION = NEW_REFERENCES.TIME_LIMITATION,
    ENR_OFFICER_PERSON_ID = NEW_REFERENCES.ENR_OFFICER_PERSON_ID,
    ATTRIBUTE_CATEGORY = NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 = NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 = NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 = NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 = NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 = NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 = NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 = NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 = NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 = NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 = NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 = NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 = NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 = NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 = NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 = NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 = NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 = NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 = NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 = NEW_REFERENCES.ATTRIBUTE20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_LENGTH = NEW_REFERENCES.PROGRAM_LENGTH,
    PROGRAM_LENGTH_MEASUREMENT = NEW_REFERENCES.PROGRAM_LENGTH_MEASUREMENT,
    DELETE_FLAG = NVL(X_DELETE_FLAG,'N')
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
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_FORCED_LOCATION_IND in VARCHAR2,
  X_FORCED_ATT_MODE_IND in VARCHAR2,
  X_FORCED_ATT_TYPE_IND in VARCHAR2,
  X_TIME_LIMITATION in NUMBER,
  X_ENR_OFFICER_PERSON_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 ,
  X_ATTRIBUTE1 in VARCHAR2 ,
  X_ATTRIBUTE2 in VARCHAR2 ,
  X_ATTRIBUTE3 in VARCHAR2 ,
  X_ATTRIBUTE4 in VARCHAR2 ,
  X_ATTRIBUTE5 in VARCHAR2 ,
  X_ATTRIBUTE6 in VARCHAR2 ,
  X_ATTRIBUTE7 in VARCHAR2 ,
  X_ATTRIBUTE8 in VARCHAR2 ,
  X_ATTRIBUTE9 in VARCHAR2 ,
  X_ATTRIBUTE10 in VARCHAR2 ,
  X_ATTRIBUTE11 in VARCHAR2 ,
  X_ATTRIBUTE12 in VARCHAR2 ,
  X_ATTRIBUTE13 in VARCHAR2 ,
  X_ATTRIBUTE14 in VARCHAR2 ,
  X_ATTRIBUTE15 in VARCHAR2 ,
  X_ATTRIBUTE16 in VARCHAR2 ,
  X_ATTRIBUTE17 in VARCHAR2 ,
  X_ATTRIBUTE18 in VARCHAR2 ,
  X_ATTRIBUTE19 in VARCHAR2 ,
  X_ATTRIBUTE20 in VARCHAR2 ,
  X_MODE in VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_PROGRAM_LENGTH IN NUMBER ,
  X_PROGRAM_LENGTH_MEASUREMENT IN VARCHAR2 ,
  X_DELETE_FLAG IN VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_PS_OFR_OPT_ALL
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and ATTENDANCE_MODE = X_ATTENDANCE_MODE
     and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
     and LOCATION_CD = X_LOCATION_CD
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
     X_CAL_TYPE,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_LOCATION_CD,
     X_COO_ID,
     X_FORCED_LOCATION_IND,
     X_FORCED_ATT_MODE_IND,
     X_FORCED_ATT_TYPE_IND,
     X_TIME_LIMITATION,
     X_ENR_OFFICER_PERSON_ID,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_ATTRIBUTE16,
     X_ATTRIBUTE17,
     X_ATTRIBUTE18,
     X_ATTRIBUTE19,
     X_ATTRIBUTE20,
     X_MODE,
     x_org_id,
     X_PROGRAM_LENGTH,
     X_PROGRAM_LENGTH_MEASUREMENT);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_LOCATION_CD,
   X_COO_ID,
   X_FORCED_LOCATION_IND,
   X_FORCED_ATT_MODE_IND,
   X_FORCED_ATT_TYPE_IND,
   X_TIME_LIMITATION,
   X_ENR_OFFICER_PERSON_ID,
   X_ATTRIBUTE_CATEGORY,
   X_ATTRIBUTE1,
   X_ATTRIBUTE2,
   X_ATTRIBUTE3,
   X_ATTRIBUTE4,
   X_ATTRIBUTE5,
   X_ATTRIBUTE6,
   X_ATTRIBUTE7,
   X_ATTRIBUTE8,
   X_ATTRIBUTE9,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11,
   X_ATTRIBUTE12,
   X_ATTRIBUTE13,
   X_ATTRIBUTE14,
   X_ATTRIBUTE15,
   X_ATTRIBUTE16,
   X_ATTRIBUTE17,
   X_ATTRIBUTE18,
   X_ATTRIBUTE19,
   X_ATTRIBUTE20,
   X_MODE ,
   X_PROGRAM_LENGTH,
   X_PROGRAM_LENGTH_MEASUREMENT);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
  delete from IGS_PS_OFR_OPT_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_OFR_OPT_PKG;

/
