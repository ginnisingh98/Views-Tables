--------------------------------------------------------
--  DDL for Package PV_STATUS_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_STATUS_NOTIFICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pvxtsnfs.pls 120.0 2005/07/11 23:13:08 appldev noship $ */

procedure INSERT_ROW (
  px_status_notification_id	 in out nocopy NUMBER,
  px_object_version_number	 in out nocopy NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_creation_date		 in DATE,
  p_created_by			 in NUMBER,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER);

procedure LOCK_ROW (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2
);

procedure UPDATE_ROW (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER
);

procedure UPDATE_ROW_SEED (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER
);

procedure SEED_UPDATE_ROW (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER
);

procedure LOAD_ROW (
  p_upload_mode			 in VARCHAR2,
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_owner			 in VARCHAR2
);
procedure DELETE_ROW (
  p_STATUS_NOTIFICATION_ID in NUMBER
);
end PV_STATUS_NOTIFICATIONS_PKG;

 

/
