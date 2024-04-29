--------------------------------------------------------
--  DDL for Package PMI_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_COMMON_PKG" AUTHID CURRENT_USER as
/* $Header: PMICOMMS.pls 120.0 2005/05/24 16:54:45 appldev noship $ */

/* ###########################################################################
   Function PMICO_GET_COST

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

 FUNCTION PMICO_GET_COST(p_Item_id       IN ic_item_mst.item_id%TYPE,
             p_Whse_code     IN ic_whse_mst.whse_code%TYPE,
             p_Cost_mthd     IN cm_cmpt_dtl.cost_mthd_code%TYPE DEFAULT NULL,
	       p_Transaction_date    IN DATE)
     RETURN NUMBER;

/*
  ###########################################################################
   Function PMICO_GET_MULCURR_AMT

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

       PV_PMICO_GMA_F_CURR    gl_curr_mst.currency_code%TYPE;
       PV_PMICO_GMA_T_CURR    gl_curr_mst.currency_code%TYPE;
       PV_PMICO_GMA_RATE_DT   DATE;
       PV_PMICO_GMA_SIGN      NUMBER;
       PV_PMICO_GMA_XCNG_RATE NUMBER;

     FUNCTION PMICO_GET_MULCURR_AMT(
                  p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
                  p_To_Curr               IN gl_curr_mst.currency_code%TYPE,
                  p_Rate_date             IN DATE,
		      p_amount                IN NUMBER)
     RETURN NUMBER;

/* #####################################################################
   Function PMICO_CURRCONV_ERROR

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

       PV_PMICO_CE_F_CURR    gl_curr_mst.currency_code%TYPE;
       PV_PMICO_CE_T_CURR    gl_curr_mst.currency_code%TYPE;
       PV_PMICO_CE_RATE_DT   DATE;
       PV_PMICO_CE_XCNG_ERROR     NUMBER;

     FUNCTION PMICO_CURRCONV_ERROR (
               p_From_Curr             IN gl_curr_mst.currency_code%TYPE,
               p_To_Curr               IN gl_curr_mst.currency_code%TYPE,
               p_Rate_date             IN DATE)
     RETURN NUMBER;


/*
*******************************************************************************
***   Function PMICO_GET_TARGET
***
***   Input Parameters
***      Target Short Name
***      ORG Level Value ID
***      Dimension Level 1 Value ID
***      Period Type (GL Period Type Eg. Year,Quarter,Month
***      Period Set Name (GL Calendar Name)
***      Plan Id         (Business Plan Id)
***      From Date
***      To Date
***      View By         1-- Time 2-- Organization
***      Period Num      (GL Periods Period Num)
***
***
***    Description:
***      This function gets the target from bis targets based on input
***    parameters. Returns Target value if target exists otherwise returns
***    null.
******************************************************************************
*/
FUNCTION  PMICO_GET_TARGET(p_target_shortname      VARCHAR2,
                            p_ORG_LVL_ID           VARCHAR2,
                            p_DIM1_LVL_ID          VARCHAR2,
                            p_period_type          VARCHAR2,
                            P_period_set_name      VARCHAR2,
                            p_plan_id              NUMBER,
                            p_from_date            DATE,
                            p_to_date              DATE,
                            p_param_view_by        NUMBER,
                            p_period_num           NUMBER DEFAULT 0)
                     RETURN NUMBER;
END pmi_common_pkg;

 

/
