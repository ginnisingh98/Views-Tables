--------------------------------------------------------
--  DDL for Package Body ARH_CPC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CPC_PKG" as
/*$Header: ARHCPCB.pls 120.5.12010000.2 2009/02/02 14:08:38 mpsingh ship $*/

--
PROCEDURE sel_class    (x_customer_profile_class_id     IN NUMBER,
                        x_collector_id                  IN OUT  NOCOPY NUMBER,
                        x_collector_name                IN OUT  NOCOPY VARCHAR2,
                        x_credit_checking               IN OUT  NOCOPY VARCHAR2,
                        x_tolerance                     IN OUT  NOCOPY VARCHAR2,
                        x_interest_charges              IN OUT  NOCOPY VARCHAR2,
                        x_charge_on_fin_charge_flag     IN OUT  NOCOPY VARCHAR2,
                        x_interest_period_days          IN OUT  NOCOPY NUMBER,
                        x_discount_terms                IN OUT  NOCOPY VARCHAR2,
                        x_discount_grace_days           IN OUT  NOCOPY NUMBER,
                        x_statements                    IN OUT  NOCOPY VARCHAR2,
                        x_statement_cycle_id            IN OUT  NOCOPY NUMBER,
                        x_statement_cycle_name          IN OUT  NOCOPY VARCHAR2,
                        x_credit_balance_statements     IN OUT  NOCOPY VARCHAR2,
                        x_standard_terms                IN OUT  NOCOPY NUMBER,
                        x_standard_terms_name           IN OUT  NOCOPY VARCHAR2,
                        x_override_terms                IN OUT  NOCOPY VARCHAR2,
                        x_payment_grace_days            IN OUT  NOCOPY NUMBER,
                        x_dunning_letters               IN OUT  NOCOPY VARCHAR2,
                        x_dunning_letter_set_id         IN OUT  NOCOPY NUMBER,
                        x_dunning_letter_set_name       IN OUT  NOCOPY VARCHAR2,
                        x_autocash_hierarchy_id         IN OUT  NOCOPY NUMBER,
                        x_autocash_hierarchy_name       IN OUT  NOCOPY VARCHAR2,
                        x_auto_rec_incl_disputed_flag   IN OUT  NOCOPY VARCHAR2,
                        x_tax_printing_option           IN OUT  NOCOPY VARCHAR2,
                        x_grouping_rule_id              IN OUT  NOCOPY VARCHAR2,
                        x_grouping_rule_name            IN OUT  NOCOPY VARCHAR2,
                        x_attribute_category            IN OUT  NOCOPY VARCHAR2,
                        x_attribute1                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute2                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute3                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute4                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute5                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute6                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute7                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute8                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute9                    IN OUT  NOCOPY VARCHAR2,
                        x_attribute10                   IN OUT  NOCOPY VARCHAR2,
                        x_attribute11                   IN OUT  NOCOPY VARCHAR2,
                        x_attribute12                   IN OUT  NOCOPY VARCHAR2,
                        x_attribute13                   IN OUT  NOCOPY VARCHAR2,
                        x_attribute14                   IN OUT  NOCOPY VARCHAR2,
                        x_attribute15                   IN OUT  NOCOPY VARCHAR2,
                        x_review_cycle                  IN OUT  NOCOPY VARCHAR2,
                        x_credit_analyst_id             IN OUT  NOCOPY NUMBER
                      )
IS
        CURSOR  c_cust_prof IS
        SELECT  collector_id,
                collector_name,
                credit_checking,
                tolerance,
                interest_charges,
                charge_on_finance_charge_flag,
                interest_period_days,
                discount_terms,
                discount_grace_days,
                statements,
                statement_cycle_id,
                statement_cycle_name,
                credit_balance_statements,
                standard_terms,
                standard_terms_name,
                override_terms,
                payment_grace_days,
                dunning_letters,
                dunning_letter_set_id,
                dunning_letter_set_name,
                autocash_hierarchy_id,
                autocash_hierarchy_name,
                auto_rec_incl_disputed_flag,
                tax_printing_option,
                grouping_rule_id,
                grouping_rule_name,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                review_cycle,
                credit_analyst_id
        FROM    ar_customer_profiles_v
        WHERE   customer_profile_class_id = x_customer_profile_class_id;
BEGIN
        OPEN c_cust_prof;
        FETCH c_cust_prof INTO
                x_collector_id,
                x_collector_name,
                x_credit_checking,
                x_tolerance,
                x_interest_charges,
                x_charge_on_fin_charge_flag,
                x_interest_period_days,
                x_discount_terms,
                x_discount_grace_days,
                x_statements,
                x_statement_cycle_id,
                x_statement_cycle_name,
                x_credit_balance_statements,
                x_standard_terms,
                x_standard_terms_name,
                x_override_terms,
                x_payment_grace_days,
                x_dunning_letters,
                x_dunning_letter_set_id,
                x_dunning_letter_set_name,
                x_autocash_hierarchy_id,
                x_autocash_hierarchy_name,
                x_auto_rec_incl_disputed_flag,
                x_tax_printing_option,
                x_grouping_rule_id,
                x_grouping_rule_name,
                x_attribute_category,
                x_attribute1,
                x_attribute2,
                x_attribute3,
                x_attribute4,
                x_attribute5,
                x_attribute6,
                x_attribute7,
                x_attribute8,
                x_attribute9,
                x_attribute10,
                x_attribute11,
                x_attribute12,
                x_attribute13,
                x_attribute14,
                x_attribute15,
                x_review_cycle,
                x_credit_analyst_id;
   CLOSE c_cust_prof;
END sel_class;
--
--
PROCEDURE check_unique
(c_profile_class_name in varchar2,
 c_rowid              in varchar2)
is
  profile_class_count number;
BEGIN
  select 1
  into   profile_class_count
  from   dual
  where  not exists ( select 1
                      from   hz_cust_profile_classes
                      where  name = c_profile_class_name
                      and    profile_class_id >= 0
                      and    ( ( c_rowid is null ) or ( rowid <> c_rowid ) )
                    );
exception
    when no_data_found then
      fnd_message.set_name ('AR', 'AR_CUST_DUP_PROF_NAME');
      app_exception.raise_exception;
END check_unique;





PROCEDURE Insert_Row  (X_Row_Id                         IN OUT NOCOPY VARCHAR2,
                       X_Customer_Profile_Class_Id      IN OUT NOCOPY NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Profile_Class_Name             VARCHAR2,
                       X_Profile_Class_Description      VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Credit_Checking                VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Interest_Charges               VARCHAR2,
                       X_Charge_On_Finance_Charge_Flg   VARCHAR2,
                       X_Interest_Period_Days           NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Discount_Grace_Days            NUMBER,
                       X_Statements                     VARCHAR2,
                       X_Statement_Cycle_Id             NUMBER,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Standard_Terms                 NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Dunning_Letters                VARCHAR2,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Copy_Method                    VARCHAR2,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Tax_Printing_Option_Meaning    VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Jgzz_attribute_Category        VARCHAR2,
                       X_Jgzz_attribute1                VARCHAR2,
                       X_Jgzz_attribute2                VARCHAR2,
                       X_Jgzz_attribute3                VARCHAR2,
                       X_Jgzz_attribute4                VARCHAR2,
                       X_Jgzz_attribute5                VARCHAR2,
                       X_Jgzz_attribute6                VARCHAR2,
                       X_Jgzz_attribute7                VARCHAR2,
                       X_Jgzz_attribute8                VARCHAR2,
                       X_Jgzz_attribute9                VARCHAR2,
                       X_Jgzz_attribute10               VARCHAR2,
                       X_Jgzz_attribute11               VARCHAR2,
                       X_Jgzz_attribute12               VARCHAR2,
                       X_Jgzz_attribute13               VARCHAR2,
                       X_Jgzz_attribute14               VARCHAR2,
                       X_Jgzz_attribute15               VARCHAR2,
                       X_global_attribute_category      VARCHAR2,
                       X_global_attribute1              VARCHAR2,
                       X_global_attribute2              VARCHAR2,
                       X_global_attribute3              VARCHAR2,
                       X_global_attribute4              VARCHAR2,
                       X_global_attribute5              VARCHAR2,
                       X_global_attribute6              VARCHAR2,
                       X_global_attribute7              VARCHAR2,
                       X_global_attribute8              VARCHAR2,
                       X_global_attribute9              VARCHAR2,
                       X_global_attribute10             VARCHAR2,
                       X_global_attribute11             VARCHAR2,
                       X_global_attribute12             VARCHAR2,
                       X_global_attribute13             VARCHAR2,
                       X_global_attribute14             VARCHAR2,
                       X_global_attribute15             VARCHAR2,
                       X_global_attribute16             VARCHAR2,
                       X_global_attribute17             VARCHAR2,
                       X_global_attribute18             VARCHAR2,
                       X_global_attribute19             VARCHAR2,
                       X_global_attribute20             VARCHAR2,
                       X_lockbox_matching_option        VARCHAR2,
                       X_autocash_hierarchy_id_adr      NUMBER,
                       X_review_cycle                   VARCHAR2 DEFAULT NULL,
                       X_credit_analyst_id              NUMBER   DEFAULT NULL,
                       X_Cons_Bill_Level                VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_CALCULATION_TRX    VARCHAR2 DEFAULT NULL,
                       X_CREDIT_ITEMS_FLAG              VARCHAR2 DEFAULT NULL,
                       X_DISPUTED_TRANSACTIONS_FLAG     VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TYPE               VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TERM_ID            NUMBER   DEFAULT NULL,
                       X_INTEREST_CALCULATION_PERIOD    VARCHAR2 DEFAULT NULL,
                       X_HOLD_CHARGED_INVOICES_FLAG     VARCHAR2 DEFAULT NULL,
                       X_MESSAGE_TEXT_ID                NUMBER   DEFAULT NULL,
                       X_MULTIPLE_INTEREST_RATES_FLAG   VARCHAR2 DEFAULT NULL,
                       X_CHARGE_BEGIN_DATE              DATE     DEFAULT NULL,
		       X_AUTOMATCH_SET_ID		NUMBER	 DEFAULT NULL)
IS
BEGIN

