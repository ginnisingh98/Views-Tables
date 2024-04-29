--------------------------------------------------------
--  DDL for Package IGS_EN_SUSA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SUSA_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENA3S.pls 120.1 2006/01/17 03:37:20 rnirwani noship $ */
/*#
 * The Student Unit Set Attempt Import process is a public API designed for use in populating rows
 * with data during a system conversion.  This API is also used by the Legacy Import Process for
 * Enrollment and Records when importing rows from the IGS_EN_LGY_SUSA_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Unit Set Attempt
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.

-- Record Type for columns of Interface table IGS_EN_LGY_SUSA_INT
--
TYPE susa_rec_type IS RECORD (person_number                 igs_en_lgy_susa_int.person_number%TYPE,
                              program_cd                    igs_en_lgy_susa_int.program_cd%TYPE,
                              unit_set_cd                   igs_en_lgy_susa_int.unit_set_cd%TYPE,
                              us_version_number             igs_en_lgy_susa_int.us_version_number%TYPE,
                              selection_dt                  igs_en_lgy_susa_int.selection_dt%TYPE,
                              student_confirmed_ind         igs_en_lgy_susa_int.student_confirmed_ind%TYPE,
                              end_dt                        igs_en_lgy_susa_int.end_dt%TYPE,
                              parent_unit_set_cd            igs_en_lgy_susa_int.parent_unit_set_cd%TYPE,
                              primary_set_ind               igs_en_lgy_susa_int.primary_set_ind%TYPE,
                              voluntary_end_ind             igs_en_lgy_susa_int.voluntary_end_ind%TYPE,
                              authorised_person_number      igs_en_lgy_susa_int.authorised_person_number%TYPE,
                              authorised_on                 igs_en_lgy_susa_int.authorised_on%TYPE,
                              override_title                igs_en_lgy_susa_int.override_title%TYPE,
                              rqrmnts_complete_ind          igs_en_lgy_susa_int.rqrmnts_complete_ind%TYPE,
                              rqrmnts_complete_dt           igs_en_lgy_susa_int.rqrmnts_complete_dt%TYPE,
                              s_completed_source_type       igs_en_lgy_susa_int.s_completed_source_type%TYPE,
                              catalog_cal_alternate_code    igs_en_lgy_susa_int.catalog_cal_alternate_code%TYPE,
                              attribute_category            igs_en_lgy_susa_int.attribute_category%TYPE,
                              attribute1                    igs_en_lgy_susa_int.attribute1%TYPE,
                              attribute2                    igs_en_lgy_susa_int.attribute2%TYPE,
                              attribute3                    igs_en_lgy_susa_int.attribute3%TYPE,
                              attribute4                    igs_en_lgy_susa_int.attribute4%TYPE,
                              attribute5                    igs_en_lgy_susa_int.attribute5%TYPE,
                              attribute6                    igs_en_lgy_susa_int.attribute6%TYPE,
                              attribute7                    igs_en_lgy_susa_int.attribute7%TYPE,
                              attribute8                    igs_en_lgy_susa_int.attribute8%TYPE,
                              attribute9                    igs_en_lgy_susa_int.attribute9%TYPE,
                              attribute10                   igs_en_lgy_susa_int.attribute10%TYPE,
                              attribute11                   igs_en_lgy_susa_int.attribute11%TYPE,
                              attribute12                   igs_en_lgy_susa_int.attribute12%TYPE,
                              attribute13                   igs_en_lgy_susa_int.attribute13%TYPE,
                              attribute14                   igs_en_lgy_susa_int.attribute14%TYPE,
                              attribute15                   igs_en_lgy_susa_int.attribute15%TYPE,
                              attribute16                   igs_en_lgy_susa_int.attribute16%TYPE,
                              attribute17                   igs_en_lgy_susa_int.attribute17%TYPE,
                              attribute18                   igs_en_lgy_susa_int.attribute18%TYPE,
                              attribute19                   igs_en_lgy_susa_int.attribute19%TYPE,
                              attribute20                   igs_en_lgy_susa_int.attribute20%TYPE );


/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 11-Nov-2002
||  Purpose : To create a EN Student Unit Set Attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
-- irep annotations below
/*#
 * The Student Unit Set Attempt Import process is a public API designed for use in populating
 * rows with data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_EN_LGY_SUSA_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_susa_rec Legacy Student Unit Set Attempt record type. Refer to IGS_EN_LGY_SUSA_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Unit Set Attempt
 */
PROCEDURE create_unit_set_atmpt (p_api_version           IN   NUMBER,
                                 p_init_msg_list         IN   VARCHAR2              DEFAULT FND_API.G_FALSE,
                                 p_commit                IN   VARCHAR2              DEFAULT FND_API.G_FALSE,
                                 p_validation_level      IN   NUMBER                DEFAULT FND_API.G_VALID_LEVEL_FULL,
                                 p_susa_rec              IN   susa_rec_type,
                                 x_return_status         OUT  NOCOPY VARCHAR2,
                                 x_msg_count             OUT  NOCOPY NUMBER,
                                 x_msg_data              OUT  NOCOPY VARCHAR2);



END igs_en_susa_lgcy_pub;

 

/
