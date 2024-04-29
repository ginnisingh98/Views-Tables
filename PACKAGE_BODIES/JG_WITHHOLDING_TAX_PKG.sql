--------------------------------------------------------
--  DDL for Package Body JG_WITHHOLDING_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_WITHHOLDING_TAX_PKG" as
/* $Header: jgzzawtb.pls 120.4.12010000.2 2008/08/04 13:54:18 vgadde ship $ */

function Get_Rate_Id (
                       P_Tax_Name     IN varchar2
                      ,P_Invoice_Id   IN number
                      ,P_Payment_Num  IN number
                      ,P_Awt_Date     IN date
                      ,P_Amount       IN number
                      )
                      return number
is
  l_product_code varchar2(2);
BEGIN

   l_product_code := jg_zz_shared_pkg.get_product(ap_calc_withholding_pkg.g_org_id, NULL);

   IF l_product_code = 'JA' then
    return ( JA_AWT_PKG.Get_Rate_Id(
                      		    P_Tax_Name
                      		   ,P_Invoice_Id
                      		   ,P_Payment_Num
                      		   ,P_Awt_Date
                      		   ,P_Amount
                      		   ));
   /* commented for June 24 th release bug by shijain, uncomment later
   ELSIF jg_zz_shared_pkg.get_product(l_ou_id, NULL) = 'JE' then
    return ( JE_AWT_PKG.Get_Rate_Id(
                                    P_Tax_Name
                                   ,P_Invoice_Id
                                   ,P_Payment_Num
                                   ,P_Awt_Date
                                   ,P_Amount
                                   ));
*/
   ELSIF l_product_code = 'JL' then
    return ( JL_AWT_PKG.Get_Rate_Id(
                                    P_Tax_Name
                                   ,P_Invoice_Id
                                   ,P_Payment_Num
                                   ,P_Awt_Date
                                   ,P_Amount
                                   ));
  ELSE
    return(null);
  END IF;


END Get_Rate_Id;


procedure AWT_Rounding (
			P_Checkrun_Name IN varchar2
			)
is
  l_ou_id  NUMBER;
BEGIN

  fnd_profile.get('ORG_ID',l_ou_id);

  IF jg_zz_shared_pkg.get_product(l_ou_id, NULL) = 'JA' then
    JA_AWT_PKG.AWT_Rounding(P_Checkrun_Name);
/* commented for June 24 th release bug by shijain, uncomment later
  ELSIF jg_zz_shared_pkg.get_product(l_ou_id, NULL) = 'JE' then
    JE_AWT_PKG.AWT_Rounding(P_Checkrun_Name);
*/
  ELSIF jg_zz_shared_pkg.get_product(l_ou_id, NULL) = 'JL' then
    JL_AWT_PKG.AWT_Rounding(P_Checkrun_Name);
  ELSE
    null;
  END IF;

END AWT_Rounding;

/**************************************************************
  Procedure JG_Special_Rounding
  Objective: Make special rounding for the Withheld Amount
             and Check a minimum withheld amount.
  Countries: Korea. (So far)
 **************************************************************/

PROCEDURE JG_Special_Withheld_Amt
                (
                 P_Withheld_Amount        IN OUT NOCOPY Number
                ,P_Base_WT_amount         IN OUT NOCOPY Number
                ,P_CurrCode               IN Varchar2
                ,P_BaseCurrCode           IN Varchar2
                ,P_Invoice_exchange_rate  IN Number
                ,P_Tax_Name               IN Varchar2
                ,P_Calling_sequence       IN Varchar2
                 )

IS
  l_country_code              VARCHAR2(10);
  current_calling_sequence    VARCHAR2(2000);
BEGIN
    current_calling_sequence := 'JG_WITHHOLDING_TAX_PKG.<-Jg_Special_Withheld_Amt ' ||
                              P_Calling_Sequence;

    l_country_code := jg_zz_shared_pkg.get_country(ap_calc_withholding_pkg.g_org_id, NULL);
    IF (l_country_code = 'KR') THEN

       Ja_Kr_Ap_Special_Wh_PKG.Ja_Special_Withheld_Amt
                                               (P_Withheld_Amount
                                               ,P_Base_WT_amount
                                               ,P_CurrCode
                                               ,P_BaseCurrCode
                                               ,P_Invoice_exchange_rate
                                               ,P_Tax_Name
                                               ,P_Calling_sequence
                                               );
    END IF;
END JG_Special_Withheld_Amt;

end JG_WITHHOLDING_TAX_PKG;

/
