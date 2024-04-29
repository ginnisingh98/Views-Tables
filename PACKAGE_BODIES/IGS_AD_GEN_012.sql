--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_012
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_012" AS
/* $Header: IGSAD12B.pls 120.3 2005/10/18 02:48:39 appldev ship $ */

/******************************************************************
Change History
Who       When          What
sjlaport  18-FEB-2005   Removed function get_inq_stat_id for IGR Migration. Bug 4114493
sarakshi  23-Nov-2004   Bug#4027591, removed outermost exception such that masking of the message does not happen in admp_upd_acai_comm.
cdcruz    feb18         bug 2217104 Admit to future term Enhancement,updated tbh call for
                        new columns being added to IGS_AD_PS_APPL_INST
nshee     29-Aug-2002   Bug 2395510 DEferments build Added 6 columns in update row call
rboddu    13-FEB-2003   removed PROCEDURE Admp_Upd_Eap_Avail. Moved this to
                        igs_rc_gen_001 package. Bug:2664699
********************************************************************/

FUNCTION Admp_Upd_Acai_Comm(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_prpsd_commencement_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

    -- This module updates the IGS_AD_PS_APPL_INST.prpsd_commencement_dt.

    v_adm_appl_status   IGS_AD_APPL.adm_appl_status%TYPE;
        v_dummy             VARCHAR2(1);
        v_message_name      VARCHAR2(30);
        v_update_non_enrol_detail_ind   VARCHAR2(1);
        CURSOR  c_acai IS
                SELECT  ROWID, acai.*
                FROM    IGS_AD_PS_APPL_INST acai
                WHERE   acai.person_id                  = p_person_id                   AND
                        acai.admission_appl_number      = p_admission_appl_number       AND
                        acai.nominated_course_cd        = p_nominated_course_cd         AND
                        acai.sequence_number            = p_acai_sequence_number
                FOR UPDATE OF acai.prpsd_commencement_dt NOWAIT;
        CURSOR  c_aa IS
                SELECT  aa.adm_appl_status
                FROM    IGS_AD_APPL aa
                WHERE   aa.person_id                    = p_person_id AND
                        aa.admission_appl_number        = p_admission_appl_number;
        e_resource_busy_exception               EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
        Rec_IGS_AD_PS_APPL_Inst         c_acai%RowType;
BEGIN
        /*
          ||  Change History :
          ||  Who             When            What
          ||  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
          ||  rrengara      26-JUL-2001     Bug Enh No: 1891835 : For the DLD Process Student Response to Offer. Added two columns in TBH
          ||  (reverse chronological order - newest change first)
        */

        OPEN c_acai;
--      FETCH c_acai INTO v_dummy;
        FETCH c_acai INTO Rec_IGS_AD_PS_APPL_Inst;
        IF c_acai%NOTFOUND THEN
                --Invalid parameters
                CLOSE c_acai;
                p_message_name := null;
                RETURN TRUE;
        END IF;
        OPEN c_aa;
        FETCH c_aa INTO v_adm_appl_status;
        CLOSE c_aa;
        -- Validate if the commencement date can be updated.
        IF IGS_AD_VAL_ACAI.admp_val_acai_update (
                        v_adm_appl_status,
                        p_person_id,
                        p_admission_appl_number,
                        p_nominated_course_cd,
                        p_acai_sequence_number,
                        v_message_name,
                        v_update_non_enrol_detail_ind) = FALSE THEN

		-- begin apadegal adtd001 igs.m

   		-- PRPSD_COMMENCEMENT_DT can be udpated in proceed phase
		IF ( v_message_name = 'IGS_AD_APPL_INST_COMPL')
		THEN


		     IF  igs_ad_gen_002.check_adm_appl_inst_stat(   p_person_id             => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID ,
								    p_admission_appl_number => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER ,
								    p_nominated_course_cd   => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD ,
								    p_sequence_number       => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER ,
								    p_updateable            => 'Y'
								    )='N'	    --- not updateable.. so throw error
		    THEN
			p_message_name := 'IGS_AD_APPL_INST_COMPL';
		        RETURN FALSE;
		    END IF;
		ELSE
		--end apadegal adtd001 igs.m
		   p_message_name := v_message_name;
		   RETURN FALSE;
		END IF;
        END IF;
        IGS_AD_PS_APPL_Inst_Pkg.UPDATE_ROW (
                X_ROWID                                         => Rec_IGS_AD_PS_APPL_Inst.ROWID ,
                X_PERSON_ID                                     => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID ,
                X_ADMISSION_APPL_NUMBER                         => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER ,
                X_NOMINATED_COURSE_CD                           => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD ,
                X_SEQUENCE_NUMBER                               => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER ,
                X_PREDICTED_GPA                                 => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA ,
                X_ACADEMIC_INDEX                                => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
                X_ADM_CAL_TYPE                                  => Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE ,
                X_APP_FILE_LOCATION                             => Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION ,
                X_ADM_CI_SEQUENCE_NUMBER                        => Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER ,
                X_COURSE_CD                                     => Rec_IGS_AD_PS_APPL_Inst.COURSE_CD ,
                X_APP_SOURCE_ID                                 => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID ,
                X_CRV_VERSION_NUMBER                            => Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER ,
                X_Waitlist_Rank                                 => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
                X_LOCATION_CD                                   => Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD ,
                X_Attent_Other_Inst_Cd                          => Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
                X_ATTENDANCE_MODE                               => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE ,
                X_Edu_Goal_Prior_Enroll_Id                      => Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
                X_ATTENDANCE_TYPE                               => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE ,
                X_Decision_Make_Id                              => Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
                X_UNIT_SET_CD                                   => Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD ,
                X_Decision_Date                                 => Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
                X_Attribute_Category                            => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
                X_Attribute1                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute1,
                X_Attribute2                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
                X_Attribute3                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
                X_Attribute4                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
                X_Attribute5                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute5,
                X_Attribute6                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute6,
                X_Attribute7                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute7,
                X_Attribute8                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
                X_Attribute9                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
                X_Attribute10                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
                X_Attribute11                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute11,
                X_Attribute12                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute12,
                X_Attribute13                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute13,
                X_Attribute14                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
                X_Attribute15                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
                X_Attribute16                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
                X_Attribute17                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
                X_Attribute18                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute18,
                X_Attribute19                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute19,
                X_Attribute20                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute20,
                X_Decision_Reason_Id                            => Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
                X_US_VERSION_NUMBER                             => Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER ,
                X_Decision_Notes                                => Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
                X_Pending_Reason_Id                             => Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
                X_PREFERENCE_NUMBER                             => Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER ,
                X_ADM_DOC_STATUS                                => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS ,
                X_ADM_ENTRY_QUAL_STATUS                         => Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS ,
                X_DEFICIENCY_IN_PREP                            => Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP ,
                X_LATE_ADM_FEE_STATUS                           => Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS ,
                X_Spl_Consider_Comments                         => Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
                X_Apply_For_Finaid                              => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
                X_Finaid_Apply_Date                             => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
                X_ADM_OUTCOME_STATUS                            => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS ,
                X_ADM_OTCM_STAT_AUTH_PER_ID                     => Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID ,
                X_ADM_OUTCOME_STATUS_AUTH_DT                    => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT ,
                X_ADM_OUTCOME_STATUS_REASON                     => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON ,
                X_OFFER_DT                                      => Rec_IGS_AD_PS_APPL_Inst.OFFER_DT ,
                X_OFFER_RESPONSE_DT                             => Rec_IGS_AD_PS_APPL_Inst.OFFER_RESPONSE_DT ,
                X_PRPSD_COMMENCEMENT_DT                         => p_prpsd_commencement_dt ,
                X_ADM_CNDTNL_OFFER_STATUS                       => Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS ,
                X_CNDTNL_OFFER_SATISFIED_DT                     => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT ,
                X_CNDNL_OFR_MUST_BE_STSFD_IND                   => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND ,
                X_ADM_OFFER_RESP_STATUS                         => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_RESP_STATUS ,
                X_ACTUAL_RESPONSE_DT                            => Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT ,
                X_ADM_OFFER_DFRMNT_STATUS                       => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS ,
                X_DEFERRED_ADM_CAL_TYPE                         => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE ,
                X_DEFERRED_ADM_CI_SEQUENCE_NUM                  => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM  ,
                X_DEFERRED_TRACKING_ID                          => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID ,
                X_ASS_RANK                                      => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK ,
                X_SECONDARY_ASS_RANK                            => Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK ,
                X_INTR_ACCEPT_ADVICE_NUM                        => Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM  ,
                X_ASS_TRACKING_ID                               => Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID ,
                X_FEE_CAT                                       => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT ,
                X_HECS_PAYMENT_OPTION                           => Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION ,
                X_EXPECTED_COMPLETION_YR                        => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR ,
                X_EXPECTED_COMPLETION_PERD                      => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD ,
                X_CORRESPONDENCE_CAT                            => Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT ,
                X_ENROLMENT_CAT                                 => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT ,
                X_FUNDING_SOURCE                                => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE ,
                X_APPLICANT_ACPTNCE_CNDTN                       => Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN ,
                X_CNDTNL_OFFER_CNDTN                            => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN ,
                X_SS_APPLICATION_ID                             => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID ,
                X_SS_PWD                                        => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
                X_AUTHORIZED_DT                                 => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,  -- BUG ENH NO : 1891835 Added this column in table
                X_AUTHORIZING_PERS_ID                           => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,  -- BUG ENH NO : 1891835 Added this column in table
                X_IDX_CALC_DATE                                 => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
                X_WAITLIST_STATUS                               => Rec_IGS_AD_PS_APPL_Inst.WAITLIST_STATUS, -- BUG # 2097333
                X_ENTRY_STATUS                                  => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,  -- Bug # 1905651
                X_ENTRY_LEVEL                                   => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,  -- Bug # 1905651
                X_SCH_APL_TO_ID                                 => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID, -- Bug # 1905651
                X_FUT_ACAD_CAL_TYPE                          => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                X_FUT_ACAD_CI_SEQUENCE_NUMBER                => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                X_FUT_ADM_CAL_TYPE                           => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                X_FUT_ADM_CI_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                X_PREV_TERM_ADM_APPL_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_PREV_TERM_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_FUT_TERM_ADM_APPL_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_FUT_TERM_SEQUENCE_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_DEF_ACAD_CAL_TYPE                                        => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                X_DEF_ACAD_CI_SEQUENCE_NUM                   => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                X_DEF_PREV_TERM_ADM_APPL_NUM           => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_PREV_APPL_SEQUENCE_NUM              => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
                X_DEF_TERM_ADM_APPL_NUM                        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_APPL_SEQUENCE_NUM                           => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
                X_MODE                                          => 'R',
                X_Attribute21                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                X_Attribute22                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                X_Attribute23                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                X_Attribute24                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                X_Attribute25                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                X_Attribute26                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                X_Attribute27                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                X_Attribute28                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                X_Attribute29                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                X_Attribute30                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                X_Attribute31                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                X_Attribute32                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                X_Attribute33                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                X_Attribute34                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                X_Attribute35                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                X_Attribute36                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                X_Attribute37                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                X_Attribute38                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                X_Attribute39                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                X_Attribute40                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
		X_APPL_INST_STATUS				=> Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
		x_ais_reason					=> Rec_IGS_AD_PS_APPL_Inst.ais_reason,
		x_decline_ofr_reason				=> Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason
                );

        CLOSE c_acai;
        p_message_name := null;
        RETURN TRUE;
EXCEPTION
        WHEN e_resource_busy_exception THEN
                IF (c_acai%ISOPEN) THEN
                        CLOSE c_acai;
                END IF;
                IF (c_aa%ISOPEN) THEN
                        CLOSE c_aa;
                END IF;
                p_message_name := 'IGS_AD_NOTUPD_LOCKED_ANOTHUSR';
                RETURN FALSE;
        WHEN OTHERS THEN
                IF (c_acai%ISOPEN) THEN
                        CLOSE c_acai;
                END IF;
                IF (c_aa%ISOPEN) THEN
                        CLOSE c_aa;
                END IF;
                APP_EXCEPTION.RAISE_EXCEPTION;
END admp_upd_acai_comm;

PROCEDURE Admp_Upd_Acai_Defer(
  p_log_creation_dt OUT NOCOPY DATE )
IS
BEGIN
/******************************************************************
The code has been commented out NOCOPY completely becuase of the obsoletion of the Job IGSADS06 report as a part of DLD_DEFERMETNT_CHAGES_2395510
According the obsoletion process we need to remove all the code and put only NULL.
Done By rrengara on 20-SEP-2002  for Bug 2563941 (D) 2395510 (P)
***************************/
  NULL;
END admp_upd_acai_defer;

PROCEDURE Admp_Upd_Acai_Lapsed(
        errbuf OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER,
        p_org_id IN NUMBER)
IS
        gv_other_detail         VARCHAR2(255);
   -- admp_upd_acai_lapsed
        -- This module updates all IGS_AD_PS_APPL_INST.adm_offer_resp_status to
        -- lapsed if the applicant has not responded to an offer in the appropriate
        -- time. This will be run nightly by the Job Scheduler.

	e_resource_busy                 EXCEPTION;
        PRAGMA  EXCEPTION_INIT(e_resource_busy, -54);
        cst_offer       CONSTANT        VARCHAR2(5) := 'OFFER';
        cst_cond_offer  CONSTANT        VARCHAR2(10) := 'COND-OFFER';
        cst_pending     CONSTANT        VARCHAR2(7) := 'PENDING';
        cst_lapsed      CONSTANT        VARCHAR2(6) := 'LAPSED';
        v_adm_offer_resp_status         IGS_AD_PS_APPL_INST.adm_offer_resp_status%TYPE;

    CURSOR c_update_acai IS
          SELECT  acai.ROWID, acai.*
          FROM    IGS_AD_PS_APPL_INST     acai
          WHERE   EXISTS (SELECT 'x' from igs_ad_ou_stat  aos
                          WHERE   aos.adm_outcome_status = acai.adm_outcome_status
                          AND     aos.s_adm_outcome_status IN ( cst_offer, cst_cond_offer))
          AND     EXISTS (SELECT 'x' FROM igs_ad_ofr_resp_stat  aors
                          WHERE   aors.adm_offer_resp_status = acai.adm_offer_resp_status
                          AND     aors.s_adm_offer_resp_status    = cst_pending
                          AND     acai.offer_response_dt < TRUNC(SYSDATE))
          FOR UPDATE OF acai.adm_offer_resp_status NOWAIT;

	  l_msg_data VARCHAR2(2000);

BEGIN

         /*
          ||  Change History :
          ||  Who             When            What
          ||  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
          ||  rrengara      26-JUL-2001     Bug Enh No: 1891835 : For the DLD Process Student Response to Offer. Added two columns in TBH
          ||  (reverse chronological order - newest change first)
        */

      retcode := 0;
      igs_ge_gen_003.set_org_id(p_org_id);

        -- Get default value for system offer response status LAPSED.
        v_adm_offer_resp_status := IGS_AD_GEN_009.admp_get_sys_aors(cst_lapsed);
        -- All admission course applications that are passed their offer response date
        -- should be lapsed.

        FOR Rec_IGS_AD_PS_APPL_Inst IN c_update_acai LOOP
        BEGIN
	IGS_AD_PS_APPL_Inst_Pkg.UPDATE_ROW (
                X_ROWID                                         => Rec_IGS_AD_PS_APPL_Inst.ROWID ,
                X_PERSON_ID                                     => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID ,
                X_ADMISSION_APPL_NUMBER                         => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER ,
                X_NOMINATED_COURSE_CD                           => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD ,
                X_SEQUENCE_NUMBER                               => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER ,
                X_PREDICTED_GPA                                 => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA ,
                X_ACADEMIC_INDEX                                => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
                X_ADM_CAL_TYPE                                  => Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE ,
                X_APP_FILE_LOCATION                             => Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION ,
                X_ADM_CI_SEQUENCE_NUMBER                        => Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER ,
                X_COURSE_CD                                     => Rec_IGS_AD_PS_APPL_Inst.COURSE_CD ,
                X_APP_SOURCE_ID                                 => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID ,
                X_CRV_VERSION_NUMBER                            => Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER ,
                X_Waitlist_Rank                                 => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
                X_Waitlist_Status                               => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
                X_LOCATION_CD                                   => Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD ,
                X_Attent_Other_Inst_Cd                          => Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
                X_ATTENDANCE_MODE                               => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE ,
                X_Edu_Goal_Prior_Enroll_Id                      => Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
                X_ATTENDANCE_TYPE                               => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE ,
                X_Decision_Make_Id                              => Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
                X_UNIT_SET_CD                                   => Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD ,
                X_Decision_Date                                 => Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
                X_Attribute_Category                            => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
                X_Attribute1                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute1,
                X_Attribute2                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
                X_Attribute3                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
                X_Attribute4                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
                X_Attribute5                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute5,
                X_Attribute6                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute6,
                X_Attribute7                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute7,
                X_Attribute8                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
                X_Attribute9                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
                X_Attribute10                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
                X_Attribute11                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute11,
                X_Attribute12                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute12,
                X_Attribute13                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute13,
                X_Attribute14                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
                X_Attribute15                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
                X_Attribute16                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
                X_Attribute17                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
                X_Attribute18                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute18,
                X_Attribute19                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute19,
                X_Attribute20                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute20,
                X_Decision_Reason_Id                            => Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
                X_US_VERSION_NUMBER                             => Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER ,
                X_Decision_Notes                                => Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
                X_Pending_Reason_Id                             => Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
                X_PREFERENCE_NUMBER                             => Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER ,
                X_ADM_DOC_STATUS                                => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS ,
                X_ADM_ENTRY_QUAL_STATUS                         => Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS ,
                X_DEFICIENCY_IN_PREP                            => Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP ,
                X_LATE_ADM_FEE_STATUS                           => Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS ,
                X_Spl_Consider_Comments                         => Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
                X_Apply_For_Finaid                              => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
                X_Finaid_Apply_Date                             => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
                X_ADM_OUTCOME_STATUS                            => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS ,
                X_ADM_OTCM_STAT_AUTH_PER_ID                     => Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID ,
                X_ADM_OUTCOME_STATUS_AUTH_DT                    => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT ,
                X_ADM_OUTCOME_STATUS_REASON                     => Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON ,
                X_OFFER_DT                                      => Rec_IGS_AD_PS_APPL_Inst.OFFER_DT ,
                X_OFFER_RESPONSE_DT                             => Rec_IGS_AD_PS_APPL_Inst.OFFER_RESPONSE_DT ,
                X_PRPSD_COMMENCEMENT_DT                         => Rec_IGS_AD_PS_APPL_Inst.Prpsd_Commencement_Dt,
                X_ADM_CNDTNL_OFFER_STATUS                       => Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS ,
                X_CNDTNL_OFFER_SATISFIED_DT                     => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT ,
                X_CNDNL_OFR_MUST_BE_STSFD_IND                   => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND ,
                X_ADM_OFFER_RESP_STATUS                         => v_adm_offer_resp_status,
                X_ACTUAL_RESPONSE_DT                            => Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT ,
                X_ADM_OFFER_DFRMNT_STATUS                       => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS ,
                X_DEFERRED_ADM_CAL_TYPE                         => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE ,
                X_DEFERRED_ADM_CI_SEQUENCE_NUM                  => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM  ,
                X_DEFERRED_TRACKING_ID                          => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID ,
                X_ASS_RANK                                      => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK ,
                X_SECONDARY_ASS_RANK                            => Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK ,
                X_INTR_ACCEPT_ADVICE_NUM                        => Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM  ,
                X_ASS_TRACKING_ID                               => Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID ,
                X_FEE_CAT                                       => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT ,
                X_HECS_PAYMENT_OPTION                           => Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION ,
                X_EXPECTED_COMPLETION_YR                        => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR ,
                X_EXPECTED_COMPLETION_PERD                      => Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD ,
                X_CORRESPONDENCE_CAT                            => Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT ,
                X_ENROLMENT_CAT                                 => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT ,
                X_FUNDING_SOURCE                                => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE ,
                X_APPLICANT_ACPTNCE_CNDTN                       => Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN ,
                X_CNDTNL_OFFER_CNDTN                            => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN ,
                X_SS_APPLICATION_ID                             => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID ,
                X_SS_PWD                                        => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
                X_AUTHORIZED_DT                                 => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,  -- BUG ENH NO : 1891835 Added this column in table
                X_AUTHORIZING_PERS_ID                           => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,  -- BUG ENH NO : 1891835 Added this column in table
                X_IDX_CALC_DATE                                 => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
                X_ENTRY_STATUS                                  => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,  -- Bug # 1905651
                X_ENTRY_LEVEL                                   => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,  -- Bug # 1905651
                X_SCH_APL_TO_ID                                 => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID, -- Bug # 1905651
                X_FUT_ACAD_CAL_TYPE                          => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                X_FUT_ACAD_CI_SEQUENCE_NUMBER                => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                X_FUT_ADM_CAL_TYPE                           => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                X_FUT_ADM_CI_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                X_PREV_TERM_ADM_APPL_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_PREV_TERM_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_FUT_TERM_ADM_APPL_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_FUT_TERM_SEQUENCE_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_DEF_ACAD_CAL_TYPE                                        => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                X_DEF_ACAD_CI_SEQUENCE_NUM                   => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                X_DEF_PREV_TERM_ADM_APPL_NUM           => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_PREV_APPL_SEQUENCE_NUM              => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
                X_DEF_TERM_ADM_APPL_NUM                        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_APPL_SEQUENCE_NUM                           => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
                X_MODE                                          => 'R',
                X_Attribute21                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                X_Attribute22                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                X_Attribute23                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                X_Attribute24                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                X_Attribute25                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                X_Attribute26                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                X_Attribute27                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                X_Attribute28                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                X_Attribute29                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                X_Attribute30                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                X_Attribute31                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                X_Attribute32                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                X_Attribute33                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                X_Attribute34                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                X_Attribute35                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                X_Attribute36                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                X_Attribute37                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                X_Attribute38                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                X_Attribute39                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                X_Attribute40                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
		X_APPL_INST_STATUS				=> Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
		x_ais_reason					=> Rec_IGS_AD_PS_APPL_Inst.ais_reason,
		x_decline_ofr_reason				=> Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason

                );
        EXCEPTION
        WHEN e_resource_busy THEN
          RAISE;
        WHEN OTHERS THEN
             fnd_file.put_line(fnd_file.log, 'Failed to update Offer Response Status to LAPSED for Person ID: '|| Rec_IGS_AD_PS_APPL_Inst.PERSON_ID || '; Admission Application Number: ' ||
		                                    Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER || '; Course Code: ' || Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD || '; Sequence Number: '||
                                                    Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER  );
              l_msg_data := FND_MESSAGE.GET;
              IF l_msg_data is not null THEN
  	        FND_FILE.PUT_LINE(FND_FILE.LOG, ' Reason: ' || l_msg_data);
	      END IF;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '');
	      l_msg_data := null;
        END;

        END LOOP;

	IF c_update_acai%ISOPEN THEN
		CLOSE c_update_acai;
	END IF;

        COMMIT;

