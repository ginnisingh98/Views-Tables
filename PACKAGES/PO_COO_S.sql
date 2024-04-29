--------------------------------------------------------
--  DDL for Package PO_COO_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COO_S" AUTHID CURRENT_USER AS
/* $Header: POXRCOOS.pls 115.4 2002/11/23 02:08:01 sbull ship $*/
PROCEDURE get_default_country_of_origin(x_item_id IN NUMBER,
	x_ship_to_org_id IN NUMBER,
	x_vendor_id IN NUMBER,
	x_vendor_site_id IN NUMBER,
	x_country_of_origin	IN OUT	NOCOPY VARCHAR2);

END PO_COO_S;

 

/
