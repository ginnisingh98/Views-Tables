--------------------------------------------------------
--  DDL for Package Body ZX_UPGRADE_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_UPGRADE_CONTROL_PKG" AS
/* $Header: zxupctlb.pls 120.22.12010000.2 2009/02/16 14:33:23 srajapar ship $ */


PG_DEBUG CONSTANT VARCHAR(1) default
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*PROCEDURE migrate_sco_code_lte(
             P_TAX_REGIME_CODE   IN VARCHAR2 DEFAULT NULL,
             P_ORG_ID            IN NUMBER,
             P_CREATION_DATE     IN DATE,
             P_CREATED_BY        IN NUMBER,
             P_LAST_UPDATE_DATE  IN DATE,
             P_LAST_UPDATED_BY   IN NUMBER,
             P_LAST_UPDATE_LOGIN IN NUMBER);
*/
 /* Following Functions and Procedures Calls will be placed in the appropriate
    Forms in AP */

 /* ========================================================================*
  | Function Name: IS_AP_TAX_DEF_UPDATE_ALLOWED
  |
  | Product using
  | this function : Will be called by AP, from Payables Option Form
  |
  | Purpose: Will be used to lock the Tax Attributes on 'Tax Defaults
  |          and Rules' Tab in Payables Option Form
  |
  |
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax defaulting hierarchy
  |          migration starts. Tax attributes in Payables 'Tax Defaults
  |          and Rules' should be made non-updateable in Payables Option Form,
  |          if value returned is FALSE.
  |
  *=========================================================================*/

  FUNCTION IS_AP_TAX_DEF_UPDATE_ALLOWED
  (
   p_org_id IN     ap_system_parameters.org_id%TYPE
   ) RETURN BOOLEAN IS

  BEGIN

      RETURN TRUE;

   END IS_AP_TAX_DEF_UPDATE_ALLOWED;


 /* =========================================================================*
  | Function Name: IS_AP_INV_TAX_UPDATE_ALLOWED
  | Product using
  | this function : Will be called by AP, from Payables Option Form
  |
  |
  | Purpose: Will be used to lock the Tax Attributes on 'Invoice Tax' Tab in
  |          Payables Option Form.
  |
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the sa e function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax Defintion
  |          migration starts. Tax attributes in Payables 'Invoice Tax' Tab
  |          should be  ade non-updateable in Payables Option Form,
  |          if value returned is FALSE.
  |
   *========================================================================*/

  FUNCTION  IS_AP_INV_TAX_UPDATE_ALLOWED
  (
   p_org_id IN     ap_system_parameters.org_id%TYPE
  ) RETURN BOOLEAN IS

   BEGIN

  RETURN TRUE;

   END IS_AP_INV_TAX_UPDATE_ALLOWED;


 /* =========================================================================*
  | Function Name: IS_FIN_SYS_TAX_UPDATE_ALLOWED
  | Product using
  | this function : Will be called by AP, from Financial Options Form
  |
  | Purpose: Will be used to lock the Tax Attributes on 'Tax' Tab in
  |          Financial Options Form.
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax Defintion
  |          migration starts. Tax attributes in Financial Options Form
  |          should be made non-updateable in Payables Option Form,
  |          if value returned is FALSE.
  |
   *========================================================================*/

  FUNCTION IS_FIN_SYS_TAX_UPDATE_ALLOWED
  (
   p_org_id IN     FINANCIALS_SYSTEM_PARAMS_ALL.ORG_ID%TYPE
   ) RETURN BOOLEAN IS

  BEGIN

      RETURN TRUE;

  END IS_FIN_SYS_TAX_UPDATE_ALLOWED;

 /* =========================================================================*
  | Function Name: IS_CUST_UPDATE_ALLOWED
  | Product using
  | this function : Will be called by AR/TCA
  |
  | Purpose: Will be used to lock the Tax Attributes in
  |          Customer Form.
  |
   *========================================================================*/

  FUNCTION IS_CUST_UPDATE_ALLOWED
    (
     p_org_id IN     hz_cust_accounts.org_id%TYPE Default NULL
    )
  RETURN BOOLEAN IS

  BEGIN

      RETURN TRUE;

  END IS_CUST_UPDATE_ALLOWED;


 /* =========================================================================*
  | Procedure Name: SYNC_SUPPLIERS
  | Product using
  | this Procedure : Will be called by AP, from Suppliers Form
  |
  | Purpose: Will be used to Synchronize the data between the Suppliers and
  |          eTax Party tax profile Gateway entity.
  |
  |          Will be called from Suppliers form,passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the same Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Suppliers) and eTax Party tax profile
  |          Gateway entity.
  |
   *========================================================================*/


