--------------------------------------------------------
--  DDL for Package Body CSI_SYSTEMS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_SYSTEMS_B_PKG" AS
/* $Header: csitsysb.pls 120.0.12010000.2 2008/11/06 20:30:23 mashah ship $ */
-- start of comments
-- package name     : csi_systems_b_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments


g_pkg_name constant VARCHAR2(30):= 'csi_systems_b_pkg';
g_file_name constant VARCHAR2(12) := 'csitsysb.pls';

PROCEDURE insert_row(
          px_system_id          IN OUT NOCOPY  NUMBER  ,
          p_customer_id                 NUMBER  ,
          p_system_type_code            VARCHAR2,
          p_system_number               VARCHAR2,
          p_parent_system_id            NUMBER  ,
          p_ship_to_contact_id          NUMBER  ,
          p_bill_to_contact_id          NUMBER  ,
          p_technical_contact_id        NUMBER  ,
          p_service_admin_contact_id    NUMBER  ,
          p_ship_to_site_use_id         NUMBER  ,
          p_bill_to_site_use_id         NUMBER  ,
          p_install_site_use_id         NUMBER  ,
          p_coterminate_day_month       VARCHAR2,
          p_autocreated_from_system_id  NUMBER  ,
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
          p_created_by                  NUMBER  ,
          p_creation_date               DATE    ,
          p_last_updated_by             NUMBER  ,
          p_last_update_date            DATE    ,
          p_last_update_login           NUMBER  ,
          p_object_version_number       NUMBER  ,
          p_name                        VARCHAR2,
          p_description                 VARCHAR2,
          p_operating_unit_id           NUMBER  ,
          p_request_id                  NUMBER  ,
          p_program_application_id      NUMBER  ,
          p_program_id                  NUMBER  ,
          p_program_update_date         DATE
          )


 is
   CURSOR c2 IS SELECT csi_systems_s.NEXTVAL FROM sys.dual;