/*Bug 3619062 Call overloaded procedure with credit_classification set as NULL*/
Insert_Row  (          X_Row_Id                         =>  X_Row_Id                         ,
                       X_Customer_Profile_Class_Id      =>  X_Customer_Profile_Class_Id      ,
                       X_Last_Updated_By                =>  X_Last_Updated_By                ,
                       X_Last_Update_Date               =>  X_Last_Update_Date               ,
                       X_Last_Update_Login              =>  X_Last_Update_Login              ,
                       X_Created_By                     =>  X_Created_By                     ,
                       X_Creation_Date                  =>  X_Creation_Date                  ,
                       X_Profile_Class_Name             =>  X_Profile_Class_Name             ,
                       X_Profile_Class_Description      =>  X_Profile_Class_Description      ,
                       X_Status                         =>  X_Status                         ,
                       X_Collector_Id                   =>  X_Collector_Id                   ,
                       X_Credit_Checking                =>  X_Credit_Checking                ,
                       X_Tolerance                      =>  X_Tolerance                      ,
                       X_Interest_Charges               =>  X_Interest_Charges               ,
                       X_Charge_On_Finance_Charge_Flg   =>  X_Charge_On_Finance_Charge_Flg   ,
                       X_Interest_Period_Days           =>  X_Interest_Period_Days           ,
                       X_Discount_Terms                 =>  X_Discount_Terms                 ,
                       X_Discount_Grace_Days            =>  X_Discount_Grace_Days            ,
                       X_Statements                     =>  X_Statements                     ,
                       X_Statement_Cycle_Id             =>  X_Statement_Cycle_Id             ,
                       X_Credit_Balance_Statements      =>  X_Credit_Balance_Statements      ,
                       X_Standard_Terms                 =>  X_Standard_Terms                 ,
                       X_Override_Terms                 =>  X_Override_Terms                 ,
                       X_Payment_Grace_Days             =>  X_Payment_Grace_Days             ,
                       X_Dunning_Letters                =>  X_Dunning_Letters                ,
                       X_Dunning_Letter_Set_Id          =>  X_Dunning_Letter_Set_Id          ,
                       X_Autocash_Hierarchy_Id          =>  X_Autocash_Hierarchy_Id          ,
                       X_Copy_Method                    =>  X_Copy_Method                    ,
                       X_Auto_Rec_Incl_Disputed_Flag    =>  X_Auto_Rec_Incl_Disputed_Flag    ,
                       X_Tax_Printing_Option            =>  X_Tax_Printing_Option            ,
                       X_Tax_Printing_Option_Meaning    =>  X_Tax_Printing_Option_Meaning    ,
                       X_Grouping_Rule_Id               =>  X_Grouping_Rule_Id               ,
                       X_Cons_Inv_Flag                  =>  X_Cons_Inv_Flag                  ,
                       X_Cons_Inv_Type                  =>  X_Cons_Inv_Type                  ,
                       X_Request_Id                     =>  X_Request_Id                     ,
                       X_Attribute_Category             =>  X_Attribute_Category             ,
                       X_Attribute1                     =>  X_Attribute1                     ,
                       X_Attribute2                     =>  X_Attribute2                     ,
                       X_Attribute3                     =>  X_Attribute3                     ,
                       X_Attribute4                     =>  X_Attribute4                     ,
                       X_Attribute5                     =>  X_Attribute5                     ,
                       X_Attribute6                     =>  X_Attribute6                     ,
                       X_Attribute7                     =>  X_Attribute7                     ,
                       X_Attribute8                     =>  X_Attribute8                     ,
                       X_Attribute9                     =>  X_Attribute9                     ,
                       X_Attribute10                    =>  X_Attribute10                    ,
                       X_Attribute11                    =>  X_Attribute11                    ,
                       X_Attribute12                    =>  X_Attribute12                    ,
                       X_Attribute13                    =>  X_Attribute13                    ,
                       X_Attribute14                    =>  X_Attribute14                    ,
                       X_Attribute15                    =>  X_Attribute15                    ,
                       X_Jgzz_attribute_Category        =>  X_Jgzz_attribute_Category        ,
                       X_Jgzz_attribute1                =>  X_Jgzz_attribute1                ,
                       X_Jgzz_attribute2                =>  X_Jgzz_attribute2                ,
                       X_Jgzz_attribute3                =>  X_Jgzz_attribute3                ,
                       X_Jgzz_attribute4                =>  X_Jgzz_attribute4                ,
                       X_Jgzz_attribute5                =>  X_Jgzz_attribute5                ,
                       X_Jgzz_attribute6                =>  X_Jgzz_attribute6                ,
                       X_Jgzz_attribute7                =>  X_Jgzz_attribute7                ,
                       X_Jgzz_attribute8                =>  X_Jgzz_attribute8                ,
                       X_Jgzz_attribute9                =>  X_Jgzz_attribute9                ,
                       X_Jgzz_attribute10               =>  X_Jgzz_attribute10               ,
                       X_Jgzz_attribute11               =>  X_Jgzz_attribute11               ,
                       X_Jgzz_attribute12               =>  X_Jgzz_attribute12               ,
                       X_Jgzz_attribute13               =>  X_Jgzz_attribute13               ,
                       X_Jgzz_attribute14               =>  X_Jgzz_attribute14               ,
                       X_Jgzz_attribute15               =>  X_Jgzz_attribute15               ,
                       X_global_attribute_category      =>  X_global_attribute_category      ,
                       X_global_attribute1              =>  X_global_attribute1              ,
                       X_global_attribute2              =>  X_global_attribute2              ,
                       X_global_attribute3              =>  X_global_attribute3              ,
                       X_global_attribute4              =>  X_global_attribute4              ,
                       X_global_attribute5              =>  X_global_attribute5              ,
                       X_global_attribute6              =>  X_global_attribute6              ,
                       X_global_attribute7              =>  X_global_attribute7              ,
                       X_global_attribute8              =>  X_global_attribute8              ,
                       X_global_attribute9              =>  X_global_attribute9              ,
                       X_global_attribute10             =>  X_global_attribute10             ,
                       X_global_attribute11             =>  X_global_attribute11             ,
                       X_global_attribute12             =>  X_global_attribute12             ,
                       X_global_attribute13             =>  X_global_attribute13             ,
                       X_global_attribute14             =>  X_global_attribute14             ,
                       X_global_attribute15             =>  X_global_attribute15             ,
                       X_global_attribute16             =>  X_global_attribute16             ,
                       X_global_attribute17             =>  X_global_attribute17             ,
                       X_global_attribute18             =>  X_global_attribute18             ,
                       X_global_attribute19             =>  X_global_attribute19             ,
                       X_global_attribute20             =>  X_global_attribute20             ,
                       X_lockbox_matching_option        =>  X_lockbox_matching_option        ,
                       X_autocash_hierarchy_id_adr      =>  X_autocash_hierarchy_id_adr      ,
                       X_review_cycle                   =>  X_review_cycle                   ,
                       X_credit_analyst_id              =>  X_credit_analyst_id              ,
                       X_credit_classification          =>  NULL                             ,
                       X_Cons_Bill_Level                =>  X_Cons_Bill_Level,
                       X_LATE_CHARGE_CALCULATION_TRX    =>  X_LATE_CHARGE_CALCULATION_TRX,
                       X_CREDIT_ITEMS_FLAG              =>  X_CREDIT_ITEMS_FLAG,
                       X_DISPUTED_TRANSACTIONS_FLAG     =>  X_DISPUTED_TRANSACTIONS_FLAG,
                       X_LATE_CHARGE_TYPE               =>  X_LATE_CHARGE_TYPE,
                       X_LATE_CHARGE_TERM_ID            =>  X_LATE_CHARGE_TERM_ID,
                       X_INTEREST_CALCULATION_PERIOD    =>  X_INTEREST_CALCULATION_PERIOD,
                       X_HOLD_CHARGED_INVOICES_FLAG     =>  X_HOLD_CHARGED_INVOICES_FLAG,
                       X_MESSAGE_TEXT_ID                =>  X_MESSAGE_TEXT_ID,
                       X_MULTIPLE_INTEREST_RATES_FLAG   =>  X_MULTIPLE_INTEREST_RATES_FLAG,
                       X_CHARGE_BEGIN_DATE              =>  X_CHARGE_BEGIN_DATE    ,
		       X_AUTOMATCH_SET_ID		=>  X_AUTOMATCH_SET_ID);

END Insert_Row;

PROCEDURE Insert_Row  (X_Row_Id                         IN OUT NOCOPY VARCHAR2,
                       X_Customer_Profile_Class_Id      IN OUT NOCOPY NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Profile_Class_Name             VARCHAR2,
                       X_Profile_Class_Description      VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Credit_Checking                VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Interest_Charges               VARCHAR2,
                       X_Charge_On_Finance_Charge_Flg   VARCHAR2,
                       X_Interest_Period_Days           NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Discount_Grace_Days            NUMBER,
                       X_Statements                     VARCHAR2,
                       X_Statement_Cycle_Id             NUMBER,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Standard_Terms                 NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Dunning_Letters                VARCHAR2,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Copy_Method                    VARCHAR2,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Tax_Printing_Option_Meaning    VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Jgzz_attribute_Category        VARCHAR2,
                       X_Jgzz_attribute1                VARCHAR2,
                       X_Jgzz_attribute2                VARCHAR2,
                       X_Jgzz_attribute3                VARCHAR2,
                       X_Jgzz_attribute4                VARCHAR2,
                       X_Jgzz_attribute5                VARCHAR2,
                       X_Jgzz_attribute6                VARCHAR2,
                       X_Jgzz_attribute7                VARCHAR2,
                       X_Jgzz_attribute8                VARCHAR2,
                       X_Jgzz_attribute9                VARCHAR2,
                       X_Jgzz_attribute10               VARCHAR2,
                       X_Jgzz_attribute11               VARCHAR2,
                       X_Jgzz_attribute12               VARCHAR2,
                       X_Jgzz_attribute13               VARCHAR2,
                       X_Jgzz_attribute14               VARCHAR2,
                       X_Jgzz_attribute15               VARCHAR2,
                       X_global_attribute_category      VARCHAR2,
                       X_global_attribute1              VARCHAR2,
                       X_global_attribute2              VARCHAR2,
                       X_global_attribute3              VARCHAR2,
                       X_global_attribute4              VARCHAR2,
                       X_global_attribute5              VARCHAR2,
                       X_global_attribute6              VARCHAR2,
                       X_global_attribute7              VARCHAR2,
                       X_global_attribute8              VARCHAR2,
                       X_global_attribute9              VARCHAR2,
                       X_global_attribute10             VARCHAR2,
                       X_global_attribute11             VARCHAR2,
                       X_global_attribute12             VARCHAR2,
                       X_global_attribute13             VARCHAR2,
                       X_global_attribute14             VARCHAR2,
                       X_global_attribute15             VARCHAR2,
                       X_global_attribute16             VARCHAR2,
                       X_global_attribute17             VARCHAR2,
                       X_global_attribute18             VARCHAR2,
                       X_global_attribute19             VARCHAR2,
                       X_global_attribute20             VARCHAR2,
                       X_lockbox_matching_option        VARCHAR2,
                       X_autocash_hierarchy_id_adr      NUMBER,
                       X_review_cycle                   VARCHAR2 DEFAULT NULL,
                       X_credit_analyst_id              NUMBER   DEFAULT NULL,
                       X_credit_classification          VARCHAR2,   /*Bug 3619062*/
                       X_Cons_Bill_Level                VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_CALCULATION_TRX    VARCHAR2 DEFAULT NULL,
                       X_CREDIT_ITEMS_FLAG              VARCHAR2 DEFAULT NULL,
                       X_DISPUTED_TRANSACTIONS_FLAG     VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TYPE               VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TERM_ID            NUMBER   DEFAULT NULL,
                       X_INTEREST_CALCULATION_PERIOD    VARCHAR2 DEFAULT NULL,
                       X_HOLD_CHARGED_INVOICES_FLAG     VARCHAR2 DEFAULT NULL,
                       X_MESSAGE_TEXT_ID                NUMBER   DEFAULT NULL,
                       X_MULTIPLE_INTEREST_RATES_FLAG   VARCHAR2 DEFAULT NULL,
                       X_CHARGE_BEGIN_DATE              DATE     DEFAULT NULL,
		       X_AUTOMATCH_SET_ID		NUMBER	 DEFAULT NULL)
IS
   CURSOR C IS SELECT rowid
               FROM   hz_cust_profile_classes
               WHERE  profile_class_id = X_Customer_Profile_Class_Id;

