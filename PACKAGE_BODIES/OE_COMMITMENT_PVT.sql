--------------------------------------------------------
--  DDL for Package Body OE_COMMITMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_COMMITMENT_PVT" AS
/* $Header: OEXVCMTB.pls 115.34 2004/07/22 00:03:27 lkxu ship $ */

--  Global constant holding the package name

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'oe_commitment_pvt';
g_fmt_mask		VARCHAR2(500);

-- ar_balance :=
-- oe_balance := balance that has not been invoiced yet
-- ar_balance - oe_balance -> true balance
-- the new line total <= true balance
--
--
--
--
procedure evaluate_commitment(
		   p_commitment_id    IN NUMBER
                   ,p_header_id	      IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                   ,p_unit_selling_price IN NUMBER
)
IS

 cursor c_trx_number_cur IS
 select TRX_NUMBER
   FROM   RA_CUSTOMER_TRX
  WHERE  CUSTOMER_TRX_ID = p_commitment_id;

l_api_name             CONSTANT VARCHAR2(30) := 'Evaluate_Commitment';
l_commitment_bal            NUMBER;
l_total_balance             NUMBER;
l_converted_commitment_bal  VARCHAR2(500);
l_converted_total_balance   VARCHAR2(500);
l_trx_number                VARCHAR2(20);
l_class                     VARCHAR2(30);
l_so_source_code            VARCHAR2(30);
l_oe_installed_flag         VARCHAR2(30);
l_currency_code		varchar2(30) := 'USD';
l_precision         	NUMBER;
l_ext_precision     	NUMBER;
l_min_acct_unit     	NUMBER;
l_text			VARCHAR2(500);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_COMMITMENT_PVT' ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  If do_commitment_sequencing Then
  --new behavior this old procedure should not even get called
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' NEW COMMITMENT RETURNING TO CALLER' ) ;
    END IF;
    Return;
  End If;

  If p_unit_selling_price Is Null Or p_unit_selling_price = 0 Then
    --Return, no validation needed since the price is 0
    Return;
  End If;

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'EVALUATE COMMITMENT FOR COMMITMENTID:' || TO_CHAR ( P_COMMITMENT_ID ) , 1 ) ;
				END IF;
  l_class := NULL;
  l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
  l_oe_installed_flag := 'I';
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COMMITMENT AFTER CALLING FND_PROFILE.VALUE' ) ;
  END IF;

  l_commitment_bal := nvl(oe_globals.g_commitment_balance, 0);

  l_total_balance := l_commitment_bal - p_unit_selling_price;
					   IF l_debug_level  > 0 THEN
					       oe_debug_pub.add(  'TOTAL COMMITMENT BALANCE:'|| TO_CHAR ( L_TOTAL_BALANCE ) , 1 ) ;
					   END IF;
  BEGIN
    SELECT nvl(transactional_curr_code,'USD')
    INTO   l_currency_code from oe_order_headers
    WHERE  header_id=p_header_id;
  EXCEPTION WHEN no_data_found THEN
    l_currency_code := 'USD';
  END ;

  FND_CURRENCY.Get_Info(l_currency_code,  -- IN variable
		l_precision,
		l_ext_precision,
		l_min_acct_unit);

  FND_CURRENCY.Build_Format_Mask(G_Fmt_mask, 20, l_precision,
                                       l_min_acct_unit, TRUE
                                      );

  l_converted_commitment_bal := TO_CHAR(l_commitment_bal, g_fmt_mask);
  l_converted_total_balance := TO_CHAR(l_total_balance, g_fmt_mask);

   open c_trx_number_cur;
	 fetch c_trx_number_cur into l_trx_number;
	 close c_trx_number_cur;

   if l_commitment_bal <= 0 then
         --raise error if saved balance has exceeded allowed balance
	 FND_MESSAGE.SET_NAME('ONT','OE_COM_ZERO_BALANCE');
	 FND_MESSAGE.SET_TOKEN('COMMITMENT' , l_trx_number);
	 OE_MSG_PUB.ADD;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' COMMITMENT HAVE OVERDRAWN MORE THAN ONCE' ) ;
             oe_debug_pub.add(  ' EXPECTED ERROR IN EVALUATE_COMMITMENT' , 1 ) ;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
   -- move code to calculate_commitment
   elsif l_total_balance <= 0 then
      --not to raise error if balance - current line amount exceed
      --balance, allowing to use up last available balance
      FND_MESSAGE.Set_Name('ONT','OE_COM_BALANCE_WARNING');
      FND_MESSAGE.Set_Token('COMMITMENT',l_trx_number);
      FND_Message.Set_Token('BALANCE',TO_CHAR(l_total_balance * -1, g_fmt_mask));
      OE_MSG_PUB.ADD;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' ISSUE A WARNING ABOUT COMMITMENT HAS BEEN OVERDRAWN' ) ;
      END IF;
   -- show the message after saving the commitment
   else
        FND_MESSAGE.Set_Name('ONT','OE_COM_BALANCE');
        FND_MESSAGE.Set_Token('COMMITMENT',l_trx_number);
       -- FND_Message.Set_Token('BALANCE',l_total_balance);
       FND_Message.Set_Token('BALANCE',l_converted_total_balance);
        OE_MSG_PUB.ADD;

  end if;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING COMMITMENT' ) ;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                  ,l_api_name
               );
        END IF;

