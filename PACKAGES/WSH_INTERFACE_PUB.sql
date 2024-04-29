--------------------------------------------------------
--  DDL for Package WSH_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE_PUB" AUTHID CURRENT_USER as
/* $Header: WSHDDITS.pls 115.2 2002/11/18 20:15:23 nparikh ship $ */

   C_SDEBUG    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   C_DEBUG     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--  Procedure:      Create_Shipment_Lines
--
--  Parameters:     p_delivery_details_info  IN WSH_DELIVERY_DETAILS_PKG.Delivery_Details_Rec_Type

--  Description:    This procedure is a wraper for the create_delivery_Details.
--                  It is called by any system that is pushing shipment lines
--                  into shipping system.
--
--

PROCEDURE Create_Shipment_Lines
			(p_delivery_details_info IN OUT NOCOPY   WSH_DELIVERY_DETAILS_PKG.delivery_details_rec_type,
			 x_delivery_Detail_id OUT NOCOPY  NUMBER,
			 x_return_status OUT NOCOPY  VARCHAR2);
END WSH_INTERFACE_PUB;

 

/
