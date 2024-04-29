--------------------------------------------------------
--  DDL for Package GMS_AWARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARD_PVT" AUTHID CURRENT_USER AS
-- $Header: gmsawpvs.pls 120.1 2007/02/06 09:48:44 rshaik ship $


	-- ---------------------------------------------
	-- reset_msg_init
	-- This is called from gms_award_pub API.
	-- This is used to reset flags indicating that
	-- message table has not  been initialized.
	-- ---------------------------------------------
	PROCEDURE reset_message_flag ;


	-- ---------------------------------------------
	-- init_message_stack
	-- Initialize the message stack here.
	-- ---------------------------------------------
	PROCEDURE init_message_stack ;



	-- ---------------------------------------------
	-- add_message_to_stack
	-- Common program unit used to set the message
	-- in the stack.
	-- ---------------------------------------------
	PROCEDURE add_message_to_stack( P_Label	IN Varchar2,
				    P_token1	IN varchar2 DEFAULT NULL,
				    P_val1	IN varchar2 DEFAULT NULL,
				    P_token2	IN varchar2 DEFAULT NULL,
				    P_val2	in varchar2 DEFAULT NULL,
				    P_token3	IN varchar2 DEFAULT NULL,
				    P_val3	in varchar2 DEFAULT NULL ) ;


	PROCEDURE set_return_status(X_return_status IN OUT NOCOPY VARCHAR2,
				 p_type in varchar2 DEFAULT 'B' ) ;
	---------------------------------------------------------------------------
	--
    	-- CREATE_AWARD
    	-- Create award is a private API provided to create award
    	-- into grants accounting. This is the API used to
    	-- transfer Legacy system data into grants accounting.
    	-- OUT NOCOPY Parameters meanings
    	-- X_MSG_COUNT              :   Holds no. of messages in the global
    	--                              message table.
    	-- X_MSG_DATE               :   Holds the message code, if the API
    	--                              returned only one error/warning message.
    	-- X_return_status          :   The indicator of success/Failure
    	--                              S- Success, E- and U- Failure
    	-- p_award_id               :   The Award ID created.
	---------------------------------------------------------------------------
	-- Create Award
	-- ======================================================================

	PROCEDURE	create_award( 	X_msg_count		IN OUT NOCOPY	NUMBER	,
					X_MSG_DATA		IN OUT NOCOPY	varchar2	,
					X_return_status		IN OUT NOCOPY	varchar2,
					X_ROW_ID		OUT NOCOPY	VARCHAR2,
					X_AWARD_ID		OUT NOCOPY	NUMBER 	,
					P_CALLING_MODULE	IN	VARCHAR2,
					P_API_VERSION_NUMBER	IN	NUMBER	,
					P_AWARD_REC		IN	GMS_AWARDS_ALL%ROWTYPE	 ) ;

	-- ===========================================================
	-- COPY_AWARD :
	-- Copy award has all the parameters that we have in quick entry for award.
	-- The ID's in the table are replaced by corresponding value. Users must
	-- provide decode values instead of code values.
	-- P_return_status 	: 	S- Success,
	--				E- Business Rule Validation error
	--				U- Unexpected Error
	-- P_API_VERSION_NUMBER	:	1.0
	-- ===============================================================================
	PROCEDURE	COPY_AWARD(
				X_MSG_COUNT			IN OUT NOCOPY	NUMBER,
				X_MSG_DATA			IN OUT NOCOPY	VARCHAR2,
				X_return_status		      	IN OUT NOCOPY	VARCHAR2,
				P_AWARD_NUMBER			IN OUT NOCOPY	VARCHAR2,
				X_AWARD_ID		      	OUT NOCOPY	NUMBER,
				P_CALLING_MODULE	  	IN	VARCHAR2,
				P_API_VERSION_NUMBER	  	IN	NUMBER,
				P_AWARD_BASE_ID			IN	NUMBER,
				P_AWARD_SHORT_NAME		IN	VARCHAR2 	DEFAULT NULL,
				P_AWARD_FULL_NAME		IN	VARCHAR2 	DEFAULT NULL,
				P_AWARD_START_DATE 		IN	DATE 		DEFAULT NULL,
				P_AWARD_END_DATE 		IN	DATE 		DEFAULT NULL,
				P_AWARD_CLOSE_DATE		IN	DATE 		DEFAULT NULL,
				P_PREAWARD_DATE			IN	DATE 		DEFAULT NULL,
				P_AWARD_PURPOSE_CODE		IN 	VARCHAR2 	DEFAULT NULL,
				P_AWARD_STATUS_CODE		IN	VARCHAR2 	DEFAULT NULL,
				P_AWARD_MANAGER_ID		IN	NUMBER 		DEFAULT NULL,
				P_AWARD_ORGANIZATION_ID		IN	NUMBER 		DEFAULT NULL,
				P_FUNDING_SOURCE_ID		IN	NUMBER 		DEFAULT NULL,
				P_FUNDING_SOURCE_AWARD_NUM	IN	VARCHAR2 	DEFAULT NULL,
				P_ALLOWABLE_SCHEDULE_ID		IN	VARCHAR2 	DEFAULT NULL,
				P_INDIRECT_SCHEDULE_ID		IN	VARCHAR2 	DEFAULT NULL,
				P_COST_IND_SCH_FIXED_DATE	IN	DATE 		DEFAULT NULL,
				P_REVENUE_DISTRIBUTION_RULE	IN	VARCHAR2 	DEFAULT NULL,
				P_BILLING_DISTRIBUTION_RULE	IN	VARCHAR2 	DEFAULT NULL,
				P_BILLING_TERM_ID		IN	NUMBER 		DEFAULT NULL,
				P_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2 	DEFAULT NULL,
				P_NON_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2 	DEFAULT NULL,
				P_BILLING_CYCLE_ID		IN	VARCHAR2 	DEFAULT NULL,
				P_AMOUNT_TYPE_CODE		IN	VARCHAR2 	DEFAULT NULL,
				P_BOUNDARY_CODE			IN	VARCHAR2 	DEFAULT NULL,
				P_AGREEMENT_TYPE		IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE_CATEGORY		IN	VARCHAR2	DEFAULT NULL,
				P_ATTRIBUTE1			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE2			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE3			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE4			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE5			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE6			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE7			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE8			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE9			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE10			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE11			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE12			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE13			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE14			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE15			IN	VARCHAR2 	DEFAULT NULL,
          			P_ATTRIBUTE16			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE17			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE18			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE19			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE20			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE21			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE22			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE23			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE24			IN	VARCHAR2 	DEFAULT NULL,
				P_ATTRIBUTE25			IN	VARCHAR2 	DEFAULT NULL,
				P_PROPOSAL_ID			IN	NUMBER   	DEFAULT NULL)  ;


	-- ==========================================================================================
	-- Create Installments.
	--
    	-- CREATE_INSTALLMENT
    	-- Create Installment is a private API provided to create Installment for awards in grants accounting.
	-- Valid award should be defined. This API is used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_INSTALLMENT_ID		:	The Unique Record Identifier that is created.
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_INSTALLMENT_REC		:	Installment Record Which will hold all the Input
	--					Values
	-- ==========================================================================================

	PROCEDURE create_installment
			(X_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 X_INSTALLMENT_ID           OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER,
             		 P_VALIDATE                 IN      BOOLEAN DEFAULT TRUE ,
			 P_INSTALLMENT_REC          IN      GMS_INSTALLMENTS%ROWTYPE

			)  ;


	-- ==========================================================================================
	-- Create Personnel
	--
    	-- CREATE_PERSONNEL
    	-- Create Personnel is a private API provided to create Personnel for awards in
	-- grants accounting. This is the API used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_PERSONNEL_REC		:	Personnel Record Which will hold all the Input
	--					Values
	-- ==========================================================================================


	PROCEDURE create_personnel
			(X_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2  ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
             		 P_VALIDATE                 IN      BOOLEAN DEFAULT TRUE ,
			 P_PERSONNEL_REC            IN      GMS_PERSONNEL%ROWTYPE
 			);

	-- ==========================================================================================
	-- Create Terms and conditions.
	--
    	-- CREATE_TERM_CONDITION
    	-- Create Term Condition is a private API provided to create Term and Condition for awards in
	-- grants accounting. This is the API used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_AWARD_TERM_CONDITION_REC	:	Term Condition Record Which will hold all the Input
	--					Values
	-- ==========================================================================================

	PROCEDURE create_term_condition
			(X_MSG_COUNT               IN OUT NOCOPY     	NUMBER ,
			 X_MSG_DATA                IN OUT NOCOPY     	VARCHAR2 ,
			 X_RETURN_STATUS           IN OUT NOCOPY     	VARCHAR2 ,
			 X_ROW_ID	           OUT NOCOPY     	VARCHAR2 ,
			 P_CALLING_MODULE          IN      	VARCHAR2 ,
			 P_API_VERSION_NUMBER      IN      	NUMBER ,
             		 P_VALIDATE                IN      	BOOLEAN DEFAULT TRUE ,
			 P_AWARD_TERM_CONDITION_REC IN      	GMS_AWARDS_TERMS_CONDITIONS%ROWTYPE
			) ;


	-- ==========================================================================================
	-- Create Reference Number
	--
    	-- CREATE_REFERENCE_NUMBER
    	-- Create Reference Number is a private API provided to create Reference Number for awards in
	-- grants accounting. This is the API used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_REFERENCE_NUMBER_REC	:	Reference Number Record Which will hold all the Input
	--					Values
	-- ==========================================================================================

	PROCEDURE create_reference_number
			(X_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
             		 P_VALIDATE                 IN      BOOLEAN DEFAULT TRUE ,
			 P_REFERENCE_NUMBER_REC     IN      GMS_REFERENCE_NUMBERS%ROWTYPE
			) ;

	-- ==========================================================================================
	-- Create Contact
	--
    	-- CREATE_CONTACT
    	-- Create Contact is a private API provided to create Contact for awards in grants accounting.
	-- Valid Award should be defined. This API is used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_CONTACT_REC		:	Contact Record Which will hold all the Input
	--					Values
	-- ==========================================================================================

	PROCEDURE create_contact
			(X_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
            		 P_VALIDATE                 IN      BOOLEAN default TRUE,
			 P_CONTACT_REC             IN      GMS_AWARDS_CONTACTS%ROWTYPE
			) ;

	-- ==========================================================================================
	-- Create Report
	--
    	-- CREATE_REPORT
    	-- Create Report is a private API provided to create Report for awards in grants accounting.
	-- Valid award should be defined. This API is used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_DEFAULT_REPORT_ID		:	The Unique Record Identifier that is created.
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_REPORT_REC			:	Report Record Which will hold all the Input
	--					Values
	-- ==========================================================================================

	PROCEDURE create_report
			(X_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     VARCHAR2 ,
			 X_DEFAULT_REPORT_ID        IN OUT NOCOPY     NUMBER ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
            		 P_VALIDATE                 IN      BOOLEAN default TRUE,
			 P_REPORT_REC              IN      GMS_DEFAULT_REPORTS%ROWTYPE
			) ;

	-- ==========================================================================================
	-- Create Notification
	--
    	-- CREATE_NOTIFICATION
    	-- Create Notification is a private API provided to create Notifications for awards in
	-- grants accounting. This is the API used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	-- P_VALIDATE		    	:	This is for internal Use only. This is used to
	--					to avoid redundant validations, once we know Input
	--					data is valid
	-- P_NOTIFICATION_REC		:	Notification Record Which will hold all the Input
	--					Values
	-- ==========================================================================================

	PROCEDURE create_notification
			(X_MSG_COUNT                IN OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 IN OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            IN OUT NOCOPY     VARCHAR2 ,
			 X_ROW_ID	            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
            		 P_VALIDATE                 IN      BOOLEAN default TRUE,
			 P_NOTIFICATION_REC         IN      GMS_NOTIFICATIONS%ROWTYPE
			) ;

	-- ======================================================================================
	-- ADD FUNDING
	--
    	-- ADD_FUNDING
    	-- Add Funding is a private API provided to create funding from awards in grants
	-- accounting. This API needs a valid award, and installment defined with positive
	-- amount to fund. This API is used to transfer Legacy system data into grants
	-- accounting also.
	--
    	-- X_MSG_COUNT              	:   	Holds no. of messages in the global
    	--                              	message table
    	-- X_MSG_DATA               	:   	Holds the message code, if the API
    	--                              	returned only one error/warning message
    	-- X_RETURN_STATUS          	:   	The indicator of success/Failure
    	--                              	S- Success, E- and U- Failure
    	-- X_GMS_PROJECT_FUNDING_ID 	:   	The Project Funding ID created
	--
	-- X_ROW_ID		    	:  	Record Identifier
	--
	-- P_CALLING_MODULE         	:   	For Internal Use only. This is exclusively
	--			    	   	reserved by Grants Accounting for future Use.
	-- P_API_VERSION_NUMBER     	:   	Package constant used for package version
	--			    		validation
	-- P_AWARD_ID		    	:   	Award Identifier from which the funding is done
	--
	-- P_INSTALLMENT_ID         	:	Installment Identifier for the above award from
	--					which funding is done
	-- P_PROJECT_ID		    	:	Project Identifier for which funding is allocated
	--
	-- P_TASK_ID		    	:	Task Identifier for which funding can be allocated
	--
	-- P_AMOUNT	 	    	:	Amount that is allocated for the above project or task
	--
	-- P_FUNDING_DATE	    	:	Date on which funding is done, between the award dates
	--
	-- =======================================================================================

	PROCEDURE ADD_FUNDING
                        (X_MSG_COUNT                IN OUT NOCOPY      NUMBER ,
                         X_MSG_DATA                 IN OUT NOCOPY      VARCHAR2 ,
                         X_RETURN_STATUS            IN OUT NOCOPY      VARCHAR2 ,
                         X_GMS_PROJECT_FUNDING_ID   IN OUT NOCOPY      NUMBER ,
                         X_ROW_ID                      OUT NOCOPY      VARCHAR2 ,
                         P_CALLING_MODULE           IN          VARCHAR2 ,
                         P_API_VERSION_NUMBER       IN          NUMBER ,
                         P_AWARD_ID                 IN          NUMBER,
                         P_INSTALLMENT_ID           IN          NUMBER,
                         P_PROJECT_ID               IN          NUMBER,
                         P_TASK_ID                  IN          NUMBER,
                         P_AMOUNT                   IN          NUMBER,
                         P_FUNDING_DATE             IN          DATE
                        );


END GMS_AWARD_PVT ;

/
