--------------------------------------------------------
--  DDL for Package Body IGS_EN_STDNTPSHECSOP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_STDNTPSHECSOP_PKG" AS
/* $Header: IGSEI17B.pls 115.4 2002/11/28 23:35:22 nsidana ship $ */
-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The call to igs_en_val_scho.genp_val_strt_end_dt
  --                            is changed to igs_ad_val_edtl.genp_val_strt_end_dt
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_en_val_scho.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_EN_STDNTPSHECSOP%RowType;
  new_references IGS_EN_STDNTPSHECSOP%RowType;



  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_diff_hecs_ind_update_who IN VARCHAR2 DEFAULT NULL,
    x_diff_hecs_ind_update_on IN DATE DEFAULT NULL,
    x_outside_aus_res_ind IN VARCHAR2 DEFAULT NULL,
    x_nz_citizen_ind IN VARCHAR2 DEFAULT NULL,
    x_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT NULL,
    x_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT NULL,
    x_safety_net_ind IN VARCHAR2 DEFAULT NULL,
    x_tax_file_number IN NUMBER DEFAULT NULL,
    x_tax_file_number_collected_dt IN DATE DEFAULT NULL,
    x_tax_file_invalid_dt IN DATE DEFAULT NULL,
    x_tax_file_certificate_number IN NUMBER DEFAULT NULL,
    x_diff_hecs_ind_update_comment IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_STDNTPSHECSOP
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
    new_references.course_cd := x_course_cd;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.hecs_payment_option := x_hecs_payment_option;
    new_references.differential_hecs_ind := x_differential_hecs_ind;
    new_references.diff_hecs_ind_update_who := x_diff_hecs_ind_update_who;
    new_references.diff_hecs_ind_update_on := x_diff_hecs_ind_update_on;
    new_references.outside_aus_res_ind := x_outside_aus_res_ind;
    new_references.nz_citizen_ind := x_nz_citizen_ind;
    new_references.nz_citizen_less2yr_ind := x_nz_citizen_less2yr_ind;
    new_references.nz_citizen_not_res_ind := x_nz_citizen_not_res_ind;
    new_references.safety_net_ind := x_safety_net_ind;
    new_references.tax_file_number := x_tax_file_number;
    new_references.tax_file_number_collected_dt := x_tax_file_number_collected_dt;
    new_references.tax_file_invalid_dt := x_tax_file_invalid_dt;
    new_references.tax_file_certificate_number := x_tax_file_certificate_number;
    new_references.diff_hecs_ind_update_comments := x_diff_hecs_ind_update_comment;
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
  -- "OSS_TST".trg_scho_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_STDNTPSHECSOP
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
	v_return_type	VARCHAR2(1);
	v_return_val	IGS_PE_STD_TODO.sequence_number%TYPE;
	cst_error		CONSTANT	VARCHAR2(1) := 'E';
  BEGIN
	-- IMPORTANT IGS_GE_NOTE!
	-- If making any changes to functionality associated with
	-- IGS_EN_STDNTPSHECSOP, consider if this should be replicated
	-- in the validation associated with the merging of ID's.
	-- Refer to enrp_val_ps_scho_mrg.
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNTPSHECSOP') THEN
		IF p_inserting THEN
			-- Validate if the insert is allowed.
			IF IGS_EN_VAL_SCHO.enrp_val_scho_insert (
					new_references.person_id,
					new_references.course_cd,
					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;

			END IF;
			-- Create an entry on the IGS_PE_STD_TODO table.
			v_return_val := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(new_references.person_id, 'FEE_RECALC', NULL,'Y');
		END IF;
		IF p_deleting THEN
			-- Validate if the delete is allowed.
			IF IGS_EN_VAL_SCHO.enrp_val_scho_trgdel (
					old_references.person_id,
					old_references.course_cd,
					old_references.start_dt,
					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
			END IF;
		END IF;
		IF p_updating THEN
			-- Validate if the update is allowed.
			IF (NVL(old_references.differential_hecs_ind, 'NULL') <>
					NVL(new_references.differential_hecs_ind, 'NULL') ) OR
				(NVL(old_references.outside_aus_res_ind, 'NULL') <>
					NVL(new_references.outside_aus_res_ind, 'NULL') ) OR
				(NVL(old_references.nz_citizen_ind, 'NULL') <>
					NVL(new_references.nz_citizen_ind, 'NULL') ) OR
				(NVL(old_references.nz_citizen_less2yr_ind, 'NULL') <>
					NVL(new_references.nz_citizen_less2yr_ind, 'NULL') ) OR
				(NVL(old_references.nz_citizen_not_res_ind, 'NULL') <>
					NVL(new_references.nz_citizen_not_res_ind, 'NULL') ) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_scho_update (
						old_references.start_dt,
						v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
				END IF;
			END IF;
		END IF;
		IF p_inserting OR p_updating THEN
			-- Set audit details.
			--new_references.last_updated_by := USER;
			--new_references.last_update_date := SYSDATE;
			-- Validate START DATE AND END DATE.
			-- Because start date is part of the key it will be set and is not
			-- updateable, so only need to check the end date is not null.
			IF new_references.end_dt IS NOT NULL AND
				(p_inserting OR
				NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					new_references.end_dt) THEN
				IF igs_ad_val_edtl.genp_val_strt_end_dt (
						new_references.start_dt,
						new_references.end_dt,
						v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
				END IF;
			END IF;
			-- Validate END DATE.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					new_references.end_dt >= TRUNC(SYSDATE)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_scho_expire (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
				END IF;
			END IF;
			-- Validate HECS PAYMENT OPTION closed indicator.
			IF NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL') THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_closed (
						new_references.hecs_payment_option,
						v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
				END IF;
			END IF;
			-- Validate TAX FILE NUMBER INVALID DATE.
			IF IGS_EN_VAL_SCHO.enrp_val_tfn_invalid (
					new_references.tax_file_number,
					new_references.tax_file_invalid_dt,
					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
			END IF;
			-- Validate TAX FILE NUMBER CERTIFICATE NUMBER.
			IF IGS_EN_VAL_SCHO.enrp_val_tfn_crtfct (
					new_references.tax_file_number,
					new_references.tax_file_invalid_dt,
					new_references.tax_file_certificate_number,
					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
			END IF;
			-- Validate the VISA INDICATORS.
			IF (NVL(old_references.outside_aus_res_ind, 'NULL') <>
					NVL(new_references.outside_aus_res_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_ind, 'NULL') <>
					NVL(new_references.nz_citizen_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_less2yr_ind, 'NULL') <>
					NVL(new_references.nz_citizen_less2yr_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_not_res_ind, 'NULL') <>
					NVL(new_references.nz_citizen_not_res_ind, 'NULL')) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_scho_visa (
						new_references.outside_aus_res_ind,
						new_references.nz_citizen_ind,
						new_references.nz_citizen_less2yr_ind,
						new_references.nz_citizen_not_res_ind,
						v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
				END IF;
			END IF;
			-- Cross-table validations.
			-- IGS_EN_STDNTPSHECSOP and IGS_PE_STATISTICS and IGS_PS_COURSE VERSION.
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- and the IGS_PS_COURSE type of the IGS_PS_COURSE version for the student IGS_PS_COURSE attempt.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_crs_typ (
						new_references.person_id,
						new_references.course_cd,
						new_references.hecs_payment_option,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- and the special IGS_PS_COURSE type of the IGS_PS_COURSE version for the student IGS_PS_COURSE
			-- attempt.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_spc_crs (
						new_references.person_id,
						new_references.course_cd,
						new_references.hecs_payment_option,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- the IGS_PS_COURSE type of the IGS_PS_COURSE version for the student IGS_PS_COURSE attempt,
			-- and the IGS_PE_PERSON statistics citizenship code.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_crs_cic (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- and the IGS_PE_PERSON statistics citizenship code.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_cic (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- and the IGS_PE_PERSON statistics citizenship code and permanent resident code.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_cic_prc (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						NULL,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option visa indicators,
			-- and the IGS_PE_PERSON statistics citizenship code and permanent resident code.
			IF (NVL(old_references.outside_aus_res_ind, 'NULL') <>
					NVL(new_references.outside_aus_res_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_ind, 'NULL') <>
					NVL(new_references.nz_citizen_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_less2yr_ind, 'NULL') <>
					NVL(new_references.nz_citizen_less2yr_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_not_res_ind, 'NULL') <>
					NVL(new_references.nz_citizen_not_res_ind, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_vis_cic_prc (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.outside_aus_res_ind,
						new_references.nz_citizen_ind,
						new_references.nz_citizen_less2yr_ind,
						new_references.nz_citizen_not_res_ind,
						NULL,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- the student IGS_PS_COURSE attempt HECS option visa indicators,
			-- and the IGS_PE_PERSON statistics citizenship code and permanent resident code.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.outside_aus_res_ind, 'NULL') <>
					NVL(new_references.outside_aus_res_ind, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_ho_cic_prc (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						new_references.outside_aus_res_ind,
						NULL,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- the student IGS_PS_COURSE attempt HECS option visa indicators,
			-- and the IGS_PE_PERSON statistics citizenship code.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.nz_citizen_ind, 'NULL') <>
					NVL(new_references.nz_citizen_ind, 'NULL')) OR
			    (NVL(old_references.outside_aus_res_ind, 'NULL') <>
					NVL(new_references.outside_aus_res_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_less2yr_ind, 'NULL') <>
					NVL(new_references.nz_citizen_less2yr_ind, 'NULL')) OR
			    (NVL(old_references.nz_citizen_not_res_ind, 'NULL') <>
					NVL(new_references.nz_citizen_not_res_ind, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_vis_cic (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						new_references.outside_aus_res_ind,
						new_references.nz_citizen_ind,
						new_references.nz_citizen_less2yr_ind,
						new_references.nz_citizen_not_res_ind,
						NULL,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
			-- Validate the student IGS_PS_COURSE attempt HECS option HECS payment option,
			-- and the IGS_PE_PERSON statistics citizenship code and other IGS_PE_PERSON statistics
			-- values including year of arrival and term IGS_AD_LOCATION country and postcode.
			IF (NVL(old_references.hecs_payment_option, 'NULL') <>
					NVL(new_references.hecs_payment_option, 'NULL')) OR
			    (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
					NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
					(new_references.end_dt >= TRUNC(SYSDATE) OR
					new_references.end_dt IS NULL)) THEN
				IF IGS_EN_VAL_SCHO.enrp_val_hpo_cic_ps (
						new_references.person_id,
						new_references.course_cd,
						new_references.start_dt,
						new_references.end_dt,
						new_references.hecs_payment_option,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						v_message_name,
						v_return_type) = FALSE THEN
					IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_scho_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_EN_STDNTPSHECSOP
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
	v_rowid_saved	BOOLEAN := FALSE;
        v_return_type   VARCHAR2(1);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNTPSHECSOP') THEN
		-- Validate for open ended student IGS_PS_COURSE HECS option records.
		IF new_references.end_dt IS NULL THEN
			v_rowid_saved := TRUE;
		END IF;
		-- Validate for date overlaps.
		IF p_inserting OR (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
				 NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
			IF v_rowid_saved = FALSE THEN
				v_rowid_saved := TRUE;
			END IF;
		END IF;
		--  Validate TAX FILE NUMBER.
		IF (new_references.tax_file_number IS NOT NULL AND
		    NVL(old_references.tax_file_number,0) <> new_references.tax_file_number) THEN
			IF v_rowid_saved = FALSE THEN
				v_rowid_saved := TRUE;
			END IF;
		END IF;
		-- Validate  HECS PAYMENT OPTION and other fields.
		IF (NVL(old_references.hecs_payment_option, 'NULL') <>
				NVL(new_references.hecs_payment_option, 'NULL')) OR
		    (NVL(old_references.outside_aus_res_ind, 'NULL') <>
				NVL(new_references.outside_aus_res_ind, 'NULL')) OR
		    (NVL(old_references.nz_citizen_ind, 'NULL') <>
				NVL(new_references.nz_citizen_ind, 'NULL')) OR
		    (NVL(old_references.nz_citizen_less2yr_ind, 'NULL') <>
				NVL(new_references.nz_citizen_less2yr_ind, 'NULL')) OR
		    (NVL(old_references.nz_citizen_not_res_ind, 'NULL') <>
				NVL(new_references.nz_citizen_not_res_ind, 'NULL')) OR
		    (NVL(old_references.safety_net_ind, 'NULL') <>
				NVL(new_references.safety_net_ind, 'NULL')) OR
		    (NVL(old_references.tax_file_number,0) <> NVL(new_references.tax_file_number,0)) OR
		    (NVL(old_references.tax_file_number_collected_dt,
			IGS_GE_DATE.IGSDATE('1900/01/01')) <>
				NVL(new_references.tax_file_number_collected_dt,
			IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
		    (NVL(old_references.tax_file_certificate_number,0) <>
				NVL(new_references.tax_file_certificate_number,0)) THEN
			IF v_rowid_saved = FALSE THEN
				v_rowid_saved := TRUE;
				-- Cannot call enrp_val_scho_hpo because tax file number is a parameter
				-- and the form handles the update of tax file number in 2 update
				-- statements.
			END IF;
		END IF;
	END IF;

	-- The following code has been added to validate the rows without causing mutaion
	-- For all the 4 cases above where the rowid has been inserted the processing is done below
	-- Dt: 8-Nov-99
      IF v_rowid_saved = TRUE THEN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNTPSHECSOP') THEN
		-- Validate for open ended IGS_EN_STDNTPSHECSOP records.
  		IF New_References.end_dt IS NULL THEN
  			IF IGS_EN_VAL_SCHO.enrp_val_scho_open (
  					New_References.person_id,
  					New_References.course_cd,
  					New_References.start_dt,
  					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
  			END IF;
  		END IF;
  		-- Validate IGS_EN_STDNTPSHECSOP date overlaps.
  		IF IGS_EN_VAL_SCHO.enrp_val_scho_ovrlp (
  				New_References.person_id,
  				New_References.course_cd,
  				New_References.start_dt,
  				New_References.end_dt,
  				v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
  		END IF;
  		-- Validate TAX FILE NUMBER.
  		IF IGS_EN_VAL_SCHO.enrp_val_scho_tfn(
  				New_References.person_id,
  				New_References.course_cd,
  				New_References.start_dt,
  				New_References.tax_file_number,
  				v_message_name,
  				v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
  			END IF;
  		END IF;
  		-- Validate HECS PAYMENT OPTION and other fields.
  		IF IGS_EN_VAL_SCHO.enrp_val_scho_hpo (
  				New_References.hecs_payment_option,
  				New_References.outside_aus_res_ind,
  				New_References.nz_citizen_ind,
  				New_References.nz_citizen_less2yr_ind,
  				New_References.nz_citizen_not_res_ind,
  				New_References.safety_net_ind,
  				New_References.tax_file_number,
  				New_References.tax_file_number_collected_dt,
  				New_References.tax_file_certificate_number,
  				New_References.differential_hecs_ind,
  				v_message_name,
  				v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
  			END IF;
  		END IF;
	END IF;
      END IF;


  END AfterRowInsertUpdate2;

procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
  	If column_name is null then
		NULL;
  	elsif upper(column_name) = 'DIFFERENTIAL_HECS_IND' then
		new_references.differential_hecs_ind := column_value;
  	elsif upper(column_name) = 'OUTSIDE_AUS_RES_IND' then
		new_references.outside_aus_res_ind := column_value;
	elsif upper(column_name) = 'NZ_CITIZEN_IND' then
		new_references.nz_citizen_ind := column_value;
	elsif upper(column_name) = 'NZ_CITIZEN_LESS2YR_IND' then
		new_references.nz_citizen_less2yr_ind := column_value;
	elsif upper(column_name) = 'NZ_CITIZEN_NOT_RES_IND' then
		new_references.nz_citizen_not_res_ind := column_value;
	elsif upper(column_name) = 'SAFETY_NET_IND' then
		new_references.safety_net_ind := column_value;
	elsif upper(column_name) = 'TAX_FILE_CERTIFICATE_NUMBER' then
		new_references.tax_file_certificate_number := igs_ge_number.to_num(column_value);
	elsif upper(column_name) = 'COURSE_CD' then
		new_references.course_cd := column_value;
    	elsif upper(column_name) = 'DIFF_HECS_IND_UPDATE_WHO' then
		new_references.diff_hecs_ind_update_who := column_value;
	elsif upper(column_name) = 'HECS_PAYMENT_OPTION' then
		new_references.hecs_payment_option := column_value;
	end if;

	if upper(column_name) = 'DIFFERENTIAL_HECS_IND' OR
	column_name is null then
	    if new_references.differential_hecs_ind not IN ('Y','N') OR
	    new_references.differential_hecs_ind <> upper(new_references.differential_hecs_ind) then
		 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	         App_Exception.Raise_Exception;
	    end if;
	end if;
	if upper(column_name) = 'OUTSIDE_AUS_RES_IND' OR
	column_name is null then
	   if new_references.outside_aus_res_ind not IN ('Y','N') OR
  	   new_references.outside_aus_res_ind <> upper(new_references.outside_aus_res_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'NZ_CITIZEN_IND' OR
	column_name is null then
	   if new_references.nz_citizen_ind  not IN ('Y','N') OR
	   new_references.nz_citizen_ind <> upper(new_references.nz_citizen_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'NZ_CITIZEN_LESS2YR_IND' OR
	column_name is null then
	   if  new_references.nz_citizen_less2yr_ind not IN ('Y','N') OR
	   new_references.nz_citizen_less2yr_ind <> upper(new_references.nz_citizen_less2yr_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
 	if upper(column_name) = 'NZ_CITIZEN_NOT_RES_IND' OR
	column_name is null then
	   if  new_references.nz_citizen_not_res_ind  not IN ('Y','N') OR
	   new_references.nz_citizen_not_res_ind <> upper(new_references.nz_citizen_not_res_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'SAFETY_NET_IND' OR
	column_name is null then
	  if new_references.safety_net_ind  not IN ('Y','N') OR
	  new_references.safety_net_ind <> upper(new_references.safety_net_ind) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'TAX_FILE_CERTIFICATE_NUMBER' OR
	column_name is null then
	  if new_references.tax_file_certificate_number < 0 OR
 	   new_references.tax_file_certificate_number > 9999999999 then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'COURSE_CD' OR
	column_name is null then
	  if new_references.course_cd <> upper(new_references.course_cd) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'DIFF_HECS_IND_UPDATE_WHO' OR
	column_name is null then
 	  if new_references.diff_hecs_ind_update_who <>
	   upper(new_references.diff_hecs_ind_update_who) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
	if upper(column_name) = 'HECS_PAYMENT_OPTION' OR
	column_name is null then
	  if new_references.hecs_payment_option <>upper(new_references.hecs_payment_option) then
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  	   end if;
	end if;
END check_constraints;
 PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.hecs_payment_option = new_references.hecs_payment_option)) OR
        ((new_references.hecs_payment_option IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_HECS_PAY_OPTN_PKG.Get_PK_For_Validation (
        new_references.hecs_payment_option
        )then
	  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     end if;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        )then
	  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     end if;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_STDNTPSHECSOP
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      start_dt = x_start_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
 	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
        Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_FI_HECS_PAY_OPTN (
    x_hecs_payment_option IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_STDNTPSHECSOP
      WHERE    hecs_payment_option = x_hecs_payment_option ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCHO_HPO_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_FI_HECS_PAY_OPTN;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_STDNTPSHECSOP
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCHO_SCA_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_diff_hecs_ind_update_who IN VARCHAR2 DEFAULT NULL,
    x_diff_hecs_ind_update_on IN DATE DEFAULT NULL,
    x_outside_aus_res_ind IN VARCHAR2 DEFAULT NULL,
    x_nz_citizen_ind IN VARCHAR2 DEFAULT NULL,
    x_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT NULL,
    x_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT NULL,
    x_safety_net_ind IN VARCHAR2 DEFAULT NULL,
    x_tax_file_number IN NUMBER DEFAULT NULL,
    x_tax_file_number_collected_dt IN DATE DEFAULT NULL,
    x_tax_file_invalid_dt IN DATE DEFAULT NULL,
    x_tax_file_certificate_number IN NUMBER DEFAULT NULL,
    x_diff_hecs_ind_update_comment IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER  DEFAULT NULL,
    x_last_update_date IN DATE  DEFAULT NULL,
    x_last_updated_by IN NUMBER  DEFAULT NULL,
    x_last_update_login IN NUMBER  DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_start_dt,
      x_end_dt,
      x_hecs_payment_option,
      x_differential_hecs_ind,
      x_diff_hecs_ind_update_who,
      x_diff_hecs_ind_update_on,
      x_outside_aus_res_ind,
      x_nz_citizen_ind,
      x_nz_citizen_less2yr_ind,
      x_nz_citizen_not_res_ind,
      x_safety_net_ind,
      x_tax_file_number,
      x_tax_file_number_collected_dt,
      x_tax_file_invalid_dt,
      x_tax_file_certificate_number,
      x_diff_hecs_ind_update_comment,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF get_pk_for_validation(
		new_references.person_id,
	    	new_references.course_cd,
    		new_references.start_dt
           ) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_constraints;
      Check_Parent_Existance;
   ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
   ELSIF (p_action = 'VALIDATE_INSERT') then
	 IF get_pk_for_validation(
		new_references.person_id,
	    	new_references.course_cd,
    		new_references.start_dt
           ) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
	null;
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
      -- AfterStmtInsertUpdate3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );
      -- AfterStmtInsertUpdate3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_START_DT in out NOCOPY DATE,
  X_END_DT in DATE,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_WHO in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_ON in DATE,
  X_OUTSIDE_AUS_RES_IND in VARCHAR2,
  X_NZ_CITIZEN_IND in VARCHAR2,
  X_NZ_CITIZEN_LESS2YR_IND in VARCHAR2,
  X_NZ_CITIZEN_NOT_RES_IND in VARCHAR2,
  X_SAFETY_NET_IND in VARCHAR2,
  X_TAX_FILE_NUMBER in NUMBER,
  X_TAX_FILE_NUMBER_COLLECTED_DT in DATE,
  X_TAX_FILE_INVALID_DT in DATE,
  X_TAX_FILE_CERTIFICATE_NUMBER in NUMBER,
  X_DIFF_HECS_IND_UPDATE_COMMENT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_STDNTPSHECSOP
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and START_DT = NEW_REFERENCES.START_DT;
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

	   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   	   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
       X_PROGRAM_APPLICATION_ID :=  FND_GLOBAL.PROG_APPL_ID;

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

Before_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_person_id => X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_start_dt => X_START_DT,
  x_end_dt => X_END_DT,
  x_hecs_payment_option => X_HECS_PAYMENT_OPTION,
  x_differential_hecs_ind => X_DIFFERENTIAL_HECS_IND,
  x_diff_hecs_ind_update_who => X_DIFF_HECS_IND_UPDATE_WHO,
  x_diff_hecs_ind_update_on => X_DIFF_HECS_IND_UPDATE_ON,
  x_outside_aus_res_ind => X_OUTSIDE_AUS_RES_IND,
  x_nz_citizen_ind => X_NZ_CITIZEN_IND,
  x_nz_citizen_less2yr_ind => X_NZ_CITIZEN_LESS2YR_IND,
  x_nz_citizen_not_res_ind => X_NZ_CITIZEN_NOT_RES_IND,
  x_safety_net_ind => X_SAFETY_NET_IND,
  x_tax_file_number => X_TAX_FILE_NUMBER,
  x_tax_file_number_collected_dt => X_TAX_FILE_NUMBER_COLLECTED_DT,
  x_tax_file_invalid_dt => X_TAX_FILE_INVALID_DT,
  x_tax_file_certificate_number => X_TAX_FILE_CERTIFICATE_NUMBER,
  x_diff_hecs_ind_update_comment => X_DIFF_HECS_IND_UPDATE_COMMENT,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
);

  insert into IGS_EN_STDNTPSHECSOP (
    PERSON_ID,
    COURSE_CD,
    START_DT,
    END_DT,
    HECS_PAYMENT_OPTION,
    DIFFERENTIAL_HECS_IND,
    DIFF_HECS_IND_UPDATE_WHO,
    DIFF_HECS_IND_UPDATE_ON,
    OUTSIDE_AUS_RES_IND,
    NZ_CITIZEN_IND,
    NZ_CITIZEN_LESS2YR_IND,
    NZ_CITIZEN_NOT_RES_IND,
    SAFETY_NET_IND,
    TAX_FILE_NUMBER,
    TAX_FILE_NUMBER_COLLECTED_DT,
    TAX_FILE_INVALID_DT,
    TAX_FILE_CERTIFICATE_NUMBER,
    DIFF_HECS_IND_UPDATE_COMMENTS,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.HECS_PAYMENT_OPTION,
    NEW_REFERENCES.DIFFERENTIAL_HECS_IND,
    NEW_REFERENCES.DIFF_HECS_IND_UPDATE_WHO,
    NEW_REFERENCES.DIFF_HECS_IND_UPDATE_ON,
    NEW_REFERENCES.OUTSIDE_AUS_RES_IND,
    NEW_REFERENCES.NZ_CITIZEN_IND,
    NEW_REFERENCES.NZ_CITIZEN_LESS2YR_IND,
    NEW_REFERENCES.NZ_CITIZEN_NOT_RES_IND,
    NEW_REFERENCES.SAFETY_NET_IND,
    NEW_REFERENCES.TAX_FILE_NUMBER,
    NEW_REFERENCES.TAX_FILE_NUMBER_COLLECTED_DT,
    NEW_REFERENCES.TAX_FILE_INVALID_DT,
    NEW_REFERENCES.TAX_FILE_CERTIFICATE_NUMBER,
    NEW_REFERENCES.DIFF_HECS_IND_UPDATE_COMMENTS,
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

After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_WHO in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_ON in DATE,
  X_OUTSIDE_AUS_RES_IND in VARCHAR2,
  X_NZ_CITIZEN_IND in VARCHAR2,
  X_NZ_CITIZEN_LESS2YR_IND in VARCHAR2,
  X_NZ_CITIZEN_NOT_RES_IND in VARCHAR2,
  X_SAFETY_NET_IND in VARCHAR2,
  X_TAX_FILE_NUMBER in NUMBER,
  X_TAX_FILE_NUMBER_COLLECTED_DT in DATE,
  X_TAX_FILE_INVALID_DT in DATE,
  X_TAX_FILE_CERTIFICATE_NUMBER in NUMBER,
  X_DIFF_HECS_IND_UPDATE_COMMENT in VARCHAR2
) AS
  cursor c1 is select
      END_DT,
      HECS_PAYMENT_OPTION,
      DIFFERENTIAL_HECS_IND,
      DIFF_HECS_IND_UPDATE_WHO,
      DIFF_HECS_IND_UPDATE_ON,
      OUTSIDE_AUS_RES_IND,
      NZ_CITIZEN_IND,
      NZ_CITIZEN_LESS2YR_IND,
      NZ_CITIZEN_NOT_RES_IND,
      SAFETY_NET_IND,
      TAX_FILE_NUMBER,
      TAX_FILE_NUMBER_COLLECTED_DT,
      TAX_FILE_INVALID_DT,
      TAX_FILE_CERTIFICATE_NUMBER,
      DIFF_HECS_IND_UPDATE_COMMENTS
    from IGS_EN_STDNTPSHECSOP
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

      if ( ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND (tlinfo.HECS_PAYMENT_OPTION = X_HECS_PAYMENT_OPTION)
      AND (tlinfo.DIFFERENTIAL_HECS_IND = X_DIFFERENTIAL_HECS_IND)
      AND ((tlinfo.DIFF_HECS_IND_UPDATE_WHO = X_DIFF_HECS_IND_UPDATE_WHO)
           OR ((tlinfo.DIFF_HECS_IND_UPDATE_WHO is null)
               AND (X_DIFF_HECS_IND_UPDATE_WHO is null)))
      AND ((tlinfo.DIFF_HECS_IND_UPDATE_ON = X_DIFF_HECS_IND_UPDATE_ON)
           OR ((tlinfo.DIFF_HECS_IND_UPDATE_ON is null)
               AND (X_DIFF_HECS_IND_UPDATE_ON is null)))
      AND (tlinfo.OUTSIDE_AUS_RES_IND = X_OUTSIDE_AUS_RES_IND)
      AND (tlinfo.NZ_CITIZEN_IND = X_NZ_CITIZEN_IND)
      AND (tlinfo.NZ_CITIZEN_LESS2YR_IND = X_NZ_CITIZEN_LESS2YR_IND)
      AND (tlinfo.NZ_CITIZEN_NOT_RES_IND = X_NZ_CITIZEN_NOT_RES_IND)
      AND (tlinfo.SAFETY_NET_IND = X_SAFETY_NET_IND)
      AND ((tlinfo.TAX_FILE_NUMBER = X_TAX_FILE_NUMBER)
           OR ((tlinfo.TAX_FILE_NUMBER is null)
               AND (X_TAX_FILE_NUMBER is null)))
      AND ((tlinfo.TAX_FILE_NUMBER_COLLECTED_DT = X_TAX_FILE_NUMBER_COLLECTED_DT)
           OR ((tlinfo.TAX_FILE_NUMBER_COLLECTED_DT is null)
               AND (X_TAX_FILE_NUMBER_COLLECTED_DT is null)))
      AND ((tlinfo.TAX_FILE_INVALID_DT = X_TAX_FILE_INVALID_DT)
           OR ((tlinfo.TAX_FILE_INVALID_DT is null)
               AND (X_TAX_FILE_INVALID_DT is null)))
      AND ((tlinfo.TAX_FILE_CERTIFICATE_NUMBER = X_TAX_FILE_CERTIFICATE_NUMBER)
           OR ((tlinfo.TAX_FILE_CERTIFICATE_NUMBER is null)
               AND (X_TAX_FILE_CERTIFICATE_NUMBER is null)))
      AND ((tlinfo.DIFF_HECS_IND_UPDATE_COMMENTS = X_DIFF_HECS_IND_UPDATE_COMMENT)
           OR ((tlinfo.DIFF_HECS_IND_UPDATE_COMMENTS is null)
               AND (X_DIFF_HECS_IND_UPDATE_COMMENT is null)))
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_WHO in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_ON in DATE,
  X_OUTSIDE_AUS_RES_IND in VARCHAR2,
  X_NZ_CITIZEN_IND in VARCHAR2,
  X_NZ_CITIZEN_LESS2YR_IND in VARCHAR2,
  X_NZ_CITIZEN_NOT_RES_IND in VARCHAR2,
  X_SAFETY_NET_IND in VARCHAR2,
  X_TAX_FILE_NUMBER in NUMBER,
  X_TAX_FILE_NUMBER_COLLECTED_DT in DATE,
  X_TAX_FILE_INVALID_DT in DATE,
  X_TAX_FILE_CERTIFICATE_NUMBER in NUMBER,
  X_DIFF_HECS_IND_UPDATE_COMMENT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
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
IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;




Before_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_person_id => X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_start_dt => X_START_DT,
  x_end_dt => X_END_DT,
  x_hecs_payment_option => X_HECS_PAYMENT_OPTION,
  x_differential_hecs_ind => X_DIFFERENTIAL_HECS_IND,
  x_diff_hecs_ind_update_who => X_DIFF_HECS_IND_UPDATE_WHO,
  x_diff_hecs_ind_update_on => X_DIFF_HECS_IND_UPDATE_ON,
  x_outside_aus_res_ind => X_OUTSIDE_AUS_RES_IND,
  x_nz_citizen_ind => X_NZ_CITIZEN_IND,
  x_nz_citizen_less2yr_ind => X_NZ_CITIZEN_LESS2YR_IND,
  x_nz_citizen_not_res_ind => X_NZ_CITIZEN_NOT_RES_IND,
  x_safety_net_ind => X_SAFETY_NET_IND,
  x_tax_file_number => X_TAX_FILE_NUMBER,
  x_tax_file_number_collected_dt => X_TAX_FILE_NUMBER_COLLECTED_DT,
  x_tax_file_invalid_dt => X_TAX_FILE_INVALID_DT,
  x_tax_file_certificate_number => X_TAX_FILE_CERTIFICATE_NUMBER,
  x_diff_hecs_ind_update_comment => X_DIFF_HECS_IND_UPDATE_COMMENT,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
);


 if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=  OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=    OLD_REFERENCES.PROGRAM_UPDATE_DATE;
   else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
   end if;
  end if;


  update IGS_EN_STDNTPSHECSOP set
    END_DT = X_END_DT,
    HECS_PAYMENT_OPTION = NEW_REFERENCES.HECS_PAYMENT_OPTION,
    DIFFERENTIAL_HECS_IND = NEW_REFERENCES.DIFFERENTIAL_HECS_IND,
    DIFF_HECS_IND_UPDATE_WHO = NEW_REFERENCES.DIFF_HECS_IND_UPDATE_WHO,
    DIFF_HECS_IND_UPDATE_ON = NEW_REFERENCES.DIFF_HECS_IND_UPDATE_ON,
    OUTSIDE_AUS_RES_IND = NEW_REFERENCES.OUTSIDE_AUS_RES_IND,
    NZ_CITIZEN_IND = NEW_REFERENCES.NZ_CITIZEN_IND,
    NZ_CITIZEN_LESS2YR_IND = NEW_REFERENCES.NZ_CITIZEN_LESS2YR_IND,
    NZ_CITIZEN_NOT_RES_IND = NEW_REFERENCES.NZ_CITIZEN_NOT_RES_IND,
    SAFETY_NET_IND = NEW_REFERENCES.SAFETY_NET_IND,
    TAX_FILE_NUMBER = NEW_REFERENCES.TAX_FILE_NUMBER,
    TAX_FILE_NUMBER_COLLECTED_DT = NEW_REFERENCES.TAX_FILE_NUMBER_COLLECTED_DT,
    TAX_FILE_INVALID_DT = NEW_REFERENCES.TAX_FILE_INVALID_DT,
    TAX_FILE_CERTIFICATE_NUMBER = NEW_REFERENCES.TAX_FILE_CERTIFICATE_NUMBER,
    DIFF_HECS_IND_UPDATE_COMMENTS = NEW_REFERENCES.DIFF_HECS_IND_UPDATE_COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;

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
  X_COURSE_CD in VARCHAR2,
  X_START_DT in out NOCOPY DATE,
  X_END_DT in DATE,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_WHO in VARCHAR2,
  X_DIFF_HECS_IND_UPDATE_ON in DATE,
  X_OUTSIDE_AUS_RES_IND in VARCHAR2,
  X_NZ_CITIZEN_IND in VARCHAR2,
  X_NZ_CITIZEN_LESS2YR_IND in VARCHAR2,
  X_NZ_CITIZEN_NOT_RES_IND in VARCHAR2,
  X_SAFETY_NET_IND in VARCHAR2,
  X_TAX_FILE_NUMBER in NUMBER,
  X_TAX_FILE_NUMBER_COLLECTED_DT in DATE,
  X_TAX_FILE_INVALID_DT in DATE,
  X_TAX_FILE_CERTIFICATE_NUMBER in NUMBER,
  X_DIFF_HECS_IND_UPDATE_COMMENT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_STDNTPSHECSOP
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and START_DT = nvl(X_START_DT,SYSDATE)
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_START_DT,
     X_END_DT,
     X_HECS_PAYMENT_OPTION,
     X_DIFFERENTIAL_HECS_IND,
     X_DIFF_HECS_IND_UPDATE_WHO,
     X_DIFF_HECS_IND_UPDATE_ON,
     X_OUTSIDE_AUS_RES_IND,
     X_NZ_CITIZEN_IND,
     X_NZ_CITIZEN_LESS2YR_IND,
     X_NZ_CITIZEN_NOT_RES_IND,
     X_SAFETY_NET_IND,
     X_TAX_FILE_NUMBER,
     X_TAX_FILE_NUMBER_COLLECTED_DT,
     X_TAX_FILE_INVALID_DT,
     X_TAX_FILE_CERTIFICATE_NUMBER,
     X_DIFF_HECS_IND_UPDATE_COMMENT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_START_DT,
   X_END_DT,
   X_HECS_PAYMENT_OPTION,
   X_DIFFERENTIAL_HECS_IND,
   X_DIFF_HECS_IND_UPDATE_WHO,
   X_DIFF_HECS_IND_UPDATE_ON,
   X_OUTSIDE_AUS_RES_IND,
   X_NZ_CITIZEN_IND,
   X_NZ_CITIZEN_LESS2YR_IND,
   X_NZ_CITIZEN_NOT_RES_IND,
   X_SAFETY_NET_IND,
   X_TAX_FILE_NUMBER,
   X_TAX_FILE_NUMBER_COLLECTED_DT,
   X_TAX_FILE_INVALID_DT,
   X_TAX_FILE_CERTIFICATE_NUMBER,
   X_DIFF_HECS_IND_UPDATE_COMMENT,
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


  delete from IGS_EN_STDNTPSHECSOP
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
);


end DELETE_ROW;

end IGS_EN_STDNTPSHECSOP_PKG;

/