PROCEDURE SYNC_SUPPLIERS
 (
 P_Dml_Type                   IN VARCHAR2,
 P_Vendor_Id                  IN NUMBER,
 P_Last_Update_Date           IN DATE,
 P_Last_Updated_By            IN NUMBER,
 P_Vendor_Name                IN VARCHAR2,
 P_Segment1                   IN VARCHAR2,
 P_Summary_Flag               IN VARCHAR2,
 P_Enabled_Flag               IN VARCHAR2,
 P_Last_Update_Login          IN NUMBER,
 P_Creation_Date              IN DATE,
 P_Created_By                 IN NUMBER,
 P_Employee_Id                IN NUMBER,
 P_Validation_Number          IN NUMBER,
 P_Vendor_Type_Lookup_Code    IN VARCHAR2,
 P_Customer_Num               IN VARCHAR2,
 P_One_Time_Flag              IN VARCHAR2,
 P_Parent_Vendor_Id           IN NUMBER,
 P_Min_Order_Amount           IN NUMBER,
 P_Ship_To_Location_Id        IN NUMBER,
 P_Bill_To_Location_Id        IN NUMBER,
 P_Ship_Via_Lookup_Code       IN VARCHAR2,
 P_Freight_Terms_Lookup_Code  IN VARCHAR2,
 P_Fob_Lookup_Code            IN VARCHAR2,
 P_Terms_Id                   IN NUMBER,
 P_Set_Of_Books_Id            IN NUMBER,
 P_Always_Take_Disc_Flag      IN VARCHAR2,
 P_Pay_Date_Basis_Lookup_Code IN VARCHAR2,
 P_Pay_Group_Lookup_Code      IN VARCHAR2,
 P_Payment_Priority           IN NUMBER,
 P_Invoice_Currency_Code      IN VARCHAR2,
 P_Payment_Currency_Code      IN VARCHAR2,
 P_Invoice_Amount_Limit       IN NUMBER,
 P_Hold_All_Payments_Flag     IN VARCHAR2,
 P_Hold_Future_Payments_Flag  IN VARCHAR2,
 P_Hold_Reason                IN VARCHAR2,
 P_Distribution_Set_Id        IN NUMBER,
 P_Accts_Pay_CCID             IN NUMBER,
 P_Future_Dated_Payment_CCID  IN NUMBER,
 P_Prepay_CCID                IN NUMBER,
 P_Num_1099                   IN VARCHAR2,
 P_Type_1099                  IN VARCHAR2,
 P_Withholding_Stat_Lookup_Code   IN VARCHAR2,
 P_Withholding_Start_Date     IN DATE,
 P_Org_Type_Lookup_Code       IN VARCHAR2,
 P_Vat_Code                   IN VARCHAR2,
 P_Start_Date_Active          IN DATE,
 P_End_Date_Active            IN DATE,
 P_Qty_Rcv_Tolerance          IN NUMBER,
 P_Minority_Group_Lookup_Code IN VARCHAR2,
 P_Payment_Method_Lookup_Code IN VARCHAR2,
 P_Bank_Account_Name          IN VARCHAR2,
 P_Bank_Account_Num           IN VARCHAR2,
 P_Bank_Num                   IN VARCHAR2,
 P_Bank_Account_Type          IN VARCHAR2,
 P_Women_Owned_Flag           IN VARCHAR2,
 P_Small_Business_Flag        IN VARCHAR2,
 P_Standard_Industry_Class    IN VARCHAR2,
 P_Attribute_Category         IN VARCHAR2,
 P_Attribute1                 IN VARCHAR2,
 P_Attribute2                 IN VARCHAR2,
 P_Attribute3                 IN VARCHAR2,
 P_Attribute4                 IN VARCHAR2,
 P_Attribute5                 IN VARCHAR2,
 P_Hold_Flag                  IN VARCHAR2,
 P_Purchasing_Hold_Reason     IN VARCHAR2,
 P_Hold_By                    IN NUMBER,
 P_Hold_Date                  IN DATE,
 P_Terms_Date_Basis           IN VARCHAR2,
 P_Price_Tolerance            IN NUMBER,
 P_Attribute10                IN VARCHAR2,
 P_Attribute11                IN VARCHAR2,
 P_Attribute12                IN VARCHAR2,
 P_Attribute13                IN VARCHAR2,
 P_Attribute14                IN VARCHAR2,
 P_Attribute15                IN VARCHAR2,
 P_Attribute6                 IN VARCHAR2,
 P_Attribute7                 IN VARCHAR2,
 P_Attribute8                 IN VARCHAR2,
 P_Attribute9                 IN VARCHAR2,
 P_Days_Early_Receipt_Allowed IN NUMBER,
 P_Days_Late_Receipt_Allowed  IN NUMBER,
 P_Enforce_Ship_To_Loc_Code   IN VARCHAR2,
 P_Exclusive_Payment_Flag     IN VARCHAR2,
 P_Federal_Reportable_Flag    IN VARCHAR2,
 P_Hold_Unmatched_Invoices_Flag   IN VARCHAR2,
 P_Match_Option               IN VARCHAR2,
 P_Create_Debit_Memo_Flag     IN VARCHAR2,
 P_Inspection_Required_Flag   IN VARCHAR2,
 P_Receipt_Required_Flag      IN VARCHAR2,
 P_Receiving_Routing_Id       IN NUMBER,
 P_State_Reportable_Flag      IN VARCHAR2,
 P_Tax_Verification_Date      IN DATE,
 P_Auto_Calculate_Interest_Flag    IN VARCHAR2,
 P_Name_Control               IN VARCHAR2,
 P_Allow_Subst_Receipts_Flag  IN VARCHAR2,
 P_allow_Unord_Receipts_Flag  IN VARCHAR2,
 P_Receipt_Days_Exception_Code    IN VARCHAR2,
 P_Qty_Rcv_Exception_Code     IN VARCHAR2,
 P_Offset_Tax_Flag            IN VARCHAR2,
 P_Exclude_Freight_From_Disc  IN VARCHAR2,
 P_Vat_Registration_Num       IN VARCHAR2,
 P_Tax_Reporting_Name         IN VARCHAR2,
 P_Awt_Group_Id               IN NUMBER,
 P_Check_Digits               IN VARCHAR2,
 P_Bank_Number                IN VARCHAR2,
 P_Allow_Awt_Flag             IN VARCHAR2,
 P_Bank_Branch_Type           IN VARCHAR2,
 P_EDI_Payment_Method         IN VARCHAR2,
 P_EDI_Payment_Format         IN VARCHAR2,
 P_EDI_Remittance_Method      IN VARCHAR2,
 P_EDI_Remittance_Instruction IN VARCHAR2,
 P_EDI_transaction_handling   IN VARCHAR2,
 P_Auto_Tax_Calc_Flag         IN VARCHAR2,
 P_Auto_Tax_Calc_Override     IN VARCHAR2,
 P_Amount_Includes_Tax_Flag   IN VARCHAR2,
 P_AP_Tax_Rounding_Rule       IN VARCHAR2,
 P_Vendor_Name_Alt            IN VARCHAR2,
 P_global_attribute_category  IN VARCHAR2,
 P_global_attribute1          IN VARCHAR2,
 P_global_attribute2          IN VARCHAR2,
 P_global_attribute3          IN VARCHAR2,
 P_global_attribute4          IN VARCHAR2,
 P_global_attribute5          IN VARCHAR2,
 P_global_attribute6          IN VARCHAR2,
 P_global_attribute7          IN VARCHAR2,
 P_global_attribute8          IN VARCHAR2,
 P_global_attribute9          IN VARCHAR2,
 P_global_attribute10         IN VARCHAR2,
 P_global_attribute11         IN VARCHAR2,
 P_global_attribute12         IN VARCHAR2,
 P_global_attribute13         IN VARCHAR2,
 P_global_attribute14         IN VARCHAR2,
 P_global_attribute15         IN VARCHAR2,
 P_global_attribute16         IN VARCHAR2,
 P_global_attribute17         IN VARCHAR2,
 P_global_attribute18         IN VARCHAR2,
 P_global_attribute19         IN VARCHAR2,
 P_global_attribute20         IN VARCHAR2,
 P_bank_charge_bearer         IN VARCHAR2) IS

  CURSOR  C_SUPPLIER_TYPE IS
    SELECT POV.VENDOR_ID
      FROM ap_suppliers POV , ZX_PARTY_TAX_PROFILE PTP
     WHERE POV.VENDOR_ID  = PTP.PARTY_ID
       AND POV.VENDOR_ID = p_vendor_id
       AND PTP.PARTY_TYPE_CODE = 'SUPPLIER'
       AND VENDOR_TYPE_LOOKUP_CODE is not null
       AND VENDOR_TYPE_LOOKUP_CODE <> 'TAX AUTHORITY';

  l_party_tax_profile_id zx_party_tax_profile.party_tax_profile_id%type;
  l_status fnd_module_installations.status%TYPE;
  l_db_status fnd_module_installations.DB_STATUS%TYPE;

 BEGIN

    IF P_DML_TYPE = 'I' THEN
      arp_util_tax.debug(' Insert of SYNC SUPPLIERS(+) ' );

      INSERT INTO
        ZX_PARTY_TAX_PROFILE(
         Party_Tax_Profile_Id
        ,Party_Id
        ,Party_Type_code
        ,Customer_Flag
        ,First_Party_Le_Flag
        ,Supplier_Flag
        ,Site_Flag
        ,Legal_Establishment_Flag
        ,Rounding_Level_code
        ,Process_For_Applicability_Flag
        ,ROUNDING_RULE_CODE
        ,Inclusive_Tax_Flag
        ,Use_Le_As_Subscriber_Flag
        ,Effective_From_Use_Le
        ,Reporting_Authority_Flag
        ,Collecting_Authority_Flag
        ,PROVIDER_TYPE_CODE
        ,RECORD_TYPE_CODE
        ,TAX_CLASSIFICATION_CODE
        ,Self_Assess_Flag
        ,Allow_Offset_Tax_Flag
        ,Created_By
        ,Creation_Date
        ,Last_Updated_By
        ,Last_Update_Date
        ,Last_Update_Login)
      VALUES(
        ZX_PARTY_TAX_PROFILE_S.NEXTVAL
        ,P_VENDOR_ID -- Party ID
        ,'SUPPLIER' -- Party Type
        ,'N' -- Customer_Flag
        ,'N' -- First Party
        ,'Y' -- Suppliers
        ,'N' -- Site
        ,'N' -- Establishment
        ,decode(nvl(p_auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE')
        ,decode(nvl(p_auto_tax_calc_flag, 'N'), 'N', 'N', 'Y')
        ,DECODE (P_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN','UP')
        ,nvl(p_amount_includes_tax_flag,'N')
        ,'N' -- Use_Le_As_Subscriber_Flag
        ,NULL -- Effective_From_Use_Le
        ,'N' -- Reporting Authority Flag
        ,'N'  -- Collecting Authority Flag
        ,NULL -- Provider Type
        ,'MIGRATED' -- Record Type
        ,p_vat_code --   Tax Classification
        ,'N' -- Self_Assess_Flag
        ,nvl(p_offset_tax_flag,'N') -- Allow_Offset_Tax_Flag
        ,fnd_global.user_id   -- Who Columns
        ,SYSDATE     -- Who Columns
        ,fnd_global.user_id   -- Who Columns
        ,SYSDATE     -- Who Columns
        ,FND_GLOBAL.CONC_LOGIN_ID);   -- Who Columns


      INSERT INTO
        ZX_REGISTRATIONS(
        Registration_Id,
        Registration_Type_Code,
        Registration_Number,
        Registration_Status_Code,
        Registration_Source_Code,
        Registration_Reason_Code,
        Party_Tax_Profile_Id,
        Tax_Authority_Id,
        Coll_Tax_Authority_Id,
        Rep_Tax_Authority_Id,
        Tax,
        Tax_Regime_Code,
        ROUNDING_RULE_CODE,
        Tax_Jurisdiction_Code,
        Self_Assess_Flag,
        Inclusive_Tax_Flag,
        Effective_From,
        Effective_To,
        Rep_Party_Tax_Name,
        Legal_Registration_Id,
        Default_Registration_Flag,
        RECORD_TYPE_CODE,
        Created_By,
        Creation_Date,
        Last_Updated_By,
        Last_Update_Date,
        Last_Update_Login)
       (SELECT
        ZX_REGISTRATIONS_S.NEXTVAL
        ,Null -- Type
        ,decode(p_GLOBAL_ATTRIBUTE_CATEGORY,
        'JL.AR.APXVDMVD.SUPPLIERS',p_Global_Attribute12,
        'JL.CL.APXVDMVD.SUPPLIERS',p_Global_Attribute12,
        'JL.CO.APXVDMVD.SUPPLIERS',p_Global_Attribute12,
        P_Vat_Registration_Num) -- Reg Number
        --Bug # 3594759
        ,decode(p_GLOBAL_ATTRIBUTE_CATEGORY,
        'JL.AR.APXVDMVD.SUPPLIERS',p_Global_Attribute1,
        'REGISTERED') -- Registration_Status_code
        ,'EXPLICIT' -- Registration_Source_Code
        ,NULL -- Registration_Reason_Code
        ,PTP.Party_Tax_Profile_ID
        ,NULL -- Tax Authority ID
        ,NULL -- Collecting Tax Authority ID
        ,NULL -- Reporting Tax Authority ID
        ,NULL -- Tax
        ,NULL -- TAX_Regime_Code
        ,PTP.ROUNDING_RULE_CODE
        ,NULL -- Tax Jurisdiction Code
        , PTP.Self_Assess_Flag  -- Self Assess
        ,PTP.Inclusive_Tax_Flag
        ,nvl(P_Start_Date_Active, Sysdate) -- Effective from
        ,P_End_Date_Active -- Effective to
        ,NULL -- Rep_Party_Tax_Name
        ,NULL -- Legal Registration_ID
        ,'Y'  -- Default Registration Flag
        ,'MIGRATED' -- Record Type
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,FND_GLOBAL.CONC_LOGIN_ID
      FROM  zx_party_tax_profile ptp
      WHERE   PTP.Party_ID = P_VENDOR_ID
        AND PTP.Party_Type_code = 'SUPPLIER');

  arp_util_tax.debug(' Now calling SUPPLIER_TYPE_EXTRACT ' );

      SELECT  PTP.PARTY_TAX_PROFILE_ID
      INTO  l_party_tax_profile_id
           FROM     ZX_PARTY_TAX_PROFILE PTP
      WHERE   PTP.PARTY_ID= P_VENDOR_ID
        AND PTP.PARTY_TYPE_CODE = 'SUPPLIER'
        AND P_Vendor_Type_Lookup_Code is not null
        AND P_Vendor_Type_Lookup_Code <> 'TAX AUTHORITY' ;


      ZX_PTP_MIGRATE_PKG.Party_Assoc_Extract
                                (p_party_source=>'ZX_PARTY_TAX_PROFILE',
                                 p_party_tax_profile_id  => l_party_tax_profile_id,
                                 p_fiscal_class_type_code=> 'SUPPLIER_TYPE',
                                 p_fiscal_classification_code=>P_Vendor_Type_Lookup_Code,
                                 p_dml_type =>'I');



       END IF; -- For P_DML_TYPE = 'I'

  IF P_DML_TYPE = 'U' THEN

  arp_util_tax.debug(' Update of SYNC SUPPLIERS (+) ' );


    UPDATE  ZX_PARTY_TAX_PROFILE
       SET     Rounding_Level_code =
      decode(nvl(p_auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE'),
      Process_For_Applicability_Flag =
      decode(nvl(p_auto_tax_calc_flag, 'N'), 'N', 'N', 'Y'),
      ROUNDING_RULE_CODE=
      DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN','UP'),
      Inclusive_Tax_Flag=
      nvl(p_amount_includes_tax_flag,'N'),
      TAX_CLASSIFICATION_CODE=
      p_vat_code, --  Tax Classification
      Allow_Offset_Tax_Flag=
      nvl(p_Offset_Tax_Flag,'N'), -- Allow_Offset_Tax_Flag,
      Last_updated_By=fnd_global.user_id,
      Last_update_Date=SYSDATE,
      Last_update_Login=FND_GLOBAL.CONC_LOGIN_ID
    WHERE   party_tax_profile_id=p_vendor_id  and
      party_type_code ='SUPPLIER';

      UPDATE  ZX_REGISTRATIONS
      SET     Registration_Number = decode(p_GLOBAL_ATTRIBUTE_CATEGORY,
        'JL.AR.APXVDMVD.SUPPLIERS',p_Global_Attribute12,
        'JL.CL.APXVDMVD.SUPPLIERS',p_Global_Attribute12,
        'JL.CO.APXVDMVD.SUPPLIERS',p_Global_Attribute12,
        P_Vat_Registration_Num) ,  -- Reg Number
        Registration_Status_code = decode(p_GLOBAL_ATTRIBUTE_CATEGORY,
        'JL.AR.APXVDMVD.SUPPLIERS',p_Global_Attribute1,
        'REGISTERED') , -- Registration_Status_code
        ROUNDING_RULE_CODE =  decode(nvl(p_auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE'),
        Inclusive_Tax_Flag = nvl(p_amount_includes_tax_flag,'N'),
        Effective_From = nvl(p_start_date_active, Sysdate),
        Effective_To = p_end_date_active,
        Last_Updated_By = fnd_global.user_id,
        Last_Update_Date = SYSDATE,
        Last_Update_Login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE   Party_tax_profile_id in (select party_tax_profile_id
        from zx_party_tax_profile where party_id
        = p_vendor_id and party_type_code = 'SUPPLIER');


       SELECT  PTP.PARTY_TAX_PROFILE_ID
                        INTO    l_party_tax_profile_id
                        FROM    ZX_PARTY_TAX_PROFILE PTP
                        WHERE   PTP.PARTY_ID= P_VENDOR_ID
                                AND PTP.PARTY_TYPE_CODE = 'SUPPLIER'
                                AND P_VENDOR_TYPE_LOOKUP_CODE is not null
                                AND P_VENDOR_TYPE_LOOKUP_CODE <> 'TAX AUTHORITY';


                        ZX_PTP_MIGRATE_PKG.Party_Assoc_Extract
                                (p_party_source=>'ZX_PARTY_TAX_PROFILE',
                                 p_party_tax_profile_id  => l_party_tax_profile_id,
                                 p_fiscal_class_type_code=> 'SUPPLIER_TYPE',
                                 p_fiscal_classification_code=>P_Vendor_Type_Lookup_Code,
                                 p_dml_type =>'U');

       END IF; -- For P_DML_TYPE = 'U'

  arp_util_tax.debug(' SYNC_SUPPLIERS(-) ' );

     EXCEPTION
                WHEN OTHERS THEN
                arp_util_tax.debug('Exception: Error Occurred during Supplier synchronization ..'||SQLERRM );

 END SYNC_SUPPLIERS;


 /* ==========================================================================*
 | Procedure Name: SYNC_SUPPLIER_MERGE
 | Product using
 | this Procedure : Will be called by AP, from Suppliers Merge
 |
 |
 | Purpose: Will be used to Synchronize the data between the Suppliers and
 |          eTax Party tax profile entity.
 |
 |          Will be called fro  Suppliers for  passing the attributes
 |          required for synchronization.
 |
 |          This stubbed version will do nothing.
 |
 |          In later version of the same Procedure(delivered in ZX),
 |          it will be replaced with the actual solution for synchronizing data
 |          between the source (Suppliers) and eTax Party tax profile Gateway
 |          entity.
 |
 *==========================================================================*/

PROCEDURE SYNC_SUPPLIERS_MERGE
(
P_Dml_Type                              IN VARCHAR2,
P_Vendor_Id                             IN NUMBER,
P_End_Date_Active                       IN DATE,
P_Last_Update_Date                      IN DATE,
P_Last_Updated_By                       IN NUMBER
                                       ) IS
BEGIN
     NULL;
END SYNC_SUPPLIERS_MERGE;


/* ==========================================================================*
 | Procedure Name: SYNC_SUPPLIER_SITES
 | Product using
 | this Procedure : Will be called by AP, from Suppliers Form
 |
 |
 | Purpose: Will be used to Synchronize the data between the Suppliers and
 |          eTax Party tax profile Gateway entity.
 |
 |          Will be called fro  Suppliers for  passing the attributes
 |          required for synchronization.
 |
 |          This stubbed version will do nothing.
 |
 |          In later version of the sa e Procedure(delivered in ZX),
 |          it will be replaced with the actual solution for synchronizing data
 |          between the source (Suppliers) and eTax Party tax profile Gateway
 |          entity.
 |
 *==========================================================================*/

PROCEDURE SYNC_SUPPLIER_SITES
(
P_Dml_Type       IN VARCHAR2,
P_Vendor_Site_Id          IN NUMBER,
P_Last_Update_Date        IN DATE,
P_Last_Updated_By         IN NUMBER,
P_Vendor_Id               IN NUMBER,
P_Vendor_Site_Code        IN VARCHAR2,
P_Last_Update_Login       IN NUMBER,
P_Creation_Date           IN DATE,
P_Created_By              IN NUMBER,
P_Purchasing_Site_Flag    IN VARCHAR2,
P_Rfq_Only_Site_Flag      IN VARCHAR2,
P_Pay_Site_Flag           IN VARCHAR2,
P_Attention_Ar_Flag       IN VARCHAR2,
P_Address_Line1           IN VARCHAR2,
P_Address_Line2           IN VARCHAR2,
P_Address_Line3           IN VARCHAR2,
P_City                    IN VARCHAR2,
P_State                   IN VARCHAR2,
P_Zip                     IN VARCHAR2,
P_Province                IN VARCHAR2,
P_Country                 IN VARCHAR2,
P_Area_Code               IN VARCHAR2,
P_Phone                   IN VARCHAR2,
P_Customer_Num            IN VARCHAR2,
P_Ship_To_Location_Id     IN NUMBER,
P_Bill_To_Location_Id     IN NUMBER,
P_Ship_Via_Lookup_Code    IN VARCHAR2,
P_Freight_Terms_Lookup_Code  IN VARCHAR2,
P_Fob_Lookup_Code         IN VARCHAR2,
P_Inactive_Date           IN DATE,
P_Fax                     IN VARCHAR2,
P_Fax_Area_Code           IN VARCHAR2,
P_Telex                   IN VARCHAR2,
P_Payment_Method_Lookup_Code  IN VARCHAR2,
P_Bank_Account_Name       IN VARCHAR2,
P_Bank_Account_Num        IN VARCHAR2,
P_Bank_Num                IN VARCHAR2,
P_Bank_Account_Type       IN VARCHAR2,
P_Terms_Date_Basis        IN VARCHAR2,
P_Current_Catalog_Num     IN VARCHAR2,
P_Vat_Code                IN VARCHAR2,
P_Distribution_Set_Id     IN NUMBER,
P_Accts_Pay_CCID          IN NUMBER,
P_Future_Dated_Payment_CCID  IN NUMBER,
P_Prepay_Code_Combination_Id  IN NUMBER,
P_Pay_Group_Lookup_Code   IN VARCHAR2,
P_Payment_Priority        IN NUMBER,
P_Terms_Id                IN NUMBER,
P_Invoice_Amount_Limit    IN NUMBER,
P_Pay_Date_Basis_Lookup_Code  IN VARCHAR2,
P_Always_Take_Disc_Flag   IN VARCHAR2,
P_Invoice_Currency_Code   IN VARCHAR2,
P_Payment_Currency_Code   IN VARCHAR2,
P_Hold_All_Payments_Flag  IN VARCHAR2,
P_Hold_Future_Payments_Flag  IN VARCHAR2,
P_Hold_Reason             IN VARCHAR2,
P_Hold_Unmatched_Invoices_Flag  IN VARCHAR2,
P_Match_Option            IN VARCHAR2,
P_create_debit_memo_flag  IN VARCHAR2,
P_Exclusive_Payment_Flag  IN VARCHAR2,
P_Tax_Reporting_Site_Flag IN VARCHAR2,
P_Attribute_Category      IN VARCHAR2,
P_Attribute1              IN VARCHAR2,
P_Attribute2              IN VARCHAR2,
P_Attribute3              IN VARCHAR2,
P_Attribute4              IN VARCHAR2,
P_Attribute5              IN VARCHAR2,
P_Attribute6              IN VARCHAR2,
P_Attribute7              IN VARCHAR2,
P_Attribute8              IN VARCHAR2,
P_Attribute9              IN VARCHAR2,
P_Attribute10             IN VARCHAR2,
P_Attribute11             IN VARCHAR2,
P_Attribute12             IN VARCHAR2,
P_Attribute13             IN VARCHAR2,
P_Attribute14             IN VARCHAR2,
P_Attribute15             IN VARCHAR2,
P_Validation_Number       IN NUMBER,
P_Exclude_Freight_From_Disc  IN VARCHAR2,
P_Vat_Registration_Num    IN VARCHAR2,
P_Offset_Tax_Flag         IN VARCHAR2,
P_Check_Digits            IN VARCHAR2,
P_Bank_Number             IN VARCHAR2,
P_Address_Line4           IN VARCHAR2,
P_County                  IN VARCHAR2,
P_Address_Style           IN VARCHAR2,
P_Language                IN VARCHAR2,
P_Allow_Awt_Flag          IN VARCHAR2,
P_Awt_Group_Id            IN NUMBER,
P_pay_on_code             IN VARCHAR2,
P_default_pay_site_id     IN NUMBER,
P_pay_on_receipt_summary_code   IN VARCHAR2,
P_Bank_Branch_Type        IN VARCHAR2,
P_EDI_ID_Number           IN VARCHAR2,
P_EDI_Payment_Method      IN VARCHAR2,
P_EDI_Payment_Format      IN VARCHAR2,
P_EDI_Remittance_Method   IN VARCHAR2,
P_EDI_Remittance_Instruction  IN VARCHAR2,
P_EDI_transaction_handling    IN VARCHAR2,
P_Auto_Tax_Calc_Flag          IN VARCHAR2,
P_Auto_Tax_Calc_Override      IN VARCHAR2,
P_Amount_Includes_Tax_Flag    IN VARCHAR2,
P_AP_Tax_Rounding_Rule        IN VARCHAR2,
P_Vendor_Site_Code_Alt        IN VARCHAR2,
P_Address_Lines_Alt           IN VARCHAR2,
P_global_attribute_category   IN VARCHAR2,
P_global_attribute1           IN VARCHAR2,
P_global_attribute2           IN VARCHAR2,
P_global_attribute3           IN VARCHAR2,
P_global_attribute4           IN VARCHAR2,
P_global_attribute5           IN VARCHAR2,
P_global_attribute6           IN VARCHAR2,
P_global_attribute7           IN VARCHAR2,
P_global_attribute8           IN VARCHAR2,
P_global_attribute9           IN VARCHAR2,
P_global_attribute10          IN VARCHAR2,
P_global_attribute11          IN VARCHAR2,
P_global_attribute12          IN VARCHAR2,
P_global_attribute13          IN VARCHAR2,
P_global_attribute14          IN VARCHAR2,
P_global_attribute15          IN VARCHAR2,
P_global_attribute16          IN VARCHAR2,
P_global_attribute17          IN VARCHAR2,
P_global_attribute18          IN VARCHAR2,
P_global_attribute19          IN VARCHAR2,
P_global_attribute20          IN VARCHAR2,
P_bank_charge_bearer          IN VARCHAR2,
P_ece_tp_location_code        IN VARCHAR2,
P_Pcard_Site_Flag             IN VARCHAR2,
P_Country_of_Origin_Code      IN VARCHAR2,
P_Shipping_Location_id        IN NUMBER,
P_Supplier_Notif_Method       IN VARCHAR2,
P_Email_Address               IN VARCHAR2,
P_Remittance_email            IN VARCHAR2,
P_primary_pay_site_flag       IN VARCHAR2,
P_Shipping_Control            IN VARCHAR2) IS

  l_Global_Attribute10 po_vendors.Global_Attribute10%type;
  l_Global_Attribute11 po_vendors.Global_Attribute11%type;
  l_Global_Attribute12 po_vendors.Global_Attribute12%type;
  l_Global_Attribute13 po_vendors.Global_Attribute13%type;
  l_Global_Attribute14 po_vendors.Global_Attribute14%type;


  BEGIN


    IF P_DML_TYPE = 'I' THEN
      arp_util_tax.debug(' SYNC_SUPPLIER_SITES(+) ' );

      INSERT INTO ZX_PARTY_TAX_PROFILE(
        Party_Tax_Profile_Id
        ,Party_Id
        ,Party_Type_code
        ,Customer_Flag
        ,First_Party_Le_Flag
        ,Supplier_Flag
        ,Site_Flag
        ,Legal_Establishment_Flag
        ,Rounding_Level_code
        ,Process_For_Applicability_Flag
        ,ROUNDING_RULE_CODE
        ,Inclusive_Tax_Flag
        ,Use_Le_As_Subscriber_Flag
        ,Effective_From_Use_Le
        ,Reporting_Authority_Flag
        ,Collecting_Authority_Flag
        ,PROVIDER_TYPE_CODE
        ,RECORD_TYPE_CODE
        ,TAX_CLASSIFICATION_CODE
        ,Self_Assess_Flag
        ,Allow_Offset_Tax_Flag
        ,Created_By
        ,Creation_Date
        ,Last_Updated_By
        ,Last_Update_Date
        ,Last_Update_Login)
            SELECT
        ZX_PARTY_TAX_PROFILE_S.NEXTVAL
        ,p_VENDOR_SITE_ID -- Party ID
        ,'SUPPLIER_SITE' -- Party Type
        ,'N' -- Customer_Flag
        ,'N' -- First Party
        ,'N' -- Suppliers
        ,'Y' -- Site
        ,'N' -- Establishment
        ,decode(nvl(p_auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE')
        ,decode(nvl(p_auto_tax_calc_flag, 'N'), 'N', 'N', 'Y')
        , DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST',
              'D','DOWN', 'UP')
        , nvl(p_amount_includes_tax_flag, 'N')
        ,'N' -- Use_Le_As_Subscriber_Flag
        , NULL -- Effective_From_Use_Le
        ,'N' -- Reporting Authority Flag
        ,'N'  -- Collecting Authority Flag
        ,NULL -- Provider Type
        ,'MIGRATED' -- Record Type
        ,p_vat_code --   Tax Classification
        ,'N' -- Self_Assess_Flag
        , nvl(pv.offset_tax_flag,'N') -- Allow_Offset_Tax_Flag
        , fnd_global.user_id   -- Who Columns
        ,SYSDATE     -- Who Columns
        ,fnd_global.user_id   -- Who Columns
        ,SYSDATE     -- Who Columns
        ,FND_GLOBAL.CONC_LOGIN_ID   -- Who Columns
      FROM    ap_suppliers Pv
      WHERE   p_Vendor_Site_Id = nvl(P_vendor_site_Id,p_Vendor_site_Id)
        AND p_vendor_id = pv.vendor_id
        AND pv.VENDOR_TYPE_LOOKUP_CODE <> 'TAX AUTHORITY';


      INSERT INTO ZX_REGISTRATIONS(
        Registration_Id,
        Registration_Type_Code,
        Registration_Number,
        Registration_Status_Code,
        Registration_Source_Code,
        Registration_Reason_Code,
        Party_Tax_Profile_Id,
        Tax_Authority_Id,
        Coll_Tax_Authority_Id,
        Rep_Tax_Authority_Id,
        Tax,
        Tax_Regime_Code,
        ROUNDING_RULE_CODE,
        Tax_Jurisdiction_Code,
        Self_Assess_Flag,
        Inclusive_Tax_Flag,
        Effective_From,
        Effective_To,
        Rep_Party_Tax_Name,
        Legal_Registration_Id,
        Default_Registration_Flag,
        RECORD_TYPE_CODE,
        Created_By,
        Creation_Date,
        Last_Updated_By,
        Last_Update_Date,
        Last_Update_Login)
      (SELECT
        ZX_REGISTRATIONS_S.NEXTVAL
        ,NULL -- Registration type code
        ,P_Vat_Registration_Num --Reg Number
        ,'REGISTERED' -- Registration_Status_code
        ,'EXPLICIT' -- Registration_Source_Code
        ,NULL -- Registration_Reason_Code
        ,PTP.Party_Tax_Profile_ID
        ,NULL -- Tax Authority ID
        ,NULL -- Collecting Tax Authority ID
        ,NULL -- Reporting Tax Authority ID
        ,NULL -- Tax
        ,NULL -- TAX_Regime_Code
        ,PTP.ROUNDING_RULE_CODE
        , NULL -- Tax Jurisdiction Code
        , PTP.Self_Assess_Flag  -- Self Assess
        ,PTP.Inclusive_Tax_Flag
        ,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
        ,PV.End_Date_Active -- Effective to
        ,NULL -- Rep_Party_Tax_Name
        ,NULL -- Legal Registration_ID
        ,'Y'  -- Default Registration Flag
        ,'MIGRATED' -- Record Type
        ,fnd_global.user_id
        ,SYSDATE
        ,fnd_global.user_id
        ,SYSDATE
        ,FND_GLOBAL.CONC_LOGIN_ID
         FROM  ap_suppliers PV,
         zx_party_tax_profile PTP
         WHERE
        P_vendor_site_id = PTP.Party_ID
        AND PTP.Party_Type_code = 'SUPPLIER_SITE'
        AND P_Vendor_ID = PV.Vendor_ID);


       -- Verify Argentina Installation
      IF (p_GLOBAL_ATTRIBUTE_CATEGORY='JL.AR.APXVDMVD.SUPPLIER_SITES') THEN

        -- Code for Reporting Code Association. Bug # 3594759
        -- Insert the Fiscal Printer Codes into Association table

        INSERT INTO ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE,
          ENTITY_ID,
          REPORTING_TYPE_ID,
          REPORTING_CODE_CHAR_VALUE,
          EXCEPTION_CODE,
          EFFECTIVE_FROM,
          EFFECTIVE_TO,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
        (SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
          'ZX_PARTY_TAX_PROFILE',     --ENTITY_CODE
          ptp.Party_Tax_Profile_Id,   --ENTITY_ID
          REPORTING_TYPE_ID       ,   --REPORTING_TYPE_ID
          p_GLOBAL_ATTRIBUTE18,     --REPORTING_CODE_CHAR_VALUE
          null,         --EXCEPTION_CODE
          sysdate,       --EFFECTIVE_FROM
          null,         --EFFECTIVE_TO
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.conc_login_id
        FROM  zx_party_tax_profile ptp ,
              zx_reporting_types_b
        WHERE   ptp.party_id = p_vendor_site_id and
          ptp.Party_Type_Code = 'SUPPLIER_SITE' and
          reporting_type_code = 'FISCAL PRINTER');

        -- Insert the CAI Number and Date into Association table

        INSERT INTO ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE,
          ENTITY_ID,
          REPORTING_TYPE_ID ,
          REPORTING_CODE_NUM_VALUE,
          EXCEPTION_CODE,
          EFFECTIVE_FROM,
          EFFECTIVE_TO,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
        (SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
          'ZX_PARTY_TAX_PROFILE',     --ENTITY_CODE
          ptp.Party_Tax_Profile_Id,   --ENTITY_ID
          REPORTING_TYPE_ID,     --REPORTING_TYPE_ID
          p_GLOBAL_ATTRIBUTE19,     --REPORTING_CODE_NUM_VALUE
          null,         --EXCEPTION_CODE
          sysdate,       --EFFECTIVE_FROM
          p_GLOBAL_ATTRIBUTE20,     --EFFECTIVE_TO
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.conc_login_id
        FROM  zx_party_tax_profile ptp ,
              zx_reporting_types_b
        WHERE   ptp.party_id  = p_vendor_site_id and
          ptp.Party_Type_Code = 'SUPPLIER_SITE' and
          reporting_type_code = 'CAI NUMBER');

      END IF; -- end of Argentina Installation verification

      IF (p_GLOBAL_ATTRIBUTE_CATEGORY =  'JL.BR.APXVDMVD.SITES') THEN

        -- Inserts Records for CNPJ

        INSERT INTO ZX_REGISTRATIONS(
          Registration_Id,
          Registration_Type_Code,
          Registration_Number,
          Registration_Status_Code,
          Registration_Source_Code,
          Registration_Reason_Code,
          Party_Tax_Profile_Id,
          Tax_Authority_Id,
          Coll_Tax_Authority_Id,
          Rep_Tax_Authority_Id,
          Tax,
          Tax_Regime_Code,
          ROUNDING_RULE_CODE,
          Tax_Jurisdiction_Code,
          Self_Assess_Flag,
          Inclusive_Tax_Flag,
          Effective_From,
          Effective_To,
          Rep_Party_Tax_Name,
          Legal_Registration_Id,
          Default_Registration_Flag,
          RECORD_TYPE_CODE,
          Created_By,
          Creation_Date,
          Last_Updated_By,
          Last_Update_Date,
          Last_Update_Login)
         (SELECT
          ZX_REGISTRATIONS_S.NEXTVAL
          ,'CNPJ' -- Type
          ,p_Global_Attribute10 ||' / '|| p_Global_Attribute11 ||' / '|| p_Global_Attribute12 --Reg Number
          ,'REGISTERED' -- Registration_Status_code
          ,'EXPLICIT'
          ,NULL -- Registration_Reason_Code
          ,PTP.Party_Tax_Profile_ID
          ,NULL -- Tax Authority ID
          ,NULL -- Collecting Tax Authority ID
          ,NULL -- Reporting Tax Authority ID
          ,NULL -- Tax
          ,'BR-IPI' -- Tax_Regime_Code
          ,PTP.ROUNDING_RULE_CODE
          , NULL -- Tax Jurisdiction Code
          , PTP.Self_Assess_Flag  -- Self Assess
          ,PTP.Inclusive_Tax_Flag
          ,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
          ,PV.End_Date_Active -- Effective to
          ,NULL -- Rep_Party_Tax_Name
          ,NULL -- Legal Registration_ID
          ,'Y'  -- Default Registration Flag
          ,'MIGRATED' -- Record Type
          ,fnd_global.user_id
          ,SYSDATE
          ,fnd_global.user_id
          ,SYSDATE
          ,FND_GLOBAL.CONC_LOGIN_ID
        FROM  ap_supplier_sites_all PVS,
              ap_suppliers PV,
              zx_party_tax_profile PTP
        WHERE  p_vendor_site_id = PTP.Party_ID
          AND PTP.Party_Type_code = 'SUPPLIER_SITE'
          AND p_Vendor_ID = PV.Vendor_ID);


        -- Inserts Records for State Inscription

        INSERT INTO ZX_REGISTRATIONS(
          Registration_Id,
          Registration_Type_Code,
          Registration_Number,
          Registration_Status_Code,
          Registration_Source_Code,
          Registration_Reason_Code,
          Party_Tax_Profile_Id,
          Tax_Authority_Id,
          Coll_Tax_Authority_Id,
          Rep_Tax_Authority_Id,
          Tax,
          Tax_Regime_Code,
          ROUNDING_RULE_CODE,
          Tax_Jurisdiction_Code,
          Self_Assess_Flag,
          Inclusive_Tax_Flag,
          Effective_From,
          Effective_To,
          Rep_Party_Tax_Name,
          Legal_Registration_Id,
          Default_Registration_Flag,
          RECORD_TYPE_CODE,
          Created_By,
          Creation_Date,
          Last_Updated_By,
          Last_Update_Date,
          Last_Update_Login)
        SELECT
          ZX_REGISTRATIONS_S.NEXTVAL
          ,'STATE INSCRIPTION' -- Type
          ,p_Global_Attribute13 -- State Registration Num
          ,'REGISTERED' -- Registration_Status_Code
          ,'EXPLICIT'
          ,NULL -- Registration_Reason_Code
          ,PTP.Party_Tax_Profile_ID
          ,NULL -- Tax Authority ID
          ,NULL -- Collecting Tax Authority ID
          ,NULL -- Reporting Tax Authority ID
          ,NULL -- Tax
          ,'BR-ICMS' -- Tax_Regime_Code
          ,PTP.ROUNDING_RULE_CODE
          , NULL -- Tax Jurisdiction Code
          , PTP.Self_Assess_Flag -- Self Asses
          ,PTP.Inclusive_Tax_Flag
          ,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
          ,PV.End_Date_Active -- Effective To
          ,NULL -- Rep_Party_Tax_Name
          ,NULL -- Legal Registration_ID
          ,'N'  -- Default Registration Flag
          ,'MIGRATED' -- Record Type
          ,fnd_global.user_id
          ,SYSDATE
          ,fnd_global.user_id
          ,SYSDATE
          ,FND_GLOBAL.CONC_LOGIN_ID
        FROM  ap_suppliers PV,
              zx_party_tax_profile PTP
        WHERE  p_vendor_site_id = PTP.Party_ID
          AND  PTP.Party_Type_code = 'SUPPLIER_SITE'
          AND  p_Vendor_ID = PV.Vendor_ID;

        -- Inserts Records for Municipal Inscription

        INSERT INTO ZX_REGISTRATIONS(
          Registration_Id,
          Registration_Type_Code,
          Registration_Number,
          Registration_Status_Code,
          Registration_Source_Code,
          Registration_Reason_Code,
          Party_Tax_Profile_Id,
          Tax_Authority_Id,
          Coll_Tax_Authority_Id,
          Rep_Tax_Authority_Id,
          Tax,
          Tax_Regime_Code,
          ROUNDING_RULE_CODE,
          Tax_Jurisdiction_Code,
          Self_Assess_Flag,
          Inclusive_Tax_Flag,
          Effective_From,
          Effective_To,
          Rep_Party_Tax_Name,
          Legal_Registration_Id,
          Default_Registration_Flag,
          RECORD_TYPE_CODE,
          Created_By,
          Creation_Date,
          Last_Updated_By,
          Last_Update_Date,
          Last_Update_Login)
        (SELECT
          ZX_REGISTRATIONS_S.NEXTVAL
          ,'CITY INSCRIPTION' -- Type
          ,p_Global_Attribute14 -- City Registration Num
          ,'REGISTERED' -- Registration_Status_Code
          ,'EXPLICIT'
          ,NULL -- Registration_Reason_Code
          ,PTP.Party_Tax_Profile_ID
          ,NULL -- Tax Authority ID
          ,NULL -- Collecting Tax Authority ID
          ,NULL -- Reporting Tax Authority ID
          ,NULL -- Tax
          ,'BR-ISS' -- Tax_Regime_Code
          ,PTP.ROUNDING_RULE_CODE
          ,NULL -- Tax Jurisdiction Code
          ,PTP.Self_Assess_Flag  -- Self Asses
          ,PTP.Inclusive_Tax_Flag
          ,nvl(PV.Start_Date_Active, Sysdate) -- Effective from
          ,PV.End_Date_Active -- Effective To
          ,NULL -- Rep_Party_Tax_Name
          ,NULL -- Legal Registration_ID
          ,'N'  -- Default Registration Flag
          ,'MIGRATED' -- Record Type
          ,fnd_global.user_id
          ,SYSDATE
          ,fnd_global.user_id
          ,SYSDATE
          ,FND_GLOBAL.CONC_LOGIN_ID
        FROM  ap_supplier_sites_all PVS,
              ap_suppliers PV,
              zx_party_tax_profile PTP
        WHERE p_vendor_site_id = PTP.Party_ID
          AND PTP.Party_Type_code = 'SUPPLIER_SITE'
          AND p_Vendor_ID = PV.Vendor_ID);


      END IF; --  Brazil Localizations

    END IF; -- End for insert mode

    IF P_DML_TYPE = 'U' THEN

      arp_util_tax.debug(' Update of SYNC_SUPPLIER_SITES(+) ' );


      UPDATE  ZX_PARTY_TAX_PROFILE
        SET
        Rounding_Level_code= decode(nvl(p_auto_tax_calc_flag,'L'),'L','LINE','H','HEADER','T','HEADER','LINE'),
        Process_For_Applicability_Flag =
        decode(nvl(p_auto_tax_calc_flag, 'N'), 'N', 'N', 'Y'),
        ROUNDING_RULE_CODE=
        DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN', 'UP'),
        Inclusive_Tax_Flag=nvl(p_amount_includes_tax_flag, 'N'),
        TAX_CLASSIFICATION_CODE=p_vat_code, --   Tax Classification
        Allow_Offset_Tax_Flag =nvl(p_offset_tax_flag,'N'), -- Allow_Offset_Tax_Flag
        Last_Updated_By=fnd_global.user_id,
        Last_Update_Date=SYSDATE,
        Last_Update_Login=FND_GLOBAL.CONC_LOGIN_ID
      WHERE   party_tax_profile_id= p_VENDOR_SITE_ID
        and party_TYPE_CODE = 'SUPPLIER_SITE'
        and p_vendor_id in (  SELECT  vendor_id
              FROM  ap_suppliers
              WHERE  p_vendor_id = p_vendor_id
                AND VENDOR_TYPE_LOOKUP_CODE <> 'TAX AUTHORITY' );


      SELECT  global_attribute10,global_attribute11,global_attribute12,global_attribute13,global_attribute14
      INTO   l_global_attribute10,l_global_attribute11,l_global_attribute12,l_global_attribute13,l_global_attribute14
      FROM    ap_suppliers
      WHERE   vendor_id=p_Vendor_id;


      UPDATE  ZX_REGISTRATIONS
        SET Registration_Number = P_Vat_Registration_Num, -- Reg Number
        ROUNDING_RULE_CODE = DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN', 'UP'),
        Inclusive_Tax_Flag=nvl(p_amount_includes_tax_flag, 'N'),
        Last_Updated_By=fnd_global.user_id,
        Last_Update_Date=SYSDATE,
        Last_Update_Login=FND_GLOBAL.CONC_LOGIN_ID
      WHERE  Party_tax_profile_id in (select party_tax_profile_id
                                from zx_party_tax_profile where party_id
                                = p_vendor_site_id and party_type_code = 'SUPPLIER_SITE');


      -- Verify Argentina Installation

      IF (p_GLOBAL_ATTRIBUTE_CATEGORY='JL.AR.APXVDMVD.SUPPLIER_SITES') THEN


        -- Code for Reporting Code Association. Bug # 3594759
        -- Update the Fiscal Printer Codes into Association table

        UPDATE   ZX_REPORT_CODES_ASSOC
          SET  REPORTING_CODE_CHAR_VALUE  = p_GLOBAL_ATTRIBUTE18,
               LAST_UPDATED_BY =   fnd_global.user_id,
               LAST_UPDATE_DATE =  sysdate,
               LAST_UPDATE_LOGIN = fnd_global.conc_login_id
         WHERE ENTITY_CODE = 'ZX_PARTY_TAX_PROFILE' AND
               REPORTING_TYPE_ID = (SELECT REPORTING_TYPE_ID
                                      FROM ZX_REPORTING_TYPES_B
                                    WHERE REPORTING_TYPE_CODE ='FISCAL PRINTER')
           AND ENTITY_ID in  (SELECT Party_Tax_Profile_Id
                                FROM zx_party_tax_profile ptp
                               WHERE ptp.party_id = p_vendor_site_id
                                 AND ptp.Party_Type_Code = 'SUPPLIER_SITE');


        -- Update the CAI Number and Date into Association table

       UPDATE ZX_REPORT_CODES_ASSOC
          SET REPORTING_CODE_NUM_VALUE = p_GLOBAL_ATTRIBUTE19,
              EFFECTIVE_TO = p_GLOBAL_ATTRIBUTE20,
              LAST_UPDATED_BY =   fnd_global.user_id,
              LAST_UPDATE_DATE =  sysdate,
              LAST_UPDATE_LOGIN = fnd_global.conc_login_id
          WHERE ENTITY_CODE = 'ZX_PARTY_TAX_PROFILE' AND
                REPORTING_TYPE_ID = (SELECT REPORTING_TYPE_ID
                                       FROM ZX_REPORTING_TYPES_B
                                      WHERE REPORTING_TYPE_CODE ='CAI NUMBER')
            AND ENTITY_ID in  (SELECT Party_Tax_Profile_Id
                                 FROM zx_party_tax_profile ptp
                                WHERE ptp.party_id = p_vendor_site_id
                                  AND ptp.Party_Type_Code = 'SUPPLIER_SITE');

     END IF; -- end of Argentina Installation verification


     IF (p_GLOBAL_ATTRIBUTE_CATEGORY =  'JL.BR.APXVDMVD.SITES') THEN

      -- Updates Records for CNPJ

      UPDATE  ZX_REGISTRATIONS
        SET Registration_Number = p_Global_Attribute10||' / '||p_Global_Attribute11||' / '||p_Global_Attribute12, --Reg Num
            Tax_Regime_Code = 'BR-IPI',
            ROUNDING_RULE_CODE= DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN', 'UP'),
            Inclusive_Tax_Flag=nvl(p_amount_includes_tax_flag, 'N'),
            Last_Updated_By=fnd_global.user_id,
            Last_Update_Date=SYSDATE,
            Last_Update_Login=FND_GLOBAL.CONC_LOGIN_ID
       WHERE Party_tax_profile_id in (select party_tax_profile_id
                                from zx_party_tax_profile where party_id
                                = p_vendor_site_id and party_type_code = 'SUPPLIER_SITE');


      -- Updates Records for State Inscription

      UPDATE ZX_REGISTRATIONS
        SET Registration_Number = p_Global_Attribute13,-- State Registration Num,
            Tax_Regime_Code = 'BR-ICMS',
            ROUNDING_RULE_CODE = DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN', 'UP'),
            Inclusive_Tax_Flag =nvl(p_amount_includes_tax_flag, 'N'),
            Last_Updated_By=fnd_global.user_id,
            Last_Update_Date=SYSDATE,
            Last_Update_Login=FND_GLOBAL.CONC_LOGIN_ID
      WHERE Party_tax_profile_id in (select party_tax_profile_id
                                from zx_party_tax_profile where party_id
                                = p_vendor_site_id and party_type_code = 'SUPPLIER_SITE');


      -- Updates Records for Municipal Inscription

      UPDATE ZX_REGISTRATIONS
        SET Registration_Number = p_Global_Attribute14,-- City Registration Num,
            Tax_Regime_Code = 'BR-ISS',
            ROUNDING_RULE_CODE = DECODE (p_AP_TAX_ROUNDING_RULE,'N','NEAREST','D','DOWN', 'UP'),
            Inclusive_Tax_Flag =nvl(p_amount_includes_tax_flag, 'N'),
            Last_Updated_By=fnd_global.user_id,
            Last_Update_Date=SYSDATE,
            Last_Update_Login=FND_GLOBAL.CONC_LOGIN_ID
      WHERE Party_tax_profile_id in (select party_tax_profile_id
                                from zx_party_tax_profile where party_id
                                = p_vendor_site_id and party_type_code = 'SUPPLIER_SITE');


    END IF; --  Brazil Localizations

  END IF; -- End of p_dml_type = update

  arp_util_tax.debug(' SYNC_SUPPLIER_SITES(-) ' );

  EXCEPTION
    WHEN OTHERS THEN
      arp_util_tax.debug('Exception: Error Occurred during Supplier sites Extract in PTP/REGISTRATIONS Migration '||SQLERRM );

END SYNC_SUPPLIER_SITES;

/* ==========================================================================*
 | Procedure Name: SYNC_SUPPLIER_SITES_MERGE
 | Product using
 | this Procedure : Will be called by AP, from Suppliers Merge
 |
 |
 | Purpose: Will be used to Synchronize the data between the Suppliers and
 |          eTax Party tax profile entity.
 |
 |          Will be called fro  Suppliers for  passing the attributes
 |          required for synchronization.
 |
 |          This stubbed version will do nothing.
 |
 |          In later version of the sa e Procedure(delivered in ZX),
 |          it will be replaced with the actual solution for synchronizing data
 |          between the source (Suppliers) and eTax Party tax profile Gateway
 |          entity.
 |
 *==========================================================================*/

PROCEDURE SYNC_SUPPLIER_SITES_MERGE
(
P_Dml_Type                      IN VARCHAR2,
P_Vendor_Site_Id                IN NUMBER,
P_Inactive_Date                 IN DATE,
P_Primary_Pay_Site_Flag         IN VARCHAR2,
P_Tax_Reporting_Site_Flag       IN VARCHAR2,
P_Last_Update_Date              IN DATE,
P_Last_Updated_By               IN NUMBER
                                ) IS
BEGIN

   NULL;
END SYNC_SUPPLIER_SITES_MERGE;


  /* Following Procedure Call will be placed in the appropriate
      Forms in GL */

  /* ========================================================================*
   | Procedure Name: SYNC_GL_ACCOUNT_TAX
   | Product using
   | this Procedure : Will be called by GL, from GL Tax Option Accounts
   |
   | Purpose: Will be used to Synchronize the data between the GL Tax Option
   |          Accounts and eTax Gateway entities.
   |          Will be called from GL Tax Option Accounts form, passing the
   |          attributes required for synchronization.
   |
   |          This stubbed version will do nothing.
   |
   |          In later version of the same Procedure(delivered in ZX),
   |          it will be replaced with the actual solution for synchronizing
   |          data between the source (GL tax option accounts) and eTax
   |          ZX_CONDITIONS_GATEWAY and  ZX_RULES_GATEWAY Gateway entities.
   |
   | Modification History:
   |
    *=======================================================================*/

PROCEDURE SYNC_GL_ACCOUNT_TAX
  (
  P_Dml_Type                           IN VARCHAR2,
  P_RowId                              IN VARCHAR2,
  P_Set_Of_Books_Id                    IN NUMBER,
  P_Org_id                             IN NUMBER,
  P_Account_Segment_Value              IN VARCHAR2,
  P_Tax_Type_Code                      IN VARCHAR2,
  P_Allow_Tax_Code_Override_Flag       IN VARCHAR2,
  P_Amount_Includes_Tax_Flag           IN VARCHAR2,
  P_Creation_Date                      IN DATE,
  P_Created_By                         IN NUMBER,
  P_Last_Update_Date                   IN DATE,
  P_Last_Updated_By                    IN NUMBER,
  P_Last_Update_Login                  IN NUMBER,
  P_Tax_Code                           IN VARCHAR2,
  P_Context                            IN VARCHAR2,
  P_Attribute1                         IN VARCHAR2,
  P_Attribute2                         IN VARCHAR2,
  P_Attribute3                         IN VARCHAR2,
  P_Attribute4                         IN VARCHAR2,
  P_Attribute5                         IN VARCHAR2,
  P_Attribute6                         IN VARCHAR2,
  P_Attribute7                         IN VARCHAR2,
  P_Attribute8                         IN VARCHAR2,
  P_Attribute9                         IN VARCHAR2,
  P_Attribute10                        IN VARCHAR2,
  P_Attribute11                        IN VARCHAR2,
  P_Attribute12                        IN VARCHAR2,
  P_Attribute13                        IN VARCHAR2,
  P_Attribute14                        IN VARCHAR2,
  P_Attribute15                        IN VARCHAR2) IS

l_tax VARCHAR2(30);
BEGIN

      arp_util_tax.debug('SYNC_GL_ACCOUNT_TAX(+)');
      null;
      arp_util_tax.debug('SYNC_GL_ACCOUNT_TAX(-)');

END SYNC_GL_ACCOUNT_TAX;

/* Following Function Call  will be placed in the appropriate
    Form in HR */

  /* ========================================================================*
  | Function Name: IS_HR_LOCATION_UPDATE_ALLOWED
  | Product using
  | this function : Will be called by HR, from Locations Form
  |
  | Purpose: Will be used to lock the Tax Attributes on Locations
  |          Form.
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax Defintion
  |          migration starts. Tax attributes in Location Form
  |          should be  ade non-updateable,if value returned is FALSE.
  |
  *=========================================================================*/

  FUNCTION IS_HR_LOCATION_UPDATE_ALLOWED
  (
   p_location_id IN     HR_LOCATIONS_ALL.LOCATION_ID%TYPE
   ) RETURN BOOLEAN IS

  BEGIN

  RETURN TRUE;

  END IS_HR_LOCATION_UPDATE_ALLOWED;

 /* ===========================================================================*
  | Function Name: IS_PO_TAX_DEF_UPDATE_ALLOWED
  | Product using
  | this function : Will be called by PO, from System Options Form
  |
  | Purpose: Will be used to lock the Tax Attributes on PO System Options
  |          Form.
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax Defaulting
  |          migration starts. Tax attributes in PO System Options Form
  |          should be  ade non-updateable,if value returned is FALSE.
  |
  *===========================================================================*/


 FUNCTION  IS_PO_TAX_DEF_UPDATE_ALLOWED
 (
  p_org_id IN po_system_parameters.org_id%TYPE
  ) RETURN BOOLEAN IS

  BEGIN

       RETURN TRUE;
  END IS_PO_TAX_DEF_UPDATE_ALLOWED;

 /* Following Functions and Procedures Calls will be placed in the appropriate
    Forms in AR */

 /* ========================================================================*
  | Function Name: IS_AR_TAX_UPDATE_ALLOWED
  |
  | Product using
  | this function : Will be called by AR, from Receivables Option Form
  |
  | Purpose: Will be used to lock the Tax Attributes on 'Tax' Tab in
  |          Receivables Option Form
  |
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax definition
  |          migration starts. Tax attributes in 'Tax' Tab
  |          should be made non-updateable in the System Option Form,
  |          if value returned is FALSE.
  |
  *=========================================================================*/

  FUNCTION IS_AR_TAX_UPDATE_ALLOWED
  (
   p_org_id IN     ar_system_parameters.org_id%TYPE
   ) RETURN BOOLEAN IS

  BEGIN

      RETURN TRUE;

   END IS_AR_TAX_UPDATE_ALLOWED;

 /* ========================================================================*
  | Function Name: IS_AR_TAX_DEF_UPDATE_ALLOWED
  |
  | Product using
  | this function : Will be called by AR, from Receivables Option Form
  |
  | Purpose: Will be used to lock the Tax Attributes on 'Tax Defaults
  |          and Rules' Tab in Receivables Option Form
  |
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |          A value of FALSE would be returned if eTax defaulting hierarchy
  |          migration starts. Tax attributes in Receivables 'Tax Defaults
  |          and Rules' should be made non-updateable in the Option Form,
  |          if value returned is FALSE.
  |
  *=========================================================================*/

  FUNCTION IS_AR_TAX_DEF_UPDATE_ALLOWED
  (
   p_org_id IN     ar_system_parameters.org_id%TYPE
   ) RETURN BOOLEAN IS

  BEGIN

      RETURN TRUE;

   END IS_AR_TAX_DEF_UPDATE_ALLOWED;

 /* ========================================================================*
  | Function Name: IS_JL_LTE_GDF_UPDATE_ALLOWED
  |
  | Product using
  | this function : Will be called by JL from various Core Forms to decide
  |                 on whether updates to GDF is allowed or not.
  |
  | Purpose: Will be used to lock GDF Attributes of LTE feature
  |
  |          A value of TRUE will be returned in this skeleton version.
  |
  |          In later version of the same function (delivered in ZX),
  |          it will be replaced with the actual solution.
  |
  *=========================================================================*/
  FUNCTION IS_JL_LTE_GDF_UPDATE_ALLOWED
     RETURN BOOLEAN IS

  BEGIN

      RETURN TRUE;

   END IS_JL_LTE_GDF_UPDATE_ALLOWED;



  /* Following Procedure Calls will be placed in the appropriate
    Forms in AP (tax), that are owned by Tax */


 /* =========================================================================*
  | Procedure Name: SYNC_AR_TAX_GROUP_CODES
  | Purpose: Will be used to Synchronize the data between the Tax Groups and
  |          eTax Conditions and Rules gateway entity.
  |
  |          Will be called from  Tax Group form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the same Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Group) and eTax Conditions and Rules
  |          Gateway entity
  |
  | Modification History:
  | 30-Jan-2004  Srinivas Lokam     Added code for the synchronization of
  |                                 eBTax entities for default tax
  |                                 hierarchy setup.Code will insert
  |                                 AP/PO tax default hierarchy related
  |                                 eBTax RULES entities, whenever
  |                                 new tax code(s) within the Tax group is
  |                                 inserted in AP Tax groups Form.
  |
  *=========================================================================*/

PROCEDURE SYNC_AR_TAX_GROUP_CODES
(
P_DML_TYPE           IN VARCHAR2,
P_TAX_GROUP_CODE_ID  IN NUMBER,
P_CREATED_BY         IN NUMBER,
P_CREATION_DATE      IN DATE,
P_LAST_UPDATED_BY    IN NUMBER,
P_LAST_UPDATE_DATE   IN DATE,
P_LAST_UPDATE_LOGIN  IN NUMBER,
P_TAX_GROUP_TYPE     IN VARCHAR2,
P_TAX_GROUP_ID       IN NUMBER,
P_DISPLAY_ORDER      IN NUMBER,
P_TAX_CODE_ID        IN NUMBER,
P_TAX_CONDITION_ID   IN NUMBER,
P_TAX_EXCEPTION_ID   IN NUMBER,
P_START_DATE         IN DATE,
P_END_DATE           IN DATE,
P_ENABLED_FLAG             IN VARCHAR2,
P_COMPOUNDING_PRECEDENCE   IN NUMBER,
P_ORG_ID                   IN NUMBER,
P_ATTRIBUTE_CATEGORY       IN VARCHAR2,
P_ATTRIBUTE1               IN VARCHAR2 ,
P_ATTRIBUTE2               IN VARCHAR2,
P_ATTRIBUTE3               IN VARCHAR2,
P_ATTRIBUTE4               IN VARCHAR2,
P_ATTRIBUTE5               IN VARCHAR2,
P_ATTRIBUTE6               IN VARCHAR2,
P_ATTRIBUTE7               IN VARCHAR2,
P_ATTRIBUTE8               IN VARCHAR2,
P_ATTRIBUTE9               IN VARCHAR2,
P_ATTRIBUTE10              IN VARCHAR2,
P_ATTRIBUTE11              IN VARCHAR2,
P_ATTRIBUTE12              IN VARCHAR2,
P_ATTRIBUTE13              IN VARCHAR2,
P_ATTRIBUTE14              IN VARCHAR2,
P_ATTRIBUTE15              IN VARCHAR2,
P_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2,
P_GLOBAL_ATTRIBUTE1        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE2        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE3        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE4        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE5        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE6        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE7        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE8        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE9        IN VARCHAR2,
P_GLOBAL_ATTRIBUTE10       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE11       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE12       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE13       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE14       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE15       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE16       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE17       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE18       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE19       IN VARCHAR2,
P_GLOBAL_ATTRIBUTE20       IN VARCHAR2) IS

l_tax VARCHAR2(30);
l_name VARCHAR2(30);
  BEGIN
    arp_util_tax.debug('SYNC_AR_TAX_GROUP_CODES(+)');
    IF P_TAX_GROUP_TYPE = 'AP' AND P_DML_TYPE = 'I' THEN
      /* Following code creates the RULEs gateway entities for the Tax codes
         within the Tax groups,where as the associated CONDITIONs entities
         for the corresponding Tax group was already created in
         SYNC process of the AP_TAX_CODES */
      -- For Sync of Default Hierarchy
      SELECT  DECODE(global_attribute_category,
                    'JE.CZ.APXTADTC.TAX_ORIGIN', global_attribute1,
                    'JE.HU.APXTADTC.TAX_ORIGIN', global_attribute1,
                    'JE.PL.APXTADTC.TAX_ORIGIN', global_attribute1,
                    'JE.CH.APXTADTC.TAX_INFO',   global_attribute1,
                     zx_migrate_util.GET_TAX(name, tax_type)
                      ),
              NAME
       INTO l_tax,l_name
       FROM AP_TAX_CODES_ALL
      WHERE TAX_ID = P_TAX_CODE_ID;

      Zx_Migrate_Tax_Default_Hier.create_rules(l_tax);
      Zx_Migrate_Tax_Default_Hier.create_process_results
                                       (p_tax_id      =>  p_tax_code_id,
                                        p_sync_module => 'AP');
       -- End of sync for Default Hierarchy
    ELSIF P_TAX_GROUP_TYPE = 'AR' AND P_DML_TYPE = 'I' THEN
      -- For Sync of Default Hierarchy

      SELECT DECODE(global_attribute_category,
                'JE.CZ.ARXSUVAT.TAX_ORIGIN', global_attribute1,
                'JE.HU.ARXSUVAT.TAX_ORIGIN', global_attribute1,
                'JE.PL.ARXSUVAT.TAX_ORIGIN', global_attribute1,
                 Zx_Migrate_Util.GET_TAX( tax_code, tax_type) ),
             tax_code
        INTO l_tax , l_name
        FROM AR_VAT_TAX_ALL
       WHERE VAT_TAX_ID = P_TAX_CODE_ID;

                Zx_Migrate_Tax_Default_Hier.create_rules(l_tax);
                Zx_Migrate_Tax_Default_Hier.create_process_results
                                             (p_tax_id      =>  p_tax_code_id,
                                              p_sync_module => 'AR');
             -- End of sync for Default Hierarchy

       END IF;
       arp_util_tax.debug('SYNC_AR_TAX_GROUP_CODES(-)');
END SYNC_AR_TAX_GROUP_CODES;


 /* =========================================================================*
  | Procedure Name: SYNC_AP_TAX_CODES
  |
  | Purpose: Will be used to Synchronize the data between the Tax Codes and
  |          eTax Tax Definition Gateway entity.
  |
  |          Will be called from Tax Codes form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the sa e Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Codes) and eTax Tax Definition
  |          Gateway entity
  |
  | Modification History:
  | 30-Jan-2004  Srinivas Lokam     Added code for the synchronization of
  |                                 eBTax entities for both Tax Definition and
  |                                 default AP tax hierarchy setup.
  |                                 For Tax Definition entities:-
  |                                  Creates associated ZX_RATES_B,ZX_STATUS_B,
  |                                 ZX_TAXES_B,ZX_REGIMES_B and also creates
  |                                 ZX_CONDITIONS, ZX_RULES_B,ZX_PROCESS_RESULTS
  |                                 based on recoveryr rates(rules) setup of
  |                                 newly created Tax codes.
  |                                 For Tax Default Hierarchy:-
  |                                  Creates associated ZX_CONDITIONS,ZX_RULES,
  |                                 ZX_PROCESS_RESULTS for newly created
  |                                 Tax codes.
  |
  *=========================================================================*/

PROCEDURE SYNC_AP_TAX_CODES
(
P_DML_TYPE               IN      VARCHAR2,
P_NAME                            IN  VARCHAR2,
P_LAST_UPDATE_DATE                IN  DATE,
P_LAST_UPDATED_BY                 IN  NUMBER,
P_TAX_TYPE                        IN  VARCHAR2,
P_SET_OF_BOOKS_ID                 IN  NUMBER,
P_DESCRIPTION                     IN  VARCHAR2,
P_TAX_RATE                        IN  NUMBER,
P_TAX_CODE_COMBINATION_ID         IN  NUMBER,
P_INACTIVE_DATE                   IN  DATE,
P_LAST_UPDATE_LOGIN               IN  NUMBER,
P_CREATION_DATE                   IN  DATE,
P_CREATED_BY                      IN  NUMBER,
P_ATTRIBUTE_CATEGORY              IN  VARCHAR2,
P_ATTRIBUTE1                      IN  VARCHAR2,
P_ATTRIBUTE2                      IN  VARCHAR2,
P_ATTRIBUTE3                      IN  VARCHAR2,
P_ATTRIBUTE4                      IN  VARCHAR2,
P_ATTRIBUTE5                      IN  VARCHAR2,
P_ATTRIBUTE6                      IN  VARCHAR2,
P_ATTRIBUTE7                      IN  VARCHAR2,
P_ATTRIBUTE8                      IN  VARCHAR2,
P_ATTRIBUTE9                      IN  VARCHAR2,
P_ATTRIBUTE10                     IN  VARCHAR2,
P_ATTRIBUTE11                     IN  VARCHAR2,
P_ATTRIBUTE12                     IN  VARCHAR2,
P_ATTRIBUTE13                     IN  VARCHAR2,
P_ATTRIBUTE14                     IN  VARCHAR2,
P_ATTRIBUTE15                     IN  VARCHAR2,
P_AWT_VENDOR_ID                   IN  NUMBER,
P_AWT_VENDOR_SITE_ID              IN  NUMBER,
P_AWT_PERIOD_TYPE                 IN  VARCHAR2,
P_AWT_PERIOD_LIMIT                IN  NUMBER,
P_RANGE_AMOUNT_BASIS              IN  VARCHAR2,
P_RANGE_PERIOD_BASIS              IN  VARCHAR2,
P_ORG_ID                          IN  NUMBER,
P_VAT_TRANSACTION_TYPE            IN  VARCHAR2,
P_TAX_ID                          IN  NUMBER,
P_GLOBAL_ATTRIBUTE_CATEGORY       IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE1               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE2               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE3               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE4               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE5               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE6               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE7               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE8               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE9               IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE10              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE11              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE12              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE13              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE14              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE20              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE19              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE18              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE17              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE15              IN  VARCHAR2,
P_GLOBAL_ATTRIBUTE16              IN  VARCHAR2,
P_WEB_ENABLED_FLAG                IN  VARCHAR2,
P_TAX_RECOVERY_RULE_ID            IN  NUMBER,
P_TAX_RECOVERY_RATE               IN  NUMBER,
P_START_DATE                      IN  DATE,
P_ENABLED_FLAG                    IN  VARCHAR2,
P_AWT_RATE_TYPE                   IN  VARCHAR2,
P_OFFSET_TAX_CODE_ID              IN  NUMBER,
P_SUPPRESS_ZERO_AMOUNT_FLAG       IN  VARCHAR2) IS

l_tax VARCHAR2(30);

BEGIN
   IF PG_DEBUG = 'Y' THEN
     arp_util_tax.debug('SYNC_AP_TAX_CODES (+)');
   END IF;

   --IF control_table THEN

  IF p_dml_type = 'I' AND p_tax_type <> 'AWT' THEN
    Zx_Migrate_Tax_Def.Create_Tax_Classifications(p_tax_id);
  END IF;

        IF p_dml_type = 'I' AND p_tax_type = 'TAX_GROUP' THEN
        -- For Sync of Default Hierarchy
        /* Following code creates CONDITION's entities for the new
           TAX GROUP and the associated RULE entities for each
           Tax code within the Tax Group will be created in the SYNC process
           of AR_TAX_GROUP_CODES */
           Zx_Migrate_Tax_Default_Hier.create_condition_groups(p_name);
        -- End of sync for Default Hierarchy

        ELSIF p_dml_type = 'I' AND p_tax_type = 'OFFSET' THEN

            -- For sync of eB-Tax defintion entities.
              ZX_MIGRATE_TAX_DEF.migrate_unassign_offset_codes(p_tax_id);
              IF p_tax_recovery_rate is not null THEN
                 ZX_MIGRATE_TAX_DEF.migrate_recovery_rates(p_tax_id);
              END IF;
              ZX_MIGRATE_TAX_DEF.create_zx_statuses(p_tax_id);
              ZX_MIGRATE_TAX_DEF.create_zx_taxes(p_tax_id);

  /******************************************************************************
   * Important!!! please check why this API ZX_MIGRATE_TAX_DEF.create_zx_regimes *
   * was dropped and see if this API call needs to be replaced with another one *
   * Commentiong out this call temporarily ge get this package body valid for   *
   * sanity testing                                                             *
   ******************************************************************************/
            -- bug 4507349  ZX_MIGRATE_TAX_DEF.create_zx_regimes(p_tax_id);
            -- End of sync for eB-Tax defintion entities.

        ELSIF p_dml_type = 'I' AND p_tax_type <> 'AWT'   THEN

            -- For sync of eB-Tax defintion entities.
              ZX_MIGRATE_TAX_DEF.migrate_normal_tax_codes(p_tax_id);
              IF  p_tax_recovery_rate    is not null THEN
                  ZX_MIGRATE_TAX_DEF.migrate_recovery_rates(p_tax_id);
              ELSIF  p_tax_recovery_rule_id is not null THEN
                     ZX_MIGRATE_TAX_DEF.create_rules(p_tax_id);
              END IF;
              IF p_offset_tax_code_id is not null THEN
                 ZX_MIGRATE_TAX_DEF.migrate_assign_offset_codes
                                            (p_offset_tax_code_id);
              END IF;
              ZX_MIGRATE_TAX_DEF.create_zx_statuses(p_tax_id);
              ZX_MIGRATE_TAX_DEF.create_zx_taxes(p_tax_id);
  /******************************************************************************
   * Important!!! please check why this API ZX_MIGRATE_TAX_DEF.create_zx_regimes *
   * was dropped and see if this API call needs to be replaced with another one *
   * Commentiong out this call temporarily ge get this package body valid for   *
   * sanity testing                                                             *
   ******************************************************************************/
            -- bug 4507349  ZX_MIGRATE_TAX_DEF.create_zx_regimes(p_tax_id);
            -- End of sync for eB-Tax defintion entities.

            -- For Sync of Default Hierarchy
               SELECT  DECODE(p_global_attribute_category,
                             'JE.CZ.APXTADTC.TAX_ORIGIN',
                              p_global_attribute1,
                             'JE.HU.APXTADTC.TAX_ORIGIN',
                              p_global_attribute1,
                             'JE.PL.APXTADTC.TAX_ORIGIN',
                              p_global_attribute1,
                             'JE.CH.APXTADTC.TAX_INFO',
                              p_global_attribute1,
                              zx_migrate_util.GET_TAX(p_name,
                                      p_tax_type)
                             ) INTO l_tax
               FROM DUAL;

               -- Bug 3751717
               IF p_tax_type NOT IN('OFFSET','USE') THEN
                  Zx_Migrate_Tax_Default_Hier.create_condition_groups(p_name);
                  Zx_Migrate_Tax_Default_Hier.create_rules(l_tax);
                  Zx_Migrate_Tax_Default_Hier.create_process_results
                                             (p_tax_id      =>  p_tax_id,
                                              p_sync_module => 'AP');
               END IF;
            -- End of sync for Default Hierarchy

        ELSE
            null;
        END IF;

   --END IF;
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('SYNC_AP_TAX_CODES (-)');
     END IF;
END  SYNC_AP_TAX_CODES;

/* ==========================================================================*
  | Procedure Name: SYNC_AP_TAX_RECVRY_RULES
  |
  | Purpose: Will be used to Synchronize the data between the Tax Recovery
  |          Rules and eTax Condition and Rules Gateway entity.
  |
  |          Will be called fro  Tax Codes for  passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the sa e Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Recovery Rules) and eTax Condition
  |          and Rules Gateway entity
  |
  *=========================================================================*/

PROCEDURE SYNC_AP_TAX_RECVRY_RULES
(
P_DML_TYPE                  IN   VARCHAR2,
P_RULE_ID                   IN   NUMBER,
P_CREATED_BY                IN   NUMBER,
P_CREATION_DATE             IN   DATE,
P_LAST_UPDATED_BY           IN   NUMBER,
P_LAST_UPDATE_DATE          IN   DATE,
P_LAST_UPDATE_LOGIN         IN   NUMBER,
P_NAME                      IN   VARCHAR2,
P_DESCRIPTION               IN   VARCHAR2,
P_ORG_ID                    IN   NUMBER,
P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
P_ATTRIBUTE1                IN   VARCHAR2,
P_ATTRIBUTE2                IN   VARCHAR2,
P_ATTRIBUTE3                IN   VARCHAR2,
P_ATTRIBUTE4                IN   VARCHAR2,
P_ATTRIBUTE5                IN   VARCHAR2,
P_ATTRIBUTE6                IN   VARCHAR2,
P_ATTRIBUTE7                IN   VARCHAR2,
P_ATTRIBUTE8                IN   VARCHAR2,
P_ATTRIBUTE9                IN   VARCHAR2,
P_ATTRIBUTE10               IN   VARCHAR2,
P_ATTRIBUTE11               IN   VARCHAR2,
P_ATTRIBUTE12               IN   VARCHAR2,
P_ATTRIBUTE13               IN   VARCHAR2,
P_ATTRIBUTE14               IN   VARCHAR2,
P_ATTRIBUTE15               IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE_CATEGORY IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE1         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE2         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE3         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE4         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE5         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE6         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE7         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE8         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE9         IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE10        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE11        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE12        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE13        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE14        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE15        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE16        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE17        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE18        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE19        IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE20        IN   VARCHAR2) IS

BEGIN
   IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('SYNC_AP_TAX_RECVRY_RULES()+');
   END IF;
      null;
   IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('SYNC_AP_TAX_RECVRY_RULES()-');
   END IF;
END SYNC_AP_TAX_RECVRY_RULES;

 /* =========================================================================*
  | Procedure Name: SYNC_AP_TAX_RECVRY_RATES
  |
  | Purpose: Will be used to Synchronize the data between the Tax REcovery
  |          Rates and eTax Tax Definition Gateway entity.
  |
  |          Will be called fro  Tax Codes for  passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the sa e Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Recovery Rates) and eTax Tax
  |          Definition Gateway entity
  |
   *========================================================================*/

PROCEDURE SYNC_AP_TAX_RECVRY_RATES
(
P_DML_TYPE                 IN   VARCHAR2,
P_RATE_ID                     IN   NUMBER,
P_CREATED_BY                  IN   NUMBER,
P_CREATION_DATE               IN   DATE,
P_LAST_UPDATED_BY             IN   NUMBER,
P_LAST_UPDATE_DATE            IN   DATE,
P_LAST_UPDATE_LOGIN           IN   NUMBER,
P_RULE_ID                     IN   NUMBER,
P_CONCATENATED_SEGMENT_LOW    IN   VARCHAR2,
P_CONCATENATED_SEGMENT_HIGH   IN   VARCHAR2,
P_ENABLED_FLAG                IN   VARCHAR2,
P_START_DATE                  IN   DATE,
P_END_DATE                    IN   DATE,
P_RECOVERY_RATE               IN   NUMBER,
P_CONDITION                   IN   VARCHAR2,
P_CONDITION_VALUE             IN   VARCHAR2,
P_FUNCTION                    IN   VARCHAR2,
P_DESCRIPTION                 IN   VARCHAR2,
P_ORG_ID                      IN   NUMBER,
P_ATTRIBUTE_CATEGORY          IN   VARCHAR2,
P_ATTRIBUTE1                  IN   VARCHAR2,
P_ATTRIBUTE2                  IN   VARCHAR2,
P_ATTRIBUTE3                  IN   VARCHAR2,
P_ATTRIBUTE4                  IN   VARCHAR2,
P_ATTRIBUTE5                  IN   VARCHAR2,
P_ATTRIBUTE6                  IN   VARCHAR2,
P_ATTRIBUTE7                  IN   VARCHAR2,
P_ATTRIBUTE8                  IN   VARCHAR2,
P_ATTRIBUTE9                  IN   VARCHAR2,
P_ATTRIBUTE10                 IN   VARCHAR2,
P_ATTRIBUTE11                 IN   VARCHAR2,
P_ATTRIBUTE12                 IN   VARCHAR2,
P_ATTRIBUTE13                 IN   VARCHAR2,
P_ATTRIBUTE14                 IN   VARCHAR2,
P_ATTRIBUTE15                 IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE_CATEGORY   IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE1           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE2           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE3           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE4           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE5           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE6           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE7           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE8           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE9           IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE10          IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE11          IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE12          IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE13          IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE14          IN         VARCHAR2,
P_GLOBAL_ATTRIBUTE15          IN         VARCHAR2,
P_GLOBAL_ATTRIBUTE16          IN         VARCHAR2,
P_GLOBAL_ATTRIBUTE17          IN    VARCHAR2,
P_GLOBAL_ATTRIBUTE18          IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE19          IN   VARCHAR2,
P_GLOBAL_ATTRIBUTE20          IN   VARCHAR2) IS

BEGIN
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('SYNC_AP_TAX_RECVRY_RATES()+');
    END IF;
      IF p_dml_type = 'I' THEN
         ZX_MIGRATE_TAX_DEF.create_condition_groups(p_rate_id);
      END IF;
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('SYNC_AP_TAX_RECVRY_RATES()-');
    END IF;

END  SYNC_AP_TAX_RECVRY_RATES;

 /* =========================================================================*
  | Procedure Name: SYNC_MTL_SYSTEM_ITEMS
  |
  | Purpose: Will be used to Synchronize the data between the Inventory Items
  |          and eTax Fiscal Classifications.
  |
  |          Will be called from JE library passing the Global Attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of these Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data. This procedure will be creating data in
  |          ZX_PROD_FSC_CLASS_ASSOC_GW
   *========================================================================*/


PROCEDURE SYNC_MTL_SYSTEM_ITEMS(
 P_ITEM_ID                    IN NUMBER,
 P_ITEM_ORGANIZATION_ID       IN NUMBER,
 P_FISCAL_CLASSIF_TYPE_CODE   IN VARCHAR2,
 P_FISCAL_CLASSIF_CODE        IN VARCHAR2 ) IS

BEGIN
  NULL;

END SYNC_MTL_SYSTEM_ITEMS;

 /* =========================================================================*
  | Procedure Name: SYNC_GDF_AR_MEMO_LINES
  |
  | Purpose: Will be used to Synchronize Global Attributes data between
  |          the Memo Lines and eTax entities.
  |
  |          Will be called from JL library passing the Global Attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of these Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data.
   *========================================================================*/

PROCEDURE SYNC_GDF_AR_MEMO_LINES (
 P_MEMO_LINE_ID               IN        NUMBER,
 P_SET_OF_BOOKS_ID            IN        NUMBER,
 P_LINE_TYPE                  IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE_CATEGORY  IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE1          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE2          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE3          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE4          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE5          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE6          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE7          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE8          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE9          IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE10         IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE11         IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE12         IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE13         IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE14         IN        VARCHAR2,
 P_GLOBAL_ATTRIBUTE15         IN        VARCHAR2) IS

BEGIN
  NULL;

END SYNC_GDF_AR_MEMO_LINES;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_CATEG
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Categories Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_CATEG (
 P_DML_TYPE          IN        VARCHAR2,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_CATEGORY               IN        VARCHAR2,
 P_END_DATE_ACTIVE            IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_THRESHOLD_CHECK_LEVEL      IN        VARCHAR2,
 P_THRESHOLD_CHECK_GRP_BY     IN        VARCHAR2,
 P_MIN_AMOUNT                 IN        NUMBER,
 P_MIN_TAXABLE_BASIS          IN        NUMBER,
 P_MIN_PERCENTAGE             IN        NUMBER,
 P_TAX_INCLUSIVE              IN        VARCHAR2,
 P_ORG_TAX_ATTRIBUTE          IN        VARCHAR2,
 P_CUS_TAX_ATTRIBUTE          IN        VARCHAR2,
 P_TXN_TAX_ATTRIBUTE          IN        VARCHAR2,
 P_TRIBUTARY_SUBSTITUTION     IN        VARCHAR2,
 P_USED_TO_REDUCE             IN        VARCHAR2,
 P_TAX_CATEG_TO_REDUCE_ID     IN        NUMBER,
 P_TAX_CODE                   IN        VARCHAR2,
 P_TAX_AUTHORITY_CODE         IN        VARCHAR2,
 P_MANDATORY_IN_CLASS         IN        VARCHAR2,
 P_PRINT_FLAG                 IN        VARCHAR2,
 P_TAX_RULE_SET               IN        VARCHAR2,
 P_START_DATE_ACTIVE          IN        DATE,
 P_TAX_REGIME                 IN        VARCHAR2,
 P_ATTRIBUTE_CATEGORY         IN  VARCHAR2,
 P_ATTRIBUTE1                 IN  VARCHAR2,
 P_ATTRIBUTE2                 IN  VARCHAR2,
 P_ATTRIBUTE3                 IN  VARCHAR2,
 P_ATTRIBUTE4                 IN  VARCHAR2,
 P_ATTRIBUTE5                 IN  VARCHAR2,
 P_ATTRIBUTE6                 IN  VARCHAR2,
 P_ATTRIBUTE7                 IN  VARCHAR2,
 P_ATTRIBUTE8                 IN  VARCHAR2,
 P_ATTRIBUTE9                 IN  VARCHAR2,
 P_ATTRIBUTE10                IN  VARCHAR2,
 P_ATTRIBUTE11                IN  VARCHAR2,
 P_ATTRIBUTE12                IN  VARCHAR2,
 P_ATTRIBUTE13                IN  VARCHAR2,
 P_ATTRIBUTE14                IN  VARCHAR2,
 P_ATTRIBUTE15                IN  VARCHAR2 ) IS
BEGIN
  NULL;
END SYNC_LTE_CATEG;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_GROUPS
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Groups Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_GROUPS (
 P_DML_TYPE          IN        VARCHAR2,
 P_GROUP_TAX_ID               IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_GROUP_RECORD_ID        IN        NUMBER,
 P_ESTABLISHMENT_TYPE         IN        VARCHAR2,
 P_CONTRIBUTOR_TYPE           IN        VARCHAR2,
 P_TRANSACTION_NATURE         IN        VARCHAR2,
 P_END_DATE_ACTIVE            IN        DATE,
 P_USE_TX_CATEG_THRESHOLDS    IN        VARCHAR2,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_COMPOUND_PRECEDENCE        IN        NUMBER,
 P_MIN_AMOUNT                 IN        NUMBER,
 P_MIN_TAXABLE_BASIS          IN        NUMBER,
 P_MIN_PERCENTAGE             IN        NUMBER,
 P_TAX_INCLUSIVE              IN        VARCHAR2,
 P_TRIBUTARY_SUBSTITUTION     IN        VARCHAR2,
 P_USED_TO_REDUCE             IN        VARCHAR2,
 P_TAX_CODE                   IN        VARCHAR2,
 P_BASE_RATE                  IN        NUMBER,
 P_START_DATE_ACTIVE          IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_TAX_CATEGORY_TO_REDUCE_ID  IN        NUMBER,
 P_CALCULATE_IN_OE            IN        VARCHAR2,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_GROUPS;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_CAT_ATT
 | Product using
 | this Procedure : Will be called by JL, from Associate Latin Tax Category
 |                  with Conditions and Values Form (Master Block)
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_CAT_ATT (
 P_DML_TYPE          IN        VARCHAR2,
 P_TAX_CATEG_ATTR_ID          IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_ATTRIBUTE_TYPE         IN        VARCHAR2,
 P_TAX_ATTRIBUTE_NAME         IN        VARCHAR2,
 P_MANDATORY_IN_CLASS         IN        VARCHAR2,
 P_DETERMINING_FACTOR         IN        VARCHAR2,
 P_GROUPING_ATTRIBUTE         IN        VARCHAR2,
 P_PRIORITY_NUMBER            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
  NULL;
END SYNC_LTE_CAT_ATT;


/* =========================================================================*
 | Procedure Name: SYNC_LTE_ATT_VAL
 | Product using
 | this Procedure : Will be called by JL, from Associate Latin Tax Category
 |                  with Conditions and Values Form (Detail Block)
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_ATT_VAL (
 P_DML_TYPE          IN        VARCHAR2,
 P_TAX_CATEG_ATTR_VAL_ID      IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_ATTRIBUTE_TYPE         IN        VARCHAR2,
 P_TAX_ATTRIBUTE_NAME         IN        VARCHAR2,
 P_TAX_ATTRIBUTE_VALUE        IN        VARCHAR2,
 P_TAX_ATTR_VALUE_CODE        IN        VARCHAR2,
 P_DEFAULT_TO_CLASS           IN        VARCHAR2,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_ATT_VAL;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_ATT_CLS_HDR
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Condition Classes
 |                  Form (Master Block)
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_ATT_CLS_HDR (
 P_DML_TYPE          IN        VARCHAR2,
 P_LOOKUP_TYPE                IN        VARCHAR2,
 P_SECURITY_GROUP_ID          IN        NUMBER,
 P_VIEW_APPLICATION_ID        IN        NUMBER,
 P_LOOKUP_CODE                IN        VARCHAR2,
 P_ENABLED_FLAG               IN        VARCHAR2,
 P_START_DATE_ACTIVE          IN        DATE,
 P_END_DATE_ACTIVE            IN        DATE,
 P_TERRITORY_CODE             IN        VARCHAR2,
 P_TAG                        IN        VARCHAR2,
 P_MEANING                    IN        VARCHAR2,
 P_DESCRIPTION                IN        VARCHAR2,
 P_CREATION_DATE              IN        VARCHAR2,
 P_CREATED_BY                 IN        VARCHAR2,
 P_LAST_UPDATE_DATE           IN        VARCHAR2,
 P_LAST_UPDATED_BY            IN        VARCHAR2,
 P_LAST_UPDATE_LOGIN          IN        VARCHAR2,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_ATT_CLS_HDR;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_ATT_CLS
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Condition Classes
 |                  Form (Detail Block)
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_ATT_CLS (
 P_DML_TYPE          IN        VARCHAR2,
 P_ATTRIBUTE_CLASS_ID         IN        NUMBER,
 P_TAX_ATTR_CLASS_TYPE        IN        VARCHAR2,
 P_TAX_ATTR_CLASS_CODE        IN        VARCHAR2,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_ATTRIBUTE_TYPE         IN        VARCHAR2,
 P_TAX_ATTRIBUTE_NAME         IN        VARCHAR2,
 P_TAX_ATTRIBUTE_VALUE        IN        VARCHAR2,
 P_ENABLED_FLAG               IN        VARCHAR2,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_ATT_CLS;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_LOCN
 | Product using
 | this Procedure : Will be called by JL, from Latin Locations Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_LOCN (
 P_DML_TYPE          IN        VARCHAR2,
 P_LOCN_ID                    IN        NUMBER,
 P_SHIP_FROM_CODE             IN        VARCHAR2,
 P_SHIP_TO_SEGMENT_ID         IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_BASE_RATE                  IN        NUMBER,
 P_TAX_CODE                   IN        VARCHAR2,
 P_TRIB_SUBST_INSCRIPTION     IN        VARCHAR2,
 P_START_DATE_ACTIVE          IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_LOCN;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_FSC_CLS_HDR
 | Product using
 | this Procedure : Will be called by JL, from Latin Fiscal Classifications
 |                  Form (Master Block)
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_FSC_CLS_HDR (
 P_DML_TYPE          IN        VARCHAR2,
 P_LOOKUP_TYPE                IN        VARCHAR2,
 P_LOOKUP_CODE                IN        VARCHAR2,
 P_ENABLED_FLAG               IN        VARCHAR2,
 P_START_DATE_ACTIVE          IN        DATE,
 P_END_DATE_ACTIVE            IN        DATE,
 P_MEANING                    IN        VARCHAR2,
 P_DESCRIPTION                IN        VARCHAR2,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        VARCHAR2,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        VARCHAR2,
 P_LAST_UPDATE_LOGIN          IN        VARCHAR2,
 P_SECURITY_GROUP_ID          IN        NUMBER,
 P_VIEW_APPLICATION_ID        IN        NUMBER,
 P_TAG                        IN        VARCHAR2,
 P_TERRITORY_CODE             IN        VARCHAR2,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_FSC_CLS_HDR;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_FSC_CLS
 | Product using
 | this Procedure : Will be called by JL, from Latin Fiscal Classifications
 |                  Form (Detail Block)
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_FSC_CLS (
 P_DML_TYPE          IN        VARCHAR2,
 P_FSC_CLS_ID                 IN        NUMBER,
 P_FISCAL_CLASSIFICATION_CODE IN        VARCHAR2,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_CODE                   IN        VARCHAR2,
 P_END_DATE_ACTIVE            IN        DATE,
 P_BASE_RATE                  IN        NUMBER,
 P_START_DATE_ACTIVE          IN        DATE,
 P_ENABLED_FLAG               IN        VARCHAR2,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_FSC_CLS;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_RULES
 | Product using
 | this Procedure : Will be called by JL, from Tax Rules Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_RULES (
 P_DML_TYPE          IN        VARCHAR2,
 P_RULE_ID                    IN        NUMBER,
 P_TAX_RULE_LEVEL             IN        VARCHAR2,
 P_RULE                       IN        VARCHAR2,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_CONTRIBUTOR_TYPE           IN        VARCHAR2,
 P_CUST_TRX_TYPE_ID           IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_PRIORITY                   IN        NUMBER,
 P_DESCRIPTION                IN        VARCHAR2,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER) IS
BEGIN
   NULL;
END SYNC_LTE_RULES;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_CAT_DTL
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Category Details
 |                  Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_CAT_DTL (
 P_DML_TYPE          IN        VARCHAR2,
 P_TAX_CATEG_DTL_ID           IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_MIN_TAXABLE_BASIS          IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_MIN_AMOUNT                 IN        NUMBER,
 P_MIN_PERCENTAGE             IN        NUMBER,
 P_TAX_CODE                   IN        VARCHAR2,
 P_START_DATE_ACTIVE          IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_CAT_DTL;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_SCHEDULES
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Category Schedules
 |                  Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_SCHEDULES (
 P_DML_TYPE          IN        VARCHAR2,
 P_TAX_CATEG_SLAB_ID          IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_MIN_TAXABLE_BASIS          IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_MAX_TAXABLE_BASIS          IN        NUMBER,
 P_TAX_CODE                   IN        VARCHAR2,
 P_START_DATE_ACTIVE          IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_SCHEDULES;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_LGL_MSG
 | Product using
 | this Procedure : Will be called by JL, from Associate Latin Tax Legal
 |                  Messages Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_LGL_MSG (
 P_DML_TYPE          IN        VARCHAR2,
 P_RULE_ID                    IN        NUMBER,
 P_RULE_DATA_ID               IN        NUMBER,
 P_EXCEPTION_CODE             IN        VARCHAR2,
 P_MESSAGE_ID                 IN        NUMBER,
 P_INVENTORY_ITEM_FLAG        IN        VARCHAR2,
 P_INVENTORY_ORGANIZATION_ID  IN        NUMBER,
 P_START_DATE_ACTIVE          IN        DATE,
 P_END_DATE_ACTIVE            IN        DATE,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER) IS
BEGIN
   NULL;
END SYNC_LTE_LGL_MSG;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_CUS_CLS
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Customer Site
 |                  Profile Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_CUS_CLS (
 P_DML_TYPE          IN        VARCHAR2,
 P_CUS_CLASS_ID               IN        NUMBER,
 P_ADDRESS_ID                 IN        NUMBER,
 P_TAX_ATTR_CLASS_CODE        IN        VARCHAR2,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_TAX_ATTRIBUTE_NAME         IN        VARCHAR2,
 P_TAX_ATTRIBUTE_VALUE        IN        VARCHAR2,
 P_ENABLED_FLAG               IN        VARCHAR2,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER) IS
BEGIN
   NULL;
END SYNC_LTE_CUS_CLS;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_EXC_FSC
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Exceptions by Fiscal
 |                  Classification Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_EXC_FSC (
 P_DML_TYPE          IN        VARCHAR2,
 P_EXC_FSC_ID                 IN        NUMBER,
 P_SHIP_FROM_CODE             IN        VARCHAR2,
 P_SHIP_TO_SEGMENT_ID         IN        NUMBER,
 P_FISCAL_CLASSIFICATION_CODE IN        VARCHAR2,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_START_DATE_ACTIVE          IN        DATE,
 P_TAX_CODE                   IN        VARCHAR2,
 P_BASE_RATE                  IN        NUMBER,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_EXC_FSC;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_EXC_ITM
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Exceptions by Item
 |                  Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_EXC_ITM (
 P_DML_TYPE          IN        VARCHAR2,
 P_EXC_ITM_ID                 IN        NUMBER,
 P_SHIP_FROM_CODE             IN        VARCHAR2,
 P_SHIP_TO_SEGMENT_ID         IN        NUMBER,
 P_INVENTORY_ITEM_ID          IN        NUMBER,
 P_ORGANIZATION_ID            IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_START_DATE_ACTIVE          IN        DATE,
 P_TAX_CODE                   IN        VARCHAR2,
 P_BASE_RATE                  IN        NUMBER,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_EXC_ITM;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_EXC_CUS
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Exceptions by
 |                  Customer Sites Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_EXC_CUS (
 P_DML_TYPE          IN        VARCHAR2,
 P_EXC_CUS_ID                 IN        NUMBER,
 P_ADDRESS_ID                 IN        NUMBER,
 P_TAX_CATEGORY_ID            IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_TAX_CODE                   IN        VARCHAR2,
 P_BASE_RATE                  IN        NUMBER,
 P_START_DATE_ACTIVE          IN        DATE,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_EXC_CUS;

/* =========================================================================*
 | Procedure Name: SYNC_LTE_NAT_RAT
 | Product using
 | this Procedure : Will be called by JL, from Latin Tax Exceptions by
 |                  Transaction Condition Values Form
 |
 | Purpose: Will be used to Synchronize data with eTax Gateway entity.
 |
  *========================================================================*/

PROCEDURE SYNC_LTE_NAT_RAT (
 P_DML_TYPE          IN        VARCHAR2,
 P_TXN_NATURE_ID              IN        NUMBER,
 P_LAST_UPDATE_DATE           IN        DATE,
 P_LAST_UPDATED_BY            IN        NUMBER,
 P_CREATION_DATE              IN        DATE,
 P_CREATED_BY                 IN        NUMBER,
 P_LAST_UPDATE_LOGIN          IN        NUMBER,
 P_TAX_CATEG_ATTR_VAL_ID      IN        NUMBER,
 P_END_DATE_ACTIVE            IN        DATE,
 P_TAX_CODE                   IN        VARCHAR2,
 P_MIN_TAXABLE_BASIS          IN        NUMBER,
 P_MIN_AMOUNT                 IN        NUMBER,
 P_MIN_PERCENTAGE             IN        NUMBER,
 P_BASE_RATE                  IN        NUMBER,
 P_START_DATE_ACTIVE          IN        DATE,
 P_ATTRIBUTE_CATEGORY         IN        VARCHAR2,
 P_ATTRIBUTE1                 IN        VARCHAR2,
 P_ATTRIBUTE2                 IN        VARCHAR2,
 P_ATTRIBUTE3                 IN        VARCHAR2,
 P_ATTRIBUTE4                 IN        VARCHAR2,
 P_ATTRIBUTE5                 IN        VARCHAR2,
 P_ATTRIBUTE6                 IN        VARCHAR2,
 P_ATTRIBUTE7                 IN        VARCHAR2,
 P_ATTRIBUTE8                 IN        VARCHAR2,
 P_ATTRIBUTE9                 IN        VARCHAR2,
 P_ATTRIBUTE10                IN        VARCHAR2,
 P_ATTRIBUTE11                IN        VARCHAR2,
 P_ATTRIBUTE12                IN        VARCHAR2,
 P_ATTRIBUTE13                IN        VARCHAR2,
 P_ATTRIBUTE14                IN        VARCHAR2,
 P_ATTRIBUTE15                IN        VARCHAR2) IS
BEGIN
   NULL;
END SYNC_LTE_NAT_RAT;


 /* =========================================================================*
  | Procedure Name: SYNC_AR_TAX_CONDITION_ACTIONS
  |
  | Purpose: Will be used to Synchronize the data between the AR Tax Conditons and
  |          eTax Tax Definition, Tax Rules, Tax Conditions Gateway entity.
  |
  |          Will be called from Tax Groups form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Groups) and eTax Tax Definition,
  |          Rules, Conditions Gateway entity
  |
  *=========================================================================*/

PROCEDURE SYNC_AR_TAX_CONDITION_ACTIONS
(
  P_DML_TYPE                                 IN VARCHAR2,
  P_TAX_CONDITION_ACTION_ID                  IN NUMBER,
  P_CREATED_BY                               IN NUMBER,
  P_TAX_CONDITION_ID                         IN NUMBER,
  P_CREATION_DATE                            IN DATE,
  P_TAX_CONDITION_ACTION_TYPE                IN VARCHAR2,
  P_DISPLAY_ORDER                            IN NUMBER,
  P_LAST_UPDATED_BY                          IN NUMBER,
  P_LAST_UPDATE_DATE                         IN DATE,
  P_LAST_UPDATE_LOGIN                        IN NUMBER,
  P_TAX_CONDITION_ACTION_CODE                IN VARCHAR2,
  P_TAX_CONDITION_ACTION_VALUE               IN VARCHAR2,
  P_ORG_ID                                   IN NUMBER,
  P_ATTRIBUTE_CATEGORY                       IN VARCHAR2,
  P_ATTRIBUTE1                               IN VARCHAR2,
  P_ATTRIBUTE2                               IN VARCHAR2,
  P_ATTRIBUTE3                               IN VARCHAR2,
  P_ATTRIBUTE4                               IN VARCHAR2,
  P_ATTRIBUTE5                               IN VARCHAR2,
  P_ATTRIBUTE6                               IN VARCHAR2,
  P_ATTRIBUTE7                               IN VARCHAR2,
  P_ATTRIBUTE8                               IN VARCHAR2,
  P_ATTRIBUTE9                               IN VARCHAR2,
  P_ATTRIBUTE10                              IN VARCHAR2,
  P_ATTRIBUTE11                              IN VARCHAR2,
  P_ATTRIBUTE12                              IN VARCHAR2,
  P_ATTRIBUTE13                              IN VARCHAR2,
  P_ATTRIBUTE14                              IN VARCHAR2,
  P_ATTRIBUTE15                              IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE_CATEGORY                IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE1                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE2                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE3                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE4                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE5                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE6                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE7                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE8                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE9                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE10                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE11                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE12                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE13                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE14                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE15                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE16                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE17                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE18                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE19                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE20                       IN VARCHAR2
)
IS
BEGIN
  NULL;
END SYNC_AR_TAX_CONDITION_ACTIONS;


 /* =========================================================================*
  | Procedure Name: SYNC_AR_TAX_CONDITION_LINES
  |
  | Purpose: Will be used to Synchronize the data between the AR Tax Conditons and
  |          eTax Tax Definition, Tax Rules, Tax Conditions Gateway entity.
  |
  |          Will be called from Tax Groups form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Groups) and eTax Tax Definition,
  |          Rules, Conditions Gateway entity
  |
  *=========================================================================*/

PROCEDURE SYNC_AR_TAX_CONDITON_LINES
(
  P_DML_TYPE                                 IN VARCHAR2,
  P_TAX_CONDITION_LINE_ID                    IN NUMBER,
  P_CREATED_BY                               IN NUMBER,
  P_TAX_CONDITION_ID                         IN NUMBER,
  P_CREATION_DATE                            IN DATE,
  P_DISPLAY_ORDER                            IN NUMBER,
  P_LAST_UPDATED_BY                          IN NUMBER,
  P_LAST_UPDATE_DATE                         IN DATE,
  P_LAST_UPDATE_LOGIN                        IN NUMBER,
  P_TAX_CONDITION_CLAUSE                     IN VARCHAR2,
  P_TAX_CONDITION_ENTITY                     IN VARCHAR2,
  P_TAX_CONDITION_OPERATOR                   IN VARCHAR2,
  P_TAX_CONDITION_FIELD                      IN VARCHAR2,
  P_TAX_CONDITION_VALUE                      IN VARCHAR2,
  P_TAX_CONDITION_EXPR                       IN VARCHAR2,
  P_ORG_ID                                   IN NUMBER,
  P_ATTRIBUTE_CATEGORY                       IN VARCHAR2,
  P_ATTRIBUTE1                               IN VARCHAR2,
  P_ATTRIBUTE2                               IN VARCHAR2,
  P_ATTRIBUTE3                               IN VARCHAR2,
  P_ATTRIBUTE4                               IN VARCHAR2,
  P_ATTRIBUTE5                               IN VARCHAR2,
  P_ATTRIBUTE6                               IN VARCHAR2,
  P_ATTRIBUTE7                               IN VARCHAR2,
  P_ATTRIBUTE8                               IN VARCHAR2,
  P_ATTRIBUTE9                               IN VARCHAR2,
  P_ATTRIBUTE10                              IN VARCHAR2,
  P_ATTRIBUTE11                              IN VARCHAR2,
  P_ATTRIBUTE12                              IN VARCHAR2,
  P_ATTRIBUTE13                              IN VARCHAR2,
  P_ATTRIBUTE14                              IN VARCHAR2,
  P_ATTRIBUTE15                              IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE_CATEGORY                IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE1                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE2                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE3                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE4                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE5                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE6                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE7                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE8                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE9                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE10                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE11                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE12                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE13                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE14                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE15                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE16                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE17                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE18                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE19                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE20                       IN VARCHAR2
)
IS
BEGIN
  NULL;
END SYNC_AR_TAX_CONDITON_LINES;


 /* =========================================================================*
  | Procedure Name: SYNC_AR_TAX_CONDITIONS
  |
  | Purpose: Will be used to Synchronize the data between the AR Tax Conditons and
  |          eTax Tax Definition, Tax Rules, Tax Conditions Gateway entity.
  |
  |          Will be called from Tax Groups form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Groups) and eTax Tax Definition,
  |          Rules, Conditions Gateway entity
  |
  *=========================================================================*/

PROCEDURE SYNC_AR_TAX_CONDITIONS
(
  P_DML_TYPE                                 IN VARCHAR2,
  P_TAX_CONDITION_ID                         IN NUMBER,
  P_CREATED_BY                               IN NUMBER,
  P_CREATION_DATE                            IN DATE,
  P_LAST_UPDATED_BY                          IN NUMBER,
  P_LAST_UPDATE_DATE                         IN DATE,
  P_LAST_UPDATE_LOGIN                        IN NUMBER,
  P_TAX_CONDITION_NAME                       IN VARCHAR2,
  P_TAX_CONDITION_TYPE                       IN VARCHAR2,
  P_TAX_CONDITION_EXPR                       IN VARCHAR2,
  P_ORG_ID                                   IN NUMBER,
  P_ATTRIBUTE_CATEGORY                       IN VARCHAR2,
  P_ATTRIBUTE1                               IN VARCHAR2,
  P_ATTRIBUTE2                               IN VARCHAR2,
  P_ATTRIBUTE3                               IN VARCHAR2,
  P_ATTRIBUTE4                               IN VARCHAR2,
  P_ATTRIBUTE5                               IN VARCHAR2,
  P_ATTRIBUTE6                               IN VARCHAR2,
  P_ATTRIBUTE7                               IN VARCHAR2,
  P_ATTRIBUTE8                               IN VARCHAR2,
  P_ATTRIBUTE9                               IN VARCHAR2,
  P_ATTRIBUTE10                              IN VARCHAR2,
  P_ATTRIBUTE11                              IN VARCHAR2,
  P_ATTRIBUTE12                              IN VARCHAR2,
  P_ATTRIBUTE13                              IN VARCHAR2,
  P_ATTRIBUTE14                              IN VARCHAR2,
  P_ATTRIBUTE15                              IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE_CATEGORY                IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE1                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE2                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE3                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE4                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE5                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE6                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE7                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE8                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE9                        IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE10                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE11                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE12                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE13                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE14                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE15                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE16                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE17                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE18                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE19                       IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE20                       IN VARCHAR2
)
IS
BEGIN
  NULL;
END SYNC_AR_TAX_CONDITIONS;


 /* =========================================================================*
  | Procedure Name: SYNC_AR_TAX_EXCEPTIONS
  |
  | Purpose: Will be used to Synchronize the data between the AR Tax Exceptions and
  |          eTax Tax Definition, Tax Rules, Tax Conditions Gateway entity.
  |
  |          Will be called from AR Tax Exceptions form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Exception) and eTax Tax Definition,
  |          Rules, Conditions Gateway entity
  |
  *=========================================================================*/

PROCEDURE SYNC_AR_TAX_EXCEPTIONS
(
  P_Dml_Type                       IN VARCHAR2,
  P_Org_Id                         IN NUMBER,
  P_Item_Exception_Rate_Id         IN NUMBER,
  P_Creation_Date                  IN DATE,
  P_Created_By                     IN NUMBER,
  P_Last_Update_Login              IN NUMBER,
  P_Last_Updated_By                IN NUMBER,
  P_Last_Update_Date               IN DATE,
  P_Item_Id                        IN NUMBER,
  P_Rate_Context                   IN VARCHAR2,
  P_Location1_Rate                 IN NUMBER,
  P_Location2_Rate                 IN NUMBER,
  P_Location3_Rate                 IN NUMBER,
  P_Location4_Rate                 IN NUMBER,
  P_Location5_Rate                 IN NUMBER,
  P_Location6_Rate                 IN NUMBER,
  P_Location7_Rate                 IN NUMBER,
  P_Location8_Rate                 IN NUMBER,
  P_Location9_Rate                 IN NUMBER,
  P_Location10_Rate                IN NUMBER,
  P_Start_Date                     IN DATE,
  P_End_Date                       IN DATE,
  P_Attribute_Category             IN VARCHAR2,
  P_Attribute1                     IN VARCHAR2,
  P_Attribute2                     IN VARCHAR2,
  P_Attribute3                     IN VARCHAR2,
  P_Attribute4                     IN VARCHAR2,
  P_Attribute5                     IN VARCHAR2,
  P_Attribute6                     IN VARCHAR2,
  P_Attribute7                     IN VARCHAR2,
  P_Attribute8                     IN VARCHAR2,
  P_Attribute9                     IN VARCHAR2,
  P_Attribute10                    IN VARCHAR2,
  P_Attribute11                    IN VARCHAR2,
  P_Attribute12                    IN VARCHAR2,
  P_Attribute13                    IN VARCHAR2,
  P_Attribute14                    IN VARCHAR2,
  P_Attribute15                    IN VARCHAR2,
  P_Reason_Code                    IN VARCHAR2,
  P_Location_Context               IN VARCHAR2,
  P_Location_Id_Segment_1          IN NUMBER,
  P_Location_Id_Segment_2          IN NUMBER,
  P_Location_Id_Segment_3          IN NUMBER,
  P_Location_Id_Segment_4          IN NUMBER,
  P_Location_Id_Segment_5          IN NUMBER,
  P_Location_Id_Segment_6          IN NUMBER,
  P_Location_Id_Segment_7          IN NUMBER,
  P_Location_Id_Segment_8          IN NUMBER,
  P_Location_Id_Segment_9          IN NUMBER,
  P_Location_Id_Segment_10         IN NUMBER
)
IS
BEGIN
  NULL;
END SYNC_AR_TAX_EXCEPTIONS;



 /* =========================================================================*
  | Procedure Name: SYNC_AR_TAX_EXEMPTIONS
  |
  | Purpose: Will be used to Synchronize the data between the AR Tax Exemptions and
  |          eTax Tax Definition, Tax Rules, Tax Conditions Gateway entity.
  |
  |          Will be called from AR Tax Exemptions form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (Tax Exemption) and eTax Tax Definition,
  |          Rules, Conditions Gateway entity
  |
  *=========================================================================*/

PROCEDURE SYNC_AR_TAX_EXEMPTIONS
(
  P_Dml_Type                    IN VARCHAR2,
  P_Org_Id                      IN NUMBER,
  p_Tax_exemption_id          IN NUMBER,
  p_Last_updated_by            IN NUMBER,
  p_Last_update_date        IN DATE,
  p_Created_by              IN NUMBER,
  p_Creation_date          IN DATE,
  p_Status                  IN VARCHAR2,
  p_Inventory_item_id        IN NUMBER,
  p_Customer_id              IN NUMBER,
  p_Site_use_id              IN NUMBER,
  p_Exemption_type            IN VARCHAR2,
  p_Tax_code              IN VARCHAR2,
  p_Percent_exempt            IN NUMBER,
  p_Customer_exemption_number  IN VARCHAR2,
  p_Start_date              IN DATE,
  p_End_date              IN DATE,
  p_Location_context        IN VARCHAR2,
  p_Location_id_segment_1    IN NUMBER,
  p_Location_id_segment_2    IN NUMBER,
  p_Location_id_segment_3    IN NUMBER,
  p_Location_id_segment_4    IN NUMBER,
  p_Location_id_segment_5    IN NUMBER,
  p_Location_id_segment_6    IN NUMBER,
  p_Location_id_segment_7    IN NUMBER,
  p_Location_id_segment_8    IN NUMBER,
  p_Location_id_segment_9    IN NUMBER,
  p_Location_id_segment_10      IN NUMBER,
  p_Attribute_category        IN VARCHAR2,
  p_Attribute1              IN VARCHAR2,
  p_Attribute2              IN VARCHAR2,
  p_Attribute3              IN VARCHAR2,
  p_Attribute4              IN VARCHAR2,
  p_Attribute5               IN VARCHAR2,
  p_Attribute6              IN VARCHAR2,
  p_Attribute7              IN VARCHAR2,
  p_Attribute8              IN VARCHAR2,
  p_Attribute9              IN VARCHAR2,
  p_Attribute10              IN VARCHAR2,
  p_Attribute11              IN VARCHAR2,
  p_Attribute12              IN VARCHAR2,
  p_Attribute13                IN VARCHAR2,
  p_Attribute14              IN VARCHAR2,
  p_Attribute15              IN VARCHAR2,
  p_In_use_flag              IN VARCHAR2,
  p_Program_id              IN NUMBER,
  p_Program_update_date        IN DATE,
  p_Request_id              IN NUMBER,
  p_Program_application_id      IN NUMBER,
  p_Reason_code              IN VARCHAR2,
  p_Exempt_Context              IN VARCHAR2,
  p_Exempt_percent1             IN NUMBER,
  p_Exempt_percent2             IN NUMBER,
  p_Exempt_percent3             IN NUMBER,
  p_Exempt_percent4             IN NUMBER,
  p_Exempt_percent5             IN NUMBER,
  p_Exempt_percent6             IN NUMBER,
  p_Exempt_percent7             IN NUMBER,
  p_Exempt_percent8             IN NUMBER,
  p_Exempt_percent9             IN NUMBER,
  p_Exempt_percent10            IN NUMBER
)
IS
BEGIN
  NULL;
END SYNC_AR_TAX_EXEMPTIONS;

/*==========================================================
 | This procudure inserts data into
 | subscription tables for LTE
 | Call from : SYNC_AR_VAT_TAX
 ==========================================================*/
PROCEDURE migrate_sco_code_lte(
             P_TAX_REGIME_CODE   IN VARCHAR2 DEFAULT NULL,
             P_ORG_ID            IN NUMBER,
             P_CREATION_DATE     IN DATE,
             P_CREATED_BY        IN NUMBER,
             P_LAST_UPDATE_DATE  IN DATE,
             P_LAST_UPDATED_BY   IN NUMBER,
             P_LAST_UPDATE_LOGIN IN NUMBER
) IS

CURSOR pty_org_id_cur IS
SELECT party_tax_profile_id
  FROM zx_party_tax_profile
 WHERE party_id = P_ORG_ID
   AND party_type_code = 'OU';

CURSOR regm_id IS
SELECT tax_regime_id,effective_from
  FROM zx_regimes_b
 WHERE tax_regime_code = P_TAX_REGIME_CODE;


CURSOR sub_usage_id_cur (c_tax_regime_code zx_regimes_b.tax_regime_code%type,
                         c_pty_org_id NUMBER)IS
SELECT COUNT(*)
  FROM zx_subscription_options
 WHERE REGIME_USAGE_ID
       IN (SELECT REGIME_USAGE_ID
             FROM ZX_REGIMES_USAGES
            WHERE tax_regime_code = c_tax_regime_code
              AND FIRST_PTY_ORG_ID = c_pty_org_id);

 l_pty_org_id NUMBER;
 l_regime_id  NUMBER;
 l_regime_usage_id NUMBER;
 l_regm_start_date DATE;
 l_sub_opt_id NUMBER;
 l_count NUMBER;

BEGIN

  arp_util_tax.debug('MIGRATE_SCO_CODE_LTE(+)');
  arp_util_tax.debug('Regime tax Code :'||p_tax_regime_code);
  arp_util_tax.debug('P_ORG_ID:'||to_char(P_ORG_ID));

   OPEN pty_org_id_cur;
   FETCH pty_org_id_cur INTO l_pty_org_id;
   CLOSE pty_org_id_cur;

   OPEN regm_id;
   FETCH regm_id INTO l_regime_id, l_regm_start_date;
   CLOSE regm_id;

   OPEN sub_usage_id_cur(p_tax_regime_code,l_pty_org_id);
   FETCH sub_usage_id_cur INTO l_count;

  arp_util_tax.debug('l_pty_org_id:'||to_char(l_pty_org_id));
   IF sub_usage_id_cur%NOTFOUND THEN
   BEGIN
   arp_util_tax.debug('sub_usage_id_cur NOTFOUND :');

   SELECT zx_regimes_usages_s.nextval
     INTO l_regime_usage_id
     FROM dual;

   SELECT zx_subscription_options_s.nextval
     INTO l_sub_opt_id
     FROM dual;

    INSERT INTO zx_regimes_usages
               (regime_usage_id,
                first_pty_org_id,
                tax_regime_id,
                tax_regime_code,
                record_type_code,
                object_version_number,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
         VALUES (l_regime_usage_id,
                 l_pty_org_id,
                 l_regime_id,
                 P_TAX_REGIME_CODE,
                 'MIGRATED',
                 1,
                 P_CREATED_BY,
                 P_CREATION_DATE,
                 P_LAST_UPDATED_BY,
                 P_LAST_UPDATE_DATE,
                 P_LAST_UPDATE_LOGIN);

    INSERT INTO zx_subscription_options
                (SUBSCRIPTION_OPTION_ID,
                 SUBSCRIPTION_OPTION_CODE,
                 REGIME_USAGE_ID,
                 EFFECTIVE_FROM,
                 ENABLED_FLAG,
                 ALLOW_SUBSCRIPTION_FLAG,
                 RECORD_TYPE_CODE,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN,
                 EXCEPTION_OPTION_CODE)
          VALUES(l_sub_opt_id,
                 'OWN_GCO',
                 l_regime_usage_id,
                 l_regm_start_date,
                 'Y',
                 'Y',
                 'MIGRATED',
                 P_CREATED_BY,
                 P_CREATION_DATE,
                 P_LAST_UPDATED_BY,
                 P_LAST_UPDATE_DATE,
                 P_LAST_UPDATE_LOGIN,
                 'OWN_ONLY');

    INSERT INTO zx_subscription_details
                (SUBSCRIPTION_DETAIL_ID,
                 SUBSCRIPTION_OPTION_ID,
                 FIRST_PTY_ORG_ID,
                 PARENT_FIRST_PTY_ORG_ID,
                 VIEW_OPTIONS_CODE,
                 TAX_REGIME_CODE,
                 EFFECTIVE_FROM,
                 RECORD_TYPE_CODE,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN)
          VALUES(zx_subscription_details_s.nextval,
                 l_sub_opt_id,
                 l_pty_org_id,
                 l_pty_org_id,
                 'VFC',
                 P_TAX_REGIME_CODE,
                 l_regm_start_date,
                 'MIGRATED',
                 P_CREATED_BY,
                 P_CREATION_DATE,
                 P_LAST_UPDATED_BY,
                 P_LAST_UPDATE_DATE,
                 P_LAST_UPDATE_LOGIN);

    INSERT INTO zx_subscription_details
                (SUBSCRIPTION_DETAIL_ID,
                 SUBSCRIPTION_OPTION_ID,
                 FIRST_PTY_ORG_ID,
                 PARENT_FIRST_PTY_ORG_ID,
                 VIEW_OPTIONS_CODE,
                 TAX_REGIME_CODE,
                 EFFECTIVE_FROM,
                 RECORD_TYPE_CODE,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN)
          VALUES(zx_subscription_details_s.nextval,
                 l_sub_opt_id,
                 l_pty_org_id,
                 -99,
                 'VFR',
                 P_TAX_REGIME_CODE,
                 l_regm_start_date,
                 'MIGRATED',
                 P_CREATED_BY,
                 P_CREATION_DATE,
                 P_LAST_UPDATED_BY,
                 P_LAST_UPDATE_DATE,
                 P_LAST_UPDATE_LOGIN);
      END;
     END IF;
     CLOSE sub_usage_id_cur;
  arp_util_tax.debug('MIGRATE_SCO_CODE_LTE(-)');
  EXCEPTION
    WHEN OTHERS THEN
      CLOSE sub_usage_id_cur;
END migrate_sco_code_lte;

/* ==========================================================================*
 | Procedure Name: GET_PTP
 | Purpose:        This procedure will be called during upload,to populate
 |                 the party tax profile id(content_owner_id) in various
 |                 eTax target tables.
 *===========================================================================*/

PROCEDURE GET_PTP(
            p_party_id          IN  NUMBER,
            p_party_type        IN  VARCHAR2,
            p_ptp_id            OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2) IS
BEGIN
    NULL;
END;

 /* =========================================================================*
  | Procedure Name: SYNC_AR_VAT_TAX
  |
  | Purpose: Will be used to Synchronize the data between the AR Tax Codes and
  |          eTax Tax Definition, Tax Rules, Tax Conditions Gateway entity.
  |
  |          Will be called from AR Tax Codes form, passing the attributes
  |          required for synchronization.
  |
  |          This stubbed version will do nothing.
  |
  |          In later version of the Procedure(delivered in ZX),
  |          it will be replaced with the actual solution for synchronizing
  |          data between the source (AR Tax Codes) and eTax Tax Definition,
  |          Rules, Conditions Gateway entity
  |
  *=========================================================================*/
PROCEDURE SYNC_AR_VAT_TAX (
  P_DML_TYPE IN VARCHAR2,
  P_ORG_ID  IN NUMBER,
  P_VAT_TAX_ID IN NUMBER,
  P_TAX_CONSTRAINT_ID IN NUMBER,
  P_TAX_CLASS IN VARCHAR2,
  P_DISPLAYED_FLAG IN VARCHAR2,
  P_ENABLED_FLAG IN VARCHAR2,
  P_AMOUNT_INCLUDES_TAX_FLAG IN VARCHAR2,
  P_AMOUNT_INCLUDES_TAX_OVERRIDE IN VARCHAR2,
  P_TAXABLE_BASIS IN VARCHAR2,
  P_TAX_CALCULATION_PLSQL_BLOCK IN VARCHAR2,
  P_INTERIM_TAX_CCID IN NUMBER,
  P_ADJ_CCID IN NUMBER,
  P_EDISC_CCID IN NUMBER,
  P_UNEDISC_CCID IN NUMBER,
  P_FINCHRG_CCID IN NUMBER,
  P_ADJ_NON_REC_TAX_CCID IN NUMBER,
  P_EDISC_NON_REC_TAX_CCID IN NUMBER,
  P_UNEDISC_NON_REC_TAX_CCID IN NUMBER,
  P_FINCHRG_NON_REC_TAX_CCID IN NUMBER,
  P_SET_OF_BOOKS_ID IN NUMBER,
  P_TAX_CODE IN VARCHAR2,
  P_TAX_RATE IN NUMBER,
  P_TAX_TYPE IN VARCHAR2,
  P_VALIDATE_FLAG IN VARCHAR2,
  P_TAX_ACCOUNT_ID IN NUMBER,
  P_START_DATE IN DATE,
  P_END_DATE IN DATE,
  P_ATTRIBUTE_CATEGORY IN VARCHAR2,
  P_ATTRIBUTE1 IN VARCHAR2,
  P_ATTRIBUTE2 IN VARCHAR2,
  P_ATTRIBUTE3 IN VARCHAR2,
  P_ATTRIBUTE4 IN VARCHAR2,
  P_ATTRIBUTE5 IN VARCHAR2,
  P_ATTRIBUTE6 IN VARCHAR2,
  P_ATTRIBUTE7 IN VARCHAR2,
  P_ATTRIBUTE8 IN VARCHAR2,
  P_ATTRIBUTE9 IN VARCHAR2,
  P_ATTRIBUTE10 IN VARCHAR2,
  P_ATTRIBUTE11 IN VARCHAR2,
  P_ATTRIBUTE12 IN VARCHAR2,
  P_ATTRIBUTE13 IN VARCHAR2,
  P_ATTRIBUTE14 IN VARCHAR2,
  P_ATTRIBUTE15 IN VARCHAR2,
  P_UNAPPROVED_EXEMPTION_FLAG IN VARCHAR2,
  P_DESCRIPTION IN VARCHAR2,
  P_VAT_TRANSACTION_TYPE IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE_CATEGORY IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE1 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE2 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE3 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE4 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE5 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE6 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE7 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE8 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE9 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE10 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE11 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE12 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE13 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE14 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE15 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE16 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE17 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE18 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE19 IN VARCHAR2,
  P_GLOBAL_ATTRIBUTE20 IN VARCHAR2,
  P_PRINTED_TAX_NAME IN VARCHAR2,
  P_CREATION_DATE IN DATE,
  P_CREATED_BY IN NUMBER,
  P_LAST_UPDATE_DATE IN DATE,
  P_LAST_UPDATED_BY IN NUMBER,
  P_LAST_UPDATE_LOGIN IN NUMBER,
  P_TAX_REGIME_CODE   IN VARCHAR2 DEFAULT NULL, --Bug3872888
  P_TAX               IN VARCHAR2 DEFAULT NULL, --Bug3872888
  P_TAX_STATUS_CODE   IN VARCHAR2 DEFAULT NULL  --Bug3872888
) IS
l_tax VARCHAR2(30);
--x_return_status    VARCHAR2(30);
BEGIN

  arp_util_tax.debug('SYNC_AR_VAT_TAX(+)');
  arp_util_tax.debug('p_vat_tax_id :'||to_char(p_vat_tax_id));
  arp_util_tax.debug('p_dml_type :'||p_dml_type);
  arp_util_tax.debug('p_tax_type :'||p_tax_type);

  IF p_dml_type = 'I'  THEN
       --Tax Code Synch
    zx_migrate_tax_def_common.load_results_for_ar(p_vat_tax_id);
    zx_migrate_tax_def_common.load_regimes;
    --zx_sbscr_options_migrate_pkg.sbscrptn_options_migrate(x_return_status);

    IF p_tax_type = 'LOCATION' THEN
      zx_migrate_ar_tax_def.migrate_loc_tax_code (p_vat_tax_id, p_tax_type);
    ELSIF p_tax_type = 'SALES_TAX' THEN
      zx_migrate_ar_tax_def.migrate_vnd_tax_code (p_vat_tax_id, p_tax_type);
    ELSE
      zx_migrate_ar_tax_def.migrate_ar_tax_code_setup (p_vat_tax_id);
    END IF;

    --Begin of sync for AR Tax defaulting process.
    Zx_Migrate_Tax_Default_Hier.create_condition_groups(p_tax_code);

    -- Bug 3751717
    -- If Tax Type is group then we are creating the Tax Rule and Process
    -- result in SYNC_AR_TAX_GROUP_CODES procedure
    IF P_TAX_TYPE <> 'TAX_GROUP' THEN
      SELECT DECODE(p_global_attribute_category,
                    'JE.CZ.ARXSUVAT.TAX_ORIGIN', p_global_attribute1,
                    'JE.HU.ARXSUVAT.TAX_ORIGIN', p_global_attribute1,
                    'JE.PL.ARXSUVAT.TAX_ORIGIN', p_global_attribute1,
                    Zx_Migrate_Util.GET_TAX( p_tax_code, p_tax_type)  )
       INTO l_tax
       FROM DUAL;

      Zx_Migrate_Tax_Default_Hier.create_rules(l_tax);
      Zx_Migrate_Tax_Default_Hier.create_process_results
         (p_tax_id      =>  p_vat_tax_id,
          p_sync_module => 'AR');
    END IF;

    --End of Sync for AR tax defaulting process.
  ELSIF p_dml_type = 'U'  THEN

    arp_util_tax.debug('p_dml_type'||p_dml_type);

-- 6820043: moving description from zx_rates_b to zx_rates_tl
    UPDATE ZX_RATES_B_TMP
    SET EFFECTIVE_TO = P_END_DATE,
        ACTIVE_FLAG = P_ENABLED_FLAG,
        ADJ_FOR_ADHOC_AMT_CODE =  DECODE(nvl(P_VALIDATE_FLAG, 'N'),'Y', 'RATES','N', NULL),
        ALLOW_ADHOC_TAX_RATE_FLAG = P_VALIDATE_FLAG,
        DEF_REC_SETTLEMENT_OPTION_CODE =  DECODE(P_INTERIM_TAX_CCID,NULL, 'IMMEDIATE','DEFERRED'),
        VAT_TRANSACTION_TYPE_CODE = P_VAT_TRANSACTION_TYPE,
        INCLUSIVE_TAX_FLAG = P_AMOUNT_INCLUDES_TAX_FLAG,
        TAX_INCLUSIVE_OVERRIDE_FLAG = P_AMOUNT_INCLUDES_TAX_OVERRIDE,
--        DESCRIPTION = P_DESCRIPTION,
        ATTRIBUTE1 = P_ATTRIBUTE1,
        ATTRIBUTE2 = P_ATTRIBUTE2,
        ATTRIBUTE3 = P_ATTRIBUTE3,
        ATTRIBUTE4 = P_ATTRIBUTE4,
        ATTRIBUTE5 = P_ATTRIBUTE5,
        ATTRIBUTE6 = P_ATTRIBUTE6,
        ATTRIBUTE7 = P_ATTRIBUTE7,
        ATTRIBUTE8 = P_ATTRIBUTE8,
        ATTRIBUTE9 = P_ATTRIBUTE9,
        ATTRIBUTE10 = P_ATTRIBUTE10,
        ATTRIBUTE11 = P_ATTRIBUTE11,
        ATTRIBUTE12 = P_ATTRIBUTE12,
        ATTRIBUTE13 = P_ATTRIBUTE13,
        ATTRIBUTE14 = P_ATTRIBUTE14,
        ATTRIBUTE15 = P_ATTRIBUTE15,
        ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY,
        LAST_UPDATED_BY = P_LAST_UPDATED_BY,
        LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
    WHERE TAX_RATE_ID = P_VAT_TAX_ID;

    UPDATE ZX_RATES_TL
    SET TAX_RATE_NAME = P_PRINTED_TAX_NAME,
        DESCRIPTION = P_DESCRIPTION,
        LAST_UPDATED_BY = P_LAST_UPDATED_BY,
        LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
    WHERE TAX_RATE_ID = P_VAT_TAX_ID;

    UPDATE ZX_ACCOUNTS
    SET LEDGER_ID = P_SET_OF_BOOKS_ID,
        TAX_ACCOUNT_CCID = P_TAX_ACCOUNT_ID,
        INTERIM_TAX_CCID = P_INTERIM_TAX_CCID,
        NON_REC_ACCOUNT_CCID = DECODE(P_GLOBAL_ATTRIBUTE_CATEGORY,'JL.CL.ARXSUVAT.VAT_TAX',
                         fnd_flex_ext.get_ccid( 'SQLGL','GL#',
                        (SELECT chart_of_accounts_id
                          FROM gl_sets_of_books
                         WHERE set_of_books_id = P_SET_OF_BOOKS_ID),
                                                 sysdate,P_GLOBAL_ATTRIBUTE5),NULL),
        ADJ_CCID = P_ADJ_CCID,
        EDISC_CCID = P_EDISC_CCID,
        UNEDISC_CCID = P_UNEDISC_CCID,
        FINCHRG_CCID = P_FINCHRG_CCID,
        ADJ_NON_REC_TAX_CCID = P_ADJ_NON_REC_TAX_CCID,
        EDISC_NON_REC_TAX_CCID = P_EDISC_NON_REC_TAX_CCID,
        UNEDISC_NON_REC_TAX_CCID = P_UNEDISC_NON_REC_TAX_CCID,
        FINCHRG_NON_REC_TAX_CCID = P_FINCHRG_NON_REC_TAX_CCID,
        LAST_UPDATED_BY = P_LAST_UPDATED_BY,
        LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
     WHERE TAX_ACCOUNT_ENTITY_ID = P_VAT_TAX_ID
       AND TAX_ACCOUNT_ENTITY_CODE = 'RATES';

  END IF;

  migrate_sco_code_lte( P_TAX_REGIME_CODE,
             P_ORG_ID,
             P_CREATION_DATE,
             P_CREATED_BY,
             P_LAST_UPDATE_DATE,
             P_LAST_UPDATED_BY,
             P_LAST_UPDATE_LOGIN);

  arp_util_tax.debug('SYNC_AR_VAT_TAX(-)');
END SYNC_AR_VAT_TAX;

END  ZX_UPGRADE_CONTROL_PKG ;

/
