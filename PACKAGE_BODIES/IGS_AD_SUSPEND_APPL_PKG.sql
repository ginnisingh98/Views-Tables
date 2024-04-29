--------------------------------------------------------
--  DDL for Package Body IGS_AD_SUSPEND_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SUSPEND_APPL_PKG" AS
/* $Header: IGSADC3B.pls 120.2 2006/01/16 20:24:47 rghosh ship $ */
/******************************************************************
Created By: Tapash.Ray@oracle.com
Date Created: 09-16-2002
Purpose: ADCR040 -  Change Suspended Applications to Withdrawn
Known limitations,enhancements,remarks:
 Change History
Who        When          What
******************************************************************/
PROCEDURE prc_suspend_adm_appl(
	                    errbuf                         OUT NOCOPY  VARCHAR2,
	                    retcode                        OUT NOCOPY  NUMBER,
		            p_acad_perd                   IN     VARCHAR2,
	                    p_adm_perd                    IN     VARCHAR2,
	                    p_admission_process_category   IN   VARCHAR2) AS

/*****************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created :  09-16-2002
Purpose:  ADCR040 -  Change Suspended Applications to Withdrawn, Main Proc
Known limitations,enhancements,remarks:
Change History
Who        When          What
nshee      17-DEC-2002 changed the check, additional check to log data when program start date is in future too., bug 2630250
*****************************************************************************************/

         CURSOR c_cal_abs_val(cp_adm_cal_type igs_ad_appl_all.adm_cal_type%TYPE,cp_adm_ci_seq_number igs_ad_appl_all.adm_ci_sequence_number%TYPE) IS
 	 SELECT c.absolute_val absolute_value
         FROM IGS_CA_DA_INST c
         WHERE
	     c.cal_type =  cp_adm_cal_type
             AND c.ci_sequence_number = cp_adm_ci_seq_number
             AND c.dt_alias = (select ADM_APPL_COURSE_STRT_DT_ALIAS from  IGS_AD_CAL_CONF);
	 c_cal_abs_val_rec c_cal_abs_val%ROWTYPE;

         CURSOR c_all_records_case_1 IS
         SELECT a.*
         FROM igs_ad_ps_appl_inst a
         WHERE a.adm_outcome_status IN
              ( SELECT adm_outcome_status
                FROM igs_ad_ou_stat
                WHERE s_adm_outcome_status = 'SUSPEND') ;

         CURSOR c_all_records_case_2(cp_acad_cal_type  igs_ad_appl_all.acad_cal_type%TYPE,cp_acad_ci_sequence_number igs_ad_appl_all.acad_ci_sequence_number%TYPE) IS
         SELECT a.*
         FROM IGS_AD_PS_APPL_INST a,
              IGS_AD_APPL_ALL b
         WHERE
              a.person_id=b.person_id AND
              a.admission_appl_number = b.admission_appl_number AND
              b.acad_cal_type = cp_acad_cal_type AND
              b.acad_ci_sequence_number = cp_acad_ci_sequence_number AND
              a.adm_outcome_status IN (SELECT adm_outcome_status
                                    FROM igs_ad_ou_stat
                                    WHERE s_adm_outcome_status = 'SUSPEND');

         CURSOR c_all_records_case_3(cp_acad_cal_type  igs_ad_appl_all.acad_cal_type%TYPE,
	                             cp_acad_ci_sequence_number igs_ad_appl_all.acad_ci_sequence_number%TYPE,
				     cp_adm_cal_type igs_ad_appl_all.adm_cal_type%TYPE,
				     cp_adm_ci_sequence_number igs_ad_appl_all.adm_ci_sequence_number%TYPE) IS
	 SELECT a.*
	 FROM IGS_AD_PS_APPL_INST a, IGS_AD_APPL_ALL b
	 WHERE a.person_id=b.person_id AND
	 a.admission_appl_number = b.admission_appl_number AND
         b.acad_cal_type = cp_acad_cal_type AND
         b.acad_ci_sequence_number = cp_acad_ci_sequence_number AND
         b.adm_cal_type = cp_adm_cal_type AND
         b.adm_ci_sequence_number = cp_adm_ci_sequence_number AND
         a.adm_outcome_status IN (SELECT adm_outcome_status
                                  FROM igs_ad_ou_stat
                                  WHERE s_adm_outcome_status = 'SUSPEND');

         CURSOR c_all_records_case_4(cp_acad_cal_type  igs_ad_appl_all.acad_cal_type%TYPE,
	                             cp_acad_ci_sequence_number igs_ad_appl_all.acad_ci_sequence_number%TYPE,
				     cp_adm_cal_type igs_ad_appl_all.adm_cal_type%TYPE,
				     cp_adm_ci_sequence_number igs_ad_appl_all.adm_ci_sequence_number%TYPE,
				     cp_adm_cat igs_ad_prd_ad_prc_ca.admission_cat%TYPE,
				     cp_admission_process_type igs_ad_prd_ad_prc_ca.s_admission_process_type%TYPE) IS
         SELECT  a.*
         FROM IGS_AD_PS_APPL_INST a, IGS_AD_APPL_ALL b
         WHERE a.person_id=b.person_id AND
               a.admission_appl_number = b.admission_appl_number AND
               b.acad_cal_type = cp_acad_cal_type AND
               b.acad_ci_sequence_number = cp_acad_ci_sequence_number AND
               b.adm_cal_type = cp_adm_cal_type AND
               b.adm_ci_sequence_number = cp_adm_ci_sequence_number AND
               b.admission_cat = cp_adm_cat AND
               b.s_admission_process_type = cp_admission_process_type AND
               a.adm_outcome_status IN (SELECT adm_outcome_status
                                        FROM igs_ad_ou_stat
                                        WHERE s_adm_outcome_status = 'SUSPEND');


        CURSOR c_get_alt_code(cp_cal_type igs_ca_inst.cal_type%TYPE,cp_seq_no igs_ca_inst.sequence_number%TYPE) IS
	SELECT alternate_code
	FROM IGS_CA_INST
	WHERE cal_type = cp_cal_type AND
              sequence_number = cp_seq_no;


	lv_acad_cal_type igs_ad_appl_all.acad_cal_type%TYPE;
        lv_acad_ci_sequence_number igs_ad_appl_all.acad_ci_sequence_number%TYPE;
        lv_adm_cal_type igs_ad_appl_all.adm_cal_type%TYPE;
	lv_adm_ci_sequence_number igs_ad_appl_all.adm_ci_sequence_number%TYPE;
	lv_admission_cat igs_ad_prd_ad_prc_ca.admission_cat%TYPE ;
	lv_admission_process_type igs_ad_prd_ad_prc_ca.s_admission_process_type%TYPE;
	lv_alt_code_acad igs_ca_inst.alternate_code%TYPE;
	lv_alt_code_adm igs_ca_inst.alternate_code%TYPE;


        CASE_1 BOOLEAN;
        CASE_2 BOOLEAN;
        CASE_3 BOOLEAN;
        CASE_4 BOOLEAN;

	PROCEDURE logerror(p_pid IN igs_ad_ps_appl_inst.person_id%TYPE,
	                   p_aid IN igs_ad_ps_appl_inst.admission_appl_number%TYPE,
			   p_pc IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
			   p_seq IN igs_ad_ps_appl_inst.sequence_number%TYPE,
			   p_message IN VARCHAR2) AS
