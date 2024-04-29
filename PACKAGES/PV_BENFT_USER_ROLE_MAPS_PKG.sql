--------------------------------------------------------
--  DDL for Package PV_BENFT_USER_ROLE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_BENFT_USER_ROLE_MAPS_PKG" AUTHID CURRENT_USER as
/* $Header: pvxtulms.pls 120.0 2005/07/11 23:13:10 appldev noship $ */

procedure INSERT_ROW (
  px_user_role_map_id		IN OUT NOCOPY NUMBER,
  px_object_version_number	IN OUT NOCOPY NUMBER,
  p_benefit_type		in VARCHAR2,
  p_user_role_code		in VARCHAR2,
  p_external_flag		in VARCHAR2,
  p_creation_date		in DATE,
  p_created_by			in NUMBER,
  p_last_update_date		in DATE,
  p_last_updated_by		in NUMBER,
  p_last_update_login		in NUMBER);

procedure LOCK_ROW (
  p_user_role_map_id		in NUMBER,
  p_object_version_number	in NUMBER,
  p_benefit_type		in VARCHAR2,
  p_user_role_code		in VARCHAR2,
  p_external_flag		in VARCHAR2
);

procedure UPDATE_ROW (
  p_user_role_map_id		in NUMBER,
  p_object_version_number	in NUMBER,
  p_benefit_type		in VARCHAR2,
  p_user_role_code		in VARCHAR2,
  p_external_flag		in VARCHAR2,
  p_last_update_date		in DATE,
  p_last_updated_by		in NUMBER,
  p_last_update_login		in NUMBER
);

procedure DELETE_ROW (
  p_user_role_map_id		in NUMBER
);

procedure LOAD_ROW (
  p_upload_mode            IN VARCHAR2,
  p_user_role_map_id	   IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_user_role_code	   IN VARCHAR2,
  p_external_flag	   IN VARCHAR2,
  p_owner		   IN VARCHAR2
);
end PV_BENFT_USER_ROLE_MAPS_PKG;

 

/
