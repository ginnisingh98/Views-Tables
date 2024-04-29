--------------------------------------------------------
--  DDL for Package RG_REPORT_DISPLAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_DISPLAY_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirdpgs.pls 120.2 2002/11/14 03:00:58 djogg ship $ */
--
-- Package
--   RG_REPORT_DISPLAY_GROUPS_PKG
-- Purpose
--   To create RG_REPORT_DISPLAY_GROUPS_PKG package.
-- History
--   01.24.94   A. Chen    Created
--

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure new display group name is unique.
  -- History
  --   01.24.94   A. Chen   Created
  -- Arguments
  --   X_rowid    The ID of the row to be checked
  --   X_name     The display group name to be checked
  -- Example
  --   RG_REPORT_DISPLAY_GROUPS_PKG.check_unique( '12345', 'Display Group 1' );
  -- Notes
  --
  PROCEDURE check_unique( X_rowid  VARCHAR2,
                          X_name   VARCHAR2 );

  --
  -- Procedure
  --   check_references
  -- Purpose
  --   Ensure the object is not used report display options
  -- History
  --   01.24.94   A. Chen   Created
  -- Arguments
  --   X_display_group_id     The display group id to be checked
  -- Example
  --   RG_REPORT_DISPLAY_GROUPS_PKG.check_references( '12345' );
  -- Notes
  --
  PROCEDURE check_references(X_report_display_group_id NUMBER);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a new sequence unique id for a new display groups.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   none
  -- Example
  --   :display_groups.report_display_group_id := RG_REPORT_DISPLAY_GROUPS_PKG.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

-- *********************************************************************

-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_group_id              NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
                     X_from_sequence                        NUMBER,
                     X_to_sequence                          NUMBER,
                     X_creation_date                        DATE,
                     X_created_by                           NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
                     X_context                              VARCHAR2,
                     X_attribute1                           VARCHAR2,
                     X_attribute2                           VARCHAR2,
                     X_attribute3                           VARCHAR2,
                     X_attribute4                           VARCHAR2,
                     X_attribute5                           VARCHAR2,
                     X_attribute6                           VARCHAR2,
                     X_attribute7                           VARCHAR2,
                     X_attribute8                           VARCHAR2,
                     X_attribute9                           VARCHAR2,
                     X_attribute10                          VARCHAR2,
                     X_attribute11                          VARCHAR2,
                     X_attribute12                          VARCHAR2,
                     X_attribute13                          VARCHAR2,
                     X_attribute14                          VARCHAR2,
                     X_attribute15                          VARCHAR2
                     );

PROCEDURE lock_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                   X_report_display_group_id              NUMBER,
                   X_name                                 VARCHAR2,
                   X_description                          VARCHAR2,
                   X_row_set_id                           NUMBER,
                   X_column_set_id                        NUMBER,
                   X_from_sequence                        NUMBER,
                   X_to_sequence                          NUMBER,
                   X_context                              VARCHAR2,
                   X_attribute1                           VARCHAR2,
                   X_attribute2                           VARCHAR2,
                   X_attribute3                           VARCHAR2,
                   X_attribute4                           VARCHAR2,
                   X_attribute5                           VARCHAR2,
                   X_attribute6                           VARCHAR2,
                   X_attribute7                           VARCHAR2,
                   X_attribute8                           VARCHAR2,
                   X_attribute9                           VARCHAR2,
                   X_attribute10                          VARCHAR2,
                   X_attribute11                          VARCHAR2,
                   X_attribute12                          VARCHAR2,
                   X_attribute13                          VARCHAR2,
                   X_attribute14                          VARCHAR2,
                   X_attribute15                          VARCHAR2
                   );

PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_group_id              NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
                     X_from_sequence                        NUMBER,
                     X_to_sequence                          NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
                     X_context                              VARCHAR2,
                     X_attribute1                           VARCHAR2,
                     X_attribute2                           VARCHAR2,
                     X_attribute3                           VARCHAR2,
                     X_attribute4                           VARCHAR2,
                     X_attribute5                           VARCHAR2,
                     X_attribute6                           VARCHAR2,
                     X_attribute7                           VARCHAR2,
                     X_attribute8                           VARCHAR2,
                     X_attribute9                           VARCHAR2,
                     X_attribute10                          VARCHAR2,
                     X_attribute11                          VARCHAR2,
                     X_attribute12                          VARCHAR2,
                     X_attribute13                          VARCHAR2,
                     X_attribute14                          VARCHAR2,
                     X_attribute15                          VARCHAR2
                     );

PROCEDURE delete_row(X_rowid VARCHAR2);

END RG_REPORT_DISPLAY_GROUPS_PKG;

 

/
