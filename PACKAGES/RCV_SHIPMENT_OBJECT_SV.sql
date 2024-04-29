--------------------------------------------------------
--  DDL for Package RCV_SHIPMENT_OBJECT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SHIPMENT_OBJECT_SV" AUTHID CURRENT_USER as
/* $Header: RCVCHTIS.pls 120.0.12010000.1 2008/07/24 14:35:03 appldev ship $  */
/*===========================================================================
  PACKAGE NAME:		rcv_shipment_object_sv

  DESCRIPTION:          Contains the server side APIs: high-level record types,
			cursors and record type variables.

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                DFong

  PROCEDURES/FUNCTIONS:

============================================================================*/

/* ksareddy 2481798 performance issue - cache the is_edi_installed flag */
g_is_edi_installed varchar2(1) := NULL;


 TYPE ErrorRecType IS RECORD
 (error_status		varchar2(1),
  error_message		varchar2(255));

 uom_class		po_line_locations.unit_of_measure_class%type;
 ship_to_org_id		po_line_locations.ship_to_organization_id%type;
 receipt_code		po_line_locations.receipt_days_exception_code%type;
 error_code		varchar2(1);
 error_text		varchar2(255);

/* ksareddy 2506961 - support for parallel processing of RVCTP */
 cursor c1 (x_request_id number, x_group_id NUMBER) is
      select * from rcv_headers_interface
      where NVL(asn_type,'STD') in ('ASN','ASBN','STD')
      and   processing_status_code in ('RUNNING')
      and   nvl(validation_flag,'N') = 'Y'
      and   processing_request_id  = x_request_id
			and   group_id = decode(x_group_id, 0, group_id, x_group_id)
      order by transaction_type,shipment_num
      for update of processing_status_code nowait;

 cursor c2 (x_header_interface_id number) is
      select rcv_transactions_interface.*,
	     rowid		row_id,
	     uom_class		unit_of_measure_class,
	     ship_to_org_id	ship_to_organization_id,
	     receipt_code	receipt_days_exception_code,
	     error_code		error_status,
	     error_text		error_message
	     from rcv_transactions_interface
      where header_interface_id = x_header_interface_id
        and nvl(validation_flag,'N') = 'Y'
      order by document_line_num;

 TYPE cascaded_trans_rec_type is RECORD
 (transaction_record		rcv_shipment_object_sv.c2%rowtype,
  error_record			rcv_shipment_object_sv.ErrorRecType);

 -- Need 7.3 and Above for defining the cascaded_trans_tab_type record type below.

 TYPE cascaded_trans_tab_type IS TABLE OF rcv_shipment_object_sv.c2%rowtype
 INDEX BY BINARY_INTEGER;

 TYPE organization_id_record_type IS RECORD
 (organization_name		org_organization_definitions.organization_name%type,
  organization_code		org_organization_definitions.organization_code%type,
  organization_id		org_organization_definitions.organization_id%type,
  error_record			ErrorRecType);

 TYPE location_id_record_type IS RECORD
 (location_id			hr_locations.location_id%type,
  location_code			hr_locations.location_code%type,
  organization_id		org_organization_definitions.organization_id%type,
  error_record			ErrorRecType);

 TYPE employee_id_record_type IS RECORD
 (employee_name			hr_employees.full_name%type,
  employee_id			hr_employees.employee_id%type,
  error_record			ErrorRecType);

/*===========================================================================
  PROCEDURE NAME:	create_object()

  DESCRIPTION:          Creates the receiving shipment object, namely new rows in the
			RCV_SHIPMENT_HEADERS and RCV_SHIPMENT_LINES tables.  Prior to
			insert, create_object() will derive, default and validate columns
			in the rcv_headers_interface and rcv_transactions_interface tables.

  PARAMETERS:

	x_request_id:  The group of rows that this submission of the
                       processor should work on.


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/23/96   Created
===========================================================================*/

-- ksareddy - changed signature to support parallel processing in RVCTP - 2506961
 PROCEDURE create_object (x_request_id NUMBER, x_group_id NUMBER DEFAULT 0);

 END RCV_SHIPMENT_OBJECT_SV;


/
