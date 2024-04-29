--------------------------------------------------------
--  DDL for Package FA_LEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LEASE_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVLEAS.pls 120.2.12010000.2 2009/07/19 11:25:08 glchen ship $ */
--
-- API name 	: FA_LEASE_PVT
-- Type		: Private
-- Pre-reqs	: None.
-- Function	: To validate Create Lease and Update Lease API parameters.
--

	--------------------------------
	-- CHECK FOR LESSOR_ID
	--------------------------------
	FUNCTION CHECK_LESSOR_ID (
	   P_VENDOR_ID 			IN     	 PO_VENDORS.VENDOR_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR LESSOR_NAME
	--------------------------------
	FUNCTION CHECK_LESSOR_NAME  (
	   P_VENDOR_NAME		IN     	 PO_VENDORS.VENDOR_NAME%TYPE,
	   X_VENDOR_ID			OUT NOCOPY PO_VENDORS.VENDOR_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
		) RETURN BOOLEAN;
	----------------------------------
	-- CHECK FOR PAYMENT SCHEDULE ID
	----------------------------------
	FUNCTION CHECK_PAYMENT_SCHEDULE_ID (
	   P_PAYMENT_SCHEDULE_ID 	IN 	 FA_LEASE_SCHEDULES.PAYMENT_SCHEDULE_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	------------------------------------
	-- CHECK FOR PAYMENT SCHEDULE NAME
	------------------------------------
	FUNCTION CHECK_PAYMENT_SCHEDULE_NAME (
	 P_PAYMENT_SCHEDULE_NAME    	IN       FA_LEASE_SCHEDULES.PAYMENT_SCHEDULE_NAME%TYPE,
	 X_PAYMENT_SCHEDULE_ID	    	OUT NOCOPY FA_LEASE_SCHEDULES.PAYMENT_SCHEDULE_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR PAYMENT TERMS ID
	--------------------------------
	FUNCTION CHECK_TERMS_ID (
	 P_TERMS_ID 			IN 	 AP_TERMS.TERM_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR PAYMENT TERMS
	--------------------------------
	FUNCTION CHECK_PAYMENT_TERMS (
	 P_PAYMENT_TERMS		IN 	 AP_TERMS.NAME%TYPE,
	 X_TERMS_ID			OUT NOCOPY AP_TERMS.TERM_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR LESSOR SITE ID
	--------------------------------
	FUNCTION CHECK_LESSOR_SITE_ID (
	 P_VENDOR_SITE_ID		IN 	 PO_VENDOR_SITES_ALL.VENDOR_SITE_ID%TYPE,
	 P_VENDOR_ID      		IN	 PO_VENDOR_SITES_ALL.VENDOR_ID%TYPE,
	 X_CHART_OF_ACCOUNTS_ID 	OUT NOCOPY GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE,
	 X_LESSOR_SITE_ORG_ID		OUT NOCOPY NUMBER
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR LESSOR SITE CODE
	--------------------------------
	FUNCTION CHECK_LESSOR_SITE_CODE (
	 P_VENDOR_SITE_CODE		IN 	 PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE,
	 P_VENDOR_ID      		IN	 PO_VENDOR_SITES_ALL.VENDOR_ID%TYPE,
	 P_VENDOR_SITE_ORG_ID   	IN	 PO_VENDOR_SITES_ALL.ORG_ID%TYPE,
	 X_VENDOR_SITE_ID		OUT NOCOPY PO_VENDOR_SITES_ALL.VENDOR_SITE_ID%TYPE,
	 X_CHART_OF_ACCOUNTS_ID 	OUT NOCOPY GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	------------------------------------
	-- CHECK FOR CODE COMBINATION ID
	------------------------------------
	FUNCTION CHECK_DIST_CODE_COMBINATION_ID(
 	P_DIST_CODE_COMBINATION_ID 	IN 	GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE,
 	P_COA_ID 			IN 	GL_CODE_COMBINATIONS.CHART_OF_ACCOUNTS_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	)  RETURN BOOLEAN;

	--------------------------------------------------------------------------------
	-- CHECK FOR CODE COMBINATION, IF DYNAMIC INSERT IS ON IF NOT FOUND INSERT ONE
	--------------------------------------------------------------------------------
	FUNCTION CHECK_CODE_COMBINATION (
 	P_CON_CODE_COMBINATION 		IN 	VARCHAR2,
 	P_COA_ID 			IN 	GL_CODE_COMBINATIONS.CHART_OF_ACCOUNTS_ID%TYPE,
 	X_CODE_COMBINATION_ID 		OUT NOCOPY GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	)  RETURN BOOLEAN;

	-------------------------------------------------
	-- CHECK FOR LEASE NUMBER AND LESSOR COMBINATION
	-------------------------------------------------
	FUNCTION CHECK_LEASE_LESSOR_COMBINATION (
	P_LESSOR_ID 			IN 	NUMBER,
	P_LEASE_NUMBER 			IN 	VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR CURRENCY CODE
	--------------------------------
	FUNCTION CHECK_CURRENCY_CODE (
	P_CURRENCY_CODE 		IN 	VARCHAR2,
	P_PAYMENT_SCHEDULE_ID 		IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

	--------------------------------
	-- CHECK FOR LEASE TYPE
	--------------------------------
	FUNCTION CHECK_LEASE_TYPE(
	P_LEASE_TYPE 			IN 	VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

	------------------------------------
	--VALIDATE LESSOTR THAT IT EXISTS
	------------------------------------
	FUNCTION VALIDATE_LESSOR
	(P_VENDOR_ID 			IN 	NUMBER,
	 P_VENDOR_NAME 			IN 	VARCHAR2,
	 X_VENDOR_ID 			OUT NOCOPY NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	--------------------------------
	-- GET LEASE_ID
	--------------------------------
	FUNCTION GET_LEASE_ID
	(P_LESSOR_ID 			IN 	NUMBER,
 	P_LEASE_NUMBER 			IN 	VARCHAR2,
 	X_LEASE_ID 			OUT NOCOPY NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	--------------------------------
	-- VALIDATE LEASE_ID
	--------------------------------
	FUNCTION VALIDATE_LEASE_ID
	(P_LEASE_ID 			IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	-------------------------------------------------------------------------------
	-- CHECK IF LEASE INFORMATION CAN BE UPDATED AND NOT ASSOCIATED WITH ANY ASSET
	-------------------------------------------------------------------------------
	FUNCTION CHECK_LEASE_UPDATE
	(P_LEASE_ID 			IN 	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
	RETURN VARCHAR2;

	--------------------------------------------------
	-- CHECK IF LEASE, LESSOR COMBINATION
	--------------------------------------------------
	FUNCTION VALIDATE_LEASE_LESSOR
	(P_LEASE_ID 			IN 	NUMBER,
	P_LESSOR_ID 			IN 	NUMBER,
	P_LESSOR_SITE_ID 		IN 	NUMBER,
	P_LESSOR_SITE_ORG_ID 		IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	-------------------------------------------
	-- VALIDATE CREATE LEASE PARAMETERS
	-------------------------------------------
	FUNCTION VALIDATION_CREATE_LEASE  (
	PX_LEASE_DETAILS_REC	      IN OUT NOCOPY FA_API_TYPES.LEASE_DETAILS_REC_TYPE
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	--------------------------------------------
	-- VALIDATE UPDATE LEASE PARAMETERS
	---------------------------------------------
	FUNCTION VALIDATION_UPDATE_LEASE  (
   	PX_LEASE_DETAILS_REC_NEW    IN  OUT NOCOPY FA_API_TYPES.LEASE_DETAILS_REC_TYPE,
   	X_OK_TO_UPDATE_FLAG		OUT NOCOPY VARCHAR2
  	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	--------------------------------------------
	-- UPDATE LEASE DATA
	---------------------------------------------

	PROCEDURE UPDATE_ROW(
	X_ROWID                         IN 		VARCHAR2 DEFAULT NULL,
        X_LEASE_ID                      IN            	NUMBER,
	X_LESSOR_ID                     IN            	NUMBER,
	X_LESSOR_SITE_ID                IN              NUMBER,
	X_DESCRIPTION                   IN            	VARCHAR2,
	X_LAST_UPDATE_DATE              IN            	DATE,
	X_LAST_UPDATED_BY               IN            	NUMBER,
	X_ATTRIBUTE1                    IN              VARCHAR2,
	X_ATTRIBUTE2                    IN              VARCHAR2,
	X_ATTRIBUTE3                    IN              VARCHAR2,
	X_ATTRIBUTE4                    IN              VARCHAR2,
	X_ATTRIBUTE5                    IN              VARCHAR2,
	X_ATTRIBUTE6                    IN              VARCHAR2,
	X_ATTRIBUTE7                    IN              VARCHAR2,
	X_ATTRIBUTE8                    IN              VARCHAR2,
	X_ATTRIBUTE9                    IN              VARCHAR2,
	X_ATTRIBUTE10                   IN              VARCHAR2,
	X_ATTRIBUTE11                   IN              VARCHAR2,
	X_ATTRIBUTE12                   IN              VARCHAR2,
	X_ATTRIBUTE13                   IN              VARCHAR2,
	X_ATTRIBUTE14                   IN              VARCHAR2,
	X_ATTRIBUTE15                   IN              VARCHAR2,
	X_ATTRIBUTE_CATEGORY_CODE       IN              VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_LEASE_PVT;

/
