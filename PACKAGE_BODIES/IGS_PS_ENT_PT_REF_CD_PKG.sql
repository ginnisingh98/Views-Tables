--------------------------------------------------------
--  DDL for Package Body IGS_PS_ENT_PT_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_ENT_PT_REF_CD_PKG" AS
  /* $Header: IGSPI10B.pls 120.1 2006/05/29 07:29:39 sarakshi noship $ */

--sarakshi  20-Apr-2002   As a part of the bug #2146753 removed the call to the function
--                        igs_ps_val_ceprc.crsp_val_ceprc_uref from beforerowinsertupdatedelete1
--                        Also addd few columns in lock_row,update_row which were missing.
--sarakshi  27-Apr-2006   Bug#5165619, modified check_parent_existance and created procedure GET_FK_IGS_PS_OFR_UNIT_SET

  l_rowid VARCHAR2(25);
  old_references IGS_PS_ENT_PT_REF_CD%RowType;
  new_references IGS_PS_ENT_PT_REF_CD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_ENT_PT_REF_CD
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
    new_references.reference_cd_type := x_reference_cd_type;
    new_references.sequence_number := x_sequence_number;
    new_references.coo_id := x_coo_id;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.reference_cd := x_reference_cd;
    new_references.description := x_description;
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
  -- "OSS_TST".trg_ceprc_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PS_ENT_PT_REF_CD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

	v_message_name		varchar2(30);
	v_course_cd		IGS_PS_VER.course_cd%TYPE;
	v_version_number	IGS_PS_VER.version_number%TYPE;

  BEGIN

	-- Set IGS_PS_OFR_OPT key.
	IF p_inserting THEN
		IGS_PS_GEN_003.CRSP_GET_COO_KEY (
			new_references.coo_id,
			new_references.course_cd,
			new_references.version_number,
			new_references.cal_type,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type);
	END IF;
	-- Set variables
	IF p_inserting OR p_updating THEN
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
	ELSE	-- p_deleting
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
	END IF;
	-- Validate that inserts/updates/deletes are allowed
	IF IGS_PS_VAL_CRS.CRSP_VAL_IUD_CRV_DTL(v_course_cd,
				v_version_number,
				v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	IF p_inserting THEN
		-- Validate IGS_PS_COURSE offering option
		-- IGS_GE_NOTE:crsp_val_iud_crv_dtl called from this function
		IF IGS_PS_VAL_COp.crsp_val_coo_inactiv (
			new_references.course_cd,
			new_references.version_number,
			new_references.cal_type,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		-- Validate reference code type
		IF IGS_PS_VAL_CRFC.crsp_val_ref_cd_type(
			new_references.reference_cd_type,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR p_updating THEN
		-- Validate IGS_PS_UNIT sets are valid for the IGS_PS_COURSE offering option
		 IF (new_references.unit_set_cd IS NOT NULL OR
		    new_references.us_version_number IS NOT NULL) THEN
			IF IGS_PS_VAL_CEPRC.crsp_val_ceprc_coous (
				new_references.coo_id,
				new_references.unit_set_cd,
				new_references.us_version_number,
				v_message_name) = 'FALSE' THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	IF p_inserting THEN
		IF IGS_PS_VAL_CEPRC.crsp_val_ceprc_uniq (
			new_references.coo_id,
			new_references.reference_cd_type,
			new_references.sequence_number,
			new_references.unit_set_cd,
			new_references.us_version_number,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
                --As a part of the bug #2146753 removed the call to the function
                --igs_ps_val_ceprc.crsp_val_ceprc_uref
	END IF;
        IF p_deleting THEN
           IF IGS_PS_VAL_ATL.chk_mandatory_ref_cd(
                        new_references.reference_cd_type) = TRUE THEN
                        Fnd_Message.Set_Name('IGS','IGS_PS_REF_CD_MANDATORY');
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
            END IF;
        END IF;
  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	DEFAULT NULL,
 Column_Value 	IN VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

	IF column_name is null then
	    NULL;
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
	ELSIF upper(Column_name) = 'REFERENCE_CD' then
	    new_references.reference_cd := column_value;
	ELSIF upper(Column_name) = 'REFERENCE_CD_TYPE' then
	    new_references.reference_cd_type := column_value;
	ELSIF upper(Column_name) = 'UNIT_SET_CD' then
	    new_references.unit_set_cd := column_value;
	ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
	    new_references.sequence_number := igs_ge_number.to_num(column_value);
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

    IF upper(column_name) = 'REFERENCE_CD' OR
    column_name is null Then
	   IF ( new_references.reference_cd <> UPPER(new_references.reference_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'REFERENCE_CD_TYPE' OR
    column_name is null Then
	   IF ( new_references.reference_cd_type <> UPPER(new_references.reference_cd_type) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'UNIT_SET_CD' OR
    column_name is null Then
	   IF ( new_references.unit_set_cd <> UPPER(new_references.unit_set_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'SEQUENCE_NUMBER' OR
    column_name is null Then
	   IF ( new_references.sequence_number < 1 OR new_references.sequence_number > 999999 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS

    CURSOR cur_reference_cd_chk(cp_reference_cd_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE) IS
    SELECT 'X'
    FROM   igs_ge_ref_cd_type_all
    WHERE  restricted_flag='Y'
    AND    reference_cd_type=cp_reference_cd_type;
    l_var  VARCHAR2(1);

    CURSOR cur_check(cp_course_cd igs_ps_ofr_opt_unit_set_v.course_cd%TYPE,
                     cp_crv_version_number igs_ps_ofr_opt_unit_set_v.crv_version_number%TYPE,
		     cp_cal_type igs_ps_ofr_opt_unit_set_v.cal_type%TYPE,
		     cp_location_cd igs_ps_ofr_opt_unit_set_v.location_cd%TYPE,
		     cp_attendance_mode igs_ps_ofr_opt_unit_set_v.attendance_mode%TYPE,
		     cp_attendance_type igs_ps_ofr_opt_unit_set_v.attendance_type%TYPE,
		     cp_unit_set_cd igs_ps_ofr_opt_unit_set_v.unit_set_cd%TYPE,
		     cp_us_version_number igs_ps_ofr_opt_unit_set_v.us_version_number%TYPE) IS
    SELECT 'X'
    FROM   igs_ps_ofr_opt_unit_set_v
    WHERE  course_cd=cp_course_cd
    AND    crv_version_number=cp_crv_version_number
    AND    cal_type = cp_cal_type
    AND    location_cd = cp_location_cd
    AND    attendance_mode = cp_attendance_mode
    AND    attendance_type = cp_attendance_type
    AND    unit_set_cd = cp_unit_set_cd
    AND    us_version_number = cp_us_version_number;
    l_c_var VARCHAR2(1);


  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.attendance_mode = new_references.attendance_mode) AND
         (old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.attendance_mode IS NULL) OR
         (new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_OPT_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.location_cd,
        new_references.attendance_mode,
        new_references.attendance_type
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.coo_id = new_references.coo_id)) OR
        ((new_references.coo_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_OPT_PKG.Get_UK_For_Validation (
        new_references.coo_id
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.reference_cd_type = new_references.reference_cd_type)) OR
        ((new_references.reference_cd_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_REF_CD_TYPE_PKG.Get_PK_For_Validation (
        new_references.reference_cd_type
        ) THEN
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
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
      END IF;

      --Added the check parent existance for the IGS_PS_OFR_UNIT_SET and IGS_PS_OF_OPT_UNT_ST
      OPEN cur_check( new_references.course_cd,
                      new_references.version_number,
                      new_references.cal_type,
                      new_references.location_cd,
                      new_references.attendance_mode,
                      new_references.attendance_type,
	              new_references.unit_set_cd,
		      new_references.us_version_number);
      FETCH cur_check INTO l_c_var;
      IF cur_check%NOTFOUND THEN
	CLOSE cur_check;
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF;
      CLOSE cur_check;
    END IF;

    OPEN cur_reference_cd_chk(new_references.reference_cd_type);
    FETCH cur_reference_cd_chk INTO l_var;
    IF cur_reference_cd_chk%FOUND THEN
      IF (((old_references.reference_cd_type = new_references.reference_cd_type) AND
           (old_references.reference_cd = new_references.reference_cd)) OR
          ((new_references.reference_cd_type IS NULL) OR
           (new_references.reference_cd IS NULL))) THEN
         NULL;
      ELSIF NOT igs_ge_ref_cd_pkg.get_uk_for_validation (
                          new_references.reference_cd_type,
                          new_references.reference_cd
          )  THEN
          Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
    END IF;
    CLOSE cur_reference_cd_chk;


  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_reference_cd_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ENT_PT_REF_CD
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type
      AND      reference_cd_type = x_reference_cd_type
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

  PROCEDURE GET_FK_IGS_PS_OFR_OPT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ENT_PT_REF_CD
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CEPRC_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_OPT;

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
    x_coo_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ENT_PT_REF_CD
      WHERE    coo_id = x_coo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CEPRC_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_PS_OFR_OPT;

  PROCEDURE GET_FK_IGS_GE_REF_CD_TYPE (
    x_reference_cd_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ENT_PT_REF_CD
      WHERE    reference_cd_type = x_reference_cd_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CEPRC_RCT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_REF_CD_TYPE;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ENT_PT_REF_CD
      WHERE    unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CEPRC_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET;

  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) AS
  /*************************************************************
  Created By :sarakshi
  Date Created By :27-APR-2006
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ENT_PT_REF_CD
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_us_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CEPRC_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_UNIT_SET;



   PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :sarakshi
  Date Created By :7-May-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type
      AND      reference_cd = x_reference_cd ;

    lv_rowid cur_rowid%ROWTYPE;

 BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRCC_RC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ge_ref_cd;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
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
      x_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_reference_cd_type,
      x_sequence_number,
      x_coo_id,
      x_unit_set_cd,
      x_us_version_number,
      x_reference_cd,
      x_description,
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
	new_references.course_cd ,
      new_references.version_number,
      new_references.cal_type,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.reference_cd_type,
      new_references.sequence_number) THEN
	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	   IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
	new_references.course_cd ,
      new_references.version_number,
      new_references.cal_type,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.reference_cd_type,
      new_references.sequence_number) THEN
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


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COO_ID in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_ENT_PT_REF_CD
      where COURSE_CD = X_COURSE_CD
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and REFERENCE_CD_TYPE = X_REFERENCE_CD_TYPE
      and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
      and CAL_TYPE = X_CAL_TYPE
      and LOCATION_CD = X_LOCATION_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and ATTENDANCE_MODE = X_ATTENDANCE_MODE;
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
    x_reference_cd_type => X_REFERENCE_CD_TYPE,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_coo_id => X_COO_ID ,
    x_unit_set_cd => X_UNIT_SET_CD ,
    x_us_version_number => X_US_VERSION_NUMBER ,
    x_reference_cd => X_REFERENCE_CD ,
    x_description => X_DESCRIPTION ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_ENT_PT_REF_CD (
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    COO_ID,
    REFERENCE_CD_TYPE,
    SEQUENCE_NUMBER,
    UNIT_SET_CD,
    US_VERSION_NUMBER,
    REFERENCE_CD,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.COO_ID,
    NEW_REFERENCES.REFERENCE_CD_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.US_VERSION_NUMBER,
    NEW_REFERENCES.REFERENCE_CD,
    NEW_REFERENCES.DESCRIPTION,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COO_ID in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) AS
  cursor c1 is select
      COO_ID,
--added by sarakshi, bug#2146753
      course_cd,
      version_number,
      cal_type,
      location_cd,
      attendance_mode,
      attendance_type,
      reference_cd_type,
      sequence_number,
--
      UNIT_SET_CD,
      US_VERSION_NUMBER,
      REFERENCE_CD,
      DESCRIPTION
    from IGS_PS_ENT_PT_REF_CD
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

  if ((tlinfo.COO_ID = X_COO_ID)
--added by sarakshi, bug#2146753
      AND (tlinfo.course_cd = x_course_cd)
      AND (tlinfo.version_number = x_version_number)
      AND (tlinfo.cal_type = x_cal_type)
      AND (tlinfo.location_cd = x_location_cd)
      AND (tlinfo.attendance_mode = x_attendance_mode)
      AND (tlinfo.attendance_type = x_attendance_type)
      AND (tlinfo.reference_cd_type = x_reference_cd_type)
      AND (tlinfo.sequence_number = x_sequence_number)
--
      AND ((tlinfo.UNIT_SET_CD = X_UNIT_SET_CD)
           OR ((tlinfo.UNIT_SET_CD is null)
               AND (X_UNIT_SET_CD is null)))
      AND ((tlinfo.US_VERSION_NUMBER = X_US_VERSION_NUMBER)
           OR ((tlinfo.US_VERSION_NUMBER is null)
               AND (X_US_VERSION_NUMBER is null)))
      AND (tlinfo.REFERENCE_CD = X_REFERENCE_CD)
      AND ((tlinfo.DESCRIPTION= X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COO_ID in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_reference_cd_type => X_REFERENCE_CD_TYPE,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_coo_id => X_COO_ID ,
    x_unit_set_cd => X_UNIT_SET_CD ,
    x_us_version_number => X_US_VERSION_NUMBER ,
    x_reference_cd => X_REFERENCE_CD ,
    x_description => X_DESCRIPTION ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_PS_ENT_PT_REF_CD set
--added by sarakshi, bug#2146753
    course_cd=new_references.course_cd,
    version_number=new_references.version_number,
    cal_type=new_references.cal_type,
    location_cd=new_references.location_cd,
    attendance_mode=new_references.attendance_mode,
    attendance_type=new_references.attendance_type,
    reference_cd_type=new_references.reference_cd_type,
    sequence_number=new_references.sequence_number,
--
    COO_ID = NEW_REFERENCES.COO_ID,
    UNIT_SET_CD = NEW_REFERENCES.UNIT_SET_CD,
    US_VERSION_NUMBER = NEW_REFERENCES.US_VERSION_NUMBER,
    REFERENCE_CD = NEW_REFERENCES.REFERENCE_CD,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COO_ID in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_ENT_PT_REF_CD
     where COURSE_CD = X_COURSE_CD
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and REFERENCE_CD_TYPE = X_REFERENCE_CD_TYPE
     and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
     and CAL_TYPE = X_CAL_TYPE
     and LOCATION_CD = X_LOCATION_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and ATTENDANCE_MODE = X_ATTENDANCE_MODE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_SEQUENCE_NUMBER,
     X_REFERENCE_CD_TYPE,
     X_ATTENDANCE_TYPE,
     X_CAL_TYPE,
     X_LOCATION_CD,
     X_VERSION_NUMBER,
     X_ATTENDANCE_MODE,
     X_COO_ID,
     X_UNIT_SET_CD,
     X_US_VERSION_NUMBER,
     X_REFERENCE_CD,
     X_DESCRIPTION,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_SEQUENCE_NUMBER,
   X_REFERENCE_CD_TYPE,
   X_ATTENDANCE_TYPE,
   X_CAL_TYPE,
   X_LOCATION_CD,
   X_VERSION_NUMBER,
   X_ATTENDANCE_MODE,
   X_COO_ID,
   X_UNIT_SET_CD,
   X_US_VERSION_NUMBER,
   X_REFERENCE_CD,
   X_DESCRIPTION,
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
  delete from IGS_PS_ENT_PT_REF_CD
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_ENT_PT_REF_CD_PKG;

/
