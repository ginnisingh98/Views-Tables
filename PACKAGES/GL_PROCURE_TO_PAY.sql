--------------------------------------------------------
--  DDL for Package GL_PROCURE_TO_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PROCURE_TO_PAY" AUTHID CURRENT_USER AS
/* $Header: gluprocs.pls 120.1 2002/11/12 00:03:09 djogg ship $ */
--
-- Package
--   GL_PROCURE_TO_PAY
-- Purpose
--   This package is used to export the data from GL_INTERFACE to a flat file.
--   This package was originally created for the Shooman Project
--   (building tight integration between Oracle Exchange and ERP applications)
-- History
--   04-18-01  	O Monnier       Created
--

  --
  -- Procedure
  --   export_from_gl_interface
  -- Purpose
  --   Export all data from GL_INTERFACE into a flat file and purge GL_INTERFACE.
  -- Details
  --   By default, all rows existing in GL_INTERFACE are exported to the file.
  --   Before the export, all existing rows are inserted into the GL_INTERFACE_HISTORY
  --   table. After the export, all exported rows are deleted from the GL_INTERFACE table.
  --   The data in GL_INTERFACE should use a 5 segments Chart Of Accounts.
  --   All foreign key data in GL_INTERFACE (such as set_of_books_id ...) must
  --   point to existing data (for example, a row must exist for this set_of_books_id
  --   in GL_SETS_OF_BOOKS) except code_combination_id (outer join).
  --   Otherwise, the procedure will raise an exception.
  --   The filename specified must be valid for the platform. If a file with this
  --   name already exists in the system, the exported data will be appended to it.
  --   Otherwise, a brand new file will be created.
  --   The directory selected must be specified in the 'utl_file_dir' parameter of the init.ora file.
  --   The database must have read/write access at the O/S level to the directory specified.
  --   If no directory is specified, the file will be written to the first directory
  --   specified as writable in the 'utl_file_dir' parameter of the init.ora file for the database.
  --   If no directory is specified in this parameter, the procedure will raise an exception.
  --   When choosing the TEXT output type, the values are comma delimited in the
  --   output file. When choosing the XML output type, the values are exported in an XML format.
  -- History
  --   04-18-01   O Monnier		Created
  -- Arguments
  --   x_filename		        The file name
  --   x_dir		            The directory
  --   x_output_type            The output type (TEXT or XML)
  PROCEDURE export_from_gl_interface( x_filename               VARCHAR2,
                                      x_dir                    VARCHAR2,
                                      x_output_type            VARCHAR2 );

  --
  -- Procedure
  --   export_from_gl_interface
  -- Purpose
  --   Concurrent job version of export_from_gl_interface.
  -- History
  --   04-18-01   O Monnier		Created
  -- Arguments
  --   errbuf		            Standard error buffer
  --   retcode		            Standard return code
  --   x_filename		        The file name
  --   x_dir		            The directory
  --   x_output_type            The output type (TEXT or XML)
  PROCEDURE export_from_gl_interface(errbuf                 OUT NOCOPY VARCHAR2,
                                     retcode                OUT NOCOPY VARCHAR2,
                                     x_filename             IN VARCHAR2,
                                     x_dir                  IN VARCHAR2,
                                     x_output_type          IN VARCHAR2 );

END GL_PROCURE_TO_PAY;

 

/
