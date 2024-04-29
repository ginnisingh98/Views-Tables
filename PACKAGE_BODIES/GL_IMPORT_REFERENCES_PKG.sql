--------------------------------------------------------
--  DDL for Package Body GL_IMPORT_REFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_IMPORT_REFERENCES_PKG" as
/* $Header: gliimrfb.pls 120.2 2005/05/05 01:08:41 kvora noship $ */
  PROCEDURE delete_line(X_header_id NUMBER, X_line_num NUMBER )  IS
       /*    It deletes a line in gl_import_references
             when a corresponding line is deleted in je_lines  */
  BEGIN
          DELETE FROM GL_IMPORT_REFERENCES
          WHERE  je_header_id = X_header_id
          AND je_line_num = X_line_num;

  EXCEPTION
      WHEN NO_DATA_FOUND then
           null;
  END delete_line;

  PROCEDURE delete_lines(X_header_id NUMBER )  IS
       /*    It deletes all lines in gl_import_references
             when a corresponding line is deleted in je_lines  */

  BEGIN
          DELETE FROM GL_IMPORT_REFERENCES
          WHERE  je_header_id = X_header_id;

  EXCEPTION
      WHEN NO_DATA_FOUND then
           null;
  END delete_lines;

  PROCEDURE delete_header(X_header_id NUMBER ) IS
    /*   It Deletes a header in gl_import_references while a header
         is deleted gl_je_headers     */
  BEGIN
            DELETE FROM GL_IMPORT_REFERENCES
            WHERE  je_header_id = X_header_id;

  EXCEPTION
            WHEN NO_DATA_FOUND then
            null;
  END delete_header;

  PROCEDURE delete_batch(X_batch_id NUMBER ) IS
      /*  It deletes a batch in gl_import_references while a batch
          is deleted in gl_je_batches*/
  BEGIN
            DELETE FROM GL_IMPORT_REFERENCES
            WHERE  je_header_id IN
	    (select je_header_id FROM gl_je_headers WHERE je_batch_id = X_batch_id );

  EXCEPTION
            WHEN NO_DATA_FOUND then
            null;
  END delete_batch;

END GL_IMPORT_REFERENCES_PKG;

/
