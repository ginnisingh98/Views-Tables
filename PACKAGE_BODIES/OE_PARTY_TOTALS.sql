--------------------------------------------------------
--  DDL for Package Body OE_PARTY_TOTALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PARTY_TOTALS" AS
/* $Header: OEXBTOTB.pls 120.1 2005/06/02 23:23:23 appldev  $ */

-- Forward declaration of procedure

PROCEDURE Update_HZ_Parties(p_party_id         IN  NUMBER
                          , p_party_type       IN  VARCHAR2
                          , p_last_update_date IN  DATE
                          , p_party_total      IN  NUMBER
                          , p_order_count      IN  NUMBER
                          , p_last_order_date  IN  DATE
                          , x_return_status    OUT NOCOPY VARCHAR2
                          );


--  Start of Comments
--  API name    Update_Party_Totals
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Update_Party_Totals(err_buff OUT NOCOPY VARCHAR2,
   retcode out NOCOPY NUMBER)
IS
    a_date    DATE;
    CURSOR C_PARTIES IS
    SELECT DISTINCT a.party_id,
		 a.party_type,
		 a.last_update_date
    FROM   hz_cust_accounts b,
		 hz_parties a
    WHERE  b.party_id = a.party_id;

    CURSOR C_ORDER_HEADER(p_party_id  NUMBER) IS
    SELECT a.header_id,
           a.org_id,
		 a.order_number,
           a.TRANSACTIONAL_CURR_CODE,
           a.CONVERSION_RATE,
           a.CONVERSION_TYPE_CODE,
           a.sold_to_org_id,
           a.CONVERSION_RATE_DATE,
           a.ORDERED_DATE,
           a.ORDER_CATEGORY_CODE
    FROM   hz_cust_accounts b,
           oe_order_headers_all a
    WHERE  b.party_id = p_party_id
    AND    b.cust_account_id = a.sold_to_org_id
    AND    a.booked_flag = 'Y'
    AND    a.cancelled_flag = 'N';

    CURSOR C_LINE_TOTALS(p_header_id NUMBER) IS
    SELECT SUM(DECODE(l.line_category_code,'RETURN',-1,1)*
			l.unit_selling_price*l.ordered_quantity)
    FROM   oe_order_lines_all l
    WHERE  l.header_id = p_header_id
    AND    l.cancelled_flag <> 'Y'
    AND    l.charge_periodicity_code IS NULL; -- Added for Recurring Charges

    CURSOR C_ALL_CHARGES(p_header_id  NUMBER) IS
    SELECT SUM( DECODE(p.LINE_ID, NULL,
        DECODE(p.CREDIT_OR_CHARGE_FLAG,'C',(-1) * p.OPERAND,p.OPERAND),
        DECODE(p.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               (-1) * (P.OPERAND),
                               (-1) * (L.ORDERED_QUANTITY*P.ADJUSTED_AMOUNT)),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               P.OPERAND,
                               (L.ORDERED_QUANTITY*P.ADJUSTED_AMOUNT))
               )))
    FROM   oe_price_adjustments p,
           oe_order_lines_all l
    WHERE  p.header_id = p_header_id
    AND    p.list_line_type_code = 'FREIGHT_CHARGE'
    AND    p.applied_flag = 'Y'
    AND    p.line_id = l.line_id(+)
    AND    DECODE(p.line_id,NULL,'P',l.cancelled_flag)=
           DECODE(p.line_id,NULL,'P','N')
    AND    l.charge_periodicity_code IS NULL; -- Added for Recurring Charges

    l_cust_currency_code    VARCHAR2(15);
    l_sob_currency_code     VARCHAR2(15);
    l_return_status         VARCHAR2(1);
    l_conversion_type       VARCHAR2(30);
    l_last_order_date       DATE := NULL;
    l_conversion_rate       NUMBER;
    l_party_id              NUMBER;
    l_order_count           NUMBER;
    l_party_total           NUMBER;
    l_converted_total       NUMBER;
    l_converted_total_new   NUMBER;
    l_line_total            NUMBER;
    l_charge_total          NUMBER;
    l_commit_ctr            NUMBER;
    v_errcode      NUMBER := 0;
    v_errmsg       VARCHAR2(500);

    ERROR_IN_CURRENCY_CONVERSION    EXCEPTION;

