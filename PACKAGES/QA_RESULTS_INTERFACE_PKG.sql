--------------------------------------------------------
--  DDL for Package QA_RESULTS_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_RESULTS_INTERFACE_PKG" AUTHID CURRENT_USER as
/* $Header: qltimptb.pls 120.0.12010000.5 2015/11/09 21:15:35 ntungare ship $ */

PROCEDURE START_IMPORT_ROW ( proc_status IN NUMBER,
    			     org_id IN NUMBER,
   			     given_plan_id IN NUMBER,
    			     script OUT NOCOPY VARCHAR2,
    			     tail_script OUT NOCOPY VARCHAR2,
			     source_code IN VARCHAR2 default null,
			     source_line_id IN NUMBER default null,
			     po_agent_id IN NUMBER default null);


FUNCTION  ADD_ELEMENT_VALUE ( GIVEN_PLAN_ID IN NUMBER,
			      ELEMENT_ID IN NUMBER,
                              ELEMENT_VALUE IN VARCHAR2,
                              SCRIPT IN OUT NOCOPY VARCHAR2,
                              TAIL_SCRIPT IN OUT NOCOPY VARCHAR2) return NUMBER;

PROCEDURE END_IMPORT_ROW  ( script IN VARCHAR2,
	                    tail_script IN VARCHAR2, no_error IN BOOLEAN);


FUNCTION BUILD_OSP_VQR_SQL ( p_plan_id IN NUMBER,
    p_item IN VARCHAR2 DEFAULT NULL,
    p_revision IN VARCHAR2 DEFAULT NULL,
    p_job_name IN VARCHAR2 DEFAULT NULL,
    p_from_op_seq_num IN VARCHAR2 DEFAULT NULL,
    p_vendor_name IN VARCHAR2 DEFAULT NULL,
    p_po_number IN VARCHAR2 DEFAULT NULL,
    p_ordered_quantity IN VARCHAR2 DEFAULT NULL,
    p_vendor_item_number IN VARCHAR2 DEFAULT NULL,
    p_po_release_num IN VARCHAR2 DEFAULT NULL,
    p_uom_name IN VARCHAR2 DEFAULT NULL,
    p_production_line IN VARCHAR2 DEFAULT NULL,
    p_po_header_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2;


FUNCTION BUILD_SHIPMENT_VQR_SQL ( p_plan_id IN NUMBER,
    p_item IN VARCHAR2 DEFAULT NULL,
    p_item_category IN VARCHAR2 DEFAULT NULL,
    p_revision IN VARCHAR2 DEFAULT NULL,
    p_supplier IN VARCHAR2 DEFAULT NULL,
    p_po_number IN VARCHAR2 DEFAULT NULL,
    p_po_line_num IN VARCHAR2 DEFAULT NULL,
    p_po_shipment_num IN VARCHAR2 DEFAULT NULL,
    p_ship_to IN VARCHAR2 DEFAULT NULL,
    p_ordered_quantity IN VARCHAR2 DEFAULT NULL,
    p_vendor_item_number IN VARCHAR2 DEFAULT NULL,
    p_po_release_num IN VARCHAR2 DEFAULT NULL,
    p_uom_name IN VARCHAR2 DEFAULT NULL,
    p_supplier_site IN VARCHAR2 DEFAULT NULL,
    p_ship_to_location IN VARCHAR2 DEFAULT NULL,
    p_po_header_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2;


FUNCTION BUILD_OM_VQR_SQL ( p_plan_id IN NUMBER,
    p_so_header_id IN VARCHAR2,
    p_so_line_id IN VARCHAR2 DEFAULT NULL,
    p_item_id IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;


FUNCTION GET_PLAN_VQR_SQL (p_plan_id IN NUMBER)
    RETURN VARCHAR2;

--
-- Bug 20844486 - ENHANCEMENTS TO QUALITY CODE FOR EAM MOBILE USE
--                copy of get_plan_vqr_sql  and some modifications
--                to produce a sql that for date attributes  returns the
--                conversion to iso8601 instead of the date attribute
--
FUNCTION GET_PLAN_VQR_SQL_MOBILE (p_plan_id IN NUMBER)
    RETURN VARCHAR2;


FUNCTION BUILD_ASSET_VQR_SQL ( p_plan_id IN NUMBER DEFAULT NULL,
    p_asset_group IN VARCHAR2 DEFAULT NULL,
    p_asset_number IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;


FUNCTION BUILD_VQR_SQL (given_plan_id IN NUMBER,
			ss_where_clause in varchar2 default null)
	 return VARCHAR2;


FUNCTION COMMIT_ROWS RETURN NUMBER;


FUNCTION ROLLBACK_ROWS RETURN NUMBER;




--Bug 3140760
--A sales order has a representation in two tables
--OE_HEADERS_ALL.HEADER_ID and MTL_SALES_ORDERS.SALES_ORDER_ID
--Given a header id, finding the equivalent sales_order_id is a little tricky
--Similar logic is done in the view QA_SALES_ORDERS_LOV_V
--Function below is built for Convenience purpose
--This function takes a SO Header id (OE_HEADERS_ALL.HEADER_ID)
--Computes the equivalent Sales_order_id in Mtl_sales_orders and return it
--
FUNCTION OEHEADER_TO_MTLSALES ( p_oe_header_id IN NUMBER )
				RETURN NUMBER;


END QA_RESULTS_INTERFACE_PKG;


/