BEGIN
    IF X_CUSTOMER_PROFILE_CLASS_ID IS NULL THEN
        select hz_cust_profile_classes_s.nextval
        into   x_customer_profile_class_id
        from   dual;
    END IF;

    -- Calling check_unique Procedure To Verify The Uniqueness Of The Customer
    -- Profile Class Id
    check_unique
	 (  c_profile_class_name => x_customer_profile_class_id,
        c_rowid              => x_row_id  );

    INSERT INTO HZ_CUST_PROFILE_CLASSES(
              profile_class_id,
              last_updated_by,
              last_update_date,
              last_update_login,
              created_by,
              creation_date,
              name,
              description,
              status,
              collector_id,
              credit_checking,
              tolerance,
              interest_charges,
              charge_on_finance_charge_flag,
              interest_period_days,
              discount_terms,
              discount_grace_days,
              statements,
              statement_cycle_id,
              credit_balance_statements,
              standard_terms,
              override_terms,
              payment_grace_days,
              dunning_letters,
              dunning_letter_set_id,
              autocash_hierarchy_id,
              copy_method,
              auto_rec_incl_disputed_flag,
              tax_printing_option,
              grouping_rule_id,
              cons_inv_flag,
              cons_inv_type,
              request_Id,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              jgzz_attribute_category,
              jgzz_attribute1,
              jgzz_attribute2,
              jgzz_attribute3,
              jgzz_attribute4,
              jgzz_attribute5,
              jgzz_attribute6,
              jgzz_attribute7,
              jgzz_attribute8,
              jgzz_attribute9,
              jgzz_attribute10,
              jgzz_attribute11,
              jgzz_attribute12,
              jgzz_attribute13,
              jgzz_attribute14,
              jgzz_attribute15,
              global_attribute_category,
              global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              lockbox_matching_option,
              autocash_hierarchy_id_for_adr,
              review_cycle,
              credit_analyst_id,
	          credit_classification, /*Bug 3619062*/
              Cons_Bill_Level,
              LATE_CHARGE_CALCULATION_TRX ,
              CREDIT_ITEMS_FLAG           ,
              DISPUTED_TRANSACTIONS_FLAG  ,
              LATE_CHARGE_TYPE            ,
              LATE_CHARGE_TERM_ID         ,
              INTEREST_CALCULATION_PERIOD ,
              HOLD_CHARGED_INVOICES_FLAG  ,
              MESSAGE_TEXT_ID             ,
              MULTIPLE_INTEREST_RATES_FLAG,
              CHARGE_BEGIN_DATE           ,
	      AUTOMATCH_SET_ID            )
              VALUES (
              X_Customer_Profile_Class_Id,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Update_Login,
              X_Created_By,
              X_Creation_Date,
              X_Profile_Class_Name,
              X_Profile_Class_Description,
              X_Status,
              X_Collector_Id,
              X_Credit_Checking,
              X_Tolerance,
              X_Interest_Charges,
              X_Charge_On_Finance_Charge_Flg,
              X_Interest_Period_Days,
              X_Discount_Terms,
              X_Discount_Grace_Days,
              X_Statements,
              X_Statement_Cycle_Id,
              X_Credit_Balance_Statements,
              X_Standard_Terms,
              X_Override_Terms,
              X_Payment_Grace_Days,
              X_Dunning_Letters,
              X_Dunning_Letter_Set_Id,
              X_Autocash_Hierarchy_Id,
              X_Copy_Method,
              X_Auto_Rec_Incl_Disputed_Flag,
              X_Tax_Printing_Option,
              X_Grouping_Rule_Id,
              X_Cons_Inv_Flag,
              X_Cons_Inv_Type,
              X_Request_Id,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Jgzz_attribute_Category,
              X_Jgzz_attribute1,
              X_Jgzz_attribute2,
              X_Jgzz_attribute3,
              X_Jgzz_attribute4,
              X_Jgzz_attribute5,
              X_Jgzz_attribute6,
              X_Jgzz_attribute7,
              X_Jgzz_attribute8,
              X_Jgzz_attribute9,
              X_Jgzz_attribute10,
              X_Jgzz_attribute11,
              X_Jgzz_attribute12,
              X_Jgzz_attribute13,
              X_Jgzz_attribute14,
              X_Jgzz_attribute15,
              X_global_attribute_category,
              X_global_attribute1,
              X_global_attribute2,
              X_global_attribute3,
              X_global_attribute4,
              X_global_attribute5,
              X_global_attribute6,
              X_global_attribute7,
              X_global_attribute8,
              X_global_attribute9,
              X_global_attribute10,
              X_global_attribute11,
              X_global_attribute12,
              X_global_attribute13,
              X_global_attribute14,
              X_global_attribute15,
              X_global_attribute16,
              X_global_attribute17,
              X_global_attribute18,
              X_global_attribute19,
              X_global_attribute20,
              X_lockbox_matching_option,
              X_autocash_hierarchy_id_adr,
              X_review_cycle,
              X_credit_analyst_id,
              X_credit_classification,  /*Bug 3619062*/
              X_Cons_Bill_Level,
              X_LATE_CHARGE_CALCULATION_TRX ,
              X_CREDIT_ITEMS_FLAG           ,
              X_DISPUTED_TRANSACTIONS_FLAG  ,
              X_LATE_CHARGE_TYPE            ,
              X_LATE_CHARGE_TERM_ID         ,
              X_INTEREST_CALCULATION_PERIOD ,
              X_HOLD_CHARGED_INVOICES_FLAG  ,
              X_MESSAGE_TEXT_ID             ,
              X_MULTIPLE_INTEREST_RATES_FLAG,
              X_CHARGE_BEGIN_DATE           ,
	      X_AUTOMATCH_SET_ID            );

  -- Setting The Value Of Row Id To Be Returned To The Forms Block
  -- "cust_prof" Block
  OPEN C;
    FETCH C INTO X_Row_id;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
  CLOSE C;
END Insert_Row;





PROCEDURE Lock_Row  (X_Row_Id                           VARCHAR2,
                     X_Customer_Profile_Class_Id        NUMBER,
                     X_Profile_Class_Name               VARCHAR2,
                     X_Profile_Class_Description        VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Collector_Id                     NUMBER,
                     X_Credit_Checking                  VARCHAR2,
                     X_Tolerance                        NUMBER,
                     X_Interest_Charges                 VARCHAR2,
                     X_Charge_On_Finance_Charge_Flg     VARCHAR2,
                     X_Interest_Period_Days             NUMBER,
                     X_Discount_Terms                   VARCHAR2,
                     X_Discount_Grace_Days              NUMBER,
                     X_Statements                       VARCHAR2,
                     X_Statement_Cycle_Id               NUMBER,
                     X_Credit_Balance_Statements        VARCHAR2,
                     X_Standard_Terms                   NUMBER,
                     X_Override_Terms                   VARCHAR2,
                     X_Payment_Grace_Days               NUMBER,
                     X_Dunning_Letters                  VARCHAR2,
                     X_Dunning_Letter_Set_Id            NUMBER,
                     X_Autocash_Hierarchy_Id            NUMBER,
                     X_Copy_Method                      VARCHAR2,
                     X_Auto_Rec_Incl_Disputed_Flag      VARCHAR2,
                     X_Tax_Printing_Option              VARCHAR2,
                     X_Tax_Printing_Option_Meaning      VARCHAR2,
                     X_Grouping_Rule_Id                 NUMBER,
                     X_Cons_Inv_Flag                    VARCHAR2,
                     X_Cons_Inv_Type                    VARCHAR2,
                     X_Request_Id                       NUMBER,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Jgzz_attribute_Category          VARCHAR2,
                     X_Jgzz_attribute1                  VARCHAR2,
                     X_Jgzz_attribute2                  VARCHAR2,
                     X_Jgzz_attribute3                  VARCHAR2,
                     X_Jgzz_attribute4                  VARCHAR2,
                     X_Jgzz_attribute5                  VARCHAR2,
                     X_Jgzz_attribute6                  VARCHAR2,
                     X_Jgzz_attribute7                  VARCHAR2,
                     X_Jgzz_attribute8                  VARCHAR2,
                     X_Jgzz_attribute9                  VARCHAR2,
                     X_Jgzz_attribute10                 VARCHAR2,
                     X_Jgzz_attribute11                 VARCHAR2,
                     X_Jgzz_attribute12                 VARCHAR2,
                     X_Jgzz_attribute13                 VARCHAR2,
                     X_Jgzz_attribute14                 VARCHAR2,
                     X_Jgzz_attribute15                 VARCHAR2,
                     X_global_attribute_category        VARCHAR2,
                     X_global_attribute1                VARCHAR2,
                     X_global_attribute2                VARCHAR2,
                     X_global_attribute3                VARCHAR2,
                     X_global_attribute4                VARCHAR2,
                     X_global_attribute5                VARCHAR2,
                     X_global_attribute6                VARCHAR2,
                     X_global_attribute7                VARCHAR2,
                     X_global_attribute8                VARCHAR2,
                     X_global_attribute9                VARCHAR2,
                     X_global_attribute10               VARCHAR2,
                     X_global_attribute11               VARCHAR2,
                     X_global_attribute12               VARCHAR2,
                     X_global_attribute13               VARCHAR2,
                     X_global_attribute14               VARCHAR2,
                     X_global_attribute15               VARCHAR2,
                     X_global_attribute16               VARCHAR2,
                     X_global_attribute17               VARCHAR2,
                     X_global_attribute18               VARCHAR2,
                     X_global_attribute19               VARCHAR2,
                     X_global_attribute20               VARCHAR2,
                     X_lockbox_matching_option          VARCHAR2,
                     X_autocash_hierarchy_id_adr        NUMBER,
                     X_review_cycle                     VARCHAR2,
                     X_credit_analyst_id                NUMBER,
                     X_Cons_Bill_Level                  VARCHAR2,
                     X_LATE_CHARGE_CALCULATION_TRX      VARCHAR2,
                     X_CREDIT_ITEMS_FLAG                VARCHAR2,
                     X_DISPUTED_TRANSACTIONS_FLAG       VARCHAR2,
                     X_LATE_CHARGE_TYPE                 VARCHAR2,
                     X_LATE_CHARGE_TERM_ID              NUMBER,
                     X_INTEREST_CALCULATION_PERIOD      VARCHAR2,
                     X_HOLD_CHARGED_INVOICES_FLAG       VARCHAR2,
                     X_MESSAGE_TEXT_ID                  NUMBER,
                     X_MULTIPLE_INTEREST_RATES_FLAG     VARCHAR2,
                     X_CHARGE_BEGIN_DATE                DATE,
		     X_AUTOMATCH_SET_ID			NUMBER)
IS
BEGIN

