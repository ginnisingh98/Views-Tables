--------------------------------------------------------
--  DDL for Package Body IGS_GR_AWD_CRMN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_AWD_CRMN_PKG" as
/* $Header: IGSGI03B.pls 115.7 2002/11/29 00:34:09 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_AWD_CRMN%RowType;
  new_references IGS_GR_AWD_CRMN%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_GAC_ID in NUMBER ,
    x_person_id IN NUMBER ,
    x_create_dt IN DATE ,
    x_grd_cal_type IN VARCHAR2 ,
    x_grd_ci_sequence_number IN NUMBER ,
    x_ceremony_number IN NUMBER ,
    x_award_course_cd IN VARCHAR2 ,
    x_award_crs_version_number IN NUMBER ,
    x_award_cd IN VARCHAR2 ,
    x_us_group_number IN NUMBER ,
    x_order_in_presentation IN NUMBER ,
    x_graduand_seat_number IN VARCHAR2 ,
    x_name_pronunciation IN VARCHAR2 ,
    x_name_announced IN VARCHAR2 ,
    x_academic_dress_rqrd_ind IN VARCHAR2 ,
    x_academic_gown_size IN VARCHAR2 ,
    x_academic_hat_size IN VARCHAR2 ,
    x_guest_tickets_requested IN NUMBER ,
    x_guest_tickets_allocated IN NUMBER ,
    x_guest_seats IN VARCHAR2 ,
    x_fees_paid_ind IN VARCHAR2 ,
    x_special_requirements IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_AWD_CRMN
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
    new_references.GAC_ID := x_GAC_ID;
    new_references.person_id := x_person_id;
    new_references.create_dt := x_create_dt;
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.ceremony_number := x_ceremony_number;
    new_references.award_course_cd := x_award_course_cd;
    new_references.award_crs_version_number := x_award_crs_version_number;
    new_references.award_cd := x_award_cd;
    new_references.us_group_number := x_us_group_number;
    new_references.order_in_presentation := x_order_in_presentation;
    new_references.graduand_seat_number := x_graduand_seat_number;
    new_references.name_pronunciation := x_name_pronunciation;
    new_references.name_announced := x_name_announced;
    new_references.academic_dress_rqrd_ind := x_academic_dress_rqrd_ind;
    new_references.academic_gown_size := x_academic_gown_size;
    new_references.academic_hat_size := x_academic_hat_size;
    new_references.guest_tickets_requested := x_guest_tickets_requested;
    new_references.guest_tickets_allocated := x_guest_tickets_allocated;
    new_references.guest_seats := x_guest_seats;
    new_references.fees_paid_ind := x_fees_paid_ind;
    new_references.special_requirements := x_special_requirements;
    new_references.comments := x_comments;
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
  -- "OSS_TST".trg_gac_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_AWD_CRMN
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS

   v_message_name	VARCHAR2(30);

  BEGIN
	IF p_inserting THEN
		IF IGS_GR_VAL_GAC.grdp_val_gac_insert(
						new_references.person_id,
  						new_references.create_dt,
  						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF p_inserting OR p_updating THEN
		-- Validate the graduand award ceremony record may be inserted or updated
		IF IGS_GR_VAL_GAC.grdp_val_gac_iu(
				new_references.grd_cal_type,
				new_references.grd_ci_sequence_number,
				new_references.ceremony_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
		-- validate required details have been specified
		IF IGS_GR_VAL_GAC.grdp_val_gac_rqrd(
				new_references.award_course_cd,
  				new_references.award_crs_version_number,
  				new_references.award_cd,
  				new_references.us_group_number,
				new_references.academic_dress_rqrd_ind,
				new_references.academic_gown_size,
				new_references.academic_hat_size,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
		-- validate unit set group
		IF (NVL(new_references.us_group_number, 0) <>
			NVL(old_references.us_group_number, 0)) THEN
			IF (new_references.us_group_number IS NOT NULL) THEN
				IF IGS_GR_VAL_GAC.grdp_val_gac_susa(
						new_references.person_id,
  						new_references.create_dt,
  						new_references.grd_cal_type,
  						new_references.grd_ci_sequence_number,
						NULL,
						NULL,
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
		END IF;
		-- validate measurement codes
		IF (NVL(new_references.academic_gown_size, 'NULL') <>
			NVL(old_references.academic_gown_size, 'NULL')) THEN
			IF (new_references.academic_gown_size IS NOT NULL) THEN
				IF IGS_GR_VAL_GAC.grdp_val_msr_closed(
						new_references.academic_gown_size,
  						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
				END IF;
			END IF;
		END IF;
		IF (NVL(new_references.academic_hat_size, 'NULL') <>
			NVL(old_references.academic_hat_size, 'NULL')) THEN
			IF (new_references.academic_hat_size IS NOT NULL) THEN
				IF IGS_GR_VAL_GAC.grdp_val_msr_closed(
						new_references.academic_hat_size,
  						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
				END IF;
			END IF;
		END IF;
	END IF;

	IF p_inserting OR (p_updating AND
			new_references.grd_cal_type <> old_references.grd_cal_type OR
			new_references.grd_ci_sequence_number <> old_references.grd_ci_sequence_number)  THEN
		-- validate the graduation calendar instance
		IF IGS_GR_VAL_GAC.grdp_val_gac_grd_ci(
				new_references.grd_cal_type,
  				new_references.grd_ci_sequence_number,
  				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF p_inserting OR (p_updating AND
			new_references.grd_cal_type <> old_references.grd_cal_type OR
			new_references.grd_ci_sequence_number <> old_references.grd_ci_sequence_number OR
			new_references.ceremony_number <> old_references.ceremony_number OR
			new_references.award_course_cd <> old_references.award_course_cd OR
			new_references.award_crs_version_number <> old_references.award_crs_version_number OR
			new_references.award_cd <> old_references.award_cd)  THEN
		-- Validate the award ceremony record is not closed
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

	IF p_inserting OR (p_updating AND
			new_references.grd_cal_type <> old_references.grd_cal_type OR
			new_references.grd_ci_sequence_number <> old_references.grd_ci_sequence_number OR
			new_references.ceremony_number <> old_references.ceremony_number OR
			new_references.award_course_cd <> old_references.award_course_cd OR
			new_references.award_crs_version_number <> old_references.award_crs_version_number OR
			new_references.award_cd <> old_references.award_cd OR
			NVL(new_references.us_group_number, 0) <> NVL(old_references.us_group_number, 0))  THEN
		-- Validate the award ceremony unit set group record is not closed
		IF new_references.us_group_number IS NOT NULL THEN
			IF IGS_GR_VAL_ACUS.GRDP_VAL_ACUSG_CLOSE(
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
	END IF;

  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_gac_ar_d_hist
  -- AFTER DELETE
  -- ON IGS_GR_AWD_CRMN
  -- FOR EACH ROW

  PROCEDURE AfterRowDelete2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Delete the history records.
	IF IGS_GR_GEN_001.GRDP_DEL_GAC_HIST (
			old_references.person_id,
			old_references.create_dt,
			old_references.grd_cal_type,
			old_references.grd_ci_sequence_number,
			old_references.ceremony_number,
			old_references.award_course_cd,
			old_references.award_crs_version_number,
			old_references.award_cd,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS', v_message_name);
		IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
	END IF;


  END AfterRowDelete2;

  -- Trigger description :-
  -- "OSS_TST".trg_gac_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_GR_AWD_CRMN
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate3(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	IF p_inserting OR p_updating THEN
		-- validate graduand seat number
		IF (NVL(new_references.graduand_seat_number, 'NULL') <>
			NVL(old_references.graduand_seat_number, 'NULL')) THEN
			IF (new_references.graduand_seat_number IS NOT NULL) THEN
		  			-- validate graduand seat number
		  			IF (NEW_REFERENCES.graduand_seat_number IS NOT NULL) THEN
		  				IF IGS_GR_VAL_GAC.grdp_val_gac_seat(
		  						NEW_REFERENCES.person_id,
		  						NEW_REFERENCES.grd_cal_type,
		  						NEW_REFERENCES.grd_ci_sequence_number,
		  						NEW_REFERENCES.ceremony_number,
		  						NEW_REFERENCES.graduand_seat_number,
		  						v_message_name) = FALSE THEN
		  					Fnd_Message.Set_Name('IGS', v_message_name);
		  					IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		  				END IF;
		  			END IF;
		  			-- validate order in presentation
		  			IF (NEW_REFERENCES.order_in_presentation IS NOT NULL) THEN
		  				IF IGS_GR_VAL_GAC.grdp_val_gac_order(
		  						NEW_REFERENCES.person_id,
		  						NEW_REFERENCES.grd_cal_type,
		  						NEW_REFERENCES.grd_ci_sequence_number,
		  						NEW_REFERENCES.ceremony_number,
		  						NEW_REFERENCES.order_in_presentation,
		  						v_message_name) = FALSE THEN
		  					Fnd_Message.Set_Name('IGS', v_message_name);
		  					IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		  				END IF;
		  			END IF;
				v_rowid_saved := TRUE;
			END IF;
		END IF;
		-- validate order in presentation
		IF (NVL(new_references.order_in_presentation, 0) <>
			NVL(old_references.order_in_presentation, 0)) THEN
			IF (new_references.order_in_presentation IS NOT NULL) THEN
				-- Save the rowid of the current row.
				-- Cannot call grdp_val_gac_order because trigger
				-- will be mutating.
				IF v_rowid_saved = FALSE THEN

		  			-- validate graduand seat number
		  			IF (NEW_REFERENCES.graduand_seat_number IS NOT NULL) THEN
		  				IF IGS_GR_VAL_GAC.grdp_val_gac_seat(
		  						NEW_REFERENCES.person_id,
		  						NEW_REFERENCES.grd_cal_type,
		  						NEW_REFERENCES.grd_ci_sequence_number,
		  						NEW_REFERENCES.ceremony_number,
		  						NEW_REFERENCES.graduand_seat_number,
		  						v_message_name) = FALSE THEN
		  					Fnd_Message.Set_Name('IGS', v_message_name);
		  					IGS_GE_MSG_STACK.ADD;
  							App_Exception.Raise_Exception;
		  				END IF;
		  			END IF;

					v_rowid_saved := TRUE;
				END IF;
			END IF;
		END IF;
	END IF;


  END AfterRowInsertUpdate3;

  -- Trigger description :-
  -- "OSS_TST".trg_gac_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_GR_AWD_CRMN
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate4(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	NUMBER;
  BEGIN
	-- If the Ceremony Number has not been updated then create a history record.
	-- If the Ceremony Number has been updated then remove the history records.
	-- p_updating the Ceremony Number is the equivalent to creating a new record.
	-- For this reason all existing history records are deleted.
	IF old_references.ceremony_number = new_references.ceremony_number THEN
		IGS_GR_GEN_001.GRDP_INS_GAC_HIST (
				old_references.person_id,
				old_references.create_dt,
				old_references.grd_cal_type,
				old_references.grd_ci_sequence_number,
				old_references.ceremony_number,
				old_references.award_course_cd,
				old_references.award_crs_version_number,
				old_references.award_cd,
				old_references.us_group_number,
				new_references.us_group_number,
				old_references.order_in_presentation,
				new_references.order_in_presentation,
				old_references.graduand_seat_number,
				new_references.graduand_seat_number,
				old_references.name_pronunciation,
				new_references.name_pronunciation,
				old_references.name_announced,
				new_references.name_announced,
				old_references.academic_dress_rqrd_ind,
				new_references.academic_dress_rqrd_ind,
				old_references.academic_gown_size,
				new_references.academic_gown_size,
				old_references.academic_hat_size,
				new_references.academic_hat_size,
				old_references.guest_tickets_requested,
				new_references.guest_tickets_requested,
				old_references.guest_tickets_allocated,
				new_references.guest_tickets_allocated,
				old_references.guest_seats,
				new_references.guest_seats,
				old_references.fees_paid_ind,
				new_references.fees_paid_ind,
				old_references.last_updated_by,
				new_references.last_updated_by,
				old_references.last_update_date,
				new_references.last_update_date,
				old_references.special_requirements,
				new_references.special_requirements,
				old_references.comments,
				new_references.comments);
	ELSE
		IF IGS_GR_GEN_001.GRDP_DEL_GAC_HIST (
				old_references.person_id,
				old_references.create_dt,
				old_references.grd_cal_type,
				old_references.grd_ci_sequence_number,
				old_references.ceremony_number,
				old_references.award_course_cd,
				old_references.award_crs_version_number,
				old_references.award_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END AfterRowUpdate4;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_CRMN_ROUND_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.academic_gown_size = new_references.academic_gown_size)) OR
        ((new_references.academic_gown_size IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_MEASUREMENT_PKG.Get_PK_For_Validation (
        new_references.academic_gown_size
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.create_dt = new_references.create_dt) AND
         (old_references.award_course_cd = new_references.award_course_cd) AND
         (old_references.award_crs_version_number = new_references.award_crs_version_number) AND
         (old_references.award_cd = new_references.award_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.create_dt IS NULL) OR
         (new_references.award_course_cd IS NULL) OR
         (new_references.award_crs_version_number IS NULL) OR
         (new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_GRADUAND_PKG.Get_UK_For_Validation (
        new_references.person_id,
        new_references.create_dt,
        new_references.award_course_cd,
        new_references.award_crs_version_number,
        new_references.award_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.academic_hat_size = new_references.academic_hat_size)) OR
        ((new_references.academic_hat_size IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_MEASUREMENT_PKG.Get_PK_For_Validation (
        new_references.academic_hat_size
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

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
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

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
      IF NOT IGS_GR_AWD_CEREMONY_PKG.Get_UK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number,
        new_references.ceremony_number,
        new_references.award_course_cd,
        new_references.award_crs_version_number,
        new_references.award_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Uniqueness AS
  BEGIN
	IF Get_UK_For_Validation (
         NEW_REFERENCES.person_id,
         NEW_REFERENCES.create_dt,
         NEW_REFERENCES.grd_cal_type,
         NEW_REFERENCES.grd_ci_sequence_number,
         NEW_REFERENCES.ceremony_number,
         NEW_REFERENCES.award_course_cd,
         NEW_REFERENCES.award_crs_version_number,
         NEW_REFERENCES.award_cd) THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END;

  PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 ,
	Column_Value IN VARCHAR2
	) AS
	BEGIN
	    IF column_name is null then
	        NULL;
	    ELSIF upper(column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
		NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(column_value);
	    ELSIF upper(column_name) = 'US_GROUP_NUMBER' THEN
		NEW_REFERENCES.US_GROUP_NUMBER := IGS_GE_NUMBER.to_num(column_value) ;
	    ELSIF upper(column_name) = 'ORDER_IN_PRESENTATION' THEN
		NEW_REFERENCES.ORDER_IN_PRESENTATION := IGS_GE_NUMBER.to_num(column_value);
	    ELSIF upper(column_name) = 'ACADEMIC_DRESS_RQRD_IND' THEN
		NEW_REFERENCES.ACADEMIC_DRESS_RQRD_IND := column_value;
	    ELSIF upper(column_name) = 'GUEST_TICKETS_REQUESTED' THEN
		NEW_REFERENCES.GUEST_TICKETS_REQUESTED := IGS_GE_NUMBER.to_num(column_value);
	    ELSIF upper(column_name) = 'GUEST_TICKETS_ALLOCATED' THEN
		NEW_REFERENCES.GUEST_TICKETS_ALLOCATED := IGS_GE_NUMBER.to_num(column_value);
	    ELSIF upper(column_name) = 'ACADEMIC_GOWN_SIZE' THEN
		NEW_REFERENCES.ACADEMIC_GOWN_SIZE := column_value;
	    ELSIF upper(column_name) = 'ACADEMIC_HAT_SIZE' THEN
		NEW_REFERENCES.ACADEMIC_HAT_SIZE := column_value;
	    ELSIF upper(column_name) = 'AWARD_CD' THEN
		NEW_REFERENCES.AWARD_CD := column_value;
	    ELSIF upper(column_name) = 'AWARD_COURSE_CD' THEN
		NEW_REFERENCES.AWARD_COURSE_CD := column_value;
	    ELSIF upper(column_name) = 'FEES_PAID_IND' THEN
		NEW_REFERENCES.FEES_PAID_IND := column_value;
	    ELSIF upper(column_name) = 'GRADUAND_SEAT_NUMBER' THEN
		NEW_REFERENCES.GRADUAND_SEAT_NUMBER := column_value;
	    ELSIF upper(column_name) = 'GRD_CAL_TYPE' THEN
		NEW_REFERENCES.GRD_CAL_TYPE := column_value;
	    ELSIF upper(column_name) = 'GUEST_SEATS' THEN
		NEW_REFERENCES.GUEST_SEATS := column_value;
	    ELSIF upper(column_name) = 'NAME_ANNOUNCED' THEN
		NEW_REFERENCES.NAME_ANNOUNCED := column_value;
	    END IF;

	    IF upper(column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR column_name is null then
		IF NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER < 1 OR NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER > 999999 THEN
 			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	    END IF;
	    IF upper(column_name) = 'US_GROUP_NUMBER' OR column_name is null then
		IF NEW_REFERENCES.US_GROUP_NUMBER < 0 OR NEW_REFERENCES.US_GROUP_NUMBER > 999999 THEN
			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF ;
	    END IF;
	    IF upper(column_name) = 'ORDER_IN_PRESENTATION' OR column_name is null then
		IF NEW_REFERENCES.ORDER_IN_PRESENTATION < 1 OR NEW_REFERENCES.ORDER_IN_PRESENTATION > 9999 THEN
 			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	    END IF;
	    IF upper(column_name) = 'ACADEMIC_DRESS_RQRD_IND' OR column_name is null then
		IF NEW_REFERENCES.ACADEMIC_DRESS_RQRD_IND NOT IN ( 'Y' , 'N' ) THEN
 			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	    END IF;
	    IF upper(column_name) = 'GUEST_TICKETS_REQUESTED' OR column_name is null then
		IF NEW_REFERENCES.GUEST_TICKETS_REQUESTED < 0 OR NEW_REFERENCES.GUEST_TICKETS_REQUESTED > 999 THEN
			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	    END IF;
	    IF upper(column_name) = 'GUEST_TICKETS_ALLOCATED' OR column_name is null then
		IF NEW_REFERENCES.GUEST_TICKETS_ALLOCATED < 0 OR NEW_REFERENCES.GUEST_TICKETS_ALLOCATED > 999 THEN
 			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	    END IF;
    IF ((UPPER (column_name) = 'ACADEMIC_GOWN_SIZE') OR (column_name IS NULL)) THEN
      IF (new_references.ACADEMIC_GOWN_SIZE <> UPPER (new_references.ACADEMIC_GOWN_SIZE)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'ACADEMIC_HAT_SIZE') OR (column_name IS NULL)) THEN
      IF (new_references.ACADEMIC_HAT_SIZE <> UPPER (new_references.ACADEMIC_HAT_SIZE)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'AWARD_CD') OR (column_name IS NULL)) THEN
      IF (new_references.AWARD_CD <> UPPER (new_references.AWARD_CD)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'AWARD_COURSE_CD') OR (column_name IS NULL)) THEN
      IF (new_references.AWARD_COURSE_CD <> UPPER (new_references.AWARD_COURSE_CD)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
	    IF upper(column_name) = 'FEES_PAID_IND' OR column_name is null then
		IF NEW_REFERENCES.FEES_PAID_IND NOT IN ('Y', 'N') THEN
 			FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	    END IF;
    IF ((UPPER (column_name) = 'GRADUAND_SEAT_NUMBER') OR (column_name IS NULL)) THEN
      IF (new_references.GRADUAND_SEAT_NUMBER <> UPPER (new_references.GRADUAND_SEAT_NUMBER)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'GRD_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.GRD_CAL_TYPE <> UPPER (new_references.GRD_CAL_TYPE)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'GUEST_SEATS') OR (column_name IS NULL)) THEN
      IF (new_references.GUEST_SEATS <> UPPER (new_references.GUEST_SEATS)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'NAME_ANNOUNCED') OR (column_name IS NULL)) THEN
      IF (new_references.NAME_ANNOUNCED <> UPPER (new_references.NAME_ANNOUNCED)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
	END Check_Constraints;


  FUNCTION Get_PK_For_Validation (
        X_GAC_ID IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN
      WHERE    GAC_ID = X_GAC_ID
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
         x_person_id IN NUMBER,
         x_create_dt IN DATE,
         x_grd_cal_type IN VARCHAR2,
         x_grd_ci_sequence_number IN NUMBER,
         x_ceremony_number IN NUMBER,
         x_award_course_cd IN VARCHAR2,
         x_award_crs_version_number IN NUMBER,
         x_award_cd IN VARCHAR2
  ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN
      WHERE    person_id = x_person_id
	AND    create_dt = x_create_dt
	AND    grd_cal_type = x_grd_cal_type
	AND    grd_ci_sequence_number = x_grd_ci_sequence_number
	AND    ceremony_number = x_ceremony_number
	AND    NVL(award_course_cd,0) = NVL(x_award_course_cd,0)
	AND    NVL(award_crs_version_number,0) = NVL(x_award_crs_version_number,0)
	AND    award_cd = x_award_cd
	AND    (l_rowid is null or rowid <> l_rowid)
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


  PROCEDURE GET_FK_IGS_GR_CRMN_ROUND (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GAC_CRD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_CRMN_ROUND;

  PROCEDURE GET_FK_IGS_GE_MEASUREMENT (
    x_measurement_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN
      WHERE    academic_gown_size = x_measurement_cd
      OR       academic_hat_size = x_measurement_cd;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GAC_GOWN_MSR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_MEASUREMENT;

  PROCEDURE GET_UFK_IGS_GR_GRADUAND (
    x_person_id IN NUMBER,
    x_create_dt IN DATE,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN
      WHERE    person_id = x_person_id
      AND      create_dt = x_create_dt
      AND      award_course_cd = x_award_course_cd
      AND      award_crs_version_number = x_award_crs_version_number
      AND      award_cd = x_award_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GAC_GR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_GR_GRADUAND;

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
      FROM     IGS_GR_AWD_CRMN
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
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GAC_ACUSG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_AWD_CRM_US_GP;

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
      FROM     IGS_GR_AWD_CRMN
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
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GAC_AWC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_GR_AWD_CEREMONY;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_GAC_ID in NUMBER ,
    x_person_id IN NUMBER ,
    x_create_dt IN DATE ,
    x_grd_cal_type IN VARCHAR2 ,
    x_grd_ci_sequence_number IN NUMBER ,
    x_ceremony_number IN NUMBER ,
    x_award_course_cd IN VARCHAR2 ,
    x_award_crs_version_number IN NUMBER ,
    x_award_cd IN VARCHAR2 ,
    x_us_group_number IN NUMBER ,
    x_order_in_presentation IN NUMBER ,
    x_graduand_seat_number IN VARCHAR2 ,
    x_name_pronunciation IN VARCHAR2 ,
    x_name_announced IN VARCHAR2 ,
    x_academic_dress_rqrd_ind IN VARCHAR2 ,
    x_academic_gown_size IN VARCHAR2 ,
    x_academic_hat_size IN VARCHAR2 ,
    x_guest_tickets_requested IN NUMBER ,
    x_guest_tickets_allocated IN NUMBER ,
    x_guest_seats IN VARCHAR2 ,
    x_fees_paid_ind IN VARCHAR2 ,
    x_special_requirements IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_GAC_ID,
      x_person_id,
      x_create_dt,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_ceremony_number,
      x_award_course_cd,
      x_award_crs_version_number,
      x_award_cd,
      x_us_group_number,
      x_order_in_presentation,
      x_graduand_seat_number,
      x_name_pronunciation,
      x_name_announced,
      x_academic_dress_rqrd_ind,
      x_academic_gown_size,
      x_academic_hat_size,
      x_guest_tickets_requested,
      x_guest_tickets_allocated,
      x_guest_seats,
      x_fees_paid_ind,
      x_special_requirements,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE,
                               p_updating  => FALSE,
                               p_deleting  => FALSE);
      IF Get_PK_For_Validation (
         NEW_REFERENCES.gac_id) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_inserting => FALSE,
                               p_updating  => TRUE,
                               p_deleting  => FALSE);
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(NEW_REFERENCES.GAC_ID) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	check_uniqueness;
	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
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
      AfterRowInsertUpdate3 ( p_inserting => TRUE,
                              p_updating  => FALSE,
                              p_deleting  => FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate3 ( p_inserting => FALSE,
                              p_updating  => TRUE,
                              p_deleting  => FALSE);
      AfterRowUpdate4(p_inserting => FALSE,
                      p_updating  => TRUE,
                      p_deleting  => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowDelete2(p_inserting => FALSE,
                      p_updating  => FALSE,
                      p_deleting  => TRUE);
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GAC_ID in out NOCOPY NUMBER,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_GR_AWD_CRMN
      where GAC_ID = X_GAC_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin

  SELECT IGS_GR_AWD_CRMN_GAC_ID_S.NEXTVAL INTO X_GAC_ID FROM DUAL;

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
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1) then
    	X_REQUEST_ID := NULL;
    	X_PROGRAM_ID := NULL;
    	X_PROGRAM_APPLICATION_ID := NULL;
    	X_PROGRAM_UPDATE_DATE := NULL;
    else
    	X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    app_exception.raise_exception;
  end if;

Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_GAC_ID => X_GAC_ID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_us_group_number => X_US_GROUP_NUMBER,
    x_order_in_presentation => X_ORDER_IN_PRESENTATION,
    x_graduand_seat_number => X_GRADUAND_SEAT_NUMBER,
    x_name_pronunciation => X_NAME_PRONUNCIATION,
    x_name_announced => X_NAME_ANNOUNCED,
    x_academic_dress_rqrd_ind => NVL(X_ACADEMIC_DRESS_RQRD_IND, 'N'),
    x_academic_gown_size => X_ACADEMIC_GOWN_SIZE,
    x_academic_hat_size => X_ACADEMIC_HAT_SIZE,
    x_guest_tickets_requested => X_GUEST_TICKETS_REQUESTED,
    x_guest_tickets_allocated => X_GUEST_TICKETS_ALLOCATED,
    x_guest_seats => X_GUEST_SEATS,
    x_fees_paid_ind => NVL(X_FEES_PAID_IND, 'N'),
    x_special_requirements => X_SPECIAL_REQUIREMENTS,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_GR_AWD_CRMN (
    GRADUAND_SEAT_NUMBER,
    NAME_PRONUNCIATION,
    NAME_ANNOUNCED,
    ACADEMIC_DRESS_RQRD_IND,
    ACADEMIC_GOWN_SIZE,
    ACADEMIC_HAT_SIZE,
    GUEST_TICKETS_REQUESTED,
    GUEST_TICKETS_ALLOCATED,
    GUEST_SEATS,
    FEES_PAID_IND,
    SPECIAL_REQUIREMENTS,
    COMMENTS,
    GAC_ID,
    PERSON_ID,
    CREATE_DT,
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    US_GROUP_NUMBER,
    ORDER_IN_PRESENTATION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.GRADUAND_SEAT_NUMBER,
    NEW_REFERENCES.NAME_PRONUNCIATION,
    NEW_REFERENCES.NAME_ANNOUNCED,
    NEW_REFERENCES.ACADEMIC_DRESS_RQRD_IND,
    NEW_REFERENCES.ACADEMIC_GOWN_SIZE,
    NEW_REFERENCES.ACADEMIC_HAT_SIZE,
    NEW_REFERENCES.GUEST_TICKETS_REQUESTED,
    NEW_REFERENCES.GUEST_TICKETS_ALLOCATED,
    NEW_REFERENCES.GUEST_SEATS,
    NEW_REFERENCES.FEES_PAID_IND,
    NEW_REFERENCES.SPECIAL_REQUIREMENTS,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.GAC_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CEREMONY_NUMBER,
    NEW_REFERENCES.AWARD_COURSE_CD,
    NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.US_GROUP_NUMBER,
    NEW_REFERENCES.ORDER_IN_PRESENTATION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
  X_GAC_ID in NUMBER,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER
) AS
  cursor c1 is select
      GRADUAND_SEAT_NUMBER,
      NAME_PRONUNCIATION,
      NAME_ANNOUNCED,
      ACADEMIC_DRESS_RQRD_IND,
      ACADEMIC_GOWN_SIZE,
      ACADEMIC_HAT_SIZE,
      GUEST_TICKETS_REQUESTED,
      GUEST_TICKETS_ALLOCATED,
      GUEST_SEATS,
      FEES_PAID_IND,
      SPECIAL_REQUIREMENTS,
      COMMENTS,
      PERSON_ID,
      CREATE_DT,
      GRD_CAL_TYPE,
      GRD_CI_SEQUENCE_NUMBER,
      CEREMONY_NUMBER,
      AWARD_COURSE_CD,
      AWARD_CRS_VERSION_NUMBER,
      AWARD_CD,
      US_GROUP_NUMBER,
      ORDER_IN_PRESENTATION
    from IGS_GR_AWD_CRMN
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

      if ( ((tlinfo.GRADUAND_SEAT_NUMBER = X_GRADUAND_SEAT_NUMBER)
           OR ((tlinfo.GRADUAND_SEAT_NUMBER is null)
               AND (X_GRADUAND_SEAT_NUMBER is null)))
      AND ((tlinfo.NAME_PRONUNCIATION = X_NAME_PRONUNCIATION)
           OR ((tlinfo.NAME_PRONUNCIATION is null)
               AND (X_NAME_PRONUNCIATION is null)))
      AND ((tlinfo.NAME_ANNOUNCED = X_NAME_ANNOUNCED)
           OR ((tlinfo.NAME_ANNOUNCED is null)
               AND (X_NAME_ANNOUNCED is null)))
      AND (tlinfo.ACADEMIC_DRESS_RQRD_IND = X_ACADEMIC_DRESS_RQRD_IND)
      AND ((tlinfo.ACADEMIC_GOWN_SIZE = X_ACADEMIC_GOWN_SIZE)
           OR ((tlinfo.ACADEMIC_GOWN_SIZE is null)
               AND (X_ACADEMIC_GOWN_SIZE is null)))
      AND ((tlinfo.ACADEMIC_HAT_SIZE = X_ACADEMIC_HAT_SIZE)
           OR ((tlinfo.ACADEMIC_HAT_SIZE is null)
               AND (X_ACADEMIC_HAT_SIZE is null)))
      AND ((tlinfo.GUEST_TICKETS_REQUESTED = X_GUEST_TICKETS_REQUESTED)
           OR ((tlinfo.GUEST_TICKETS_REQUESTED is null)
               AND (X_GUEST_TICKETS_REQUESTED is null)))
      AND ((tlinfo.GUEST_TICKETS_ALLOCATED = X_GUEST_TICKETS_ALLOCATED)
           OR ((tlinfo.GUEST_TICKETS_ALLOCATED is null)
               AND (X_GUEST_TICKETS_ALLOCATED is null)))
      AND ((tlinfo.GUEST_SEATS = X_GUEST_SEATS)
           OR ((tlinfo.GUEST_SEATS is null)
               AND (X_GUEST_SEATS is null)))
      AND (tlinfo.FEES_PAID_IND = X_FEES_PAID_IND)
      AND ((tlinfo.SPECIAL_REQUIREMENTS = X_SPECIAL_REQUIREMENTS)
           OR ((tlinfo.SPECIAL_REQUIREMENTS is null)
               AND (X_SPECIAL_REQUIREMENTS is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.CREATE_DT = X_CREATE_DT)
      AND (tlinfo.GRD_CAL_TYPE = X_GRD_CAL_TYPE)
      AND (tlinfo.GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER)
      AND (tlinfo.CEREMONY_NUMBER = X_CEREMONY_NUMBER)
      AND ((tlinfo.AWARD_COURSE_CD = X_AWARD_COURSE_CD)
           OR ((tlinfo.AWARD_COURSE_CD is null)
               AND (X_AWARD_COURSE_CD is null)))
      AND ((tlinfo.AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER)
           OR ((tlinfo.AWARD_CRS_VERSION_NUMBER is null)
               AND (X_AWARD_CRS_VERSION_NUMBER is null)))
      AND (tlinfo.AWARD_CD = X_AWARD_CD)
      AND ((tlinfo.US_GROUP_NUMBER = X_US_GROUP_NUMBER)
           OR ((tlinfo.US_GROUP_NUMBER is null)
               AND (X_US_GROUP_NUMBER is null)))
      AND ((tlinfo.ORDER_IN_PRESENTATION = X_ORDER_IN_PRESENTATION)
           OR ((tlinfo.ORDER_IN_PRESENTATION is null)
               AND (X_ORDER_IN_PRESENTATION is null)))
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
  X_GAC_ID in NUMBER,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_MODE in VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    app_exception.raise_exception;
  end if;

Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_GAC_ID => X_GAC_ID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_us_group_number => X_US_GROUP_NUMBER,
    x_order_in_presentation => X_ORDER_IN_PRESENTATION,
    x_graduand_seat_number => X_GRADUAND_SEAT_NUMBER,
    x_name_pronunciation => X_NAME_PRONUNCIATION,
    x_name_announced => X_NAME_ANNOUNCED,
    x_academic_dress_rqrd_ind => X_ACADEMIC_DRESS_RQRD_IND,
    x_academic_gown_size => X_ACADEMIC_GOWN_SIZE,
    x_academic_hat_size => X_ACADEMIC_HAT_SIZE,
    x_guest_tickets_requested => X_GUEST_TICKETS_REQUESTED,
    x_guest_tickets_allocated => X_GUEST_TICKETS_ALLOCATED,
    x_guest_seats => X_GUEST_SEATS,
    x_fees_paid_ind => X_FEES_PAID_IND,
    x_special_requirements => X_SPECIAL_REQUIREMENTS,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  if (X_MODE = 'R') then
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1) then
    	X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
    	X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
    	X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    	X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
    	X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  end if;

  update IGS_GR_AWD_CRMN set
    GRADUAND_SEAT_NUMBER = NEW_REFERENCES.GRADUAND_SEAT_NUMBER,
    NAME_PRONUNCIATION = NEW_REFERENCES.NAME_PRONUNCIATION,
    NAME_ANNOUNCED = NEW_REFERENCES.NAME_ANNOUNCED,
    ACADEMIC_DRESS_RQRD_IND = NEW_REFERENCES.ACADEMIC_DRESS_RQRD_IND,
    ACADEMIC_GOWN_SIZE = NEW_REFERENCES.ACADEMIC_GOWN_SIZE,
    ACADEMIC_HAT_SIZE = NEW_REFERENCES.ACADEMIC_HAT_SIZE,
    GUEST_TICKETS_REQUESTED = NEW_REFERENCES.GUEST_TICKETS_REQUESTED,
    GUEST_TICKETS_ALLOCATED = NEW_REFERENCES.GUEST_TICKETS_ALLOCATED,
    GUEST_SEATS = NEW_REFERENCES.GUEST_SEATS,
    FEES_PAID_IND = NEW_REFERENCES.FEES_PAID_IND,
    SPECIAL_REQUIREMENTS = NEW_REFERENCES.SPECIAL_REQUIREMENTS,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    PERSON_ID = NEW_REFERENCES.PERSON_ID,
    CREATE_DT = NEW_REFERENCES.CREATE_DT,
    GRD_CAL_TYPE = NEW_REFERENCES.GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER = NEW_REFERENCES.CEREMONY_NUMBER,
    AWARD_COURSE_CD = NEW_REFERENCES.AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER = NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    AWARD_CD = NEW_REFERENCES.AWARD_CD,
    US_GROUP_NUMBER = NEW_REFERENCES.US_GROUP_NUMBER,
    ORDER_IN_PRESENTATION = NEW_REFERENCES.ORDER_IN_PRESENTATION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
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
  X_GAC_ID in out NOCOPY NUMBER,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_GR_AWD_CRMN
     where GAC_ID = X_GAC_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GAC_ID,
     X_GRADUAND_SEAT_NUMBER,
     X_NAME_PRONUNCIATION,
     X_NAME_ANNOUNCED,
     X_ACADEMIC_DRESS_RQRD_IND,
     X_ACADEMIC_GOWN_SIZE,
     X_ACADEMIC_HAT_SIZE,
     X_GUEST_TICKETS_REQUESTED,
     X_GUEST_TICKETS_ALLOCATED,
     X_GUEST_SEATS,
     X_FEES_PAID_IND,
     X_SPECIAL_REQUIREMENTS,
     X_COMMENTS,
     X_PERSON_ID,
     X_CREATE_DT,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_CEREMONY_NUMBER,
     X_AWARD_COURSE_CD,
     X_AWARD_CRS_VERSION_NUMBER,
     X_AWARD_CD,
     X_US_GROUP_NUMBER,
     X_ORDER_IN_PRESENTATION,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GAC_ID,
   X_GRADUAND_SEAT_NUMBER,
   X_NAME_PRONUNCIATION,
   X_NAME_ANNOUNCED,
   X_ACADEMIC_DRESS_RQRD_IND,
   X_ACADEMIC_GOWN_SIZE,
   X_ACADEMIC_HAT_SIZE,
   X_GUEST_TICKETS_REQUESTED,
   X_GUEST_TICKETS_ALLOCATED,
   X_GUEST_SEATS,
   X_FEES_PAID_IND,
   X_SPECIAL_REQUIREMENTS,
   X_COMMENTS,
   X_PERSON_ID,
   X_CREATE_DT,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_CEREMONY_NUMBER,
   X_AWARD_COURSE_CD,
   X_AWARD_CRS_VERSION_NUMBER,
   X_AWARD_CD,
   X_US_GROUP_NUMBER,
   X_ORDER_IN_PRESENTATION,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  delete from IGS_GR_AWD_CRMN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

end DELETE_ROW;

end IGS_GR_AWD_CRMN_PKG;

/
