--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_ACTIVITY" AS
/* $Header: FIIAPS4B.pls 120.7 2006/03/24 23:11:16 vkazhipu noship $ */

--vkazhipu added for performance repository tuning
--bug 4997442

g_date_string DATE;

  PROCEDURE get_inv_activity (
     p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
     inv_act_anal_sql        OUT NOCOPY VARCHAR2,
     inv_act_anal_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
                sqlstmt                 varchar2(14000);
		l_viewby_dim            VARCHAR2(240);  -- what is the viewby
                l_as_of_date            DATE;
                l_organization          VARCHAR2(240);
                l_supplier              VARCHAR2(240);
                l_currency              VARCHAR2(240);  -- random size, possibly high
                l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
                l_record_type_id        NUMBER;         --
                l_gid                   NUMBER;         -- 0,4 or 8
                l_viewby_string         VARCHAR2(240);
                inv_act_rec             BIS_QUERY_ATTRIBUTES;
                l_period_type           VARCHAR2(240);
                l_invoice_number        VARCHAR2(240);
                l_column_name           VARCHAR2(240);
                l_table_name            VARCHAR2(240);
 	        l_org_WHERE             VARCHAR2(240);
                l_supplier_WHERE        VARCHAR2(240);
 		l_url_1                 VARCHAR2(1000);
 		l_url_2                 VARCHAR2(1000);
 		l_url_3                 VARCHAR2(1000);
 BEGIN

   /*getting the parameters values by calling the util package*/
FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_WHERE,
       l_supplier_WHERE
       );

 IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
    l_url_1 := 'pFunctionName=FII_AP_INV_ACTIVITY&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_2 := 'pFunctionName=FII_AP_INV_ACTIVITY&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_3 := 'pFunctionName=FII_AP_INV_ACTIVITY&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
    l_url_1 := 'pFunctionName=FII_AP_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&FII_CURRENCIES=FII_CURRENCIES&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ENT_DTL';
    l_url_2 := 'pFunctionName=FII_AP_E_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&FII_CURRENCIES=FII_CURRENCIES&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
    l_url_3 := 'pFunctionName=FII_AP_MANUAL_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&FII_CURRENCIES=FII_CURRENCIES&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_MANUAL_INV_ENT_DTL';
END IF;

/*------------------------------------------------------------------------------------------------
|       VIEWBY						-Either Operating Unit or Supplier
|       VIEWBY_ID					-Either org_id/supplier_id
|	FII_ATTRIBUTE1 			 		 Graph Title
|	FII_ATTRIBUTE2 					 Graph Title
|	FII_ATTRIBUTE7 					 Column Spanning
|	FII_MEASURE1   					 Invoice_amt_entered
|	FII_MEASURE2   					 Prior Invoice_amt_entered
|	FII_MEASURE3					 Change
|	FII_MEASURE4   					 Invoice_count_entered
|	FII_MEASURE5					 Prior Invoice_count_entered
|	FII_MEASURE6					 Change
|	FII_MEASURE7                                     Distribution_count
|	FII_MEASURE8					 Prior Distribution_count
|	FII_MEASURE9    				 Change
|	FII_ATTRIBUTE8                                   COLUMN SPANNING
|	FII_MEASURE10					 Electronic Invoice Amount
|	FII_MEASURE11					 Prior Electronic Invoice Amount
|	FII_MEASURE12					 Change in electronic Invoice Amount
|	FII_MEASURE14					 Prior Electronic Invoice Count
|	FII_MEASURE23					 Prior Manual Invoice Count
|	FII_MEASURE13					 Electronic Invoice Count
|	FII_CAL1					 For legend
|	FII_MEASURE15					 Change in Invoice Count
|	FII_MEASURE16					 Number of Distributions
|	FII_MEASURE17  					 Prior Number of Distributions
|	FII_MEASURE18					 Change
|	FII_ATTRIBUTE10					 Column Spanning
|	FII_MEASURE19					 Manual Invoice Amount
|	FII_MEASURE20					 Prior Manual Invoice Amount
|	FII_MEASURE21					 Change
|	FII_MEASURE22					 Manual Number of Invoices
|	FII_CAL2					 Dummy variable for Legend
|	FII_MEASURE24					 Change in Manual Invoices
|	FII_MEASURE25					 Manual Distribution Count
|	FII_MEASURE26					 Prior Manual Distribution Count
|	FII_MEASURE27					 Change in Manual Distribution Count
|	FII_MEASURE28					 Grand Total(invoice amount entered)
|	FII_MEASURE29					 Grand Total(prior invoice amount)
|	FII_MEASURE30					 Grand Total(invoice count entered)
|	FII_DIM1					 Grand Total(prior invoice count entered)
|	FII_DIM2					 Grand Total(distribution count)
|	FII_DIM3 					 Grand Total(prior distribution count)
|	FII_DIM4 					 Grand Total(electronic invoice entered)
|	FII_DIM5 					 Grand Total(prior electronic invoice amount entered)
|	FII_DIM7 					 Grand Total(electronic invoice count)
|	FII_DIM8 					 Grand Total(prior electronic invoice count)
|	FII_DIM9   					 Grand Total(electronic distribution count)
|	FII_DIM10					 Grand Total(prior electronic distribution count)
|	FII_FSG_COL1					 Grand Total(manual amount entered)
|	FII_FSG_COL2					 Grand Total(prior manual amount entered)
|	FII_FSG_COL3					 Grand Total(manual invoice count)
|	FII_FSG_COL4					 Grand Total(prior manual invoice count)
|	FII_FSG_COL5					 Grand Total(manual distribution count)
|	FII_FSG_COL6					 Grand Total(prior distribution count)
|	FII_FSG_COL7					 Grand Total(Change Total Invoice Amt.)
|	FII_FSG_COL8					 Grand Total(Change No. of Invoices Entered)
|	FII_FSG_COL9					 Grand Total(Change no. of Distributions)
|	FII_FSG_COL10					 Grand Total(Change Electronic Invoice Amount)
|	FII_FSG_COL11					 Grand Total(Change No. of Elect. invoices Entered)
|	FII_FSG_COL12					 Grand Total(Change No. of Distributions)
|	FII_FSG_COL13					 Grand Total(Change Manual Invoice Amount)
|	FII_FSG_COL14					 Grand Total(Change No. of Manual Invoices)
|	FII_ATTRIBUTE3					 Grand Total(Change No. of Distributions)
|	FII_ATTRIBUTE11					 Drill across(FII_MEASURE4)
|	FII_ATTRIBUTE12					 Drill Dynamic(FII_MEASURE13)
|	FII_ATTRIBUTE13					 Drill Dynamic(FII_MEASURE22)
 ------------------------------------------------------------------------------------------------------------------*/


----constructing the sql statement


sqlstmt:= '
SELECT   viewby_dim.value 				   			     VIEWBY,
 	 viewby_dim.id 								     VIEWBYID,
	 f.FII_MEASURE1   						     FII_MEASURE1,
	 f.FII_MEASURE2     						     FII_MEASURE2,
	 f.FII_MEASURE4 						     FII_MEASURE4,
	 f.FII_MEASURE5					     			FII_MEASURE5,
	 f.FII_MEASURE7						     		FII_MEASURE7,
	 f.FII_MEASURE8						     		FII_MEASURE8,
	 f.FII_MEASURE10   				             		FII_MEASURE10,
	 f.FII_MEASURE11     				             		FII_MEASURE11,
 	 f.FII_MEASURE13			 				     FII_MEASURE13,
	 f.FII_MEASURE14						     FII_MEASURE14,
	 f.FII_MEASURE16						     FII_MEASURE16,
	 f.FII_MEASURE17				 	     		FII_MEASURE17,
	 f.FII_MEASURE19  		     					FII_MEASURE19,
	 f.FII_MEASURE20			     				FII_MEASURE20,
	 f.FII_MEASURE22 			     				FII_MEASURE22,
	 f.FII_MEASURE23 		     					FII_MEASURE23,
	 f.FII_MEASURE25 			     				FII_MEASURE25,
	 f.FII_MEASURE26	     						FII_MEASURE26,
	 f.FII_MEASURE28                           				FII_MEASURE28,
	 f.FII_MEASURE29                           				FII_MEASURE29,
	 f.FII_MEASURE30							FII_MEASURE30,
	 f.FII_DIM1                           					FII_DIM1,
	 f.FII_DIM2                           					FII_DIM2,
	 f.FII_DIM3								FII_DIM3,
	 f.FII_DIM4                           					FII_DIM4,
	 f.FII_DIM5                           					FII_DIM5,
	 f.FII_DIM7                           					FII_DIM7,
	 f.FII_DIM8                           					FII_DIM8,
	 f.FII_DIM9                           					FII_DIM9,
	 f.FII_DIM10                           					FII_DIM10,
	 f.FII_FSG_COL1 							FII_FSG_COL1,
	 f.FII_FSG_COL2								 FII_FSG_COL2,
	 f.FII_FSG_COL3 							FII_FSG_COL3,
	 f.FII_FSG_COL4 							FII_FSG_COL4,
	 f.FII_FSG_COL5 							FII_FSG_COL5,
	 f.FII_FSG_COL6 							FII_FSG_COL6,
         '''||l_url_1||'''                                                       FII_ATTRIBUTE11,
         '''||l_url_2||'''                                                       FII_ATTRIBUTE12,
         '''||l_url_3||'''                                                       FII_ATTRIBUTE13
