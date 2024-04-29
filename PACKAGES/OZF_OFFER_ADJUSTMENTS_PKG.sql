--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftobds.pls 120.0 2005/06/01 01:17:18 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJUSTMENTS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_offer_adjustment_id   IN OUT NOCOPY NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_comments    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Update_Row(
          p_offer_adjustment_id    NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_comments    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Delete_Row(
    p_OFFER_ADJUSTMENT_ID  NUMBER);
PROCEDURE Lock_Row(
          p_offer_adjustment_id    NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_comments    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER);

END OZF_OFFER_ADJUSTMENTS_PKG;

 

/
