--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSENC_EFFCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSENC_EFFCT_PKG" AS
 /* $Header: IGSNI16B.pls 115.9 2003/02/25 05:14:20 npalanis ship $ */

  l_rowid VARCHAR2(25);

  old_references IGS_PE_PERSENC_EFFCT%RowType;

  new_references IGS_PE_PERSENC_EFFCT%RowType;



  PROCEDURE Set_Column_Values (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2,

    x_person_id IN NUMBER,

    x_encumbrance_type IN VARCHAR2,

    x_pen_start_dt IN DATE,

    x_s_encmb_effect_type IN VARCHAR2,

    x_pee_start_dt IN DATE,

    x_sequence_number IN NUMBER,

    x_expiry_dt IN DATE,

    x_course_cd IN VARCHAR2,

    x_restricted_enrolment_cp IN NUMBER,

    x_restricted_attendance_type IN VARCHAR2,

    x_creation_date IN DATE,

    x_created_by IN NUMBER,

    x_last_update_date IN DATE,

    x_last_updated_by IN NUMBER,

    x_last_update_login IN NUMBER

  ) AS



    CURSOR cur_old_ref_values IS

      SELECT   *

      FROM     IGS_PE_PERSENC_EFFCT

      WHERE    rowid = x_rowid;



  BEGIN



    l_rowid := x_rowid;



    -- Code for setting the Old and New Reference Values.

    -- Populate Old Values.

    Open cur_old_ref_values;

    Fetch cur_old_ref_values INTO old_references;

    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN

      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;


      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_old_ref_values;



    -- Populate New Values.

    new_references.person_id := x_person_id;

    new_references.encumbrance_type := x_encumbrance_type;

    new_references.pen_start_dt := x_pen_start_dt;

    new_references.s_encmb_effect_type := x_s_encmb_effect_type;

    new_references.pee_start_dt := x_pee_start_dt;

    new_references.sequence_number := x_sequence_number;

    new_references.expiry_dt := x_expiry_dt;

    new_references.course_cd := x_course_cd;

    new_references.restricted_enrolment_cp := x_restricted_enrolment_cp;

    new_references.restricted_attendance_type := x_restricted_attendance_type;

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



  PROCEDURE BeforeRowInsertUpdate1(

    p_inserting IN BOOLEAN,

    p_updating IN BOOLEAN,

    p_deleting IN BOOLEAN

    ) AS

CURSOR cur_hold_ovr IS
	SELECT HOLD_OLD_END_DT
	FROM igs_pe_hold_rel_ovr HOVR, IGS_EN_ELGB_OVR_ALL OVR
	WHERE OVR.ELGB_OVERRIDE_ID =HOVR.ELGB_OVERRIDE_ID  AND
	OVR.PERSON_ID = new_references.PERSON_ID AND new_references.pee_start_dt = HOVR.START_DATE
	AND new_references.encumbrance_typE = HOVR.HOLD_TYPE;

	l_hold_old_end_date DATE;
