--------------------------------------------------------
--  DDL for Package OZF_CREATE_OZF_PROD_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CREATE_OZF_PROD_LINE_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftodps.pls 120.0 2005/06/01 01:26:45 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Create_Ozf_Prod_Line_PKG
-- Purpose
--
-- History
--           Wed May 18 2005:11/52 AM RSSHARMA Added Insert_row and Update_row methods for Volume Offer

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
          px_off_discount_product_id   IN OUT NOCOPY NUMBER,
          p_parent_off_disc_prod_id IN NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER);


--  ========================================================
--
--  NAME
--  Insert_Row for volume_offer
--
--  PURPOSE Insert Row for release 12 Volume Offers
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_off_discount_product_id   IN OUT NOCOPY NUMBER,
          p_parent_off_disc_prod_id IN NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_product_context VARCHAR2,
          p_product_attribute VARCHAR2,
          p_product_attr_value VARCHAR2,
          p_apply_discount_flag VARCHAR2,
          p_include_volume_flag VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER);




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
          p_off_discount_product_id    NUMBER,
          p_parent_off_disc_prod_id   NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER
          );

--  ========================================================
--
--  NAME
--  Update_Row for volume_offer
--
--  PURPOSE Update Row for release 12 Volume Offers
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_off_discount_product_id    NUMBER,
          p_parent_off_disc_prod_id    NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_product_context VARCHAR2,
          p_product_attribute VARCHAR2,
          p_product_attr_value VARCHAR2,
          p_apply_discount_flag VARCHAR2,
          p_include_volume_flag VARCHAR2,
          p_object_version_number   IN NUMBER);


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
    p_off_discount_product_id  NUMBER,
    p_object_version_number  NUMBER);

PROCEDURE Delete_Product(
    p_offer_discount_line_id  NUMBER
);


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
    p_off_discount_product_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_Create_Ozf_Prod_Line_PKG;

 

/
