--------------------------------------------------------
--  DDL for Package RCV_INSERT_RTI_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INSERT_RTI_SV" AUTHID CURRENT_USER as
/* $Header: RCVRTIS.pls 120.2 2005/07/19 00:46:30 usethura noship $*/

/*===========================================================================
  PACKAGE NAME:		RCV_INSERT_RTI_SV

  DESCRIPTION:		This package contains the server side maintain
                        shipments part to handle  ASN's

  CLIENT/SERVER:	Server

  OWNER:		Harsha Vadlamudi

  PROCEDURE NAMES:	insert_into_rti

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME	insert_into_rti

  DESCRIPTION:		Insert into the rcv_transactions_interface table.


  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	HVADLAMU 06/03/97 CREATED
===========================================================================*/

PROCEDURE insert_into_rti (
X_group_id		 IN  NUMBER,
X_transaction_type	 IN  VARCHAR2,
X_transaction_date	 IN  DATE,
X_processing_status_code IN  VARCHAR2,
X_processing_mode_code	 IN  VARCHAR2,
X_transaction_status_code IN VARCHAR2,
X_last_update_date	 IN  DATE,
X_last_updated_by	 IN  NUMBER,
X_last_update_login	 IN  NUMBER,
X_interface_source_code  IN  VARCHAR2,
X_creation_date		 IN  DATE,
X_created_by		 IN  NUMBER,
X_auto_transact_code	 IN  VARCHAR2,
X_receipt_source_code	 IN  VARCHAR2,
X_po_header_id           IN  NUMBER,
X_po_release_id          IN  NUMBER,
X_po_line_id             IN  NUMBER,
X_shipment_line_id       IN  NUMBER,
X_shipment_header_id     IN  NUMBER,
X_po_line_location_id    IN  NUMBER,
X_deliver_to_location_id IN  NUMBER,
X_to_organization_id     IN  NUMBER,
X_item_id                IN  NUMBER,
X_quantity_shipped       IN  NUMBER,
X_source_document_code   IN  VARCHAR2,
X_category_id            IN  NUMBER,
X_unit_of_measure        IN  VARCHAR2,
X_item_description       IN  VARCHAR2,
X_employee_id            IN  NUMBER,
X_destination_type_code  IN  VARCHAR2,
X_destination_context    IN  VARCHAR2,
X_subinventory           IN  VARCHAR2,
X_routing_header_id      IN  NUMBER,
X_primary_unit_of_measure IN  VARCHAR2,
X_ship_to_location_id    IN  NUMBER,
X_vendor_id              IN  NUMBER,
p_operating_unit_id      IN  MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE DEFAULT NULL-- New Parameter <R12 MOAC>

);


END RCV_INSERT_RTI_SV;

 

/
