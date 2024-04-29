--------------------------------------------------------
--  DDL for Package Body GL_TAX_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TAX_CODES_PKG" AS
/*  $Header: glisttcb.pls 120.4 2006/01/17 20:39:18 xiwu ship $ */


--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular tax row
  -- History
  --   28-MAR-94  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_tax_codes_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row(recinfo IN OUT NOCOPY gl_tax_codes_v%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_tax_codes_v
    WHERE tax_code_id = recinfo.tax_code_id
    AND   tax_type_code in
       (decode(recinfo.tax_type_code,'I', 'I', 'O', 'O'), 'T');
  END SELECT_ROW;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE select_columns(
			x_tax_code_id				NUMBER,
			x_tax_type_code				VARCHAR2,
			x_tax_code			IN OUT NOCOPY	VARCHAR2) IS

    recinfo gl_tax_codes_v%ROWTYPE;

  BEGIN
    recinfo.tax_code_id := x_tax_code_id;
    recinfo.tax_type_code := x_tax_type_code;

    select_row(recinfo);

    x_tax_code := recinfo.tax_code;
  END select_columns;

END GL_TAX_CODES_PKG;

/