BEGIN
   IF (px_system_id IS NULL) OR (px_system_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 INTO px_system_id;
       CLOSE c2;
   END IF;
   INSERT INTO csi_systems_b(
           system_id,
           customer_id,
           system_type_code,
           system_number,
           parent_system_id,
           ship_to_contact_id,
           bill_to_contact_id,
           technical_contact_id,
           service_admin_contact_id,
           ship_to_site_use_id,
           bill_to_site_use_id,
           install_site_use_id,
           coterminate_day_month,
           autocreated_from_system_id,
           config_system_type,
           start_date_active,
           end_date_active,
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
           object_version_number,
           operating_unit_id,
           request_id,
           program_application_id,
           program_id,
           program_update_date
          ) VALUES (
           px_system_id,
           decode( p_customer_id, fnd_api.g_miss_num, NULL, p_customer_id),
           decode( p_system_type_code, fnd_api.g_miss_char, NULL, p_system_type_code),
           decode( p_system_number, fnd_api.g_miss_char, NULL, p_system_number),
           decode( p_parent_system_id, fnd_api.g_miss_num, NULL, p_parent_system_id),
           decode( p_ship_to_contact_id, fnd_api.g_miss_num, NULL, p_ship_to_contact_id),
           decode( p_bill_to_contact_id, fnd_api.g_miss_num, NULL, p_bill_to_contact_id),
           decode( p_technical_contact_id, fnd_api.g_miss_num, NULL, p_technical_contact_id),
           decode( p_service_admin_contact_id, fnd_api.g_miss_num, NULL, p_service_admin_contact_id),
           decode( p_ship_to_site_use_id, fnd_api.g_miss_num, NULL, p_ship_to_site_use_id),
           decode( p_bill_to_site_use_id, fnd_api.g_miss_num, NULL, p_bill_to_site_use_id),
           decode( p_install_site_use_id, fnd_api.g_miss_num, NULL, p_install_site_use_id),
           decode( p_coterminate_day_month, fnd_api.g_miss_char, NULL, p_coterminate_day_month),
           decode( p_autocreated_from_system_id,fnd_api.g_miss_num, NULL, p_autocreated_from_system_id),
           decode( p_config_system_type, fnd_api.g_miss_char, NULL, p_config_system_type),
           decode( p_start_date_active, fnd_api.g_miss_date, to_date(NULL), p_start_date_active),
           decode( p_end_date_active, fnd_api.g_miss_date, to_date(NULL), p_end_date_active),
           decode( p_context, fnd_api.g_miss_char, NULL, p_context),
           decode( p_attribute1, fnd_api.g_miss_char, NULL, p_attribute1),
           decode( p_attribute2, fnd_api.g_miss_char, NULL, p_attribute2),
           decode( p_attribute3, fnd_api.g_miss_char, NULL, p_attribute3),
           decode( p_attribute4, fnd_api.g_miss_char, NULL, p_attribute4),
           decode( p_attribute5, fnd_api.g_miss_char, NULL, p_attribute5),
           decode( p_attribute6, fnd_api.g_miss_char, NULL, p_attribute6),
           decode( p_attribute7, fnd_api.g_miss_char, NULL, p_attribute7),
           decode( p_attribute8, fnd_api.g_miss_char, NULL, p_attribute8),
           decode( p_attribute9, fnd_api.g_miss_char, NULL, p_attribute9),
           decode( p_attribute10, fnd_api.g_miss_char, NULL, p_attribute10),
           decode( p_attribute11, fnd_api.g_miss_char, NULL, p_attribute11),
           decode( p_attribute12, fnd_api.g_miss_char, NULL, p_attribute12),
           decode( p_attribute13, fnd_api.g_miss_char, NULL, p_attribute13),
           decode( p_attribute14, fnd_api.g_miss_char, NULL, p_attribute14),
           decode( p_attribute15, fnd_api.g_miss_char, NULL, p_attribute15),
           decode( p_created_by, fnd_api.g_miss_num, NULL, p_created_by),
           decode( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
           decode( p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
           decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
           decode( p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login),
           decode( p_object_version_number, fnd_api.g_miss_num, NULL, p_object_version_number),
           decode( p_operating_unit_id, fnd_api.g_miss_num, NULL, p_operating_unit_id),
           decode( p_request_id, fnd_api.g_miss_num, NULL, p_request_id),
           decode( p_program_application_id, fnd_api.g_miss_num, NULL, p_program_application_id),
           decode( p_program_id, fnd_api.g_miss_num, NULL, p_program_id),
           decode( p_program_update_date, fnd_api.g_miss_date, to_date(NULL), p_program_update_date)
           );

    INSERT INTO csi_systems_tl(
                system_id        ,
                language         ,
                source_lang      ,
                name             ,
                description      ,
                created_by       ,
                creation_date    ,
                last_updated_by  ,
                last_update_date  ,
                last_update_login
                )
         SELECT
                px_system_id,
                L.language_code,
                userenv('LANG'),
                decode( p_name, fnd_api.g_miss_char, NULL, p_name),
                decode( p_description, fnd_api.g_miss_char, NULL, p_description),
                decode( p_created_by, fnd_api.g_miss_num, NULL, p_created_by),
                decode( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
                decode( p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
                decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
                decode( p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login)
         FROM   fnd_languages L
         WHERE  L.installed_flag IN ('I','B')
         AND NOT EXISTS
                (SELECT NULL
                 FROM   csi_systems_tl T
                 WHERE  T.system_id=px_system_id
                 AND    T.language = L.language_code);

END insert_row;

PROCEDURE update_row(
          p_system_id                   NUMBER      := fnd_api.g_miss_num ,
          p_customer_id                 NUMBER      := fnd_api.g_miss_num ,
          p_system_type_code            VARCHAR2    := fnd_api.g_miss_char,
          p_system_number               VARCHAR2    := fnd_api.g_miss_char,
          p_parent_system_id            NUMBER      := fnd_api.g_miss_num ,
          p_ship_to_contact_id          NUMBER      := fnd_api.g_miss_num ,
          p_bill_to_contact_id          NUMBER      := fnd_api.g_miss_num ,
          p_technical_contact_id        NUMBER      := fnd_api.g_miss_num ,
          p_service_admin_contact_id    NUMBER      := fnd_api.g_miss_num ,
          p_ship_to_site_use_id         NUMBER      := fnd_api.g_miss_num ,
          p_bill_to_site_use_id         NUMBER      := fnd_api.g_miss_num ,
          p_install_site_use_id         NUMBER      := fnd_api.g_miss_num ,
          p_coterminate_day_month       VARCHAR2    := fnd_api.g_miss_char,
          p_autocreated_from_system_id  NUMBER      := fnd_api.g_miss_num ,
          p_config_system_type          VARCHAR2    := fnd_api.g_miss_char,
          p_start_date_active           DATE        := fnd_api.g_miss_date,
          p_end_date_active             DATE        := fnd_api.g_miss_date,
          p_context                     VARCHAR2    := fnd_api.g_miss_char,
          p_attribute1                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute2                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute3                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute4                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute5                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute6                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute7                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute8                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute9                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute10                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute11                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute12                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute13                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute14                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute15                 VARCHAR2    := fnd_api.g_miss_char,
          p_created_by                  NUMBER      := fnd_api.g_miss_num ,
          p_creation_date               DATE        := fnd_api.g_miss_date,
          p_last_updated_by             NUMBER      := fnd_api.g_miss_num ,
          p_last_update_date            DATE        := fnd_api.g_miss_date,
          p_last_update_login           NUMBER      := fnd_api.g_miss_num ,
          p_object_version_number       NUMBER      := fnd_api.g_miss_num ,
          p_name                        VARCHAR2    := fnd_api.g_miss_char,
          p_description                 VARCHAR2    := fnd_api.g_miss_char,
          p_operating_unit_id           NUMBER      := fnd_api.g_miss_num,
          p_request_id                  NUMBER      ,
          p_program_application_id      NUMBER      ,
          p_program_id                  NUMBER      ,
          p_program_update_date         DATE        )
 IS
 BEGIN
    update csi_systems_b
    set
              customer_id = decode( p_customer_id, fnd_api.g_miss_num, customer_id, p_customer_id),
              system_type_code = decode( p_system_type_code, fnd_api.g_miss_char, system_type_code, p_system_type_code),
              system_number = decode( p_system_number, fnd_api.g_miss_char, system_number, p_system_number),
              parent_system_id = decode( p_parent_system_id, fnd_api.g_miss_num, parent_system_id, p_parent_system_id),
              ship_to_contact_id = decode( p_ship_to_contact_id, fnd_api.g_miss_num, ship_to_contact_id, p_ship_to_contact_id),
              bill_to_contact_id = decode( p_bill_to_contact_id, fnd_api.g_miss_num, bill_to_contact_id, p_bill_to_contact_id),
              technical_contact_id = decode( p_technical_contact_id, fnd_api.g_miss_num, technical_contact_id, p_technical_contact_id),
              service_admin_contact_id = decode( p_service_admin_contact_id, fnd_api.g_miss_num, service_admin_contact_id, p_service_admin_contact_id),
              ship_to_site_use_id = decode( p_ship_to_site_use_id, fnd_api.g_miss_num, ship_to_site_use_id, p_ship_to_site_use_id),
              bill_to_site_use_id = decode( p_bill_to_site_use_id, fnd_api.g_miss_num, bill_to_site_use_id, p_bill_to_site_use_id),
              install_site_use_id = decode( p_install_site_use_id, fnd_api.g_miss_num, install_site_use_id, p_install_site_use_id),
              coterminate_day_month = decode( p_coterminate_day_month, fnd_api.g_miss_char, coterminate_day_month, p_coterminate_day_month),
              autocreated_from_system_id = decode( p_autocreated_from_system_id,fnd_api.g_miss_num, autocreated_from_system_id, p_autocreated_from_system_id),
              config_system_type = decode(p_config_system_type,fnd_api.g_miss_char, config_system_type, p_config_system_type),
              start_date_active = decode( p_start_date_active, fnd_api.g_miss_date, start_date_active, p_start_date_active),
              end_date_active = decode( p_end_date_active, fnd_api.g_miss_date, end_date_active, p_end_date_active),
              context = decode( p_context, fnd_api.g_miss_char, context, p_context),
              attribute1 = decode( p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1),
              attribute2 = decode( p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2),
              attribute3 = decode( p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3),
              attribute4 = decode( p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4),
              attribute5 = decode( p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5),
              attribute6 = decode( p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6),
              attribute7 = decode( p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7),
              attribute8 = decode( p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8),
              attribute9 = decode( p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9),
              attribute10 = decode( p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10),
              attribute11 = decode( p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11),
              attribute12 = decode( p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12),
              attribute13 = decode( p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13),
              attribute14 = decode( p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14),
              attribute15 = decode( p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15),
              created_by = decode( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
              creation_date = decode( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
              last_updated_by = decode( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = decode( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = decode( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = object_version_number+1,
              operating_unit_id = decode(p_operating_unit_id,fnd_api.g_miss_num,operating_unit_id,p_operating_unit_id),
              request_id = decode(p_request_id,fnd_api.g_miss_num,request_id,p_request_id),
              program_application_id = decode(p_program_application_id,fnd_api.g_miss_num,program_application_id,p_program_application_id),
              program_id = decode(p_program_id,fnd_api.g_miss_num,program_id,p_program_id),
              program_update_date = decode( p_program_update_date, fnd_api.g_miss_date, program_update_date, p_program_update_date)
    WHERE system_id = p_system_id;

        UPDATE csi_systems_tl
              SET    source_lang        = userenv('LANG'),
                     name               = decode( p_name, fnd_api.g_miss_char, name, p_name),
                     description        = decode( p_description, fnd_api.g_miss_char, description, p_description),
                     created_by         = decode( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
                     creation_date      = decode( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
                     last_updated_by    = decode( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
                     last_update_date   = decode( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
                     last_update_login  = decode( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login)
               WHERE system_id = p_system_id
               AND   userenv('LANG') IN (LANGUAGE,SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;
END update_row;


PROCEDURE update_row_for_mu(
          p_system_id                   NUMBER      := fnd_api.g_miss_num ,
          p_customer_id                 NUMBER      := fnd_api.g_miss_num ,
          p_system_type_code            VARCHAR2    := fnd_api.g_miss_char,
          p_system_number               VARCHAR2    := fnd_api.g_miss_char,
          p_parent_system_id            NUMBER      := fnd_api.g_miss_num ,
          p_ship_to_contact_id          NUMBER      := fnd_api.g_miss_num ,
          p_bill_to_contact_id          NUMBER      := fnd_api.g_miss_num ,
          p_technical_contact_id        NUMBER      := fnd_api.g_miss_num ,
          p_service_admin_contact_id    NUMBER      := fnd_api.g_miss_num ,
          p_ship_to_site_use_id         NUMBER      := fnd_api.g_miss_num ,
          p_bill_to_site_use_id         NUMBER      := fnd_api.g_miss_num ,
          p_install_site_use_id         NUMBER      := fnd_api.g_miss_num ,
          p_coterminate_day_month       VARCHAR2    := fnd_api.g_miss_char,
          p_autocreated_from_system_id  NUMBER      := fnd_api.g_miss_num ,
          p_config_system_type          VARCHAR2    := fnd_api.g_miss_char,
          p_start_date_active           DATE        := fnd_api.g_miss_date,
          p_end_date_active             DATE        := fnd_api.g_miss_date,
          p_context                     VARCHAR2    := fnd_api.g_miss_char,
          p_attribute1                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute2                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute3                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute4                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute5                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute6                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute7                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute8                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute9                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute10                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute11                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute12                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute13                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute14                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute15                 VARCHAR2    := fnd_api.g_miss_char,
          p_created_by                  NUMBER      := fnd_api.g_miss_num ,
          p_creation_date               DATE        := fnd_api.g_miss_date,
          p_last_updated_by             NUMBER      := fnd_api.g_miss_num ,
          p_last_update_date            DATE        := fnd_api.g_miss_date,
          p_last_update_login           NUMBER      := fnd_api.g_miss_num ,
          p_object_version_number       NUMBER      := fnd_api.g_miss_num ,
          p_name                        VARCHAR2    := fnd_api.g_miss_char,
          p_description                 VARCHAR2    := fnd_api.g_miss_char,
          p_operating_unit_id           NUMBER      := fnd_api.g_miss_num,
          p_request_id                  NUMBER      ,
          p_program_application_id      NUMBER      ,
          p_program_id                  NUMBER      ,
          p_program_update_date         DATE        )
 IS
 BEGIN
    update csi_systems_b
    set
              customer_id = decode( p_customer_id, fnd_api.g_miss_num, customer_id, p_customer_id),
              system_type_code = decode( p_system_type_code, fnd_api.g_miss_char, system_type_code, p_system_type_code),
              system_number = decode( p_system_number, fnd_api.g_miss_char, system_number, p_system_number),
              parent_system_id = decode( p_parent_system_id, fnd_api.g_miss_num, parent_system_id, p_parent_system_id),
              ship_to_contact_id = null,
              bill_to_contact_id = null,
              technical_contact_id = null,
              service_admin_contact_id = null,
              ship_to_site_use_id = null,
              bill_to_site_use_id = null,
              install_site_use_id = null,
              coterminate_day_month = decode( p_coterminate_day_month, fnd_api.g_miss_char, coterminate_day_month, p_coterminate_day_month),
              autocreated_from_system_id = decode( p_autocreated_from_system_id,fnd_api.g_miss_num, autocreated_from_system_id, p_autocreated_from_system_id),
              config_system_type = decode(p_config_system_type,fnd_api.g_miss_char, config_system_type, p_config_system_type),
              start_date_active = decode( p_start_date_active, fnd_api.g_miss_date, start_date_active, p_start_date_active),
              end_date_active = decode( p_end_date_active, fnd_api.g_miss_date, end_date_active, p_end_date_active),
              context = decode( p_context, fnd_api.g_miss_char, context, p_context),
              attribute1 = decode( p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1),
              attribute2 = decode( p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2),
              attribute3 = decode( p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3),
              attribute4 = decode( p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4),
              attribute5 = decode( p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5),
              attribute6 = decode( p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6),
              attribute7 = decode( p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7),
              attribute8 = decode( p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8),
              attribute9 = decode( p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9),
              attribute10 = decode( p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10),
              attribute11 = decode( p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11),
              attribute12 = decode( p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12),
              attribute13 = decode( p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13),
              attribute14 = decode( p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14),
              attribute15 = decode( p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15),
              created_by = decode( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
              creation_date = decode( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
              last_updated_by = decode( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = decode( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = decode( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = object_version_number+1,
              operating_unit_id = decode(p_operating_unit_id,fnd_api.g_miss_num,operating_unit_id,p_operating_unit_id),
              request_id = decode(p_request_id,fnd_api.g_miss_num,request_id,p_request_id),
              program_application_id = decode(p_program_application_id,fnd_api.g_miss_num,program_application_id,p_program_application_id),
              program_id = decode(p_program_id,fnd_api.g_miss_num,program_id,p_program_id),
              program_update_date = decode( p_program_update_date, fnd_api.g_miss_date, program_update_date, p_program_update_date)
    WHERE system_id = p_system_id;

        UPDATE csi_systems_tl
              SET    source_lang        = userenv('LANG'),
                     name               = decode( p_name, fnd_api.g_miss_char, name, p_name),
                     description        = decode( p_description, fnd_api.g_miss_char, description, p_description),
                     created_by         = decode( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
                     creation_date      = decode( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
                     last_updated_by    = decode( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
                     last_update_date   = decode( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
                     last_update_login  = decode( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login)
               WHERE system_id = p_system_id
               AND   userenv('LANG') IN (LANGUAGE,SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;
END update_row_for_mu;

PROCEDURE delete_row(
    p_system_id  NUMBER)
 is
 BEGIN
   delete FROM csi_systems_b
    WHERE system_id = p_system_id;
   if (sql%notfound) THEN
       raise no_data_found;
   END IF;
 end delete_row;

PROCEDURE lock_row(
          p_system_id                   NUMBER,
          p_customer_id                 NUMBER,
          p_system_type_code            VARCHAR2,
          p_system_number               VARCHAR2,
          p_parent_system_id            NUMBER,
          p_ship_to_contact_id          NUMBER,
          p_bill_to_contact_id          NUMBER,
          p_technical_contact_id        NUMBER,
          p_service_admin_contact_id    NUMBER,
          p_ship_to_site_use_id         NUMBER,
          p_bill_to_site_use_id         NUMBER,
          p_install_site_use_id         NUMBER,
          p_coterminate_day_month       VARCHAR2,
          p_start_date_active           DATE,
          p_end_date_active             DATE,
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
          p_object_version_number       NUMBER,
          p_name                        VARCHAR2,
          p_description                 VARCHAR2,
	  p_operating_unit_id           NUMBER)

 is
   CURSOR c IS
        SELECT *
        FROM   csi_systems_b
        WHERE  system_id =  p_system_id
        FOR UPDATE OF system_id NOWAIT;
   recinfo c%rowtype;

   CURSOR c1 IS
      SELECT name,
             description,
             decode(language, userenv('LANG'), 'Y', 'N') baselang
      FROM   csi_systems_tl
      WHERE  system_id = p_system_id
      AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
      FOR UPDATE OF system_id NOWAIT;
 BEGIN
    OPEN c;
    FETCH c INTO recinfo;
    IF (c%notfound) THEN
        CLOSE c;
        fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
    END IF;
    CLOSE c;


    IF  (recinfo.object_version_number=p_object_version_number)
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

   FOR tlinfo IN c1 LOOP
    IF (tlinfo.baselang = 'Y') THEN
       IF (    (tlinfo.name = p_name)
          AND ((tlinfo.description = p_description)
               OR ((tlinfo.description IS NULL) AND (p_description IS NULL)))
       ) THEN
        NULL;
       ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
       END IF;
    END IF;
   END LOOP;
  RETURN;

 END lock_row;


PROCEDURE add_language
IS
BEGIN
  /********* COMMENTED FOR BUG 4238439 (Refer 3723612 for solution)
  DELETE FROM csi_systems_tl t
  WHERE NOT EXISTS
    (SELECT NULL
     FROM   csi_systems_b b
     WHERE  b.system_id = t.system_id
    );

  UPDATE csi_systems_tl t
  SET (name,description) =
      (SELECT b.name,
              b.description
       FROM   csi_systems_tl b
       WHERE  b.system_id = t.system_id
       AND    b.language  = t.source_lang)
  WHERE (t.system_id,t.language) IN
        (SELECT  subt.system_id,
                 subt.language
         FROM    csi_systems_tl subb, csi_systems_tl subt
         WHERE   subb.system_id = subt.system_id
         AND     subb.language  = subt.source_lang
         AND (subb.name <> subt.name
              OR subb.description <> subt.description
              OR (subb.description IS NULL AND subt.description IS NOT NULL)
              OR (subb.description iS NOT NULL AND subt.description IS NULL)
              )
         );
   *********** END OF COMMENT **********/

  INSERT /*+ append parallel(tt) */ INTO csi_systems_tl tt (system_id,
                              name,
                              description,
                              last_update_date,
                              last_updated_by,
                              creation_date,
                              created_by,
                              last_update_login,
                              language,
                              source_lang
                              )
   SELECT /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
    ( SELECT /*+ no_merge ordered parallel(b) */   b.system_id,
						   b.name,
						   b.description,
						   b.last_update_date,
						   b.last_updated_by,
						   b.creation_date,
						   b.created_by,
						   b.last_update_login,
						   l.language_code,
						   b.source_lang
                                  FROM      csi_systems_tl b, fnd_languages l
                                  WHERE     l.installed_flag in ('I', 'B')
                                  AND       b.language = userenv('LANG')
                             ) v, csi_systems_tl t
     WHERE t.system_id(+) = v.system_id
     AND   t.language(+) = v.language_code
     AND   t.system_id IS NULL;
                              /***** COMMENTED    AND NOT EXISTS
                                            (SELECT NULL
                                             FROM   csi_systems_tl t
                                             WHERE  t.system_id = b.system_id
                                             AND    t.language  = l.language_code); *****/
END add_language;

PROCEDURE translate_row (
                p_system_id    IN     NUMBER  ,
                p_name         IN     VARCHAR2,
                p_description  IN     VARCHAR2,
                p_owner        IN     VARCHAR2
                        ) IS
BEGIN
  UPDATE csi_systems_tl
  SET   name              = p_name,
        description       = p_description,
        last_update_date  = sysdate,
        last_updated_by   = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = userenv('LANG')
  WHERE system_id = p_system_id
  AND   userenv('LANG') IN (language, source_lang);
END translate_row;



end csi_systems_b_pkg;

/
