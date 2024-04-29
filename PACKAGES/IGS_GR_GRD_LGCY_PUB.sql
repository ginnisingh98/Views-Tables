--------------------------------------------------------
--  DDL for Package IGS_GR_GRD_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_GRD_LGCY_PUB" AUTHID CURRENT_USER AS
 /* $Header: IGSPGR1S.pls 120.1 2006/01/17 03:53:43 ijeddy noship $ */
/*#
 * The Graduand Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_GR_LGCY_GRD_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Graduand
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose : This is an API to move  legacy graduand details to OSS
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

TYPE lgcy_grd_rec_type  IS RECORD (
     PERSON_NUMBER                            igs_gr_lgcy_grd_int.PERSON_NUMBER %TYPE,
     CREATE_DT                                igs_gr_lgcy_grd_int.CREATE_DT%TYPE,
     GRD_CAL_ALT_CODE                           igs_gr_lgcy_grd_int.GRD_CAL_ALT_CODE%TYPE,
     PROGRAM_CD                               igs_gr_lgcy_grd_int.PROGRAM_CD%TYPE,
     AWARD_PROGRAM_CD                         igs_gr_lgcy_grd_int.AWARD_PROGRAM_CD%TYPE,
     AWARD_PROG_VERSION_NUMBER                igs_gr_lgcy_grd_int.AWARD_PROG_VERSION_NUMBER%TYPE,
     AWARD_CD                                 igs_gr_lgcy_grd_int.AWARD_CD%TYPE,
     GRADUAND_STATUS                          igs_gr_lgcy_grd_int.GRADUAND_STATUS%TYPE,
     GRADUAND_APPR_STATUS                     igs_gr_lgcy_grd_int.GRADUAND_APPR_STATUS%TYPE,
     S_GRADUAND_TYPE                          igs_gr_lgcy_grd_int.S_GRADUAND_TYPE%TYPE,
     GRADUATION_NAME                          igs_gr_lgcy_grd_int.GRADUATION_NAME%TYPE,
     PROXY_AWARD_PERSON_NUMBER                igs_gr_lgcy_grd_int.PROXY_AWARD_PERSON_NUMBER%TYPE,
     PREVIOUS_QUALIFICATIONS                  igs_gr_lgcy_grd_int.PREVIOUS_QUALIFICATIONS%TYPE,
     CONVOCATION_MEMBERSHIP_IND               igs_gr_lgcy_grd_int.CONVOCATION_MEMBERSHIP_IND%TYPE,
     SUR_FOR_PROGRAM_CD                       igs_gr_lgcy_grd_int.SUR_FOR_PROGRAM_CD%TYPE,
     SUR_FOR_PROG_VERSION_NUMBER              igs_gr_lgcy_grd_int.SUR_FOR_PROG_VERSION_NUMBER%TYPE,
     SUR_FOR_AWARD_CD                         igs_gr_lgcy_grd_int.SUR_FOR_AWARD_CD%TYPE,
     COMMENTS                                 igs_gr_lgcy_grd_int.COMMENTS%TYPE,
     ATTRIBUTE_CATEGORY                       igs_gr_lgcy_grd_int.ATTRIBUTE_CATEGORY%TYPE,
     ATTRIBUTE1                               igs_gr_lgcy_grd_int.ATTRIBUTE1%TYPE,
     ATTRIBUTE2                               igs_gr_lgcy_grd_int.ATTRIBUTE2%TYPE,
     ATTRIBUTE3                               igs_gr_lgcy_grd_int.ATTRIBUTE3%TYPE,
     ATTRIBUTE4                               igs_gr_lgcy_grd_int.ATTRIBUTE4%TYPE,
     ATTRIBUTE5                               igs_gr_lgcy_grd_int.ATTRIBUTE5%TYPE,
     ATTRIBUTE6                               igs_gr_lgcy_grd_int.ATTRIBUTE6%TYPE,
     ATTRIBUTE7                               igs_gr_lgcy_grd_int.ATTRIBUTE7%TYPE,
     ATTRIBUTE8                               igs_gr_lgcy_grd_int.ATTRIBUTE8%TYPE,
     ATTRIBUTE9                               igs_gr_lgcy_grd_int.ATTRIBUTE9%TYPE,
     ATTRIBUTE10                              igs_gr_lgcy_grd_int.ATTRIBUTE10%TYPE,
     ATTRIBUTE11                              igs_gr_lgcy_grd_int.ATTRIBUTE11%TYPE,
     ATTRIBUTE12                              igs_gr_lgcy_grd_int.ATTRIBUTE12%TYPE,
     ATTRIBUTE13                              igs_gr_lgcy_grd_int.ATTRIBUTE13%TYPE,
     ATTRIBUTE14                              igs_gr_lgcy_grd_int.ATTRIBUTE14%TYPE,
     ATTRIBUTE15                              igs_gr_lgcy_grd_int.ATTRIBUTE15%TYPE,
     ATTRIBUTE16                              igs_gr_lgcy_grd_int.ATTRIBUTE16%TYPE,
     ATTRIBUTE17                              igs_gr_lgcy_grd_int.ATTRIBUTE17%TYPE,
     ATTRIBUTE18                              igs_gr_lgcy_grd_int.ATTRIBUTE18%TYPE,
     ATTRIBUTE19                              igs_gr_lgcy_grd_int.ATTRIBUTE19%TYPE,
     ATTRIBUTE20                              igs_gr_lgcy_grd_int.ATTRIBUTE20%TYPE
);

/*#
 * The Graduand Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_GR_LGCY_GRD_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_lgcy_grd_rec Legacy graduation record type. Refer to IGS_GR_LGCY_GRD_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Graduand
 */
 PROCEDURE create_graduand(
                       p_api_version         IN  NUMBER,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       p_lgcy_grd_rec        IN  OUT NOCOPY lgcy_grd_rec_type,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2);

END IGS_GR_GRD_LGCY_PUB;

 

/
