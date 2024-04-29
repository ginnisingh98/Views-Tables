--------------------------------------------------------
--  DDL for Package IGS_EN_SPI_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPI_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENA6S.pls 120.2 2006/04/13 01:56:03 smaddali noship $ */
/*#
 * The Student Intermission Import process is a public API designed for use in populating rows with
 * data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment
 * and Records when importing rows from the IGS_EN_LGCY_SPI_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Intermission
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
 -- irep annotations above.

   TYPE en_spi_rec_type IS RECORD ( person_number                 igs_en_lgcy_spi_int.person_number%TYPE,
                                    program_cd                    igs_en_lgcy_spi_int.program_cd%TYPE,
                                    start_dt                      igs_en_lgcy_spi_int.start_dt%TYPE,
                                    end_dt                        igs_en_lgcy_spi_int.end_dt%TYPE,
                                    voluntary_ind                 igs_en_lgcy_spi_int.voluntary_ind%TYPE,
                                    comments                      igs_en_lgcy_spi_int.comments%TYPE,
                                    intermission_type             igs_en_lgcy_spi_int.intermission_type%TYPE,
                                    approved                      igs_en_lgcy_spi_int.approved%TYPE,
                                    institution_name              igs_en_lgcy_spi_int.institution_name%TYPE,
                                    max_credit_pts                igs_en_lgcy_spi_int.max_credit_pts%TYPE,
                                    max_terms                     igs_en_lgcy_spi_int.max_terms%TYPE,
                                    anticipated_credit_points     igs_en_lgcy_spi_int.anticipated_credit_points%TYPE,
                                    approver_person_number        igs_en_lgcy_spi_int.approver_person_number%TYPE,
                                    attribute_category            igs_en_lgcy_spi_int.attribute_category%TYPE,
                                    attribute1                    igs_en_lgcy_spi_int.attribute1%TYPE,
                                    attribute2                    igs_en_lgcy_spi_int.attribute2%TYPE,
                                    attribute3                    igs_en_lgcy_spi_int.attribute3%TYPE,
                                    attribute4                    igs_en_lgcy_spi_int.attribute4%TYPE,
                                    attribute5                    igs_en_lgcy_spi_int.attribute5%TYPE,
                                    attribute6                    igs_en_lgcy_spi_int.attribute6%TYPE,
                                    attribute7                    igs_en_lgcy_spi_int.attribute7%TYPE,
                                    attribute8                    igs_en_lgcy_spi_int.attribute8%TYPE,
                                    attribute9                    igs_en_lgcy_spi_int.attribute9%TYPE,
                                    attribute10                   igs_en_lgcy_spi_int.attribute10%TYPE,
                                    attribute11                   igs_en_lgcy_spi_int.attribute11%TYPE,
                                    attribute12                   igs_en_lgcy_spi_int.attribute12%TYPE,
                                    attribute13                   igs_en_lgcy_spi_int.attribute13%TYPE,
                                    attribute14                   igs_en_lgcy_spi_int.attribute14%TYPE,
                                    attribute15                   igs_en_lgcy_spi_int.attribute15%TYPE,
                                    attribute16                   igs_en_lgcy_spi_int.attribute16%TYPE,
                                    attribute17                   igs_en_lgcy_spi_int.attribute17%TYPE,
                                    attribute18                   igs_en_lgcy_spi_int.attribute18%TYPE,
                                    attribute19                   igs_en_lgcy_spi_int.attribute19%TYPE,
                                    attribute20                   igs_en_lgcy_spi_int.attribute20%TYPE,
                                    cond_return_flag              igs_en_lgcy_spi_int.cond_return_flag%TYPE
                                  );

-- irep annotations below.
/*#
 * The Student Intermission Import process is a public API designed for use in populating rows with
 * data during a system conversion.  This API is also used by the Legacy Import Process for Enrollment
 * and Records when importing rows from the IGS_EN_LGCY_SPI_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param P_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_intermiss_rec Legacy Student Intermission record type. Refer to IGS_EN_LGCY_SPI_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Intermission
 */
  PROCEDURE create_student_intm
  (
    p_api_version             IN           NUMBER,
    p_init_msg_list           IN           VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                  IN           VARCHAR2 DEFAULT  FND_API.G_FALSE ,
    p_validation_level        IN           NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL ,
    p_intermiss_rec           IN           en_spi_rec_type,
    x_return_status           OUT  NOCOPY  VARCHAR2,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2
 );

END igs_en_spi_lgcy_pub;

 

/
