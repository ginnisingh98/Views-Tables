--------------------------------------------------------
--  DDL for Package IGS_ADMAPPLICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ADMAPPLICATION_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPAPPS.pls 120.5 2006/09/21 11:46:13 rghosh noship $ */
/*#
 * This Package contains Public API's for giving ratings,Outcome,offer reponse and Qualification codes to an Admission Application
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Admission Application
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_ADM_APPLICATION
 */
-- Start of comments
--	API name 	: RECORD_ACADEMIC_INDEX
--	Type		: Public.
--	Function	: To record Academic index value for an application instance.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--                              p_person_id      :
--                                     It is a Required parameter. Its data type is Number.
--                                     Maximum length is 15.Unique identifier assigned to the Applicant
--		                p_admission_appl_number :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 2.This holding the admission application number
--                                     associated with the applicant's application
--		                p_nominated_program_cd  :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 6.This holding the program code of the program
--                                     for that the applicant is seeking admission
--		                p_sequence_number  :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 6.This holding the sequence number of the application
--				p_predicted_gpa :
--                                     Its data type is Number(5,2).
--                                     maximum length is (5,2).This holding the new predicated GPA to
--                                     be recorded
--		                p_academic_index :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 10.This holding the new Academic index to
--                                     be recorded
--		                p_calculation_date :
--                                     Its data type is Date.
--                                     This holding the Calculation date of Academic Index and GPA

--	OUT		:	x_return_status	:
--                                    It is out parameter that will contain teh return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--	Version	: Current version	1.0
--				Changed....
--			  previous version	N.A.
--			  Initial version 	1.0
--	Notes		: None.
-- End of comments
 /*#
 * The Record Academic Index API is a public API that enables Academic Index and Predicted GPA to be recorded against an application instance.
 * The API can be called as part of workflow logic, through the action of data being entered or updated in the system and a subsequent business
 * event being raised or as a result of the evaluation of a particular sequence of logic.
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
 * @param p_PREDICTED_GPA Predicted GPA
 * @param p_ACADEMIC_INDEX Academic index
 * @param p_CALCULATION_DATE Calculation Date
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Record Indices
 */
 PROCEDURE RECORD_ACADEMIC_INDEX(
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id             IN      NUMBER,
		    p_admission_appl_number IN      NUMBER,
		    p_nominated_program_cd   IN      VARCHAR2,
		    p_sequence_number       IN      NUMBER,
		    p_predicted_gpa         IN      NUMBER DEFAULT NULL,
		    p_academic_index        IN      VARCHAR2,
		    p_calculation_date      IN      DATE DEFAULT NULL
);

