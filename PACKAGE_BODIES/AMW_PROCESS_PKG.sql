--------------------------------------------------------
--  DDL for Package Body AMW_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCESS_PKG" as
/* $Header: amwtprlb.pls 120.0 2005/05/31 18:37:15 appldev noship $ */
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PROCESS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwtprlb.pls';

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLoadBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================


PROCEDURE Load_Row(
	      p_significant_process_flag    					VARCHAR2,
          p_standard_process_flag    						VARCHAR2,
          p_approval_status    								VARCHAR2,
          p_certification_status    						VARCHAR2,
          p_process_owner_id 								number,
          p_last_update_date    							DATE,
          p_last_updated_by    								NUMBER,
          p_creation_date    								DATE,
          p_created_by    									NUMBER,
          p_last_update_login    							NUMBER,
          p_item_type    									VARCHAR2,
          p_name    										VARCHAR2,
          p_created_from    								VARCHAR2,
          p_request_id    									NUMBER,
          p_program_application_id    						NUMBER,
          p_program_id    									NUMBER,
          p_program_update_date    							DATE,
          p_attribute_category    							VARCHAR2,
          p_attribute1    									VARCHAR2,
          p_attribute2    									VARCHAR2,
          p_attribute3    									VARCHAR2,
          p_attribute4    									VARCHAR2,
          p_attribute5    									VARCHAR2,
          p_attribute6    									VARCHAR2,
          p_attribute7    									VARCHAR2,
          p_attribute8    									VARCHAR2,
          p_attribute9    									VARCHAR2,
          p_attribute10    									VARCHAR2,
          p_attribute11    									VARCHAR2,
          p_attribute12    									VARCHAR2,
          p_attribute13    									VARCHAR2,
          p_attribute14    									VARCHAR2,
          p_attribute15    									VARCHAR2,
          p_security_group_id    							NUMBER,
          p_control_count 									number,
          p_risk_count 										number,
          p_org_count 										number,
		  p_process_category 								varchar2 := 	null,
		  p_finance_owner_id 								number	 :=		null,
		  p_application_owner_id 							number	 :=		null,
		  p_standard_variation 								number	 :=		null,
          px_object_version_number   IN OUT NOCOPY 			NUMBER,
          px_process_rev_id 		 in out nocopy 			number,
          px_process_id   			 IN OUT NOCOPY 			NUMBER)

is
begin

--  declare
--     user_id            number := 0;
--     row_id             varchar2(64);

 -- begin

  null;

  --     if (X_OWNER = 'SEED') then
  --      user_id := -1;
  --     end if;

	-- user_id := 1;
