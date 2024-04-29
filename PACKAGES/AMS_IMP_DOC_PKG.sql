--------------------------------------------------------
--  DDL for Package AMS_IMP_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMP_DOC_PKG" AUTHID CURRENT_USER AS
/* $Header: amstidos.pls 115.3 2002/11/12 23:36:18 jieli noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_Imp_Doc_PKG
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
           px_imp_document_id   IN OUT NOCOPY NUMBER,
           p_last_updated_by    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_last_update_date    DATE,
           p_creation_date    DATE,
           p_import_list_header_id    NUMBER,
           p_content_text    CLOB := NULL,
           p_dtd_text    CLOB := NULL,
           p_file_type    VARCHAR2,
           p_filter_content_text    CLOB := NULL,
           p_file_size    NUMBER
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
           p_imp_document_id    NUMBER,
           p_last_updated_by    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_last_update_login    NUMBER,
           p_last_update_date    DATE,
           p_import_list_header_id    NUMBER,
           p_content_text    CLOB := NULL,
           p_dtd_text    CLOB := NULL,
           p_file_type    VARCHAR2,
           p_filter_content_text    CLOB := NULL,
           p_file_size    NUMBER
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
     p_imp_document_id  NUMBER,
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
     p_imp_document_id  NUMBER);

END AMS_IMP_DOC_PKG;

 

/
