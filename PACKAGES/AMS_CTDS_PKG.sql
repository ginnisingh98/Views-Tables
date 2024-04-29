--------------------------------------------------------
--  DDL for Package AMS_CTDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CTDS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstctds.pls 120.1 2005/06/03 12:43:08 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CTDS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_ctd_id   IN OUT NOCOPY NUMBER,
          p_action_id    NUMBER,
          p_forward_url    VARCHAR2,
          p_track_url    VARCHAR2,
          p_activity_product_id    NUMBER,
          p_activity_offer_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Update_Row(
          p_ctd_id    NUMBER,
          p_action_id    NUMBER,
          p_forward_url    VARCHAR2,
          p_track_url    VARCHAR2,
          p_activity_product_id    NUMBER,
          p_activity_offer_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Delete_Row(
    p_CTD_ID  NUMBER);

PROCEDURE Lock_Row(
          p_ctd_id    NUMBER,
          p_action_id    NUMBER,
          p_forward_url    VARCHAR2,
          p_track_url    VARCHAR2,
          p_activity_product_id    NUMBER,
          p_activity_offer_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_security_group_id    NUMBER);

procedure LOAD_ROW(
	X_CTD_ID IN NUMBER,
	X_ACTION_ID IN NUMBER,
	X_FORWARD_URL IN VARCHAR2,
	X_TRACK_URL IN VARCHAR2,
	X_ACTIVITY_PRODUCT_ID IN NUMBER,
	X_ACTIVITY_OFFER_ID IN NUMBER,
	X_OWNER in  VARCHAR2,
	X_CUSTOM_MODE in VARCHAR2
);


PROCEDURE TRANSLATE_ROW (
	X_CTD_ID IN NUMBER,
	X_OWNER IN VARCHAR2,
	X_CUSTOM_MODE IN VARCHAR2
);

END AMS_CTDS_PKG;

 

/
