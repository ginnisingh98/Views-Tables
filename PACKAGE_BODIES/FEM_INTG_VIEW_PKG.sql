--------------------------------------------------------
--  DDL for Package Body FEM_INTG_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_VIEW_PKG" AS
/* $Header: fem_intg_view.plb 120.0 2005/06/06 21:48:50 appldev noship $ */


--
-- PUBLIC PROCEDURES
--

  PROCEDURE Recreate_View(
	p_view_name	VARCHAR2,
	p_sql		VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || p_view_name || ' AS ' || p_sql;
    commit;
  END Recreate_View;

END FEM_INTG_VIEW_PKG;

/
