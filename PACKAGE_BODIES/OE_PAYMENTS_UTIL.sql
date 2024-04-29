--------------------------------------------------------
--  DDL for Package Body OE_PAYMENTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PAYMENTS_UTIL" AS
/* $Header: OEXULCMB.pls 115.21 2004/06/03 23:49:12 lkxu ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'oe_payments_Util';

--  Procedure Update_Row
PROCEDURE Update_Row
(   p_payment_types_rec	IN OUT NOCOPY Payment_Types_Rec_Type
)
IS
l_lock_control		NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- increment lock_control by 1 whenever the record is updated
    /**
    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_PRICE_ADJUSTMENTS
    WHERE  price_adjustment_id = p_payment_types_rec.price_adjustment_id;
    **/

  --  l_lock_control := l_lock_control + 1;

    UPDATE  oe_payments
    SET     PAYMENT_TRX_ID	     = p_payment_types_rec.payment_trx_id
    ,	  COMMITMENT_APPLIED_AMOUNT     = p_payment_types_rec.commitment_applied_amount
    ,	  COMMITMENT_INTERFACED_AMOUNT  = p_payment_types_rec.commitment_interfaced_amount
/* START PREPAYMENT */
    ,       PAYMENT_SET_ID      = p_payment_types_rec.payment_set_id
    ,       PREPAID_AMOUNT      = p_payment_types_rec.prepaid_amount
    ,       PAYMENT_TYPE_CODE   = p_payment_types_rec.payment_type_code
    ,       CREDIT_CARD_CODE    = p_payment_types_rec.credit_card_code
    ,       CREDIT_CARD_NUMBER  = p_payment_types_rec.credit_card_number
    ,       CREDIT_CARD_HOLDER_NAME  = p_payment_types_rec.credit_card_holder_name
    ,       CREDIT_CARD_EXPIRATION_DATE  = p_payment_types_rec.credit_card_expiration_date
/* END PREPAYMENT */
    ,       PAYMENT_LEVEL_CODE	= p_payment_types_rec.payment_level_code
    ,       HEADER_ID              = p_payment_types_rec.header_id
    ,       LINE_ID                = p_payment_types_rec.line_id
    ,       LAST_UPDATE_DATE       = p_payment_types_rec.last_update_date
    ,       LAST_UPDATED_BY        = p_payment_types_rec.last_updated_by

    WHERE   PAYMENT_TRX_ID    = p_payment_types_rec.payment_trx_id
    ;

    --  p_payment_types_rec.lock_control := l_lock_control;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_PAYMENTS_UTIL.UPDATE_ROW.' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row
