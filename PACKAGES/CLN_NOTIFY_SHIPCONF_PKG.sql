--------------------------------------------------------
--  DDL for Package CLN_NOTIFY_SHIPCONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_NOTIFY_SHIPCONF_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNNTSHS.pls 115.3 2003/11/19 06:01:16 rkrishan noship $ */

--  Package
--      CLN_NOTIFY_SHIPCONF_PKG
--
--  Purpose
--      Specs of package CLN_NOTIFY_SHIPCONF_PKG.
--
--  History
--      July-21-2003        Rahul Krishan         Created


   -- Name
   --    RAISE_UPDATE_EVENT
   -- Purpose
   --    This is the public procedure which raises an event to update collaboration
   --    passing these parameters so obtained.This procedure requires only
   --    p_internal_control_number. This procedure is called from the root of XGM map
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_UPDATE_EVENT(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_orig_ref                     IN VARCHAR2,
         p_delivery_doc_id              IN VARCHAR2,
         p_internal_control_number      IN NUMBER,
         p_partner_document_number      IN VARCHAR2 );

   -- Name
   --    REQ_ORDER_INF
   -- Purpose
   --    This API checks for the repeating tag value of RequestingOrderInformation and
   --    based on few parameters decides the value for other tags.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE REQ_ORDER_INF(
         x_return_status                IN OUT NOCOPY VARCHAR2,
         x_msg_data                     IN OUT NOCOPY VARCHAR2,
         p_gb_doc_code                  IN VARCHAR2,
         p_gb_partner_role              IN VARCHAR2,
         p_doc_identifier               IN VARCHAR2,
         x_cust_po_number               IN OUT NOCOPY VARCHAR2,
         x_delivery_name                IN OUT NOCOPY VARCHAR2 );


   -- Name
   --    UPDATE_NEW_DEL_INTERFACE
   -- Purpose
   --    This API updates the wsh_new_del_interface table with the waybill
   --    based on the delivery interface id inputted.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE UPDATE_NEW_DEL_INTERFACE(
         x_return_status                IN OUT NOCOPY VARCHAR2,
         x_msg_data                     IN OUT NOCOPY VARCHAR2,
         p_delivery_interface_id        IN VARCHAR2,
         p_delivery_name                IN VARCHAR2,
         p_waybill                      IN VARCHAR2 );


END CLN_NOTIFY_SHIPCONF_PKG;


 

/