FROM
(SELECT
 	 id,
	 FII_MEASURE1,
	 FII_MEASURE2,
	 FII_MEASURE4,
	 FII_MEASURE5,
	 FII_MEASURE7,
	 FII_MEASURE8,
	 FII_MEASURE10,
	 FII_MEASURE11,
 	 FII_MEASURE13,
	 FII_MEASURE14,
	 FII_MEASURE16,
	 FII_MEASURE17,
	 FII_MEASURE19,
	 FII_MEASURE20,
	 FII_MEASURE22,
	 FII_MEASURE23,
	 FII_MEASURE25,
	 FII_MEASURE26,
	 SUM(FII_MEASURE1)          OVER()                           FII_MEASURE28,
	 SUM(FII_MEASURE2)          OVER()                           FII_MEASURE29,
	 SUM(FII_MEASURE4)          OVER()                           FII_MEASURE30,
	 SUM(FII_MEASURE5)          OVER()                           FII_DIM1,
	 SUM(FII_MEASURE7)          OVER()                           FII_DIM2,
	 SUM(FII_MEASURE8)          OVER()                           FII_DIM3,
	 SUM(FII_MEASURE10)         OVER()                           FII_DIM4,
	 SUM(FII_MEASURE11)         OVER()                           FII_DIM5,
	 SUM(FII_MEASURE13)         OVER()                           FII_DIM7,
	 SUM(FII_MEASURE14)    	    OVER()                           FII_DIM8,
	 SUM(FII_MEASURE16)         OVER()                           FII_DIM9,
	 SUM(FII_MEASURE17)         OVER()                           FII_DIM10,
	 SUM(FII_MEASURE19)         OVER() 		        	FII_FSG_COL1,
	 SUM(FII_MEASURE20)         OVER() 				FII_FSG_COL2,
	 SUM(FII_MEASURE22)         OVER() 				FII_FSG_COL3,
	 SUM(FII_MEASURE23)         OVER() 				FII_FSG_COL4,
	 SUM(FII_MEASURE25)         OVER() 				FII_FSG_COL5,
	 SUM(FII_MEASURE26)         OVER() 				FII_FSG_COL6,
         ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
FROM
   (
   SELECT f.'||l_viewby_id||' id,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	      THEN f.invoice_amt_entered'||l_currency||' ELSE 0 END)             FII_MEASURE1,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
      	      THEN f.invoice_amt_entered'||l_currency||' ELSE 0 END)    	 FII_MEASURE2,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	      THEN f.invoice_count_entered ELSE 0 END) 			         FII_MEASURE4,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	      THEN f.invoice_count_entered ELSE 0 END) 		                 FII_MEASURE5,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
              THEN f.e_invoice_count ELSE 0 END) 		                 FII_MEASURE13,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	      THEN f.e_invoice_count ELSE 0 END) 		                 FII_MEASURE14,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	      THEN f.distribution_count ELSE 0 END) 		                 FII_MEASURE7,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	      THEN f.distribution_count ELSE 0 END) 		                 FII_MEASURE8,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	      THEN f.e_distribution_count ELSE 0 END) 		                 FII_MEASURE16,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	      THEN f.e_distribution_count ELSE 0 END)  		                 FII_MEASURE17,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
              THEN f.e_invoice_amt'||l_currency||' ELSE 0 END)                   FII_MEASURE10,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
  	      THEN f.e_invoice_amt'||l_currency||' ELSE 0 END)                   FII_MEASURE11,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.invoice_amt_entered'||l_currency||' -  f.e_invoice_amt'||l_currency||'
                       ELSE 0 END)						 FII_MEASURE19,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	  THEN f.invoice_amt_entered'||l_currency||' -  f.e_invoice_amt'||l_currency||'
                         ELSE 0 END)						 FII_MEASURE20,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	 THEN f.invoice_count_entered - f.e_invoice_count  ELSE 0 END)		     FII_MEASURE22,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	 THEN f.invoice_count_entered - f.e_invoice_count  ELSE 0 END)		     FII_MEASURE23,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	 THEN f.distribution_count - f.e_distribution_count  ELSE 0 END) 	  FII_MEASURE25,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	 THEN f.distribution_count - f.e_distribution_count  ELSE 0 END)	     FII_MEASURE26
   FROM  FII_AP_IVATY_XB_MV f,
      	 fii_time_structures cal
   WHERE f.time_id = cal.time_id
   AND   f.period_type_id = cal.period_type_id
         '||l_org_WHERE||l_supplier_WHERE||'
   AND   bitAND(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
   AND   f.gid = :GID
   GROUP BY f.'||l_viewby_id||')) f,
 ('||l_viewby_string||') viewby_dim
 WHERE f.id = viewby_dim.id
 and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
 &ORDER_BY_CLAUSE';

 /*Section for binding the variables*/

FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>inv_act_anal_sql,
       p_bind_output_table=>inv_act_anal_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );


  END get_inv_activity;






PROCEDURE get_inv_type (
     p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
     inv_type_sql        OUT NOCOPY VARCHAR2,
     inv_type_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
                sqlstmt                 varchar2(14000);
		l_num                   NUMBER;
		l_viewby_dim            VARCHAR2(240);  -- what is the viewby
                l_as_of_date            DATE;
                l_organization          VARCHAR2(240);
                l_supplier              VARCHAR2(240);
                l_currency              VARCHAR2(240);  -- rANDom size, possibly high
                l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
                l_record_type_id        NUMBER;         --
                l_gid                   NUMBER;         -- 0,4 or 8
                l_viewby_string         VARCHAR2(240);
                inv_type_rec            BIS_QUERY_ATTRIBUTES;
                l_param_join            VARCHAR2(240);
                l_param_join_ou         VARCHAR2(240);
                l_curr_info             VARCHAR2(240);
                l_curr_suffix           VARCHAR2(240);
                l_prim_curr             VARCHAR2(240);
                l_sec_curr              VARCHAR2(240);
                l_period_type           VARCHAR2(240);
                l_invoice_number        VARCHAR2(240);
                l_column_name           VARCHAR2(240);
                l_table_name            VARCHAR2(240);
 	        l_org_WHERE             VARCHAR2(240);
                l_supplier_WHERE        VARCHAR2(240);
                l_url_1                 VARCHAR2(1000);
                l_url_2                 VARCHAR2(1000);
                l_url_3                 VARCHAR2(1000);
                l_url_4                 VARCHAR2(1000);
                l_url_5                 VARCHAR2(1000);
                l_url_6                 VARCHAR2(1000);
                l_url_7                 VARCHAR2(1000);
                l_url_8                 VARCHAR2(1000);


 BEGIN

   /*getting the parameters values FROM the page parameter table*/
FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_WHERE,
       l_supplier_WHERE
       );
   IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
   l_url_1 := 'pFunctionName=FII_AP_INV_TYPE&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_url_2 := '';
   l_url_3 := '';
   l_url_4 := '';
   l_url_5 := '';
   l_url_6 := '';
   l_url_7 := '';
   l_url_8 := '';
ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
   l_url_1 := 'pFunctionName=FII_AP_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ENT_DTL';
   l_url_2 := 'pFunctionName=FII_AP_STANDARD_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_STANDARD_INV_ENT_DTL';
   l_url_3 := 'pFunctionName=FII_AP_WITHHOLDING_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_WITHHOLDING_INV_ENT_DTL';
   l_url_4 := 'pFunctionName=FII_AP_PREPAYMENT_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_PREPAYMENT_INV_ENT_DTL';
   l_url_5 := 'pFunctionName=FII_AP_CREDIT_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_CREDIT_INV_ENT_DTL';
   l_url_6 := 'pFunctionName=FII_AP_DEBIT_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_DEBIT_INV_ENT_DTL';
   l_url_7 := 'pFunctionName=FII_AP_MIXED_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_MIXED_INV_ENT_DTL';
   l_url_8 := 'pFunctionName=FII_AP_INTEREST_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INTEREST_INV_ENT_DTL';
END IF;


