--------------------------------------------------------
--  DDL for Package Body QP_CROSS_ORDER_VOLUME_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CROSS_ORDER_VOLUME_LOAD" AS
/* $Header: QPXCOVLB.pls 120.7 2006/10/03 12:13:33 nirmkuma ship $ */


   G_LOAD_EFFECTIVE_DATE 	DATE;
   G_ORG_ID				NUMBER;


/*================================================================================
  function get_uom_code
  description
     Retrieves primary unit of measure for an item.
  =============================================================================== */

  FUNCTION get_uom_code(pitem_id NUMBER,porg_id NUMBER) RETURN VARCHAR2 IS

    CURSOR Cur_getuom(citem_id NUMBER,corg_id NUMBER) IS
      SELECT primary_uom_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = citem_id
      AND    organization_id = corg_id;

      l_uom_code VARCHAR2(3);

  BEGIN
    OPEN Cur_getuom(pitem_id,porg_id);
    FETCH Cur_getuom INTO l_uom_code;
    CLOSE Cur_getuom;
    RETURN(l_uom_code);

    EXCEPTION
    WHEN OTHERS THEN RAISE;

  END get_uom_code;

  FUNCTION convert_to_base_curr(p_trans_amount NUMBER, p_from_currency VARCHAR2,
						  p_to_currency VARCHAR2, p_conversion_date DATE,
						  p_conversion_rate NUMBER, p_conversion_type VARCHAR2)
						  RETURN NUMBER IS

     l_conversion_type          VARCHAR2(30);
	l_conversion_date		  DATE;
	l_rate_exists              VARCHAR2(1);
	l_converted_amount         NUMBER;
	l_max_roll_days            NUMBER;
	l_denominator              NUMBER;
	l_numerator                NUMBER;
	l_rate                     NUMBER;
	No_User_Defined_Rate       EXCEPTION;
	x_trans_amount             NUMBER;
	x_return_status		  VARCHAR2(1);
       NO_RATE                    EXCEPTION;
       INVALID_CURRENCY           EXCEPTION;

 BEGIN
	x_trans_amount := p_trans_amount;
     l_max_roll_days := 300;
     l_conversion_type := NVL(p_conversion_type, 'Corporate');
	l_conversion_date := NVL(p_conversion_date,g_load_effective_date);

 	IF x_trans_amount = 0
	THEN
	  return(0);

     ELSIF (GL_CURRENCY_API.Is_Fixed_Rate( p_from_currency,
                              p_to_currency, p_conversion_date) = 'Y')
        THEN
            x_trans_amount := GL_CURRENCY_API.convert_amount(
                                     p_from_currency,
                                     p_to_currency,
                                     l_conversion_date,
                                     l_conversion_type,
                                     p_trans_amount
                                     );
            return(x_trans_amount);
        ELSIF (l_conversion_type = 'User')
        THEN
            IF (p_conversion_rate IS NOT NULL) THEN
                x_trans_amount := p_trans_amount * p_conversion_rate;
		      return(x_trans_amount);
            ELSE
                RAISE No_User_Defined_Rate;
            END IF;
        ELSE
            l_rate_exists := GL_CURRENCY_API.Rate_Exists(
                                 x_from_currency   => p_from_currency,
                                 x_to_currency     => p_to_currency,
                                 x_conversion_date => l_conversion_date,
                                 x_conversion_type => l_conversion_type
                                 );
            IF (l_rate_exists = 'Y') THEN
                x_trans_amount := GL_CURRENCY_API.convert_amount(
                                           p_from_currency,
                                           p_to_currency,
                                           l_conversion_date,
                                           l_conversion_type,
                                           p_trans_amount
                                           );
                return(x_trans_amount);
            ELSE
               BEGIN
                 GL_CURRENCY_API.convert_closest_amount(
                      x_from_currency   => p_from_currency,
                      x_to_currency     => p_to_currency,
                      x_conversion_date => l_conversion_date,
                      x_conversion_type => l_conversion_type,
                      x_user_rate       => p_conversion_rate,
                      x_amount          => p_trans_amount,
                      x_max_roll_days   => l_max_roll_days,
                      x_converted_amount=> l_converted_amount,
                      x_denominator     => l_denominator,
                      x_numerator       => l_numerator,
                      x_rate            => l_rate);
               EXCEPTION
                 WHEN OTHERS THEN
                 if (l_numerator >0) AND (l_denominator >0)
                    THEN
                       return(0);
                 ELSIF (l_numerator =-2) OR (l_denominator =-2)
                    THEN
                       RAISE INVALID_CURRENCY;
                 ELSE
                       RAISE NO_RATE;
                  END IF;
               END;
                x_trans_amount := l_converted_amount;
                return(x_trans_amount);
            END IF;

        END IF;

 EXCEPTION
     WHEN No_User_Defined_Rate THEN
	    return(0);
    WHEN NO_RATE THEN
    fnd_file.put_line(FND_FILE.LOG,'No rate is defined');
    RAISE;
    WHEN INVALID_CURRENCY THEN
    fnd_file.put_line(FND_FILE.LOG,'Invalid currency');
     RAISE;
    WHEN OTHERS THEN
	    RAISE;

 END convert_to_base_curr;

  /*================================================================================
   function get_converted_qty
   description
      Converts order unit of measure quantity to primary unit of measure qty.
   ================================================================================= */

  FUNCTION get_converted_qty(pitem_id NUMBER,porg_id NUMBER,pordr_qty NUMBER,porduom VARCHAR2) RETURN NUMBER IS
    l_uom_code  VARCHAR2(3);
    l_item_rate NUMBER;
    l_converted_qty NUMBER;
    l_error_message VARCHAR2(200);

  BEGIN
    l_uom_code := get_uom_code(pitem_id,porg_id);
    IF l_uom_code <> porduom
    THEN
      l_converted_qty := inv_convert.inv_um_convert(pitem_id,NULL,pordr_qty,porduom,l_uom_code,NULL,NULL);

	 -- Check conversion found
	 IF l_converted_qty = -99999
	 THEN
	   -- Log message
	   FND_MESSAGE.SET_NAME('QP','QP_XORD_UOM_CONVERSION');
	   FND_MESSAGE.SET_TOKEN('ITEM',pitem_id);
	   FND_MESSAGE.SET_TOKEN('ORG',porg_id);
	   FND_MESSAGE.SET_TOKEN('FROM_UOM',porduom);
	   FND_MESSAGE.SET_TOKEN('TO_UOM',l_uom_code);
	   l_error_message := FND_MESSAGE.GET;
	   fnd_file.put_line(FND_FILE.LOG,l_error_message);

	   RETURN(0);
	 ELSE
	   RETURN(l_converted_qty);
      END IF;

    ELSE
	 RETURN(pordr_qty);
    END IF;
  END get_converted_qty;