--	 AMW_PROCESS_PKG.Update_Row (
--          p_significant_process_flag 	=> p_significant_process_flag,
--          p_standard_process_flag 		=> p_standard_process_flag,
--          p_approval_status 			=> p_approval_status,
--          p_certification_status 		=> p_certification_status,
--          p_process_owner_id 			=> p_process_owner_id,
--          p_last_update_date 			=> p_last_update_date,
--          p_last_updated_by 			=> p_last_updated_by,
--          p_creation_date 				=> p_creation_date,
--          p_created_by 					=> p_created_by,
--          p_last_update_login 			=> p_last_update_login,
--          p_item_type 					=> p_item_type,
--          p_name 						=> p_name,
--          p_created_from 				=> p_created_from,
--          p_request_id 					=> p_request_id,
--          p_program_application_id 		=> p_program_application_id,
--          p_program_id 					=> p_program_id,
--          p_program_update_date 		=> p_program_update_date,
--          p_attribute_category 			=> p_attribute_category,
--          p_attribute1 					=> p_attribute1,
--          p_attribute2 					=> p_attribute2,
--          p_attribute3 					=> p_attribute3,
--          p_attribute4 					=> p_attribute4,
--          p_attribute5 					=> p_attribute5,
--          p_attribute6 					=> p_attribute6,
--          p_attribute7 					=> p_attribute7,
--          p_attribute8 					=> p_attribute8,
--          p_attribute9 					=> p_attribute9,
--          p_attribute10 				=> p_attribute10,
--          p_attribute11 				=> p_attribute11,
--          p_attribute12 				=> p_attribute12,
--          p_attribute13 				=> p_attribute13,
--          p_attribute14 				=> p_attribute14,
--          p_attribute15 				=> p_attribute15,
--          p_security_group_id 			=> p_security_group_id,
--          p_control_count 				=> p_control_count,
--          p_risk_count 					=> p_risk_count,
--          p_org_count 					=> p_org_count,
--		  p_process_category 			=> p_process_category,
--		  p_finance_owner_id 			=> p_finance_owner_id,
--		  p_application_owner_id 		=> p_application_owner_id,
--		  p_standard_variation 			=> p_standard_variation,
--          p_object_version_number 		=> px_object_version_number,
--          p_process_rev_id 				=> px_process_rev_id,
--          p_process_id 					=> px_process_id);
--
--exception
--    when NO_DATA_FOUND then
--
--	 AMW_PROCESS_PKG.Insert_Row(
--          p_significant_process_flag 	   => p_significant_process_flag,
--          p_standard_process_flag 		   => p_standard_process_flag,
--          p_approval_status 			   => p_approval_status,
--          p_certification_status 		   => p_certification_status,
--          p_process_owner_id 			   => p_process_owner_id,
--          p_last_update_date 			   => p_last_update_date,
--          p_last_updated_by 			   => p_last_updated_by,
--          p_creation_date 				   => p_creation_date,
--          p_created_by 					   => p_created_by,
--          p_last_update_login 			   => p_last_update_login,
--          p_item_type 					   => p_item_type,
--          p_name 						   => p_name,
--          p_created_from 				   => p_created_from,
--          p_request_id 					   => p_request_id,
--          p_program_application_id 		   => p_program_application_id,
--          p_program_id 					   => p_program_id,
--          p_program_update_date 		   => p_program_update_date,
--          p_attribute_category 			   => p_attribute_category,
--          p_attribute1 					   => p_attribute1,
--          p_attribute2 					   => p_attribute2,
--          p_attribute3 					   => p_attribute3,
--          p_attribute4 					   => p_attribute4,
--          p_attribute5 					   => p_attribute5,
--          p_attribute6 					   => p_attribute6,
--          p_attribute7 					   => p_attribute7,
--          p_attribute8 					   => p_attribute8,
--          p_attribute9 					   => p_attribute9,
--          p_attribute10 				   => p_attribute10,
--          p_attribute11 				   => p_attribute11,
--          p_attribute12 				   => p_attribute12,
--          p_attribute13 				   => p_attribute13,
--          p_attribute14 				   => p_attribute14,
--          p_attribute15 				   => p_attribute15,
--          p_security_group_id 			   => p_security_group_id,
--          p_control_count 				   => p_control_count,
--          p_risk_count 					   => p_risk_count,
--          p_org_count 					   => p_org_count,
--		  p_process_category 			   => p_process_category,
--		  p_finance_owner_id 			   => p_finance_owner_id,
--		  p_application_owner_id 		   => p_application_owner_id,
--		  p_standard_variation 			   => p_standard_variation,
--          px_object_version_number 		   => px_object_version_number,
--		  px_process_rev_id 			   => px_process_rev_id,
--          px_process_id 				   => px_process_id);
--	  end;
--EXCEPTION WHEN OTHERS THEN
-----dbms_output.put_line(SQLERRM);
--RAISE ;
--RETURN;
end Load_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          p_SIGNIFICANT_PROCESS_FLAG    					VARCHAR2,
          p_STANDARD_PROCESS_FLAG    						VARCHAR2,
          p_APPROVAL_STATUS    								VARCHAR2,
          p_CERTIFICATION_STATUS    						VARCHAR2,
          p_PROCESS_OWNER_ID    							NUMBER,
		  p_last_update_date    							DATE,
          p_last_updated_by    								NUMBER,
          p_creation_date    								DATE,
          p_created_by    									NUMBER,
          p_last_update_login    							NUMBER,
          p_item_type    									VARCHAR2,
          p_name    										VARCHAR2,
          p_created_from    								VARCHAR2,
          p_request_id    									NUMBER,
          p_program_application_id    						NUMBER,
          p_program_id    									NUMBER,
          p_program_update_date    							DATE,
          p_attribute_category    							VARCHAR2,
          p_attribute1    									VARCHAR2,
          p_attribute2    									VARCHAR2,
          p_attribute3    									VARCHAR2,
          p_attribute4    									VARCHAR2,
          p_attribute5    									VARCHAR2,
          p_attribute6    									VARCHAR2,
          p_attribute7    									VARCHAR2,
          p_attribute8    									VARCHAR2,
          p_attribute9    									VARCHAR2,
          p_attribute10    									VARCHAR2,
          p_attribute11    									VARCHAR2,
          p_attribute12    									VARCHAR2,
          p_attribute13    									VARCHAR2,
          p_attribute14    									VARCHAR2,
          p_attribute15    									VARCHAR2,
          p_security_group_id    							NUMBER,
          p_RISK_COUNT    									NUMBER,
		  p_control_COUNT    								NUMBER,
          p_ORG_COUNT    									NUMBER,
		  p_process_category 								varchar2 :=	 null,
		  p_finance_owner_id 								number	 :=	 null,
		  p_application_owner_id 							number	 :=	 null,
		  p_standard_variation 								number	 :=	 null,
		  px_object_version_number   IN OUT NOCOPY 			NUMBER,
		  px_PROCESS_REV_ID    		 in out nocopy 			NUMBER,
          px_process_id   			 IN OUT NOCOPY 			NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMW_PROCESS(
           significant_process_flag,
		   standard_process_flag,
		   approval_status,
		   certification_status,
		   process_owner_id,
		   process_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           item_type,
           name,
           created_from,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           security_group_id,
           object_version_number,
		   process_rev_id,
           control_count,
		   risk_count,
		   org_count,
		   process_category,
		   finance_owner_id,
		   application_owner_id,
		   standard_variation
   ) VALUES (
     	   DECODE( p_significant_process_flag, FND_API.g_miss_char, NULL, p_significant_process_flag),
		   DECODE( p_standard_process_flag,    FND_API.g_miss_char, NULL, p_standard_process_flag),
		   DECODE( p_approval_status, 		   FND_API.g_miss_char, NULL, p_approval_status),
		   DECODE( p_certification_status, 	   FND_API.g_miss_char, NULL, p_certification_status),
		   DECODE( p_process_owner_id, 		   FND_API.g_miss_num, 	NULL, p_process_owner_id),
		   DECODE( px_process_id, 			   FND_API.g_miss_num, 	NULL, px_process_id),
           DECODE( p_last_update_date, 		   FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, 		   FND_API.g_miss_num, 	NULL, p_last_updated_by),
           DECODE( p_creation_date, 		   FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, 			   FND_API.g_miss_num, 	NULL, p_created_by),
           DECODE( p_last_update_login, 	   FND_API.g_miss_num, 	NULL, p_last_update_login),
           DECODE( p_item_type, 			   FND_API.g_miss_char, NULL, p_item_type),
           DECODE( p_name, 					   FND_API.g_miss_char, NULL, p_name),
           DECODE( p_created_from, 			   FND_API.g_miss_char, NULL, p_created_from),
           DECODE( p_request_id, 			   FND_API.g_miss_num, 	NULL, p_request_id),
           DECODE( p_program_application_id,   FND_API.g_miss_num, 	NULL, p_program_application_id),
           DECODE( p_program_id, 			   FND_API.g_miss_num, 	NULL, p_program_id),
           DECODE( p_program_update_date, 	   FND_API.g_miss_date, NULL, p_program_update_date),
           DECODE( p_attribute_category, 	   FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, 			   FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, 			   FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, 			   FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, 			   FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, 			   FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, 			   FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, 			   FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, 			   FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, 			   FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, 			   FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, 			   FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, 			   FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, 			   FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, 			   FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, 			   FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_security_group_id, 	   FND_API.g_miss_num, 	NULL, p_security_group_id),
           DECODE( px_object_version_number,   FND_API.g_miss_num, 	NULL, px_object_version_number),
           DECODE( px_process_rev_id, 		   FND_API.g_miss_num, 	NULL, px_process_rev_id),
		   DECODE( p_control_count, 		   FND_API.g_miss_num, 	NULL, p_control_count),
		   DECODE( p_risk_count, 			   FND_API.g_miss_num, 	NULL, p_risk_count),
		   DECODE( p_org_count, 			   FND_API.g_miss_num, 	NULL, p_org_count),
		   DECODE( p_process_category, 		   FND_API.g_miss_char, NULL, p_process_category),
		   DECODE( p_finance_owner_id, 		   FND_API.g_miss_num, 	NULL, p_finance_owner_id),
		   DECODE( p_application_owner_id, 	   FND_API.g_miss_num, 	NULL, p_application_owner_id),
		   DECODE( p_standard_variation, 	   FND_API.g_miss_num, 	NULL, p_standard_variation)
		   );
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
		  p_SIGNIFICANT_PROCESS_FLAG    					VARCHAR2,
          p_STANDARD_PROCESS_FLAG    						VARCHAR2,
          p_APPROVAL_STATUS    								VARCHAR2,
          p_CERTIFICATION_STATUS    						VARCHAR2,
		  p_PROCESS_OWNER_ID    							NUMBER,
          p_last_update_date    							DATE,
          p_last_updated_by    								NUMBER,
          p_creation_date    								DATE,
          p_created_by    									NUMBER,
          p_last_update_login    							NUMBER,
          p_item_type    									VARCHAR2,
          p_name    										VARCHAR2,
          p_created_from    								VARCHAR2,
          p_request_id    									NUMBER,
          p_program_application_id    						NUMBER,
          p_program_id    									NUMBER,
          p_program_update_date    							DATE,
          p_attribute_category    							VARCHAR2,
          p_attribute1    									VARCHAR2,
          p_attribute2    									VARCHAR2,
          p_attribute3    									VARCHAR2,
          p_attribute4    									VARCHAR2,
          p_attribute5    									VARCHAR2,
          p_attribute6    									VARCHAR2,
          p_attribute7    									VARCHAR2,
          p_attribute8    									VARCHAR2,
          p_attribute9    									VARCHAR2,
          p_attribute10    									VARCHAR2,
          p_attribute11    									VARCHAR2,
          p_attribute12    									VARCHAR2,
          p_attribute13    									VARCHAR2,
          p_attribute14    									VARCHAR2,
          p_attribute15    									VARCHAR2,
          p_security_group_id    							NUMBER,
		  p_control_COUNT    								NUMBER,
          p_RISK_COUNT    									NUMBER,
          p_ORG_COUNT    									NUMBER,
		  p_process_category 								varchar2 :=	  null,
		  p_finance_owner_id 								number	 :=	  null,
		  p_application_owner_id 							number	 :=	  null,
		  p_standard_variation 								number	 :=	  null,
          p_object_version_number    						NUMBER,
		  p_PROCESS_REV_ID    								NUMBER,
          p_process_id    									NUMBER)

 IS
   cursor c1 is
     select object_version_number from amw_process where process_rev_id=p_process_rev_id;

   l_obj_num c1%rowtype;
   l_object_version_number number := 0;

 BEGIN
   open c1;
  fetch c1 into l_obj_num;
   close c1;

   l_object_version_number := l_obj_num.object_version_number+1;

    Update AMW_PROCESS
    SET
              significant_process_flag = DECODE(p_significant_process_flag, FND_API.g_miss_char, significant_process_flag, p_significant_process_flag),
			  standard_process_flag    = DECODE(p_standard_process_flag, 	FND_API.g_miss_char, standard_process_flag, p_standard_process_flag),
			  approval_status 		   = DECODE(p_approval_status, 			FND_API.g_miss_char, approval_status, p_approval_status),
			  certification_status 	   = DECODE(p_certification_status, 	FND_API.g_miss_char, certification_status, p_certification_status),
			  process_owner_id 		   = DECODE( p_process_owner_id, 		FND_API.g_miss_num, process_owner_id, p_process_owner_id),
			  process_id 			   = DECODE( p_process_id, 				FND_API.g_miss_num, process_id, p_process_id),
			  last_update_date 		   = DECODE( p_last_update_date, 		FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by 		   = DECODE( p_last_updated_by, 		FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date 		   = DECODE( p_creation_date, 			FND_API.g_miss_date, creation_date, p_creation_date),
              created_by 			   = DECODE( p_created_by, 				FND_API.g_miss_num, created_by, p_created_by),
              last_update_login 	   = DECODE( p_last_update_login, 		FND_API.g_miss_num, last_update_login, p_last_update_login),
              item_type 			   = DECODE( p_item_type, 				FND_API.g_miss_char, item_type, p_item_type),
              name 					   = DECODE( p_name, 					FND_API.g_miss_char, name, p_name),
              created_from 			   = DECODE( p_created_from, 			FND_API.g_miss_char, created_from, p_created_from),
              request_id 			   = DECODE( p_request_id, 				FND_API.g_miss_num, request_id, p_request_id),
              program_application_id   = DECODE( p_program_application_id, 	FND_API.g_miss_num, program_application_id, p_program_application_id),
              program_id 			   = DECODE( p_program_id, 				FND_API.g_miss_num, program_id, p_program_id),
              program_update_date 	   = DECODE( p_program_update_date, 	FND_API.g_miss_date, program_update_date, p_program_update_date),
              attribute_category 	   = DECODE( p_attribute_category, 		FND_API.g_miss_char, attribute_category, p_attribute_category),
              attribute1 			   = DECODE( p_attribute1, 				FND_API.g_miss_char, attribute1, p_attribute1),
              attribute2 			   = DECODE( p_attribute2, 				FND_API.g_miss_char, attribute2, p_attribute2),
              attribute3 			   = DECODE( p_attribute3, 				FND_API.g_miss_char, attribute3, p_attribute3),
              attribute4 			   = DECODE( p_attribute4, 				FND_API.g_miss_char, attribute4, p_attribute4),
              attribute5 			   = DECODE( p_attribute5, 				FND_API.g_miss_char, attribute5, p_attribute5),
              attribute6 			   = DECODE( p_attribute6, 				FND_API.g_miss_char, attribute6, p_attribute6),
              attribute7 			   = DECODE( p_attribute7, 				FND_API.g_miss_char, attribute7, p_attribute7),
              attribute8 			   = DECODE( p_attribute8, 				FND_API.g_miss_char, attribute8, p_attribute8),
              attribute9 			   = DECODE( p_attribute9, 				FND_API.g_miss_char, attribute9, p_attribute9),
              attribute10 			   = DECODE( p_attribute10, 			FND_API.g_miss_char, attribute10, p_attribute10),
              attribute11 			   = DECODE( p_attribute11, 			FND_API.g_miss_char, attribute11, p_attribute11),
              attribute12 			   = DECODE( p_attribute12, 			FND_API.g_miss_char, attribute12, p_attribute12),
              attribute13 			   = DECODE( p_attribute13, 			FND_API.g_miss_char, attribute13, p_attribute13),
              attribute14 			   = DECODE( p_attribute14, 			FND_API.g_miss_char, attribute14, p_attribute14),
              attribute15 			   = DECODE( p_attribute15, 			FND_API.g_miss_char, attribute15, p_attribute15),
              security_group_id 	   = DECODE( p_security_group_id, 		FND_API.g_miss_num, security_group_id, p_security_group_id),
              object_version_number    = DECODE( l_object_version_number, 	FND_API.g_miss_num, object_version_number, l_object_version_number),
			  control_count 		   = DECODE( p_control_count, 			FND_API.g_miss_num, control_count, p_control_count),
			  risk_count 			   = DECODE( p_risk_count, 				FND_API.g_miss_num, risk_count, p_risk_count),
			  org_count 			   = DECODE( p_org_count, 				FND_API.g_miss_num, org_count, p_org_count),
			  process_category 		   = DECODE( p_process_category, 		FND_API.g_miss_char, process_category, p_process_category),
			  finance_owner_id 		   = DECODE( p_finance_owner_id, 		FND_API.g_miss_num, finance_owner_id, p_finance_owner_id),
			  application_owner_id 	   = DECODE( p_application_owner_id, 	FND_API.g_miss_num, application_owner_id, p_application_owner_id),
			  standard_variation 	   = DECODE( p_standard_variation, 		FND_API.g_miss_num, standard_variation, p_standard_variation)
   WHERE PROCESS_rev_ID = p_PROCESS_rev_ID;

   IF (SQL%NOTFOUND) THEN
     RAISE  NO_DATA_FOUND;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_PROCESS_rev_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMW_PROCESS
    WHERE PROCESS_rev_ID = p_PROCESS_rev_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_SIGNIFICANT_PROCESS_FLAG    					VARCHAR2,
          p_STANDARD_PROCESS_FLAG    						VARCHAR2,
          p_APPROVAL_STATUS    								VARCHAR2,
          p_CERTIFICATION_STATUS    						VARCHAR2,
          p_PROCESS_OWNER_ID    							NUMBER,
		  p_last_update_date    							DATE,
          p_last_updated_by    								NUMBER,
          p_creation_date    								DATE,
          p_created_by    									NUMBER,
          p_last_update_login    							NUMBER,
          p_item_type    									VARCHAR2,
          p_name    										VARCHAR2,
          p_created_from    								VARCHAR2,
          p_request_id    									NUMBER,
          p_program_application_id    						NUMBER,
          p_program_id    									NUMBER,
          p_program_update_date    							DATE,
          p_attribute_category    							VARCHAR2,
          p_attribute1    									VARCHAR2,
          p_attribute2    									VARCHAR2,
          p_attribute3    									VARCHAR2,
          p_attribute4    									VARCHAR2,
          p_attribute5    									VARCHAR2,
          p_attribute6    									VARCHAR2,
          p_attribute7    									VARCHAR2,
          p_attribute8    									VARCHAR2,
          p_attribute9    									VARCHAR2,
          p_attribute10    									VARCHAR2,
          p_attribute11    									VARCHAR2,
          p_attribute12    									VARCHAR2,
          p_attribute13    									VARCHAR2,
          p_attribute14    									VARCHAR2,
          p_attribute15    									VARCHAR2,
          p_security_group_id    							NUMBER,
		  p_RISK_COUNT    									NUMBER,
		  p_control_COUNT    								NUMBER,
          p_ORG_COUNT    									NUMBER,
		  p_process_category 								varchar2 :=		null,
		  p_finance_owner_id 								number	 :=		null,
		  p_application_owner_id 							number	 :=		null,
		  p_standard_variation 								number	 :=		null,
          p_object_version_number    						NUMBER,
		  p_PROCESS_REV_ID    								NUMBER,
          p_process_id    									NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMW_PROCESS
        WHERE PROCESS_rev_ID =  p_PROCESS_rev_ID
        FOR UPDATE of PROCESS_rev_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.last_update_date = p_last_update_date)
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.item_type = p_item_type)
            OR (    ( Recinfo.item_type IS NULL )
                AND (  p_item_type IS NULL )))
       AND (    ( Recinfo.name = p_name)
            OR (    ( Recinfo.name IS NULL )
                AND (  p_name IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.process_id = p_process_id)
            OR (    ( Recinfo.process_id IS NULL )
                AND (  p_process_id IS NULL )))
       AND (    ( Recinfo.process_category = p_process_category)
            OR (    ( Recinfo.process_category IS NULL )
                AND (  p_process_category IS NULL )))
       AND (    ( Recinfo.finance_owner_id = p_finance_owner_id)
            OR (    ( Recinfo.finance_owner_id IS NULL )
                AND (  p_finance_owner_id IS NULL )))
       AND (    ( Recinfo.application_owner_id = p_application_owner_id)
            OR (    ( Recinfo.application_owner_id IS NULL )
                AND (  p_application_owner_id IS NULL )))
       AND (    ( Recinfo.standard_variation = p_standard_variation)
            OR (    ( Recinfo.standard_variation IS NULL )
                AND (  p_standard_variation IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMW_PROCESS_PKG;

/
