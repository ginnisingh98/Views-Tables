--------------------------------------------------------
--  DDL for Package GL_ENCUMBRANCE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ENCUMBRANCE_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: glietdfs.pls 120.4 2005/12/19 23:01:42 djogg ship $ */
--
-- Package
--   gl_encumbrance_types
-- Purpose
--   To implement various data checking needed for the
--   gl_encumbrance_types table
-- History
--   12-21-93  S. J. Mueller    Created
--

  --
  -- Procedure
  --   check_unique_name
  -- Purpose
  --   Checks to make sure the given encumbrance_type is
  --   unique within gl_encumbrance_types.
  -- History
  --   12-21-93  S. J. Mueller    Created
  -- Arguments
  --   name      	The encumbrance type to be checked
  --   rowid		The ID of the row to be checked
  -- Example
  --   gl_encumbrance_types.check_unique_name('SuperObligation', 'ABD0123');
  -- Notes
  --
  PROCEDURE check_unique_name(x_name   VARCHAR2,
	                      x_row_id VARCHAR2);

  --
  -- Procedure
  --   check_unique_id
  -- Purpose
  --   Checks to make sure the encumbrance_type_id is
  --   unique within gl_encumbrance_types.
  -- History
  --   13-JUL-94  E Wilson    Created
  -- Arguments
  --   etid      	The encumbrance type id to be checked
  --   rowid		The ID of the row to be checked
  -- Example
  --   gl_encumbrance_types.check_unique_id(1, 'ABD0123');
  -- Notes
  --
  PROCEDURE check_unique_id(x_etid   NUMBER,
	                    x_row_id VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique encumbrance type id for a new encumbrance type.
  -- History
  --   12-21-93  S. J. Mueller    Created
  -- Arguments
  --   none
  -- Example
  --   gl_encumbrance_types_pkg.get_unique_id(encumbrance_type_id);
  -- Notes
  --
  PROCEDURE get_unique_id(x_encumbrance_type_id  IN OUT NOCOPY NUMBER);


  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the values of some columns from gl_encumbrance_types associated
  --   with the given encumbrance.
  -- History
  --   01-NOV-94  D. J. Ogg  Created.
  -- Arguments
  --   x_encumbrance_type_id		ID of the desired encumbrance type
  --   x_encumbrance_type		Name of the encumbrance type
  --
  PROCEDURE select_columns(
	      x_encumbrance_type_id			NUMBER,
	      x_encumbrance_type		IN OUT NOCOPY  VARCHAR2);

  --
  -- Function
  --   get_enc_type_all
  -- Purpose
  --   Gets the "ALL" value for encumbrance type. Fix for bug #401290:
  --   for support for different languages.
  -- History
  --   09/12/96  W Ho 	Created
  -- Arguments
  --   enc_type
  -- Returns
  --   TRUE if found, FALSE if not found.
  --   The encumbrance type for "ALL" is returned through the parameter
  --   enc_type.
  --
  FUNCTION get_enc_type_all(enc_type IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   Inserts a new row into GL_ENCUMBRANCE_TYPES table
  -- History
  --   16-JUL-1999   K Vora       Created
  -- Arguments
  --   x_rowid                       Rowid
  --   x_encumbrance_type_id         ID of the encumbrance type
  --   x_encumbrance_type_key        Key of the encumbrance type
  --   x_encumbrance_type            Name of the encumbrance type
  --   x_enabled_flag                Enabled flag
  --   x_last_update_date
  --   x_last_updated_by
  --   x_creation_date
  --   x_created_by
  --   x_last_update_login
  --   x_description
  PROCEDURE insert_row(
              x_rowid                       IN OUT NOCOPY  VARCHAR2,
              x_encumbrance_type_id         IN OUT NOCOPY  NUMBER,
              x_encumbrance_type_key        IN OUT NOCOPY  VARCHAR2,
              x_encumbrance_type                IN  VARCHAR2,
              x_enabled_flag                    IN  VARCHAR2,
              x_last_update_date                IN  DATE,
              x_last_updated_by                 IN  NUMBER,
              x_creation_date                   IN  DATE,
              x_created_by                      IN  NUMBER,
              x_last_update_login               IN  NUMBER,
              x_description                     IN  VARCHAR2);

  --
  -- Procedure
  --   update_row
  -- Purpose
  --   Updates a row in GL_ENCUMBRANCE_TYPES table
  -- History
  --   16-JUL-1999   K Vora       Created
  -- Arguments
  --   x_encumbrance_type_id            ID of the encumbrance type
  --   x_encumbrance_type		Name of the encumbrance type
  --   x_enabled_flag                   Enabled flag
  --   x_last_update_date
  --   x_last_updated_by
  --   x_last_update_login
  --   x_description                    Description
  --   x_force_edits                    Y - load row
  --                                    NULL - load row only if owner is SEED
 PROCEDURE update_row(
              x_encumbrance_type_id             IN  NUMBER,
              x_encumbrance_type                IN  VARCHAR2,
              x_enabled_flag                    IN  VARCHAR2,
              x_last_update_date                IN  DATE,
              x_last_updated_by                 IN  NUMBER,
              x_last_update_login               IN  NUMBER,
              x_description                     IN  VARCHAR2);
  --
  -- Procedure
  --   load_row
  -- Purpose
  --   Load row procedure for NLS changes.
  -- History
  --   16-JUL-1999   K Vora       Created
  -- Arguments
  --   x_encumbrance_type_key           Key of the encumbrance type
  --   x_owner                          Indicates seed data or custom data
  --   x_encumbrance_type		Name of the encumbrance type
  --   x_description                    Description
  --   x_enabled_flag                   Enabled flag
  -- Note
  PROCEDURE load_row(
              y_encumbrance_type_key            IN  VARCHAR2,
              y_owner                           IN  VARCHAR2,
              y_encumbrance_type                IN  VARCHAR2,
              y_description                     IN  VARCHAR2,
              y_enabled_flag                    IN  VARCHAR2,
              y_force_edits                     IN  VARCHAR2 default 'N');

  --
  -- Procedure
  --   translate_row
  -- Purpose
  --   Translate row procedure for NLS changes.
  -- History
  --   16-JUL-1999   K Vora       Created
  -- Arguments
  --   x_encumbrance_type_key           ID of the encumbrance type
  --   x_owner                          Indicates seed data or custom data
  --   x_encumbrance_type		Name of the encumbrance type
  --   x_description                    Description
  --   x_enabled_flag                   Enabled flag
  --   x_force_edits                    Y - load row
  --                                    NULL - load row only if owner is SEED
  PROCEDURE translate_row(
            x_encumbrance_type_key            IN  VARCHAR2,
            x_owner                           IN  VARCHAR2,
            x_encumbrance_type		      IN  VARCHAR2,
            x_description                     IN  VARCHAR2,
            x_enabled_flag                    IN  VARCHAR2,
            x_force_edits                     IN  VARCHAR2 default 'N');

END gl_encumbrance_types_pkg;

 

/
