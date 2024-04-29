--------------------------------------------------------
--  DDL for Package FEM_INTG_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_VIEW_PKG" AUTHID CURRENT_USER as
/* $Header: fem_intg_view.pls 120.0 2005/06/06 21:49:36 appldev noship $ */
--
-- Package
--   fem_intg_view_pkg
-- Purpose
--   Package to maintain the dynamic views
-- History
--   27-SEP-04  M Ward          Created
--

  --
  -- Procedure
  --   Recreate_View
  -- Purpose
  --   Check whether an edit lock exists on an object definition
  -- Arguments
  --   p_view_name	The name of the view being created
  --   p_sql		The sql that should be used for creating the view
  -- Example
  --   FEM_INTG_VIEW_PKG.Recreate_View(p_view_name => view_name,
  --                                   p_sql => sql_text)
  -- Notes
  --
  PROCEDURE Recreate_View(
	p_view_name	VARCHAR2,
	p_sql		VARCHAR2);

END FEM_INTG_VIEW_PKG;

 

/
