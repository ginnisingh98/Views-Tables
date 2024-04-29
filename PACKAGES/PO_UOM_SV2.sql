--------------------------------------------------------
--  DDL for Package PO_UOM_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UOM_SV2" AUTHID CURRENT_USER as
/* $Header: RCVTXUOS.pls 115.3 2003/07/07 20:35:26 prpeters ship $*
/*===========================================================================
  PACKAGE NAME:		PO_UOM_SV2

  DESCRIPTION:

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:

  PROCEDURE NAMES:	convert_quantity()
			convert_inv_cost()
===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	convert_inv_cost()

  DESCRIPTION:		If the current unit of measure differs from the
			primary UOM for an inventory sourced line, this
			procedure will round the inventory cost (based
			on the primary UOM in the source organization).
			The rounding is based on the uom conversion for the
			item, current, and primary UOMs.

  RETURN TYPE:		BOOLEAN

  CHANGE HISTORY:	LBROADBE	April 6, 1996	Created
===========================================================================*/
function convert_inv_cost(x_item_id          in     number,
			  x_current_uom	     in     varchar2,
			  x_primary_uom	     in     varchar2,
			  x_primary_inv_cost in     number,
			  x_result_price     in out NOCOPY number) return boolean;

/*===========================================================================
  FUNCTION NAME:	convert_quantity()

  DESCRIPTION:		This is the server-side component of the client-side
			round_line_quantity function used to handle unit of
			issue conversion for inventory-sourced requisition
			lines.  This function returns TRUE if the calling
			function should proceed with the conversion, and
			FALSE if it is not required or possible.

  RETURN TYPE:		BOOLEAN

  CHANGE HISTORY:	LBROADBE	11-15-95	Created
===========================================================================*/
function convert_quantity(x_item_id         in number,
			  x_source_org_id   in number,
			  x_order_quantity  in number,
			  x_order_uom       in varchar2,
			  x_result_quantity in out NOCOPY number,
			  x_rounding_factor in out NOCOPY number,
			  x_unit_of_issue   in out NOCOPY varchar2,
			  x_error_type      in out NOCOPY varchar2) return boolean;

/*===========================================================================
  PROCEDURE NAME:	reqimport_convert_uom_qty()

  DESCRIPTION:	        Bug#2470849, This procedure is called from Reqimport
                        and it converts the uom to the unit_of_issue of the
                        Source uom and also rounds the quantity depending
                        on the rounding factor.

  RETURN TYPE:

  CHANGE HISTORY:	PRPETERS	07/02/03	Created
===========================================================================*/
PROCEDURE reqimport_convert_uom_qty(x_request_id      in number );

END PO_UOM_SV2;

 

/
