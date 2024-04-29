--------------------------------------------------------
--  DDL for Package PMI_SALES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_SALES_PKG" AUTHID CURRENT_USER as
/* $Header: PMISAANS.pls 115.5 2003/02/19 04:46:55 srpuri ship $ */
/* #############################################################################
   Function PMISA_GET_TOP_N
   This function returns Top customers/Item from op_ordr_dtl
   with group by on Organization and Item/Customer for a fiven period
   with respect to margin made. The list is calculated and populated in a
   PL/SQL package table which is referred if the passed parameters are same


   Inputs
         Sales Organization
         Cost  method to calculate cost
         Period Start Date
         Period End Date
         Item Id
         Customer Id
         top N to calcluate the TOP N

    Description
          This function accepts the given parameters and calculates the top N list
          and populates a PL/SQL Table
   ################################################################################# */
/*Package Variable for Top N Products */

         Pv_pmisa_tp_Sales_orgn         sy_orgn_mst.orgn_code%TYPE;
         pv_pmisa_tp_cost_mthd          cm_cmpt_dtl.cost_mthd_code%TYPE;
         Pv_pmisa_tp_Prd_start_dt       DATE;
         Pv_pmisa_tp_Prd_end_dt         DATE;
         Pv_pmisa_tp_top_n              number;

/*Package Variable for Top N customers  */

         Pv_pmisa_tp_cust_Sales_orgn         sy_orgn_mst.orgn_code%TYPE;
         pv_pmisa_tp_cust_cost_mthd          cm_cmpt_dtl.cost_mthd_code%TYPE;
         Pv_pmisa_tp_cust_Prd_start_dt       DATE;
         Pv_pmisa_tp_cust_Prd_end_dt         DATE;
         Pv_pmisa_tp_cust_top_n              number;


 /* Added new variable to support OMSO which are at OU Level for Top N Products */

         Pv_pmisa_tp_om_OU_ID              hr_operating_units.ORGANIZATION_ID%TYPE;
         pv_pmisa_tp_om_cost_mthd          cm_cmpt_dtl.cost_mthd_code%TYPE;
         Pv_pmisa_tp_om_Prd_start_dt       DATE;
         Pv_pmisa_tp_om_Prd_end_dt         DATE;
         Pv_pmisa_tp_om_top_n              number;

 /* Added new variable to support OMSO which are at OU Level for Top N Customers */

         Pv_pmisa_tp_om_cust_OU_ID              hr_operating_units.ORGANIZATION_ID%TYPE;
         pv_pmisa_tp_om_cust_cost_mthd          cm_cmpt_dtl.cost_mthd_code%TYPE;
         Pv_pmisa_tp_om_cust_Prd_st_dt       DATE;
         Pv_pmisa_tp_om_cust_Prd_end_dt         DATE;
         Pv_pmisa_tp_om_cust_top_n              number;


  /* Package Table to hold Top n customers */
   TYPE  pv_pmisa_top_n_cust_type     is table of NUMBER INDEX BY BINARY_INTEGER;
         pv_pmisa_top_n_cust          pv_pmisa_top_n_cust_type;
  /* Package Table to hold Top n Items */
   TYPE pv_pmisa_top_n_item_type     is table of NUMBER INDEX BY BINARY_INTEGER;
        pv_pmisa_top_n_item          pv_pmisa_top_n_item_type;

 /* Added new variable to support OMSO which are at OU Level */
 /* Package Table to hold Top n customers By OU*/
        pv_pmisa_top_n_cust_by_ou    pv_pmisa_top_n_cust_type;

 /* Package Table to hold Top n Items by OU */
        pv_pmisa_top_n_item_by_ou    pv_pmisa_top_n_item_type;


FUNCTION PMISA_GET_TOP_N(P_Sales_orgn        IN sy_orgn_mst.orgn_code%TYPE,
                         P_cost_mthd         IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		             P_Prd_start_date    IN DATE,
                         P_Prd_end_date      IN DATE,
                         P_item_id		   IN ic_item_mst.item_id%TYPE DEFAULT NULL,
                         P_customer_id       IN op_ordr_hdr.billcust_id%TYPE DEFAULT NULL,
                         P_top_n             IN NUMBER
                         )
RETURN NUMBER;


FUNCTION PMISA_GET_TOP_N_BY_OU(p_OU_ID         IN hr_operating_units.ORGANIZATION_ID%TYPE,
                         p_cost_mthd           IN cm_cmpt_dtl.cost_mthd_code%TYPE,
		             p_Prd_start_date      IN DATE,
                         p_Prd_end_date        IN DATE,
                         p_item_id		     IN ic_item_mst.item_id%TYPE DEFAULT NULL,
                         P_customer_id         IN hz_parties.PARTY_ID%TYPE DEFAULT NULL,
                         p_top_n               IN NUMBER
                        )
 RETURN NUMBER;

