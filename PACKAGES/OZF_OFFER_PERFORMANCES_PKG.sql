--------------------------------------------------------
--  DDL for Package OZF_OFFER_PERFORMANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_PERFORMANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftpers.pls 120.0 2005/06/01 02:45:48 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_PERFORMANCES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_offer_performance_id   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_product_attribute_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_channel_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_estimated_value    NUMBER,
          p_required_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_security_group_id    NUMBER,
          p_requirement_type  VARCHAR2,
          p_uom_code       VARCHAR2,
          p_description    VARCHAR2);

PROCEDURE Update_Row(
          p_offer_performance_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_product_attribute_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_channel_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_estimated_value    NUMBER,
          p_required_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_security_group_id    NUMBER,
          p_requirement_type  VARCHAR2,
          p_uom_code       VARCHAR2,
          p_description    VARCHAR2);

PROCEDURE Delete_Row(
    p_OFFER_PERFORMANCE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_offer_performance_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_product_attribute_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_channel_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_estimated_value    NUMBER,
          p_required_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_security_group_id    NUMBER,
          p_requirement_type  VARCHAR2,
          p_uom_code       VARCHAR2,
          p_description    VARCHAR2);

END OZF_OFFER_PERFORMANCES_PKG;

 

/