-- Start of comments
--	API name 	: Record_Outcome_AdmApplication
--	Type		: Public.
--	Function	: This API will enable Outcome and Offer details to be recorded for an application instance.
--                        Through a call to the API it will be possible to setup Outcome, Override Outcome,
--                        Conditional Offer and Offer Deadline details.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--                              p_person_id      :
--                                     It is a Required parameter. Its data type is Number.
--                                     Maximum length is 15.Unique identifier assigned to the Applicant
--		                p_admission_appl_number :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 2.This holding the admission application number
--                                     associated with the applicant's application
--		                p_nominated_program_cd  :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 6.This holding the program code of the program
--                                     for that the applicant is seeking admission
--		                p_sequence_number  :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 6.This holding the sequence number of the application
--		                p_adm_outcome_status :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 10.This holding the new outcome status of the admission
--                                     program application instance be recorded
--				p_decision_make_id :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 15.This holding the Decision maker person identifier
--		                p_decision_date :
--                                     It is a Required parameter. Its data type is Date.
--                                     This holding the Date when the decision was made
--		                p_decision_reason_id :
--                                     It is an Optional parameter. Its data type is Number.
--                                     The maximum length is 15 .This holding the Decision reason identifier
--		                p_pending_reason_id :
--                                     It is an Optional parameter. Its data type is Number.
--                                     The maximum length is 15 .This holding the Pending reason identifier
--		                p_offer_dt :
--                                     It is an Optional parameter. Its data type is Date.
--                                     This holding the date that an offer of admission was made to the applicant
--		                p_adm_outcome_status_auth_dt :
--                                     It is an Optional parameter. Its data type is Date.
--                                     This holding the date that change to the Admission Outcome Status was authorized
--		                p_adm_otcm_status_auth_per_id :
--                                     It is an Optional parameter. Its data type is Number.
--                                     The maximum length is 15. This holding the identifier of the person
--                                     who authorized the change to the Admission Outcome Status
--		                p_adm_outcome_status_reason :
--                                     It is an Optional parameter. Its data type is Varchar2.
--                                     The maximum length is 60. This holding the reason used to
--                                     further describe the Admission Outcome Status
--		                p_adm_cndtnl_offer_status :
--                                     It is an Optional parameter. Its data type is Varchar2.
--                                     The maximum length is 10. This holding the status assigned
--                                     to an admission program application in relation to a conditional offer
--		                p_cndtnl_offer_cndtn :
--                                     It is an Optional parameter. Its data type is Varchar2.
--                                     The maximum length is 2000. This holding the The conditions of a
--                                     conditional offer.
--		                p_cndtl_offer_must_stsfd_ind :
--                                     It is an Optional parameter. Its data type is Varchar2.
--                                     The maximum length is 1. This contains whether or not a conditional
--                                     offer must be satisfied before the offer can be accepted
--		                p_cndtnl_offer_satisfied_dt :
--                                     It is an Optional parameter. Its data type is Date.
--                                     This contains The date that a conditional offer was satisfied or waived
--		                p_offer_response_dt :
--                                     It is an Optional parameter. Its data type is Date.
--                                     This contains The date by which an applicant
--                                     must respond to the offer of admission
--		                p_reconsider_flag:
--                                     It is an Optional parameter. Its data type is Varchar2.
--                                     The maximum length is 1. This contains application reconsideration flag
--		                p_prpsd_commencement_date :
--                                     It is an Optional parameter. Its data type is Date.
--                                     This contains he proposed commencement date for enrollment in a program
--		                p_ucas_transaction:
--                                     It is an Optional parameter. Its data type is Varchar2.
--                                     The maximum length is 1. This variable decides whether user UCAS HOOK(igs_ad_ps_appl_inst_pkg.ucas_user_hook)
--                                      will be called or not. if 'Y' then it will be called else not.


