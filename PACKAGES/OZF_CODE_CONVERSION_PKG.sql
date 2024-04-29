--------------------------------------------------------
--  DDL for Package OZF_CODE_CONVERSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CODE_CONVERSION_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftsccs.pls 120.1 2007/12/21 07:44:37 gdeepika ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Code_Conversion_PKG
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
          px_code_conversion_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_party_id    NUMBER,
          p_cust_account_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2
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
          p_code_conversion_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_org_id    NUMBER,
          p_party_id    NUMBER,
          p_cust_account_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2);





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
    p_code_conversion_id  NUMBER,
    p_object_version_number  NUMBER);


--  ========================================================
--
--  NAME
--  Insert_Supp_Code_Conv_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Supp_Code_Conv_Row(
          px_code_conversion_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_supp_trade_profile_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2
);





--  ========================================================
--
--  NAME
--  Update_Supp_Code_Conv_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Supp_Code_Conv_Row(
          p_code_conversion_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_org_id    NUMBER,
          p_supp_trade_profile_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2);





--  ========================================================
--
--  NAME
--  Delete_Supp_Code_Conv_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Supp_Code_Conv_Row(
    p_code_conversion_id  NUMBER,
    p_object_version_number  NUMBER);
END OZF_Code_Conversion_PKG;

/
