--------------------------------------------------------
--  DDL for Package Body EAM_WB_WR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WB_WR" as
/* $Header: EAMWBWRB.pls 115.3 2002/02/20 19:55:06 pkm ship   $ */

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
	X_attribute15                   VARCHAR2) IS

CURSOR C IS
    SELECT
	work_request_id,
	work_request_number,
	organization_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	asset_number,
	asset_group,
	description,
	work_request_status_id,
	work_request_priority_id,
	work_request_owning_dept,
	expected_resolution_date,
	wip_entity_id,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15
    FROM
	wip_eam_work_requests
    WHERE
	rowid = X_row_id
    FOR UPDATE of wip_entity_id NOWAIT;

Recinfo C%ROWTYPE;

BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
	CLOSE C;
	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
		(Recinfo.work_request_id =  X_work_request_id)
	   AND (Recinfo.work_request_number =  X_work_request_number)
	   AND 	(   (Recinfo.organization_id =  X_organization_id)
		OR (	(Recinfo.organization_id IS NULL)
			AND (X_organization_id IS NULL)))
	   AND 	(   (Recinfo.description =  X_description)
		OR (	(Recinfo.description IS NULL)
			AND (X_description IS NULL)))
	   AND (Recinfo.last_update_date =  X_last_update_date)
	   AND (Recinfo.last_updated_by =  X_last_updated_by)
	   AND (Recinfo.creation_date =  X_creation_date)
	   AND (Recinfo.created_by =  X_created_by)
	   AND (   (Recinfo.last_update_login =  X_last_update_login)
		OR (	(Recinfo.last_update_login IS NULL)
			AND (X_last_update_login IS NULL)))
	   AND (   (Recinfo.asset_number =  X_asset_number)
		OR (	(Recinfo.asset_number IS NULL)
			AND (X_asset_number IS NULL)))
	   AND (   (Recinfo.asset_group =  X_asset_group)
		OR (	(Recinfo.asset_group IS NULL)
			AND (X_asset_group IS NULL)))
	   AND (   (Recinfo.work_request_status_id =  X_work_request_status_id)
		OR (	(Recinfo.work_request_status_id IS NULL)
			AND (X_work_request_status_id IS NULL)))
	   AND (   (Recinfo.work_request_priority_id =  X_work_request_priority_id)
		OR (	(Recinfo.work_request_priority_id IS NULL)
			AND (X_work_request_priority_id IS NULL)))
	   AND (   (Recinfo.work_request_owning_dept =  X_work_request_owning_dept)
		OR (	(Recinfo.work_request_owning_dept IS NULL)
			AND (X_work_request_owning_dept IS NULL)))
	   AND (   (Recinfo.expected_resolution_date =  X_expected_resolution_date)
		OR (	(Recinfo.expected_resolution_date IS NULL)
			AND (X_expected_resolution_date IS NULL)))
	   AND (   (Recinfo.wip_entity_id =  X_wip_entity_id)
		OR (	(Recinfo.wip_entity_id IS NULL)
			AND (X_wip_entity_id IS NULL)))
	   AND (   (Recinfo.attribute_category = X_attribute_category)
		OR (    (Recinfo.attribute_category IS NULL)
			AND (X_attribute_category IS NULL)))
	   AND (   (Recinfo.attribute1 =  X_attribute1)
		OR (	(Recinfo.attribute1 IS NULL)
			AND (X_attribute1 IS NULL)))
	   AND (   (Recinfo.attribute2 =  X_attribute2)
		OR (	(Recinfo.attribute2 IS NULL)
			AND (X_attribute2 IS NULL)))
	   AND (   (Recinfo.attribute3 =  X_attribute3)
		OR (	(Recinfo.attribute3 IS NULL)
			AND (X_attribute3 IS NULL)))
	   AND (   (Recinfo.attribute4 =  X_attribute4)
		OR (	(Recinfo.attribute4 IS NULL)
			AND (X_attribute4 IS NULL)))
	   AND (   (Recinfo.attribute5 =  X_attribute5)
		OR (	(Recinfo.attribute5 IS NULL)
			AND (X_attribute5 IS NULL)))
	   AND (   (Recinfo.attribute6 =  X_attribute6)
		OR (	(Recinfo.attribute6 IS NULL)
			AND (X_attribute6 IS NULL)))
	   AND (   (Recinfo.attribute7 =  X_attribute7)
		OR (	(Recinfo.attribute7 IS NULL)
			AND (X_attribute7 IS NULL)))
	   AND (   (Recinfo.attribute8 =  X_attribute8)
		OR (	(Recinfo.attribute8 IS NULL)
			AND (X_attribute8 IS NULL)))
	   AND (   (Recinfo.attribute9 =  X_attribute9)
		OR (	(Recinfo.attribute9 IS NULL)
			AND (X_attribute9 IS NULL)))
	   AND (   (Recinfo.attribute10 =  X_attribute10)
		OR (	(Recinfo.attribute10 IS NULL)
			AND (X_attribute10 IS NULL)))
	   AND (   (Recinfo.attribute11 =  X_attribute11)
		OR (	(Recinfo.attribute11 IS NULL)
			AND (X_attribute11 IS NULL)))
	   AND (   (Recinfo.attribute12 =  X_attribute12)
		OR (	(Recinfo.attribute12 IS NULL)
			AND (X_attribute12 IS NULL)))
	   AND (   (Recinfo.attribute13 =  X_attribute13)
		OR (	(Recinfo.attribute13 IS NULL)
			AND (X_attribute13 IS NULL)))
	   AND (   (Recinfo.attribute14 =  X_attribute14)
		OR (	(Recinfo.attribute14 IS NULL)
			AND (X_attribute14 IS NULL)))
	   AND (   (Recinfo.attribute15 =  X_attribute15)
		OR (	(Recinfo.attribute15 IS NULL)
			AND (X_attribute15 IS NULL)))
    ) then
	return;
    else
	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
	APP_EXCEPTION.Raise_Exception;
    end if;

END Lock_Row;

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
	X_attribute15                   VARCHAR2) IS

BEGIN
    UPDATE WIP_EAM_WORK_REQUESTS SET
	work_request_id			= X_work_request_id,
	work_request_number		= X_work_request_number,
	organization_id			= X_organization_id,
	last_update_date		= X_last_update_date,
	last_updated_by			= X_last_updated_by,
	last_update_login		= X_last_update_login,
	asset_number			= X_asset_number,
	asset_group			= X_asset_group,
	description			= X_description,
	work_request_status_id		= X_work_request_status_id,
	work_request_priority_id	= X_work_request_priority_id,
	work_request_owning_dept	= X_work_request_owning_dept,
	expected_resolution_date	= X_expected_resolution_date,
	wip_entity_id			= X_wip_entity_id,
	attribute_category		= X_attribute_category,
	attribute1			= X_attribute1,
	attribute2			= X_attribute2,
	attribute3			= X_attribute3,
	attribute4			= X_attribute4,
	attribute5			= X_attribute5,
	attribute6			= X_attribute6,
	attribute7			= X_attribute7,
	attribute8			= X_attribute8,
	attribute9			= X_attribute9,
	attribute10			= X_attribute10,
	attribute11			= X_attribute11,
	attribute12			= X_attribute12,
	attribute13			= X_attribute13,
	attribute14			= X_attribute14,
	attribute15			= X_attribute15

    WHERE
	rowid = X_row_id;

    if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
    end if;

END Update_Row;

END EAM_WB_WR;

/
