--------------------------------------------------------
--  DDL for Package RCV_GET_DELIVERED_QTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_GET_DELIVERED_QTY" AUTHID CURRENT_USER AS
/* $Header: RCVDELQS.pls 115.3 2002/11/22 21:59:39 sbull noship $*/

PROCEDURE GET_TRANSACTION_DETAILS ( x_vendor_id         in      number,
                                    x_vendor_site_id    in      number,
                                    x_item_id           in      number,
                                    x_start_date        in      date,
                                    x_end_date          in      date,
                                    x_delivered_qty     out NOCOPY     number );

PROCEDURE GET_INTERNAL_DETAILS ( x_from_org_id       in      number,
                                 x_to_org_id         in      number,
                                 x_item_id           in      number,
                                 x_start_date        in      date,
                                 x_end_date          in      date,
                                 x_delivered_qty     out NOCOPY     number );

PROCEDURE GET_INTRANSIT_DETAILS ( x_from_org_id       in      number,
                                  x_to_org_id         in      number,
                                  x_rec_not_del_qty   out NOCOPY     number );

END RCV_GET_DELIVERED_QTY;

 

/
