--------------------------------------------------------
--  DDL for Package Body IGS_ADMAPPLICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ADMAPPLICATION_PUB" AS
/* $Header: IGSPAPPB.pls 120.16 2006/09/22 13:21:43 pbondugu noship $ */
G_PKG_NAME 	CONSTANT VARCHAR2 (30):='IGS_ADMAPPLICATION_PUB';

PROCEDURE check_length(p_param_name IN VARCHAR2, p_table_name IN VARCHAR2, p_param_length IN NUMBER) AS
 CURSOR c_col_length IS
  SELECT WIDTH , precision , column_type ,scale
  FROM FND_COLUMNS
  WHERE  table_id IN
    (SELECT TABLE_ID
     FROM FND_TABLES
     WHERE table_name = p_table_name AND APPLICATION_ID = 8405)
  AND column_name = p_param_name
  AND APPLICATION_ID = 8405;

  l_col_length  c_col_length%ROWTYPE;
begin
  OPEN 	c_col_length;
  FETCH   c_col_length INTO  l_col_length;
  CLOSE  c_col_length;
  IF l_col_length.column_type = 'V' AND p_param_length > l_col_length.width  THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.width);
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;


  ELSIF 	l_col_length.column_type ='N' AND p_param_length > (l_col_length.precision - l_col_length.scale) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       IF l_col_length.scale > 0 THEN
          FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision || ',' || l_col_length.scale);
       ELSE
          FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision );
       END IF;
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;


END check_length;

 --API
 PROCEDURE RECORD_ACADEMIC_INDEX(
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id             IN      NUMBER,
		    p_admission_appl_number IN      NUMBER,
		    p_nominated_program_cd   IN      VARCHAR2,
		    p_sequence_number       IN      NUMBER,
		    p_predicted_gpa         IN      NUMBER,
		    p_academic_index        IN      VARCHAR2,
		    p_calculation_date      IN      DATE
)
 AS
  l_api_version         CONSTANT    	NUMBER := '1.0';
  l_api_name  	    	CONSTANT    	VARCHAR2(30) := 'RECORD_ACADEMIC_INDEX';
  l_msg_index                           NUMBER;
  l_return_status                       VARCHAR2(1);
  l_hash_msg_name_text_type_tab         igs_ad_gen_016.g_msg_name_text_type_table;




-- All records selected from application Instance Tables

CURSOR c_acai (	p_person_id 	NUMBER,
                p_admission_appl_number	  NUMBER,
                p_nominated_course_cd	VARCHAR,
                p_sequence_number  NUMBER)	 IS
SELECT
    a.*
FROM
     igs_ad_ps_appl_inst a,
     igs_ad_ou_stat c
WHERE a.person_id = p_person_id
   AND a.admission_appl_number	= p_admission_appl_number
   AND a.nominated_course_cd	= p_nominated_course_cd
   AND a.sequence_number	= p_sequence_number
   AND a.adm_outcome_status    = c.adm_outcome_status
   AND c.s_adm_outcome_status  = 'PENDING';

  l_appl_inst_rec       c_acai%ROWTYPE;
-- DOC Status

/*   CURSOR c_doc_status(p_doc_status VARCHAR2) IS
   SELECT 'x'
   FROM	igs_ad_doc_stat
   WHERE s_adm_doc_status = 'SATISFIED'
   AND adm_doc_status = p_doc_status;
  l_doc_status c_doc_status%ROWTYPE;
*/
  l_academic_index    VARCHAR2(10);
  l_predicted_gpa     NUMBER;
  l_calculation_date  DATE;
 BEGIN
  l_msg_index   := 0;
     SAVEPOINT RECORD_ACADEMIC_INDEX_pub;
     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
     l_msg_index := igs_ge_msg_stack.count_msg;

-- Validate all the parameters for their length
-- PERSON_ID
     check_length('PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_person_id)));
-- P_ADMISSION_APPL_NUMBER
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_admission_appl_number)));
-- p_nominated_program_cd
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_PS_APPL_INST_ALL', length(p_nominated_program_cd));
-- P_SEQUENCE_NUMBER
     check_length('SEQUENCE_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_sequence_number)));
-- P_ACADEMIC_INDEX
     check_length('ACADEMIC_INDEX', 'IGS_AD_PS_APPL_INST_ALL', length(p_academic_index));
-- P_PREDICTED_GPA
     check_length('PREDICTED_GPA', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_predicted_gpa)));
-- END OF PARAMETER VALIDATIONS.


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


        OPEN C_ACAI(p_person_id,
               p_admission_appl_number,
               p_nominated_program_cd,
               p_sequence_number);

        FETCH c_acai INTO l_appl_inst_rec;

        IF c_acai%NOTFOUND THEN --If no application instance exists for this application
	                        --with s_adm_outcome_status  = 'PENDING'
        ROLLBACK TO RECORD_ACADEMIC_INDEX_pub;
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACDX_NO_APPL');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
	ELSIF c_acai%FOUND THEN
     	  ------------------------------
	  --Intialization of varable to handle G_MISS_CHAR/NUM/DATE
	  -------------------------------
	  IF  p_academic_index = FND_API.G_MISS_CHAR THEN
            l_academic_index := NULL;
          ELSE
            l_academic_index := NVL(p_academic_index, l_appl_inst_rec.academic_index);
          END IF;

	  IF p_predicted_gpa = FND_API.G_MISS_NUM THEN
	    l_predicted_gpa := NULL;
	  ELSE
	    l_predicted_gpa := 	NVL(p_predicted_gpa, l_appl_inst_rec.predicted_gpa);
	  END IF;

	  IF p_calculation_date = FND_API.G_MISS_DATE THEN
	    l_calculation_date := NULL;
	  ELSE
	    l_calculation_date := NVL(p_calculation_date, l_appl_inst_rec.idx_calc_date);
	  END IF;


           -- Fetch the documentation status
  --         OPEN c_doc_status(l_appl_inst_rec.adm_doc_status);
  --         FETCH c_doc_status INTO l_doc_status;
  --         IF c_doc_status%FOUND THEN
--             BEGIN
--	     FND_FILE.PUT_LINE(FND_FILE.LOG, 'E: Record found with SATISFIED STATUS');
               -- Call to update row
	                    igs_ad_ps_appl_inst_pkg.update_row(
                                             x_rowid                        => l_appl_inst_rec.row_id,
                                             x_person_id                    => l_appl_inst_rec.person_id,
                                             x_admission_appl_number        => l_appl_inst_rec.admission_appl_number,
                                             x_nominated_course_cd          => l_appl_inst_rec.nominated_course_cd,
                                             x_sequence_number              => l_appl_inst_rec.sequence_number,
                                             x_predicted_gpa                => l_predicted_gpa,
                                             x_academic_index              =>  l_academic_index,
                                             x_adm_cal_type                 => l_appl_inst_rec.adm_cal_type,
                                             x_app_file_location            => l_appl_inst_rec.app_file_location,
                                             x_adm_ci_sequence_number       => l_appl_inst_rec.adm_ci_sequence_number,
                                             x_course_cd                    => l_appl_inst_rec.course_cd,
                                             x_app_source_id                => l_appl_inst_rec.app_source_id,
                                             x_crv_version_number           => l_appl_inst_rec.crv_version_number,
                                             x_waitlist_rank                => l_appl_inst_rec.waitlist_rank,
                                             x_waitlist_status              => l_appl_inst_rec.waitlist_status,
                                             x_location_cd                  => l_appl_inst_rec.location_cd,
                                             x_attent_other_inst_cd         => l_appl_inst_rec.attent_other_inst_cd,
                                             x_attendance_mode              => l_appl_inst_rec.attendance_mode,
                                             x_edu_goal_prior_enroll_id     => l_appl_inst_rec.edu_goal_prior_enroll_id,
                                             x_attendance_type              => l_appl_inst_rec.attendance_type,
                                             x_decision_make_id             => l_appl_inst_rec.decision_make_id,
                                             x_unit_set_cd                  => l_appl_inst_rec.unit_set_cd,
                                             x_decision_date                => l_appl_inst_rec.decision_date,
                                             x_attribute_category           => l_appl_inst_rec.attribute_category,
                                             x_attribute1                   => l_appl_inst_rec.attribute1,
                                             x_attribute2                   => l_appl_inst_rec.attribute2,
                                             x_attribute3                   => l_appl_inst_rec.attribute3,
                                             x_attribute4                   => l_appl_inst_rec.attribute4,
                                             x_attribute5                   => l_appl_inst_rec.attribute5,
                                             x_attribute6                   => l_appl_inst_rec.attribute6,
                                             x_attribute7                   => l_appl_inst_rec.attribute7,
                                             x_attribute8                   => l_appl_inst_rec.attribute8,
                                             x_attribute9                   => l_appl_inst_rec.attribute9,
                                             x_attribute10                  => l_appl_inst_rec.attribute10,
                                             x_attribute11                  => l_appl_inst_rec.attribute11,
                                             x_attribute12                  => l_appl_inst_rec.attribute12,
                                             x_attribute13                  => l_appl_inst_rec.attribute13,
                                             x_attribute14                  => l_appl_inst_rec.attribute14,
                                             x_attribute15                  => l_appl_inst_rec.attribute15,
                                             x_attribute16                  => l_appl_inst_rec.attribute16,
                                             x_attribute17                  => l_appl_inst_rec.attribute17,
                                             x_attribute18                  => l_appl_inst_rec.attribute18,
                                             x_attribute19                  => l_appl_inst_rec.attribute19,
                                             x_attribute20                  => l_appl_inst_rec.attribute20,
                                             x_decision_reason_id           => l_appl_inst_rec.decision_reason_id,
                                             x_us_version_number            => l_appl_inst_rec.us_version_number,
                                             x_decision_notes               => l_appl_inst_rec.decision_notes,
                                             x_pending_reason_id            => l_appl_inst_rec.pending_reason_id,
                                             x_preference_number            => l_appl_inst_rec.preference_number,
                                             x_adm_doc_status               => l_appl_inst_rec.adm_doc_status,
                                             x_adm_entry_qual_status        => l_appl_inst_rec.adm_entry_qual_status,
                                             x_deficiency_in_prep           => l_appl_inst_rec.deficiency_in_prep,
                                             x_late_adm_fee_status          => l_appl_inst_rec.late_adm_fee_status,
                                             x_spl_consider_comments        => l_appl_inst_rec.spl_consider_comments,
                                             x_apply_for_finaid             => l_appl_inst_rec.apply_for_finaid,
                                             x_finaid_apply_date            => l_appl_inst_rec.finaid_apply_date,
                                             x_adm_outcome_status           => l_appl_inst_rec.adm_outcome_status,
                                             x_adm_otcm_stat_auth_per_id    => l_appl_inst_rec.adm_otcm_status_auth_person_id,
                                             x_adm_outcome_status_auth_dt   => l_appl_inst_rec.adm_outcome_status_auth_dt,
                                             x_adm_outcome_status_reason    => l_appl_inst_rec.adm_outcome_status_reason,
                                             x_offer_dt                     => l_appl_inst_rec.offer_dt,
                                             x_offer_response_dt            => l_appl_inst_rec.offer_response_dt,
                                             x_prpsd_commencement_dt        => l_appl_inst_rec.prpsd_commencement_dt,
                                             x_adm_cndtnl_offer_status      => l_appl_inst_rec.adm_cndtnl_offer_status,
                                             x_cndtnl_offer_satisfied_dt    => l_appl_inst_rec.cndtnl_offer_satisfied_dt,
                                             x_cndnl_ofr_must_be_stsfd_ind  => l_appl_inst_rec.cndtnl_offer_must_be_stsfd_ind,
                                             x_adm_offer_resp_status        => l_appl_inst_rec.adm_offer_resp_status,
                                             x_actual_response_dt           => l_appl_inst_rec.actual_response_dt,
                                             x_adm_offer_dfrmnt_status      => l_appl_inst_rec.adm_offer_dfrmnt_status,
                                             x_deferred_adm_cal_type        => l_appl_inst_rec.deferred_adm_cal_type,
                                             x_deferred_adm_ci_sequence_num => l_appl_inst_rec.deferred_adm_ci_sequence_num,
                                             x_deferred_tracking_id         => l_appl_inst_rec.deferred_tracking_id,
                                             x_ass_rank                     => l_appl_inst_rec.ass_rank,
                                             x_secondary_ass_rank           => l_appl_inst_rec.secondary_ass_rank,
                                             x_intr_accept_advice_num       => l_appl_inst_rec.intrntnl_acceptance_advice_num,
                                             x_ass_tracking_id              => l_appl_inst_rec.ass_tracking_id,
                                             x_fee_cat                      => l_appl_inst_rec.fee_cat,
                                             x_hecs_payment_option          => l_appl_inst_rec.hecs_payment_option,
                                             x_expected_completion_yr       => l_appl_inst_rec.expected_completion_yr,
                                             x_expected_completion_perd     => l_appl_inst_rec.expected_completion_perd,
                                             x_correspondence_cat           => l_appl_inst_rec.correspondence_cat,
                                             x_enrolment_cat                => l_appl_inst_rec.enrolment_cat,
                                             x_funding_source               => l_appl_inst_rec.funding_source,
                                             x_applicant_acptnce_cndtn      => l_appl_inst_rec.applicant_acptnce_cndtn,
                                             x_cndtnl_offer_cndtn           => l_appl_inst_rec.cndtnl_offer_cndtn,
                                             x_ss_application_id            => l_appl_inst_rec.ss_application_id,
                                             x_ss_pwd                       => l_appl_inst_rec.ss_pwd,
                                             x_authorized_dt                => l_appl_inst_rec.authorized_dt,
                                             x_authorizing_pers_id          => l_appl_inst_rec.authorizing_pers_id,
                                             x_entry_status                 => l_appl_inst_rec.entry_status,
                                             x_entry_level                  => l_appl_inst_rec.entry_level,
                                             x_sch_apl_to_id                => l_appl_inst_rec.sch_apl_to_id,
					     x_idx_calc_date                => l_calculation_date,
                                             X_FUT_ACAD_CAL_TYPE            => l_appl_inst_rec.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                                             X_FUT_ACAD_CI_SEQUENCE_NUMBER  => l_appl_inst_rec.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                                             X_FUT_ADM_CAL_TYPE             => l_appl_inst_rec.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                                             X_FUT_ADM_CI_SEQUENCE_NUMBER   => l_appl_inst_rec.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_PREV_TERM_ADM_APPL_NUMBER    => l_appl_inst_rec.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                                             X_PREV_TERM_SEQUENCE_NUMBER    => l_appl_inst_rec.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_FUT_TERM_ADM_APPL_NUMBER     => l_appl_inst_rec.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                                             X_FUT_TERM_SEQUENCE_NUMBER     => l_appl_inst_rec.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
			                     X_DEF_ACAD_CAL_TYPE            => l_appl_inst_rec.DEF_ACAD_CAL_TYPE, --Bug 2395510
			                     X_DEF_ACAD_CI_SEQUENCE_NUM     => l_appl_inst_rec.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
			                     X_DEF_PREV_TERM_ADM_APPL_NUM   => l_appl_inst_rec.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
					     X_DEF_PREV_APPL_SEQUENCE_NUM   => l_appl_inst_rec.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
					     X_DEF_TERM_ADM_APPL_NUM        => l_appl_inst_rec.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
				             X_DEF_APPL_SEQUENCE_NUM        => l_appl_inst_rec.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
					     x_mode                         => 'R',
					     x_attribute21                  => l_appl_inst_rec.attribute21,
                                             x_attribute22                  => l_appl_inst_rec.attribute22,
                                             x_attribute23                  => l_appl_inst_rec.attribute23,
                                             x_attribute24                  => l_appl_inst_rec.attribute24,
                                             x_attribute25                  => l_appl_inst_rec.attribute25,
                                             x_attribute26                  => l_appl_inst_rec.attribute26,
                                             x_attribute27                  => l_appl_inst_rec.attribute27,
                                             x_attribute28                  => l_appl_inst_rec.attribute28,
                                             x_attribute29                  => l_appl_inst_rec.attribute29,
                                             x_attribute30                  => l_appl_inst_rec.attribute30,
                                             x_attribute31                  => l_appl_inst_rec.attribute31,
                                             x_attribute32                  => l_appl_inst_rec.attribute32,
                                             x_attribute33                  => l_appl_inst_rec.attribute33,
                                             x_attribute34                  => l_appl_inst_rec.attribute34,
					     x_attribute35                  => l_appl_inst_rec.attribute35,
					     x_attribute36                  => l_appl_inst_rec.attribute36,
					     x_attribute37                  => l_appl_inst_rec.attribute37,
					     x_attribute38                  => l_appl_inst_rec.attribute38,
					     x_attribute39                  => l_appl_inst_rec.attribute39,
					     x_attribute40                  => l_appl_inst_rec.attribute40,
					     X_APPL_INST_STATUS		    => l_appl_inst_rec.appl_inst_status,
					     x_ais_reason		    => l_appl_inst_rec.ais_reason,
					     x_decline_ofr_reason	    => l_appl_inst_rec.decline_ofr_reason

                                            );
   --          END;
--	     ELSIF c_doc_status%NOTFOUND THEN -- DOC STATUS
--	     	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'C: No record found with SATISFIED STATUS');
  --                  ROLLBACK TO RECORD_ACADEMIC_INDEX_pub;
--	            x_return_status := FND_API.G_RET_STS_ERROR;
  --                  FND_MESSAGE.SET_NAME('IGS','IGS_AD_DOC_STATUS_INCORRECT');
--		    IGS_GE_MSG_STACK.ADD;
--		    RAISE FND_API.G_EXC_ERROR;
  --           END IF;--IF c_doc_status%NOTFOUND THEN
    --       IF c_doc_status%ISOPEN THEN
      --       CLOSE c_doc_status;
      --     END IF ;
        END IF;-- of C_ACAI%NOTFOUND
        CLOSE c_acai;
