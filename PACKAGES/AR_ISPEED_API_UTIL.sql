--------------------------------------------------------
--  DDL for Package AR_ISPEED_API_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ISPEED_API_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARISPEDS.pls 115.2 2003/10/31 22:48:08 msenthil noship $ */
  --
  -- Function
  --   fire_concurrent_location
  -- Purpose
  --   Submits concurrent programs that create package body and specs
  --   for the Location flexfield in AR System Options
  --
  --   This will be called from AR System Options API
  -- History
  --   02/14/00         M Gudivaka      Created
  -- Example
  --   req_id = ar_ispeed_api_util.fire_concurrent_location(argument2)
  -- Notes
  --

  FUNCTION fire_concurrent_location(argument2 VARCHAR2, argument3 VARCHAR2)
  RETURN NUMBER;

END ar_ispeed_api_util ;

 

/