/*****************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created :  09-16-2002
Purpose:  ADCR040 -  Change Suspended Applications to Withdrawn: Log Error Procedure
Known limitations,enhancements,remarks:
Change History
Who        When          What
*****************************************************************************************/
			   CURSOR c_get_person_number IS SELECT party_number FROM hz_parties
			   WHERE party_id = p_pid;
			   l_person_number hz_parties.party_number%TYPE;
			   l_err_msg VARCHAR2(2000);
        BEGIN
	  OPEN c_get_person_number ;
	  FETCH c_get_person_number  INTO l_person_number;
	  CLOSE c_get_person_number ;
	   FND_MESSAGE.SET_NAME ('IGS', p_message);
	   l_err_msg := FND_MESSAGE.GET();
           FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_ERROR_MESSAGE');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,rpad(l_person_number,30)||rpad(p_aid,19)||rpad(p_pc,13)||rpad(p_seq,16)||fnd_global.newline||FND_MESSAGE.GET()||l_err_msg );
        END logerror;

	PROCEDURE update_appl_inst(cp_all_records_rec c_all_records_case_1%ROWTYPE)
	IS
/*****************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created :  09-16-2002
Purpose:  ADCR040 -  Change Suspended Applications to Withdrawn:  Updates Application instance
Known limitations,enhancements,remarks:
Change History
Who        When          What
*****************************************************************************************/
  	  lv_msg VARCHAR2(2000);
	BEGIN
	  		      IGS_AD_PS_APPL_INST_PKG.UPDATE_ROW (
			      X_Mode                              => 'R',
			      X_RowId                             => cp_all_records_rec.row_id,
			      X_Person_Id                         => cp_all_records_rec.Person_Id                     ,
			      X_Admission_Appl_Number             => cp_all_records_rec.Admission_Appl_Number         ,
			      X_Nominated_Course_Cd               => cp_all_records_rec.Nominated_Course_Cd           ,
			      X_Sequence_Number                   => cp_all_records_rec.Sequence_Number               ,
			      X_Predicted_Gpa                     => cp_all_records_rec.Predicted_Gpa                 ,
			      X_Academic_Index                    => cp_all_records_rec.Academic_Index                ,
			      X_Adm_Cal_Type                      => cp_all_records_rec.Adm_Cal_Type                  ,
			      X_App_File_Location                 => cp_all_records_rec.App_File_Location             ,
			      X_Adm_Ci_Sequence_Number            => cp_all_records_rec.Adm_Ci_Sequence_Number        ,
			      X_Course_Cd                         => cp_all_records_rec.Course_Cd                     ,
			      X_App_Source_Id                     => cp_all_records_rec.App_Source_Id                 ,
			      X_Crv_Version_Number                => cp_all_records_rec.Crv_Version_Number            ,
			      X_Waitlist_Rank                     => cp_all_records_rec.Waitlist_Rank                 ,
			      X_Location_Cd                       => cp_all_records_rec.Location_Cd                   ,
			      X_Attent_Other_Inst_Cd              => cp_all_records_rec.Attent_Other_Inst_Cd          ,
			      X_Attendance_Mode                   => cp_all_records_rec.Attendance_Mode               ,
			      X_Edu_Goal_Prior_Enroll_Id          => cp_all_records_rec.Edu_Goal_Prior_Enroll_Id      ,
			      X_Attendance_Type                   => cp_all_records_rec.Attendance_Type               ,
			      X_Decision_Make_Id                  => cp_all_records_rec.Decision_Make_Id              ,
			      X_Unit_Set_Cd                       => cp_all_records_rec.Unit_Set_Cd                   ,
			      X_Decision_Date                     => cp_all_records_rec.Decision_Date                 ,
			      X_Attribute_Category                => cp_all_records_rec.Attribute_Category            ,
			      X_Attribute1                        => cp_all_records_rec.Attribute1                    ,
			      X_Attribute2                        => cp_all_records_rec.Attribute2                    ,
			      X_Attribute3                        => cp_all_records_rec.Attribute3                    ,
			      X_Attribute4                        => cp_all_records_rec.Attribute4                    ,
			      X_Attribute5                        => cp_all_records_rec.Attribute5                    ,
			      X_Attribute6                        => cp_all_records_rec.Attribute6                    ,
			      X_Attribute7                        => cp_all_records_rec.Attribute7                    ,
			      X_Attribute8                        => cp_all_records_rec.Attribute8                    ,
			      X_Attribute9                        => cp_all_records_rec.Attribute9                    ,
			      X_Attribute10                       => cp_all_records_rec.Attribute10                   ,
			      X_Attribute11                       => cp_all_records_rec.Attribute11                   ,
			      X_Attribute12                       => cp_all_records_rec.Attribute12                   ,
			      X_Attribute13                       => cp_all_records_rec.Attribute13                   ,
			      X_Attribute14                       => cp_all_records_rec.Attribute14                   ,
			      X_Attribute15                       => cp_all_records_rec.Attribute15                   ,
			      X_Attribute16                       => cp_all_records_rec.Attribute16                   ,
			      X_Attribute17                       => cp_all_records_rec.Attribute17                   ,
			      X_Attribute18                       => cp_all_records_rec.Attribute18                   ,
			      X_Attribute19                       => cp_all_records_rec.Attribute19                   ,
			      X_Attribute20                       => cp_all_records_rec.Attribute20                   ,
			      X_Decision_Reason_Id                => cp_all_records_rec.Decision_Reason_Id            ,
			      X_Us_Version_Number                 => cp_all_records_rec.Us_Version_Number             ,
			      X_Decision_Notes                    => cp_all_records_rec.Decision_Notes                ,
			      X_Pending_Reason_Id                 => cp_all_records_rec.Pending_Reason_Id             ,
			      X_Preference_Number                 => cp_all_records_rec.Preference_Number             ,
			      X_Adm_Doc_Status                    => cp_all_records_rec.Adm_Doc_Status                ,
			      X_Adm_Entry_Qual_Status             => cp_all_records_rec.Adm_Entry_Qual_Status         ,
			      X_Deficiency_In_Prep                => cp_all_records_rec.Deficiency_In_Prep            ,
			      X_Late_Adm_Fee_Status               => cp_all_records_rec.Late_Adm_Fee_Status           ,
			      X_Spl_Consider_Comments             => cp_all_records_rec.Spl_Consider_Comments         ,
			      X_Apply_For_Finaid                  => cp_all_records_rec.Apply_For_Finaid              ,
			      X_Finaid_Apply_Date                 => cp_all_records_rec.Finaid_Apply_Date             ,
			      X_Adm_Outcome_Status                => igs_ad_gen_009.admp_get_sys_aos('WITHDRAWN')            ,
			      X_Adm_Otcm_Stat_Auth_Per_Id         => cp_all_records_rec.adm_otcm_status_auth_person_id,
			      X_Adm_Outcome_Status_Auth_Dt        => cp_all_records_rec.Adm_Outcome_Status_Auth_Dt    ,
			      X_Adm_Outcome_Status_Reason         => cp_all_records_rec.Adm_Outcome_Status_Reason     ,
			      X_Offer_Dt                          => cp_all_records_rec.Offer_Dt                      ,
			      X_Offer_Response_Dt                 => cp_all_records_rec.Offer_Response_Dt             ,
			      X_Prpsd_Commencement_Dt             => cp_all_records_rec.Prpsd_Commencement_Dt         ,
			      X_Adm_Cndtnl_Offer_Status           => cp_all_records_rec.Adm_Cndtnl_Offer_Status       ,
			      X_Cndtnl_Offer_Satisfied_Dt         => cp_all_records_rec.Cndtnl_Offer_Satisfied_Dt     ,
			      X_Cndnl_Ofr_Must_Be_Stsfd_Ind       => cp_all_records_rec.cndtnl_offer_must_be_stsfd_ind   ,
			      X_Adm_Offer_Resp_Status             => cp_all_records_rec.Adm_Offer_Resp_Status         ,
			      X_Actual_Response_Dt                => cp_all_records_rec.Actual_Response_Dt            ,
			      X_Adm_Offer_Dfrmnt_Status           => cp_all_records_rec.Adm_Offer_Dfrmnt_Status       ,
			      X_Deferred_Adm_Cal_Type             => cp_all_records_rec.Deferred_Adm_Cal_Type         ,
			      X_Deferred_Adm_Ci_Sequence_Num      => cp_all_records_rec.Deferred_Adm_Ci_Sequence_Num  ,
			      X_Deferred_Tracking_Id              => cp_all_records_rec.Deferred_Tracking_Id          ,
			      X_Ass_Rank                          => cp_all_records_rec.Ass_Rank                      ,
			      X_Secondary_Ass_Rank                => cp_all_records_rec.Secondary_Ass_Rank            ,
			      X_Intr_Accept_Advice_Num            => cp_all_records_rec.intrntnl_acceptance_advice_num         ,
			      X_Ass_Tracking_Id                   => cp_all_records_rec.Ass_Tracking_Id               ,
			      X_Fee_Cat                           => cp_all_records_rec.Fee_Cat                       ,
			      X_Hecs_Payment_Option               => cp_all_records_rec.Hecs_Payment_Option           ,
			      X_Expected_Completion_Yr            => cp_all_records_rec.Expected_Completion_Yr        ,
			      X_Expected_Completion_Perd          => cp_all_records_rec.Expected_Completion_Perd      ,
			      X_Correspondence_Cat                => cp_all_records_rec.Correspondence_Cat            ,
			      X_Enrolment_Cat                     => cp_all_records_rec.Enrolment_Cat                 ,
			      X_Funding_Source                    => cp_all_records_rec.Funding_Source                ,
			      X_Applicant_Acptnce_Cndtn           => cp_all_records_rec.Applicant_Acptnce_Cndtn       ,
			      X_Cndtnl_Offer_Cndtn                => cp_all_records_rec.Cndtnl_Offer_Cndtn            ,
			      X_SS_APPLICATION_ID                 => cp_all_records_rec.SS_APPLICATION_ID             ,
			      X_SS_PWD                            => cp_all_records_rec.SS_PWD                        ,
			      X_AUTHORIZED_DT                     => cp_all_records_rec.AUTHORIZED_DT                 ,
			      X_AUTHORIZING_PERS_ID               => cp_all_records_rec.AUTHORIZING_PERS_ID           ,
			      X_ENTRY_STATUS                      => cp_all_records_rec.ENTRY_STATUS                  ,
			      X_ENTRY_LEVEL                       => cp_all_records_rec.ENTRY_LEVEL                   ,
			      X_SCH_APL_TO_ID                     => cp_all_records_rec.SCH_APL_TO_ID                 ,
			      X_IDX_CALC_DATE                     => cp_all_records_rec.IDX_CALC_DATE                 ,
			      X_WAITLIST_STATUS                   => cp_all_records_rec.WAITLIST_STATUS               ,
			      X_Attribute21                       => cp_all_records_rec.Attribute21                   ,
			      X_Attribute22                       => cp_all_records_rec.Attribute22                   ,
			      X_Attribute23                       => cp_all_records_rec.Attribute23                   ,
			      X_Attribute24                       => cp_all_records_rec.Attribute24                   ,
			      X_Attribute25                       => cp_all_records_rec.Attribute25                   ,
			      X_Attribute26                       => cp_all_records_rec.Attribute26                   ,
			      X_Attribute27                       => cp_all_records_rec.Attribute27                   ,
			      X_Attribute28                       => cp_all_records_rec.Attribute28                   ,
			      X_Attribute29                       => cp_all_records_rec.Attribute29                   ,
			      X_Attribute30                       => cp_all_records_rec.Attribute30                   ,
			      X_Attribute31                       => cp_all_records_rec.Attribute31                   ,
			      X_Attribute32                       => cp_all_records_rec.Attribute32                   ,
			      X_Attribute33                       => cp_all_records_rec.Attribute33                   ,
			      X_Attribute34                       => cp_all_records_rec.Attribute34                   ,
			      X_Attribute35                       => cp_all_records_rec.Attribute35                   ,
			      X_Attribute36                       => cp_all_records_rec.Attribute36                   ,
			      X_Attribute37                       => cp_all_records_rec.Attribute37                   ,
			      X_Attribute38                       => cp_all_records_rec.Attribute38                   ,
			      X_Attribute39                       => cp_all_records_rec.Attribute39                   ,
			      X_Attribute40                       => cp_all_records_rec.Attribute40                   ,
			      x_fut_acad_cal_type                 => cp_all_records_rec.future_acad_cal_type                ,
			      x_fut_acad_ci_sequence_number       => cp_all_records_rec.future_acad_ci_sequence_number    ,
			      x_fut_adm_cal_type                  => cp_all_records_rec.future_adm_cal_type                  ,
			      x_fut_adm_ci_sequence_number        => cp_all_records_rec.future_adm_ci_sequence_number      ,
			      x_prev_term_adm_appl_number         => cp_all_records_rec.previous_term_adm_appl_number     ,
			      x_prev_term_sequence_number         => cp_all_records_rec.previous_term_sequence_number       ,
			      x_fut_term_adm_appl_number          => cp_all_records_rec.future_term_adm_appl_number      ,
			      x_fut_term_sequence_number          => cp_all_records_rec.future_term_sequence_number          ,
			      x_def_acad_cal_type                 => cp_all_records_rec.def_acad_cal_type             ,
			      x_def_acad_ci_sequence_num          => cp_all_records_rec.def_acad_ci_sequence_num      ,
			      x_def_prev_term_adm_appl_num        => cp_all_records_rec.def_prev_term_adm_appl_num    ,
			      x_def_prev_appl_sequence_num        => cp_all_records_rec.def_prev_appl_sequence_num    ,
			      x_def_term_adm_appl_num             => cp_all_records_rec.def_term_adm_appl_num         ,
			      x_def_appl_sequence_num             => cp_all_records_rec.def_appl_sequence_num,
			      x_appl_inst_status		  => cp_all_records_rec.appl_inst_status,
			      x_ais_reason			  => cp_all_records_rec.ais_reason,
			      x_decline_ofr_reason		  => cp_all_records_rec.decline_ofr_reason
    			      );
        EXCEPTION
  	  WHEN OTHERS THEN
            fnd_message.RETRIEVE(lv_msg);
	    lv_msg := replace(lv_msg,chr(0),'/');
            lv_msg := substr(lv_msg,instr(lv_msg,'/')+1);
            lv_msg := substr(lv_msg,1,instr(lv_msg,'/')-1);
              LOGERROR(p_pid =>cp_all_records_rec.person_id,
                       p_aid => cp_all_records_rec.admission_appl_number,
		       p_pc => cp_all_records_rec.nominated_course_cd,
		       p_seq => cp_all_records_rec.sequence_number,
		       p_message =>lv_msg);
	END update_appl_inst;