--	IF c_doc_status%ISOPEN THEN
  --           CLOSE c_doc_status;
    --       END IF ;
 	-- Standard check of p_commit.
 	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
EXCEPTION
	WHEN FND_API.G_EXC_ERROR  THEN
		ROLLBACK TO RECORD_ACADEMIC_INDEX_pub;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
	    x_msg_count := x_msg_count-1;
--		FND_FILE.PUT_LINE(FND_FILE.LOG, 'aFTER STACK Exception in API: FND_API.G_EXC_ERROR : '|| l_hash_msg_name_text_type_tab(x_msg_count-2).text);
        IF c_acai%ISOPEN THEN
        CLOSE c_acai;
	END IF;
--	IF c_doc_status%ISOPEN THEN
  --        CLOSE c_doc_status;
    --    END IF ;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RECORD_ACADEMIC_INDEX_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      WHEN OTHERS THEN
      ROLLBACK TO RECORD_ACADEMIC_INDEX_pub;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
          IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	  ELSE
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  END IF;
        IF c_acai%ISOPEN THEN
        CLOSE c_acai;
	END IF;
--	IF c_doc_status%ISOPEN THEN
  --        CLOSE c_doc_status;
    --    END IF ;

 END RECORD_ACADEMIC_INDEX;



  PROCEDURE Record_Outcome_AdmApplication(p_api_version      IN NUMBER,
                                    p_init_msg_list    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_commit           IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,

                                    p_person_id             NUMBER,
                                    p_admission_appl_number NUMBER,
                                    p_nominated_program_cd   VARCHAR2,
                                    p_sequence_number       NUMBER,

                                    p_adm_outcome_status    VARCHAR2,
                                    p_decision_maker_id      NUMBER,
                                    p_decision_date         DATE,
                                    p_decision_reason_id    NUMBER DEFAULT NULL,
                                    p_pending_reason_id     NUMBER DEFAULT NULL,
                                    p_offer_dt              DATE DEFAULT NULL,
                                    -- Columns for Override Outcome
                                    p_adm_outcome_status_auth_dt   DATE DEFAULT NULL,
                                    p_adm_otcm_status_auth_per_id NUMBER DEFAULT NULL,
                                    p_adm_outcome_status_reason    VARCHAR2 DEFAULT NULL,
                                    -- Columns for Conditional Offer Status
                                    p_adm_cndtnl_offer_status    VARCHAR2 DEFAULT NULL,
                                    p_cndtnl_offer_cndtn         VARCHAR2 DEFAULT NULL,
                                    p_cndtl_offer_must_stsfd_ind VARCHAR2 DEFAULT NULL,
                                    p_cndtnl_offer_satisfied_dt  DATE DEFAULT NULL,

                                    p_offer_response_dt       DATE DEFAULT NULL,
                                    p_reconsider_flag         VARCHAR2 DEFAULT 'N',
                                    p_prpsd_commencement_date DATE DEFAULT NULL,
                                    p_ucas_transaction        VARCHAR2 DEFAULT 'N',

                                    x_return_status OUT  NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2

                                    ) AS

    CURSOR c_appl_cur IS
      SELECT a.ROWID, a.*
        FROM IGS_AD_APPL a
       WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number;
    l_c_appl_cur c_appl_cur%ROWTYPE;

    CURSOR c_aplinst_cur IS
      SELECT a.ROWID, a.*, b.req_for_reconsideration_ind
        FROM igs_ad_ps_appl_inst a, IGS_AD_PS_APPL b
       WHERE a.person_id = p_person_id
         AND a.admission_appl_number = p_admission_appl_number
         AND a.nominated_course_cd = p_nominated_program_cd
         AND a.sequence_number = p_sequence_number
	 AND a.person_id = b.person_id
  	 AND a.admission_appl_number = b.admission_appl_number
	 AND a.nominated_course_cd = b.nominated_course_cd;

    CURSOR c_ps_appl_cur IS
      SELECT a.*
        FROM igs_ad_ps_appl a
       WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number
         AND nominated_course_cd = p_nominated_program_cd;

    CURSOR c_check_reconsider(cp_admission_cat IGS_AD_PRCS_CAT_STEP.ADMISSION_CAT%TYPE, cp_s_admission_process_type IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
      SELECT 'X'
        FROM IGS_AD_PRCS_CAT_STEP
       WHERE admission_cat = cp_admission_cat
         AND s_admission_process_type = cp_s_admission_process_type
         AND s_admission_step_type = 'RECONSIDER';

    CURSOR c_apcs(cp_admission_cat IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE, cp_s_admission_process_type IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
      SELECT 'Y'
        FROM IGS_AD_PRCS_CAT_STEP
       WHERE admission_cat = cp_admission_cat
         AND s_admission_process_type = cp_s_admission_process_type
         AND s_admission_step_type = 'PRE-ENROL'
         AND step_group_type <> 'TRACK';

    CURSOR c_adm_ofr_resp_stat_cur IS
      SELECT a.adm_offer_resp_status
        FROM igs_ad_ps_appl_inst a
       WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number
         AND nominated_course_cd = p_nominated_program_cd
         AND sequence_number = p_sequence_number;

    CURSOR c_person_id(cp_party_number hz_parties.party_number%TYPE) IS
      SELECT party_id FROM hz_parties WHERE party_number = cp_party_number;
    l_adm_otcm_status_auth_per_id hz_parties.party_id%TYPE;
    l_check_reconsider            VARCHAR2(1);
    l_pre_enroll                  VARCHAR2(2);
    l_c_aplinst_cur               c_aplinst_cur%ROWTYPE;
    l_c_ps_appl_cur               c_ps_appl_cur%ROWTYPE;

    l_api_name    CONSTANT VARCHAR2(30) := 'Record_Outcome_AdmApplication';
    l_api_version CONSTANT NUMBER := 1.1;
    l_message_name VARCHAR2(80);

    l_decision_make_id           NUMBER(15) ;
    l_decision_date              DATE ;
    l_decision_reason_id         NUMBER(15) ;
    l_pending_reason_id          NUMBER(15) ;
    l_offer_dt                   DATE ;
    l_offer_response_dt          DATE ;
    l_reconsider_flag            VARCHAR2(1) ;
    l_prpsd_commencement_date    DATE ;
    l_cndtnl_offer_cndtn         VARCHAR2(2000) ;
    l_cndtl_offer_must_stsfd_ind VARCHAR2(1) ;
    l_actual_response_dt         igs_ad_ps_appl_inst.actual_response_dt%TYPE;
    l_adm_outcome_status         igs_ad_ps_appl_inst.adm_outcome_status%TYPE ;
    l_adm_offer_resp_status      igs_ad_ps_appl_inst.adm_offer_resp_status%TYPE ;
    l_cndtnl_offer_satisfied_dt  igs_ad_ps_appl_inst.cndtnl_offer_satisfied_dt%TYPE ;
    l_adm_cndtl_offer_status     igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE ;
    l_adm_outcome_status_auth_dt  igs_ad_ps_appl_inst.adm_outcome_status_auth_dt%TYPE;
    l_adm_otcm_status_auth_per_num  hz_parties.party_number%TYPE;
    l_adm_outcome_status_reason    igs_ad_ps_appl_inst.adm_outcome_status_reason%TYPE;

    l_uc_tran_id           igs_uc_transactions.uc_tran_id%TYPE;
    l_s_adm_outcome_status igs_ad_ou_Stat.s_adm_outcome_status%TYPE;

    l_req_for_reconsideration_ind VARCHAR2(1);
    v_message_name                VARCHAR2(2000);

    l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;
    l_msg_index                   NUMBER := 0;

    --begin apadegal ADTD001 IGS.M
	 lv_return_status         VARCHAR2(10);
	 lv_msg_count             NUMBER;
	 lv_msg_data              VARCHAR2(1000);
	 lv_msg_nme                     varchar2(2000);
	 l_recon_unchecked        BOOLEAN DEFAULT FALSE;

   --end apadegal ADTD001 IGS.M


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Record_Outcome_AdmAppl_pub;
    l_msg_index := igs_ge_msg_stack.count_msg;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


-- Validate all the parameters for their length
-- PERSON_ID
     check_length('PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_person_id)));
-- P_ADMISSION_APPL_NUMBER
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_admission_appl_number)));
-- p_nominated_program_cd
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_PS_APPL_INST_ALL', length(p_nominated_program_cd));
-- P_SEQUENCE_NUMBER
     check_length('SEQUENCE_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_sequence_number)));
-- P_ADM_OUTCOME_STATUS
     check_length('ADM_OUTCOME_STATUS', 'IGS_AD_PS_APPL_INST_ALL', length(p_adm_outcome_status));
-- P_DECISION_MAKER_ID
     check_length('DECISION_MAKE_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_decision_maker_id)));
-- P_DECISION_REASON_ID
     check_length('DECISION_REASON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_decision_reason_id)));
-- P_PENDING_REASON_ID
     check_length('PENDING_REASON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_pending_reason_id)));
-- P_ADM_OTCM_STATUS_AUTH_PER_ID
     check_length('ADM_OTCM_STATUS_AUTH_PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_adm_otcm_status_auth_per_id)));
-- P_ADM_OUTCOME_STATUS_REASON
     check_length('ADM_OUTCOME_STATUS_REASON', 'IGS_AD_PS_APPL_INST_ALL', length(p_adm_outcome_status_reason));
-- P_ADM_CNDTNL_OFFER_STATUS
     check_length('ADM_CNDTNL_OFFER_STATUS', 'IGS_AD_PS_APPL_INST_ALL', length(p_adm_cndtnl_offer_status));
-- P_CNDTNL_OFFER_CNDTN
     check_length('CNDTNL_OFFER_CNDTN', 'IGS_AD_PS_APPL_INST_ALL', length(p_cndtnl_offer_cndtn));
-- P_CNDTL_OFFER_MUST_STSFD_IND
     check_length('CNDTNL_OFFER_MUST_BE_STSFD_IND', 'IGS_AD_PS_APPL_INST_ALL', length(p_cndtl_offer_must_stsfd_ind));
-- P_RECONSIDER_FLAG
     check_length('REQ_FOR_RECONSIDERATION_IND', 'IGS_AD_PS_APPL', length(p_reconsider_flag));


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Check whether any application is available in OSS to update outcome status
    -- if the corresponding application is not there , then update the interface record with appropriate error code
    OPEN c_appl_cur;
    FETCH c_appl_cur INTO l_c_appl_cur;
    CLOSE c_appl_cur;


    OPEN c_aplinst_cur;
    FETCH c_aplinst_cur
      INTO l_c_aplinst_cur;
    CLOSE c_aplinst_cur;

    IF l_c_aplinst_cur.person_id IS NULL THEN
      fnd_message.set_name('IGS', 'IGS_AD_DECISION_DTLS_INVALID');
      IGS_GE_MSG_STACK.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    ---------------------------------------------------------------
    -- Start Code to Check and assign the Missing Fields/ Nullified Filelds
    ---------------------------------------------------------------
    IF p_adm_outcome_status = FND_API.G_MISS_CHAR OR p_adm_outcome_status IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OUTCOME_STATUS'));
      IGS_GE_MSG_STACK.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_adm_outcome_status := p_adm_outcome_status;
    END IF;
    l_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(l_adm_outcome_status);

    IF p_decision_maker_id = FND_API.G_MISS_NUM THEN
       l_decision_make_id := null;
    ELSE
       	l_decision_make_id := NVL( p_decision_maker_id, 	l_c_aplinst_cur.decision_make_id);
    END IF;
    IF p_decision_date = FND_API.G_MISS_DATE THEN
       l_decision_date := null;
    ELSE
       	l_decision_date := NVL( p_decision_date, 	l_c_aplinst_cur.decision_date);
    END IF;
    IF p_decision_reason_id = FND_API.G_MISS_NUM THEN
       l_decision_reason_id := null;
    ELSE
       	l_decision_reason_id := NVL( p_decision_reason_id, l_c_aplinst_cur.decision_reason_id);
    END IF;
    IF p_pending_reason_id = FND_API.G_MISS_NUM THEN
       l_pending_reason_id := null;
    ELSE
       	l_pending_reason_id := NVL( p_pending_reason_id, l_c_aplinst_cur.pending_reason_id);
    END IF;

    IF p_offer_dt = FND_API.G_MISS_DATE THEN
       l_offer_dt := null;
    ELSIF  l_s_adm_outcome_status IN ('OFFER', 'COND-OFFER') THEN
       	l_offer_dt := NVL (NVL( p_offer_dt, l_c_aplinst_cur.offer_dt), SYSDATE);
    END IF;
    IF p_offer_response_dt = FND_API.G_MISS_DATE THEN
       l_offer_response_dt := null;
    ELSE
       	l_offer_response_dt := NVL( p_offer_response_dt, l_c_aplinst_cur.offer_response_dt);
    END IF;


     IF p_reconsider_flag =  FND_API.G_MISS_CHAR OR p_reconsider_flag NOT IN ('Y', 'N') THEN
       fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REQ_RECONS_IND'));
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       	l_reconsider_flag := NVL(p_reconsider_flag, l_c_aplinst_cur.req_for_reconsideration_ind);
     END IF;

     IF p_prpsd_commencement_date = FND_API.G_MISS_DATE  OR l_s_adm_outcome_status NOT IN ('OFFER', 'COND-OFFER')THEN
        l_prpsd_commencement_date := NULL;
     ELSE
        l_prpsd_commencement_date := NVL(p_prpsd_commencement_date, l_c_aplinst_cur.prpsd_commencement_dt);
     END IF;
     IF p_adm_cndtnl_offer_status = FND_API.G_MISS_CHAR THEN
       fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_COND_OFR_STATUS'));
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       l_adm_cndtl_offer_status :=  p_adm_cndtnl_offer_status;
     END IF;

     IF p_cndtnl_offer_cndtn  = FND_API.G_MISS_CHAR  THEN
        l_cndtnl_offer_cndtn := NULL;
     ELSE
        l_cndtnl_offer_cndtn := NVL(p_cndtnl_offer_cndtn, l_c_aplinst_cur.cndtnl_offer_cndtn);
     END IF;

     IF p_cndtl_offer_must_stsfd_ind  = FND_API.G_MISS_CHAR
         OR p_cndtl_offer_must_stsfd_ind NOT IN ('Y', 'N') THEN

       fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CND_OFR_STSFD_IND'));
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       	 l_cndtl_offer_must_stsfd_ind :=
	      NVL(p_cndtl_offer_must_stsfd_ind, l_c_aplinst_cur.cndtnl_offer_must_be_stsfd_ind);
     END IF;


     IF p_cndtnl_offer_satisfied_dt = FND_API.G_MISS_DATE THEN
         l_cndtnl_offer_satisfied_dt := NULL;
     ELSE
        l_cndtnl_offer_satisfied_dt :=
	      NVL(p_cndtnl_offer_satisfied_dt, l_c_aplinst_cur.cndtnl_offer_satisfied_dt);
     END IF;

     IF p_adm_outcome_status_auth_dt = 	FND_API.G_MISS_DATE  THEN
         l_adm_outcome_status_auth_dt := NULL;
     ELSE
        l_adm_outcome_status_auth_dt :=
	    NVL(p_adm_outcome_status_auth_dt, l_c_aplinst_cur.adm_outcome_status_auth_dt);
     END IF;


     IF p_adm_otcm_status_auth_per_id = FND_API.G_MISS_NUM THEN
         l_adm_otcm_status_auth_per_id := NULL;
     ELSE
          l_adm_otcm_status_auth_per_id :=
	        NVL(p_adm_otcm_status_auth_per_id, l_c_aplinst_cur.adm_otcm_status_auth_person_id);
     END IF;

     IF p_adm_outcome_status_reason  = FND_API.G_MISS_CHAR  THEN
        l_adm_outcome_status_reason := NULL;
     ELSE
        l_adm_outcome_status_reason := NVL(p_adm_outcome_status_reason, l_c_aplinst_cur.adm_outcome_status_reason);
     END IF;

    ---------------------------------------------------------------
    -- End Code to Check and assign the Missing Fields/ Nullified Fields
    ---------------------------------------------------------------


    /* Not needed now - ADTD001 - IGS.M - apadegal

      IF IGS_AD_VAL_AA.admp_val_aa_update (
		 l_c_appl_cur.adm_appl_status,
  		  v_message_name) = FALSE AND l_reconsider_flag = 'N' THEN
            FND_MESSAGE.SET_NAME('IGS',v_message_name);
            IGS_GE_MSG_STACK.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

     */

    IF l_s_adm_outcome_status IN ('OFFER', 'COND-OFFER') THEN
      IF l_offer_response_dt IS NULL AND
         NVL(p_offer_response_dt, TRUNC(SYSDATE) )
	    <> FND_API.G_MISS_DATE THEN
        l_offer_response_dt := IGS_AD_GEN_007.ADMP_GET_RESP_DT(l_c_aplinst_cur.nominated_course_cd,
                                                               l_c_aplinst_cur.crv_version_number,
                                                               l_c_appl_cur.acad_cal_type,
                                                               l_c_aplinst_cur.location_cd,
                                                               l_c_aplinst_cur.attendance_mode,
                                                               l_c_aplinst_cur.attendance_type,
                                                               l_c_appl_cur.admission_cat,
                                                               l_c_appl_cur.s_admission_process_type,
                                                               NVL(l_c_aplinst_cur.adm_cal_type,
                                                                   l_c_appl_cur.adm_cal_type),
                                                               NVL(l_c_aplinst_cur.adm_ci_sequence_number,
                                                                   l_c_appl_cur.adm_ci_sequence_number),
                                                               l_offer_dt);

	IF l_offer_response_dt IS NULL THEN
          fnd_message.set_name('IGS', 'IGS_AD_OFR_RESPDT_SET_ODR_ADM');
          IGS_GE_MSG_STACK.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    --  Moved back from method BeforeInsertUpdateDelete1 of TBH-IGSAI18B.pls on account of bug-4234911
    -- ==========================================
     IF l_decision_make_id IS NULL THEN
                     IF l_s_adm_outcome_status  NOT IN ('PENDING') THEN
                        fnd_message.set_name('IGS', 'IGS_AD_INVALID_DECISION_ID');
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
		                 END IF;
     ELSIF  l_decision_make_id = p_person_id THEN
                    fnd_message.set_name('IGS', 'IGS_AD_INVALID_DECISION_ID');
                    IGS_GE_MSG_STACK.ADD;
                    APP_EXCEPTION.RAISE_EXCEPTION;
		  ELSIF NOT igs_ad_val_acai.genp_val_staff_fculty_prsn
		             (l_decision_make_id, v_message_name) THEN
                    fnd_message.set_name('IGS', v_message_name);
                    IGS_GE_MSG_STACK.ADD;
                    APP_EXCEPTION.RAISE_EXCEPTION;
		  END IF;
     -- Validate decision Date
      IF  l_decision_date IS NULL AND l_s_adm_outcome_status NOT IN ('PENDING') THEN
        fnd_message.set_name('IGS', 'IGS_AD_MAND_DECISION_INFO');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
       -- Decision date should be between the application date and the system date
         IF NOT l_decision_date BETWEEN l_c_appl_cur.appl_dt AND SYSDATE THEN
          fnd_message.set_name('IGS', 'IGS_AD_DECISION_DATE');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
      END IF;

      --Validate Decision Reason
      IF  l_decision_reason_id IS NULL AND
           l_s_adm_outcome_status NOT IN ('PENDING')
          THEN
        fnd_message.set_name('IGS', 'IGS_AD_DECISION_REASON_INVALID');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    -- ==============================================================


       --Validate Pending Reason
       IF  l_pending_reason_id IS NULL AND
              l_s_adm_outcome_status  IN ('PENDING') AND
                      l_c_aplinst_cur.adm_outcome_status <> l_adm_outcome_status_reason THEN
            fnd_message.set_name('IGS', 'IGS_AD_PENDING_REASON_INVALID');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

    IF l_s_adm_outcome_status IN ('OFFER', 'COND-OFFER') THEN
      IF (p_pending_reason_id IS NOT NULL AND NVL(p_pending_reason_id, -1)  <> FND_API.G_MISS_NUM ) THEN
        fnd_message.set_name('IGS', 'IGS_AD_INVALID_PARAM_COMB');
        IGS_GE_MSG_STACK.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;
      l_pending_reason_id := NULL;
    ELSIF l_s_adm_outcome_status IN ('PENDING') THEN
    -- p_offer_dt, p_offer_response_dt, p_decision_maker_id or p_decision_date
    -- cannot be specified when l_s_adm_outcome_status = PENDING
	 IF (p_offer_dt IS NOT NULL AND NVL(p_offer_dt, TRUNC(SYSDATE) ) <> FND_API.G_MISS_DATE)
            OR
            (p_offer_response_dt IS NOT NULL AND NVL(p_offer_response_dt, TRUNC(SYSDATE) ) <> FND_API.G_MISS_DATE )
            OR
            (p_decision_maker_id IS NOT NULL AND NVL(p_decision_maker_id, -1 ) <> FND_API.G_MISS_NUM )
            OR
            (p_decision_date IS NOT NULL AND NVL( p_decision_date, TRUNC(SYSDATE) ) <> FND_API.G_MISS_DATE) THEN
              fnd_message.set_name('IGS', 'IGS_AD_INVALID_PARAM_COMB');
               IGS_GE_MSG_STACK.ADD;
               RAISE FND_API.G_EXC_ERROR;
        END IF;
      l_offer_dt           := NULL;
      l_offer_response_dt  := NULL;
      l_decision_reason_id := NULL;
      l_decision_make_id   := NULL;
      l_decision_date      := NULL;
    ELSE
     IF
     -- p_offer_dt, p_offer_response_dt or p_pending_reason_id cannot be specified when
     -- l_s_adm_outcome_status NOT IN PENDING , OFFER , COND-OFFER
      (p_offer_dt IS NOT NULL AND NVL(p_offer_dt, TRUNC(SYSDATE) ) <> FND_API.G_MISS_DATE)
       OR
      (p_offer_response_dt IS NOT NULL AND NVL(p_offer_response_dt, TRUNC(SYSDATE) ) <> FND_API.G_MISS_DATE )
      OR
      (p_pending_reason_id IS NOT NULL AND NVL(p_pending_reason_id, -1)  <> FND_API.G_MISS_NUM ) THEN
        fnd_message.set_name('IGS', 'IGS_AD_INVALID_PARAM_COMB');
        IGS_GE_MSG_STACK.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
      l_offer_dt          := NULL;
      l_offer_response_dt := NULL;
      l_pending_reason_id := NULL;
    END IF;

    l_actual_response_dt := l_c_aplinst_cur.actual_response_dt;

    IF NVL(igs_ad_gen_008.admp_get_saos(l_adm_outcome_status), 'NONE') IN
       ('OFFER', 'COND-OFFER') THEN
      IF l_prpsd_commencement_date IS NULL THEN
        -- Default the proposed commencement date.
        l_prpsd_commencement_date := igs_en_gen_002.enrp_get_acad_comm(l_c_appl_cur.acad_cal_type,
                                                                       l_c_appl_cur.acad_ci_sequence_number,
                                                                       p_person_id,
                                                                       p_nominated_program_cd,
                                                                       p_admission_appl_number,
                                                                       p_nominated_program_cd,
                                                                       p_sequence_number,
                                                                      'Y'); -- Check for proposed commencement date.
      END IF;



      -- Default the Offer Response Status.
      IF l_c_appl_cur.s_admission_process_type <> 'RE-ADMIT' THEN
        l_adm_offer_resp_status := igs_ad_gen_009.admp_get_sys_aors('PENDING');
      ELSE
        l_adm_offer_resp_status := igs_ad_gen_009.admp_get_sys_aors('ACCEPTED');
        l_actual_response_dt    := TRUNC(SYSDATE);
      END IF;
    ELSE
      l_adm_offer_resp_status   := igs_ad_gen_009.admp_get_sys_aors('NOT-APPLIC');
    END IF;

    -- If outcome status is not in withdrawn, voided and cond offer then
    -- set the condition offer status as not-applic
    -- otherwise retain the old status

    IF NVL(l_s_adm_outcome_status, 'NONE') NOT IN ('WITHDRAWN', 'VOIDED', 'COND-OFFER') THEN
          IF p_adm_cndtnl_offer_status IS NOT NULL AND
	     igs_ad_gen_007.Admp_Get_Sacos (p_adm_cndtnl_offer_status) <>  'NOT-APPLIC' THEN
          fnd_message.set_name('IGS', 'IGS_AD_INVALID_PARAM_COMB');
          IGS_GE_MSG_STACK.ADD;
          RAISE FND_API.G_EXC_ERROR;
	END IF;
       l_adm_cndtl_offer_status     := igs_ad_gen_009.admp_get_sys_acos('NOT-APPLIC');
    ELSIF NVL(l_s_adm_outcome_status, 'NONE') = 'COND-OFFER' AND
         NVL(IGS_AD_GEN_007.ADMP_GET_SACOS(l_adm_cndtl_offer_status),
             'NOT-APPLIC') = 'NOT-APPLIC' THEN

      -- if outcome status is cond offer then set the cond offer status to pending
        l_adm_cndtl_offer_status := igs_ad_gen_009.admp_get_sys_acos('PENDING');
    ELSE
        l_adm_cndtl_offer_status := l_adm_cndtl_offer_status;
    END IF;



    BEGIN
    l_msg_index := igs_ge_msg_stack.count_msg;

    -- begin apadegal adtd001 igs.m
     OPEN c_ps_appl_cur;
     FETCH c_ps_appl_cur  INTO l_c_ps_appl_cur;
     CLOSE c_ps_appl_cur;

    -- If not reconsidered previously
    IF p_reconsider_flag  = 'Y'	 AND  NVL(l_c_ps_appl_cur.req_for_reconsideration_ind,'N') = 'N'
    THEN

	igs_ad_gen_002.Is_inst_recon_allowed(  p_person_id 	           =>   l_c_aplinst_cur.person_id,
						   p_admission_appl_number =>   l_c_aplinst_cur.admission_appl_number,
						   p_nominated_course_cd   =>   l_c_aplinst_cur.nominated_course_cd,
						   p_sequence_number 	   =>   l_c_aplinst_cur.sequence_number,
						   p_success 		   =>   lv_return_status,
						   p_message_name 	   =>   lv_msg_nme
						);
			 IF lv_return_status = 'N'
			 THEN
	  	                FND_MESSAGE.SET_NAME('IGS', lv_msg_nme);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			 END IF;

      igs_ad_ps_appl_pkg.update_row(x_rowid                       => l_c_ps_appl_cur.row_id,
                                    x_person_id                   => l_c_ps_appl_cur.person_id,
                                    x_admission_appl_number       => l_c_ps_appl_cur.admission_appl_number,
                                    x_nominated_course_cd         => l_c_ps_appl_cur.nominated_course_cd,
                                    x_transfer_course_cd          => l_c_ps_appl_cur.transfer_course_cd,
                                    x_basis_for_admission_type    => l_c_ps_appl_cur.basis_for_admission_type,
                                    x_admission_cd                => l_c_ps_appl_cur.admission_cd,
                                    x_course_rank_set             => l_c_ps_appl_cur.course_rank_set,
                                    x_course_rank_schedule        => l_c_ps_appl_cur.course_rank_schedule,
                                    x_req_for_reconsideration_ind => 'Y',
                                    x_req_for_adv_standing_ind    => l_c_ps_appl_cur.req_for_adv_standing_ind,
                                    x_mode                        => 'R');

       IGS_AD_GEN_002.Reconsider_Appl_Inst(p_person_id 	     	    => l_c_aplinst_cur.person_id,
					   p_admission_appl_number  => l_c_aplinst_cur.admission_appl_number,
					   p_nominated_course_cd    => l_c_aplinst_cur.nominated_course_cd,
					   p_acai_sequence_number   => l_c_aplinst_cur.sequence_number,
					   p_interface	            => 'IMPORT'
				          );


    END IF;
    -- end    apadegal adtd001 igs.m

    -- check if the program was previously reconsidered and outcome is changed now
     OPEN c_ps_appl_cur;
     FETCH c_ps_appl_cur  INTO l_c_ps_appl_cur;
     CLOSE c_ps_appl_cur;

     IF NVL(l_c_ps_appl_cur.req_for_reconsideration_ind,'N') = 'Y'  AND
        NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(l_adm_outcome_status),'NULL') <> NVL(IGS_AD_GEN_008.ADMP_GET_SAOS (l_c_aplinst_cur.Adm_outcome_status ),'NULL')
     THEN

	 igs_ad_ps_appl_pkg.update_row(x_rowid                       => l_c_ps_appl_cur.row_id,
                                    x_person_id                   => l_c_ps_appl_cur.person_id,
                                    x_admission_appl_number       => l_c_ps_appl_cur.admission_appl_number,
                                    x_nominated_course_cd         => l_c_ps_appl_cur.nominated_course_cd,
                                    x_transfer_course_cd          => l_c_ps_appl_cur.transfer_course_cd,
                                    x_basis_for_admission_type    => l_c_ps_appl_cur.basis_for_admission_type,
                                    x_admission_cd                => l_c_ps_appl_cur.admission_cd,
                                    x_course_rank_set             => l_c_ps_appl_cur.course_rank_set,
                                    x_course_rank_schedule        => l_c_ps_appl_cur.course_rank_schedule,
                                    x_req_for_reconsideration_ind => 'N',
                                    x_req_for_adv_standing_ind    => l_c_ps_appl_cur.req_for_adv_standing_ind,
                                    x_mode                        => 'R');
         l_recon_unchecked := TRUE;
     END IF;

     -- end apadegal adtd001 igs.m

    igs_ad_ps_appl_inst_pkg.update_row(x_rowid                        => l_c_aplinst_cur.ROWID,
                                       x_person_id                    => l_c_aplinst_cur.person_id,
                                       x_admission_appl_number        => l_c_aplinst_cur.admission_appl_number,
                                       x_nominated_course_cd          => l_c_aplinst_cur.nominated_course_cd,
                                       x_sequence_number              => l_c_aplinst_cur.sequence_number,
                                       x_predicted_gpa                => l_c_aplinst_cur.predicted_gpa,
                                       x_academic_index               => l_c_aplinst_cur.academic_index,
                                       x_adm_cal_type                 => l_c_aplinst_cur.adm_cal_type,
                                       x_app_file_location            => l_c_aplinst_cur.app_file_location,
                                       x_adm_ci_sequence_number       => l_c_aplinst_cur.adm_ci_sequence_number,
                                       x_course_cd                    => l_c_aplinst_cur.course_cd,
                                       x_app_source_id                => l_c_aplinst_cur.app_source_id,
                                       x_crv_version_number           => l_c_aplinst_cur.crv_version_number,
                                       x_waitlist_rank                => l_c_aplinst_cur.waitlist_rank,
                                       x_waitlist_status              => l_c_aplinst_cur.waitlist_status,
                                       x_location_cd                  => l_c_aplinst_cur.location_cd,
                                       x_attent_other_inst_cd         => l_c_aplinst_cur.attent_other_inst_cd,
                                       x_attendance_mode              => l_c_aplinst_cur.attendance_mode,
                                       x_edu_goal_prior_enroll_id     => l_c_aplinst_cur.edu_goal_prior_enroll_id,
                                       x_attendance_type              => l_c_aplinst_cur.attendance_type,
                                       x_decision_make_id             => l_decision_make_id,
                                       x_unit_set_cd                  => l_c_aplinst_cur.unit_set_cd,
                                       x_decision_date                => l_decision_date,
                                       x_attribute_category           => l_c_aplinst_cur.attribute_category,
                                       x_attribute1                   => l_c_aplinst_cur.attribute1,
                                       x_attribute2                   => l_c_aplinst_cur.attribute2,
                                       x_attribute3                   => l_c_aplinst_cur.attribute3,
                                       x_attribute4                   => l_c_aplinst_cur.attribute4,
                                       x_attribute5                   => l_c_aplinst_cur.attribute5,
                                       x_attribute6                   => l_c_aplinst_cur.attribute6,
                                       x_attribute7                   => l_c_aplinst_cur.attribute7,
                                       x_attribute8                   => l_c_aplinst_cur.attribute8,
                                       x_attribute9                   => l_c_aplinst_cur.attribute9,
                                       x_attribute10                  => l_c_aplinst_cur.attribute10,
                                       x_attribute11                  => l_c_aplinst_cur.attribute11,
                                       x_attribute12                  => l_c_aplinst_cur.attribute12,
                                       x_attribute13                  => l_c_aplinst_cur.attribute13,
                                       x_attribute14                  => l_c_aplinst_cur.attribute14,
                                       x_attribute15                  => l_c_aplinst_cur.attribute15,
                                       x_attribute16                  => l_c_aplinst_cur.attribute16,
                                       x_attribute17                  => l_c_aplinst_cur.attribute17,
                                       x_attribute18                  => l_c_aplinst_cur.attribute18,
                                       x_attribute19                  => l_c_aplinst_cur.attribute19,
                                       x_attribute20                  => l_c_aplinst_cur.attribute20,
                                       x_decision_reason_id           => l_decision_reason_id,
                                       x_us_version_number            => l_c_aplinst_cur.us_version_number,
                                       x_decision_notes               => l_c_aplinst_cur.decision_notes,
                                       x_pending_reason_id            => l_pending_reason_id,
                                       x_preference_number            => l_c_aplinst_cur.preference_number,
                                       x_adm_doc_status               => l_c_aplinst_cur.adm_doc_status,
                                       x_adm_entry_qual_status        => l_c_aplinst_cur.adm_entry_qual_status,
                                       x_deficiency_in_prep           => l_c_aplinst_cur.deficiency_in_prep,
                                       x_late_adm_fee_status          => l_c_aplinst_cur.late_adm_fee_status,
                                       x_spl_consider_comments        => l_c_aplinst_cur.spl_consider_comments,
                                       x_apply_for_finaid             => l_c_aplinst_cur.apply_for_finaid,
                                       x_finaid_apply_date            => l_c_aplinst_cur.finaid_apply_date,
                                       x_adm_outcome_status           => l_adm_outcome_status,
                                       x_adm_otcm_stat_auth_per_id    => l_adm_otcm_status_auth_per_id,
                                       x_adm_outcome_status_auth_dt   => l_adm_outcome_status_auth_dt,
                                       x_adm_outcome_status_reason    => l_adm_outcome_status_reason,
                                       x_offer_dt                     => l_offer_dt,
                                       x_offer_response_dt            => l_offer_response_dt,
                                       x_prpsd_commencement_dt        => l_prpsd_commencement_date,
                                       x_adm_cndtnl_offer_status      => l_adm_cndtl_offer_status,
                                       x_cndtnl_offer_satisfied_dt    => l_cndtnl_offer_satisfied_dt,
                                       x_cndnl_ofr_must_be_stsfd_ind  => l_cndtl_offer_must_stsfd_ind,
                                       x_adm_offer_resp_status        => l_adm_offer_resp_status,
                                       x_actual_response_dt           => l_actual_response_dt,
                                       x_adm_offer_dfrmnt_status      => l_c_aplinst_cur.adm_offer_dfrmnt_status,
                                       x_deferred_adm_cal_type        => l_c_aplinst_cur.deferred_adm_cal_type,
                                       x_deferred_adm_ci_sequence_num => l_c_aplinst_cur.deferred_adm_ci_sequence_num,
                                       x_deferred_tracking_id         => l_c_aplinst_cur.deferred_tracking_id,
                                       x_ass_rank                     => l_c_aplinst_cur.ass_rank,
                                       x_secondary_ass_rank           => l_c_aplinst_cur.secondary_ass_rank,
                                       x_intr_accept_advice_num       => l_c_aplinst_cur.intrntnl_acceptance_advice_num,
                                       x_ass_tracking_id              => l_c_aplinst_cur.ass_tracking_id,
                                       x_fee_cat                      => l_c_aplinst_cur.fee_cat,
                                       x_hecs_payment_option          => l_c_aplinst_cur.hecs_payment_option,
                                       x_expected_completion_yr       => l_c_aplinst_cur.expected_completion_yr,
                                       x_expected_completion_perd     => l_c_aplinst_cur.expected_completion_perd,
                                       x_correspondence_cat           => l_c_aplinst_cur.correspondence_cat,
                                       x_enrolment_cat                => l_c_aplinst_cur.enrolment_cat,
                                       x_funding_source               => l_c_aplinst_cur.funding_source,
                                       x_applicant_acptnce_cndtn      => l_c_aplinst_cur.applicant_acptnce_cndtn,
                                       x_cndtnl_offer_cndtn           => l_cndtnl_offer_cndtn,
                                       x_ss_application_id            => l_c_aplinst_cur.ss_application_id,
                                       x_ss_pwd                       => l_c_aplinst_cur.ss_pwd,
                                       x_authorized_dt                => l_c_aplinst_cur.authorized_dt,
                                       x_authorizing_pers_id          => l_c_aplinst_cur.authorizing_pers_id,
                                       x_entry_status                 => l_c_aplinst_cur.entry_status,
                                       x_entry_level                  => l_c_aplinst_cur.entry_level,
                                       x_sch_apl_to_id                => l_c_aplinst_cur.sch_apl_to_id,
                                       x_idx_calc_date                => l_c_aplinst_cur.idx_calc_date,
                                       x_fut_acad_cal_type            => l_c_aplinst_cur.future_acad_cal_type, -- bug # 2217104
                                       x_fut_acad_ci_sequence_number  => l_c_aplinst_cur.future_acad_ci_sequence_number, -- bug # 2217104
                                       x_fut_adm_cal_type             => l_c_aplinst_cur.future_adm_cal_type, -- bug # 2217104
                                       x_fut_adm_ci_sequence_number   => l_c_aplinst_cur.future_adm_ci_sequence_number, -- bug # 2217104
                                       x_prev_term_adm_appl_number    => l_c_aplinst_cur.previous_term_adm_appl_number, -- bug # 2217104
                                       x_prev_term_sequence_number    => l_c_aplinst_cur.previous_term_sequence_number, -- bug # 2217104
                                       x_fut_term_adm_appl_number     => l_c_aplinst_cur.future_term_adm_appl_number, -- bug # 2217104
                                       x_fut_term_sequence_number     => l_c_aplinst_cur.future_term_sequence_number, -- bug # 2217104
                                       X_DEF_ACAD_CAL_TYPE            => l_c_aplinst_cur.DEF_ACAD_CAL_TYPE, --Bug 2395510
                                       X_DEF_ACAD_CI_SEQUENCE_NUM     => l_c_aplinst_cur.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                                       X_DEF_PREV_TERM_ADM_APPL_NUM   => l_c_aplinst_cur.DEF_PREV_TERM_ADM_APPL_NUM, --Bug 2395510
                                       X_DEF_PREV_APPL_SEQUENCE_NUM   => l_c_aplinst_cur.DEF_PREV_APPL_SEQUENCE_NUM, --Bug 2395510
                                       X_DEF_TERM_ADM_APPL_NUM        => l_c_aplinst_cur.DEF_TERM_ADM_APPL_NUM, --Bug 2395510
                                       X_DEF_APPL_SEQUENCE_NUM        => l_c_aplinst_cur.DEF_APPL_SEQUENCE_NUM, --Bug 2395510
                                       x_mode                         => 'R',
                                       x_attribute21                  => l_c_aplinst_cur.attribute21,
                                       x_attribute22                  => l_c_aplinst_cur.attribute22,
                                       x_attribute23                  => l_c_aplinst_cur.attribute23,
                                       x_attribute24                  => l_c_aplinst_cur.attribute24,
                                       x_attribute25                  => l_c_aplinst_cur.attribute25,
                                       x_attribute26                  => l_c_aplinst_cur.attribute26,
                                       x_attribute27                  => l_c_aplinst_cur.attribute27,
                                       x_attribute28                  => l_c_aplinst_cur.attribute28,
                                       x_attribute29                  => l_c_aplinst_cur.attribute29,
                                       x_attribute30                  => l_c_aplinst_cur.attribute30,
                                       x_attribute31                  => l_c_aplinst_cur.attribute31,
                                       x_attribute32                  => l_c_aplinst_cur.attribute32,
                                       x_attribute33                  => l_c_aplinst_cur.attribute33,
                                       x_attribute34                  => l_c_aplinst_cur.attribute34,
                                       x_attribute35                  => l_c_aplinst_cur.attribute35,
                                       x_attribute36                  => l_c_aplinst_cur.attribute36,
                                       x_attribute37                  => l_c_aplinst_cur.attribute37,
                                       x_attribute38                  => l_c_aplinst_cur.attribute38,
                                       x_attribute39                  => l_c_aplinst_cur.attribute39,
                                       x_attribute40                  => l_c_aplinst_cur.attribute40,
				       X_APPL_INST_STATUS	      => l_c_aplinst_cur.appl_inst_status,
				       x_ais_reason		      => l_c_aplinst_cur.ais_reason,
				       x_decline_ofr_reason	      => l_c_aplinst_cur.decline_ofr_reason
					);


             --- NEED TO CREATE dummy history records for pending applications, if recon is unchecked
	      -- begin apadegal adtd001 igs.m
 	     IF l_recon_unchecked
	     THEN
		IGS_AD_GEN_002.ins_dummy_pend_hist_rec( l_c_aplinst_cur.person_id,
							l_c_aplinst_cur.admission_appl_number,
	     	    			                l_c_aplinst_cur.nominated_course_cd  );
	     END IF;
	     -- end apadegal adtd001 igs.m
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Record_Outcome_AdmAppl_pub;
      igs_ad_gen_016.extract_msg_from_stack(p_msg_at_index                => l_msg_index,
                                            p_return_status               => x_return_status,
                                            p_msg_count                   => x_msg_count,
                                            p_msg_data                    => x_msg_data,
                                            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_hash_msg_name_text_type_tab(x_msg_count - 1).name <> 'ORA' THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
       RETURN;
    END;


    IF p_ucas_transaction = 'Y' THEN
      -- Check the message count in stack before calling TBH.
      IF FND_PROFILE.VALUE('OSS_COUNTRY_CODE') = 'GB' THEN
        igs_ad_ps_appl_inst_pkg.ucas_user_hook(p_admission_appl_number  => l_c_aplinst_cur.admission_appl_number,
                                               p_nominated_course_cd    => l_c_aplinst_cur.nominated_course_cd,
                                               p_sequence_number        => l_c_aplinst_cur.sequence_number,
                                               p_adm_outcome_status     => l_adm_outcome_status,
                                               p_cond_offer_status      => l_c_aplinst_cur.adm_cndtnl_offer_status,
                                               p_adm_outcome_status_old => l_c_aplinst_cur.adm_outcome_status,
                                               p_cond_offer_status_old  => l_c_aplinst_cur.adm_cndtnl_offer_status,
                                               p_person_id              => l_c_aplinst_cur.person_id,
                                               p_condition_category     => NULL,
                                               p_condition_name         => NULL,
                                               p_uc_tran_id             => l_uc_tran_id);
      END IF;
      -- tray end CCR2550009
      -- kamohan Bug # 2550009
    END IF;

    -- Call the Pre-enrollment Process if the Outcome status is in OFFER or COND-OFFER
    -- Check whether the APC Step has been included for the application's APC
    -- then call the pre-enrollment process
    l_pre_enroll := 'N';

    OPEN c_apcs(l_c_appl_cur.admission_cat,
                l_c_appl_cur.s_admission_process_type);
    FETCH c_apcs
      INTO l_pre_enroll;
    CLOSE c_apcs;


    OPEN c_adm_ofr_resp_stat_cur;
    FETCH c_adm_ofr_resp_stat_cur
      INTO l_adm_offer_resp_status;
    CLOSE c_adm_ofr_resp_stat_cur;
    IF NVL(igs_ad_gen_008.admp_get_saors(l_adm_offer_resp_status), 'NULL') =
       'ACCEPTED' THEN
      IF igs_ad_upd_initialise.perform_pre_enrol(p_person_id,
                                                 p_admission_appl_number,
                                                 p_nominated_program_cd,
                                                 p_sequence_number,
                                                 'Y', -- Confirm course indicator.
                                                 'Y', -- Perform eligibility check indicator.
                                                 v_message_name) = FALSE THEN
        FND_MESSAGE.SET_NAME('IGS', v_message_name);
        IGS_GE_MSG_STACK.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- if we need to run the pre enrollment process for this application,
      -- we need to check the apc step and run the pre enrollment process
      -- for a course that has been offered on this update.
    ELSIF l_pre_enroll = 'Y' AND
          NVL(igs_ad_gen_008.admp_get_saos(l_adm_outcome_status), 'NULL') IN
          ('OFFER', 'COND-OFFER') AND
          NVL(igs_ad_gen_008.admp_get_saos(l_adm_outcome_status), 'NULL') <>
          NVL(igs_ad_gen_008.admp_get_saos(l_c_aplinst_cur.adm_outcome_status),
              'NULL') THEN

      IF igs_ad_upd_initialise.perform_pre_enrol(p_person_id,
                                                 p_admission_appl_number,
                                                 p_nominated_program_cd,
                                                 p_sequence_number,
                                                 'N', -- Confirm course indicator.
                                                 'N', -- Perform eligibility check indicator.
                                                 v_message_name) = FALSE THEN
        FND_MESSAGE.SET_NAME('IGS', v_message_name);
        IGS_GE_MSG_STACK.ADD;

        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Application Decision got imported successfully
    -- Raise the business event
    -- Changes to the logic of raising the business event is done as part of Financial Aid Integration buid - 3202866
    IF l_c_aplinst_cur.adm_outcome_status <> l_adm_outcome_status THEN

      igs_ad_wf_001.wf_raise_event(p_person_id             => p_person_id,
                                   p_raised_for            => 'IOD',
                                   p_admission_appl_number => p_admission_appl_number,
                                   p_nominated_course_cd   => p_nominated_program_cd,
                                   p_sequence_number       => p_sequence_number,
                                   p_old_outcome_status    => l_c_aplinst_cur.adm_outcome_status,
                                   p_new_outcome_status    => l_adm_outcome_status);
    END IF;
    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Record_Outcome_AdmAppl_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      igs_ad_gen_016.extract_msg_from_stack(p_msg_at_index                => l_msg_index,
                                            p_return_status               => x_return_status,
                                            p_msg_count                   => x_msg_count,
                                            p_msg_data                    => x_msg_data,
                                            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_hash_msg_name_text_type_tab(x_msg_count - 2).name <> 'ORA' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      x_msg_data := l_hash_msg_name_text_type_tab( x_msg_count - 2).text;
      x_msg_count := x_msg_count - 1;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Record_Outcome_AdmAppl_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Record_Outcome_AdmAppl_pub;
      igs_ad_gen_016.extract_msg_from_stack(p_msg_at_index                => l_msg_index,
                                            p_return_status               => x_return_status,
                                            p_msg_count                   => x_msg_count,
                                            p_msg_data                    => x_msg_data,
                                            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_hash_msg_name_text_type_tab(x_msg_count - 1).name <> 'ORA' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

  END Record_Outcome_AdmApplication;

  PROCEDURE validate_off_resp_dtls(
      p_person_id                   IN igs_ad_offresp_int.person_id%TYPE,
      p_admission_appl_number       IN igs_ad_offresp_int.admission_appl_number%TYPE,
      p_nominated_course_cd         IN igs_ad_offresp_int.nominated_course_cd%TYPE ,
      p_sequence_number             IN igs_ad_offresp_int.sequence_number%TYPE,
      p_adm_offer_resp_status       IN igs_ad_offresp_int.adm_offer_resp_status%TYPE ,
      p_actual_offer_response_dt    IN igs_ad_offresp_int.actual_offer_response_dt%TYPE,
      p_applicant_acptnce_cndtn     IN igs_ad_offresp_int.applicant_acptnce_cndtn%TYPE,
--      p_attent_other_inst_cd        IN igs_ad_offresp_int.attent_other_inst_cd%TYPE,
      p_adm_offer_defr_status       IN OUT NOCOPY igs_ad_ps_appl_inst_all.adm_offer_dfrmnt_status%TYPE,
--      p_authorized_dt               IN      DATE,    -- if null then default it to sys date. and validation exists in Form(pld)
--      p_authorizing_pers_id         IN      NUMBER,   --NUMBER(15)    LOV (No validation)  need to write validations
      p_def_acad_cal_type           IN igs_ad_offresp_int.def_acad_cal_type%TYPE ,
      p_def_acad_ci_sequence_number IN igs_ad_offresp_int.def_acad_ci_sequence_number%TYPE,
      p_def_adm_cal_type            IN igs_ad_offresp_int.def_adm_cal_type%TYPE ,
      p_def_adm_ci_sequence_number  IN igs_ad_offresp_int.def_adm_ci_sequence_number%TYPE ,
      p_decline_ofr_reason	    IN igs_ad_offresp_int.decline_ofr_reason%TYPE,
      p_attent_other_inst_cd        IN igs_ad_offresp_int.attent_other_inst_cd%TYPE,
      p_calc_actual_ofr_resp_dt     OUT NOCOPY igs_ad_offresp_int.actual_offer_response_dt%TYPE,
--      p_yes_no                      IN VARCHAR2,
      p_validation_success          OUT NOCOPY VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------------------------------
  --  Created By : rsharma
  --  Date Created On : 09-OCT-2004
  --  Purpose : This Procedure performs all the validations that are being done in Offer Response form (IGSAD093). Apart
  --  from these validations some additional validations are performed to check for the validity of different Offer Response details.
  --  Validations are stopped whenever basic validation a fails, like the application is not in Open processing state or Outcome Status
  --  is not valid etc.
  --  Know limitations, enhancements or remarks
  --  Change History
  --  Who             When            What
  ---------------------------------------------------------------------------------------------------------------------------------------


-- to get the one application row
  CURSOR c_adm_appl_dtl (cp_person_id              igs_ad_appl_all.person_id%TYPE ,
                   cp_admission_appl_number  igs_ad_appl_all.admission_appl_number%TYPE) IS
  SELECT appl.*
  FROM igs_ad_appl_all appl
  WHERE person_id = cp_person_id AND
        admission_appl_number = cp_admission_appl_number;

-- to get teh application instance
  CURSOR  cur_ad_ps_appl_inst (  cp_person_id              igs_ad_ps_appl_inst_all.person_id%TYPE ,
                               cp_admission_appl_number  igs_ad_ps_appl_inst_all.admission_appl_number%TYPE ,
                               cp_nominated_course_cd    igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE ,
                               cp_sequence_number        igs_ad_ps_appl_inst_all.sequence_number%TYPE
                                ) IS
  SELECT aplinst.rowid, aplinst.*
  FROM  igs_ad_ps_appl_inst_all aplinst
  WHERE  person_id = cp_person_id   AND
         admission_appl_number = cp_admission_appl_number AND
         nominated_course_cd = cp_nominated_course_cd AND
         sequence_number = cp_sequence_number;

  CURSOR c_apcs (cp_admission_cat  igs_ad_prcs_cat_step.admission_cat%TYPE,
      cp_s_admission_process_type  igs_ad_prcs_cat_step.s_admission_process_type%TYPE) IS
  SELECT  s_admission_step_type,
          step_type_restriction_num
  FROM  igs_ad_prcs_cat_step
  WHERE admission_cat = cp_admission_cat AND
        s_admission_process_type = cp_s_admission_process_type AND
        step_group_type <> 'TRACK' ;


    v_step_type          VARCHAR2(100);
    l_deferral_allowed   VARCHAR2(1);
    l_pre_enrol          VARCHAR2(1);
    l_multi_offer_allowed VARCHAR2(1);
    l_multi_offer_limit  NUMBER(10);
    v_message_name       VARCHAR2(100);
    l_valid_def_adm_cal  VARCHAR2(1);
    l_valid_def_acad_cal VARCHAR2(1);
    cst_completed        CONSTANT VARCHAR2(10) := 'COMPLETED';
    cst_withdrawn        CONSTANT VARCHAR2(10) := 'WITHDRAWN';
    cst_offer            CONSTANT VARCHAR2(10) := 'OFFER';
    cst_cond_offer       CONSTANT VARCHAR2(10) := 'COND-OFFER';
    cst_pending          CONSTANT VARCHAR2(10) := 'PENDING';
    cst_accepted         CONSTANT VARCHAR2(10) := 'ACCEPTED';
    cst_rejected         CONSTANT VARCHAR2(10) := 'REJECTED';
    cst_deferral         CONSTANT VARCHAR2(10) := 'DEFERRAL';
    cst_lapsed           CONSTANT VARCHAR2(10) := 'LAPSED';
    cst_not_applic       CONSTANT VARCHAR2(10) := 'NOT-APPLIC';


    v_admission_cat                 igs_ad_appl.admission_cat%TYPE;
    v_s_admission_process_type      igs_ad_appl.s_admission_process_type%TYPE;
    v_acad_cal_type                 igs_ad_appl.acad_cal_type%TYPE;
    v_acad_ci_sequence_number       igs_ad_appl.acad_ci_sequence_number%TYPE;
    v_aa_adm_cal_type               igs_ad_appl.adm_cal_type%TYPE;
    v_aa_adm_ci_sequence_number     igs_ad_appl.adm_ci_sequence_number%TYPE;
    v_acaiv_adm_cal_type            igs_ad_ps_appl_inst_all.adm_cal_type%TYPE;
    v_acaiv_adm_ci_sequence_number  igs_ad_ps_appl_inst_all.adm_ci_sequence_number%TYPE;
    v_adm_cal_type                  igs_ad_appl.adm_cal_type%TYPE;
    v_adm_ci_sequence_number        igs_ad_appl.adm_ci_sequence_number%TYPE;
    v_appl_dt                       igs_ad_appl.appl_dt%TYPE;
    v_adm_appl_status               igs_ad_appl.adm_appl_status%TYPE;
    v_adm_fee_status                igs_ad_appl.adm_fee_status%TYPE;
    l_single_response_flag          igs_ad_prd_ad_prc_ca.single_response_flag%TYPE;
    l_application_id                igs_ad_appl_all.application_id%TYPE;
    l_nominated_course_cd           igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE;
    l_acad_alt_code                 igs_ca_inst.alternate_code%TYPE;
    l_adm_alt_code                  igs_ca_inst.alternate_code%TYPE;
    l_acaiv_rec                     cur_ad_ps_appl_inst%ROWTYPE;
    l_appl_rec                      c_adm_appl_dtl%ROWTYPE;

  BEGIN

     --Initialize the flag indicating the SUCCESS ('Y'). Gets updated to 'N' even if one validation fails
    p_validation_success := 'Y';


         OPEN c_adm_appl_dtl( p_person_id,
                              p_admission_appl_number);
         FETCH c_adm_appl_dtl INTO l_appl_rec;
         CLOSE c_adm_appl_dtl;

         OPEN cur_ad_ps_appl_inst(
               p_person_id,
               p_admission_appl_number,
               p_nominated_course_cd,
               p_sequence_number);
         FETCH cur_ad_ps_appl_inst INTO l_acaiv_rec;
	 CLOSE cur_ad_ps_appl_inst;

   IF l_acaiv_rec.person_id IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_APPL'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;


      -- begin apadegal adtd001 igs.m

   /* This validation is not needed now as offer reponse is always updateable as per Re-Open ADFD001

   --Validations to check if Application Processing Status is OPEN or not
   IF igs_ad_gen_007.admp_get_saas(l_appl_rec.adm_appl_status) IN (cst_completed, cst_withdrawn) THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_CANNOTUPD_STATUS_COMPL');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;
   */
      -- end apadegal adtd001 igs.m

   --Check if the New Offer Response Status is a valid Offer Response Status mapped to one of the System Offer Response Statuses.
--  IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) IS NULL THEN
     IF NOT IGS_AD_OFR_RESP_STAT_PKG.Get_PK_For_Validation(p_adm_offer_resp_status,'N')  THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_GE_PK_UK_NOT_FOUND_CLOSED');
     fnd_message.set_token('ATTRIBUTE', FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_RESP_STATUS'));
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;
   --Validations on the Application Instance Outcome Status. Check if the Applicant's Outcome Status is mapped to one of the System Outcome Status of
   --'Make Offer of Admission' (OFFER) or 'Make Offer of Admission Subject to Condition' (COND-OFFER).
   IF NVL(igs_ad_gen_008.admp_get_saos(l_acaiv_rec.adm_outcome_status), 'NULL') NOT IN (cst_offer, cst_cond_offer) THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_OFRST_NOTACCEPTED');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;


--  ********** VALIDATIONS WHICH CHECK FOR THE PROPER COMBINATION OF New Offer response status Vs SYSTEM TABLE Offer Response Status. Stop processing in case of failure
   -- Check if New  Offer Response status = Production table (IGS_AD_PS_APPL_INST_ALL) Offer Response Status.
   IF p_adm_offer_resp_status = l_acaiv_rec.adm_offer_resp_status THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_RESP_SATUS_NOT_CHANGE');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;

      -- begin apadegal adtd001 igs.m

   /* Following validations are not needed now as Offer response is
   -- Check if the Interface Offer Response Status is allowed to update the existing offer response in production table.
   -- IF Interface Offer Response Status is 'PENDING' and the corresponding status in production table is 'ACCEPTED' Then
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_pending AND igs_ad_gen_008.admp_get_saors(l_acaiv_rec.adm_offer_resp_status) = cst_accepted THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_ADMOFR_ALREADY_RESPOND');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;
   -- IF Interface Offer Response Status is PENDING and the corresponding status in production table is REJECTED Then
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_pending AND igs_ad_gen_008.admp_get_saors(l_acaiv_rec.adm_offer_resp_status) = cst_rejected THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_ADMOFR_ALREADY_REJECT');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;
   -- IF Interface Offer Response Status is 'ACCEPTED' and the corresponding status in production table is 'REJECTED' Then
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_accepted AND igs_ad_gen_008.admp_get_saors(l_acaiv_rec.adm_offer_resp_status) = cst_rejected THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_ADMOFR_ALREADY_REJECT');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;
   -- IF Interface Offer Response Status is 'DEFERRAL' and the corresponding status in production table is 'REJECTED' Then
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_deferral AND igs_ad_gen_008.admp_get_saors(l_acaiv_rec.adm_offer_resp_status) = cst_rejected THEN
     p_validation_success := 'N';
     fnd_message.set_name('IGS', 'IGS_AD_ADMOFR_ALREADY_REJECT');
     IGS_GE_MSG_STACK.ADD;
     RETURN;
   END IF;
   */

   -- added this new validation to check if an application is already created in deferred term. Throw the error accordingly.

    IF 	l_acaiv_rec.Def_term_adm_appl_num IS NOT NULL or l_acaiv_rec.def_appl_sequence_num IS NOT NULL
    THEN
        p_validation_success := 'N';
        fnd_message.set_name('IGS', 'IGS_AD_CANNOT_CHG_CONF_APPL');
        IGS_GE_MSG_STACK.ADD;
	RETURN	;

    END IF;

   -- end apadegal adtd001 igs.m


 -- If Offer Response is changed to PENDING from DEFERRAL, then the Deffered Calendars should be NULL otherswise insert error record into corresponding table
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) <> cst_pending AND igs_ad_gen_008.admp_get_saors(l_acaiv_rec.adm_offer_resp_status) = cst_deferral THEN
     IF p_def_acad_cal_type IS NOT NULL OR p_def_acad_ci_sequence_number IS NOT NULL THEN
        p_validation_success := 'N';
        fnd_message.set_name('IGS', 'IDS_AD_DEFER_TO_PENDING');
        IGS_GE_MSG_STACK.ADD;
     RETURN;
     END IF;
    IF p_def_adm_cal_type IS NOT NULL OR p_def_adm_ci_sequence_number IS NOT NULL THEN
        p_validation_success := 'N';
        fnd_message.set_name('IGS', 'IDS_AD_DEFER_TO_PENDING');
        IGS_GE_MSG_STACK.ADD;
     RETURN;
     END IF;
   END IF;

/*****   END OF VALIDATIONS CHECKING FOR THE PROPER COMBINATION OF OFFER RESPONSE STATUS (Interface Table Vs System Table)   ************/

    --Copy the interface Actual Response Date to the OUT NOCOPY Variable p_calc_actual_ofr_resp_dt
    -- and populate this variable accordingly after necessary validations
    p_calc_actual_ofr_resp_dt := p_actual_offer_response_dt;

    -- Check if parameter Offer Response Status is Other than 'PENDING', 'LAPSED', 'NOT-APPLIC'.
    IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) NOT IN (cst_pending, cst_lapsed, cst_not_applic) THEN
      IF p_calc_actual_ofr_resp_dt IS NULL THEN
         p_calc_actual_ofr_resp_dt := SYSDATE;
      END IF;
    END IF;

    -- Validate admission offer response status
    FOR c_apcs_rec IN c_apcs(l_appl_rec.admission_cat,l_appl_rec.s_admission_process_type) LOOP
      IF c_apcs_rec.s_admission_step_type = 'DEFER' THEN
        l_deferral_allowed := 'Y';
      END IF;
      IF c_apcs_rec.s_admission_step_type = 'PRE-ENROL' THEN
        v_step_type := 'IGSAD' || SUBSTR (ltrim(rtrim(c_apcs_rec.s_admission_step_type)),1,3);
        IF fnd_function.test(v_step_type) THEN
          l_pre_enrol := 'Y';
        END IF;
      END IF;
      IF c_apcs_rec.s_admission_step_type = 'MULTI-OFF' THEN
        l_multi_offer_allowed := 'Y';
        l_multi_offer_limit := c_apcs_rec.step_type_restriction_num;
      END IF;

    END LOOP;
    IF igs_ad_val_acai_status.admp_val_aors_item(
              p_person_id,
              p_admission_appl_number,
              p_nominated_course_cd,
              p_sequence_number,
              l_acaiv_rec.course_cd,
              p_adm_offer_resp_status,
              p_calc_actual_ofr_resp_dt,
              l_appl_rec.s_admission_process_type,
              NVL(l_deferral_allowed,'N'),
              NVL(l_pre_enrol, 'N'),
              v_message_name,
	      p_decline_ofr_reason ,		--arvsrini igsm
	      p_attent_other_inst_cd		--arvsrini igsm
	) = FALSE THEN
      p_validation_success := 'N';
      fnd_message.set_name('IGS', v_message_name);
      IGS_GE_MSG_STACK.ADD;
      RETURN;
    END IF;


     -- Validations on the Offer Deferment Status
     -- Though Offer Deferment Status is not directly imported from Offer Response Interface table, it should be populated
     -- with either of the values 'PENDING' or 'NOT-APPLIC' depending on the value of Offer Response Status.
     -- Default the Offer Deferment Status, depending on the value of Offer Response Status, and validate the same.
     -- IF Offer Response Status is 'DEFERRAL', then default the Offer Deferment Status to 'PENDING'.
     -- ELSE Offer Response Status is not equal to 'DEFERRAL', then Default the Offer Deferment Status to 'NOT-APPLIC'.
     IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_deferral AND
       NVL(igs_ad_gen_008.admp_get_saods(l_acaiv_rec.adm_offer_dfrmnt_status), cst_not_applic) = cst_not_applic THEN
       IF igs_ad_gen_009.admp_get_sys_aods(cst_pending) IS NULL AND p_adm_offer_defr_status IS NULL THEN
        p_validation_success := 'N';
        fnd_message.set_name('IGS', 'IGS_AD_DEFR_STATUS_PEND_NOMAP');
        IGS_GE_MSG_STACK.ADD;
         RETURN;
       ELSE
          p_adm_offer_defr_status := NVL(p_adm_offer_defr_status , igs_ad_gen_009.admp_get_sys_aods(cst_pending));
          -- ADMISSION COURSE APPLICATION INSTANCE: Admission Offer Deferment Status.
          IF  p_adm_offer_defr_status <> l_acaiv_rec.adm_offer_dfrmnt_status THEN
	  --the offer deferment status can be moved to CONFIRM only from 'APPROVED'.
              IF igs_ad_val_acai_status.admp_val_aods_update(p_person_id,
                                                   p_admission_appl_number,
                                                   p_nominated_course_cd,
                                                   p_sequence_number,
						   p_adm_offer_defr_status,
						   v_message_name) = FALSE THEN
                 p_validation_success := 'N';
       	         FND_MESSAGE.SET_NAME('IGS',v_message_name);
                 IGS_GE_MSG_STACK.ADD;
                 RETURN;
               END IF;
            -- Validate.
             IF igs_ad_val_acai_status.admp_val_acai_aods (
                  p_person_id,
                  p_admission_appl_number,
                  p_nominated_course_cd,
                  p_sequence_number,
                  l_acaiv_rec.course_cd,
                  p_adm_offer_defr_status,
                  l_acaiv_rec.adm_offer_dfrmnt_status,
                  p_adm_offer_resp_status,
                  NVL(l_deferral_allowed,'N'),
                  l_appl_rec.s_admission_process_type,
                  v_message_name) = FALSE THEN
                p_validation_success := 'N';
                fnd_message.set_name('IGS', v_message_name);
                IGS_GE_MSG_STACK.ADD;
                RETURN;
             END IF; --End of igs_ad_val_acai_status.admp_val_acai_aods
          END IF; ---End of the deferred calendar validations here
       END IF;
     ELSE -- Of DEFERRAL check
       IF igs_ad_gen_009.admp_get_sys_aods(cst_not_applic) IS NULL THEN
         p_validation_success := 'N';
        fnd_message.set_name('IGS', 'IGS_AD_DEFER_NOT_DEFSTATUS');
        IGS_GE_MSG_STACK.ADD;
         RETURN;
       ELSE
         p_adm_offer_defr_status := igs_ad_gen_009.admp_get_sys_aods(cst_not_applic);
       END IF;
     END IF; -- Of DEFERRAL check

/*     Commeting this code to enable the Offer Response after offer response Deadline
-- if the offer response date is elapsed then continue with other validations  Otherwise raise the error.
    IF p_calc_actual_ofr_resp_dt > l_acaiv_rec.offer_response_dt AND TRUNC(l_acaiv_rec.offer_response_dt) < TRUNC(SYSDATE) AND
      igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_accepted THEN
        p_validation_success := 'N';
        fnd_message.set_name('IGS', 'IGS_AD_RESP_DT_PASSED');
        IGS_GE_MSG_STACK.ADD;
        RETURN;
    END IF;*/

-------------------------------------
--Start of code taken out by praveen
-------------------------------------

 /*   -- Validations on the Application Acceptance Condition
    IF p_applicant_acptnce_cndtn IS NOT NULL THEN
      IF  p_applicant_acptnce_cndtn <> l_acaiv_rec.applicant_acptnce_cndtn OR
          p_adm_offer_resp_status <> l_acaiv_rec.adm_offer_resp_status THEN
          -- Validate the acceptance condition
        IF igs_ad_val_acai.admp_val_acpt_cndtn (
                                p_applicant_acptnce_cndtn,
                                p_adm_offer_resp_status,
                                v_message_name) = FALSE THEN
          p_validation_success := 'N';
        fnd_message.set_name('IGS', v_message_name);
        IGS_GE_MSG_STACK.ADD;
          RETURN;
        END IF; -- End of igs_ad_val_acai.admp_val_acpt_cndtn
      END IF;
    END IF;*/

--------------------------------------------------------------------------------
-- Start of Validations intoduced as part of ADSS Build For Respond To Offer Page
--------------------------------------------------------------------------------
    IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) IN ('REJECTED','NOT-COMING') AND p_decline_ofr_reason IS NULL THEN
        p_validation_success := 'N';
        fnd_message.set_name('IGS','IGS_AD_ADMOFR_WITH_REAS');
        IGS_GE_MSG_STACK.ADD;
        RETURN;
    END IF;

    IF (p_decline_ofr_reason = 'OTHER-INST' AND p_attent_other_inst_cd IS NULL) THEN
	p_validation_success := 'N';
        fnd_message.set_name('IGS','IGS_AD_NO_OTH_INST');
        IGS_GE_MSG_STACK.ADD;
        RETURN;
    END IF;
-- Validations Ends

EXCEPTION


     WHEN OTHERS THEN
      p_validation_success := 'N';
      IF c_apcs%ISOPEN THEN
        CLOSE c_apcs;
      END IF;
      IF c_adm_appl_dtl%ISOPEN THEN
        CLOSE c_adm_appl_dtl;
      END IF;
      IF cur_ad_ps_appl_inst%ISOPEN THEN
        CLOSE cur_ad_ps_appl_inst;
      END IF;
  END validate_off_resp_dtls;

 PROCEDURE RECORD_OFFER_RESPONSE(
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id                 IN      NUMBER,
		    p_admission_appl_number 	IN      NUMBER,
		    p_nominated_program_cd   	IN      VARCHAR2,
		    p_sequence_number       	IN      NUMBER,
		    p_adm_offer_resp_status     IN      VARCHAR2, --Varchar2(10)  LOV(validation exists in Form(PLD))
		    p_actual_response_dt        IN      DATE,  --validation exists in form(pld)
		    p_response_comments   IN      VARCHAR2, --VARCHAR2(2000)
		    p_def_acad_cal_type         IN      VARCHAR2, --Varchar2(10)
		    p_def_acad_ci_sequence_num  IN      NUMBER,   --NUMBER(5)
		    p_def_adm_cal_type     IN      VARCHAR2, --Varchar2(10)
		    p_def_adm_ci_sequence_num  IN      NUMBER,   --NUMBER(5)
		    p_decline_ofr_reason	IN	VARCHAR2,
		    p_attent_other_inst_cd	IN	VARCHAR2
)
 AS
  l_api_version         CONSTANT    	NUMBER := '2.0';
  l_api_name  	    	CONSTANT    	VARCHAR2(30) := 'RECORD_OFFER_RESPONSE';
  l_msg_index                           NUMBER;
  l_return_status                       VARCHAR2(1);
  l_hash_msg_name_text_type_tab         igs_ad_gen_016.g_msg_name_text_type_table;
  l_validation_success                  VARCHAR2(1);
  l_calc_actual_response_dt             DATE;
  l_adm_offer_dfrmnt_status             VARCHAR2(10);

  l_response_comments        igs_ad_ps_appl_inst_all.applicant_acptnce_cndtn%TYPE;
  l_def_acad_cal_type        igs_ad_ps_appl_inst_all.def_acad_cal_type%TYPE;
  l_def_acad_ci_sequence_num igs_ad_ps_appl_inst_all.def_acad_ci_sequence_num%TYPE;
  l_def_adm_cal_type         igs_ad_ps_appl_inst_all.deferred_adm_cal_type%TYPE;
  l_def_adm_ci_sequence_num  igs_ad_ps_appl_inst_all.deferred_adm_ci_sequence_num%TYPE;
  l_decline_ofr_reason	     igs_ad_ps_appl_inst_all.decline_ofr_reason%TYPE;
  l_attent_other_inst_cd     igs_ad_ps_appl_inst_all.attent_other_inst_cd%TYPE;
  l_enrl_message_name VARCHAR2(30);

  CURSOR cur_ad_ps_appl_inst(  cp_person_id         igs_ad_ps_appl_inst.person_id%type ,
                            cp_admission_appl_number   igs_ad_ps_appl_inst.admission_appl_number%type ,
                            cp_nominated_course_cd     igs_ad_ps_appl_inst.nominated_course_cd%type,
			    cp_sequence_no            igs_ad_ps_appl_inst.sequence_number%type) IS
    SELECT  rowid , igs_ad_ps_appl_inst.*   from igs_ad_ps_appl_inst
    WHERE       person_id = cp_person_id   and
                admission_appl_number = cp_admission_appl_number and
                nominated_course_cd = cp_nominated_course_cd and
		sequence_number = cp_sequence_no;

  cur_ad_ps_appl_inst_rec   cur_ad_ps_appl_inst%ROWTYPE;

  x_dummy  VARCHAR2(2000);
 BEGIN
SAVEPOINT S_RECORD_OFFER_RESPONSE_PUB;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

l_msg_index := 0;
--All the standard functionality
     IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
l_msg_index := igs_ge_msg_stack.count_msg;
 --Assign all defaul values

-- Validate all the parameters for their length
     check_length('PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_person_id)));
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_admission_appl_number)));
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_PS_APPL_INST_ALL', length(p_nominated_program_cd));
     check_length('SEQUENCE_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_sequence_number)));
     check_length('ADM_OFFER_RESP_STATUS', 'IGS_AD_PS_APPL_INST_ALL', length(p_adm_offer_resp_status));
     check_length('APPLICANT_ACPTNCE_CNDTN', 'IGS_AD_PS_APPL_INST_ALL', length(p_response_comments));
--     check_length('ADM_OFFER_DFRMNT_STATUS', 'IGS_AD_PS_APPL_INST_ALL', length(p_adm_offer_dfrmnt_status));
     check_length('DEF_ACAD_CAL_TYPE', 'IGS_AD_PS_APPL_INST_ALL', length(p_def_acad_cal_type));
     check_length('DEF_ACAD_CI_SEQUENCE_NUM', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_def_acad_ci_sequence_num)));
     check_length('DEFERRED_ADM_CAL_TYPE', 'IGS_AD_PS_APPL_INST_ALL', length(p_def_adm_cal_type));
     check_length('DEFERRED_ADM_CI_SEQUENCE_NUM', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_def_adm_ci_sequence_num)));
     check_length('DECLINE_OFR_REASON', 'IGS_AD_PS_APPL_INST_ALL', length(p_decline_ofr_reason));
     check_length('ATTENT_OTHER_INST_CD', 'IGS_AD_PS_APPL_INST_ALL', length(p_attent_other_inst_cd));

  l_adm_offer_dfrmnt_status := NULL;

     OPEN cur_ad_ps_appl_inst(p_person_id,
                             p_admission_appl_number,
                             p_nominated_program_cd,
			     p_sequence_number);
    FETCH cur_ad_ps_appl_inst INTO cur_ad_ps_appl_inst_rec;
    CLOSE cur_ad_ps_appl_inst;

    IF p_adm_offer_resp_status = FND_API.G_MISS_CHAR OR p_adm_offer_resp_status IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_RESP_STATUS'));
      IGS_GE_MSG_STACK.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_actual_response_dt = FND_API.G_MISS_DATE THEN
       l_calc_actual_response_dt := null;
    END IF;

    IF p_response_comments = FND_API.G_MISS_CHAR THEN
       l_response_comments := NULL;
    ELSE
      l_response_comments := NVL(p_response_comments, cur_ad_ps_appl_inst_rec.applicant_acptnce_cndtn );
    END IF;

    IF p_def_acad_cal_type = FND_API.G_MISS_CHAR THEN
       l_def_acad_cal_type := NULL;
    ELSE
      l_def_acad_cal_type := NVL(p_def_acad_cal_type, cur_ad_ps_appl_inst_rec.def_acad_cal_type  );
    END IF;

    IF p_def_acad_ci_sequence_num = FND_API.G_MISS_NUM THEN
       l_def_acad_ci_sequence_num := NULL;
    ELSE
      l_def_acad_ci_sequence_num := NVL(p_def_acad_ci_sequence_num, cur_ad_ps_appl_inst_rec.def_acad_ci_sequence_num );
    END IF;

    IF p_def_adm_cal_type = FND_API.G_MISS_CHAR THEN
       l_def_adm_cal_type := NULL;
    ELSE
      l_def_adm_cal_type := NVL(p_def_adm_cal_type, cur_ad_ps_appl_inst_rec.deferred_adm_cal_type );
    END IF;

    IF p_def_adm_ci_sequence_num = FND_API.G_MISS_NUM THEN
       l_def_adm_ci_sequence_num := NULL;
    ELSE
      l_def_adm_ci_sequence_num := NVL(p_def_adm_ci_sequence_num, cur_ad_ps_appl_inst_rec.deferred_adm_ci_sequence_num );
    END IF;

    IF p_decline_ofr_reason = FND_API.G_MISS_CHAR THEN
       l_decline_ofr_reason := NULL;
    ELSE
      l_decline_ofr_reason := NVL(p_decline_ofr_reason, cur_ad_ps_appl_inst_rec.decline_ofr_reason );
    END IF;

    IF p_attent_other_inst_cd = FND_API.G_MISS_CHAR THEN
       l_attent_other_inst_cd := NULL;
    ELSE
      l_attent_other_inst_cd := NVL(p_attent_other_inst_cd, cur_ad_ps_appl_inst_rec.attent_other_inst_cd );
    END IF;

 --Validate all the parameter through function validate_off_resp_dtls, if validation fails then retun value will
 -- be stored in variable l_validation_success as 'N' else it will be 'Y'.
 validate_off_resp_dtls
 (
      p_person_id                   => p_person_id,
      p_admission_appl_number       => p_admission_appl_number,
      p_nominated_course_cd         => p_nominated_program_cd,
      p_sequence_number             => p_sequence_number,
      p_adm_offer_resp_status       => p_adm_offer_resp_status,
      p_actual_offer_response_dt    => p_actual_response_dt,
      p_applicant_acptnce_cndtn     => p_response_comments,
--      p_attent_other_inst_cd        => p_attent_other_inst_cd,
      p_adm_offer_defr_status       => l_adm_offer_dfrmnt_status,
--      p_authorized_dt               => p_authorized_dt,
--      p_authorizing_pers_id         => p_authorizing_pers_id,
      p_def_acad_cal_type           => p_def_acad_cal_type,
      p_def_acad_ci_sequence_number => p_def_acad_ci_sequence_num,
      p_def_adm_cal_type            => p_def_adm_cal_type,
      p_def_adm_ci_sequence_number  => p_def_adm_ci_sequence_num,
      p_decline_ofr_reason	    => l_decline_ofr_reason,
      p_attent_other_inst_cd        => l_attent_other_inst_cd,
      p_calc_actual_ofr_resp_dt     => l_calc_actual_response_dt,
--      p_yes_no                      => p_yes_no,
      p_validation_success          => l_validation_success

 );


 IF l_validation_success = 'Y' THEN


  IF NVL(IGS_AD_GEN_008.ADMP_GET_SAORS(cur_ad_ps_appl_inst_rec.adm_offer_resp_status), 'NULL') = 'ACCEPTED'
	 AND    NVL(IGS_AD_GEN_008.ADMP_GET_SAORS(p_adm_offer_resp_status), 'NULL') <> 'ACCEPTED'
			 THEN
	  -- UNCONFIRM the Student PROGRAM ATTEMPTS.   (api would be provided by enrolments team)
	IF NOT IGS_EN_VAL_SCA.handle_rederive_prog_att (p_person_id 		     =>  cur_ad_ps_appl_inst_rec.PERSON_ID ,
							  p_admission_appl_number    =>  cur_ad_ps_appl_inst_rec.ADMISSION_APPL_NUMBER ,
							  p_nominated_course_cd      =>  cur_ad_ps_appl_inst_rec.NOMINATED_COURSE_CD ,
							  p_sequence_number 	     =>  cur_ad_ps_appl_inst_rec.SEQUENCE_NUMBER ,
							  p_message 		     =>	 x_dummy
							 )
	 THEN


		App_Exception.Raise_Exception;

	 END IF;
  END IF;




   IGS_AD_PS_APPL_INST_PKG.UPDATE_ROW (
      X_Mode                              => 'R',
      X_RowId                             => cur_ad_ps_appl_inst_rec.row_id,
      X_Person_Id                         => cur_ad_ps_appl_inst_rec.Person_Id,
      X_Admission_Appl_Number             => cur_ad_ps_appl_inst_rec.Admission_Appl_Number,
      X_Nominated_Course_Cd               => cur_ad_ps_appl_inst_rec.Nominated_Course_Cd,
      X_Sequence_Number                   => cur_ad_ps_appl_inst_rec.Sequence_Number,
      X_Predicted_Gpa                     => cur_ad_ps_appl_inst_rec.Predicted_Gpa,
      X_Academic_Index                    => cur_ad_ps_appl_inst_rec.Academic_Index,
      X_Adm_Cal_Type                      => cur_ad_ps_appl_inst_rec.Adm_Cal_Type,
      X_App_File_Location                 => cur_ad_ps_appl_inst_rec.App_File_Location,
      X_Adm_Ci_Sequence_Number            => cur_ad_ps_appl_inst_rec.Adm_Ci_Sequence_Number,
      X_Course_Cd                         => cur_ad_ps_appl_inst_rec.Course_Cd,
      X_App_Source_Id                     => cur_ad_ps_appl_inst_rec.App_Source_Id,
      X_Crv_Version_Number                => cur_ad_ps_appl_inst_rec.Crv_Version_Number,
      X_Waitlist_Rank                     => cur_ad_ps_appl_inst_rec.Waitlist_Rank,
      X_Location_Cd                       => cur_ad_ps_appl_inst_rec.Location_Cd,
      X_Attent_Other_Inst_Cd              => l_attent_other_inst_cd, --
      X_Attendance_Mode                   => cur_ad_ps_appl_inst_rec.Attendance_Mode,
      X_Edu_Goal_Prior_Enroll_Id          => cur_ad_ps_appl_inst_rec.Edu_Goal_Prior_Enroll_Id,
      X_Attendance_Type                   => cur_ad_ps_appl_inst_rec.Attendance_Type,
      X_Decision_Make_Id                  => cur_ad_ps_appl_inst_rec.Decision_Make_Id,
      X_Unit_Set_Cd                       => cur_ad_ps_appl_inst_rec.Unit_Set_Cd,
      X_Decision_Date                     => cur_ad_ps_appl_inst_rec.Decision_Date,
      X_Attribute_Category                => cur_ad_ps_appl_inst_rec.Attribute_Category,
      X_Attribute1                        => cur_ad_ps_appl_inst_rec.Attribute1,
      X_Attribute2                        => cur_ad_ps_appl_inst_rec.Attribute2,
      X_Attribute3                        => cur_ad_ps_appl_inst_rec.Attribute3,
      X_Attribute4                        => cur_ad_ps_appl_inst_rec.Attribute4,
      X_Attribute5                        => cur_ad_ps_appl_inst_rec.Attribute5,
      X_Attribute6                        => cur_ad_ps_appl_inst_rec.Attribute6,
      X_Attribute7                        => cur_ad_ps_appl_inst_rec.Attribute7,
      X_Attribute8                        => cur_ad_ps_appl_inst_rec.Attribute8,
      X_Attribute9                        => cur_ad_ps_appl_inst_rec.Attribute9,
      X_Attribute10                       => cur_ad_ps_appl_inst_rec.Attribute10,
      X_Attribute11                       => cur_ad_ps_appl_inst_rec.Attribute11,
      X_Attribute12                       => cur_ad_ps_appl_inst_rec.Attribute12,
      X_Attribute13                       => cur_ad_ps_appl_inst_rec.Attribute13,
      X_Attribute14                       => cur_ad_ps_appl_inst_rec.Attribute14,
      X_Attribute15                       => cur_ad_ps_appl_inst_rec.Attribute15,
      X_Attribute16                       => cur_ad_ps_appl_inst_rec.Attribute16,
      X_Attribute17                       => cur_ad_ps_appl_inst_rec.Attribute17,
      X_Attribute18                       => cur_ad_ps_appl_inst_rec.Attribute18,
      X_Attribute19                       => cur_ad_ps_appl_inst_rec.Attribute19,
      X_Attribute20                       => cur_ad_ps_appl_inst_rec.Attribute20,
      X_Decision_Reason_Id                => cur_ad_ps_appl_inst_rec.decision_reason_id,
      X_Us_Version_Number                 => cur_ad_ps_appl_inst_rec.Us_Version_Number,
      X_Decision_Notes                    => cur_ad_ps_appl_inst_rec.Decision_Notes,
      X_Pending_Reason_Id                 => cur_ad_ps_appl_inst_rec.Pending_Reason_Id,
      X_Preference_Number                 => cur_ad_ps_appl_inst_rec.Preference_Number,
      X_Adm_Doc_Status                    => cur_ad_ps_appl_inst_rec.Adm_Doc_Status,
      X_Adm_Entry_Qual_Status             => cur_ad_ps_appl_inst_rec.Adm_Entry_Qual_Status,
      X_Deficiency_In_Prep                => cur_ad_ps_appl_inst_rec.Deficiency_In_Prep,
      X_Late_Adm_Fee_Status               => cur_ad_ps_appl_inst_rec.Late_Adm_Fee_Status,
      X_Spl_Consider_Comments             => cur_ad_ps_appl_inst_rec.Spl_Consider_Comments,
      X_Apply_For_Finaid                  => cur_ad_ps_appl_inst_rec.Apply_For_Finaid,
      X_Finaid_Apply_Date                 => cur_ad_ps_appl_inst_rec.Finaid_Apply_Date,
      X_Adm_Outcome_Status                => cur_ad_ps_appl_inst_rec.Adm_Outcome_Status,
      X_Adm_Otcm_Stat_Auth_Per_Id         => cur_ad_ps_appl_inst_rec.Adm_Otcm_Status_Auth_Person_Id,
      X_Adm_Outcome_Status_Auth_Dt        => cur_ad_ps_appl_inst_rec.Adm_Outcome_Status_Auth_Dt,
      X_Adm_Outcome_Status_Reason         => cur_ad_ps_appl_inst_rec.Adm_Outcome_Status_Reason,
      X_Offer_Dt                          => cur_ad_ps_appl_inst_rec.Offer_Dt,
      X_Offer_Response_Dt                 => cur_ad_ps_appl_inst_rec.Offer_Response_Dt,
      X_Prpsd_Commencement_Dt             => cur_ad_ps_appl_inst_rec.Prpsd_Commencement_Dt,
      X_Adm_Cndtnl_Offer_Status           => cur_ad_ps_appl_inst_rec.Adm_Cndtnl_Offer_Status,
      X_Cndtnl_Offer_Satisfied_Dt         => cur_ad_ps_appl_inst_rec.Cndtnl_Offer_Satisfied_Dt,
      X_Cndnl_Ofr_Must_Be_Stsfd_Ind       => cur_ad_ps_appl_inst_rec.Cndtnl_Offer_Must_Be_Stsfd_Ind,
      X_Adm_Offer_Resp_Status             => p_adm_offer_resp_status,     -- Updated field
      X_Actual_Response_Dt                => l_calc_actual_response_dt, --Updated field
      X_Adm_Offer_Dfrmnt_Status           => l_adm_offer_dfrmnt_status, --Updated Field
      X_Deferred_Adm_Cal_Type             => l_def_adm_cal_type, --Updated Field
      X_Deferred_Adm_Ci_Sequence_Num      => l_def_adm_ci_sequence_num, --Updated field
      X_Deferred_Tracking_Id              => NULL,
      X_Ass_Rank                          => cur_ad_ps_appl_inst_rec.Ass_Rank,
      X_Secondary_Ass_Rank                => cur_ad_ps_appl_inst_rec.Secondary_Ass_Rank,
      X_Intr_Accept_Advice_Num            => cur_ad_ps_appl_inst_rec.Intrntnl_Acceptance_Advice_Num,
      X_Ass_Tracking_Id                   => cur_ad_ps_appl_inst_rec.Ass_Tracking_Id,
      X_Fee_Cat                           => cur_ad_ps_appl_inst_rec.Fee_Cat,
      X_Hecs_Payment_Option               => cur_ad_ps_appl_inst_rec.Hecs_Payment_Option,
      X_Expected_Completion_Yr            => cur_ad_ps_appl_inst_rec.Expected_Completion_Yr,
      X_Expected_Completion_Perd          => cur_ad_ps_appl_inst_rec.Expected_Completion_Perd,
      X_Correspondence_Cat                => cur_ad_ps_appl_inst_rec.Correspondence_Cat,
      X_Enrolment_Cat                     => cur_ad_ps_appl_inst_rec.Enrolment_Cat,
      X_Funding_Source                    => cur_ad_ps_appl_inst_rec.Funding_Source,
      X_Applicant_Acptnce_Cndtn           => l_response_comments, --Updated Field
      X_Cndtnl_Offer_Cndtn                => cur_ad_ps_appl_inst_rec.Cndtnl_Offer_Cndtn,
      X_SS_APPLICATION_ID                 => NULL,
      X_SS_PWD                            => NULL   ,
      X_AUTHORIZED_DT                     => cur_ad_ps_appl_inst_rec.authorized_dt,--
      X_AUTHORIZING_PERS_ID               => cur_ad_ps_appl_inst_rec.authorizing_pers_id,--
      X_ENTRY_STATUS                      => cur_ad_ps_appl_inst_rec.entry_status,
      X_ENTRY_LEVEL                       => cur_ad_ps_appl_inst_rec.entry_level,
      X_SCH_APL_TO_ID                     => cur_ad_ps_appl_inst_rec.sch_apl_to_id,
      X_IDX_CALC_DATE                     => cur_ad_ps_appl_inst_rec.IDX_CALC_DATE,
      X_WAITLIST_STATUS                   => cur_ad_ps_appl_inst_rec.Waitlist_Status,
      X_Attribute21                       => cur_ad_ps_appl_inst_rec.Attribute21,
      X_Attribute22                       => cur_ad_ps_appl_inst_rec.Attribute22,
      X_Attribute23                       => cur_ad_ps_appl_inst_rec.Attribute23,
      X_Attribute24                       => cur_ad_ps_appl_inst_rec.Attribute24,
      X_Attribute25                       => cur_ad_ps_appl_inst_rec.Attribute25,
      X_Attribute26                       => cur_ad_ps_appl_inst_rec.Attribute26,
      X_Attribute27                       => cur_ad_ps_appl_inst_rec.Attribute27,
      X_Attribute28                       => cur_ad_ps_appl_inst_rec.Attribute28,
      X_Attribute29                       => cur_ad_ps_appl_inst_rec.Attribute29,
      X_Attribute30                       => cur_ad_ps_appl_inst_rec.Attribute30,
      X_Attribute31                       => cur_ad_ps_appl_inst_rec.Attribute31,
      X_Attribute32                       => cur_ad_ps_appl_inst_rec.Attribute32,
      X_Attribute33                       => cur_ad_ps_appl_inst_rec.Attribute33,
      X_Attribute34                       => cur_ad_ps_appl_inst_rec.Attribute34,
      X_Attribute35                       => cur_ad_ps_appl_inst_rec.Attribute35,
      X_Attribute36                       => cur_ad_ps_appl_inst_rec.Attribute36,
      X_Attribute37                       => cur_ad_ps_appl_inst_rec.Attribute37,
      X_Attribute38                       => cur_ad_ps_appl_inst_rec.Attribute38,
      X_Attribute39                       => cur_ad_ps_appl_inst_rec.Attribute39,
      X_Attribute40                       => cur_ad_ps_appl_inst_rec.Attribute40,
      x_fut_acad_cal_type                 => cur_ad_ps_appl_inst_rec.future_acad_cal_type,
      x_fut_acad_ci_sequence_number       => cur_ad_ps_appl_inst_rec.future_acad_ci_sequence_number,
      x_fut_adm_cal_type                  => cur_ad_ps_appl_inst_rec.future_adm_cal_type,
      x_fut_adm_ci_sequence_number        => cur_ad_ps_appl_inst_rec.future_adm_ci_sequence_number,
      x_prev_term_adm_appl_number         => cur_ad_ps_appl_inst_rec.previous_term_adm_appl_number,
      x_prev_term_sequence_number         => cur_ad_ps_appl_inst_rec.previous_term_sequence_number,
      x_fut_term_adm_appl_number          => cur_ad_ps_appl_inst_rec.future_term_adm_appl_number,
      x_fut_term_sequence_number          => cur_ad_ps_appl_inst_rec.future_term_sequence_number,
      x_def_acad_cal_type                 => l_def_acad_cal_type,--Updated field
      x_def_acad_ci_sequence_num          => l_def_acad_ci_sequence_num,--Updated field
      x_def_prev_term_adm_appl_num        => cur_ad_ps_appl_inst_rec.def_prev_term_adm_appl_num,
      x_def_prev_appl_sequence_num        => cur_ad_ps_appl_inst_rec.def_prev_appl_sequence_num,
      x_def_term_adm_appl_num             => cur_ad_ps_appl_inst_rec.def_term_adm_appl_num,
      x_def_appl_sequence_num             => cur_ad_ps_appl_inst_rec.def_appl_sequence_num,
      x_decline_ofr_reason                => l_decline_ofr_reason,
      X_APPL_INST_STATUS		  => cur_ad_ps_appl_inst_rec.appl_inst_status,
      x_ais_reason			  => cur_ad_ps_appl_inst_rec.ais_reason
      );

      IF NVL(IGS_AD_GEN_008.ADMP_GET_SAORS(p_adm_offer_resp_status), 'NULL') = 'ACCEPTED' THEN
          IF igs_ad_upd_initialise.perform_pre_enrol(cur_ad_ps_appl_inst_rec.Person_Id,
						 cur_ad_ps_appl_inst_rec.Admission_Appl_Number,
						 cur_ad_ps_appl_inst_rec.Nominated_Course_Cd,
						 cur_ad_ps_appl_inst_rec.Sequence_Number,
						 'Y',                     -- Confirm course indicator.
						 'Y',                     -- Perform eligibility check indicator.
						 l_enrl_message_name) = FALSE THEN
	        FND_MESSAGE.SET_NAME('IGS',l_enrl_message_name);
	        IGS_GE_MSG_STACK.ADD;
	        RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF FND_API.To_Boolean( p_commit ) THEN
	 COMMIT;
      END IF;
 ELSE
    RAISE FND_API.G_EXC_ERROR;
 END IF;