EXCEPTION
        WHEN e_resource_busy THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRGAPPL_NOT_LAPSED');
                FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
        WHEN OTHERS THEN
                IF c_update_acai%ISOPEN THEN
                        CLOSE c_update_acai;
                END IF;

		retcode := 2;
                errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END admp_upd_acai_lapsed;

PROCEDURE Admp_Upd_Acai_Recon(
  p_log_creation_dt OUT NOCOPY DATE )
IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- admp_upd_acai_recon
        -- Routine to update a IGS_AD_PS_APPL_INST when the admission
        -- course application made a request for reconsideration, and the
        -- outcome of the course application was REJECTED, NO-QUOTA.
        -- This procedure will be triggered nightly for relevant date ranges
        -- in the year, by the Job Scheduler
  DECLARE
        e_resource_busy_exception               EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
        cst_pending             CONSTANT VARCHAR2(10) := 'PENDING';
        cst_not_applic          CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
        cst_rejected            CONSTANT VARCHAR2(10) := 'REJECTED';
        cst_no_quota            CONSTANT VARCHAR2(10) := 'NO-QUOTA';
        cst_adm_recon           CONSTANT VARCHAR2(10) := 'ADM-RECON';
        CURSOR c_daiv IS
                SELECT  daiv.cal_type,
                        daiv.ci_sequence_number,
                        ci.start_dt
                FROM    IGS_CA_DA_INST_V        daiv,
                        IGS_CA_INST             ci,
                        IGS_AD_CAL_CONF                 sacco
                WHERE   sacco.s_control_num     = 1 AND
                        daiv.dt_alias           = sacco.initialise_adm_perd_dt_alias AND
                        daiv.alias_val          = TRUNC(SYSDATE) AND
                        daiv.cal_type           = ci.cal_type AND
                        daiv.ci_sequence_number = ci.sequence_number
                ORDER BY
                        ci.start_dt;
        CURSOR c_apapc (
                cp_adm_cal_type                 IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,
                cp_adm_ci_sequence_number       IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE) IS

          SELECT      aa.admission_cat,
                      aa.s_admission_process_type,
                      aa.person_id,
                      aa.admission_appl_number,
                      aa.appl_dt,
                      aca.nominated_course_cd
          FROM        IGS_AD_PS_APPL aca,
                      IGS_AD_APPL     aa
          WHERE       aa.person_id                    = aca.person_id
      AND         aa.admission_appl_number        = aca.admission_appl_number
      AND         aca.req_for_reconsideration_ind = 'Y'
      AND         EXISTS ( SELECT 'x' FROM igs_ad_prd_ad_prc_ca apapc
                               WHERE   apapc.adm_cal_type              = cp_adm_cal_type
                           AND     apapc.adm_ci_sequence_number    = cp_adm_ci_sequence_number
                   AND     apapc.admission_cat             = aa.admission_cat
                   AND     apapc.s_admission_process_type  = aa.s_admission_process_type
                   AND     apapc.closed_ind = 'N');

        CURSOR c_aca (
                cp_person_id                    IGS_AD_PS_APPL.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_PS_APPL.admission_appl_number%TYPE,
        cp_nominated_course_cd          IGS_AD_PS_APPL.nominated_course_cd%TYPE ) IS

                SELECT  ROWID, aca.*
                FROM    IGS_AD_PS_APPL aca
                WHERE   aca.person_id                   = cp_person_id AND
                        aca.admission_appl_number       = cp_admission_appl_number AND
                        aca.nominated_course_cd         = cp_nominated_course_cd
                FOR UPDATE OF aca.req_for_reconsideration_ind NOWAIT;

        Rec_IGS_AD_PS_APPL              c_aca%ROWTYPE;

        CURSOR c_acaiv (
                cp_start_dt                           IGS_CA_INST.start_dt%TYPE,
                cp_person_id                    IGS_AD_APPL.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_APPL.admission_appl_number%TYPE,
                cp_nominated_course_cd          IGS_AD_PS_APPL.nominated_course_cd%TYPE) IS
          SELECT        acaiv.person_id,
                        acaiv.admission_appl_number,
                        acaiv.nominated_course_cd,
                        acaiv.sequence_number,
                        acaiv.course_cd,
                        acaiv.crv_version_number,
                        aa.acad_cal_type,
            aa.acad_ci_sequence_number,
                        acaiv.attendance_type,
                        acaiv.attendance_mode,
                        acaiv.location_cd
          FROM          igs_ad_ps_appl_inst acaiv,
            igs_ad_appl aa
          WHERE         aa.person_id                    = acaiv.person_id
      AND           aa.admission_appl_number        = acaiv.admission_appl_number
      AND           acaiv.person_id                 = cp_person_id
      AND           acaiv.admission_appl_number     = cp_admission_appl_number
      AND           acaiv.nominated_course_cd       = cp_nominated_course_cd
      AND           EXISTS (SELECT 'x' FROM igs_ad_ou_stat  aos
                                WHERE  aos.adm_outcome_status = acaiv.adm_outcome_status
                AND    aos.s_adm_outcome_status IN (cst_rejected, cst_no_quota))
                AND    EXISTS (SELECT 'x' FROM igs_ca_inst  ci
                                WHERE  ci.cal_type                     = NVL (acaiv.adm_cal_type,aa.adm_cal_type)
                AND    ci.sequence_number              = NVL (acaiv.adm_ci_sequence_number,aa.adm_ci_sequence_number)
                AND    ci.start_dt                     < cp_start_dt);


        CURSOR c_acai (
                cp_person_id                    IGS_AD_PS_APPL_INST.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                cp_nominated_course_cd          IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
                cp_sequence_number              IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
                SELECT  acai.ROWID, acai.*
                FROM    IGS_AD_PS_APPL_INST acai
                WHERE   acai.person_id                  = cp_person_id AND
                        acai.admission_appl_number      = cp_admission_appl_number AND
                        acai.nominated_course_cd        = cp_nominated_course_cd AND
                        acai.sequence_number            = cp_sequence_number
                FOR UPDATE  OF
                                acai.adm_cal_type,
                                acai.adm_ci_sequence_number,
                                acai.late_adm_fee_status,
                                acai.adm_outcome_status,
                                acai.offer_dt,
                                acai.offer_response_dt,
                                acai.adm_cndtnl_offer_status,
                                acai.cndtnl_offer_satisfied_dt,
                                acai.cndtnl_offer_cndtn,
                                acai.ass_tracking_id,
                                acai.ass_rank,
                                acai.secondary_ass_rank,
                                acai.adm_otcm_status_auth_person_id,
                                acai.adm_outcome_status_auth_dt,
                                acai.adm_outcome_status_reason,
                                acai.expected_completion_perd,
                                acai.expected_completion_yr NOWAIT;

    Rec_IGS_AD_PS_APPL_Inst                 c_acai%ROWTYPE;
        v_creation_dt                   DATE;
        v_message_name  varchar2(30);
        v_log_message_name  varchar2(30);
        v_return_type                   VARCHAR2(1);
        v_late_ind                      VARCHAR2(1);
        v_aca_exists                    VARCHAR2(1);
        v_acai_exists                   VARCHAR2(1);
        v_acai_updated                  VARCHAR2(1)     DEFAULT 'N';
        v_adm_outcome_status            IGS_AD_OU_STAT.adm_outcome_status%TYPE;
        v_adm_cndtnl_offer_status       IGS_AD_CNDNL_OFRSTAT.adm_cndtnl_offer_status%TYPE;
        v_late_adm_fee_status           IGS_AD_FEE_STAT.adm_fee_status%TYPE;
        v_crv_version_number            NUMBER;
        v_course_start_dt                     IGS_CA_DA_INST_V.alias_val%TYPE;
        v_expected_completion_yr        IGS_AD_PS_APPL_INST.expected_completion_yr%TYPE;
        v_expected_completion_perd
                                IGS_AD_PS_APPL_INST.expected_completion_perd%TYPE;
        v_completion_dt                 DATE;
BEGIN
         /*
          ||  Change History :
          ||  Who             When            What
          ||  knag          29-OCT-2002     Bug 2647482 - added parameters attendance_mode, location_cd for proposed completion date calculation
          ||  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
          ||  rrengara      26-JUL-2001     Bug Enh No: 1891835 : For the DLD Process Student Response to Offer. Added two columns in TBH
          ||  (reverse chronological order - newest change first)
        */

        -- Determine if it is time to process reconsiderations.
        FOR v_daiv_rec IN c_daiv LOOP
                IF c_daiv%ROWCOUNT = 1 THEN
                        -- Insert log for exception reporting
                        IGS_GE_GEN_003.genp_ins_log(
                                cst_adm_recon,
                                NULL,
                                v_creation_dt);
                        p_log_creation_dt := v_creation_dt;
                        -- Get user default for pending outcome status and not
                        -- applicable conditional Offer status, late fee status
                        v_adm_outcome_status := IGS_AD_GEN_009.admp_get_sys_aos(
                                                                cst_pending);
                        v_adm_cndtnl_offer_status := IGS_AD_GEN_009.admp_get_sys_acos(
                                                                cst_not_applic);
                        v_late_adm_fee_status := IGS_AD_GEN_009.admp_get_sys_afs(
                                                                cst_not_applic);
                END IF;
                -- Find each admission process category for this admission period
                -- Find previous admission application with "Reconsiderations" not yet
                -- processed
                FOR v_apapc_rec IN c_apapc (
                                        v_daiv_rec.cal_type,
                                        v_daiv_rec.ci_sequence_number) LOOP
                        BEGIN   -- lock_block A
                                -- Check that record (IGS_AD_PS_APPL) can be locked prior to update
                        SAVEPOINT sp_aca;
                        OPEN c_aca(
                                v_apapc_rec.person_id,
                                v_apapc_rec.admission_appl_number,
                v_apapc_rec.nominated_course_cd);
--                      FETCH c_aca INTO v_aca_exists;
                        FETCH c_aca INTO Rec_IGS_AD_PS_APPL;
                        IF c_aca%FOUND THEN
                                -- Reset the ACAI updated indicator.
                                v_acai_updated := 'N';
                                FOR v_acaiv_rec IN c_acaiv(
                                                        v_daiv_rec.start_dt,
                                                        v_apapc_rec.person_id,
                                                        v_apapc_rec.admission_appl_number,
                                                        v_apapc_rec.nominated_course_cd) LOOP

                      -- Validate the admission calendar.
                                        IF IGS_AD_VAL_AA.admp_val_aa_adm_cal(
                                                                        v_daiv_rec.cal_type,
                                                                        v_daiv_rec.ci_sequence_number,                                                                  v_acaiv_rec.acad_cal_type,
                                                                        v_acaiv_rec.acad_ci_sequence_number,
                                                                        v_apapc_rec.admission_cat,
                                                                        v_apapc_rec.s_admission_process_type,
                                                                        v_message_name) THEN
-- the following section/block was not indented for
-- readability.
                                        -- Validate the course application in the new admission period
                                        IF NOT IGS_AD_VAL_ACAI.admp_val_acai_course(
                                                                        v_acaiv_rec.course_cd,
                                                                        v_acaiv_rec.crv_version_number,
                                                                        v_apapc_rec.admission_cat,
                                                                        v_apapc_rec.s_admission_process_type,
                                                                        v_acaiv_rec.acad_cal_type,
                                                                        v_acaiv_rec.acad_ci_sequence_number,
                                                                        v_daiv_rec.cal_type,
                                                                        v_daiv_rec.ci_sequence_number,
                                                                        v_apapc_rec.appl_dt,
                                                                        'Y',
                                                                        'N',
                                                                        v_crv_version_number,
                                                                        v_message_name,
                                                                        v_return_type) THEN
                                                v_log_message_name := v_message_name;
                                        ELSE
                                                v_log_message_name := NULL;
                                                BEGIN   -- lock_block B
                                                OPEN c_acai(
                                                        v_acaiv_rec.person_id,
                                                        v_acaiv_rec.admission_appl_number,
                                                        v_acaiv_rec.nominated_course_cd,
                                                        v_acaiv_rec.sequence_number);
--                                              FETCH c_acai INTO v_acai_exists;
                                                FETCH c_acai INTO Rec_IGS_AD_PS_APPL_Inst;
                                                IF c_acai%FOUND THEN
                                                        -- Derive the expected completion details
                                                        v_course_start_dt := IGS_AD_GEN_005.admp_get_crv_strt_dt(
                                                                                        v_daiv_rec.cal_type,
                                                                                        v_daiv_rec.ci_sequence_number);
                                                        IGS_AD_GEN_004.admp_get_crv_comp_dt (
                                                                        v_acaiv_rec.course_cd,
                                                                        v_acaiv_rec.crv_version_number,
                                                                        v_acaiv_rec.acad_cal_type,
                                                                        v_acaiv_rec.attendance_type,
                                                                        v_course_start_dt,
                                                                        v_expected_completion_yr,
                                                                        v_expected_completion_perd,
                                                                        v_completion_dt,
                                                                        v_acaiv_rec.attendance_mode,
                                                                        v_acaiv_rec.location_cd);
                                                        -- Update this record (IGS_AD_PS_APPL_INST)

        IGS_AD_PS_APPL_Inst_Pkg.UPDATE_ROW (
                X_ROWID                                         => Rec_IGS_AD_PS_APPL_Inst.ROWID ,
                X_PERSON_ID                                     => Rec_IGS_AD_PS_APPL_Inst.PERSON_ID ,
                X_ADMISSION_APPL_NUMBER                         => Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER ,
                X_NOMINATED_COURSE_CD                           => Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD ,
                X_SEQUENCE_NUMBER                               => Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER ,
                X_PREDICTED_GPA                                 => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA ,
                X_ACADEMIC_INDEX                                => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
                X_Adm_Cal_Type                                  => v_daiv_rec.cal_type,
                X_APP_FILE_LOCATION                             => Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION ,
                X_Adm_Ci_Sequence_Number                        => v_daiv_rec.ci_sequence_number,
                X_COURSE_CD                                     => Rec_IGS_AD_PS_APPL_Inst.COURSE_CD ,
                X_APP_SOURCE_ID                                 => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID ,
                X_CRV_VERSION_NUMBER                            => Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER ,
                X_Waitlist_Rank                                 => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
                X_Waitlist_Status                               => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
                X_LOCATION_CD                                   => Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD ,
                X_Attent_Other_Inst_Cd                          => Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
                X_ATTENDANCE_MODE                               => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE ,
                X_Edu_Goal_Prior_Enroll_Id                      => Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
                X_ATTENDANCE_TYPE                               => Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE ,
                X_Decision_Make_Id                              => Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
                X_UNIT_SET_CD                                   => Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD ,
                X_Decision_Date                                 => Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
                X_Attribute_Category                            => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
                X_Attribute1                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute1,
                X_Attribute2                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
                X_Attribute3                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
                X_Attribute4                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
                X_Attribute5                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute5,
                X_Attribute6                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute6,
                X_Attribute7                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute7,
                X_Attribute8                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
                X_Attribute9                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
                X_Attribute10                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
                X_Attribute11                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute11,
                X_Attribute12                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute12,
                X_Attribute13                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute13,
                X_Attribute14                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
                X_Attribute15                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
                X_Attribute16                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
                X_Attribute17                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
                X_Attribute18                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute18,
                X_Attribute19                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute19,
                X_Attribute20                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute20,
                X_Decision_Reason_Id                            => Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
                X_US_VERSION_NUMBER                             => Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER ,
                X_Decision_Notes                                => Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
                X_Pending_Reason_Id                             => Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
                X_PREFERENCE_NUMBER                             => Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER ,
                X_ADM_DOC_STATUS                                => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS ,
                X_ADM_ENTRY_QUAL_STATUS                         => Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS ,
                X_DEFICIENCY_IN_PREP                            => Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP ,
                X_Late_Adm_Fee_Status                           => v_late_adm_fee_status,
                X_Spl_Consider_Comments                         => Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
                X_Apply_For_Finaid                              => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
                X_Finaid_Apply_Date                             => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
                X_Adm_Outcome_Status                            => v_adm_outcome_status,
                X_ADM_OTCM_STAT_AUTH_PER_ID                     => NULL,
                X_Adm_Outcome_Status_Auth_Dt                    => NULL,
                X_Adm_Outcome_Status_Reason                     => NULL,
                X_Offer_Dt                                      => NULL,
                X_Offer_Response_Dt                             => NULL,
                X_PRPSD_COMMENCEMENT_DT                         => Rec_IGS_AD_PS_APPL_Inst.prpsd_commencement_dt ,
                X_Adm_Cndtnl_Offer_Status                       => v_adm_cndtnl_offer_status,
                X_Cndtnl_Offer_Satisfied_Dt                     => NULL,
                X_CNDNL_OFR_MUST_BE_STSFD_IND                   => Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND ,
                X_ADM_OFFER_RESP_STATUS                         => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_RESP_STATUS ,
                X_ACTUAL_RESPONSE_DT                            => Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT ,
                X_ADM_OFFER_DFRMNT_STATUS                       => Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS ,
                X_DEFERRED_ADM_CAL_TYPE                         => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE ,
                X_DEFERRED_ADM_CI_SEQUENCE_NUM                  => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM  ,
                X_DEFERRED_TRACKING_ID                          => Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID ,
                X_ASS_RANK                                      => NULL,
                X_SECONDARY_ASS_RANK                            => NULL,
                X_INTR_ACCEPT_ADVICE_NUM                        => Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM  ,
                X_ASS_TRACKING_ID                               => NULL,
                X_FEE_CAT                                       => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT ,
                X_HECS_PAYMENT_OPTION                           => Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION ,
                X_EXPECTED_COMPLETION_YR                        => V_EXPECTED_COMPLETION_YR ,
                X_EXPECTED_COMPLETION_PERD                      => V_EXPECTED_COMPLETION_PERD ,
                X_CORRESPONDENCE_CAT                            => Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT ,
                X_ENROLMENT_CAT                                 => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT ,
                X_FUNDING_SOURCE                                => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE ,
                X_APPLICANT_ACPTNCE_CNDTN                       => Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN ,
                X_CNDTNL_OFFER_CNDTN                            => NULL ,
                X_SS_APPLICATION_ID                             => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID ,
                X_SS_PWD                                        => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
                X_AUTHORIZED_DT                                 => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,  -- BUG ENH NO : 1891835 Added this column in table
                X_AUTHORIZING_PERS_ID                           => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,  -- BUG ENH NO : 1891835 Added this column in table
                X_IDX_CALC_DATE                                 => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
                X_ENTRY_STATUS                                  => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,  -- Bug # 1905651
                X_ENTRY_LEVEL                                   => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,  -- Bug # 1905651
                X_SCH_APL_TO_ID                                 => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID, -- Bug # 1905651
                X_FUT_ACAD_CAL_TYPE                          => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                X_FUT_ACAD_CI_SEQUENCE_NUMBER                => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                X_FUT_ADM_CAL_TYPE                           => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                X_FUT_ADM_CI_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                X_PREV_TERM_ADM_APPL_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_PREV_TERM_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_FUT_TERM_ADM_APPL_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_FUT_TERM_SEQUENCE_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_DEF_ACAD_CAL_TYPE                                        => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                X_DEF_ACAD_CI_SEQUENCE_NUM                   => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                X_DEF_PREV_TERM_ADM_APPL_NUM           => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_PREV_APPL_SEQUENCE_NUM              => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
                X_DEF_TERM_ADM_APPL_NUM                        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_APPL_SEQUENCE_NUM                           => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
                X_MODE                                          => 'R',
                X_Attribute21                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                X_Attribute22                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                X_Attribute23                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                X_Attribute24                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                X_Attribute25                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                X_Attribute26                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                X_Attribute27                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                X_Attribute28                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                X_Attribute29                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                X_Attribute30                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                X_Attribute31                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                X_Attribute32                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                X_Attribute33                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                X_Attribute34                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                X_Attribute35                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                X_Attribute36                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                X_Attribute37                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                X_Attribute38                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                X_Attribute39                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                X_Attribute40                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
		X_APPL_INST_STATUS				=> Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
		x_ais_reason					=> Rec_IGS_AD_PS_APPL_Inst.ais_reason,
		x_decline_ofr_reason				=> Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason
                );
                v_acai_updated := 'Y';
                                                        CLOSE c_acai;
                                                        -- Update admission course application units
                                                        IGS_AD_UPD_INITIALISE.admp_upd_acaiu_init(
                                                                        v_acaiv_rec.person_id,
                                                                        v_acaiv_rec.admission_appl_number,
                                                                        v_acaiv_rec.nominated_course_cd,
                                                                        v_acaiv_rec.sequence_number,
                                                                        v_acaiv_rec.acad_cal_type,
                                                                        v_acaiv_rec.acad_ci_sequence_number,
                                                                        v_daiv_rec.cal_type,
                                                                        v_daiv_rec.ci_sequence_number,
                                                                        v_apapc_rec.s_admission_process_type,
                                                                        'N',
                                                                        cst_adm_recon,
                                                                        v_creation_dt);
                                                ELSE
                                                        CLOSE c_acai;
                                                END IF;
                                                EXCEPTION
                                                        WHEN e_resource_busy_exception THEN
                                                                v_log_message_name := 'IGS_AD_APPL_NOT_PROCESSED';
                                                        WHEN OTHERS THEN
                                                                IF c_acai%ISOPEN THEN
                                                                        CLOSE c_acai;
                                                                END IF;
                                                                ROLLBACK TO sp_aca;
                                                                APP_EXCEPTION.RAISE_EXCEPTION;
                                                END;    -- lock_block B
                                        END IF;
-- continues from unindented block.
                                        ELSE
                                                v_log_message_name := v_message_name;
                                        END IF;
                                        -- Insert into log for reporting
                                        IGS_GE_GEN_003.genp_ins_log_entry(
                                                        cst_adm_recon,
                                                        v_creation_dt,
                                                        (FND_NUMBER.NUMBER_TO_CANONICAL(v_acaiv_rec.person_id) || ',' ||
                                                        FND_NUMBER.NUMBER_TO_CANONICAL(v_acaiv_rec.admission_appl_number) || ',' ||
                                                        v_acaiv_rec.nominated_course_cd || ','  ||
                                                        FND_NUMBER.NUMBER_TO_CANONICAL(v_acaiv_rec.sequence_number)),
                                                        v_log_message_name,
                                                        ' ');
                                        -- Reset the log message number
                                        v_log_message_name := NULL;
                                END LOOP;       -- v_acaiv_rec
                                IF v_acai_updated = 'Y' THEN
                                IGS_AD_PS_APPL_Pkg.Update_Row (
                                        X_Mode                              => 'R',
                                        X_RowId                             => Rec_IGS_AD_PS_APPL.RowId,
                                        X_Person_Id                         => Rec_IGS_AD_PS_APPL.Person_Id,
                                        X_Admission_Appl_Number             => Rec_IGS_AD_PS_APPL.Admission_Appl_Number,
                                        X_Nominated_Course_Cd               => Rec_IGS_AD_PS_APPL.Nominated_Course_Cd,
                                        X_Transfer_Course_Cd                => Rec_IGS_AD_PS_APPL.Transfer_Course_Cd,
                                        X_Basis_For_Admission_Type          => Rec_IGS_AD_PS_APPL.Basis_For_Admission_Type,
                                        X_Admission_Cd                      => Rec_IGS_AD_PS_APPL.Admission_Cd,
                                        X_Course_Rank_Set                   => Rec_IGS_AD_PS_APPL.Course_Rank_Set,
                                        X_Course_Rank_Schedule              => Rec_IGS_AD_PS_APPL.Course_Rank_Schedule,
                                        X_Req_For_Reconsideration_Ind       => 'N',
                                        X_Req_For_Adv_Standing_Ind          => Rec_IGS_AD_PS_APPL.Req_For_Adv_Standing_Ind
                                );

                                END IF;
                                CLOSE c_aca;
                        ELSE
                                CLOSE c_aca;
                        END IF;
                        EXCEPTION
                                WHEN e_resource_busy_exception THEN
                                        v_log_message_name := 'IGS_AD_APPL_CURR_BEING_UPD';
                                                -- Insert into log for reporting
                                        IGS_GE_GEN_003.genp_ins_log_entry(
                                                        cst_adm_recon,
                                                        v_creation_dt,
                                                        (FND_NUMBER.NUMBER_TO_CANONICAL(v_apapc_rec.person_id) || ',' ||
                                                        FND_NUMBER.NUMBER_TO_CANONICAL(v_apapc_rec.admission_appl_number) || ',' ||
                                                        v_apapc_rec.nominated_course_cd || ','  ||
                                                        NULL),
                                                        v_log_message_name,
                                                        ' ');
                                        -- Reset the log message number
                                        v_log_message_name := NULL;
                                WHEN OTHERS THEN
                                        IF c_aca%ISOPEN THEN
                                                CLOSE c_aca;
                                        END IF;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END;    -- lock_block A
                        COMMIT;
                END LOOP;       -- v_apapc_rec
        END LOOP;       -- v_daiv_rec
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
                IF c_daiv%ISOPEN THEN
                        CLOSE c_daiv;
                END IF;
                IF c_apapc%ISOPEN THEN
                        CLOSE c_apapc;
                END IF;
                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;
                IF c_aca%ISOPEN THEN
                        CLOSE c_aca;
                END IF;
                IF c_acai%ISOPEN THEN
                        CLOSE c_acai;
                END IF;
                APP_EXCEPTION.RAISE_EXCEPTION;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.admp_upd_acai_recon');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_upd_acai_recon;

PROCEDURE Admp_Upd_Adm_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_adm_acad_cal_type IN VARCHAR2 ,
  p_adm_acad_ci_sequence_number IN NUMBER ,
  p_adm_adm_cal_type IN VARCHAR2 ,
  p_adm_adm_ci_sequence_number IN NUMBER ,
  p_adm_admission_cat IN VARCHAR2 ,
  p_adm_s_admission_process_type IN VARCHAR2 )
IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- admp_upd_adm_pp
        -- routine to update the admission values on the IGS_PE_PERS_PREFS table
DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA                  EXCEPTION_INIT(e_resource_busy, -54);
        CURSOR c_pp (
                        cp_pp_per_id    IN      IGS_PE_PERSON.person_id%TYPE)IS
--              SELECT  'x'
                SELECT  ROWID, pp.*
                FROM    IGS_PE_PERS_PREFS_ALL pp
                WHERE   pp.person_id = cp_pp_per_id
                FOR UPDATE OF enr_acad_cal_type NOWAIT;

        Rec_IGS_PE_PERS_PREFS           C_PP%ROWTYPE;
        v_person_id             IGS_PE_PERSON.person_id%TYPE;
        v_check                 CHAR;
    lv_rowid    VARCHAR2(25);
    l_org_id NUMBER(15);
BEGIN
        -- Select the person and then update or insert the Admission Person Preferences
        --  table
--      OPEN c_pe(
--              p_oracle_username);
--      FETCH c_pe INTO v_person_id;

         v_person_id := FND_GLOBAL.USER_ID;

        BEGIN -- sub-block
--              IF (c_pe%FOUND) THEN
                        OPEN c_pp (v_person_id);
--                      FETCH c_pp INTO v_check;

                        FETCH c_pp INTO Rec_IGS_PE_PERS_PREFS;

                        IF (c_pp%FOUND) THEN

                        IGS_PE_PERS_PREFS_Pkg.Update_Row (
                                X_Mode                              => 'R',
                                X_RowId                             => Rec_IGS_PE_PERS_PREFS.RowId,
                                X_Person_Id                         => Rec_IGS_PE_PERS_PREFS.Person_Id,
                                X_Enr_Acad_Cal_Type                 => Rec_IGS_PE_PERS_PREFS.Enr_Acad_Cal_Type,
                                X_Enr_Acad_Sequence_Number          => Rec_IGS_PE_PERS_PREFS.Enr_Acad_Sequence_Number,
                                X_Enr_Enrolment_Cat                 => Rec_IGS_PE_PERS_PREFS.Enr_Enrolment_Cat,
                                X_Enr_Enr_Method_Type               => Rec_IGS_PE_PERS_PREFS.Enr_Enr_Method_Type,
                                X_Adm_Acad_Cal_Type                 => p_adm_acad_cal_type,
                                X_Adm_Acad_Ci_Sequence_Number       => p_adm_acad_ci_sequence_number,
                                X_Adm_Adm_Cal_Type                  => p_adm_adm_cal_type,
                                X_Adm_Adm_Ci_Sequence_Number        => p_adm_adm_ci_sequence_number,
                                X_Adm_Admission_Cat                 => p_adm_admission_cat,
                                X_Adm_S_Admission_Process_Type      => p_adm_s_admission_process_type,
                                X_Enq_Acad_Cal_Type                 => Rec_IGS_PE_PERS_PREFS.Enq_Acad_Cal_Type,
                                X_Enq_Acad_Ci_Sequence_Number       => Rec_IGS_PE_PERS_PREFS.Enq_Acad_Ci_Sequence_Number,
                                X_Enq_Adm_Cal_Type                  => Rec_IGS_PE_PERS_PREFS.Enq_Adm_Cal_Type,
                                X_Enq_Adm_Ci_Sequence_Number        => Rec_IGS_PE_PERS_PREFS.Enq_Adm_Ci_Sequence_Number,
                                X_Server_Printer_Dflt               => Rec_IGS_PE_PERS_PREFS.Server_Printer_Dflt,
                                X_Allow_Stnd_Req_Ind                => Rec_IGS_PE_PERS_PREFS.Allow_Stnd_Req_Ind
                        );

                        ELSE
                         l_org_id := igs_ge_gen_003.get_org_id;
                        IGS_PE_PERS_PREFS_Pkg.Insert_Row (
                                X_Mode                              => 'R',
                                X_Org_Id                            => l_org_id,
                                X_RowId                             => lv_rowid,
                                X_Person_Id                         => v_person_id,
                                X_Enr_Acad_Cal_Type                 => Null,
                                X_Enr_Acad_Sequence_Number          => Null,
                                X_Enr_Enrolment_Cat                 => Null,
                                X_Enr_Enr_Method_Type               => Null,
                                X_Adm_Acad_Cal_Type                 => p_adm_acad_cal_type,
                                X_Adm_Acad_Ci_Sequence_Number       => p_adm_acad_ci_sequence_number,
                                X_Adm_Adm_Cal_Type                  => p_adm_adm_cal_type,
                                X_Adm_Adm_Ci_Sequence_Number        => p_adm_adm_ci_sequence_number,
                                X_Adm_Admission_Cat                 => p_adm_admission_cat,
                                X_Adm_S_Admission_Process_Type      => p_adm_s_admission_process_type,
                                X_Enq_Acad_Cal_Type                 => Null,
                                X_Enq_Acad_Ci_Sequence_Number       => Null,
                                X_Enq_Adm_Cal_Type                  => Null,
                                X_Enq_Adm_Ci_Sequence_Number        => Null,
                                X_Server_Printer_Dflt               => Null,
                                X_Allow_Stnd_Req_Ind                => 'N'
                        );


                        END IF;
                        COMMIT;
                        CLOSE c_pp;
        --      END IF;
        EXCEPTION
                WHEN e_resource_busy THEN
        --              CLOSE c_pe;
                        APP_EXCEPTION.RAISE_EXCEPTION;
        END; -- sub-block

        --CLOSE c_pe;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.admp_upd_adm_pp');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_upd_adm_pp;

