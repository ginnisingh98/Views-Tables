--------------------------------------------------------
--  DDL for Package Body IGS_AD_SS_APPL_FEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SS_APPL_FEE_PKG" AS
/* $Header: IGSADB7B.pls 120.6 2005/12/18 21:28:32 appldev ship $ */

/*************************************************************
Created By :rboddu
Date Created By : 31-DEC-2001
Purpose :2158524
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

PROCEDURE check_offer_resp_update(
         p_person_id IN NUMBER,
	 p_admission_application_number IN NUMBER,
	 p_nominated_course_cd IN VARCHAR2,
	 p_sequence_number IN NUMBER,
	 x_return_status OUT NOCOPY VARCHAR2,
	 x_msg_count OUT NOCOPY NUMBER,
	 x_msg_data OUT NOCOPY VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date : 20-DEC-2001
  Created By : Sandhya.Amaresh
  Purpose : This api check if the offer response can be made
  'Accepted' for the offer
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ***************************************************************/
  CURSOR c_appl(cp_person_id NUMBER,cp_admission_appl_number NUMBER) IS
  SELECT *
  FROM igs_ad_appl
  WHERE person_id = cp_person_id
  AND admission_appl_number = cp_admission_appl_number;

  CURSOR c_appl_inst(cp_person_id NUMBER,cp_admission_appl_number NUMBER,cp_nominated_cd VARCHAR,cp_seq_number NUMBER) IS
  SELECT *
  FROM igs_ad_ps_appl_inst
  WHERE person_id = cp_person_id
  AND admission_appl_number = cp_admission_appl_number
  AND nominated_course_cd = cp_nominated_cd
  AND sequence_number = cp_seq_number;

  c_appl_inst_rec c_appl_inst%ROWTYPE;
  c_appl_rec c_appl%ROWTYPE;

  invalidsysstatus EXCEPTION;
  applnotfound EXCEPTION;
  applinstnotfound EXCEPTION;

  l_offer_resp_outcome_status IGS_AD_PS_APPL_INST_ALL.adm_outcome_status%TYPE;

  l_apcs_pref_limit_ind       VARCHAR2(1);
  l_apcs_app_fee_ind          VARCHAR2(1);
  l_apcs_late_app_ind         VARCHAR2(1);
  l_apcs_late_fee_ind         VARCHAR2(1);
  l_apcs_chkpencumb_ind       VARCHAR2(1);
  l_apcs_fee_assess_ind       VARCHAR2(1);
  l_apcs_corcategry_ind       VARCHAR2(1);
  l_apcs_enrcategry_ind       VARCHAR2(1);
  l_apcs_chkcencumb_ind       VARCHAR2(1);
  l_apcs_unit_set_ind         VARCHAR2(1);
  l_apcs_un_crs_us_ind        VARCHAR2(1);
  l_apcs_chkuencumb_ind       VARCHAR2(1);
  l_apcs_unit_restr_ind       VARCHAR2(1);
  l_apcs_unit_restriction_num IGS_AD_PRCS_CAT_STEP.STEP_ORDER_NUM%TYPE;
  l_apcs_un_dob_ind           VARCHAR2(1);
  l_apcs_un_title_ind         VARCHAR2(1);
  l_apcs_asses_cond_ind       VARCHAR2(1);
  l_apcs_fee_cond_ind         VARCHAR2(1);
  l_apcs_doc_cond_ind         VARCHAR2(1);
  l_apcs_multi_off_ind        VARCHAR2(1);
  l_apcs_multi_off_restn_num  IGS_AD_PRCS_CAT_STEP.STEP_ORDER_NUM%TYPE;
  l_apcs_set_otcome_ind       VARCHAR2(1);
  l_apcs_override_o_ind       VARCHAR2(1);
  l_apcs_defer_ind            VARCHAR2(1);
  l_apcs_ack_app_ind          VARCHAR2(1);
  l_apcs_outcome_lt_ind       VARCHAR2(1);
  l_apcs_pre_enrol_ind        VARCHAR2(1);