--check the outcome status
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

--		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in API: FND_API.G_EXC_ERROR : '||SQLERRM);
		ROLLBACK TO s_RECORD_OFFER_RESPONSE_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
	    x_msg_count := x_msg_count-1;
      IF cur_ad_ps_appl_inst%ISOPEN THEN
        CLOSE cur_ad_ps_appl_inst;
      END IF;
WHEN OTHERS THEN
--		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in API: FND_API.G_EXC_ERROR : '||SQLERRM);
		ROLLBACK TO s_RECORD_OFFER_RESPONSE_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-1).text;
      IF cur_ad_ps_appl_inst%ISOPEN THEN
        CLOSE cur_ad_ps_appl_inst;
      END IF;
 END RECORD_OFFER_RESPONSE;

PROCEDURE RECORD_QUALIFICATION_CODE(
                    p_api_version           	IN	NUMBER				,
		    p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE	,
		    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
		    p_validation_level		IN  	NUMBER	:=
		    					FND_API.G_VALID_LEVEL_FULL	,
		    p_person_id                 IN      NUMBER,
		    p_admission_appl_number     IN      NUMBER,
		    p_nominated_course_cd       IN      VARCHAR2,
		    p_sequence_number           IN      NUMBER,
		    p_qualifying_type_code      IN      VARCHAR2,
	            p_qualifying_code           IN      VARCHAR2,
		    p_qualifying_value          IN      VARCHAR2,
		    x_return_status             OUT     NOCOPY    VARCHAR2,
		    x_msg_count		        OUT     NOCOPY    NUMBER,
		    x_msg_data                  OUT     NOCOPY    VARCHAR2
)
 AS
  l_api_version         CONSTANT    	NUMBER := '1.0';
  l_api_name  	    	CONSTANT    	VARCHAR2(30) := 'RECORD_QUALIFICATION_CODE';
  l_msg_index                           NUMBER;
  l_return_status                       VARCHAR2(1);
  l_hash_msg_name_text_type_tab         igs_ad_gen_016.g_msg_name_text_type_table;

  l_qualifying_type_code      VARCHAR2(30);
  l_qualifying_code      VARCHAR2(30);
  l_qualifying_value      VARCHAR2(80);



