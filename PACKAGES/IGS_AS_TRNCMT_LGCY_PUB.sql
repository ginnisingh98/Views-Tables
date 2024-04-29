--------------------------------------------------------
--  DDL for Package IGS_AS_TRNCMT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_TRNCMT_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSAS56S.pls 120.1 2006/01/17 03:52:12 ijeddy noship $ */
/*#
 * The Transcript Comments import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AS_LGCY_STC_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Transcript Comment
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */

/******************************************************************************
  ||  Created By : anilk
  ||  Created On : 22-Sep-2002
  ||  Purpose : This is an API to move  legacy teranscript comments to OSS
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
******************************************************************************/

  TYPE lgcy_trncmt_rec_type  IS RECORD (
        comment_type_code                 igs_as_lgcy_stc_int.comment_type_code%TYPE,
        comment_txt                       igs_as_lgcy_stc_int.comment_txt%TYPE,
        person_number                     igs_as_lgcy_stc_int.person_number%TYPE,
        program_cd                        igs_as_lgcy_stc_int.program_cd%TYPE,
        program_type                      igs_as_lgcy_stc_int.program_type%TYPE,
        award_cd                          igs_as_lgcy_stc_int.award_cd%TYPE,
        load_cal_alternate_cd             igs_as_lgcy_stc_int.load_cal_alternate_cd%TYPE,
        unit_set_cd                       igs_as_lgcy_stc_int.unit_set_cd%TYPE,
        us_version_number                 igs_as_lgcy_stc_int.us_version_number%TYPE,
        unit_cd                           igs_as_lgcy_stc_int.unit_cd%TYPE,
        version_number                    igs_as_lgcy_stc_int.version_number%TYPE,
        teach_cal_alternate_cd            igs_as_lgcy_stc_int.teach_cal_alternate_cd%TYPE,
        location_cd                       igs_as_lgcy_stc_int.location_cd%TYPE,
        unit_class                        igs_as_lgcy_stc_int.unit_class%TYPE
  );

/*#
 * The Transcript Comments import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AS_LGCY_STC_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_lgcy_trncmt_rec Legacy Transcript Comment record type. Refer to IGS_AS_LGCY_STC_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Transcript Comment
 */
  PROCEDURE create_trncmt(
      p_api_version          IN              NUMBER          ,
      p_init_msg_list        IN              VARCHAR2   DEFAULT FND_API.G_FALSE,
      p_commit               IN              VARCHAR2   DEFAULT FND_API.G_FALSE,
      p_validation_level     IN              NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL,
      p_lgcy_trncmt_rec      IN  OUT NOCOPY     LGCY_TRNCMT_REC_TYPE,
      x_return_status        OUT NOCOPY      VARCHAR2        ,
      x_msg_count            OUT NOCOPY      NUMBER          ,
      x_msg_data             OUT NOCOPY      VARCHAR2
  );
END igs_as_trncmt_lgcy_pub;

 

/
