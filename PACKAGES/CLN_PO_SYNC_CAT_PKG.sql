--------------------------------------------------------
--  DDL for Package CLN_PO_SYNC_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_PO_SYNC_CAT_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNPOCSS.pls 115.6 2004/06/30 11:49:29 kkram noship $ */
-- Package
--   CLN_PO_SYNC_CAT_PKG
--
-- Purpose
--    Specification of package specification: CLN_PO_CATALOG_SYNC.
--    This package functions facilitate in Catalog sync operation
--    An inbound catalog will result in a Blanket purchase order
--    creation or updation
--
-- History
--    Jun-03-2003       Viswanthan Umapathy         Created


   -- Name
   --    PROCESS_ORDER_HEADER
   -- Purpose
   --    Creates a row in  PO_HEADERS_INTERFACE and updates the collaboration
   --    based on Catalog header details
   -- Arguments
   --   Catalog header details
   -- Notes
   --    No specific notes



     PROCEDURE PROCESS_HEADER (
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         x_po_hdr_id            OUT NOCOPY NUMBER,
         x_operation            OUT NOCOPY VARCHAR2,
         p_app_ref_id           IN  VARCHAR2,
         p_int_cont_num         IN  VARCHAR2,
         p_ctg_sync_id          IN  VARCHAR2,
         p_itf_hdr_id           IN  NUMBER,
         p_batch_id             IN  NUMBER,
         p_doc_type             IN  VARCHAR2,
         p_tp_id                IN  NUMBER,
         p_tp_site_id           IN  NUMBER,
         p_ctg_name             IN  VARCHAR2,
         p_eff_date             IN  DATE,
         p_exp_date             IN  DATE,
         p_currency             IN  NUMBER);


   -- Name
   --    PROCESS_LINE
   -- Purpose
   --    Creates or updates a BPO Line
   --    By creating a row in  PO_LINES_INTERFACE
   --    Updates the collaboration,
   --    Based on Catalog line details
   -- Arguments
   --    Catalog line header details
   -- Notes
   --   No Specific Notes

      PROCEDURE PROCESS_LINE(
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         x_line_num             OUT NOCOPY NUMBER,
         p_operation            IN  VARCHAR2,
         p_hdr_id               IN  NUMBER,
         p_app_ref_id           IN  VARCHAR2,
         p_int_cont_num         IN  VARCHAR2,
         p_ctg_name             IN  VARCHAR2,
         p_itf_hdr_id           IN  NUMBER,
         p_itf_lin_id           IN  NUMBER,
         p_vdr_part_num         IN  VARCHAR2,
         p_item_desc            IN  VARCHAR2,
         p_item                 IN  VARCHAR2,
         p_item_rev             IN  VARCHAR2,
         p_category             IN  VARCHAR2,
         p_uom                  IN  VARCHAR2,
         p_item_min_ord_quan    IN  VARCHAR2,
         p_price                IN  NUMBER,
         p_price_uom            IN  VARCHAR2,
         p_price_currency       IN  VARCHAR2,
         p_attribute1           IN  VARCHAR2,
         p_attribute2           IN  VARCHAR2,
         p_attribute3           IN  VARCHAR2,
         p_attribute4           IN  VARCHAR2,
         p_attribute5           IN  VARCHAR2,
         p_attribute6           IN  VARCHAR2,
         p_attribute7           IN  VARCHAR2,
         p_attribute8           IN  VARCHAR2,
         p_attribute9           IN  VARCHAR2,
         p_attribute10          IN  VARCHAR2,
         p_attribute11          IN  VARCHAR2,
         p_attribute12          IN  VARCHAR2,
         p_attribute13          IN  VARCHAR2,
         p_attribute14          IN  VARCHAR2,
         p_attribute15          IN  VARCHAR2);


   -- Name
   --    PROCESS_PRICE_BREAKS
   -- Purpose
   --    Creates a PRICE BREAK row in  PO_LINES_INTERFACE
   --    based on Catalog line details
   -- Arguments
   --   Catalog line details and price break details
   -- Notes
   --   No Specific Notes

   -- BUG 3138217 - CURRENCY VALIDATION TO BE DONE ON THE BUY SIDE
   -- Added parameter x_bpo_cur_updated      IN OUT NOCOPY VARCHAR2

      PROCEDURE PROCESS_PRICE_BREAKS(
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         x_bpo_cur_updated      IN OUT NOCOPY VARCHAR2,
         p_app_ref_id           IN  VARCHAR2,
         p_int_cont_num         IN  VARCHAR2,
         p_ctg_name             IN  VARCHAR2,
         p_itf_hdr_id           IN  NUMBER,
         p_itf_lin_id           IN  NUMBER,
         p_line_num             IN  NUMBER,
         p_item                 IN  VARCHAR2,
         p_item_rev             IN  VARCHAR2,
         p_eff_date             IN  DATE,
         p_exp_date             IN  DATE,
         p_quantity             IN  NUMBER,
         p_price                IN  NUMBER,
         p_price_uom            IN  VARCHAR2,
         p_price_currency       IN  VARCHAR2);


   -- Name
   --    GET_TRADING_PARTNER_DETAILS
   -- Purpose
   --    This procedure returns back the trading partner id
   --    and trading partner site id based the header id
   --
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
   --   Description - Error message if errored out else 'SUCCESS'
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


   -- Name
   --   SET_ITEM_ATTRIBUTES
   -- Purpose
   --   Sets the workflow item attributes requires
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE SET_ITEM_ATTRIBUTES(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);

   -- Name
   --   SET_ACTION_CREATE_OR_UPDATE
   -- Purpose
   --   Sets the ACTION column of po_heasers_interface to either CREATE or UPDATE
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE SET_ACTION_CREATE_OR_UPDATE(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);



   -- Name
   --   IS_PROCESSING_ERROR
   -- Purpose
   --   Checks if any error has occured and returns the same
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE IS_PROCESSING_ERROR(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);


   -- Name
   --   LOG_PO_OI_ERRORS
   -- Purpose
   --   Quries PO Open Interface error table and captures the errors
   --   in collaboration addmessages
   -- Arguments
   --   Interface Header ID available as a item attribute
   -- Notes
   --   No specific notes.

      PROCEDURE LOG_PO_OI_ERRORS(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);

END CLN_PO_SYNC_CAT_PKG;

 

/
