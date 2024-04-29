--------------------------------------------------------
--  DDL for Package WSH_INTERFACE_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHINVDS.pls 120.0.12010000.5 2010/02/25 15:55:31 sankarun ship $ */

   C_sdebug   CONSTANT NUMBER := Wsh_debug_sv.C_level1;
   C_debug    CONSTANT NUMBER := Wsh_debug_sv.C_level2;

   TYPE Interface_errors_rec_type IS RECORD (
      P_message_name                VARCHAR2 (30) DEFAULT NULL,
      P_text                        VARCHAR2 (2000) DEFAULT NULL,
      P_token1                      VARCHAR2 (250) DEFAULT NULL,
      P_value1                      VARCHAR2 (250) DEFAULT NULL,
      P_token2                      VARCHAR2 (250) DEFAULT NULL,
      P_value2                      VARCHAR2 (250) DEFAULT NULL,
      P_token3                      VARCHAR2 (250) DEFAULT NULL,
      P_value3                      VARCHAR2 (250) DEFAULT NULL,
      P_token4                      VARCHAR2 (250) DEFAULT NULL,
      P_value4                      VARCHAR2 (250) DEFAULT NULL,
      P_token5                      VARCHAR2 (250) DEFAULT NULL,
      P_value5                      VARCHAR2 (250) DEFAULT NULL,
      P_token6                      VARCHAR2 (250) DEFAULT NULL,
      P_value6                      VARCHAR2 (250) DEFAULT NULL,
      P_token7                      VARCHAR2 (250) DEFAULT NULL,
      P_value7                      VARCHAR2 (250) DEFAULT NULL,
      P_token8                      VARCHAR2 (250) DEFAULT NULL,
      P_value8                      VARCHAR2 (250) DEFAULT NULL,
      P_token9                      VARCHAR2 (250) DEFAULT NULL,
      P_value9                      VARCHAR2 (250) DEFAULT NULL,
      P_token10                     VARCHAR2 (250) DEFAULT NULL,
      P_value10                     VARCHAR2 (250) DEFAULT NULL,
      P_token11                     VARCHAR2 (250) DEFAULT NULL,
      P_value11                     VARCHAR2 (250) DEFAULT NULL,
      P_interface_table_name        Wsh_interface_errors.Interface_table_name%TYPE,
      P_interface_id                Wsh_interface_errors.Interface_id%TYPE);

   --R12.1.1 STANDALONE PROJECT
   TYPE Interface_errors_rec_tab IS TABLE OF Interface_errors_rec_type INDEX BY BINARY_INTEGER;
   -- LSP PROJECT : Added new in parameter p_client_code.
   -- Trading Partner Id value comes from xml mapping when p_client_code is not NULL
   PROCEDURE Validate_document (
      P_doc_type               IN       VARCHAR2,
      P_doc_number             IN       VARCHAR2,
      --R12.1.1 STANDALONE PROJECT
      P_doc_revision           IN       NUMBER DEFAULT NULL,
      P_trading_partner_Code   IN       VARCHAR2,
      P_action_type            IN       VARCHAR2,
      P_doc_direction          IN       VARCHAR2,
      P_orig_document_number   IN       VARCHAR2,
      p_client_code            IN       VARCHAR2 DEFAULT NULL, -- LSP PROJECT
      X_Trading_Partner_ID     IN OUT NOCOPY    NUMBER,	-- LSP PROJECT
      X_valid_doc              OUT NOCOPY       VARCHAR2,
      X_return_status          OUT NOCOPY       VARCHAR2
   );

   -- LSP PROJECT : API returns client Code associated to the given
   -- party id and party site id values. It also returns item delimiter
   -- value. This api is being called from XML gateway inbound mapping.
   PROCEDURE Get_Client_details (
      P_trading_partner_id      IN         NUMBER,
      P_trading_partner_site_id IN         NUMBER,
      p_trading_partner_type    OUT NOCOPY VARCHAR2,
      P_client_code             OUT NOCOPY VARCHAR2,
      P_item_delimiter          OUT NOCOPY VARCHAR2,
      X_return_status           OUT NOCOPY VARCHAR2
   );

     -- TPW - Distributed Organization Changes
   /*==============================================================================

   PROCEDURE NAME: Validate_Delivery_Details

   This Procedure is called from the Wsh_Inbound_Ship_Advice_Pkg.Process_Ship_Advice,
   after data is populated into the interface tables.

   This Procedure checks if the Delivery Details received in the 945,
   exists in the Supplier Instance base tables.

   ==============================================================================*/
   PROCEDURE Validate_delivery_details (
      p_delivery_interface_id  IN         NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   PROCEDURE Validate_deliveries (
      P_delivery_id     IN       NUMBER,
      X_return_status   OUT NOCOPY       VARCHAR2
   );

   PROCEDURE Compare_ship_request_advice (
      P_delivery_id     IN       NUMBER,
      X_return_status   OUT NOCOPY       VARCHAR2
   );

   PROCEDURE Log_interface_errors (
      P_interface_errors_rec   IN       Interface_errors_rec_type,
      p_msg_data               IN       VARCHAR2 DEFAULT NULL,
      p_api_name	       IN       VARCHAR2,
      X_return_status          OUT NOCOPY       VARCHAR2
   );

 -- R12.1.1 STANDALONE PROJECT
/*==============================================================================

PROCEDURE NAME: Log_Interface_Errors (Overloaded)

This Procedure is called from various procedure whenever an error is detected in
the data elements.
==============================================================================*/

   PROCEDURE Log_interface_errors (
      P_Interface_errors_rec_tab IN         Interface_errors_rec_tab,
      p_interface_action_code	 IN         VARCHAR2,
      X_return_status            OUT NOCOPY VARCHAR2
   );
END Wsh_interface_validations_pkg;

/