BEGIN

        -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
        igs_ge_gen_003.set_org_id(null);

---------------------------------------------------------------------------------
--Intialize local var
---------------------------------------------------------------------------------
	retcode := 0;
	lv_acad_cal_type := RTRIM(SUBSTR(p_acad_perd,101, 10));
        lv_acad_ci_sequence_number := (SUBSTR(p_acad_perd,112));
        lv_adm_cal_type := RTRIM(SUBSTR(p_adm_perd,1, 10));
        lv_adm_ci_sequence_number:= RTRIM(SUBSTR(p_adm_perd,11));
        lv_admission_cat := RTRIM(SUBSTR(p_admission_process_category, 1, 10));
        lv_admission_process_type:= RTRIM(SUBSTR( p_admission_process_category, 14));

        CASE_1 := FALSE;
        CASE_2 := FALSE;
        CASE_3 := FALSE;
        CASE_4 := FALSE;

---------------------------------------------------------------------------------
--Get Alternate Code
---------------------------------------------------------------------------------
        OPEN c_get_alt_code(lv_acad_cal_type,lv_acad_ci_sequence_number);
	FETCH c_get_alt_code INTO lv_alt_code_acad;
	CLOSE c_get_alt_code;

        OPEN c_get_alt_code(lv_adm_cal_type,lv_adm_ci_sequence_number);
	FETCH c_get_alt_code INTO lv_alt_code_adm;
	CLOSE c_get_alt_code;

