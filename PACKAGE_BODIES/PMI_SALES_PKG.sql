--------------------------------------------------------
--  DDL for Package Body PMI_SALES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_SALES_PKG" as
/* $Header: PMISAANB.pls 115.5 2003/02/19 04:47:42 srpuri ship $ */

/* Added New function SKARIMIS 12/28/1999 */

FUNCTION PMISA_GET_TOP_N(p_Sales_orgn          IN sy_orgn_mst.orgn_code%TYPE,
                         p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		             p_Prd_start_date      IN DATE,
                         p_Prd_end_date        IN DATE,
                         p_item_id		     IN ic_item_mst.item_id%TYPE DEFAULT NULL,
                         P_customer_id         IN op_ordr_hdr.billcust_id%TYPE DEFAULT NULL,
                         p_top_n               IN NUMBER
                        )
 RETURN NUMBER
 IS
 /* cursor to Fetch Top products with respect to margin */

 Cursor cur_item  (     p_Sales_orgn          IN sy_orgn_mst.orgn_code%TYPE,
                        p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		            p_Prd_start_date      IN DATE,
                        p_Prd_end_date        IN DATE
                  )
                 IS
                    SELECT  orderdetail.item_id,
                            SUM(DECODE(orderdetail.BASE_CURRENCY,orderdetail.BILLING_CURRENCY,
                            orderdetail.EXTENDED_PRICE,
                            Decode(orderdetail.mul_div_sign,0,orderdetail.EXTENDED_PRICE*orderdetail.EXCHANGE_RATE,
                            orderdetail.EXTENDED_PRICE/orderdetail.EXCHANGE_RATE)))-
                            SUM(gmicuom.I2UOM_CV(orderdetail.Item_Id,0,orderdetail.ORDER_UM1,
                            orderdetail.ORDER_QTY1,itemmst.Item_UM)*
                            pmi_common_pkg.PMICO_GET_COST(orderdetail.item_id,
                            orderdetail.From_whse,p_cost_mthd,orderdetail.Actual_Shipdate))-
                            SUM(pmi_sales_pkg.PMISA_GET_CHARGE(orderdetail.order_Id,orderdetail.line_Id,
                                orderdetail.extended_price,orderdetail.billing_currency,orderdetail.base_currency,
                                orderdetail.exchange_rate,orderdetail.mul_div_sign)) Margin
			  FROM
                           OP_ORDR_HDR orderhdr,
                           OP_ORDR_DTL orderdetail,
                           IC_ITEM_MST itemmst
                    WHERE  orderhdr.order_id  = orderdetail.order_id
                          AND orderdetail.item_id = itemmst.item_id
                          AND trunc(orderdetail.ACTUAL_SHIPDATE)
                              between p_prd_start_date and p_prd_end_date
                          AND orderhdr.ORGN_CODE=p_Sales_orgn
                    GROUP BY  orderhdr.orgn_code,orderdetail.item_id
                    ORDER BY Margin desc;
