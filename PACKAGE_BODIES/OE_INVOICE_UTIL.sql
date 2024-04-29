--------------------------------------------------------
--  DDL for Package Body OE_INVOICE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INVOICE_UTIL" AS
/*  $Header: OEXUINVB.pls 120.0 2005/06/01 01:23:25 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OE_Invoice_Util';

PROCEDURE Update_Interco_Invoiced_Flag
(   p_price_adjustment_id  IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

) IS
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_Old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_return_status               VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING UPDATE_INTERCO_INVOICED_FLAG' , 1 ) ;
    END IF;
    OE_Header_Adj_Util.Lock_Rows
    	(P_PRICE_ADJUSTMENT_ID=>p_price_adjustment_id,
         X_HEADER_ADJ_TBL=>l_old_header_adj_tbl,
	     X_RETURN_STATUS => l_return_status);
    IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_Header_Adj_tbl := l_old_Header_Adj_Tbl;
    UPDATE OE_PRICE_ADJUSTMENTS
    SET    INTERCO_INVOICED_FLAG = 'Y'
	     , LOCK_CONTROL = LOCK_CONTROL + 1
    WHERE  PRICE_ADJUSTMENT_ID = p_price_adjustment_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --l_Header_Adj_tbl(1).Invoiced_Flag := 'Y';
    l_Header_Adj_tbl(1).lock_control := l_Header_Adj_tbl(1).lock_control + 1;
    OE_Order_PVT.PROCESS_REQUESTS_AND_NOTIFY(P_HEADER_ADJ_TBL =>l_Header_Adj_tbl,
                                P_OLD_HEADER_ADJ_TBL =>l_Old_Header_Adj_tbl,
                                P_PROCESS_REQUESTS => TRUE,
                                P_NOTIFY => TRUE,
                                X_RETURN_STATUS => l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT UPDATE_INTERCO_INVOICED_FLAG ( ) PROCEDURE' , 1 ) ;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Interco_Invoiced_flag'
                        );
        END IF;
END Update_Interco_Invoiced_Flag;

END OE_Invoice_Util;

/
