--------------------------------------------------------
--  DDL for Package Body OPI_OPM_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_OPM_COMMON_PKG" as
/* $Header: OPICOMMB.pls 115.4 2002/05/07 13:28:59 pkm ship    $ */

    FUNCTION OPMCO_GET_COST(            p_Item_id             IN ic_item_mst.item_id%TYPE,
                                        p_Whse_code           IN ic_whse_mst.whse_code%TYPE,
                                        p_Cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE DEFAULT NULL,
	                                  p_Transaction_date    IN DATE)
    RETURN NUMBER
    IS
    /* Cursor to get Organization code for the Warehouse passed */
    CURSOR cur_whse_orgn_code(l_whse_code IN ic_whse_mst.whse_code%TYPE)
        IS
           SELECT orgn_code
             FROM ic_whse_mst
            WHERE whse_code = l_whse_code;
    CURSOR CUR_COST_MTHD(l_whse_code IN ic_whse_mst.whse_code%TYPE)
        IS
            SELECT b.orgn_code,c.GL_COST_MTHD
            FROM   ic_whse_mst a, sy_orgn_mst b, GL_PLCY_MST c
            WHERE  a.whse_code = l_whse_code
            AND    a.orgn_code = b.orgn_code
            AND    b.co_code = c.co_code;

    /* Local Variable Declaration */
    l_whse_code ic_whse_mst.whse_code%TYPE;
    l_orgn_code sy_orgn_mst.orgn_code%TYPE;
    l_cmpntcls_ind CM_CMPT_DTL.COST_CMPNTCLS_ID%TYPE;
    l_analysis_code CM_CMPT_DTL.COST_ANALYSIS_CODE%TYPE;
    l_total_cost NUMBER;
    l_no_of_rows NUMBER;
    l_cost_mthd  cm_cmpt_dtl.cost_mthd_code%TYPE;

    BEGIN
      IF p_cost_mthd IS NOT NULL THEN
         OPEN   cur_whse_orgn_code(p_Whse_code);
         FETCH  cur_whse_orgn_code into l_orgn_code;
         CLOSE  cur_whse_orgn_code;
         /* Assigning Parameter Cost Method to Local Cost method as the CMCOMMON_GET_COST
            will accept variable of type IN/OUT */
         l_cost_mthd:=p_cost_mthd;
      ELSE
         OPEN   CUR_COST_MTHD(p_Whse_code);
         FETCH  CUR_COST_MTHD into l_orgn_code,l_cost_mthd;
         CLOSE  CUR_COST_MTHD;
      END IF;
         IF GMF_CMCOMMON.CMCOMMON_GET_COST(p_Item_id,p_Whse_code,l_orgn_code,p_Transaction_date,
                                           l_Cost_mthd,l_cmpntcls_ind,l_analysis_code,1,
                                           l_total_cost,l_no_of_rows)= 1 THEN
             /* if Cost Found Return total Cost */
             Return l_total_cost;
         ELSE
             Return 0;
         END IF;
     END OPMCO_GET_COST;

     /*Function to calculate  amount in to_currency */

     FUNCTION OPMCO_GET_MULCURR_AMT(     p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
                                         p_To_Curr               IN gl_curr_mst.currency_code%TYPE,
                                         p_Rate_date             IN DATE,
		                             p_amount                IN NUMBER)
     RETURN NUMBER IS
     /* Cursor to get Rate type Code for Sales orders
        Trans Source type is Hardcoded with 5 as we need rate type for sales orders.
        The data in gl_srce_mst is seeded by GMFSEED.sql at the time of customer installation
     */
     CURSOR cur_get_rate_type
        IS
           SELECT rate_type_code
             FROM gl_srce_mst
            WHERE TRANS_SOURCE_TYPE=5;
     /*local Variables */
      l_rate_type_code gl_srce_mst.rate_type_code%TYPE;
      l_mul_div_sign   op_ordr_dtl.mul_div_sign%TYPE;
      l_error_code     number:=0;
      l_exchange_rate  number;
      l_converted_amount number;
      BEGIN
           IF(PV_OPMCO_GMA_F_CURR =p_from_curr AND PV_OPMCO_GMA_T_CURR =p_to_curr AND
              PV_OPMCO_GMA_RATE_DT   = p_rate_date) THEN
                  IF PV_OPMCO_GMA_SIGN = 0 THEN
                     l_converted_amount:= P_amount*PV_OPMCO_GMA_XCNG_RATE;
                  ELSE
                     l_converted_amount:= P_amount/PV_OPMCO_GMA_XCNG_RATE;
                  END IF;
                  return l_converted_amount;
           ELSE
                       /* Open the cursor to get rate type */
          		     OPEN cur_get_rate_type;
		           FETCH cur_get_rate_type into l_rate_type_code;
		           CLOSE cur_get_rate_type;
		           l_exchange_rate := gmf_glcommon_db.get_closest_rate(p_from_curr,p_to_curr,
                                                               p_rate_date,l_rate_type_code,
                                                               l_mul_div_sign,
                                                               l_error_code);
           			/* check if function returned any error
		              get_closest_rate return 100 as error*/
		           IF l_error_code = 100 THEN
		              RETURN 0;
		           ELSE
		              IF l_mul_div_sign = 0 THEN
		                 /* l_mul_div_sign = 0 indicates to perform multiplication between conversion */
		                 l_converted_amount:= P_amount*l_exchange_rate;
		              ELSE
		                 l_converted_amount:= P_amount/l_exchange_rate;
		              END IF;
                          PV_OPMCO_GMA_F_CURR:=p_from_curr;
                          PV_OPMCO_GMA_T_CURR:=p_to_curr;
                          PV_OPMCO_GMA_RATE_DT:=p_rate_date;
                          PV_OPMCO_GMA_SIGN:=l_mul_div_sign;
                          PV_OPMCO_GMA_XCNG_RATE:=l_exchange_rate;
		              return l_converted_amount;
                        END IF;
           END IF;
        END  OPMCO_GET_MULCURR_AMT;

 /*Function to find if conversion factor exist for currency */

     FUNCTION OPMCO_CURRCONV_ERROR(      p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
                                         p_To_Curr               IN gl_curr_mst.currency_code%TYPE,
                                         p_Rate_date             IN DATE)
     RETURN NUMBER IS
     /* Cursor to get Rate type Code for Sales orders
        Trans Source type is Hardcoded with 5 as we need rate type for sales orders.
        The data in gl_srce_mst is seeded by GMFSEED.sql at the time of customer installation
     */
     CURSOR cur_get_rate_type
        IS
           SELECT rate_type_code
             FROM gl_srce_mst
            WHERE TRANS_SOURCE_TYPE=5;
     /*local Variables */
      l_rate_type_code gl_srce_mst.rate_type_code%TYPE;
      l_mul_div_sign   op_ordr_dtl.mul_div_sign%TYPE;
      l_error_code     number:=0;
      l_exchange_rate NUMBER;
      BEGIN
           IF(PV_OPMCO_CE_F_CURR =p_from_curr AND PV_OPMCO_CE_T_CURR =p_to_curr AND
              PV_OPMCO_CE_RATE_DT   = p_rate_date) THEN
                  return PV_OPMCO_CE_XCNG_ERROR;
           ELSE
                       /* Open the cursor to get rate type */
          		     OPEN cur_get_rate_type;
		           FETCH cur_get_rate_type into l_rate_type_code;
		           CLOSE cur_get_rate_type;
		           l_exchange_rate := gmf_glcommon_db.get_closest_rate(p_from_curr,p_to_curr,
                                                               p_rate_date,l_rate_type_code,
                                                               l_mul_div_sign,
                                                               l_error_code);
           		     PV_OPMCO_CE_F_CURR:=p_from_curr;
                       PV_OPMCO_CE_T_CURR:=p_to_curr;
                       PV_OPMCO_CE_RATE_DT:=p_rate_date;
	        /* check if function returned any error get_closest_rate return 100 as error*/
		           IF l_error_code = 100 THEN
                          PV_OPMCO_CE_XCNG_ERROR:=1;
		           ELSE
                          PV_OPMCO_CE_XCNG_ERROR:=0;
		           END IF;
                       RETURN PV_OPMCO_CE_XCNG_ERROR;
           END IF;
        END  OPMCO_CURRCONV_ERROR;