/* Cursor to get Top N customers with respect to Margin */
  Cursor cur_customer  (      p_Sales_orgn          IN sy_orgn_mst.orgn_code%TYPE,
                              p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		                  p_Prd_start_date      IN DATE,
                              p_Prd_end_date        IN DATE
                       )
                    IS
                     SELECT  orderhdr.billcust_id,
                             SUM(DECODE(orderdetail.BASE_CURRENCY,orderdetail.BILLING_CURRENCY,
                             orderdetail.EXTENDED_PRICE,
                             Decode(orderdetail.mul_div_sign,0,orderdetail.EXTENDED_PRICE*orderdetail.EXCHANGE_RATE,
                             orderdetail.EXTENDED_PRICE/orderdetail.EXCHANGE_RATE)))-
                             SUM(gmicuom.I2UOM_CV(orderdetail.Item_Id,0,orderdetail.ORDER_UM1,
                             orderdetail.ORDER_QTY1,itemmst.Item_UM)*
                             pmi_common_pkg.PMICO_GET_COST(orderdetail.item_id,
                             orderdetail.From_whse,p_cost_mthd,orderdetail.Actual_Shipdate))-
                             SUM(pmi_sales_pkg.PMISA_GET_CHARGE(orderdetail.order_Id,orderdetail.line_Id,
                             orderdetail.extended_price,orderdetail.billing_currency,orderdetail.base_currency,
                             orderdetail.exchange_rate,orderdetail.mul_div_sign))  Margin
	               FROM
                             OP_ORDR_HDR orderhdr,
                             OP_ORDR_DTL orderdetail,
                             IC_ITEM_MST itemmst
                      WHERE  orderhdr.order_id  = orderdetail.order_id
                          AND orderdetail.item_id = itemmst.item_id
                          AND trunc(orderdetail.ACTUAL_SHIPDATE)
                              between p_prd_start_date and p_prd_end_date
                          AND orderhdr.ORGN_CODE=p_Sales_orgn
                      GROUP BY orderhdr.orgn_code,orderhdr.billcust_id
                      ORDER BY Margin desc;
 l_count       NUMBER:=1;
 l_found       NUMBER:=0;
 l_item_id     NUMBER;
 l_customer_id NUMBER;
 l_margin      NUMBER;
 BEGIN
        /* Check Package varables if already top N is calculated for the given combination */

      /* If Item id is passed check Item Table */
      IF P_CUSTOMER_ID is NULL THEN
         /* If already Top N were Calculated for the given parameters
            then check respective Package tables for given item-Customer id  */
        IF    (Pv_pmisa_tp_Sales_orgn        = p_sales_orgn        AND Pv_pmisa_tp_cost_mthd        = p_cost_mthd AND
               Pv_pmisa_tp_Prd_start_dt      = p_Prd_start_date    AND Pv_pmisa_tp_Prd_end_dt       = p_Prd_end_date  AND
               Pv_pmisa_tp_top_n             = p_top_n ) THEN
            LOOP
               IF pv_pmisa_top_n_item(l_count) = p_item_id THEN
                  return 1;
               END IF;
               l_count := l_count+1;
               EXIT WHEN l_count > p_top_n;
             END LOOP;
             return 0;
        ELSE
                /* If Top N is not calculated for the given parameters , Start Calculating the TOP N and
                   Populate corresponding tables */
                /* assign new passed values to Package Variables */
                Pv_pmisa_tp_Sales_orgn        := p_sales_orgn;
                Pv_pmisa_tp_cost_mthd         := p_cost_mthd;
                Pv_pmisa_tp_Prd_start_dt      := p_Prd_start_date;
                Pv_pmisa_tp_Prd_end_dt        := p_Prd_end_date;
                Pv_pmisa_tp_top_n             := p_top_n ;
             /* If Top N item need to be calculated, Empty the previous constructed table */
             pv_pmisa_top_n_item.DELETE;
	       OPEN cur_item(p_Sales_orgn,p_cost_mthd,p_Prd_start_date,p_Prd_end_date);
             LOOP
                 FETCH cur_item INTO l_item_id,l_margin;
                 EXIT WHEN  cur_item%NOTFOUND;
                 EXIT WHEN  l_count > p_top_n;
		     IF l_item_id = p_item_id THEN
                    /*Flag to check if this list contains the passed item */
                    l_found := 1;
                 END IF;
                 pv_pmisa_top_n_item(l_count):= l_item_id;
                 l_count := l_count+1;
              END LOOP;
              CLOSE cur_item;
              IF l_found=1 THEN
                 return 1;
              ELSE
                 return 0;
              END IF;
         END IF;

   ELSIF P_ITEM_ID is NULL THEN             /* If customer id is passed check Customer Table */

         /* If already Top N were Calculated for the given parameters
            then check respective Package tables for given item-Customer id  */
        IF    (Pv_pmisa_tp_cust_Sales_orgn        = p_sales_orgn        AND Pv_pmisa_tp_cust_cost_mthd        = p_cost_mthd AND
               Pv_pmisa_tp_cust_Prd_start_dt      = p_Prd_start_date    AND Pv_pmisa_tp_cust_Prd_end_dt       = p_Prd_end_date  AND
               Pv_pmisa_tp_cust_top_n             = p_top_n ) THEN

             LOOP
                IF pv_pmisa_top_n_cust(l_count) = p_customer_id THEN
                   return 1;
                END IF;
                l_count := l_count+1;
                EXIT WHEN l_count > p_top_n;
             END LOOP;
             return 0;

       ELSE
         /* If Top N is not calculated for the given parameters , Start Calculating the TOP N and
            Populate corresponding tables */
         /* assign new passed values to Package Variables */
         Pv_pmisa_tp_cust_Sales_orgn        := p_sales_orgn;
         Pv_pmisa_tp_cust_cost_mthd         := p_cost_mthd;
         Pv_pmisa_tp_cust_Prd_start_dt      := p_Prd_start_date;
         Pv_pmisa_tp_cust_Prd_end_dt        := p_Prd_end_date;
         Pv_pmisa_tp_cust_top_n             := p_top_n ;

         /* If Top N Customers  need to be calculated, Empty the previous constructed table */

              pv_pmisa_top_n_cust.DELETE;
	        OPEN cur_customer(p_Sales_orgn,p_cost_mthd,p_Prd_start_date,p_Prd_end_date);
                   LOOP
                      FETCH cur_customer INTO l_customer_id,l_margin;
                      EXIT WHEN  cur_customer%NOTFOUND;
                      EXIT WHEN  l_count > p_top_n;
		          IF l_customer_id = p_customer_id THEN
                       /*Flag to check if this list contains the passed Customer */
                         l_found := 1;
                      END IF;
                      pv_pmisa_top_n_cust(l_count):= l_customer_id;
                      l_count := l_count+1;
                   END LOOP;
              CLOSE cur_customer;
              IF l_found=1 THEN
                 return 1;
              ELSE
                 return 0;
              END IF;
	END IF;
   END IF;