END evaluate_commitment;

FUNCTION Get_Allocate_Tax_Freight
( p_line_rec		IN 	OE_ORDER_PUB.line_rec_type
) RETURN VARCHAR2 IS

l_allocate_tax_freight		VARCHAR2(1);
v_CursorID		INTEGER;
v_SelectStmt		VARCHAR2(500);
v_allocate_tax_freight	VARCHAR2(1);
v_Dummy			INTEGER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_ALLOCATE_TAX_FREIGHT' , 1 ) ;
    END IF;

    -- implementing dynamic SQL to avoid compilation error if AR Patch D is not installed.
    v_CursorID := DBMS_SQL.OPEN_CURSOR;

    v_SelectStmt :=
	'SELECT allocate_tax_freight
           INTO :allocate_fax_freight
      	   FROM  ra_cust_trx_types_all rctt
                 ,ra_customer_trx_all rcta
    	   WHERE rctt.cust_trx_type_id = rcta.cust_trx_type_id
    	   AND   rcta.customer_trx_id = :commitment_id';

    DBMS_SQL.PARSE(v_CursorID, v_SelectStmt, DBMS_SQL.V7);
    DBMS_SQL.BIND_VARIABLE(v_CursorID, ':commitment_id', p_line_rec.commitment_id);

    DBMS_SQL.DEFINE_COLUMN(v_CursorID, 1, v_allocate_tax_freight, 20);

    v_Dummy := DBMS_SQL.EXECUTE(v_CursorID);

    LOOP
    IF DBMS_SQL.FETCH_ROWS(v_CursorID) = 0 THEN
      EXIT;
    END IF;

    DBMS_SQL.COLUMN_VALUE(v_CursorID, 1, v_allocate_tax_freight);

    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_CursorID);

    IF v_allocate_tax_freight IS NULL THEN
      v_allocate_tax_freight := 'N';
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'THE RETURNED VALUE FOR ALLOCATE_TAX_FREIGHT IS: '||V_ALLOCATE_TAX_FREIGHT , 3 ) ;
    END IF;


    /***
    SELECT NVL(allocate_tax_freight, 'N')
    INTO   l_allocate_tax_freight
    FROM   ra_cust_trx_types_all rctt
          ,ra_customer_trx_all rcta
    WHERE  rctt.cust_trx_type_id = rcta.cust_trx_type_id
    AND    rcta.customer_trx_id = p_line_rec.commitment_id;
    ***/


     RETURN(v_allocate_tax_freight);

EXCEPTION
    WHEN OTHERS THEN
      l_allocate_tax_freight := 'N';
      DBMS_SQL.CLOSE_CURSOR(v_CursorID);
END Get_Allocate_Tax_Freight;

-- get the total amount of an order line according to allocate_tax_freight flag.
FUNCTION Get_Line_Total
( p_line_rec		IN 	OE_ORDER_PUB.line_rec_type
) RETURN NUMBER IS

l_return_status		VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_total			NUMBER;
l_charge_amount		NUMBER;
l_allocate_tax_freight	VARCHAR2(1) := 'N';
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_COMMITMENT_PVT.GET_LINE_TOTAL.' , 1 ) ;
  END IF;

    l_allocate_tax_freight := Get_Allocate_Tax_Freight(p_line_rec => p_line_rec);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN OE_COMMITMENT_PVT , ALLOCATE_TAX_FREIGHT IS: '||L_ALLOCATE_TAX_FREIGHT , 3 ) ;
    END IF;

    -- get line level charges
    IF nvl(p_line_rec.ordered_quantity, 0) > 0 THEN
    OE_CHARGE_PVT.Get_Charge_Amount(
			   p_api_version_number => 1.1 ,
			   p_init_msg_list      => FND_API.G_FALSE ,
			   p_header_id          => p_line_rec.header_id ,
			   p_line_id            => p_line_rec.line_id ,
			   p_all_charges        => FND_API.G_FALSE ,
			   x_return_status      => l_return_status ,
			   x_msg_count          => l_msg_count ,
			   x_msg_data           => l_msg_data ,
			   x_charge_amount      => l_charge_amount );

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		 RAISE FND_API.G_EXC_ERROR;
     END IF;
     END IF;

     -- to include tax only if the tax calculation flag is 'Y'
     IF l_allocate_tax_freight = 'Y' THEN
       l_total := nvl(p_line_rec.ordered_quantity,0) * nvl(p_line_rec.unit_selling_price,0)
		  + nvl(p_line_rec.tax_value,0) + nvl(l_charge_amount, 0);
    ELSE
       l_total := nvl(p_line_rec.ordered_quantity,0) * nvl(p_line_rec.unit_selling_price,0);
    END IF;


  RETURN l_total;

