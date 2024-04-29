--------------------------------------------------------
--  DDL for Package Body AP_CUSTOM_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CUSTOM_WITHHOLDING_PKG" as
/* $Header: apcmawtb.pls 120.3.12010000.2 2008/08/08 03:06:52 sparames ship $ */
                                                                          --
function Ap_Special_Rate (
                          P_Tax_Name    IN varchar2
                         ,P_Invoice_Id  IN number
                         ,P_Payment_Num IN number
                         ,P_Awt_Date    IN date
                         ,P_Amount      IN number
                         )
                         return number
is

BEGIN

-- IMPORTANT: This section is reserved for Globalization features.
--            Please do not modify code here.

-- BUG 7232736 replaced sys_context with g_zz_shared_pkg.get_product

-- IF sys_context('JG','JGZZ_PRODUCT_CODE') is not null THEN
IF jg_zz_shared_pkg.get_product(AP_CALC_WITHHOLDING_PKG.g_org_id, NULL) is not null THEN
    return(JG_WITHHOLDING_TAX_PKG.Get_Rate_Id(
                          		       P_Tax_Name
                         		      ,P_Invoice_Id
                         		      ,P_Payment_Num
                         		      ,P_Awt_Date
                        		      ,P_Amount
					     ));
  END IF;

-- Please enter all custom code below this line.
-- Begin Custom Code

    return(null);

-- End Custom Code

END Ap_Special_Rate;

				   --
procedure Ap_Special_Rounding (P_Checkrun_Name IN varchar2)
is
--l_org_id           NUMBER(15); -- BUG 7232736

BEGIN
-- BUG 7232736 : added select ot get the Org_id using checkrun_id (p_checkrun_name)
-- select org_id into l_org_id
-- from ap_checks_all
-- where checkrun_id = P_Checkrun_Name;



-- IMPORTANT: This section is reserved for Globalization features.
--            Please do not modify code here.

--  BUG 7232736 replaced sys_context with g_zz_shared_pkg.get_product/reverted to Orginal  code.
   IF sys_context('JG','JGZZ_PRODUCT_CODE') is not null THEN
-- IF jg_zz_shared_pkg.get_product(l_org_id, NULL) is not null THEN
    JG_WITHHOLDING_TAX_PKG.AWT_Rounding(
                          		P_Checkrun_Name
				       );
  END IF;

-- Please enter all custom code below this line.
-- Begin Custom Code

    null;

-- End Custom Code

END Ap_Special_Rounding;

/*****************************************************************
 Procedure: Ap_Special_Withheld_Amt
 Objective: This procedure enable globalization to make some
            adjusments in the withheld amount, for example
            rounding.  This procedure is called from
            AP_CALC_WITHHOLDING_PKG.Insert_Temp_Distribution
 ******************************************************************/

procedure Ap_Special_Withheld_Amt
                (
                 P_Withheld_Amount        IN OUT NOCOPY Number
                ,P_Base_WT_amount         IN OUT NOCOPY Number
                ,P_CurrCode               IN Varchar2
                ,P_BaseCurrCode           IN Varchar2
                ,P_Invoice_exchange_rate  IN Number
                ,P_Tax_Name               IN Varchar2
                ,P_Calling_sequence       IN Varchar2
                 )
is

BEGIN

-- IMPORTANT: This section is reserved for Globalization features.
--            Please do not modify code here.
-- BUG 7232736 replaced sys_context with g_zz_shared_pkg.get_product
-- Uncommented the call to JG_WITHHOLDING_TAX_PKG.JG_Special_Withheld_Amt

-- IF sys_context('JG','JGZZ_PRODUCT_CODE') is not null THEN
IF jg_zz_shared_pkg.get_product(AP_CALC_WITHHOLDING_PKG.g_org_id, NULL) is not null THEN
    JG_WITHHOLDING_TAX_PKG.JG_Special_Withheld_Amt
                                     (P_Withheld_Amount
                                     ,P_Base_WT_amount
                                     ,P_CurrCode
                                     ,P_BaseCurrCode
                                     ,P_Invoice_exchange_rate
                                     ,P_Tax_Name
                                     ,P_Calling_sequence
                                     );
    NULL;

  END IF;

-- Please enter all custom code below this line.
-- Begin Custom Code

    null;

-- End Custom Code

END Ap_Special_Withheld_Amt;

end AP_CUSTOM_WITHHOLDING_PKG;

/
