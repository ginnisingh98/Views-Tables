--------------------------------------------------------
--  DDL for Package AMW_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtprls.pls 115.6 2003/12/02 00:15:21 npanandi noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCESS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Load_Row(
          p_significant_process_flag    						  VARCHAR2,
          p_standard_process_flaG    							  VARCHAR2,
          p_approval_status    									  VARCHAR2,
          p_certification_status    							  VARCHAR2,
          p_process_owner_id    								  NUMBER,
		  p_last_update_date    								  DATE,
          p_last_updated_by    									  NUMBER,
          p_creation_date    									  DATE,
          p_created_by    										  NUMBER,
          p_last_update_login    								  NUMBER,
          p_item_type    										  VARCHAR2,
          p_name    											  VARCHAR2,
          p_created_from    									  VARCHAR2,
          p_request_id    										  NUMBER,
          p_program_application_id    							  NUMBER,
          p_program_id    										  NUMBER,
          p_program_update_date    								  DATE,
          p_attribute_category    								  VARCHAR2,
          p_attribute1    										  VARCHAR2,
          p_attribute2    										  VARCHAR2,
          p_attribute3    										  VARCHAR2,
          p_attribute4    										  VARCHAR2,
          p_attribute5    										  VARCHAR2,
          p_attribute6    										  VARCHAR2,
          p_attribute7    										  VARCHAR2,
          p_attribute8    										  VARCHAR2,
          p_attribute9    										  VARCHAR2,
          p_attribute10    										  VARCHAR2,
          p_attribute11    										  VARCHAR2,
          p_attribute12    										  VARCHAR2,
          p_attribute13    										  VARCHAR2,
          p_attribute14    										  VARCHAR2,
          p_attribute15    										  VARCHAR2,
          p_security_group_id    								  NUMBER,
          p_CONTROL_COUNT    									  NUMBER,
          p_RISK_COUNT    										  NUMBER,
          p_ORG_COUNT    										  NUMBER,
		  p_process_category 									  varchar2 :=	null,
		  p_finance_owner_id 									  number   := 	null,
		  p_application_owner_id 								  number   :=	null,
		  p_standard_variation 									  number   :=	null,
		  px_object_version_number   IN OUT NOCOPY 				  NUMBER,
		  px_PROCESS_REV_ID    		 in out nocopy 				  NUMBER,
          px_process_id   			 IN OUT NOCOPY 				  NUMBER);

PROCEDURE Insert_Row(
		  p_SIGNIFICANT_PROCESS_FLAG    						  VARCHAR2,
          p_STANDARD_PROCESS_FLAG    							  VARCHAR2,
          p_APPROVAL_STATUS    									  VARCHAR2,
          p_CERTIFICATION_STATUS    							  VARCHAR2,
          p_PROCESS_OWNER_ID    								  NUMBER,
		  p_last_update_date    								  DATE,
          p_last_updated_by    									  NUMBER,
          p_creation_date    									  DATE,
          p_created_by    										  NUMBER,
          p_last_update_login    								  NUMBER,
          p_item_type    										  VARCHAR2,
          p_name    											  VARCHAR2,
          p_created_from    									  VARCHAR2,
          p_request_id    										  NUMBER,
          p_program_application_id    							  NUMBER,
          p_program_id    										  NUMBER,
          p_program_update_date    								  DATE,
          p_attribute_category    								  VARCHAR2,
          p_attribute1    										  VARCHAR2,
          p_attribute2    										  VARCHAR2,
          p_attribute3    										  VARCHAR2,
          p_attribute4    										  VARCHAR2,
          p_attribute5    										  VARCHAR2,
          p_attribute6    										  VARCHAR2,
          p_attribute7    										  VARCHAR2,
          p_attribute8    										  VARCHAR2,
          p_attribute9    										  VARCHAR2,
          p_attribute10    										  VARCHAR2,
          p_attribute11    										  VARCHAR2,
          p_attribute12    										  VARCHAR2,
          p_attribute13    										  VARCHAR2,
          p_attribute14    										  VARCHAR2,
          p_attribute15    										  VARCHAR2,
          p_security_group_id    								  NUMBER,
          p_RISK_COUNT    										  NUMBER,
		  p_control_COUNT    									  NUMBER,
          p_ORG_COUNT    										  NUMBER,
		  p_process_category 									  varchar2 :=	null,
		  p_finance_owner_id 									  number   :=	null,
		  p_application_owner_id 								  number   := 	null,
		  p_standard_variation 									  number   :=	null,
		  px_object_version_number   IN OUT NOCOPY 				  NUMBER,
		  px_PROCESS_REV_ID    		 in out nocopy 				  NUMBER,
          px_process_id   			 IN OUT NOCOPY 				  NUMBER);

