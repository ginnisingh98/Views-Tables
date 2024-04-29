--------------------------------------------------------
--  DDL for Package GML_PO_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: GMLIPOIS.pls 115.1 99/07/16 06:15:19 porting ship  $ */


PROCEDURE insert_rec(p_po_header_id              IN     NUMBER,
  		  p_po_line_id                IN     NUMBER,
  		  p_po_line_location_id       IN     NUMBER,
  		  p_quantity                  IN     NUMBER,
  		  p_need_by_date              IN     DATE,
  		  p_promised_date             IN     DATE,
  		  p_last_accept_date          IN     DATE,
  		  p_po_release_id             IN     NUMBER,
  		  p_cancel_flag               IN     VARCHAR2,
  		  p_closed_code               IN     VARCHAR2,
  		  p_source_shipment_id        IN     NUMBER,
  		  p_close_trig_call           IN     VARCHAR2,
  		  p_price_override            IN     NUMBER,
  		  p_ship_to_location_id       IN     NUMBER,
   	 	  p_shipment_num              IN     NUMBER
);

END GML_PO_INTERFACE;

 

/
