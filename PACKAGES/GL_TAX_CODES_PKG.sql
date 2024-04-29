--------------------------------------------------------
--  DDL for Package GL_TAX_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TAX_CODES_PKG" AUTHID CURRENT_USER AS
/*  $Header: glisttcs.pls 120.3 2005/05/05 01:27:55 kvora ship $  */
--
-- Package
--   GL_TAX_CODES_PKG
-- Purpose
--   To create GL_TAX_CODES_PKG package.
-- History
--   06-DEC-96	D J Ogg		Created

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the tax_code for a given tax_code_id
  -- History
  --   06-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   x_tax_code_id			Id of desired tax code
  --   x_tax_type_code			Type of desired tax code
  --   x_tax_code			Name of desired tax code
  -- Example
  --   gl_tax_codes_pkg.select_columns(12, tax_code);
  -- Notes
  --
  PROCEDURE select_columns(
			x_tax_code_id				NUMBER,
			x_tax_type_code				VARCHAR2,
			x_tax_code			IN OUT NOCOPY	VARCHAR2);


END GL_TAX_CODES_PKG;

 

/