END Get_Line_Total;


PROCEDURE calculate_commitment(
 p_request_rec          IN      OE_Order_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2

)
IS
l_line_id                       NUMBER := p_request_rec.entity_id;
l_line_rec			OE_ORDER_PUB.Line_Rec_Type;
l_payment_types_rec		OE_PAYMENTS_UTIL.Payment_Types_Rec_Type;
l_payment_types_tbl		OE_PAYMENTS_UTIL.Payment_Types_Tbl_Type;
l_return_status		VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_header_id			NUMBER;
l_commitment_id		NUMBER;
l_new_commitment_id		NUMBER;
l_commitment_applied_amount	NUMBER;
l_class			VARCHAR2(30);
l_so_source_code	VARCHAR2(30);
l_oe_installed_flag	VARCHAR2(30);
l_currency_code		varchar2(30) := 'USD';
l_precision         	NUMBER;
l_ext_precision     	NUMBER;
l_min_acct_unit     	NUMBER;
l_commitment_bal	NUMBER;
l_new_commitment_bal	NUMBER;
l_total			NUMBER;
l_ordered_quantity	NUMBER;
l_unit_selling_price	NUMBER;
l_tax_value		NUMBER;
l_allocate_tax_freight	VARCHAR2(1) := 'N';
l_commitment		VARCHAR2(20);
l_overdrawn_amount	NUMBER;
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_payment_type_code     VARCHAR2(30);
l_payment_amount        NUMBER;
l_outbound_total        NUMBER;
l_verify_payment_flag   VARCHAR2(1):= 'N';
l_show_balance		BOOLEAN := FALSE;
l_split_by		VARCHAR2(30);
-- QUOTING change
l_transaction_phase_code          VARCHAR2(30);
--bug 3560198
l_result                BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_COMMITMENT_PVT.CALCULATE_COMMITMENT FOR LINE: '||l_LINE_ID , 1 ) ;
  END IF;

  BEGIN
    SELECT 	l.header_id
	        ,l.ordered_quantity
		,l.commitment_id
		,nvl(l.unit_selling_price, 0)
		,nvl(l.tax_value,0)
                -- QUOTING change
                ,l.transaction_phase_code
                ,l.split_by
    INTO   	l_header_id
		,l_ordered_quantity
		,l_new_commitment_id
		,l_unit_selling_price
		,l_tax_value
                -- QUOTING change
                ,l_transaction_phase_code
                ,l_split_by
    FROM   	oe_order_lines_all l
    WHERE  	l.line_id = l_line_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  -- QUOTING change
  -- No need to calculate commitment for orders in negotiation phase
  if l_debug_level > 0 then
     oe_debug_pub.add('trxn phase :'||l_transaction_phase_code);
  end if;
  IF l_transaction_phase_code = 'N' THEN
     RETURN;
  END IF;

  -- bug 2405348, comment out the following code.
  /***
  IF l_new_commitment_id IS NULL  THEN
    RETURN;
  END IF;
  ***/

  -- build currency format.
  IF g_fmt_mask IS NULL THEN
    BEGIN
      SELECT nvl(transactional_curr_code,'USD')
      INTO   l_currency_code from oe_order_headers
      WHERE  header_id=l_header_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_currency_code := 'USD';
    END ;

    FND_CURRENCY.Get_Info(l_currency_code,  -- IN variable
		l_precision,
		l_ext_precision,
		l_min_acct_unit);

    FND_CURRENCY.Build_Format_Mask(G_Fmt_mask, 20, l_precision,
                                       l_min_acct_unit, TRUE
                                      );
  END IF;

  -- populating l_line_rec.
  l_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_rec.commitment_id := l_new_commitment_id;
  l_line_rec.header_id := l_header_id;
  l_line_rec.line_id := l_line_id;
  l_line_rec.ordered_quantity := l_ordered_quantity;
  l_line_rec.unit_selling_price := l_unit_selling_price;
  l_line_rec.tax_value := l_tax_value;

  -- calling the procedure to get the line total amount
  l_total := get_line_total(p_line_rec => l_line_rec);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE TOTAL RETURNED IS: '||L_TOTAL , 1 ) ;
  END IF;

  -- get the commitment balance
  l_class := NULL;
  l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
  l_oe_installed_flag := 'I';

  -- Fix Bug # 2511389: Get the commitment balance from tables.
  IF l_new_commitment_id IS NOT NULL THEN

    l_commitment_bal := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
			 l_new_commitment_id
                	,l_class
                	,l_so_source_code
                	,l_oe_installed_flag );
  END IF;

  -- l_commitment_bal := nvl(oe_globals.g_commitment_balance, 0);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COMMITMENT BALANCE IS: '||L_COMMITMENT_BAL ) ;
  END IF;

  BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING OE_PAYMENTS_UTIL.QUERY_ROWS' ) ;
    END IF;

    oe_payments_Util.Query_Rows
    	(  p_payment_trx_id		=> l_new_commitment_id    /* Bug#3536642 */
	  ,p_header_id			=> l_header_id
	  ,p_line_id			=> l_line_id
	  ,x_payment_types_tbl		=> l_payment_types_tbl
	  ,x_return_status		=> l_return_status
	 );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING OE_PAYMENTS_UTIL.QUERY_ROWS' ) ;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
  END;


  -- commitment_applied should be the lesser of the l_total and l_commitment_bal
  -- Fix Bug # 2511389: Changed logic inside following IF condition
  IF l_new_commitment_id IS NOT NULL THEN

    IF l_payment_types_tbl.COUNT > 0 THEN
         oe_debug_pub.add( 'commitment type '||l_payment_types_tbl(1).payment_type_code);
         oe_debug_pub.add( '1 : '||l_payment_types_tbl(1).payment_trx_id);
         oe_debug_pub.add( 'New commitment Id '||l_new_commitment_id);
      IF l_new_commitment_id = l_payment_types_tbl(1).payment_trx_id THEN
        /* Added nvl for the Bug #3536642 */
        oe_debug_pub.add( 'commitment applied amount '||l_payment_types_tbl(1).commitment_applied_amount);
        l_commitment_bal := l_commitment_bal + nvl(l_payment_types_tbl(1).commitment_applied_amount,0);

        --added for multiple payments
       if l_payment_types_tbl(1).payment_amount is not null
          and oe_prepayment_util.is_multiple_payments_enabled = TRUE
       then
          l_total := l_payment_types_tbl(1).payment_amount;
       end if;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMMITMENT BALANCE WITH CURRENTLY APPLIED COMMITMENT: '||L_COMMITMENT_BAL ) ;
        END IF;
      END IF;

    END IF;

    IF l_commitment_bal >= l_total THEN
      l_commitment_applied_amount := l_total;
    ELSE
      l_commitment_applied_amount := l_commitment_bal;
      l_overdrawn_amount := l_total - l_commitment_applied_amount;
    END IF;

    IF l_split_by is not null THEN
      IF l_commitment_applied_amount > oe_globals.g_original_commitment_applied THEN
         l_commitment_applied_amount := oe_globals.g_original_commitment_applied;
         l_overdrawn_amount := 0;
      END IF;
    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMMITMENT APPLIED AMOUNT IS: '||L_COMMITMENT_APPLIED_AMOUNT ) ;
    END IF;
  END IF;

  IF l_payment_types_tbl.COUNT > 0 THEN
    IF l_line_id IS NOT NULL THEN
      IF l_new_commitment_id IS NULL THEN
        oe_payments_Util.Delete_Row(p_line_id => l_line_id, p_header_id => l_header_id);
      ELSE
        -- Fix Bug # 2511389: Delete payment record if applied amount has been set to <= 0.
        IF nvl(l_commitment_applied_amount, 0) <= 0 THEN
          oe_payments_Util.Delete_Row(p_line_id => l_line_id, p_header_id => l_header_id);
        ELSE
	  IF NOT OE_GLOBALS.Equal(l_new_commitment_id, l_payment_types_tbl(1).payment_trx_id) THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATING BOTH APPLIED AMOUNT AND COMMITMENT' ) ;
            END IF;

            IF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE then
              UPDATE oe_payments
              SET    payment_trx_id = l_new_commitment_id,
                     commitment_applied_amount = l_commitment_applied_amount,
                     payment_number = nvl(payment_number, 1)
              WHERE  line_id = l_line_id
              AND    header_id = l_header_id
              AND    nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';

            ELSE
              UPDATE oe_payments
              SET    payment_trx_id = l_new_commitment_id,
                     commitment_applied_amount = l_commitment_applied_amount
              WHERE  line_id = l_line_id
              AND    header_id = l_header_id
              AND    nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';
            END IF;

            l_show_balance := TRUE;

          ELSE

            /*** Fix Bug # 2511389: Call to delete_row added above should take care of this scenario also
            IF l_commitment_bal >0 OR (l_commitment_bal <= 0 AND l_commitment_applied_amount < l_payment_types_tbl(1).commitment_applied_amount) THEN
                 IF l_ordered_quantity = 0 THEN
                   Oe_Payments_Util.Delete_Row(p_line_id => p_line_id);
                 ELSE
            ***/
            IF NVL(l_commitment_applied_amount, 0) <> NVL(l_payment_types_tbl(1).commitment_applied_amount, 0) THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'UPDATING ONLY THE APPLIED AMOUNT' ) ;
              END IF;

              IF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE then
	        UPDATE oe_payments
	        SET    commitment_applied_amount = l_commitment_applied_amount,
                       payment_number = nvl(payment_number, 1)
	        WHERE  line_id = l_line_id
                AND    header_id = l_header_id
                AND    payment_trx_id = l_new_commitment_id     /* Added this condition for Bug #3536642 */
                AND    nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';

              ELSE
	        UPDATE oe_payments
	        SET    commitment_applied_amount = l_commitment_applied_amount
	        WHERE  line_id = l_line_id
                AND    header_id = l_header_id
                AND    payment_trx_id = l_new_commitment_id    /* Added this condition for Bug #3536642 */
                AND    nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';
              END IF;

              l_show_balance := TRUE;

            END IF;
            -- END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  ELSE

    -- Fix Bug # 2511389: Added condition so that record is created only if commitment is really applied
    IF nvl(l_commitment_applied_amount, 0) > 0 THEN
      l_payment_types_rec.payment_trx_id := l_new_commitment_id;
      l_payment_types_rec.payment_type_code := 'COMMITMENT';
      l_payment_types_rec.header_id := l_header_id;
      l_payment_types_rec.line_id := l_line_id;
      l_payment_types_rec.payment_level_code := 'LINE';
      l_payment_types_rec.creation_date := SYSDATE;
      l_payment_types_rec.created_by := FND_GLOBAL.USER_ID;
      l_payment_types_rec.last_update_date := SYSDATE;
      l_payment_types_rec.last_updated_by := FND_GLOBAL.USER_ID;
      l_payment_types_rec.commitment_applied_amount := l_commitment_applied_amount;

      IF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE then

        Begin

         select (nvl(max(payment_number),0) + 1)
         into l_payment_types_rec.payment_number
         from oe_payments
         where header_id = l_header_id
         and line_id = l_line_id;

        Exception
          when no_data_found then
           l_payment_types_rec.payment_number := 1;
        end;

      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING OE_PAYMENTS_UTIL.INSERT_ROW' ) ;
      END IF;

      OE_Payments_Util.INSERT_ROW(p_payment_types_rec => l_payment_types_rec);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING OE_PAYMENTS_UTIL.INSERT_ROW' ) ;
      END IF;

      l_show_balance := TRUE;
    END IF;
  END IF;

  --bug 3560198
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Check if a request for update commitment applied has been logged or not');
     oe_debug_pub.add('p_request_rec.entity_code : '||p_request_rec.entity_code);
     oe_debug_pub.add('p_request_rec.entity_id : '||p_request_rec.entity_id);
     oe_debug_pub.add('p_request_rec.request_type : '||p_request_rec.request_type);
  END IF;
  l_result := Oe_Delayed_Requests_Pvt.Check_For_Request(p_request_rec.entity_code,
                                            p_request_rec.entity_id,
                                            OE_GLOBALS.G_UPDATE_COMMITMENT_APPLIED
                                           );
  IF l_result THEN
     oe_debug_pub.add('setting l_show_balance to false');
     l_show_balance := FALSE;
  END IF;
  --bug 3560198
  IF l_new_commitment_id IS NOT NULL AND l_show_balance THEN

    /* Fix Bug # 2511389: Replaced call the api with statement below
    l_new_commitment_bal := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
			 l_new_commitment_id
                	,l_class
                	,l_so_source_code
                	,l_oe_installed_flag );
    */

    l_new_commitment_bal := l_commitment_bal - l_commitment_applied_amount;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEW COMMITMENT BALANCE IS: '||L_NEW_COMMITMENT_BAL ) ;
    END IF;

    FND_MESSAGE.Set_Name('ONT','OE_COM_BALANCE');
    FND_MESSAGE.Set_Token('COMMITMENT',l_commitment);
    FND_Message.Set_Token('BALANCE',to_char(l_new_commitment_bal, g_fmt_mask));
    OE_MSG_PUB.ADD;

    -- to display message if the current line overdraws
    IF l_total > l_commitment_bal and nvl(l_overdrawn_amount, 0) <> 0 THEN
      FND_MESSAGE.Set_Name('ONT','OE_COM_BALANCE_WARNING');
      FND_MESSAGE.Set_Token('COMMITMENT',l_commitment);
      FND_Message.Set_Token('BALANCE',TO_CHAR(l_overdrawn_amount, g_fmt_mask));
      OE_MSG_PUB.ADD;
    END IF;
    l_show_balance := FALSE;
  END IF;

  -- Get Header Inforamtion ..
  SELECT
    payment_type_code
  , NVL(payment_amount, 0)
  INTO
    l_payment_type_code
  , l_payment_amount
  FROM  oe_order_headers_all
  WHERE header_id = l_header_id;

  -- If Credit Card Order then
  --
  IF l_payment_type_code = 'CREDIT_CARD' THEN

    -- Get the Outbound Lines Total
    --
    l_outbound_total := OE_OE_TOTALS_SUMMARY.OUTBOUND_ORDER_TOTAL(l_header_id);

    -- Log a Delayed Request only if previously authorized
    -- amount is less than the current outbound total.
    --
    IF l_payment_amount < l_outbound_total THEN
      l_verify_payment_flag := 'Y';
    END IF;

  END IF; -- Payment Type Code

  -- Log Delayed Request for Verify Payment
  --
  IF l_verify_payment_flag = 'Y' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR VERIFY PAYMENT IN COMMITMENTS' , 2 ) ;
    END IF;
    OE_delayed_requests_Pvt.log_request
        (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
         p_entity_id              => l_header_id,
         p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
         p_requesting_entity_id   => l_line_id,
         p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
         x_return_status          => l_return_status);

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_COMMITMENT_PVT.CALCULATE_COMMITMENT.' , 1 ) ;
  END IF;