/*--------------------------------------------------------------
|	VIEWBY                  Either Supplier or Operating Unit
|	VIEWBY_ID               Either supplier_id/org_id
|	FII_MEASURE1		Invoice Amount
|	FII_MEASURE2		Prior Invoice Amount
|	FII_MEASURE3		Change
|	FII_MEASURE4		Invoices Entered
|	FII_MEASURE5		Prior Invoices Entered
|	FII_MEASURE6		Change
|	FII_MEASURE7		Standard
|	FII_MEASURE8		Withholding
|	FII_MEASURE9		Prepayment
|	FII_MEASURE10		Credit
|	FII_MEASURE11		Debit
|	FII_MEASURE12		Mixed
|	FII_MEASURE13		Interest
|	FII_MEASURE15		Grand Total(invoice amount entered)
|	FII_MEASURE16		Grand Total(prior invoice amount entered)
|	FII_MEASURE17		Grand Total(invoice count entered)
|	FII_MEASURE18		Grand Total(prior invoice count entered)
|	FII_MEASURE19		Grand Total(standard)
|	FII_MEASURE20		Grand Total(withholding)
|	FII_MEASURE21		Grand Total(prepayment)
|	FII_MEASURE22		Grand Total(credit)
|	FII_MEASURE23		Grand Total(debit)
|	FII_MEASURE24		Grand Total(mixed)
|	FII_MEASURE25		Grand Total(interest)
|	FII_DIM1		Grand Total(Invoice Amount Change)
|	FII_DIM2		Grand Total(Invoice Count change)
|	FII_ATTRIBUTE5		Dynamic Drill (FII_MEASURE4)
|	FII_ATTRIBUTE 6		Dynamic Drill (FII_MEASURE7)
|	FII_ATTRIBUTE 7		Dynamic Drill (FII_MEASURE8)
|	FII_ATTRIBUTE 8		Dynamic Drill (FII_MEASURE9)
|	FII_ATTRIBUTE 10	Dynamic Drill (FII_MEASURE10)
|	FII_ATTRIBUTE11		Dynamic Drill (FII_MEASURE11)
|	FII_ATTRIBUTE 12	Dynamic Drill (FII_MEASURE12)
|	FII_ATTRIBUTE 13	Dynamic Drill (FII_MEASURE13)
---------------------------------------------------------------------------*/


----constructing the sql statement

sqlstmt:= '
select viewby_dim.value 				    VIEWBY,
    viewby_dim.id 					    VIEWBYID,
    f.FII_MEASURE1   					    FII_MEASURE1,
    f.FII_MEASURE2     					    FII_MEASURE2,
    f.FII_MEASURE4 					    FII_MEASURE4,
    f.FII_MEASURE5					    FII_MEASURE5,
    f.FII_MEASURE7					    FII_MEASURE7,
    f.FII_MEASURE8					    FII_MEASURE8,
    f.FII_MEASURE9					    FII_MEASURE9,
    f.FII_MEASURE10					    FII_MEASURE10,
    f.FII_MEASURE11					    FII_MEASURE11,
    f.FII_MEASURE12					    FII_MEASURE12,
    f.FII_MEASURE13					    FII_MEASURE13,
    f.FII_MEASURE15            				        FII_MEASURE15,
    f.FII_MEASURE16                    			  FII_MEASURE16,
    f.FII_MEASURE17               			  FII_MEASURE17,
    f.FII_MEASURE18           				 FII_MEASURE18,
    f.FII_MEASURE19                              	 FII_MEASURE19,
    f.FII_MEASURE20                         		   FII_MEASURE20,
    f.FII_MEASURE21                            		FII_MEASURE21,
    f.FII_MEASURE22                                 	FII_MEASURE22,
    f.FII_MEASURE23                                  	FII_MEASURE23,
    f.FII_MEASURE24					FII_MEASURE24,
    f.FII_MEASURE25                               		FII_MEASURE25,
    '''||l_url_1||'''                                       FII_ATTRIBUTE5,
    '''||l_url_2||'''                                       FII_ATTRIBUTE6,
    '''||l_url_3||'''                                       FII_ATTRIBUTE7,
    '''||l_url_4||'''                                       FII_ATTRIBUTE8,
    '''||l_url_5||'''                                       FII_ATTRIBUTE10,
    '''||l_url_6||'''                                       FII_ATTRIBUTE11,
    '''||l_url_7||'''                                       FII_ATTRIBUTE12,
    '''||l_url_8||'''                                       FII_ATTRIBUTE13

 FROM
(select
    id,
    FII_MEASURE1,
    FII_MEASURE2,
    FII_MEASURE4,
    FII_MEASURE5,
    FII_MEASURE7,
    FII_MEASURE8,
    FII_MEASURE9,
    FII_MEASURE10,
    FII_MEASURE11,
    FII_MEASURE12,
    FII_MEASURE13,
    SUM(FII_MEASURE1) over()                    	FII_MEASURE15,
    SUM(FII_MEASURE2) over()                      	FII_MEASURE16,
    SUM(FII_MEASURE4) over()                 		FII_MEASURE17,
    SUM(FII_MEASURE5) over()            		FII_MEASURE18,
    SUM(FII_MEASURE7) over()                            FII_MEASURE19,
    SUM(FII_MEASURE8) over()                            FII_MEASURE20,
    SUM(FII_MEASURE9) over()                            FII_MEASURE21,
    SUM(FII_MEASURE10) over()                           FII_MEASURE22,
    SUM(FII_MEASURE11) over()                           FII_MEASURE23,
    SUM(FII_MEASURE12) over()                           FII_MEASURE24,
    SUM(FII_MEASURE13) over()                           FII_MEASURE25,
   ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
 FROM
 (SELECT f.'||l_viewby_id||' id,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	     THEN f.invoice_amt_entered'||l_currency||' ELSE 0 END)      FII_MEASURE1,
    SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
  	     THEN f.invoice_amt_entered'||l_currency||' ELSE 0 END)      FII_MEASURE2,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	    THEN f.invoice_count_entered ELSE 0 END) 	    	         FII_MEASURE4,
    SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	     THEN f.invoice_count_entered ELSE 0 END) 	                 FII_MEASURE5,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	     THEN f.stANDard_count ELSE 0 END) 		                 FII_MEASURE7,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	     THEN f.withholding_count ELSE 0 END) 			 FII_MEASURE8,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	     THEN f.prepayment_count ELSE 0 END) 			 FII_MEASURE9,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	     THEN f.credit_count ELSE 0 END) 		                 FII_MEASURE10,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	     THEN f.debit_count ELSE 0 END) 		                 FII_MEASURE11,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	     THEN f.mixed_count ELSE 0 END) 		                 FII_MEASURE12,
    SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
             THEN f.interest_count ELSE 0 END) 		                 FII_MEASURE13
   FROM  FII_AP_IVATY_XB_MV f,
         fii_time_structures cal
   WHERE f.time_id = cal.time_id
   AND   f.period_type_id = cal.period_type_id
         '||l_org_WHERE||l_supplier_WHERE||'
   AND   bitAND(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
   AND   f.gid = :GID
   GROUP BY f.'||l_viewby_id||')) f,
 ('||l_viewby_string||') viewby_dim
 WHERE f.id = viewby_dim.id
 and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
 &ORDER_BY_CLAUSE';

 /*Section for binding the variables*/

FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>inv_type_sql,
       p_bind_output_table=>inv_type_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );

  END get_inv_type;



  /* -  Electronic Invoice Analysis
      - Procedure get_electronic_inv         */


PROCEDURE get_electronic_inv (
     p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
     elec_inv_sql            OUT NOCOPY VARCHAR2,
     elec_inv_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
                sqlstmt                 varchar2(14000);
		l_num                   NUMBER;
		l_viewby_dim            VARCHAR2(240);  -- what is the viewby
                l_as_of_date            DATE;
                l_organization          VARCHAR2(240);
                l_supplier              VARCHAR2(240);
                l_currency              VARCHAR2(240);  -- random size, possibly high
                l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
                l_record_type_id        NUMBER;         --
                l_gid                   NUMBER;         -- 0,4 or 8
                l_viewby_string         VARCHAR2(240);
                elec_inv_rec            BIS_QUERY_ATTRIBUTES;
                l_param_join            VARCHAR2(240);
                l_param_join_ou         VARCHAR2(240);
                l_curr_info             VARCHAR2(240);
                l_curr_suffix           VARCHAR2(240);
                l_prim_curr             VARCHAR2(240);
                l_sec_curr              VARCHAR2(240);
                l_period_type           VARCHAR2(240);
                l_invoice_number        VARCHAR2(240);
                l_column_name           VARCHAR2(240);
                l_table_name            VARCHAR2(240);
 	        l_org_where             VARCHAR2(240);
                l_supplier_where        VARCHAR2(240);
 		l_url_1                 VARCHAR2(1000);
                l_url_2                 VARCHAR2(1000);
                l_url_3                 VARCHAR2(1000);
                l_url_4                 VARCHAR2(1000);
                l_url_5                 VARCHAR2(1000);
                l_url_6                 VARCHAR2(1000);
                l_url_7                 VARCHAR2(1000);
                l_url_8			VARCHAR2(1000);


 BEGIN

   /*getting the parameters values FROM the page parameter table*/
FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_where,
       l_supplier_where
       );

/* Bug:3036059- Added a URL to l_url_1 for drill on 'Invoices Entered' column when viewed by Operating Unit. */

IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
   l_url_1 := 'pFunctionName=FII_AP_ELECTRONIC_INV&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_url_2 := '';
   l_url_3 := '';
   l_url_4 := '';
   l_url_5 := '';
   l_url_6 := '';
   l_url_7 := '';
   l_url_8 := '';

ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
   l_url_1 :='pFunctionName=FII_AP_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ENT_DTL';
   l_url_2 := 'pFunctionName=FII_AP_XML_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_XML_INV_ENT_DTL';
   l_url_3:= 'pFunctionName=FII_AP_EDI_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_EDI_INV_ENT_DTL';
   l_url_4 :='pFunctionName=FII_AP_ERS_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_ERS_INV_ENT_DTL';
   l_url_5:='pFunctionName=FII_AP_ISP_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_ISP_INV_ENT_DTL';
   l_url_6:= 'pFunctionName=FII_AP_ASBN_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_ASBN_INV_ENT_DTL';
   l_url_7:= 'pFunctionName=FII_AP_OTHER_SRC_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_OTHER_SRC_INV_ENT_DTL';
   l_url_8:= 'pFunctionName=FII_AP_E_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';

END IF;


  /*-------------------------------------------------------------------------------------------------
 |	VIEWBY						Either Operating Unit or Supplier
 |	VIEWBY_ID  					Either Org_id/supplier_id
 |	FII_ATTRIBUTE1					Graph title
 |	FII_ATTRIBUTE2					Graph title
 |	FII_ATTRIBUTE6					Column Spanning
 | 	FII_MEASURE1					Amount
 |	FII_MEASURE2	                        	Invoices
 |	FII_MEASURE3					Prior Total Invoices Entered
 |	FII_MEASURE4					Percent Electronic
 |	FII_MEASURE5					Prior % Electronic Invoices
 |	FII_MEASURE6					Change (fiimeasure4-fii_measure5)
 |	FII_MEASURE7					Electronic Invoices Amount
 |	FII_MEASURE8					Prior Electronic Invoices Amount
 |	FII_MEASURE9					Change in electronic invoice amount
 |	FII_MEASURE11					Prior Electronic Invoice Count
 |	FII_MEASURE14					Prior Manual Invoice Count
 |	FII_MEASURE10					Electronic Invoices Entered
 |	FII_CAL1					Dummy column for Legend
 |	FII_MEASURE13					Manual Invoice Count
 |	FII_MEASURE12					Change In electronic invoices entered
 |	FII_MEASURE15					XML
 |	FII_MEASURE16					EDI
 |	FII_MEASURE17					ERS
 |	FII_MEASURE18					ISP
 | 	FII_MEASURE19					ASBN
 |	FII_MEASURE20					Other Integrated
 |	FII_MEASURE23					Grand Total(invoice amt entered)
 |	FII_MEASURE24					Grand Total(invoice count entered)
 |	FII_MEASURE25					Grand Total(prior invoice entered count)
 |	FII_MEASURE26					Grand Total(elec invoice amt entered)
 |	FII_MEASURE27					Grand Total(elec prior invoice amt entered)
 |	FII_MEASURE28					Grand Total(e_invoice _count)
 |	FII_MEASURE29					Grand Total(prior e_invoice_count)
 |	FII_MEASURE30					Grand Total(xml)
 |	FII_DIM1					Grand Total(edi)
 |	FII_DIM2					Grand Total(ers)
 |	FII_DIM3					Grand Total(isp)
 |	FII_DIM4					Grand Total(asbn)
 |	FII_DIM5					Grand Total(others)
 |	FII_DIM7					Grand Total(% electronic invoices entered)
 | 	FII_DIM8					Grand Total(% prior electronic invoices entered)
 |	FII_DIM9					Change(electronic invoice amt)
 | 	FII_DIM10					Change (electroninic invoice entered)
 |	FII_ATTRIBUTE3					Drill (Total Invoices Entered)
 |	FII_ATTRIBUTE12					Drill(Electronic Invoices Entered)
 |	FII_ATTRIBUTE4					Drill (XML)
 |	FII_ATTRIBUTE5					Drill (EDI)
 |	FII_ATTRIBUTE7					Drill (ERS)
 |	FII_ATTRIBUTE8					Drill (ISP)
 |	FII_ATTRIBUTE10					Drill (ASBN)
 |	FII_ATTRIBUTE11					Drill (Other Integrated)
 |	FII_ATTRIBUTE13					Change % for Number of Invoices(For Custom View)
 |	FII_ATTRIBUTE14					Grand Total for Change(For Custom View)
 |	FII_KPI1					Invoices Entered
 |	FII_KPI2			 		Hidden column Electronic Invoices
 |	FII_CV1						Amount (For Custom View Implementation)
 |	FII_CV2						Entered(For Custom View Implementation)
 |	FII_CV3						Change(For Custom View Implementation)
 |	FII_CV4						Electronic(For Custom View Implementation)
 ------------------------------------------------------------------------------------------------------------*/


----constructing the sql statement

sqlstmt:= '
SELECT viewby_dim.value 				    	VIEWBY,
    viewby_dim.id 					    	VIEWBYID,
    SUM(f.FII_MEASURE1)   				    	FII_MEASURE1,
    SUM(f.FII_MEASURE2) 				    	FII_MEASURE2,
    SUM(f.FII_MEASURE3)			    	FII_MEASURE3,
    SUM(f.FII_MEASURE7)   			    	FII_MEASURE7,
    SUM(f.FII_MEASURE8)   			    	FII_MEASURE8,
    SUM(f.FII_MEASURE10)     		        	    	FII_MEASURE10,
    SUM(f.FII_MEASURE11)			 	    	FII_MEASURE11,
    SUM(f.FII_MEASURE15)                         			    	FII_MEASURE15,
    SUM(f.FII_MEASURE16)                         			    	FII_MEASURE16,
    SUM(f.FII_MEASURE17)                         			    	FII_MEASURE17,
    SUM(f.FII_MEASURE18)                         			    	FII_MEASURE18,
    SUM(f.FII_MEASURE19)                         			    	FII_MEASURE19,
    SUM(f.FII_MEASURE20)                        			     	FII_MEASURE20,
    SUM(f.FII_MEASURE23)                                 FII_MEASURE23,
    SUM(f.FII_MEASURE24)                                 FII_MEASURE24,
    SUM(f.FII_MEASURE25)                                 FII_MEASURE25,
    SUM(f.FII_MEASURE26)                                	FII_MEASURE26,
    SUM(f.FII_MEASURE27)                                	FII_MEASURE27,
    SUM(f.FII_MEASURE28)                                	FII_MEASURE28,
    SUM(f.FII_MEASURE29)                                	FII_MEASURE29,
    SUM(f.FII_MEASURE30)                                	FII_MEASURE30,
    SUM(f.FII_DIM1)                                     	FII_DIM1,
    SUM(f.FII_DIM2)                                     	FII_DIM2,
    SUM(f.FII_DIM3)                                     	FII_DIM3,
    SUM(f.FII_DIM4)                                     	FII_DIM4,
    SUM(f.FII_DIM5)  	                                  	FII_DIM5,
    '''||l_url_1||'''                                           FII_ATTRIBUTE3,
    '''||l_url_2||'''                                           FII_ATTRIBUTE4,
    '''||l_url_3||'''                                           FII_ATTRIBUTE5,
    '''||l_url_4||'''                                           FII_ATTRIBUTE7,
    '''||l_url_5||'''                                           FII_ATTRIBUTE8,
    '''||l_url_6||'''                                           FII_ATTRIBUTE10,
    '''||l_url_7||'''                                           FII_ATTRIBUTE11,
    '''||l_url_8||'''                                           FII_ATTRIBUTE12,
    SUM(f.FII_CV5)                                                FII_CV5
 FROM
 (SELECT id ID,
    FII_MEASURE1   				    	FII_MEASURE1,
    FII_MEASURE2 				    	FII_MEASURE2,
    FII_MEASURE3			    	FII_MEASURE3,
    FII_MEASURE7   			    	FII_MEASURE7,
    FII_MEASURE8   			    	FII_MEASURE8,
    FII_MEASURE10     		        	    	FII_MEASURE10,
    FII_MEASURE11			 	    	FII_MEASURE11,
    FII_MEASURE15                         			    	FII_MEASURE15,
    FII_MEASURE16                         			    	FII_MEASURE16,
    FII_MEASURE17                         			    	FII_MEASURE17,
    FII_MEASURE18                         			    	FII_MEASURE18,
    FII_MEASURE19                         			    	FII_MEASURE19,
    FII_MEASURE20                        			    	FII_MEASURE20,
    SUM(FII_MEASURE1)                   OVER() 	FII_MEASURE23,
    SUM(FII_MEASURE2)                 OVER() 	FII_MEASURE24,
    SUM(FII_MEASURE3)           OVER() 	FII_MEASURE25,
    SUM(FII_MEASURE7) 	 	    OVER() 	FII_MEASURE26,
    SUM(FII_MEASURE8) 		    OVER() 	FII_MEASURE27,
    SUM(FII_MEASURE10) 		            OVER() 	FII_MEASURE28,
    SUM(FII_MEASURE11) 		    OVER() 	FII_MEASURE29,
    SUM(FII_MEASURE15)                                   OVER() 	FII_MEASURE30,
    SUM(FII_MEASURE16)  				    OVER()  	FII_DIM1,
    SUM(FII_MEASURE17)  				    OVER()  	FII_DIM2,
    SUM(FII_MEASURE18)  				    OVER()  	FII_DIM3,
    SUM(FII_MEASURE19)  				    OVER()  	FII_DIM4,
    SUM(FII_MEASURE20)  				    OVER()  	FII_DIM5,
    ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk,
    (DECODE(SUM(nvl(FII_MEASURE2,0)) over(),0,null,
    DECODE(SUM(nvl(FII_MEASURE10,0)) over(),0,0,
    SUM(nvl(FII_MEASURE10,0)) over() / SUM(nvl(FII_MEASURE2,0)) over()))*100) -

    (DECODE(SUM(nvl(FII_MEASURE3,0)) over(),0,null,
    DECODE(SUM(nvl(FII_MEASURE11,0)) over(),0,0,
    SUM(nvl(FII_MEASURE11,0)) over()/ SUM(nvl(FII_MEASURE3,0)) over()))*100) FII_CV5 /* Changes made for Bug 3110651 */
 FROM
   (SELECT f.'||l_viewby_id||' id,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	  THEN f.invoice_amt_entered'||l_currency||' ELSE 0 END)     FII_MEASURE1,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.invoice_count_entered ELSE 0 END) 	             FII_MEASURE2,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
 	  THEN f.invoice_count_entered ELSE 0 END) 	             FII_MEASURE3,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	  THEN f.e_invoice_amt'||l_currency||' ELSE 0 END)           FII_MEASURE7,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
  	  THEN f.e_invoice_amt'||l_currency||' ELSE 0 END)           FII_MEASURE8,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.e_invoice_count ELSE 0 END) 	                     FII_MEASURE10,
     SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	  THEN f.e_invoice_count ELSE 0 END) 	                     FII_MEASURE11,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.xml_count ELSE 0 END) 		                     FII_MEASURE15,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.edi_count ELSE 0 END) 			             FII_MEASURE16,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.ers_count ELSE 0 END) 			             FII_MEASURE17,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.isp_count ELSE 0 END) 			             FII_MEASURE18,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.asbn_count ELSE 0 END) 			     FII_MEASURE19,
     SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
	  THEN f.other_integrated_count ELSE 0 END) 		     FII_MEASURE20
    FROM  FII_AP_IVATY_XB_MV f,
          fii_time_structures cal
    WHERE f.time_id = cal.time_id
    AND   f.period_type_id = cal.period_type_id
          '||l_org_where||l_supplier_where||'
    AND   bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
    AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
    AND   f.gid = :GID
    GROUP by f.'||l_viewby_id||')) f,
          ('||l_viewby_string||') viewby_dim
    WHERE f.id = viewby_dim.id
    and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
    GROUP BY viewby_dim.value,viewby_dim.id
    &ORDER_BY_CLAUSE';

 /*Section for binding the variables*/

FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>elec_inv_sql,
       p_bind_output_table=>elec_inv_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );

  END get_electronic_inv;



/* Holds Activity
        Procedure get_hold_activity     */



PROCEDURE get_hold_activity (
     p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
     get_hold_sql            OUT NOCOPY VARCHAR2,
     get_hold_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
                sqlstmt                 varchar2(14000);
		l_num                   NUMBER;
		l_viewby_dim            VARCHAR2(240);  -- what is the viewby
                l_as_of_date            DATE;
                l_organization          VARCHAR2(240);
                l_supplier              VARCHAR2(240);
                l_currency              VARCHAR2(240);  -- rANDom size, possibly high
                l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
                l_record_type_id        NUMBER;         --
                l_gid                   NUMBER;         -- 0,4 or 8
                l_viewby_string         VARCHAR2(240);
                get_hold_rec            BIS_QUERY_ATTRIBUTES;
                l_param_join            VARCHAR2(240);
                l_param_join_ou         VARCHAR2(240);
                l_curr_info             VARCHAR2(240);
                l_curr_suffix           VARCHAR2(240);
                l_prim_curr             VARCHAR2(240);
                l_sec_curr              VARCHAR2(240);
                l_period_type           VARCHAR2(240);
                l_invoice_number        VARCHAR2(240);
                l_column_name           VARCHAR2(240);
                l_table_name            VARCHAR2(240);
 	        l_org_where             VARCHAR2(240);
                l_supplier_where        VARCHAR2(240);
		l_period_suffix         VARCHAR2(240);
                l_url_1                 VARCHAR2(1000);

 BEGIN

   /*getting the parameters values FROM the page parameter table*/
FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_where,
       l_supplier_where
       );

    l_period_suffix:=FII_PMV_UTIL.get_period_type_suffix(l_period_type);

IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
   l_url_1 := 'pFunctionName=FII_AP_HOLD_ACTIVITY&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
   l_url_1 := 'pFunctionName=FII_AP_INV_HOLD_ACTIVITY_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_HOLD_ACTIVITY_DTL';

END IF;



/*------------------------------------------------------------------------
 |	VIEWBY			-Either supplier or operating unit
 |	VIEWBY_ID		-Either supplier_id or org_id
 |	FII_ATTRIBUTE6		Graph Title
 |	FII_MEASURE1		Invoices Placed on Hold Amount
 |	FII_MEASURE2		Prior Invoices Placed on Hold Amount
 |	FII_MEASURE3		Change
 |	FII_MEASURE4		Number of Invoices
 |	FII_MEASURE5		Prior Invoices Placed on Hold
 |	FII_MEASURE6		Change
 |	FII_MEASURE7		Total Number of Days on Hold
 |	FII_MEASURE8		Prior Total Number of Days on Hold
 |	FII_MEASURE9		Average Days on Hold
 |	FII_MEASURE10		Prior Average Days on Hold
 |	FII_MEASURE11		Change
 |	FII_MEASURE12		Number of Holds Placed
 |	FII_MEASURE13		Prior Number of Holds Placed
 |	FII_MEASURE14		Change
 |	FII_MEASURE15		Variance Holds
 |	FII_MEASURE16		% Variance
 |	FII_MEASURE17		PO Matching Holds
 |	FII_MEASURE18   	% PO Matching
 |	FII_MEASURE19		Invoice Holds
 |	FII_MEASURE20		% Invoice
 | 	FII_MEASURE21		User Defined Holds
 |	FII_MEASURE22		% User Defined
 |	FII_MEASURE23		Other Holds
 |	FII_MEASURE24		% Other
 |	FII_MEASURE25		Grand Total(invoice on hold amt)
 |	FII_MEASURE26		Grand Total(prior invoice on hold amt)
 |	FII_MEASURE27		Grand Total(prior invoice on hold amt)
 |	FII_MEASURE28		Grand Total(prior invoice on hold count)
 |	FII_MEASURE29		Grand Total(invoice days on hold)
 |	FII_MEASURE30		Grand Total(prior invoice days on hold)
 |	FII_DIM1		Grand Total(no of holds placed)
 |	FII_DIM2		Grand Total(prior no of holds placed)
 |	FII_DIM3		Grand Total(variance hold count)
 |	FII_DIM4		Grand Total(PO Matching Holds)
 |	FII_DIM5		Grand Total(User Defined Holds)
 |	FII_DIM7		Grand Total(Other Holds)
 |	FII_DIM8		Grand Total(Invoice Holds)
 |	FII_DIM9		Grand Total(Change Inv placed on Hold amt)
 |	FII_DIM10		Grand Total(Change Inv Placed on Hold)
 |	FII_FSG_COL1		Grand Total(Average days on Hold)
 |	FII_FSG_COL2		Grand Total(Prior Average days on Hold)
 |	FII_FSG_COL3		Grand Total(Change Days on Hold)
 |	FII_FSG_COL4		Grand Total(Change no. of Holds Placed)
 |	FII_FSG_COL5		Grand Total(% Invoice)
 |	FII_FSG_COL6		Grand Total(% User Defined)
 |	FII_FSG_COL7		Grand Total(% Other Holds)
 |	FII_FSG_COL8		Grand Total(% PO Matching)
 |	FII_FSG_COL9		Grand Total(% Variance)
 |	FII_ATTRIBUTE14		Drill (No. of Invoices)
 |	FII_CV1			Amount(Custom View Implementation)
 |	FII_CV2			Number of Invoices(Custom View Implementation)
 |	FII_CV3			Change(Custom View Implementation)
 | 	FII_CV4			PO Matching Holds(Custom View Implementation)
 |	FII_CV5			Days on Hold (Custom View Implementation)
  ----------------------------------------------------------------------------------*/


----constructing the sql statement

