--------------------------------------------------------
--  DDL for Package CSI_I_EXT_ATTRIB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_I_EXT_ATTRIB_PKG" AUTHID CURRENT_USER AS
/* $Header: csitieas.pls 115.3 2003/09/04 00:18:20 sguthiva ship $ */
-- Start of Comments
-- Package name     : CSI_I_EXT_ATTRIB_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments

PROCEDURE Insert_Row(
          px_attribute_id           IN OUT NOCOPY  NUMBER  ,
          p_attribute_level                 VARCHAR2,
          p_master_organization_id          NUMBER  ,
          p_inventory_item_id               NUMBER  ,
          p_item_category_id                NUMBER  ,
          p_instance_id                     NUMBER  ,
          p_attribute_code                  VARCHAR2,
          p_attribute_name                  VARCHAR2,
          p_attribute_category              VARCHAR2,
          p_description                     VARCHAR2,
          p_active_start_date               DATE    ,
          p_active_end_date                 DATE    ,
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
          p_created_by                      NUMBER  ,
          p_creation_date                   DATE    ,
          p_last_updated_by                 NUMBER  ,
          p_last_update_date                DATE    ,
          p_last_update_login               NUMBER  ,
          p_object_version_number           NUMBER);

PROCEDURE update_row(
          p_attribute_id                    NUMBER  ,
          p_attribute_level                 VARCHAR2,
          p_master_organization_id          NUMBER  ,
          p_inventory_item_id               NUMBER  ,
          p_item_category_id                NUMBER  ,
          p_instance_id                     NUMBER  ,
          p_attribute_code                  VARCHAR2,
          p_attribute_name                  VARCHAR2,
          p_attribute_category              VARCHAR2,
          p_description                     VARCHAR2,
          p_active_start_date               DATE    ,
          p_active_end_date                 DATE    ,
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
          p_created_by                      NUMBER  ,
          p_creation_date                   DATE    ,
          p_last_updated_by                 NUMBER  ,
          p_last_update_date                DATE    ,
          p_last_update_login               NUMBER  ,
          p_object_version_number           NUMBER);

PROCEDURE delete_row(
          p_attribute_id                    NUMBER);
END csi_i_ext_attrib_pkg;

 

/