--	OUT		:	x_return_status	:
--                                    It is out parameter that will contain teh return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--	Version	: Current version	1.0
--				Changed....
--			  previous version	N.A.
--			  Initial version 	1.0
--	Notes		: None.
-- End of comments
/*#
 * The Record Outcome Status API is a public API that enables Outcome and Offer details to be recorded for an application instance.
 * The API can be called as part of workflow logic, through the action of data being entered or updated in the system and a subsequent business
 * event being raised or as a result of the evaluation of a particular sequence of logic.
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
 * @param p_ADM_OUTCOME_STATUS Outcome Status
 * @param p_DECISION_MAKER_ID Decision Maker ID
 * @param p_DECISION_DATE Date on which the admission decision is taken
 * @param p_DECISION_REASON_ID Identifier of the reason to make such a decision
 * @param p_PENDING_REASON_ID Identifier of the reason that the application is pending
 * @param p_OFFER_DT Date on which the offer is made on the application
 * @param p_ADM_OUTCOME_STATUS_AUTH_DT Describes the date that the outcome status was authorized.
 * @param p_ADM_OTCM_STATUS_AUTH_PER_ID Describes the outcome status authorising person ID
 * @param p_ADM_OUTCOME_STATUS_REASON Used to further describe a status, for example, an outcome status of Revoked may have associated reason for the revocation
 * @param p_ADM_CNDTNL_OFFER_STATUS Describes the status assigned to an admission program application in relation to a conditional offer
 * @param p_CNDTNL_OFFER_CNDTN Describes the conditions of a conditional offer. An assessor may use this field to list conditions the applicant must satisfy in order to satisfy the conditional offer.
 * @param p_CNDTL_OFFER_MUST_STSFD_IND Determines whether conditional offer must be satisfied for conditional offer
 * @param p_CNDTNL_OFFER_SATISFIED_DT Describes the date that a conditional offer was satisfied or waived.
 * @param p_OFFER_RESPONSE_DT Date the person to respond on the offer made
 * @param p_RECONSIDER_FLAG Reconsideration flag indicating whether the Application instance has to be reconsider or not.
 * @param p_PRPSD_COMMENCEMENT_DATE Proposed Commencement Date
 * @param p_UCAS_TRANSACTION Determines whether the UCAS transcation should be generated for UK institutions
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Record Admissions Decision
 */
 PROCEDURE Record_Outcome_AdmApplication
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,

	p_person_id                        NUMBER                       ,
	p_admission_appl_number            NUMBER                       ,
	p_nominated_program_cd              VARCHAR2                     ,
	p_sequence_number                  NUMBER                       ,
	p_adm_outcome_status               VARCHAR2                     ,
	p_decision_maker_id                 NUMBER                       ,
	p_decision_date                    DATE                         ,
	p_decision_reason_id               NUMBER        DEFAULT NULL   ,
	p_pending_reason_id                NUMBER        DEFAULT NULL   ,
	p_offer_dt                         DATE          DEFAULT NULL   ,
     -- Columns for Override Outcome
	p_adm_outcome_status_auth_dt       DATE          DEFAULT NULL   ,
        p_adm_otcm_status_auth_per_id      NUMBER  	 DEFAULT NULL   ,
        p_adm_outcome_status_reason       VARCHAR2 	 DEFAULT NULL   ,
    -- Columns for Conditional Offer Status
	p_adm_cndtnl_offer_status         VARCHAR2       DEFAULT NULL   ,
        p_cndtnl_offer_cndtn              VARCHAR2       DEFAULT NULL   ,
        p_cndtl_offer_must_stsfd_ind	  VARCHAR2	 DEFAULT NULL    ,
        p_cndtnl_offer_satisfied_dt       DATE		 DEFAULT NULL   ,

	p_offer_response_dt                        DATE          DEFAULT NULL   ,
	p_reconsider_flag                          VARCHAR2      DEFAULT 'N'    ,
	p_prpsd_commencement_date                  DATE          DEFAULT NULL   ,
	p_ucas_transaction                         VARCHAR2      DEFAULT 'N'    ,

	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER				,
	x_msg_data		OUT	NOCOPY VARCHAR2

) ;


-- Start of comments
--	API name 	: RECORD_OFFER_RESPONSE
--	Type		: Public.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--                              p_person_id      :
--                                     It is a Required parameter. Its data type is Number.
--                                     Maximum length is 15.Unique identifier assigned to the Applicant
--		                p_admission_appl_number :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 2.This holding the admission application number
--                                     associated with the applicant's application
--		                p_nominated_program_cd  :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 6.This holding the program code of the program
--                                     for that the applicant is seeking admission
--		                p_sequence_number  :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 6.This holding the sequence number of the application
--				p_adm_offer_resp_status  :
--					It is a Required parameter. Its data type is Varchar2.
--                                      maximum length is 10. It Describes the offer response status of the
--					admission program application instance
--				p_actual_response_dt  :
--					It is a Required parameter. Its data type is DATE.
--                                      It Describes the actual date a response was made by an applicant to an offer
--				p_response_comments  :
--					It is a Required parameter.Its data type is
--                                      maximum length is 2000. It Describes comments regarding the applicant's
--					response to the offer.
--				p_def_acad_cal_type  :
--					It is a Required parameter.Its data type is Varchar2
--                                      maximum length is 10
--				p_def_acad_ci_sequence_num  :
--					It is a Required parameter.Its data type is
--                                      maximum length is 6
--				p_def_adm_cal_type  :
--					It is a Required parameter.Its data type is Varchar2
--                                      maximum length is 10
--				p_def_adm_ci_sequence_num  :
--					It is a Required parameter.Its data type is NUMBER
--                                      maximum length is 6.
--				p_decline_ofr_reason  :
--					It is a Required parameter.Its data type is Varchar2
--                                      maximum length is 60. It describes Reason for declining offer.
--				p_attent_other_inst_cd  :
--					It is a Required parameter.Its data type is Varchar2
--                                      maximum length is 10. It describes Intend to attend other institution code
--
--      OUT             :	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--	Version		: Current version	2.0
--			  previous version	1.0.
--			  Initial version 	1.0
--	Notes		: None.
--
-- End of comments

