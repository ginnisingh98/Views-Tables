--------------------------------------------------------
--  DDL for Package Body WSH_BUSINESS_VIEWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_BUSINESS_VIEWS" as
/* $Header: WSHBVGLB.pls 115.8 2004/08/18 23:40:47 anxsharm ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_BUSINESS_VIEWS';
--

-- Function :   Get_Locations
-- Parameters : p_stop_location_id
-- Description : Returns the stop location description for a location id.
-- Bug 3793608, Need to keep a stub of this function for backward compilation purpose


FUNCTION Get_Locations(p_stop_location_id IN NUMBER) RETURN VARCHAR2 IS

BEGIN

  -- Stub API only, only for backward compilation
  RETURN null;

END Get_Locations;

END WSH_BUSINESS_VIEWS;


/
