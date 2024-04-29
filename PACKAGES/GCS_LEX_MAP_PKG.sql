--------------------------------------------------------
--  DDL for Package GCS_LEX_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_LEX_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: gcslxmps.pls 115.0 2003/08/15 18:50:29 jhhuang noship $ */

-- Package
--   gcs_lex_map_pkg
-- Purpose
--   routines used by lexical mapping feature
-- History
--   04/11/03

  --
  -- Function
  --   get_concatenated_conditions
  -- Purpose
  --   retrieves and concatenates all conditions with a derivation_id with "AND"
  -- History
  --   04-11-2003   J Huang     Created
  -- Notes
  --
  FUNCTION get_concat_conditions(Derivation_id NUMBER )RETURN VARCHAR2;
END GCS_LEX_MAP_PKG;


 

/
