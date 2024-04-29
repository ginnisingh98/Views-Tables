--------------------------------------------------------
--  DDL for Package OZF_PROD_RELN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PROD_RELN_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftdprs.pls 120.0 2005/06/01 01:13:59 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Prod_Reln_PKG
-- Purpose
--
-- History
--
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
          px_discount_product_reln_id   IN OUT NOCOPY NUMBER,
          p_offer_discount_line_id    NUMBER,
          p_off_discount_product_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
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
          p_discount_product_reln_id    NUMBER,
          p_offer_discount_line_id    NUMBER,
          p_off_discount_product_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER
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
    p_discount_product_reln_id  NUMBER,
    p_object_version_number  NUMBER);


PROCEDURE Delete(
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
    p_discount_product_reln_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_Prod_Reln_PKG;

 

/