---------------------------------------------------------------------------------
--Define Log File
---------------------------------------------------------------------------------
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APPL_ACADCL_DTLS');
        FND_MESSAGE.SET_TOKEN('ACADCL',lv_alt_code_acad);
        FND_FILE.PUT_LINE (FND_FILE.LOG,lv_acad_cal_type||'/'||FND_MESSAGE.GET());

        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APPL_ADMCL_DTLS');
        FND_MESSAGE.SET_TOKEN('ADMCL', lv_alt_code_adm);
        FND_FILE.PUT_LINE (FND_FILE.LOG,lv_adm_cal_type||'/'||FND_MESSAGE.GET());

        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_APC');
        FND_MESSAGE.SET_TOKEN ('APC', p_admission_process_category);
        FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.GET());

        FND_FILE.PUT_LINE(FND_FILE.LOG,'================================================================================================');
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_SUSPEND_APPL_LOG_HDR');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
        FND_FILE.PUT_LINE(FND_FILE.LOG,'================================================================================================');

---------------------------------------------------------------------------------
--Judge Cases, Set Boolean TRUE for cases to execute
---------------------------------------------------------------------------------
	IF (p_acad_perd IS NULL AND p_adm_perd IS NULL AND p_admission_process_category IS NULL) THEN
          CASE_1 := TRUE;
          CASE_2 := FALSE;
          CASE_3 := FALSE;
          CASE_4 := FALSE;
        ELSIF ((p_acad_perd IS NOT NULL AND p_adm_perd IS NULL AND p_admission_process_category IS NULL)) THEN
          CASE_1 := FALSE;
          CASE_2 := TRUE;
          CASE_3 := FALSE;
          CASE_4 := FALSE;
        ELSIF ((p_acad_perd IS NOT NULL AND p_adm_perd IS NOT NULL AND p_admission_process_category IS NULL)) THEN
          CASE_1 := FALSE;
          CASE_2 := FALSE;
          CASE_3 := TRUE;
          CASE_4 := FALSE;
        ELSIF ((p_acad_perd IS NOT NULL AND p_adm_perd IS NOT NULL AND p_admission_process_category IS NOT NULL)) THEN
          CASE_1 := FALSE;
          CASE_2 := FALSE;
          CASE_3 := FALSE;
          CASE_4 := TRUE;
	END IF;

