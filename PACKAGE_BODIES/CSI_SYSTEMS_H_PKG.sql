--------------------------------------------------------
--  DDL for Package Body CSI_SYSTEMS_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_SYSTEMS_H_PKG" AS
/* $Header: csitsyhb.pls 115.13 2003/09/04 00:22:54 sguthiva ship $ */
-- start of comments
-- package name     : csi_systems_h_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments


g_pkg_name CONSTANT VARCHAR2(30):= 'csi_systems_h_pkg';
g_file_name CONSTANT VARCHAR2(12) := 'csitsyhb.pls';

PROCEDURE insert_row(
          px_system_history_id      IN OUT NOCOPY  NUMBER,
          p_system_id                       NUMBER,
          p_transaction_id                  NUMBER,
          p_old_customer_id                 NUMBER,
          p_new_customer_id                 NUMBER,
          p_old_system_type_code            VARCHAR2,
          p_new_system_type_code            VARCHAR2,
          p_old_system_number               VARCHAR2,
          p_new_system_number               VARCHAR2,
          p_old_parent_system_id            NUMBER,
          p_new_parent_system_id            NUMBER,
          p_old_ship_to_contact_id          NUMBER,
          p_new_ship_to_contact_id          NUMBER,
          p_old_bill_to_contact_id          NUMBER,
          p_new_bill_to_contact_id          NUMBER,
          p_old_technical_contact_id        NUMBER,
          p_new_technical_contact_id        NUMBER,
          p_old_service_admin_contact_id    NUMBER,
          p_new_service_admin_contact_id    NUMBER,
          p_old_ship_to_site_use_id         NUMBER,
          p_new_ship_to_site_use_id         NUMBER,
          p_old_install_site_use_id         NUMBER,
          p_new_install_site_use_id         NUMBER,
          p_old_bill_to_site_use_id         NUMBER,
          p_new_bill_to_site_use_id         NUMBER,
          p_old_coterminate_day_month       VARCHAR2,
          p_new_coterminate_day_month       VARCHAR2,
          p_old_start_date_active           DATE,
          p_new_start_date_active           DATE,
          p_old_end_date_active             DATE,
          p_new_end_date_active             DATE,
          p_old_autocreated_from_system     NUMBER,
          p_new_autocreated_from_system     NUMBER,
          p_old_config_system_type          VARCHAR2,
          p_new_config_system_type          VARCHAR2,
          p_old_context                     VARCHAR2,
          p_new_context                     VARCHAR2,
          p_old_attribute1                  VARCHAR2,
          p_new_attribute1                  VARCHAR2,
          p_old_attribute2                  VARCHAR2,
          p_new_attribute2                  VARCHAR2,
          p_old_attribute3                  VARCHAR2,
          p_new_attribute3                  VARCHAR2,
          p_old_attribute4                  VARCHAR2,
          p_new_attribute4                  VARCHAR2,
          p_old_attribute5                  VARCHAR2,
          p_new_attribute5                  VARCHAR2,
          p_old_attribute6                  VARCHAR2,
          p_new_attribute6                  VARCHAR2,
          p_old_attribute7                  VARCHAR2,
          p_new_attribute7                  VARCHAR2,
          p_old_attribute8                  VARCHAR2,
          p_new_attribute8                  VARCHAR2,
          p_old_attribute9                  VARCHAR2,
          p_new_attribute9                  VARCHAR2,
          p_old_attribute10                 VARCHAR2,
          p_new_attribute10                 VARCHAR2,
          p_old_attribute11                 VARCHAR2,
          p_new_attribute11                 VARCHAR2,
          p_old_attribute12                 VARCHAR2,
          p_new_attribute12                 VARCHAR2,
          p_old_attribute13                 VARCHAR2,
          p_new_attribute13                 VARCHAR2,
          p_old_attribute14                 VARCHAR2,
          p_new_attribute14                 VARCHAR2,
          p_old_attribute15                 VARCHAR2,
          p_new_attribute15                 VARCHAR2,
          p_full_dump_flag                  VARCHAR2,
          p_created_by                      NUMBER,
          p_creation_date                   DATE,
          p_last_updated_by                 NUMBER,
          p_last_update_date                DATE,
          p_last_update_login               NUMBER,
          p_object_version_number           NUMBER,
          p_old_name                        VARCHAR2,
          p_new_name                        VARCHAR2,
          p_old_description                 VARCHAR2,
          p_new_description                 VARCHAR2,
		p_old_operating_unit_id           NUMBER,
		p_new_operating_unit_id           NUMBER)

 IS
   CURSOR c2 IS SELECT csi_systems_h_s.NEXTVAL FROM sys.dual;