END PMISA_GET_TOP_N;

FUNCTION PMISA_GET_TOP_N_BY_OU(p_OU_ID         IN hr_operating_units.ORGANIZATION_ID%TYPE,
                         p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		             p_Prd_start_date      IN DATE,
                         p_Prd_end_date        IN DATE,
                         p_item_id		     IN ic_item_mst.item_id%TYPE DEFAULT NULL,
                         P_customer_id         IN hz_parties.PARTY_ID%TYPE DEFAULT NULL,
                         p_top_n               IN NUMBER
                        )
 RETURN NUMBER
 IS
 /* cursor to Fetch Top products with respect to margin */

 Cursor cur_item  (     p_OU_ID               IN hr_operating_units.ORGANIZATION_ID%TYPE,
                        p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		            p_Prd_start_date      IN DATE,
                        p_Prd_end_date        IN DATE
                  )
                 IS
                    SELECT item_id, SUM(line_margin) margin
                    FROM
                    (
                    SELECT  orderdetail.item_id,
                            DECODE(orderdetail.BASE_CURRENCY,orderdetail.BILLING_CURRENCY,
                            orderdetail.EXTENDED_PRICE,
                            Decode(orderdetail.mul_div_sign,0,orderdetail.EXTENDED_PRICE*orderdetail.EXCHANGE_RATE,
                            orderdetail.EXTENDED_PRICE/orderdetail.EXCHANGE_RATE))
                            -
                            gmicuom.I2UOM_CV(orderdetail.Item_Id,0,orderdetail.ORDER_UM1,
                            orderdetail.ORDER_QTY1,itemmst.Item_UM)*
                            pmi_common_pkg.PMICO_GET_COST(orderdetail.item_id,
                            orderdetail.From_whse,p_cost_mthd,orderdetail.Actual_Shipdate)
                            -
                            pmi_sales_pkg.PMISA_GET_CHARGE(orderdetail.order_Id,orderdetail.line_Id,
                                orderdetail.extended_price,orderdetail.billing_currency,orderdetail.base_currency,
                                orderdetail.exchange_rate,orderdetail.mul_div_sign) line_Margin
			  FROM
                           OP_ORDR_HDR orderhdr,
                           OP_ORDR_DTL orderdetail,
                           IC_ITEM_MST itemmst,
                           SY_ORGN_MST org,
                           GL_PLCY_MST pol
                    WHERE  orderhdr.order_id  = orderdetail.order_id
                          AND orderdetail.item_id = itemmst.item_id
                          AND trunc(orderdetail.ACTUAL_SHIPDATE)
                              between p_prd_start_date and p_prd_end_date
                          AND org.orgn_code = orderhdr.orgn_code
                          AND pol.co_code = org.co_code
                          AND pol.org_id = p_OU_ID
                    UNION ALL
                    SELECT  itemmst.item_id,
                              (DECODE(sob.CURRENCY_CODE,
                                       orderhdr.TRANSACTIONAL_CURR_CODE,
                                       orderdetail.ORDERED_QUANTITY * orderdetail.UNIT_SELLING_PRICE,
                                       orderdetail.ORDERED_QUANTITY * orderdetail.UNIT_SELLING_PRICE
                                                                    * orderhdr.CONVERSION_RATE)
                                )
                            - (gmicuom.I2UOM_CV(itemmst.Item_Id,
                                0, orderdetail.ORDER_QUANTITY_UOM,
                                orderdetail.ORDERED_QUANTITY,itemmst.Item_UM)*
                                pmi_common_pkg.PMICO_GET_COST(itemmst.item_id,
                                                              fromwhse.whse_code,
                                                              p_cost_mthd,
                                                              orderdetail.Actual_Shipment_date)
                                 )
                            - (pmi_sales_pkg.PMIOM_GET_CHARGE(
                                          orderdetail.header_Id,
                                          orderdetail.line_Id,
                                          orderdetail.ordered_quantity*orderdetail.unit_selling_price,
                                          orderhdr.transactional_curr_code,
                                          sob.currency_code,
                                          orderhdr.conversion_rate,
                                          orderdetail.ordered_quantity)
                                 ) line_Margin
			  FROM
                           OE_ORDER_HEADERS_ALL orderhdr,
                           OE_ORDER_LINES_ALL orderdetail,
                           OE_SYSTEM_PARAMETERS_ALL masterorg,
                           MTL_SYSTEM_ITEMS msi,
                           IC_ITEM_MST itemmst,
                           HR_OPERATING_UNITS ou,
                           GL_SETS_OF_BOOKS sob,
                           IC_WHSE_MST fromwhse
                    WHERE
                           orderhdr.header_id  = orderdetail.header_id
                      AND  masterorg.org_id = orderhdr.org_id
                      AND  msi.organization_id = masterorg.master_organization_id
                      AND  msi.inventory_item_id = orderdetail.inventory_item_id
                      AND  itemmst.item_no = msi.segment1
                      AND  trunc(orderdetail.ACTUAL_SHIPMENT_DATE) between p_prd_start_date and p_prd_end_date
                      AND  ou.organization_id = p_OU_ID
                      AND  ou.organization_id = orderhdr.org_id
                      AND  sob.set_of_books_id = ou.set_of_books_id
                      AND  fromwhse.mtl_organization_id = orderdetail.ship_from_org_id
                    )
                    GROUP BY  item_id
                    ORDER BY Margin desc;

