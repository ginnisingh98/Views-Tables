--------------------------------------------------------
--  DDL for Package GCS_SYSTEM_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_SYSTEM_TASKS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcssystasks.pls 120.1 2005/10/30 05:19:08 appldev noship $ */


  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_system_tasks table.
  -- Arguments
  --   row_id
  --   task_code
  --   status_code
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_SYSTEM_TASKS_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	                VARCHAR2,
				task_code			VARCHAR2,
                        	status_code	                VARCHAR2,
				creation_date			DATE,
				created_by			NUMBER,
				last_update_date		DATE,
				last_updated_by			NUMBER,
				last_update_login		NUMBER,
                        	object_version_number           NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_system_tasks table.
  -- Arguments
  --   row_id
  --   task_code
  --   status_code
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_SYSTEM_TASKS_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(		row_id	IN OUT NOCOPY	        VARCHAR2,
				task_code			VARCHAR2,
                        	status_code	                VARCHAR2,
				creation_date			DATE,
				created_by			NUMBER,
				last_update_date		DATE,
				last_updated_by			NUMBER,
				last_update_login		NUMBER,
                        	object_version_number           NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_system_tasks table.
  -- Arguments
  --   task_code
  --   owner
  --   last_update_date
  --   status_code

  -- Example
  --   GCS_SYSTEM_TASKS_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(		task_code			VARCHAR2,
				owner				VARCHAR2,
				last_update_date		VARCHAR2,
                        	custom_mode			VARCHAR2,
				status_code			VARCHAR2,
                		object_version_number           NUMBER);

END GCS_SYSTEM_TASKS_PKG;

 

/
