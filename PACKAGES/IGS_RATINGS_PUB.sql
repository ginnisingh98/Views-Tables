--------------------------------------------------------
--  DDL for Package IGS_RATINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RATINGS_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPRATS.pls 120.1 2006/01/18 01:13:49 rghosh noship $ */
/*#
 * This Package contains Public API's for assigning review groups and Evaluators to Admission Application.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Assign Review Groups and Evaluators
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_ADM_APPLICATION
 */

/*#
 * The Record Program Approval API is a public API that enables program approval to be recorded against an application instance. The API can be
 * called as part of workflow logic, through the action of data being entered or updated in the system and a subsequent business event being raised
 * or as a result of the evaluation of a particular sequence of logic.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_PERSON_ID Person ID
 * @param p_ADMISSION_APPL_NUMBER Admission Application number
 * @param p_NOMINATED_PROGRAM_CD Nominated Program Code
 * @param p_SEQUENCE_NUMBER Sequence Number
 * @param p_PGM_APPROVER_ID Program Approver ID
 * @param p_PROGRAM_APPROVAL_DATE Program Approval Date
 * @param p_PROGRAM_APPROVAL_STATUS Program Approval Status
 * @param p_APPROVAL_NOTES Approval Notes
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Record Program Approval
 */
PROCEDURE rec_pgm_approval
  (
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
		     p_person_id                   IN     NUMBER,
		     p_admission_appl_number       IN     NUMBER,
		     p_nominated_program_cd         IN     VARCHAR2,
		     p_sequence_number             IN     NUMBER,
		     p_pgm_approver_id             IN     NUMBER,
		     p_program_approval_date       IN     DATE,
		     p_program_approval_status     IN     VARCHAR2,
		     p_approval_notes              IN     VARCHAR2
  );


/*#
 * The Assign Review Profile and Evaluators API is a public API that enables Review Groups and Evaluators to be assigned to an application instance.
 * The API can be called as part of workflow logic, through the action of data being entered or updated in the system and a subsequent business event
 * being raised or as a result of the evaluation of a particular sequence of logic.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_PERSON_ID Person ID
 * @param p_ADMISSION_APPL_NUMBER Admission Application number
 * @param p_NOMINATED_PROGRAM_CD Nominated Program Code
 * @param p_SEQUENCE_NUMBER Sequence Number
 * @param p_APPL_REV_PROFILE_ID Review Profile ID
 * @param p_APPL_REVPROF_REVGR_ID Review Profile-Review Group ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initiate Application Evaluation
 */
 PROCEDURE ASSIGN_EVALUATORS_TO_AI (
   --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,

--Standard parameter ends

		    p_person_id                 IN  igs_ad_appl_arp_v.PERSON_ID%TYPE               ,
		    p_admission_appl_number     IN  igs_ad_appl_arp_v.ADMISSION_APPL_NUMBER%TYPE   ,
		    p_nominated_program_cd       IN  igs_ad_appl_arp_v.NOMINATED_COURSE_CD%TYPE     ,
		    p_sequence_number           IN  igs_ad_appl_arp_v.SEQUENCE_NUMBER%TYPE         ,
		    p_appl_rev_profile_id       IN  igs_ad_appl_arp_v.APPL_REV_PROFILE_ID%TYPE     ,
		    p_appl_revprof_revgr_id     IN  igs_ad_appl_arp_v.APPL_REVPROF_REVGR_ID%TYPE   ,

		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2
  );

END igs_ratings_pub;

 

/
