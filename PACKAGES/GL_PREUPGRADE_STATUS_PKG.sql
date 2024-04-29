--------------------------------------------------------
--  DDL for Package GL_PREUPGRADE_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PREUPGRADE_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: glupgrds.pls 115.2 2003/04/05 02:38:39 xiwu noship $ */
 --
  -- Function
  --   preupgraded_env
  -- Purpose
  --   Check preupgrade status
  -- History
  --   02-11-03    J Wu    Created
  -- Arguments
  --   none
  -- Returns
  --    FALSE for pure 11.5 env
  --    TRUE  for preupgraded env.
  -- Notes
  --

  FUNCTION preupgraded_env	RETURN BOOLEAN;

END GL_PREUPGRADE_STATUS_PKG;

 

/