-- All records selected from application Instance Tables

CURSOR c_acai (	p_person_id 	NUMBER,
                p_admission_appl_number	  NUMBER,
                p_nominated_course_cd	VARCHAR,
                p_sequence_number  NUMBER)	 IS
SELECT
    a.*
FROM
     igs_ad_ps_appl_inst a,
     igs_ad_ou_stat c
WHERE a.person_id = p_person_id
   AND a.admission_appl_number	= p_admission_appl_number
   AND a.nominated_course_cd	= p_nominated_course_cd
   AND a.sequence_number	= p_sequence_number
   AND a.adm_outcome_status    = c.adm_outcome_status
   AND c.s_adm_outcome_status  = 'PENDING';

  l_appl_inst_rec       c_acai%ROWTYPE;

CURSOR c_qualtype (p_person_id 	IN NUMBER,
                p_admission_appl_number	IN  NUMBER,
                p_nominated_course_cd	IN VARCHAR,
                p_sequence_number  IN NUMBER,
		p_qualfying_type IN VARCHAR2 )	 IS
SELECT ac.rowid,ac.* FROM IGS_AD_APPQUAL_CODE ac WHERE
       PERSON_ID = p_person_id
       AND ADMISSION_APPL_NUMBER = p_admission_appl_number
       AND NOMINATED_COURSE_CD = p_nominated_course_cd
       AND SEQUENCE_NUMBER = p_sequence_number
       AND qualifying_type_code = p_qualfying_type;
  l_qualtype       c_qualtype%ROWTYPE;