BEGIN

	l_commit_ctr := 0;

     -- Open the HZ_PARTY cursor for update;
	l_cust_currency_code := fnd_profile.value('OM_CUST_TOTAL_CURRENCY');

	IF l_cust_currency_code IS NULL THEN
	    oe_debug_pub.ADD('Profile OM: Party Total Currency is not set', 2);
	    RAISE FND_API.G_EXC_ERROR;
     END IF;
	oe_debug_pub.ADD('The Party Total Currency is '||l_cust_currency_code, 2);
	FOR C1 IN C_PARTIES LOOP
	BEGIN
	    -- Open the Order Header Cursor
         l_party_total := 0;
         l_order_count := 0;
         l_last_order_date := NULL;

	    FOR C2 IN C_ORDER_HEADER(p_party_id => C1.party_id) LOOP
	    BEGIN


             -- Get Order Level Totals = LINE Total

             OPEN C_LINE_TOTALS(C2.header_id);
             FETCH C_LINE_TOTALS INTO l_line_total;
             CLOSE C_LINE_TOTALS;

             -- Get Total Charges (Freight and Special Charges)

             OPEN C_ALL_CHARGES(C2.header_id);
             FETCH C_ALL_CHARGES INTO l_charge_total;
             CLOSE C_ALL_CHARGES;

             -- Get the Set Of Books currency
             l_sob_currency_code := OE_Upgrade_Misc.GET_SOB_CURRENCY(c2.org_id);

		   IF l_sob_currency_code IS NULL THEN
	            oe_debug_pub.ADD('Set Of Books currency does not exist for order '||to_char(c2.order_number), 2);
			  RAISE FND_API.G_EXC_ERROR;
             END IF;

             l_converted_total := NVL(l_line_total,0) +
                                 NVL(l_charge_total,0);

             IF C2.TRANSACTIONAL_CURR_CODE <> l_cust_currency_code
             AND l_converted_total <> 0 THEN

                 -- Convert the Currency:
                 -- If the Order Currency is different than SOB currency then
                 -- convert the order currency to SOB currency.

                 IF C2.TRANSACTIONAL_CURR_CODE <> l_sob_currency_code THEN
                     OE_UPGRADE_MISC.CONVERT_CURRENCY(
                        l_converted_total,
                        C2.TRANSACTIONAL_CURR_CODE,
                        l_sob_currency_code,
                        C2.conversion_rate_date,
                        C2.conversion_rate,
                        C2.conversion_type_code,
                        l_return_status,
                        l_converted_total_new
                        );
                      IF l_return_status <> 'S' THEN
	                     oe_debug_pub.ADD('Error in currency conversion from Order to SOB currency for order '||to_char(c2.order_number), 2);
                          RAISE ERROR_IN_CURRENCY_CONVERSION;
                      END IF;

                      if l_converted_total_new is not null then
                        l_converted_total := l_converted_total_new;
                      end if;

		 END IF;


                 -- If the SOB currency is different than the Customer Total
                 -- currency then convert the SOB currency to customer total
                 -- currency.
                 IF l_cust_currency_code <> l_sob_currency_code THEN

                     IF C2.conversion_type_code = 'User' THEN
                        l_conversion_type := 'Spot';
		        l_conversion_rate := NULL;
                     ELSE
                        l_conversion_type := C2.conversion_type_code;
		        l_conversion_rate := C2.conversion_rate;
                     END IF;

                     OE_UPGRADE_MISC.CONVERT_CURRENCY(
                        l_converted_total_new,
                        l_sob_currency_code,
                        l_cust_currency_code,
                        C2.conversion_rate_date,
                        l_conversion_rate,
                        l_conversion_type,
                        l_return_status,
                        l_converted_total_new
                        );
                      IF l_return_status <> 'S' THEN
	                  oe_debug_pub.ADD('Error in currency conversion from SOB to Party Total currency for order '||to_char(c2.order_number), 2);
                          RAISE ERROR_IN_CURRENCY_CONVERSION;
                      END IF;
                      if l_converted_total_new is not null then
                        l_converted_total := l_converted_total_new;
                      end if;
		 END IF;

	     END IF;

             l_party_total := l_party_total + l_converted_total;

             IF C2.ORDER_CATEGORY_CODE <> 'RETURN' THEN

                 -- Add the Order Total Counter
                 l_order_count := l_order_count + 1;

                 -- Get the Last Order Date
                 IF l_last_order_date IS NULL THEN
                     l_last_order_date := C2.ORDERED_DATE;
                 END IF;

                 IF C2.ORDERED_DATE > l_last_order_date THEN
                     l_last_order_date := C2.ORDERED_DATE;
                 END IF;

             END IF;
         EXCEPTION
		   WHEN OTHERS THEN
                 v_errcode := SQLCODE;
                 v_errmsg := SQLERRM;
	            oe_debug_pub.ADD('Error in processing Order '||to_char(c2.order_number) || ' SQL error is '|| to_char(v_errcode) || v_errmsg, 2);
         END;
	    END LOOP; -- End Loop For C_ORDER_HEADER

         IF NOT (l_party_total = 0 AND l_order_count = 0 AND
		  l_last_order_date IS NULL)
	    THEN

             IF l_order_count = 0 THEN
		       l_order_count := NULL;
             END IF;

	        oe_debug_pub.ADD('The Party Total was '||to_char(l_party_total), 2);
             Update_HZ_Parties(p_party_id => C1.party_id
				   ,   p_party_type   => C1.party_type
				   ,   p_last_update_date => C1.last_update_date
				   ,   p_party_total  => l_party_total
				   ,   p_order_count  => l_order_count
				   ,   p_last_order_date => l_last_order_date
				   ,   x_return_status => l_return_status
				   );
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	            oe_debug_pub.ADD('Error in updating the Party record for party '||to_char(c1.party_id), 2);
             END IF;
	    END IF;

    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      oe_debug_pub.ADD('No Order for PARTY '||to_char(C1.party_id), 2);

        WHEN OTHERS THEN
            v_errcode := SQLCODE;
            v_errmsg := SQLERRM;
	       oe_debug_pub.ADD('Error in processing Party '||to_char(c1.party_id) || ' SQL error is '|| to_char(v_errcode) || v_errmsg, 2);
    END;
    l_commit_ctr := l_commit_ctr + 1;
    IF l_commit_ctr > 500 THEN
         commit;
         l_commit_ctr := 0;
    END IF;

    END LOOP; -- End Loop For C_PARTIES
 -- set return status
    err_buff := '';
    retcode  := 0;
    commit;

