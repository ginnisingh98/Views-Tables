--------------------------------------------------------
--  DDL for Package IGS_PRECREATE_APPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PRECREATE_APPL_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPSAPS.pls 120.4 2006/05/31 08:00:24 arvsrini noship $ */
/*#
 * The Pre Create Application Package contains Public API's for Pre Creation of Admission Application.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Pre-Create Admission Application
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_ADM_APPLICATION
 */
-- Start of comments
--	API name 	: PRE_CREATE_APPLICATION
--	Type		: Public.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--					It is Required parameter. Its data type is Number
--				p_init_msg_list :
--					It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--					It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--					It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--				p_person_id	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Person Identifier.
--				p_appl_date	:
--					It is an optional parameter. Its datatype is DATE.
--					This parameter contains the Application Date.
--				p_acad_cal_type		:
--					It is a required parameter. Its datatype is VARCHAR2.
--					Maximum Length is 10. This parameter contains the Academic Calendar Type.
--				p_acad_cal_seq_number	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Academic Calendar Sequence Number.
--				p_adm_cal_type		:
--					It is a required parameter. Its datatype is VARCHAR2.
--					Maximum Length is 10. This parameter contains the Admission Calendar Type.
--				p_adm_cal_seq_number	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Admission Calendar Sequence Number.
--				p_entry_status		:
--					It is an optional parameter. Its datatype is NUMBER.
--					This parameter contains the Entry Status.
--				p_entry_level	:
--					It is an optional  parameter. Its datatype is NUMBER.
--					This parameter contains the Entry Level.
--				p_spcl_gr1	:
--					It is an optional parameter. Its datatype is NUMBER.
--					This parameter contains the Special Group1.
--				p_spcl_gr2	:
--					It is an optional parameter. Its datatype is NUMBER.
--					This parameter contains the Special Group2.
--				p_apply_for_finaid	:
--					It is an optional  parameter. Its datatype is VARCHAR2.
--					Maximum Length is 1. This parameter contains the Apply for Financial Aid indicator .
--				p_finaid_apply_date	:
--					It is an optional  parameter. Its datatype is DATE.
--					This parameter contains the Financial Aid Apply Date.
--				p_admission_application_type	:
--					It is a required parameter. Its datatype is VARCHAR2.
--					Maximum Length is 30. This parameter contains the Application Type.
--				p_apsource_id		:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Application Source Identifier.
--				p_application_fee_amount	:
--					It is an optional parameter. Its datatype is NUMBER.
--					This parameter contains the Application Fee Amount.
--
--      OUT             :	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--				x_ss_adm_appl_id	:
--				      Contains the Admission Application Identifier. Its DataType is NUMBER.
--	Version		: Current version	1.0
--			  previous version	N.A.
--			  Initial version 	1.0
--	Notes		: None.
--
-- End of comments
/*#
 * The Pre-Create Admission Application API is a public API that enables captured data to be populated into an unsubmitted admissions
 * application that is then completed and submitted via WEB self-service.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_PERSON_ID Person ID
 * @param p_APPL_DATE Application Date
 * @param p_ACAD_CAL_TYPE Academic Calendar Type
 * @param p_ACAD_CAL_SEQ_NUMBER Academic Calendar Sequence Number
 * @param p_ADM_CAL_TYPE Admission Calendar Type
 * @param p_ADM_CAL_SEQ_NUMBER Admission Calendar Sequence Number
 * @param p_ENTRY_STATUS Entry Status
 * @param p_ENTRY_LEVEL Entry Level
 * @param p_SPCL_GR1 Special Group1
 * @param p_SPCL_GR2 Special Group2
 * @param p_APPLY_FOR_FINAID Apply for Financial Aid indicator
 * @param p_FINAID_APPLY_DATE Financial Aid Apply Date
 * @param p_ADMISSION_APPLICATION_TYPE Application Type
 * @param p_APSOURCE_ID Application Source Identifier
 * @param p_APPLICATION_FEE_AMOUNT Application fee amount
 * @param X_SS_ADM_APPL_ID Admission Application Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pre-Create Admission Application
 */
   PROCEDURE PRE_CREATE_APPLICATION(
		    --Standard Parameters Start
		    p_api_version                 IN      NUMBER,
		    p_init_msg_list               IN	  VARCHAR2  default FND_API.G_FALSE,
		    p_commit                      IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level            IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status               OUT     NOCOPY    VARCHAR2,
		    x_msg_count		          OUT     NOCOPY    NUMBER,
		    x_msg_data                    OUT     NOCOPY    VARCHAR2,
		    --Standard Parameters Start
		    p_person_id		          IN	  NUMBER,
		    p_appl_date		          IN	  DATE,
		    p_acad_cal_type	          IN	  VARCHAR2,
		    p_acad_cal_seq_number         IN	  NUMBER,
		    p_adm_cal_type		  IN   	  VARCHAR2,
		    p_adm_cal_seq_number	  IN	  NUMBER,
		    p_entry_status		  IN   	  NUMBER,
		    p_entry_level		  IN   	  NUMBER,
		    p_spcl_gr1		   	  IN	  NUMBER,
		    p_spcl_gr2		          IN 	  NUMBER,
		    p_apply_for_finaid		  IN   	  VARCHAR2,
		    p_finaid_apply_date		  IN   	  DATE,
		    p_admission_application_type  IN	  VARCHAR2,
		    p_apsource_id		  IN   	  NUMBER,
		    p_application_fee_amount	  IN	  NUMBER,
		    x_ss_adm_appl_id		  OUT 	  NOCOPY	NUMBER
		);