/* Cursor to get Top N customers with respect to Margin */
  Cursor cur_customer  (      p_OU_ID               IN hr_operating_units.ORGANIZATION_ID%TYPE,
                              p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		                  p_Prd_start_date      IN DATE,
                              p_Prd_end_date        IN DATE
                       )
                    IS
                    SELECT cust_id, SUM(line_margin) margin
                    FROM
                    (
                     SELECT  orderhdr.billcust_id cust_id,
                            DECODE(orderdetail.BASE_CURRENCY,orderdetail.BILLING_CURRENCY,
                            orderdetail.EXTENDED_PRICE,
                            Decode(orderdetail.mul_div_sign,0,orderdetail.EXTENDED_PRICE*orderdetail.EXCHANGE_RATE,
                            orderdetail.EXTENDED_PRICE/orderdetail.EXCHANGE_RATE))
                            -
                            gmicuom.I2UOM_CV(orderdetail.Item_Id,0,orderdetail.ORDER_UM1,
                            orderdetail.ORDER_QTY1,itemmst.Item_UM)*
                            pmi_common_pkg.PMICO_GET_COST(orderdetail.item_id,
                            orderdetail.From_whse,p_cost_mthd,orderdetail.Actual_Shipdate)
                            -
                            pmi_sales_pkg.PMISA_GET_CHARGE(orderdetail.order_Id,orderdetail.line_Id,
                                orderdetail.extended_price,orderdetail.billing_currency,orderdetail.base_currency,
                                orderdetail.exchange_rate,orderdetail.mul_div_sign) line_Margin
			  FROM
                           OP_ORDR_HDR orderhdr,
                           OP_ORDR_DTL orderdetail,
                           IC_ITEM_MST itemmst,
                           SY_ORGN_MST org,
                           GL_PLCY_MST pol
                    WHERE  orderhdr.order_id  = orderdetail.order_id
                          AND orderdetail.item_id = itemmst.item_id
                          AND trunc(orderdetail.ACTUAL_SHIPDATE)
                              between p_prd_start_date and p_prd_end_date
                          AND org.orgn_code = orderhdr.orgn_code
                          AND pol.co_code = org.co_code
                          AND pol.org_id = p_OU_ID
                    UNION ALL
                    SELECT  billingcustomer.party_id cust_id,
                              (DECODE(sob.CURRENCY_CODE,
                                       orderhdr.TRANSACTIONAL_CURR_CODE,
                                       orderdetail.ORDERED_QUANTITY * orderdetail.UNIT_SELLING_PRICE,
                                       orderdetail.ORDERED_QUANTITY * orderdetail.UNIT_SELLING_PRICE
                                                                    * orderhdr.CONVERSION_RATE)
                                )
                            - (gmicuom.I2UOM_CV(itemmst.Item_Id,
                                0, orderdetail.ORDER_QUANTITY_UOM,
                                orderdetail.ORDERED_QUANTITY,itemmst.Item_UM)*
                                pmi_common_pkg.PMICO_GET_COST(itemmst.item_id,
                                                              fromwhse.whse_code,
                                                              p_cost_mthd,
                                                              orderdetail.Actual_Shipment_date)
                                 )
                            - (pmi_sales_pkg.PMIOM_GET_CHARGE(
                                          orderdetail.header_Id,
                                          orderdetail.line_Id,
                                          orderdetail.ordered_quantity*orderdetail.unit_selling_price,
                                          orderhdr.transactional_curr_code,
                                          sob.currency_code,
                                          orderhdr.conversion_rate,
                                          orderdetail.ordered_quantity)
                                 ) line_Margin
			  FROM
                           OE_ORDER_HEADERS_ALL orderhdr,
                           OE_ORDER_LINES_ALL orderdetail,
                           OE_SYSTEM_PARAMETERS_ALL masterorg,
                           MTL_SYSTEM_ITEMS msi,
                           IC_ITEM_MST itemmst,
                           HR_OPERATING_UNITS ou,
                           GL_SETS_OF_BOOKS sob,
                           IC_WHSE_MST fromwhse,
                           PMI_HZ_PARTY_V billingcustomer
                    WHERE
                           orderhdr.header_id  = orderdetail.header_id
                      AND  masterorg.org_id = orderhdr.org_id
                      AND  msi.organization_id = masterorg.master_organization_id
                      AND  msi.inventory_item_id = orderdetail.inventory_item_id
                      AND  itemmst.item_no = msi.segment1
                      AND  trunc(orderdetail.ACTUAL_SHIPMENT_DATE) between p_prd_start_date and p_prd_end_date
                      AND  ou.organization_id = p_OU_ID
                      AND  ou.organization_id = orderhdr.org_id
                      AND  sob.set_of_books_id = ou.set_of_books_id
                      AND  fromwhse.mtl_organization_id = orderdetail.ship_from_org_id
                      AND  billingcustomer.SITE_USE_ID(+)  = orderhdr.invoice_to_org_id
                    )
                      GROUP BY cust_id
                      ORDER BY Margin desc;
 l_count       NUMBER:=1;
 l_found       NUMBER:=0;
 l_item_id     NUMBER;
 l_customer_id NUMBER;
 l_margin      NUMBER;
 BEGIN
   IF P_CUSTOMER_ID is NULL THEN
       /* If Item id is passed check Item Table */
        /* Check Package varables if already top N is calculated for the given combination */
     IF    (Pv_pmisa_tp_om_OU_ID             = p_OU_ID             AND Pv_pmisa_tp_om_cost_mthd        = p_cost_mthd AND
            Pv_pmisa_tp_om_Prd_start_dt      = p_Prd_start_date    AND Pv_pmisa_tp_om_Prd_end_dt       = p_Prd_end_date  AND
            Pv_pmisa_tp_om_top_n             = p_top_n ) THEN

         /* If already Top N were Calculated for the given parameters
            then check respective Package tables for given item-Customer id  */

            LOOP
               IF pv_pmisa_top_n_item_by_ou(l_count) = p_item_id THEN
                  return 1;
               END IF;
               l_count := l_count+1;
               EXIT WHEN l_count > p_top_n;
             END LOOP;
             return 0;
     ELSE
         /* If Top N is not calculated for the given parameters , Start Calculating the TOP N and
            Populate corresponding tables */
         /* assign new passed values to Package Variables */
         Pv_pmisa_tp_om_OU_ID             := p_OU_ID;
         Pv_pmisa_tp_om_cost_mthd         := p_cost_mthd;
         Pv_pmisa_tp_om_Prd_start_dt      := p_Prd_start_date;
         Pv_pmisa_tp_om_Prd_end_dt        := p_Prd_end_date;
         Pv_pmisa_tp_om_top_n             := p_top_n ;
             /* If Top N item need to be calculated, Empty the previous constructed table */
             pv_pmisa_top_n_item_by_ou.DELETE;
	       OPEN cur_item(p_OU_ID,p_cost_mthd,p_Prd_start_date,p_Prd_end_date);
             LOOP
                 FETCH cur_item INTO l_item_id,l_margin;
                 EXIT WHEN  cur_item%NOTFOUND;
                 EXIT WHEN  l_count > p_top_n;
		     IF l_item_id = p_item_id THEN
                    /*Flag to check if this list contains the passed item */
                    l_found := 1;
                 END IF;
                 pv_pmisa_top_n_item_by_ou(l_count):= l_item_id;
                 l_count := l_count+1;
              END LOOP;
              CLOSE cur_item;
              IF l_found=1 THEN
                 return 1;
              ELSE
                 return 0;
              END IF;
       END IF;
 ELSIF P_ITEM_ID is NULL THEN
        /* Check Package varables if already top N is calculated for the given combination */
     IF    (Pv_pmisa_tp_om_cust_OU_ID             = p_OU_ID             AND Pv_pmisa_tp_om_cust_cost_mthd        = p_cost_mthd AND
            Pv_pmisa_tp_om_cust_Prd_st_dt      = p_Prd_start_date    AND Pv_pmisa_tp_om_cust_Prd_end_dt       = p_Prd_end_date  AND
            Pv_pmisa_tp_om_cust_top_n             = p_top_n ) THEN

             /* If customer id is passed check Customer Table */
             LOOP
                IF pv_pmisa_top_n_cust_by_ou(l_count) = p_customer_id THEN
                   return 1;
                END IF;
                l_count := l_count+1;
                EXIT WHEN l_count > p_top_n;
             END LOOP;
             return 0;

       ELSE
         /* If Top N is not calculated for the given parameters , Start Calculating the TOP N and
            Populate corresponding tables */
         /* assign new passed values to Package Variables */
         Pv_pmisa_tp_om_cust_OU_ID             := p_OU_ID;
         Pv_pmisa_tp_om_cust_cost_mthd         := p_cost_mthd;
         Pv_pmisa_tp_om_cust_Prd_st_dt         := p_Prd_start_date;
         Pv_pmisa_tp_om_cust_Prd_end_dt        := p_Prd_end_date;
         Pv_pmisa_tp_om_cust_top_n             := p_top_n ;

             /* If Top N Customers  need to be calculated, Empty the previous constructed table */

              pv_pmisa_top_n_cust_by_ou.DELETE;
	        OPEN cur_customer(p_OU_ID,p_cost_mthd,p_Prd_start_date,p_Prd_end_date);
                   LOOP
                      FETCH cur_customer INTO l_customer_id,l_margin;
                      EXIT WHEN  cur_customer%NOTFOUND;
                      EXIT WHEN  l_count > p_top_n;
		          IF l_customer_id = p_customer_id THEN
                       /*Flag to check if this list contains the passed Customer */
                         l_found := 1;
                      END IF;
                      pv_pmisa_top_n_cust_by_ou(l_count):= l_customer_id;
                      l_count := l_count+1;
                   END LOOP;
              CLOSE cur_customer;
              IF l_found=1 THEN
                 return 1;
              ELSE
                 return 0;
              END IF;
        END IF;
  END IF;
