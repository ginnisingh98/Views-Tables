--------------------------------------------------------
--  DDL for Package Body ARP_CPROF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CPROF_PKG" as
/* $Header: AROCPRFB.pls 120.1 2005/08/11 00:57:09 hyu noship $ */
--
--
PROCEDURE check_unique ( p_customer_id in number,
			  p_site_use_id in number
			) is
BEGIN
  NULL;
end check_unique;
 --
 --
PROCEDURE update_customer_alt_names(p_rowid in varchar2,
                                    p_standard_terms in number,
                                    p_customer_id in number,
                                    p_site_use_id in number
                                    ) is
begin
   NULL;
end update_customer_alt_names;
--
--
--
PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Customer_Profile_Id     IN OUT NOCOPY NUMBER,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Credit_Checking                VARCHAR2,
                       X_Credit_Hold                    VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Dunning_Letters                VARCHAR2,
                       X_Interest_Charges               VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Statements                     VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Account_Status                 VARCHAR2,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Credit_Rating                  VARCHAR2,
                       X_Customer_Profile_Class_Id      NUMBER,
                       X_Discount_Grace_Days            NUMBER,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Interest_Period_Days           NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Percent_Collectable            NUMBER,
                       X_Risk_Code                      VARCHAR2,
                       X_Site_Use_Id                    NUMBER,
                       X_Standard_Terms                 NUMBER,
                       X_Statement_Cycle_Id             NUMBER,
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
                       X_Charge_On_Fin_Charge_Flag   	VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Clearing_Days                  NUMBER,
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
                       X_autocash_hierarchy_id_adr        NUMBER
  ) IS
BEGIN
   NULL;
END Insert_Row;


procedure insert_row( 	x_customer_id			number,
 			x_site_use_id			number,
			x_customer_profile_class_id	number ) is
begin
  NULL;
end insert_row;
--
--
--
PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Customer_Profile_Id              NUMBER,
                     X_Auto_Rec_Incl_Disputed_Flag      VARCHAR2,
                     X_Collector_Id                     NUMBER,
                     X_Credit_Balance_Statements        VARCHAR2,
                     X_Credit_Checking                  VARCHAR2,
                     X_Credit_Hold                      VARCHAR2,
                     X_Customer_Id                      NUMBER,
                     X_Discount_Terms                   VARCHAR2,
                     X_Dunning_Letters                  VARCHAR2,
                     X_Interest_Charges                 VARCHAR2,
                     X_Statements                       VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Tolerance                        NUMBER,
                     X_Tax_Printing_Option              VARCHAR2,
                     X_Account_Status                   VARCHAR2,
                     X_Autocash_Hierarchy_Id            NUMBER,
                     X_Credit_Rating                    VARCHAR2,
                     X_Customer_Profile_Class_Id        NUMBER,
                     X_Discount_Grace_Days              NUMBER,
                     X_Dunning_Letter_Set_Id            NUMBER,
                     X_Interest_Period_Days             NUMBER,
                     X_Override_Terms                   VARCHAR2,
                     X_Payment_Grace_Days               NUMBER,
                     X_Percent_Collectable              NUMBER,
                     X_Risk_Code                        VARCHAR2,
                     X_Standard_Terms                   NUMBER,
                     X_Statement_Cycle_Id               NUMBER,
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
                     X_Charge_On_Fin_Charge_Flag   	VARCHAR2,
                     X_Grouping_Rule_Id                 NUMBER,
                     X_Cons_Inv_Flag                    VARCHAR2,
                     X_Cons_Inv_Type                    VARCHAR2,
                     X_Clearing_Days                    NUMBER,
                     X_Jgzz_attribute_Category               VARCHAR2,
                     X_Jgzz_attribute1                       VARCHAR2,
                     X_Jgzz_attribute2                       VARCHAR2,
                     X_Jgzz_attribute3                       VARCHAR2,
                     X_Jgzz_attribute4                       VARCHAR2,
                     X_Jgzz_attribute5                       VARCHAR2,
                     X_Jgzz_attribute6                       VARCHAR2,
                     X_Jgzz_attribute7                       VARCHAR2,
                     X_Jgzz_attribute8                       VARCHAR2,
                     X_Jgzz_attribute9                       VARCHAR2,
                     X_Jgzz_attribute10                      VARCHAR2,
                     X_Jgzz_attribute11                      VARCHAR2,
                     X_Jgzz_attribute12                      VARCHAR2,
                     X_Jgzz_attribute13                      VARCHAR2,
                     X_Jgzz_attribute14                      VARCHAR2,
                     X_Jgzz_attribute15                      VARCHAR2,
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
                     X_autocash_hierarchy_id_adr        NUMBER
  )