-- Start of comments
--
--	API name 	: PRE_CREATE_APPLICATION_INST
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
--				p_ss_adm_appl_id	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Admission Application Identifier.
--				p_sch_apl_to_id		:
--					It is an optional parameter. Its datatype is NUMBER.
--					This parameter contains the School Applying to Identifier.
--				p_location_cd		:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 10. This parameter contains the Location Code.
--				p_attendance_type	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 2. This parameter contains the Attendance Type.
--				p_attendance_mode	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 2. This parameter contains the Attendance Mode.
--				p_attribute_category	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 30. This parameter contains the Descriptive flex field qualifier..
--				p_attribute1	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute2	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute3	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute4	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute5	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute6	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute7	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute8	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute9	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute10	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute11	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute12	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute13	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute14	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute15	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute16	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute17	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute18	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute19	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute20	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute21	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute22	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute23	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute24	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute25	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute26	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute27	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute28	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute29	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute30	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute31	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute32	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute33	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute34	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute35	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute36	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute37	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute38	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute39	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--				p_attribute40	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 150. This parameter contains the Standard Attribute Column. Meant for descriptive flex field.
--
--      OUT             :	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--				      G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--				x_ss_admappl_pgm_id    :
--				       It is the Admission Application Program Instance Identifier. Datatype is NUMBER.
--	Version		: Current version	1.0
--			  previous version	N.A.
--			  Initial version 	1.0
--	Notes		: None.
--
-- End of comments

/*#
 * The Pre-Create Admission Application Instance API is a public API that enables captured data to be populated into
 * an unsubmitted admissions application instance that is then completed and submitted via WEB self-service.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_SS_ADM_APPL_ID A unique identifier to identify a Self Service Admission Application
 * @param p_SCH_APL_TO_ID School Applying to Id
 * @param p_LOCATION_CD Location Code
 * @param p_ATTENDANCE_TYPE Attendance Type
 * @param p_ATTENDANCE_MODE Attendance Mode
 * @param p_ATTRIBUTE_CATEGORY Descriptive flex field qualifier.
 * @param p_ATTRIBUTE1 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE2 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE3 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE4 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE5 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE6 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE7 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE8 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE9 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE10 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE11 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE12 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE13 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE14 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE15 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE16 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE17 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE18 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE19 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE20 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE21 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE22 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE23 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE24 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE25 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE26 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE27 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE28 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE29 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE30 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE31 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE32 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE33 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE34 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE35 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE36 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE37 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE38 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE39 Standard Attribute Column. Meant for descriptive flex field.
 * @param p_ATTRIBUTE40 Standard Attribute Column. Meant for descriptive flex field.
 * @param X_SS_ADMAPPL_PGM_ID Admission Application Program Identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pre-Create Admission Application Instance
 */
   PROCEDURE PRE_CREATE_APPLICATION_INST(
			--Standard Parameters Start
			p_api_version           IN      NUMBER,
			p_init_msg_list         IN	VARCHAR2  default FND_API.G_FALSE,
			p_commit                IN      VARCHAR2  default FND_API.G_FALSE,
			p_validation_level      IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
			x_return_status         OUT     NOCOPY    VARCHAR2,
			x_msg_count		OUT     NOCOPY    NUMBER,
			x_msg_data              OUT     NOCOPY    VARCHAR2,
			--Standard Parameters Start
			p_ss_adm_appl_id	IN	NUMBER,
			p_sch_apl_to_id		IN	NUMBER,
			p_location_cd		IN	VARCHAR2,
			p_attendance_type	IN	VARCHAR2,
			p_attendance_mode	IN	VARCHAR2,
			p_attribute_category	IN	VARCHAR2,
			p_attribute1		IN	VARCHAR2,
			p_attribute2		IN	VARCHAR2,
			p_attribute3		IN	VARCHAR2,
			p_attribute4		IN	VARCHAR2,
			p_attribute5		IN	VARCHAR2,
			p_attribute6		IN	VARCHAR2,
			p_attribute7		IN	VARCHAR2,
			p_attribute8		IN	VARCHAR2,
			p_attribute9		IN	VARCHAR2,
			p_attribute10		IN	VARCHAR2,
			p_attribute11		IN	VARCHAR2,
			p_attribute12		IN	VARCHAR2,
			p_attribute13		IN	VARCHAR2,
			p_attribute14		IN	VARCHAR2,
			p_attribute15		IN	VARCHAR2,
			p_attribute16		IN	VARCHAR2,
			p_attribute17		IN	VARCHAR2,
			p_attribute18		IN	VARCHAR2,
			p_attribute19		IN	VARCHAR2,
			p_attribute20		IN	VARCHAR2,
			p_attribute21		IN	VARCHAR2,
			p_attribute22		IN	VARCHAR2,
			p_attribute23		IN	VARCHAR2,
			p_attribute24		IN	VARCHAR2,
			p_attribute25		IN	VARCHAR2,
			p_attribute26		IN	VARCHAR2,
			p_attribute27		IN	VARCHAR2,
			p_attribute28		IN	VARCHAR2,
			p_attribute29		IN	VARCHAR2,
			p_attribute30		IN	VARCHAR2,
			p_attribute31		IN	VARCHAR2,
			p_attribute32		IN	VARCHAR2,
			p_attribute33		IN	VARCHAR2,
			p_attribute34		IN	VARCHAR2,
			p_attribute35		IN	VARCHAR2,
			p_attribute36		IN	VARCHAR2,
			p_attribute37		IN	VARCHAR2,
			p_attribute38		IN	VARCHAR2,
			p_attribute39		IN	VARCHAR2,
			p_attribute40		IN	VARCHAR2,
			x_ss_admappl_pgm_id     OUT     NOCOPY		NUMBER
   );