sqlstmt:= '
SELECT viewby_dim.value 	VIEWBY,
      viewby_dim.id 					VIEWBYID,
    		SUM(FII_MEASURE1)	 FII_MEASURE1,
    		SUM(FII_MEASURE2) 	FII_MEASURE2,
    		SUM(FII_MEASURE4)		FII_MEASURE4,
    		SUM(FII_MEASURE5)  FII_MEASURE5,
    		SUM(FII_MEASURE7)  FII_MEASURE7,
    		SUM(FII_MEASURE8)		FII_MEASURE8,
    		SUM(FII_MEASURE12) FII_MEASURE12,
    		SUM(FII_MEASURE13) FII_MEASURE13,
    		SUM(FII_MEASURE15) FII_MEASURE15,
    		SUM(FII_MEASURE17) FII_MEASURE17,
    		SUM(FII_MEASURE19) FII_MEASURE19,
    		SUM(FII_MEASURE21) FII_MEASURE21,
    		SUM(FII_MEASURE23) FII_MEASURE23,
     	SUM(FII_MEASURE25) FII_MEASURE25,
    		SUM(FII_MEASURE26)	FII_MEASURE26,
    		SUM(FII_MEASURE27) FII_MEASURE27,
    		SUM(FII_MEASURE28) FII_MEASURE28,
    		SUM(FII_MEASURE29) FII_MEASURE29,
    		SUM(FII_MEASURE30) FII_MEASURE30,
    		SUM(FII_DIM1)      FII_DIM1,
    		SUM(FII_DIM2)      FII_DIM2,
    		SUM(FII_DIM3)      FII_DIM3,
    		SUM(FII_DIM4)      FII_DIM4,
    		SUM(FII_DIM5)      FII_DIM5,
    		SUM(FII_DIM7)      FII_DIM7,
    		SUM(FII_DIM8)      FII_DIM8,
    		'''||l_url_1||''' FII_ATTRIBUTE14
FROM
(select id,
     	FII_MEASURE1	   		        FII_MEASURE1,
    		FII_MEASURE2 			          FII_MEASURE2,
    		FII_MEASURE4			           FII_MEASURE4,
    		FII_MEASURE5   	     	    FII_MEASURE5,
    		FII_MEASURE7     	        FII_MEASURE7,
    		FII_MEASURE8		 	          FII_MEASURE8,
    		FII_MEASURE12             FII_MEASURE12,
    		FII_MEASURE13             FII_MEASURE13,
    		FII_MEASURE15          		 FII_MEASURE15,
    		FII_MEASURE17        		   FII_MEASURE17,
    		FII_MEASURE19            	FII_MEASURE19,
    		FII_MEASURE21            	FII_MEASURE21,
    		FII_MEASURE23             FII_MEASURE23,
    		SUM(FII_MEASURE1)  OVER()	FII_MEASURE25,
    		SUM(FII_MEASURE2)  OVER()	FII_MEASURE26,
    		SUM(FII_MEASURE4)  OVER() FII_MEASURE27,
    		SUM(FII_MEASURE5)  OVER() FII_MEASURE28,
    		SUM(FII_MEASURE7)  OVER() FII_MEASURE29,
    		SUM(FII_MEASURE8)  OVER() FII_MEASURE30,
    		SUM(FII_MEASURE12) OVER() FII_DIM1,
    		SUM(FII_MEASURE13) OVER() FII_DIM2,
    		SUM(FII_MEASURE15) OVER() FII_DIM3,
    		SUM(FII_MEASURE17) OVER() FII_DIM4,
    		SUM(FII_MEASURE21) OVER() FII_DIM5,
    		SUM(FII_MEASURE23) OVER() FII_DIM7,
    		SUM(FII_MEASURE19) OVER() FII_DIM8,
      ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
 from
 (select id,
     	SUM(FII_MEASURE1)	   		        FII_MEASURE1,
    		SUM(FII_MEASURE2) 			          FII_MEASURE2,
    		SUM(FII_MEASURE4)			           FII_MEASURE4,
    		SUM(FII_MEASURE5)   	     	    FII_MEASURE5,
    		SUM(FII_MEASURE7)     	        FII_MEASURE7,
    		SUM(FII_MEASURE8)		 	          FII_MEASURE8,
    		SUM(FII_MEASURE12)             FII_MEASURE12,
    		SUM(FII_MEASURE13)             FII_MEASURE13,
    		SUM(FII_MEASURE15)          		 FII_MEASURE15,
    		SUM(FII_MEASURE17)        		   FII_MEASURE17,
    		SUM(FII_MEASURE19)            	FII_MEASURE19,
    		SUM(FII_MEASURE21)            	FII_MEASURE21,
    		SUM(FII_MEASURE23)             FII_MEASURE23
  from
  (SELECT f.'||l_viewby_id||' id,
 	      		SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	 	     		 THEN f.inv_on_hold_amt'||l_period_suffix||l_currency||' ELSE 0 END) FII_MEASURE1,
 	 	     	SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	    			    THEN f.inv_on_hold_amt'||l_period_suffix||l_currency||' ELSE 0 END) FII_MEASURE2,
       			SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	    	  		 THEN f.inv_on_hold_count'||l_period_suffix||' ELSE 0 END) FII_MEASURE4,
       			SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	    		   	 THEN f.inv_on_hold_count'||l_period_suffix||' ELSE 0 END) FII_MEASURE5,
       			SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	    	  		 THEN f.days_on_hold'||l_period_suffix||' ELSE 0 END) FII_MEASURE7,
   	    		SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	       			 THEN f.days_on_hold'||l_period_suffix||' ELSE 0 END) FII_MEASURE8,
   	    		SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	      			 THEN f.no_of_holds_placed ELSE 0 END) FII_MEASURE12,
   	    		SUM(CASE WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	       			 THEN f.no_of_holds_placed ELSE 0 END) FII_MEASURE13,
   	    		0 FII_MEASURE15,
     			  0 FII_MEASURE17,
     			  0 FII_MEASURE19,
       			0 FII_MEASURE21,
       			0 FII_MEASURE23
   FROM FII_AP_HATY_XB_MV f,
	fii_time_structures cal
   WHERE f.time_id = cal.time_id
   AND   f.period_type_id = cal.period_type_id
   '||l_org_where||l_supplier_where||'
   AND   bitAND(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
   AND   f.gid = :GID
   GROUP BY f.'||l_viewby_id||'
   UNION ALL
   SELECT f.'||l_viewby_id||' id,
      		 	0 FII_MEASURE1,
       			0 FII_MEASURE2,
       			0 FII_MEASURE4,
       			0 FII_MEASURE5,
     	  		0 FII_MEASURE7,
     			  0 FII_MEASURE8,
       			0 FII_MEASURE12,
       			0 FII_MEASURE13,
     			  SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	    			   THEN f.variance_hold_count ELSE 0 END) FII_MEASURE15,
      	 		SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	      			 THEN f.po_matching_hold_count ELSE 0 END) FII_MEASURE17,
      	 		SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	      			 THEN f.invoice_hold_count ELSE 0 END) FII_MEASURE19,
      	 		SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	      			 THEN f.user_defined_hold_count ELSE 0 END) FII_MEASURE21,
      	 		SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
 	      			 THEN f.other_hold_count ELSE 0 END) FII_MEASURE23
		 FROM FII_AP_HCAT_IB_MV f,
       		      fii_time_structures cal
   WHERE f.time_id = cal.time_id
   AND f.period_type_id = cal.period_type_id
  	'||l_org_where||l_supplier_where||'
 		AND bitAND(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
 		AND cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
		 AND f.hold_release_flag=''H''           /*added for bug no.3096078*/
		 AND f.gid = :GID
   GROUP BY f.'||l_viewby_id||')
  group by ID)) f,
('||l_viewby_string||') viewby_dim
WHERE f.id = viewby_dim.id
and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
GROUP BY viewby_dim.value,viewby_dim.id
&ORDER_BY_CLAUSE';


 /*Section for binding the variables*/


FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_sql,
       p_bind_output_table=>get_hold_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );


END get_hold_activity;

/* Creating a Procedure for the Electronic Invoice trend report */

PROCEDURE Local_Bind_Variable
     (p_sqlstmt                         IN Varchar2,
     p_page_parameter_tbl               IN BIS_PMV_PAGE_PARAMETER_TBL,
     p_sql_output OUT NOCOPY Varchar2,
     p_bind_output_table OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
     p_record_type_id IN Number Default Null,
     p_view_by IN Varchar2 Default Null,
     p_gid IN Number Default Null,
     p_period_start   IN Date     Default null,
     p_report_start          IN Date     Default null,
     p_cur_effective_num IN Number Default Null,
     p_period_id                 IN Number   Default Null
      ) IS
      l_bind_rec       BIS_QUERY_ATTRIBUTES;

