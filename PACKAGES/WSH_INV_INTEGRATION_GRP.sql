--------------------------------------------------------
--  DDL for Package WSH_INV_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INV_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHINVIS.pls 115.2 2003/07/08 01:42:22 heali ship $ */


   G_PRINTERTAB   WSH_UTIL_CORE.Column_Tab_Type ;
   G_ORGTAB       WSH_UTIL_CORE.Column_Tab_Type ;
   G_ORGSUBTAB    WSH_UTIL_CORE.Column_Tab_Type ;

   PROCEDURE Find_Printer (
      p_subinventory               IN         VARCHAR2 ,
      p_organization_id            IN         NUMBER ,
      x_api_status                 OUT NOCOPY VARCHAR2,
      x_error_message              OUT NOCOPY VARCHAR2
   )  ;



   /*
   Procedure :Complete_Inv_Interface
   Description: This procedure will be called by Inventory during processing of the data from their interface
                tables.The purpose of this procedure is to update the inventory_interfaced_flag on
                wsh_delivery_details to 'Y' if inventory interface process has completed successfully
                and also to update the pending_interface_flag for the corresponding trip stops to NULL.
   */
   PROCEDURE Complete_Inv_Interface(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_txn_header_id         IN NUMBER,
        p_txn_batch_id          IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
   ) ;


END WSH_INV_INTEGRATION_GRP  ;

 

/