PROCEDURE Insert_Row
(   p_payment_types_rec	IN OUT NOCOPY  Payment_Types_Rec_Type
)
IS
l_lock_control		NUMBER := 1;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


    INSERT  INTO oe_payments
    (       PAYMENT_TRX_ID
    ,       COMMITMENT_APPLIED_AMOUNT
    ,       COMMITMENT_INTERFACED_AMOUNT
/* START PREPAYMENT */
    ,       PAYMENT_SET_ID
    ,       PREPAID_AMOUNT
    ,       PAYMENT_TYPE_CODE
    ,       CREDIT_CARD_CODE
    ,       CREDIT_CARD_NUMBER
    ,       CREDIT_CARD_HOLDER_NAME
    ,       CREDIT_CARD_EXPIRATION_DATE
/* END PREPAYMENT */
    ,       PAYMENT_LEVEL_CODE
    ,       HEADER_ID
    ,       LINE_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       REQUEST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       PAYMENT_NUMBER
    )
    VALUES
    (       p_payment_types_rec.payment_trx_id
    ,       p_payment_types_rec.commitment_applied_amount
    ,       p_payment_types_rec.commitment_interfaced_amount
/* START PREPAYMENT */
    ,       p_payment_types_rec.payment_set_id
    ,       p_payment_types_rec.prepaid_amount
    ,       p_payment_types_rec.payment_type_code
    ,       p_payment_types_rec.credit_card_code
    ,       p_payment_types_rec.credit_card_number
    ,       p_payment_types_rec.credit_card_holder_name
    ,       p_payment_types_rec.credit_card_expiration_date
/* END PREPAYMENT */
    ,       p_payment_types_rec.payment_level_code
    ,       p_payment_types_rec.header_id
    ,       p_payment_types_rec.line_id
    ,       p_payment_types_rec.creation_date
    ,       p_payment_types_rec.created_by
    ,       p_payment_types_rec.last_update_date
    ,       p_payment_types_rec.last_updated_by
    ,       p_payment_types_rec.last_update_login
    ,       p_payment_types_rec.request_id
    ,       p_payment_types_rec.program_application_id
    ,       p_payment_types_rec.program_id
    ,       p_payment_types_rec.program_update_date
    ,       p_payment_types_rec.context
    ,       p_payment_types_rec.attribute1
    ,       p_payment_types_rec.attribute2
    ,       p_payment_types_rec.attribute3
    ,       p_payment_types_rec.attribute4
    ,       p_payment_types_rec.attribute5
    ,       p_payment_types_rec.attribute6
    ,       p_payment_types_rec.attribute7
    ,       p_payment_types_rec.attribute8
    ,       p_payment_types_rec.attribute9
    ,       p_payment_types_rec.attribute10
    ,       p_payment_types_rec.attribute11
    ,       p_payment_types_rec.attribute12
    ,       p_payment_types_rec.attribute13
    ,       p_payment_types_rec.attribute14
    ,       p_payment_types_rec.attribute15
    ,       p_payment_types_rec.payment_number
    );

    -- p_payment_types_rec.lock_control := l_lock_control;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_PAYMENTS_UTIL.INSERT_ROW.' , 1 ) ;
    END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX Then
       --self correction on this error so that it would not happen again
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row:'||SQLERRM
            );
        END IF;

        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Insert_Row:'||SQLERRM);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':INSER_ROW:'||SQLERRM ) ;
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row:'||SQLERRM
            );
        END IF;

        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Insert_Row:'||SQLERRM);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row
PROCEDURE Delete_Row
(   p_payment_trx_id           IN  NUMBER := FND_API.G_MISS_NUM
,   p_header_id              IN  NUMBER := FND_API.G_MISS_NUM
,   p_line_id              IN  NUMBER := FND_API.G_MISS_NUM
)
IS
l_return_status		VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING DELETING COMMITMENT FOR LINE: '||P_LINE_ID , 1 ) ;
    END IF;

    IF p_payment_trx_id IS NOT NULL AND p_payment_trx_id <> FND_API.G_MISS_NUM THEN
      DELETE  FROM oe_payments
      WHERE   payment_trx_id = p_payment_trx_id;
    END IF;

    IF p_line_id IS NOT NULL AND p_line_id <> FND_API.G_MISS_NUM
       AND p_header_id IS NOT NULL AND p_header_id <> FND_API.G_MISS_NUM THEN
      DELETE  FROM oe_payments
      WHERE   line_id = p_line_id
      AND     header_id = p_header_id;
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':DELETE_ROW:'||SQLERRM ) ;
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Procedure Query_Row

PROCEDURE Query_Row
(   p_payment_trx_id     	IN  NUMBER
,   p_header_id		  	IN  NUMBER
,   p_line_id				IN 	NUMBER
,   x_Payment_types_Rec	IN OUT NOCOPY Payment_Types_Rec_Type
)
IS
  l_Payment_Types_Tbl	Payment_Types_Tbl_Type;
  l_return_status		VARCHAR2(30);
BEGIN

    Query_Rows
        (   p_payment_trx_id        => p_payment_trx_id
	   ,   p_header_id			=> p_header_id
	   ,   p_line_id			=> p_line_id
	   ,   x_Payment_Types_Tbl => l_Payment_Types_Tbl
	   ,   x_return_status	  => l_return_status
	   );
    x_Payment_Types_Rec := l_Payment_Types_Tbl(1);


