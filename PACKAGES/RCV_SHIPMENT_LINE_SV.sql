--------------------------------------------------------
--  DDL for Package RCV_SHIPMENT_LINE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SHIPMENT_LINE_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTHCS.pls 120.1.12010000.2 2012/11/18 03:08:58 liayang ship $*/

/*===========================================================================
  PACKAGE NAME:		rcv_shipment_line_sv

  DESCRIPTION:          Contains the server side APIs

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                DFong

  PROCEDURES/FUNCTIONS:	create_shipment_line()

===========================================================================*/

 TYPE transaction_record_type IS RECORD
 (transaction_record	rcv_shipment_object_sv.c2%rowtype,
  error_record		rcv_shipment_object_sv.errorrectype);

 TYPE item_id_record_type IS RECORD
 (item_id			mtl_system_items_kfv.inventory_item_id%type,
  po_line_id			rcv_transactions_interface.po_line_id%type,
  po_line_location_id           rcv_transactions_interface.po_line_location_id%type,
  to_organization_id		rcv_transactions_interface.to_organization_id%type,
  item_description		rcv_transactions_interface.item_description%type,
  item_revision			rcv_transactions_interface.item_revision%type,
  primary_unit_of_measure	rcv_transactions_interface.primary_unit_of_measure%type,
  use_mtl_lot			rcv_transactions_interface.item_revision%type,  -- bug 608353
  use_mtl_serial		rcv_transactions_interface.primary_unit_of_measure%type,
  item_num			varchar2(2000),
  vendor_item_num		varchar2(2000),
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE document_num_record_type IS RECORD
 (document_num		po_headers.segment1%type,
  po_header_id		po_headers.po_header_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE release_id_record_type IS RECORD
 (release_num		po_releases.release_num%type,
  po_release_id		po_releases.po_release_id%type,
  po_line_id            po_lines.po_line_id%type,
  shipment_num          po_line_locations.shipment_num%type,
  po_line_location_id   rcv_transactions_interface.po_line_location_id%type,
  po_header_id          rcv_transactions_interface.po_header_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE po_line_id_record_type IS RECORD
 (document_line_num	po_lines.line_num%type,
  document_num		po_headers.segment1%type,
  po_header_id		po_headers.po_header_id%type,
  po_line_id		po_lines.po_line_id%type,
  item_id		mtl_system_items_kfv.inventory_item_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE po_line_location_id_rtype IS RECORD
 (po_header_id			rcv_transactions_interface.po_header_id%type,
  po_line_id			rcv_transactions_interface.po_line_id%type,
  po_line_location_id		rcv_transactions_interface.po_line_location_id%type,
  item_id			mtl_system_items_kfv.inventory_item_id%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE intransit_owning_org_rtype IS RECORD
 (intransit_owning_org_id	rcv_transactions_interface.intransit_owning_org_id%type,
  intransit_owning_org_code	rcv_transactions_interface.intransit_owning_org_code%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE sub_item_id_record_type IS RECORD
 (substitute_item_num	varchar2(2000),
  substitute_item_id	mtl_system_items_kfv.inventory_item_id%type,
  related_item_id	mtl_related_items.related_item_id%type,
  po_line_id		rcv_transactions_interface.po_line_id%type,
  to_organization_id	rcv_transactions_interface.to_organization_id%type,
  vendor_id		rcv_transactions_interface.vendor_id%type,
  vendor_item_num	varchar2(2000),
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE po_lookup_code_record_type IS RECORD
 (displayed_field	po_lookup_codes.displayed_field%Type,
  lookup_code    	po_lookup_codes.lookup_code%Type,
  lookup_type    	po_lookup_codes.lookup_type%Type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE category_id_record_type IS RECORD
 (item_category		rcv_transactions_interface.item_category%type,
  category_id		rcv_transactions_interface.category_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE routing_header_id_rec_type IS RECORD
 (routing_code		rcv_transactions_interface.routing_code%type,
  routing_header_id	rcv_transactions_interface.routing_header_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE routing_step_id_rec_type IS RECORD
 (routing_step		rcv_transactions_interface.routing_step%type,
  routing_step_id	rcv_transactions_interface.routing_step_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE deliver_to_person_id_rtype IS RECORD
 (deliver_to_person_name	rcv_transactions_interface.deliver_to_person_name%type,
  deliver_to_person_id		rcv_transactions_interface.deliver_to_person_id%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE employee_record_type IS RECORD
 (full_name			rcv_transactions_interface.deliver_to_person_name%type,
  employee_id			rcv_transactions_interface.deliver_to_location_id%type,
  to_organization_id		rcv_transactions_interface.to_organization_id%type,
  destination_type_code         rcv_transactions_interface.destination_type_code%type,
  transaction_date		rcv_transactions_interface.transaction_date%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE location_record_type IS RECORD
 (location_code			rcv_transactions_interface.deliver_to_location_code%type,
  location_id			rcv_transactions_interface.deliver_to_location_id%type,
  to_organization_id		rcv_transactions_interface.to_organization_id%type,
  destination_type_code         rcv_transactions_interface.destination_type_code%type,
  location_type_code            po_lookup_codes.lookup_code%type,
  transaction_date		rcv_transactions_interface.transaction_date%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE subinventory_record_type IS RECORD
 (subinventory          	rcv_transactions_interface.subinventory%type,
  to_organization_id		rcv_transactions_interface.to_organization_id%type,
  destination_type_code         rcv_transactions_interface.destination_type_code%type,
  from_subinventory          	rcv_transactions_interface.subinventory%type,
  from_organization_id		rcv_transactions_interface.to_organization_id%type,
  source_document_code          rcv_transactions_interface.source_document_code%type,
  item_id			mtl_system_items_kfv.inventory_item_id%type,
  transaction_date		rcv_transactions_interface.transaction_date%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

  /*
  ** Bug 724495
  ** added subinventory and to_organization_id the record
  **
  */


 TYPE locator_record_type IS RECORD
 (locator		        rcv_transactions_interface.locator%type,
  locator_id		        rcv_transactions_interface.locator_id%type,
  subinventory          	rcv_transactions_interface.subinventory%type,
  subinventory_locator_control  mtl_system_items.location_control_code%type,
  restrict_locator_control      mtl_system_items.restrict_locators_code%type,
  to_organization_id		rcv_transactions_interface.to_organization_id%type,
  destination_type_code         rcv_transactions_interface.destination_type_code%type,
  from_subinventory          	rcv_transactions_interface.subinventory%type,
  from_organization_id		rcv_transactions_interface.to_organization_id%type,
  source_document_code          rcv_transactions_interface.source_document_code%type,
  item_id			mtl_system_items_kfv.inventory_item_id%type,
  transaction_date		rcv_transactions_interface.transaction_date%type,
  po_distribution_id         rcv_transactions_interface.po_distribution_id%type,--Bug13844195
  receipt_source_code         rcv_transactions_interface.receipt_source_code%type,--Bug13844195
  project_id                   rcv_transactions_interface.project_id%type,--Bug13844195
  task_id                         rcv_transactions_interface.task_id%type,--Bug13844195
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE locator_id_record_type IS RECORD
 (locator		rcv_transactions_interface.locator%type,
  locator_id		rcv_transactions_interface.locator_id%type,
  subinventory          rcv_transactions_interface.subinventory%type,
  to_organization_id    rcv_transactions_interface.to_organization_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE location_id_record_type IS RECORD
 (location_code		rcv_transactions_interface.location_code%type,
  location_id		rcv_transactions_interface.location_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE reason_id_record_type IS RECORD
 (reason_name		rcv_transactions_interface.reason_name%type,
  reason_id		rcv_transactions_interface.reason_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE quantity_shipped_record_type IS RECORD
 (quantity_shipped		rcv_transactions_interface.quantity_shipped%type,
  unit_of_measure		rcv_transactions_interface.unit_of_measure%type,
  item_id			rcv_transactions_interface.item_id%type,
  po_line_id			rcv_transactions_interface.po_line_id%type,
  po_line_location_id		rcv_transactions_interface.po_line_location_id%type,
  to_organization_id		rcv_transactions_interface.to_organization_id%type,
  po_header_id			rcv_transactions_interface.po_header_id%type,
  interface_transaction_id	rcv_transactions_interface.interface_transaction_id%type,
  primary_quantity		rcv_transactions_interface.primary_quantity%type,
  primary_unit_of_measure	rcv_transactions_interface.primary_unit_of_measure%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE expected_receipt_record_type IS RECORD
 (expected_receipt_date	rcv_transactions_interface.expected_receipt_date%type,
  line_location_id	rcv_transactions_interface.po_line_location_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE quantity_invoiced_record_type IS RECORD
 (quantity_invoiced	rcv_transactions_interface.quantity_invoiced%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE ref_integrity_record_type IS RECORD
 (to_organization_id	rcv_transactions_interface.to_organization_id%type,
  po_line_location_id	rcv_transactions_interface.po_line_location_id%type,
  po_header_id		rcv_transactions_interface.po_header_id%type,
  po_line_id		rcv_transactions_interface.po_line_id%type,
  vendor_id		rcv_transactions_interface.vendor_id%type,
  vendor_item_num	rcv_transactions_interface.vendor_item_num%type,
  vendor_site_id	rcv_transactions_interface.vendor_site_id%type,
  po_revision_num	rcv_transactions_interface.po_revision_num%type,
  item_id		mtl_system_items_kfv.inventory_item_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType,
  parent_txn_id rcv_transactions_interface.parent_transaction_id%TYPE);
/*
 Added the 'parent_txn_id' column to above rec so as to handle bug 6447564 issue.
*/

 TYPE freight_carrier_record_type IS RECORD
 (to_organization_id	rcv_transactions_interface.to_organization_id%type,
  freight_carrier_code	rcv_transactions_interface.freight_carrier_code%type,
  po_header_id		po_headers.po_header_id%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

 TYPE tax_name_record_type IS RECORD
 (tax_name		rcv_transactions_interface.tax_name%type,
  error_record		rcv_shipment_object_sv.ErrorRecType);

--FRKHAN 12/18/98 add new record type for country of origin
  TYPE country_of_origin_record_type IS RECORD
 (country_of_origin_code	rcv_transactions_interface.country_of_origin_code%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 TYPE cum_quantity_record_type IS RECORD
 (to_organization_id		rcv_transactions_interface.to_organization_id%type,
  po_header_id			rcv_transactions_interface.po_header_id%type,
  vendor_cum_shipped_qty	rcv_transactions_interface.vendor_cum_shipped_qty%type,
  transaction_date		rcv_transactions_interface.transaction_date%type,
  vendor_id			rcv_transactions_interface.vendor_id%type,
  vendor_site_id		rcv_transactions_interface.vendor_site_id%type,
  item_id			rcv_transactions_interface.item_id%type,
  quantity_shipped		rcv_transactions_interface.quantity_shipped%type,
  unit_of_measure		rcv_transactions_interface.unit_of_measure%type,
  primary_unit_of_measure	rcv_transactions_interface.primary_unit_of_measure%type,
  error_record			rcv_shipment_object_sv.ErrorRecType);

/*===========================================================================
  PROCEDURE NAME:	create_shipment_line()

  DESCRIPTION:          Creates the receiving shipment object, namely new rows in the
			RCV_SHIPMENT_LINES tables

  PARAMETERS:           Line record type
			Header identifier (new)
			Asn type
			Lines fatal flag

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/23/96   Created
===========================================================================*/
  PROCEDURE create_shipment_line (X_cascaded_table		IN OUT	NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
				n				IN OUT NOCOPY  binary_integer,
		   		X_header_id			IN	rcv_headers_interface.header_interface_id%type,
		   		X_asn_type			IN	rcv_headers_interface.asn_type%type,
                                V_header_record                 IN OUT NOCOPY  rcv_shipment_header_sv.headerrectype);

 END RCV_SHIPMENT_LINE_SV;


/
