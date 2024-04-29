--------------------------------------------------------
--  DDL for Package EAM_WB_WR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WB_WR" AUTHID CURRENT_USER as
/* $Header: EAMWBWRS.pls 115.3 2002/02/20 19:55:07 pkm ship   $ */

PROCEDURE Lock_Row (
	X_row_id 			VARCHAR2,
	X_work_request_id 		NUMBER,
	X_work_request_number		VARCHAR2,
	X_organization_id               NUMBER,
	X_last_update_date              DATE,
	X_last_updated_by               NUMBER,
	X_creation_date                 DATE,
	X_created_by                    NUMBER,
	X_last_update_login             NUMBER,
	X_asset_number			VARCHAR2,
	X_asset_group			NUMBER,
	X_description                   VARCHAR2,
	X_work_request_status_id	NUMBER,
	X_work_request_priority_id      NUMBER,
	X_work_request_owning_dept      NUMBER,
	X_expected_resolution_date      DATE,
	X_wip_entity_id			NUMBER,
	X_attribute_category		VARCHAR2,
	X_attribute1                    VARCHAR2,
	X_attribute2                    VARCHAR2,
	X_attribute3                    VARCHAR2,
	X_attribute4                    VARCHAR2,
	X_attribute5                    VARCHAR2,
	X_attribute6                    VARCHAR2,
	X_attribute7                    VARCHAR2,
	X_attribute8                    VARCHAR2,
	X_attribute9                    VARCHAR2,
	X_attribute10                   VARCHAR2,
	X_attribute11                   VARCHAR2,
	X_attribute12                   VARCHAR2,
	X_attribute13                   VARCHAR2,
	X_attribute14                   VARCHAR2,
	X_attribute15                   VARCHAR2);

PROCEDURE Update_Row (
	X_row_id 			VARCHAR2,
	X_work_request_id 		NUMBER,
	X_work_request_number		VARCHAR2,
	X_organization_id               NUMBER,
	X_last_update_date              DATE,
	X_last_updated_by               NUMBER,
	X_last_update_login             NUMBER,
	X_asset_number			VARCHAR2,
	X_asset_group			NUMBER,
	X_description                   VARCHAR2,
	X_work_request_status_id	NUMBER,
	X_work_request_priority_id      NUMBER,
	X_work_request_owning_dept      NUMBER,
	X_expected_resolution_date      DATE,
	X_wip_entity_id			NUMBER,
	X_attribute_category		VARCHAR2,
	X_attribute1                    VARCHAR2,
	X_attribute2                    VARCHAR2,
	X_attribute3                    VARCHAR2,
	X_attribute4                    VARCHAR2,
	X_attribute5                    VARCHAR2,
	X_attribute6                    VARCHAR2,
	X_attribute7                    VARCHAR2,
	X_attribute8                    VARCHAR2,
	X_attribute9                    VARCHAR2,
	X_attribute10                   VARCHAR2,
	X_attribute11                   VARCHAR2,
	X_attribute12                   VARCHAR2,
	X_attribute13                   VARCHAR2,
	X_attribute14                   VARCHAR2,
	X_attribute15                   VARCHAR2);

END EAM_WB_WR;

 

/
