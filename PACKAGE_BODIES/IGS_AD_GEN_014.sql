--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_014
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_014" AS
/* $Header: IGSADB9B.pls 120.14 2006/05/30 10:59:55 pbondugu ship $ */
/******************************************************************
Created By: Tapash.Ray@oracle.com
Date Created: 12-27-2001
Purpose: Common Admissions API to
         1.Insert Admission Application , proc: insert_adm_appl
	 2.Insert Admission Program Application , proc: insert_adm_appl_prog
	 3.Insert Admission Program Application Instance , proc: insert_adm_appl_prog_inst
Known limitations,enhancements,remarks:
 Change History
Who        When          What
rrengara  17-DEC-2002    When we are creating appl , appl program and instance in when other displayed
                         the SQLERRM in the log file
cdcruz    18-feb-2002    Bug 2217104 Admit to future term Enhancement,updated tbh call for
                         new columns being added to IGS_AD_PS_APPL_INST
rbezawad  30-Oct-2004    Added logic to properly handle the security Policy errors IGS_SC_POLICY_EXCEPTION
                         and IGS_SC_POLICY_UPD_DEL_EXCEP   w.r.t. bug fix 3919112.

******************************************************************/

--Fwd Declarations
PROCEDURE logHeader(p_proc_name                         VARCHAR2
                    ,p_mode                             VARCHAR2 );
PROCEDURE logDetail(p_debug_msg                         VARCHAR2
                    ,p_mode                             VARCHAR2 );
