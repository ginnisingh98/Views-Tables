--------------------------------------------------------
--  DDL for Package RCV_ROI_PREPROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROI_PREPROCESSOR" AUTHID CURRENT_USER as
/* $Header: RCVPREPS.pls 120.4.12010000.2 2008/10/09 18:11:41 vthevark ship $*/

	-- Global vars cached for performance or convenience
    g_is_edi_installed varchar2(1) := NULL;
    g_strict VARCHAR2(1) := 'N';

	-- Custom types used in the transactions cursor
 	uom_class      po_line_locations.unit_of_measure_class%type;
 	ship_to_org_id po_line_locations.ship_to_organization_id%type;
 	receipt_code   po_line_locations.receipt_days_exception_code%type;
 	value_basis    po_lines.order_type_lookup_code%type;
 	purchase_basis po_lines.purchase_basis%type;
 	matching_basis po_lines.matching_basis%type;
 	error_code     varchar2(1);
 	error_text     varchar2(255);
	derive_values          Varchar2(1);
        cascaded_table_index   number;

	-- Our main loop cursors
	-- This is for picking up the RECEIVE and SHIP txns, which
	-- will have headers in rcv_headers_interface
    cursor headers_cur (x_request_id number, x_group_id NUMBER, x_header_interface_id NUMBER) is
      select * from rcv_headers_interface
      where NVL(asn_type,'STD') in ('ASN','ASBN','STD','WC','LCM') /* lcm changes */
      and   processing_status_code in ('RUNNING', 'SUCCESS')
      and   ( nvl(validation_flag,'N') = 'Y' OR
              processing_status_code = 'SUCCESS') -- include sucess rows for multi-line asn
      and   (processing_request_id = x_request_id)
      and   (group_id = x_group_id or x_group_id = 0)
      and header_interface_id = decode(x_header_interface_id, 0, group_id, x_header_interface_id)
      -- order by transaction_type,shipment_num
      for update of processing_status_code nowait;

	-- This is for picking up the all the transaction lines
	-- existing in rti for the given request and group ids
	-- including the child / headerless transactions
	-- such as corrections, transfers, inspections, returns, and deliveries.
	cursor txns_cur (x_request_id NUMBER, x_group_id NUMBER) is
      select rcv_transactions_interface.*,
         rowid      		row_id,
         uom_class      unit_of_measure_class,
         ship_to_org_id ship_to_organization_id,
         receipt_code   receipt_days_exception_code,
         value_basis,
         purchase_basis,
         error_code     error_status,
         error_text     error_message,
	     derive_values      derive,
         cascaded_table_index derive_index
         from rcv_transactions_interface
      where  (processing_request_id = x_request_id)
      and   (group_id = x_group_id or x_group_id = 0)
      and   processing_status_code in ('RUNNING')
      and nvl(validation_flag,'N') = 'Y'
      order by order_transaction_id,interface_transaction_id asc;
      -- order by document_line_num;

    -- Custom record types used for derivation and defaulting
 	TYPE error_rec_type IS RECORD
 	(error_status      varchar2(1),
  	 error_message     varchar2(255));

    TYPE cascaded_trans_rec_type is RECORD
 	(transaction_record        RCV_ROI_PREPROCESSOR.txns_cur%rowtype,
  	 error_record          RCV_ROI_PREPROCESSOR.error_rec_type);

 	TYPE cascaded_trans_tab_type IS TABLE OF
 		RCV_ROI_PREPROCESSOR.txns_cur%rowtype
 	INDEX BY BINARY_INTEGER;

    TYPE organization_id_record_type IS RECORD
 	(organization_name     org_organization_definitions.organization_name%type,
  	 organization_code     org_organization_definitions.organization_code%type,
  	 organization_id       org_organization_definitions.organization_id%type,
  	 error_record          RCV_ROI_PREPROCESSOR.error_rec_type);

 	TYPE location_id_record_type IS RECORD
 	(location_id           hr_locations.location_id%type,
  	 location_code         hr_locations.location_code%type,
  	 organization_id       org_organization_definitions.organization_id%type,
  	 error_record          RCV_ROI_PREPROCESSOR.error_rec_type);

 	TYPE employee_id_record_type IS RECORD
 	(employee_name         hr_employees.full_name%type,
  	 employee_id           hr_employees.employee_id%type,
  	 error_record          RCV_ROI_PREPROCESSOR.error_rec_type);

    TYPE header_rec_type IS RECORD
    (header_record				RCV_ROI_PREPROCESSOR.headers_cur%rowtype,
     error_record				RCV_ROI_PREPROCESSOR.error_rec_type);


/*===========================================================================
  PROCEDURE NAME:   Preprocessor()

  DESCRIPTION:    Derives, defaults, and validates entries in the
						Receiving Open Interface tables,
						rcv_headers_interface and rcv_transactions_interface.
						The preprocessor also handles ASN/ASBN imports,
						creating the appropriate lines in rcv_shipment_headers
						and rcv_shipment_lines.

  PARAMETERS:

    x_request_id:  The group of rows that this submission of the
                   processor should work on.

	 X_group_id:	 The secondary grouping of rows, added for FPI
						 parallel-processing project.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DAWILLIA       03/10/03   Created, based on
													Rcv_shipment_object_sv.create_object
===========================================================================*/

PROCEDURE Preprocessor (x_request_id NUMBER , x_group_id NUMBER DEFAULT 0);

PROCEDURE process_line(
      x_cascaded_table   IN OUT NOCOPY   RCV_ROI_PREPROCESSOR.cascaded_trans_tab_type,
      n                  IN OUT NOCOPY   BINARY_INTEGER,
      x_header_id        IN              rcv_headers_interface.header_interface_id%TYPE,
      x_asn_type         IN              rcv_headers_interface.asn_type%TYPE,
      v_header_record    IN OUT NOCOPY   RCV_ROI_PREPROCESSOR.header_rec_type
   );

PROCEDURE explode_lpn_failed(
      x_interface_txn_id   	IN OUT NOCOPY   rcv_transactions_interface.interface_transaction_id%type,
      x_group_id 			NUMBER,
      x_lpn_group_id 		NUMBER
   );

PROCEDURE update_rti_error
  (p_group_id IN rcv_transactions_interface.group_id%type,
   p_interface_id IN rcv_transactions_interface.interface_transaction_id%type,
   p_header_interface_id IN rcv_transactions_interface.header_interface_id%type,
   p_lpn_group_id IN rcv_transactions_interface.lpn_group_id%type);

--Shikyu project
FUNCTION get_oe_osa_flag(
      p_oe_order_line_id NUMBER
   ) RETURN NUMBER;

END RCV_ROI_PREPROCESSOR;


/
