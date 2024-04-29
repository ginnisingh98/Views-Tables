--------------------------------------------------------
--  DDL for Package IGS_AV_UNT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_UNT_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPAV2S.pls 120.2 2006/01/17 03:53:24 ijeddy ship $ */
/*#
 * The Advanced Standing Unit Legacy Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AV_LGCY_UNIT_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Unit Advanced Standing
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_ADV_STAND
 */
  -- RECORD type variable for the table igs_av_lgcy_lvl_int
  TYPE lgcy_adstunt_rec_type IS RECORD (
            person_number               igs_av_lgcy_unt_int.person_number%TYPE,
            program_cd                  igs_av_lgcy_unt_int.program_cd%TYPE,
            total_exmptn_approved       igs_av_lgcy_unt_int.total_exmptn_approved%TYPE,
            total_exmptn_granted        igs_av_lgcy_unt_int.total_exmptn_granted%TYPE,
            total_exmptn_perc_grntd     igs_av_lgcy_unt_int.total_exmptn_perc_grntd%TYPE,
            exemption_institution_cd    igs_av_lgcy_unt_int.exemption_institution_cd%TYPE,
            unit_cd                     igs_av_lgcy_unt_int.unit_cd%TYPE,
            version_number              igs_av_lgcy_unt_int.version_number%TYPE,
            institution_cd              igs_av_lgcy_unt_int.institution_cd%TYPE,
            approved_dt                 igs_av_lgcy_unt_int.approved_dt%TYPE,
            authorising_person_number   igs_av_lgcy_unt_int.authorising_person_number%TYPE,
            prog_group_ind              igs_av_lgcy_unt_int.prog_group_ind%TYPE,
            granted_dt                  igs_av_lgcy_unt_int.granted_dt%TYPE,
            expiry_dt                   igs_av_lgcy_unt_int.expiry_dt%TYPE,
            cancelled_dt                igs_av_lgcy_unt_int.cancelled_dt%TYPE,
            revoked_dt                  igs_av_lgcy_unt_int.revoked_dt%TYPE,
            comments                    igs_av_lgcy_unt_int.comments%TYPE,
            credit_percentage            NUMBER(5,2),
            s_adv_stnd_granting_status  igs_av_lgcy_unt_int.s_adv_stnd_granting_status%TYPE,
            s_adv_stnd_recognition_type igs_av_lgcy_unt_int.s_adv_stnd_recognition_type%TYPE,
            load_cal_alt_code           igs_av_lgcy_unt_int.load_cal_alt_code%TYPE,
            grading_schema_cd           igs_av_lgcy_unt_int.grading_schema_cd%TYPE,
            grd_sch_version_number      igs_av_lgcy_unt_int.grd_sch_version_number%TYPE,
            grade                       igs_av_lgcy_unt_int.grade%TYPE,
            achievable_credit_points    igs_av_lgcy_unt_int.achievable_credit_points%TYPE,
            prev_unit_cd                igs_av_lgcy_unt_int.prev_unit_cd%TYPE,
            prev_term                   igs_av_lgcy_unt_int.prev_term%TYPE,
            tst_admission_test_type     igs_av_lgcy_unt_int.tst_admission_test_type%TYPE,
            tst_test_date               igs_av_lgcy_unt_int.tst_test_date%TYPE,
            test_segment_name           igs_av_lgcy_unt_int.test_segment_name%TYPE,
            alt_unit_cd                 igs_av_lgcy_unt_int.alt_unit_cd%TYPE,
            alt_version_number          igs_av_lgcy_unt_int.alt_version_number%TYPE,
            optional_ind                igs_av_lgcy_unt_int.optional_ind%TYPE,
            basis_program_type          igs_av_lgcy_unt_int.basis_program_type%TYPE,
            basis_year                  igs_av_lgcy_unt_int.basis_year%TYPE,
            basis_completion_ind        igs_av_lgcy_unt_int.basis_completion_ind%TYPE,
            start_date                  igs_av_lgcy_unt_int.start_date%TYPE,
            end_date                    igs_av_lgcy_unt_int.end_date%TYPE,
	    --  added jhanda bug 4327991
	    reference_cd_type           igs_av_lgcy_unt_int.reference_cd_type%TYPE,
            reference_cd                igs_av_lgcy_unt_int.reference_cd%TYPE,
            applied_program_cd          igs_av_lgcy_unt_int.applied_program_cd%TYPE

        );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_adv_stnd_unit                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Creates advanced standing unit                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |                    p_commit                                               |
 |                    p_lgcy_adstunt_rec                                     |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
/*#
 * The Advanced Standing Unit Legacy Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AV_LGCY_UNIT_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_lgcy_adstunt_rec Legacy Advanced Standing Unit record type. Refer to IGS_AV_LGCY_UNIT_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Unit Advanced Standing
 */
  PROCEDURE create_adv_stnd_unit
        (p_api_version                 IN NUMBER,
         p_init_msg_list               IN VARCHAR2 DEFAULT FND_API.G_FALSE,
         p_commit                      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
         p_validation_level            IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
         p_lgcy_adstunt_rec            IN OUT NOCOPY lgcy_adstunt_rec_type,
         x_return_status               OUT NOCOPY VARCHAR2,
         x_msg_count                   OUT NOCOPY NUMBER,
         x_msg_data                    OUT NOCOPY VARCHAR2
        );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              initialise                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Initialise the advanced standing lgcy_adstunt_rec_type record|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  :                                                              |
 |          IN/ OUT:   p_lgcy_adstunt_rec                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    jhanda    11-11-2002  Created                                          |
 +===========================================================================*/
 PROCEDURE initialise ( p_lgcy_adstunt_rec IN OUT NOCOPY lgcy_adstunt_rec_type );

END igs_av_unt_lgcy_pub;

 

/
