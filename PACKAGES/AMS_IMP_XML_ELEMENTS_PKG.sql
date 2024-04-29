--------------------------------------------------------
--  DDL for Package AMS_IMP_XML_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMP_XML_ELEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: amslxels.pls 115.5 2002/11/12 23:34:27 jieli noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IMP_XML_ELEMENTS_PKG
-- Purpose
--    Manage XML Elements.
--
-- History
--    05/13/2002 DMVINCEN  Created.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_imp_xml_element_id   IN OUT NOCOPY NUMBER,
          p_last_updated_by    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_last_update_date    DATE,
          p_creation_date    DATE,
          p_imp_xml_document_id    NUMBER,
          p_order_initial    NUMBER,
          p_order_final    NUMBER,
          p_column_name    VARCHAR2,
          p_data    VARCHAR2,
          p_num_attr    NUMBER,
          p_data_type    VARCHAR2,
          p_load_status    VARCHAR2,
          p_error_text    VARCHAR2);

PROCEDURE Update_Row(
          p_imp_xml_element_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER,
          -- p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_last_update_date    DATE,
          -- p_creation_date    DATE,
          p_imp_xml_document_id    NUMBER,
          p_order_initial    NUMBER,
          p_order_final    NUMBER,
          p_column_name    VARCHAR2,
          p_data    VARCHAR2,
          p_num_attr    NUMBER,
          p_data_type    VARCHAR2,
          p_load_status    VARCHAR2,
          p_error_text    VARCHAR2);

PROCEDURE Delete_Row(
    p_IMP_XML_ELEMENT_ID  NUMBER);
PROCEDURE Lock_Row(
          p_imp_xml_element_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_last_update_date    DATE,
          p_creation_date    DATE,
          p_imp_xml_document_id    NUMBER,
          p_order_initial    NUMBER,
          p_order_final    NUMBER,
          p_column_name    VARCHAR2,
          p_data    VARCHAR2,
          p_num_attr    NUMBER,
          p_data_type    VARCHAR2,
          p_load_status    VARCHAR2,
          p_error_text    VARCHAR2);

END AMS_IMP_XML_ELEMENTS_PKG;

 

/
