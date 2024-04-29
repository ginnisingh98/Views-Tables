--------------------------------------------------------
--  DDL for Package OZF_THRESHOLD_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_THRESHOLD_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: ozfttrus.pls 115.1 2003/11/28 12:27:25 pkarthik noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_THRESHOLD_RULES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_threshold_rule_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_period_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_threshold_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_value_limit    VARCHAR2,
          p_operator_code    VARCHAR2,
          p_percent_amount    NUMBER,
          p_base_line    VARCHAR2,
          p_error_mode    VARCHAR2,
          p_repeat_frequency    NUMBER,
          p_frequency_period    VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_converted_days    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_comparison_type    VARCHAR2,
          p_alert_type    VARCHAR2
          );

PROCEDURE Update_Row(
          p_threshold_rule_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          --p_creation_date    DATE,
          --p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_period_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_threshold_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_value_limit    VARCHAR2,
          p_operator_code    VARCHAR2,
          p_percent_amount    NUMBER,
          p_base_line    VARCHAR2,
          p_error_mode    VARCHAR2,
          p_repeat_frequency    NUMBER,
          p_frequency_period    VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_converted_days    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_comparison_type    VARCHAR2,
          p_alert_type    VARCHAR2
          );

PROCEDURE Delete_Row(
    p_THRESHOLD_RULE_ID  NUMBER);


PROCEDURE Lock_Row(
          p_threshold_rule_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_period_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_threshold_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_value_limit    VARCHAR2,
          p_operator_code    VARCHAR2,
          p_percent_amount    NUMBER,
          p_base_line    VARCHAR2,
          p_error_mode    VARCHAR2,
          p_repeat_frequency    NUMBER,
          p_frequency_period    VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_converted_days    NUMBER,
          p_object_version_number    NUMBER);

END OZF_THRESHOLD_RULES_PKG;

 

/