/*#
 * The Record Offer Response API is a public API that enables Offer Response details to be recorded for an application
 * instance.  The API can be called as part of workflow logic, through the action of data being entered or updated in
 * the system and a subsequent business event being raised or as a result of the evaluation of a particular sequence of logic.
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
 * @param p_ADM_OFFER_RESp_STATUS Offer Response Status
 * @param p_ACTUAL_RESPONSE_DT Offer Response Date
 * @param p_RESPONSE_COMMENTS Response Comments
 * @param p_DEF_ACAD_CAL_TYPE Deferred Academic Calendar Type
 * @param p_DEF_ACAD_CI_SEQUENCE_NUM Deferred Academic Calendar sequence number
 * @param p_DEF_ADM_CAL_TYPE Deferred Admission Calendar Type
 * @param p_DEF_ADM_CI_SEQUENCE_NUM Deferred Admission Calendar sequence number
 * @param p_DECLINE_OFR_REASON Reason For Declining Offer
 * @param p_ATTENT_OTHER_INST_CD Intend To Attend Other Institution Code
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Record Offer Response
 */
 PROCEDURE RECORD_OFFER_RESPONSE(
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id                 IN      NUMBER,
		    p_admission_appl_number 	IN      NUMBER,
		    p_nominated_program_cd   	IN      VARCHAR2,
		    p_sequence_number       	IN      NUMBER,
		    p_adm_offer_resp_status     IN      VARCHAR2, --Varchar2(10)  LOV(validation exists in Form(PLD))
		    p_actual_response_dt        IN      DATE,  --validation exists in form(pld)
		    p_response_comments         IN      VARCHAR2, --VARCHAR2(2000)
		    p_def_acad_cal_type         IN      VARCHAR2, --Varchar2(10)
		    p_def_acad_ci_sequence_num  IN      NUMBER,   --NUMBER(5)
		    p_def_adm_cal_type          IN      VARCHAR2, --Varchar2(10)
		    p_def_adm_ci_sequence_num   IN      NUMBER,   --NUMBER(5)
		    p_decline_ofr_reason	IN	VARCHAR2,
		    p_attent_other_inst_cd	IN	VARCHAR2
);

