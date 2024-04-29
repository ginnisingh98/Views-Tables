--------------------------------------------------------
--  DDL for Package Body PMI_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_COMMON_PKG" as
/* $Header: PMICOMMB.pls 120.0 2005/05/24 16:54:43 appldev noship $ */

    FUNCTION PMICO_GET_COST(            p_Item_id             IN ic_item_mst.item_id%TYPE,
                                        p_Whse_code           IN ic_whse_mst.whse_code%TYPE,
                                        p_Cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
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
     END PMICO_GET_COST;

     /*Function to calculate  amount in to_currency */

     FUNCTION PMICO_GET_MULCURR_AMT(     p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
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
           IF(PV_PMICO_GMA_F_CURR =p_from_curr AND PV_PMICO_GMA_T_CURR =p_to_curr AND
              PV_PMICO_GMA_RATE_DT   = p_rate_date) THEN
                  IF PV_PMICO_GMA_SIGN = 0 THEN
                     l_converted_amount:= P_amount*PV_PMICO_GMA_XCNG_RATE;
                  ELSE
                     l_converted_amount:= P_amount/PV_PMICO_GMA_XCNG_RATE;
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
                          PV_PMICO_GMA_F_CURR:=p_from_curr;
                          PV_PMICO_GMA_T_CURR:=p_to_curr;
                          PV_PMICO_GMA_RATE_DT:=p_rate_date;
                          PV_PMICO_GMA_SIGN:=l_mul_div_sign;
                          PV_PMICO_GMA_XCNG_RATE:=l_exchange_rate;
		              return l_converted_amount;
                        END IF;
           END IF;
        END  PMICO_GET_MULCURR_AMT;

 /*Function to find if conversion factor exist for currency */

     FUNCTION PMICO_CURRCONV_ERROR(      p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
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
           IF(PV_PMICO_CE_F_CURR =p_from_curr AND PV_PMICO_CE_T_CURR =p_to_curr AND
              PV_PMICO_CE_RATE_DT   = p_rate_date) THEN
                  return PV_PMICO_CE_XCNG_ERROR;
           ELSE
                       /* Open the cursor to get rate type */
          		     OPEN cur_get_rate_type;
		           FETCH cur_get_rate_type into l_rate_type_code;
		           CLOSE cur_get_rate_type;
		           l_exchange_rate := gmf_glcommon_db.get_closest_rate(p_from_curr,p_to_curr,
                                                               p_rate_date,l_rate_type_code,
                                                               l_mul_div_sign,
                                                               l_error_code);
           		     PV_PMICO_CE_F_CURR:=p_from_curr;
                       PV_PMICO_CE_T_CURR:=p_to_curr;
                       PV_PMICO_CE_RATE_DT:=p_rate_date;
	        /* check if function returned any error get_closest_rate return 100 as error*/
		           IF l_error_code = 100 THEN
                          PV_PMICO_CE_XCNG_ERROR:=1;
		           ELSE
                          PV_PMICO_CE_XCNG_ERROR:=0;
		           END IF;
                       RETURN PV_PMICO_CE_XCNG_ERROR;
           END IF;
        END  PMICO_CURRCONV_ERROR;



FUNCTION  PMICO_GET_TARGET(p_target_shortname     VARCHAR2,
                            p_ORG_LVL_ID           VARCHAR2,
                            p_DIM1_LVL_ID          VARCHAR2,
                            p_period_type          VARCHAR2,
                            P_period_set_name      VARCHAR2,
                            p_plan_id              NUMBER,
                            p_from_date            DATE,
                            p_to_date              DATE,
                            p_param_view_by        NUMBER,
                            p_period_num           NUMBER)
                            RETURN NUMBER  IS

  CURSOR cur_target_lvl IS
    SELECT TARGET_LEVEL_ID
    FROM   bisbv_target_levels
    WHERE  lower(target_level_short_name) = lower(p_target_shortname);
  l_target         bisbv_targets.TARGET%TYPE;
  l_period_type    gl_periods.period_type%type;
  target_lvl_id    bisbv_target_levels.TARGET_LEVEL_ID%TYPE;
  time_lvl_id      bisbv_targets.TIME_LEVEL_VALUE_ID%TYPE;
BEGIN
  IF p_param_view_by = 1 THEN
    IF p_period_num IS NOT NULL AND p_period_num <> 0 THEN
      BEGIN
        SELECT p_period_set_name || '+' || period_name INTO time_lvl_id
        FROM gl_periods
        WHERE period_type     = p_period_type AND
            period_set_name   = p_period_set_name AND
            start_Date        BETWEEN p_from_date AND p_to_date  AND
            period_num        = p_period_num AND
            ADJUSTMENT_PERIOD_FLAG <> 'Y' ;
      EXCEPTION WHEN OTHERS THEN
        RETURN(NULL);
      END;
    ELSE
      RETURN (NULL);
    END IF;
  ELSE
    BEGIN
      SELECT p_period_set_name || '+' || period_name INTO time_lvl_id
      FROM gl_periods
      WHERE period_type     = p_period_type AND
            period_set_name = p_period_set_name AND
            start_Date      BETWEEN p_from_date AND p_to_date AND
            ADJUSTMENT_PERIOD_FLAG <> 'Y' ;
    EXCEPTION WHEN TOO_MANY_ROWS THEN
        RETURN (NULL);
      WHEN OTHERS THEN
        RETURN (NULL);
    END;
  END IF;
  OPEN cur_target_lvl;
  FETCH cur_target_lvl INTO target_lvl_id;
  IF cur_target_lvl%NOTFOUND THEN
     CLOSE cur_target_lvl;
     RETURN (NULL);
  END IF;
  CLOSE cur_target_lvl;

 BEGIN
   SELECT  TARGET INTO l_target
   FROM bisbv_targets
   WHERE target_level_id  =  target_lvl_id and
     ORG_LEVEL_VALUE_ID   =  p_ORG_LVL_ID  AND
     PLAN_ID              =  p_plan_id     AND
     DIM1_LEVEL_VALUE_ID  =  p_DIM1_LVL_ID AND
     TIME_LEVEL_VALUE_ID  =  time_lvl_id;

 EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN (NULL);
 WHEN OTHERS THEN
    RETURN (NULL);
 END;
   return(l_target);

END PMICO_GET_TARGET;


END pmi_common_pkg;

/
