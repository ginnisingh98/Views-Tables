--------------------------------------------------------
--  DDL for Package MRP_GET_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GET_LOCATION" AUTHID CURRENT_USER AS
/* $Header: MRPGLOCS.pls 115.0 99/07/16 12:21:30 porting ship $ */

	FUNCTION location(arg_location_id IN NUMBER, arg_org_id IN NUMBER) return varchar2;

	PRAGMA RESTRICT_REFERENCES (location, WNDS, WNPS);

END MRP_GET_LOCATION;

 

/