END Query_Row;

--  Procedure Query_Rows
PROCEDURE Query_Rows
(   p_payment_trx_id           IN  NUMBER := FND_API.G_MISS_NUM
,   p_Header_id            IN  NUMBER := FND_API.G_MISS_NUM
,   p_line_id              IN  NUMBER := FND_API.G_MISS_NUM
,   x_Payment_Types_Tbl    IN OUT NOCOPY Payment_Types_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_count			NUMBER;

CURSOR l_payment_types_csr IS
    SELECT  PAYMENT_TRX_ID
,   COMMITMENT_APPLIED_AMOUNT
,   COMMITMENT_INTERFACED_AMOUNT
/* START PREPAYMENT */
,   PAYMENT_SET_ID
,   PREPAID_AMOUNT
,   PAYMENT_TYPE_CODE
,   CREDIT_CARD_CODE
,   CREDIT_CARD_NUMBER
,   CREDIT_CARD_HOLDER_NAME
,   CREDIT_CARD_EXPIRATION_DATE
/* END PREPAYMENT */
,   PAYMENT_LEVEL_CODE
,   HEADER_ID
,   LINE_ID
,   CREATION_DATE
,   CREATED_BY
,   LAST_UPDATE_DATE
,   LAST_UPDATED_BY
,   LAST_UPDATE_LOGIN
,   REQUEST_ID
,   PROGRAM_APPLICATION_ID
,   PROGRAM_ID
,   PROGRAM_UPDATE_DATE
,   CONTEXT
,   ATTRIBUTE1
,   ATTRIBUTE2
,   ATTRIBUTE3
,   ATTRIBUTE4
,   ATTRIBUTE5
,   ATTRIBUTE6
,   ATTRIBUTE7
,   ATTRIBUTE8
,   ATTRIBUTE9
,   ATTRIBUTE10
,   ATTRIBUTE11
,   ATTRIBUTE12
,   ATTRIBUTE13
,   ATTRIBUTE14
,   ATTRIBUTE15
,   PAYMENT_AMOUNT
    FROM   oe_payments
    WHERE  PAYMENT_TRX_ID = p_payment_trx_id
    AND    nvl(PAYMENT_TYPE_CODE, 'COMMITMENT') = 'COMMITMENT'
    AND    line_id = p_line_id
    AND	   HEADER_ID = p_header_id
  UNION
    SELECT  PAYMENT_TRX_ID
,   COMMITMENT_APPLIED_AMOUNT
,   COMMITMENT_INTERFACED_AMOUNT
/* START PREPAYMENT */
,   PAYMENT_SET_ID
,   PREPAID_AMOUNT
,   PAYMENT_TYPE_CODE
,   CREDIT_CARD_CODE
,   CREDIT_CARD_NUMBER
,   CREDIT_CARD_HOLDER_NAME
,   CREDIT_CARD_EXPIRATION_DATE
/* END PREPAYMENT */
,   PAYMENT_LEVEL_CODE
,   HEADER_ID
,   LINE_ID
,   CREATION_DATE
,   CREATED_BY
,   LAST_UPDATE_DATE
,   LAST_UPDATED_BY
,   LAST_UPDATE_LOGIN
,   REQUEST_ID
,   PROGRAM_APPLICATION_ID
,   PROGRAM_ID
,   PROGRAM_UPDATE_DATE
,   CONTEXT
,   ATTRIBUTE1
,   ATTRIBUTE2
,   ATTRIBUTE3
,   ATTRIBUTE4
,   ATTRIBUTE5
,   ATTRIBUTE6
,   ATTRIBUTE7
,   ATTRIBUTE8
,   ATTRIBUTE9
,   ATTRIBUTE10
,   ATTRIBUTE11
,   ATTRIBUTE12
,   ATTRIBUTE13
,   ATTRIBUTE14
,   ATTRIBUTE15
,   PAYMENT_AMOUNT
    FROM  oe_payments
    WHERE line_id = p_line_id
    AND   nvl(PAYMENT_TYPE_CODE, 'COMMITMENT') = 'COMMITMENT'
    AND   header_id = p_header_id
    ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    /***
    IF
    (p_price_adjustment_id IS NOT NULL
     AND
     p_price_adjustment_id <> FND_API.G_MISS_NUM)
    AND
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: price_adjustment_id = '|| p_price_adjustment_id || ', line_id = '|| p_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    ***/


    --  Loop over fetched records

    l_count := 1;
    FOR l_implicit_rec IN l_payment_types_csr LOOP

        x_payment_types_tbl(l_count).payment_trx_id  := l_implicit_rec.payment_trx_id;
        x_payment_types_tbl(l_count).commitment_applied_amount  := l_implicit_rec.commitment_applied_amount;
        x_payment_types_tbl(l_count).commitment_interfaced_amount  := l_implicit_rec.commitment_interfaced_amount;
/* START PREPAYMENT */
        x_payment_types_tbl(l_count).payment_set_id  := l_implicit_rec.payment_set_id;
        x_payment_types_tbl(l_count).prepaid_amount  := l_implicit_rec.prepaid_amount;
        x_payment_types_tbl(l_count).payment_type_code  := l_implicit_rec.payment_type_code;
        x_payment_types_tbl(l_count).credit_card_code := l_implicit_rec.credit_card_code;
        x_payment_types_tbl(l_count).credit_card_number := l_implicit_rec.credit_card_number;
        x_payment_types_tbl(l_count).credit_card_holder_name  := l_implicit_rec.credit_card_holder_name;
        x_payment_types_tbl(l_count).credit_card_expiration_date := l_implicit_rec.credit_card_expiration_date;
/* END PREPAYMENT */
        x_payment_types_tbl(l_count).payment_level_code  := l_implicit_rec.payment_level_code;
        x_payment_types_tbl(l_count).header_id       := l_implicit_rec.HEADER_ID;
        x_payment_types_tbl(l_count).line_id         := l_implicit_rec.LINE_ID;
        x_payment_types_tbl(l_count).creation_date := l_implicit_rec.CREATION_DATE;
        x_payment_types_tbl(l_count).created_by := l_implicit_rec.CREATED_BY;
        x_payment_types_tbl(l_count).last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_payment_types_tbl(l_count).last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_payment_types_tbl(l_count).last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        x_payment_types_tbl(l_count).request_id := l_implicit_rec.REQUEST_ID;
        x_payment_types_tbl(l_count).program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        x_payment_types_tbl(l_count).program_id := l_implicit_rec.PROGRAM_ID;
        x_payment_types_tbl(l_count).program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        x_payment_types_tbl(l_count).context := l_implicit_rec.CONTEXT;
        x_payment_types_tbl(l_count).attribute1 := l_implicit_rec.ATTRIBUTE1;
        x_payment_types_tbl(l_count).attribute2 := l_implicit_rec.ATTRIBUTE2;
        x_payment_types_tbl(l_count).attribute3 := l_implicit_rec.ATTRIBUTE3;
        x_payment_types_tbl(l_count).attribute4 := l_implicit_rec.ATTRIBUTE4;
        x_payment_types_tbl(l_count).attribute5 := l_implicit_rec.ATTRIBUTE5;
        x_payment_types_tbl(l_count).attribute6 := l_implicit_rec.ATTRIBUTE6;
        x_payment_types_tbl(l_count).attribute7 := l_implicit_rec.ATTRIBUTE7;
        x_payment_types_tbl(l_count).attribute8 := l_implicit_rec.ATTRIBUTE8;
        x_payment_types_tbl(l_count).attribute9 := l_implicit_rec.ATTRIBUTE9;
        x_payment_types_tbl(l_count).attribute10 := l_implicit_rec.ATTRIBUTE10;
        x_payment_types_tbl(l_count).attribute11 := l_implicit_rec.ATTRIBUTE11;
        x_payment_types_tbl(l_count).attribute12 := l_implicit_rec.ATTRIBUTE12;
        x_payment_types_tbl(l_count).attribute13 := l_implicit_rec.ATTRIBUTE13;
        x_payment_types_tbl(l_count).attribute14 := l_implicit_rec.ATTRIBUTE14;
        x_payment_types_tbl(l_count).attribute15 := l_implicit_rec.ATTRIBUTE15;
   x_payment_types_tbl(l_count).payment_amount := l_implicit_rec.payment_amount;

        -- set values for non-DB fields
        x_payment_types_tbl(l_count).db_flag          := FND_API.G_TRUE;
        x_payment_types_tbl(l_count).operation        := FND_API.G_MISS_CHAR;
        x_payment_types_tbl(l_count).return_status    := FND_API.G_MISS_CHAR;

	   l_count := l_count + 1;

    END LOOP;


    --  PK sent and no rows found
    /***
    IF
    (p_payment_id IS NOT NULL
     AND
     p_payment_id <> FND_API.G_MISS_NUM)
    AND
    (x_payment_types_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;
    ***/


    --  Return fetched table

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':QUERY_ROW:'||SQLERRM ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':QUERY_ROW:'||SQLERRM ) ;
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