BEGIN


  l_offer_resp_outcome_status := IGS_AD_GEN_009.ADMP_GET_SYS_AORS('ACCEPTED');
  IF l_offer_resp_outcome_status IS NULL THEN
   RAISE invalidsysstatus;
  END IF;

  OPEN c_appl(p_person_id,p_admission_application_number);
  FETCH c_appl INTO c_appl_rec;
  IF c_appl%NOTFOUND THEN
    RAISE applnotfound;
  END IF;
  CLOSE c_appl;

  OPEN c_appl_inst(p_person_id,p_admission_application_number,p_nominated_course_cd,p_sequence_number);
  FETCH c_appl_inst INTO c_appl_inst_rec;
  IF c_appl_inst%NOTFOUND THEN
    RAISE applinstnotfound;
  END IF;
  CLOSE c_appl_inst;

  IGS_AD_GEN_004.ADMP_GET_APCS_VAL(
    c_appl_rec.admission_cat,
    c_appl_rec.s_admission_process_type,
    l_apcs_pref_limit_ind,
    l_apcs_app_fee_ind,
    l_apcs_late_app_ind,
    l_apcs_late_fee_ind,
    l_apcs_chkpencumb_ind,
    l_apcs_fee_assess_ind,
    l_apcs_corcategry_ind,
    l_apcs_enrcategry_ind,
    l_apcs_chkcencumb_ind,
    l_apcs_unit_set_ind,
    l_apcs_un_crs_us_ind,
    l_apcs_chkuencumb_ind,
    l_apcs_unit_restr_ind,
    l_apcs_unit_restriction_num,
    l_apcs_un_dob_ind,
    l_apcs_un_title_ind,
    l_apcs_asses_cond_ind,
    l_apcs_fee_cond_ind,
    l_apcs_doc_cond_ind,
    l_apcs_multi_off_ind,
    l_apcs_multi_off_restn_num,
    l_apcs_set_otcome_ind,
    l_apcs_override_o_ind,
    l_apcs_defer_ind,
    l_apcs_ack_app_ind,
    l_apcs_outcome_lt_ind,
    l_apcs_pre_enrol_ind);

  IF igs_ad_val_acai_status.admp_val_aors_item(
	p_person_id,
	p_admission_application_number,
	p_nominated_course_cd,
	p_sequence_number,
        p_nominated_course_cd,
	l_offer_resp_outcome_status,
	SYSDATE,
        c_appl_rec.s_admission_process_type,
        l_apcs_defer_ind,
        l_apcs_pre_enrol_ind,
	x_msg_data,
	c_appl_inst_rec.decline_ofr_reason ,		-- IGSM
	c_appl_inst_rec.attent_other_inst_cd		-- igsm
	) THEN

	-- Call the following Api to validate the offer response status at record level
	IF igs_ad_val_acai_status.admp_val_acai_aors(
             p_person_id,
             p_admission_application_number,
             p_nominated_course_cd,
             p_sequence_number,
             p_nominated_course_cd,
	     l_offer_resp_outcome_status,
	     c_appl_inst_rec.adm_offer_resp_status,
             c_appl_inst_rec.adm_outcome_status,
	     c_appl_inst_rec.adm_offer_dfrmnt_status,
             c_appl_inst_rec.adm_offer_dfrmnt_status,
	     c_appl_inst_rec.adm_outcome_status_auth_dt,
	     SYSDATE,
             c_appl_inst_rec.adm_cal_type,
             c_appl_inst_rec.adm_ci_sequence_number,
	     c_appl_rec.admission_cat,
             c_appl_rec.s_admission_process_type,
             l_apcs_defer_ind,
             l_apcs_multi_off_ind,
             l_apcs_multi_off_restn_num,
	     l_apcs_pre_enrol_ind,
             c_appl_inst_rec.cndtnl_offer_must_be_stsfd_ind,
	     c_appl_inst_rec.cndtnl_offer_satisfied_dt,
             'FORM',
	     x_msg_data,
	     c_appl_inst_rec.decline_ofr_reason ,		-- IGSM
	     c_appl_inst_rec.attent_other_inst_cd		-- igsm
	) THEN
	       x_return_status := 'S';
	       x_msg_count := 0;
	       x_msg_data := NULL;
	       RETURN;
        ELSE
	  x_return_status := 'E';
	  x_msg_count := 0;
	  RETURN;
        END IF;
  ELSE
     x_return_status := 'E';
     x_msg_count := 0;
     RETURN;
  END IF;
  EXCEPTION
     WHEN invalidsysstatus THEN
       x_return_status := 'E';
       x_msg_data := 'IGS_AD_INVALID_SYSTEM_TYPE';
       x_msg_count := 0;
       RETURN;
     WHEN applnotfound THEN
       CLOSE c_appl;
       x_return_status := 'E';
       x_msg_data := 'IGS_AD_INVALID_APPL';
       x_msg_count := 0;
       RETURN;
     WHEN applinstnotfound THEN
       CLOSE c_appl_inst;
       x_return_status := 'E';
       x_msg_data := 'IGS_AD_INVALID_APPL';
       x_msg_count := 0;
       RETURN;
     WHEN OTHERS THEN
       x_return_status := 'E';
       x_msg_data := 'IGS_GE_UNHANLED_EXP';
       x_msg_count := 0;
       RETURN;
END check_offer_resp_update;