/*Bug 3619062 Call overloaded procedure with credit_classification set as NULL*/
 Lock_Row  (         X_Row_Id                           =>  X_Row_id                            ,
                     X_Customer_Profile_Class_Id        =>  X_Customer_Profile_Class_Id        ,
                     X_Profile_Class_Name               =>  X_Profile_Class_Name               ,
                     X_Profile_Class_Description        =>  X_Profile_Class_Description        ,
                     X_Status                           =>  X_Status                           ,
                     X_Collector_Id                     =>  X_Collector_Id                     ,
                     X_Credit_Checking                  =>  X_Credit_Checking                  ,
                     X_Tolerance                        =>  X_Tolerance                        ,
                     X_Interest_Charges                 =>  X_Interest_Charges                 ,
                     X_Charge_On_Finance_Charge_Flg     =>  X_Charge_On_Finance_Charge_Flg     ,
                     X_Interest_Period_Days             =>  X_Interest_Period_Days             ,
                     X_Discount_Terms                   =>  X_Discount_Terms                   ,
                     X_Discount_Grace_Days              =>  X_Discount_Grace_Days              ,
                     X_Statements                       =>  X_Statements                       ,
                     X_Statement_Cycle_Id               =>  X_Statement_Cycle_Id               ,
                     X_Credit_Balance_Statements        =>  X_Credit_Balance_Statements        ,
                     X_Standard_Terms                   =>  X_Standard_Terms                   ,
                     X_Override_Terms                   =>  X_Override_Terms                   ,
                     X_Payment_Grace_Days               =>  X_Payment_Grace_Days               ,
                     X_Dunning_Letters                  =>  X_Dunning_Letters                  ,
                     X_Dunning_Letter_Set_Id            =>  X_Dunning_Letter_Set_Id            ,
                     X_Autocash_Hierarchy_Id            =>  X_Autocash_Hierarchy_Id            ,
                     X_Copy_Method                      =>  X_Copy_Method                      ,
                     X_Auto_Rec_Incl_Disputed_Flag      =>  X_Auto_Rec_Incl_Disputed_Flag      ,
                     X_Tax_Printing_Option              =>  X_Tax_Printing_Option              ,
                     X_Tax_Printing_Option_Meaning      =>  X_Tax_Printing_Option_Meaning      ,
                     X_Grouping_Rule_Id                 =>  X_Grouping_Rule_Id                 ,
                     X_Cons_Inv_Flag                    =>  X_Cons_Inv_Flag                    ,
                     X_Cons_Inv_Type                    =>  X_Cons_Inv_Type                    ,
                     X_Request_Id                       =>  X_Request_Id                       ,
                     X_Attribute_Category               =>  X_Attribute_Category               ,
                     X_Attribute1                       =>  X_Attribute1                       ,
                     X_Attribute2                       =>  X_Attribute2                       ,
                     X_Attribute3                       =>  X_Attribute3                       ,
                     X_Attribute4                       =>  X_Attribute4                       ,
                     X_Attribute5                       =>  X_Attribute5                       ,
                     X_Attribute6                       =>  X_Attribute6                       ,
                     X_Attribute7                       =>  X_Attribute7                       ,
                     X_Attribute8                       =>  X_Attribute8                       ,
                     X_Attribute9                       =>  X_Attribute9                       ,
                     X_Attribute10                      =>  X_Attribute10                      ,
                     X_Attribute11                      =>  X_Attribute11                      ,
                     X_Attribute12                      =>  X_Attribute12                      ,
                     X_Attribute13                      =>  X_Attribute13                      ,
                     X_Attribute14                      =>  X_Attribute14                      ,
                     X_Attribute15                      =>  X_Attribute15                      ,
                     X_Jgzz_attribute_Category          =>  X_Jgzz_attribute_Category          ,
                     X_Jgzz_attribute1                  =>  X_Jgzz_attribute1                  ,
                     X_Jgzz_attribute2                  =>  X_Jgzz_attribute2                  ,
                     X_Jgzz_attribute3                  =>  X_Jgzz_attribute3                  ,
                     X_Jgzz_attribute4                  =>  X_Jgzz_attribute4                  ,
                     X_Jgzz_attribute5                  =>  X_Jgzz_attribute5                  ,
                     X_Jgzz_attribute6                  =>  X_Jgzz_attribute6                  ,
                     X_Jgzz_attribute7                  =>  X_Jgzz_attribute7                  ,
                     X_Jgzz_attribute8                  =>  X_Jgzz_attribute8                  ,
                     X_Jgzz_attribute9                  =>  X_Jgzz_attribute9                  ,
                     X_Jgzz_attribute10                 =>  X_Jgzz_attribute10                 ,
                     X_Jgzz_attribute11                 =>  X_Jgzz_attribute11                 ,
                     X_Jgzz_attribute12                 =>  X_Jgzz_attribute12                 ,
                     X_Jgzz_attribute13                 =>  X_Jgzz_attribute13                 ,
                     X_Jgzz_attribute14                 =>  X_Jgzz_attribute14                 ,
                     X_Jgzz_attribute15                 =>  X_Jgzz_attribute15                 ,
                     X_global_attribute_category        =>  X_global_attribute_category        ,
                     X_global_attribute1                =>  X_global_attribute1                ,
                     X_global_attribute2                =>  X_global_attribute2                ,
                     X_global_attribute3                =>  X_global_attribute3                ,
                     X_global_attribute4                =>  X_global_attribute4                ,
                     X_global_attribute5                =>  X_global_attribute5                ,
                     X_global_attribute6                =>  X_global_attribute6                ,
                     X_global_attribute7                =>  X_global_attribute7                ,
                     X_global_attribute8                =>  X_global_attribute8                ,
                     X_global_attribute9                =>  X_global_attribute9                ,
                     X_global_attribute10               =>  X_global_attribute10               ,
                     X_global_attribute11               =>  X_global_attribute11               ,
                     X_global_attribute12               =>  X_global_attribute12               ,
                     X_global_attribute13               =>  X_global_attribute13               ,
                     X_global_attribute14               =>  X_global_attribute14               ,
                     X_global_attribute15               =>  X_global_attribute15               ,
                     X_global_attribute16               =>  X_global_attribute16               ,
                     X_global_attribute17               =>  X_global_attribute17               ,
                     X_global_attribute18               =>  X_global_attribute18               ,
                     X_global_attribute19               =>  X_global_attribute19               ,
                     X_global_attribute20               =>  X_global_attribute20               ,
                     X_lockbox_matching_option          =>  X_lockbox_matching_option          ,
                     X_autocash_hierarchy_id_adr        =>  X_autocash_hierarchy_id_adr        ,
                     X_review_cycle                     =>  X_review_cycle                     ,
                     X_credit_analyst_id                =>  X_credit_analyst_id                ,
                     X_credit_classification            =>  NULL                               ,
                     X_Cons_Bill_Level                  =>  X_Cons_Bill_Level,
                     X_LATE_CHARGE_CALCULATION_TRX      =>  X_LATE_CHARGE_CALCULATION_TRX,
                     X_CREDIT_ITEMS_FLAG                =>  X_CREDIT_ITEMS_FLAG,
                     X_DISPUTED_TRANSACTIONS_FLAG       =>  X_DISPUTED_TRANSACTIONS_FLAG,
                     X_LATE_CHARGE_TYPE                 =>  X_LATE_CHARGE_TYPE,
                     X_LATE_CHARGE_TERM_ID              =>  X_LATE_CHARGE_TERM_ID,
                     X_INTEREST_CALCULATION_PERIOD      =>  X_INTEREST_CALCULATION_PERIOD,
                     X_HOLD_CHARGED_INVOICES_FLAG       =>  X_HOLD_CHARGED_INVOICES_FLAG,
                     X_MESSAGE_TEXT_ID                  =>  X_MESSAGE_TEXT_ID,
                     X_MULTIPLE_INTEREST_RATES_FLAG     =>  X_MULTIPLE_INTEREST_RATES_FLAG,
                     X_CHARGE_BEGIN_DATE                =>  X_CHARGE_BEGIN_DATE,
		     X_AUTOMATCH_SET_ID			=>  X_AUTOMATCH_SET_ID);
END Lock_Row;

PROCEDURE Lock_Row  (X_Row_Id                           VARCHAR2,
                     X_Customer_Profile_Class_Id        NUMBER,
                     X_Profile_Class_Name               VARCHAR2,
                     X_Profile_Class_Description        VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Collector_Id                     NUMBER,
                     X_Credit_Checking                  VARCHAR2,
                     X_Tolerance                        NUMBER,
                     X_Interest_Charges                 VARCHAR2,
                     X_Charge_On_Finance_Charge_Flg     VARCHAR2,
                     X_Interest_Period_Days             NUMBER,
                     X_Discount_Terms                   VARCHAR2,
                     X_Discount_Grace_Days              NUMBER,
                     X_Statements                       VARCHAR2,
                     X_Statement_Cycle_Id               NUMBER,
                     X_Credit_Balance_Statements        VARCHAR2,
                     X_Standard_Terms                   NUMBER,
                     X_Override_Terms                   VARCHAR2,
                     X_Payment_Grace_Days               NUMBER,
                     X_Dunning_Letters                  VARCHAR2,
                     X_Dunning_Letter_Set_Id            NUMBER,
                     X_Autocash_Hierarchy_Id            NUMBER,
                     X_Copy_Method                      VARCHAR2,
                     X_Auto_Rec_Incl_Disputed_Flag      VARCHAR2,
                     X_Tax_Printing_Option              VARCHAR2,
                     X_Tax_Printing_Option_Meaning      VARCHAR2,
                     X_Grouping_Rule_Id                 NUMBER,
                     X_Cons_Inv_Flag                    VARCHAR2,
                     X_Cons_Inv_Type                    VARCHAR2,
                     X_Request_Id                       NUMBER,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Jgzz_attribute_Category          VARCHAR2,
                     X_Jgzz_attribute1                  VARCHAR2,
                     X_Jgzz_attribute2                  VARCHAR2,
                     X_Jgzz_attribute3                  VARCHAR2,
                     X_Jgzz_attribute4                  VARCHAR2,
                     X_Jgzz_attribute5                  VARCHAR2,
                     X_Jgzz_attribute6                  VARCHAR2,
                     X_Jgzz_attribute7                  VARCHAR2,
                     X_Jgzz_attribute8                  VARCHAR2,
                     X_Jgzz_attribute9                  VARCHAR2,
                     X_Jgzz_attribute10                 VARCHAR2,
                     X_Jgzz_attribute11                 VARCHAR2,
                     X_Jgzz_attribute12                 VARCHAR2,
                     X_Jgzz_attribute13                 VARCHAR2,
                     X_Jgzz_attribute14                 VARCHAR2,
                     X_Jgzz_attribute15                 VARCHAR2,
                     X_global_attribute_category        VARCHAR2,
                     X_global_attribute1                VARCHAR2,
                     X_global_attribute2                VARCHAR2,
                     X_global_attribute3                VARCHAR2,
                     X_global_attribute4                VARCHAR2,
                     X_global_attribute5                VARCHAR2,
                     X_global_attribute6                VARCHAR2,
                     X_global_attribute7                VARCHAR2,
                     X_global_attribute8                VARCHAR2,
                     X_global_attribute9                VARCHAR2,
                     X_global_attribute10               VARCHAR2,
                     X_global_attribute11               VARCHAR2,
                     X_global_attribute12               VARCHAR2,
                     X_global_attribute13               VARCHAR2,
                     X_global_attribute14               VARCHAR2,
                     X_global_attribute15               VARCHAR2,
                     X_global_attribute16               VARCHAR2,
                     X_global_attribute17               VARCHAR2,
                     X_global_attribute18               VARCHAR2,
                     X_global_attribute19               VARCHAR2,
                     X_global_attribute20               VARCHAR2,
                     X_lockbox_matching_option          VARCHAR2,
                     X_autocash_hierarchy_id_adr        NUMBER,
                     X_review_cycle                     VARCHAR2,
                     X_credit_analyst_id                NUMBER,
                     X_credit_classification            VARCHAR2,   /*Bug 3619062*/
                     X_Cons_Bill_Level                  VARCHAR2,
                     X_LATE_CHARGE_CALCULATION_TRX      VARCHAR2,
                     X_CREDIT_ITEMS_FLAG                VARCHAR2,
                     X_DISPUTED_TRANSACTIONS_FLAG       VARCHAR2,
                     X_LATE_CHARGE_TYPE                 VARCHAR2,
                     X_LATE_CHARGE_TERM_ID              NUMBER,
                     X_INTEREST_CALCULATION_PERIOD      VARCHAR2,
                     X_HOLD_CHARGED_INVOICES_FLAG       VARCHAR2,
                     X_MESSAGE_TEXT_ID                  NUMBER,
                     X_MULTIPLE_INTEREST_RATES_FLAG     VARCHAR2,
                     X_CHARGE_BEGIN_DATE                DATE,
		     X_AUTOMATCH_SET_ID			NUMBER)
