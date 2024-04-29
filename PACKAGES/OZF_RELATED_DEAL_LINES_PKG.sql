--------------------------------------------------------
--  DDL for Package OZF_RELATED_DEAL_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RELATED_DEAL_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftords.pls 120.0 2005/06/01 03:24:36 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RELATED_DEAL_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_related_deal_lines_id   IN OUT NOCOPY NUMBER,
          p_modifier_id    NUMBER,
          p_related_modifier_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          --p_security_group_id    NUMBER,
          p_estimated_qty_is_max    VARCHAR2,
          p_estimated_amount_is_max    VARCHAR2,
          p_estimated_qty    NUMBER,
          p_estimated_amount    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_estimate_qty_uom  VARCHAR2);

PROCEDURE Update_Row(
          p_related_deal_lines_id    NUMBER,
          p_modifier_id    NUMBER,
          p_related_modifier_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          --p_security_group_id    NUMBER,
          p_estimated_qty_is_max    VARCHAR2,
          p_estimated_amount_is_max    VARCHAR2,
          p_estimated_qty    NUMBER,
          p_estimated_amount    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_estimate_qty_uom  VARCHAR2);

PROCEDURE Delete_Row(
    p_RELATED_DEAL_LINES_ID  NUMBER);
PROCEDURE Lock_Row(
          p_related_deal_lines_id    NUMBER,
          p_modifier_id    NUMBER,
          p_related_modifier_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          --p_security_group_id    NUMBER,
          p_estimated_qty_is_max    VARCHAR2,
          p_estimated_amount_is_max    VARCHAR2,
          p_estimated_qty    NUMBER,
          p_estimated_amount    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_estimate_qty_uom  VARCHAR2);

END OZF_RELATED_DEAL_LINES_PKG;

 

/
