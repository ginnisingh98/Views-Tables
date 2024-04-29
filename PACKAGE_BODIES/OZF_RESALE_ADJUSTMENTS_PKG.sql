--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_ADJUSTMENTS_PKG" as
/* $Header: ozftrsab.pls 120.1.12000000.2 2007/05/28 10:24:37 ateotia ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_ADJUSTMENTS_PKG
-- Purpose
--
-- History
-- Anuj Teotia              28/05/2007       bug # 5997978 fixed
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RESALE_ADJUSTMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrsab.pls';


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
          px_resale_adjustment_id   IN OUT  NOCOPY NUMBER,
          px_object_version_number   IN OUT  NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_resale_batch_id    NUMBER,
	  p_orig_system_agreement_uom	varchar2,
          p_ORIG_SYSTEM_AGREEMENT_name  varchar2,
          p_orig_system_agreement_type      VARCHAR2,
          p_orig_system_agreement_status    VARCHAR2,
          p_orig_system_agreement_curr       VARCHAR2,
          p_orig_system_agreement_price     NUMBER,
          p_orig_system_agreement_quant  NUMBER,
          p_agreement_id    NUMBER,
          p_agreement_type    VARCHAR2,
          p_agreement_name    VARCHAR2,
          p_agreement_price    NUMBER,
          p_agreement_uom_code    VARCHAR2,
          p_corrected_agreement_id    NUMBER,
          p_corrected_agreement_name    VARCHAR2,
	  p_credit_code       varchar2,
	  p_credit_advice_date   DATE,
          p_allowed_amount    NUMBER,
          p_total_allowed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_total_accepted_amount    NUMBER,
          p_claimed_amount    NUMBER,
          p_total_claimed_amount    NUMBER,
	  p_calculated_price             NUMBER,
          p_acctd_calculated_price       NUMBER,
          p_calculated_amount            NUMBER,
	  p_line_agreement_flag       varchar2,
          p_tolerance_flag    VARCHAR2,
          p_line_tolerance_amount    NUMBER,
          p_operand    NUMBER,
          p_operand_calculation_code    VARCHAR2,
          p_priced_quantity    NUMBER,
          p_priced_uom_code    VARCHAR2,
          p_priced_unit_price    NUMBER,
          p_list_header_id    NUMBER,
          p_list_line_id    NUMBER,
          p_status_code    VARCHAR2,
          px_org_id   IN OUT  NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);
   l_batch_org_id NUMBER; -- bug # 5997978 fixed

BEGIN

   -- Start: bug # 5997978 fixed
   IF px_org_id IS NULL THEN
      OPEN OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr(p_resale_batch_id);
      FETCH OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr INTO l_batch_org_id;
      CLOSE OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr;
      px_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
      IF (l_batch_org_id IS NULL OR px_org_id IS NULL) THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      /*IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL; */
   END IF;
   -- End: bug # 5997978 fixed


   px_object_version_number := 1;


   INSERT INTO OZF_RESALE_ADJUSTMENTS_ALL(
           resale_adjustment_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           request_id,
           created_by,
           created_from,
           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           resale_line_id,
           resale_batch_id,
           orig_system_agreement_uom,
           ORIG_SYSTEM_AGREEMENT_name,
           orig_system_agreement_type,
           orig_system_agreement_status ,
           orig_system_agreement_curr,
           orig_system_agreement_price,
           orig_system_agreement_quantity,
           agreement_id,
           agreement_type,
           agreement_name,
	   agreement_price,
	   agreement_uom_code,
           corrected_agreement_id,
           corrected_agreement_name,
           credit_code,
           credit_advice_date,
	   allowed_amount,
           total_allowed_amount,
           accepted_amount,
           total_accepted_amount,
           claimed_amount,
           total_claimed_amount,
	   calculated_price,
           acctd_calculated_price,
           calculated_amount,
	   line_agreement_flag,
           tolerance_flag,
           line_tolerance_amount,
           operand,
           operand_calculation_code,
           priced_quantity,
           priced_uom_code,
           priced_unit_price,
           list_header_id,
           list_line_id,
           status_code,
           org_id
   ) VALUES (
           px_resale_adjustment_id,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_request_id,
           p_created_by,
           p_created_from,
           p_last_update_login,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_resale_line_id,
           p_resale_batch_id,
           p_orig_system_agreement_uom,
           p_ORIG_SYSTEM_AGREEMENT_name,
           p_orig_system_agreement_type,
           p_orig_system_agreement_status ,
           p_orig_system_agreement_curr,
           p_orig_system_agreement_price,
           p_orig_system_agreement_quant,
           p_agreement_id,
           p_agreement_type,
           p_agreement_name,
           p_agreement_price,
           p_agreement_uom_code,
	   p_corrected_agreement_id,
           p_corrected_agreement_name,
           p_credit_code,
	   p_credit_advice_date,
           p_allowed_amount,
           p_total_allowed_amount,
           p_accepted_amount,
           p_total_accepted_amount,
           p_claimed_amount,
           p_total_claimed_amount,
	   p_calculated_price,
           p_acctd_calculated_price,
           p_calculated_amount,
	   p_line_agreement_flag,
	   p_tolerance_flag,
           p_line_tolerance_amount,
           p_operand,
           p_operand_calculation_code,
           p_priced_quantity,
           p_priced_uom_code,
           p_priced_unit_price,
           p_list_header_id,
           p_list_line_id,
           p_status_code,
           px_org_id);
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
          p_resale_adjustment_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_resale_batch_id    NUMBER,
	  p_orig_system_agreement_uom	varchar2,
          p_ORIG_SYSTEM_AGREEMENT_name  varchar2,
          p_orig_system_agreement_type      VARCHAR2,
          p_orig_system_agreement_status    VARCHAR2,
          p_orig_system_agreement_curr       VARCHAR2,
          p_orig_system_agreement_price     NUMBER,
          p_orig_system_agreement_quant  NUMBER,
          p_agreement_id    NUMBER,
          p_agreement_type    VARCHAR2,
          p_agreement_name    VARCHAR2,
          p_agreement_price    NUMBER,
          p_agreement_uom_code    VARCHAR2,
          p_corrected_agreement_id    NUMBER,
          p_corrected_agreement_name    VARCHAR2,
	  p_credit_code       varchar2,
	  p_credit_advice_date   DATE,
          p_allowed_amount    NUMBER,
          p_total_allowed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_total_accepted_amount    NUMBER,
          p_claimed_amount    NUMBER,
          p_total_claimed_amount    NUMBER,
	  p_calculated_price             NUMBER,
          p_acctd_calculated_price       NUMBER,
          p_calculated_amount            NUMBER,
	  p_line_agreement_flag       varchar2,
          p_tolerance_flag    VARCHAR2,
          p_line_tolerance_amount    NUMBER,
          p_operand    NUMBER,
          p_operand_calculation_code    VARCHAR2,
          p_priced_quantity    NUMBER,
          p_priced_uom_code    VARCHAR2,
          p_priced_unit_price    NUMBER,
          p_list_header_id    NUMBER,
          p_list_line_id    NUMBER,
          p_status_code    VARCHAR2,
          p_org_id    NUMBER)

 IS
 BEGIN
    Update OZF_RESALE_ADJUSTMENTS_ALL
    SET
              resale_adjustment_id = p_resale_adjustment_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              request_id = p_request_id,
              created_from = p_created_from,
              last_update_login = p_last_update_login,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              resale_line_id = p_resale_line_id,
              resale_batch_id = p_resale_batch_id,
              orig_system_agreement_uom = p_orig_system_agreement_uom,
              ORIG_SYSTEM_AGREEMENT_name = p_ORIG_SYSTEM_AGREEMENT_name,
	      orig_system_agreement_type = p_orig_system_agreement_type,
              orig_system_agreement_status = p_orig_system_agreement_status,
	      orig_system_agreement_curr = p_orig_system_agreement_curr,
              orig_system_agreement_price = p_orig_system_agreement_price,
              orig_system_agreement_quantity = p_orig_system_agreement_quant,
              agreement_id = p_agreement_id,
              agreement_type = p_agreement_type,
              agreement_name = p_agreement_name,
	      agreement_price = p_agreement_price,
              agreement_uom_code = p_agreement_uom_code,
              corrected_agreement_id = p_corrected_agreement_id,
              corrected_agreement_name = p_corrected_agreement_name,
	      credit_code = p_credit_code,
	      credit_advice_date = p_credit_advice_date,
              allowed_amount = p_allowed_amount,
              total_allowed_amount = p_total_allowed_amount,
              accepted_amount = p_accepted_amount,
              total_accepted_amount = p_total_accepted_amount,
              claimed_amount = p_claimed_amount,
              total_claimed_amount = p_total_claimed_amount,
              calculated_price = p_calculated_price,
              acctd_calculated_price = p_acctd_calculated_price,
              calculated_amount = p_calculated_amount,
	      line_agreement_flag = p_line_agreement_flag,
	      tolerance_flag = p_tolerance_flag,
              line_tolerance_amount = p_line_tolerance_amount,
              operand = p_operand,
              operand_calculation_code = p_operand_calculation_code,
              priced_quantity = p_priced_quantity,
              priced_uom_code = p_priced_uom_code,
              priced_unit_price = p_priced_unit_price,
              list_header_id = p_list_header_id,
              list_line_id = p_list_line_id,
              status_code = p_status_code,
              org_id = p_org_id
   WHERE RESALE_ADJUSTMENT_ID = p_RESALE_ADJUSTMENT_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
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
    p_RESALE_ADJUSTMENT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RESALE_ADJUSTMENTS_ALL
    WHERE RESALE_ADJUSTMENT_ID = p_RESALE_ADJUSTMENT_ID;
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
          p_resale_adjustment_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_resale_batch_id    NUMBER,
          p_orig_system_agreement_uom	varchar2,
          p_ORIG_SYSTEM_AGREEMENT_name  varchar2,
          p_orig_system_agreement_type      VARCHAR2,
          p_orig_system_agreement_status    VARCHAR2,
          p_orig_system_agreement_curr       VARCHAR2,
          p_orig_system_agreement_price     NUMBER,
          p_orig_system_agreement_quant  NUMBER,
          p_agreement_id    NUMBER,
          p_agreement_type    VARCHAR2,
          p_agreement_name    VARCHAR2,
          p_agreement_price    NUMBER,
          p_agreement_uom_code    VARCHAR2,
          p_corrected_agreement_id    NUMBER,
          p_corrected_agreement_name    VARCHAR2,
	  p_credit_code       varchar2,
	  p_credit_advice_date   DATE,
          p_allowed_amount    NUMBER,
          p_total_allowed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_total_accepted_amount    NUMBER,
          p_claimed_amount    NUMBER,
          p_total_claimed_amount    NUMBER,
	  p_calculated_price             NUMBER,
          p_acctd_calculated_price       NUMBER,
          p_calculated_amount            NUMBER,
	  p_line_agreement_flag       varchar2,
          p_tolerance_flag    VARCHAR2,
          p_line_tolerance_amount    NUMBER,
          p_operand    NUMBER,
          p_operand_calculation_code    VARCHAR2,
          p_priced_quantity    NUMBER,
          p_priced_uom_code    VARCHAR2,
          p_priced_unit_price    NUMBER,
          p_list_header_id    NUMBER,
          p_list_line_id    NUMBER,
          p_status_code    VARCHAR2,
          p_org_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RESALE_ADJUSTMENTS_ALL
        WHERE RESALE_ADJUSTMENT_ID =  p_RESALE_ADJUSTMENT_ID
        FOR UPDATE of RESALE_ADJUSTMENT_ID NOWAIT;
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
           (      Recinfo.resale_adjustment_id = p_resale_adjustment_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.resale_line_id = p_resale_line_id)
            OR (    ( Recinfo.resale_line_id IS NULL )
                AND (  p_resale_line_id IS NULL )))
       AND (    ( Recinfo.resale_batch_id = p_resale_batch_id)
            OR (    ( Recinfo.resale_batch_id IS NULL )
                AND (  p_resale_batch_id IS NULL )))
       AND (    ( Recinfo.orig_system_agreement_uom = p_orig_system_agreement_uom)
            OR (    ( Recinfo.orig_system_agreement_uom IS NULL )
                AND (  p_orig_system_agreement_uom IS NULL )))
       AND (    ( Recinfo.ORIG_SYSTEM_AGREEMENT_name = p_ORIG_SYSTEM_AGREEMENT_name)
            OR (    ( Recinfo.ORIG_SYSTEM_AGREEMENT_name IS NULL )
                AND (  p_ORIG_SYSTEM_AGREEMENT_name IS NULL )))
       AND (    ( Recinfo.orig_system_agreement_type = p_orig_system_agreement_type)
            OR (    ( Recinfo.orig_system_agreement_type IS NULL )
                AND (  p_orig_system_agreement_type IS NULL )))
       AND (    ( Recinfo.orig_system_agreement_status = p_orig_system_agreement_status)
            OR (    ( Recinfo.orig_system_agreement_status IS NULL )
                AND (  p_orig_system_agreement_status IS NULL )))
      AND (    ( Recinfo.orig_system_agreement_curr = p_orig_system_agreement_curr)
            OR (    ( Recinfo.orig_system_agreement_curr IS NULL )
                AND (  p_orig_system_agreement_curr IS NULL )))
       AND (    ( Recinfo.orig_system_agreement_price = p_orig_system_agreement_price)
            OR (    ( Recinfo.orig_system_agreement_price IS NULL )
                AND (  p_orig_system_agreement_price IS NULL )))
       AND (    ( Recinfo.orig_system_agreement_quantity = p_orig_system_agreement_quant)
            OR (    ( Recinfo.orig_system_agreement_quantity IS NULL )
                AND (  p_orig_system_agreement_quant IS NULL )))
       AND (    ( Recinfo.agreement_id = p_agreement_id)
            OR (    ( Recinfo.agreement_id IS NULL )
                AND (  p_agreement_id IS NULL )))
       AND (    ( Recinfo.agreement_type = p_agreement_type)
            OR (    ( Recinfo.agreement_type IS NULL )
                AND (  p_agreement_type IS NULL )))
       AND (    ( Recinfo.agreement_name = p_agreement_name)
            OR (    ( Recinfo.agreement_name IS NULL )
                AND (  p_agreement_name IS NULL )))
       AND (    ( Recinfo.agreement_price = p_agreement_price)
            OR (    ( Recinfo.agreement_price IS NULL )
                AND (  p_agreement_price IS NULL )))
       AND (    ( Recinfo.agreement_uom_code = p_agreement_uom_code)
            OR (    ( Recinfo.agreement_uom_code IS NULL )
                AND (  p_agreement_uom_code IS NULL )))
       AND (    ( Recinfo.corrected_agreement_id = p_corrected_agreement_id)
            OR (    ( Recinfo.corrected_agreement_id IS NULL )
                AND (  p_corrected_agreement_id IS NULL )))
       AND (    ( Recinfo.corrected_agreement_name = p_corrected_agreement_name)
            OR (    ( Recinfo.corrected_agreement_name IS NULL )
                AND (  p_corrected_agreement_name IS NULL )))
       AND (    ( Recinfo.credit_code = p_credit_code)
            OR (    ( Recinfo.credit_code IS NULL )
                AND (  p_credit_code IS NULL )))
       AND (    ( Recinfo.credit_advice_date = p_credit_advice_date)
            OR (    ( Recinfo.credit_advice_date IS NULL )
                AND (  p_credit_advice_date IS NULL )))
       AND (    ( Recinfo.allowed_amount = p_allowed_amount)
            OR (    ( Recinfo.allowed_amount IS NULL )
                AND (  p_allowed_amount IS NULL )))
       AND (    ( Recinfo.total_allowed_amount = p_total_allowed_amount)
            OR (    ( Recinfo.total_allowed_amount IS NULL )
                AND (  p_total_allowed_amount IS NULL )))
       AND (    ( Recinfo.accepted_amount = p_accepted_amount)
            OR (    ( Recinfo.accepted_amount IS NULL )
                AND (  p_accepted_amount IS NULL )))
       AND (    ( Recinfo.total_accepted_amount = p_total_accepted_amount)
            OR (    ( Recinfo.total_accepted_amount IS NULL )
                AND (  p_total_accepted_amount IS NULL )))
       AND (    ( Recinfo.claimed_amount = p_claimed_amount)
            OR (    ( Recinfo.claimed_amount IS NULL )
                AND (  p_claimed_amount IS NULL )))
       AND (    ( Recinfo.total_claimed_amount = p_total_claimed_amount)
            OR (    ( Recinfo.total_claimed_amount IS NULL )
                AND (  p_total_claimed_amount IS NULL )))
       AND (    ( Recinfo.calculated_price = p_calculated_price)
            OR (    ( Recinfo.calculated_price IS NULL )
                AND (  p_calculated_price IS NULL )))
       AND (    ( Recinfo.acctd_calculated_price = p_acctd_calculated_price)
            OR (    ( Recinfo.acctd_calculated_price IS NULL )
                AND (  p_acctd_calculated_price IS NULL )))
       AND (    ( Recinfo.calculated_amount = p_calculated_amount)
            OR (    ( Recinfo.calculated_amount IS NULL )
                AND (  p_calculated_amount IS NULL )))
       AND (    ( Recinfo.line_agreement_flag = p_line_agreement_flag)
            OR (    ( Recinfo.line_agreement_flag IS NULL )
                AND (  p_line_agreement_flag IS NULL )))
       AND (    ( Recinfo.tolerance_flag = p_tolerance_flag)
            OR (    ( Recinfo.tolerance_flag IS NULL )
                AND (  p_tolerance_flag IS NULL )))
       AND (    ( Recinfo.line_tolerance_amount = p_line_tolerance_amount)
            OR (    ( Recinfo.line_tolerance_amount IS NULL )
                AND (  p_line_tolerance_amount IS NULL )))
       AND (    ( Recinfo.operand = p_operand)
            OR (    ( Recinfo.operand IS NULL )
                AND (  p_operand IS NULL )))
       AND (    ( Recinfo.operand_calculation_code = p_operand_calculation_code)
            OR (    ( Recinfo.operand_calculation_code IS NULL )
                AND (  p_operand_calculation_code IS NULL )))
       AND (    ( Recinfo.priced_quantity = p_priced_quantity)
            OR (    ( Recinfo.priced_quantity IS NULL )
                AND (  p_priced_quantity IS NULL )))
       AND (    ( Recinfo.priced_uom_code = p_priced_uom_code)
            OR (    ( Recinfo.priced_uom_code IS NULL )
                AND (  p_priced_uom_code IS NULL )))
       AND (    ( Recinfo.priced_unit_price = p_priced_unit_price)
            OR (    ( Recinfo.priced_unit_price IS NULL )
                AND (  p_priced_unit_price IS NULL )))
       AND (    ( Recinfo.list_header_id = p_list_header_id)
            OR (    ( Recinfo.list_header_id IS NULL )
                AND (  p_list_header_id IS NULL )))
       AND (    ( Recinfo.list_line_id = p_list_line_id)
            OR (    ( Recinfo.list_line_id IS NULL )
                AND (  p_list_line_id IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_RESALE_ADJUSTMENTS_PKG;

/