/*================================================================================
   function get_value
  description
   Evaluates a condition and if it is true then return first value else second value.
  =================================================================================  */

  FUNCTION get_value(req_date DATE,perd_val NUMBER,p_inval NUMBER,p_invaltwo NUMBER) RETURN NUMBER IS
  BEGIN
IF  (trunc(req_date) <= (trunc(g_load_effective_date))) THEN
 IF (trunc(g_load_effective_date) - trunc(req_date) <= perd_val) THEN
      RETURN(p_inval);
    ELSE
      RETURN(p_invaltwo);
  END IF;
    ELSE
    RETURN(p_invaltwo);
END IF;
  END get_value;

/*================================================================================
   function multi_org_install
  description
   returns true if install is multi-org, otherwise returns false.
  =================================================================================  */

  FUNCTION multi_org_install RETURN BOOLEAN IS
    l_is_multiorg_enabled VARCHAR2(1) := 'N';
  BEGIN
    /*commented for moac
    IF SUBSTRB(USERENV('CLIENT_INFO'),1,1) is null THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    */
    --added for MOAC
    l_is_multiorg_enabled := MO_GLOBAL.is_multi_org_enabled;
    IF l_is_multiorg_enabled = 'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END multi_org_install;

 /*================================================================================
   function create_crossordvol_brk
    description
   Calculates customer volumes for an item.
 ================================================================================== */



  PROCEDURE create_crossordvol_brk
  (err_buff out NOCOPY /* file.sql.39 change */ VARCHAR2,
   retcode out NOCOPY /* file.sql.39 change */ NUMBER,
   x_org_id in NUMBER,
   x_load_effective_date in VARCHAR2) IS

    l_ordr_vol_perd1  NUMBER DEFAULT  0;
    l_ordr_vol_perd2  NUMBER DEFAULT  0;
    l_ordr_vol_perd3  NUMBER DEFAULT  0;
    l_converted_qty1  NUMBER  DEFAULT 0;
    l_converted_qty2  NUMBER  DEFAULT 0;
    l_converted_qty3  NUMBER  DEFAULT 0;
    l_period1_amount  NUMBER  DEFAULT 0;
    l_period2_amount  NUMBER  DEFAULT 0;
    l_period3_amount  NUMBER  DEFAULT 0;
    l_sob_id          NUMBER  DEFAULT 0;
    l_sob_currency    VARCHAR2(15);
    l_period1_item_qty_attr VARCHAR2(30);
    l_period2_item_qty_attr VARCHAR2(30);
    l_period3_item_qty_attr VARCHAR2(30);
    l_period1_item_amt_attr VARCHAR2(30);
    l_period2_item_amt_attr VARCHAR2(30);
    l_period3_item_amt_attr VARCHAR2(30);
    l_multi_org_install BOOLEAN DEFAULT TRUE;

    -- Cursor to get set of books id.

    CURSOR Cur_get_sob_currency(psob_id NUMBER) IS
     SELECT gsob.currency_code
     FROM  gl_sets_of_books gsob
	WHERE gsob.set_of_books_id = psob_id;

	-- Cursor to get all items which have cross order volume pricing attributes defined

    CURSOR Cur_get_items IS
  	  SELECT distinct to_number(qpa.product_attr_value) c_inventory_item_id
	  FROM   qp_list_headers qlh,
              qp_list_lines qpl,
              qp_pricing_attributes qpa
       WHERE qlh.list_header_id = qpl.list_header_id
       AND qpl.list_line_id = qpa.list_line_id
	  AND qlh.active_flag = 'Y'
       AND qpa.product_attribute_context  = 'ITEM'
       AND qpa.product_attribute = qp_util.get_attribute_name('QP',
				 'QP_ATTR_DEFNS_PRICING','ITEM','INVENTORY_ITEM_ID')
       AND qpa.pricing_attribute_context  = 'VOLUME'
       AND (       qpa.pricing_attribute = l_period1_item_qty_attr
               OR  qpa.pricing_attribute = l_period2_item_qty_attr
	          OR  qpa.pricing_attribute = l_period3_item_qty_attr
	          OR  qpa.pricing_attribute = l_period1_item_amt_attr
	          OR  qpa.pricing_attribute = l_period2_item_amt_attr
	          OR  qpa.pricing_attribute = l_period3_item_amt_attr);

  BEGIN

    l_multi_org_install := multi_org_install;

    -- Set Variables
 G_load_effective_date := NVL(fnd_date.canonical_to_date(x_load_effective_date),sysdate);

    IF l_multi_org_install
    THEN

      G_org_id := x_org_id;

    ELSE

      -- Get Master Organization

      G_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID',g_org_id);

      -- Get Set of Books currency

     --added for moac to call Oe_sys_params only if org_id is not null
     IF G_org_id IS NOT NULL THEN
      l_sob_id := oe_sys_parameters.value('SET_OF_BOOKS_ID',g_org_id);
     ELSE
      l_sob_id := null;
     END IF;--if g_org_id

       OPEN Cur_get_sob_currency(l_sob_id);
	  FETCH Cur_get_sob_currency INTO l_sob_currency;
	  CLOSE Cur_get_sob_currency;

    END IF;

    -- Get profile values
    l_ordr_vol_perd1 := to_number(FND_PROFILE.VALUE('QP_CROSS_ORDER_VOLUME_PERIOD1'));
    l_ordr_vol_perd2 := to_number(FND_PROFILE.VALUE('QP_CROSS_ORDER_VOLUME_PERIOD2'));
    l_ordr_vol_perd3 := to_number(FND_PROFILE.VALUE('QP_CROSS_ORDER_VOLUME_PERIOD3'));

    -- Get Attribute columns for Cross Order Pricing Attributes
    l_period1_item_qty_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_PRICING','VOLUME','PERIOD1_ITEM_QUANTITY');
    l_period2_item_qty_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_PRICING','VOLUME','PERIOD2_ITEM_QUANTITY');
    l_period3_item_qty_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_PRICING','VOLUME','PERIOD3_ITEM_QUANTITY');
    l_period1_item_amt_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_PRICING','VOLUME','PERIOD1_ITEM_AMOUNT');
    l_period2_item_amt_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_PRICING','VOLUME','PERIOD2_ITEM_AMOUNT');
    l_period3_item_amt_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_PRICING','VOLUME','PERIOD3_ITEM_AMOUNT');


      IF (g_org_id IS NULL) OR (NOT l_multi_org_install)
	 THEN

        DELETE FROM OE_ITEM_CUST_VOLS_ALL;

      ELSE

        DELETE FROM OE_ITEM_CUST_VOLS_ALL
	   WHERE ORG_ID = g_org_id;

      END IF;