/* #############################################################################
   Function PMISA_VALIDATE_DATE
   This function validate the Actual ship date for a gicen period

   Inputs
         Sales Company
         From Period
         To Period
         From Fiscal Year
         To Fiscal Year
         Actual Ship Date

    Description
       The function accepts the parameter and return 1 if the actual ship date falls
       between the given period
   ################################################################################# */

/*Package Variable for PMISA_VALIDATE_DATE*/
         pv_pmisa_vd_actual_date      DATE;
         Pv_pmisa_vd_from_year        number;
         Pv_pmisa_vd_to_year          number;
         Pv_pmisa_vd_from_period      pmi_gl_calendar_v.period_name%TYPE;
         Pv_pmisa_vd_to_period        pmi_gl_calendar_v.period_name%TYPE;
         pv_pmisa_vd_start_date       DATE;
         pv_pmisa_vd_end_date         DATE;
         pv_pmisa_vd_company          sy_orgn_mst.co_code%TYPE;

FUNCTION PMISA_VALIDATE_DATE(p_Sales_company   IN sy_orgn_mst.co_code%TYPE,
                             p_From_year       IN number,
                             p_To_year         IN number,
		                 p_From_period     IN pmi_gl_calendar_v.period_name%TYPE,
                             p_To_period       IN pmi_gl_calendar_v.period_name%TYPE,
                             P_Actual_date     IN DATE
                         )
RETURN NUMBER;

/* #############################################################################
   Function PMISA_GET_CHARGE
   This function is to get charges from given order line

   Inputs
         ORDER_ID
         LINE_ID
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
     4. In the table OP_ORDR_CHG, if LINE_ID is not NULL ( i.e. Charge specified for the Order Line ) then
        EXTENDED_AMOUNT will be deducted from the Extended price to calculate the net Revenue of the Order Line.
     5. In the table OP_ORDR_CHG, if LINE_ID is NULL ( i.e. Charge specified for the whole Order ) then calculate the
        charge for a particular order line using the formula (Extended Price of the order line / Total Order Value ) *
        EXTENDED_AMOUNT
     6. If No Charge is found the function returns 0

   ################################################################################# */

FUNCTION PMISA_GET_CHARGE  ( p_Order_id         IN op_ordr_dtl.order_id%TYPE,
                             p_line_id          IN op_ordr_dtl.line_id%TYPE,
                             p_extended_price   IN op_ordr_dtl.extended_price%TYPE,
                             p_Billing_Currency IN op_ordr_dtl.billing_currency%TYPE,
		                 p_Base_Currency    IN op_ordr_dtl.BASE_CURRENCY%TYPE,
                             p_exchange_Rate    IN op_ordr_dtl.EXCHANGE_RATE%TYPE,
                             p_mul_div_sign     IN op_ordr_dtl.mul_div_sign%TYPE
                            )
RETURN NUMBER;
/*
PMIOM_GET_CHARGE is the Order Management equivalent of PMISA_GET_CHARGE.  Instead of identifying charge_type on a charge line basis, there are pricing lists that have list_type_codes at the header (QP_LIST_HEADERS_B) and line (QP_LIST_LINES_ALL) levels.

At the header level, list_type_code has the following values:

       PRL = Price List
       DLT = Discount List
       SLT = Surcharge List
       PML = Price Modifier List
       DEL = Deal
       PRO = Promotion
       CHARGES = Freight and Special Charges List
       AGR = Agreement Price List

As per Price Table Mapping.doc, only DLT is considered the equivalent of a charge in Order Fulfillment.

At the line level, list_type_code has the following values:

       PLL = Price List Line
       PBH = Price Break Header
       DIS = Discount
       SUR = Surcharge
       PMR = Price Modifier
       OID = Other Item Discount
       PRG = Promotional Goods
       TSN = Terms Substitution
       IUE = Item Upgrade
       CIE = Coupon Issue
       FRIEND_CHARGE = Freight / Special Charge

As per Price Table Mapping.doc, only DIS is considered the equivalent of a charge in Order Fulfillment

*/
FUNCTION PMIOM_GET_CHARGE  ( p_header_id        IN oe_order_lines_all.header_id%TYPE,
                             p_line_id          IN oe_order_lines_all.line_id%TYPE,
                             p_extended_price   IN oe_order_lines_all.unit_selling_price%TYPE,
                             p_Billing_Currency IN oe_order_headers_all.transactional_curr_code%TYPE,
		                 p_Base_Currency    IN gl_sets_of_books.CURRENCY_CODE%TYPE,
                             p_exchange_Rate    IN oe_order_headers_all.CONVERSION_RATE%TYPE,
                             p_ordered_quantity IN oe_order_lines_all.ordered_quantity%TYPE
                            )
RETURN NUMBER;

END;

 

/