-- Start of comments
--
--	API name 	: INSERT_STG_FEE_REQ_DET
--	Type		: Public.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit	:
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--				p_SS_ADM_APPL_ID   :
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Admission Application Identifier.
--				p_PERSON_ID	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Person Identifier.
--				p_APPLICANT_FEE_TYPE	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Application Fee Type.
--				p_APPLICANT_FEE_STATUS	:
--					It is a required parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Applicant Fee Status.
--				p_FEE_DATE	:
--					It is a required parameter. Its datatype is DATE.
--					This parameter contains the Fee Date.
--				p_FEE_PAYMENT_METHOD	:
--					It is an optional parameter. Its datatype is NUMBER.
--					Maximum Length is 15. This parameter contains the Fee Payment Methods.
--				p_FEE_AMOUNT	:
--					It is a required parameter. Its datatype is NUMBER.
--					This parameter contains the Fee Amount.
--				p_REFERENCE_NUM	:
--					It is an optional parameter. Its datatype is VARCHAR2.
--					Maximum Length is 60. This parameter contains the Reference Number.
--
--      OUT             :	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--				      G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--
--	Version		: Current version	1.0
--			  previous version	N.A.
--			  Initial version 	1.0
--	Notes		: None.
--
-- End of comments
/*#
 * The Admission Fee Detail API is a public API that enables customers to insert fee transaction records (most notably waivers) on the basis of data captured in the create application flow
 * application on its submission via WEB self-service.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_SS_ADM_APPL_ID Self-Service Admission Application Identifier
 * @param p_PERSON_ID Person Identifier
 * @param p_APPLICANT_FEE_TYPE Application Fee Type
 * @param p_APPLICANT_FEE_STATUS Application Fee Status
 * @param p_FEE_DATE Application Fee Date
 * @param p_FEE_PAYMENT_METHOD Fee Payment Method
 * @param p_FEE_AMOUNT Fee Amount Paid
 * @param p_REFERENCE_NUM Transaction Reference Number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Admission Fee Detail
 */
PROCEDURE INSERT_STG_FEE_REQ_DET (
       p_api_version IN NUMBER,					-- standard Public API IN params
       p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
       p_commit	IN VARCHAR2 default FND_API.G_FALSE,
       p_validation_level IN NUMBER :=FND_API.G_VALID_LEVEL_FULL,
       x_return_status OUT NOCOPY VARCHAR2,				-- standard Public API OUT params
       x_msg_count OUT NOCOPY NUMBER,
       x_msg_data OUT NOCOPY VARCHAR2,
       p_SS_ADM_APPL_ID IN NUMBER,				-- Staging table related params
       p_PERSON_ID IN NUMBER,
       p_APPLICANT_FEE_TYPE IN NUMBER,
       p_APPLICANT_FEE_STATUS IN NUMBER,
       p_FEE_DATE IN DATE,
       p_FEE_PAYMENT_METHOD IN NUMBER,
       p_FEE_AMOUNT IN NUMBER,
       p_REFERENCE_NUM IN VARCHAR2
  );

END IGS_PRECREATE_APPL_PUB;

 

/