BEGIN
   IF (px_system_history_id IS NULL) OR (px_system_history_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 INTO px_system_history_id;
       CLOSE c2;
   END IF;
   INSERT INTO csi_systems_h(
           system_history_id,
           system_id,
           transaction_id,
           old_customer_id,
           new_customer_id,
           old_system_type_code,
           new_system_type_code,
           old_system_number,
           new_system_number,
           old_parent_system_id,
           new_parent_system_id,
           old_ship_to_contact_id,
           new_ship_to_contact_id,
           old_bill_to_contact_id,
           new_bill_to_contact_id,
           old_technical_contact_id,
           new_technical_contact_id,
           old_service_admin_contact_id,
           new_service_admin_contact_id,
           old_ship_to_site_use_id,
           new_ship_to_site_use_id,
           old_install_site_use_id,
           new_install_site_use_id,
           old_bill_to_site_use_id,
           new_bill_to_site_use_id,
           old_coterminate_day_month,
           new_coterminate_day_month,
           old_start_date_active,
           new_start_date_active,
           old_end_date_active,
           new_end_date_active,
           old_autocreated_from_system,
           new_autocreated_from_system,
           old_config_system_type,
           new_config_system_type,
           old_context,
           new_context,
           old_attribute1,
           new_attribute1,
           old_attribute2,
           new_attribute2,
           old_attribute3,
           new_attribute3,
           old_attribute4,
           new_attribute4,
           old_attribute5,
           new_attribute5,
           old_attribute6,
           new_attribute6,
           old_attribute7,
           new_attribute7,
           old_attribute8,
           new_attribute8,
           old_attribute9,
           new_attribute9,
           old_attribute10,
           new_attribute10,
           old_attribute11,
           new_attribute11,
           old_attribute12,
           new_attribute12,
           old_attribute13,
           new_attribute13,
           old_attribute14,
           new_attribute14,
           old_attribute15,
           new_attribute15,
           full_dump_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           old_name,
           new_name,
           old_description,
           new_description,
		 old_operating_unit_id,
		 new_operating_unit_id
          ) VALUES (
           px_system_history_id,
           DECODE( p_system_id, fnd_api.g_miss_num, NULL, p_system_id),
           DECODE( p_transaction_id, fnd_api.g_miss_num, NULL, p_transaction_id),
           DECODE( p_old_customer_id, fnd_api.g_miss_num, NULL, p_old_customer_id),
           DECODE( p_new_customer_id, fnd_api.g_miss_num, NULL, p_new_customer_id),
           DECODE( p_old_system_type_code, fnd_api.g_miss_char, NULL, p_old_system_type_code),
           DECODE( p_new_system_type_code, fnd_api.g_miss_char, NULL, p_new_system_type_code),
           DECODE( p_old_system_number, fnd_api.g_miss_char, NULL, p_old_system_number),
           DECODE( p_new_system_number, fnd_api.g_miss_char, NULL, p_new_system_number),
           DECODE( p_old_parent_system_id, fnd_api.g_miss_num, NULL, p_old_parent_system_id),
           DECODE( p_new_parent_system_id, fnd_api.g_miss_num, NULL, p_new_parent_system_id),
           DECODE( p_old_ship_to_contact_id, fnd_api.g_miss_num, NULL, p_old_ship_to_contact_id),
           DECODE( p_new_ship_to_contact_id, fnd_api.g_miss_num, NULL, p_new_ship_to_contact_id),
           DECODE( p_old_bill_to_contact_id, fnd_api.g_miss_num, NULL, p_old_bill_to_contact_id),
           DECODE( p_new_bill_to_contact_id, fnd_api.g_miss_num, NULL, p_new_bill_to_contact_id),
           DECODE( p_old_technical_contact_id, fnd_api.g_miss_num, NULL, p_old_technical_contact_id),
           DECODE( p_new_technical_contact_id, fnd_api.g_miss_num, NULL, p_new_technical_contact_id),
           DECODE( p_old_service_admin_contact_id, fnd_api.g_miss_num, NULL, p_old_service_admin_contact_id),
           DECODE( p_new_service_admin_contact_id, fnd_api.g_miss_num, NULL, p_new_service_admin_contact_id),
           DECODE( p_old_ship_to_site_use_id, fnd_api.g_miss_num, NULL, p_old_ship_to_site_use_id),
           DECODE( p_new_ship_to_site_use_id, fnd_api.g_miss_num, NULL, p_new_ship_to_site_use_id),
           DECODE( p_old_install_site_use_id, fnd_api.g_miss_num, NULL, p_old_install_site_use_id),
           DECODE( p_new_install_site_use_id, fnd_api.g_miss_num, NULL, p_new_install_site_use_id),
           DECODE( p_old_bill_to_site_use_id, fnd_api.g_miss_num, NULL, p_old_bill_to_site_use_id),
           DECODE( p_new_bill_to_site_use_id, fnd_api.g_miss_num, NULL, p_new_bill_to_site_use_id),
           DECODE( p_old_coterminate_day_month, fnd_api.g_miss_char, NULL, p_old_coterminate_day_month),
           DECODE( p_new_coterminate_day_month, fnd_api.g_miss_char, NULL, p_new_coterminate_day_month),
           DECODE( p_old_start_date_active, fnd_api.g_miss_date, to_date(NULL), p_old_start_date_active),
           DECODE( p_new_start_date_active, fnd_api.g_miss_date, to_date(NULL), p_new_start_date_active),
           DECODE( p_old_end_date_active, fnd_api.g_miss_date, to_date(NULL), p_old_end_date_active),
           DECODE( p_new_end_date_active, fnd_api.g_miss_date, to_date(NULL), p_new_end_date_active),
           DECODE( p_old_autocreated_from_system,  fnd_api.g_miss_num, NULL, p_old_autocreated_from_system),
           DECODE( p_new_autocreated_from_system,  fnd_api.g_miss_num, NULL, p_new_autocreated_from_system),
           DECODE( p_old_config_system_type, fnd_api.g_miss_char, NULL, p_old_config_system_type),
           DECODE( p_new_config_system_type, fnd_api.g_miss_char, NULL, p_new_config_system_type),
           DECODE( p_old_context, fnd_api.g_miss_char, NULL, p_old_context),
           DECODE( p_new_context, fnd_api.g_miss_char, NULL, p_new_context),
           DECODE( p_old_attribute1, fnd_api.g_miss_char, NULL, p_old_attribute1),
           DECODE( p_new_attribute1, fnd_api.g_miss_char, NULL, p_new_attribute1),
           DECODE( p_old_attribute2, fnd_api.g_miss_char, NULL, p_old_attribute2),
           DECODE( p_new_attribute2, fnd_api.g_miss_char, NULL, p_new_attribute2),
           DECODE( p_old_attribute3, fnd_api.g_miss_char, NULL, p_old_attribute3),
           DECODE( p_new_attribute3, fnd_api.g_miss_char, NULL, p_new_attribute3),
           DECODE( p_old_attribute4, fnd_api.g_miss_char, NULL, p_old_attribute4),
           DECODE( p_new_attribute4, fnd_api.g_miss_char, NULL, p_new_attribute4),
           DECODE( p_old_attribute5, fnd_api.g_miss_char, NULL, p_old_attribute5),
           DECODE( p_new_attribute5, fnd_api.g_miss_char, NULL, p_new_attribute5),
           DECODE( p_old_attribute6, fnd_api.g_miss_char, NULL, p_old_attribute6),
           DECODE( p_new_attribute6, fnd_api.g_miss_char, NULL, p_new_attribute6),
           DECODE( p_old_attribute7, fnd_api.g_miss_char, NULL, p_old_attribute7),
           DECODE( p_new_attribute7, fnd_api.g_miss_char, NULL, p_new_attribute7),
           DECODE( p_old_attribute8, fnd_api.g_miss_char, NULL, p_old_attribute8),
           DECODE( p_new_attribute8, fnd_api.g_miss_char, NULL, p_new_attribute8),
           DECODE( p_old_attribute9, fnd_api.g_miss_char, NULL, p_old_attribute9),
           DECODE( p_new_attribute9, fnd_api.g_miss_char, NULL, p_new_attribute9),
           DECODE( p_old_attribute10, fnd_api.g_miss_char, NULL, p_old_attribute10),
           DECODE( p_new_attribute10, fnd_api.g_miss_char, NULL, p_new_attribute10),
           DECODE( p_old_attribute11, fnd_api.g_miss_char, NULL, p_old_attribute11),
           DECODE( p_new_attribute11, fnd_api.g_miss_char, NULL, p_new_attribute11),
           DECODE( p_old_attribute12, fnd_api.g_miss_char, NULL, p_old_attribute12),
           DECODE( p_new_attribute12, fnd_api.g_miss_char, NULL, p_new_attribute12),
           DECODE( p_old_attribute13, fnd_api.g_miss_char, NULL, p_old_attribute13),
           DECODE( p_new_attribute13, fnd_api.g_miss_char, NULL, p_new_attribute13),
           DECODE( p_old_attribute14, fnd_api.g_miss_char, NULL, p_old_attribute14),
           DECODE( p_new_attribute14, fnd_api.g_miss_char, NULL, p_new_attribute14),
           DECODE( p_old_attribute15, fnd_api.g_miss_char, NULL, p_old_attribute15),
           DECODE( p_new_attribute15, fnd_api.g_miss_char, NULL, p_new_attribute15),
           DECODE( p_full_dump_flag, fnd_api.g_miss_char, NULL, p_full_dump_flag),
           DECODE( p_created_by, fnd_api.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login),
           DECODE( p_object_version_number, fnd_api.g_miss_num, NULL, p_object_version_number),
           DECODE( p_old_name, fnd_api.g_miss_char, NULL, p_old_name),
           DECODE( p_new_name, fnd_api.g_miss_char, NULL, p_new_name),
           DECODE( p_old_description, fnd_api.g_miss_char, NULL, p_old_description),
           DECODE( p_new_description, fnd_api.g_miss_char, NULL, p_new_description),
           DECODE( p_old_operating_unit_id, fnd_api.g_miss_num, NULL, p_old_operating_unit_id),
           DECODE( p_new_operating_unit_id, fnd_api.g_miss_num, NULL, p_new_operating_unit_id)
           );
END insert_row;

PROCEDURE Update_Row(
          p_system_history_id               NUMBER  ,
          p_system_id                       NUMBER  ,
          p_transaction_id                  NUMBER  ,
          p_old_customer_id                 NUMBER  ,
          p_new_customer_id                 NUMBER  ,
          p_old_system_type_code            VARCHAR2,
          p_new_system_type_code            VARCHAR2,
          p_old_system_number               VARCHAR2,
          p_new_system_number               VARCHAR2,
          p_old_parent_system_id            NUMBER  ,
          p_new_parent_system_id            NUMBER  ,
          p_old_ship_to_contact_id          NUMBER  ,
          p_new_ship_to_contact_id          NUMBER  ,
          p_old_bill_to_contact_id          NUMBER  ,
          p_new_bill_to_contact_id          NUMBER  ,
          p_old_technical_contact_id        NUMBER  ,
          p_new_technical_contact_id        NUMBER  ,
          p_old_service_admin_contact_id    NUMBER  ,
          p_new_service_admin_contact_id    NUMBER  ,
          p_old_ship_to_site_use_id         NUMBER  ,
          p_new_ship_to_site_use_id         NUMBER  ,
          p_old_install_site_use_id         NUMBER  ,
          p_new_install_site_use_id         NUMBER  ,
          p_old_bill_to_site_use_id         NUMBER  ,
          p_new_bill_to_site_use_id         NUMBER  ,
          p_old_coterminate_day_month       VARCHAR2,
          p_new_coterminate_day_month       VARCHAR2,
          p_old_start_date_active           DATE    ,
          p_new_start_date_active           DATE    ,
          p_old_end_date_active             DATE    ,
          p_new_end_date_active             DATE    ,
          p_old_autocreated_from_system     NUMBER  ,
          p_new_autocreated_from_system     NUMBER  ,
          p_old_config_system_type          VARCHAR2,
          p_new_config_system_type          VARCHAR2,
          p_old_context                     VARCHAR2,
          p_new_context                     VARCHAR2,
          p_old_attribute1                  VARCHAR2,
          p_new_attribute1                  VARCHAR2,
          p_old_attribute2                  VARCHAR2,
          p_new_attribute2                  VARCHAR2,
          p_old_attribute3                  VARCHAR2,
          p_new_attribute3                  VARCHAR2,
          p_old_attribute4                  VARCHAR2,
          p_new_attribute4                  VARCHAR2,
          p_old_attribute5                  VARCHAR2,
          p_new_attribute5                  VARCHAR2,
          p_old_attribute6                  VARCHAR2,
          p_new_attribute6                  VARCHAR2,
          p_old_attribute7                  VARCHAR2,
          p_new_attribute7                  VARCHAR2,
          p_old_attribute8                  VARCHAR2,
          p_new_attribute8                  VARCHAR2,
          p_old_attribute9                  VARCHAR2,
          p_new_attribute9                  VARCHAR2,
          p_old_attribute10                 VARCHAR2,
          p_new_attribute10                 VARCHAR2,
          p_old_attribute11                 VARCHAR2,
          p_new_attribute11                 VARCHAR2,
          p_old_attribute12                 VARCHAR2,
          p_new_attribute12                 VARCHAR2,
          p_old_attribute13                 VARCHAR2,
          p_new_attribute13                 VARCHAR2,
          p_old_attribute14                 VARCHAR2,
          p_new_attribute14                 VARCHAR2,
          p_old_attribute15                 VARCHAR2,
          p_new_attribute15                 VARCHAR2,
          p_full_dump_flag                  VARCHAR2,
          p_created_by                      NUMBER  ,
          p_creation_date                   DATE    ,
          p_last_updated_by                 NUMBER  ,
          p_last_update_date                DATE    ,
          p_last_update_login               NUMBER  ,
          p_object_version_number           NUMBER  ,
          p_old_name                        VARCHAR2,
          p_new_name                        VARCHAR2,
          p_old_description                 VARCHAR2,
          p_new_description                 VARCHAR2,
		p_old_operating_unit_id           NUMBER,
		p_new_operating_unit_id           NUMBER)
 IS
 BEGIN
    Update csi_systems_h
    SET
              system_id = DECODE( p_system_id, fnd_api.g_miss_num, system_id, p_system_id),
              transaction_id = DECODE( p_transaction_id, fnd_api.g_miss_num, transaction_id, p_transaction_id),
              old_customer_id = DECODE( p_old_customer_id, fnd_api.g_miss_num, old_customer_id, p_old_customer_id),
              new_customer_id = DECODE( p_new_customer_id, fnd_api.g_miss_num, new_customer_id, p_new_customer_id),
              old_system_type_code = DECODE( p_old_system_type_code, fnd_api.g_miss_char, old_system_type_code, p_old_system_type_code),
              new_system_type_code = DECODE( p_new_system_type_code, fnd_api.g_miss_char, new_system_type_code, p_new_system_type_code),
              old_system_number = DECODE( p_old_system_number, fnd_api.g_miss_char, old_system_number, p_old_system_number),
              new_system_number = DECODE( p_new_system_number, fnd_api.g_miss_char, new_system_number, p_new_system_number),
              old_parent_system_id = DECODE( p_old_parent_system_id, fnd_api.g_miss_num, old_parent_system_id, p_old_parent_system_id),
              new_parent_system_id = DECODE( p_new_parent_system_id, fnd_api.g_miss_num, new_parent_system_id, p_new_parent_system_id),
              old_ship_to_contact_id = DECODE( p_old_ship_to_contact_id, fnd_api.g_miss_num, old_ship_to_contact_id, p_old_ship_to_contact_id),
              new_ship_to_contact_id = DECODE( p_new_ship_to_contact_id, fnd_api.g_miss_num, new_ship_to_contact_id, p_new_ship_to_contact_id),
              old_bill_to_contact_id = DECODE( p_old_bill_to_contact_id, fnd_api.g_miss_num, old_bill_to_contact_id, p_old_bill_to_contact_id),
              new_bill_to_contact_id = DECODE( p_new_bill_to_contact_id, fnd_api.g_miss_num, new_bill_to_contact_id, p_new_bill_to_contact_id),
              old_technical_contact_id = DECODE( p_old_technical_contact_id, fnd_api.g_miss_num, old_technical_contact_id, p_old_technical_contact_id),
              new_technical_contact_id = DECODE( p_new_technical_contact_id, fnd_api.g_miss_num, new_technical_contact_id, p_new_technical_contact_id),
              old_service_admin_contact_id = DECODE( p_old_service_admin_contact_id, fnd_api.g_miss_num, old_service_admin_contact_id, p_old_service_admin_contact_id),
              new_service_admin_contact_id = DECODE( p_new_service_admin_contact_id, fnd_api.g_miss_num, new_service_admin_contact_id, p_new_service_admin_contact_id),
              old_ship_to_site_use_id = DECODE( p_old_ship_to_site_use_id, fnd_api.g_miss_num, old_ship_to_site_use_id, p_old_ship_to_site_use_id),
              new_ship_to_site_use_id = DECODE( p_new_ship_to_site_use_id, fnd_api.g_miss_num, new_ship_to_site_use_id, p_new_ship_to_site_use_id),
              old_install_site_use_id = DECODE( p_old_install_site_use_id, fnd_api.g_miss_num, old_install_site_use_id, p_old_install_site_use_id),
              new_install_site_use_id = DECODE( p_new_install_site_use_id, fnd_api.g_miss_num, new_install_site_use_id, p_new_install_site_use_id),
              old_bill_to_site_use_id = DECODE( p_old_bill_to_site_use_id, fnd_api.g_miss_num, old_bill_to_site_use_id, p_old_bill_to_site_use_id),
              new_bill_to_site_use_id = DECODE( p_new_bill_to_site_use_id, fnd_api.g_miss_num, new_bill_to_site_use_id, p_new_bill_to_site_use_id),
              old_coterminate_day_month = DECODE( p_old_coterminate_day_month, fnd_api.g_miss_char, old_coterminate_day_month, p_old_coterminate_day_month),
              new_coterminate_day_month = DECODE( p_new_coterminate_day_month, fnd_api.g_miss_char, new_coterminate_day_month, p_new_coterminate_day_month),
              old_start_date_active = DECODE( p_old_start_date_active, fnd_api.g_miss_date, old_start_date_active, p_old_start_date_active),
              new_start_date_active = DECODE( p_new_start_date_active, fnd_api.g_miss_date, new_start_date_active, p_new_start_date_active),
              old_end_date_active = DECODE( p_old_end_date_active, fnd_api.g_miss_date, old_end_date_active, p_old_end_date_active),
              new_end_date_active = DECODE( p_new_end_date_active, fnd_api.g_miss_date, new_end_date_active, p_new_end_date_active),
              old_autocreated_from_system = DECODE( p_old_autocreated_from_system, fnd_api.g_miss_num, old_autocreated_from_system, p_old_autocreated_from_system),
              new_autocreated_from_system = DECODE( p_new_autocreated_from_system, fnd_api.g_miss_num, new_autocreated_from_system, p_new_autocreated_from_system),
              old_config_system_type = DECODE( p_old_config_system_type, fnd_api.g_miss_char, old_config_system_type, p_old_config_system_type),
              new_config_system_type = DECODE( p_new_config_system_type, fnd_api.g_miss_char, new_config_system_type, p_new_config_system_type),
              old_context = DECODE( p_old_context, fnd_api.g_miss_char, old_context, p_old_context),
              new_context = DECODE( p_new_context, fnd_api.g_miss_char, new_context, p_new_context),
              old_attribute1 = DECODE( p_old_attribute1, fnd_api.g_miss_char, old_attribute1, p_old_attribute1),
              new_attribute1 = DECODE( p_new_attribute1, fnd_api.g_miss_char, new_attribute1, p_new_attribute1),
              old_attribute2 = DECODE( p_old_attribute2, fnd_api.g_miss_char, old_attribute2, p_old_attribute2),
              new_attribute2 = DECODE( p_new_attribute2, fnd_api.g_miss_char, new_attribute2, p_new_attribute2),
              old_attribute3 = DECODE( p_old_attribute3, fnd_api.g_miss_char, old_attribute3, p_old_attribute3),
              new_attribute3 = DECODE( p_new_attribute3, fnd_api.g_miss_char, new_attribute3, p_new_attribute3),
              old_attribute4 = DECODE( p_old_attribute4, fnd_api.g_miss_char, old_attribute4, p_old_attribute4),
              new_attribute4 = DECODE( p_new_attribute4, fnd_api.g_miss_char, new_attribute4, p_new_attribute4),
              old_attribute5 = DECODE( p_old_attribute5, fnd_api.g_miss_char, old_attribute5, p_old_attribute5),
              new_attribute5 = DECODE( p_new_attribute5, fnd_api.g_miss_char, new_attribute5, p_new_attribute5),
              old_attribute6 = DECODE( p_old_attribute6, fnd_api.g_miss_char, old_attribute6, p_old_attribute6),
              new_attribute6 = DECODE( p_new_attribute6, fnd_api.g_miss_char, new_attribute6, p_new_attribute6),
              old_attribute7 = DECODE( p_old_attribute7, fnd_api.g_miss_char, old_attribute7, p_old_attribute7),
              new_attribute7 = DECODE( p_new_attribute7, fnd_api.g_miss_char, new_attribute7, p_new_attribute7),
              old_attribute8 = DECODE( p_old_attribute8, fnd_api.g_miss_char, old_attribute8, p_old_attribute8),
              new_attribute8 = DECODE( p_new_attribute8, fnd_api.g_miss_char, new_attribute8, p_new_attribute8),
              old_attribute9 = DECODE( p_old_attribute9, fnd_api.g_miss_char, old_attribute9, p_old_attribute9),
              new_attribute9 = DECODE( p_new_attribute9, fnd_api.g_miss_char, new_attribute9, p_new_attribute9),
              old_attribute10 = DECODE( p_old_attribute10, fnd_api.g_miss_char, old_attribute10, p_old_attribute10),
              new_attribute10 = DECODE( p_new_attribute10, fnd_api.g_miss_char, new_attribute10, p_new_attribute10),
              old_attribute11 = DECODE( p_old_attribute11, fnd_api.g_miss_char, old_attribute11, p_old_attribute11),
              new_attribute11 = DECODE( p_new_attribute11, fnd_api.g_miss_char, new_attribute11, p_new_attribute11),
              old_attribute12 = DECODE( p_old_attribute12, fnd_api.g_miss_char, old_attribute12, p_old_attribute12),
              new_attribute12 = DECODE( p_new_attribute12, fnd_api.g_miss_char, new_attribute12, p_new_attribute12),
              old_attribute13 = DECODE( p_old_attribute13, fnd_api.g_miss_char, old_attribute13, p_old_attribute13),
              new_attribute13 = DECODE( p_new_attribute13, fnd_api.g_miss_char, new_attribute13, p_new_attribute13),
              old_attribute14 = DECODE( p_old_attribute14, fnd_api.g_miss_char, old_attribute14, p_old_attribute14),
              new_attribute14 = DECODE( p_new_attribute14, fnd_api.g_miss_char, new_attribute14, p_new_attribute14),
              old_attribute15 = DECODE( p_old_attribute15, fnd_api.g_miss_char, old_attribute15, p_old_attribute15),
              new_attribute15 = DECODE( p_new_attribute15, fnd_api.g_miss_char, new_attribute15, p_new_attribute15),
              full_dump_flag = DECODE( p_full_dump_flag, fnd_api.g_miss_char, full_dump_flag, p_full_dump_flag),
              created_by = DECODE( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
              creation_date = DECODE( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
              last_updated_by = DECODE( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login),
              --object_version_number = DECODE( p_object_version_number, fnd_api.g_miss_num, object_version_number, p_object_version_number),
              object_version_number = object_version_number + 1,
              old_name = DECODE( p_old_name, fnd_api.g_miss_char, old_name, p_old_name),
              new_name = DECODE( p_new_name, fnd_api.g_miss_char, new_name, p_new_name),
              old_description = DECODE( p_old_description, fnd_api.g_miss_char, old_description, p_old_description),
              new_description = DECODE( p_new_description, fnd_api.g_miss_char, new_description, p_new_description),
		    old_operating_unit_id = DECODE(p_old_operating_unit_id,fnd_api.g_miss_num,old_operating_unit_id,p_old_operating_unit_id),
		    new_operating_unit_id = DECODE(p_new_operating_unit_id,fnd_api.g_miss_num,new_operating_unit_id,p_new_operating_unit_id)
    WHERE system_history_id = p_system_history_id;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;
END Update_Row;




END csi_systems_h_pkg;

/