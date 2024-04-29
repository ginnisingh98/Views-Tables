--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_SYSTEMS_PKG" AS
/* $Header: csittsyb.pls 115.2 2002/11/12 00:26:21 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_T_TXN_SYSTEMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_T_TXN_SYSTEMS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csittsyb.pls';

PROCEDURE Insert_Row(
          px_transaction_system_id   IN OUT NOCOPY NUMBER,
          p_transaction_line_id             NUMBER,
          p_system_name                     VARCHAR2,
          p_description                     VARCHAR2,
          p_system_type_code                VARCHAR2,
          p_system_number                   VARCHAR2,
          p_customer_id                     NUMBER,
          p_bill_to_contact_id              NUMBER,
          p_ship_to_contact_id              NUMBER,
          p_technical_contact_id            NUMBER,
          p_service_admin_contact_id        NUMBER,
          p_ship_to_site_use_id             NUMBER,
          p_bill_to_site_use_id             NUMBER,
          p_install_site_use_id             NUMBER,
          p_coterminate_day_month           VARCHAR2,
          p_config_system_type              VARCHAR2,
          p_start_date_active               DATE    ,
          p_end_date_active                 DATE    ,
          p_context                         VARCHAR2,
          p_attribute1                      VARCHAR2,
          p_attribute2                      VARCHAR2,
          p_attribute3                      VARCHAR2,
          p_attribute4                      VARCHAR2,
          p_attribute5                      VARCHAR2,
          p_attribute6                      VARCHAR2,
          p_attribute7                      VARCHAR2,
          p_attribute8                      VARCHAR2,
          p_attribute9                      VARCHAR2,
          p_attribute10                     VARCHAR2,
          p_attribute11                     VARCHAR2,
          p_attribute12                     VARCHAR2,
          p_attribute13                     VARCHAR2,
          p_attribute14                     VARCHAR2,
          p_attribute15                     VARCHAR2,
          p_created_by                      NUMBER,
          p_creation_date                   DATE,
          p_last_updated_by                 NUMBER,
          p_last_update_date                DATE,
          p_last_update_login               NUMBER,
          p_object_version_number           NUMBER)

 IS
   CURSOR c2 IS SELECT csi_t_txn_systems_s.nextval FROM sys.dual;
BEGIN
   IF (px_transaction_system_id IS NULL) OR (px_transaction_system_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 INTO px_transaction_system_id;
       CLOSE c2;
   END IF;
   INSERT INTO csi_t_txn_systems(
           transaction_system_id,
           transaction_line_id,
           system_name,
           description,
           system_type_code,
           system_number,
           customer_id,
           bill_to_contact_id,
           ship_to_contact_id,
           technical_contact_id,
           service_admin_contact_id,
           ship_to_site_use_id,
           bill_to_site_use_id,
           install_site_use_id,
           coterminate_day_month,
           config_system_type,
           start_date_active ,
           end_date_active ,
           context,
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
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
          ) VALUES (
           px_transaction_system_id,
           DECODE( p_transaction_line_id, fnd_api.g_miss_num, NULL, p_transaction_line_id),
           DECODE( p_system_name, fnd_api.g_miss_char, NULL, p_system_name),
           DECODE( p_description, fnd_api.g_miss_char, NULL, p_description),
           DECODE( p_system_type_code, fnd_api.g_miss_char, NULL, p_system_type_code),
           DECODE( p_system_number, fnd_api.g_miss_char, NULL, p_system_number),
           DECODE( p_customer_id, fnd_api.g_miss_num, NULL, p_customer_id),
           DECODE( p_bill_to_contact_id, fnd_api.g_miss_num, NULL, p_bill_to_contact_id),
           DECODE( p_ship_to_contact_id, fnd_api.g_miss_num, NULL, p_ship_to_contact_id),
           DECODE( p_technical_contact_id, fnd_api.g_miss_num, NULL, p_technical_contact_id),
           DECODE( p_service_admin_contact_id, fnd_api.g_miss_num, NULL, p_service_admin_contact_id),
           DECODE( p_ship_to_site_use_id, fnd_api.g_miss_num, NULL, p_ship_to_site_use_id),
           DECODE( p_bill_to_site_use_id, fnd_api.g_miss_num, NULL, p_bill_to_site_use_id),
           DECODE( p_install_site_use_id, fnd_api.g_miss_num, NULL, p_install_site_use_id),
           DECODE( p_coterminate_day_month, fnd_api.g_miss_char, NULL, p_coterminate_day_month),
           DECODE( p_config_system_type, fnd_api.g_miss_char, NULL, p_config_system_type),
           DECODE( p_start_date_active, fnd_api.g_miss_date, NULL, p_start_date_active),
           DECODE( p_end_date_active, fnd_api.g_miss_date, NULL, p_end_date_active),
           DECODE( p_context, fnd_api.g_miss_char, NULL, p_context),
           DECODE( p_attribute1, fnd_api.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, fnd_api.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, fnd_api.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, fnd_api.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, fnd_api.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, fnd_api.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, fnd_api.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, fnd_api.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, fnd_api.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, fnd_api.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, fnd_api.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, fnd_api.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, fnd_api.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, fnd_api.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, fnd_api.g_miss_char, NULL, p_attribute15),
           DECODE( p_created_by, fnd_api.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login),
           DECODE( p_object_version_number, fnd_api.g_miss_num, NULL, p_object_version_number));
END insert_row;

PROCEDURE Update_Row(
          p_transaction_system_id       NUMBER,
          p_transaction_line_id         NUMBER,
          p_system_name                 VARCHAR2,
          p_description                 VARCHAR2,
          p_system_type_code            VARCHAR2,
          p_system_number               VARCHAR2,
          p_customer_id                 NUMBER,
          p_bill_to_contact_id          NUMBER,
          p_ship_to_contact_id          NUMBER,
          p_technical_contact_id        NUMBER,
          p_service_admin_contact_id    NUMBER,
          p_ship_to_site_use_id         NUMBER,
          p_bill_to_site_use_id         NUMBER,
          p_install_site_use_id         NUMBER,
          p_coterminate_day_month       VARCHAR2,
          p_config_system_type          VARCHAR2,
          p_start_date_active           DATE    ,
          p_end_date_active             DATE    ,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER)

 IS
 BEGIN
    UPDATE csi_t_txn_systems
    SET
              transaction_line_id = DECODE( p_transaction_line_id, fnd_api.g_miss_num, transaction_line_id, p_transaction_line_id),
              system_name = DECODE( p_system_name, fnd_api.g_miss_char, system_name, p_system_name),
              description = DECODE( p_description, fnd_api.g_miss_char, description, p_description),
              system_type_code = DECODE( p_system_type_code, fnd_api.g_miss_char, system_type_code, p_system_type_code),
              system_number = DECODE( p_system_number, fnd_api.g_miss_char, system_number, p_system_number),
              customer_id = DECODE( p_customer_id, fnd_api.g_miss_num, customer_id, p_customer_id),
              bill_to_contact_id = DECODE( p_bill_to_contact_id, fnd_api.g_miss_num, bill_to_contact_id, p_bill_to_contact_id),
              ship_to_contact_id = DECODE( p_ship_to_contact_id, fnd_api.g_miss_num, ship_to_contact_id, p_ship_to_contact_id),
              technical_contact_id = DECODE( p_technical_contact_id, fnd_api.g_miss_num, technical_contact_id, p_technical_contact_id),
              service_admin_contact_id = DECODE( p_service_admin_contact_id, fnd_api.g_miss_num, service_admin_contact_id, p_service_admin_contact_id),
              ship_to_site_use_id = DECODE( p_ship_to_site_use_id, fnd_api.g_miss_num, ship_to_site_use_id, p_ship_to_site_use_id),
              bill_to_site_use_id = DECODE( p_bill_to_site_use_id, fnd_api.g_miss_num, bill_to_site_use_id, p_bill_to_site_use_id),
              install_site_use_id = DECODE( p_install_site_use_id, fnd_api.g_miss_num, install_site_use_id, p_install_site_use_id),
              coterminate_day_month = DECODE( p_coterminate_day_month, fnd_api.g_miss_char, coterminate_day_month, p_coterminate_day_month),
              config_system_type = DECODE( p_config_system_type, fnd_api.g_miss_char, config_system_type, p_config_system_type),
              start_date_active = DECODE( p_start_date_active, fnd_api.g_miss_date, start_date_active, p_start_date_active),
              end_date_active = DECODE( p_end_date_active, fnd_api.g_miss_date, end_date_active, p_end_date_active),
              context = DECODE( p_context, fnd_api.g_miss_char, context, p_context),
              attribute1 = DECODE( p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1),
              attribute2 = DECODE( p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2),
              attribute3 = DECODE( p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3),
              attribute4 = DECODE( p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4),
              attribute5 = DECODE( p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5),
              attribute6 = DECODE( p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6),
              attribute7 = DECODE( p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7),
              attribute8 = DECODE( p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8),
              attribute9 = DECODE( p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9),
              attribute10 = DECODE( p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10),
              attribute11 = DECODE( p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11),
              attribute12 = DECODE( p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12),
              attribute13 = DECODE( p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13),
              attribute14 = DECODE( p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14),
              attribute15 = DECODE( p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15),
              created_by = DECODE( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
              creation_date = DECODE( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
              last_updated_by = DECODE( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = object_version_number+1
    WHERE transaction_system_id = p_transaction_system_id;

    IF (SQL%NOTFOUND) THEN
        RAISE no_data_found;
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_TRANSACTION_SYSTEM_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM csi_t_txn_systems
    WHERE transaction_system_id = p_transaction_system_id;
   IF (SQL%NOTFOUND) THEN
       RAISE no_data_found;
   END IF;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_transaction_system_id       NUMBER,
          p_transaction_line_id         NUMBER,
          p_system_name                 VARCHAR2,
          p_description                 VARCHAR2,
          p_system_type_code            VARCHAR2,
          p_system_number               VARCHAR2,
          p_customer_id                 NUMBER,
          p_bill_to_contact_id          NUMBER,
          p_ship_to_contact_id          NUMBER,
          p_technical_contact_id        NUMBER,
          p_service_admin_contact_id    NUMBER,
          p_ship_to_site_use_id         NUMBER,
          p_bill_to_site_use_id         NUMBER,
          p_install_site_use_id         NUMBER,
          p_coterminate_day_month       VARCHAR2,
          p_config_system_type          VARCHAR2,
          p_start_date_active           DATE    ,
          p_end_date_active             DATE    ,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER)

 IS
   CURSOR c IS
        SELECT *
        FROM   csi_t_txn_systems
        WHERE  transaction_system_id =  p_transaction_system_id
        FOR UPDATE of transaction_system_id NOWAIT;
   recinfo c%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO recinfo;
    IF (c%notfound) THEN
        CLOSE c;
        fnd_message.set_name('fnd', 'form_record_deleted');
        app_exception.raise_exception;
    END IF;
    CLOSE c;
    IF (
           (      recinfo.transaction_system_id = p_transaction_system_id)
       AND (    ( recinfo.transaction_line_id = p_transaction_line_id)
            OR (    ( recinfo.transaction_line_id IS NULL )
                AND (  p_transaction_line_id IS NULL )))
       AND (    ( recinfo.system_name = p_system_name)
            OR (    ( recinfo.system_name IS NULL )
                AND (  p_system_name IS NULL )))
       AND (    ( recinfo.description = p_description)
            OR (    ( recinfo.description IS NULL )
                AND (  p_description IS NULL )))
       AND (    ( recinfo.system_type_code = p_system_type_code)
            OR (    ( recinfo.system_type_code IS NULL )
                AND (  p_system_type_code IS NULL )))
       AND (    ( recinfo.system_number = p_system_number)
            OR (    ( recinfo.system_number IS NULL )
                AND (  p_system_number IS NULL )))
       AND (    ( recinfo.customer_id = p_customer_id)
            OR (    ( recinfo.customer_id IS NULL )
                AND (  p_customer_id IS NULL )))
       AND (    ( recinfo.bill_to_contact_id = p_bill_to_contact_id)
            OR (    ( recinfo.bill_to_contact_id IS NULL )
                AND (  p_bill_to_contact_id IS NULL )))
       AND (    ( recinfo.ship_to_contact_id = p_ship_to_contact_id)
            OR (    ( recinfo.ship_to_contact_id IS NULL )
                AND (  p_ship_to_contact_id IS NULL )))
       AND (    ( recinfo.technical_contact_id = p_technical_contact_id)
            OR (    ( recinfo.technical_contact_id IS NULL )
                AND (  p_technical_contact_id IS NULL )))
       AND (    ( recinfo.service_admin_contact_id = p_service_admin_contact_id)
            OR (    ( recinfo.service_admin_contact_id IS NULL )
                AND (  p_service_admin_contact_id IS NULL )))
       AND (    ( recinfo.ship_to_site_use_id = p_ship_to_site_use_id)
            OR (    ( recinfo.ship_to_site_use_id IS NULL )
                AND (  p_ship_to_site_use_id IS NULL )))
       AND (    ( recinfo.bill_to_site_use_id = p_bill_to_site_use_id)
            OR (    ( recinfo.bill_to_site_use_id IS NULL )
                AND (  p_bill_to_site_use_id IS NULL )))
       AND (    ( recinfo.install_site_use_id = p_install_site_use_id)
            OR (    ( recinfo.install_site_use_id IS NULL )
                AND (  p_install_site_use_id IS NULL )))
       AND (    ( recinfo.coterminate_day_month = p_coterminate_day_month)
            OR (    ( recinfo.coterminate_day_month IS NULL )
                AND (  p_coterminate_day_month IS NULL )))
       AND (    ( recinfo.config_system_type = p_config_system_type)
            OR (    ( recinfo.config_system_type IS NULL )
                AND (  p_config_system_type IS NULL )))
       AND (    ( recinfo.context = p_context)
            OR (    ( recinfo.context IS NULL )
                AND (  p_context IS NULL )))
       AND (    ( recinfo.attribute1 = p_attribute1)
            OR (    ( recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( recinfo.attribute2 = p_attribute2)
            OR (    ( recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( recinfo.attribute3 = p_attribute3)
            OR (    ( recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( recinfo.attribute4 = p_attribute4)
            OR (    ( recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( recinfo.attribute5 = p_attribute5)
            OR (    ( recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( recinfo.attribute6 = p_attribute6)
            OR (    ( recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( recinfo.attribute7 = p_attribute7)
            OR (    ( recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( recinfo.attribute8 = p_attribute8)
            OR (    ( recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( recinfo.attribute9 = p_attribute9)
            OR (    ( recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( recinfo.attribute10 = p_attribute10)
            OR (    ( recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( recinfo.attribute11 = p_attribute11)
            OR (    ( recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( recinfo.attribute12 = p_attribute12)
            OR (    ( recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( recinfo.attribute13 = p_attribute13)
            OR (    ( recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( recinfo.attribute14 = p_attribute14)
            OR (    ( recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( recinfo.attribute15 = p_attribute15)
            OR (    ( recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( recinfo.created_by = p_created_by)
            OR (    ( recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( recinfo.creation_date = p_creation_date)
            OR (    ( recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( recinfo.last_updated_by = p_last_updated_by)
            OR (    ( recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( recinfo.last_update_date = p_last_update_date)
            OR (    ( recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( recinfo.last_update_login = p_last_update_login)
            OR (    ( recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( recinfo.object_version_number = p_object_version_number)
            OR (    ( recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       fnd_message.set_name('fnd', 'form_record_changed');
       app_exception.raise_exception;
   END IF;
END Lock_Row;

END CSI_T_TXN_SYSTEMS_PKG;

/
