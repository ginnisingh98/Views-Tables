--------------------------------------------------------
--  DDL for Package POS_VALIDATE_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_VALIDATE_ASN" AUTHID CURRENT_USER AS
/* $Header: POSASNVS.pls 115.2 2002/11/26 02:13:16 mji ship $*/

PROCEDURE shipment_num	 (P_SHIPMENT_NUM    IN  VARCHAR2,
			  P_VENDOR_ID IN NUMBER,
                          P_VENDOR_SITE_ID IN NUMBER,
                          P_COUNT OUT NOCOPY NUMBER);

PROCEDURE freight_terms	 (P_DESCRIPTION    IN  VARCHAR2,
			  P_LOOKUP_CODE IN OUT NOCOPY VARCHAR2,
			  P_COUNT	IN OUT NOCOPY 	NUMBER);

PROCEDURE freight_carrier (P_DESCRIPTION IN VARCHAR2,
			   P_ORGANIZATION_ID IN NUMBER,
			   P_FREIGHT_CARRIER_CODE IN OUT NOCOPY VARCHAR2,
			   P_COUNT IN OUT NOCOPY NUMBER);


PROCEDURE payment_terms (P_NAME IN VARCHAR2,
			P_TERM_ID IN OUT NOCOPY NUMBER,
			   P_COUNT IN OUT NOCOPY NUMBER);

PROCEDURE country_of_origin(P_TERRITORY_SHORT_NAME IN VARCHAR,
			    P_TERRITORY_CODE IN OUT NOCOPY VARCHAR,
			    P_COUNT IN OUT NOCOPY NUMBER);

END POS_VALIDATE_ASN;


 

/