END PMISA_GET_TOP_N_BY_OU;


FUNCTION PMISA_VALIDATE_DATE(p_Sales_Company   IN sy_orgn_mst.co_code%TYPE,
                             p_From_year       IN number,
                             p_To_year         IN number,
		                 p_From_period     IN pmi_gl_calendar_v.period_name%TYPE,
                             p_To_period       IN pmi_gl_calendar_v.period_name%TYPE,
                             p_actual_date     IN DATE
                         )
RETURN NUMBER IS
BEGIN
       /* Check if Start Date and End Date of given period has been calculated */
       IF      pv_pmisa_vd_from_year          = p_From_year
           AND pv_pmisa_vd_to_year            = p_To_year
           AND pv_pmisa_vd_from_period        = p_From_period
           AND pv_pmisa_vd_to_period          = p_To_period
           AND pv_pmisa_vd_Company            = p_Sales_company THEN
             /*If already Calculated then compare with package variables */

              IF (trunc(p_actual_date) between  pv_pmisa_vd_start_date  and  pv_pmisa_vd_end_date) THEN
                  return 1;
              ELSE
                  return 0;
              END IF;
        ELSE
              /*If not, Recalculate the start date and end date */
             pv_pmisa_vd_from_year       := p_From_year;
             pv_pmisa_vd_to_year         := p_To_year;
             pv_pmisa_vd_from_period     := p_From_period;
             pv_pmisa_vd_to_period       := p_To_period;
             pv_pmisa_vd_Company         := p_sales_company;
             select start_date into pv_pmisa_vd_start_date
               from pmi_gl_calendar_v
               where period_year=p_from_year and period_name=p_from_period and co_code=p_sales_company;
             select end_date into pv_pmisa_vd_end_date
               from pmi_gl_calendar_v
               where period_year=p_to_year and period_name=p_to_period and co_code=p_sales_company;
              IF (trunc(p_actual_date) between  pv_pmisa_vd_start_date  and  pv_pmisa_vd_end_date) THEN
                  return 1;
              ELSE
                  return 0;
              END IF;
          END IF;
