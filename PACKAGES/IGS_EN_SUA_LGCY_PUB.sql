--------------------------------------------------------
--  DDL for Package IGS_EN_SUA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SUA_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENA4S.pls 120.2 2006/01/17 03:28:25 rnirwani ship $ */
/*#
 * The Student Unit Attempt Import process is a public API designed for use in populating rows with
 * data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment
 * and Records when importing rows from the IGS_EN_LGCY_SUA_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Unit Attempt
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_UNIT
 */
-- irep annotations above.

TYPE sua_dtls_rec_type IS RECORD (
 person_number                  	IGS_EN_LGCY_SUA_INT.person_number%TYPE ,
 program_cd                     	IGS_EN_LGCY_SUA_INT.program_cd%TYPE ,
 unit_cd                        	IGS_EN_LGCY_SUA_INT.unit_cd%TYPE ,
 version_number                 	IGS_EN_LGCY_SUA_INT.version_number%TYPE ,
 teach_calendar_alternate_code  	IGS_EN_LGCY_SUA_INT.teach_calendar_alternate_code%TYPE ,
 location_cd                    	IGS_EN_LGCY_SUA_INT.location_cd%TYPE ,
 unit_class                     	IGS_EN_LGCY_SUA_INT.unit_class%TYPE ,
 enrolled_dt                    	IGS_EN_LGCY_SUA_INT.enrolled_dt%TYPE ,
 waitlisted_dt                  	IGS_EN_LGCY_SUA_INT.waitlisted_dt%TYPE ,
 dropped_ind                    	IGS_EN_LGCY_SUA_INT.dropped_ind%TYPE ,
 discontinued_dt                	IGS_EN_LGCY_SUA_INT.discontinued_dt%TYPE ,
 administrative_unit_status     	IGS_EN_LGCY_SUA_INT.administrative_unit_status%TYPE ,
 dcnt_reason_cd                 	IGS_EN_LGCY_SUA_INT.dcnt_reason_cd%TYPE ,
 no_assessment_ind              	IGS_EN_LGCY_SUA_INT.no_assessment_ind%TYPE ,
 override_enrolled_cp           	IGS_EN_LGCY_SUA_INT.override_enrolled_cp%TYPE ,
 override_achievable_cp         	IGS_EN_LGCY_SUA_INT.override_achievable_cp%TYPE ,
 grading_schema_code            	IGS_EN_LGCY_SUA_INT.grading_schema_code%TYPE ,
 gs_version_number              	IGS_EN_LGCY_SUA_INT.gs_version_number%TYPE ,
 subtitle                       	IGS_EN_LGCY_SUA_INT.subtitle%TYPE ,
 student_career_transcript      	IGS_EN_LGCY_SUA_INT.student_career_transcript%TYPE ,
 student_career_statistics      	IGS_EN_LGCY_SUA_INT.student_career_statistics%TYPE ,
 transfer_dt                    	IGS_EN_LGCY_SUA_INT.transfer_dt%TYPE ,
 transfer_program_cd            	IGS_EN_LGCY_SUA_INT.transfer_program_cd%TYPE ,
 outcome_dt                     	IGS_EN_LGCY_SUA_INT.outcome_dt%TYPE ,
 mark                           	IGS_EN_LGCY_SUA_INT.mark%TYPE ,
 outcome_grading_schema_code    	IGS_EN_LGCY_SUA_INT.outcome_grading_schema_code%TYPE ,
 outcome_gs_version_number      	IGS_EN_LGCY_SUA_INT.outcome_gs_version_number%TYPE ,
 grade                          	IGS_EN_LGCY_SUA_INT.grade%TYPE ,
 incomp_deadline_date           	IGS_EN_LGCY_SUA_INT.incomp_deadline_date%TYPE ,
 incomp_default_grade           	IGS_EN_LGCY_SUA_INT.incomp_default_grade%TYPE ,
 incomp_default_mark            	IGS_EN_LGCY_SUA_INT.incomp_default_mark%TYPE ,
 --added by rvangala 01-OCT-2003. Enh Bug# 3052432
 core_indicator                         IGS_EN_LGCY_SUA_INT.core_indicator_code%TYPE,
 attribute_category              	IGS_EN_LGCY_SUA_INT.attribute_category%TYPE ,
 attribute1                     	IGS_EN_LGCY_SUA_INT.attribute1%TYPE ,
 attribute2                     	IGS_EN_LGCY_SUA_INT.attribute2%TYPE ,
 attribute3                     	IGS_EN_LGCY_SUA_INT.attribute3%TYPE ,
 attribute4                     	IGS_EN_LGCY_SUA_INT.attribute4%TYPE ,
 attribute5                     	IGS_EN_LGCY_SUA_INT.attribute5%TYPE ,
 attribute6                     	IGS_EN_LGCY_SUA_INT.attribute6%TYPE ,
 attribute7                     	IGS_EN_LGCY_SUA_INT.attribute7%TYPE ,
 attribute8                     	IGS_EN_LGCY_SUA_INT.attribute8%TYPE ,
 attribute9                     	IGS_EN_LGCY_SUA_INT.attribute9%TYPE ,
 attribute10                    	IGS_EN_LGCY_SUA_INT.attribute10%TYPE ,
 attribute11                    	IGS_EN_LGCY_SUA_INT.attribute11%TYPE ,
 attribute12                    	IGS_EN_LGCY_SUA_INT.attribute12%TYPE ,
 attribute13                    	IGS_EN_LGCY_SUA_INT.attribute13%TYPE ,
 attribute14                    	IGS_EN_LGCY_SUA_INT.attribute14%TYPE ,
 attribute15                    	IGS_EN_LGCY_SUA_INT.attribute15%TYPE ,
 attribute16                    	IGS_EN_LGCY_SUA_INT.attribute16%TYPE ,
 attribute17                    	IGS_EN_LGCY_SUA_INT.attribute17%TYPE ,
 attribute18                    	IGS_EN_LGCY_SUA_INT.attribute18%TYPE ,
 attribute19                    	IGS_EN_LGCY_SUA_INT.attribute19%TYPE ,
 attribute20                    	IGS_EN_LGCY_SUA_INT.attribute20%TYPE
);

-- irep annotations below.
/*#
 * The Student Unit Attempt Import process is a public API designed for use in populating rows with
 * data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment
 * and Records when importing rows from the IGS_EN_LGCY_SUA_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_sua_dtls_rec Legacy Student Unit Attempt record type. Refer to IGS_EN_LGCY_SUA_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Unit Attempt
 */
PROCEDURE create_sua (	    p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2              DEFAULT FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2              DEFAULT FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER                DEFAULT FND_API.G_VALID_LEVEL_FULL,
                            p_sua_dtls_rec		    IN   sua_dtls_rec_type ,
                            x_return_status         OUT  NOCOPY VARCHAR2,
                            x_msg_count             OUT  NOCOPY NUMBER,
                            x_msg_data              OUT  NOCOPY VARCHAR2);


END igs_en_sua_lgcy_pub;

 

/