END calculate_commitment;

FUNCTION get_commitment_applied_amount
( p_header_id	IN NUMBER
, p_line_id	IN NUMBER
, p_commitment_id IN NUMBER
) RETURN NUMBER IS
l_commitment_applied_amount	NUMBER := 0.0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  BEGIN
    SELECT NVL(commitment_applied_amount, 0)
    INTO  l_commitment_applied_amount
    FROM  oe_payments
    WHERE line_id = p_line_id
    AND  header_id = p_header_id
    AND  payment_trx_id = p_commitment_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_commitment_applied_amount := 0.0;
  END;

  return l_commitment_applied_amount;


  EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                  ,'OE_COMMITMENT_PVT.GET_COMMITMENT_APPLIED_AMOUNT'
               );
        END IF;

END get_commitment_applied_amount;

PROCEDURE update_commitment(
 p_line_id		IN 	NUMBER
,x_return_status OUT NOCOPY VARCHAR2

)
IS
l_split_by		VARCHAR2(30);
l_split_from_line_id	NUMBER;
l_commitment_applied_amount	NUMBER;
l_commitment_id		NUMBER;
l_new_commitment_id	NUMBER;
l_header_id		NUMBER := -1;
l_payment_types_rec	OE_PAYMENTS_UTIL.Payment_Types_Rec_Type;
l_payment_types_tbl	OE_PAYMENTS_UTIL.Payment_Types_Tbl_Type;
l_children_line_id	NUMBER;
l_children_commitment    NUMBER;
l_children_line_rec	OE_ORDER_PUB.Line_Rec_Type;
l_children_commitment_id	NUMBER;
l_children_header_id		NUMBER;
l_children_ordered_quantity	NUMBER;
l_children_unit_selling_price	NUMBER;
l_children_tax_value		NUMBER;

