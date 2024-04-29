--------------------------------------------------------
--  DDL for Package Body PV_PG_ENRL_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_ENRL_REQUESTS_PKG" as
/* $Header: pvxtperb.pls 120.5 2006/01/25 15:42:17 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrl_Requests_PKG
-- Purpose
--
-- History
--      29-AUG-2003  ktsao  Modified for column name change: transactional_curr_code to trans_curr_code
--      26-SEP-2003  pukken Added dependent_program_id column in  pv_pg_enrl_requests record
--      20-APR-2005  ktsao  Modified forR12.
--	05-JUL-2005  kvattiku Added trxn_extension_id column in  pv_pg_enrl_requests record
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pg_Enrl_Requests_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtperb.pls';




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_enrl_request_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_program_id    NUMBER,
          p_partner_id    NUMBER,
          p_custom_setup_id    NUMBER,
          p_requestor_resource_id    NUMBER,
          p_request_status_code    VARCHAR2,
          p_enrollment_type_code    VARCHAR2,
          p_request_submission_date    DATE,
          p_order_header_id    NUMBER,
          p_contract_id    NUMBER,
          p_request_initiated_by_code    VARCHAR2,
          p_invite_header_id    NUMBER,
          p_tentative_start_date    DATE,
          p_tentative_end_date    DATE,
          p_contract_status_code    VARCHAR2,
          p_payment_status_code    VARCHAR2,
          p_score_result_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_membership_fee    NUMBER,
          p_dependent_program_id    NUMBER,
          p_trans_curr_code    VARCHAR2,
          p_contract_binding_contact_id  NUMBER,
          p_contract_signed_date   DATE,
	  p_trxn_extension_id    NUMBER,
	  p_attribute1	VARCHAR2,
	  p_attribute2	VARCHAR2,
	  p_attribute3	VARCHAR2,
	  p_attribute4	VARCHAR2,
	  p_attribute5	VARCHAR2,
	  p_attribute6	VARCHAR2,
	  p_attribute7	VARCHAR2,
	  p_attribute8	VARCHAR2,
	  p_attribute9	VARCHAR2,
	  p_attribute10	VARCHAR2,
	  p_attribute11	VARCHAR2,
	  p_attribute12	VARCHAR2,
	  p_attribute13	VARCHAR2,
	  p_attribute14	VARCHAR2,
	  p_attribute15	VARCHAR2
          )
 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_pg_enrl_requests(
           enrl_request_id,
           object_version_number,
           program_id,
           partner_id,
           custom_setup_id,
           requestor_resource_id,
           request_status_code,
           enrollment_type_code,
           request_submission_date,
           order_header_id,
           contract_id,
           request_initiated_by_code,
           invite_header_id,
           tentative_start_date,
           tentative_end_date,
           contract_status_code,
           payment_status_code,
           score_result_code,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           membership_fee,
           dependent_program_id,
           trans_curr_code,
           contract_binding_contact_id,
           contract_signed_date,
	   trxn_extension_id,
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
	   attribute15
   ) VALUES (
           DECODE( px_enrl_request_id, FND_API.G_MISS_NUM, NULL, px_enrl_request_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
           DECODE( p_partner_id, FND_API.G_MISS_NUM, NULL, p_partner_id),
           DECODE( p_custom_setup_id, FND_API.G_MISS_NUM, NULL, p_custom_setup_id),
           DECODE( p_requestor_resource_id, FND_API.G_MISS_NUM, NULL, p_requestor_resource_id),
           DECODE( p_request_status_code, FND_API.g_miss_char, NULL, p_request_status_code),
           DECODE( p_enrollment_type_code, FND_API.g_miss_char, NULL, p_enrollment_type_code),
           DECODE( p_request_submission_date, FND_API.G_MISS_DATE, NULL, p_request_submission_date),
           DECODE( p_order_header_id, FND_API.G_MISS_NUM, NULL, p_order_header_id),
           DECODE( p_contract_id, FND_API.G_MISS_NUM, NULL, p_contract_id),
           DECODE( p_request_initiated_by_code, FND_API.g_miss_char, NULL, p_request_initiated_by_code),
           DECODE( p_invite_header_id, FND_API.G_MISS_NUM, NULL, p_invite_header_id),
           DECODE( p_tentative_start_date, FND_API.G_MISS_DATE, NULL, p_tentative_start_date),
           DECODE( p_tentative_end_date, FND_API.G_MISS_DATE, NULL, p_tentative_end_date),
           DECODE( p_contract_status_code, FND_API.g_miss_char, NULL, p_contract_status_code),
           DECODE( p_payment_status_code, FND_API.g_miss_char, NULL, p_payment_status_code),
           DECODE( p_score_result_code, FND_API.g_miss_char, NULL, p_score_result_code),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_membership_fee, FND_API.G_MISS_NUM, NULL, p_membership_fee),
           DECODE( p_dependent_program_id, FND_API.G_MISS_NUM, NULL, p_dependent_program_id),
           DECODE( p_trans_curr_code, FND_API.g_miss_char, NULL, p_trans_curr_code),
           DECODE( p_contract_binding_contact_id, FND_API.G_MISS_NUM, NULL, p_contract_binding_contact_id),
           DECODE( p_contract_signed_date, FND_API.G_MISS_DATE, SYSDATE, p_contract_signed_date),
	   DECODE( p_trxn_extension_id, FND_API.G_MISS_NUM, NULL, p_trxn_extension_id),
	   DECODE( p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
	   DECODE( p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
	   DECODE( p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
	   DECODE( p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
	   DECODE( p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
	   DECODE( p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
	   DECODE( p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
	   DECODE( p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
	   DECODE( p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
	   DECODE( p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
	   DECODE( p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
	   DECODE( p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
	   DECODE( p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
	   DECODE( p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
	   DECODE( p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15));

END Insert_Row;




--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_enrl_request_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_program_id    NUMBER,
          p_partner_id    NUMBER,
          p_custom_setup_id    NUMBER,
          p_requestor_resource_id    NUMBER,
          p_request_status_code    VARCHAR2,
          p_enrollment_type_code    VARCHAR2,
          p_request_submission_date    DATE,
          p_order_header_id    NUMBER,
          p_contract_id    NUMBER,
          p_request_initiated_by_code    VARCHAR2,
          p_invite_header_id    NUMBER,
          p_tentative_start_date    DATE,
          p_tentative_end_date    DATE,
          p_contract_status_code    VARCHAR2,
          p_payment_status_code    VARCHAR2,
          p_score_result_code    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_membership_fee    NUMBER,
          p_dependent_program_id    NUMBER,
          p_trans_curr_code    VARCHAR2,
          p_contract_binding_contact_id  NUMBER,
          p_contract_signed_date   DATE,
	  p_trxn_extension_id    NUMBER,
	  p_attribute1	VARCHAR2,
	  p_attribute2	VARCHAR2,
	  p_attribute3	VARCHAR2,
	  p_attribute4	VARCHAR2,
	  p_attribute5	VARCHAR2,
	  p_attribute6	VARCHAR2,
	  p_attribute7	VARCHAR2,
	  p_attribute8	VARCHAR2,
	  p_attribute9	VARCHAR2,
	  p_attribute10	VARCHAR2,
	  p_attribute11	VARCHAR2,
	  p_attribute12	VARCHAR2,
	  p_attribute13	VARCHAR2,
	  p_attribute14	VARCHAR2,
	  p_attribute15	VARCHAR2
          )

 IS
 BEGIN
    Update pv_pg_enrl_requests
    SET
              enrl_request_id = DECODE( p_enrl_request_id, null, enrl_request_id, FND_API.G_MISS_NUM, null, p_enrl_request_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              program_id = DECODE( p_program_id, null, program_id, FND_API.G_MISS_NUM, null, p_program_id),
              partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
              custom_setup_id = DECODE( p_custom_setup_id, null, custom_setup_id, FND_API.G_MISS_NUM, null, p_custom_setup_id),
              requestor_resource_id = DECODE( p_requestor_resource_id, null, requestor_resource_id, FND_API.G_MISS_NUM, null, p_requestor_resource_id),
              request_status_code = DECODE( p_request_status_code, null, request_status_code, FND_API.g_miss_char, null, p_request_status_code),
              enrollment_type_code = DECODE( p_enrollment_type_code, null, enrollment_type_code, FND_API.g_miss_char, null, p_enrollment_type_code),
              request_submission_date = DECODE( p_request_submission_date, null, request_submission_date, FND_API.G_MISS_DATE, null, p_request_submission_date),
              order_header_id = DECODE( p_order_header_id, null, order_header_id, FND_API.G_MISS_NUM, null, p_order_header_id),
              contract_id = DECODE( p_contract_id, null, contract_id, FND_API.G_MISS_NUM, null, p_contract_id),
              request_initiated_by_code = DECODE( p_request_initiated_by_code, null, request_initiated_by_code, FND_API.g_miss_char, null, p_request_initiated_by_code),
              invite_header_id = DECODE( p_invite_header_id, null, invite_header_id, FND_API.G_MISS_NUM, null, p_invite_header_id),
              tentative_start_date = DECODE( p_tentative_start_date, null, tentative_start_date, FND_API.G_MISS_DATE, null, p_tentative_start_date),
              tentative_end_date = DECODE( p_tentative_end_date, null, tentative_end_date, FND_API.G_MISS_DATE, null, p_tentative_end_date),
              contract_status_code = DECODE( p_contract_status_code, null, contract_status_code, FND_API.g_miss_char, null, p_contract_status_code),
              payment_status_code = DECODE( p_payment_status_code, null, payment_status_code, FND_API.g_miss_char, null, p_payment_status_code),
              score_result_code = DECODE( p_score_result_code, null, score_result_code, FND_API.g_miss_char, null, p_score_result_code),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              membership_fee = DECODE( p_membership_fee, null, membership_fee, FND_API.G_MISS_NUM, null, p_membership_fee),
              dependent_program_id = DECODE( p_dependent_program_id, null, dependent_program_id, FND_API.G_MISS_NUM, null, p_dependent_program_id),
              trans_curr_code = DECODE( p_trans_curr_code, null, trans_curr_code, FND_API.g_miss_char, null, p_trans_curr_code),
              contract_binding_contact_id = DECODE( p_contract_binding_contact_id, null, contract_binding_contact_id, FND_API.G_MISS_NUM, null, p_contract_binding_contact_id),
              contract_signed_date = DECODE( p_contract_signed_date, null, contract_signed_date, FND_API.G_MISS_DATE, null, p_contract_signed_date),
              trxn_extension_id = DECODE( p_trxn_extension_id, null, trxn_extension_id, FND_API.G_MISS_NUM, null, p_trxn_extension_id),
	      attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.G_MISS_CHAR, p_attribute1),
	      attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.G_MISS_CHAR, p_attribute2),
	      attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.G_MISS_CHAR, p_attribute3),
	      attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.G_MISS_CHAR, p_attribute4),
	      attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.G_MISS_CHAR, p_attribute5),
	      attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.G_MISS_CHAR, p_attribute6),
	      attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.G_MISS_CHAR, p_attribute7),
	      attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.G_MISS_CHAR, p_attribute8),
	      attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.G_MISS_CHAR, p_attribute9),
	      attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.G_MISS_CHAR, p_attribute10),
	      attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.G_MISS_CHAR, p_attribute11),
	      attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.G_MISS_CHAR, p_attribute12),
	      attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.G_MISS_CHAR, p_attribute13),
	      attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.G_MISS_CHAR, p_attribute14),
	      attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.G_MISS_CHAR, p_attribute15)
   WHERE enrl_request_id = p_enrl_request_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE PVX_Utility_PVT.API_RECORD_CHANGED;
   END IF;


END Update_Row;




--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_enrl_request_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_pg_enrl_requests
    WHERE enrl_request_id = p_enrl_request_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;





--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_enrl_request_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_pg_enrl_requests
        WHERE enrl_request_id =  p_enrl_request_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF enrl_request_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END PV_Pg_Enrl_Requests_PKG;

/
