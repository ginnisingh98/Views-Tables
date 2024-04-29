--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_NEW_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_NEW_PRODUCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftanps.pls 120.0 2006/03/30 13:46:55 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJ_NEW_PRODUCTS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_offer_adj_new_product_id   IN OUT NOCOPY  NUMBER,
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id      NUMBER,
          p_product_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER);

PROCEDURE Update_Row(
          p_offer_adj_new_product_id    NUMBER,
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id      NUMBER,
          p_product_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER);

PROCEDURE Delete_Row(
    p_OFFER_ADJ_NEW_PRODUCT_ID  NUMBER);
PROCEDURE Lock_Row(
          p_offer_adj_new_product_id    NUMBER,
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id      NUMBER,
          p_product_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER);

END OZF_OFFER_ADJ_NEW_PRODUCTS_PKG;

 

/
