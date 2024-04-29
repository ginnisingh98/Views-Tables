--------------------------------------------------------
--  DDL for Package GL_IMPORT_REFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_IMPORT_REFERENCES_PKG" AUTHID CURRENT_USER as
/* $Header: gliimrfs.pls 120.2 2005/05/05 01:08:48 kvora noship $ */

  -- Procedure
  --   delete_line
  -- Purpose
  --   deletes the line
  --   is unique within the header.
  -- Arguments
  --   header_id        The ID of the header
  --   line_num         The line number to check

  -- Example
  --   gl_import_references_pkg.delete_line(2002, 10 );
  -- Notes
  --


   PROCEDURE delete_line(X_header_id NUMBER, X_line_num NUMBER );
  -- Procedure
  --   delete_lines
  -- Purpose
  --   deletes all the lines
  --   within the header.
  -- Arguments
  --   header_id        The ID of the header

  -- Example
  --   gl_import_references_pkg.delete_lines(2002 );
  -- Notes
  --


   PROCEDURE delete_lines (X_header_id NUMBER );

  --
  -- Procedure
  --   delete_header
  -- Purpose
  --   Deletes all of the lines for a given header.
  -- Arguments
  --   header_id 	The ID of the header
  -- Example
  --   gl_import_references_pkg.delete_header(1002);
  -- Notes
  --
   PROCEDURE delete_header(X_header_id NUMBER );

  --
  -- Procedure
  --  delete_batches
  -- Purpose
  --  deletes all the lines for a given batch.
  -- Arguments
  --   batch_id 	   The ID of the batch
  -- Example
  --   gl_import_references_pkg.delete_batch(1002);
  -- Notes
  --
   PROCEDURE delete_batch(X_batch_id	NUMBER);

END GL_IMPORT_REFERENCES_PKG;

 

/
