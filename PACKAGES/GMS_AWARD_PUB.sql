--------------------------------------------------------
--  DDL for Package GMS_AWARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARD_PUB" AUTHID CURRENT_USER AS
-- $Header: gmsawpbs.pls 120.0.12010000.2 2008/10/30 11:13:37 rrambati ship $

	G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;


	-- ===============================================================================
	-- CREATE_AWARD :
	-- Create award has all the parameters that we have in gms_awards_all table.
	-- The ID's in the table are replaced by corresponding value. Users must
	-- provide decode values instead of code values.
	-- P_return_status 	: 	S- Success,
	--				E- Business Rule Validation error
	--				U- Unexpected Error
	-- P_API_VERSION_NUMBER	:	1.0
	-- ===============================================================================
	PROCEDURE	CREATE_AWARD(
				X_MSG_COUNT			OUT NOCOPY	NUMBER,
				X_MSG_DATA			OUT NOCOPY	VARCHAR2,
				X_return_status			OUT NOCOPY	VARCHAR2,
				X_AWARD_ID			OUT NOCOPY	NUMBER,
				P_CALLING_MODULE		IN	VARCHAR2,
				P_API_VERSION_NUMBER		IN	NUMBER,
				P_LAST_UPDATE_DATE		IN	DATE,
				P_LAST_UPDATED_BY		IN	NUMBER,
				P_CREATED_BY			IN	NUMBER,
				P_CREATION_DATE			IN	DATE,
				P_LAST_UPDATE_LOGIN		IN	NUMBER,
				P_AWARD_NUMBER			IN	VARCHAR2,
				P_AWARD_SHORT_NAME		IN	VARCHAR2,
				P_AWARD_FULL_NAME		IN	VARCHAR2,
				P_AWARD_START_DATE		IN	DATE,
				P_AWARD_END_DATE		IN	DATE,
				P_AWARD_CLOSE_DATE		IN	DATE,
				P_PREAWARD_DATE			IN	DATE,
				P_AWARD_PURPOSE_CODE		IN 	VARCHAR2,
				P_AWARD_STATUS_CODE		IN	VARCHAR2,
				P_AWARD_MANAGER_ID		IN	NUMBER,
				P_AWARD_ORGANIZATION_ID		IN	NUMBER,
				P_FUNDING_SOURCE_ID		IN	NUMBER,
				P_FUNDING_SOURCE_AWARD_NUM	IN	VARCHAR2,
				P_ALLOWABLE_SCHEDULE		IN	VARCHAR2,
				P_INDIRECT_SCHEDULE		IN	VARCHAR2,
				P_COST_IND_SCH_FIXED_DATE	IN	DATE,
				P_REVENUE_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_FORMAT		IN	VARCHAR2,
				P_BILLING_TERM_ID		IN	NUMBER,
				P_AGENCY_FORM			IN	VARCHAR2,
				P_BILL_TO_CUSTOMER_ID		IN	VARCHAR2,
				P_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_NON_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_BILL_TO_ADDRESS_ID		IN	NUMBER,
				P_SHIP_TO_ADDRESS_ID		IN	NUMBER,
				P_LOC_BILL_TO_ADDRESS_ID	IN	NUMBER,
				P_LOC_SHIP_TO_ADDRESS_ID	IN	NUMBER,
				P_HARD_LIMIT_FLAG		IN	VARCHAR2,
				P_INVOICE_LIMIT_FLAG		IN	VARCHAR2,  /*Bug 6642901*/
				P_BILLING_OFFSET		IN	NUMBER,
				P_BILLING_CYCLE			IN	VARCHAR2,
				P_TRANSACTION_NUM		IN	VARCHAR2,
				P_AMOUNT_TYPE_CODE		IN	VARCHAR2,
				P_BOUNDARY_CODE			IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_AWARD	IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_TASK		IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_RES_GROUP    IN	VARCHAR2,
				P_FUNDS_CONTROL_AT_RES	        IN	VARCHAR2,
				P_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
				P_ATTRIBUTE1			IN	VARCHAR2,
				P_ATTRIBUTE2			IN	VARCHAR2,
				P_ATTRIBUTE3			IN	VARCHAR2,
				P_ATTRIBUTE4			IN	VARCHAR2,
				P_ATTRIBUTE5			IN	VARCHAR2,
				P_ATTRIBUTE6			IN	VARCHAR2,
				P_ATTRIBUTE7			IN	VARCHAR2,
				P_ATTRIBUTE8			IN	VARCHAR2,
				P_ATTRIBUTE9			IN	VARCHAR2,
				P_ATTRIBUTE10			IN	VARCHAR2,
				P_ATTRIBUTE11			IN	VARCHAR2,
				P_ATTRIBUTE12			IN	VARCHAR2,
				P_ATTRIBUTE13			IN	VARCHAR2,
				P_ATTRIBUTE14			IN	VARCHAR2,
				P_ATTRIBUTE15			IN	VARCHAR2,
				P_AGREEMENT_TYPE		IN	VARCHAR2,
				P_ORG_ID			IN	NUMBER,
				P_WF_ENABLED_FLAG		IN	VARCHAR2,
				P_PROPOSAL_ID			IN	NUMBER ) ;


	-- ===============================================================================
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
				X_MSG_COUNT			OUT NOCOPY	NUMBER,
				X_MSG_DATA			OUT NOCOPY	VARCHAR2,
				X_return_status			OUT NOCOPY	VARCHAR2,
				X_AWARD_ID			OUT NOCOPY	NUMBER,
				P_CALLING_MODULE		IN	VARCHAR2,
				P_API_VERSION_NUMBER		IN	NUMBER,
				P_AWARD_BASE_ID			IN	NUMBER,
				P_AWARD_NUMBER			IN	VARCHAR2,
				P_AWARD_SHORT_NAME		IN	VARCHAR2,
				P_AWARD_FULL_NAME		IN	VARCHAR2,
				P_AWARD_START_DATE		IN	DATE,
				P_AWARD_END_DATE		IN	DATE,
				P_AWARD_CLOSE_DATE		IN	DATE,
				P_PREAWARD_DATE			IN	DATE,
				P_AWARD_PURPOSE_CODE		IN 	VARCHAR2,
				P_AWARD_STATUS_CODE		IN	VARCHAR2,
				P_AWARD_MANAGER_ID		IN	NUMBER,
				P_AWARD_ORGANIZATION_ID		IN	NUMBER,
				P_FUNDING_SOURCE_ID		IN	NUMBER,
				P_FUNDING_SOURCE_AWARD_NUM	IN	VARCHAR2,
				P_ALLOWABLE_SCHEDULE		IN	VARCHAR2,
				P_INDIRECT_SCHEDULE		IN	VARCHAR2,
				P_COST_IND_SCH_FIXED_DATE	IN	DATE,
				P_REVENUE_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_DISTRIBUTION_RULE	IN	VARCHAR2,
				P_BILLING_TERM_ID		IN	NUMBER,
				P_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_NON_LABOR_INVOICE_FORMAT_ID	IN	VARCHAR2,
				P_BILLING_CYCLE			IN	VARCHAR2,
				P_AMOUNT_TYPE_CODE		IN	VARCHAR2,
				P_BOUNDARY_CODE			IN	VARCHAR2,
				P_AGREEMENT_TYPE		IN	VARCHAR2,
				P_PROPOSAL_ID			IN	NUMBER  ) ;



	-- ===============================================================================
	-- CREATE_AWARD_INSTALLMENT :
	-- Create award installment  has all the parameters that we have in gms_awards_installment table.
	-- The ID's in the table are replaced by corresponding value. Users must
	-- provide decode values instead of code values.
	-- P_return_status 	: 	S- Success,
	--				E- Business Rule Validation error
	--				U- Unexpected Error
	-- P_API_VERSION_NUMBER	:	1.0
	-- ===============================================================================
	PROCEDURE CREATE_INSTALLMENT
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 X_INSTALLMENT_ID           OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER,
			 P_LAST_UPDATE_DATE         IN      DATE   ,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE   ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_INSTALLMENT_NUMBER       IN      NUMBER ,
			 P_INSTALLMENT_TYPE_CODE    IN      VARCHAR2 ,
			 P_DESCRIPTION              IN      VARCHAR2  ,
			 P_ISSUE_DATE               IN      DATE ,
			 P_INSTALLMENT_START_DATE   IN      DATE ,
			 P_INSTALLMENT_END_DATE     IN      DATE ,
			 P_INSTALLMENT_CLOSE_DATE   IN      DATE  ,
			 P_ACTIVE_FLAG              IN      VARCHAR2 ,
			 P_BILLABLE_FLAG            IN      VARCHAR2 ,
			 P_DIRECT_COST              IN      NUMBER ,
			 P_INDIRECT_COST            IN      NUMBER ,
			 P_ATTRIBUTE_CATEGORY       IN      VARCHAR2 ,
			 P_ATTRIBUTE1               IN      VARCHAR2 ,
			 P_ATTRIBUTE2               IN      VARCHAR2 ,
			 P_ATTRIBUTE3               IN      VARCHAR2 ,
			 P_ATTRIBUTE4               IN      VARCHAR2 ,
			 P_ATTRIBUTE5               IN      VARCHAR2 ,
			 P_ATTRIBUTE6               IN      VARCHAR2 ,
			 P_ATTRIBUTE7               IN      VARCHAR2 ,
			 P_ATTRIBUTE8               IN      VARCHAR2 ,
			 P_ATTRIBUTE9               IN      VARCHAR2 ,
			 P_ATTRIBUTE10              IN      VARCHAR2 ,
			 P_ATTRIBUTE11              IN      VARCHAR2 ,
			 P_ATTRIBUTE12              IN      VARCHAR2 ,
			 P_ATTRIBUTE13              IN      VARCHAR2 ,
			 P_ATTRIBUTE14              IN      VARCHAR2 ,
			 P_ATTRIBUTE15              IN      VARCHAR2 ,
			 P_PROPOSAL_ID              IN      NUMBER
			)  ;

		-- ==========================================================================================
		-- Personal or Award Roles are user defined positions or functions that people perform in
		-- activities funded by an award. Each Personnel or Award Role is linked to an individual
		-- Award .
		-- ==========================================================================================
		PROCEDURE CREATE_PERSONNEL
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 X_PERSONNEL_ID             OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2  ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE         IN      DATE   ,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE  ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_AWARD_ROLE_CODE          IN      VARCHAR2 ,
			 P_PERSON_ID                IN      VARCHAR2 ,
			 P_START_DATE_ACTIVE        IN      DATE ,
			 P_END_DATE_ACTIVE          IN      DATE ,
			 P_REQUIRED_FLAG            IN      VARCHAR2
 			);

		-- ===========================================================================
		-- Award terms and conditions are stipulated by the Grantor that are indicated
		-- in an agreement or contract.
		-- ===========================================================================
		PROCEDURE CREATE_TERM_CONDITION
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE             IN      DATE   ,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_CATEGORY_NAME            IN      VARCHAR2 ,
			 P_TERM_ID                IN      NUMBER ,
			 P_OPERAND                  IN      VARCHAR2 ,
			 P_VALUE                    IN      NUMBER
			) ;

		-- =============================================================================
		-- Reference Numbers are user defined values or characters assigned to an award
		-- for identification purposes.
		-- =============================================================================
		PROCEDURE CREATE_REFERENCE_NUMBER
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_return_status            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE	    IN      DATE,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_REFERENCE_TYPE           IN      VARCHAR2 ,
			 P_REFERENCE_VALUE          IN      VARCHAR2 ,
			 P_REQUIRED_FLAG	    IN      VARCHAR2
			) ;

		-- ==========================================================
		-- Create Contacts
		-- ==========================================================

		PROCEDURE CREATE_CONTACT
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            OUT NOCOPY     VARCHAR2 ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE	    IN      DATE,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_CONTACT_ID               IN      NUMBER ,
			 P_PRIMARY_FLAG	            IN      VARCHAR2 ,
			 P_USAGE_CODE	            IN      VARCHAR2
			) ;

		-- ==========================================================
		-- Create Reports
		-- ==========================================================
		PROCEDURE CREATE_REPORT
			(X_MSG_COUNT                OUT NOCOPY     NUMBER ,
			 X_MSG_DATA                 OUT NOCOPY     VARCHAR2 ,
			 X_RETURN_STATUS            OUT NOCOPY     VARCHAR2 ,
			 X_DEFAULT_REPORT_ID        OUT NOCOPY     NUMBER ,
			 P_CALLING_MODULE           IN      VARCHAR2 ,
			 P_API_VERSION_NUMBER       IN      NUMBER ,
			 P_LAST_UPDATE_DATE	    IN      DATE,
			 P_LAST_UPDATED_BY          IN      NUMBER ,
			 P_CREATED_BY               IN      NUMBER ,
			 P_CREATION_DATE            IN      DATE ,
			 P_LAST_UPDATE_LOGIN        IN      NUMBER ,
			 P_AWARD_NUMBER             IN      VARCHAR2 ,
			 P_REPORT_NAME              IN      VARCHAR2 ,
			 P_FREQUENCY_CODE           IN      VARCHAR2 ,
			 P_DUE_WITHIN_DAYS          IN      NUMBER ,
			 P_SITE_USE_ID	            IN      NUMBER ,
			 P_NUMBER_OF_COPIES         IN      NUMBER
			) ;

END GMS_AWARD_PUB ;

/