PROCEDURE check_offer_update(
         p_person_id IN NUMBER,
	 p_admission_application_number IN NUMBER,
	 p_nominated_course_cd IN VARCHAR2,
	 p_sequence_number IN NUMBER,
	 x_return_status OUT NOCOPY VARCHAR2,
	 x_msg_count OUT NOCOPY NUMBER,
	 x_msg_data OUT NOCOPY VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date : 20-DEC-2001
  Created By : Sandhya.Amaresh
  Purpose : This api check if an offer can be made for the
  application
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ***************************************************************/

  CURSOR c_appl(cp_person_id NUMBER,cp_admission_appl_number NUMBER) IS
  SELECT *
  FROM igs_ad_appl
  WHERE person_id = cp_person_id
  AND admission_appl_number = cp_admission_appl_number;

  CURSOR c_appl_inst(cp_person_id NUMBER,cp_admission_appl_number NUMBER,cp_nominated_cd VARCHAR,cp_seq_number NUMBER) IS
  SELECT *
  FROM igs_ad_ps_appl_inst
  WHERE person_id = cp_person_id
  AND admission_appl_number = cp_admission_appl_number
  AND nominated_course_cd = cp_nominated_cd
  AND sequence_number = cp_seq_number;

  c_appl_inst_rec c_appl_inst%ROWTYPE;
  c_appl_rec c_appl%ROWTYPE;

  invalidsysstatus EXCEPTION;
  applnotfound EXCEPTION;
  applinstnotfound EXCEPTION;

  l_offer_adm_outcome_status IGS_AD_PS_APPL_INST_ALL.adm_outcome_status%TYPE;
  l_old_adm_outcome_status   IGS_AD_PS_APPL_INST_ALL.adm_outcome_status%TYPE;

  l_offer_resp_status        IGS_AD_PS_APPL_INST_ALL.adm_offer_resp_status%TYPE;
  l_offer_old_resp_status    IGS_AD_PS_APPL_INST_ALL.adm_offer_resp_status%TYPE;

  l_apcs_pref_limit_ind       VARCHAR2(1);
  l_apcs_app_fee_ind          VARCHAR2(1);
  l_apcs_late_app_ind         VARCHAR2(1);
  l_apcs_late_fee_ind         VARCHAR2(1);
  l_apcs_chkpencumb_ind       VARCHAR2(1);
  l_apcs_fee_assess_ind       VARCHAR2(1);
  l_apcs_corcategry_ind       VARCHAR2(1);
  l_apcs_enrcategry_ind       VARCHAR2(1);
  l_apcs_chkcencumb_ind       VARCHAR2(1);
  l_apcs_unit_set_ind         VARCHAR2(1);
  l_apcs_un_crs_us_ind        VARCHAR2(1);
  l_apcs_chkuencumb_ind       VARCHAR2(1);
  l_apcs_unit_restr_ind       VARCHAR2(1);
  l_apcs_unit_restriction_num IGS_AD_PRCS_CAT_STEP.STEP_ORDER_NUM%TYPE;
  l_apcs_un_dob_ind           VARCHAR2(1);
  l_apcs_un_title_ind         VARCHAR2(1);
  l_apcs_asses_cond_ind       VARCHAR2(1);
  l_apcs_fee_cond_ind         VARCHAR2(1);
  l_apcs_doc_cond_ind         VARCHAR2(1);
  l_apcs_multi_off_ind        VARCHAR2(1);
  l_apcs_multi_off_restn_num  IGS_AD_PRCS_CAT_STEP.STEP_ORDER_NUM%TYPE;
  l_apcs_set_otcome_ind       VARCHAR2(1);
  l_apcs_override_o_ind       VARCHAR2(1);
  l_apcs_defer_ind            VARCHAR2(1);
  l_apcs_ack_app_ind          VARCHAR2(1);
  l_apcs_outcome_lt_ind       VARCHAR2(1);
  l_apcs_pre_enrol_ind        VARCHAR2(1);

BEGIN

  l_offer_adm_outcome_status := IGS_AD_GEN_009.ADMP_GET_SYS_AOS('OFFER');
  l_old_adm_outcome_status := IGS_AD_GEN_009.ADMP_GET_SYS_AOS('PENDING');

  l_offer_resp_status := IGS_AD_GEN_009.ADMP_GET_SYS_AORS('PENDING');
  l_offer_old_resp_status := IGS_AD_GEN_009.ADMP_GET_SYS_AORS('NOT-APPLIC');

  IF l_offer_adm_outcome_status IS NULL OR l_old_adm_outcome_status IS NULL THEN
    RAISE invalidsysstatus;
  END IF;

  IF l_offer_resp_status IS NULL OR l_offer_old_resp_status IS NULL THEN
    RAISE invalidsysstatus;
  END IF;

  OPEN c_appl(p_person_id,p_admission_application_number);
  FETCH c_appl INTO c_appl_rec;
  IF c_appl%NOTFOUND THEN
    RAISE applnotfound;
  END IF;
  CLOSE c_appl;

  OPEN c_appl_inst(p_person_id,p_admission_application_number,p_nominated_course_cd,p_sequence_number);
  FETCH c_appl_inst INTO c_appl_inst_rec;
  IF c_appl_inst%NOTFOUND THEN
    RAISE applinstnotfound;
  END IF;
  CLOSE c_appl_inst;


  IGS_AD_GEN_004.ADMP_GET_APCS_VAL(
    c_appl_rec.admission_cat,
    c_appl_rec.s_admission_process_type,
    l_apcs_pref_limit_ind,
    l_apcs_app_fee_ind,
    l_apcs_late_app_ind,
    l_apcs_late_fee_ind,
    l_apcs_chkpencumb_ind,
    l_apcs_fee_assess_ind,
    l_apcs_corcategry_ind,
    l_apcs_enrcategry_ind,
    l_apcs_chkcencumb_ind,
    l_apcs_unit_set_ind,
    l_apcs_un_crs_us_ind,
    l_apcs_chkuencumb_ind,
    l_apcs_unit_restr_ind,
    l_apcs_unit_restriction_num,
    l_apcs_un_dob_ind,
    l_apcs_un_title_ind,
    l_apcs_asses_cond_ind,
    l_apcs_fee_cond_ind,
    l_apcs_doc_cond_ind,
    l_apcs_multi_off_ind,
    l_apcs_multi_off_restn_num,
    l_apcs_set_otcome_ind,
    l_apcs_override_o_ind,
    l_apcs_defer_ind,
    l_apcs_ack_app_ind,
    l_apcs_outcome_lt_ind,
    l_apcs_pre_enrol_ind);

  IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aos(
         p_person_id,
         p_admission_application_number,
         p_nominated_course_cd,
         p_sequence_number,
         p_nominated_course_cd,
         c_appl_inst_rec.crv_version_number,
         c_appl_inst_rec.location_cd,
         c_appl_inst_rec.attendance_mode,
         c_appl_inst_rec.attendance_type,
         c_appl_inst_rec.unit_set_cd,
         c_appl_inst_rec.us_version_number,
         c_appl_rec.acad_cal_type,
         c_appl_rec.acad_ci_sequence_number,
         c_appl_inst_rec.adm_cal_type,
         c_appl_inst_rec.adm_ci_sequence_number,
	 c_appl_rec.admission_cat,
         c_appl_rec.s_admission_process_type,
         c_appl_rec.appl_dt,
         c_appl_inst_rec.fee_cat,
         c_appl_inst_rec.correspondence_cat,
         c_appl_inst_rec.enrolment_cat,
         l_offer_adm_outcome_status,
         l_old_adm_outcome_status,
         c_appl_inst_rec.adm_doc_status,
         c_appl_rec.adm_fee_status,
         c_appl_inst_rec.late_adm_fee_status,
         c_appl_inst_rec.adm_cndtnl_offer_status,
         c_appl_inst_rec.adm_entry_qual_status,
         l_offer_resp_status,
         l_offer_old_resp_status,
         c_appl_inst_rec.adm_outcome_status_auth_dt,
         l_apcs_set_otcome_ind,
         'N',
         'N',
         'N',
	 l_apcs_late_app_ind,
	 l_apcs_app_fee_ind,
	 l_apcs_multi_off_ind,
	 l_apcs_multi_off_restn_num,
	 l_apcs_pref_limit_ind,
	 l_apcs_unit_set_ind,
	 l_apcs_chkpencumb_ind,
	 l_apcs_chkcencumb_ind,
         'FORM',
         x_msg_data) THEN
    x_return_status := 'S';
    x_msg_count := 0;
  ELSE
    x_return_status := 'E';
  END IF;
 EXCEPTION
     WHEN invalidsysstatus THEN
       x_return_status := 'E';
       x_msg_data := 'IGS_AD_INVALID_SYSTEM_TYPE';
       x_msg_count := 0;
       RETURN;
     WHEN applnotfound THEN
       CLOSE c_appl;
       x_return_status := 'E';
       x_msg_data := 'IGS_AD_INVALID_APPL';
       x_msg_count := 0;
       RETURN;
     WHEN APPLINSTNOTFOUND THEN
       CLOSE c_appl_inst;
       x_return_status := 'E';
       x_msg_data := 'IGS_AD_INVALID_APPL';
       x_msg_count := 0;
       RETURN;
     WHEN OTHERS THEN
       x_return_status := 'E';
       x_msg_data := 'IGS_GE_UNHANLED_EXP';
       x_msg_count := 0;
       RETURN;
END check_offer_update;

PROCEDURE check_update_aeps_acs(
          p_person_id  IN NUMBER,
          p_admission_application_number  IN NUMBER,
          p_nominated_course_cd    IN VARCHAR2,
          p_sequence_number        IN NUMBER,
          x_return_status          OUT NOCOPY VARCHAR2,
          x_msg_count              OUT NOCOPY NUMBER,
          x_msg_data               OUT NOCOPY VARCHAR2)
AS
/*************************************************************
 Created By :rboddu
 Date Created By : 31-DEC-2001
 Purpose : 2158524
 Know limitations, enhancements or remarks
 Change History
 Who             When            What
 (reverse chronological order - newest change first)
***************************************************************/
--Cursor which retrieves the system admission process type associated with the application.
CURSOR c_appl_cur IS
  SELECT s_admission_process_type, admission_cat
  FROM   igs_ad_appl
  WHERE  person_id = p_person_id AND
         admission_appl_number = p_admission_application_number;

CURSOR c_trk_exists(p_adm_cat VARCHAR2, p_adm_prc_typ VARCHAR2) IS
SELECT 1 FROM IGS_AD_PRCS_CAT_STEP APCS , IGS_TR_TYPE_ALL TRT
WHERE
APCS.S_ADMISSION_STEP_TYPE = TRT.TRACKING_TYPE AND
APCS.STEP_GROUP_TYPE = 'TRACK' AND
TRT.S_TRACKING_TYPE IS NOT NULL
AND admission_cat = p_adm_cat
AND s_admission_process_type = p_adm_prc_typ;

c_appl_rec  c_appl_cur%ROWTYPE;

l_trk_exists number;
l_adm_cat igs_ad_appl.ADMISSION_CAT%TYPE;
l_adm_proc_type igs_ad_appl.S_ADMISSION_PROCESS_TYPE%TYPE;
lvc_user_application_status  VARCHAR2(30);
lvc_user_entry_qual_status   VARCHAR2(30);
lvc_user_outcome_status      VARCHAR2(30);
lvc_user_conditional_status  VARCHAR2(30);

BEGIN
  --Get the user defined Statuses for the corresponding system defined Statuses
  lvc_user_application_status := igs_ad_gen_009.admp_get_sys_ads('SATISFIED');
  lvc_user_entry_qual_status  := igs_ad_gen_009.admp_get_sys_aeqs('QUALIFIED');
  lvc_user_outcome_status     := igs_ad_gen_009.admp_get_sys_aos('PENDING');
  lvc_user_conditional_status := igs_ad_gen_009.admp_get_sys_acos('NOT-APPLIC');

--If any of User defined Status is NULL copy the error message into x_msg_data and set the corresponding x_return_status to 'E'
  IF ((lvc_user_application_status IS NULL) OR (lvc_user_entry_qual_status IS NULL) OR
      (lvc_user_outcome_status IS NULL) OR (lvc_user_conditional_status IS NULL)) THEN
    x_msg_data := 'IGS_AD_INVALID_SYSTEM_TYPE';
    x_return_status:= 'E';
    x_msg_count:=0;
    RETURN;
  END IF;

  OPEN c_appl_cur;
  FETCH c_appl_cur INTO c_appl_rec;
  l_adm_cat := c_appl_rec.admission_cat;
  l_adm_proc_type := c_appl_rec.s_admission_process_type;
  IF c_appl_cur%NOTFOUND THEN
     x_return_status := 'E';
     x_msg_data:='IGS_AD_INVALID_APPL';
     x_msg_count :=0;
     CLOSE c_appl_cur;
     RETURN;
  END IF;
  CLOSE c_appl_cur;

-- hreddych 3419856 For a NON-AWARD Appl Type the Entry Qual Status and Appl Comp Status
-- should be NOT-APPLIC
  IF l_adm_proc_type = 'NON-AWARD' THEN
    lvc_user_application_status := igs_ad_gen_009.admp_get_sys_ads('NOT-APPLIC');
    lvc_user_entry_qual_status  := igs_ad_gen_009.admp_get_sys_aeqs('NOT-APPLIC');
  END IF;

--Check whether the Admission Entry qualification status be updated
--to system admission entry qualification
--'QUALIFIED' by calling the following API. If API returns false
--then correspondingly update the x_return_status to 'E'. x_msg_data will contain the error message thrown by the API.
  IF NOT (igs_ad_val_acai_status.admp_val_acai_aeqs(
          lvc_user_entry_qual_status,
          lvc_user_outcome_status,
          c_appl_rec.s_admission_process_type,
          x_msg_data)) THEN
     x_return_status:='E';
     x_msg_count :=0;
     RETURN;
  END IF;

--Check whether the Admission Application status can be updated to 'SATISFIED' by calling the following API. If API returns false
--then correspondingly update the x_return_status to 'E'. x_msg_data will contain the error message thrown by the API.

--Validate at Record level which internally validates the Item Level also.
--Capture the error message into x_msg_data if the validation returns FALSE.
  IF NOT (igs_ad_val_acai_status.admp_val_acai_ads(
          lvc_user_application_status,
          lvc_user_outcome_status,
          lvc_user_conditional_status,
          c_appl_rec.s_admission_process_type,
          'N',
          x_msg_data)) THEN
     x_return_status :='E';
     x_msg_count :=0;
    RETURN;
  END IF;

-- Check whether the tracking type is assoicated for the APC
 OPEN c_trk_exists(l_adm_cat, l_adm_proc_type);
 FETCH c_trk_exists INTO l_trk_exists;

--IF l_trk_exists <> 0 THEN
IF c_trk_exists%FOUND THEN

--Check whether the tracking items are completed for the Application by calling the following API.
  IF NOT (igs_ad_ac_comp.get_cmp_apltritm(
          p_person_id,
          p_admission_application_number,
          p_nominated_course_cd,
          p_sequence_number)) THEN
     x_return_status:='E';
     x_msg_count:=0;
     x_msg_data:=  'IGS_AD_CNT_COM_APP';
    RETURN;
  END IF;

ELSE
   x_return_status := 'S';
   x_msg_data := NULL;
   x_msg_count:=0;

END IF;
  CLOSE c_trk_exists;

 --Control reaches here if all the validations are successful. The x_return_Status is set to 'S' and x_msg_data tp 0
  x_return_status := 'S';
  x_msg_data := NULL;
  x_msg_count:=0;

END check_update_aeps_acs;

PROCEDURE get_appl_type_fee_details(
         p_person_id             IN NUMBER,
         p_admission_appl_number IN NUMBER,
         appl_fee_amt            OUT NOCOPY NUMBER,
         revenue_acct_code       OUT NOCOPY VARCHAR2,
         cash_acct_code          OUT NOCOPY VARCHAR2,
         revenue_acct_ccid       OUT NOCOPY NUMBER,
         cash_acct_ccid          OUT NOCOPY NUMBER,
         x_return_status         OUT NOCOPY VARCHAR2,
         x_msg_count             OUT NOCOPY NUMBER,
         x_msg_data              OUT NOCOPY VARCHAR2)
AS
/**************************************************************
 Created By :rboddu
 modified to derive fee amount from igs_ad_appl_all - igsm - arvsrini
 Date Created By : 31-DEC-2001
 Purpose : 2158524
 Know limitations, enhancements or remarks
 Change History
 Who             When            What
 (reverse chronological order - newest change first)
***************************************************************/


--Cursor which returns the admission_application_type associated with the passed admission_application_number
CURSOR get_appl_type_cur IS
   SELECT application_type
   FROM igs_ad_appl
   WHERE person_id = p_person_id AND
         admission_appl_number = p_admission_appl_number;

--Cursor to fetch the account details associated with the application_type into the OUT NOCOPY parameters
CURSOR get_account_details_cur(l_adm_application_type igs_ad_ss_appl_typ.admission_application_type%TYPE) IS
    SELECT
	   gl_rev_acct_ccid,
	   gl_cash_acct_ccid,
           rev_account_code,
	   cash_account_code
    FROM   igs_ad_ss_appl_typ
    WHERE  admission_application_type = l_adm_application_type;

-- Cursor to fetch the outstanding balance for the applicant		--arvsrini
CURSOR c_appl_fee_amt IS
    SELECT
	(NVL(apl.appl_fee_amt,0)-sum(req.FEE_AMOUNT)) OutstandingBal
	FROM
	IGS_AD_APPL_ALL apl,
	igs_ad_app_req req
	WHERE
	apl.person_id= p_person_id AND
	apl.admission_appl_number = p_admission_appl_number AND
	apl.person_id = req.person_id AND
	apl.admission_appl_number= req.admission_appl_number AND
	EXISTS (SELECT 'x'
		FROM igs_ad_code_classes
		WHERE class = 'SYS_FEE_TYPE'
		AND system_status = 'APPL_FEE'
		AND applicant_fee_type = code_id
		AND CLASS_TYPE_CODE = 'ADM_CODE_CLASSES')
	GROUP BY apl.appl_fee_amt;
--cursor to fetch the initial application fee amount
CURSOR c_appl_fee_appl IS
     SELECT
        NVL(apl.appl_fee_amt,0) appfee
     FROM IGS_AD_APPL_ALL apl
     WHERE
	apl.person_id= p_person_id AND
	apl.admission_appl_number = p_admission_appl_number;


l_application_type igs_ad_ss_appl_typ.admission_application_type%TYPE;

BEGIN
  OPEN get_appl_type_cur;
  FETCH get_appl_type_cur INTO l_application_type;

   -- If application_type associated with the given person is not found then populate error message into out NOCOPY parameter x_msg_data.
   IF l_application_type IS NULL THEN
      x_return_status:= 'E';
      x_msg_data := 'IGS_AD_NO_APPL_TYPE';
      x_msg_count :=0;
      appl_fee_amt  :=     NULL;
      revenue_acct_code := NULL;
      cash_acct_code :=    NULL;
      revenue_acct_ccid := NULL;
      cash_acct_ccid :=    NULL;

      CLOSE get_appl_type_cur;
      RETURN;
   ELSE
      OPEN c_appl_fee_appl;
      FETCH c_appl_fee_appl INTO appl_fee_amt;
       IF (c_appl_fee_appl%NOTFOUND) THEN
	appl_fee_amt:=0;
       END IF;
      CLOSE c_appl_fee_appl;

      OPEN get_account_details_cur(l_application_type);
      FETCH get_account_details_cur
      INTO
        revenue_acct_ccid,
        cash_acct_ccid,
        revenue_acct_code,
        cash_acct_code;
      CLOSE get_account_details_cur;

      OPEN c_appl_fee_amt;					--  IGS.M fee details derivation
      FETCH c_appl_fee_amt INTO appl_fee_amt;

       IF (c_appl_fee_amt%FOUND) THEN
	IF appl_fee_amt < 0 THEN
		appl_fee_amt:= 0;
	END IF;
       END IF;

      CLOSE c_appl_fee_amt;

      x_return_status := 'S';
      x_msg_data := NULL;
      x_msg_count := 0;
      CLOSE get_appl_type_cur;
    END IF;

    IF(get_appl_type_cur%ISOPEN) THEN
	 CLOSE get_appl_type_cur;
    END IF;

END get_appl_type_fee_details;

PROCEDURE upd_fee_details( p_person_id IN NUMBER,
                           p_admission_appl_number IN NUMBER,
                           p_app_fee_amt IN NUMBER,
                           p_authorization_number IN VARCHAR2,
                           p_sys_fee_status IN VARCHAR2,
                           p_sys_fee_type IN VARCHAR2,
                           p_sys_fee_method IN VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           p_credit_card_code IN VARCHAR2,
                           p_credit_card_holder_name IN VARCHAR2,
                           p_credit_card_number IN VARCHAR2,
                           p_credit_card_expiration_date IN DATE,
                           p_gl_date IN DATE,
                           p_rev_gl_ccid IN NUMBER,
                           p_cash_gl_ccid IN NUMBER,
                           p_rev_account_cd IN VARCHAR2,
                           p_cash_account_cd IN VARCHAR2,
                           p_credit_card_tangible_cd IN VARCHAR2
                           ) AS
    /*************************************************************
    Created By :rboddu
    Date Created By : 31-DEC-2001
    Purpose : 2158524
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    (reverse chronological order - newest change first)
    pathipat    14-Jun-2003    Enh 2831587 - Credit Card Fund Transfer build
                               Added new IN parameter, p_credit_card_tangible_cd
                               Modified call to igs_ad_app_req_pkg.insert_row() - added 3 new parameters
    VVUTUKUR    26-NOV-2002    Enh#2584986.GL Interface Build. Added 9 new parameters to this procedure.
                               These additional attributes, i.e. credit card details, Accounting information and the GL_DATE are passed to the call to igs_ad_app_req_pkg.insert_row.
    ***************************************************************/

   --CURSOR which checks whether the application is a valid one
      CURSOR is_valid_appl_cur(l_person_id IN NUMBER, l_admission_appl_number IN NUMBER) IS
        SELECT person_id
        FROM igs_ad_appl apai
        WHERE apai.person_id = l_person_id AND
        apai.admission_appl_number = l_admission_appl_number;

   --CURSOR which retrieves the default System Status for the given System Fee Method
      CURSOR def_pay_method_cur IS
        SELECT code_id
        FROM igs_ad_code_classes
        WHERE system_status = p_sys_fee_method
        AND system_default = 'Y'
	AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';
   -- removed the check whether there is already a transaction with the same Fee Type
   --CURSOR which retrieves the default System Status for the given System Fee Status
      CURSOR def_fee_status_cur IS
        SELECT code_id
        FROM igs_ad_code_classes
        WHERE system_status = p_sys_fee_status
        AND system_default = 'Y'
	AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

   --CURSOR which retrieves the default System Status for the given System Fee Type
      CURSOR def_fee_types_cur IS
        SELECT code_id
        FROM igs_ad_code_classes
        WHERE system_status = p_sys_fee_type
        AND system_default = 'Y'
	AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';


      l_default_pay_method  igs_ad_code_classes.code_id%TYPE;
      l_default_fee_status  igs_ad_code_classes.code_id%TYPE;
      l_default_fee_type    igs_ad_code_classes.code_id%TYPE;
      l_rowid               VARCHAR2(100);
      l_app_req_id          NUMBER(15);
      lv_person_id          igs_ad_appl.person_id%TYPE;
      lv_dup_person VARCHAR2(10);
      l_message VARCHAR2(100);
      invalidamount EXCEPTION;
      invalidappl  EXCEPTION;
      sysinvalid  EXCEPTION;

    BEGIN
     --If passed fee amount is not positive then abort the process by raising error
      IF p_app_fee_amt <= 0 THEN
        RAISE invalidamount;
      END IF;

     -- If application is invalid then abort the process by raising error
      OPEN is_valid_appl_cur(p_person_id,p_admission_appl_number);
      FETCH is_valid_appl_cur INTO lv_person_id;
        IF is_valid_appl_cur%NOTFOUND THEN
          RAISE invalidappl;
        ELSE
     --Get the default payment method associated with the given System Payment method
          OPEN def_pay_method_cur;
          FETCH def_pay_method_cur INTO l_default_pay_method;
          IF def_pay_method_cur%NOTFOUND THEN
          CLOSE def_pay_method_cur;
            RAISE sysinvalid;
          END IF;
          CLOSE def_pay_method_cur;
     --Get the default fee status associated with the given system Fee Status
          OPEN def_fee_status_cur;
          FETCH def_fee_status_cur INTO l_default_fee_status;
          IF def_fee_status_cur%NOTFOUND THEN
            CLOSE def_fee_status_cur;
            RAISE sysinvalid;
          END IF;
          CLOSE def_fee_status_cur;
     --Get the default Fee Status associated with the given System Fee Type
          OPEN def_fee_types_cur;
          FETCH def_fee_types_cur INTO l_default_fee_type;

          IF def_fee_types_cur%NOTFOUND THEN
            CLOSE def_fee_types_cur;
            RAISE sysinvalid;
          END IF;
          CLOSE def_fee_types_cur;

    -- Removed the existing check that disallowed multiple payments for the same fee type as a part of IGS.M

	    igs_ad_app_req_pkg.insert_row(
                                      X_ROWID                        => l_rowid,
                                      X_APP_REQ_ID                   => l_app_req_id,
                                      X_PERSON_ID                    => p_person_id,
                                      X_ADMISSION_APPL_NUMBER        => p_admission_appl_number,
                                      X_APPLICANT_FEE_TYPE           => l_default_fee_type,
                                      X_APPLICANT_FEE_STATUS         => l_default_fee_status,
                                      X_FEE_DATE                     => TRUNC(SYSDATE),
                                      X_FEE_PAYMENT_METHOD           => l_default_pay_method,
                                      X_FEE_AMOUNT                   => p_app_fee_amt,
                                      X_REFERENCE_NUM                => p_authorization_number,
                                      X_CREDIT_CARD_CODE             => p_credit_card_code,
                                      X_CREDIT_CARD_HOLDER_NAME      => p_credit_card_holder_name,
                                      X_CREDIT_CARD_NUMBER           => p_credit_card_number,
                                      X_CREDIT_CARD_EXPIRATION_DATE  => p_credit_card_expiration_date,
                                      X_REV_GL_CCID                  => p_rev_gl_ccid,
                                      X_CASH_GL_CCID                 => p_cash_gl_ccid,
                                      X_REV_ACCOUNT_CD               => p_rev_account_cd,
                                      X_CASH_ACCOUNT_CD              => p_cash_account_cd,
                                      X_GL_DATE                      => p_gl_date,
                                      X_GL_POSTED_DATE               => NULL,
                                      X_POSTING_CONTROL_ID           => NULL,
                                      x_credit_card_tangible_cd      => p_credit_card_tangible_cd,
                                      x_credit_card_payee_cd         => fnd_profile.value('IGS_FI_PAYEE_NAME'),
                                      x_credit_card_status_code      => 'PENDING'
                                     );
          END IF;

     -- All the validations are successfull and insertion of record into igs_ad_app_req is successfull.
        x_return_status := 'S';
        x_msg_count:=0;
        x_msg_data :=NULL;

    EXCEPTION
      WHEN invalidamount THEN
        x_return_status := 'E';
        x_msg_count:=0;
        x_msg_data :='IGS_AD_FEE_AMT_NON_NEGATIVE';
        RETURN;

      WHEN invalidappl THEN
        x_return_status := 'E';
        x_msg_count:=0;
        x_msg_data :='IGS_AD_INVALID_APPL';
        RETURN;

      WHEN sysinvalid THEN
        x_return_status := 'E';
        x_msg_count:=0;
        x_msg_data :='IGS_AD_INVALID_SYSTEM_TYPE';
        RETURN;


      WHEN OTHERS THEN
        x_return_status := 'E';
        x_msg_count:=0;
        x_msg_data :=sqlerrm;
        RETURN;

    END upd_fee_details;

END igs_ad_ss_appl_fee_pkg;

/