---------------------------------------------------------------------------------
--Executing Cases
---------------------------------------------------------------------------------
	IF CASE_1 THEN
          FOR c_all_records_case_1_rec in c_all_records_case_1 LOOP
	    OPEN c_cal_abs_val(c_all_records_case_1_rec.adm_cal_type,c_all_records_case_1_rec.adm_ci_sequence_number);
	    FETCH c_cal_abs_val INTO c_cal_abs_val_rec;
--	      IF c_cal_abs_val%NOTFOUND THEN --nshee bug 2630250
	      IF (c_cal_abs_val%NOTFOUND OR c_cal_abs_val_rec.absolute_value IS NULL OR TRUNC(c_cal_abs_val_rec.absolute_value)>TRUNC(SYSDATE)) THEN
---------------------------------------------------------------------------------
--Log Error if abs value not found
---------------------------------------------------------------------------------
	        LOGERROR(p_pid =>c_all_records_case_1_rec.person_id,
	                   p_aid => c_all_records_case_1_rec.admission_appl_number,
			   p_pc => c_all_records_case_1_rec.nominated_course_cd,
			   p_seq => c_all_records_case_1_rec.sequence_number,
			   p_message =>'IGS_AD_APPL_CANNOT_WITHDRAW');
              ELSE
		IF TRUNC(c_cal_abs_val_rec.absolute_value)<=TRUNC(SYSDATE) THEN
