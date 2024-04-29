--------------------------------------------------------
--  DDL for Package AMS_VENUE_RATES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_VENUE_RATES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstvrts.pls 115.6 2003/03/28 23:19:25 soagrawa ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_VENUE_RATES_B_PKG
-- Purpose
--
-- History
--   10-MAY-2002  GMADANA    Added Rate_code.
--   28-mar-2003  soagrawa   Added add_language. Bug# 2876033
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_rate_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_active_flag    VARCHAR2,
          p_venue_id    NUMBER,
          p_metric_id    NUMBER,
          p_transactional_value    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_value    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_rate_code   VARCHAR2,
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
	  p_description    VARCHAR2);

PROCEDURE Update_Row(
          p_rate_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_venue_id    NUMBER,
          p_metric_id    NUMBER,
          p_transactional_value    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_value    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_rate_code   VARCHAR2,
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
	  p_description    VARCHAR2);

PROCEDURE Delete_Row(
    p_RATE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_rate_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_venue_id    NUMBER,
          p_metric_id    NUMBER,
          p_transactional_value    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_value    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_rate_code   VARCHAR2,
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

PROCEDURE ADD_LANGUAGE;

END AMS_VENUE_RATES_B_PKG;

 

/
