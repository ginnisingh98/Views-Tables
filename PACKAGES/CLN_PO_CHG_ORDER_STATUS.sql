--------------------------------------------------------
--  DDL for Package CLN_PO_CHG_ORDER_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_PO_CHG_ORDER_STATUS" AUTHID CURRENT_USER AS
/* $Header: CLNPOSSS.pls 115.0 2003/12/10 09:39:38 kkram noship $ */
-- Package
--   CLN_PO_CHG_ORDER_STATUS
--
-- Purpose
--    Specification of package specification: CLN_PO_CHG_ORDER_STATUS.
--    This package functions facilitate in updating the Purchase order
--
-- History
--    Aug-06-2002       Viswanthan Umapathy         Created

   -- Need to keep track of the line numbers
   G_PO_LINE_NUMBER NUMBER;

   -- Name
   --    PROCESS_ORDER_HEADER
   -- Purpose
   --    Processes the order header details by creating and updating the collaboration history
   -- Arguments
   --   PO and SO details
   -- Notes
   --    No specific notes

      PROCEDURE PROCESS_ORDER_HEADER(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_app_ref_id                IN VARCHAR2,
         p_po_id                     IN VARCHAR2,
         p_po_rel_num                IN NUMBER,
         p_po_rev_num                IN NUMBER,
         p_so_id                     IN VARCHAR2,
         p_so_status                 IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2);



   -- Name
   --    PROCESS_ORDER_LINE
   -- Purpose
   --    Processes the order line header details by updating the PO  thru
   --    'Change PO' APIs and collaboration history. Line price gets modified
   -- Arguments
   --   PO and SO Line details
   -- Notes
   --    x_order_line_closed will be 'YES' if the SO Line Status is
   --    equivalent to any of the one defined in the lookup
   --    CLN_ORDER_LINE_CLOSE_STATUS

      PROCEDURE PROCESS_ORDER_LINE(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         x_order_line_closed         OUT NOCOPY VARCHAR2,
         p_po_id                     IN VARCHAR2,
         p_po_rel_num                IN NUMBER,
         p_po_rev_num                IN NUMBER,
         p_po_line_num               IN NUMBER,
         p_so_price                  IN NUMBER,
         p_price_currency            IN VARCHAR2,
         p_price_uom                 IN VARCHAR2,
         p_supplier_part_num         IN VARCHAR2,
         p_so_id                     IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_app_ref_id                IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2,
         -- Supplier Doc and Line Reference added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL);




   -- Name
   --    PROCESS_ORDER_LINE_SHIPMENT
   -- Purpose
   --    Processes the order line shipment by updating the PO thru 'Change PO' APIs
   --    and collaboration history
   --    Shipment Quantity and Promised date get modified
   --    If it is a RELEASE PO, Line price also gets modified
   -- Arguments
   --   PO and SO Line details
   -- Notes
   --   No Specific Notes

      PROCEDURE PROCESS_ORDER_LINE_SHIPMENT(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         x_order_line_closed         OUT NOCOPY VARCHAR2,
         p_po_id                     IN VARCHAR2,
         p_po_rel_num                IN NUMBER,
         p_po_rev_num                IN NUMBER,
         p_po_line_num               IN NUMBER,
         p_po_ship_num               IN NUMBER,
         p_po_quantity               IN NUMBER,
         p_po_quantity_uom           IN VARCHAR2,
         p_so_price                  IN NUMBER,
         p_price_currency            IN VARCHAR2,
         p_price_uom                 IN VARCHAR2,
         p_po_promised_date          IN DATE,
         p_supplier_part_num         IN VARCHAR2,
         p_so_id                     IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_app_ref_id                IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2,
         -- Additional parameters added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL,
         p_supplier_shipment_ref     IN VARCHAR2 DEFAULT NULL,
         p_parent_shipment_number    IN VARCHAR2 DEFAULT NULL);


   -- Name
   --   LOAD_CHANGES
   -- Purpose
   --   Call Process Supplier Request of Update_PO API to
   --   load all changes in to interface tables
   -- Arguments
   --   Internal Control Number
   -- Notes
   --   No Specific Notes

      PROCEDURE LOAD_CHANGES(
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         p_app_ref_id           IN  VARCHAR2,
         p_po_id                IN  VARCHAR2,
         p_so_num               IN  VARCHAR2,
         p_int_ctl_num          IN  VARCHAR2);

   -- Name
   --    GET_TRADING_PARTNER_DETAILS
   -- Purpose
   --    This procedure returns back the trading partner id
   --    and trading partner site id based the header id
   -- Arguments
   --    Header ID
   -- Notes
   --    No specific notes.

   PROCEDURE GET_TRADING_PARTNER_DETAILS(
      x_tp_id              OUT NOCOPY NUMBER,
      x_tp_site_id         OUT NOCOPY NUMBER,
      p_tp_header_id       IN  NUMBER);



   -- Name
   --    RAISE_UPDATE_EVENT
   -- Purpose
   --    This procedure raises an event to update a collaboration.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

      PROCEDURE RAISE_UPDATE_COLLABORATION(
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_data           OUT NOCOPY VARCHAR2,
         p_ref_id             IN  VARCHAR2,
         p_doc_no             IN  VARCHAR2,
         p_part_doc_no        IN  VARCHAR2,
         p_msg_text           IN  VARCHAR2,
         p_status_code        IN  NUMBER,
         p_int_ctl_num        IN VARCHAR2);



   -- Name
   --    RAISE_ADD_MSG_EVENT
   -- Purpose
   --    This procedure raises an event to add messages into collaboration history
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

      PROCEDURE RAISE_ADD_MESSAGE(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ictrl_no                     IN  NUMBER,
         p_ref1                         IN  VARCHAR2,
         p_ref2                         IN  VARCHAR2,
         p_ref3                         IN  VARCHAR2,
         p_ref4                         IN  VARCHAR2,
         p_ref5                         IN  VARCHAR2,
         p_dtl_msg                      IN  VARCHAR2);




   -- Name
   --   CALL_TAKE_ACTIONS
   -- Purpose
   --   Invokes Notification Processor TAKE_ACTIONS according to the parameter.
   -- Arguments
   --   Status - S/E/U - Sucess, Error, Unexpected Error respectively
   --   Description - Error message if the status if E/U, else 'SUCCESS'
   --   Sales Order Status
   --   Order Line Closed - YES/NO
   -- Notes
   --   No specific notes.

      PROCEDURE CALL_TAKE_ACTIONS(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);


END CLN_PO_CHG_ORDER_STATUS;

 

/
