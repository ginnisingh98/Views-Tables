--------------------------------------------------------
--  DDL for Package AMS_ACT_CONTACT_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACT_CONTACT_POINTS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstcons.pls 120.0 2005/05/31 23:39:04 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ACT_CONTACT_POINTS_PKG
-- Purpose
--
-- History
--     20-may-2005    musman	  Added contact_point_value_id column for webadi collaboration script usage

-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_contact_point_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_contact_used_by    VARCHAR2,
          p_act_contact_used_by_id    NUMBER,
          p_contact_point_type    VARCHAR2,
          p_contact_point_value    VARCHAR2,
          p_city    VARCHAR2,
          p_country    NUMBER,
          p_zipcode    VARCHAR2,
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
	  p_contact_point_value_id NUMBER);

PROCEDURE Update_Row(
          p_contact_point_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_arc_contact_used_by    VARCHAR2,
          p_act_contact_used_by_id    NUMBER,
          p_contact_point_type    VARCHAR2,
          p_contact_point_value    VARCHAR2,
          p_city    VARCHAR2,
          p_country    NUMBER,
          p_zipcode    VARCHAR2,
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
	  p_contact_point_value_id NUMBER);

PROCEDURE Delete_Row(
    p_CONTACT_POINT_ID  NUMBER);
PROCEDURE Lock_Row(
          p_CONTACT_POINT_ID  NUMBER);

END AMS_ACT_CONTACT_POINTS_PKG;

 

/
