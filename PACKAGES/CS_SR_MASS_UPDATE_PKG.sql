--------------------------------------------------------
--  DDL for Package CS_SR_MASS_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_MASS_UPDATE_PKG" AUTHID CURRENT_USER as
/* $Header: cssrmus.pls 120.0.12010000.3 2009/07/29 09:48:16 mkundali noship $ */

procedure sr_mass_update(p_incident_id_arr in SYSTEM.IBU_NUM_TBL_TYPE,
					  p_status_id in NUMBER,
					  p_resolution_code in VARCHAR2,
					  p_owner_id in NUMBER,
					  p_owner_group_id in NUMBER,
					  p_note_type in VARCHAR2,
					  p_noteVisibility in VARCHAR2,
					  p_noteDetails in VARCHAR2,
					  p_last_updated_by in NUMBER,
					  auto_assign_group_flag in VARCHAR2,
					  auto_assign_owner_flag in VARCHAR2,
					  x_param_incident_id out NOCOPY CS_KB_NUMBER_TBL_TYPE,
					  x_param_status out NOCOPY JTF_VARCHAR2_TABLE_4000,
					  x_param_msg_data out NOCOPY JTF_VARCHAR2_TABLE_4000
					  );



end cs_sr_mass_update_pkg;

/