PROCEDURE Update_Row(
          p_SIGNIFICANT_PROCESS_FLAG    						  VARCHAR2,
          p_STANDARD_PROCESS_FLAG    							  VARCHAR2,
          p_APPROVAL_STATUS    									  VARCHAR2,
          p_CERTIFICATION_STATUS    							  VARCHAR2,
		  p_PROCESS_OWNER_ID    								  NUMBER,
		  p_last_update_date    								  DATE,
          p_last_updated_by    									  NUMBER,
          p_creation_date    									  DATE,
          p_created_by    										  NUMBER,
          p_last_update_login    								  NUMBER,
          p_item_type    										  VARCHAR2,
          p_name    											  VARCHAR2,
          p_created_from    									  VARCHAR2,
          p_request_id    										  NUMBER,
          p_program_application_id    							  NUMBER,
          p_program_id    										  NUMBER,
          p_program_update_date    								  DATE,
          p_attribute_category    								  VARCHAR2,
          p_attribute1    										  VARCHAR2,
          p_attribute2    										  VARCHAR2,
          p_attribute3    										  VARCHAR2,
          p_attribute4    										  VARCHAR2,
          p_attribute5    										  VARCHAR2,
          p_attribute6    										  VARCHAR2,
          p_attribute7    										  VARCHAR2,
          p_attribute8    										  VARCHAR2,
          p_attribute9    										  VARCHAR2,
          p_attribute10    										  VARCHAR2,
          p_attribute11    										  VARCHAR2,
          p_attribute12    										  VARCHAR2,
          p_attribute13    										  VARCHAR2,
          p_attribute14    										  VARCHAR2,
          p_attribute15    										  VARCHAR2,
          p_security_group_id    								  NUMBER,
		  p_control_COUNT    									  NUMBER,
		  p_RISK_COUNT    										  NUMBER,
          p_ORG_COUNT    										  NUMBER,
		  p_process_category 									  varchar2 :=	null,
		  p_finance_owner_id 									  number   :=	null,
		  p_application_owner_id 								  number   :=	null,
		  p_standard_variation 									  number   :=	null,
          p_object_version_number    							  NUMBER,
		  p_PROCESS_REV_ID    									  NUMBER,
          p_process_id    										  NUMBER);

PROCEDURE Delete_Row(
    p_PROCESS_rev_ID  NUMBER);
PROCEDURE Lock_Row(
		  p_SIGNIFICANT_PROCESS_FLAG    						  VARCHAR2,
          p_STANDARD_PROCESS_FLAG    							  VARCHAR2,
          p_APPROVAL_STATUS    									  VARCHAR2,
          p_CERTIFICATION_STATUS    							  VARCHAR2,
          p_PROCESS_OWNER_ID    								  NUMBER,
		  p_last_update_date    								  DATE,
          p_last_updated_by    									  NUMBER,
          p_creation_date    									  DATE,
          p_created_by    										  NUMBER,
          p_last_update_login    								  NUMBER,
          p_item_type    										  VARCHAR2,
          p_name    											  VARCHAR2,
          p_created_from    									  VARCHAR2,
          p_request_id    										  NUMBER,
          p_program_application_id    							  NUMBER,
          p_program_id    										  NUMBER,
          p_program_update_date    								  DATE,
          p_attribute_category    								  VARCHAR2,
          p_attribute1    										  VARCHAR2,
          p_attribute2    										  VARCHAR2,
          p_attribute3    										  VARCHAR2,
          p_attribute4    										  VARCHAR2,
          p_attribute5    										  VARCHAR2,
          p_attribute6    										  VARCHAR2,
          p_attribute7    										  VARCHAR2,
          p_attribute8    										  VARCHAR2,
          p_attribute9    										  VARCHAR2,
          p_attribute10    										  VARCHAR2,
          p_attribute11    										  VARCHAR2,
          p_attribute12    										  VARCHAR2,
          p_attribute13    										  VARCHAR2,
          p_attribute14    										  VARCHAR2,
          p_attribute15    										  VARCHAR2,
          p_security_group_id    								  NUMBER,
		  p_RISK_COUNT    										  NUMBER,
		  p_control_COUNT    									  NUMBER,
          p_ORG_COUNT    										  NUMBER,
		  p_process_category 									  varchar2 :=	null,
		  p_finance_owner_id 									  number   :=	null,
		  p_application_owner_id 								  number   :=	null,
		  p_standard_variation 									  number   :=	null,
          p_object_version_number    							  NUMBER,
		  p_PROCESS_REV_ID    									  NUMBER,
          p_process_id    										  NUMBER);

END AMW_PROCESS_PKG;

 

/