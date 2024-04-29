--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_HEADERS_PKG" as
/* $Header: ozftrshb.pls 115.1 2003/12/02 11:02:11 jxwu noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_HEADERS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RESALE_HEADERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrshb.pls';


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
          px_resale_header_id   IN OUT NOCOPY  NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_date_shipped    DATE,
          p_date_ordered    DATE,
          p_order_type_id    NUMBER,
          p_order_type    VARCHAR2,
          p_order_category    VARCHAR2,
          p_status_code    VARCHAR2,
          p_direct_customer_flag    VARCHAR2,
          p_order_number    VARCHAR2,
          p_price_list_id    NUMBER,
          p_bill_to_cust_account_id    NUMBER,
          p_bill_to_site_use_id    NUMBER,
          p_bill_to_PARTY_NAME    VARCHAR2,
          p_bill_to_PARTY_ID      NUMBER,
          p_bill_to_PARTY_site_id NUMBER,
          p_bill_to_location    VARCHAR2,
          p_bill_to_duns_number    VARCHAR2,
          p_bill_to_address    VARCHAR2,
          p_bill_to_city    VARCHAR2,
          p_bill_to_state    VARCHAR2,
          p_bill_to_postal_code    VARCHAR2,
          p_bill_to_country    VARCHAR2,
          p_bill_to_contact_party_id   NUMBER,
          p_bill_to_contact_name    VARCHAR2,
	  p_bill_to_email           VARCHAR2,
          p_bill_to_phone              VARCHAR2,
          p_bill_to_fax                VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_ship_to_site_use_id    NUMBER,
          p_ship_to_PARTY_NAME    VARCHAR2,
          p_ship_to_PARTY_ID      NUMBER,
          p_ship_to_PARTY_site_id NUMBER,
          p_ship_to_location    VARCHAR2,
          p_ship_to_duns_number    VARCHAR2,
          p_ship_to_address    VARCHAR2,
          p_ship_to_city    VARCHAR2,
          p_ship_to_state    VARCHAR2,
          p_ship_to_postal_code    VARCHAR2,
          p_ship_to_country    VARCHAR2,
          p_ship_to_contact_party_id   NUMBER,
          p_ship_to_contact_name    VARCHAR2,
          p_ship_to_email           VARCHAR2,
          p_ship_to_phone              VARCHAR2,
          p_ship_to_fax                VARCHAR2,
          p_sold_from_cust_account_id    NUMBER,
          p_ship_from_cust_account_id    NUMBER,
          p_header_attribute_category    VARCHAR2,
          p_header_attribute1    VARCHAR2,
          p_header_attribute2    VARCHAR2,
          p_header_attribute3    VARCHAR2,
          p_header_attribute4    VARCHAR2,
          p_header_attribute5    VARCHAR2,
          p_header_attribute6    VARCHAR2,
          p_header_attribute7    VARCHAR2,
          p_header_attribute8    VARCHAR2,
          p_header_attribute9    VARCHAR2,
          p_header_attribute10    VARCHAR2,
          p_header_attribute11    VARCHAR2,
          p_header_attribute12    VARCHAR2,
          p_header_attribute13    VARCHAR2,
          p_header_attribute14    VARCHAR2,
          p_header_attribute15    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          px_org_id   IN OUT NOCOPY  NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

   IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL;
   END IF;


   px_object_version_number := 1;


   INSERT INTO OZF_RESALE_HEADERS_ALL(
           resale_header_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           request_id,
           created_by,
           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           created_from,
           date_shipped,
           date_ordered,
           order_type_id,
           order_type,
           order_category,
           status_code,
           direct_customer_flag,
           order_number,
           price_list_id,
           bill_to_cust_account_id,
           bill_to_site_use_id,
           bill_to_PARTY_NAME,
           bill_to_PARTY_ID,
           bill_to_PARTY_site_id,
           bill_to_location,
           bill_to_duns_number,
           bill_to_address,
           bill_to_city,
           bill_to_state,
           bill_to_postal_code,
           bill_to_country,
           bill_to_contact_party_id,
	   bill_to_contact_name,
           bill_to_email,
           bill_to_phone,
           bill_to_fax,
           ship_to_cust_account_id,
           ship_to_site_use_id,
           ship_to_PARTY_NAME,
           ship_to_PARTY_ID,
           ship_to_PARTY_site_id,
           ship_to_location,
           ship_to_duns_number,
           ship_to_address,
           ship_to_city,
           ship_to_state,
           ship_to_postal_code,
           ship_to_country,
           ship_to_contact_party_id,
           ship_to_contact_name,
           ship_to_email,
           ship_to_phone,
           ship_to_fax,
           sold_from_cust_account_id,
           ship_from_cust_account_id,
           header_attribute_category,
           header_attribute1,
           header_attribute2,
           header_attribute3,
           header_attribute4,
           header_attribute5,
           header_attribute6,
           header_attribute7,
           header_attribute8,
           header_attribute9,
           header_attribute10,
           header_attribute11,
           header_attribute12,
           header_attribute13,
           header_attribute14,
           header_attribute15,
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
           org_id
   ) VALUES (
           px_resale_header_id,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_request_id,
           p_created_by,
           p_last_update_login,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_created_from,
           p_date_shipped,
           p_date_ordered,
           p_order_type_id,
           p_order_type,
           p_order_category,
           p_status_code,
           p_direct_customer_flag,
           p_order_number,
           p_price_list_id,
           p_bill_to_cust_account_id,
           p_bill_to_site_use_id,
           p_bill_to_PARTY_NAME,
           p_bill_to_PARTY_ID,
           p_bill_to_PARTY_site_id,
           p_bill_to_location,
           p_bill_to_duns_number,
           p_bill_to_address,
           p_bill_to_city,
           p_bill_to_state,
           p_bill_to_postal_code,
           p_bill_to_country,
           p_bill_to_contact_party_id,
           p_bill_to_contact_name,
           p_bill_to_email,
           p_bill_to_phone,
           p_bill_to_fax,
           p_ship_to_cust_account_id,
           p_ship_to_site_use_id,
           p_ship_to_PARTY_NAME,
           p_ship_to_PARTY_ID,
           p_ship_to_PARTY_site_id,
           p_ship_to_location,
           p_ship_to_duns_number,
           p_ship_to_address,
           p_ship_to_city,
           p_ship_to_state,
           p_ship_to_postal_code,
           p_ship_to_country,
           p_ship_to_contact_party_id,
	   p_ship_to_contact_name,
           p_ship_to_email,
           p_ship_to_phone,
           p_ship_to_fax,
           p_sold_from_cust_account_id,
           p_ship_from_cust_account_id,
           p_header_attribute_category,
           p_header_attribute1,
           p_header_attribute2,
           p_header_attribute3,
           p_header_attribute4,
           p_header_attribute5,
           p_header_attribute6,
           p_header_attribute7,
           p_header_attribute8,
           p_header_attribute9,
           p_header_attribute10,
           p_header_attribute11,
           p_header_attribute12,
           p_header_attribute13,
           p_header_attribute14,
           p_header_attribute15,
           p_attribute_category,
           p_attribute1,
           p_attribute2,
           p_attribute3,
           p_attribute4,
           p_attribute5,
           p_attribute6,
           p_attribute7,
           p_attribute8,
           p_attribute9,
           p_attribute10,
           p_attribute11,
           p_attribute12,
           p_attribute13,
           p_attribute14,
           p_attribute15,
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
          p_resale_header_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_date_shipped    DATE,
          p_date_ordered    DATE,
          p_order_type_id    NUMBER,
          p_order_type    VARCHAR2,
          p_order_category    VARCHAR2,
          p_status_code    VARCHAR2,
          p_direct_customer_flag    VARCHAR2,
          p_order_number    VARCHAR2,
          p_price_list_id    NUMBER,
          p_bill_to_cust_account_id    NUMBER,
          p_bill_to_site_use_id    NUMBER,
          p_bill_to_PARTY_NAME    VARCHAR2,
          p_bill_to_PARTY_ID      NUMBER,
          p_bill_to_PARTY_site_id NUMBER,
          p_bill_to_location    VARCHAR2,
          p_bill_to_duns_number    VARCHAR2,
          p_bill_to_address    VARCHAR2,
          p_bill_to_city    VARCHAR2,
          p_bill_to_state    VARCHAR2,
          p_bill_to_postal_code    VARCHAR2,
          p_bill_to_country    VARCHAR2,
          p_bill_to_contact_party_id   NUMBER,
          p_bill_to_contact_name    VARCHAR2,
	  p_bill_to_email           VARCHAR2,
          p_bill_to_phone              VARCHAR2,
          p_bill_to_fax                VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_ship_to_site_use_id    NUMBER,
          p_ship_to_PARTY_NAME    VARCHAR2,
          p_ship_to_PARTY_ID      NUMBER,
          p_ship_to_PARTY_site_id NUMBER,
          p_ship_to_location    VARCHAR2,
          p_ship_to_duns_number    VARCHAR2,
          p_ship_to_address    VARCHAR2,
          p_ship_to_city    VARCHAR2,
          p_ship_to_state    VARCHAR2,
          p_ship_to_postal_code    VARCHAR2,
          p_ship_to_country    VARCHAR2,
          p_ship_to_contact_party_id   NUMBER,
          p_ship_to_contact_name    VARCHAR2,
	  p_ship_to_email           VARCHAR2,
          p_ship_to_phone              VARCHAR2,
          p_ship_to_fax                VARCHAR2,
          p_sold_from_cust_account_id    NUMBER,
          p_ship_from_cust_account_id    NUMBER,
          p_header_attribute_category    VARCHAR2,
          p_header_attribute1    VARCHAR2,
          p_header_attribute2    VARCHAR2,
          p_header_attribute3    VARCHAR2,
          p_header_attribute4    VARCHAR2,
          p_header_attribute5    VARCHAR2,
          p_header_attribute6    VARCHAR2,
          p_header_attribute7    VARCHAR2,
          p_header_attribute8    VARCHAR2,
          p_header_attribute9    VARCHAR2,
          p_header_attribute10    VARCHAR2,
          p_header_attribute11    VARCHAR2,
          p_header_attribute12    VARCHAR2,
          p_header_attribute13    VARCHAR2,
          p_header_attribute14    VARCHAR2,
          p_header_attribute15    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER)

 IS
 BEGIN
    Update OZF_RESALE_HEADERS_ALL
    SET
              resale_header_id = p_resale_header_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              request_id = p_request_id,
              last_update_login = p_last_update_login,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              created_from = p_created_from,
              date_shipped = p_date_shipped,
              date_ordered = p_date_ordered,
              order_type_id = p_order_type_id,
              order_type = p_order_type,
              order_category = p_order_category,
              status_code = p_status_code,
              direct_customer_flag = p_direct_customer_flag,
              order_number = p_order_number,
              price_list_id = p_price_list_id,
              bill_to_cust_account_id = p_bill_to_cust_account_id,
              bill_to_site_use_id = p_bill_to_site_use_id,
              bill_to_PARTY_NAME = p_bill_to_PARTY_NAME,
              bill_to_PARTY_ID = p_bill_to_PARTY_ID,
              bill_to_PARTY_site_id = p_bill_to_PARTY_site_id,
              bill_to_location = p_bill_to_location,
              bill_to_duns_number = p_bill_to_duns_number,
              bill_to_address = p_bill_to_address,
              bill_to_city = p_bill_to_city,
              bill_to_state = p_bill_to_state,
              bill_to_postal_code = p_bill_to_postal_code,
              bill_to_country = p_bill_to_country,
              bill_to_contact_party_id = p_bill_to_contact_party_id,
	      bill_to_contact_name = p_bill_to_contact_name,
              bill_to_email = p_bill_to_email,
              bill_to_phone = p_bill_to_phone,
              bill_to_fax = p_bill_to_fax,
              ship_to_cust_account_id = p_ship_to_cust_account_id,
              ship_to_site_use_id = p_ship_to_site_use_id,
              ship_to_PARTY_NAME = p_ship_to_PARTY_NAME,
              ship_to_PARTY_ID = p_ship_to_PARTY_ID,
              ship_to_PARTY_site_id = p_ship_to_PARTY_site_id,
              ship_to_location = p_ship_to_location,
              ship_to_duns_number = p_ship_to_duns_number,
              ship_to_address = p_ship_to_address,
              ship_to_city = p_ship_to_city,
              ship_to_state = p_ship_to_state,
              ship_to_postal_code = p_ship_to_postal_code,
              ship_to_country = p_ship_to_country,
	      ship_to_contact_party_id = p_ship_to_contact_party_id,
              ship_to_contact_name = p_ship_to_contact_name,
	      ship_to_email = p_ship_to_email,
              ship_to_phone = p_ship_to_phone,
              ship_to_fax = p_ship_to_fax,
              sold_from_cust_account_id = p_sold_from_cust_account_id,
              ship_from_cust_account_id = p_ship_from_cust_account_id,
              header_attribute_category = p_header_attribute_category,
              header_attribute1 = p_header_attribute1,
              header_attribute2 = p_header_attribute2,
              header_attribute3 = p_header_attribute3,
              header_attribute4 = p_header_attribute4,
              header_attribute5 = p_header_attribute5,
              header_attribute6 = p_header_attribute6,
              header_attribute7 = p_header_attribute7,
              header_attribute8 = p_header_attribute8,
              header_attribute9 = p_header_attribute9,
              header_attribute10 = p_header_attribute10,
              header_attribute11 = p_header_attribute11,
              header_attribute12 = p_header_attribute12,
              header_attribute13 = p_header_attribute13,
              header_attribute14 = p_header_attribute14,
              header_attribute15 = p_header_attribute15,
              attribute_category = p_attribute_category,
              attribute1 = p_attribute1,
              attribute2 = p_attribute2,
              attribute3 = p_attribute3,
              attribute4 = p_attribute4,
              attribute5 = p_attribute5,
              attribute6 = p_attribute6,
              attribute7 = p_attribute7,
              attribute8 = p_attribute8,
              attribute9 = p_attribute9,
              attribute10 = p_attribute10,
              attribute11 = p_attribute11,
              attribute12 = p_attribute12,
              attribute13 = p_attribute13,
              attribute14 = p_attribute14,
              attribute15 = p_attribute15,
              org_id = p_org_id
   WHERE RESALE_HEADER_ID = p_RESALE_HEADER_ID
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
    p_RESALE_HEADER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RESALE_HEADERS_ALL
    WHERE RESALE_HEADER_ID = p_RESALE_HEADER_ID;
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
          p_resale_header_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_date_shipped    DATE,
          p_date_ordered    DATE,
          p_order_type_id    NUMBER,
          p_order_type    VARCHAR2,
          p_order_category    VARCHAR2,
          p_status_code    VARCHAR2,
          p_direct_customer_flag    VARCHAR2,
          p_order_number    VARCHAR2,
          p_price_list_id    NUMBER,
          p_bill_to_cust_account_id    NUMBER,
          p_bill_to_site_use_id    NUMBER,
          p_bill_to_PARTY_NAME    VARCHAR2,
          p_bill_to_PARTY_ID      NUMBER,
          p_bill_to_PARTY_site_id NUMBER,
          p_bill_to_location    VARCHAR2,
          p_bill_to_duns_number    VARCHAR2,
          p_bill_to_address    VARCHAR2,
          p_bill_to_city    VARCHAR2,
          p_bill_to_state    VARCHAR2,
          p_bill_to_postal_code    VARCHAR2,
          p_bill_to_country    VARCHAR2,
	  p_bill_to_contact_party_id   NUMBER,
          p_bill_to_contact_name    VARCHAR2,
	  p_bill_to_email           VARCHAR2,
          p_bill_to_phone              VARCHAR2,
          p_bill_to_fax                VARCHAR2,
          p_ship_to_cust_account_id    NUMBER,
          p_ship_to_site_use_id    NUMBER,
          p_ship_to_PARTY_NAME    VARCHAR2,
          p_ship_to_PARTY_ID      NUMBER,
          p_ship_to_PARTY_site_id NUMBER,
          p_ship_to_location    VARCHAR2,
          p_ship_to_duns_number    VARCHAR2,
          p_ship_to_address    VARCHAR2,
          p_ship_to_city    VARCHAR2,
          p_ship_to_state    VARCHAR2,
          p_ship_to_postal_code    VARCHAR2,
          p_ship_to_country    VARCHAR2,
	  p_ship_to_contact_party_id   NUMBER,
          p_ship_to_contact_name    VARCHAR2,
	  p_ship_to_email           VARCHAR2,
          p_ship_to_phone              VARCHAR2,
          p_ship_to_fax                VARCHAR2,
          p_sold_from_cust_account_id    NUMBER,
          p_ship_from_cust_account_id    NUMBER,
          p_header_attribute_category    VARCHAR2,
          p_header_attribute1    VARCHAR2,
          p_header_attribute2    VARCHAR2,
          p_header_attribute3    VARCHAR2,
          p_header_attribute4    VARCHAR2,
          p_header_attribute5    VARCHAR2,
          p_header_attribute6    VARCHAR2,
          p_header_attribute7    VARCHAR2,
          p_header_attribute8    VARCHAR2,
          p_header_attribute9    VARCHAR2,
          p_header_attribute10    VARCHAR2,
          p_header_attribute11    VARCHAR2,
          p_header_attribute12    VARCHAR2,
          p_header_attribute13    VARCHAR2,
          p_header_attribute14    VARCHAR2,
          p_header_attribute15    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RESALE_HEADERS_ALL
        WHERE RESALE_HEADER_ID =  p_RESALE_HEADER_ID
        FOR UPDATE of RESALE_HEADER_ID NOWAIT;
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
           (      Recinfo.resale_header_id = p_resale_header_id)
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
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.date_shipped = p_date_shipped)
            OR (    ( Recinfo.date_shipped IS NULL )
                AND (  p_date_shipped IS NULL )))
       AND (    ( Recinfo.date_ordered = p_date_ordered)
            OR (    ( Recinfo.date_ordered IS NULL )
                AND (  p_date_ordered IS NULL )))
       AND (    ( Recinfo.order_type_id = p_order_type_id)
            OR (    ( Recinfo.order_type_id IS NULL )
                AND (  p_order_type_id IS NULL )))
       AND (    ( Recinfo.order_type = p_order_type)
            OR (    ( Recinfo.order_type IS NULL )
                AND (  p_order_type IS NULL )))
       AND (    ( Recinfo.order_category = p_order_category)
            OR (    ( Recinfo.order_category IS NULL )
                AND (  p_order_category IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.direct_customer_flag = p_direct_customer_flag)
            OR (    ( Recinfo.direct_customer_flag IS NULL )
                AND (  p_direct_customer_flag IS NULL )))
       AND (    ( Recinfo.order_number = p_order_number)
            OR (    ( Recinfo.order_number IS NULL )
                AND (  p_order_number IS NULL )))
       AND (    ( Recinfo.price_list_id = p_price_list_id)
            OR (    ( Recinfo.price_list_id IS NULL )
                AND (  p_price_list_id IS NULL )))
       AND (    ( Recinfo.bill_to_cust_account_id = p_bill_to_cust_account_id)
            OR (    ( Recinfo.bill_to_cust_account_id IS NULL )
                AND (  p_bill_to_cust_account_id IS NULL )))
       AND (    ( Recinfo.bill_to_site_use_id = p_bill_to_site_use_id)
            OR (    ( Recinfo.bill_to_site_use_id IS NULL )
                AND (  p_bill_to_site_use_id IS NULL )))
       AND (    ( Recinfo.bill_to_PARTY_NAME = p_bill_to_PARTY_NAME)
            OR (    ( Recinfo.bill_to_PARTY_NAME IS NULL )
                AND (  p_bill_to_PARTY_NAME IS NULL )))
       AND (    ( Recinfo.bill_to_PARTY_ID = p_bill_to_PARTY_ID)
            OR (    ( Recinfo.bill_to_PARTY_ID IS NULL )
                AND (  p_bill_to_PARTY_ID IS NULL )))
       AND (    ( Recinfo.bill_to_PARTY_site_id = p_bill_to_PARTY_site_id)
            OR (    ( Recinfo.bill_to_PARTY_site_id IS NULL )
                AND (  p_bill_to_PARTY_site_id IS NULL )))
       AND (    ( Recinfo.bill_to_location = p_bill_to_location)
            OR (    ( Recinfo.bill_to_location IS NULL )
                AND (  p_bill_to_location IS NULL )))
       AND (    ( Recinfo.bill_to_duns_number = p_bill_to_duns_number)
            OR (    ( Recinfo.bill_to_duns_number IS NULL )
                AND (  p_bill_to_duns_number IS NULL )))
       AND (    ( Recinfo.bill_to_address = p_bill_to_address)
            OR (    ( Recinfo.bill_to_address IS NULL )
                AND (  p_bill_to_address IS NULL )))
       AND (    ( Recinfo.bill_to_city = p_bill_to_city)
            OR (    ( Recinfo.bill_to_city IS NULL )
                AND (  p_bill_to_city IS NULL )))
       AND (    ( Recinfo.bill_to_state = p_bill_to_state)
            OR (    ( Recinfo.bill_to_state IS NULL )
                AND (  p_bill_to_state IS NULL )))
       AND (    ( Recinfo.bill_to_postal_code = p_bill_to_postal_code)
            OR (    ( Recinfo.bill_to_postal_code IS NULL )
                AND (  p_bill_to_postal_code IS NULL )))
       AND (    ( Recinfo.bill_to_country = p_bill_to_country)
            OR (    ( Recinfo.bill_to_country IS NULL )
                AND (  p_bill_to_country IS NULL )))
       AND (    ( Recinfo.bill_to_contact_party_id = p_bill_to_contact_party_id)
            OR (    ( Recinfo.bill_to_contact_party_id IS NULL )
                AND (  p_bill_to_contact_party_id IS NULL )))
       AND (    ( Recinfo.bill_to_contact_name = p_bill_to_contact_name)
            OR (    ( Recinfo.bill_to_contact_name IS NULL )
                AND (  p_bill_to_contact_name IS NULL )))
       AND (    ( Recinfo.bill_to_email = p_bill_to_email)
            OR (    ( Recinfo.bill_to_email IS NULL )
                AND (  p_bill_to_email IS NULL )))
       AND (    ( Recinfo.bill_to_phone = p_bill_to_phone)
            OR (    ( Recinfo.bill_to_phone IS NULL )
                AND (  p_bill_to_phone IS NULL )))
       AND (    ( Recinfo.bill_to_fax = p_bill_to_fax)
            OR (    ( Recinfo.bill_to_fax IS NULL )
                AND (  p_bill_to_fax IS NULL )))
       AND (    ( Recinfo.ship_to_cust_account_id = p_ship_to_cust_account_id)
            OR (    ( Recinfo.ship_to_cust_account_id IS NULL )
                AND (  p_ship_to_cust_account_id IS NULL )))
       AND (    ( Recinfo.ship_to_site_use_id = p_ship_to_site_use_id)
            OR (    ( Recinfo.ship_to_site_use_id IS NULL )
                AND (  p_ship_to_site_use_id IS NULL )))
       AND (    ( Recinfo.ship_to_PARTY_NAME = p_ship_to_PARTY_NAME)
            OR (    ( Recinfo.ship_to_PARTY_NAME IS NULL )
                AND (  p_ship_to_PARTY_NAME IS NULL )))
       AND (    ( Recinfo.ship_to_PARTY_ID = p_ship_to_PARTY_ID)
            OR (    ( Recinfo.ship_to_PARTY_ID IS NULL )
                AND (  p_ship_to_PARTY_ID IS NULL )))
       AND (    ( Recinfo.ship_to_PARTY_site_id = p_ship_to_PARTY_site_id)
            OR (    ( Recinfo.ship_to_PARTY_site_id IS NULL )
                AND (  p_ship_to_PARTY_site_id IS NULL )))
       AND (    ( Recinfo.ship_to_location = p_ship_to_location)
            OR (    ( Recinfo.ship_to_location IS NULL )
                AND (  p_ship_to_location IS NULL )))
       AND (    ( Recinfo.ship_to_duns_number = p_ship_to_duns_number)
            OR (    ( Recinfo.ship_to_duns_number IS NULL )
                AND (  p_ship_to_duns_number IS NULL )))
       AND (    ( Recinfo.ship_to_address = p_ship_to_address)
            OR (    ( Recinfo.ship_to_address IS NULL )
                AND (  p_ship_to_address IS NULL )))
       AND (    ( Recinfo.ship_to_city = p_ship_to_city)
            OR (    ( Recinfo.ship_to_city IS NULL )
                AND (  p_ship_to_city IS NULL )))
       AND (    ( Recinfo.ship_to_state = p_ship_to_state)
            OR (    ( Recinfo.ship_to_state IS NULL )
                AND (  p_ship_to_state IS NULL )))
       AND (    ( Recinfo.ship_to_postal_code = p_ship_to_postal_code)
            OR (    ( Recinfo.ship_to_postal_code IS NULL )
                AND (  p_ship_to_postal_code IS NULL )))
       AND (    ( Recinfo.ship_to_country = p_ship_to_country)
            OR (    ( Recinfo.ship_to_country IS NULL )
                AND (  p_ship_to_country IS NULL )))
       AND (    ( Recinfo.ship_to_contact_party_id = p_ship_to_contact_party_id)
            OR (    ( Recinfo.ship_to_contact_party_id IS NULL )
                AND (  p_ship_to_contact_party_id IS NULL )))
       AND (    ( Recinfo.ship_to_contact_name = p_ship_to_contact_name)
            OR (    ( Recinfo.ship_to_contact_name IS NULL )
                AND (  p_ship_to_contact_name IS NULL )))
       AND (    ( Recinfo.ship_to_email = p_ship_to_email)
            OR (    ( Recinfo.ship_to_email IS NULL )
                AND (  p_ship_to_email IS NULL )))
       AND (    ( Recinfo.ship_to_phone = p_ship_to_phone)
            OR (    ( Recinfo.ship_to_phone IS NULL )
                AND (  p_ship_to_phone IS NULL )))
       AND (    ( Recinfo.ship_to_fax = p_ship_to_fax)
            OR (    ( Recinfo.ship_to_fax IS NULL )
                AND (  p_ship_to_fax IS NULL )))
       AND (    ( Recinfo.sold_from_cust_account_id = p_sold_from_cust_account_id)
            OR (    ( Recinfo.sold_from_cust_account_id IS NULL )
                AND (  p_sold_from_cust_account_id IS NULL )))
       AND (    ( Recinfo.ship_from_cust_account_id = p_ship_from_cust_account_id)
            OR (    ( Recinfo.ship_from_cust_account_id IS NULL )
                AND (  p_ship_from_cust_account_id IS NULL )))
       AND (    ( Recinfo.header_attribute_category = p_header_attribute_category)
            OR (    ( Recinfo.header_attribute_category IS NULL )
                AND (  p_header_attribute_category IS NULL )))
       AND (    ( Recinfo.header_attribute1 = p_header_attribute1)
            OR (    ( Recinfo.header_attribute1 IS NULL )
                AND (  p_header_attribute1 IS NULL )))
       AND (    ( Recinfo.header_attribute2 = p_header_attribute2)
            OR (    ( Recinfo.header_attribute2 IS NULL )
                AND (  p_header_attribute2 IS NULL )))
       AND (    ( Recinfo.header_attribute3 = p_header_attribute3)
            OR (    ( Recinfo.header_attribute3 IS NULL )
                AND (  p_header_attribute3 IS NULL )))
       AND (    ( Recinfo.header_attribute4 = p_header_attribute4)
            OR (    ( Recinfo.header_attribute4 IS NULL )
                AND (  p_header_attribute4 IS NULL )))
       AND (    ( Recinfo.header_attribute5 = p_header_attribute5)
            OR (    ( Recinfo.header_attribute5 IS NULL )
                AND (  p_header_attribute5 IS NULL )))
       AND (    ( Recinfo.header_attribute6 = p_header_attribute6)
            OR (    ( Recinfo.header_attribute6 IS NULL )
                AND (  p_header_attribute6 IS NULL )))
       AND (    ( Recinfo.header_attribute7 = p_header_attribute7)
            OR (    ( Recinfo.header_attribute7 IS NULL )
                AND (  p_header_attribute7 IS NULL )))
       AND (    ( Recinfo.header_attribute8 = p_header_attribute8)
            OR (    ( Recinfo.header_attribute8 IS NULL )
                AND (  p_header_attribute8 IS NULL )))
       AND (    ( Recinfo.header_attribute9 = p_header_attribute9)
            OR (    ( Recinfo.header_attribute9 IS NULL )
                AND (  p_header_attribute9 IS NULL )))
       AND (    ( Recinfo.header_attribute10 = p_header_attribute10)
            OR (    ( Recinfo.header_attribute10 IS NULL )
                AND (  p_header_attribute10 IS NULL )))
       AND (    ( Recinfo.header_attribute11 = p_header_attribute11)
            OR (    ( Recinfo.header_attribute11 IS NULL )
                AND (  p_header_attribute11 IS NULL )))
       AND (    ( Recinfo.header_attribute12 = p_header_attribute12)
            OR (    ( Recinfo.header_attribute12 IS NULL )
                AND (  p_header_attribute12 IS NULL )))
       AND (    ( Recinfo.header_attribute13 = p_header_attribute13)
            OR (    ( Recinfo.header_attribute13 IS NULL )
                AND (  p_header_attribute13 IS NULL )))
       AND (    ( Recinfo.header_attribute14 = p_header_attribute14)
            OR (    ( Recinfo.header_attribute14 IS NULL )
                AND (  p_header_attribute14 IS NULL )))
       AND (    ( Recinfo.header_attribute15 = p_header_attribute15)
            OR (    ( Recinfo.header_attribute15 IS NULL )
                AND (  p_header_attribute15 IS NULL )))
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

END OZF_RESALE_HEADERS_PKG;

/
