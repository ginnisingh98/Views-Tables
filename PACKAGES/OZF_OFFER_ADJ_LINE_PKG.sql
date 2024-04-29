--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_LINE_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftoals.pls 120.3 2006/03/29 17:27:30 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Line_PKG
-- Purpose
--
-- History
--        Wed Mar 29 2006:5/5 PM RSSHARMA Added end date column
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
          px_offer_adjustment_line_id   IN OUT NOCOPY NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_accrual_flag    VARCHAR2,
          p_list_line_id_td    NUMBER,
          p_original_discount_td    NUMBER,
          p_modified_discount_td    NUMBER,
          p_quantity    NUMBER ,
          p_created_from_adjustments VARCHAR2,
          p_discount_end_date DATE);





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
          p_offer_adjustment_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_accrual_flag    VARCHAR2,
          p_list_line_id_td    NUMBER,
          p_original_discount_td    NUMBER,
          p_modified_discount_td    NUMBER,
          p_quantity    NUMBER ,
          p_created_from_adjustments VARCHAR2,
          p_discount_end_date DATE);





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
    p_offer_adjustment_line_id  NUMBER,
    p_object_version_number  NUMBER);




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
    p_offer_adjustment_line_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_Offer_Adj_Line_PKG;

 

/