END PMISA_VALIDATE_DATE;

/* Function to calculate Charges for a given order line , Refer Package Spec for Details Description */
FUNCTION PMISA_GET_CHARGE  ( p_Order_id         IN op_ordr_dtl.order_id%TYPE,
                             p_Line_id          IN op_ordr_dtl.line_id%TYPE,
                             p_extended_price   IN op_ordr_dtl.extended_price%TYPE,
                             p_Billing_Currency IN op_ordr_dtl.billing_currency%TYPE,
		                 p_Base_Currency    IN op_ordr_dtl.BASE_CURRENCY%TYPE,
                             p_exchange_Rate    IN op_ordr_dtl.EXCHANGE_RATE%TYPE,
                             p_mul_div_sign     IN op_ordr_dtl.mul_div_sign%TYPE
                            )
RETURN NUMBER IS
/* Cursor to find changes for order and line */
/* SUM added in case multiple charge lines are returned for a line_id. -PDONG 01-31-02 */

CURSOR cur_line_charge(P_order_id         op_ordr_dtl.order_id%TYPE,
                       P_line_id          op_ordr_dtl.line_id%TYPE,
                       P_base_currency    op_ordr_dtl.BASE_CURRENCY%TYPE,
                       p_billing_currency op_ordr_dtl.billing_currency%TYPE,
                       p_exchange_rate    op_ordr_dtl.EXCHANGE_RATE%TYPE,
                       p_mul_div_sign     op_ordr_dtl.mul_div_sign%TYPE)
                  IS
                  SELECT SUM(abs(DECODE(P_Base_Currency,p_Billing_Currency,
                             Extended_amount,
                             Decode(p_mul_div_sign,0,Extended_amount*p_Exchange_Rate,
                             Extended_amount/p_Exchange_Rate)))
                             )
                    FROM op_ordr_chg a, op_chrg_mst b
                   WHERE a.order_id = P_order_id
                     AND a.line_id  = P_line_id
                     AND a.charge_id = b.charge_id
                     AND b.charge_type in (20,30);

