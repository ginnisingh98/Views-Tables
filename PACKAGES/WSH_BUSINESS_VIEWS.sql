--------------------------------------------------------
--  DDL for Package WSH_BUSINESS_VIEWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BUSINESS_VIEWS" AUTHID CURRENT_USER AS
/* $Header: WSHBVGLS.pls 115.5 2004/08/18 23:39:34 anxsharm ship $ */

-- Function :   Get_Locations
-- Parameters : p_stop_location_id
-- Description : Returns the stop location description for a location id.
-- Bug 3793608 , for backward compatibility need to keep stub of this function


FUNCTION Get_Locations(p_stop_location_id IN NUMBER) RETURN VARCHAR2;


END WSH_BUSINESS_VIEWS;

 

/