IS
BEGIN
   NULL;
END Lock_Row;
--
--
--
PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Customer_Profile_Id            NUMBER,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Credit_Checking                VARCHAR2,
                       X_Credit_Hold                    VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Dunning_Letters                VARCHAR2,
                       X_Interest_Charges               VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Statements                     VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Account_Status                 VARCHAR2,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Credit_Rating                  VARCHAR2,
                       X_Customer_Profile_Class_Id      NUMBER,
                       X_Discount_Grace_Days            NUMBER,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Interest_Period_Days           NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Percent_Collectable            NUMBER,
                       X_Risk_Code                      VARCHAR2,
                       X_Site_Use_Id                    NUMBER,
                       X_Standard_Terms                 NUMBER,
                       X_Statement_Cycle_Id             NUMBER,
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
                       X_Charge_On_Fin_Charge_Flag  VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Clearing_Days                  NUMBER,
                       X_Jgzz_attribute_Category             VARCHAR2,
                       X_Jgzz_attribute1                     VARCHAR2,
                       X_Jgzz_attribute2                     VARCHAR2,
                       X_Jgzz_attribute3                     VARCHAR2,
                       X_Jgzz_attribute4                     VARCHAR2,
                       X_Jgzz_attribute5                     VARCHAR2,
                       X_Jgzz_attribute6                     VARCHAR2,
                       X_Jgzz_attribute7                     VARCHAR2,
                       X_Jgzz_attribute8                     VARCHAR2,
                       X_Jgzz_attribute9                     VARCHAR2,
                       X_Jgzz_attribute10                    VARCHAR2,
                       X_Jgzz_attribute11                    VARCHAR2,
                       X_Jgzz_attribute12                    VARCHAR2,
                       X_Jgzz_attribute13                    VARCHAR2,
                       X_Jgzz_attribute14                    VARCHAR2,
                       X_Jgzz_attribute15                    VARCHAR2,
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
                       X_autocash_hierarchy_id_adr      NUMBER
  ) IS
BEGIN
  NULL;
