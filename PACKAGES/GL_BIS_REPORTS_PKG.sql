--------------------------------------------------------
--  DDL for Package GL_BIS_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BIS_REPORTS_PKG" AUTHID CURRENT_USER AS
/*  $Header: gluoarps.pls 120.2 2005/05/05 01:41:36 kvora ship $ */
--
-- Package
--   gl_bis_reports_pkg
-- Purpose
--   This package contains various BIS reports utilities.
-- History
--   07-13-99   K Chang		Created
--
  ---
  --- GLOBAL VARIABLES
  ---

  G_SOB_ID		NUMBER := null;


  -- Procedure
  --   initialize
  --
  -- Purpose
  --   Initialize set of book id
  --
  -- History
  --   07-13-99   K Chang	Created
  --
  -- Arguments
  --   sob_id NUMBER

  PROCEDURE initialize ( sob_id NUMBER);

  -- Procedure
  --   get_sob_id
  --
  -- Purpose
  --   Gets the Set of book ID
  --
  -- History
  --   07-13-99   K Chang	Created
  --
  -- Arguments
  --   none

  FUNCTION get_sob_id RETURN NUMBER;

END gl_bis_reports_pkg;

 

/
