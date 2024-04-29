--------------------------------------------------------
--  DDL for Package GL_ELIM_ACCOUNTS_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ELIM_ACCOUNTS_MAP_PKG" AUTHID CURRENT_USER As
/* $Header: glieacms.pls 120.4 2005/05/05 01:06:52 kvora ship $ */
 --
 -- Package
 --  gl_elim_accounts_map_pkg
 -- Purpose
 --  Server routines related to table gl_elim_accounts_map
 -- History
 --  11/11/1998   W Wong      Created


  --
  -- Procedure
  --   unique_line_number
  -- Purpose
  --   Make sure line number within each journal is unique
  -- Parameters
  --   None
  -- History
  --   11-06-1998  W Wong    Created
  -- Notes
  --   Raises GL_DUPLICATE_JE_LINE_NUM on failure
  --
  PROCEDURE unique_line_number (
		X_journal_id IN NUMBER,
		X_lineno     IN NUMBER,
		X_rowid      IN VARCHAR2
  );

  --
  -- Procedure
  --   source_spec_is_unique
  -- Purpose
  --   Enforces unique constraint over columns
  --   GL_ELIM_ACCOUNTS_MAP.source_segmentN
  -- History
  --   11-06-1998  W Wong    Created
  -- Notes
  --   Raises GL_ELIM_SOURCE_NOT_UNIQUE on failure
  --
  PROCEDURE source_spec_is_unique  (
    X_journal_id IN NUMBER, X_row_id IN CHAR,
    X_ss1     IN VARCHAR2,   X_ss2    IN VARCHAR2,
    X_ss3     IN VARCHAR2,   X_ss4    IN VARCHAR2,
    X_ss5     IN VARCHAR2,   X_ss6    IN VARCHAR2,
    X_ss7     IN VARCHAR2,   X_ss8    IN VARCHAR2,
    X_ss9     IN VARCHAR2,   X_ss10   IN VARCHAR2,
    X_ss11    IN VARCHAR2,   X_ss12   IN VARCHAR2,
    X_ss13    IN VARCHAR2,   X_ss14   IN VARCHAR2,
    X_ss15    IN VARCHAR2,   X_ss16   IN VARCHAR2,
    X_ss17    IN VARCHAR2,   X_ss18   IN VARCHAR2,
    X_ss19    IN VARCHAR2,   X_ss20   IN VARCHAR2,
    X_ss21    IN VARCHAR2,   X_ss22   IN VARCHAR2,
    X_ss23    IN VARCHAR2,   X_ss24   IN VARCHAR2,
    X_ss25    IN VARCHAR2,   X_ss26   IN VARCHAR2,
    X_ss27    IN VARCHAR2,   X_ss28   IN VARCHAR2,
    X_ss29    IN VARCHAR2,   X_ss30   IN VARCHAR2
  );

  --
  -- Procedure
  --   get_bal_seg_num
  -- Purpose
  --   Get the balancing segment number
  -- History
  --   12-17-1998  W Wong    Created
  -- Notes
  --
  PROCEDURE get_bal_seg_num (
    X_coa_id          IN	NUMBER,
    X_company_value   IN OUT NOCOPY 	NUMBER
  );

End gl_elim_accounts_map_pkg;

 

/
