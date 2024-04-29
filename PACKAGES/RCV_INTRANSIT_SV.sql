--------------------------------------------------------
--  DDL for Package RCV_INTRANSIT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INTRANSIT_SV" AUTHID CURRENT_USER as
/* $Header: RCVSHINS.pls 120.1 2005/06/14 18:13:26 wkunz noship $ */
/*===========================================================================
  PACKAGE NAME:		PO_ITEMS_SV2

  DESCRIPTION:		This package contains the server side Shipment related
			functions for v10 char mode.  This must be a separate
                        file because it acts as a prereq for the pocso.opc
                        Create Internal Sales order process

  CLIENT/SERVER:	Server

  OWNER:		George Kellner

  PROCEDURE NAMES:	get_expected_shipped_date

===========================================================================*/


/*===========================================================================
  PROCEDURE NAME:	 get_expected_shipped_date

  DESCRIPTION:		Obtain the exepected shipped date for an internal
                        req to sales order creation (Create internal sales
                        order routine.) so that the shipped date is offset
                        by the INTRANSIT LEAD TIME for the ship to org

  PARAMETERS:		X_from_organization_id    IN NUMBER
                        X_to_organization_id      IN NUMBER
                        X_need_by_date            IN DATE
                        X_req_line_id             IN NUMBER


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	GKELLNER 09/22/96 CReATED
===========================================================================*/

FUNCTION get_expected_shipped_date (
X_from_organization_id    IN NUMBER,
X_to_organization_id      IN NUMBER,
X_need_by_date            IN DATE,
X_req_line_id             IN NUMBER)
RETURN DATE;

--pragma restrict_references (get_expected_shipped_date,WNDS,RNPS,WNPS);

FUNCTION rcv_get_org_name  (
  p_source_code    IN VARCHAR2,
  p_vendor_id      IN NUMBER,
  p_org_id         IN NUMBER)
RETURN VARCHAR2 ;

--pragma restrict_references (rcv_get_org_name,WNDS,WNPS);

END RCV_INTRANSIT_SV;

 

/