/* Cursor to find changes for order  */
CURSOR cur_order_charge(P_order_id         op_ordr_dtl.order_id%TYPE,
                        P_base_currency    op_ordr_dtl.BASE_CURRENCY%TYPE,
                        p_billing_currency op_ordr_dtl.billing_currency%TYPE,
                        p_exchange_rate    op_ordr_dtl.EXCHANGE_RATE%TYPE,
                        p_mul_div_sign     op_ordr_dtl.mul_div_sign%TYPE)
                  IS
                  SELECT sum(abs(DECODE(P_Base_Currency,p_Billing_Currency,
                             Extended_amount,
                             Decode(p_mul_div_sign,0,Extended_amount*p_Exchange_Rate,
                             Extended_amount/p_Exchange_Rate))))
                    FROM op_ordr_chg a, op_chrg_mst b
                   WHERE a.order_id = P_order_id
                     AND a.line_id IS NULL
                     AND a.charge_id = b.charge_id
                     AND b.charge_type in (20,30);

/*Cursor to find total value for order*/

CURSOR cur_order_value(P_order_id op_ordr_dtl.order_id%TYPE)
                  IS
                  SELECT  SUM(DECODE(Base_Currency,Billing_Currency,
                             Extended_price,
                             Decode(mul_div_sign,0,Extended_price*Exchange_Rate,
                             Extended_price/Exchange_Rate)))
                    FROM op_ordr_dtl
                  WHERE  order_id = P_order_id;

