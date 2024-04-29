--------------------------------------------------------
--  DDL for Package GL_FLEX_INSERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLEX_INSERT_PKG" AUTHID CURRENT_USER AS
/* $Header: glffglis.pls 120.1 2003/04/29 02:01:37 djogg ship $ */


--  Returns TRUE if ok, or returns FALSE and sets FND_MESSAGE on error.
--
  FUNCTION fdfgli(ccid IN NUMBER) RETURN BOOLEAN;

END GL_FLEX_INSERT_PKG;

 

/
