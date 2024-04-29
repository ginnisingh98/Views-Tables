--------------------------------------------------------
--  DDL for Package PO_PRICE_BREAK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_BREAK_GRP" AUTHID CURRENT_USER as
/* $Header: POXPRBKS.pls 120.0.12010000.3 2011/11/15 00:17:41 lswamy ship $ */
-- <FPJ Advanced Price START>
Procedure Get_Price_Break (
	p_source_document_header_id	IN NUMBER,
        p_source_document_line_num	IN NUMBER,
	p_in_quantity			IN NUMBER,
	p_unit_of_measure		IN VARCHAR2,
        p_deliver_to_location_id	IN NUMBER,
	p_required_currency		IN VARCHAR2,
	p_required_rate_type		IN VARCHAR2,
	p_need_by_date			IN DATE,
	p_destination_org_id		IN NUMBER,
        p_org_id			IN  NUMBER,
	p_supplier_id			IN  NUMBER,
	p_supplier_site_id		IN  NUMBER,
	p_creation_date			IN  DATE,
	p_order_header_id		IN  NUMBER,
	p_order_line_id			IN  NUMBER,
	p_line_type_id			IN  NUMBER,
	p_item_revision			IN  VARCHAR2,
	p_item_id			IN  NUMBER,
	p_category_id			IN  NUMBER,
	p_supplier_item_num		IN  VARCHAR2,
	p_in_price			IN  NUMBER,
	x_base_unit_price		OUT NOCOPY NUMBER,
	x_base_price			OUT NOCOPY NUMBER,
	x_currency_price		OUT NOCOPY NUMBER,
	x_discount			OUT NOCOPY NUMBER,
	x_currency_code			OUT NOCOPY VARCHAR2,
	x_rate_type                 	OUT NOCOPY VARCHAR2,
	x_rate_date                 	OUT NOCOPY DATE,
	x_rate                      	OUT NOCOPY NUMBER,
        x_price_break_id            	OUT NOCOPY NUMBER
);
-- <FPJ Advanced Price END>

Procedure Get_Price_Break (
	p_source_document_header_id	IN NUMBER,
        p_source_document_line_num	IN NUMBER,
	p_in_quantity			IN NUMBER,
	p_unit_of_measure		IN VARCHAR2,
        p_deliver_to_location_id	IN NUMBER,
	p_required_currency		IN VARCHAR2,
	p_required_rate_type		IN VARCHAR2,
	p_need_by_date			IN DATE,          --  <TIMEPHASED FPI>
	p_destination_org_id		IN NUMBER,        --  <TIMEPHASED FPI>
	x_base_price			OUT NOCOPY NUMBER,
	x_currency_price		OUT NOCOPY NUMBER,
	x_discount			OUT NOCOPY NUMBER,
	x_currency_code			OUT NOCOPY VARCHAR2,
	x_rate_type                 	OUT NOCOPY VARCHAR2,
	x_rate_date                 	OUT NOCOPY DATE,
	x_rate                      	OUT NOCOPY NUMBER,
        x_price_break_id            	OUT NOCOPY NUMBER    -- <SERVICES FPJ>
);

/* This procedure is a wrapper for get_price_break(). */
/* It is called by ReqImport */
Procedure Reqimport_Set_Break_Price(
	p_request_id	po_requisitions_interface.request_id%TYPE
);

-- Overloaded price break API
Procedure Get_Price_Break (
	source_document_header_id	IN NUMBER,
        source_document_line_num	IN NUMBER,
	in_quantity			IN NUMBER,
	unit_of_measure			IN VARCHAR2,
        deliver_to_location_id		IN NUMBER,
	required_currency		IN VARCHAR2,
	required_rate_type		IN VARCHAR2,
	p_need_by_date			IN DATE,          --  <TIMEPHASED FPI>
	p_destination_org_id		IN NUMBER,        --  <TIMEPHASED FPI>
	base_price			OUT NOCOPY NUMBER,
	currency_price			OUT NOCOPY NUMBER,
	discount			OUT NOCOPY NUMBER,
	currency_code			OUT NOCOPY VARCHAR2,
	rate_type			OUT NOCOPY VARCHAR2,
	rate_date			OUT NOCOPY DATE,
	rate				OUT NOCOPY NUMBER
);



 --BUG 13061889 : Declaring the function, so it can be called from a different package.
 FUNCTION get_conversion_rate
 (
     p_po_header_id    IN   PO_HEADERS_ALL.po_header_id%TYPE
 )
 RETURN PO_HEADERS_ALL.rate%TYPE;
 --BUG 13061889

end po_price_break_grp;

/