CURSOR c_qualcode(cp_qual_code IN VARCHAR2,
                  cp_qual_type_code IN VARCHAR2) IS
SELECT code_id FROM IGS_AD_CODE_CLASSES ac WHERE
UPPER(ac.NAME)=UPPER(cp_qual_code) AND ac.CLASS_TYPE_CODE='IGS_AD_QUAL_TYPE'
AND UPPER(ac.CLASS) = UPPER(cp_qual_type_code);

l_qualcode     c_qualcode%ROWTYPE;
l_code_id IGS_AD_CODE_CLASSES.CODE_ID%TYPE;

 BEGIN
  l_msg_index   := 0;
     SAVEPOINT RECORD_QUALIFICATION_CODE_pub;
     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
     l_msg_index := igs_ge_msg_stack.count_msg;

-- Validate all the parameters for their length
-- PERSON_ID
     check_length('PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_person_id)));
-- P_ADMISSION_APPL_NUMBER
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_admission_appl_number)));
-- p_nominated_course_cd
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_PS_APPL_INST_ALL', length(p_nominated_course_cd));
-- P_SEQUENCE_NUMBER
     check_length('SEQUENCE_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_sequence_number)));
-- P_qualifying_type_code
     check_length('QUALIFYING_TYPE_CODE', 'IGS_AD_APPQUAL_CODE', length(p_qualifying_type_code));
-- P_QUALIFYING_CODE
     check_length('NAME', 'IGS_AD_CODE_CLASSES', length(p_qualifying_code));
-- P_QUALIFYING_VALUE
     check_length('QUALIFYING_VALUE', 'IGS_AD_APPQUAL_CODE', length(p_qualifying_value));
-- END OF PARAMETER VALIDATIONS.

  IF p_person_id  = FND_API.G_MISS_NUM OR p_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_PERSON_ID');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_admission_appl_number  = FND_API.G_MISS_NUM OR p_admission_appl_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_ADMISSION_APPL_NUMBER');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_nominated_course_cd  = FND_API.G_MISS_CHAR OR p_nominated_course_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_NOMINATED_COURSE_CD');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_sequence_number  = FND_API.G_MISS_NUM OR p_sequence_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_SEQUENCE_NUMBER');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_qualifying_type_code  = FND_API.G_MISS_CHAR OR p_qualifying_type_code IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_QUALIFYING_TYPE_CODE');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
  END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/*        OPEN C_ACAI(p_person_id,
               p_admission_appl_number,
               p_nominated_course_cd,
               p_sequence_number);
        FETCH c_acai INTO l_appl_inst_rec;
        IF c_acai%NOTFOUND THEN --If no application instance exists for this application
	                        --with s_adm_outcome_status  = 'PENDING'
        ROLLBACK TO RECORD_QUALIFICATION_CODE_pub;
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACDX_NO_APPL');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
	ELSIF c_acai%FOUND THEN */
     	  ------------------------------
	  --Intialization of varable to handle G_MISS_CHAR/NUM/DATE
	  -------------------------------
	  IF  p_qualifying_type_code = FND_API.G_MISS_CHAR THEN
            l_qualifying_type_code := NULL;
	  ELSE
	     l_qualifying_type_code := p_qualifying_type_code;
          END IF;

	  IF p_qualifying_code = FND_API.G_MISS_CHAR THEN
	    l_qualifying_code := NULL;
	  ELSE
	    l_qualifying_code := p_qualifying_code;
	  END IF;

	  IF p_qualifying_value = FND_API.G_MISS_CHAR THEN
	    l_qualifying_value := NULL;
	  ELSE
	    l_qualifying_value := p_qualifying_value;
	  END IF;

