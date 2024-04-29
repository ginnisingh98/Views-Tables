--------------------------------------------------------
--  DDL for Package GL_HISTORICAL_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_HISTORICAL_RANGES_PKG" AUTHID CURRENT_USER as
/* $Header: glirtrgs.pls 120.2 2005/05/05 01:21:39 kvora ship $ */

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a new sequence unique id for a new historical ranges row .
  -- History
  --   11-APR-94  ERumanan  Created.
  -- Arguments
  --   none
  -- Example
  --   :block.field := GL_HISTORICAL_RANGES_PKG.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

END GL_HISTORICAL_RANGES_PKG;

 

/
