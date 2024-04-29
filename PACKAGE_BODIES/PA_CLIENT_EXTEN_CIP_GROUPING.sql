--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTEN_CIP_GROUPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTEN_CIP_GROUPING" AS
/* $Header: PAXGCEB.pls 120.5 2007/02/06 09:30:05 rshaik ship $ */
FUNCTION CLIENT_GROUPING_METHOD( p_proj_id         IN PA_PROJECTS_ALL.project_id%TYPE,
                                 p_task_id        IN PA_TASKS.task_id%TYPE,
                                 p_expnd_item_id  IN PA_EXPENDITURE_ITEMS_ALL.expenditure_item_id%TYPE,
                                 p_expnd_id       IN PA_EXPENDITURE_ITEMS_ALL.expenditure_id%TYPE,
                                 p_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
                                 p_expnd_category IN PA_EXPENDITURE_CATEGORIES.expenditure_category%TYPE,
                                 p_attribute1     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute2     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute3     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute4     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute5     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute6     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute7     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute8     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute9     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute10    IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                 p_attribute_category IN PA_EXPENDITURE_ITEMS_ALL.attribute_category%TYPE,
                                 p_transaction_source IN PA_EXPENDITURE_ITEMS_ALL.transaction_source%TYPE,
                                 p_ref2           IN PA_COST_DISTRIBUTION_LINES_ALL.system_reference2%TYPE,
                                 p_ref3           IN PA_COST_DISTRIBUTION_LINES_ALL.system_reference3%TYPE,
                                 p_ref4           IN PA_COST_DISTRIBUTION_LINES_ALL.system_reference4%TYPE)
return VARCHAR2 IS
v_grouping_method      varchar2(2000) default null;
v_material_flag        pa_expenditure_types.attribute10%TYPE;

 /* Adding cursor  for IPA for bug 5637615 */
   CURSOR get_crl_instal_rec is
       SELECT asset_name_id
       FROM ipa_asset_naming_conventions ;

l_crl_rec  ipa_asset_naming_convents_all.asset_name_id%TYPE;
BEGIN

  /* Adding another check for IPA for bug 5637615 */
 OPEN get_crl_instal_rec;
 FETCH get_crl_instal_rec into l_crl_rec;
 IF get_crl_instal_rec%notfound then
        l_crl_rec :=NULL;
 END IF;
 CLOSE get_crl_instal_rec;


 IF (PA_INSTALL.is_product_installed('IPA')) AND (l_crl_rec IS NOT NULL) THEN
  /* All the CRL Customers need to uncomment this part  */


    /*bug5454123 adding IF-ELSE*/
  IF  (p_transaction_source IN('AP INVOICE', 'AP EXPENSE', 'AP NRTAX', 'AP DISCOUNTS', 'AP VARIANCE',
                              'PO RECEIPT', 'PO RECEIPT NRTAX', 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ')
     and p_attribute6 is NULL
     and p_attribute7  is NULL
     and p_attribute8 is NULL
     and p_attribute9 is NULL
     and p_attribute10 is NULL) THEN

     v_grouping_method := p_ref2||p_ref3;

 ELSE
    /* Bug#2956569. Added IF condition to check if NL is installed and if so,
       use attributes 6 and 7 on EI else do not use */

    IF NVL(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N') = 'Y' THEN
        v_grouping_method := p_attribute8||p_attribute9||p_attribute10||
                             p_attribute6||p_attribute7;
    ELSE
        v_grouping_method := p_attribute8||p_attribute9||p_attribute10;
    END IF;

   /* For Grouping method by material flag do the following and comment
      the other portion - grouping by expenditure type
      Portion for grouping by Material and Non material  */

   /* CRL customers using Material flag as one of the grouping critera
      uncomment the portion below
      Note : Make sure the attrubute10 in pa_expenditure_types is populated
             with the material flag indicator */
   /*   Select attribute10 into v_material_flag
      From PA_EXPENDITURE_TYPES
      Where expenditure_type = p_expnd_type;

      if (v_material_flag is not null ) then
        v_grouping_method := v_grouping_method || v_material_flag;
      end if;
   */
   /* Portion for grouping by Expenditure Type
      CRL customers using expenditure type (Not material flag)
      uncomment the portion below  */
   /*  v_grouping_method := v_grouping_method || p_expnd_type  */
  END IF; -- End if for bug 5523708
 END IF;
   -- If gruping method is null then return ALL
      IF v_grouping_method is null then
         v_grouping_method := 'ALL';
      end if;
     -- Return the Grouping Method
       return v_grouping_method;

    EXCEPTION
    WHEN OTHERS THEN
      null;
    END;

 END PA_CLIENT_EXTEN_CIP_GROUPING;

/