-- QUOTING change
l_transaction_phase_code          VARCHAR2(30);

CURSOR l_split_lines_cur IS
SELECT line_id,commitment_id,header_id,
       ordered_quantity,unit_selling_price,tax_value
FROM   oe_order_lines_all
WHERE  header_id = l_header_id
AND split_from_line_id = p_line_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING UPDATE_COMMITMENT FOR LINE_ID '||P_LINE_ID , 1 ) ;
  END IF;

  BEGIN
    SELECT 	l.header_id
		,l.commitment_id
                ,l.split_by
                ,l.split_from_line_id
                -- QUOTING change
                ,l.transaction_phase_code
    INTO   	l_header_id
		,l_new_commitment_id
               ,l_split_by
               ,l_split_from_line_id
                -- QUOTING change
               ,l_transaction_phase_code
    FROM   oe_order_lines l
    WHERE  l.line_id = p_line_id;

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
     null;
   end;

  -- QUOTING change
  -- No need to update commitment for orders in negotiation phase
  if l_debug_level > 0 then
     oe_debug_pub.add('trxn phase :'||l_transaction_phase_code);
  end if;
  IF l_transaction_phase_code = 'N' THEN
     RETURN;
  END IF;

  BEGIN
    SELECT commitment_applied_amount
    INTO   l_commitment_applied_amount
    FROM   oe_payments oop
    WHERE  nvl(payment_type_code,'COMMITMENT') = 'COMMITMENT'
    AND    line_id=p_line_id
    AND    header_id = l_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    null;
  END;

  IF l_split_by IS NOT NULL THEN

     oe_globals.g_commitment_balance
	:= oe_globals.g_original_commitment_applied - l_commitment_applied_amount;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('commitment balance is: '||oe_globals.g_commitment_balance,3);
    oe_debug_pub.add('commitment applied amount is: '||l_commitment_applied_amount,3);
    oe_debug_pub.add('original commitment applied is: '||oe_globals.g_original_commitment_applied,3);
  END IF;

  OPEN l_split_lines_cur;
  LOOP
    -- loop through split children lines to re-adjust the commitment
    -- applied amount.
    FETCH l_split_lines_cur INTO l_children_line_id,
                                   l_children_commitment_id,
                                   l_children_header_id,
                                   l_children_ordered_quantity,
                                   l_children_unit_selling_price,
                                   l_children_tax_value;

    EXIT WHEN l_split_lines_cur%NOTFOUND;

    -- populating l_line_rec.
    l_children_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;
    l_children_line_rec.commitment_id := l_children_commitment_id;
    l_children_line_rec.header_id := l_children_header_id;
    l_children_line_rec.line_id := l_children_line_id;
    l_children_line_rec.ordered_quantity := l_children_ordered_quantity;
    l_children_line_rec.unit_selling_price := l_children_unit_selling_price;
    l_children_line_rec.tax_value := l_children_tax_value;

    l_children_commitment
      := get_line_total(p_line_rec => l_children_line_rec);

   oe_debug_pub.add('Linda0721 -- child commit applied is: '||l_children_commitment,1);

    IF nvl(oe_globals.g_commitment_balance,0)  <= 0 THEN
       update oe_payments
       set commitment_applied_amount = 0
       WHERE line_id = l_children_line_id
       AND   header_id = l_header_id
       AND   nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';

    ELSIF nvl(oe_globals.g_commitment_balance, 0) >= l_children_commitment THEN
      update oe_payments
      set commitment_applied_amount = l_children_commitment
      where line_id = l_children_line_id
      and   header_id = l_header_id
      and   nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';

      oe_globals.g_commitment_balance
        := nvl(oe_globals.g_commitment_balance, 0) - l_children_commitment;
    ELSIF nvl(oe_globals.g_commitment_balance, 0) < l_children_commitment THEN
      update oe_payments
      set commitment_applied_amount = nvl(oe_globals.g_commitment_balance, 0)
      where line_id = l_children_line_id
      and   header_id =l_header_id
      and   nvl(payment_type_code, 'COMMITMENT') = 'COMMITMENT';

      oe_globals.g_commitment_balance := 0;
    END IF;

  END LOOP;
  CLOSE l_split_lines_cur;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting UPDATE_COMMITMENT. ', 1 ) ;
  END IF;

