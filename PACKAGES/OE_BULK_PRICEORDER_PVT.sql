--------------------------------------------------------
--  DDL for Package OE_BULK_PRICEORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_PRICEORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: OEBVOPRS.pls 120.0.12010000.1 2008/07/25 07:44:48 appldev ship $ */


G_SEED_GSA_HOLD_ID   CONSTANT NUMBER := 2;  --bug 3716296

Procedure Insert_Adjs_From_Iface
(p_batch_id      IN  NUMBER,
 x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Price_Orders
        (p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
         , p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
         , p_adjustments_exist        VARCHAR2  --pibadj
         , x_return_status OUT NOCOPY VARCHAR2
        );


/**************************************************************************************************
PROCEDURE Credit_Check
1.  OE_BULK_HEADER_UTIL.Insert_Headers will always insert booked_flag = 'N' for the header.
2.  The g_header_rec memory always contains the correct booked_flag.
3.  Before process acknowledgment, we call credit_check
4.  Credit_Check will  one by one loop through the G_HEADER_REC updates the db header book_flag as 'BOOKED' and then perform the credit check for each order
****************************************************************************************************/

PROCEDURE Credit_Check (p_header_rec IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE);

Procedure set_calc_flag_incl_item(p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
 ,                                            p_index   in   Number);



Procedure set_price_flag(p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE,
                         p_index                  Number,
                         p_header_counter         Number
                         );

Procedure set_hdr_price_flag(p_header_rec IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE);


End  OE_BULK_PRICEORDER_PVT;

/