END Update_Row;
--
--
--
--
-- PROCEDURE
--     create_profile_from_class
--
-- DESCRIPTION
--	This procedure creates a customer profile from the customr_profile_class
--	It is designed to be called from the cust_prof|addr_prof blocks of the
--	enter customer form.
--
--	It returns all the profiles attributes to the form ans sliently
--      creates the rows in ar_customer_profile_amounts;
--
--	It is assume that the calling forms has no uncomitted rows for the
-- 	table ar_customer_profile_amounts.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
PROCEDURE create_profile_from_class(
			x_customer_profile_class_id	in number,
			x_customer_profile_id		in OUT NOCOPY number,
			x_customer_id			in OUT NOCOPY number,
			x_site_use_id			in number,
			x_collector_id 			OUT NOCOPY number,
 			x_collector_name 		OUT NOCOPY varchar2,
 			x_credit_checking		OUT NOCOPY varchar2,
 			x_tolerance			OUT NOCOPY number,
 			x_interest_charges		OUT NOCOPY varchar2,
 			x_charge_on_fin_charge_flag	OUT NOCOPY varchar2,
 			x_interest_period_days		OUT NOCOPY number,
 			x_discount_terms 		OUT NOCOPY varchar2,
 			x_discount_grace_days		OUT NOCOPY number,
 			x_statements			OUT NOCOPY varchar2,
 			x_statement_cycle_id		OUT NOCOPY number,
 			x_statement_cycle_name		OUT NOCOPY varchar2,
 			x_credit_balance_statements	OUT NOCOPY varchar2,
 			x_standard_terms 		OUT NOCOPY number,
 			x_standard_terms_name		OUT NOCOPY varchar2,
 			x_override_terms 		OUT NOCOPY varchar2,
 			x_payment_grace_days		OUT NOCOPY number,
 			x_dunning_letters		OUT NOCOPY varchar2,
 			x_dunning_letter_set_id		OUT NOCOPY number,
 			x_dunning_letter_set_name	OUT NOCOPY varchar2,
 			x_autocash_hierarchy_id		OUT NOCOPY number,
 			x_autocash_hierarchy_name	OUT NOCOPY varchar2,
 			x_auto_rec_incl_disputed_flag	OUT NOCOPY varchar2,
 			x_tax_printing_option		OUT NOCOPY varchar2,
 			x_grouping_rule_id		OUT NOCOPY number,
 			x_grouping_rule_name		OUT NOCOPY varchar2,
                        x_cons_inv_flag                 OUT NOCOPY varchar2,
                        x_cons_inv_type                 OUT NOCOPY varchar2,
 			x_attribute_category		OUT NOCOPY varchar2,
 			x_attribute1			OUT NOCOPY varchar2,
 			x_attribute2			OUT NOCOPY varchar2,
 			x_attribute3			OUT NOCOPY varchar2,
 			x_attribute4			OUT NOCOPY varchar2,
 			x_attribute5			OUT NOCOPY varchar2,
 			x_attribute6			OUT NOCOPY varchar2,
 			x_attribute7			OUT NOCOPY varchar2,
 			x_attribute8			OUT NOCOPY varchar2,
 			x_attribute9			OUT NOCOPY varchar2,
 			x_attribute10			OUT NOCOPY varchar2,
 			x_attribute11			OUT NOCOPY varchar2,
 			x_attribute12			OUT NOCOPY varchar2,
 			x_attribute13			OUT NOCOPY varchar2,
 			x_attribute14			OUT NOCOPY varchar2,
 			x_attribute15			OUT NOCOPY varchar2,
 			x_jgzz_attribute_category		OUT NOCOPY varchar2,
 			x_jgzz_attribute1			OUT NOCOPY varchar2,
 			x_jgzz_attribute2			OUT NOCOPY varchar2,
 			x_jgzz_attribute3			OUT NOCOPY varchar2,
 			x_jgzz_attribute4			OUT NOCOPY varchar2,
 			x_jgzz_attribute5			OUT NOCOPY varchar2,
 			x_jgzz_attribute6			OUT NOCOPY varchar2,
 			x_jgzz_attribute7			OUT NOCOPY varchar2,
 			x_jgzz_attribute8			OUT NOCOPY varchar2,
 			x_jgzz_attribute9			OUT NOCOPY varchar2,
 			x_jgzz_attribute10			OUT NOCOPY varchar2,
 			x_jgzz_attribute11			OUT NOCOPY varchar2,
 			x_jgzz_attribute12			OUT NOCOPY varchar2,
 			x_jgzz_attribute13			OUT NOCOPY varchar2,
 			x_jgzz_attribute14			OUT NOCOPY varchar2,
 			x_jgzz_attribute15			OUT NOCOPY varchar2,
 			x_global_attribute_category		OUT NOCOPY varchar2,
 			x_global_attribute1			OUT NOCOPY varchar2,
 			x_global_attribute2			OUT NOCOPY varchar2,
 			x_global_attribute3			OUT NOCOPY varchar2,
 			x_global_attribute4			OUT NOCOPY varchar2,
 			x_global_attribute5			OUT NOCOPY varchar2,
 			x_global_attribute6			OUT NOCOPY varchar2,
 			x_global_attribute7			OUT NOCOPY varchar2,
 			x_global_attribute8			OUT NOCOPY varchar2,
 			x_global_attribute9			OUT NOCOPY varchar2,
 			x_global_attribute10			OUT NOCOPY varchar2,
 			x_global_attribute11			OUT NOCOPY varchar2,
 			x_global_attribute12			OUT NOCOPY varchar2,
 			x_global_attribute13			OUT NOCOPY varchar2,
 			x_global_attribute14			OUT NOCOPY varchar2,
 			x_global_attribute15			OUT NOCOPY varchar2,
 			x_global_attribute16			OUT NOCOPY varchar2,
 			x_global_attribute17			OUT NOCOPY varchar2,
 			x_global_attribute18			OUT NOCOPY varchar2,
 			x_global_attribute19			OUT NOCOPY varchar2,
 			x_global_attribute20			OUT NOCOPY varchar2,
                        x_lockbox_matching_option               OUT NOCOPY varchar2,
                        x_lockbox_matching_name                 OUT NOCOPY varchar2,
                        x_autocash_hierarchy_id_adr             OUT NOCOPY number,
                        x_autocash_hierarchy_name_adr           OUT NOCOPY varchar2
			) is
begin
   NULL;
end create_profile_from_class;
--
--
--
END arp_cprof_pkg;

/
