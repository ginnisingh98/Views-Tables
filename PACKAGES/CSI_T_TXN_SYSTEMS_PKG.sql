--------------------------------------------------------
--  DDL for Package CSI_T_TXN_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_SYSTEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: csittsys.pls 115.2 2002/11/12 00:26:32 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_T_TXN_SYSTEMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_transaction_system_id    IN OUT NOCOPY    NUMBER  ,
          p_transaction_line_id                 NUMBER  ,
          p_system_name                         VARCHAR2,
          p_description                         VARCHAR2,
          p_system_type_code                    VARCHAR2,
          p_system_number                       VARCHAR2,
          p_customer_id                         NUMBER  ,
          p_bill_to_contact_id                  NUMBER  ,
          p_ship_to_contact_id                  NUMBER  ,
          p_technical_contact_id                NUMBER  ,
          p_service_admin_contact_id            NUMBER  ,
          p_ship_to_site_use_id                 NUMBER  ,
          p_bill_to_site_use_id                 NUMBER  ,
          p_install_site_use_id                 NUMBER  ,
          p_coterminate_day_month               VARCHAR2,
          p_config_system_type                  VARCHAR2,
          p_start_date_active                   DATE    ,
          p_end_date_active                     DATE    ,
          p_context                             VARCHAR2,
          p_attribute1                          VARCHAR2,
          p_attribute2                          VARCHAR2,
          p_attribute3                          VARCHAR2,
          p_attribute4                          VARCHAR2,
          p_attribute5                          VARCHAR2,
          p_attribute6                          VARCHAR2,
          p_attribute7                          VARCHAR2,
          p_attribute8                          VARCHAR2,
          p_attribute9                          VARCHAR2,
          p_attribute10                         VARCHAR2,
          p_attribute11                         VARCHAR2,
          p_attribute12                         VARCHAR2,
          p_attribute13                         VARCHAR2,
          p_attribute14                         VARCHAR2,
          p_attribute15                         VARCHAR2,
          p_created_by                          NUMBER  ,
          p_creation_date                       DATE    ,
          p_last_updated_by                     NUMBER  ,
          p_last_update_date                    DATE    ,
          p_last_update_login                   NUMBER  ,
          p_object_version_number               NUMBER);

PROCEDURE Update_Row(
          p_transaction_system_id               NUMBER  ,
          p_transaction_line_id                 NUMBER  ,
          p_system_name                         VARCHAR2,
          p_description                         VARCHAR2,
          p_system_type_code                    VARCHAR2,
          p_system_number                       VARCHAR2,
          p_customer_id                         NUMBER  ,
          p_bill_to_contact_id                  NUMBER  ,
          p_ship_to_contact_id                  NUMBER  ,
          p_technical_contact_id                NUMBER  ,
          p_service_admin_contact_id            NUMBER  ,
          p_ship_to_site_use_id                 NUMBER  ,
          p_bill_to_site_use_id                 NUMBER  ,
          p_install_site_use_id                 NUMBER  ,
          p_coterminate_day_month               VARCHAR2,
          p_config_system_type                  VARCHAR2,
          p_start_date_active                   DATE    ,
          p_end_date_active                     DATE    ,
          p_context                             VARCHAR2,
          p_attribute1                          VARCHAR2,
          p_attribute2                          VARCHAR2,
          p_attribute3                          VARCHAR2,
          p_attribute4                          VARCHAR2,
          p_attribute5                          VARCHAR2,
          p_attribute6                          VARCHAR2,
          p_attribute7                          VARCHAR2,
          p_attribute8                          VARCHAR2,
          p_attribute9                          VARCHAR2,
          p_attribute10                         VARCHAR2,
          p_attribute11                         VARCHAR2,
          p_attribute12                         VARCHAR2,
          p_attribute13                         VARCHAR2,
          p_attribute14                         VARCHAR2,
          p_attribute15                         VARCHAR2,
          p_created_by                          NUMBER  ,
          p_creation_date                       DATE    ,
          p_last_updated_by                     NUMBER  ,
          p_last_update_date                    DATE    ,
          p_last_update_login                   NUMBER  ,
          p_object_version_number               NUMBER);

PROCEDURE Lock_Row(
          p_transaction_system_id               NUMBER  ,
          p_transaction_line_id                 NUMBER  ,
          p_system_name                         VARCHAR2,
          p_description                         VARCHAR2,
          p_system_type_code                    VARCHAR2,
          p_system_number                       VARCHAR2,
          p_customer_id                         NUMBER  ,
          p_bill_to_contact_id                  NUMBER  ,
          p_ship_to_contact_id                  NUMBER  ,
          p_technical_contact_id                NUMBER  ,
          p_service_admin_contact_id            NUMBER  ,
          p_ship_to_site_use_id                 NUMBER  ,
          p_bill_to_site_use_id                 NUMBER  ,
          p_install_site_use_id                 NUMBER  ,
          p_coterminate_day_month               VARCHAR2,
          p_config_system_type                  VARCHAR2,
          p_start_date_active                   DATE    ,
          p_end_date_active                     DATE    ,
          p_context                             VARCHAR2,
          p_attribute1                          VARCHAR2,
          p_attribute2                          VARCHAR2,
          p_attribute3                          VARCHAR2,
          p_attribute4                          VARCHAR2,
          p_attribute5                          VARCHAR2,
          p_attribute6                          VARCHAR2,
          p_attribute7                          VARCHAR2,
          p_attribute8                          VARCHAR2,
          p_attribute9                          VARCHAR2,
          p_attribute10                         VARCHAR2,
          p_attribute11                         VARCHAR2,
          p_attribute12                         VARCHAR2,
          p_attribute13                         VARCHAR2,
          p_attribute14                         VARCHAR2,
          p_attribute15                         VARCHAR2,
          p_created_by                          NUMBER  ,
          p_creation_date                       DATE    ,
          p_last_updated_by                     NUMBER  ,
          p_last_update_date                    DATE    ,
          p_last_update_login                   NUMBER  ,
          p_object_version_number               NUMBER);

PROCEDURE Delete_Row(
          p_transaction_system_id               NUMBER);
End CSI_T_TXN_SYSTEMS_PKG;

 

/