PROCEDURE Admp_Upd_Enq_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_enq_acad_cal_type IN VARCHAR2 ,
  p_enq_acad_ci_sequence_number IN NUMBER ,
  p_enq_adm_cal_type IN VARCHAR2 ,
  p_enq_adm_ci_sequence_number IN NUMBER )
IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- admp_upd_enq_pp
        -- routine to update the enquiry values on the IGS_PE_PERS_PREFS table
DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA                  EXCEPTION_INIT(e_resource_busy, -54);
        CURSOR c_pp (
                        cp_pp_per_id    IN      IGS_PE_PERSON.person_id%TYPE)IS
--              SELECT  'x'
                SELECT  ROWID, pp.*
                FROM    IGS_PE_PERS_PREFS_ALL pp
                WHERE   pp.person_id = cp_pp_per_id
                FOR UPDATE OF enr_acad_cal_type NOWAIT;

        Rec_IGS_PE_PERS_PREFS           c_pp%ROWTYPE;
        v_person_id             IGS_PE_PERSON.person_id%TYPE;
        v_check                 CHAR;
        lv_rowid        VARCHAR2(25);
        l_org_id        NUMBER(15);
BEGIN
        -- Select the person and then update or insert the Admission Person Preferences
        --  table
        --OPEN c_pe(
        --      p_oracle_username);
        --FETCH c_pe INTO v_person_id;
        v_person_id := FND_GLOBAL.USER_ID;
        BEGIN -- sub-block
        --      IF (c_pe%FOUND) THEN
                        OPEN c_pp (v_person_id);
