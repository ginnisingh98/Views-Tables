--------------------------------------------------------
--  DDL for Package OPI_OPM_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_OPM_COMMON_PKG" AUTHID CURRENT_USER as
/* $Header: OPICOMMS.pls 115.4 2002/05/07 13:29:01 pkm ship    $ */

/* ###########################################################################
   Function OPMCO_GET_COST

   Wrapper Function   on GMF_COMMON.cmcommon_get_Cost
   Input Parameters
         Item_id    Item_id
         Whse_code  Warehouse Code
         Trans_date Transaction Date
         Cost_mthd  Cost Method
    Description:

    Return Value Accounting Cost from GL_ITEM_CST table

    Note : This function return cost only if the cost is posted against GL tables
           i.e if Cost update is run after Cost Rollup for the periods
           Refer GMF_COMMON.cmcommon_get_Cost package for further Details

***************************************************************************
*/

 FUNCTION OPMCO_GET_COST(p_Item_id       IN ic_item_mst.item_id%TYPE,
             p_Whse_code     IN ic_whse_mst.whse_code%TYPE,
             p_Cost_mthd     IN cm_cmpt_dtl.cost_mthd_code%TYPE DEFAULT NULL,
	       p_Transaction_date    IN DATE)
     RETURN NUMBER;

/*
  ###########################################################################
   Function OPMCO_GET_MULCURR_AMT

   Wrapper Function   on GMF_GLCOMMON_DB.get_closest_rate
   Input Parameters
         From Currency
         To Currency
         Exchange Rate Date
         Amount to be converted
    Description:
    Return The converted amount from-currency to-currency. If conversion fails
    returns the 0
    Note :

    #####################################################################
*/

    /* Package Variables for the function to avoid repetative calculations */

       PV_OPMCO_GMA_F_CURR    gl_curr_mst.currency_code%TYPE;
       PV_OPMCO_GMA_T_CURR    gl_curr_mst.currency_code%TYPE;
       PV_OPMCO_GMA_RATE_DT   DATE;
       PV_OPMCO_GMA_SIGN      NUMBER;
       PV_OPMCO_GMA_XCNG_RATE NUMBER;

     FUNCTION OPMCO_GET_MULCURR_AMT(
                  p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
                  p_To_Curr               IN gl_curr_mst.currency_code%TYPE,
                  p_Rate_date             IN DATE,
		      p_amount                IN NUMBER)
     RETURN NUMBER;

/* #####################################################################
   Function OPMCO_CURRCONV_ERROR

   Wrapper Function   on GMF_GLCOMMON_DB.get_closest_rate
   Input Parameters
         From Currency
         To Currency
         Exchange Rate Date

    Description:
    This function checks the availability of Currency cinversion for the date given.
    Return 1 If conversion Does not exist or returns 0 if conversion exist

    Note :

    ###################################################################### */

    /* Package Variables for the function to avoid repetative calculations */

       PV_OPMCO_CE_F_CURR    gl_curr_mst.currency_code%TYPE;
       PV_OPMCO_CE_T_CURR    gl_curr_mst.currency_code%TYPE;
       PV_OPMCO_CE_RATE_DT   DATE;
       PV_OPMCO_CE_XCNG_ERROR     NUMBER;

     FUNCTION OPMCO_CURRCONV_ERROR (
               p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
               p_To_Curr               IN gl_curr_mst.currency_code%TYPE,
               p_Rate_date             IN DATE)
     RETURN NUMBER;
/* #############################################################################
   Function OPI_OPM_GET_CHARGE
   This function is to get charges from given order line

   Inputs
         ORDER_ID
         EXTENDED_PRICE
         BASE_CURRENCY
         Exchange Rate
         MUL_DIV_SIGN

    Description
    The following assumptions are made to get the charges
     1. We should consider only those Charges where CHARGE_TYPE = 20 or 30 ( 20= Discount, 30= Allowances )
     2. We will exclude CHARGE_TYPE = 0 or 1 or 10 ( 0 = Miscellaneous, 1 = Freight, 10 = Tax ) from this calculation.
     3. OP_ORDR_CHG.EXTENDED_AMOUNT is the Total Charge (in Base Currency) for the order Line or the whole
        Order.
     4. In the table OP_ORDR_CHG, if LINE_ID is NULL ( i.e. Charge specified for the whole Order ) then calculate the
        charge for a particular order line using the formula (Extended Price of the order line / Total Order Value ) *
        EXTENDED_AMOUNT
     5. If No Charge is found the function returns 0

   ################################################################################# */


FUNCTION OPI_OPM_GET_CHARGE  (p_Order_id        IN op_ordr_dtl.order_id%TYPE,
                             p_charge_amount   IN NUMBER,
                             p_extended_price   IN op_ordr_dtl.extended_price%TYPE,
                             p_Billing_Currency IN op_ordr_dtl.billing_currency%TYPE,
		                 p_Base_Currency    IN op_ordr_dtl.BASE_CURRENCY%TYPE,
                             p_exchange_Rate    IN op_ordr_dtl.EXCHANGE_RATE%TYPE,
                             p_mul_div_sign     IN op_ordr_dtl.mul_div_sign%TYPE
                            )
          RETURN NUMBER;

/* ###########################################################################
   Function OPMCO_GET_RSRC_COST

   Input Parameters
         ORGN_CODE  Organization Code
         RESOURCE   Resource
         Trans_date Transaction Date
         Cost_mthd  Cost Method
    Description:

    Return Value NOMINAL_COST from CM_RSRC_DTL
    Note : This funciton returns a 0 cost if cost is not found
***************************************************************************
*/

 FUNCTION OPMCO_GET_RSRC_COST(p_ORGN_CODE IN SY_ORGN_MST.ORGN_CODE%TYPE,
             p_RESOURCE     IN CR_RSRC_MST.RESOURCES%TYPE,
             p_Cost_mthd    IN cm_rsrc_dtl.cost_mthd_code%TYPE DEFAULT NULL,
             p_usage_uom    IN cm_rsrc_dtl.USAGE_UM%TYPE,
	       p_Transaction_date    IN DATE)
     RETURN NUMBER;


END opi_opm_common_pkg;

 

/
