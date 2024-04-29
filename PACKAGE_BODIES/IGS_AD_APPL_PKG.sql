--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_PKG" as
/* $Header: IGSAI04B.pls 120.6 2005/09/30 05:55:10 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_APPL_ALL%RowType;
  new_references IGS_AD_APPL_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_org_id IN NUMBER,
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_appl_dt IN DATE,
    x_acad_cal_type IN VARCHAR2,
    x_acad_ci_sequence_number IN NUMBER,
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_adm_appl_status IN VARCHAR2,
    x_adm_fee_status IN VARCHAR2,
    x_tac_appl_ind IN VARCHAR2,
    x_spcl_grp_1 IN NUMBER,
    x_spcl_grp_2 IN NUMBER,
    x_common_app IN VARCHAR2,
    x_application_type IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER ,
    x_choice_number    IN VARCHAR2,
    x_routeb_pref      IN VARCHAR2,
    x_alt_appl_id      IN VARCHAR2,
    x_appl_fee_amt     IN NUMBER
  ) AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    12-Feb-2002     Bug 2217104. Added columns choice_number,routeb_pref
  -------------------------------------------------------------------
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APPL_ALL
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
    new_references.person_id := x_person_id;
    new_references.org_id := x_org_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.appl_dt := TRUNC(x_appl_dt);
    new_references.acad_cal_type := x_acad_cal_type;
    new_references.acad_ci_sequence_number := x_acad_ci_sequence_number;
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.admission_cat := x_admission_cat;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.adm_appl_status := x_adm_appl_status;
    new_references.adm_fee_status := x_adm_fee_status;
    new_references.tac_appl_ind := x_tac_appl_ind;
    new_references.spcl_grp_1  := x_spcl_grp_1;
    new_references.spcl_grp_2  := x_spcl_grp_2;
    new_references.common_app  := x_common_app;
    new_references.application_type :=  x_application_type;
    new_references.choice_number    :=  x_choice_number;
    new_references.routeb_pref      :=  x_routeb_pref;
    new_references.alt_appl_id      :=  x_alt_appl_id;
    new_references.appl_fee_amt     :=  x_appl_fee_amt;

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
	v_message_name			VARCHAR2(30);
	v_return_type			VARCHAR2(1);
	v_title_required_ind		VARCHAR2(1);
	v_birth_dt_required_ind		VARCHAR2(1);
	v_fees_required_ind		VARCHAR2(1);
	v_person_encmb_chk_ind		VARCHAR2(1);
	v_cond_offer_fee_allowed_ind	VARCHAR2(1);
	cst_error	CONSTANT	VARCHAR2(1) := 'E';
	cst_warn	CONSTANT	VARCHAR2(1) := 'W';
	 l_birth_date  igs_pe_person_base_v.birth_date%TYPE;

        CURSOR c_apcs (
		cp_admission_cat		IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
		cp_s_admission_process_type
					IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE)
        IS
	SELECT	s_admission_step_type
	FROM	IGS_AD_PRCS_CAT_STEP
	WHERE	admission_cat = cp_admission_cat AND
		s_admission_process_type = cp_s_admission_process_type AND
 		step_group_type <> 'TRACK'		;-- 2402377


        CURSOR c_birth_date(p_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT birth_date
      FROM   igs_pe_person_base_v
      WHERE  person_id =p_person_id ;

  BEGIN
        v_title_required_ind         := 'Y';
        v_birth_dt_required_ind      := 'Y';
        v_fees_required_ind          := 'N';
        v_person_encmb_chk_ind       := 'N';
        v_cond_offer_fee_allowed_ind := 'N';


	IF p_inserting OR p_updating THEN
	      OPEN c_birth_date(new_references.person_id);
	      FETCH c_birth_date INTO l_birth_date;
	      CLOSE c_birth_date;
		IF ((l_birth_date IS NOT NULL) AND (l_birth_date > new_references.appl_dt)) THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_DOB_ERROR');
		FND_MESSAGE.SET_TOKEN ('NAME',fnd_message.get_string('IGS','IGS_AD_APPL_DT'));
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	      END IF;
		--
		-- Determine the admission process category steps.
		--
		FOR v_apcs_rec IN c_apcs (
				new_references.admission_cat,
				new_references.s_admission_process_type)
		LOOP
			IF v_apcs_rec.s_admission_step_type = 'UN-TITLE' THEN
				v_title_required_ind := 'N';
			ELSIF v_apcs_rec.s_admission_step_type = 'UN-DOB' THEN
				v_birth_dt_required_ind := 'N';
			ELSIF v_apcs_rec.s_admission_step_type = 'APP-FEE' THEN
				v_fees_required_ind := 'Y';
			ELSIF v_apcs_rec.s_admission_step_type = 'CHKPENCUMB' THEN
				v_person_encmb_chk_ind := 'Y';
			ELSIF v_apcs_rec.s_admission_step_type = 'FEE-COND' THEN
				v_cond_offer_fee_allowed_ind := 'Y';
			END IF;
		END LOOP;
	END IF;	-- p_inserting or p_updating.
	-- IGS_GE_NOTE: The following fields only need to be validated
	-- on insert because they cannot be updated.
	IF p_inserting THEN
                --
		-- Validate insert of the admission application record.
		--
		IF IGS_AD_VAL_AA.admp_val_aa_insert (
				new_references.person_id,
				new_references.adm_cal_type,
				new_references.adm_ci_sequence_number,
				new_references.s_admission_process_type,
				v_person_encmb_chk_ind,
				new_references.appl_dt,
				v_title_required_ind,
				v_birth_dt_required_ind,
				v_message_name,
				v_return_type) = FALSE THEN
			IF NVL(v_return_type, '-1') = cst_error THEN
				--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                     FND_MESSAGE.SET_NAME('IGS',v_message_name);
                     IGS_GE_MSG_STACK.ADD;
			   APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;
		--
		-- Validate the Academic Calendar.
		--
		IF IGS_AD_VAL_AA.admp_val_aa_acad_cal (
				new_references.acad_cal_type,
				new_references.acad_ci_sequence_number,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
		  IF v_message_name = 'IGS_AD_ADM_CAL_INSTNOT_DEFINE' THEN
		     FND_MESSAGE.SET_TOKEN('CAL_TYPE',new_references.acad_cal_type);
		  END IF;
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		--
		-- Validate the Admission Calendar.
		--
		IF IGS_AD_VAL_AA.admp_val_aa_adm_cal (
				new_references.adm_cal_type,
				new_references.adm_ci_sequence_number,
				new_references.acad_cal_type,
				new_references.acad_ci_sequence_number,
				new_references.admission_cat,
				new_references.s_admission_process_type,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		--
		-- Validate the Admission Category.
		--
		IF IGS_AD_VAL_AA.admp_val_aa_adm_cat (
				new_references.admission_cat,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;	-- p_inserting.
	IF p_updating THEN
		-- Validate update of the admission application record.
		IF (TRUNC(old_references.appl_dt) <> new_references.appl_dt OR
				old_references.adm_fee_status <> new_references.adm_fee_status OR
				old_references.tac_appl_ind <> new_references.tac_appl_ind) THEN
			IF IGS_AD_VAL_AA.admp_val_aa_update (
					old_references.adm_appl_status,
					v_message_name) = FALSE THEN
				--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;
		-- Cannot update the Commencement Period.
		IF  ((old_references.acad_cal_type <> new_references.acad_cal_type) OR
		     (old_references.acad_ci_sequence_number <> new_references.acad_ci_sequence_number) OR (old_references.adm_cal_type <> new_references.adm_cal_type) OR
		     (old_references.adm_ci_sequence_number <> new_references.adm_ci_sequence_number)) THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(2537));
                  FND_MESSAGE.SET_NAME('IGS','IGS_AD_UPD_COMPERIOD_NOTALLOW');
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		--
		-- Cannot update the Admission Process Category.
		--
		IF ((old_references.admission_cat <> new_references.admission_cat) OR
                         (old_references.s_admission_process_type <> new_references.s_admission_process_type) OR
                         (old_references.application_type IS NOT NULL AND old_references.application_type  <> new_references.application_type   )) THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(2538));
                  FND_MESSAGE.SET_NAME('IGS','IGS_AD_UPD_ADMPRC_CAT_NOTALLO');
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		--
		-- Cannot update the Choice Number for UK Profile.
		--
                IF  FND_PROFILE.VALUE('OSS_COUNTRY_CODE') = 'GB' AND (old_references.choice_number <> new_references.choice_number)    THEN
                  FND_MESSAGE.SET_NAME('IGS','IGS_AD_UPD_CH_NUM');
                  IGS_GE_MSG_STACK.ADD;
         	  APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
		--
		-- Cannot update the Choice Number for Alternate Application ID for UK Profile.
		--
                IF  FND_PROFILE.VALUE('OSS_COUNTRY_CODE') = 'GB' AND (old_references.alt_appl_id <> new_references.alt_appl_id)    THEN
                  FND_MESSAGE.SET_NAME('IGS','IGS_AD_UPD_ALT_APPL_ID');
                  IGS_GE_MSG_STACK.ADD;
         	  APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;

	END IF;	-- p_updating.
	IF p_deleting THEN
		--
		-- Validate delete of the admission application record.
		--
		IF IGS_AD_VAL_AA.admp_val_aa_delete (
				old_references.adm_appl_status,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;	-- p_deleting.
	--
	-- Validate the Application Date.
	--
	IF p_inserting OR
		(p_updating AND
			(TRUNC(old_references.appl_dt) <> new_references.appl_dt)) THEN
		IF IGS_AD_VAL_AA.admp_val_aa_appl_dt (
				new_references.appl_dt,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	--
	-- Validate the Admission Application Status.
	--
	IF p_inserting OR
		(p_updating AND
			(old_references.adm_appl_status <> new_references.adm_appl_status))
THEN
		IF IGS_AD_VAL_AA.admp_val_aa_aas (
				new_references.person_id,
				new_references.admission_appl_number,
				new_references.adm_appl_status,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	--
	-- Validate the Admission Fee Status.
	--
	IF p_inserting OR
		(p_updating AND
			(old_references.adm_fee_status <> new_references.adm_fee_status))
THEN
		IF IGS_AD_VAL_AA.admp_val_aa_afs (
				new_references.person_id,
				new_references.admission_appl_number,
				new_references.adm_fee_status,
				v_fees_required_ind,
				v_cond_offer_fee_allowed_ind,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	--
	-- Validate the TAC Application Indicator.
	--
	IF p_inserting OR
		(p_updating AND
			(old_references.tac_appl_ind <> new_references.tac_appl_ind) OR
			(TRUNC(old_references.appl_dt) <> new_references.appl_dt) ) THEN
		IF IGS_AD_VAL_AA.admp_val_aa_tac_appl (
				new_references.person_id,
				new_references.tac_appl_ind,
				new_references.appl_dt,
				new_references.s_admission_process_type,
				v_message_name,
				v_return_type) = FALSE THEN
			IF NVL(v_return_type, '-1') = cst_error THEN
				--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;
	END IF;

	-- Validate Applciation fee amount	(igsm fee enhancements arvsrini)
	--
	IF p_inserting OR
		(p_updating AND
			(NVL(old_references.appl_fee_amt,-1) <> NVL(new_references.appl_fee_amt,-2)))
	THEN
		IF new_references.appl_fee_amt < 0 OR
		   new_references.appl_fee_amt IS NULL THEN

                  FND_MESSAGE.SET_NAME('IGS','IGS_AD_FEE_AMT_NON_NEGATIVE');
                  IGS_GE_MSG_STACK.ADD;
		  APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	--





  END BeforeRowInsertUpdateDelete1;


  PROCEDURE AfterRowUpdateDelete2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name			VARCHAR2(30);
  BEGIN
	IF p_updating THEN
		-- Create admission application history record.
		IGS_AD_GEN_010.ADMP_INS_AA_HIST (
			new_references.person_id,
			new_references.admission_appl_number,
			new_references.appl_dt,
			TRUNC(old_references.appl_dt),
			new_references.acad_cal_type,
			old_references.acad_cal_type,
			new_references.acad_ci_sequence_number,
			old_references.acad_ci_sequence_number,
			new_references.adm_cal_type,
			old_references.adm_cal_type,
			new_references.adm_ci_sequence_number,
			old_references.adm_ci_sequence_number,
			new_references.admission_cat,
			old_references.admission_cat,
			new_references.s_admission_process_type,
			old_references.s_admission_process_type,
			new_references.adm_appl_status,
			old_references.adm_appl_status,
			new_references.adm_fee_status,
			old_references.adm_fee_status,
			new_references.tac_appl_ind,
			old_references.tac_appl_ind,
			new_references.last_updated_by,
			old_references.last_updated_by,
			new_references.last_update_date,
			old_references.last_update_date);
	END IF;
	IF p_deleting THEN
		-- Delete admission application history records.
		IF IGS_AD_GEN_001.ADMP_DEL_AA_HIST (
				old_references.person_id,
				old_references.admission_appl_number,
				v_message_name) = FALSE THEN
			--raise_application_error(-20000,IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;


  END AfterRowUpdateDelete2;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (old_references.acad_cal_type = new_references.acad_cal_type) AND
         (old_references.acad_ci_sequence_number = new_references.acad_ci_sequence_number)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.acad_cal_type IS NULL) OR
         (new_references.acad_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_REL_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number,
        new_references.acad_cal_type,
        new_references.acad_ci_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACACAL_ADMCAL_NOTEXIST');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.application_type = new_references.application_type)) OR
        ((new_references.application_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_SS_APPL_TYP_PKG.Get_PK_For_Validation (
        new_references.application_type,'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_APPL_TYPE'));
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


    IF (((old_references.adm_appl_status = new_references.adm_appl_status)) OR
        ((new_references.adm_appl_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_appl_status ,'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_APPL_STATUS'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_fee_status = new_references.adm_fee_status)) OR
        ((new_references.adm_fee_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_FEE_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_fee_status , 'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_FEE_STATUS'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PRD_AD_PRC_CA_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number,
        new_references.admission_cat,
        new_references.s_admission_process_type ,
        'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_PRCS_CAT_ADM_CAL'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PRCS_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat,
        new_references.s_admission_process_type ,
        'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_PRCS_CAT'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

     IF new_references.spcl_grp_1 IS NOT NULL AND  NOT igs_ad_code_classes_pkg.Get_PK_For_Validation(new_references.spcl_grp_1,'N')  THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_GRP'));
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
     IF new_references.spcl_grp_1 IS NOT NULL AND  NOT igs_ad_code_classes_pkg.Get_PK_For_Validation(new_references.spcl_grp_1,'N')  THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_GRP'));
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_APPL_LTR_PKG.GET_FK_IGS_AD_APPL (
      old_references.person_id,
      old_references.admission_appl_number
      );

    IGS_AD_PS_APPL_PKG.GET_FK_IGS_AD_APPL (
      old_references.person_id,
      old_references.admission_appl_number
      );

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_AD_APPL (
      old_references.person_id,
      old_references.admission_appl_number
      );
    IGS_AD_APP_REQ_PKG.GET_FK_IGS_AD_APPL (
      old_references.person_id,
      old_references.admission_appl_number
      );
    --
    -- Modified By : kamohan
    -- Date : 1/21/02
    -- Bug # 2177686
    -- Added the fk check for the following six tables which are moved from igs_ad_ps_appl_inst table
    --
    igs_ad_other_inst_pkg.get_fk_igs_ad_appl (
      old_references.person_id,
      old_references.admission_appl_number
      );
    igs_ad_acad_interest_pkg.get_fk_igs_ad_appl (
      old_references.person_id,
      old_references.admission_appl_number
      );
    igs_ad_app_intent_pkg.get_fk_igs_ad_appl (
      old_references.person_id,
      old_references.admission_appl_number
      );
    igs_ad_spl_interests_pkg.get_fk_igs_ad_appl (
      old_references.person_id,
      old_references.admission_appl_number
      );
    igs_ad_spl_talents_pkg.get_fk_igs_ad_appl (
      old_references.person_id,
      old_references.admission_appl_number
      );
    --
    -- End of Bug # 2177686 modifications
    --

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return TRUE;
    ELSE
      Close cur_rowid;
      Return FALSE;
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_AD_SS_APPL_TYP(
   x_application_type IN VARCHAR2
    ) AS
   CURSOR cur_rowid IS
     SELECT rowid
     FROM   igs_ad_appl_all
     WHERE application_type = x_application_type;

   lv_rowid cur_rowid%RowType;
  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_SSAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_SS_APPL_TYP;

  PROCEDURE GET_FK_IGS_CA_INST_REL (
    x_sub_cal_type IN VARCHAR2,
    x_sub_ci_sequence_number IN NUMBER,
    x_sup_cal_type IN VARCHAR2,
    x_sup_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    adm_cal_type = x_sub_cal_type
      AND      adm_ci_sequence_number = x_sub_ci_sequence_number
      AND      acad_cal_type = x_sup_cal_type
      AND      acad_ci_sequence_number = x_sup_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_AA_CIR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST_REL;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_AD_APPL_STAT (
    x_adm_appl_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    adm_appl_status = x_adm_appl_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_AAS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_APPL_STAT;

  PROCEDURE GET_FK_IGS_AD_FEE_STAT (
    x_adm_fee_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    adm_fee_status = x_adm_fee_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_AFS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_FEE_STAT;

  PROCEDURE GET_FK_IGS_AD_PRD_AD_PRC_CA (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_APAPC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PRD_AD_PRC_CA;

  PROCEDURE GET_FK_IGS_AD_PRCS_CAT (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_ALL
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_APC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PRCS_CAT;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS
  /*************************************************************
  Created By : nsinha
  Date Created By : 01-Aug-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid1 IS
      SELECT   rowid
      FROM     igs_ad_appl_all
      WHERE    spcl_grp_1 = x_code_id
      OR       spcl_grp_2 = x_code_id;
    lv_rowid cur_rowid1%RowType;
  BEGIN
    Open cur_rowid1;
    Fetch cur_rowid1 INTO lv_rowid;
    IF (cur_rowid1%FOUND) THEN
      Close cur_rowid1;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AA_ACDC_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid1;
  END Get_FK_Igs_Ad_Code_Classes;

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2,
     column_value IN VARCHAR2
  ) AS
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'ACAD_CAL_TYPE' THEN
      new_references.acad_cal_type := column_value;
     ELSIF upper(column_name) = 'ADMISSION_CAT' THEN
      new_references.admission_cat := column_value;
     ELSIF upper(column_name) = 'ADM_APPL_STATUS' THEN
      new_references.adm_appl_status := column_value;
     ELSIF upper(column_name) = 'ADM_CAL_TYPE' THEN
      new_references.adm_cal_type := column_value;
     ELSIF upper(column_name) = 'ADM_FEE_STATUS' THEN
      new_references.adm_fee_status := column_value;
     ELSIF upper(column_name) = 'S_ADMISSION_PROCESS_TYPE' THEN
      new_references.s_admission_process_type := column_value;
     ELSIF upper(column_name) = 'TAC_APPL_IND' THEN
      new_references.tac_appl_ind := column_value;
     ELSIF upper(column_name) = 'ADMISSION_APPL_NUMBER' THEN
      new_references.admission_appl_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'ACAD_CI_SEQUENCE_NUMBER' THEN
      new_references.acad_ci_sequence_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' THEN
      new_references.adm_ci_sequence_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'APPLICATION_TYPE' THEN-- Added as part of Enh Bug 2599457
      new_references.application_type := column_value;
     END IF;

     IF upper(column_name) = 'ADMISSION_APPL_NUMBER' OR column_name IS NULL THEN
      IF new_references.admission_appl_number < 0 OR new_references.admission_appl_number > 99 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_NO'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ACAD_CI_SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.acad_ci_sequence_number < 1 OR new_references.acad_ci_sequence_number > 999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ACAD_CAL'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF (new_references.adm_ci_sequence_number < 1 OR  new_references.adm_ci_sequence_number > 999999)  THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'TAC_APPL_IND' OR column_name IS NULL THEN
      IF new_references.tac_appl_ind NOT IN ('Y','N') THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TAC_APPL_IND'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'APPLICATION_TYPE' OR column_name IS NULL THEN -- Added as part of Enh Bug 2599457
      IF new_references.application_type IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_APPL_TYPE_NULL');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ACAD_CAL_TYPE' OR column_name IS NULL THEN
      IF new_references.acad_cal_type IS  NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ACAD_CAL'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADMISSION_CAT' OR column_name IS NULL THEN
      IF new_references.admission_cat IS  NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_PRCS_CAT'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_APPL_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_appl_status   IS  NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_APPL_STATUS'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_CAL_TYPE' OR column_name IS NULL THEN
      IF new_references.adm_cal_type   IS  NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_FEE_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_fee_status   IS  NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_FEE_STATUS'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'S_ADMISSION_PROCESS_TYPE' OR column_name IS NULL THEN
      IF new_references.s_admission_process_type   IS  NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_PRCS_CAT'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF new_references.Common_app IS NOT NULL AND new_references.common_app NOT IN ('Y','N') THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_COM_APP'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

  END CHECK_CONSTRAINTS;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_org_id IN NUMBER,
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_appl_dt IN DATE,
    x_acad_cal_type IN VARCHAR2,
    x_acad_ci_sequence_number IN NUMBER,
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_adm_appl_status IN VARCHAR2,
    x_adm_fee_status IN VARCHAR2,
    x_tac_appl_ind IN VARCHAR2,
    x_spcl_grp_1 IN NUMBER,
    x_spcl_grp_2 IN NUMBER,
    x_common_app IN VARCHAR2,
    x_application_type  IN VARCHAR2,
    x_creation_date     IN DATE,
    x_created_by        IN NUMBER,
    x_last_update_date  IN DATE,
    x_last_updated_by   IN NUMBER,
    x_last_update_login IN NUMBER,
    x_choice_number     IN VARCHAR2,
    x_routeb_pref       IN VARCHAR2,
    x_alt_appl_id       IN VARCHAR2,
    x_appl_fee_amt      IN NUMBER
  ) AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    12-Feb-2002     Bug 2217104. Added columns choice_number,routeb_pref
  --pbondugu   04-Mar-2003      Validation is added for checking whether application date
  --						is greater than birthdate or not.
  --pbondugu   23-apr-2003     validation for checking whether application date
  --						is greater than birthdate or not  is moved to BeforeRowInsertUpdateDelete1
  -------------------------------------------------------------------

  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_person_id,
      x_admission_appl_number,
      x_appl_dt,
      x_acad_cal_type,
      x_acad_ci_sequence_number,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_s_admission_process_type,
      x_adm_appl_status,
      x_adm_fee_status,
      x_tac_appl_ind,
      x_spcl_grp_1,
      x_spcl_grp_2,
      x_common_app,
      x_application_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_choice_number,
      x_routeb_pref,
      x_alt_appl_id,
      x_appl_fee_amt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 (
                                     p_inserting => TRUE,
                                     p_updating  => FALSE,
                                     p_deleting  => FALSE );
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 (
                                     p_inserting => FALSE,
                                     p_updating  => TRUE,
                                     p_deleting  => FALSE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 (
                                     p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action                  IN VARCHAR2,
    x_rowid                   IN VARCHAR2
  ) AS
-------------------------------------------------------------------------------
-- Bug ID : 1818617
-- who              when                  what
-- rasahoo          01-Sep-2003      Removed the private procedure IGF_UPDATE_DATA And
--                                   Removed the call of IGF_UPDATE_DATA as part of the Build
--                                   FA 114(Obsoletion of base record history)
-- sjadhav          jun 28,2001           this procedure is modified to trigger
--                                        a Concurrent Request (IGFAPJ10) which
--                                        will create a new record in IGF To
--                                        Do table
-------------------------------------------------------------------------------


  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdateDelete2 (
                                     p_inserting => FALSE,
                                     p_updating  => TRUE,
                                     p_deleting  => FALSE );
     IF NEW_REFERENCES.ADM_APPL_STATUS <> OLD_REFERENCES.ADM_APPL_STATUS THEN
       igs_ad_wf_001.APP_PRCOC_STATUS_UPD_EVENT (
	     P_PERSON_ID	        => new_references.person_id,
	     P_ADMISSION_APPL_NUMBER	=> new_references.admission_appl_number,
	     P_ADM_APPL_STATUS_NEW	=> new_references.adm_appl_status,
             P_ADM_APPL_STATUS_OLD	=> old_references.adm_appl_status);

     END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete2 (
                                     p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER,
  x_spcl_grp_2 IN NUMBER,
  x_common_app IN VARCHAR2,
  x_application_type IN VARCHAR2,
  X_MODE             IN VARCHAR2,
  x_choice_number    IN VARCHAR2,
  x_routeb_pref      IN VARCHAR2,
  x_alt_appl_id      IN VARCHAR2,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
  ) AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --ravishar   25-May-2005    Security related changes(Bug- 4344197)
  --smvk        14-Feb-2002     Call to igs_ge_gen_003.get_org_id w.r.t SWCR006
  --smadathi    12-Feb-2002     Bug 2217104. Added columns choice_number,routeb_pref
  -------------------------------------------------------------------
    cursor C is select ROWID from IGS_AD_APPL_ALL
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER;
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
  elsif (X_MODE IN ('R', 'S')) then
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_person_id => X_PERSON_ID,
    x_admission_appl_number => X_ADMISSION_APPL_NUMBER,
    x_appl_dt => Nvl(X_APPL_DT, SYSDATE),
    x_acad_cal_type => X_ACAD_CAL_TYPE,
    x_acad_ci_sequence_number => X_ACAD_CI_SEQUENCE_NUMBER,
    x_adm_cal_type => X_ADM_CAL_TYPE,
    x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
    x_admission_cat => X_ADMISSION_CAT,
    x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
    x_adm_appl_status => X_ADM_APPL_STATUS,
    x_adm_fee_status => X_ADM_FEE_STATUS,
    x_tac_appl_ind => Nvl(X_TAC_APPL_IND, 'N'),
    x_spcl_grp_1 => x_spcl_grp_1,
    x_spcl_grp_2 => x_spcl_grp_2,
    x_common_app => x_common_app,
    x_application_type  => x_application_type,
    x_creation_date     => X_LAST_UPDATE_DATE,
    x_created_by        => X_LAST_UPDATED_BY,
    x_last_update_date  => X_LAST_UPDATE_DATE,
    x_last_updated_by   => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_choice_number     => x_choice_number,
    x_routeb_pref       => x_routeb_pref,
    x_alt_appl_id       => x_alt_appl_id,
    x_appl_fee_amt      => x_appl_fee_amt
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_APPL_ALL (
    PERSON_ID,
    ORG_ID,
    ADMISSION_APPL_NUMBER,
    APPL_DT,
    ACAD_CAL_TYPE,
    ACAD_CI_SEQUENCE_NUMBER,
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    ADMISSION_CAT,
    S_ADMISSION_PROCESS_TYPE,
    ADM_APPL_STATUS,
    ADM_FEE_STATUS,
    TAC_APPL_IND,
    spcl_grp_1,
    spcl_grp_2,
    common_app,
    application_type,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    choice_number,
    routeb_pref,
    application_id,
    alt_appl_id,
    appl_fee_amt
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.APPL_DT,
    NEW_REFERENCES.ACAD_CAL_TYPE,
    NEW_REFERENCES.ACAD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    NEW_REFERENCES.ADM_APPL_STATUS,
    NEW_REFERENCES.ADM_FEE_STATUS,
    NEW_REFERENCES.TAC_APPL_IND,
    NEW_REFERENCES.spcl_grp_1,
    NEW_REFERENCES.spcl_grp_2,
    NEW_REFERENCES.common_app,
    new_references.application_type,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE ,
    new_references.choice_number,
    new_references.routeb_pref,
    IGS_AD_APL_INT_S.nextval,
    new_references.alt_appl_id,
    new_references.appl_fee_amt
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML (
    p_action                    =>  'INSERT',
    x_rowid                     =>  X_ROWID
  );
EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER,
  x_spcl_grp_2 IN NUMBER,
  x_common_app IN VARCHAR2,
  x_application_type IN VARCHAR2,
  x_choice_number    IN VARCHAR2,
  x_routeb_pref      IN VARCHAR2,
  x_alt_appl_id      IN VARCHAR2,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
) AS
  cursor c1 is select
      APPL_DT,
      ACAD_CAL_TYPE,
      ACAD_CI_SEQUENCE_NUMBER,
      ADM_CAL_TYPE,
      ADM_CI_SEQUENCE_NUMBER,
      ADMISSION_CAT,
      S_ADMISSION_PROCESS_TYPE,
      ADM_APPL_STATUS,
      ADM_FEE_STATUS,
      TAC_APPL_IND,
      spcl_grp_1,
      spcl_grp_2,
      common_app,
      application_type,
      choice_number,
      routeb_pref,
      alt_appl_id,
      appl_fee_amt
 from IGS_AD_APPL_ALL
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

  if ( (TRUNC(tlinfo.APPL_DT) = TRUNC(X_APPL_DT))
      AND (tlinfo.ACAD_CAL_TYPE = X_ACAD_CAL_TYPE)
      AND (tlinfo.ACAD_CI_SEQUENCE_NUMBER = X_ACAD_CI_SEQUENCE_NUMBER)
      AND (tlinfo.ADM_CAL_TYPE = X_ADM_CAL_TYPE)
      AND (tlinfo.ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER)
      AND (tlinfo.ADMISSION_CAT = X_ADMISSION_CAT)
      AND (tlinfo.S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE)
      AND (tlinfo.ADM_APPL_STATUS = X_ADM_APPL_STATUS)
      AND (tlinfo.ADM_FEE_STATUS = X_ADM_FEE_STATUS)
      AND (tlinfo.TAC_APPL_IND = X_TAC_APPL_IND)
      AND ((tlinfo.spcl_grp_1 = x_spcl_grp_1)
 	    OR ((tlinfo.spcl_grp_1 is null)
		AND (x_spcl_grp_1 is null)))
      AND ((tlinfo.spcl_grp_2 = x_spcl_grp_2)
 	    OR ((tlinfo.spcl_grp_2 is null)
		AND (x_spcl_grp_2 is null)))
      AND ((tlinfo.common_app = x_common_app)
 	    OR ((tlinfo.common_app is null)
		AND (x_common_app is null)))
      AND ((tlinfo.application_type = x_application_type)
            OR ((tlinfo.application_type IS NULL)
                AND (x_application_type IS NULL)))
      AND ((tlinfo.choice_number = x_choice_number)
            OR ((tlinfo.choice_number IS NULL)
                AND (x_choice_number IS NULL)))
      AND ((tlinfo.routeb_pref = x_routeb_pref)
            OR ((tlinfo.routeb_pref IS NULL)
                AND (x_routeb_pref IS NULL)))
      AND ((tlinfo.alt_appl_id = x_alt_appl_id)
            OR ((tlinfo.alt_appl_id IS NULL)
                AND (x_alt_appl_id IS NULL)))
      AND ((tlinfo.appl_fee_amt = x_appl_fee_amt)
            OR ((tlinfo.appl_fee_amt IS NULL)
                AND (x_appl_fee_amt IS NULL)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER,
  x_spcl_grp_2 IN NUMBER,
  x_common_app IN VARCHAR2,
  x_application_type IN VARCHAR2,
  X_MODE             IN VARCHAR2,
  x_choice_number    IN VARCHAR2,
  x_routeb_pref      IN VARCHAR2,
  x_alt_appl_id      IN VARCHAR2,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
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
  elsif (X_MODE IN ('R', 'S')) then
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
    x_person_id => X_PERSON_ID,
    x_admission_appl_number => X_ADMISSION_APPL_NUMBER,
    x_appl_dt => X_APPL_DT,
    x_acad_cal_type => X_ACAD_CAL_TYPE,
    x_acad_ci_sequence_number => X_ACAD_CI_SEQUENCE_NUMBER,
    x_adm_cal_type => X_ADM_CAL_TYPE,
    x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
    x_admission_cat => X_ADMISSION_CAT,
    x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
    x_adm_appl_status => X_ADM_APPL_STATUS,
    x_adm_fee_status => X_ADM_FEE_STATUS,
    x_tac_appl_ind => X_TAC_APPL_IND,
    x_spcl_grp_1 => x_spcl_grp_1,
    x_spcl_grp_2 => x_spcl_grp_2,
    x_common_app => x_common_app,
    x_application_type => x_application_type,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_choice_number    => x_choice_number,
    x_routeb_pref      => x_routeb_pref,
    x_alt_appl_id      => x_alt_appl_id,
    x_appl_fee_amt     => x_appl_fee_amt
  );

  if (X_MODE IN ('R', 'S')) then
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

  /* Removed the Commencement Period details (Acad and Adm calendars) from the update statement
     as they should not be allowed to update for an existing application. Bug: 2772337  */
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_APPL_ALL set
    APPL_DT = NEW_REFERENCES.APPL_DT,
    ADM_APPL_STATUS = NEW_REFERENCES.ADM_APPL_STATUS,
    ADM_FEE_STATUS = NEW_REFERENCES.ADM_FEE_STATUS,
    TAC_APPL_IND = NEW_REFERENCES.TAC_APPL_IND,
    spcl_grp_1 = NEW_REFERENCES.spcl_grp_1,
    spcl_grp_2 = NEW_REFERENCES.spcl_grp_2,
    common_app = NEW_REFERENCES.common_app,
    application_type = NEW_REFERENCES.application_type,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    choice_number    = new_references.choice_number,
    routeb_pref      = new_references.routeb_pref,
    alt_appl_id      = new_references.alt_appl_id,
    appl_fee_amt     = new_references.appl_fee_amt
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 end if;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );
EXCEPTION
  WHEN OTHERS THEN
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;
 IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER,
  x_spcl_grp_2 IN NUMBER,
  x_common_app IN VARCHAR2,
  x_application_type IN VARCHAR2,
  X_MODE in VARCHAR2,
  x_choice_number    IN VARCHAR2,
  x_routeb_pref      IN VARCHAR2,
  x_alt_appl_id      IN VARCHAR2,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
  ) AS
  cursor c1 is select rowid from IGS_AD_APPL_ALL
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_PERSON_ID,
     X_ADMISSION_APPL_NUMBER,
     X_APPL_DT,
     X_ACAD_CAL_TYPE,
     X_ACAD_CI_SEQUENCE_NUMBER,
     X_ADM_CAL_TYPE,
     X_ADM_CI_SEQUENCE_NUMBER,
     X_ADMISSION_CAT,
     X_S_ADMISSION_PROCESS_TYPE,
     X_ADM_APPL_STATUS,
     X_ADM_FEE_STATUS,
     X_TAC_APPL_IND,
     x_spcl_grp_1,
     x_spcl_grp_2,
     x_common_app,
     x_application_type,
     X_MODE,
     x_choice_number,
     x_routeb_pref,
     x_alt_appl_id,
     x_appl_fee_amt
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_APPL_DT,
   X_ACAD_CAL_TYPE,
   X_ACAD_CI_SEQUENCE_NUMBER,
   X_ADM_CAL_TYPE,
   X_ADM_CI_SEQUENCE_NUMBER,
   X_ADMISSION_CAT,
   X_S_ADMISSION_PROCESS_TYPE,
   X_ADM_APPL_STATUS,
   X_ADM_FEE_STATUS,
   X_TAC_APPL_IND,
   x_spcl_grp_1,
   x_spcl_grp_2,
   x_common_app,
   x_application_type,
   X_MODE,
   x_choice_number,
   x_routeb_pref,
   x_alt_appl_id,
   x_appl_fee_amt
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_APPL_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 end if;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  After_DML (
    p_action                    =>  'DELETE',
    x_rowid                     =>  X_ROWID
  );
EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end DELETE_ROW;

end IGS_AD_APPL_PKG;

/