EXCEPTION
    WHEN OTHERS THEN
        v_errcode := SQLCODE;
        v_errmsg := SQLERRM;
	   oe_debug_pub.ADD('Error in processing Parties '|| ' SQL error is '|| to_char(v_errcode) || v_errmsg, 2);
       retcode  := 2;
END Update_Party_Totals;

PROCEDURE Update_HZ_Parties(p_party_id         IN  NUMBER
                          , p_party_type       IN  VARCHAR2
                          , p_last_update_date IN  DATE
			 , p_party_total      IN  NUMBER
			 , p_order_count      IN  NUMBER
			 , p_last_order_date  IN  DATE
			 , x_return_status    OUT NOCOPY VARCHAR2
					 )
IS
v_errcode      NUMBER := 0;
v_errmsg       VARCHAR2(500);
l_profile_id   NUMBER;
l_msg_count    NUMBER;
l_msg_data     VARCHAR2(2000);
l_return_status VARCHAR2(1);
l_rel_date      DATE := sysdate;
l_date          DATE := p_last_update_date;

BEGIN

    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    IF p_party_type = 'PERSON' OR
       p_party_type = 'GROUP' OR
       p_party_type = 'PARTY_RELATIONSHIP' OR
       p_party_type = 'ORGANIZATION' THEN

      UPDATE hz_parties
         SET total_num_of_orders = p_order_count,
             total_ordered_amount = p_party_total,
             last_ordered_date    = p_last_order_date
       WHERE party_id = p_party_id;

    ELSE
	   oe_debug_pub.ADD('Invalid Party type for PARTY '||to_char(p_party_id), 2);
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        If l_msg_count > 0 THEN

		  FOR k in 1 .. l_msg_count LOOP
                l_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                               p_encoded => 'F');
                oe_debug_pub.add(substr(l_msg_data,1,255),2);
            END LOOP;

	   END IF;
    ELSE
      oe_debug_pub.ADD('Success in  Processing PARTY '||to_char(p_party_id), 2);
    END IF;
    x_return_status := l_return_status;
EXCEPTION
    WHEN OTHERS THEN
        v_errcode := SQLCODE;
        v_errmsg := SQLERRM;
	   oe_debug_pub.ADD('Error in updating the Party '||to_char(p_party_id) || ' SQL error is '|| to_char(v_errcode) || v_errmsg, 2);
        x_return_status := FND_API.G_RET_STS_ERROR;

END Update_HZ_Parties;

END OE_Party_TOTALS;

/
