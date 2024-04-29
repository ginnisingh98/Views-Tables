--------------------------------------------------------
--  DDL for Package Body GL_PREUPGRADE_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PREUPGRADE_STATUS_PKG" AS
/* $Header: glupgrdb.pls 115.2 2003/04/05 02:38:51 xiwu noship $ */
  -- False for pure 11.5 env
  -- True for preupgraded env
  FUNCTION preupgraded_env RETURN BOOLEAN IS
  BEGIN
     RETURN FALSE;
  END preupgraded_env;

END GL_PREUPGRADE_STATUS_PKG;

/
