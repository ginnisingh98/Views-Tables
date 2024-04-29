--------------------------------------------------------
--  DDL for Package GL_BIS_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BIS_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: gluoascs.pls 120.1 2002/04/10 20:07:39 djogg ship $ */
--
-- Package
--   gl_bis_security_pkg
-- Purpose
--   To provide security accessing data in the GL BIS Business Views
-- History
--   26-MAR-99  	E.Weinstein	Created

  --
  -- Procedure
  --   login_sob_id
  -- Purpose
  --    Returns the set of books id a user signed on with.
  --
  FUNCTION login_sob_id RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES ( login_sob_id, WNDS, WNPS) ;

END gl_bis_security_pkg;

 

/
