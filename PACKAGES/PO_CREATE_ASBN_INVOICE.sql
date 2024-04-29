--------------------------------------------------------
--  DDL for Package PO_CREATE_ASBN_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CREATE_ASBN_INVOICE" AUTHID CURRENT_USER AS
/* $Header: POXBNIVS.pls 120.0 2005/06/01 21:16:02 appldev noship $*/

FUNCTION create_asbn_invoice (
	p_commit_interval	IN	NUMBER,
	p_shipment_header_id	IN	NUMBER )
RETURN BOOLEAN;

END PO_CREATE_ASBN_INVOICE;

 

/