BEGIN
       p_bind_output_table := BIS_QUERY_ATTRIBUTES_TBL();
       l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
       p_sql_output := p_sqlstmt;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':VIEW_BY';
       l_bind_rec.attribute_value := to_char(p_view_by);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':RECORD_TYPE_ID';
       l_bind_rec.attribute_value := to_char(p_record_type_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':GID';
       l_bind_rec.attribute_value := to_char(p_gid);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SEC_ID';
       l_bind_rec.attribute_value := fii_pmv_util.get_sec_profile;
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PERIOD_START';
       l_bind_rec.attribute_value := to_char(p_period_start, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_REPORT_START';
       l_bind_rec.attribute_value := to_char(p_report_start, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_CUR_EFFECTIVE_NUM';
       l_bind_rec.attribute_value := TO_CHAR(p_cur_effective_num);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_PERIOD_ID';
       l_bind_rec.attribute_value := to_char(p_period_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       --vkazhipu added for performance
       --bug 4997442
        l_bind_rec.attribute_name := ':P_DATE_STRING';
       l_bind_rec.attribute_value := to_char(g_date_string,'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

END Local_Bind_Variable;

 /* Creating Procedure that fetches the period details for the Electronic Invoice Trend reports */

PROCEDURE get_period_details(p_page_parameter_tbl   IN  BIS_PMV_PAGE_PARAMETER_TBL,
                           p_period_start           OUT NOCOPY Date,
                           p_cur_period             OUT NOCOPY Number,
                           p_id_column              OUT NOCOPY Varchar2,
                           p_report_start           OUT NOCOPY DATE,
                           p_cur_effective_num      OUT NOCOPY number,
                           p_period_id              OUT NOCOPY number)
IS
   l_as_of_date         DATE;
   i                    NUMBER;
   l_period_type        VARCHAR2(2000);
   l_p_as_of_date       DATE;
   l_start_date         DATE;
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
         l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
         l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_WEEK_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'week_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'ent_period_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_ENT_QTR_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'ent_qtr_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'ent_year_id';
       END IF;
     END LOOP;
  END IF;

  select nvl(min(start_date), trunc(sysdate)) into l_start_date from fii_time_ent_year;

 CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN
        p_period_id := 16;
        select nvl(fii_time_api.pwk_end(l_as_of_date-91) +1, l_start_date) into p_report_start from dual;
        select nvl(fii_time_api.pwk_end(l_as_of_date) +1, l_start_date-1) into p_period_start from dual;
        select sequence into p_cur_effective_num
        from fii_time_week
        where l_as_of_date between start_date and end_date;
    WHEN 'FII_TIME_ENT_PERIOD' THEN
        p_period_id := 32;
        select nvl(fii_time_api.ent_lysper_end(l_as_of_date), l_start_date-1) into p_report_start from dual;
        select nvl(fii_time_api.ent_cper_start(l_as_of_date), l_start_date) into p_period_start from dual;
        select sequence into p_cur_effective_num
        from fii_time_ent_period
        where l_as_of_date between start_date and end_date;
    WHEN 'FII_TIME_ENT_QTR' THEN
      p_period_id := 64;
      select nvl(fii_time_api.ent_lysqtr_end(l_as_of_date), l_start_date-1) into p_report_start from dual;
      select nvl(fii_time_api.ent_cqtr_start(l_as_of_date), l_start_date) into p_period_start from dual;

      select sequence into p_cur_effective_num
      from fii_time_ent_qtr
      where l_as_of_date between start_date and end_date;
    WHEN 'FII_TIME_ENT_YEAR'   THEN
       p_period_id := 128;
       --p_report_start := fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(l_as_of_date))));

	select nvl(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(l_as_of_date)))),l_start_date-1)
	into p_report_start from dual;   /* Bug 3325387 */

       select nvl(fii_time_api.ent_cyr_start(l_as_of_date), l_start_date) into  p_period_start from dual;
       select sequence into p_cur_effective_num
       from fii_time_ent_year
       where l_as_of_date between start_date and end_date;
END CASE;

END get_period_details;

/* Electronic Invoice trend Report */

PROCEDURE get_electronic_inv_trend (
   p_page_parameter_tbl            IN  BIS_PMV_PAGE_PARAMETER_TBL,
   electronic_inv_trend_sql        OUT NOCOPY VARCHAR2,
   electronic_inv_trend_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_viewby_dim                    VARCHAR2(240);  -- what is the viewby
        l_as_of_date                    DATE;
        l_organization                  VARCHAR2(240);
        l_supplier                      VARCHAR2(240);
        l_currency                      VARCHAR2(240);  -- random size, possibly high
        l_viewby_id                     VARCHAR2(240);  -- org_id or supplier_id
        l_record_type_id                NUMBER;         --
        l_gid                           NUMBER;         -- 0,4 or 8
        l_viewby_string                 VARCHAR2(240);
        electronic_inv_trend_rec        BIS_QUERY_ATTRIBUTES;
        l_param_join                    VARCHAR2(240);
        l_cur_period                    NUMBER;
        l_id_column                     VARCHAR2(100);
        sqlstmt                         VARCHAR2(14000);
        l_invoice_number                VARCHAR2(240);
        l_org_where                     VARCHAR2(240);
        l_supplier_where                VARCHAR2(240);
        l_period_type                   VARCHAR2(1000);
        l_period_start                  DATE;
        l_report_start                  DATE;
        l_cur_effective_num             NUMBER;
        l_period_id                     NUMBER;
        l_url_1                         VARCHAR2(1000);
        l_url_2                         VARCHAR2(1000);
	     -- l_date                          VARCHAR2(1000);
        l_date_mask                     VARCHAR2(240);
	     --l_count                          NUMBER;
        l_status                        VARCHAR2(30);
        l_industry                      VARCHAR2(30);
        l_fii_schema                    VARCHAR2(30);
        l_as_of_date_2                   VARCHAR2(50);
        l_as_of_date_3                  DATE;


 BEGIN
  FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_where,
       l_supplier_where
       );

 get_period_details(p_page_parameter_tbl,
                    l_period_start,
                    l_cur_period,
                    l_id_column,
                    l_report_start,
                    l_cur_effective_num,
                    l_period_id );

    FII_PMV_Util.get_format_mask(l_date_mask);

l_as_of_date_2 := to_char(l_as_of_date,'DD/MM/YYYY');
l_as_of_date_3 := to_date(l_as_of_date_2,'DD/MM/YYYY');

/* As part of bug 3497818 we check if the table FII_AR_SALES_CREDITS is present. If it is present then we need
to use the new logic of populating the urls which is available in 11.5.10 env so as to avoid the security concern
arising due to using of Drill across package.
For 11.5.9 environments we will be using the same old logic of using the drill across package for passing the dates
In 11.5.9 environments the FII_AR_SALES_CREDITS table will not exist and hence this test will suffice.*/

IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema))
  THEN NULL;
  END IF;

/* Commented out by VKAZHIPU, since FII_AP_DRILL_ACROSS Package is not used for drill down */
/* bug 4568962 */

/*select count(*)  into l_count from all_tables where table_name = 'FII_AR_SALES_CREDITS' and
 rownum = 1 and owner = l_fii_schema; */

/* Commented out by VKAZHIPU, since FII_AP_DRILL_ACROSS Package is not used for drill down */
/* bug 4568962 */

--IF l_count = 0 THEN


/* changed code below to implement drill as per bug no.3044393*/
-- IF l_organization <> 'All' and l_supplier <> 'All' then
     -- l_url_1 := 'pFunctionName=FII_AP_E_INV_ENT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
--      CASE l_period_type

--     WHEN 'FII_TIME_ENT_PERIOD' THEN
--     l_url_1  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||tcur.end_date||''&pPeriod=FII_TIME_ENT_PERIOD&pParamIds=Y';
--     l_url_2  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||&BIS_CURRENT_ASOF_DATE||''&pPeriod=FII_TIME_ENT_PERIOD&pParamIds=Y';
--     l_date   := 'fii_time_api.ent_cper_end(&BIS_CURRENT_ASOF_DATE)';
--	  WHEN 'FII_TIME_ENT_YEAR' THEN
--     l_url_1  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||tcur.end_date||''&pPeriod=FII_TIME_ENT_YEAR&pParamIds=Y';
--     l_url_2  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||&BIS_CURRENT_ASOF_DATE||''&pPeriod=FII_TIME_ENT_YEAR&pParamIds=Y';
--     l_date   :='fii_time_api.ent_cyr_end(&BIS_CURRENT_ASOF_DATE)';
--	  WHEN 'FII_TIME_ENT_QTR' THEN
--     l_url_1  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||tcur.end_date||''&pPeriod=FII_TIME_ENT_QTR&pParamIds=Y';
--     l_url_2  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||&BIS_CURRENT_ASOF_DATE||''&pPeriod=FII_TIME_ENT_QTR&pParamIds=Y';
--     l_date   :='fii_time_api.ent_cqtr_end(&BIS_CURRENT_ASOF_DATE)';
--	  WHEN 'FII_TIME_WEEK' THEN
--     l_url_1  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||enddate||''&pPeriod=FII_TIME_WEEK&pParamIds=Y';
--     l_url_2  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_E_INV_ENT_DTL&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=''||&BIS_CURRENT_ASOF_DATE||''&pPeriod=FII_TIME_WEEK&pParamIds=Y';
--     END CASE;
-- ELSE
--      l_url_1 := '';
--      l_url_2 := '';
      g_date_string   := fii_time_api.ent_cper_end(l_as_of_date_3);
-- END IF;

-- ELSE