END update_commitment;

FUNCTION Do_Commitment_Sequencing RETURN BOOLEAN IS

l_column1_exists		VARCHAR2(1) := 'N';
l_column2_exists		VARCHAR2(1) := 'N';
INVALID_COLUMN_NAME		EXCEPTION;
PRAGMA	EXCEPTION_INIT(INVALID_COLUMN_NAME, -904);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF G_Do_Commitment_Sequencing <> FND_API.G_MISS_NUM THEN
     IF G_Do_Commitment_Sequencing = 0 THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
  ELSE
    IF Nvl(Fnd_Profile.Value('OE_COMMITMENT_SEQUENCING'),'N') = 'N' THEN
       G_Do_Commitment_Sequencing := 0;
       RETURN FALSE;
    ELSE
      BEGIN

        EXECUTE IMMEDIATE
        'SELECT ALLOCATE_TAX_FREIGHT
         FROM   RA_CUST_TRX_TYPES_ALL
         WHERE  ROWNUM = 1';

        l_column1_exists := 'Y';

       EXCEPTION WHEN INVALID_COLUMN_NAME THEN
         l_column1_exists := 'N';
       END;

       IF l_column1_exists = 'N' THEN
         G_Do_Commitment_Sequencing := 0;
         RETURN FALSE;
       ELSE
         BEGIN

         EXECUTE IMMEDIATE
         'SELECT PROMISED_COMMITMENT_AMOUNT
          FROM   RA_INTERFACE_LINES_ALL
          WHERE  ROWNUM = 1';

         l_column2_exists := 'Y';


         EXCEPTION WHEN INVALID_COLUMN_NAME THEN
           l_column2_exists := 'N';
         END;

         IF l_column2_exists = 'N' THEN
           G_Do_Commitment_Sequencing := 0;
           RETURN FALSE;
         ELSE
           G_Do_Commitment_Sequencing := 1;
           RETURN TRUE;
         END IF; -- end of column2 exists check

       END IF; -- end of column1 exists chck
    END IF;  -- end of profile option checking.

  END IF;  -- end of G_Do_Commitment_Sequencing is FND_API.G_MISS_NUM.

  EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                  ,'OE_COMMITMENT_PVT.DO_COMMITMENT_SEQUENCING'
               );
        END IF;