---------------------------------------------------------------------------------
--Update Application Instance if everything is correct
---------------------------------------------------------------------------------
			update_appl_inst(c_all_records_case_1_rec);
	        END IF;
	      END IF;
            CLOSE c_cal_abs_val;
	  END LOOP;
        ELSIF CASE_2 THEN
          FOR c_all_records_case_2_rec in c_all_records_case_2(lv_acad_cal_type,lv_acad_ci_sequence_number) LOOP
            OPEN c_cal_abs_val(c_all_records_case_2_rec.adm_cal_type,c_all_records_case_2_rec.adm_ci_sequence_number);
	    FETCH c_cal_abs_val INTO c_cal_abs_val_rec;
--	      IF c_cal_abs_val%NOTFOUND THEN --nshee bug 2630250
	      IF (c_cal_abs_val%NOTFOUND OR c_cal_abs_val_rec.absolute_value IS NULL OR TRUNC(c_cal_abs_val_rec.absolute_value)>TRUNC(SYSDATE)) THEN
	        LOGERROR(p_pid =>c_all_records_case_2_rec.person_id,
	                   p_aid => c_all_records_case_2_rec.admission_appl_number,
			   p_pc => c_all_records_case_2_rec.nominated_course_cd,
			   p_seq => c_all_records_case_2_rec.sequence_number,
			   p_message =>'IGS_AD_APPL_CANNOT_WITHDRAW');
              ELSE
                IF TRUNC(c_cal_abs_val_rec.absolute_value)<=TRUNC(SYSDATE) THEN
		        update_appl_inst(c_all_records_case_2_rec);
	        END IF;
              END IF;
            CLOSE c_cal_abs_val;
	  END LOOP;
        ELSIF CASE_3 THEN
          FOR c_all_records_case_3_rec in c_all_records_case_3(lv_acad_cal_type,lv_acad_ci_sequence_number,lv_adm_cal_type,lv_adm_ci_sequence_number) LOOP
            OPEN c_cal_abs_val(c_all_records_case_3_rec.adm_cal_type,c_all_records_case_3_rec.adm_ci_sequence_number);
	    FETCH c_cal_abs_val INTO c_cal_abs_val_rec;
