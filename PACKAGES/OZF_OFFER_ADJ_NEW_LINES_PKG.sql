--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_NEW_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_NEW_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftanls.pls 120.0 2006/03/30 13:48:47 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJ_NEW_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_offer_adj_new_line_id   IN OUT NOCOPY  NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_td_discount NUMBER,
          p_td_discount_type VARCHAR2,
          p_quantity NUMBER,
          p_benefit_price_list_line_id NUMBER,
          p_parent_adj_line_id NUMBER,
          p_start_date_active DATE,
          p_end_date_active DATE,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER);

--
--  ========================================================
PROCEDURE Update_Row(
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_td_discount NUMBER,
          p_td_discount_type VARCHAR2,
          p_quantity NUMBER,
          p_benefit_price_list_line_id NUMBER,
          p_parent_adj_line_id NUMBER,
          p_start_date_active DATE,
          p_end_date_active DATE,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER);

PROCEDURE Delete_Row(
    p_OFFER_ADJ_NEW_LINE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_td_discount NUMBER,
          p_td_discount_type VARCHAR2,
          p_quantity NUMBER,
          p_benefit_price_list_line_id NUMBER,
          p_parent_adj_line_id NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER);

END OZF_OFFER_ADJ_NEW_LINES_PKG;

 

/
