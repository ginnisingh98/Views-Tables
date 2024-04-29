--------------------------------------------------------
--  DDL for Package Body GL_BIS_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BIS_REPORTS_PKG" AS
/* $Header: gluoarpb.pls 120.3 2005/05/05 01:41:29 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE initialize (sob_id NUMBER) IS
  BEGIN
     G_SOB_ID := sob_id;
  END initialize;

  FUNCTION get_sob_id RETURN NUMBER IS
  BEGIN
     return G_SOB_ID;
  END get_sob_id;

END gl_bis_reports_pkg;

/