END Do_Commitment_Sequencing;

procedure update_commitment_applied(
  p_line_id             IN NUMBER
, p_amount              IN NUMBER
, p_header_id           IN NUMBER
, p_commitment_id       IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

) IS

l_commitment_applied_amount	NUMBER := 0;
l_commitment_bal		NUMBER;
l_class				VARCHAR2(30);
l_so_source_code		VARCHAR2(30);
l_oe_installed_flag		VARCHAR2(30);
l_amount_to_apply		NUMBER;
--bug 3560198
l_new_commitment_bal            NUMBER;
l_commitment                    VARCHAR2(20);
l_currency_code         varchar2(30) := 'USD';
l_precision             NUMBER;
l_ext_precision         NUMBER;
l_min_acct_unit         NUMBER;
--bug 3560198

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('OEXVCMTB: Entering UPDATE_COMMITMENT_APPLIED FOR LINE_ID '||P_LINE_ID, 1 );
     oe_debug_pub.add('OEXVCMTB: p_amount is: '||p_amount, 3 );
     oe_debug_pub.add('OEXVCMTB: p_header_id is: '||p_header_id, 3 );
     oe_debug_pub.add('OEXVCMTB: p_commitment_id is: '||p_commitment_id, 3 );
  END IF;

  -- get the commitment balance
  l_class := NULL;
  l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
  l_oe_installed_flag := 'I';

  l_commitment_bal := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
			 p_commitment_id
                	,l_class
                	,l_so_source_code
                	,l_oe_installed_flag );

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('OEXVCMTB: commitment balance is '||l_commitment_bal, 1 );
  END IF;

  BEGIN
  SELECT nvl(commitment_applied_amount,0)
  INTO   l_commitment_applied_amount
  FROM   oe_payments
  WHERE  header_id = p_header_id
  AND    line_id = p_line_id
  AND    payment_trx_id = p_commitment_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_commitment_applied_amount := 0;
  END;

  l_commitment_bal := l_commitment_bal + l_commitment_applied_amount;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('OEXVCMTB: available commitment balance is '||l_commitment_bal, 1 );
  END IF;

  IF p_amount <= l_commitment_bal THEN
    l_amount_to_apply := p_amount;
  ELSE
    l_amount_to_apply := l_commitment_bal;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXVCMTB: no sufficient balance '||l_amount_to_apply, 1 );
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXVCMTB: amount to apply is '||l_amount_to_apply, 1 );
  END IF;

  --bug 3560198
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('To display the commitment balance');
  END IF;
  l_new_commitment_bal := l_commitment_bal - l_amount_to_apply;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('New commitment balance is : '||l_new_commitment_bal);
  END IF;

  -- build currency format.
  IF g_fmt_mask IS NULL THEN
    BEGIN
      SELECT nvl(transactional_curr_code,'USD')
      INTO   l_currency_code from oe_order_headers
      WHERE  header_id=p_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_currency_code := 'USD';
    END ;

    FND_CURRENCY.Get_Info(l_currency_code,  -- IN variable
                l_precision,
                l_ext_precision,
                l_min_acct_unit);

    FND_CURRENCY.Build_Format_Mask(G_Fmt_mask, 20, l_precision,
                                       l_min_acct_unit, TRUE
                                      );
  END IF;

  FND_MESSAGE.Set_Name('ONT','OE_COM_BALANCE');
  FND_MESSAGE.Set_Token('COMMITMENT',l_commitment);
  FND_Message.Set_Token('BALANCE',to_char(l_new_commitment_bal, g_fmt_mask));
  OE_MSG_PUB.ADD;
  --bug 3560198


  UPDATE oe_payments
  SET    commitment_applied_amount = l_amount_to_apply
  WHERE  header_id = p_header_id
  AND    line_id   = p_line_id
  AND    payment_trx_id = p_commitment_id;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('OEXVCMTB: Exiting UPDATE_COMMITMENT_APPLIED. ', 1 );
  END IF;

END update_commitment_applied;

END oe_commitment_pvt;


/