--                      FETCH c_pp INTO v_check;
                        FETCH c_pp INTO Rec_IGS_PE_PERS_PREFS;
                        IF (c_pp%FOUND) THEN

                        IGS_PE_PERS_PREFS_Pkg.Update_Row (
                                X_Mode                              => 'R',
                                X_RowId                             => Rec_IGS_PE_PERS_PREFS.RowId,
                                X_Person_Id                         => Rec_IGS_PE_PERS_PREFS.Person_Id,
                                X_Enr_Acad_Cal_Type                 => Rec_IGS_PE_PERS_PREFS.Enr_Acad_Cal_Type,
                                X_Enr_Acad_Sequence_Number          => Rec_IGS_PE_PERS_PREFS.Enr_Acad_Sequence_Number,
                                X_Enr_Enrolment_Cat                 => Rec_IGS_PE_PERS_PREFS.Enr_Enrolment_Cat,
                                X_Enr_Enr_Method_Type               => Rec_IGS_PE_PERS_PREFS.Enr_Enr_Method_Type,
                                X_Adm_Acad_Cal_Type                 => Rec_IGS_PE_PERS_PREFS.adm_acad_cal_type,
                                X_Adm_Acad_Ci_Sequence_Number       => Rec_IGS_PE_PERS_PREFS.adm_acad_ci_sequence_number,
                                X_Adm_Adm_Cal_Type                  => Rec_IGS_PE_PERS_PREFS.adm_adm_cal_type,
                                X_Adm_Adm_Ci_Sequence_Number        => Rec_IGS_PE_PERS_PREFS.adm_adm_ci_sequence_number,
                                X_Adm_Admission_Cat                 => Rec_IGS_PE_PERS_PREFS.adm_admission_cat,
                                X_Adm_S_Admission_Process_Type      => Rec_IGS_PE_PERS_PREFS.adm_s_admission_process_type,
                                X_Enq_Acad_Cal_Type                 => p_enq_acad_cal_type,
                                X_Enq_Acad_Ci_Sequence_Number       => p_enq_acad_ci_sequence_number,
                                X_Enq_Adm_Cal_Type                  => p_enq_adm_cal_type,
                                X_Enq_Adm_Ci_Sequence_Number        => p_enq_adm_ci_sequence_number,
                                X_Server_Printer_Dflt               => Rec_IGS_PE_PERS_PREFS.Server_Printer_Dflt,
                                X_Allow_Stnd_Req_Ind                => Rec_IGS_PE_PERS_PREFS.Allow_Stnd_Req_Ind
                        );

                        ELSE
                        l_org_id := igs_ge_gen_003.get_org_id;
                        IGS_PE_PERS_PREFS_Pkg.Insert_Row (
                                X_Mode                              => 'R',
                                X_org_id                            => l_org_id,
                                X_RowId                             => lv_rowid,
                                X_Person_Id                         => v_person_id,
                                X_Enr_Acad_Cal_Type                 => Null,
                                X_Enr_Acad_Sequence_Number          => Null,
                                X_Enr_Enrolment_Cat                 => Null,
                                X_Enr_Enr_Method_Type               => Null,
                                X_Adm_Acad_Cal_Type                 => Null,
                                X_Adm_Acad_Ci_Sequence_Number       => Null,
                                X_Adm_Adm_Cal_Type                  => Null,
                                X_Adm_Adm_Ci_Sequence_Number        => Null,
                                X_Adm_Admission_Cat                 => Null,
                                X_Adm_S_Admission_Process_Type      => Null,
                                X_Enq_Acad_Cal_Type                 => p_enq_acad_cal_type,
                                X_Enq_Acad_Ci_Sequence_Number       => p_enq_acad_ci_sequence_number,
                                X_Enq_Adm_Cal_Type                  => p_enq_adm_cal_type,
                                X_Enq_Adm_Ci_Sequence_Number        => p_enq_adm_ci_sequence_number,
                                X_Server_Printer_Dflt               => Null,
                                X_Allow_Stnd_Req_Ind                => 'N'
                        );


                        END IF;
                        COMMIT;
                        CLOSE c_pp;
        --      END IF;
        EXCEPTION
                WHEN e_resource_busy THEN
                        --CLOSE c_pe;
                        APP_EXCEPTION.RAISE_EXCEPTION;
        END; -- sub-block
        --CLOSE c_pe;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.admp_upd_enq_pp');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_upd_enq_pp;

