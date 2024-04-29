--------------------------------------------------------
--  DDL for Package IGS_PR_CLSRNK_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_CLSRNK_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPPR2S.pls 120.1 2006/01/17 03:54:19 ijeddy noship $ */
/*#
 * The Class Rank Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_PR_LGY_CLSR_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Class Rank
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */
  -- RECORD type variable for the table igs_av_lgcy_lvl_int
  TYPE lgcy_clsrnk_rec_type IS RECORD
       (
	person_number                  igs_pr_lgy_clsr_int.person_number%TYPE,
	program_cd                     igs_pr_lgy_clsr_int.program_cd%TYPE,
	cohort_name                    igs_pr_lgy_clsr_int.cohort_name%TYPE,
	calendar_alternate_code        igs_pr_lgy_clsr_int.calendar_alternate_code%TYPE,
	cohort_rank                    igs_pr_lgy_clsr_int.cohort_rank%TYPE,
	cohort_override_rank           igs_pr_lgy_clsr_int.cohort_override_rank%TYPE,
	comments                       igs_pr_lgy_clsr_int.comments%TYPE,
	as_of_rank_gpa                 igs_pr_lgy_clsr_int.as_of_rank_gpa%TYPE
       );

/*#
 * The Class Rank Legacy import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_PR_LGY_CLSR_INT interface table.
 * @param p_api_version The version number will be used to compare with claim public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_TRUE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_TRUE to have API to commit automatically.
 * @param p_validation_level Public API will always perform full level of validation.
 * @param p_lgcy_clsrnk_rec Legacy Class Rank record type. Refer to IGS_PR_LGY_CLSR_INT for detail column descriptions.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXP_ERROR.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Class Rank
 */
  PROCEDURE create_class_rank
            (p_api_version                 IN NUMBER,
	     p_init_msg_list               IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_commit                      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_validation_level            IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
	     p_lgcy_clsrnk_rec             IN lgcy_clsrnk_rec_type,
	     x_return_status               OUT NOCOPY VARCHAR2,
	     x_msg_count                   OUT NOCOPY NUMBER,
	     x_msg_data                    OUT NOCOPY VARCHAR2
	    );
   /*
      Usage of create_adv_stnd_level
      Initialise the variable p_lgcy_clsrnk_rec using
      initialise so that the values are set to NULL
      Now, set the value of each element
   */

   PROCEDURE initialise ( p_lgcy_clsrnk_rec IN OUT NOCOPY lgcy_clsrnk_rec_type );

END igs_pr_clsrnk_lgcy_pub;

 

/
