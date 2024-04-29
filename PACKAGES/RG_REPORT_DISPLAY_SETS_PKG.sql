--------------------------------------------------------
--  DDL for Package RG_REPORT_DISPLAY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_DISPLAY_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirdpss.pls 120.2 2002/11/14 03:01:15 djogg ship $ */
--
-- Package
--   RG_REPORT_DISPLAY_SETS_PKG
-- Purpose
--   To create RG_REPORT_DISPLAY_SETS_PKG package.
-- History
--   01.12.94   A. Chen    Created
--

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure new display sets name is unique.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_rowid    The ID of the row to be checked
  --   X_name     The display sets name to be checked
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_unique( '12345', 'Display Set 1' );
  -- Notes
  --
  PROCEDURE check_unique( X_rowid  VARCHAR2,
                          X_name   VARCHAR2 );

  --
  -- Procedure
  --   check_references
  -- Purpose
  --   Ensure the object is not used reports
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_display_set_id     The display set id to be checked
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_references( '12345' );
  -- Notes
  --
  PROCEDURE check_references(X_report_display_set_id NUMBER);

  --
  -- Procedure
  --   check_display_exists
  -- Purpose
  --   Check whether a display set has display options.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_display_set_id     The display set id to be checked
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_display_exists( '12345' );
  -- Notes
  --
  FUNCTION check_display_exists(X_report_display_set_id NUMBER)
           RETURN BOOLEAN;

  --
  -- Procedure
  --   check_displays_row_set
  -- Purpose
  --   To check whether updating the row set in a display set
  --   is allowed.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_rowid                The rowid of the display set
  --   X_display_set_id       The display set id to be checked
  --   X_row_set_id_saved     The original row set id
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_displays_row_set(:display_sets.row_id,
  --        :display_sets.report_display_set_id,
  --        :display_sets.row_set_id_saved)
  -- Notes
  --
  FUNCTION check_displays_row_set(X_rowid VARCHAR2,
                                   X_report_display_set_id NUMBER,
                                   X_row_set_id_saved NUMBER)
           RETURN BOOLEAN;

  --
  -- PROCEDURE
  --   check_reports_row_set
  -- Purpose
  --   To check whether updating the row set in a display set
  --   is allowed.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_rowid                The rowid of the display set
  --   X_display_set_id       The display set id to be checked
  --   X_row_set_id           The new row set id to be checked
  --   X_row_set_id_saved     The original row set id
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_reports_row_set(:display_sets.row_id,
  --        :display_sets.report_display_set_id,
  --        :display_sets.row_set_id,
  --        :display_sets.row_set_id_saved)
  -- Notes
  --
  FUNCTION check_reports_row_set(X_rowid VARCHAR2,
                                  X_report_display_set_id NUMBER,
                                  X_row_set_id NUMBER,
                                  X_row_set_id_saved NUMBER)
           RETURN BOOLEAN;

  --
  -- Procedure
  --   check_displays_column_set
  -- Purpose
  --   To check whether updating the column set in a display set
  --   is allowed.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_rowid                The rowid of the display set
  --   X_display_set_id       The display set id to be checked
  --   X_column_set_id_saved  The original column set id
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_displays_column_set(:display_sets.row_id,
  --        :display_sets.report_display_set_id,
  --        :display_sets.column_set_id_save)
  -- Notes
  --
  FUNCTION check_displays_column_set(X_rowid VARCHAR2,
                             X_report_display_set_id NUMBER,
                             X_column_set_id_saved NUMBER)
           RETURN BOOLEAN;

  --
  -- Procedure
  --   check_reports_column_set
  -- Purpose
  --   To check whether updating the column set in a display set
  --   is allowed.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   X_rowid                The rowid of the display set
  --   X_display_set_id       The display set id to be checked
  --   X_column_set_id        The new column set id to be checked
  --   X_column_set_id_saved  The original column set id
  -- Example
  --   RG_REPORT_DISPLAY_SETS_PKG.check_reports_column_set(:display_sets.row_id,
  --        :display_sets.report_display_set_id,
  --        :display_sets.column_set_id,
  --        :display_sets.column_set_id_save)
  -- Notes
  --
  FUNCTION check_reports_column_set(X_rowid VARCHAR2,
                                     X_report_display_set_id NUMBER,
                                     X_column_set_id NUMBER,
                                     X_column_set_id_saved NUMBER)
           RETURN BOOLEAN;

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a new sequence unique id for a new display sets.
  -- History
  --   01.12.94   A. Chen   Created
  -- Arguments
  --   none
  -- Example
  --   :display_sets.report_display_set_id := RG_REPORT_DISPLAY_SETS_PKG.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

-- *********************************************************************

-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
                     X_report_display_set_id                NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
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
                   X_report_display_set_id                NUMBER,
                   X_name                                 VARCHAR2,
                   X_description                          VARCHAR2,
                   X_row_set_id                           NUMBER,
                   X_column_set_id                        NUMBER,
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
                     X_report_display_set_id                NUMBER,
                     X_name                                 VARCHAR2,
                     X_description                          VARCHAR2,
                     X_row_set_id                           NUMBER,
                     X_column_set_id                        NUMBER,
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

END RG_REPORT_DISPLAY_SETS_PKG;

 

/