FUNCTION OPI_OPM_GET_CHARGE  ( p_Order_id         IN op_ordr_dtl.order_id%TYPE,
                               p_charge_amount   IN NUMBER,
                             p_extended_price   IN op_ordr_dtl.extended_price%TYPE,
                             p_Billing_Currency IN op_ordr_dtl.billing_currency%TYPE,
		                 p_Base_Currency    IN op_ordr_dtl.BASE_CURRENCY%TYPE,
                             p_exchange_Rate    IN op_ordr_dtl.EXCHANGE_RATE%TYPE,
                             p_mul_div_sign     IN op_ordr_dtl.mul_div_sign%TYPE
                            )
RETURN NUMBER IS

/*Cursor to find total value for order*/

CURSOR cur_order_value(P_order_id op_ordr_dtl.order_id%TYPE)
                  IS
                  SELECT  SUM(DECODE(Base_Currency,Billing_Currency,
                             Extended_price,
                             Decode(mul_div_sign,0,Extended_price*Exchange_Rate,
                             Extended_price/Exchange_Rate)))
                    FROM op_ordr_dtl
                  WHERE  order_id = P_order_id
                    AND  line_status >= 20;

l_line_charge NUMBER;
l_order_value NUMBER;
l_order_charge NUMBER;
l_total_charge NUMBER;
BEGIN
     /* Get order value to calculate order discount */

     OPEN  cur_order_value(P_Order_id);
     FETCH cur_order_value into l_order_value;
     IF l_order_value = 0 THEN
        l_order_value:=1;
     END IF;
     CLOSE cur_order_value;
      /* Calculate total Charges      */
     l_total_charge:=(p_extended_price/(l_order_value)*p_charge_amount);
     return nvl(l_total_charge,0);
 END OPI_OPM_GET_CHARGE;

