--------------------------------------------------------
--  DDL for Package Body OE_LOTS_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LOTS_ACK_UTIL" AS
/* $Header: OEXUSAKB.pls 115.6 2003/10/20 07:17:23 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Lots_Ack_Util';

PROCEDURE Insert_Row
(   p_line_tbl                 IN  OE_Order_Pub.Line_Tbl_Type
,   p_lot_serial_tbl           IN  OE_Order_Pub.Lot_Serial_Tbl_Type
,   p_lot_serial_val_tbl       IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type
,   p_old_line_tbl             IN  OE_Order_Pub.Line_Tbl_type
,   p_old_lot_serial_tbl       IN  OE_Order_Pub.Lot_Serial_Tbl_Type
,   p_old_lot_serial_val_tbl   IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type
,   p_reject_order             IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status             VARCHAR2(1);
l_lot_serial_rec            OE_Order_Pub.Lot_Serial_Rec_Type;
l_lot_serial_val_rec        OE_Order_Pub.Lot_Serial_Val_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Enter OE_Lots_Ack_Util.Insert_Row');
    End If;

/*
    FOR I IN 1..p_old_line_tbl.COUNT LOOP
      FOR J IN 1..p_old_lot_serial_tbl.COUNT LOOP
        IF p_old_lot_serial_tbl(J).line_index = I THEN
          IF p_reject_order = 'N' THEN
             l_lot_serial_rec      := p_lot_serial_tbl(J);
             l_lot_serial_val_rec  := p_lot_serial_val_tbl(J);
          ELSE
             l_lot_serial_rec      := p_old_lot_serial_tbl(J);
	     -- Value record is not required as record is rejected
             -- l_lot_serial_val_rec  := p_old_lot_serial_val_tbl(J);
          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BEFORE LOTSERIAL ACKNOWLEDGMENT INSERT STATEMENT' ) ;
          END IF;

           INSERT INTO OE_LOTSERIAL_ACKS
           ( ACKNOWLEDGMENT_FLAG
           , ATTRIBUTE1
           , ATTRIBUTE10
           , ATTRIBUTE11
           , ATTRIBUTE12
           , ATTRIBUTE13
           , ATTRIBUTE14
           , ATTRIBUTE15
           , ATTRIBUTE2
           , ATTRIBUTE3
           , ATTRIBUTE4
           , ATTRIBUTE5
           , ATTRIBUTE6
           , ATTRIBUTE7
           , ATTRIBUTE8
           , ATTRIBUTE9
           , BUYER_SELLER_FLAG
           , CHANGE_DATE
           , CHANGE_SEQUENCE
           , CONTEXT
           , CREATED_BY
           , CREATION_DATE
--         , ERROR_FLAG
           , FROM_SERIAL_NUMBER
--         , INTERFACE_STATUS
           , LAST_UPDATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATE_LOGIN
           , LOT_NUMBER
           , OPERATION_CODE
--         , ORDER_SOURCE
--         , ORDER_SOURCE_ID
           , ORIG_SYS_DOCUMENT_REF
           , ORIG_SYS_LINE_REF
           , ORIG_SYS_LOT_SERIAL_REF
--         , ORIG_SYS_SHIPMENT_REF
--         , PROGRAM_APPLICATION_ID
--         , PROGRAM_ID
--         , PROGRAM_UPDATE_DATE
           , QUANTITY
--         , REQUEST_ID
--         , TO_SERIAL_NUMBER
           )
          VALUES
          ( 'A'
--         , ???.ACKNOWLEDGMENT_FLAG
           , l_lot_serial_rec.ATTRIBUTE1
           , l_lot_serial_rec.ATTRIBUTE10
           , l_lot_serial_rec.ATTRIBUTE11
           , l_lot_serial_rec.ATTRIBUTE12
           , l_lot_serial_rec.ATTRIBUTE13
           , l_lot_serial_rec.ATTRIBUTE14
           , l_lot_serial_rec.ATTRIBUTE15
           , l_lot_serial_rec.ATTRIBUTE2
           , l_lot_serial_rec.ATTRIBUTE3
           , l_lot_serial_rec.ATTRIBUTE4
           , l_lot_serial_rec.ATTRIBUTE5
           , l_lot_serial_rec.ATTRIBUTE6
           , l_lot_serial_rec.ATTRIBUTE7
           , l_lot_serial_rec.ATTRIBUTE8
           , l_lot_serial_rec.ATTRIBUTE9
           , 'B'
--         , ???.BUYER_SELLER_FLAG
           , SYSDATE
--         , ???.CHANGE_DATE
           , 1
--         , ???.CHANGE_SEQUENCE
           , l_lot_serial_rec.CONTEXT
           , l_lot_serial_rec.CREATED_BY
           , l_lot_serial_rec.CREATION_DATE
--         , l_lot_serial_rec.ERROR_FLAG
           , l_lot_serial_rec.FROM_SERIAL_NUMBER
--         , l_lot_serial_rec.INTERFACE_STATUS
           , l_lot_serial_rec.LAST_UPDATED_BY
           , l_lot_serial_rec.LAST_UPDATE_DATE
           , l_lot_serial_rec.LAST_UPDATE_LOGIN
           , l_lot_serial_rec.LOT_NUMBER
           , l_lot_serial_rec.OPERATION
--         , l_lot_serial_rec.ORDER_SOURCE
--         , l_lot_serial_rec.ORDER_SOURCE_ID
           , p_old_line_tbl(I).ORIG_SYS_DOCUMENT_REF
           , p_old_line_tbl(I).ORIG_SYS_LINE_REF
           , l_lot_serial_rec.ORIG_SYS_LOTSERIAL_REF
--         , l_lot_serial_rec.ORIG_SYS_SHIPMENT_REF
--         , l_lot_serial_rec.PROGRAM_APPLICATION_ID
--         , l_lot_serial_rec.PROGRAM_ID
--         , l_lot_serial_rec.PROGRAM_UPDATE_DATE
           , l_lot_serial_rec.QUANTITY
--         , l_lot_serial_rec.REQUEST_ID
--         , l_lot_serial_rec.TO_SERIAL_NUMBER
);
        END IF;
      END LOOP;
    END LOOP;
*/

