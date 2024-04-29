--------------------------------------------------------
--  DDL for Package AMS_COMPETITOR_PRODUCTS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_COMPETITOR_PRODUCTS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstcprs.pls 120.2 2005/08/04 08:59:21 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_COMPETITOR_PRODUCTS_B_PKG
-- Purpose
--
-- History
--
--   03-Oct-2001   musman    Created.
--   05-Nov-2001   musman    Commented out the reference to security_group_id
--   28-MAR-2003   mukumar   Add languagem added
--   10-Sep-2003   Musman     Added Changes reqd for interest type to category
--   04-Aug-2005   inanaiah  R12 change - added a DFF
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_competitor_product_id   IN OUT NOCOPY NUMBER,
          px_object_version_number  IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_competitor_party_id    NUMBER,
          p_competitor_product_code    VARCHAR2,
          p_interest_type_id    NUMBER,
          p_inventory_item_id    NUMBER,
          p_organization_id    NUMBER,
          p_comp_product_url    VARCHAR2,
          p_original_system_ref    VARCHAR2,
          --p_security_group_id    NUMBER,
          p_competitor_product_name  VARCHAR2,
          p_description         VARCHAR2,
          p_start_date          DATE,
          p_end_date            DATE,
          p_category_id         NUMBER,
          p_category_set_id     NUMBER,
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
       p_attribute10                      VARCHAR2,
       p_attribute11                      VARCHAR2,
       p_attribute12                      VARCHAR2,
       p_attribute13                      VARCHAR2,
       p_attribute14                      VARCHAR2,
       p_attribute15                      VARCHAR2
        );

PROCEDURE Update_Row(
          p_competitor_product_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_competitor_party_id    NUMBER,
          p_competitor_product_code    VARCHAR2,
          p_interest_type_id    NUMBER,
          p_inventory_item_id    NUMBER,
          p_organization_id    NUMBER,
          p_comp_product_url    VARCHAR2,
          p_original_system_ref    VARCHAR2,
          --p_security_group_id    NUMBER,
          p_competitor_product_name  VARCHAR2,
          p_description         VARCHAR2,
          p_start_date          DATE,
          p_end_date            DATE,
          p_category_id         NUMBER,
          p_category_set_id     NUMBER,
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
       p_attribute10                      VARCHAR2,
       p_attribute11                      VARCHAR2,
       p_attribute12                      VARCHAR2,
       p_attribute13                      VARCHAR2,
       p_attribute14                      VARCHAR2,
       p_attribute15                      VARCHAR2
        );

PROCEDURE Delete_Row(
    p_COMPETITOR_PRODUCT_ID  NUMBER,
    p_object_version_number  NUMBER);

PROCEDURE Lock_Row(
          p_competitor_product_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_competitor_party_id    NUMBER,
          p_competitor_product_code    VARCHAR2,
          p_interest_type_id    NUMBER,
          p_inventory_item_id    NUMBER,
          p_organization_id    NUMBER,
          p_comp_product_url    VARCHAR2,
          p_original_system_ref    VARCHAR2,
          --p_security_group_id    NUMBER,
          p_competitor_product_name  VARCHAR2,
          p_description         VARCHAR2,
          p_start_date          DATE,
          p_end_date            DATE,
          p_category_id         NUMBER,
          p_category_set_id     NUMBER
        );

procedure ADD_LANGUAGE;

END AMS_COMPETITOR_PRODUCTS_B_PKG;

 

/
