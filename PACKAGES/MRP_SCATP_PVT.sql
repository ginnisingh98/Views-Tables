--------------------------------------------------------
--  DDL for Package MRP_SCATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SCATP_PVT" AUTHID CURRENT_USER AS
    /* $Header: MRPVATPS.pls 115.0 99/07/16 12:41:27 porting ship $ */

    FUNCTION get_default_ship_method (p_from_location_id IN NUMBER, p_to_location_id IN NUMBER)
		return VARCHAR2;

    FUNCTION get_default_intransit_time (p_from_location_id IN NUMBER, p_to_location_id IN NUMBER)
		 return NUMBER;

	FUNCTION get_ship_method(p_from_org_id IN NUMBER, p_to_org_id IN NUMBER,
							 p_source_ship_method IN VARCHAR2,
							 p_receipt_org_id IN NUMBER)
							 return VARCHAR2;

	FUNCTION get_intransit_time(p_from_org_id IN NUMBER, p_to_org_id IN NUMBER,
								 p_source_ship_method IN VARCHAR2,
							     p_receipt_org_id IN NUMBER)
								 return NUMBER;

	PRAGMA RESTRICT_REFERENCES (get_default_ship_method, WNDS,WNPS);
	PRAGMA RESTRICT_REFERENCES (get_default_intransit_time, WNDS,WNPS);
	PRAGMA RESTRICT_REFERENCES (get_ship_method, WNDS,WNPS);
	PRAGMA RESTRICT_REFERENCES (get_intransit_time, WNDS,WNPS);

END MRP_SCATP_PVT;

 

/