EXCEPTION

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED OTHERS ERROR EXCEPTION IN OE_LOTS_ACK_UTIL.INSERT_ROW: '||SQLERRM ) ;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
            	(G_PKG_NAME, 'OE_Lots_Ack_Util.Insert_Row');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;


PROCEDURE Delete_Row
(   p_orig_sys_document_ref         IN  VARCHAR2
,   p_change_sequence               IN  VARCHAR2
,   p_change_date                   IN  DATE
,   p_orig_sys_line_ref             IN  VARCHAR2
,   p_orig_sys_shipment_ref         IN  VARCHAR2
,   p_orig_sys_lot_serial_ref       IN  VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    DELETE  FROM OE_LOTSERIAL_ACKS
    WHERE   ORIG_SYS_DOCUMENT_REF   = p_orig_sys_document_ref
    AND     CHANGE_SEQUENCE         = p_change_sequence
    AND     CHANGE_DATE             = p_change_date
    AND     ORIG_SYS_LINE_REF       = p_orig_sys_line_ref
    AND     ORIG_SYS_SHIPMENT_REF   = p_orig_sys_shipment_ref
    AND     ORIG_SYS_LOT_SERIAL_REF = p_orig_sys_lot_serial_ref
    ;

EXCEPTION

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED OTHERS ERROR EXCEPTION IN OE_LOTS_ACK_UTIL.DELETE_ROW: '||SQLERRM ) ;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
            	(G_PKG_NAME, 'OE_Lots_Ack_Util.Delete_Row');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

END OE_Lots_Ack_Util;

/
