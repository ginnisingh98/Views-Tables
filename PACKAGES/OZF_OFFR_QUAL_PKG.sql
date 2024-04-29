--------------------------------------------------------
--  DDL for Package OZF_OFFR_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFR_QUAL_PKG" AUTHID CURRENT_USER AS
 /* $Header: ozftoqfs.pls 120.0 2005/06/01 01:16:42 appldev noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          OZF_Offr_Qual_PKG
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
           px_qualifier_id   IN OUT NOCOPY NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_last_update_login    NUMBER,
           p_qualifier_grouping_no    NUMBER,
           p_qualifier_context    VARCHAR2,
           p_qualifier_attribute    VARCHAR2,
           p_qualifier_attr_value    VARCHAR2,
           p_start_date_active    DATE,
           p_end_date_active    DATE,
           p_offer_id    NUMBER,
           p_offer_discount_line_id    NUMBER,
           p_context    VARCHAR2,
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
           p_attribute15    VARCHAR2,
           p_active_flag    VARCHAR2,
           p_object_version_number NUMBER);





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
           p_qualifier_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_last_update_login    NUMBER,
           p_qualifier_grouping_no    NUMBER,
           p_qualifier_context    VARCHAR2,
           p_qualifier_attribute    VARCHAR2,
           p_qualifier_attr_value    VARCHAR2,
           p_start_date_active    DATE,
           p_end_date_active    DATE,
           p_offer_id    NUMBER,
           p_offer_discount_line_id    NUMBER,
           p_context    VARCHAR2,
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
           p_attribute15    VARCHAR2,
           p_active_flag    VARCHAR2,
           p_object_version_number NUMBER);





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
     p_qualifier_id  NUMBER,
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
     p_qualifier_id  NUMBER,
     p_object_version_number  NUMBER);


 END OZF_Offr_Qual_PKG;

 

/