--Check whthere provided qualifying Type exists for this application or not.
--You can move this code to TBH of this table.
l_qualtype := NULL;
       OPEN c_qualtype(p_person_id,
               p_admission_appl_number,
               p_nominated_course_cd,
               p_sequence_number,
	       l_qualifying_type_code);
       FETCH c_qualtype INTO l_qualtype;
       IF c_qualtype%NOTFOUND THEN
       CLOSE c_qualtype;
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_QUAL_TYPE_ERROR');
        FND_MESSAGE.SET_TOKEN('QUALIFYING_TYPE',l_qualifying_type_code);
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_qualtype;

--Check if any qual code is there for current qual type and user is trying to pass qual value.
IF l_qualifying_value IS NOT NULL AND l_qualifying_code IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_QUAL_CODE_VAL');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
END IF;


--Check if any qual code is there for current qual type and user is trying to pass qual value.
IF l_qualifying_value IS NOT NULL AND l_qualtype.QUALIFYING_CODE_ID IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_DUP_QUAL_CODE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE1','QUALIFYING CODE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE2','QUALIFYING VALUE');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
END IF;

--Check if any qual value is there for current qual type and user is trying to pass qual code.
IF l_qualifying_code IS NOT NULL AND l_qualtype.QUALIFYING_VALUE IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_DUP_QUAL_CODE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE1','QUALIFYING VALUE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE2','QUALIFYING CODE');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
END IF;
--will be done in TBH
IF l_qualifying_code IS NOT NULL THEN
OPEN c_qualcode(l_qualifying_code,l_qualifying_type_code);
FETCH c_qualcode INTO l_qualcode;
CLOSE c_qualcode;
   IF l_qualcode.code_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_QUAL_CODE_ERROR');
        FND_MESSAGE.SET_TOKEN('QUALIFYING_CODE',l_qualifying_code);
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
   ELSE
   l_code_id := l_qualcode.code_id;
   END IF;