IS
    CURSOR C IS
        SELECT *
        FROM   HZ_CUST_PROFILE_CLASSES
        WHERE  rowid = X_Row_Id
        FOR UPDATE of Profile_Class_Id NOWAIT;
    Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    IF (       (Recinfo.profile_class_id =  X_Customer_Profile_Class_Id)
           AND (Recinfo.name             =  X_Profile_Class_Name)
           AND (   (Recinfo.description  =  X_Profile_Class_Description)
                OR (    (Recinfo.description         IS NULL)
                    AND (X_Profile_Class_Description IS NULL)) )
           AND (Recinfo.status                    =  X_Status)
           AND (Recinfo.collector_id              =  X_Collector_Id)
           AND (Recinfo.credit_checking           =  X_Credit_Checking)
           AND (Recinfo.tolerance                 =  X_Tolerance)
           AND (Recinfo.interest_charges          =  X_Interest_Charges)
           AND (   (Recinfo.charge_on_finance_charge_flag =  X_Charge_On_Finance_Charge_Flg)
                OR (    (Recinfo.charge_on_finance_charge_flag IS NULL)
                    AND (X_Charge_On_Finance_Charge_Flg IS NULL)))
           AND (   (Recinfo.interest_period_days =  X_Interest_Period_Days)
                OR (    (Recinfo.interest_period_days IS NULL)
                    AND (X_Interest_Period_Days IS NULL)))
           AND (Recinfo.discount_terms =  X_Discount_Terms)
           AND (   (Recinfo.discount_grace_days =  X_Discount_Grace_Days)
                OR (    (Recinfo.discount_grace_days IS NULL)
                    AND (X_Discount_Grace_Days IS NULL)))
           AND (Recinfo.statements =  X_Statements)
           AND (   (Recinfo.statement_cycle_id =  X_Statement_Cycle_Id)
                OR (    (Recinfo.statement_cycle_id IS NULL)
                    AND (X_Statement_Cycle_Id IS NULL)))
           AND (Recinfo.credit_balance_statements =  X_Credit_Balance_Statements)
           AND (   (Recinfo.standard_terms =  X_Standard_Terms)
                OR (    (Recinfo.standard_terms IS NULL)
                    AND (X_Standard_Terms IS NULL)))
           AND (   (Recinfo.override_terms =  X_Override_Terms)
                OR (    (Recinfo.override_terms IS NULL)
                    AND (X_Override_Terms IS NULL)))
           AND (   (Recinfo.payment_grace_days =  X_Payment_Grace_Days)
                OR (    (Recinfo.payment_grace_days IS NULL)
                    AND (X_Payment_Grace_Days IS NULL)))
           AND (Recinfo.dunning_letters =  X_Dunning_Letters)
           AND (   (Recinfo.dunning_letter_set_id =  X_Dunning_Letter_Set_Id)
                OR (    (Recinfo.dunning_letter_set_id IS NULL)
                    AND (X_Dunning_Letter_Set_Id IS NULL)))
           AND (   (Recinfo.autocash_hierarchy_id =  X_Autocash_Hierarchy_Id)
                OR (    (Recinfo.autocash_hierarchy_id IS NULL)
                    AND (X_Autocash_Hierarchy_Id IS NULL)))
           AND (   (Recinfo.copy_method =  X_Copy_Method)
                OR (    (Recinfo.copy_method IS NULL)
                    AND (X_Copy_Method IS NULL)))
           AND (Recinfo.auto_rec_incl_disputed_flag =  X_Auto_Rec_Incl_Disputed_Flag)
           AND (   (Recinfo.tax_printing_option =  X_Tax_Printing_Option)
                OR (    (Recinfo.tax_printing_option IS NULL)
                    AND (X_Tax_Printing_Option IS NULL)))
           AND (   (Recinfo.grouping_rule_id =  X_Grouping_Rule_Id)
                OR (    (Recinfo.grouping_rule_id IS NULL)
                    AND (X_Grouping_Rule_Id IS NULL)))
           AND nvl( Recinfo.cons_inv_flag , 'N' ) = X_Cons_Inv_Flag
           AND (   (Recinfo.cons_inv_type =  X_Cons_Inv_Type)
                OR (    (Recinfo.cons_inv_type IS NULL)
                    AND (X_Cons_Inv_Type IS NULL)))
           AND (   (Recinfo.request_id =  X_Request_Id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (X_Request_Id IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.jgzz_attribute_category =  X_Jgzz_attribute_Category)
                OR (    (Recinfo.jgzz_attribute_category IS NULL)
                    AND (X_Jgzz_attribute_Category IS NULL)))
           AND (   (Recinfo.jgzz_attribute1 =  X_Jgzz_attribute1)
                OR (    (Recinfo.jgzz_attribute1 IS NULL)
                    AND (X_Jgzz_attribute1 IS NULL)))
           AND (   (Recinfo.jgzz_attribute2 =  X_Jgzz_attribute2)
                OR (    (Recinfo.jgzz_attribute2 IS NULL)
                    AND (X_Jgzz_attribute2 IS NULL)))
           AND (   (Recinfo.jgzz_attribute3 =  X_Jgzz_attribute3)
                OR (    (Recinfo.jgzz_attribute3 IS NULL)
                    AND (X_Jgzz_attribute3 IS NULL)))
           AND (   (Recinfo.jgzz_attribute4 =  X_Jgzz_attribute4)
                OR (    (Recinfo.jgzz_attribute4 IS NULL)
                    AND (X_Jgzz_attribute4 IS NULL)))
           AND (   (Recinfo.jgzz_attribute5 =  X_Jgzz_attribute5)
                OR (    (Recinfo.jgzz_attribute5 IS NULL)
                    AND (X_Jgzz_attribute5 IS NULL)))
           AND (   (Recinfo.jgzz_attribute6 =  X_Jgzz_attribute6)
                OR (    (Recinfo.jgzz_attribute6 IS NULL)
                    AND (X_Jgzz_attribute6 IS NULL)))
           AND (   (Recinfo.jgzz_attribute7 =  X_Jgzz_attribute7)
                OR (    (Recinfo.jgzz_attribute7 IS NULL)
                    AND (X_Jgzz_attribute7 IS NULL)))
           AND (   (Recinfo.jgzz_attribute8 =  X_Jgzz_attribute8)
                OR (    (Recinfo.jgzz_attribute8 IS NULL)
                    AND (X_Jgzz_attribute8 IS NULL)))
           AND (   (Recinfo.jgzz_attribute9 =  X_Jgzz_attribute9)
                OR (    (Recinfo.jgzz_attribute9 IS NULL)
                    AND (X_Jgzz_attribute9 IS NULL)))
           AND (   (Recinfo.jgzz_attribute10 =  X_Jgzz_attribute10)
                OR (    (Recinfo.jgzz_attribute10 IS NULL)
                    AND (X_Jgzz_attribute10 IS NULL)))
           AND (   (Recinfo.jgzz_attribute11 =  X_Jgzz_attribute11)
                OR (    (Recinfo.jgzz_attribute11 IS NULL)
                    AND (X_Jgzz_attribute11 IS NULL)))
           AND (   (Recinfo.jgzz_attribute12 =  X_Jgzz_attribute12)
                OR (    (Recinfo.jgzz_attribute12 IS NULL)
                    AND (X_Jgzz_attribute12 IS NULL)))
           AND (   (Recinfo.jgzz_attribute13 =  X_Jgzz_attribute13)
                OR (    (Recinfo.jgzz_attribute13 IS NULL)
                    AND (X_Jgzz_attribute13 IS NULL)))
           AND (   (Recinfo.jgzz_attribute14 =  X_Jgzz_attribute14)
                OR (    (Recinfo.jgzz_attribute14 IS NULL)
                    AND (X_Jgzz_attribute14 IS NULL)))
           AND (   (Recinfo.jgzz_attribute15 =  X_Jgzz_attribute15)
                OR (    (Recinfo.jgzz_attribute15 IS NULL)
                    AND (X_Jgzz_attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute_category =  X_global_attribute_category)
                OR (    (Recinfo.global_attribute_category IS NULL)
                    AND (X_global_attribute_category IS NULL)))
           AND (   (Recinfo.global_attribute1 =  X_global_attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (X_global_Attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2 =  X_global_attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (X_global_attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3 =  X_global_attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (X_global_attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4 =  X_global_attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (X_global_attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5 =  X_global_attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (X_global_attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6 =  X_global_attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (X_global_attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7 =  X_global_attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (X_global_attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8 =  X_global_attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (X_global_attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9 =  X_global_attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (X_global_attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10 =  X_global_attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (X_global_attribute10 IS NULL))))
           AND (   (Recinfo.global_attribute11 =  X_global_attribute11)
                OR (    (Recinfo.global_attribute11 IS NULL)
                    AND (X_global_attribute11 IS NULL)))
           AND (   (Recinfo.global_attribute12 =  X_global_attribute12)
                OR (    (Recinfo.global_attribute12 IS NULL)
                    AND (X_global_attribute12 IS NULL)))
           AND (   (Recinfo.global_attribute13 =  X_global_attribute13)
                OR (    (Recinfo.global_attribute13 IS NULL)
                    AND (X_global_attribute13 IS NULL))
           AND (   (Recinfo.global_attribute14 =  X_global_attribute14)
                OR (    (Recinfo.global_attribute14 IS NULL)
                    AND (X_global_attribute14 IS NULL)))
           AND (   (Recinfo.global_attribute15 =  X_global_attribute15)
                OR (    (Recinfo.global_attribute15 IS NULL)
                    AND (X_global_attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute16 =  X_global_attribute16)
                OR (    (Recinfo.global_attribute16 IS NULL)
                    AND (X_global_attribute16 IS NULL)))
           AND (   (Recinfo.global_attribute17 =  X_global_attribute17)
                OR (    (Recinfo.global_attribute17 IS NULL)
                    AND (X_global_attribute17 IS NULL)))
           AND (   (Recinfo.global_attribute18 =  X_global_attribute18)
                OR (    (Recinfo.global_attribute18 IS NULL)
                    AND (X_global_attribute18 IS NULL)))
           AND (   (Recinfo.global_attribute19 =  X_global_attribute19)
                OR (    (Recinfo.global_attribute19 IS NULL)
                    AND (X_global_attribute19 IS NULL)))
           AND (   (Recinfo.global_attribute20 =  X_global_attribute20)
                OR (    (Recinfo.global_attribute20 IS NULL)
                    AND (X_global_attribute20 IS NULL)))
           AND (   (Recinfo.lockbox_matching_option = X_lockbox_matching_option)
                OR (    (Recinfo.lockbox_matching_option IS NULL)
                    AND (X_lockbox_matching_option IS NULL)))
           AND (   (Recinfo.autocash_hierarchy_id_for_adr =  X_autocash_hierarchy_id_adr)
                OR (    (Recinfo.autocash_hierarchy_id_for_adr IS NULL)
                    AND (X_autocash_hierarchy_id_adr IS NULL)))
           AND (   (Recinfo.review_cycle  = X_review_cycle)
                OR (    (Recinfo.review_cycle IS NULL)
                    AND (X_review_cycle IS NULL)))
           AND (   (Recinfo.credit_analyst_id = X_credit_analyst_id)
                OR (    (Recinfo.credit_analyst_id IS NULL)
                    AND (X_credit_analyst_id IS NULL)))
           AND (   (Recinfo.credit_classification = X_credit_classification)
                OR (    (Recinfo.credit_classification IS NULL)
                    AND (X_credit_classification IS NULL)))
           AND (   (Recinfo.Cons_Bill_Level = X_Cons_Bill_Level)
                OR (    (Recinfo.Cons_Bill_Level IS NULL)
                    AND (X_Cons_Bill_Level IS NULL)))
           AND (   (Recinfo.LATE_CHARGE_CALCULATION_TRX = X_LATE_CHARGE_CALCULATION_TRX)
                OR (    (Recinfo.LATE_CHARGE_CALCULATION_TRX IS NULL)
                    AND (X_LATE_CHARGE_CALCULATION_TRX IS NULL)))
           AND (   (Recinfo.CREDIT_ITEMS_FLAG = X_CREDIT_ITEMS_FLAG)
                OR (    (Recinfo.CREDIT_ITEMS_FLAG IS NULL)
                    AND (X_CREDIT_ITEMS_FLAG IS NULL)))
           AND (   (Recinfo.DISPUTED_TRANSACTIONS_FLAG = X_DISPUTED_TRANSACTIONS_FLAG)
                OR (    (Recinfo.DISPUTED_TRANSACTIONS_FLAG IS NULL)
                    AND (X_DISPUTED_TRANSACTIONS_FLAG IS NULL)))
           AND (   (Recinfo.LATE_CHARGE_TYPE = X_LATE_CHARGE_TYPE)
                OR (    (Recinfo.LATE_CHARGE_TYPE IS NULL)
                    AND (X_LATE_CHARGE_TYPE IS NULL)))
           AND (   (Recinfo.LATE_CHARGE_TERM_ID = X_LATE_CHARGE_TERM_ID)
                OR (    (Recinfo.LATE_CHARGE_TERM_ID IS NULL)
                    AND (X_LATE_CHARGE_TERM_ID IS NULL)))
           AND (   (Recinfo.INTEREST_CALCULATION_PERIOD = X_INTEREST_CALCULATION_PERIOD)
                OR (    (Recinfo.INTEREST_CALCULATION_PERIOD IS NULL)
                    AND (X_INTEREST_CALCULATION_PERIOD IS NULL)))
           AND (   (Recinfo.HOLD_CHARGED_INVOICES_FLAG = X_HOLD_CHARGED_INVOICES_FLAG)
                OR (    (Recinfo.HOLD_CHARGED_INVOICES_FLAG IS NULL)
                    AND (X_HOLD_CHARGED_INVOICES_FLAG IS NULL)))
           AND (   (Recinfo.MESSAGE_TEXT_ID = X_MESSAGE_TEXT_ID)
                OR (    (Recinfo.MESSAGE_TEXT_ID IS NULL)
                    AND (X_MESSAGE_TEXT_ID IS NULL)))
           AND (   (Recinfo.MULTIPLE_INTEREST_RATES_FLAG = X_MULTIPLE_INTEREST_RATES_FLAG)
                OR (    (Recinfo.MULTIPLE_INTEREST_RATES_FLAG IS NULL)
                    AND (X_MULTIPLE_INTEREST_RATES_FLAG IS NULL)))
           AND (   (Recinfo.CHARGE_BEGIN_DATE = X_CHARGE_BEGIN_DATE)
                OR (    (Recinfo.CHARGE_BEGIN_DATE IS NULL)
                    AND (X_CHARGE_BEGIN_DATE IS NULL)))
	   AND (   (Recinfo.AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID)
                OR (    (Recinfo.AUTOMATCH_SET_ID IS NULL)
                    AND (X_AUTOMATCH_SET_ID IS NULL)))
      )
    THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
END Lock_Row;


PROCEDURE Update_Row  (X_Row_Id                         IN OUT NOCOPY VARCHAR2,
                       X_Customer_Profile_Class_Id      IN OUT NOCOPY NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Profile_Class_Name             VARCHAR2,
                       X_Profile_Class_Description      VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Credit_Checking                VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Interest_Charges               VARCHAR2,
                       X_Charge_On_Finance_Charge_Flg  VARCHAR2,
                       X_Interest_Period_Days           NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Discount_Grace_Days            NUMBER,
                       X_Statements                     VARCHAR2,
                       X_Statement_Cycle_Id             NUMBER,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Standard_Terms                 NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Dunning_Letters                VARCHAR2,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Copy_Method                    VARCHAR2,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Tax_Printing_Option_Meaning    VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Jgzz_attribute_Category        VARCHAR2,
                       X_Jgzz_attribute1                VARCHAR2,
                       X_Jgzz_attribute2                VARCHAR2,
                       X_Jgzz_attribute3                VARCHAR2,
                       X_Jgzz_attribute4                VARCHAR2,
                       X_Jgzz_attribute5                VARCHAR2,
                       X_Jgzz_attribute6                VARCHAR2,
                       X_Jgzz_attribute7                VARCHAR2,
                       X_Jgzz_attribute8                VARCHAR2,
                       X_Jgzz_attribute9                VARCHAR2,
                       X_Jgzz_attribute10               VARCHAR2,
                       X_Jgzz_attribute11               VARCHAR2,
                       X_Jgzz_attribute12               VARCHAR2,
                       X_Jgzz_attribute13               VARCHAR2,
                       X_Jgzz_attribute14               VARCHAR2,
                       X_Jgzz_attribute15               VARCHAR2,
                       X_global_attribute_category      VARCHAR2,
                       X_global_attribute1              VARCHAR2,
                       X_global_attribute2              VARCHAR2,
                       X_global_attribute3              VARCHAR2,
                       X_global_attribute4              VARCHAR2,
                       X_global_attribute5              VARCHAR2,
                       X_global_attribute6              VARCHAR2,
                       X_global_attribute7              VARCHAR2,
                       X_global_attribute8              VARCHAR2,
                       X_global_attribute9              VARCHAR2,
                       X_global_attribute10             VARCHAR2,
                       X_global_attribute11             VARCHAR2,
                       X_global_attribute12             VARCHAR2,
                       X_global_attribute13             VARCHAR2,
                       X_global_attribute14             VARCHAR2,
                       X_global_attribute15             VARCHAR2,
                       X_global_attribute16             VARCHAR2,
                       X_global_attribute17             VARCHAR2,
                       X_global_attribute18             VARCHAR2,
                       X_global_attribute19             VARCHAR2,
                       X_global_attribute20             VARCHAR2,
                       X_lockbox_matching_option        VARCHAR2,
                       X_autocash_hierarchy_id_adr      NUMBER ,
                       X_review_cycle                   VARCHAR2 DEFAULT NULL,
                       X_credit_analyst_id              NUMBER   DEFAULT NULL,
                       X_Cons_Bill_Level                VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_CALCULATION_TRX    VARCHAR2 DEFAULT NULL,
                       X_CREDIT_ITEMS_FLAG              VARCHAR2 DEFAULT NULL,
                       X_DISPUTED_TRANSACTIONS_FLAG     VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TYPE               VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TERM_ID            NUMBER   DEFAULT NULL,
                       X_INTEREST_CALCULATION_PERIOD    VARCHAR2 DEFAULT NULL,
                       X_HOLD_CHARGED_INVOICES_FLAG     VARCHAR2 DEFAULT NULL,
                       X_MESSAGE_TEXT_ID                NUMBER   DEFAULT NULL,
                       X_MULTIPLE_INTEREST_RATES_FLAG   VARCHAR2 DEFAULT NULL,
                       X_CHARGE_BEGIN_DATE              DATE     DEFAULT NULL,
		       X_AUTOMATCH_SET_ID		NUMBER	 DEFAULT NULL)
IS
BEGIN

/*Bug 3619062 Call overloaded procedure with credit_classification set as NULL*/
UPDATE_ROW  (          X_ROW_ID                         =>  X_ROW_ID                         ,
                       X_CUSTOMER_PROFILE_CLASS_ID      =>  X_CUSTOMER_PROFILE_CLASS_ID      ,
                       X_LAST_UPDATED_BY                =>  X_LAST_UPDATED_BY                ,
                       X_LAST_UPDATE_DATE               =>  X_LAST_UPDATE_DATE               ,
                       X_LAST_UPDATE_LOGIN              =>  X_LAST_UPDATE_LOGIN              ,
                       X_PROFILE_CLASS_NAME             =>  X_PROFILE_CLASS_NAME             ,
                       X_PROFILE_CLASS_DESCRIPTION      =>  X_PROFILE_CLASS_DESCRIPTION      ,
                       X_STATUS                         =>  X_STATUS                         ,
                       X_COLLECTOR_ID                   =>  X_COLLECTOR_ID                   ,
                       X_CREDIT_CHECKING                =>  X_CREDIT_CHECKING                ,
                       X_TOLERANCE                      =>  X_TOLERANCE                      ,
                       X_INTEREST_CHARGES               =>  X_INTEREST_CHARGES               ,
                       X_CHARGE_ON_FINANCE_CHARGE_FLG   =>  X_CHARGE_ON_FINANCE_CHARGE_FLG   ,
                       X_INTEREST_PERIOD_DAYS           =>  X_INTEREST_PERIOD_DAYS           ,
                       X_DISCOUNT_TERMS                 =>  X_DISCOUNT_TERMS                 ,
                       X_DISCOUNT_GRACE_DAYS            =>  X_DISCOUNT_GRACE_DAYS            ,
                       X_STATEMENTS                     =>  X_STATEMENTS                     ,
                       X_STATEMENT_CYCLE_ID             =>  X_STATEMENT_CYCLE_ID             ,
                       X_CREDIT_BALANCE_STATEMENTS      =>  X_CREDIT_BALANCE_STATEMENTS      ,
                       X_STANDARD_TERMS                 =>  X_STANDARD_TERMS                 ,
                       X_OVERRIDE_TERMS                 =>  X_OVERRIDE_TERMS                 ,
                       X_PAYMENT_GRACE_DAYS             =>  X_PAYMENT_GRACE_DAYS             ,
                       X_DUNNING_LETTERS                =>  X_DUNNING_LETTERS                ,
                       X_DUNNING_LETTER_SET_ID          =>  X_DUNNING_LETTER_SET_ID          ,
                       X_AUTOCASH_HIERARCHY_ID          =>  X_AUTOCASH_HIERARCHY_ID          ,
                       X_COPY_METHOD                    =>  X_COPY_METHOD                    ,
                       X_AUTO_REC_INCL_DISPUTED_FLAG    =>  X_AUTO_REC_INCL_DISPUTED_FLAG    ,
                       X_TAX_PRINTING_OPTION            =>  X_TAX_PRINTING_OPTION            ,
                       X_TAX_PRINTING_OPTION_MEANING    =>  X_TAX_PRINTING_OPTION_MEANING    ,
                       X_GROUPING_RULE_ID               =>  X_GROUPING_RULE_ID               ,
                       X_CONS_INV_FLAG                  =>  X_CONS_INV_FLAG                  ,
                       X_CONS_INV_TYPE                  =>  X_CONS_INV_TYPE                  ,
                       X_REQUEST_ID                     =>  X_REQUEST_ID                     ,
                       X_ATTRIBUTE_CATEGORY             =>  X_ATTRIBUTE_CATEGORY             ,
                       X_ATTRIBUTE1                     =>  X_ATTRIBUTE1                     ,
                       X_ATTRIBUTE2                     =>  X_ATTRIBUTE2                     ,
                       X_ATTRIBUTE3                     =>  X_ATTRIBUTE3                     ,
                       X_ATTRIBUTE4                     =>  X_ATTRIBUTE4                     ,
                       X_ATTRIBUTE5                     =>  X_ATTRIBUTE5                     ,
                       X_ATTRIBUTE6                     =>  X_ATTRIBUTE6                     ,
                       X_ATTRIBUTE7                     =>  X_ATTRIBUTE7                     ,
                       X_ATTRIBUTE8                     =>  X_ATTRIBUTE8                     ,
                       X_ATTRIBUTE9                     =>  X_ATTRIBUTE9                     ,
                       X_ATTRIBUTE10                    =>  X_ATTRIBUTE10                    ,
                       X_ATTRIBUTE11                    =>  X_ATTRIBUTE11                    ,
                       X_ATTRIBUTE12                    =>  X_ATTRIBUTE12                    ,
                       X_ATTRIBUTE13                    =>  X_ATTRIBUTE13                    ,
                       X_ATTRIBUTE14                    =>  X_ATTRIBUTE14                    ,
                       X_ATTRIBUTE15                    =>  X_ATTRIBUTE15                    ,
                       X_JGZZ_ATTRIBUTE_CATEGORY        =>  X_JGZZ_ATTRIBUTE_CATEGORY        ,
                       X_JGZZ_ATTRIBUTE1                =>  X_JGZZ_ATTRIBUTE1                ,
                       X_JGZZ_ATTRIBUTE2                =>  X_JGZZ_ATTRIBUTE2                ,
                       X_JGZZ_ATTRIBUTE3                =>  X_JGZZ_ATTRIBUTE3                ,
                       X_JGZZ_ATTRIBUTE4                =>  X_JGZZ_ATTRIBUTE4                ,
                       X_JGZZ_ATTRIBUTE5                =>  X_JGZZ_ATTRIBUTE5                ,
                       X_JGZZ_ATTRIBUTE6                =>  X_JGZZ_ATTRIBUTE6                ,
                       X_JGZZ_ATTRIBUTE7                =>  X_JGZZ_ATTRIBUTE7                ,
                       X_JGZZ_ATTRIBUTE8                =>  X_JGZZ_ATTRIBUTE8                ,
                       X_JGZZ_ATTRIBUTE9                =>  X_JGZZ_ATTRIBUTE9                ,
                       X_JGZZ_ATTRIBUTE10               =>  X_JGZZ_ATTRIBUTE10               ,
                       X_JGZZ_ATTRIBUTE11               =>  X_JGZZ_ATTRIBUTE11               ,
                       X_JGZZ_ATTRIBUTE12               =>  X_JGZZ_ATTRIBUTE12               ,
                       X_JGZZ_ATTRIBUTE13               =>  X_JGZZ_ATTRIBUTE13               ,
                       X_JGZZ_ATTRIBUTE14               =>  X_JGZZ_ATTRIBUTE14               ,
                       X_JGZZ_ATTRIBUTE15               =>  X_JGZZ_ATTRIBUTE15               ,
                       X_GLOBAL_ATTRIBUTE_CATEGORY      =>  X_GLOBAL_ATTRIBUTE_CATEGORY      ,
                       X_GLOBAL_ATTRIBUTE1              =>  X_GLOBAL_ATTRIBUTE1              ,
                       X_GLOBAL_ATTRIBUTE2              =>  X_GLOBAL_ATTRIBUTE2              ,
                       X_GLOBAL_ATTRIBUTE3              =>  X_GLOBAL_ATTRIBUTE3              ,
                       X_GLOBAL_ATTRIBUTE4              =>  X_GLOBAL_ATTRIBUTE4              ,
                       X_GLOBAL_ATTRIBUTE5              =>  X_GLOBAL_ATTRIBUTE5              ,
                       X_GLOBAL_ATTRIBUTE6              =>  X_GLOBAL_ATTRIBUTE6              ,
                       X_GLOBAL_ATTRIBUTE7              =>  X_GLOBAL_ATTRIBUTE7              ,
                       X_GLOBAL_ATTRIBUTE8              =>  X_GLOBAL_ATTRIBUTE8              ,
                       X_GLOBAL_ATTRIBUTE9              =>  X_GLOBAL_ATTRIBUTE9              ,
                       X_GLOBAL_ATTRIBUTE10             =>  X_GLOBAL_ATTRIBUTE10             ,
                       X_GLOBAL_ATTRIBUTE11             =>  X_GLOBAL_ATTRIBUTE11             ,
                       X_GLOBAL_ATTRIBUTE12             =>  X_GLOBAL_ATTRIBUTE12             ,
                       X_GLOBAL_ATTRIBUTE13             =>  X_GLOBAL_ATTRIBUTE13             ,
                       X_GLOBAL_ATTRIBUTE14             =>  X_GLOBAL_ATTRIBUTE14             ,
                       X_GLOBAL_ATTRIBUTE15             =>  X_GLOBAL_ATTRIBUTE15             ,
                       X_GLOBAL_ATTRIBUTE16             =>  X_GLOBAL_ATTRIBUTE16             ,
                       X_GLOBAL_ATTRIBUTE17             =>  X_GLOBAL_ATTRIBUTE17             ,
                       X_GLOBAL_ATTRIBUTE18             =>  X_GLOBAL_ATTRIBUTE18             ,
                       X_GLOBAL_ATTRIBUTE19             =>  X_GLOBAL_ATTRIBUTE19             ,
                       X_GLOBAL_ATTRIBUTE20             =>  X_GLOBAL_ATTRIBUTE20             ,
                       X_LOCKBOX_MATCHING_OPTION        =>  X_LOCKBOX_MATCHING_OPTION        ,
                       X_AUTOCASH_HIERARCHY_ID_ADR      =>  X_AUTOCASH_HIERARCHY_ID_ADR      ,
                       X_REVIEW_CYCLE                   =>  X_REVIEW_CYCLE                   ,
                       X_CREDIT_ANALYST_ID              =>  X_CREDIT_ANALYST_ID              ,
                       X_CREDIT_CLASSIFICATION          =>  NULL                             ,
                       X_Cons_Bill_Level                =>  X_Cons_Bill_Level ,
                       X_LATE_CHARGE_CALCULATION_TRX    =>  X_LATE_CHARGE_CALCULATION_TRX,
                       X_CREDIT_ITEMS_FLAG              =>  X_CREDIT_ITEMS_FLAG,
                       X_DISPUTED_TRANSACTIONS_FLAG     =>  X_DISPUTED_TRANSACTIONS_FLAG,
                       X_LATE_CHARGE_TYPE               =>  X_LATE_CHARGE_TYPE,
                       X_LATE_CHARGE_TERM_ID            =>  X_LATE_CHARGE_TERM_ID,
                       X_INTEREST_CALCULATION_PERIOD    =>  X_INTEREST_CALCULATION_PERIOD,
                       X_HOLD_CHARGED_INVOICES_FLAG     =>  X_HOLD_CHARGED_INVOICES_FLAG,
                       X_MESSAGE_TEXT_ID                =>  X_MESSAGE_TEXT_ID,
                       X_MULTIPLE_INTEREST_RATES_FLAG   =>  X_MULTIPLE_INTEREST_RATES_FLAG,
                       X_CHARGE_BEGIN_DATE              =>  X_CHARGE_BEGIN_DATE,
		       X_AUTOMATCH_SET_ID		=>  X_AUTOMATCH_SET_ID);
END Update_Row;

PROCEDURE Update_Row  (X_Row_Id                         IN OUT NOCOPY VARCHAR2,
                       X_Customer_Profile_Class_Id      IN OUT NOCOPY NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Profile_Class_Name             VARCHAR2,
                       X_Profile_Class_Description      VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Credit_Checking                VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Interest_Charges               VARCHAR2,
                       X_Charge_On_Finance_Charge_Flg   VARCHAR2,
                       X_Interest_Period_Days           NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Discount_Grace_Days            NUMBER,
                       X_Statements                     VARCHAR2,
                       X_Statement_Cycle_Id             NUMBER,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Standard_Terms                 NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Dunning_Letters                VARCHAR2,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Copy_Method                    VARCHAR2,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Tax_Printing_Option_Meaning    VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Request_Id                     NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Jgzz_attribute_Category        VARCHAR2,
                       X_Jgzz_attribute1                VARCHAR2,
                       X_Jgzz_attribute2                VARCHAR2,
                       X_Jgzz_attribute3                VARCHAR2,
                       X_Jgzz_attribute4                VARCHAR2,
                       X_Jgzz_attribute5                VARCHAR2,
                       X_Jgzz_attribute6                VARCHAR2,
                       X_Jgzz_attribute7                VARCHAR2,
                       X_Jgzz_attribute8                VARCHAR2,
                       X_Jgzz_attribute9                VARCHAR2,
                       X_Jgzz_attribute10               VARCHAR2,
                       X_Jgzz_attribute11               VARCHAR2,
                       X_Jgzz_attribute12               VARCHAR2,
                       X_Jgzz_attribute13               VARCHAR2,
                       X_Jgzz_attribute14               VARCHAR2,
                       X_Jgzz_attribute15               VARCHAR2,
                       X_global_attribute_category      VARCHAR2,
                       X_global_attribute1              VARCHAR2,
                       X_global_attribute2              VARCHAR2,
                       X_global_attribute3              VARCHAR2,
                       X_global_attribute4              VARCHAR2,
                       X_global_attribute5              VARCHAR2,
                       X_global_attribute6              VARCHAR2,
                       X_global_attribute7              VARCHAR2,
                       X_global_attribute8              VARCHAR2,
                       X_global_attribute9              VARCHAR2,
                       X_global_attribute10             VARCHAR2,
                       X_global_attribute11             VARCHAR2,
                       X_global_attribute12             VARCHAR2,
                       X_global_attribute13             VARCHAR2,
                       X_global_attribute14             VARCHAR2,
                       X_global_attribute15             VARCHAR2,
                       X_global_attribute16             VARCHAR2,
                       X_global_attribute17             VARCHAR2,
                       X_global_attribute18             VARCHAR2,
                       X_global_attribute19             VARCHAR2,
                       X_global_attribute20             VARCHAR2,
                       X_lockbox_matching_option        VARCHAR2,
                       X_autocash_hierarchy_id_adr      NUMBER ,
                       X_review_cycle                   VARCHAR2 DEFAULT NULL,
                       X_credit_analyst_id              NUMBER   DEFAULT NULL,
                       X_credit_classification          VARCHAR2,   /*Bug 3619062*/
                       X_Cons_Bill_Level                VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_CALCULATION_TRX    VARCHAR2 DEFAULT NULL,
                       X_CREDIT_ITEMS_FLAG              VARCHAR2 DEFAULT NULL,
                       X_DISPUTED_TRANSACTIONS_FLAG     VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TYPE               VARCHAR2 DEFAULT NULL,
                       X_LATE_CHARGE_TERM_ID            NUMBER   DEFAULT NULL,
                       X_INTEREST_CALCULATION_PERIOD    VARCHAR2 DEFAULT NULL,
                       X_HOLD_CHARGED_INVOICES_FLAG     VARCHAR2 DEFAULT NULL,
                       X_MESSAGE_TEXT_ID                NUMBER   DEFAULT NULL,
                       X_MULTIPLE_INTEREST_RATES_FLAG   VARCHAR2 DEFAULT NULL,
                       X_CHARGE_BEGIN_DATE              DATE     DEFAULT NULL,
		       X_AUTOMATCH_SET_ID		NUMBER	 DEFAULT NULL)
IS
BEGIN
    -- Calling check_unique Procedure To Varify The Uniqueness Of The Customer Profile
    -- Class Id
    check_unique (  c_profile_class_name => x_customer_profile_class_id,
                     c_rowid              => x_row_id  );

    UPDATE HZ_CUST_PROFILE_CLASSES
    SET
          profile_class_id                =  X_Customer_Profile_Class_Id,
          last_updated_by                 =  X_Last_Updated_By,
          last_update_date                =  X_Last_Update_Date,
          last_update_login               =  X_Last_Update_Login,
          name                            =  X_Profile_Class_Name,
          description                     =  X_Profile_Class_Description,
          status                          =  X_Status,
          collector_id                    =  X_Collector_Id,
          credit_checking                 =  X_Credit_Checking,
          tolerance                       =  X_Tolerance,
          interest_charges                =  X_Interest_Charges,
          charge_on_finance_charge_flag   =  X_Charge_On_Finance_Charge_Flg,
          interest_period_days            =  X_Interest_Period_Days,
          discount_terms                  =  X_Discount_Terms,
          discount_grace_days             =  X_Discount_Grace_Days,
          statements                      =  X_Statements,
          statement_cycle_id              =  X_Statement_Cycle_Id,
          credit_balance_statements       =  X_Credit_Balance_Statements,
          standard_terms                  =  X_Standard_Terms,
          override_terms                  =  X_Override_Terms,
          payment_grace_days              =  X_Payment_Grace_Days,
          dunning_letters                 =  X_Dunning_Letters,
          dunning_letter_set_id           =  X_Dunning_Letter_Set_Id,
          autocash_hierarchy_id           =  X_Autocash_Hierarchy_Id,
          copy_method                     =  X_Copy_Method,
          auto_rec_incl_disputed_flag     =  X_Auto_Rec_Incl_Disputed_Flag,
          tax_printing_option             =  X_Tax_Printing_Option,
          grouping_rule_id                =  X_Grouping_Rule_Id,
          cons_inv_flag                   =  X_Cons_Inv_Flag,
          cons_inv_type                   =  X_Cons_Inv_Type,
          request_id                      =  X_Request_Id,
          attribute_category              =  X_Attribute_Category,
          attribute1                      =  X_Attribute1,
          attribute2                      =  X_Attribute2,
          attribute3                      =  X_Attribute3,
          attribute4                      =  X_Attribute4,
          attribute5                      =  X_Attribute5,
          attribute6                      =  X_Attribute6,
          attribute7                      =  X_Attribute7,
          attribute8                      =  X_Attribute8,
          attribute9                      =  X_Attribute9,
          attribute10                     =  X_Attribute10,
          attribute11                     =  X_Attribute11,
          attribute12                     =  X_Attribute12,
          attribute13                     =  X_Attribute13,
          attribute14                     =  X_Attribute14,
          attribute15                     =  X_Attribute15,
          jgzz_attribute_category         =  X_Jgzz_attribute_Category,
          jgzz_attribute1                 =  X_Jgzz_attribute1,
          jgzz_attribute2                 =  X_Jgzz_attribute2,
          jgzz_attribute3                 =  X_Jgzz_attribute3,
          jgzz_attribute4                 =  X_Jgzz_attribute4,
          jgzz_attribute5                 =  X_Jgzz_attribute5,
          jgzz_attribute6                 =  X_Jgzz_attribute6,
          jgzz_attribute7                 =  X_Jgzz_attribute7,
          jgzz_attribute8                 =  X_Jgzz_attribute8,
          jgzz_attribute9                 =  X_Jgzz_attribute9,
          jgzz_attribute10                =  X_Jgzz_attribute10,
          jgzz_attribute11                =  X_Jgzz_attribute11,
          jgzz_attribute12                =  X_Jgzz_attribute12,
          jgzz_attribute13                =  X_Jgzz_attribute13,
          jgzz_attribute14                =  X_Jgzz_attribute14,
          jgzz_attribute15                =  X_Jgzz_attribute15,
          global_attribute_category       =  X_global_attribute_category,
          global_attribute1               =  X_global_attribute1,
          global_attribute2               =  X_global_attribute2,
          global_attribute3               =  X_global_attribute3,
          global_attribute4               =  X_global_attribute4,
          global_attribute5               =  X_global_attribute5,
          global_attribute6               =  X_global_attribute6,
          global_attribute7               =  X_global_attribute7,
          global_attribute8               =  X_global_attribute8,
          global_attribute9               =  X_global_attribute9,
          global_attribute10              =  X_global_attribute10,
          global_attribute11              =  X_global_attribute11,
          global_attribute12              =  X_global_attribute12,
          global_attribute13              =  X_global_attribute13,
          global_attribute14              =  X_global_attribute14,
          global_attribute15              =  X_global_attribute15,
          global_attribute16              =  X_global_attribute16,
          global_attribute17              =  X_global_attribute17,
          global_attribute18              =  X_global_attribute18,
          global_attribute19              =  X_global_attribute19,
          global_attribute20              =  X_global_attribute20,
          lockbox_matching_option         =  X_lockbox_matching_option,
          autocash_hierarchy_id_for_adr   =  X_autocash_hierarchy_id_adr,
          review_cycle                    =  X_review_cycle,
          credit_analyst_id               =  X_credit_analyst_id,
          credit_classification           =  X_credit_classification,   /*Bug 3619062*/
          Cons_Bill_Level                 =  X_Cons_Bill_Level,
          LATE_CHARGE_CALCULATION_TRX     =  X_LATE_CHARGE_CALCULATION_TRX,
          CREDIT_ITEMS_FLAG               = X_CREDIT_ITEMS_FLAG,
          DISPUTED_TRANSACTIONS_FLAG      = X_DISPUTED_TRANSACTIONS_FLAG,
          LATE_CHARGE_TYPE                = X_LATE_CHARGE_TYPE,
          LATE_CHARGE_TERM_ID             = X_LATE_CHARGE_TERM_ID,
          INTEREST_CALCULATION_PERIOD     = X_INTEREST_CALCULATION_PERIOD,
          HOLD_CHARGED_INVOICES_FLAG      = X_HOLD_CHARGED_INVOICES_FLAG,
          MESSAGE_TEXT_ID                 = X_MESSAGE_TEXT_ID,
          MULTIPLE_INTEREST_RATES_FLAG    = X_MULTIPLE_INTEREST_RATES_FLAG,
          CHARGE_BEGIN_DATE               = X_CHARGE_BEGIN_DATE,
	  AUTOMATCH_SET_ID                = X_AUTOMATCH_SET_ID
    WHERE rowid =      X_Row_Id;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;
END Update_Row;





PROCEDURE Delete_Row(X_Row_Id VARCHAR2) IS
BEGIN
    DELETE FROM HZ_CUST_PROFILE_CLASSES
    WHERE  rowid = X_Row_Id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
END Delete_Row;





PROCEDURE compute_negative_id (X_Customer_Profile_Class_Id Number,
                               X_Negative_Id               IN OUT NOCOPY Number,
                               Notify_Flag                 IN OUT NOCOPY varchar2)
IS
    number_in_update number;
    min_negative_id  number;
BEGIN
    --IDENTIFY EXISTING ROW WITH NEGATIVE ID IN HZ_CUST_PROFILE_CLASSES
    --RETRIEVE THE MIN id WHERE id BETWEEN -100*ID-99 AND -100*ID-2
    SELECT count(*), min(profile_class_id) - 1
    INTO   number_in_update, x_negative_id
    FROM   hz_cust_profile_classes
    WHERE  profile_class_id BETWEEN
                (X_Customer_Profile_Class_Id) * (-100) -99
           AND  (X_Customer_Profile_Class_Id) * (-100) -2;

   --IF ANY RECORDS EXIST, THEN SET GIVE WARNING MESSAGE TO "W"-
   --"Warning - Customer Profiles Currently Being Updated"
    IF number_in_update > 0 THEN
      fnd_message.set_name ('AR', 'AR_CUST_PROFILE_CURR_UPD');
      Notify_Flag := 'W';
    END IF;
END compute_negative_id;





PROCEDURE insert_negative_row  (X_Customer_Profile_Class_Id Number,
                                X_Negative_Id               Number,
                                X_Update_Options            Varchar2) is
  cursor C is
  select *
  from   hz_cust_profile_classes
  where  profile_class_id = x_customer_profile_class_id
  FOR UPDATE of Profile_Class_Id NOWAIT;
  Classinfo C%ROWTYPE;
  dummy_rowid varchar2(20);
  dummy_class number(15) := X_Negative_Id;
BEGIN
  OPEN C;
    FETCH C INTO Classinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  CLOSE C;

  Insert_Row  (dummy_rowid,
               dummy_class,
               Classinfo.Last_Updated_By,
               Classinfo.Last_Update_Date,
               Classinfo.Last_Update_Login,
               Classinfo.Created_By,
               Classinfo.Creation_Date,
               Classinfo.Name,
               Classinfo.Description,
               Classinfo.Status,
               Classinfo.Collector_Id,
               Classinfo.Credit_Checking,
               Classinfo.Tolerance,
               Classinfo.Interest_Charges,
               Classinfo.Charge_On_Finance_Charge_Flag,
               Classinfo.Interest_Period_Days,
               Classinfo.Discount_Terms,
               Classinfo.Discount_Grace_Days,
               Classinfo.Statements,
               Classinfo.Statement_Cycle_Id,
               Classinfo.Credit_Balance_Statements,
               Classinfo.Standard_Terms,
               Classinfo.Override_Terms,
               Classinfo.Payment_Grace_Days,
               Classinfo.Dunning_Letters,
               Classinfo.Dunning_Letter_Set_Id,
               Classinfo.Autocash_Hierarchy_Id,
               x_update_options,
               Classinfo.Auto_Rec_Incl_Disputed_Flag,
               Classinfo.Tax_Printing_Option,
               '',
               Classinfo.Grouping_Rule_Id,
               Classinfo.Cons_Inv_Flag,
               Classinfo.Cons_Inv_Type,
               Classinfo.Request_Id,
               Classinfo.Attribute_Category,
               Classinfo.Attribute1,
               Classinfo.Attribute2,
               Classinfo.Attribute3,
               Classinfo.Attribute4,
               Classinfo.Attribute5,
               Classinfo.Attribute6,
               Classinfo.Attribute7,
               Classinfo.Attribute8,
               Classinfo.Attribute9,
               Classinfo.Attribute10,
               Classinfo.Attribute11,
               Classinfo.Attribute12,
               Classinfo.Attribute13,
               Classinfo.Attribute14,
               Classinfo.Attribute15,
               Classinfo.Jgzz_attribute_Category,
               Classinfo.Jgzz_attribute1,
               Classinfo.Jgzz_attribute2,
               Classinfo.Jgzz_attribute3,
               Classinfo.Jgzz_attribute4,
               Classinfo.Jgzz_attribute5,
               Classinfo.Jgzz_attribute6,
               Classinfo.Jgzz_attribute7,
               Classinfo.Jgzz_attribute8,
               Classinfo.Jgzz_attribute9,
               Classinfo.Jgzz_attribute10,
               Classinfo.Jgzz_attribute11,
               Classinfo.Jgzz_attribute12,
               Classinfo.Jgzz_attribute13,
               Classinfo.Jgzz_attribute14,
               Classinfo.Jgzz_attribute15,
               Classinfo.global_attribute_category,
               Classinfo.global_attribute1,
               Classinfo.global_attribute2,
               Classinfo.global_attribute3,
               Classinfo.global_attribute4,
               Classinfo.global_attribute5,
               Classinfo.global_attribute6,
               Classinfo.global_attribute7,
               Classinfo.global_attribute8,
               Classinfo.global_attribute9,
               Classinfo.global_attribute10,
               Classinfo.global_attribute11,
               Classinfo.global_attribute12,
               Classinfo.global_attribute13,
               Classinfo.global_attribute14,
               Classinfo.global_attribute15,
               Classinfo.global_attribute16,
               Classinfo.global_attribute17,
               Classinfo.global_attribute18,
               Classinfo.global_attribute19,
               Classinfo.global_attribute20,
               Classinfo.lockbox_matching_option,
               Classinfo.autocash_hierarchy_id_for_adr,
               Classinfo.review_cycle,
               Classinfo.credit_analyst_id,
               Classinfo.credit_classification,  -- Bug 3619062
               Classinfo.cons_bill_level,
               Classinfo.LATE_CHARGE_CALCULATION_TRX,
               Classinfo.CREDIT_ITEMS_FLAG          ,
               Classinfo.DISPUTED_TRANSACTIONS_FLAG ,
               Classinfo.LATE_CHARGE_TYPE           ,
               Classinfo.LATE_CHARGE_TERM_ID        ,
               Classinfo.INTEREST_CALCULATION_PERIOD,
               Classinfo.HOLD_CHARGED_INVOICES_FLAG ,
               Classinfo.MESSAGE_TEXT_ID            ,
               Classinfo.MULTIPLE_INTEREST_RATES_FLAG,
               Classinfo.CHARGE_BEGIN_DATE);

END insert_negative_row;
--

END ARH_CPC_PKG;

/
