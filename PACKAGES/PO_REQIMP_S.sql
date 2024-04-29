--------------------------------------------------------
--  DDL for Package PO_REQIMP_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQIMP_S" AUTHID CURRENT_USER AS
/* $Header: POXRQIMS.pls 120.0 2005/06/01 23:17:25 appldev noship $*/

PROCEDURE get_list_price_conversion(x_request_id	IN	NUMBER,
				    x_currency_code	IN 	VARCHAR2,
				    x_set_of_books_id	IN	NUMBER);

PROCEDURE get_uom_conversion(x_request_id 	IN	NUMBER,
			     x_inventory_org_id IN 	NUMBER);

--< Bug 3540365 Start >
PROCEDURE default_trx_reason_codes( p_request_id IN NUMBER );
--< Bug 3540365 End >

/* BEGIN INVCONV PBAMB */
PROCEDURE REQIMPORT_DEF_VALIDATE_SEC_QTY( p_request_id IN NUMBER);
/* END INVCONV PBAMB */

END PO_REQIMP_S;

 

/