END IF;

--Check if any qual code is already exists.
IF l_code_id = l_qualtype.qualifying_code_id THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_QUAL_EXISTS');
        FND_MESSAGE.SET_TOKEN('QUALIFYING_CODE',l_qualifying_code);
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
END IF;

--Check if any qual code is already exists.
IF l_qualifying_value = l_qualtype.qualifying_value THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_QUAL_VAL_EXISTS');
        FND_MESSAGE.SET_TOKEN('QUALIFYING_VALUE',l_qualifying_value);
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
END IF;
--Call TBH
igs_ad_appqual_code_pkg.UPDATE_ROW(
    x_rowid                   => l_qualtype.rowid,
    x_person_id               => p_person_id,
    x_admission_appl_number   => p_admission_appl_number,
    x_nominated_course_cd     => p_nominated_course_cd,
    x_sequence_number         => p_sequence_number,
    x_qualifying_type_code    => l_qualifying_type_code,
    x_qualifying_code_id      => l_code_id,
    x_qualifying_value        => l_qualifying_value,
    x_mode                    => 'R'
);

 	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
EXCEPTION
	WHEN FND_API.G_EXC_ERROR  THEN
		ROLLBACK TO RECORD_QUALIFICATION_CODE_pub;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
	    x_msg_count := x_msg_count-1;
      IF (x_msg_count = 0) THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        FND_MSG_PUB.ADD;
        x_msg_data := 'IGS_GE_UNHANDLED_EXCEPTION';
      ELSE
        x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count - 1).name;
        FND_MESSAGE.SET_NAME(l_hash_msg_name_text_type_tab(x_msg_count - 1).appl,
                             x_msg_data);
        FND_MSG_PUB.ADD;
        x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count - 1).text;
      END IF;

--		FND_FILE.PUT_LINE(FND_FILE.LOG, 'aFTER STACK Exception in API: FND_API.G_EXC_ERROR : '|| l_hash_msg_name_text_type_tab(x_msg_count-2).text);
        IF c_acai%ISOPEN THEN
        CLOSE c_acai;
	END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RECORD_QUALIFICATION_CODE_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      WHEN OTHERS THEN
      ROLLBACK TO RECORD_QUALIFICATION_CODE_pub;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
          IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	  ELSE
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  END IF;
        IF c_acai%ISOPEN THEN
        CLOSE c_acai;
	END IF;
 END RECORD_QUALIFICATION_CODE;


