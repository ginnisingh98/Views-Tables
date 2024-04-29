--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BURDEN_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BURDEN_SUMMARY" AS
/* $Header: PAXBSGCB.pls 120.4 2006/05/26 07:46:54 rahariha noship $ */

  /* Start : Add a variable (G_GMS_ENABLED) to hold the value of GMS implemented
  **       status for Operating  Unit  with a default value of NULL.
  **       2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
  */

  G_gms_enabled varchar2(1) := NULL ;

  /*   End : Add a variable (G_GMS_ENABLED) to hold the value of GMS implemented
  **         status for Operating  Unit  with a default value of NULL.
  **         2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
  */


 FUNCTION CLIENT_GROUPING
  (p_src_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
   p_src_ind_expnd_type IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
   p_src_attribute1     IN PA_EXPENDITURE_TYPES.attribute1%TYPE,
   p_src_attribute2     IN PA_EXPENDITURE_TYPES.attribute2%TYPE,
   p_src_attribute3     IN PA_EXPENDITURE_TYPES.attribute3%TYPE,
   p_src_attribute4     IN PA_EXPENDITURE_TYPES.attribute4%TYPE,
   p_src_attribute5     IN PA_EXPENDITURE_TYPES.attribute5%TYPE,
   p_src_attribute6     IN PA_EXPENDITURE_TYPES.attribute6%TYPE,
   p_src_attribute7     IN PA_EXPENDITURE_TYPES.attribute7%TYPE,
   p_src_attribute8     IN PA_EXPENDITURE_TYPES.attribute8%TYPE,
   p_src_attribute9     IN PA_EXPENDITURE_TYPES.attribute9%TYPE,
   p_src_attribute10    IN PA_EXPENDITURE_TYPES.attribute10%TYPE,
   p_src_attribute_category    IN PA_EXPENDITURE_TYPES.attribute_category%TYPE
   ,p_src_exp_item_date  IN PA_EXPENDITURE_ITEMS_ALL.expenditure_item_date%TYPE DEFAULT NULL
  ,p_src_acct_rate_date              IN PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_DATE%TYPE DEFAULT NULL
  ,p_src_acct_rate_type              IN PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_TYPE%TYPE DEFAULT NULL
  ,p_src_acct_exchange_rate          IN PA_COST_DISTRIBUTION_LINES_ALL.ACCT_EXCHANGE_RATE%TYPE DEFAULT NULL
  ,p_src_project_rate_date           IN PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_DATE%TYPE DEFAULT NULL
  ,p_src_project_rate_type           IN PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_TYPE%TYPE DEFAULT NULL
  ,p_src_project_exchange_rate       IN PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_EXCHANGE_RATE%TYPE DEFAULT NULL
  ,p_src_projfunc_cost_rate_date     IN PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_DATE%TYPE DEFAULT NULL
  ,p_src_projfunc_cost_rate_type     IN PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_TYPE%TYPE DEFAULT NULL
  ,p_src_projfunc_cost_xchng_rate    IN PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_EXCHANGE_RATE%TYPE DEFAULT NULL
  ) RETURN varchar2 IS


   v_grouping_method   varchar2(2000) default null;

  BEGIN

    /* This Example groups the burden detail lines further by
       attribute8,attribute9,attribute10 of PA_CDL_BURDEN_V table (which
       are used to identify the expenditure lines with the assets in addition to
       project_id||task_id||organization_id||pa_date||ind_cust_code
       This is the CRL Projects Default code and should not be removed.
     */

     If (PA_INSTALL.is_product_installed('IPA')) then
      v_grouping_method := p_src_attribute8||p_src_attribute9||p_src_attribute10;
     End if;


     /*  Start : Grants Accounting specific grouping change:
     **          Add award grouping criteria only when grants is implemented.
     **          THIS SHOULD NOT BE REMOVED.
     **          2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
     */

    If G_gms_enabled is NULL THEN
       G_gms_enabled := gms_pa_api3.grants_enabled ;
    End If;

    IF g_gms_enabled = 'Y' THEN
       V_grouping_method := V_grouping_method||p_src_attribute1 ;
    END IF ;
    /*  End : Grants Accounting specific grouping  change.
    **        2981752 - PA.L:BURDENING ENHANCEMENTS : TRACKING BUG
    */


    /*
    ** CLIENT CUSTOMIZATIONS BEGINS HERE .
    *  Enhancement :3010830 added new param p_src_exp_item_date as in param so that
    *  client can use this param to derive the grouping method
    */

   --Return the Grouping Method
     return v_grouping_method;

  EXCEPTION

    WHEN OTHERS THEN
        RAISE;

  END CLIENT_GROUPING;

  PROCEDURE CLIENT_COLUMN_VALUES
  (
   p_src_attribute2     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute2%TYPE,
   p_src_attribute3     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute3%TYPE,
   p_src_attribute4     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute4%TYPE,
   p_src_attribute5     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute5%TYPE,
   p_src_attribute6     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute6%TYPE,
   p_src_attribute7     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute7%TYPE,
   p_src_attribute8     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute8%TYPE,
   p_src_attribute9     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute9%TYPE,
   p_src_attribute10    IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute10%TYPE,
   p_src_attribute_category IN PA_EXPENDITURE_TYPES.attribute_category%TYPE
  ,p_src_acct_rate_date           IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_DATE%TYPE
  ,p_src_acct_rate_type           IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_TYPE%TYPE
  ,p_src_acct_exchange_rate       IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.ACCT_EXCHANGE_RATE%TYPE
  ,p_src_project_rate_date        IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_DATE%TYPE
  ,p_src_project_rate_type        IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_TYPE%TYPE
  ,p_src_project_exchange_rate    IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_EXCHANGE_RATE%TYPE
  ,p_src_projfunc_cost_rate_date  IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_DATE%TYPE
  ,p_src_projfunc_cost_rate_type  IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_TYPE%TYPE
  ,p_src_projfunc_cost_xchng_rate IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_EXCHANGE_RATE%TYPE
  )

  IS

  BEGIN

  /* This client extension filters out the attribute values needs to be
     populated in pa_expenditure_items table, when a new EI is created by the
     Burden Summarization process based on the additional summarization grouping
     In this example since the burden detail lines are further grouped by
     attribute8,attribute9,attribute10 for CRL Asset mechanization, all the
     other attribute values will be set to null expect these three.
     CAUTION !!! This include the default CRL code controlled by the CRL installed profile
     and this should not be removed.
     */
   If (PA_INSTALL.is_product_installed('IPA')) then /*Bug 4739511:Added the If condition*/
   	p_src_attribute2  := null;
   	p_src_attribute3  := null;
   	p_src_attribute4  := null;
   	p_src_attribute5  := null;
   	p_src_attribute6  := null;
   	p_src_attribute7  := null;
   End if; /*Bug# 4739511*/

   /*Commenting for Bug# 4739511
   If (NOT PA_INSTALL.is_product_installed('IPA')) then
          p_src_attribute8 := null;
          p_src_attribute9 := null;
          p_src_attribute10 := null;
   End if;******/

  /* This client extension filters out the column values needs to be
     populated in pa_expenditure_items table, when a new expenditure item is created by the
     Burden Summarization process based on the additional summarization grouping.
     These column values, which have been included in the grouping criteria in the function
     CLIENT_GROUPING, should be commented out from the below code.
  */
  p_src_acct_rate_date           := NULL;
  p_src_acct_rate_type           := NULL;
  p_src_acct_exchange_rate       := NULL;
  p_src_project_rate_date        := NULL;
  p_src_project_rate_type        := NULL;
  p_src_project_exchange_rate    := NULL;
  p_src_projfunc_cost_rate_date  := NULL;
  p_src_projfunc_cost_rate_type  := NULL;
  p_src_projfunc_cost_xchng_rate := NULL;

 END CLIENT_COLUMN_VALUES;

/* Function Same_Line_Burden_Cmt added for bug 2989775 */

        FUNCTION Same_Line_Burden_Cmt RETURN BOOLEAN

        IS

        BEGIN

        /* The value returned by this function determines if the burdening on commitment transactions, which can be
	   viewed from the Project Status Inquiry Screen, is to be done on the same item or separate item,
           irrespective of the set up at the project type level. If the value returned by the function is FALSE,
           burdening is as per the set up at project type level but if the value returned is TRUE, burdening will be
	   on the same line on commitment transactions. The default value of this function is FALSE and needs
           to be set to TRUE as per the desired functionality. */

        return FALSE;

        END Same_Line_Burden_Cmt;

END PA_CLIENT_EXTN_BURDEN_SUMMARY;

/