l_line_charge NUMBER;
l_order_value NUMBER;
l_order_charge NUMBER;
l_total_charge NUMBER;
BEGIN
     /* Get Charges for line */
     OPEN  cur_line_charge(P_Order_id,p_Line_id,P_base_currency,p_billing_currency,p_exchange_rate,p_mul_div_sign);
     FETCH cur_line_charge into l_line_charge;
     IF cur_line_charge%NOTFOUND THEN
        l_line_charge:=0;
     END IF;
     CLOSE cur_line_charge;

     /* Get order value to calculate order discount */

     OPEN  cur_order_value(P_Order_id);
     FETCH cur_order_value into l_order_value;
     IF l_order_value = 0 THEN
        l_order_value:=1;
     END IF;
     CLOSE cur_order_value;
     /* Get Charges for Order */
     OPEN  cur_order_charge(P_Order_id,P_base_currency,p_billing_currency,p_exchange_rate,p_mul_div_sign);
     FETCH cur_order_charge into l_order_charge;
     IF cur_order_charge%NOTFOUND THEN
        l_order_charge:=0;
     END IF;
     CLOSE cur_order_charge;

      /* Calculate total Charges      */
     l_total_charge:=l_line_charge + (p_extended_price/(l_order_value)*l_order_charge);
     return nvl(l_total_charge,0);
 END PMISA_GET_CHARGE;


/* Function to calculate Charges for a given OM order line */

FUNCTION PMIOM_GET_CHARGE   (p_Header_id        IN oe_order_lines_all.header_id%TYPE,
                             p_Line_id          IN oe_order_lines_all.line_id%TYPE,
                             p_extended_price   IN oe_order_lines_all.unit_selling_price%TYPE,
                             p_Billing_Currency IN oe_order_headers_all.transactional_curr_code%TYPE,
                             p_Base_Currency    IN gl_sets_of_books.currency_code%TYPE,
                             p_exchange_Rate    IN oe_order_headers_all.conversion_rate%TYPE,
                             p_ordered_quantity IN oe_order_lines_all.ordered_quantity%TYPE
                            )
RETURN NUMBER
IS
    /* cur_line_charge returns line-level changes, in transactional currency  */

    CURSOR cur_line_charge(P_Header_id oe_order_lines_all.header_id%TYPE,
                           P_line_id oe_price_adjustments.line_id%TYPE)
    IS
      /* Bug fix 2733400 SKARIMIS 01/10/2003 */
     SELECT   	SUM(opa.adjusted_amount) * AVG(ool.ordered_quantity)	line_level_discount
      FROM    	oe_price_adjustments_v opa
			, oe_order_lines_all ool
      WHERE  	opa.line_id =p_line_id
		   	and ool.line_id = p_line_id
		   	and ool.header_id = p_header_id
		   	and nvl(opa.applied_flag,'Y') = 'Y'
			and nvl(opa.accrual_flag,'N') = 'N'
		   	and list_line_type_code = 'DIS';

    /* cur_order_charge returns order-level changes, in transactional currency  */

    CURSOR cur_order_charge IS
      SELECT   SUM(decode(opa.arithmetic_operator,
				null, 0,
				'%', opa.operand*ool.unit_list_price/100,
				'AMT',opa.operand,
				'NEWPRICE',ool.unit_list_price - opa.operand) * ool.ordered_quantity
                  ) order_level_discount
      FROM    	oe_price_adjustments_v opa
			, oe_order_lines_all ool
      WHERE   	opa.HEADER_ID = p_header_id
			and opa.line_id is null
		   	and ool.line_id = p_line_id
		   	and ool.header_id = p_header_id
		   	and nvl(opa.applied_flag,'Y') = 'Y'
			and nvl(opa.accrual_flag,'N') = 'N'
		   	and list_line_type_code = 'DIS';

    l_line_charge NUMBER;
    l_order_charge NUMBER;
    l_total_charge NUMBER;
BEGIN
     /* Get Charges defined at the Line level */
     OPEN  cur_line_charge(p_Header_id,P_line_id) ;
     FETCH cur_line_charge into l_line_charge;
     IF cur_line_charge%NOTFOUND THEN
        l_line_charge:=0;
     END IF;
     CLOSE cur_line_charge;

     /* Get Charges defined at the Order level*/
     OPEN  cur_order_charge;
     FETCH cur_order_charge into l_order_charge;
     IF cur_order_charge%NOTFOUND THEN
        l_order_charge:=0;
     END IF;
     CLOSE cur_order_charge;

      /* Calculate total Charges */
     l_total_charge:= nvl(l_line_charge,0) +  nvl(l_order_charge, 0);

     IF p_base_currency <> p_billing_currency THEN
        l_total_charge := l_total_charge * p_exchange_rate;
     END IF;

     return l_total_charge;
END PMIOM_GET_CHARGE;


END pmi_sales_pkg;

/
