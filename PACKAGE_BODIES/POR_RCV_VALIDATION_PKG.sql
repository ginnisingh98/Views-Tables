--------------------------------------------------------
--  DDL for Package Body POR_RCV_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_RCV_VALIDATION_PKG" AS
/* $Header: PORRCVVB.pls 115.4 2002/12/24 20:41:19 mrjiang noship $ */

-- Calculates TolerableQty for Receiving
procedure getTolerableQty(pLineLocationId	IN NUMBER,
		     	  pTotalQty		IN NUMBER,
			  pTolerableQty		OUT NOCOPY NUMBER,
			  pExceptionCode	OUT NOCOPY VARCHAR2) IS
  xTolerableQty		NUMBER;
  xQuantityOrdered	NUMBER;
  xQuantityReceived	NUMBER;
  xQuantityCancelled	NUMBER;
  xRcvTolerance		NUMBER;
  xExceptionCode	VARCHAR2(25);
  xPoUOMCode 		VARCHAR2(25);
BEGIN

  begin
    select nvl(pll.quantity, 0),
           nvl(pll.quantity_received, 0),
       	   nvl(pll.quantity_cancelled, 0),
           1 + (nvl(pll.qty_rcv_tolerance, 0)/100),
           pll.qty_rcv_exception_code,
           pl.unit_meas_lookup_code
    into   xQuantityOrdered, xQuantityReceived,
	   xQuantityCancelled, xRcvTolerance,
	   pExceptionCode, xPoUOMCode
    from   po_line_locations pll,
           po_lines pl
    where  pll.line_location_id = pLineLocationId
    and    pll.po_line_id = pl.po_line_id;
  exception
    when no_data_found then
	null;
  end;

  pTolerableQty :=  xQuantityOrdered * xRcvTolerance -
		    xQuantityReceived - xQuantityCancelled -
		    pTotalQty;

END;

END POR_RCV_VALIDATION_PKG;

/
