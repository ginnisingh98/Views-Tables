--------------------------------------------------------
--  DDL for Package MSC_SCATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCATP_PUB" AUTHID CURRENT_USER AS
    /* $Header: MSCVATPS.pls 115.5 2003/06/26 07:50:38 rajjain ship $ */


-- savirine added parameters p_session_id and p_partner_site_id on Sep 10, 2001.

FUNCTION get_default_ship_method (p_from_location_id IN NUMBER,
                                  p_from_instance_id IN NUMBER,
                                  p_to_location_id IN NUMBER,
                                  p_to_instance_id IN NUMBER,
                                  p_session_id IN NUMBER DEFAULT NULL,
                                  p_partner_site_id IN NUMBER DEFAULT NULL)
return VARCHAR2;

FUNCTION get_default_intransit_time (p_from_location_id IN NUMBER,
                                     p_from_instance_id IN NUMBER,
                                     p_to_location_id IN NUMBER,
                                     p_to_instance_id IN NUMBER,
                                     p_session_id IN NUMBER DEFAULT NULL,
                                     p_partner_site_id IN NUMBER DEFAULT NULL)
return NUMBER;

FUNCTION get_ship_method(p_from_org_id IN NUMBER,
                         p_from_org_instance_id IN NUMBER,
                         p_to_org_id IN NUMBER,
                         p_to_org_instance_id IN NUMBER,
		         p_source_ship_method IN VARCHAR2,
			 p_receipt_org_id IN NUMBER)
return VARCHAR2;

FUNCTION get_intransit_time(p_from_org_id IN NUMBER,
                            p_from_org_instance_id IN NUMBER,
                            p_to_org_id IN NUMBER,
                            p_to_org_instance_id IN NUMBER,
			    p_source_ship_method IN VARCHAR2,
			    p_receipt_org_id IN NUMBER)
return NUMBER;

FUNCTION get_weight_cost(p_from_org_id IN NUMBER,
                         p_from_org_instance_id IN NUMBER,
                         p_to_org_id IN NUMBER,
                         p_to_org_instance_id IN NUMBER,
		         p_source_ship_method IN VARCHAR2,
			 p_receipt_org_id IN NUMBER)
return NUMBER;

FUNCTION get_transport_cost(p_from_org_id IN NUMBER,
                            p_from_org_instance_id IN NUMBER,
                            p_to_org_id IN NUMBER,
                            p_to_org_instance_id IN NUMBER,
		            p_source_ship_method IN VARCHAR2,
			    p_receipt_org_id IN NUMBER)
return NUMBER;

PRAGMA RESTRICT_REFERENCES (get_default_ship_method, WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (get_default_intransit_time, WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (get_ship_method, WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (get_intransit_time, WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (get_weight_cost, WNDS,WNPS);
PRAGMA RESTRICT_REFERENCES (get_transport_cost, WNDS,WNPS);

END MSC_SCATP_PUB;

 

/