v_message_name  varchar2(30);

  BEGIN

	-- Validate ENCUMBRANCE EFFECT TYPE.

	-- Closed indicator.

        IF p_inserting OR (p_updating AND (old_references.s_encmb_effect_type <> new_references.s_encmb_effect_type)) THEN

		IF IGS_EN_VAL_ETDE.enrp_val_seet_closed (

				new_references.s_encmb_effect_type,

				v_message_name ) = FALSE THEN

			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Validate that start date is not less than the current date.

	IF (new_references.pee_start_dt IS NOT NULL) THEN

		IF p_inserting OR (p_updating AND

			(NVL(old_references.pee_start_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))

			<> new_references.pee_start_dt)) THEN

			IF IGS_EN_VAL_PCE.enrp_val_encmb_dt (

				 	new_references.pee_start_dt,

			 		v_message_name ) = FALSE THEN

				 Fnd_Message.Set_Name('IGS', v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

			END IF;

		END IF;

	END IF;

	-- Validate that start date is not less than the parent IGS_PE_PERSON

	-- Encumbrance start date.

	IF p_inserting THEN

		IF IGS_EN_VAL_PCE.enrp_val_encmb_dts (

			 	new_references.pen_start_dt,

			 	new_references.pee_start_dt,

			 	v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Validate that if expiry date is specified, then expiry date is not

	-- less than the start date.

   OPEN cur_hold_ovr;
    FETCH cur_hold_ovr INTO l_hold_old_end_date;
    IF  cur_hold_ovr%NOTFOUND THEN
      l_hold_old_end_date := new_references.expiry_dt+1;
    END IF;
    CLOSE cur_hold_ovr;

    IF new_references.expiry_dt <>  l_hold_old_end_date THEN
	IF (new_references.expiry_dt IS NOT NULL) THEN

		IF p_inserting OR (p_updating AND

			(NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))

			<> new_references.expiry_dt)) THEN

			IF IGS_EN_VAL_PCE.enrp_val_strt_exp_dt (

			 	new_references.pee_start_dt,

			 	new_references.expiry_dt,

			 	v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

			END IF;
			IF IGS_EN_VAL_PCE.enrp_val_encmb_dt (

			 	new_references.expiry_dt,

			 	v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
			END IF;

		END IF;
	END IF;
     END IF;

	-- Validate that if the encumbrance effect type applies to a IGS_PS_COURSE, that the

	-- IGS_PE_PERSON is enrolled in a IGS_PS_COURSE.

	IF p_inserting THEN

		IF IGS_EN_VAL_PEE.enrp_val_pee_enrol (

			 	new_references.person_id,

			 	new_references.s_encmb_effect_type,

			 	v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Validate IGS_PE_PERSON has an enrolment in the nominated IGS_PS_COURSE code.

	IF (p_inserting OR p_updating) AND

		(new_references.course_cd IS NOT NULL) AND

		(NVL(old_references.course_cd, 'NULL') <>  new_references.course_cd) THEN

		IF IGS_EN_VAL_PEE.enrp_val_pee_crs (

				new_references.person_id,

				new_references.course_cd,

				v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', 'IGS_EN_CAN_SPEC_RESTR_ATT');
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Validate that restricted attendance type can be specified for the

	-- encumbrance  effect type.

	IF (p_inserting OR p_updating) AND

		(new_references.restricted_attendance_type IS NOT NULL) AND

		(new_references.s_encmb_effect_type <> 'RSTR_AT_TY') THEN

		Fnd_Message.Set_Name('IGS', v_message_name);
		IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
	END IF;

	-- Validate that restricted attendance type is not closed.

	IF new_references.restricted_attendance_type IS NOT NULL AND

		(NVL(old_references.restricted_attendance_type, 'NULL') <>

                                           new_references.restricted_attendance_type) THEN

		IF IGS_EN_VAL_PEE.enrp_val_att_closed (

				new_references.restricted_attendance_type,

				v_message_name ) = FALSE THEN

			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;

	END IF;

	-- Validate IGS_PE_PERSON does not already have an attendance type restriction on the

	-- IGS_PS_COURSE.

	IF (p_inserting OR p_updating) AND

		(new_references.course_cd IS NOT NULL) AND

		(NVL(old_references.course_cd, 'NULL') <>  new_references.course_cd) AND

		 (new_references.s_encmb_effect_type = 'RSTR_AT_TY') THEN

		IF IGS_EN_VAL_PEE.enrp_val_pee_crs_att (

				new_references.person_id,

				new_references.s_encmb_effect_type,

				nvl(new_references.sequence_number,0),

				new_references.course_cd,

				v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Validate that restricted enrolment load can be specified for the encumbrance

	-- effect type.

	IF (p_inserting OR p_updating) AND

		(new_references.restricted_enrolment_cp > 0) AND

		(new_references.s_encmb_effect_type <> 'RSTR_GE_CP' AND

		 new_references.s_encmb_effect_type <> 'RSTR_LE_CP') THEN

		Fnd_Message.Set_Name('IGS','IGS_EN_CANT_SPEC_ENRL_CRDT');
		IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

	END IF;

	-- Validate IGS_PE_PERSON does not already have a credit point restriction on the

	-- IGS_PS_COURSE.

	IF (p_inserting OR p_updating) AND

		(new_references.course_cd IS NOT NULL) AND

		(NVL(old_references.course_cd, 'NULL') <>  new_references.course_cd) AND

		 (new_references.s_encmb_effect_type IN ('RSTR_LE_CP','RSTR_GE_CP')) THEN

		IF IGS_EN_VAL_PEE.enrp_val_pee_crs_cp (

				new_references.person_id,

				new_references.s_encmb_effect_type,

				nvl(new_references.sequence_number,0),

				new_references.course_cd,

				v_message_name ) = FALSE THEN

			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

		END IF;

	END IF;





  END BeforeRowInsertUpdate1;



  -- Trigger description :-

  -- "OSS_TST".trg_pee_ar_iu

  -- AFTER INSERT OR UPDATE

  -- ON IGS_PE_PERSENC_EFFCT

  -- FOR EACH ROW



  PROCEDURE AfterRowInsertUpdate2(

    p_inserting IN BOOLEAN,

    p_updating IN BOOLEAN,

    p_deleting IN BOOLEAN

    ) AS

	v_message_name  varchar2(30);

	v_rowid_saved	BOOLEAN := FALSE;

  BEGIN

	-- Validate for open ended IGS_PE_PERSON encumbrance effect records.

	IF new_references.expiry_dt IS NULL THEN

		 -- Save the rowid of the current row.

		v_rowid_saved := TRUE;

		-- Cannot call enrp_val_pee_open because trigger will be mutating.

	END IF;

	IF p_updating AND

		 (NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>

		  NVL(new_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN

			-- Cannot call IGS_EN_GEN_011.ENRP_SET_PEN_EXPRY because trigger will be mutating.

			 -- Save the rowid of the current row.

			IF v_rowid_saved = FALSE THEN

				v_rowid_saved := TRUE;

			END IF;

	END IF;

	IF v_rowid_saved = TRUE THEN

		-- Based on this flag we need to do validation

  		-- Validate for open ended IGS_PE_PERS_ENCUMB effect records.

  		IF new_references.expiry_dt IS NULL THEN

  			IF IGS_EN_VAL_PEE.enrp_val_pee_open (

  					new_references.person_id,

  					new_references.encumbrance_type,

  					new_references.pen_start_dt,

  					new_references.s_encmb_effect_type,

  					new_references.sequence_number,

  					new_references.course_cd,

  					v_message_name) = FALSE THEN

  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

  			END IF;

  		END IF;

  		-- Set the expiry date of the child records if the expiry  date of the

  		-- effect has been updated.

  		IF new_references.expiry_dt IS NOT NULL THEN

  			IGS_EN_GEN_011.ENRP_SET_PEE_EXPRY (new_references.person_id,

  					     new_references.encumbrance_type,

  					     new_references.pen_start_dt,

  					     new_references.s_encmb_effect_type,

  					     new_references.pee_start_dt,

  					     new_references.sequence_number,

  					     new_references.expiry_dt,

  					     v_message_name);

			IF v_message_name IS NOT NULL  THEN

  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
  			END IF;

  		END IF;

  		-- Set the expiry date of the parent person encumbrance record if the expiry

  		-- date of the effect has been updated and no other active effect records

  		-- remain.

  		IF new_references.expiry_dt IS NOT NULL AND igs_pe_pers_encumb_pkg.initialised IS NULL THEN

  			IGS_EN_GEN_011.ENRP_SET_PEN_EXPRY (new_references.person_id,

  					     new_references.encumbrance_type,

  					     new_references.pen_start_dt,

  					     new_references.sequence_number,

  					     new_references.expiry_dt,

  					     v_message_name);

  			--IF v_message_name <> 0 THEN
  			IF v_message_name IS NOT NULL THEN

  				Fnd_Message.Set_Name('IGS', v_message_name);
  				IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;

  			END IF;

  		END IF;

	END IF;



  END AfterRowInsertUpdate2;



  -- Trigger description :-

  -- "OSS_TST".trg_pee_as_iu

  -- AFTER INSERT OR UPDATE

  -- ON IGS_PE_PERSENC_EFFCT






    PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) =  'COURSE_CD' then
     new_references.course_cd:= column_value;
 ELSIF upper(Column_name) = 'ENCUMBRANCE_TYPE' then
     new_references.encumbrance_type:= column_value;
 ELSIF upper(Column_name) = 'RESTRICTED_ATTENDANCE_TYPE' then
     new_references.restricted_attendance_type:= column_value;
 ELSIF upper(Column_name) = 'S_ENCMB_EFFECT_TYPE' then
     new_references.s_encmb_effect_type:= column_value;
 ELSIF upper(Column_name) = 'RESTRICTED_ENROLMENT_CP' then
     new_references.restricted_enrolment_cp := IGS_GE_NUMBER.to_num(column_value);
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

IF upper(column_name) = 'ENCUMBRANCE_TYPE' OR
     column_name is null Then
     IF new_references.encumbrance_type <>
UPPER(new_references.encumbrance_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 IF upper(column_name) = 'RESTRICTED_ATTENDANCE_TYPE' OR
     column_name is null Then
     IF new_references.restricted_attendance_type <>
UPPER(new_references.restricted_attendance_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'S_ENCMB_EFFECT_TYPE' OR
     column_name is null Then
     IF new_references.s_encmb_effect_type<>
UPPER(new_references.s_encmb_effect_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'RESTRICTED_ENROLMENT_CP' OR
     column_name is null Then
     IF new_references.restricted_enrolment_cp < 0 OR
          new_references.restricted_enrolment_cp > 999.999  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;


 END Check_Constraints;





  PROCEDURE Check_Parent_Existance AS

  BEGIN



    IF (((old_references.restricted_attendance_type = new_references.restricted_attendance_type)) OR

        ((new_references.restricted_attendance_type IS NULL))) THEN

      NULL;

    ELSE
       IF  NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
         new_references.restricted_attendance_type
         ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;


    END IF;



    IF (((old_references.person_id = new_references.person_id) AND

         (old_references.encumbrance_type = new_references.encumbrance_type) AND

         (old_references.pen_start_dt = new_references.pen_start_dt)) OR

        ((new_references.person_id IS NULL) OR

         (new_references.encumbrance_type IS NULL) OR

         (new_references.pen_start_dt IS NULL))) THEN

      NULL;

    ELSE


        IF  NOT IGS_PE_PERS_ENCUMB_PKG.Get_PK_For_Validation (
         new_references.person_id,
        new_references.encumbrance_type,
        new_references.pen_start_dt ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;

    END IF;



    IF (((old_references.s_encmb_effect_type = new_references.s_encmb_effect_type)) OR

        ((new_references.s_encmb_effect_type IS NULL))) THEN

      NULL;

    ELSE


       IF  NOT IGS_EN_ENCMB_EFCTTYP_Pkg.Get_PK_For_Validation (
         new_references.s_encmb_effect_type         ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;

    END IF;



  END Check_Parent_Existance;



  PROCEDURE Check_Child_Existance AS
 /*
  ||  Created By : prchandr
  ||  Created On : 04-APR-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        04-OCT-2002      Bug NO: 2600842
  ||                                  Added the call igs_pe_fund_excl_pkg.get_fk_igs_pe_persenc_effct
  ||  (reverse chronological order - newest change first)
  */
  BEGIN



    IGS_PE_COURSE_EXCL_PKG.GET_FK_IGS_PE_PERSENC_EFFCT (

      old_references.person_id,

      old_references.encumbrance_type,

      old_references.pen_start_dt,

      old_references.s_encmb_effect_type,

      old_references.pee_start_dt,

      old_references.sequence_number

      );



    IGS_PE_CRS_GRP_EXCL_PKG.GET_FK_IGS_PE_PERSENC_EFFCT (

      old_references.person_id,

      old_references.encumbrance_type,

      old_references.pen_start_dt,

      old_references.s_encmb_effect_type,

      old_references.pee_start_dt,

      old_references.sequence_number

      );



    IGS_PE_PERS_UNT_EXCL_PKG.GET_FK_IGS_PE_PERSENC_EFFCT (

      old_references.person_id,

      old_references.encumbrance_type,

      old_references.pen_start_dt,

      old_references.s_encmb_effect_type,

      old_references.pee_start_dt,

      old_references.sequence_number

      );



    IGS_PE_UNT_REQUIRMNT_PKG.GET_FK_IGS_PE_PERSENC_EFFCT (

      old_references.person_id,

      old_references.encumbrance_type,

      old_references.pen_start_dt,

      old_references.s_encmb_effect_type,

      old_references.pee_start_dt,

      old_references.sequence_number

      );



    IGS_PE_UNT_SET_EXCL_PKG.GET_FK_IGS_PE_PERSENC_EFFCT (

      old_references.person_id,

      old_references.encumbrance_type,

      old_references.pen_start_dt,

      old_references.s_encmb_effect_type,

      old_references.pee_start_dt,

      old_references.sequence_number

      );

    IGS_PE_FUND_EXCL_PKG.GET_FK_IGS_PE_PERSENC_EFFCT (

      old_references.person_id,

      old_references.encumbrance_type,

      old_references.pen_start_dt,

      old_references.s_encmb_effect_type,

      old_references.pee_start_dt,

      old_references.sequence_number

      );

  END Check_Child_Existance;



  FUNCTION Get_PK_For_Validation (

    x_person_id IN NUMBER,

    x_encumbrance_type IN VARCHAR2,

    x_pen_start_dt IN DATE,

    x_s_encmb_effect_type IN VARCHAR2,

    x_pee_start_dt IN DATE,

    x_sequence_number IN NUMBER

    ) RETURN BOOLEAN AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_PERSENC_EFFCT

      WHERE    person_id = x_person_id

      AND      encumbrance_type = x_encumbrance_type

      AND      pen_start_dt = x_pen_start_dt

      AND      s_encmb_effect_type = x_s_encmb_effect_type

      AND      pee_start_dt = x_pee_start_dt

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



  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (

    x_attendance_type IN VARCHAR2

    ) AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_PERSENC_EFFCT

      WHERE    restricted_attendance_type = x_attendance_type ;



    lv_rowid cur_rowid%RowType;



  BEGIN



    Open cur_rowid;

    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN

      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PEE_ATT_FK');

       IGS_GE_MSG_STACK.ADD;

      Close cur_rowid;
        App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_rowid;



  END GET_FK_IGS_EN_ATD_TYPE;



  PROCEDURE GET_FK_IGS_PE_PERS_ENCUMB (

    x_person_id IN NUMBER,

    x_encumbrance_type IN VARCHAR2,

    x_start_dt IN DATE
    ) AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_PERSENC_EFFCT

      WHERE    person_id = x_person_id

      AND      encumbrance_type = x_encumbrance_type

      AND      pen_start_dt = x_start_dt ;



    lv_rowid cur_rowid%RowType;



  BEGIN



    Open cur_rowid;

    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN

      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PEE_PEN_FK');

       IGS_GE_MSG_STACK.ADD;

      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_rowid;



  END GET_FK_IGS_PE_PERS_ENCUMB;


  PROCEDURE Before_DML (

    p_action IN VARCHAR2,

    x_rowid IN  VARCHAR2,

    x_person_id IN NUMBER,

    x_encumbrance_type IN VARCHAR2,

    x_pen_start_dt IN DATE,

    x_s_encmb_effect_type IN VARCHAR2,

    x_pee_start_dt IN DATE,

    x_sequence_number IN NUMBER,

    x_expiry_dt IN DATE,

    x_course_cd IN VARCHAR2,

    x_restricted_enrolment_cp IN NUMBER,

    x_restricted_attendance_type IN VARCHAR2,

    x_creation_date IN DATE,

    x_created_by IN NUMBER,

    x_last_update_date IN DATE,

    x_last_updated_by IN NUMBER,

    x_last_update_login IN NUMBER

  ) AS

  BEGIN



    Set_Column_Values (

      p_action,

      x_rowid,

      x_person_id,

      x_encumbrance_type,

      x_pen_start_dt,

      x_s_encmb_effect_type,

      x_pee_start_dt,

      x_sequence_number,

      x_expiry_dt,

      x_course_cd,

      x_restricted_enrolment_cp,

      x_restricted_attendance_type,

      x_creation_date,

      x_created_by,

      x_last_update_date,

      x_last_updated_by,

      x_last_update_login

    );



    IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdate1 (
	        p_inserting => TRUE,
			p_updating  => FALSE,
            p_deleting	=> FALSE);

      IF  Get_PK_For_Validation (
          new_references.person_id ,
    new_references.encumbrance_type ,
    new_references.pen_start_dt ,
    new_references.s_encmb_effect_type,
    new_references.pee_start_dt,
    new_references.sequence_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.

	        BeforeRowInsertUpdate1 (
	        p_inserting => FALSE,
			p_updating  => TRUE,
            p_deleting	=> FALSE);

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.

       Check_Child_Existance; -- if procedure present
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.person_id ,
    new_references.encumbrance_type ,
    new_references.pen_start_dt ,
    new_references.s_encmb_effect_type,
    new_references.pee_start_dt,
    new_references.sequence_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints; -- if procedure present
ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance; -- if procedure present
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

      AfterRowInsertUpdate2 (
            p_inserting => TRUE,
			p_updating  => FALSE,
            p_deleting	=> FALSE);

      --AfterStmtInsertUpdate3 ( p_inserting => TRUE );

    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to After Update.

      AfterRowInsertUpdate2 (
	        p_inserting => FALSE,
			p_updating  => TRUE,
            p_deleting	=> FALSE);

    ELSIF (p_action = 'DELETE') THEN

      -- Call all the procedures related to After Delete.

      Null;

    END IF;



  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPIRY_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_PE_PERSENC_EFFCT
      where PERSON_ID = X_PERSON_ID
      and ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE
      and PEN_START_DT = X_PEN_START_DT
      and S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE
      and PEE_START_DT = X_PEE_START_DT
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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

  p_action=>'INSERT',

  x_rowid=>X_ROWID,

  x_course_cd=>X_COURSE_CD,

  x_encumbrance_type=>X_ENCUMBRANCE_TYPE,

  x_expiry_dt=>X_EXPIRY_DT,

  x_pee_start_dt=>X_PEE_START_DT,

  x_pen_start_dt=>X_PEN_START_DT,

  x_person_id=>X_PERSON_ID,

  x_restricted_attendance_type=>X_RESTRICTED_ATTENDANCE_TYPE,

  x_restricted_enrolment_cp=> NVL(X_RESTRICTED_ENROLMENT_CP,0),

  x_s_encmb_effect_type=>X_S_ENCMB_EFFECT_TYPE,

  x_sequence_number=>X_SEQUENCE_NUMBER,

  x_creation_date=>X_LAST_UPDATE_DATE,

  x_created_by=>X_LAST_UPDATED_BY,

  x_last_update_date=>X_LAST_UPDATE_DATE,

  x_last_updated_by=>X_LAST_UPDATED_BY,

  x_last_update_login=>X_LAST_UPDATE_LOGIN

  );


  insert into IGS_PE_PERSENC_EFFCT (
    PERSON_ID,
    ENCUMBRANCE_TYPE,
    PEN_START_DT,
    S_ENCMB_EFFECT_TYPE,
    PEE_START_DT,
    SEQUENCE_NUMBER,
    EXPIRY_DT,
    COURSE_CD,
    RESTRICTED_ENROLMENT_CP,
    RESTRICTED_ATTENDANCE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ENCUMBRANCE_TYPE,
    NEW_REFERENCES.PEN_START_DT,
    NEW_REFERENCES.S_ENCMB_EFFECT_TYPE,
    NEW_REFERENCES.PEE_START_DT,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.RESTRICTED_ENROLMENT_CP,
    NEW_REFERENCES.RESTRICTED_ATTENDANCE_TYPE,
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

  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPIRY_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2
) AS
  cursor c1 is select
      EXPIRY_DT,
      COURSE_CD,
      RESTRICTED_ENROLMENT_CP,
      RESTRICTED_ATTENDANCE_TYPE
    from IGS_PE_PERSENC_EFFCT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.RESTRICTED_ENROLMENT_CP = X_RESTRICTED_ENROLMENT_CP)
           OR ((tlinfo.RESTRICTED_ENROLMENT_CP is null)
               AND (X_RESTRICTED_ENROLMENT_CP is null)))
      AND ((tlinfo.RESTRICTED_ATTENDANCE_TYPE = X_RESTRICTED_ATTENDANCE_TYPE)
           OR ((tlinfo.RESTRICTED_ATTENDANCE_TYPE is null)
               AND (X_RESTRICTED_ATTENDANCE_TYPE is null)))
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
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPIRY_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
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

  p_action=>'UPDATE',

  x_rowid=>X_ROWID,

  x_course_cd=>X_COURSE_CD,

  x_encumbrance_type=>X_ENCUMBRANCE_TYPE,

  x_expiry_dt=>X_EXPIRY_DT,

  x_pee_start_dt=>X_PEE_START_DT,

  x_pen_start_dt=>X_PEN_START_DT,

  x_person_id=>X_PERSON_ID,

  x_restricted_attendance_type=>X_RESTRICTED_ATTENDANCE_TYPE,

  x_restricted_enrolment_cp=>X_RESTRICTED_ENROLMENT_CP,

  x_s_encmb_effect_type=>X_S_ENCMB_EFFECT_TYPE,

  x_sequence_number=>X_SEQUENCE_NUMBER,

  x_creation_date=>X_LAST_UPDATE_DATE,

  x_created_by=>X_LAST_UPDATED_BY,

  x_last_update_date=>X_LAST_UPDATE_DATE,

  x_last_updated_by=>X_LAST_UPDATED_BY,

  x_last_update_login=>X_LAST_UPDATE_LOGIN

  );


  update IGS_PE_PERSENC_EFFCT set
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    RESTRICTED_ENROLMENT_CP = NEW_REFERENCES.RESTRICTED_ENROLMENT_CP,
    RESTRICTED_ATTENDANCE_TYPE = NEW_REFERENCES.RESTRICTED_ATTENDANCE_TYPE,
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
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPIRY_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_PE_PERSENC_EFFCT
     where PERSON_ID = X_PERSON_ID
     and ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE
     and PEN_START_DT = X_PEN_START_DT
     and S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE
     and PEE_START_DT = X_PEE_START_DT
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ENCUMBRANCE_TYPE,
     X_PEN_START_DT,
     X_S_ENCMB_EFFECT_TYPE,
     X_PEE_START_DT,
     X_SEQUENCE_NUMBER,
     X_EXPIRY_DT,
     X_COURSE_CD,
     X_RESTRICTED_ENROLMENT_CP,
     X_RESTRICTED_ATTENDANCE_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (

   X_ROWID,
   X_PERSON_ID,
   X_ENCUMBRANCE_TYPE,
   X_PEN_START_DT,
   X_S_ENCMB_EFFECT_TYPE,
   X_PEE_START_DT,
   X_SEQUENCE_NUMBER,
   X_EXPIRY_DT,
   X_COURSE_CD,
   X_RESTRICTED_ENROLMENT_CP,
   X_RESTRICTED_ATTENDANCE_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

 Before_DML(

  p_action => 'DELETE',

  x_rowid => X_ROWID

  );
  delete from IGS_PE_PERSENC_EFFCT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

 After_DML(

  p_action => 'DELETE',

  x_rowid => X_ROWID

  );
end DELETE_ROW;

end IGS_PE_PERSENC_EFFCT_PKG;

/