-- Start of comments
--	API name 	: RECORD_QUALIFICATION_CODE
--	Type		: Public.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--                              p_person_id      :
--                                     It is a Required parameter. Its data type is Number.
--                                     Maximum length is 15.Unique identifier assigned to the Applicant
--		                p_admission_appl_number :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 2.This holding the admission application number
--                                     associated with the applicant's application
--		                p_nominated_program_cd  :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 6.This holding the program code of the program
--                                     for that the applicant is seeking admission
--		                p_sequence_number  :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 6.This holding the sequence number of the application
--				p_qualifying_type  :
--					It is a Required parameter.Its data type is VARCHAR2
--                                      maximum length is 30.This holds the Qualifying Types.
--				p_qualifying_code  :
--					It is a Required parameter.Its data type is Varchar2
--                                      maximum length is 10. It holds the qualification Code.
--				p_qualifying_value  :
--					It is a Required parameter.Its data type is Varchar2
--                                      maximum length is 80. It contains the Qualifying value
--
--      OUT             :	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--	Version		: Current version	1.0
--			  previous version	NA(Newly Created)
--			  Initial version 	1.0
--	Notes		: None.
--
-- End of comments
/*#
 * The Record Qualifying Codes API is a public API that enables Application Instance Qualifying Codes and or Values to be
 * recorded against an application instance.  The API can be called as part of workflow logic, through the action of data
 * being entered or updated in the system and a subsequent business event being raised or as a result of the evaluation
 * of a particular sequence of logic.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_PERSON_ID Person ID
 * @param p_ADMISSION_APPL_NUMBER Admission Application number
 * @param p_NOMINATED_COURSE_CD Nominated Course Code
 * @param p_SEQUENCE_NUMBER Sequence Number
 * @param p_QUALIFYING_TYPE_CODE Qualifying Type
 * @param p_QUALIFYING_CODE Qualifying Code Name
 * @param p_QUALIFYING_VALUE Qualifying Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Application Instance Qualifying Codes
 */
 PROCEDURE RECORD_QUALIFICATION_CODE(
                    p_api_version           	IN	NUMBER				,
		    p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE	,
		    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
		    p_validation_level		IN  	NUMBER	:=
		    					FND_API.G_VALID_LEVEL_FULL	,
		    p_person_id                 IN      NUMBER,
		    p_admission_appl_number     IN      NUMBER,
		    p_nominated_course_cd       IN      VARCHAR2,
		    p_sequence_number           IN      NUMBER,
		    p_qualifying_type_code      IN      VARCHAR2,
	            p_qualifying_code           IN      VARCHAR2,
		    p_qualifying_value          IN      VARCHAR2,
		    x_return_status             OUT     NOCOPY    VARCHAR2,
		    x_msg_count		        OUT     NOCOPY    NUMBER,
		    x_msg_data                  OUT     NOCOPY    VARCHAR2
);

-- Start of comments
--	API name 	: UPDATE_ENTRY_QUAL_STATUS
--	Type		: Public.
--	Function	: To enable the user to update the entry qualification status of an application instance
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--                              p_person_id      :
--                                     It is a Required parameter. Its data type is Number.
--                                     Maximum length is 15.Unique identifier assigned to the Applicant
--		                p_admission_appl_number :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 2.This holds the admission application number
--                                     associated with the applicant's application
--		                p_nominated_program_cd  :
--                                     It is a Required parameter. Its data type is Varchar2.
--                                     maximum length is 6.This holds the program code of the nominated program
--                                     for which the applicant is seeking admission
--		                p_sequence_number  :
--                                     It is a Required parameter. Its data type is Number.
--                                     maximum length is 6.This holds the sequence number of the application
--		                p_entry_qual_status  :
--				       This is a required parameter. Its data type is  Varchar2.
--				       Maximum length is 10. This holds the details about the Entry Qualification
--				       status of an application.
--      OUT             :	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--	Version		: Current version	1.0
--			  previous version	NA(Newly Created)
--			  Initial version 	1.0
--	Notes		: None.
--
-- End of comments
/*#
 * The Update Entry Qualification Status API is a public API that enables the user to update the Entry Qualification
 * Status of an application instance.
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
 * @param p_ENTRY_QUAL_STATUS Entry Qualification Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Entry Qualification Status
 */
PROCEDURE UPDATE_ENTRY_QUAL_STATUS(
 --Standard Parameters Start
                    p_api_version           IN      NUMBER,
		    p_init_msg_list         IN      VARCHAR2  default FND_API.G_FALSE,
		    p_commit                IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level      IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status         OUT     NOCOPY    VARCHAR2,
		    x_msg_count		    OUT     NOCOPY    NUMBER,
		    x_msg_data              OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id             IN      NUMBER,
		    p_admission_appl_number IN      NUMBER,
		    p_nominated_program_cd  IN      VARCHAR2,
		    p_sequence_number       IN      NUMBER,
		    p_entry_qual_status     IN      VARCHAR2
);

 END igs_admapplication_pub;

 

/