FUNCTION Adms_Get_Acaiu_Uv(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 )
RETURN VARCHAR2 IS
    v_message_name  varchar2(30);
BEGIN
        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_uv (
                p_unit_cd,
                p_version_number,
                p_s_admission_process_type,
                p_offer_ind,
                v_message_name) = TRUE THEN
                --Unit  Offering Option Unit Version is valid
                Return 'Y';
        ELSE
                -- Unit Offering Unit Version is not valid
                Return 'N';
        END IF;
END adms_get_acaiu_uv;

FUNCTION ret_group_cd RETURN VARCHAR2 IS

    l_group_cd igs_pe_persid_group.group_cd%TYPE;

    FUNCTION ret_random RETURN VARCHAR2 IS

        --/* Linear congruential random number generator */
        --
        m constant number:=100000000;
        m1 constant number:=10000;
        b constant number:=31415821;
        --
        a number;
        --
        the_date date;
        days number;
        secs number;

        l_ret_char VARCHAR2(7);

        --/*-------------------------- mult ---------------------------*/
        --/* Private utility function */
        --
        FUNCTION mult(p in number, q in number) return number is
            p1 number;
            p0 number;
            q1 number;
            q0 number;
        BEGIN
            p1:=trunc(p/m1);
            p0:=mod(p,m1);
            q1:=trunc(q/m1);
            q0:=mod(q,m1);
            return(mod((mod(p0*q1+p1*q0,m1)*m1+p0*q0),m));
        END mult;   /* mult */

    BEGIN
        --/* package body random */
        --   /* Generate an initial seed "a" based on system date */
        --   /* (Must be connected to database.)                  */
        the_date:=sysdate;
        days:=IGS_GE_NUMBER.TO_NUM(to_char(the_date, 'J'));
        secs:=IGS_GE_NUMBER.TO_NUM(to_char(the_date, 'SSSSS'));
        a:=days*24*3600+secs;


        --   /* generate a random number and set it to be the new seed */
        a:=mod(mult(a,b)+1,m);

        a := a*10000000;
        a := floor (a);

        l_ret_char := LPAD ( FND_NUMBER.NUMBER_TO_CANONICAL ( a), 7, '*');

        RETURN l_ret_char;

    END ret_random;

    FUNCTION is_dup_grpcd_exists ( p_group_cd VARCHAR2) RETURN BOOLEAN
    IS
        CURSOR dup_group_cd_cur IS
        SELECT
            group_cd
            FROM
                igs_pe_persid_group
            WHERE
                group_cd = p_group_cd;

        l_dup_group_cd igs_pe_persid_group.group_cd%TYPE DEFAULT NULL;

    BEGIN

        OPEN dup_group_cd_cur;
        FETCH dup_group_cd_cur INTO l_dup_group_cd;
        CLOSE dup_group_cd_cur;

        IF l_dup_group_cd IS NOT NULL THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END is_dup_grpcd_exists;

BEGIN

    LOOP

        l_group_cd := ret_random();
        l_group_cd := 'ADM' || l_group_cd;

        IF NOT is_dup_grpcd_exists ( l_group_cd ) THEN
            RETURN l_group_cd;
        END IF;
    END LOOP;
END ret_group_cd;

--removed the function get_inq_stat_id for IGR migration (bug 2664699) sjlaport

END igs_ad_gen_012;

/
