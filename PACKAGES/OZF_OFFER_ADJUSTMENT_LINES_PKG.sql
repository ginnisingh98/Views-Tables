--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJUSTMENT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJUSTMENT_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftobcs.pls 120.0 2005/06/01 00:39:16 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJUSTMENT_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

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
          p_security_group_id    NUMBER);

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
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Delete_Row(
    p_OFFER_ADJUSTMENT_LINE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_offer_adjustment_line_id    NUMBER,
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
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER);

END OZF_OFFER_ADJUSTMENT_LINES_PKG;

 

/
