--------------------------------------------------------
--  DDL for Package IGS_EN_SPA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPA_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENA2S.pls 120.2 2006/01/19 00:07:36 rnirwani noship $ */
/*#
 * The Student Program Attempt Legacy Import process is a public API designed for
 * use in populating rows with data during a system conversion.  This API is also used
 * by the Legacy Import Process for Enrollment and Records when importing rows from the
 * IGS_EN_LGCY_SPA_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Program Attempt
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.
TYPE SCA_RE_REC_TYPE IS RECORD(
                                person_number                 igs_en_lgcy_spa_int.person_number%TYPE,
                                program_cd                    igs_en_lgcy_spa_int.program_cd%TYPE,
                                version_number                igs_en_lgcy_spa_int.version_number%TYPE,
                                cal_type                      igs_en_lgcy_spa_int.cal_type%TYPE,
                                location_cd                   igs_en_lgcy_spa_int.location_cd%TYPE,
                                attendance_mode               igs_en_lgcy_spa_int.attendance_mode%TYPE,
                                attendance_type               igs_en_lgcy_spa_int.attendance_type%TYPE,
                                student_confirmed_ind         igs_en_lgcy_spa_int.student_confirmed_ind%TYPE,
                                commencement_dt               igs_en_lgcy_spa_int.commencement_dt%TYPE,
                                primary_program_type          igs_en_lgcy_spa_int.primary_program_type%TYPE,
                                primary_prog_type_source      igs_en_lgcy_spa_int.primary_prog_type_source%TYPE,
                                key_program                   igs_en_lgcy_spa_int.key_program%TYPE,
                                provisional_ind               igs_en_lgcy_spa_int.provisional_ind%TYPE,
                                discontinued_dt               igs_en_lgcy_spa_int.discontinued_dt%TYPE,
                                discontinuation_reason_cd     igs_en_lgcy_spa_int.discontinuation_reason_cd%TYPE,
                                lapsed_dt                     igs_en_lgcy_spa_int.lapsed_dt%TYPE,
                                funding_source                igs_en_lgcy_spa_int.funding_source%TYPE,
                                exam_location_cd              igs_en_lgcy_spa_int.exam_location_cd%TYPE,
                                nominated_completion_yr       igs_en_lgcy_spa_int.nominated_completion_yr%TYPE,
                                nominated_completion_perd     igs_en_lgcy_spa_int.nominated_completion_perd%TYPE,
                                rule_check_ind                igs_en_lgcy_spa_int.rule_check_ind%TYPE,
                                waive_option_check_ind        igs_en_lgcy_spa_int.waive_option_check_ind%TYPE,
                                last_rule_check_dt            igs_en_lgcy_spa_int.last_rule_check_dt%TYPE,
                                publish_outcomes_ind          igs_en_lgcy_spa_int.publish_outcomes_ind%TYPE,
                                course_rqrmnt_complete_ind    igs_en_lgcy_spa_int.course_rqrmnt_complete_ind%TYPE,
                                course_rqrmnts_complete_dt    igs_en_lgcy_spa_int.course_rqrmnts_complete_dt%TYPE,
                                s_completed_source_type       igs_en_lgcy_spa_int.s_completed_source_type%TYPE,
                                advanced_standing_ind         igs_en_lgcy_spa_int.advanced_standing_ind%TYPE,
                                fee_cat                       igs_en_lgcy_spa_int.fee_cat%TYPE,
                                correspondence_cat            igs_en_lgcy_spa_int.correspondence_cat%TYPE,
                                self_help_group_ind           igs_en_lgcy_spa_int.self_help_group_ind%TYPE,
                                adm_admission_appl_number     igs_en_lgcy_spa_int.adm_admission_appl_number%TYPE,
                                adm_nominated_course_cd       igs_en_lgcy_spa_int.adm_nominated_course_cd%TYPE,
                                adm_sequence_number           igs_en_lgcy_spa_int.adm_sequence_number%TYPE,
                                class_standing_override       igs_en_lgcy_spa_int.class_standing_override%TYPE,
                                catalog_cal_alternate_code    igs_en_lgcy_spa_int.catalog_cal_alternate_code%TYPE,
                                override_cmpl_dt              igs_en_lgcy_spa_int.override_cmpl_dt%TYPE,
                                manual_ovr_cmpl_dt_ind        igs_en_lgcy_spa_int.manual_ovr_cmpl_dt_ind%TYPE,
                                attribute_category            igs_en_lgcy_spa_int.attribute_category%TYPE,
                                attribute1                    igs_en_lgcy_spa_int.attribute1%TYPE,
                                attribute2                    igs_en_lgcy_spa_int.attribute2%TYPE,
                                attribute3                    igs_en_lgcy_spa_int.attribute3%TYPE,
                                attribute4                    igs_en_lgcy_spa_int.attribute4%TYPE,
                                attribute5                    igs_en_lgcy_spa_int.attribute5%TYPE,
                                attribute6                    igs_en_lgcy_spa_int.attribute6%TYPE,
                                attribute7                    igs_en_lgcy_spa_int.attribute7%TYPE,
                                attribute8                    igs_en_lgcy_spa_int.attribute8%TYPE,
                                attribute9                    igs_en_lgcy_spa_int.attribute9%TYPE,
                                attribute10                   igs_en_lgcy_spa_int.attribute10%TYPE,
                                attribute11                   igs_en_lgcy_spa_int.attribute11%TYPE,
                                attribute12                   igs_en_lgcy_spa_int.attribute12%TYPE,
                                attribute13                   igs_en_lgcy_spa_int.attribute13%TYPE,
                                attribute14                   igs_en_lgcy_spa_int.attribute14%TYPE,
                                attribute15                   igs_en_lgcy_spa_int.attribute15%TYPE,
                                attribute16                   igs_en_lgcy_spa_int.attribute16%TYPE,
                                attribute17                   igs_en_lgcy_spa_int.attribute17%TYPE,
                                attribute18                   igs_en_lgcy_spa_int.attribute18%TYPE,
                                attribute19                   igs_en_lgcy_spa_int.attribute19%TYPE,
                                attribute20                   igs_en_lgcy_spa_int.attribute20%TYPE,
                                re_attendance_percentage      igs_en_lgcy_spa_int.re_attendance_percentage%TYPE,
                                re_govt_type_of_activity_cd   igs_en_lgcy_spa_int.re_govt_type_of_activity_cd%TYPE,
                                re_max_submission_dt          igs_en_lgcy_spa_int.re_max_submission_dt%TYPE,
                                re_min_submission_dt          igs_en_lgcy_spa_int.re_min_submission_dt%TYPE,
                                re_research_topic             igs_en_lgcy_spa_int.re_research_topic%TYPE,
                                re_industry_links             igs_en_lgcy_spa_int.re_industry_links%TYPE);

-- irep annotations below.
/*#
 * The Student Program Attempt Legacy Import process is a public API designed for use in
 * populating rows with data during a system conversion.  This API is also used by the Legacy
 * Import Process for Enrollment and Records when importing rows from the IGS_EN_LGCY_SPA_INT interface table.
 * @param p_api_version The version number will be used to compare with
 * claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_sca_re_rec Legacy Student Program Attempt record type. Refer to IGS_EN_LGCY_SPA_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Program Attempt
 */
PROCEDURE create_spa(
                      p_api_version        IN          NUMBER,
                      p_init_msg_list      IN          VARCHAR2  DEFAULT FND_API.G_FALSE,
                      p_commit             IN          VARCHAR2  DEFAULT FND_API.G_FALSE,
                      p_validation_level   IN          NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
                      p_sca_re_rec         IN          SCA_RE_REC_TYPE,
                      x_return_status      OUT NOCOPY  VARCHAR2,
                      x_msg_count          OUT NOCOPY  NUMBER,
                      x_msg_data           OUT NOCOPY  VARCHAR2);


END igs_en_spa_lgcy_pub;

 

/
