--------------------------------------------------------
--  DDL for Package CLN_WSH_SHIP_ORDER_OUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_WSH_SHIP_ORDER_OUT_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNWSHSS.pls 115.1 2003/11/17 12:12:31 vumapath noship $ */
-- Package
--   CLN_WSH_SO_PKG
--
-- Purpose
--    Specification of package : CLN_WSH_SO_PKG
--    This package bunbles all the procedures
--    required for 3B12 Shipping implementation
--
-- History
--    Oct-6-2003       Viswanthan Umapathy         Created


   -- Name
   --    CREATE_COLLABORATION
   -- Purpose
   --    creates a new collaboration in the collaboration history
   -- Arguments
   --
   -- Notes
   --    No specific notes

      PROCEDURE CREATE_COLLABORATION(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_delivery_number           IN VARCHAR2,
         p_tp_type                   IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_doc_dir                   IN VARCHAR2,
         p_txn_type                  IN VARCHAR2,
         p_txn_subtype               IN VARCHAR2,
         p_xmlg_doc_id               IN VARCHAR2,
         p_doc_creation_date         IN DATE,
         p_appl_ref_id               IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2);


   -- Name
   --    UPDATE_COLLABORATION
   -- Purpose
   --    Updates the collaboration in the collaboration history
   -- Arguments
   --
   -- Notes
   --    No specific notes

      PROCEDURE UPDATE_COLLABORATION(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_delivery_number           IN VARCHAR2,
         p_tp_type                   IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_tp_site_id                IN VARCHAR2,
         p_doc_dir                   IN VARCHAR2,
         p_txn_type                  IN VARCHAR2,
         p_txn_subtype               IN VARCHAR2,
         p_xmlg_doc_id               IN VARCHAR2,
         p_appl_ref_id               IN VARCHAR2,
         p_int_ctrl_num              IN VARCHAR2);


   -- Name
   --    GET_FROM_ROLE_ORG_ID
   -- Purpose
   --    Gets the Organization ID for a given Delivery Document Number
   -- Arguments
   --    Delivery Document Number
   -- Notes
   --    No specific notes

      FUNCTION GET_FROM_ROLE_ORG_ID
         (P_DOCUMENT_NUMBER IN  NUMBER)
      RETURN  NUMBER;


   -- Name
   --    GET_TO_ROLE_LOCATION_ID
   -- Purpose
   --    Gets the toRole Location ID for a given Delivery Document Number
   -- Arguments
   --    Delivery Document Number
   -- Notes
   --    No specific notes

      FUNCTION GET_TO_ROLE_LOCATION_ID
         (P_DOCUMENT_NUMBER IN  NUMBER)
      RETURN  NUMBER;


   -- Name
   --    GET_DELIVERY_INFORMATION
   -- Purpose
   --    Gets the required additional delievry information
   --    for a Delivery Document Number
   -- Arguments
   --    Delivery Document Number
   -- Notes
   --    No specific notes

      PROCEDURE GET_DELIVERY_INFORMATION(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_document_number           IN VARCHAR2,
         x_customer_po_number        OUT NOCOPY VARCHAR2,
         x_customer_id               OUT NOCOPY NUMBER,
         x_delivery_creation_date    OUT NOCOPY DATE);


END CLN_WSH_SHIP_ORDER_OUT_PKG;

 

/
