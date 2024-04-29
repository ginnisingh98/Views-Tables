--------------------------------------------------------
--  DDL for Package GL_MOVEMERGE_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MOVEMERGE_ACCOUNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: glimmacs.pls 120.3 2005/05/05 01:17:29 kvora ship $ */
 --
 -- Package
 --  gl_movemerge_accounts_pkg
 -- Purpose
 --  server routines related to table gl_movemerge_accounts
 -- History
 --  3/6/1997   Mike Marra      Created
 --

  --
  -- PUBLIC methods
  --

  --
  -- Procedure
  --   line_number_is_unique
  -- Purpose
  --   Enforces unique constraint on column
  --   GL_MOVEMERGE_ACCOUNTS.line_number
  --   for a given request.
  -- History
  --   03-06-1997  Mike Marra    Created
  -- Notes
  --   Raises GL_DUPLICATE_JE_LINE_NUM on failure
  PROCEDURE line_number_is_unique  (
    mm_id  IN NUMBER,
    lineno IN NUMBER,
    row_id IN CHAR
  );


  --
  -- Procedure
  --   source_spec_is_unique
  -- Purpose
  --   Enforces unique constraint over columns
  --   GL_MOVEMERGE_ACCOUNTS.source_segmentN
  --   conditionally, for movemerge type requests
  -- History
  --   03-05-1997  Mike Marra    Created
  -- Notes
  --   Raises GL_MM_SOURCE_NOT_UNIQUE on failure
  PROCEDURE source_spec_is_unique  (
    mm_id IN NUMBER,     row_id IN CHAR,
    ss1   IN VARCHAR2,   ss2    IN VARCHAR2,
    ss3   IN VARCHAR2,   ss4    IN VARCHAR2,
    ss5   IN VARCHAR2,   ss6    IN VARCHAR2,
    ss7   IN VARCHAR2,   ss8    IN VARCHAR2,
    ss9   IN VARCHAR2,   ss10   IN VARCHAR2,
    ss11  IN VARCHAR2,   ss12   IN VARCHAR2,
    ss13  IN VARCHAR2,   ss14   IN VARCHAR2,
    ss15  IN VARCHAR2,   ss16   IN VARCHAR2,
    ss17  IN VARCHAR2,   ss18   IN VARCHAR2,
    ss19  IN VARCHAR2,   ss20   IN VARCHAR2,
    ss21  IN VARCHAR2,   ss22   IN VARCHAR2,
    ss23  IN VARCHAR2,   ss24   IN VARCHAR2,
    ss25  IN VARCHAR2,   ss26   IN VARCHAR2,
    ss27  IN VARCHAR2,   ss28   IN VARCHAR2,
    ss29  IN VARCHAR2,   ss30   IN VARCHAR2
  );


  -- Name
  --   Pre_Insert
  -- Purpose
  --   Validations before pre_insert on account block
  -- Arguments
  --   name
  --
  PROCEDURE pre_insert(
    mm_id  IN NUMBER,
    lineno IN NUMBER,
    row_id IN CHAR);

END gl_movemerge_accounts_pkg;

 

/
