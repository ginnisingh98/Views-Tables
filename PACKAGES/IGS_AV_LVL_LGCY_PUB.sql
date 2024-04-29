--------------------------------------------------------
--  DDL for Package IGS_AV_LVL_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_LVL_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPAV1S.pls 120.2 2006/01/17 03:53:06 ijeddy ship $ */
/*#
 * The Advanced Standing Unit Level Legacy Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AV_LGCY_LVL_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Level Advanced Standing
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_ADV_STAND
 */

  -- RECORD type variable for the table igs_av_lgcy_lvl_int
  TYPE lgcy_adstlvl_rec_type IS RECORD
       (
        person_number                   igs_av_lgcy_lvl_int.person_number%TYPE                   ,
        program_cd                      igs_av_lgcy_lvl_int.program_cd%TYPE                      ,
        total_exmptn_approved           igs_av_lgcy_lvl_int.total_exmptn_approved%TYPE           ,
        total_exmptn_granted            igs_av_lgcy_lvl_int.total_exmptn_granted%TYPE            ,
        total_exmptn_perc_grntd         igs_av_lgcy_lvl_int.total_exmptn_perc_grntd%TYPE         ,
        exemption_institution_cd        igs_av_lgcy_lvl_int.exemption_institution_cd%TYPE        ,
        unit_level                      igs_av_lgcy_lvl_int.unit_level%TYPE                      ,
        prog_group_ind                  igs_av_lgcy_lvl_int.prog_group_ind%TYPE                  ,
        load_cal_alt_code               igs_av_lgcy_lvl_int.load_cal_alt_code%TYPE               ,
        institution_cd                  igs_av_lgcy_lvl_int.institution_cd%TYPE                  ,
        s_adv_stnd_granting_status      igs_av_lgcy_lvl_int.s_adv_stnd_granting_status%TYPE      ,
        credit_points                   igs_av_lgcy_lvl_int.credit_points%TYPE                   ,
        approved_dt                     igs_av_lgcy_lvl_int.approved_dt%TYPE                     ,
        authorising_person_number       igs_av_lgcy_lvl_int.authorising_person_number%TYPE       ,
        granted_dt                      igs_av_lgcy_lvl_int.granted_dt%TYPE                      ,
        expiry_dt                       igs_av_lgcy_lvl_int.expiry_dt%TYPE                       ,
        cancelled_dt                    igs_av_lgcy_lvl_int.cancelled_dt%TYPE                    ,
        revoked_dt                      igs_av_lgcy_lvl_int.revoked_dt%TYPE                      ,
        comments                        igs_av_lgcy_lvl_int.comments%TYPE                        ,
        qual_exam_level                 igs_av_lgcy_lvl_int.qual_exam_level%TYPE                 ,
        qual_subject_code               igs_av_lgcy_lvl_int.qual_subject_code%TYPE               ,
        qual_year                       igs_av_lgcy_lvl_int.qual_year%TYPE                       ,
        qual_sitting                    igs_av_lgcy_lvl_int.qual_sitting%TYPE                    ,
        qual_awarding_body              igs_av_lgcy_lvl_int.qual_awarding_body%TYPE              ,
        approved_result                 igs_av_lgcy_lvl_int.approved_result%TYPE                 ,
        prev_unit_cd                    igs_av_lgcy_lvl_int.prev_unit_cd%TYPE                    ,
        prev_term                       igs_av_lgcy_lvl_int.prev_term%TYPE                       ,
	start_date                      igs_av_lgcy_lvl_int.start_date%TYPE                      ,
	end_date                        igs_av_lgcy_lvl_int.end_date%TYPE                        ,
        tst_admission_test_type         igs_av_lgcy_lvl_int.tst_admission_test_type%TYPE         ,
        tst_test_date                   igs_av_lgcy_lvl_int.tst_test_date%TYPE                   ,
        test_segment_name               igs_av_lgcy_lvl_int.test_segment_name%TYPE               ,
        basis_program_type              igs_av_lgcy_lvl_int.basis_program_type%TYPE              ,
        basis_year                      igs_av_lgcy_lvl_int.basis_year%TYPE                      ,
        basis_completion_ind            igs_av_lgcy_lvl_int.basis_completion_ind%TYPE             ,
        unit_level_mark                 igs_av_lgcy_lvl_int.unit_level_mark%TYPE -- jhanda added unit_level_mark record member


       );

/*#
 * The Advanced Standing Unit Level Legacy Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_AV_LGCY_LVL_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_lgcy_adstlvl_rec Legacy Advanced Standing Unit Level record type. Refer to IGS_AV_LGCY_LVL_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Level Advanced Standing
 */
  PROCEDURE create_adv_stnd_level
            (p_api_version                 IN NUMBER,
	     p_init_msg_list               IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_commit                      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_validation_level            IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
	     p_lgcy_adstlvl_rec            IN OUT NOCOPY lgcy_adstlvl_rec_type,
	     x_return_status               OUT NOCOPY VARCHAR2,
	     x_msg_count                   OUT NOCOPY NUMBER,
	     x_msg_data                    OUT NOCOPY VARCHAR2
	    );
   /*
      Usage of create_adv_stnd_level
      Initialise the variable p_lgcy_adstlvl_rec using
      initialise so that the values are set to NULL
      Now, set the value of each element
   */

   PROCEDURE initialise ( p_lgcy_adstlvl_rec IN OUT NOCOPY lgcy_adstlvl_rec_type );

END igs_av_lvl_lgcy_pub;

 

/
