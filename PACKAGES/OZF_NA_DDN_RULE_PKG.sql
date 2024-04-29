--------------------------------------------------------
--  DDL for Package OZF_NA_DDN_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_NA_DDN_RULE_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftdnrs.pls 120.1 2006/02/25 19:23:00 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Ddn_Rule_PKG
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
          px_na_deduction_rule_id   IN OUT NOCOPY NUMBER,
          p_transaction_source_code    VARCHAR2,
          p_transaction_type_code    VARCHAR2,
          p_deduction_identifier_id    VARCHAR2,
          p_deduction_identifier_org_id NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2
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
          p_na_deduction_rule_id    NUMBER,
          p_transaction_source_code    VARCHAR2,
          p_transaction_type_code    VARCHAR2,
          p_deduction_identifier_id    VARCHAR2,
          p_deduction_identifier_org_id NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2
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
    p_na_deduction_rule_id  NUMBER,
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
    p_na_deduction_rule_id  NUMBER,
    p_object_version_number  NUMBER);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           add_language
--   Type
--           Private
--   History
--
--   NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Add_Language;

END OZF_Na_Ddn_Rule_PKG;

 

/