--	      IF c_cal_abs_val%NOTFOUND THEN --nshee bug 2630250
	      IF (c_cal_abs_val%NOTFOUND OR c_cal_abs_val_rec.absolute_value IS NULL OR TRUNC(c_cal_abs_val_rec.absolute_value)>TRUNC(SYSDATE)) THEN
	        LOGERROR(p_pid =>c_all_records_case_3_rec.person_id,
	                   p_aid => c_all_records_case_3_rec.admission_appl_number,
			   p_pc => c_all_records_case_3_rec.nominated_course_cd,
			   p_seq => c_all_records_case_3_rec.sequence_number,
			   p_message =>'IGS_AD_APPL_CANNOT_WITHDRAW');
              ELSE
                IF TRUNC(c_cal_abs_val_rec.absolute_value)<=TRUNC(SYSDATE) THEN
		        update_appl_inst(c_all_records_case_3_rec);
		END IF;
	      END IF;
            CLOSE c_cal_abs_val;
	  END LOOP;
        ELSIF CASE_4 THEN
          FOR c_all_records_case_4_rec in c_all_records_case_4(lv_acad_cal_type,lv_acad_ci_sequence_number,
	                                                       lv_adm_cal_type,lv_adm_ci_sequence_number,
							       lv_admission_cat,
							       lv_admission_process_type) LOOP
            OPEN c_cal_abs_val(c_all_records_case_4_rec.adm_cal_type,c_all_records_case_4_rec.adm_ci_sequence_number);
	    FETCH c_cal_abs_val INTO c_cal_abs_val_rec;
--	      IF c_cal_abs_val%NOTFOUND THEN --nshee bug 2630250
	      IF ( c_cal_abs_val%NOTFOUND OR c_cal_abs_val_rec.absolute_value IS NULL OR TRUNC(c_cal_abs_val_rec.absolute_value)>TRUNC(SYSDATE)) THEN
	        LOGERROR(p_pid =>c_all_records_case_4_rec.person_id,
	                   p_aid => c_all_records_case_4_rec.admission_appl_number,
			   p_pc => c_all_records_case_4_rec.nominated_course_cd,
			   p_seq => c_all_records_case_4_rec.sequence_number,
			   p_message =>'IGS_AD_APPL_CANNOT_WITHDRAW');
              ELSE
                IF TRUNC(c_cal_abs_val_rec.absolute_value)<=TRUNC(SYSDATE) THEN
                  update_appl_inst(c_all_records_case_4_rec);
                END IF;
	      END IF;
            CLOSE c_cal_abs_val;
	  END LOOP;
	END IF;
EXCEPTION
   WHEN OTHERS THEN
     retcode:=2;
     ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
     Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;
END prc_suspend_adm_appl;

END IGS_AD_SUSPEND_APPL_PKG;

/