FUNCTION validate_unit_sets(p_unit_set_cd               IN VARCHAR2,
			  p_us_version_number           IN NUMBER,
			  p_course_cd                   IN VARCHAR2,
			  p_crv_version_number          IN NUMBER,
			  p_acad_cal_type               IN VARCHAR2,
			  p_location_cd                 IN VARCHAR2,
			  p_attendance_mode             IN VARCHAR2,
			  p_attendance_type             IN VARCHAR2,
			  p_admission_cat               IN VARCHAR2,
			  p_offer_ind                   IN VARCHAR2,
			  p_unit_set_appl               IN VARCHAR2,
			  p_message_name                OUT NOCOPY VARCHAR2,
			  p_error_code                  OUT NOCOPY VARCHAR2,
			  p_return_type                 OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;
PROCEDURE get_adm_step_values(p_admission_cat           IN VARCHAR2,
  			p_s_admission_process_type      IN VARCHAR2,
			p_location_cd_ind               OUT NOCOPY VARCHAR2,
			p_attendance_type_ind           OUT NOCOPY VARCHAR2,
			p_attendance_mode_ind           OUT NOCOPY VARCHAR2);

--Proc Defs
  FUNCTION insert_adm_appl(
  p_person_id IN NUMBER ,
  p_appl_dt IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_appl_status IN VARCHAR2 ,
  p_adm_fee_status IN OUT NOCOPY VARCHAR2 ,
  p_tac_appl_ind IN VARCHAR2,
  p_adm_appl_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_spcl_grp_1   IN NUMBER ,
  p_spcl_grp_2   IN NUMBER ,
  p_common_app   IN VARCHAR2 ,
  p_application_type IN VARCHAR2 ,
  p_choice_number IN NUMBER ,
  p_routeb_pref  IN VARCHAR2 ,
  p_alt_appl_id IN VARCHAR2,
  p_appl_fee_amt IN NUMBER DEFAULT NULL,
  p_log IN VARCHAR2 DEFAULT 'Y'
  )

  RETURN BOOLEAN IS
/*****************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created : 12-27-2001
Purpose: 1.This Functions inserts an admission application
         2.Inserts record into igs_ad_appl table after validations
	 3.Returns boolean true if the record is inserted, boolean false if the proc fails.
         4.Flow/Calls used in the procedure :
		|-->IGS_AD_VAL_AA.admp_val_aa_insert  (IGSAD76B.pls)
		|-->IGS_AD_VAL_AA.admp_val_aa_acad_cal
		|-->IGS_AD_VAL_AA.admp_val_aa_adm_cal
		|-->IGS_AD_VAL_AA.admp_val_aa_adm_cat
		|-->IGS_AD_VAL_AA.admp_val_aa_appl_dt
		|-->IGS_AD_VAL_AA.admp_val_aa_aas
		|-->IGS_AD_VAL_AA.admp_val_aa_afs
		|-->IGS_AD_VAL_AA.admp_val_aa_tac_appl
		|-->IGS_AD_APPL_PKG.insert_row

Known limitations,enhancements,remarks:
Change History
Who        When          What
rrengara   8-jul-2002      Added UK Parameters choice_number and routre pref to insert_adm_appl procedure for bug 2448262 and also added to igs_ad_appl_pkg.insert_row call
	rboddu     10-OCT-2002    Added the check for NULL Application Type. Bug: 2599457
rghosh     14-nov-2002    Added UK Parameters alt_appl_id to insert_adm_appl procedure for bug 2664410 and also added to igs_ad_appl_pkg.insert_row call
*****************************************************************************************/

  --Local variables to check if the Security Policy exception already set or not.  Ref: Bug 3919112
  l_sc_encoded_text   VARCHAR2(4000);
  l_sc_msg_count NUMBER;
  l_sc_msg_index NUMBER;
  l_sc_app_short_name VARCHAR2(50);
  l_sc_message_name   VARCHAR2(50);

  BEGIN	--admp_ins_adm_appl
  	--Procedure inserts a new IGS_AD_APPL record. It uses an
  	--output parameter to pass back the new admission_appl_number used
  DECLARE
  	v_dummy		CHAR;
  	v_adm_fee_status			VARCHAR2(10);
  	v_adm_appl_number		IGS_AD_APPL.admission_appl_number%TYPE;
  	v_message_name VARCHAR2(30);
  	v_return_type			VARCHAR2(1);
  	v_title_required_ind		VARCHAR2(1)	DEFAULT 'Y';
  	v_birth_dt_required_ind		VARCHAR2(1)	DEFAULT 'Y';
  	v_fees_required_ind		VARCHAR2(1)	DEFAULT 'N';
  	v_person_encmb_chk_ind		VARCHAR2(1)	DEFAULT 'N';
  	v_cond_offer_fee_allowed_ind	VARCHAR2(1)	DEFAULT 'N';
  	cst_error				CONSTANT	VARCHAR2(1) := 'E';
  	cst_warn				CONSTANT	VARCHAR2(1) := 'W';
  	CURSOR c_apcs (
  		cp_admission_cat		IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
  		cp_s_admission_process_type
  					IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
  	SELECT	s_admission_step_type
  	FROM	IGS_AD_PRCS_CAT_STEP
  	WHERE	admission_cat = cp_admission_cat AND
  		s_admission_process_type = cp_s_admission_process_type AND
  		step_group_type <> 'TRACK'; --2402377
  		  	-- Have to find the last admission_appl_number used.
     	CURSOR	 c_aa IS
       	SELECT	 NVL(MAX(admission_appl_number),0) + 1
        	FROM  	 IGS_AD_APPL /*Replaced as part of Bug  3150054*/
        	WHERE 	 person_id = p_person_id;

      CURSOR c_appl_type(p_admission_application_type igs_ad_ss_appl_typ.admission_application_type%TYPE) IS
	SELECT a.admission_application_type
	FROM   igs_ad_ss_appl_typ a,
	       igs_ad_prcs_cat_v b
 	WHERE  a.closed_ind = 'N'
	AND    a.admission_cat = b.admission_cat
	AND    a.s_admission_process_type = b.s_admission_process_type
        AND    b.closed_ind ='N'
        AND    a.admission_application_type = p_admission_application_type;

    l_appl_type   igs_ad_ss_appl_typ.admission_application_type%TYPE;
    lv_rowid 	VARCHAR2(25);
    l_org_id	NUMBER(15);
    v_effective_dt	DATE;

  BEGIN
  	-- Work out NOCOPY the new admission_appl_number.
	OPEN c_aa;
      	FETCH c_aa
      	INTO  v_adm_appl_number;
      	IF c_aa%NOTFOUND THEN
        		RAISE NO_DATA_FOUND;
      	END IF;
      	CLOSE c_aa;
  	--
  	-- Determine the admission process category steps.
  	--
  	FOR v_apcs_rec IN c_apcs (
  			p_admission_cat,
  			p_s_admission_process_type)
  	LOOP
  		IF v_apcs_rec.s_admission_step_type = 'UN-IGS_PE_TITLE' THEN
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
  	-- Set fee status
  	IF v_fees_required_ind = 'Y' THEN
	        --modified the hardcoded text 'EXEMPT' to IGS_AD_GEN_009.ADMP_GET_SYS_AFS('EXEMPT') bug#2744113 (rghosh)
  		p_adm_fee_status := IGS_AD_GEN_009.ADMP_GET_SYS_AFS('EXEMPT');
  	END IF;
  	--
  	-- Validate insert of the admission application record.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_insert (
  			p_person_id,
  			p_adm_cal_type,
  			p_adm_ci_sequence_number,
  			p_s_admission_process_type,
  			v_person_encmb_chk_ind,
  			p_appl_dt,
  			v_title_required_ind,
  			v_birth_dt_required_ind,
  			v_message_name,
  			v_return_type) = FALSE THEN
  		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--
  	-- Validate the Academic Calendar.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_acad_cal (
  			p_acad_cal_type,
  			p_acad_ci_sequence_number,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Calendar.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_adm_cal (
  			p_adm_cal_type,
  			p_adm_ci_sequence_number,
  			p_acad_cal_type,
  			p_acad_ci_sequence_number,
  			p_admission_cat,
  			p_s_admission_process_type,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Category.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_adm_cat (
  			p_admission_cat,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Application Date.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_appl_dt (
  			p_appl_dt,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Application Status.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_aas (
  			p_person_id,
  			v_adm_appl_number,
  			p_adm_appl_status,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Fee Status.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_afs (
  			p_person_id,
  			v_adm_appl_number,
  			p_adm_fee_status,
  			v_fees_required_ind,
  			v_cond_offer_fee_allowed_ind,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the TAC Application Indicator.
  	--
	IF IGS_AD_VAL_AA.admp_val_aa_tac_appl (
  			p_person_id,
  			p_tac_appl_ind,
  			p_appl_dt,
  			p_s_admission_process_type,
  			v_message_name,
  			v_return_type) = FALSE THEN
  		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;

    --Validate the Application Type and fail the validation if Application Type passed is NULL. Bug: 2599457
        IF p_application_type IS NULL THEN
          p_message_name:= 'IGS_AD_APPL_TYPE_NULL';
          RETURN FALSE;
	ELSE
	  OPEN c_appl_type(p_application_type);
	  FETCH c_appl_type INTO l_appl_type;
	  CLOSE c_appl_type;
	    IF l_appl_type IS NULL THEN
              p_message_name:= 'IGS_AD_APPL_TYP_APC_CLOSED';
              RETURN FALSE;
	    END IF;
         END IF;

    -- Check if there are any person level holds that revoke/suspend services -- arvsrini igsm
	IF v_person_encmb_chk_ind = 'Y' THEN
  		-- Determine the effective date for performing the encumbrance check.
  		v_effective_dt := NVL(IGS_AD_GEN_006.ADMP_GET_ENCMB_DT (
  					p_adm_cal_type,
  					p_adm_ci_sequence_number),SYSDATE);

		IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (
  					p_person_id,
  					NULL,	-- Input parameter course code: not applicable
  					v_effective_dt,
  					v_message_name) THEN
			IF IGS_AD_TI_COMP.G_CALLED_FROM = 'S' THEN
  				p_message_name := 'IGS_AD_SS_PERS_HOLD_EXISTS';
			ELSE
				p_message_name := 'IGS_AD_OFR_CANNOT_BEMADE';
			END IF;
  			RETURN FALSE;
  		END IF;
  	END IF;




  	--Now insert the new record
  	--Populate the org id
	l_org_id := igs_ge_gen_003.get_org_id;

    IGS_AD_APPL_PKG.insert_row (
      					X_Mode                              => 'R',
      					X_RowId                             => lv_rowid,
      					X_Person_Id                         => p_Person_Id,
      					X_Admission_Appl_Number             => v_adm_appl_number,
      					X_Appl_Dt                           => p_Appl_Dt,
      					X_Acad_Cal_Type                     => p_Acad_Cal_Type,
      					X_Acad_Ci_Sequence_Number           => p_Acad_Ci_Sequence_Number,
      					X_Adm_Cal_Type                      => p_Adm_Cal_Type,
      					X_Adm_Ci_Sequence_Number            => p_Adm_Ci_Sequence_Number,
      					X_Admission_Cat                     => p_Admission_Cat,
      					X_S_Admission_Process_Type          => p_S_Admission_Process_Type,
      					X_Adm_Appl_Status                   => p_Adm_Appl_Status,
      					X_Adm_Fee_Status                    => p_Adm_Fee_Status,
      					X_Tac_Appl_Ind                      => p_Tac_Appl_Ind,
      					X_Org_Id			    => l_org_id,
                                        X_Spcl_Grp_1                        => p_spcl_grp_1,
                                        X_Spcl_Grp_2                        => p_spcl_grp_2,
                                        X_Common_App                        => p_common_app,
                                        x_application_type                  => p_application_type,
					x_choice_number                     => p_choice_number,
                                        x_routeb_pref                       => p_routeb_pref,
					x_alt_appl_id                       => p_alt_appl_id,
					x_appl_fee_amt                      => NVL(p_appl_fee_amt,0)
    				);

	p_adm_appl_number := v_adm_appl_number;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
            --Loop through all messages in stack to check if there is Security Policy exception already set or not.    Ref: Bug 3919112
            l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
            WHILE l_sc_msg_count <> 0 loop
              igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
              fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
              IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                --Raise the exception to Higher Level with out setting any Unhandled exception.
		p_message_name := 'IGS_SC_POLICY_EXCEPTION';
                App_Exception.Raise_Exception;
              END IF;
              l_sc_msg_count := l_sc_msg_count - 1;
            END LOOP;

            IF FND_MSG_PUB.Count_Msg < 1 THEN
	      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_014.insert_adm_appl -'||SQLERRM);
	      IGS_GE_MSG_STACK.ADD;
            END IF;
            IF (p_log = 'Y') THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
	    END IF;
	    p_message_name := 'IGS_GE_UNHANDLED_EXP';
	    App_Exception.Raise_Exception;

  END insert_adm_appl;

FUNCTION insert_adm_appl_prog(
  p_person_id IN igs_pe_person.person_id%type ,
  p_adm_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2,
  p_basis_for_admission_type IN VARCHAR2 ,
  p_admission_cd IN VARCHAR2 ,
  p_req_for_reconsideration_ind IN VARCHAR2 ,
  p_req_for_adv_standing_ind IN VARCHAR2 ,
  p_message_name out NOCOPY VARCHAR2,
  p_log IN VARCHAR2 DEFAULT 'Y')
  RETURN BOOLEAN IS
/*************************************************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created : 12-27-2001
Purpose: 1.This Functions inserts an admission application Program
         2.Inserts record into igs_ad_ps_appl table after validations
	 3.Returns boolean true if the record is inserted, boolean false if the proc fails.
         4.Flow/Calls used in the procedure :
		|-->IGS_AD_GEN_002.admp_get_aa_dtl
		|-->IGS_AD_VAL_ACA.admp_val_pref_limit(Validate preference limit) -IGSAD21B.pls
		|-->IGS_AD_VAL_ACAI.admp_val_acai_course(Validate the nominated COURSE code) -IGSAD22B.pls
		|-->IGS_AD_VAL_ACAI.admp_val_aca_sca(Validate against current student COURSE attempt) -IGSAD22B.pls
		|-->Validate basis for admission type closed indicator
		|-->Validate admission code closed indicator
		|-->IGS_AD_VAL_ACA.admp_val_aca_req_rec -IGSAD21B.pls
		|-->IGS_AD_VAL_ACA.admp_val_aca_req_adv -IGSAD21B.pls
		|-->IGS_AD_VAL_ACA.admp_val_aca_trnsfr(validation for course transfer)
		|-->IGS_AD_PS_APPL_PKG.insert_row(Insert the record after all validation has been performed) -IGSAI16B.pls
Known limitations,enhancements,remarks:
Change History
Who        When          What
***************************************************************************************************************************/

	e_integrity_exception		EXCEPTION;
  	PRAGMA EXCEPTION_INIT(e_integrity_exception, -2291);
        lv_mode VARCHAR2(1) DEFAULT 'R';


BEGIN	-- insert_adm_appl --Main Loop Begin
  	-- This module validate IGS_AD_PS_APLINSTUNT unit version.
logheader('insert_adm_appl',null);
  DECLARE --i=Inner Loop Declare
  	v_admission_cat			IGS_AD_APPL.admission_cat%TYPE DEFAULT NULL;
  	v_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE DEFAULT   NULL;
  	v_acad_cal_type			IGS_AD_APPL.acad_cal_type%TYPE DEFAULT NULL;
  	v_acad_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE DEFAULT 0;
  	v_adm_cal_type			IGS_AD_APPL.adm_cal_type%TYPE DEFAULT NULL;
  	v_adm_ci_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE DEFAULT 0;
  	v_appl_dt			IGS_AD_APPL.appl_dt%TYPE DEFAULT NULL;
  	v_adm_appl_status		IGS_AD_APPL.adm_appl_status%TYPE DEFAULT NULL;
  	v_adm_fee_status		IGS_AD_APPL.adm_fee_status%TYPE DEFAULT NULL;
  	v_crv_version_number		IGS_PS_VER.version_number%TYPE DEFAULT 0;
  	v_message_name                  VARCHAR2(30) DEFAULT 0;
  	v_return_type			VARCHAR2(1) DEFAULT NULL;
  	v_pref_limit         		IGS_AD_PRCS_CAT_STEP.step_type_restriction_num%TYPE DEFAULT NULL;
  	v_late_appl_allowed_ind		VARCHAR2(1)	DEFAULT 'N';
  	v_req_reconsider_allowed_ind	VARCHAR2(1)	DEFAULT 'N';
  	v_req_adv_standing_allowed_ind	VARCHAR2(1)	DEFAULT 'N';
	v_check_course_encumb		VARCHAR2(1)	DEFAULT 'N';
	cst_error			CONSTANT	VARCHAR2(1) := 'E';


	CURSOR c_apcs(
  			cp_admission_cat	IGS_AD_APPL.admission_cat%TYPE,
			cp_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE)
	IS
  	SELECT	s_admission_step_type,
  	     	step_type_restriction_num
	FROM	IGS_AD_PRCS_CAT_STEP
	WHERE	admission_cat = cp_admission_cat AND
  		s_admission_process_type = cp_s_admission_process_type AND
  		step_group_type <> 'TRACK'; -- 2402377

	CURSOR c_prg_exists(cp_person_id            IGS_AD_PS_APPL.person_id%TYPE,
                            cp_appl_no              IGS_AD_PS_APPL.admission_appl_number%TYPE,
			    cp_nominated_course_cd  IGS_AD_PS_APPL.nominated_course_cd%TYPE)
	IS
	SELECT tab.*  --multiorg table , so rowid need not be selected explicitly
	FROM   IGS_AD_PS_APPL tab
	WHERE  person_id = cp_person_id AND
	       admission_appl_number = cp_appl_no AND
	       nominated_course_cd = cp_nominated_course_cd;

        c_prg_exists_rec c_prg_exists%ROWTYPE;

	lv_rowid		VARCHAR2(25);
	l_org_id		NUMBER(15);
  BEGIN --Inner Loop Begin
  	p_message_name := NULL;
  	-- Get admission application details required for validation
logDetail('Before Call to IGS_AD_GEN_002.admp_get_aa_dtl',null);
	IGS_AD_GEN_002.admp_get_aa_dtl(
  			p_person_id,
  			p_adm_appl_number,
  			v_admission_cat,
  			v_s_admission_process_type,
  			v_acad_cal_type,
  			v_acad_ci_sequence_number,
  			v_adm_cal_type,
  			v_adm_ci_sequence_number,
  			v_appl_dt,
  			v_adm_appl_status,
  			v_adm_fee_status);
  	IF v_appl_dt IS NULL THEN
		p_message_name := 'IGS_AD_ADMAPPL_NOT_FOUND';
  		RETURN FALSE;
  	END IF;
  	-- Determine the admission process category steps.
  	FOR v_apcs_rec IN c_apcs(
  				v_admission_cat,
                v_s_admission_process_type	)  LOOP
  		IF v_apcs_rec.s_admission_step_type = 'PREF-LIMIT' THEN
  			v_pref_limit := v_apcs_rec.step_type_restriction_num;
  		END IF;
  		IF v_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
  			v_late_appl_allowed_ind := 'Y';
  		END IF;
  		IF v_apcs_rec.s_admission_step_type = 'RECONSIDER' THEN
  			v_req_reconsider_allowed_ind := 'Y';
  		END IF;
  		IF v_apcs_rec.s_admission_step_type = 'ADVSTAND' THEN
  			v_req_adv_standing_allowed_ind := 'Y';
		END IF;
		IF v_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
			v_check_course_encumb := 'Y';
		END IF;


  	END LOOP;
logDetail('Before Call to Igs_Ad_Val_Aca.admp_val_pref_limit',null);
	-- Validate preference limit
  	IF Igs_Ad_Val_Aca.admp_val_pref_limit(
  					p_person_id,
  					p_adm_appl_number,
  					p_nominated_course_cd,
  					-1,  			-- (acai sequence number not yet known)
  					v_s_admission_process_type,
  					v_pref_limit,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
logDetail('Before Call to Igs_Ad_Val_Acai.admp_val_acai_course',null);
  	-- Validate the nominated COURSE code
  	IF NOT Igs_Ad_Val_Acai.admp_val_acai_course(
  						p_nominated_course_cd,
  						NULL,
  						v_admission_cat,
  						v_s_admission_process_type,
  						v_acad_cal_type,
  						v_acad_ci_sequence_number,
  						v_adm_cal_type,
  						v_adm_ci_sequence_number,
  						v_appl_dt,
  						v_late_appl_allowed_ind,
  						'N',			-- offer indicator
  						v_crv_version_number,	-- out NOCOPY parameters
  						v_message_name,
  						v_return_type) THEN
  		IF v_return_type = 'E' THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
logDetail('Before call to Igs_Ad_Val_Acai.admp_val_aca_sca',null);
  	-- Validate against current student COURSE attempt
  	IF NOT IGS_AD_VAL_ACAI.admp_val_aca_sca(
  					p_person_id,
  					p_nominated_course_cd,
  					v_appl_dt,
  					v_admission_cat,
  					v_s_admission_process_type,
  					NULL,	-- Fee category.
  					NULL,	-- Correspondence category.
  					NULL,	-- Enrolment category.
  					'N',	-- Offer indicator
  					v_message_name,
  					v_return_type) THEN
  		IF v_return_type = 'E' THEN
	  		p_message_name := v_message_name;
 			RETURN FALSE;
  		END IF;
  	END IF;
logDetail('Before call to Igs_Ad_Val_Aca.admp_val_bfa_closed',null);
  	-- Validate basis for admission type closed indicator
  	IF p_basis_for_admission_type IS NOT NULL THEN
  		IF NOT Igs_Ad_Val_Aca.admp_val_bfa_closed(
  						p_basis_for_admission_type,
  						v_message_name) THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate admission code closed indicator
logDetail('Before call to Igs_Ad_Val_Aca.admp_val_aco_closed',null);
  	IF p_admission_cd IS NOT NULL THEN
  		IF NOT Igs_Ad_Val_Aca.admp_val_aco_closed(
  						p_admission_cd,
  						v_message_name) THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
logDetail('Before Call to Igs_Ad_Val_Aca.admp_val_aca_req_rec',null);
  	IF  Igs_Ad_Val_Aca.admp_val_aca_req_rec(
  					p_req_for_reconsideration_ind,
  					v_req_reconsider_allowed_ind,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
logDetail('Before Call to Igs_Ad_Val_Aca.admp_val_aca_req_adv',null);
  	IF  Igs_Ad_Val_Aca.admp_val_aca_req_adv(
  					p_req_for_adv_standing_ind,
  					v_req_adv_standing_allowed_ind,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
	IF v_s_admission_process_type = 'TRANSFER' THEN
logDetail('Before Call to Igs_Ad_Val_Aca.admp_val_aca_trnsfr',null);
	    /* Include here validation for course transfer */
	     	IF  Igs_Ad_Val_Aca.admp_val_aca_trnsfr(
					p_person_id,
  					p_nominated_course_cd,
					v_crv_version_number,
					p_transfer_course_cd,
					v_s_admission_process_type,
					'N',
					v_adm_cal_type,
  					v_adm_ci_sequence_number,
					v_message_name,
					v_return_type) = FALSE THEN
  					p_message_name := v_message_name;
					RETURN FALSE;
			 END IF;
  	END IF;
-- checking holds on the program, to disallow inserting a program if that has been restricted for the person -- igsm arvsrini
  	IF v_check_course_encumb = 'Y' THEN
  		IF NOT IGS_AD_VAL_ACAI.admp_val_acai_encmb(
  					p_person_id,
  					p_nominated_course_cd,
  					v_adm_cal_type,
  					v_adm_ci_sequence_number,
  					v_check_course_encumb,
  					'Y',	-- Offer indicator
  					p_message_name,
  					v_return_type) THEN
  			IF v_return_type = cst_error THEN
				IF IGS_AD_TI_COMP.G_CALLED_FROM = 'S' THEN
					p_message_name:='IGS_AD_SS_PROG_HOLD_EXISTS';
				END IF;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;



  	-- Insert the record after all validation has been performed
    l_org_id := igs_ge_gen_003.get_org_id;
logDetail('Before Call to Igs_Ad_Ps_Appl_Pkg.Insert_Row',null);
    OPEN c_prg_exists(p_person_id,p_adm_appl_number,p_nominated_course_cd);
    FETCH c_prg_exists INTO c_prg_exists_rec;

    IF  c_prg_exists%NOTFOUND THEN
      IGS_AD_PS_APPL_PKG.Insert_Row (
        X_Mode                              => 'R',
        X_RowId                             => lv_rowid,
        X_Person_Id                         => p_person_id,
        X_Admission_Appl_Number             => p_adm_appl_number,
        X_Nominated_Course_Cd               => p_nominated_course_cd,
        X_Transfer_Course_Cd                => p_transfer_course_cd,
        X_Basis_For_Admission_Type          => p_basis_for_admission_type,
        X_Admission_Cd                      => p_admission_cd,
        X_Course_Rank_Set                   => NULL,
        X_Course_Rank_Schedule              => NULL,
        X_Req_For_Reconsideration_Ind       => p_req_for_reconsideration_ind,
        X_Req_For_Adv_Standing_Ind          => p_req_for_adv_standing_ind,
        X_Org_Id		            => l_org_id
      );

    ELSE

    IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
    THEN
      lv_mode := 'S';
    END IF;
      IGS_AD_PS_APPL_PKG.update_Row (
        X_RowId                             => c_prg_exists_rec.row_id,
        X_Person_Id                         => NVL(p_person_id,c_prg_exists_rec.person_id),
        X_Admission_Appl_Number             => NVL(p_adm_appl_number,c_prg_exists_rec.admission_appl_number),
        X_Nominated_Course_Cd               => NVL(p_nominated_course_cd,c_prg_exists_rec.nominated_course_cd),
        X_Transfer_Course_Cd                => NVL(p_transfer_course_cd,c_prg_exists_rec.transfer_course_cd),
        X_Basis_For_Admission_Type          => NVL(p_basis_for_admission_type,c_prg_exists_rec.basis_for_admission_type),
        X_Admission_Cd                      => NVL(p_admission_cd,c_prg_exists_rec.admission_cd),
        X_Course_Rank_Set                   => c_prg_exists_rec.Course_Rank_Set,
        X_Course_Rank_Schedule              => c_prg_exists_rec.Course_Rank_Schedule,
        X_Req_For_Reconsideration_Ind       => NVL(p_req_for_reconsideration_ind,c_prg_exists_rec.req_for_reconsideration_ind),
        X_Req_For_Adv_Standing_Ind          => NVL(p_req_for_adv_standing_ind,c_prg_exists_rec.req_for_adv_standing_ind),
        X_Mode                              => lv_mode -- enable security for Admin
      );
    END IF;
    CLOSE c_prg_exists;
    RETURN TRUE;

  END;
EXCEPTION
  	WHEN e_integrity_exception THEN
	    Fnd_Message.Set_Name('IGS','IGS_AD_ADM_APPL_NOT_INS');
		App_Exception.Raise_Exception;
  		RETURN FALSE;
  	WHEN OTHERS THEN
          IF (p_log = 'Y') THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
          END IF;

	  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      	  App_Exception.Raise_Exception;
END insert_adm_appl_prog;


FUNCTION insert_adm_appl_prog_inst(
  p_person_id IN igs_pe_person.person_id%type ,
  p_admission_appl_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2,
  p_appl_dt IN DATE ,
  p_adm_fee_status IN VARCHAR2 ,
  p_preference_number IN NUMBER ,
  p_offer_dt IN DATE ,
  p_offer_response_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_funding_source IN VARCHAR2,
  p_edu_goal_prior_enroll IN NUMBER,
  p_app_source_id IN NUMBER,
  p_apply_for_finaid IN VARCHAR2,
  p_finaid_apply_date IN DATE,
  p_attribute_category	IN VARCHAR2,
  p_attribute1	IN VARCHAR2,
  p_attribute2	IN VARCHAR2,
  p_attribute3	IN VARCHAR2,
  p_attribute4	IN VARCHAR2,
  p_attribute5	IN VARCHAR2,
  p_attribute6	IN VARCHAR2,
  p_attribute7	IN VARCHAR2,
  p_attribute8	IN VARCHAR2,
  p_attribute9	IN VARCHAR2,
  p_attribute10	IN VARCHAR2,
  p_attribute11	IN VARCHAR2,
  p_attribute12	IN VARCHAR2,
  p_attribute13	IN VARCHAR2,
  p_attribute14	IN VARCHAR2,
  p_attribute15	IN VARCHAR2,
  p_attribute16	IN VARCHAR2,
  p_attribute17	IN VARCHAR2,
  p_attribute18	IN VARCHAR2,
  p_attribute19	IN VARCHAR2,
  p_attribute20	IN VARCHAR2,
  p_attribute21	IN VARCHAR2,
  p_attribute22	IN VARCHAR2,
  p_attribute23	IN VARCHAR2,
  p_attribute24	IN VARCHAR2,
  p_attribute25	IN VARCHAR2,
  p_attribute26	IN VARCHAR2,
  p_attribute27	IN VARCHAR2,
  p_attribute28	IN VARCHAR2,
  p_attribute29	IN VARCHAR2,
  p_attribute30	IN VARCHAR2,
  p_attribute31	IN VARCHAR2,
  p_attribute32	IN VARCHAR2,
  p_attribute33	IN VARCHAR2,
  p_attribute34	IN VARCHAR2,
  p_attribute35	IN VARCHAR2,
  p_attribute36	IN VARCHAR2,
  p_attribute37	IN VARCHAR2,
  p_attribute38	IN VARCHAR2,
  p_attribute39	IN VARCHAR2,
  p_attribute40	IN VARCHAR2,
  p_ss_application_id IN VARCHAR2,
  p_sequence_number OUT NOCOPY NUMBER,
  p_return_type   OUT NOCOPY VARCHAR2 ,
  p_error_code    OUT NOCOPY VARCHAR2,
  p_message_name  OUT NOCOPY VARCHAR2,
  p_entry_status  IN NUMBER,
  p_entry_level   IN NUMBER,
  p_sch_apl_to_id IN NUMBER,
  p_hecs_payment_option  IN VARCHAR2,
  p_log IN VARCHAR2 DEFAULT 'Y')
  RETURN BOOLEAN IS

/*************************************************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created : 12-27-2001
Purpose: 1.This Functions inserts an admission application Program Instance
         2.Inserts record into igs_ad_ps_appl_inst table after validations
	 3.Returns boolean true if the record is inserted, boolean false if the proc fails.
         4.Flow/Calls used in the procedure :
		|-->IGS_AD_GEN_004.admp_get_apcs_val(Get the admission process category steps.) -IGSAD04B.pls
		|-->IGS_AD_VAL_ACAI.admp_val_acai_fc(Set fee category) -IGSAD22B.pls
		|-->IGS_AD_GEN_005.admp_get_dflt_ecm(Set enrollment category) -IGSAD05B.pls
		|-->IGS_AD_VAL_ACAI.admp_val_acai_cc(Set correspondence category) -IGSAD22B.pls
		|-->Set admission COURSE application instance statuses for PENDING outcome
		|-->validate_unit_sets(Validate the admission COURSE offering IGS_PS_UNIT set)
		|-->admp_get_adm_step_values(get if location code, attendance mode and attendance type indicators are set)
		|-->IGS_AD_VAL_ACAI.admp_val_acai_cop(Validate program offering patterns) -IGSAD22B.pls
		|-->IGS_AD_PS_APPL_INST_PKG.insert_row(Insert an admission program application instance with PENDING outcome) -IGSAI18B.pls
Known limitations,enhancements,remarks:
Change History
Who        When          What
vdixit     19-Feb-2002   Added the logic to raise the business event in work flow
			 when a Self Service Admission Application is created enh : 2229679
nshee      29-Aug-2002 Added the six columns in the insert row for Deferments build - 2395510
tray       10-Sep-2002 Added Call to IGS_AD_GEN_003.get_entr_doc_apc for ADCR040 build - 2395510
pbondugu  28-Mar-2003    Added funding_source parameter in spec and body.
***************************************************************************************************************************/
  l_sc_encoded_text   VARCHAR2(4000);
  l_sc_msg_count NUMBER;
  l_sc_msg_index NUMBER;
  l_sc_app_short_name VARCHAR2(50);
  l_sc_message_name   VARCHAR2(50);

BEGIN
  	-- This procedure inserts a new IGS_AD_PS_APPL_INST record.
	logHeader('insert_adm_appl_prog_inst',null);
  DECLARE
  	e_resource_busy			EXCEPTION;
  	PRAGMA EXCEPTION_INIT (e_resource_busy, -54);

	p_dummy		                VARCHAR2(10);
  	v_check			        CHAR;
  	v_s_admission_process_type	IGS_AD_PRCS_CAT.s_admission_process_type%TYPE;
  	v_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE;
  	v_enrolment_cat			IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE;
  	v_correspondence_cat		IGS_CO_CAT.correspondence_cat%TYPE;
	v_funding_source	IGS_FI_FUND_SRC.funding_source%TYPE;
  	v_hecs_payment_option		IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE;
  	v_description			IGS_FI_FEE_CAT.description%TYPE;
  	v_message_name                  VARCHAR2(30);
  	v_hecs_message_name		VARCHAR2(30);
  	v_pre_enrol_message_name	VARCHAR2(30);
  	v_outcome_message_name		VARCHAR2(30);
  	v_apcs_pref_limit_ind		VARCHAR2(127);
  	v_apcs_app_fee_ind		VARCHAR2(127);
  	v_apcs_late_app_ind		VARCHAR2(127);
  	v_apcs_late_fee_ind		VARCHAR2(127);
  	v_apcs_chkpencumb_ind		VARCHAR2(127);
  	v_apcs_fee_assess_ind		VARCHAR2(127);
  	v_apcs_corcategry_ind		VARCHAR2(127);
  	v_apcs_enrcategry_ind		VARCHAR2(127);
  	v_apcs_chkcencumb_ind		VARCHAR2(127);
  	v_apcs_unit_set_ind		VARCHAR2(127);
  	v_apcs_un_crs_us_ind		VARCHAR2(127);
  	v_apcs_chkuencumb_ind		VARCHAR2(127);
  	v_apcs_unit_restr_ind		VARCHAR2(127);
  	v_apcs_unit_restriction_num	VARCHAR2(127);
  	v_apcs_un_dob_ind		VARCHAR2(127);
  	v_apcs_un_title_ind		VARCHAR2(127);
  	v_apcs_asses_cond_ind		VARCHAR2(127);
  	v_apcs_fee_cond_ind		VARCHAR2(127);
  	v_apcs_doc_cond_ind		VARCHAR2(127);
  	v_apcs_multi_off_ind		VARCHAR2(127);
  	v_apcs_multi_off_restn_num	VARCHAR2(127);
  	v_apcs_set_otcome_ind		VARCHAR2(127);
  	v_apcs_override_o_ind		VARCHAR2(127);
  	v_apcs_defer_ind		VARCHAR2(127);
  	v_apcs_ack_app_ind		VARCHAR2(127);
  	v_apcs_outcome_lt_ind		VARCHAR2(127);
  	v_apcs_pre_enrol_ind		VARCHAR2(127);
  	v_hecs_pmnt_option_found	BOOLEAN DEFAULT TRUE;
  	v_offer_letter_ins		BOOLEAN DEFAULT TRUE;
  	v_pre_enr_done			BOOLEAN DEFAULT TRUE;
  	v_adm_doc_status 		VARCHAR2(127);
  	v_adm_entry_qual_status		VARCHAR2(127);
  	v_adm_pending_outcome_status	VARCHAR2(127);
  	v_adm_cndtnl_offer_status	VARCHAR2(127);
  	v_adm_offer_dfrmnt_status	VARCHAR2(127);
  	v_late_adm_fee_status		VARCHAR2(127);
  	v_acai_sequence_number		IGS_CA_INST.sequence_number%TYPE;
  	v_offer_adm_outcome_status	VARCHAR2(127);
  	v_adm_offer_resp_status		VARCHAR2(127);
  	v_new_adm_offer_resp_status	VARCHAR2(127);
  	v_offer_response_dt		DATE;
  	v_return_type			VARCHAR2(1);
  	cst_error			CONSTANT VARCHAR2(1):= 'E';
	V_ERROR_CODE                    VARCHAR2(30);
	L_CHECK                         VARCHAR2(1);
	l_location_cd_ind               VARCHAR2(1);
	l_attendance_type_ind           VARCHAR2(1);
	l_attendance_mode_ind           VARCHAR2(1);
	l_var                           VARCHAR2(1);
	l_late_ind                      VARCHAR2(1);
	l_finaid_apply_date             DATE;
        l_msg_data                      VARCHAR2(2000);
	v_admission_cat			IGS_AD_APPL.admission_cat%TYPE DEFAULT NULL;


	CURSOR c_nxt_acai_seq_num IS
  		SELECT	NVL(MAX(sequence_number), 0) + 1
  		FROM	IGS_AD_PS_APPL_INST
  		WHERE
  			person_id		= p_person_id 	AND
  			admission_appl_number	= p_admission_appl_number AND
  			nominated_course_cd	= p_course_cd;
  	CURSOR c_upd_acai IS
		SELECT	ROWID, APAI.*
  		FROM	IGS_AD_PS_APPL_INST APAI
  		WHERE
  			person_id		= p_person_id			AND
  			admission_appl_number	= p_admission_appl_number	AND
  			nominated_course_cd	= p_course_cd			AND
  			sequence_number		= v_acai_sequence_number
  		FOR UPDATE OF person_id NOWAIT;

        CURSOR get_app_source (p_app_source_id NUMBER) IS
          SELECT system_status
          FROM  igs_ad_code_classes
          WHERE code_id = p_app_source_id AND
                class = 'SYS_APPL_SOURCE';

	CURSOR c_apcs(
  			cp_admission_cat	IGS_AD_APPL.admission_cat%TYPE,
			cp_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE)
	IS
  	SELECT	s_admission_step_type,
  	     	step_type_restriction_num
	FROM	IGS_AD_PRCS_CAT_STEP
	WHERE	admission_cat = cp_admission_cat AND
  		s_admission_process_type = cp_s_admission_process_type AND
  		step_group_type <> 'TRACK'; -- 2402377



	 Rec_IGS_AD_PS_APPL_Inst		c_upd_acai%ROWTYPE;
	 LV_ROWID					VARCHAR2(25);
	 l_org_id				NUMBER(15);
	 v_app_source      igs_ad_code_classes.system_status%TYPE;
	 v_check_course_encumb		VARCHAR2(1)	DEFAULT 'N';
	 v_unit_set_appl_ind		VARCHAR2(1)	DEFAULT 'N';

        --begin apadegal adtd001 igs.m
	  l_person_type_code IGS_PE_PERSON_TYPES.person_type_code%TYPE;
	   CURSOR c_person_type_code(l_system_type IGS_PE_PERSON_TYPES.system_type%TYPE)
		IS
		    SELECT person_type_code
		    FROM igs_pe_person_types
		    WHERE system_type=l_system_type;
	lv_rowid2 VARCHAR2(25) ;
        lv_type_instance_id NUMBER(15);
        lv_sysdate DATE := TRUNC(SYSDATE);
	lv_mode VARCHAR2(1) DEFAULT 'R';
	--end apadegal adtd001 igs.m

  BEGIN
  	p_message_name := NULL;

	FOR v_apcs_rec IN c_apcs (v_admission_cat,			--igsm
                                  v_s_admission_process_type)
	LOOP
	  IF v_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
		v_check_course_encumb := 'Y';
	  ELSIF v_apcs_rec.s_admission_step_type = 'UNIT-SET' THEN
                v_unit_set_appl_ind := 'Y';
	  END IF;
	END LOOP;

  	--------------------------------------------------
  	-- Get the admission process category steps.
  	--------------------------------------------------
logDetail('Before Call to IGS_AD_GEN_004.admp_get_apcs_val',null);
	IGS_AD_GEN_004.admp_get_apcs_val(
  			p_admission_cat,
  			p_s_admission_process_type,
  			v_apcs_pref_limit_ind,
  			v_apcs_app_fee_ind,
  			v_apcs_late_app_ind,
  			v_apcs_late_fee_ind,
  			v_apcs_chkpencumb_ind,
  			v_apcs_fee_assess_ind,
  			v_apcs_corcategry_ind,
  			v_apcs_enrcategry_ind,
  			v_apcs_chkcencumb_ind,
  			v_apcs_unit_set_ind,
  			v_apcs_un_crs_us_ind,
  			v_apcs_chkuencumb_ind,
  			v_apcs_unit_restr_ind,
  			v_apcs_unit_restriction_num,
  			v_apcs_un_dob_ind,
  			v_apcs_un_title_ind,
  			v_apcs_asses_cond_ind,
  			v_apcs_fee_cond_ind,
  			v_apcs_doc_cond_ind,
  			v_apcs_multi_off_ind,
  			v_apcs_multi_off_restn_num,
  			v_apcs_set_otcome_ind,
  			v_apcs_override_o_ind,
  			v_apcs_defer_ind,
  			v_apcs_ack_app_ind,
  			v_apcs_outcome_lt_ind,
  			v_apcs_pre_enrol_ind);

  	--------------------------------
  	-- Set fee category
  	--------------------------------
  	IF p_fee_cat IS NULL	THEN

  		-- Derive the fee category
logDetail('Before Call to IGS_AD_GEN_005.admp_get_dflt_fcm',null);
  		v_fee_cat := IGS_AD_GEN_005.admp_get_dflt_fcm(
  					p_admission_cat,
  					v_description);

	ELSIF IGS_AD_VAL_ACAI.admp_val_acai_fc(
  				p_admission_cat,
  				p_fee_cat,
  				v_message_name) = FALSE THEN
  		v_fee_cat := NULL;
  	ELSE
  		v_fee_cat := p_fee_cat;
  	END IF;

	--------------------------------
  	-- Set enrollment category
  	--------------------------------
  	IF p_enrolment_cat IS NULL THEN
  		-- Derive the enrolment category
logDetail('Before Call to IGS_AD_GEN_005.admp_get_dflt_ecm',null);
		v_enrolment_cat := IGS_AD_GEN_005.admp_get_dflt_ecm(
  					p_admission_cat,
  					v_description);
  	ELSIF Igs_Ad_Val_Acai.admp_val_acai_ec(
  			p_admission_cat,
  			p_enrolment_cat,
  			v_message_name) = FALSE THEN
  		v_enrolment_cat := NULL;
  	ELSE
  		v_enrolment_cat := p_enrolment_cat;
  	END IF;

	--------------------------------
  	-- Set correspondence category
  	--------------------------------
  	IF p_correspondence_cat IS NULL	THEN
  		-- Derive the correspondence category
logDetail('Before Call to IGS_AD_GEN_005.admp_get_dflt_ccm',null);
		v_correspondence_cat := IGS_AD_GEN_005.admp_get_dflt_ccm(
  						p_admission_cat,
  						v_description);
  	ELSIF Igs_Ad_Val_Acai.admp_val_acai_cc(
  				p_admission_cat,
  				p_correspondence_cat,
  				v_message_name) = FALSE THEN
  		v_correspondence_cat := NULL;
  	ELSE
  		v_correspondence_cat := p_correspondence_cat;
  	END IF;

   	--------------------------------
  	-- Set Funding Source
  	--------------------------------
  	IF p_funding_source IS NULL THEN
  		-- Derive the Funding Source
logDetail('Before Call to IGS_AD_GEN_005.admp_get_dflt_fs',null);
             v_funding_source := IGS_AD_GEN_005.admp_get_dflt_fs(
  					p_course_cd,
                                        p_crv_version_number,
  					v_description);
  	ELSIF IGS_AD_VAL_ACAI.admp_val_acai_fs(
  				p_course_cd,
                                p_crv_version_number,
  				p_funding_source,
  				v_message_name) = FALSE THEN
  		v_funding_source := NULL;
  	ELSE
  		v_funding_source := p_funding_source;
  	END IF;
  	--------------------------------
  	-- Set HECS Payment Option
  	--------------------------------
  	IF p_hecs_payment_option IS NULL THEN
       	  -- Derive the HECS Payment Option
logDetail('Before Call to IGS_AD_GEN_005.admp_get_dflt_hpo',null);
  		v_hecs_payment_option := IGS_AD_GEN_005.admp_get_dflt_hpo(
  					p_admission_cat,
  					v_description);

	ELSIF  IGS_AD_VAL_ACAI.admp_val_acai_hpo(
  				p_admission_cat,
  				p_hecs_payment_option,
  				v_message_name) = FALSE  THEN
  		v_hecs_payment_option := NULL;
  	ELSE
  		v_hecs_payment_option := p_hecs_payment_option;
  	END IF;

	--------------------------------------------------------------------------
  	-- Set admission COURSE application instance statuses for PENDING outcome
  	--------------------------------------------------------------------------
  	v_adm_pending_outcome_status	:= IGS_AD_GEN_009.admp_get_sys_aos('PENDING');
  	v_adm_cndtnl_offer_status	:= IGS_AD_GEN_009.admp_get_sys_acos('NOT-APPLIC');
  	v_adm_offer_resp_status		:= IGS_AD_GEN_009.admp_get_sys_aors('NOT-APPLIC');
  	v_adm_offer_dfrmnt_status	:= IGS_AD_GEN_009.admp_get_sys_aods('NOT-APPLIC');

	IF v_apcs_late_fee_ind = 'Y' THEN
	        --modified the hardcoded text 'EXEMPT' to IGS_AD_GEN_009.ADMP_GET_SYS_AFS('EXEMPT') bug# 2744113 (rghosh)
		v_late_adm_fee_status := IGS_AD_GEN_009.ADMP_GET_SYS_AFS('EXEMPT');
  	ELSE
   	        --modified the hardcoded text 'NOT-APPLIC' to IGS_AD_GEN_009.ADMP_GET_SYS_AFS('NOT-APPLIC') bug# 2744113 (rghosh)
  		v_late_adm_fee_status := IGS_AD_GEN_009.ADMP_GET_SYS_AFS('NOT-APPLIC');

  	END IF;

	---------------------------------------------------
  	-- Get the next sequence number for the application
  	---------------------------------------------------
  	OPEN c_nxt_acai_seq_num;
  	FETCH c_nxt_acai_seq_num INTO v_acai_sequence_number;
  	CLOSE c_nxt_acai_seq_num;

	---------------------------------------------------------
  	-- Validate the admission COURSE offering IGS_PS_UNIT set
  	---------------------------------------------------------
logDetail('Before Call to Local Proc validate_unit_sets',null);
  	IF validate_unit_sets (
  					p_unit_set_cd,
  					p_us_version_number,
  					p_course_cd,
  					p_crv_version_number,
  					p_acad_cal_type,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_admission_cat,
  					'N',
  					v_apcs_unit_set_ind,
  					v_message_name,
					v_error_code,
  					v_return_type) = FALSE THEN
		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
 			p_return_type := v_return_type;
        		RETURN FALSE;
  		END IF;
  	END IF;

--Call routine to determine of the location code, attendance mode and attendance type indicators
--are set
logDetail('Before Call to Local Proc get_adm_step_values',null);
	get_adm_step_values(p_admission_cat,
  			p_s_admission_process_type,
			l_location_cd_ind,
			l_attendance_type_ind,
			l_attendance_mode_ind);

	/* Write code here for validating the Location Code*/
	/* SQL for validation */
 	BEGIN
  		SELECT 'X'
  			INTO l_var
  		FROM
			DUAL
  		WHERE
			NVL(l_location_cd_ind,'N') IN ('Y','N')
  			AND  NVL(l_attendance_mode_ind,'N') IN ('Y','N')
  			AND NVL(l_attendance_type_ind,'N')IN ('Y','N');
 	EXCEPTION
   		WHEN OTHERS THEN
      			logDetail('insert_adm_appl_prog_inst'|| 'Validation Failed for attendance_mode_ind or location_cd_ind or attendance_type_ind',null );
     			RAISE;
 	END;

	-------------------------------------------------------------------------------------
	-- Validate program offering patterns
	--------------------------------------------------------------------------------------
logDetail('Before Call to IGS_AD_VAL_ACAI.admp_val_acai_cop',null);
	IF NOT  IGS_AD_VAL_ACAI.admp_val_acai_cop(
  		p_course_cd,
  		p_crv_version_number,
  		p_location_cd,
  		p_attendance_mode,
  		p_attendance_type,
  		p_acad_cal_type,
  		p_acad_ci_sequence_number,
  		p_adm_cal_type,
  		p_adm_ci_sequence_number,
  		p_admission_cat,
  		p_s_admission_process_type,
		'N',
  		p_appl_dt,
  		v_apcs_late_app_ind,
	        'N',
		p_message_name,
  		p_return_type,
  		l_late_ind) THEN
		RETURN FALSE;
	END IF;

	IF p_apply_for_finaid NOT IN ('Y') THEN
             l_finaid_apply_date := NULL;
	ELSE
             l_finaid_apply_date := p_finaid_apply_date;
	END IF;

	------------------------------------------------------------------------------
	-- Validate if there is any hold preventing the insert of the unitset selected			-- igsm arvsrini
	------------------------------------------------------------------------------
	IF v_unit_set_appl_ind = 'Y' THEN
  		IF v_check_course_encumb = 'Y' THEN
  			IF NOT IGS_AD_VAL_ACAI.admp_val_us_encmb (
  					p_person_id,
  					p_course_cd,
  					p_unit_set_cd,
  					p_us_version_number,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
  					v_check_course_encumb,
  					'Y', 	-- Offer indicator,
  					p_message_name,
  					v_return_type) THEN
  				IF v_return_type = cst_error THEN
					IF IGS_AD_TI_COMP.G_CALLED_FROM = 'S' THEN
						p_message_name:= 'IGS_AD_SS_USET_HOLD_EXISTS';
  					END IF;
					RETURN FALSE;
  				END IF;
  			 END IF;
  		END IF;
	END IF;



	--------------------------------------------------------------------------
  	-- Insert an admission program application instance with PENDING outcome
  	--------------------------------------------------------------------------

    	l_org_id := igs_ge_gen_003.get_org_id;

	-----------------------------------------------------------------------------------------
	-- Get the Application Status and Entry Qualification Status for the application instance
	-----------------------------------------------------------------------------------------
	IGS_AD_GEN_003.get_entr_doc_apc (p_admission_cat => p_admission_cat,
	                                 p_s_admission_process_type => p_s_admission_process_type,
                                         l_adm_doc_status => v_adm_doc_status,
                                         l_adm_entr_qual_status  => v_adm_entry_qual_status);

logDetail('Before Call to Igs_Ad_Ps_Appl_Inst_Pkg.Insert_Row',null);

            IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
	    THEN
	      lv_mode := 'S';
	    END IF;

	IGS_AD_PS_APPL_INST_PKG.Insert_Row (
      				                 X_ROWID  =>   lv_rowid,
						 X_PERSON_ID  => p_Person_Id,
						 X_ADMISSION_APPL_NUMBER  => p_Admission_Appl_Number,
						 X_NOMINATED_COURSE_CD =>p_course_cd,
						 X_SEQUENCE_NUMBER  => v_acai_sequence_number,
						 X_PREDICTED_GPA  => NULL,
						 X_ACADEMIC_INDEX  => NULL,
						 X_ADM_CAL_TYPE   => p_adm_cal_type,
						 X_APP_FILE_LOCATION  => NULL,
						 X_ADM_CI_SEQUENCE_NUMBER  => p_adm_ci_sequence_number,
						 X_COURSE_CD   => p_Course_Cd,
						 X_APP_SOURCE_ID => p_app_source_id,
						 X_CRV_VERSION_NUMBER   => p_Crv_Version_Number,
						 X_WAITLIST_RANK => NULL,
						 X_LOCATION_CD     => p_Location_Cd,
						 X_ATTENT_OTHER_INST_CD =>NULL,
						 X_ATTENDANCE_MODE   => p_Attendance_Mode,
						 X_EDU_GOAL_PRIOR_ENROLL_ID => p_edu_goal_prior_enroll,
						 X_ATTENDANCE_TYPE     => p_Attendance_Type,
						 X_DECISION_MAKE_ID => NULL,
						 X_UNIT_SET_CD  => p_Unit_Set_Cd,
						 X_DECISION_DATE =>NULL,
						 X_ATTRIBUTE_CATEGORY =>p_attribute_category ,
						 X_ATTRIBUTE1=>P_ATTRIBUTE1,
						 X_ATTRIBUTE2=>P_ATTRIBUTE2,
						 X_ATTRIBUTE3=>P_ATTRIBUTE3,
						 X_ATTRIBUTE4=>P_ATTRIBUTE4,
						 X_ATTRIBUTE5=>P_ATTRIBUTE5,
						 X_ATTRIBUTE6=>P_ATTRIBUTE6,
						 X_ATTRIBUTE7=>P_ATTRIBUTE7,
						 X_ATTRIBUTE8=>P_ATTRIBUTE8,
						 X_ATTRIBUTE9=>P_ATTRIBUTE9,
						 X_ATTRIBUTE10=>P_ATTRIBUTE10,
						 X_ATTRIBUTE11=>P_ATTRIBUTE11,
						 X_ATTRIBUTE12=>P_ATTRIBUTE12,
						 X_ATTRIBUTE13=>P_ATTRIBUTE13,
						 X_ATTRIBUTE14=>P_ATTRIBUTE14,
						 X_ATTRIBUTE15=>P_ATTRIBUTE15,
						 X_ATTRIBUTE16=>P_ATTRIBUTE16,
						 X_ATTRIBUTE17=>P_ATTRIBUTE17,
						 X_ATTRIBUTE18=>P_ATTRIBUTE18,
						 X_ATTRIBUTE19=>P_ATTRIBUTE19,
						 X_ATTRIBUTE20=>P_ATTRIBUTE20,
						 X_WAITLIST_STATUS => NULL,
						 X_ATTRIBUTE21=>P_ATTRIBUTE21,
 					         X_ATTRIBUTE22=>P_ATTRIBUTE22,
						 X_ATTRIBUTE23=>P_ATTRIBUTE23,
						 X_ATTRIBUTE24=>P_ATTRIBUTE24,
						 X_ATTRIBUTE25=>P_ATTRIBUTE25,
						 X_ATTRIBUTE26=>P_ATTRIBUTE26,
						 X_ATTRIBUTE27=>P_ATTRIBUTE27,
						 X_ATTRIBUTE28=>P_ATTRIBUTE28,
						 X_ATTRIBUTE29=>P_ATTRIBUTE29,
						 X_ATTRIBUTE30=>P_ATTRIBUTE30,
						 X_ATTRIBUTE31=>P_ATTRIBUTE31,
						 X_ATTRIBUTE32=>P_ATTRIBUTE32,
						 X_ATTRIBUTE33=>P_ATTRIBUTE33,
						 X_ATTRIBUTE34=>P_ATTRIBUTE34,
						 X_ATTRIBUTE35=>P_ATTRIBUTE35,
						 X_ATTRIBUTE36=>P_ATTRIBUTE36,
						 X_ATTRIBUTE37=>P_ATTRIBUTE37,
						 X_ATTRIBUTE38=>P_ATTRIBUTE38,
						 X_ATTRIBUTE39=>P_ATTRIBUTE39,
						 X_ATTRIBUTE40=>P_ATTRIBUTE40,
						 X_SS_APPLICATION_ID=>P_SS_APPLICATION_ID,
						 X_SS_PWD=> NULL,
						 X_DECISION_REASON_ID=>NULL,
						 X_US_VERSION_NUMBER => p_Us_Version_Number,
						 X_DECISION_NOTES=>NULL,
						 X_PENDING_REASON_ID=>NULL,
						 X_PREFERENCE_NUMBER  => p_Preference_Number,
						 X_ADM_DOC_STATUS=> v_Adm_Doc_Status,
						 X_ADM_ENTRY_QUAL_STATUS=> v_Adm_Entry_Qual_Status,
						 X_DEFICIENCY_IN_PREP=>NULL,
						 X_LATE_ADM_FEE_STATUS => v_Late_Adm_Fee_Status,
						 X_SPL_CONSIDER_COMMENTS=>NULL,
						 X_APPLY_FOR_FINAID =>p_apply_for_finaid,
						 X_FINAID_APPLY_DATE=>l_finaid_apply_date,
						 X_ADM_OUTCOME_STATUS => v_adm_pending_outcome_status,
						 X_ADM_OTCM_STAT_AUTH_PER_ID=>NULL,
						 X_ADM_OUTCOME_STATUS_AUTH_DT=> NULL,
						 X_ADM_OUTCOME_STATUS_REASON =>NULL,
						 X_OFFER_DT => NULL,
						 X_OFFER_RESPONSE_DT  => NULL,
						 X_PRPSD_COMMENCEMENT_DT => NULL,
						 X_ADM_CNDTNL_OFFER_STATUS => v_adm_cndtnl_offer_status,
						 X_CNDTNL_OFFER_SATISFIED_DT => NULL,
						 X_CNDNL_OFR_MUST_BE_STSFD_IND  => 'N',
						 X_ADM_OFFER_RESP_STATUS => v_adm_offer_resp_status,
						 X_ACTUAL_RESPONSE_DT  => NULL,
						 X_ADM_OFFER_DFRMNT_STATUS  => v_adm_offer_dfrmnt_status,
						 X_DEFERRED_ADM_CAL_TYPE => NULL,
						 X_DEFERRED_ADM_CI_SEQUENCE_NUM => NULL,
						 X_DEFERRED_TRACKING_ID   => NULL,
						 X_ASS_RANK    => NULL,
						 X_SECONDARY_ASS_RANK  => NULL,
						 X_INTR_ACCEPT_ADVICE_NUM   => NULL,
						 X_ASS_TRACKING_ID => NULL,
						 X_FEE_CAT=> v_Fee_Cat,
						 X_HECS_PAYMENT_OPTION => v_Hecs_Payment_Option,
						 X_EXPECTED_COMPLETION_YR => NULL,
						 X_EXPECTED_COMPLETION_PERD => NULL,
						 X_CORRESPONDENCE_CAT => v_Correspondence_Cat,
						 X_ENROLMENT_CAT  => v_Enrolment_Cat,
						 X_FUNDING_SOURCE => v_funding_source,
						 X_APPLICANT_ACPTNCE_CNDTN => NULL,
						 X_CNDTNL_OFFER_CNDTN => NULL,
						 X_AUTHORIZED_DT => NULL,
						 X_AUTHORIZING_PERS_ID => NULL,
						 X_IDX_CALC_DATE => NULL,
						 X_MODE =>lv_mode, -- enable security for Admin
                                                 X_FUT_ACAD_CAL_TYPE                          => NULL , -- Bug # 2217104
                                                 X_FUT_ACAD_CI_SEQUENCE_NUMBER                => NULL ,-- Bug # 2217104
                                                 X_FUT_ADM_CAL_TYPE                           => NULL , -- Bug # 2217104
                                                 X_FUT_ADM_CI_SEQUENCE_NUMBER                 => NULL , -- Bug # 2217104
                                                 X_PREV_TERM_ADM_APPL_NUMBER                 => NULL , -- Bug # 2217104
                                                 X_PREV_TERM_SEQUENCE_NUMBER                 => NULL , -- Bug # 2217104
                                                 X_FUT_TERM_ADM_APPL_NUMBER                   => NULL , -- Bug # 2217104
                                                 X_FUT_TERM_SEQUENCE_NUMBER                   => NULL , -- Bug # 2217104
                                                 X_DEF_ACAD_CAL_TYPE                             => NULL, -- Bug  2395510
                    				 X_DEF_ACAD_CI_SEQUENCE_NUM          => NULL,-- Bug  2395510
		                 		 X_DEF_PREV_TERM_ADM_APPL_NUM  => NULL,-- Bug  2395510
				                 X_DEF_PREV_APPL_SEQUENCE_NUM    => NULL,-- Bug  2395510
                   				 X_DEF_TERM_ADM_APPL_NUM               => NULL,-- Bug  2395510
		                                 X_DEF_APPL_SEQUENCE_NUM                 => NULL,-- Bug  2395510
						 X_Org_Id => l_org_id,
                                                 X_ENTRY_STATUS => p_entry_status,
                                                 X_ENTRY_LEVEL => p_entry_level,
                                                 X_SCH_APL_TO_ID => p_sch_apl_to_id);

      	p_message_name := NULL;
	p_sequence_number := v_acai_sequence_number;
logDetail('Before Call to Igs_Ad_Ps_Appl_Inst_Pkg.Insert_Row, returning TRUE',null);


	-- begin apadegal adtd001 igs.m

	-- a person type record of type 'Applicant' need to be created when ever an application instance is created.

	   OPEN c_person_type_code('APPLICANT');
	   FETCH c_person_type_code INTO l_person_type_code;
	   CLOSE c_person_type_code;

            IF NVL(IGS_AD_SS_GEN_001.g_admin_security_on,'N') = 'Y'
	    THEN
	      lv_mode := 'S';
	    END IF;

	   IGS_PE_TYP_INSTANCES_PKG.INSERT_ROW(
		     X_MODE                               => lv_mode, -- enable security for Admin
		     X_RowId                              => lv_rowid2,
		     X_TYPE_INSTANCE_ID                   => lv_type_instance_id,
		     X_PERSON_TYPE_CODE                   => l_person_type_code,
		     X_PERSON_ID                          => p_Person_Id,
		     X_COURSE_CD                          => NULL,
		     X_FUNNEL_STATUS                      => NULL,
		     X_ADMISSION_APPL_NUMBER              => p_Admission_Appl_Number,
		     X_NOMINATED_COURSE_CD                => p_course_cd,
		     X_SEQUENCE_NUMBER                    => v_acai_sequence_number,
		     X_START_DATE                         => lv_sysdate,
		     X_END_DATE                           => NULL,
		     X_CREATE_METHOD                      => 'CREATE_APPL_INSTANCE',
		     X_ENDED_BY                           => NULL,
		     X_END_METHOD                         => NULL,
		     X_CC_VERSION_NUMBER                  => NULL,
		     X_NCC_VERSION_NUMBER                 => p_Crv_Version_Number,
		     X_Org_Id                             => l_org_id,
		     X_EMPLMNT_CATEGORY_CODE              => NULL
		  );

       -- end apadegal adtd001 igs.m
	-- Foll logic added for 2229679 to raise the business event in workflow

	IF v_acai_sequence_number IS NOT NULL THEN
	  -- Application Instance has been successfully created and the business event needs to be raised

	  OPEN get_app_source(p_app_source_id);
	  FETCH get_app_source INTO v_app_source;
	  CLOSE get_app_source;

	  IF v_app_source IN ('WEB_APPL','WEB_STAFF') THEN -- in case the application is created via Self Service then raise the event

	    igs_ad_wf_001.wf_raise_event(p_person_id => p_person_id,
	    				 p_raised_for => 'SAC'
	    				 );
	  END IF;
	END IF;

       -- Changes for 2229679 end here

  	RETURN TRUE;
  END;
EXCEPTION
  	WHEN OTHERS THEN

	    logDetail('insert_adm_appl_prog_inst'|| 'Exception from insert_adm_appl_prog_inst: '||SQLERRM,null);
            l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
            WHILE l_sc_msg_count <> 0 loop
              igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
              fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
              IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                --Raise the exception to Higher Level with out setting any Unhandled exception.
		p_message_name := 'IGS_SC_POLICY_EXCEPTION';
                App_Exception.Raise_Exception;
              END IF;
              l_sc_msg_count := l_sc_msg_count - 1;
            END LOOP;

	    IF FND_MSG_PUB.Count_Msg < 1 THEN
	      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_014.insert_adm_appl_prog_inst -'||SQLERRM);
              p_message_name := 'IGS_GE_UNHANDLED_EXP';
	      IF (p_log = 'Y') THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
	      END IF;
              IGS_GE_MSG_STACK.ADD;
            END IF;
	    App_Exception.Raise_Exception;

END insert_adm_appl_prog_inst;

FUNCTION validate_unit_sets(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2,
  p_unit_set_appl IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_error_code OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN
IS
/*************************************************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created : 12-27-2001
Purpose:
        -- validate_unit_sets
  	-- Validate the admission course application unit set.
  	-- Validations are:
  	-- unit set may only be specified when the 'unit set' step exists for the
  	-- admission process category.
  	-- If the unit set is offered then both the unit set and unit set version must
  	-- be specified.
  	-- IF the unit SET IS nominated THEN the unit SET status must be
  	-- Active, however, if the unit set is OFFERED the unit set status must be
  	-- Active.
  	-- The expiry date of the unit set must not be set.
  	-- The unit set must be mapped to the course offering option (this is an error
  	-- on offer but a warning on nomination).
  	-- The course offering option unit set must be valid for the admission category
  	-- of the admission application.
Known limitations,enhancements,remarks:
Change History
Who        When          What
***************************************************************************************************************************/
  	cst_active		CONSTANT VARCHAR2(6) := 'ACTIVE';
  	cst_yes			CONSTANT VARCHAR2(1) := 'Y';
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  	v_s_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	v_expiry_dt		IGS_EN_UNIT_SET.expiry_dt%TYPE;
  	v_message_name		VARCHAR2(30);
  	v_coousv_match		BOOLEAN DEFAULT FALSE;
  	v_coacus_match		BOOLEAN DEFAULT FALSE;
  	v_coacus_rec_found	BOOLEAN DEFAULT FALSE;

	CURSOR c_us_uss (
  			cp_unit_set_cd		IGS_EN_UNIT_SET.unit_set_cd%TYPE,
  			cp_us_version_number	IGS_EN_UNIT_SET.version_number%TYPE) IS
  		SELECT	uss.s_unit_set_status,
  			us.expiry_dt
  		FROM	IGS_EN_UNIT_SET			us,
  			IGS_EN_UNIT_SET_STAT		uss
  		WHERE	  us.unit_set_cat IN
		         ( SELECT usc.unit_set_cat
                           FROM   igs_en_unit_set_cat usc
                     	   WHERE (fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND'  ) <> 'Y'
			      OR usc.s_unit_set_cat = 'PRENRL_YR') )
		AND    us.UNIT_SET_STATUS	= uss.UNIT_SET_STATUS
  		AND	us.unit_set_cd	= cp_unit_set_cd
  		AND	us.version_number	= cp_us_version_number;


	CURSOR c_coousv (
  			cp_unit_set_cd		IGS_PS_OF_OPT_UNT_ST.unit_set_cd%TYPE,
  			cp_us_version_number	IGS_PS_OF_OPT_UNT_ST.us_version_number%TYPE,
  			cp_course_cd		IGS_PS_OF_OPT_UNT_ST.course_cd%TYPE,
  			cp_crv_version_number	IGS_PS_OF_OPT_UNT_ST.crv_version_number%TYPE,
  			cp_acad_cal_type	IGS_PS_OF_OPT_UNT_ST.cal_type%TYPE,
			cp_admission_cat        IGS_PS_COO_AD_UNIT_S.admission_cat%TYPE,
                        cp_location_cd                IGS_PS_COO_AD_UNIT_S.location_cd%TYPE,
                        cp_attendance_mode              IGS_PS_COO_AD_UNIT_S.attendance_mode%TYPE,
                        cp_attendance_type              IGS_PS_COO_AD_UNIT_S.attendance_type%TYPE)  IS
  		SELECT 1
  		FROM    IGS_PS_OFR_OPT_UNIT_SET_V psusv
  		WHERE   psusv.course_cd              = cp_course_cd
  		        AND psusv.crv_version_number = cp_crv_version_number
			AND psusv.unit_set_cd        = cp_unit_set_cd
                        AND psusv.us_version_number  = cp_us_version_number
  		        AND psusv.cal_type           = cp_acad_cal_type
                        AND psusv.location_cd        = NVL(cp_location_cd, psusv.location_cd)
                        AND psusv.attendance_mode    = NVL(cp_attendance_mode, psusv.attendance_mode)
                        AND psusv.attendance_type    = NVL(cp_attendance_type, psusv.attendance_type)
  		        AND NOT EXISTS
  		        (SELECT 1
  		        FROM    igs_ps_coo_ad_unit_s psus
  		        WHERE   psus.course_cd              = psusv.course_cd
  		                AND psus.crv_version_number = psusv.crv_version_number
  		                AND psus.cal_type           = psusv.cal_type
				AND psus.location_cd        = psusv.location_cd
  		                AND psus.attendance_mode    = psusv.attendance_mode
  		                AND psus.attendance_type    = psusv.attendance_type
  		                AND psus.admission_cat      = cp_admission_cat
		        )
		        AND psusv.UNIT_SET_STATUS IN
  				        (SELECT unit_set_status
  		        FROM    igs_en_unit_set_stat uss
  		        WHERE   psusv.unit_set_status      = uss.unit_set_status
  		                AND uss.s_unit_set_status <> 'INACTIVE'
                        )
                        AND psusv.unit_set_cat IN
                        (SELECT usc.unit_set_cat
  		        FROM    igs_en_unit_set_cat usc
  		        WHERE   ((fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND') <> 'Y'
  		                OR usc.s_unit_set_cat  = 'PRENRL_YR'))
  		        )
  		        AND psusv.expiry_dt IS NULL
  		UNION
  		SELECT  1
		FROM    igs_ps_coo_ad_unit_s psus,
		        igs_en_unit_set us
  		WHERE   us.unit_set_cd              = psus.unit_set_cd
  		        AND us.version_number       = psus.us_version_number
                        AND psus.unit_set_cd        = cp_unit_set_cd
                        AND psus.us_version_number  = cp_us_version_number
  		        AND psus.course_cd          = cp_course_cd
  		        AND psus.crv_version_number = cp_crv_version_number
                        AND psus.cal_type           = cp_acad_cal_type
                        AND psus.location_cd        = NVL(cp_location_cd, psus.location_cd)
                        AND psus.attendance_mode    = NVL(cp_attendance_mode, psus.attendance_mode)
  		        AND psus.attendance_type    = NVL(cp_attendance_type, psus.attendance_type)
  		        AND psus.admission_cat      = cp_admission_cat
  		        AND us.unit_set_status IN
  		        (SELECT unit_set_status
  		        FROM    igs_en_unit_set_stat uss
  		        WHERE   us.unit_set_status         = uss.unit_set_status
  		                AND uss.s_unit_set_status <> 'INACTIVE'
  		        )
  		        AND us.unit_set_cat IN
  		        (SELECT usc.unit_set_cat
		        FROM    igs_en_unit_set_cat usc
		        WHERE   ((fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND') <> 'Y'
		                OR usc.s_unit_set_cat  = 'PRENRL_YR'))
		                )
		        AND us.expiry_dt IS NULL;

	CURSOR c_coacus (
  			cp_course_cd		IGS_PS_COO_AD_UNIT_S.course_cd%TYPE,
  			cp_crv_version_number	IGS_PS_COO_AD_UNIT_S.crv_version_number%TYPE,
  			cp_acad_cal_type		IGS_PS_COO_AD_UNIT_S.cal_type%TYPE,
  			cp_admission_cat		IGS_PS_COO_AD_UNIT_S.admission_cat%TYPE,
                        cp_location_cd                IGS_PS_COO_AD_UNIT_S.location_cd%TYPE,
                        cp_attendance_mode              IGS_PS_COO_AD_UNIT_S.attendance_mode%TYPE,
                        cp_attendance_type              IGS_PS_COO_AD_UNIT_S.attendance_type%TYPE) IS
  		SELECT	coacus.unit_set_cd,
  			coacus.us_version_number,
  			coacus.location_cd,
  			coacus.attendance_mode,
  			coacus.attendance_type
  		FROM	IGS_PS_COO_AD_UNIT_S	coacus
  		WHERE	coacus.course_cd		= cp_course_cd AND
  			coacus.crv_version_number	= cp_crv_version_number AND
  			coacus.cal_type		= cp_acad_cal_type AND
  			coacus.admission_cat	= cp_admission_cat AND
			coacus.location_cd = cp_location_cd AND
			coacus.attendance_mode = cp_attendance_mode AND
			coacus.attendance_type = cp_attendance_type;

  BEGIN
logHeader('validate_unit_sets',null);

        -- Initialise out NOCOPY parameters
  	p_message_name := NULL;
  	p_return_type := NULL;
        IF NVL(p_unit_set_appl,'N') = 'N' THEN
  		-- Ensure the unit set details are not specified for an admission application
  		-- that does not allow unit sets.
  		IF p_unit_set_cd IS NOT NULL OR
  			p_us_version_number IS NOT NULL THEN
  			p_message_name := 'IGS_AD_UNITSET_NOTSPECIFIED' ;
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	ELSE	-- unit sets are allowed for the application.
        	IF p_unit_set_cd IS NOT NULL AND
  		p_us_version_number IS NOT NULL THEN
  			-- Retrieve unit set data
  			OPEN 	c_us_uss(
  				p_unit_set_cd,
  				p_us_version_number);
  			FETCH	c_us_uss INTO 	v_s_unit_set_status,
  						v_expiry_dt;
  			IF(c_us_uss%FOUND) THEN
  				-- Validate unit set status
  				IF NVL(p_offer_ind,'N') = cst_yes THEN	-- Offered
  					IF v_s_unit_set_status <> cst_active THEN
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_MUSTBE_ACTIVE';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					END IF;
  				ELSE
		-- Nominated
  					IF v_s_unit_set_status <> cst_active THEN     --removed the planned status as per bug#2722785 --rghosh
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_ACTIVE_PLANNED';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				-- Validate expiry date
  				IF v_expiry_dt IS NOT NULL THEN
  					CLOSE c_us_uss;
  					p_message_name := 'IGS_AD_UNITSET_EXPDT_NOTBESET';
  					p_return_type := cst_error;
  					RETURN FALSE;
  				END IF;
		-- Validate that unit set is mapped to the course offering option.
		-- If the option details of the course offering option are specified,
		-- then an exact match must be found.  If the option details are not
		-- specified then a match on the course offering and unit set is all
		-- that is needed.
  				FOR v_coousv_rec IN c_coousv (
  						p_unit_set_cd,
  						p_us_version_number,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
						p_admission_cat,
						p_location_cd,
						p_attendance_mode,
						p_attendance_type
						) LOOP
  						v_coousv_match := TRUE;
  				END LOOP;
  				IF(v_coousv_match = FALSE) THEN
  					IF NVL(p_offer_ind,'N') = cst_yes THEN	-- Offered
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_NOTMAP_POO';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					ELSE
			-- Nominated
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_NOT_MAP_POO';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				-- Validate the course offering option unit set is mapped to the admission
  				-- category.
  				-- This is a restriction table. If no records exist on the table for the
  				-- course offering option, then the course offering option unit set is valid
  				-- for the admission category.  However, if any record exists on the table
  				-- for the course offering option then one must exist for the unit set.
  				FOR v_coacus_rec IN c_coacus(
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_admission_cat,
						p_location_cd,
						p_attendance_mode,
						p_attendance_type) LOOP
  					v_coacus_rec_found := TRUE;
  					IF ((p_unit_set_cd = v_coacus_rec.unit_set_cd) AND
  							(p_us_version_number = v_coacus_rec.us_version_number) AND
  							(p_location_cd IS NULL OR
  							p_location_cd = v_coacus_rec.location_cd) AND
  							(p_attendance_mode IS NULL OR
  							p_attendance_mode = v_coacus_rec.attendance_mode) AND
  							(p_attendance_type IS NULL OR
  							p_attendance_type = v_coacus_rec.attendance_type)) THEN
    						v_coacus_match := TRUE;
  					END IF;
    				END LOOP;
    				IF(v_coacus_rec_found = TRUE AND
  						v_coacus_match = FALSE) THEN
    					IF NVL(p_offer_ind,'N') = cst_yes THEN 	-- Offered
    						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_OFRPRG_NOT_VALID';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					ELSE 				-- Nominated
    						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_PRGOFOP_NOT_VALID';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				IF v_coacus_rec_found = FALSE THEN
  					-- Validate the unit set.
logDetail('Before Call to IGS_AD_VAL_ACAI.crsp_val_cacus_sub',null);
					IF IGS_AD_VAL_ACAI.crsp_val_cacus_sub (
  							p_course_cd,
  							p_crv_version_number,
  							p_acad_cal_type,
  							p_unit_set_cd,
  							p_us_version_number,
  							v_message_name) = FALSE THEN
  						CLOSE c_us_uss;
  						p_message_name := v_message_name;
  						p_return_type := cst_error;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				CLOSE c_us_uss;
  			ELSE	-- unit set record not found.
  				CLOSE c_us_uss;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		ELSE	-- unit set is not specified.
  			IF NVL(p_offer_ind,'N') = cst_yes THEN
  				p_message_name := 'IGS_AD_UNITSET_MUSTBE_SPECIFI';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
 		 logDetail('validate_unit_sets' || ' is not successul Message : ' || SQLERRM,null);
 	         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                 App_Exception.Raise_Exception;
END validate_unit_sets;

PROCEDURE get_adm_step_values(p_admission_cat IN VARCHAR2,
  			p_s_admission_process_type IN VARCHAR2,
			p_location_cd_ind OUT NOCOPY VARCHAR2,
			p_attendance_type_ind OUT NOCOPY VARCHAR2,
			p_attendance_mode_ind OUT NOCOPY VARCHAR2) IS
/*************************************************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created : 12-27-2001
Purpose:
        1.get location_id
        2.get attendance_mode
	3.get attendance_type depending on s_admission_step_type and admission category and
Known limitations,enhancements,remarks:
Change History
Who        When          What
***************************************************************************************************************************/

	l_var VARCHAR2(1);
BEGIN
	logHeader('get_adm_step_values',null);
	BEGIN
		SELECT 'X'
	 		INTO L_VAR
	 	FROM
			IGS_AD_PRCS_CAT_STEP
	 	WHERE
			S_ADMISSION_STEP_TYPE = 'UN-CRS-LOC'
	 		AND  ADMISSION_CAT = p_admission_cat
	 		AND S_ADMISSION_PROCESS_TYPE = p_s_admission_process_type
	 		AND  step_group_type <> 'TRACK'; --2404377
	 		p_location_cd_ind:= 'Y';

	 		EXCEPTION
	  		WHEN OTHERS THEN
	  			p_location_cd_ind:=NULL;
		END;
	BEGIN
		SELECT 'X'
	 		INTO L_VAR
	 	FROM
			IGS_AD_PRCS_CAT_STEP
	 	WHERE
			S_ADMISSION_STEP_TYPE = 'UN-CRS-MOD'
	 		AND  ADMISSION_CAT =  p_admission_cat
	 		AND S_ADMISSION_PROCESS_TYPE = p_s_admission_process_type
	 		AND step_group_type <> 'TRACK' ; --2402377
    			p_attendance_mode_ind := 'Y' ;

		EXCEPTION
	  		WHEN OTHERS THEN
	  			p_attendance_mode_ind :=NULL;
		END;
	BEGIN
		SELECT 'X'
	 		INTO L_VAR
	 	FROM
			IGS_AD_PRCS_CAT_STEP
	 	WHERE

			S_ADMISSION_STEP_TYPE = 'UN-CRS-MOD'
	 		AND  ADMISSION_CAT =  p_admission_cat
	 		AND S_ADMISSION_PROCESS_TYPE = p_s_admission_process_type
	 		AND STEP_GROUP_TYPE <> 'TRACK'; -- 2402377
		p_attendance_type_ind := 'Y';
	EXCEPTION
		WHEN OTHERS THEN
		p_attendance_type_ind := NULL;
	END;
END get_adm_step_values;

--This is a Debug Mode Proc, outputs which proc is being processed, to stop Debugging pass 'H' to p_mode param
PROCEDURE logHeader(p_proc_name VARCHAR2
                    ,p_mode VARCHAR2 ) AS
BEGIN

IF NVL(p_mode,'S') = 'S' THEN
--  FND_FILE.PUT_LINE(FND_FILE.LOG,p_proc_name);
 --dbms_output.put_line('*****************Inside Proc: '||p_proc_name||'  **********************');
null; --Last line commented for GSCC Check, uncomment to use logHeader
ELSIF p_mode = 'H' THEN
  NULL;
END IF;
END;

--This is a Debug Mode Proc, outputs each call being processed, to stop Debugging pass 'H' to p_mode param
PROCEDURE logDetail(p_debug_msg VARCHAR2
                    ,p_mode VARCHAR2) AS
BEGIN
IF NVL(p_mode,'S') = 'S' THEN
-- FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_msg);
--dbms_output.put_line(p_debug_msg);
null; --Last line commented for GSCC Check, uncomment to use logDetail
ELSIF p_mode = 'H' THEN
  NULL;
END IF;
END;

 PROCEDURE auto_assign_requirement(
           p_person_id              IN                        NUMBER,
           p_admission_appl_number  IN                        NUMBER,
	   p_course_cd              IN                        VARCHAR2,
	   p_sequence_number        IN                        NUMBER,
	   p_called_from            IN                        VARCHAR2,
	   p_error_text             OUT NOCOPY                VARCHAR2,
	   p_error_code             OUT NOCOPY                NUMBER
 ) AS
l_errbuf VARCHAR2(2000);
l_retcode NUMBER;

CURSOR c_adm_cat(cp_person_id IN NUMBER, cp_admission_Appl_number IN NUMBER) IS
SELECT ADMISSION_CAT, S_ADMISSION_PROCESS_TYPE FROM IGS_AD_APPL_ALL
WHERE PERSON_ID = cp_person_id AND ADMISSION_APPL_NUMBER = cp_admission_Appl_number;

l_adm_cat_rec       c_adm_cat%ROWTYPE;

CURSOR c_apc_step_included (cp_adm_pro_type IN VARCHAR2, cp_admission_cat IN VARCHAR2,cp_admission_step_type IN VARCHAR2) IS
SELECT '1' FROM IGS_AD_PRCS_CAT_STEP_ALL
WHERE ADMISSION_CAT = cp_admission_cat
AND S_ADMISSION_PROCESS_TYPE =cp_adm_pro_type
AND S_ADMISSION_STEP_TYPE = cp_admission_step_type;

l_apc_step_included VARCHAR2(1);

 BEGIN

OPEN c_adm_cat (p_person_id,p_admission_appl_number);
FETCH c_adm_cat INTO l_adm_cat_rec;
CLOSE c_adm_cat;

--Check whether assign requimrent step is included for import/ss or not. IF included then call
--assign requirment procedure
l_apc_step_included := NULL;
IF p_called_from ='SS' THEN--IF it is called from Self Service
	OPEN c_apc_step_included (l_adm_cat_rec.S_ADMISSION_PROCESS_TYPE,l_adm_cat_rec.admission_cat,'ASSI-REQ-SS');
	FETCH c_apc_step_included INTO l_apc_step_included;
	CLOSE c_apc_step_included;
ELSIF p_called_from ='IM' THEN--IF it is called from Import
	IF igs_ad_gen_016.get_apcs(l_adm_cat_rec.admission_cat, l_adm_cat_rec.S_ADMISSION_PROCESS_TYPE,'ASSI-REQ-IMPORT')='TRUE' THEN
		l_apc_step_included :='1';
	ELSE
		l_apc_step_included :=NULL;
	END IF;
ELSE
	l_apc_step_included := NULL;
END IF;

p_error_text := NULL;
p_error_code := NULL;

IF l_apc_step_included IS NOT NULL THEN
--Assign the requirment to Aplication
 igs_ad_adm_req.ini_adm_trk_itm(
        errbuf                          => l_errbuf,
        retcode                         => l_retcode,
        p_person_id                     => p_person_id,
        p_calendar_details              => NULL,
        p_admission_process_category    => NULL,
        p_admission_appl_number         => p_admission_appl_number,
        p_program_code                  => p_course_cd,
        p_sequence_number               => p_sequence_number,
        p_person_id_group               => NULL,
        p_requirements_type             => 'ADM_PROCESSING',
        p_originator_person             => p_person_id,
        p_org_id                        => NULL
        );
	p_error_text := l_errbuf;
	p_error_code := l_retcode;
 IF l_retcode = 0 THEN--raise the Business Event oracle.apps.igs.ad.app_requirement.
--Call the admission tracking item completion procedure to Aplication
igs_ad_ti_comp.upd_trk_itm_st(
        errbuf                          => l_errbuf,
        retcode                         => l_retcode,
        p_person_id                     => p_person_id,
        p_person_id_group               => NULL,
        p_admission_appl_number         => p_admission_appl_number,
        p_course_cd                     => p_course_cd,
        p_sequence_number               => p_sequence_number,
	p_calendar_details              => NULL,
        p_admission_process_category    => NULL,
        p_org_id                        => NULL
);

igs_ad_ac_comp.upd_apl_cmp_st(
         ERRBUF                         => l_errbuf,
         RETCODE                        => l_retcode,
         p_person_id                    => p_person_id,
         p_person_id_group              => NULL,
         p_admission_appl_number        => p_admission_appl_number,
         p_course_cd                    => p_course_cd,
         p_sequence_number              => p_sequence_number,
         p_calendar_details             => NULL,
         p_admission_process_category   => NULL,
         p_org_id                       => NULL
);

END IF;

END IF;
 END auto_assign_requirement;

 PROCEDURE assign_qual_type (
 p_person_id              IN                        NUMBER,
 p_admission_appl_number  IN                        NUMBER,
 p_course_cd              IN                        VARCHAR2,
 p_sequence_number        IN                        NUMBER
 ) IS

l_rowid ROWID;
CURSOR c_adm_cat(cp_person_id IN NUMBER, cp_admission_Appl_number IN NUMBER) IS
SELECT ADMISSION_CAT, S_ADMISSION_PROCESS_TYPE FROM IGS_AD_APPL_ALL
WHERE PERSON_ID = cp_person_id AND ADMISSION_APPL_NUMBER = cp_admission_Appl_number;

l_adm_cat_rec       c_adm_cat%ROWTYPE;

CURSOR c_apc_qual_type (cp_admission_cat IN   VARCHAR2, cp_admission_process_type IN VARCHAR2)
IS
SELECT QUALIFYING_TYPE_CODE
FROM IGS_AD_QUAL_TYPE
WHERE ADMISSION_CAT = cp_admission_cat AND S_ADMISSION_PROCESS_TYPE = cp_admission_process_type
AND CLOSED_FLAG = 'N';

CURSOR c_def_qual_code(cp_qual_type IN VARCHAR2)
IS
SELECT CODE_ID FROM IGS_AD_CODE_CLASSES
WHERE CLASS=cp_qual_type AND CLASS_TYPE_CODE = 'IGS_AD_QUAL_TYPE'
AND SYSTEM_DEFAULT = 'Y';

l_def_qual_code IGS_AD_CODE_CLASSES.CODE_ID%TYPE;

BEGIN

OPEN c_adm_cat(p_person_id,p_admission_appl_number);
FETCH c_adm_cat INTO l_adm_cat_rec;
CLOSE c_adm_cat;

 FOR l_apc_qual_type_rec IN c_apc_qual_type(l_adm_cat_rec.ADMISSION_CAT,l_adm_cat_rec.S_ADMISSION_PROCESS_TYPE) LOOP
--Get system default qual code for this qual type.
l_def_qual_code := NULL;
OPEN c_def_qual_code(l_apc_qual_type_rec.QUALIFYING_TYPE_CODE);
FETCH c_def_qual_code INTO l_def_qual_code;
CLOSE c_def_qual_code;
 igs_ad_appqual_code_pkg.INSERT_ROW
 (
    x_rowid                             => l_rowid,
    x_person_id                         => p_person_id,
    x_admission_appl_number             => p_admission_appl_number,
    x_nominated_course_cd               => p_course_cd,
    x_sequence_number                   => p_sequence_number,
    x_qualifying_type_code              => l_apc_qual_type_rec.QUALIFYING_TYPE_CODE,
    x_qualifying_code_id                => l_def_qual_code,
    x_qualifying_value                  => NULL,
    x_mode                              => 'R'
 );

 END LOOP;

END assign_qual_type;

END IGS_AD_GEN_014;

/