PROCEDURE UPDATE_ENTRY_QUAL_STATUS(
                    --Standard Parameters Start
                    p_api_version           IN      NUMBER,
		    p_init_msg_list         IN      VARCHAR2  := FND_API.G_FALSE,
		    p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
		    p_validation_level      IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		    x_return_status         OUT     NOCOPY    VARCHAR2,
		    x_msg_count		    OUT     NOCOPY    NUMBER,
		    x_msg_data              OUT     NOCOPY    VARCHAR2,
                    --Standard parameter ends
                    p_person_id             IN      NUMBER,
		    p_admission_appl_number IN      NUMBER,
		    p_nominated_program_cd  IN      VARCHAR2,
		    p_sequence_number       IN      NUMBER,
		    p_entry_qual_status     IN      VARCHAR2
                   )
  AS
        -- Declaration of the location variables
        l_api_version CONSTANT NUMBER := '1.0';
        l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_ENTRY_QUAL_STATUS';
        l_msg_index NUMBER;
        l_return_status VARCHAR2(1);
        l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;
        l_entry_qual_status VARCHAR2(10);
        v_message_name VARCHAR2(30);



        -- Cursor to fetch the application instance record details for a given set of person id, application number
        -- nominated course code and sequence number

	CURSOR c_acai (	cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                        cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                        cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                        cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE)
        IS
          SELECT aplinst.*, aplinst.rowid
          FROM igs_ad_ps_appl_inst aplinst
          WHERE aplinst.person_id = cp_person_id
          AND aplinst.admission_appl_number = cp_admission_appl_number
          AND aplinst.nominated_course_cd = cp_nominated_course_cd
          AND aplinst.sequence_number = cp_sequence_number;

        l_appl_inst_rec       c_acai%ROWTYPE;

        -- Cursor to fetch the system admission process type of the admission application
	CURSOR c_appl (cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                       cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE)
	IS
	  SELECT appl.s_admission_process_type
	  FROM igs_ad_appl_all appl
	  WHERE appl.person_id = cp_person_id
          AND appl.admission_appl_number = cp_admission_appl_number;

       l_s_admission_process_type igs_ad_appl_all.s_admission_process_type%TYPE;

 BEGIN
    l_msg_index   := 0;
    SAVEPOINT UPDATE_ENTRY_QUAL_STATUS_SAVE;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    l_msg_index := igs_ge_msg_stack.count_msg;


    -- Validate all the parameters for their length
    -- person_id
     check_length('PERSON_ID', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_person_id)));

    -- p_admission_appl_number
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_admission_appl_number)));

    -- p_nominated_course_cd
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_PS_APPL_INST_ALL', length(p_nominated_program_cd));

    -- p_sequence_number
     check_length('SEQUENCE_NUMBER', 'IGS_AD_PS_APPL_INST_ALL', length(TRUNC(p_sequence_number)));

    -- p_entry_qual_status
     check_length('ADM_ENTRY_QUAL_STATUS', 'IGS_AD_PS_APPL_INST_ALL', length(p_entry_qual_status));

    -- end of parameter validations.

    -- Show appropriate message when the parameter values are missing

    IF p_person_id  = FND_API.G_MISS_NUM OR p_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_PERSON_ID');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_admission_appl_number  = FND_API.G_MISS_NUM OR p_admission_appl_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_ADMISSION_APPL_NUMBER');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_nominated_program_cd  = FND_API.G_MISS_CHAR OR p_nominated_program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_NOMINATED_PROGRAM_CD');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_sequence_number  = FND_API.G_MISS_NUM OR p_sequence_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_SEQUENCE_NUMBER');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_entry_qual_status  = FND_API.G_MISS_CHAR OR p_entry_qual_status IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_ENTRY_QUAL_STATUS');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


    --Intialization of varable to handle G_MISS_CHAR/NUM/DATE
      l_entry_qual_status := p_entry_qual_status;


    -- Open the cursor c_acai to fetch the application instance record for the combination given
    OPEN c_acai(p_person_id, p_admission_appl_number, p_nominated_program_cd, p_sequence_number);
    FETCH c_acai INTO l_appl_inst_rec;
    CLOSE c_acai;

      IF l_appl_inst_rec.person_id IS NULL THEN
        fnd_message.set_name('IGS', 'IGS_AD_INVALID_PARAM_COMB');
        IGS_GE_MSG_STACK.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;

    -- Open the cursor c_appl to fetch the system admission process type for the application
    OPEN c_appl(p_person_id, p_admission_appl_number);
    FETCH c_appl INTO l_s_admission_process_type;
    CLOSE c_appl;


    -- Validate the admission entry qualification status
    IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aeqs (
         p_entry_qual_status,
         l_appl_inst_rec.adm_outcome_status,
         l_s_admission_process_type,
         v_message_name) = FALSE THEN
        fnd_message.set_name('IGS', v_message_name);
        IGS_GE_MSG_STACK.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update the application instance record with the new value of entry qualification status
    igs_ad_ps_appl_inst_pkg.UPDATE_ROW (
           X_Mode                              =>  'S',
           X_RowId                             =>  l_appl_inst_rec.rowId,
           X_Person_Id                         =>  p_person_id,
           X_Admission_Appl_Number             =>  p_admission_appl_number,
           X_Nominated_Course_Cd               =>  p_nominated_program_cd,
           X_Sequence_Number                   =>  p_sequence_number,
           X_Predicted_Gpa                     =>  l_appl_inst_rec.Predicted_Gpa,
           X_Academic_Index                    =>  l_appl_inst_rec.Academic_Index,
           X_Adm_Cal_Type                      =>  l_appl_inst_rec.Adm_Cal_Type,
           X_App_File_Location                 =>  l_appl_inst_rec.App_File_Location,
           X_Adm_Ci_Sequence_Number            =>  l_appl_inst_rec.Adm_Ci_Sequence_Number,
           X_Course_Cd                         =>  l_appl_inst_rec.Course_Cd,
           X_App_Source_Id                     =>  l_appl_inst_rec.App_Source_Id,
           X_Crv_Version_Number                =>  l_appl_inst_rec.Crv_Version_Number,
           X_Waitlist_Rank                     =>  l_appl_inst_rec.Waitlist_Rank,
           X_Location_Cd                       =>  l_appl_inst_rec.Location_Cd,
           X_Attent_Other_Inst_Cd              =>  l_appl_inst_rec.Attent_Other_Inst_Cd,
           X_Attendance_Mode                   =>  l_appl_inst_rec.Attendance_Mode,
           X_Edu_Goal_Prior_Enroll_Id          =>  l_appl_inst_rec.Edu_Goal_Prior_Enroll_Id,
           X_Attendance_Type                   =>  l_appl_inst_rec.Attendance_Type,
           X_Decision_Make_Id                  =>  l_appl_inst_rec.Decision_Make_Id,
           X_Unit_Set_Cd                       =>  l_appl_inst_rec.Unit_Set_Cd,
           X_Decision_Date                     =>  l_appl_inst_rec.Decision_Date,
           X_Attribute_Category                =>  l_appl_inst_rec.Attribute_Category,
           X_Attribute1                        =>  l_appl_inst_rec.Attribute1,
           X_Attribute2                        =>  l_appl_inst_rec.Attribute2,
           X_Attribute3                        =>  l_appl_inst_rec.Attribute3,
           X_Attribute4                        =>  l_appl_inst_rec.Attribute4,
           X_Attribute5                        =>  l_appl_inst_rec.Attribute5,
           X_Attribute6                        =>  l_appl_inst_rec.Attribute6,
           X_Attribute7                        =>  l_appl_inst_rec.Attribute7,
           X_Attribute8                        =>  l_appl_inst_rec.Attribute8,
           X_Attribute9                        =>  l_appl_inst_rec.Attribute9,
           X_Attribute10                       =>  l_appl_inst_rec.Attribute10,
           X_Attribute11                       =>  l_appl_inst_rec.Attribute11,
           X_Attribute12                       =>  l_appl_inst_rec.Attribute12,
           X_Attribute13                       =>  l_appl_inst_rec.Attribute13,
           X_Attribute14                       =>  l_appl_inst_rec.Attribute14,
           X_Attribute15                       =>  l_appl_inst_rec.Attribute15,
           X_Attribute16                       =>  l_appl_inst_rec.Attribute16,
           X_Attribute17                       =>  l_appl_inst_rec.Attribute17,
           X_Attribute18                       =>  l_appl_inst_rec.Attribute18,
           X_Attribute19                       =>  l_appl_inst_rec.Attribute19,
           X_Attribute20                       =>  l_appl_inst_rec.Attribute20,
           X_Attribute21                       =>  l_appl_inst_rec.Attribute21,
           X_Attribute22                       =>  l_appl_inst_rec.Attribute22,
           X_Attribute23                       =>  l_appl_inst_rec.Attribute23,
           X_Attribute24                       =>  l_appl_inst_rec.Attribute24,
           X_Attribute25                       =>  l_appl_inst_rec.Attribute25,
           X_Attribute26                       =>  l_appl_inst_rec.Attribute26,
           X_Attribute27                       =>  l_appl_inst_rec.Attribute27,
           X_Attribute28                       =>  l_appl_inst_rec.Attribute28,
           X_Attribute29                       =>  l_appl_inst_rec.Attribute29,
           X_Attribute30                       =>  l_appl_inst_rec.Attribute30,
           X_Attribute31                       =>  l_appl_inst_rec.Attribute31,
           X_Attribute32                       =>  l_appl_inst_rec.Attribute32,
           X_Attribute33                       =>  l_appl_inst_rec.Attribute33,
           X_Attribute34                       =>  l_appl_inst_rec.Attribute34,
           X_Attribute35                       =>  l_appl_inst_rec.Attribute35,
           X_Attribute36                       =>  l_appl_inst_rec.Attribute36,
           X_Attribute37                       =>  l_appl_inst_rec.Attribute37,
           X_Attribute38                       =>  l_appl_inst_rec.Attribute38,
           X_Attribute39                       =>  l_appl_inst_rec.Attribute39,
           X_Attribute40                       =>  l_appl_inst_rec.Attribute40,
           X_Decision_Reason_Id                =>  l_appl_inst_rec.Decision_Reason_Id,
           X_Us_Version_Number                 =>  l_appl_inst_rec.Us_Version_Number,
           X_Decision_Notes                    =>  l_appl_inst_rec.Decision_Notes,
           X_Pending_Reason_Id                 =>  l_appl_inst_rec.Pending_Reason_Id,
           X_Preference_Number                 =>  l_appl_inst_rec.Preference_Number,
           X_Adm_Doc_Status                    =>  l_appl_inst_rec.Adm_Doc_Status,
           X_Adm_Entry_Qual_Status             =>  l_entry_qual_status,
           X_Deficiency_In_Prep                =>  l_appl_inst_rec.Deficiency_In_Prep,
           X_Late_Adm_Fee_Status               =>  l_appl_inst_rec.Late_Adm_Fee_Status,
           X_Spl_Consider_Comments             =>  l_appl_inst_rec.Spl_Consider_Comments,
           X_Apply_For_Finaid                  =>  l_appl_inst_rec.Apply_For_Finaid,
           X_Finaid_Apply_Date                 =>  l_appl_inst_rec.Finaid_Apply_Date,
           X_Adm_Outcome_Status                =>  l_appl_inst_rec.Adm_Outcome_Status,
           X_Adm_Otcm_Stat_Auth_Per_Id         =>  l_appl_inst_rec.adm_otcm_status_auth_person_id,
           X_Adm_Outcome_Status_Auth_Dt        =>  l_appl_inst_rec.Adm_Outcome_Status_Auth_Dt,
           X_Adm_Outcome_Status_Reason         =>  l_appl_inst_rec.Adm_Outcome_Status_Reason,
           X_Offer_Dt                          =>  l_appl_inst_rec.Offer_Dt,
           X_Offer_Response_Dt                 =>  l_appl_inst_rec.Offer_Response_Dt,
           X_Prpsd_Commencement_Dt             =>  l_appl_inst_rec.Prpsd_Commencement_Dt,
           X_Adm_Cndtnl_Offer_Status           =>  l_appl_inst_rec.Adm_Cndtnl_Offer_Status,
           X_Cndtnl_Offer_Satisfied_Dt         =>  l_appl_inst_rec.Cndtnl_Offer_Satisfied_Dt,
           X_Cndnl_Ofr_Must_Be_Stsfd_Ind       =>  l_appl_inst_rec.cndtnl_offer_must_be_stsfd_ind,
           X_Adm_Offer_Resp_Status             =>  l_appl_inst_rec.Adm_Offer_Resp_Status,
           X_Actual_Response_Dt                =>  l_appl_inst_rec.Actual_Response_Dt,
           X_Adm_Offer_Dfrmnt_Status           =>  l_appl_inst_rec.Adm_Offer_Dfrmnt_Status,
           X_Deferred_Adm_Cal_Type             =>  l_appl_inst_rec.Deferred_Adm_Cal_Type,
           X_Deferred_Adm_Ci_Sequence_Num      =>  l_appl_inst_rec.Deferred_Adm_Ci_Sequence_Num,
           X_Deferred_Tracking_Id              =>  l_appl_inst_rec.Deferred_Tracking_Id,
           X_Ass_Rank                          =>  l_appl_inst_rec.Ass_Rank,
           X_Secondary_Ass_Rank                =>  l_appl_inst_rec.Secondary_Ass_Rank,
           X_Intr_Accept_Advice_Num            =>  l_appl_inst_rec.intrntnl_acceptance_advice_num,
           X_Ass_Tracking_Id                   =>  l_appl_inst_rec.Ass_Tracking_Id,
           X_Fee_Cat                           =>  l_appl_inst_rec.Fee_Cat,
           X_Hecs_Payment_Option               =>  l_appl_inst_rec.Hecs_Payment_Option,
           X_Expected_Completion_Yr            =>  l_appl_inst_rec.Expected_Completion_Yr,
           X_Expected_Completion_Perd          =>  l_appl_inst_rec.Expected_Completion_Perd,
           X_Correspondence_Cat                =>  l_appl_inst_rec.Correspondence_Cat,
           X_Enrolment_Cat                     =>  l_appl_inst_rec.Enrolment_Cat,
           X_Funding_Source                    =>  l_appl_inst_rec.Funding_Source,
           X_Applicant_Acptnce_Cndtn           =>  l_appl_inst_rec.Applicant_Acptnce_Cndtn,
           X_Cndtnl_Offer_Cndtn                =>  l_appl_inst_rec.Cndtnl_Offer_Cndtn,
           X_SS_APPLICATION_ID                 =>  l_appl_inst_rec.SS_APPLICATION_ID,
           X_SS_PWD                            =>  l_appl_inst_rec.SS_PWD,
           X_AUTHORIZED_DT                     =>  l_appl_inst_rec.AUTHORIZED_DT,
           X_AUTHORIZING_PERS_ID               =>  l_appl_inst_rec.AUTHORIZING_PERS_ID,
           X_ENTRY_STATUS                      =>  l_appl_inst_rec.ENTRY_STATUS,
           X_ENTRY_LEVEL                       =>  l_appl_inst_rec.ENTRY_LEVEL,
           X_SCH_APL_TO_ID                     =>  l_appl_inst_rec.SCH_APL_TO_ID,
           X_IDX_CALC_DATE                     =>  l_appl_inst_rec.IDX_CALC_DATE,
           X_WAITLIST_STATUS                   =>  l_appl_inst_rec.WAITLIST_STATUS,
           x_fut_acad_cal_type                 =>  l_appl_inst_rec.future_acad_cal_type,
           x_fut_acad_ci_sequence_number       =>  l_appl_inst_rec.future_acad_ci_sequence_number,
           x_fut_adm_cal_type                  =>  l_appl_inst_rec.future_adm_cal_type,
           x_fut_adm_ci_sequence_number        =>  l_appl_inst_rec.future_adm_ci_sequence_number,
           x_prev_term_adm_appl_number         =>  l_appl_inst_rec.previous_term_adm_appl_number,
           x_prev_term_sequence_number         =>  l_appl_inst_rec.previous_term_sequence_number,
           x_fut_term_adm_appl_number          =>  l_appl_inst_rec.future_term_adm_appl_number,
           x_fut_term_sequence_number          =>  l_appl_inst_rec.future_term_sequence_number,
           x_def_acad_cal_type                 =>  l_appl_inst_rec.def_acad_cal_type,
           x_def_acad_ci_sequence_num          =>  l_appl_inst_rec.def_acad_ci_sequence_num,
           x_def_prev_term_adm_appl_num        =>  l_appl_inst_rec.def_prev_term_adm_appl_num,
           x_def_prev_appl_sequence_num        =>  l_appl_inst_rec.def_prev_appl_sequence_num,
           x_def_term_adm_appl_num             =>  l_appl_inst_rec.def_term_adm_appl_num,
           x_def_appl_sequence_num             =>  l_appl_inst_rec.def_appl_sequence_num,
           x_appl_inst_status                  =>  l_appl_inst_rec.appl_inst_status,
           x_ais_reason                        =>  l_appl_inst_rec.ais_reason,
           x_decline_ofr_reason                =>  l_appl_inst_rec.decline_ofr_reason);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN

      ROLLBACK TO UPDATE_ENTRY_QUAL_STATUS_SAVE;
      x_return_status := FND_API.G_RET_STS_ERROR;

      igs_ad_gen_016.extract_msg_from_stack (
            p_msg_at_index                => l_msg_index,
            p_return_status               => l_return_status,
            p_msg_count                   => x_msg_count,
            p_msg_data                    => x_msg_data,
            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
      x_msg_count := x_msg_count-1;

      IF (x_msg_count = 0) THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        FND_MSG_PUB.ADD;
	IGS_GE_MSG_STACK.ADD;
        x_msg_data := FND_MESSAGE.GET;
      ELSE
        x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count - 1).name;
        FND_MESSAGE.SET_NAME(l_hash_msg_name_text_type_tab(x_msg_count - 1).appl,x_msg_data);
        FND_MSG_PUB.ADD;
        x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count - 1).text;
      END IF;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'aFTER STACK Exception in API: FND_API.G_EXC_ERROR : '|| l_hash_msg_name_text_type_tab(x_msg_count-2).text);
      IF c_acai%ISOPEN THEN
        CLOSE c_acai;
      END IF;

      IF c_appl%ISOPEN THEN
        CLOSE c_acai;
      END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO UPDATE_ENTRY_QUAL_STATUS_SAVE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);


    WHEN OTHERS THEN

      ROLLBACK TO UPDATE_ENTRY_QUAL_STATUS_SAVE;
      igs_ad_gen_016.extract_msg_from_stack (
            p_msg_at_index                => l_msg_index,
            p_return_status               => l_return_status,
            p_msg_count                   => x_msg_count,
            p_msg_data                    => x_msg_data,
            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

      IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
	 x_return_status := FND_API.G_RET_STS_ERROR ;
      ELSE
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF c_acai%ISOPEN THEN
        CLOSE c_acai;
      END IF;

      IF c_appl%ISOPEN THEN
        CLOSE c_acai;
      END IF;

 END UPDATE_ENTRY_QUAL_STATUS;


END igs_admapplication_pub;

/
