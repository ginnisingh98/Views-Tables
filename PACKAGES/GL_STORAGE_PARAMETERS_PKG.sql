--------------------------------------------------------
--  DDL for Package GL_STORAGE_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_STORAGE_PARAMETERS_PKG" AUTHID CURRENT_USER AS
/* $Header: glistpas.pls 120.6 2005/05/05 01:23:57 kvora ship $ */
--
-- Package
--   gl_storage_parameters_pkg
-- Purpose
--   To contain validation and insertion routines for gl_storage_parameters_pkg
-- History
--   07-19-94  	Kai Pigg	Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the storage parameter
  --   is unique.
  -- History
  --   07-19-94  Kai Pigg    Created
  -- Arguments
  --   rid		The current rowid
  -- Example
  --   storage.check_unique();
  -- Notes
  --
  PROCEDURE check_unique(X_object_name VARCHAR2,
			 X_row_id VARCHAR2);

  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into gl_storage_parameters
  -- History
  --   07-19-94  Kai Pigg	Created
  -- Arguments
  -- all the columns of the table GL_STORAGE_PARAMETERS
  -- Example
  --   gl_storage_parameters_pkg.Insert_Row(....;
  -- Notes
  --
  PROCEDURE Insert_Row( X_Rowid                         IN OUT NOCOPY VARCHAR2,
                        X_object_name                   VARCHAR2,
                        X_last_update_date              DATE,
                        X_last_updated_by               NUMBER,
                        X_creation_date                 DATE,
                        X_created_by                    NUMBER,
                        X_last_update_login             NUMBER,
                        X_object_type                   VARCHAR2,
                        X_tablespace_name               VARCHAR2,
                        X_initial_extent_size_kb        NUMBER,
                        X_next_extent_size_kb           NUMBER,
                        X_max_extents                   NUMBER,
                        X_pct_increase                  NUMBER,
                        X_pct_free                      NUMBER,
                        X_description                   VARCHAR2);

  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into gl_storage_parameters
  -- History
  --   07-19-94  Kai Pigg	Created
  -- Arguments
  -- all the columns of the table GL_STORAGE_PARAMETERS
  -- Example
  --   gl_storage_parameters_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row( X_Rowid                         IN OUT NOCOPY VARCHAR2,
                        X_object_name                   VARCHAR2,
                        X_last_update_date              DATE,
                        X_last_updated_by               NUMBER,
                        X_creation_date                 DATE,
                        X_created_by                    NUMBER,
                        X_last_update_login             NUMBER,
                        X_object_type                   VARCHAR2,
                        X_tablespace_name               VARCHAR2,
                        X_initial_extent_size_kb        NUMBER,
                        X_next_extent_size_kb           NUMBER,
                        X_max_extents                   NUMBER,
                        X_pct_increase                  NUMBER,
                        X_pct_free                      NUMBER,
                        X_description                   VARCHAR2);

  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into gl_storage_parameters
  -- History
  --   07-19-94  Kai Pigg	Created
  -- Arguments
  -- all (-who)  the columns of the table GL_STORAGE_PARAMETERS
  -- Example
  --   gl_storage_parameters_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row (   X_Rowid                         IN OUT NOCOPY VARCHAR2,
                        X_object_name                   VARCHAR2,
                        X_object_type                   VARCHAR2,
                        X_tablespace_name               VARCHAR2,
                        X_initial_extent_size_kb        NUMBER,
                        X_next_extent_size_kb           NUMBER,
                        X_max_extents                   NUMBER,
                        X_pct_increase                  NUMBER,
                        X_pct_free                      NUMBER,
                        X_description                   VARCHAR2);

  --
  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from gl_storage_parameters
  -- History
  --   07-19-94  Kai Pigg	Created
  -- Arguments
  -- 	x_rowid		Rowid of a row
  -- Example
  --   gl_storage_parameters.delete_row('001.0000.0000');
  -- Notes
  --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


  --
  -- Procedure
  --  load_row
  -- Purpose
  --   called from loader
  --   update existing data, insert new data
  -- History
  --   07-19-99  A Lal	Created
  -- Arguments
  -- all the columns of the table GL_STORAGE_PARAMETERS
  -- Example
  --   gl_storage_parameters_pkg.load_row(....;

 Procedure load_row(
                x_object_name               in out NOCOPY varchar2,
                x_object_type                   in varchar2,
                x_tablespace_name               in varchar2,
                x_initial_extent_size_kb        in number,
                x_next_extent_size_kb           in number,
                x_max_extents                   in number,
                x_pct_increase                  in number,
                x_description                   in varchar2,
                x_pct_free                      in number,
                x_owner                         in varchar2,
                x_force_edits                   in varchar2
           );


  --
  -- Procedure
  --  translate_row
  -- Purpose
  --   called from loader
  --   Update translation only.
  -- History
  --   07-19-99  A Lal	Created
  -- Arguments
  -- object  name, description, owner and force_edits

Procedure translate_row (
                x_object_name                   in varchar2,
                x_description                   in varchar2,
                x_owner                         in varchar2,
                x_force_edits                   in varchar2
           );

END gl_storage_parameters_pkg;

 

/