-- get the balance of applied commitment
FUNCTION Get_Uninvoiced_Commitment_Bal
(
  p_customer_trx_id IN NUMBER
)
RETURN NUMBER IS

  l_uninv_commitment_bal NUMBER := 0;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  BEGIN
     IF l_debug_level  >  0 THEN
	oe_debug_pub.add('ENTERING OE_PAYMENTS_UTIL.GET_UNINVOICED_COMMITMENT_BAL');
     END IF;

    IF OE_INSTALL.Get_Active_Product = 'ONT' THEN

       --bug3567339 added the following IF condition and the code for the else part.
       IF OE_Commitment_Pvt.Do_Commitment_Sequencing THEN

          SELECT
          SUM(nvl(commitment_applied_amount, 0)
            - nvl(commitment_interfaced_amount,0))
          INTO   l_uninv_commitment_bal
          FROM   oe_payments opt
          WHERE  opt.payment_trx_id  = p_customer_trx_id;
	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('pviprana: l_uninv_commitment_bal is ' || l_uninv_commitment_bal);
	   oe_debug_pub.add('pviprana: p_customer_trx_id is ' || p_customer_trx_id);
        END IF;
       ELSE
	  -- when profile options is set to NO
           SELECT
           NVL( SUM( ( NVL( ordered_quantity, 0 ) -
		       --bug3604062
--                       NVL( cancelled_quantity, 0 ) -
                       NVL( invoiced_quantity, 0 )
                     ) *
                       NVL( unit_selling_price, 0 )
                     ), 0 )
           INTO  l_uninv_commitment_bal
           FROM  oe_order_lines_all
           WHERE commitment_id    = p_customer_trx_id
           AND   NVL(line_category_code,'STANDARD') <> 'RETURN'
	   AND   NVL(invoice_interface_status_code,'NO') <> 'YES';

	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('pviprana: l_uninv_commitment_bal is ' || l_uninv_commitment_bal);
	   oe_debug_pub.add('pviprana: p_customer_trx_id is ' || p_customer_trx_id);
	END IF;
       END IF; --bug3567339 end

    ELSE

        SELECT
          NVL( SUM( ( NVL( ordered_quantity, 0 ) -
                      NVL( cancelled_quantity, 0 ) -
                      NVL( invoiced_quantity, 0 )
                    ) *
                      NVL( selling_price, 0 )
                   ), 0 )
          INTO   l_uninv_commitment_bal
          FROM   so_lines
          WHERE  commitment_id    = p_customer_trx_id
          AND    line_type_code  IN ( 'REGULAR', 'DETAIL');


    END IF;

   RETURN (l_uninv_commitment_bal);

END Get_Uninvoiced_Commitment_Bal;


END oe_payments_Util;

/
