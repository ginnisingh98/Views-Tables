--------------------------------------------------------
--  DDL for Package OZF_NA_RULE_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_NA_RULE_LINE_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftdnls.pls 120.0 2005/06/01 01:07:22 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Rule_Line_PKG
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
          px_na_rule_line_id   IN OUT NOCOPY NUMBER,
          p_na_rule_header_id    NUMBER,
          p_na_deduction_rule_id    NUMBER,
          p_active_flag    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER);





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
          p_na_rule_line_id    NUMBER,
          p_na_rule_header_id    NUMBER,
          p_na_deduction_rule_id    NUMBER,
          p_active_flag    VARCHAR2,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER);





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
    p_na_rule_line_id  NUMBER,
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
    p_na_rule_line_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_Na_Rule_Line_PKG;

 

/
