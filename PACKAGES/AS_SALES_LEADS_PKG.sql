--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_PKG" AUTHID CURRENT_USER as
/* $Header: asxtslms.pls 115.20 2003/09/05 21:50:29 ckapoor ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEADS_PKG
-- Purpose          : Sales leads table handlers
-- NOTE             :
-- History          : 06/05/2000 FFANG   Generated by Table Handler Generater.
--                    06/06/2000 FFANG   Modified according to data schema
--                                       changes.
--                    06/20/2000 FFANG   Correct sales__lead_line_id to
--                                       sales_lead_line_id
--                    06/21/2000 FFANG    Modified according schema changes
--
-- End of Comments

PROCEDURE Sales_Lead_Insert_Row(
          px_SALES_LEAD_ID   IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_LEAD_NUMBER    VARCHAR2,
          p_STATUS_CODE    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
          p_INITIATING_CONTACT_ID    NUMBER,
          p_ORIG_SYSTEM_REFERENCE    VARCHAR2,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_CHANNEL_CODE    VARCHAR2,
          p_BUDGET_AMOUNT    NUMBER,
          p_CURRENCY_CODE    VARCHAR2,
          p_DECISION_TIMEFRAME_CODE    VARCHAR2,
          p_CLOSE_REASON    VARCHAR2,
          p_LEAD_RANK_ID    NUMBER,
          p_LEAD_RANK_CODE    VARCHAR2,
          p_PARENT_PROJECT    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ASSIGN_TO_PERSON_ID    NUMBER,
          p_ASSIGN_TO_SALESFORCE_ID    NUMBER,
          p_ASSIGN_SALES_GROUP_ID  NUMBER,
          p_ASSIGN_DATE    DATE,
          p_BUDGET_STATUS_CODE    VARCHAR2,
          p_ACCEPT_FLAG    VARCHAR2,
          p_VEHICLE_RESPONSE_CODE    VARCHAR2,
          p_TOTAL_SCORE    NUMBER,
          p_SCORECARD_ID    NUMBER,
          p_KEEP_FLAG    VARCHAR2,
          p_URGENT_FLAG    VARCHAR2,
          p_IMPORT_FLAG    VARCHAR2,
          p_REJECT_REASON_CODE    VARCHAR2,
          p_DELETED_FLAG   VARCHAR2,
          p_OFFER_ID    NUMBER,
          p_QUALIFIED_FLAG VARCHAR2,
          p_ORIG_SYSTEM_CODE VARCHAR2,
--        p_SECURITY_GROUP_ID              NUMBER,
          p_INC_PARTNER_PARTY_ID     NUMBER,
          p_INC_PARTNER_RESOURCE_ID  NUMBER,
		p_PRM_EXEC_SPONSOR_FLAG VARCHAR2,
		p_PRM_PRJ_LEAD_IN_PLACE_FLAG VARCHAR2,
		p_PRM_SALES_LEAD_TYPE VARCHAR2,
		p_PRM_IND_CLASSIFICATION_CODE VARCHAR2,
		p_PRM_ASSIGNMENT_TYPE VARCHAR2,
		p_AUTO_ASSIGNMENT_TYPE VARCHAR2,
		p_PRIMARY_CONTACT_PARTY_ID NUMBER,
		-- bug 2098158
		p_PRIMARY_CNT_PERSON_PARTY_ID NUMBER,
       		p_PRIMARY_CONTACT_PHONE_ID NUMBER,

       		-- new columns for CAPRI lead referral

       		p_REFERRED_BY NUMBER,
		  p_REFERRAL_TYPE VARCHAR2,
		  p_REFERRAL_STATUS VARCHAR2,
		  p_REF_DECLINE_REASON VARCHAR2,
		  p_REF_COMM_LTR_STATUS VARCHAR2,
		  p_REF_ORDER_NUMBER NUMBER,
		  p_REF_ORDER_AMT NUMBER,
          	p_REF_COMM_AMT NUMBER,
-- bug No.2341515, 2368075
	        p_LEAD_DATE DATE ,
		p_SOURCE_SYSTEM VARCHAR2,
	        p_COUNTRY VARCHAR2,
-- 11.5.9
		p_TOTAL_AMOUNT NUMBER,
		p_EXPIRATION_DATE DATE,
		p_LEAD_RANK_IND	VARCHAR2,
		p_LEAD_ENGINE_RUN_DATE DATE,
		p_CURRENT_REROUTES NUMBER

		 -- new columns for appsperf CRMAP denorm project bug 2928041

		, p_STATUS_OPEN_FLAG VARCHAR2,
		 p_LEAD_RANK_SCORE NUMBER

		 -- 11.5.10 - ckapoor : new columns

		, p_MARKETING_SCORE	NUMBER
		, p_INTERACTION_SCORE	NUMBER
		, p_SOURCE_PRIMARY_REFERENCE	VARCHAR2
		, p_SOURCE_SECONDARY_REFERENCE	VARCHAR2
		, p_SALES_METHODOLOGY_ID	NUMBER
		, p_SALES_STAGE_ID		NUMBER

		);


PROCEDURE  Sales_Lead_Update_Row(
          p_SALES_LEAD_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_LEAD_NUMBER    VARCHAR2,
          p_STATUS_CODE    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
          p_INITIATING_CONTACT_ID    NUMBER,
          p_ORIG_SYSTEM_REFERENCE    VARCHAR2,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_CHANNEL_CODE    VARCHAR2,
          p_BUDGET_AMOUNT    NUMBER,
          p_CURRENCY_CODE    VARCHAR2,
          p_DECISION_TIMEFRAME_CODE    VARCHAR2,
          p_CLOSE_REASON    VARCHAR2,
          p_LEAD_RANK_ID    NUMBER,
          p_LEAD_RANK_CODE    VARCHAR2,
          p_PARENT_PROJECT    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ASSIGN_TO_PERSON_ID    NUMBER,
          p_ASSIGN_TO_SALESFORCE_ID    NUMBER,
          p_ASSIGN_SALES_GROUP_ID  NUMBER,
          p_ASSIGN_DATE    DATE,
          p_BUDGET_STATUS_CODE    VARCHAR2,
          p_ACCEPT_FLAG    VARCHAR2,
          p_VEHICLE_RESPONSE_CODE    VARCHAR2,
          p_TOTAL_SCORE    NUMBER,
          p_SCORECARD_ID    NUMBER,
          p_KEEP_FLAG    VARCHAR2,
          p_URGENT_FLAG    VARCHAR2,
          p_IMPORT_FLAG    VARCHAR2,
          p_REJECT_REASON_CODE    VARCHAR2,
          p_DELETED_FLAG   VARCHAR2,
          p_OFFER_ID    NUMBER,
          p_QUALIFIED_FLAG VARCHAR2,
          p_ORIG_SYSTEM_CODE VARCHAR2,
--        p_SECURITY_GROUP_ID              NUMBER,
          p_INC_PARTNER_PARTY_ID     NUMBER,
          p_INC_PARTNER_RESOURCE_ID  NUMBER,
		p_PRM_EXEC_SPONSOR_FLAG VARCHAR2,
		p_PRM_PRJ_LEAD_IN_PLACE_FLAG VARCHAR2,
		p_PRM_SALES_LEAD_TYPE VARCHAR2,
		p_PRM_IND_CLASSIFICATION_CODE VARCHAR2,
		p_PRM_ASSIGNMENT_TYPE VARCHAR2,
		p_AUTO_ASSIGNMENT_TYPE VARCHAR2,
		p_PRIMARY_CONTACT_PARTY_ID NUMBER,
		-- bug 2098158
		p_PRIMARY_CNT_PERSON_PARTY_ID NUMBER,
		p_PRIMARY_CONTACT_PHONE_ID NUMBER,

		-- new columns for CAPRI lead referral

		p_REFERRED_BY NUMBER,
		  p_REFERRAL_TYPE VARCHAR2,
		  p_REFERRAL_STATUS VARCHAR2,
		  p_REF_DECLINE_REASON VARCHAR2,
		  p_REF_COMM_LTR_STATUS VARCHAR2,
		  p_REF_ORDER_NUMBER NUMBER,
		  p_REF_ORDER_AMT NUMBER,
          	p_REF_COMM_AMT NUMBER,
-- bug No.2341515, 2368075
	        p_LEAD_DATE DATE ,
		p_SOURCE_SYSTEM VARCHAR2,
	        p_COUNTRY VARCHAR2,
-- 11.5.9
                p_TOTAL_AMOUNT NUMBER,
                p_EXPIRATION_DATE DATE,
                p_LEAD_RANK_IND VARCHAR2,
                p_LEAD_ENGINE_RUN_DATE DATE,
                p_CURRENT_REROUTES NUMBER

                 -- new columns for appsperf CRMAP denorm project bug 2928041

		, p_STATUS_OPEN_FLAG VARCHAR2,
		p_LEAD_RANK_SCORE NUMBER

		 -- 11.5.10 - ckapoor : new columns

		, p_MARKETING_SCORE	NUMBER
		, p_INTERACTION_SCORE	NUMBER
		, p_SOURCE_PRIMARY_REFERENCE	VARCHAR2
		, p_SOURCE_SECONDARY_REFERENCE	VARCHAR2
		, p_SALES_METHODOLOGY_ID	NUMBER
		, p_SALES_STAGE_ID		NUMBER





		);


PROCEDURE  Sales_Lead_Lock_Row(
          p_SALES_LEAD_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_LEAD_NUMBER    VARCHAR2,
          p_STATUS_CODE    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
          p_INITIATING_CONTACT_ID    NUMBER,
          p_ORIG_SYSTEM_REFERENCE    VARCHAR2,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_CHANNEL_CODE    VARCHAR2,
          p_BUDGET_AMOUNT    NUMBER,
          p_CURRENCY_CODE    VARCHAR2,
          p_DECISION_TIMEFRAME_CODE    VARCHAR2,
          p_CLOSE_REASON    VARCHAR2,
          p_LEAD_RANK_ID    NUMBER,
          p_LEAD_RANK_CODE    VARCHAR2,
          p_PARENT_PROJECT    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ASSIGN_TO_PERSON_ID    NUMBER,
          p_ASSIGN_TO_SALESFORCE_ID    NUMBER,
          p_ASSIGN_SALES_GROUP_ID  NUMBER,
          p_ASSIGN_DATE    DATE,
          p_BUDGET_STATUS_CODE    VARCHAR2,
          p_ACCEPT_FLAG    VARCHAR2,
          p_VEHICLE_RESPONSE_CODE    VARCHAR2,
          p_TOTAL_SCORE    NUMBER,
          p_SCORECARD_ID    NUMBER,
          p_KEEP_FLAG    VARCHAR2,
          p_URGENT_FLAG    VARCHAR2,
          p_IMPORT_FLAG    VARCHAR2,
          p_REJECT_REASON_CODE    VARCHAR2,
          p_DELETED_FLAG   VARCHAR2,
          p_OFFER_ID    NUMBER,
          p_QUALIFIED_FLAG VARCHAR2,
          p_ORIG_SYSTEM_CODE VARCHAR2,
--        p_SECURITY_GROUP_ID              NUMBER,
          p_INC_PARTNER_PARTY_ID     NUMBER,
          p_INC_PARTNER_RESOURCE_ID  NUMBER,
		p_PRM_EXEC_SPONSOR_FLAG VARCHAR2,
		p_PRM_PRJ_LEAD_IN_PLACE_FLAG VARCHAR2,
		p_PRM_SALES_LEAD_TYPE VARCHAR2,
		p_PRM_IND_CLASSIFICATION_CODE VARCHAR2,
		p_PRM_ASSIGNMENT_TYPE VARCHAR2,
		p_AUTO_ASSIGNMENT_TYPE VARCHAR2,
		p_PRIMARY_CONTACT_PARTY_ID NUMBER,
		-- bug 2098158
		p_PRIMARY_CNT_PERSON_PARTY_ID NUMBER,
		p_PRIMARY_CONTACT_PHONE_ID NUMBER,
		-- new columns for CAPRI lead referral

		p_REFERRED_BY NUMBER,
		  p_REFERRAL_TYPE VARCHAR2,
		  p_REFERRAL_STATUS VARCHAR2,
		  p_REF_DECLINE_REASON VARCHAR2,
		  p_REF_COMM_LTR_STATUS VARCHAR2,
		  p_REF_ORDER_NUMBER NUMBER,
		  p_REF_ORDER_AMT NUMBER,
          	p_REF_COMM_AMT NUMBER,
-- bug No.2341515, 2368075
	        p_LEAD_DATE DATE ,
		p_SOURCE_SYSTEM VARCHAR2,
	        p_COUNTRY VARCHAR2,
-- 11.5.9
                p_TOTAL_AMOUNT NUMBER,
                p_EXPIRATION_DATE DATE,
                p_LEAD_RANK_IND VARCHAR2,
                p_LEAD_ENGINE_RUN_DATE DATE,
                p_CURRENT_REROUTES NUMBER

               -- new columns for appsperf CRMAP denorm project bug 2928041

                , p_STATUS_OPEN_FLAG VARCHAR2,
                p_LEAD_RANK_SCORE NUMBER

		 -- 11.5.10 - ckapoor : new columns

		, p_MARKETING_SCORE	NUMBER
		, p_INTERACTION_SCORE	NUMBER
		, p_SOURCE_PRIMARY_REFERENCE	VARCHAR2
		, p_SOURCE_SECONDARY_REFERENCE	VARCHAR2
		, p_SALES_METHODOLOGY_ID	NUMBER
		, p_SALES_STAGE_ID		NUMBER




		);



End AS_SALES_LEADS_PKG;

 

/