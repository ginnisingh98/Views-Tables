--------------------------------------------------------
--  DDL for Package WSH_INBOUND_SHIP_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INBOUND_SHIP_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHINSRS.pls 115.1 2002/11/12 01:42:42 nparikh ship $ */

   c_sdebug   CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug    CONSTANT NUMBER := wsh_debug_sv.c_level2;

   PROCEDURE process_ship_request (
      p_item_type               IN       VARCHAR2,
      p_item_key                IN       VARCHAR2,
      p_action_type             IN       VARCHAR2,
      p_delivery_interface_id   IN       NUMBER,
      x_delivery_id             OUT NOCOPY       NUMBER,
      x_return_status           OUT NOCOPY       VARCHAR2
   );
END wsh_inbound_ship_request_pkg;

 

/
