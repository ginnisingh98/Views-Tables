--------------------------------------------------------
--  DDL for Package RCV_VALIDATE_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_VALIDATE_PO" AUTHID CURRENT_USER as
/* $Header: RCVTIR4S.pls 120.1.12010000.7 2014/03/03 13:11:15 gke ship $ */

FUNCTION prevent_doc_action( x_Entity             IN varchar2,
                             x_Action             IN varchar2,
                             x_Po_num             IN varchar2 DEFAULT NULL,
			     x_Org_id             IN NUMBER,
                             x_Po_header_id       IN NUMBER,
                             x_Release_num        IN NUMBER DEFAULT NULL,
                             x_Release_id         IN NUMBER DEFAULT NULL,
                             x_Po_line_num        IN NUMBER DEFAULT NULL,
                             x_Po_line_id         IN NUMBER DEFAULT NULL,
                             x_Shipment_num       IN NUMBER DEFAULT NULL,
                             x_Shipment_line_id   IN NUMBER DEFAULT NULL,
                             x_Item_id            IN NUMBER DEFAULT NULL,
			     x_item_num           IN varchar2 DEFAULT NULL,
                             x_Item_revision      IN varchar2 DEFAULT NULL,
                             x_Item_description   IN varchar2 DEFAULT NULL,
                             x_Unit_of_measure    IN varchar2 DEFAULT NULL
                           )   RETURN VARCHAR2;

  PROCEDURE validate_novation_receipts (
          p_request_id IN NUMBER,
          p_vendor_id IN NUMBER,
          p_novation_date IN DATE,
          p_header_id_tbl IN  PO_TBL_NUMBER,
          x_validation_results IN OUT NOCOPY po_multi_mod_val_results_type,
          x_validation_result_type OUT NOCOPY VARCHAR2,
          x_return_status OUT NOCOPY VARCHAR2,
          x_error_msg OUT NOCOPY VARCHAR2 );

END RCV_VALIDATE_PO;

/
