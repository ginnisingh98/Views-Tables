--------------------------------------------------------
--  DDL for Package RCV_SHIPMENT_HEADER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SHIPMENT_HEADER_SV" AUTHID CURRENT_USER as
/* $Header: RCVSHCS.pls 120.0.12010000.1 2008/07/24 14:36:53 appldev ship $ */

 TYPE headerrectype IS RECORD
 (header_record		rcv_shipment_object_sv.c1%rowtype,
  error_record		rcv_shipment_object_sv.errorrectype);

 TYPE VendorRecType IS RECORD (vendor_name po_vendors.vendor_name%type,
                                vendor_num  po_vendors.segment1%type,
                                vendor_id   po_vendors.vendor_id%type,
                                error_record rcv_shipment_object_sv.ErrorRecType);

 TYPE VendorSiteRecType IS RECORD (vendor_site_code po_vendor_sites.vendor_site_code%type,
                                    vendor_id        po_vendors.vendor_id%type,
                                    vendor_site_id   po_vendor_sites.vendor_site_id%type,
                                    organization_id  org_organization_definitions.organization_id%type,
                                    document_type    rcv_shipment_headers.asn_type%type,
                                    error_record     rcv_shipment_object_sv.ErrorRecType);

 TYPE PayRecType IS RECORD (payment_term_id         ap_terms.term_id%type,
                            payment_term_name       ap_terms.name%type,
                            error_record            rcv_shipment_object_sv.ErrorRecType);

 TYPE FreightRecType IS RECORD (freight_carrier_code org_freight.freight_code%type,
                                organization_id      org_freight.organization_id%type,
                                error_record         rcv_shipment_object_sv.ErrorRecType);

 TYPE LookupRecType IS RECORD  (lookup_code     po_lookup_codes.lookup_code%type,
                                lookup_type     po_lookup_codes.lookup_type%type,
                                error_record    rcv_shipment_object_sv.ErrorRecType);

 TYPE CurRecType IS RECORD (currency_code fnd_currencies.currency_code%type,
                            error_record  rcv_shipment_object_sv.ErrorRecType);

 TYPE InvRecType IS RECORD (
         total_invoice_amount rcv_headers_interface.total_invoice_amount%type,
         vendor_id            po_vendors.vendor_id%type,
         vendor_site_id       po_vendor_sites.vendor_site_id%type,
         error_record         rcv_shipment_object_sv.ErrorRecType);

 TYPE TaxRecType IS RECORD (
         tax_name    ap_tax_codes.name%type,
         tax_amount  rcv_headers_interface.tax_amount%type,
         error_record rcv_shipment_object_sv.ErrorRecType);

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          create_shipment_header()                         |
 |                                                                           |
 +===========================================================================*/

 procedure create_shipment_header (x_header_record in out NOCOPY rcv_shipment_header_sv.Headerrectype);

/*===========================================================================+
 |                                                                           |
 | PROCEDURE NAME:          cancel_shipment()                                |
 |                                                                           |
 | Created by Raj Bhakta 07/09/97                                            |
 +===========================================================================*/

 procedure cancel_shipment (x_header_record in out NOCOPY rcv_shipment_header_sv.Headerrectype);

END RCV_SHIPMENT_HEADER_SV;

/
