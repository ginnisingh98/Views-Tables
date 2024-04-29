--------------------------------------------------------
--  DDL for Package PV_PG_ENRL_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_ENRL_REQUESTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtpers.pls 120.2 2005/10/24 08:29:42 dgottlie ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrl_Requests_PKG
-- Purpose
--
-- History
--      29-AUG-2003  ktsao  Modified for column name change: transactional_curr_code to trans_curr_code
--      26-SEP-2003  pukken Added dependent_program_id column in  pv_pg_enrl_requests record
--      20-APR-2005  ktsao  Modified R12.
--	05-JUL-2005  kvattiku Added trxn_extension_id column in  pv_pg_enrl_requests record
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================




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
	  p_attribute15	VARCHAR2);





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
	  p_attribute15	VARCHAR2);




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
    p_object_version_number  NUMBER);




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
    p_object_version_number  NUMBER);


END PV_Pg_Enrl_Requests_PKG;

 

/
