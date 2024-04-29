--------------------------------------------------------
--  DDL for Package OZF_QP_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QP_PRODUCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftoqpps.pls 120.0 2005/07/07 19:35:03 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_QP_PRODUCTS_PKG
-- Purpose
--
-- History
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
          px_qp_product_id IN OUT NOCOPY NUMBER
          , p_off_discount_product_id NUMBER
          , p_pricing_attribute_id NUMBER
          , px_object_version_number IN OUT NOCOPY NUMBER
          , p_creation_date    DATE
          , p_created_by    NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          );

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
          p_qp_product_id NUMBER
          , p_off_discount_product_id NUMBER
          , p_pricing_attribute_id NUMBER
          , p_object_version_number NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          );


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
    p_qp_product_id NUMBER
    , p_object_version_number  NUMBER);




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
    p_qp_product_id NUMBER
    , p_object_version_number  NUMBER);




END OZF_QP_PRODUCTS_PKG;

 

/