/* Function to Find Resource Cost */

    FUNCTION OPMCO_GET_RSRC_COST(       p_ORGN_CODE IN SY_ORGN_MST.ORGN_CODE%TYPE,
             				    p_RESOURCE     IN CR_RSRC_MST.RESOURCES%TYPE,
             				    p_Cost_mthd     IN cm_rsrc_dtl.cost_mthd_code%TYPE DEFAULT NULL,
                                        p_usage_uom    IN cm_rsrc_dtl.USAGE_UM%TYPE,
	       				    p_Transaction_date    IN DATE)
    RETURN NUMBER
    IS
    CURSOR CUR_COST_MTHD(l_orgn_code IN sy_orgn_mst.orgn_code%TYPE)
        IS
            SELECT b.CO_CODE,c.GL_COST_MTHD
            FROM   sy_orgn_mst b, GL_PLCY_MST c
            WHERE  b.orgn_code = l_orgn_code
            AND    b.co_code = c.co_code;

    /* Local Variable Declaration */
    l_orgn_code sy_orgn_mst.orgn_code%TYPE;
    l_cost_mthd  cm_cmpt_dtl.cost_mthd_code%TYPE;
    l_co_code sy_orgn_mst.orgn_code%TYPE;
    l_calendar_code cm_rsrc_dtl.CALENDAR_CODE%TYPE;
    l_period_code   cm_rsrc_dtl.PERIOD_CODE%TYPE;
    l_rsrc_cost NUMBER;
    BEGIN
      l_cost_mthd:=p_cost_mthd;
      IF p_cost_mthd IS NULL THEN
         OPEN   CUR_COST_MTHD(p_orgn_code);
         FETCH  CUR_COST_MTHD into l_co_code,l_cost_mthd;

         CLOSE  CUR_COST_MTHD;
      ELSE
         SELECT CO_CODE into l_co_code
          FROM  SY_ORGN_MST
          WHERE ORGN_CODE=p_ORGN_CODE;
      END IF;
            SELECT NOMINAL_COST into l_rsrc_cost
             FROM  CM_RSRC_DTL a,CM_CLDR_DTL b,CM_CLDR_HDR c
             WHERE a.ORGN_CODE=p_ORGN_CODE
               AND a.CALENDAR_CODE=b.CALENDAR_CODE
               AND a.PERIOD_CODE=b.PERIOD_CODE
               AND a.COST_MTHD_CODE=l_cost_mthd
               AND a.USAGE_UM=p_usage_uom
               AND a.RESOURCES=p_resource
               AND p_transaction_date between b.start_date and b.end_date
               AND b.CALENDAR_CODE=c.CALENDAR_CODE
               AND c.cost_mthd_code= l_cost_mthd
               AND c.co_code=l_co_code;
             return nvl(l_rsrc_cost,0);

     END OPMCO_GET_RSRC_COST;


END opi_opm_common_pkg;

/
