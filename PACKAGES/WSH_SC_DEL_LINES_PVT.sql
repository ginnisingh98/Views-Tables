--------------------------------------------------------
--  DDL for Package WSH_SC_DEL_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_DEL_LINES_PVT" AUTHID CURRENT_USER as
/* $Header: WSHSDLNS.pls 115.0 99/07/16 08:21:20 porting ship $ */
--
-- Package
--   WSH_SC_DEL_LINES_PVT
-- Purpose
--   Will contains delivery lines server side routines specific to
-- Ship Confirm.
-- History
--   17-OCT-96  WLEE  		Created
--

  -- routine to unassign the delivery line from the delivery
  -- parameter pld_id is picking_line_detail_id
  -- Please note the routine will make a commit so that in case
  -- it need to call transaction manager to do demand/reservation
  -- transfer, the transaction manager can see the change
  FUNCTION unassign_delivery_line( pld_id		IN NUMBER,
				   original_detail_id	IN NUMBER,
				   del_id		IN NUMBER,
				   so_reservations	IN VARCHAR2)
  RETURN BOOLEAN;

  -- copy from package SHP_SC_TXN_PKG for inserting transaction ID
  FUNCTION Trx_Id(
			X_Mode		    IN     VARCHAR2,
			X_Pk_Hdr_Id 	    IN     NUMBER,
			X_Pk_Line_Id	    IN     NUMBER,
			X_Order_Category    IN     VARCHAR2
                       )
  RETURN NUMBER;

END WSH_SC_DEL_LINES_PVT;

 

/
