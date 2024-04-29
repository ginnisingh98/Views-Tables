--------------------------------------------------------
--  DDL for Package AMS_IBA_PS_STRATS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PS_STRATS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amststrs.pls 120.0 2005/06/01 02:31:18 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_STRATS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_strategy_id   IN OUT NOCOPY NUMBER,
          p_max_returned    NUMBER,
          p_strategy_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_strategy_ref_code    VARCHAR2,
          p_selector_class    VARCHAR2,
          p_strategy_name   IN VARCHAR2,
          p_strategy_description    IN VARCHAR2);


PROCEDURE Update_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_strategy_id    NUMBER,
          p_max_returned    NUMBER,
          p_strategy_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_strategy_ref_code    VARCHAR2,
          p_selector_class    VARCHAR2,
          p_strategy_name   IN VARCHAR2,
          p_strategy_description    IN VARCHAR2);


PROCEDURE Delete_Row(
    p_STRATEGY_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Lock_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_strategy_id    NUMBER,
          p_max_returned    NUMBER,
          p_strategy_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_strategy_ref_code    VARCHAR2,
          p_selector_class    VARCHAR2);

PROCEDURE TRANSLATE_ROW (
         x_strategy_id  IN NUMBER,
         x_strategy_name  IN VARCHAR2,
         x_strategy_description   IN VARCHAR2,
         x_owner    IN VARCHAR2,
	 x_custom_mode IN VARCHAR2
        );

PROCEDURE LOAD_ROW (
          X_STRATEGY_ID      IN NUMBER,
          X_MAX_RETURNED     IN NUMBER,
          X_CONTENT_TYPE        IN VARCHAR2,
          X_STRATEGY_TYPE       IN VARCHAR2,
          X_STRATEGY_REF_CODE       IN VARCHAR2,
          X_SELECTOR_CLASS     IN VARCHAR2,
          X_STRATEGY_NAME         IN VARCHAR2,
          X_STRATEGY_DESCRIPTION  IN VARCHAR2,
          X_OWNER              IN VARCHAR2,
	  X_CUSTOM_MODE		IN VARCHAR2
         );

END AMS_IBA_PS_STRATS_B_PKG;

 

/