/* Fix for Bug# 1798953. Instead of using lines.org, used  oe_sys_parameters.value('MASTER_ORGANIZATION_ID',lines.org_id) to use the master organization in get_uom_code and get_converted_qty functions */

/* Fix for Bug# 3558790. Instead of using lines.pricing_quantity for calculating item amounts, used lines.ordered_quantity */
      FOR i IN Cur_get_items
      LOOP

       IF l_multi_org_install THEN

          INSERT INTO OE_ITEM_CUST_VOLS_ALL
	       (org_id,
            inventory_item_id,
            sold_to_org_id,
            primary_uom_code,
            period1_ordered_quantity,
            period2_ordered_quantity,
            period3_ordered_quantity,
            period1_total_amount,
            period2_total_amount,
            period3_total_amount,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id)
	    (SELECT lines.org_id,
                lines.inventory_item_id,
                lines.sold_to_org_id,
                get_uom_code(lines.inventory_item_id,oe_sys_parameters.value('MASTER_ORGANIZATION_ID',lines.org_id)),
                sum(get_value(hdrs.ordered_date,l_ordr_vol_perd1,
		       get_converted_qty(lines.inventory_item_id,oe_sys_parameters.value('MASTER_ORGANIZATION_ID',lines.org_id),
		       lines.ordered_quantity,lines.order_quantity_uom),0)),
                sum(get_value(hdrs.ordered_date,l_ordr_vol_perd2,
			  get_converted_qty(lines.inventory_item_id,oe_sys_parameters.value('MASTER_ORGANIZATION_ID',lines.org_id),
			  lines.ordered_quantity,lines.order_quantity_uom),0)),
                sum(get_value(hdrs.ordered_date,l_ordr_vol_perd3,
			  get_converted_qty(lines.inventory_item_id,oe_sys_parameters.value('MASTER_ORGANIZATION_ID',lines.org_id),
			  lines.ordered_quantity,lines.order_quantity_uom),0)),
                sum(decode(hdrs.transactional_curr_code,gsob.currency_code,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd1,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd1,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,gsob.currency_code,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,gsob.currency_code,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd2,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd2,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,gsob.currency_code,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,gsob.currency_code,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd3,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd3,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,gsob.currency_code,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sysdate,
                p_created_by,
                sysdate,
                p_user_id,
                p_login_id,
                P_program_appl_id,
                P_conc_program_id,
                sysdate,
                p_request_id
          FROM  oe_order_headers_all hdrs,
			 oe_order_lines_all lines,
                hr_operating_units hou,
			 gl_sets_of_books gsob
          WHERE hdrs.header_id = lines.header_id
		AND lines.org_id = hou.organization_id
		AND hou.set_of_books_id = gsob.set_of_books_id
		AND lines.inventory_item_id = i.c_inventory_item_id
          AND lines.line_category_code <> 'RETURN'
          AND lines.org_id = nvl(g_org_id,lines.org_id)
          AND lines.sold_to_org_id is not null
		AND lines.booked_flag = 'Y'
	     AND nvl(lines.cancelled_flag,'N') = 'N'
          AND lines.charge_periodicity_code is null  -- added for recurring charges Bug 4465168
          GROUP BY lines.inventory_item_id,lines.org_id,0,lines.sold_to_org_id);

       ELSE /* not multiple sets of books */

          INSERT INTO OE_ITEM_CUST_VOLS_ALL
	       (org_id,
            inventory_item_id,
            sold_to_org_id,
            primary_uom_code,
            period1_ordered_quantity,
            period2_ordered_quantity,
            period3_ordered_quantity,
            period1_total_amount,
            period2_total_amount,
            period3_total_amount,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id)
	    (SELECT lines.org_id,
                lines.inventory_item_id,
                lines.sold_to_org_id,
                get_uom_code(lines.inventory_item_id,g_org_id),
                sum(get_value(hdrs.ordered_date,l_ordr_vol_perd1,
		       get_converted_qty(lines.inventory_item_id,g_org_id,
		       lines.ordered_quantity,lines.order_quantity_uom),0)),
                sum(get_value(hdrs.ordered_date,l_ordr_vol_perd2,
			  get_converted_qty(lines.inventory_item_id,g_org_id,
			  lines.ordered_quantity,lines.order_quantity_uom),0)),
                sum(get_value(hdrs.ordered_date,l_ordr_vol_perd3,
			  get_converted_qty(lines.inventory_item_id,g_org_id,
			  lines.ordered_quantity,lines.order_quantity_uom),0)),
                sum(decode(hdrs.transactional_curr_code,l_sob_currency,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd1,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd1,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,l_sob_currency,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,l_sob_currency,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd2,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd2,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,l_sob_currency,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,l_sob_currency,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd3,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd3,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,l_sob_currency,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sysdate,
                p_created_by,
                sysdate,
                p_user_id,
                p_login_id,
                P_program_appl_id,
                P_conc_program_id,
                sysdate,
                p_request_id
          FROM  oe_order_headers_all hdrs,
			 oe_order_lines_all lines
          WHERE hdrs.header_id = lines.header_id
		AND   lines.inventory_item_id = i.c_inventory_item_id
		AND   lines.line_category_code <> 'RETURN'
          AND   lines.sold_to_org_id is not null
		AND   lines.booked_flag = 'Y'
	     AND   nvl(lines.cancelled_flag,'N') = 'N'
             AND lines.charge_periodicity_code is null   -- added for recurring charges Bug 4465168
          GROUP BY lines.inventory_item_id,lines.org_id,0,lines.sold_to_org_id);

       END IF;

	 END LOOP;

-- This routine calculates customer total order amounts for the three periods.
   get_customer_total_amnts(l_ordr_vol_perd1,l_ordr_vol_perd2,l_ordr_vol_perd3,l_sob_currency);

    COMMIT;

    -- set return status
    err_buff := '';
    retcode  := 0;

    EXCEPTION
     WHEN OTHERS THEN
	  fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
       retcode := 2;

  END create_crossordvol_brk;

 /*================================================================================
  function get_customer_total_amnts
  description
   Calculates the total volume for a customer.
  ================================================================================= */


  PROCEDURE get_customer_total_amnts(x_cross_ordr_vol_perd1 	  NUMBER,
                                     x_cross_ordr_vol_perd2 	  NUMBER,
                                     x_cross_ordr_vol_perd3 	  NUMBER,
							  x_sob_currency			  VARCHAR2) IS


    l_period1_order_amt_attr VARCHAR2(30);
    l_period2_order_amt_attr VARCHAR2(30);
    l_period3_order_amt_attr VARCHAR2(30);
    l_cross_order_qualifiers VARCHAR2(1) DEFAULT 'N';
    l_ordr_vol_perd1 NUMBER := x_cross_ordr_vol_perd1;
    l_ordr_vol_perd2 NUMBER := x_cross_ordr_vol_perd2;
    l_ordr_vol_perd3 NUMBER := x_cross_ordr_vol_perd3;
    l_sob_currency VARCHAR2(15) := x_sob_currency;

    CURSOR Cur_cross_order_qualifiers IS
       SELECT 'Y'
       FROM  qp_list_headers qlh,
             qp_qualifiers qq
       WHERE qq.list_header_id = qlh.list_header_id
	  AND  qlh.active_flag = 'Y'
	  AND  qq.qualifier_context     = 'VOLUME'
       AND (     qualifier_attribute = l_period1_order_amt_attr
              OR qualifier_attribute = l_period2_order_amt_attr
              OR qualifier_attribute = l_period3_order_amt_attr);


  BEGIN

      IF (g_org_id IS NULL) OR (NOT multi_org_install)
	 THEN

        DELETE FROM OE_CUST_TOTAL_AMTS_ALL;

      ELSE


        DELETE FROM OE_CUST_TOTAL_AMTS_ALL
	   WHERE ORG_ID = g_org_id;

      END IF;

      -- Get Attribute columns for Cross Order Qualifier Attributes
    l_period1_order_amt_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_QUALIFIER','VOLUME','PERIOD1_ORDER_AMOUNT');
    l_period2_order_amt_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_QUALIFIER','VOLUME','PERIOD2_ORDER_AMOUNT');
    l_period3_order_amt_attr := qp_util.get_attribute_name ('QP',
			    'QP_ATTR_DEFNS_QUALIFIER','VOLUME','PERIOD3_ORDER_AMOUNT');

    -- Check to see if Cross Order Volume Qualifiers have been used on Active Lists

    OPEN Cur_cross_order_qualifiers;
    FETCH Cur_cross_order_qualifiers INTO l_cross_order_qualifiers;
    CLOSE Cur_cross_order_qualifiers;


    IF l_cross_order_qualifiers = 'Y'
    THEN

	 IF multi_org_install THEN

        INSERT INTO OE_CUST_TOTAL_AMTS_ALL
	   (org_id,
         sold_to_org_id,
         period1_total_amount,
         period2_total_amount,
         period3_total_amount,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id)
        (SELECT lines.org_id,
                lines.sold_to_org_id,
			sum(decode(hdrs.transactional_curr_code,gsob.currency_code,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd1,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd1,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,gsob.currency_code,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,gsob.currency_code,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd2,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd2,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,gsob.currency_code,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,gsob.currency_code,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd3,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd3,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,gsob.currency_code,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sysdate,
                p_user_id,
                sysdate,
                P_user_id,
                P_login_id,
                P_program_appl_id,
                P_conc_program_id,
                sysdate,
                P_request_id
         FROM  oe_order_headers_all hdrs,
	          oe_order_lines_all lines,
               hr_operating_units hou,
			gl_sets_of_books gsob
         WHERE hdrs.header_id = lines.header_id
	    AND   lines.org_id = hou.organization_id
	    AND   hou.set_of_books_id = gsob.set_of_books_id
         AND   lines.line_category_code <> 'RETURN'
         AND   lines.org_id = NVL(g_org_id,lines.org_id)
         AND   lines.sold_to_org_id is not null
         AND   lines.booked_flag = 'Y'
	    AND   nvl(lines.cancelled_flag,'N') = 'N'
         AND   lines.charge_periodicity_code is null   -- added for recurring charges Bug 4465168
         GROUP BY lines.org_id,lines.sold_to_org_id);

      ELSE

        INSERT INTO OE_CUST_TOTAL_AMTS_ALL
	   (org_id,
         sold_to_org_id,
         period1_total_amount,
         period2_total_amount,
         period3_total_amount,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id)
        (SELECT lines.org_id,
                lines.sold_to_org_id,
                sum(decode(hdrs.transactional_curr_code,l_sob_currency,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd1,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd1,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,l_sob_currency,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,l_sob_currency,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd2,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd2,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,l_sob_currency,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sum(decode(hdrs.transactional_curr_code,l_sob_currency,
			 get_value(hdrs.ordered_date,l_ordr_vol_perd3,
			 lines.ordered_quantity*lines.unit_list_price,0),
			 convert_to_base_curr(get_value(hdrs.ordered_date,
			  l_ordr_vol_perd3,lines.ordered_quantity*lines.unit_list_price,0),
			  hdrs.transactional_curr_code,l_sob_currency,hdrs.conversion_rate_date,
			  hdrs.conversion_rate,hdrs.conversion_type_code))),
                sysdate,
                p_user_id,
                sysdate,
                P_user_id,
                P_login_id,
                P_program_appl_id,
                P_conc_program_id,
                sysdate,
                P_request_id
         FROM  oe_order_headers_all hdrs,
			oe_order_lines_all lines
         WHERE hdrs.header_id = lines.header_id
	    AND   lines.line_category_code <> 'RETURN'
         AND   lines.sold_to_org_id is not null
         AND   lines.booked_flag = 'Y'
	    AND   nvl(lines.cancelled_flag,'N') = 'N'
         AND   lines.charge_periodicity_code is null     -- added for recurring charges Bug 4465168
         GROUP BY lines.org_id,lines.sold_to_org_id);

      END IF; /* Mulit org. Install */

    END IF; /* Cross Order Qualifiers */

    EXCEPTION
     WHEN OTHERS THEN
	  fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
       retcode := 2;

  END get_customer_total_amnts;
END QP_Cross_Order_Volume_Load;

/
