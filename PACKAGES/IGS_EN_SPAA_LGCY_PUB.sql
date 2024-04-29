--------------------------------------------------------
--  DDL for Package IGS_EN_SPAA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPAA_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENA5S.pls 120.1 2006/01/17 03:34:43 rnirwani noship $ */
/*#
 * The Student Award Aim Import process is a public API designed for use in populating rows with data
 * during a system conversion.  This API is also used by the Legacy Import Process for Enrollment and
 * Records when importing rows from the IGS_EN_LGY_SPAA_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Award Aim
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.

--Start of comments
--      API name        : create_student_awd_aim
--      Type            : Public.
--      Function        : Inserts one record passed as parameter of TYPE awd_aim_rec_type into the table
--                        Award Aims after validating the values for each fields.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional Default = FND_API.G_VALID_LEVEL_FULL
--                              p_awd_aim_rec           IN awd_aim_rec_type (this is a record type declared in the spec
--                                                                            contains the below mentioned fields)
--                  {
--                   person_number           :Person number of the student
--                   program_cd              :The program code in which the award is being studied. Must be an uppercase value.
--                   award_cd                :The award code being studied. Must be an uppercase value.
--                   start_dt                :The start date of the award.
--                   end_dt                  :The date the award was ended, whether completed or not.
--                   complete_ind            :Indicates whether the award has been completed.
--                   conferral_dt            :The conferral date of the student award.
--                   honours_level           :The honors level achieved for the student award. Must be an uppercase value.
--                  }
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--
--
--      Version : Current version       1.0
-- End of comments
--
-- Change History :
-- Who        When        What
-- anilk      07-Oct-2003 changes in awd_aim_rec_type for Program Completion Validation, Bug# 3129913
-- (reverse chronological order - newest change first)

TYPE awd_aim_rec_type IS RECORD (
person_number           igs_en_lgy_spaa_int.person_number%TYPE,
program_cd              igs_en_lgy_spaa_int.program_cd%TYPE,
award_cd                igs_en_lgy_spaa_int.award_cd%TYPE,
start_dt                igs_en_lgy_spaa_int.start_dt%TYPE,
end_dt                  igs_en_lgy_spaa_int.end_dt%TYPE,
complete_ind            igs_en_lgy_spaa_int.complete_ind%TYPE,
conferral_dt            igs_en_lgy_spaa_int.conferral_dt%TYPE,
award_mark              igs_en_lgy_spaa_int.award_mark%TYPE,
award_grade             igs_en_lgy_spaa_int.award_grade%TYPE,
grading_schema_cd       igs_en_lgy_spaa_int.grading_schema_cd%TYPE,
gs_version_number       igs_en_lgy_spaa_int.gs_version_number%TYPE
);

-- irep annotations below
/*#
 * The Student Award Aim Import process is a public API designed for use in populating rows with data
 * during a system conversion.  This API is also used by the Legacy Import Process for Enrollment and
 * Records when importing rows from the IGS_EN_LGY_SPAA_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_awd_aim_rec Legacy Student Award Aim record type. Refer to IGS_EN_LGY_SPAA_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Award Aim
 */
PROCEDURE create_student_awd_aim
(       p_api_version       IN   NUMBER,
        p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level  IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_awd_aim_rec       IN   awd_aim_rec_type,
        x_return_status     OUT  NOCOPY VARCHAR2,
        x_msg_count         OUT  NOCOPY NUMBER,
        x_msg_data          OUT  NOCOPY VARCHAR2
);

END igs_en_spaa_lgcy_pub;

 

/
