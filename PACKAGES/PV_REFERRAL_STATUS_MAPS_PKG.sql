--------------------------------------------------------
--  DDL for Package PV_REFERRAL_STATUS_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_REFERRAL_STATUS_MAPS_PKG" AUTHID CURRENT_USER as
/* $Header: pvxtrfms.pls 120.0 2005/07/11 23:13:06 appldev noship $ */


procedure INSERT_ROW (
  px_referral_status_map_id	IN OUT NOCOPY NUMBER,
  px_object_version_number	IN OUT NOCOPY NUMBER,
  p_benefit_type		IN VARCHAR2,
  p_status_code			IN VARCHAR2,
  p_map_status_code		IN VARCHAR2,
  p_creation_date		IN DATE,
  p_created_by			IN NUMBER,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER);


procedure LOCK_ROW (
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code            IN VARCHAR2,
  p_map_status_code        IN VARCHAR2
);

procedure UPDATE_ROW (
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code		   IN VARCHAR2,
  p_map_status_code	   IN VARCHAR2,
  p_last_update_date	   IN DATE,
  p_last_updated_by	   IN NUMBER,
  p_last_update_login	   IN NUMBER
);

procedure DELETE_ROW (
  p_referral_status_map_id in NUMBER
);

procedure LOAD_ROW (
  p_upload_mode            IN VARCHAR2,
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code		   IN VARCHAR2,
  p_map_status_code	   IN VARCHAR2,
  p_owner		   IN VARCHAR2
);
end PV_REFERRAL_STATUS_MAPS_PKG;

 

/
