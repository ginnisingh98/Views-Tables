--------------------------------------------------------
--  DDL for Package RCV_TABLE_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TABLE_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: RCVTBFNS.pls 120.3.12010000.5 2013/12/17 04:12:53 honwei ship $*/

	TYPE lookup_table_type IS TABLE OF VARCHAR2(80) INDEX BY VARCHAR2(80);

   e_fatal_error    EXCEPTION;
   g_error_column   VARCHAR2(80);
   g_default_org_id NUMBER;

   g_mp_org_id         NUMBER;      -- lcm changes
   g_rp_org_id         NUMBER;      -- lcm changes
   g_lcm_enabled_flag  VARCHAR2(1); -- lcm changes
   g_pre_rcv_flag      VARCHAR2(1); -- lcm changes
   g_pll_id            NUMBER;      -- lcm changes
   g_lcm_flag          VARCHAR2(1); -- lcm changes

/* Bug 5246147: Removed the following function declarations,
                get_fspa_row_from_org() and
                get_sob_row_from_id() */

   FUNCTION get_rhi_row_from_id(
      p_header_interface_id IN rcv_headers_interface.header_interface_id%TYPE
   )
      RETURN rcv_headers_interface%ROWTYPE;

   PROCEDURE update_rhi_row(
      p_rhi_row IN rcv_headers_interface%ROWTYPE
   );

   FUNCTION get_rti_row_from_id(
      p_interface_transaction_id IN rcv_transactions_interface.interface_transaction_id%TYPE
   )
      RETURN rcv_transactions_interface%ROWTYPE;

   PROCEDURE update_rti_row(
      p_rti_row IN rcv_transactions_interface%ROWTYPE
   );

   FUNCTION get_rt_row_from_id(
      p_transaction_id IN rcv_transactions.transaction_id%TYPE
   )
      RETURN rcv_transactions%ROWTYPE;
    --Bug 9005670 Added input parameter receipt_source_code.
   FUNCTION get_rsh_row_from_num(
      p_shipment_num         IN rcv_shipment_headers.shipment_num%TYPE,
      p_vendor_id            IN rcv_shipment_headers.vendor_id%TYPE,
      p_vendor_site_id       IN rcv_shipment_headers.vendor_site_id%TYPE,
      p_ship_to_org_id       IN rcv_shipment_headers.ship_to_org_id%TYPE,
      p_shipped_date         IN rcv_shipment_headers.shipped_date%TYPE,
      p_receipt_source_code  IN rcv_shipment_headers.receipt_source_code%TYPE,
      no_data_found_is_error IN BOOLEAN
   )
      RETURN rcv_shipment_headers%ROWTYPE;
   --Add to Receipt 17962808 begin;
   FUNCTION get_rsh_row_from_receipt_num(
      p_receipt_num          IN rcv_shipment_headers.receipt_num%TYPE,
      p_ship_to_org_id       IN rcv_shipment_headers.ship_to_org_id%TYPE,
      no_data_found_is_error IN BOOLEAN
   )
      RETURN rcv_shipment_headers%ROWTYPE;
   --Add to Receipt 17962808 end;
   FUNCTION get_rsh_row_from_id(
      p_shipment_header_id IN rcv_shipment_headers.shipment_header_id%TYPE
   )
      RETURN rcv_shipment_headers%ROWTYPE;

   FUNCTION get_rsl_row_from_num(
      p_line_num           rcv_shipment_lines.line_num%TYPE,
      p_shipment_header_id rcv_shipment_lines.shipment_header_id%TYPE
   )
      RETURN rcv_shipment_lines%ROWTYPE;

   FUNCTION get_rsl_row_from_id(
      p_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE
   )
      RETURN rcv_shipment_lines%ROWTYPE;

   PROCEDURE update_rsl_row(
      p_rsl_row IN rcv_shipment_lines%ROWTYPE
   );

   FUNCTION get_poh_row_from_num(
      p_po_num po_headers_all.segment1%TYPE,
      p_org_id po_headers_all.org_id%TYPE
   )
      RETURN po_headers_all%ROWTYPE;

   FUNCTION get_poh_row_from_id(
      p_header_id IN po_headers_all.po_header_id%TYPE
   )
      RETURN po_headers_all%ROWTYPE;

   FUNCTION get_pol_row_from_num(
      p_line_num           po_lines_all.line_num%TYPE,
      p_header_id          po_lines_all.po_header_id%TYPE,
      p_item_description   po_lines_all.item_description%TYPE,
      p_vendor_product_num po_lines_all.vendor_product_num%TYPE,
      p_item_id            po_lines_all.item_id%TYPE
   )
      RETURN po_lines_all%ROWTYPE;
      -- Bug 7645326 Added item_id in the above Function

   FUNCTION get_pol_row_from_id(
      p_line_id IN po_lines_all.po_line_id%TYPE
   )
      RETURN po_lines_all%ROWTYPE;

   FUNCTION get_pll_row_from_num(
      p_shipment_num po_line_locations_all.shipment_num%TYPE,
      p_line_id      po_line_locations_all.po_line_id%TYPE
   )
      RETURN po_line_locations_all%ROWTYPE;

   FUNCTION get_pll_row_from_id(
      p_line_location_id IN po_line_locations_all.line_location_id%TYPE
   )
      RETURN po_line_locations_all%ROWTYPE;

   FUNCTION get_pod_row_from_num(
      p_distribution_num po_distributions_all.distribution_num%TYPE,
      p_line_location_id po_distributions_all.line_location_id%TYPE
   )
      RETURN po_distributions_all%ROWTYPE;

   FUNCTION get_pod_row_from_id(
      p_distribution_id IN po_distributions_all.po_distribution_id%TYPE
   )
      RETURN po_distributions_all%ROWTYPE;

	FUNCTION get_pvs_row_from_id( p_vendor_site_id IN po_vendor_sites_all.vendor_site_id%TYPE )
		RETURN po_vendor_sites_all%ROWTYPE;

   FUNCTION get_oeh_row_from_num(
      p_order_number   oe_order_headers_all.order_number%TYPE,
      p_order_type_id  oe_order_headers_all.order_type_id%TYPE,
      p_version_number oe_order_headers_all.version_number%TYPE,
      p_org_id         oe_order_headers_all.org_id%TYPE
   )
      RETURN oe_order_headers_all%ROWTYPE;

   FUNCTION get_oeh_row_from_id(
      p_header_id IN oe_order_headers_all.header_id%TYPE
   )
      RETURN oe_order_headers_all%ROWTYPE;

   FUNCTION get_oel_row_from_num(
      p_line_number oe_order_lines_all.line_number%TYPE,
      p_header_id   oe_order_lines_all.header_id%TYPE
   )
      RETURN oe_order_lines_all%ROWTYPE;

   FUNCTION get_oel_row_from_id(
      p_line_id IN oe_order_lines_all.line_id%TYPE
   )
      RETURN oe_order_lines_all%ROWTYPE;

   FUNCTION get_prl_row_from_id(
      p_requisition_line_id IN po_requisition_lines_all.requisition_line_id%TYPE
   )
      RETURN po_requisition_lines_all%ROWTYPE;

   FUNCTION get_prd_row_from_id(
      p_req_distribution_id IN po_req_distributions_all.distribution_id%TYPE
   )
      RETURN po_req_distributions_all%ROWTYPE;

	FUNCTION get_msi_row_from_num
		( p_item_id IN mtl_system_items.inventory_item_id%TYPE
		, p_org_id IN mtl_system_items.organization_id%TYPE
		)
      RETURN mtl_system_items%ROWTYPE;

	FUNCTION get_mic_row_from_num
		( p_item_id IN mtl_item_categories.inventory_item_id%TYPE
		, p_org_id IN mtl_item_categories.organization_id%TYPE
		)
		RETURN mtl_item_categories%ROWTYPE;

	FUNCTION get_mp_row_from_org( p_org_id IN mtl_parameters.organization_id%TYPE )
		RETURN mtl_parameters%ROWTYPE;

	FUNCTION get_rp_row_from_org( p_org_id IN rcv_parameters.organization_id%TYPE )
		RETURN rcv_parameters%ROWTYPE;

	FUNCTION get_fc_row_from_code( p_currency_code IN fnd_currencies.currency_code%TYPE )
		RETURN fnd_currencies%ROWTYPE;

	FUNCTION get_fsp_row
		RETURN financials_system_parameters%ROWTYPE;


	FUNCTION get_muom_row_from_name( p_unit_of_measure IN mtl_units_of_measure.unit_of_measure%TYPE )
		RETURN mtl_units_of_measure%ROWTYPE;

	FUNCTION get_po_lookup
		( p_lookup_type IN po_lookup_codes.lookup_type%TYPE
		, p_lookup_code IN po_lookup_codes.lookup_code%TYPE
		) RETURN po_lookup_codes.displayed_field%TYPE;

   -- lcm changes
   FUNCTION is_lcm_shipment
      ( p_po_line_location_id IN NUMBER )
      RETURN VARCHAR2;

   FUNCTION is_lcm_org
      ( p_organization_id IN NUMBER )
      RETURN VARCHAR2;

   FUNCTION is_pre_rcv_org
      ( p_organization_id IN NUMBER )
      RETURN VARCHAR2;

END rcv_table_functions;

/