/*changed code below to implement drill as per bug no.3044393*/
 IF l_organization <> 'All' and l_supplier <> 'All' then

      CASE l_period_type

     WHEN 'FII_TIME_ENT_PERIOD' THEN
     l_url_1 := 'AS_OF_DATE=''||drill_date||''&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     l_url_2 := 'AS_OF_DATE='||l_as_of_date_2||'&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     g_date_string   := fii_time_api.ent_cper_end(l_as_of_date_3);


	  WHEN 'FII_TIME_ENT_YEAR' THEN
     l_url_1 := 'AS_OF_DATE=''||drill_date||''&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     l_url_2 := 'AS_OF_DATE='||l_as_of_date_2||'&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     g_date_string   :=fii_time_api.ent_cyr_end(l_as_of_date_3);


	  WHEN 'FII_TIME_ENT_QTR' THEN
     l_url_1 := 'AS_OF_DATE=''||drill_date||''&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     l_url_2 := 'AS_OF_DATE='||l_as_of_date_2||'&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     g_date_string   :=fii_time_api.ent_cqtr_end(l_as_of_date_3);


	  WHEN 'FII_TIME_WEEK' THEN

     l_url_1 := 'AS_OF_DATE=''||drill_date||''&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     l_url_2 := 'AS_OF_DATE='||l_as_of_date_2||'&pFunctionName=FII_AP_E_INV_ENT_DTL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_E_INV_ENT_DTL';
     g_date_string := fii_time_api.cwk_end(l_as_of_date_3);

     END CASE;
 ELSE
      l_url_1 := '';
      l_url_2 := '';
      g_date_string   := fii_time_api.ent_cper_end(l_as_of_date_3);
 END IF;


--END IF;

/*--------------------------------------------------------+
 |  VIEWBY           - Either Operating Unit / Supplier   |
 |  VIEWBYID         - Either org_id / supplier_id        |
 |  FII_MEASURE1     - Period to Date                     |
 |  FII_MEASURE2     - Total Invoices Entered             |
 |  FII_MEASURE3     - Electronic Invoices Entered        |
 |  FII_MEASURE4     - % Electronic Invoices              |
 |  FII_MEASURE5     - Electronic Invoice Amount          |
 +-------------------------------------------------------*/

----constructing the sql statement
 /* changed code below to implement drill as per bug no.3044393.Passing the END DATE in case of WEEK explicitly which will be last date displayed
 in the trend report so we have divided the sql in 2 parts One for the WEEK and second to handle all others.*/
CASE l_period_type
WHEN 'FII_TIME_WEEK' then

sqlstmt := '
       SELECT
         (case when FII_MEASURE1 = fii_time_api.cwk_end(&BIS_CURRENT_ASOF_DATE) then to_char(&BIS_CURRENT_ASOF_DATE) else FII_MEASURE1 end) FII_MEASURE1,
               FII_MEASURE2,
               FII_MEASURE3,
               FII_MEASURE5,
               (CASE WHEN (enddate-fii_time_api.cwk_end(&BIS_CURRENT_ASOF_DATE)) = 0  then '''||l_url_2||'''  else '''||l_url_1||'''   END )   FII_ATTRIBUTE1

        FROM(
            SELECT
	       tcur.end_date                    enddate,
               name                             FII_MEASURE1,
               inline_view.invoice_entered      FII_MEASURE2,
               inline_view.invoice_count        FII_MEASURE3,
               inline_view.invoice_amt          FII_MEASURE5,
               to_char(tcur.end_date,''DD/MM/YYYY'')  drill_date

            FROM
                (

            SELECT
                       inner_inline_view.FII_SEQUENCE   FII_EFFECTIVE_NUM,
                       SUM(invoice_count_entered)       invoice_entered ,
                       SUM(e_invoice_count)             invoice_count,
                       SUM(e_invoice_amt)               invoice_amt

            FROM
                    (
                     SELECT
                        t.sequence                         FII_SEQUENCE,
                        f.invoice_count_entered            invoice_count_entered,
                        f.e_invoice_count                  e_invoice_count,
                        f.e_invoice_amt'||l_currency||'    e_invoice_amt

                     FROM  FII_AP_IVATY_XB_MV f,
                           '||l_period_type||' t
                     WHERE
                           f.gid   = :GID
                           AND f.time_id = t.'||l_id_column||'
                           AND f.period_type_id = :P_PERIOD_ID
                           AND t.end_date  between to_date(:P_REPORT_START,''DD-MM-YYYY'') AND to_date(:PERIOD_START,''DD-MM-YYYY'')
                            '||l_org_where||l_supplier_where||'
                     UNION ALL

                     SELECT
                               :P_CUR_EFFECTIVE_NUM                 FII_SEQUENCE,
                               f.invoice_count_entered              invoice_count_entered,
                               f.e_invoice_count                    e_invoice_count,
                               f.e_invoice_amt'||l_currency||'      e_invoice_amt

                     FROM  FII_AP_IVATY_XB_MV f,
                           fii_time_structures cal

                     WHERE
                            f.gid   = :GID
                         AND   f.period_type_id        = cal.period_type_id
                         AND   f.time_id = cal.time_id
                         AND   bitand(cal.record_type_id,:RECORD_TYPE_ID)= :RECORD_TYPE_ID
                         AND   cal.report_date = &BIS_CURRENT_ASOF_DATE
                          '||l_org_where||l_supplier_where||'

                         ) inner_inline_view
                      GROUP BY inner_inline_view.FII_SEQUENCE
              ) inline_view,
              '||l_period_type||' tcur
              WHERE inline_view.fii_effective_num (+)= tcur.sequence
              AND tcur.start_date > to_date(:P_REPORT_START,''DD-MM-YYYY'')
              AND tcur.start_date <= &BIS_CURRENT_ASOF_DATE
              ORDER BY tcur.start_date)';

    ELSE

    sqlstmt := '
            SELECT
               name                             FII_MEASURE1,
               inline_view.invoice_entered      FII_MEASURE2,
               inline_view.invoice_count        FII_MEASURE3,
               inline_view.invoice_amt          FII_MEASURE5,
	      (CASE WHEN (tcur.end_date-:P_DATE_STRING) = 0  then '''||l_url_2||'''  else '''||l_url_1||'''   END )   FII_ATTRIBUTE1

            FROM
                (
                SELECT
                       inner_inline_view.FII_SEQUENCE   FII_EFFECTIVE_NUM,
                       SUM(invoice_count_entered)       invoice_entered ,
                       SUM(e_invoice_count)             invoice_count,
                       SUM(e_invoice_amt)               invoice_amt,
                       drill_date                       drill_date
                FROM
                    (
                     SELECT
                        t.sequence                         FII_SEQUENCE,
                        f.invoice_count_entered            invoice_count_entered,
                        f.e_invoice_count                  e_invoice_count,
                        f.e_invoice_amt'||l_currency||'    e_invoice_amt,
                        to_char(t.end_date,''DD/MM/YYYY'')  drill_date

                     FROM  FII_AP_IVATY_XB_MV f,
                           '||l_period_type||' t
                     WHERE
                           f.gid   = :GID
                           AND f.time_id = t.'||l_id_column||'
                           AND f.period_type_id = :P_PERIOD_ID
                           AND t.end_date > to_date(:P_REPORT_START,''DD-MM-YYYY'')    /*Changed for bug no.3069214*/
			   AND t.end_date < to_date(:PERIOD_START,''DD-MM-YYYY'')
                            '||l_org_where||l_supplier_where||'

                     UNION ALL

                     SELECT
                               :P_CUR_EFFECTIVE_NUM                 FII_SEQUENCE,
                               f.invoice_count_entered              invoice_count_entered,
                               f.e_invoice_count                    e_invoice_count,
                               f.e_invoice_amt'||l_currency||'      e_invoice_amt,
                               to_char(cal.report_date,''DD/MM/YYYY'')  drill_date
                     FROM  FII_AP_IVATY_XB_MV f,
                           fii_time_structures cal

                     WHERE
                            f.gid   = :GID
                         AND   f.period_type_id        = cal.period_type_id
                         AND   f.time_id = cal.time_id
                         AND   bitand(cal.record_type_id,:RECORD_TYPE_ID)= :RECORD_TYPE_ID
                         AND   cal.report_date = &BIS_CURRENT_ASOF_DATE
                          '||l_org_where||l_supplier_where||'

                    ) inner_inline_view
                    GROUP BY inner_inline_view.FII_SEQUENCE, drill_date
                   ) inline_view,
                 '||l_period_type||' tcur
               WHERE inline_view.fii_effective_num (+)= tcur.sequence
               AND tcur.start_date > to_date(:P_REPORT_START,''DD-MM-YYYY'')
               AND tcur.start_date <= &BIS_CURRENT_ASOF_DATE
               ORDER BY tcur.start_date';
      END CASE;

Local_Bind_Variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>electronic_inv_trend_sql,
       p_bind_output_table=>electronic_inv_trend_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid,
       p_period_start=>l_period_start,
       p_report_start => l_report_start,
       p_cur_effective_num => l_cur_effective_num,
       p_period_id => l_period_id
       );
END get_electronic_inv_trend;

END fii_ap_inv_activity;

/
