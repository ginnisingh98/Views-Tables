--------------------------------------------------------
--  DDL for Package OE_BULK_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEBVPRCS.pls 120.0.12010000.2 2008/11/18 13:05:20 smusanna ship $ */

-- added for HVOP Tax project
G_HEADER_INDEX   NUMBER;
G_BOOKING_FAILED BOOLEAN;

---------------------------------------------------------------------
-- PROCEDURE Insert_Adjustments
--
-- Inserts manual price adjustments for this bulk import batch,
-- from interface tables into oe_price_adjustments table.
-- This API should be called before Price_Orders to ensure that
-- manual adjustments are applied when pricing the order.
---------------------------------------------------------------------

PROCEDURE Insert_Adjustments
        (p_batch_id            IN NUMBER
        ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        );


---------------------------------------------------------------------
-- PROCEDURE Price_Orders
--
-- Pricing for all orders in this batch.
-- IN parameter -
-- p_header_rec: order headers in the batch
---------------------------------------------------------------------

PROCEDURE Price_Orders
        (p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,p_process_tax        IN VARCHAR2 DEFAULT 'N'
        ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        );

PROCEDURE Update_Pricing_Attributes
        (p_line_tbl          IN OE_ORDER_PUB.LINE_TBL_TYPE
        );

END OE_BULK_PRICE_PVT;

/
