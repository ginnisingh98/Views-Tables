--------------------------------------------------------
--  DDL for Package Body ARP_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CUST_PKG" as
/* $Header: AROCUSTB.pls 120.2 2005/07/21 00:02:24 hyu noship $ */
--
-- PROCEDURE
--     check_unique_customer_name
--
-- DESCRIPTION
--    This procedure determins if an address has a site use of a particular
--    Type.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_rowid - rowid of row
--			- p_customer_name
--
--              OUT:
--			- p_warning_flag  - Tells calling routine that there
--                                          is a non fatla waring on the message stack
--
--   RETURNS  null
--
--  NOTES
--
--
procedure check_unique_customer_name (p_rowid in varchar2,
				      p_customer_name in varchar2,
				      p_warning_flag in out nocopy varchar2
	    	        	     ) is
begin
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
end check_unique_customer_name;
--
--
--
--
--
-- PROCEDURE
--     check_unique_customer_number
--
-- DESCRIPTION
--    RRaise error if customer number is duplicate
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_rowid - rowid of row
--			- p_customer_number
--
--              OUT:
--
--   RETURNS  null
--
--  NOTES
--
--
procedure check_unique_customer_number(p_rowid in varchar2,
				       p_customer_number in varchar2
	    	        	      ) is
begin
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
end check_unique_customer_number;
--
--
--
-- PROCEDURE
--      check_unique_orig_system_ref
--
-- DESCRIPTION
--    Raise error if orig_system_referenc is duplicate
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_rowid - rowid of row
--			- p_orig_system_reference
--
--              OUT:
--
--   RETURNS  null
--
--  NOTES
--
--
procedure check_unique_orig_system_ref(	p_rowid in varchar2,
			 	     	p_orig_system_reference in varchar2
				      ) is
dummy number;
--Bug 1171262 Modified from rowid to row_id
begin
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
end check_unique_orig_system_ref;
--
--
procedure delete_customer_alt_names(p_rowid in varchar2,
                                    p_status in varchar2,
                                    p_customer_id in number
                                    ) is
begin
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
end delete_customer_alt_names;
--
--
procedure insert_Row  (X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Customer_Id             IN OUT NOCOPY NUMBER,
                       X_Customer_Name           IN OUT NOCOPY VARCHAR2,
                       X_Customer_Number         IN OUT NOCOPY VARCHAR2,
                       X_Customer_Key                   VARCHAR2,
                       X_Status                    	VARCHAR2,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Customer_Prospect_code        	VARCHAR2,
                       X_Customer_Category_Code         VARCHAR2,
                       X_Customer_Class_Code            VARCHAR2,
                       X_Customer_Type             	VARCHAR2,
                       X_Primary_Salesrep_Id            NUMBER,
                       X_Sic_Code                       VARCHAR2,
                       X_Tax_Reference                  VARCHAR2,
                       X_Tax_Code                       VARCHAR2,
                       X_Fob_Point                 	VARCHAR2,
                       X_Ship_Via                  	VARCHAR2,
                       X_Gsa_Indicator                  VARCHAR2,
                       X_Ship_Partial                   VARCHAR2,
                       X_Taxpayer_Id                    VARCHAR2,
                       X_Price_List_Id                  NUMBER,
                       X_Freight_Term              	VARCHAR2,
                       X_Order_Type_Id                  NUMBER,
                       X_Sales_Channel_Code             VARCHAR2,
                       X_Warehouse_Id                   NUMBER,
                       X_Mission_Statement              VARCHAR2,
                       X_Num_Of_Employees               NUMBER,
                       X_Potential_Revenue_Curr_Fy      NUMBER,
                       X_Potential_Revenue_Next_Fy      NUMBER,
                       X_Fiscal_Yearend_Month           VARCHAR2,
                       X_Year_Established               NUMBER,
                       X_Analysis_Fy                    VARCHAR2,
                       X_Competitor_Flag                VARCHAR2,
                       X_Reference_Use_Flag             VARCHAR2,
                       X_Third_Party_Flag               VARCHAR2,
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
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Name_Phonetic         VARCHAR2,
                       X_Tax_Header_Level_Flag         	VARCHAR2,
                       X_Tax_Rounding_Rule         	VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2,
                       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute11             VARCHAR2,
                       X_Global_Attribute12             VARCHAR2,
                       X_Global_Attribute13             VARCHAR2,
                       X_Global_Attribute14             VARCHAR2,
                       X_Global_Attribute15             VARCHAR2,
                       X_Global_Attribute16             VARCHAR2,
                       X_Global_Attribute17             VARCHAR2,
                       X_Global_Attribute18             VARCHAR2,
                       X_Global_Attribute19             VARCHAR2,
                       X_Global_Attribute20             VARCHAR2
   ) IS
--
begin
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
END Insert_Row;
--
--
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Customer_Id                      NUMBER,
                     X_Customer_Name                    VARCHAR2,
                     X_Customer_Number                  VARCHAR2,
                     X_Customer_Key                     VARCHAR2,
                     X_Status                      	VARCHAR2,
                     X_Orig_System_Reference            VARCHAR2,
                     X_Customer_Prospect_code          	VARCHAR2,
                     X_Customer_Category_Code           VARCHAR2,
                     X_Customer_Class_Code              VARCHAR2,
                     X_Customer_Type               	VARCHAR2,
                     X_Primary_Salesrep_Id              NUMBER,
                     X_Sic_Code                         VARCHAR2,
                     X_Tax_Reference                    VARCHAR2,
                     X_Tax_Code                         VARCHAR2,
                     X_Fob_Point                   	VARCHAR2,
                     X_Ship_Via                    	VARCHAR2,
                     X_Gsa_Indicator                    VARCHAR2,
                     X_Ship_Partial                     VARCHAR2,
                     X_Taxpayer_Id                      VARCHAR2,
                     X_Price_List_Id                    NUMBER,
                     X_Freight_Term                	VARCHAR2,
                     X_Order_Type_Id                    NUMBER,
                     X_Sales_Channel_Code               VARCHAR2,
                     X_Warehouse_Id                     NUMBER,
                     X_Mission_Statement                VARCHAR2,
                     X_Num_Of_Employees                 NUMBER,
                     X_Potential_Revenue_Curr_Fy        NUMBER,
                     X_Potential_Revenue_Next_Fy        NUMBER,
                     X_Fiscal_Yearend_Month             VARCHAR2,
                     X_Year_Established                 NUMBER,
                     X_Analysis_Fy                      VARCHAR2,
                     X_Competitor_Flag                  VARCHAR2,
                     X_Reference_Use_Flag               VARCHAR2,
                     X_Third_Party_Flag                 VARCHAR2,
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
                     X_Customer_Name_Phonetic           VARCHAR2,
                     X_Tax_Header_Level_Flag         	VARCHAR2,
                     X_Tax_Rounding_Rule         	VARCHAR2,
                     X_Global_Attribute_Category        VARCHAR2,
                     X_Global_Attribute1                VARCHAR2,
                     X_Global_Attribute2                VARCHAR2,
                     X_Global_Attribute3                VARCHAR2,
                     X_Global_Attribute4                VARCHAR2,
                     X_Global_Attribute5                VARCHAR2,
                     X_Global_Attribute6                VARCHAR2,
                     X_Global_Attribute7                VARCHAR2,
                     X_Global_Attribute8                VARCHAR2,
                     X_Global_Attribute9                VARCHAR2,
                     X_Global_Attribute10               VARCHAR2,
                     X_Global_Attribute11               VARCHAR2,
                     X_Global_Attribute12               VARCHAR2,
                     X_Global_Attribute13               VARCHAR2,
                     X_Global_Attribute14               VARCHAR2,
                     X_Global_Attribute15               VARCHAR2,
                     X_Global_Attribute16               VARCHAR2,
                     X_Global_Attribute17               VARCHAR2,
                     X_Global_Attribute18               VARCHAR2,
                     X_Global_Attribute19               VARCHAR2,
                     X_Global_Attribute20               VARCHAR2
  ) IS
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
END Lock_Row;
--
--
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Name                  VARCHAR2,
                       X_Customer_Number                VARCHAR2,
                       X_Customer_Key                   VARCHAR2,
                       X_Status                    	VARCHAR2,
                       X_Orig_System_Reference          VARCHAR2,
                       X_Customer_Prospect_Code       	VARCHAR2,
                       X_Customer_Category_Code         VARCHAR2,
                       X_Customer_Class_Code            VARCHAR2,
                       X_Customer_Type           	VARCHAR2,
                       X_Primary_Salesrep_Id            NUMBER,
                       X_Sic_Code                       VARCHAR2,
                       X_Tax_Reference                  VARCHAR2,
                       X_Tax_Code                       VARCHAR2,
                       X_Fob_Point              	VARCHAR2,
                       X_Ship_Via                	VARCHAR2,
                       X_Gsa_Indicator                  VARCHAR2,
                       X_Ship_Partial                   VARCHAR2,
                       X_Taxpayer_Id                    VARCHAR2,
                       X_Price_List_Id           	NUMBER,
                       X_Freight_Term              	VARCHAR2,
                       X_Order_Type_Id                  NUMBER,
                       X_Sales_Channel_Code             VARCHAR2,
                       X_Warehouse_Id                   NUMBER,
                       X_Mission_Statement              VARCHAR2,
                       X_Num_Of_Employees               NUMBER,
                       X_Potential_Revenue_Curr_Fy      NUMBER,
                       X_Potential_Revenue_Next_Fy      NUMBER,
                       X_Fiscal_Yearend_Month           VARCHAR2,
                       X_Year_Established               NUMBER,
                       X_Analysis_Fy                    VARCHAR2,
                       X_Competitor_Flag                VARCHAR2,
                       X_Reference_Use_Flag             VARCHAR2,
                       X_Third_Party_Flag               VARCHAR2,
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
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Name_Phonetic         VARCHAR2,
                       X_Tax_Header_Level_Flag         	VARCHAR2,
                       X_Tax_Rounding_Rule         	VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2,
                       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute11             VARCHAR2,
                       X_Global_Attribute12             VARCHAR2,
                       X_Global_Attribute13             VARCHAR2,
                       X_Global_Attribute14             VARCHAR2,
                       X_Global_Attribute15             VARCHAR2,
                       X_Global_Attribute16             VARCHAR2,
                       X_Global_Attribute17             VARCHAR2,
                       X_Global_Attribute18             VARCHAR2,
                       X_Global_Attribute19             VARCHAR2,
                       X_Global_Attribute20             VARCHAR2

  ) IS
--
begin
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
NULL;
--}
END Update_Row;
--
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_statement_site                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Returns the site_use_id of a STATEMENT (STMTS) associated with the     |
 |    customers address if present else return NULL.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_id                                          |
 |              OUT:                                                         |
 |                    site_use_id                                            |
 |                                                                           |
 | RETURNS    : site_use_id where site_use_code = 'STMTS'                    |
 |                                                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |    The function is intended to be used in SQL statements.                 |
 |                                                                           |
 |    The intent of its creation was to minimize the code change for all the |
 |    SQLs which were using :                                                |
 |                                                                           |
 |    ra_customers.statement_site_use_id = ra_site_uses.site_use_id (+)      |
 |                                                                           |
 |    These queries can now be changed to:                                   |
 |                                                                           |
 |    ARP_CUST_PKG.get_statement_site(ra_customers.customer_id) =            |
 |    ra_site_uses.site_use_id (+)                                           |
 |                                                                           |
 |    Make sure you donot pass a constant as an argument when making use     |
 |    of this function in a query which is supposed to succeed even if the   |
 |    the statement site does not exist for a customer. The outer join does  |
 |    not kick off in an event when the function returns NULL thus making the|
 |    base query to fail.                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     19-JUN-1997  Neeraj Tandon     Created                                |
 +===========================================================================*/

FUNCTION get_statement_site ( p_customer_id  IN NUMBER
                            )
RETURN NUMBER is
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
RETURN NULL;
--}
END;
--
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_dunning_site                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Returns the site_use_id of DUNNING (DUN) associated with the           |
 |    customers address if present else return NULL.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_id                                          |
 |              OUT:                                                         |
 |                    site_use_id                                            |
 |                                                                           |
 | RETURNS    : site_use_id where site_use_code = 'DUN'                      |
 |                                                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |    The function is intended to be used in SQL statements.                 |
 |                                                                           |
 |    The intent of its creation was to minimize the code change for all the |
 |    SQLs which were using :                                                |
 |                                                                           |
 |    ra_customers.dunning_site_use_id  = ra_site_uses.site_use_id (+)       |
 |                                                                           |
 |    These queries can now be changed to:                                   |
 |                                                                           |
 |    ARP_CUST_PKG.get_dunning(ra_customers.customer_id) =                   |
 |    ra_site_uses.site_use_id (+)                                           |
 |                                                                           |
 |    Make sure you donot pass a constant as an argument when making use     |
 |    of this function in a query which is supposed to succeed even if the   |
 |    the dunning   site does not exist for a customer. The outer join does  |
 |    not kick off in an event when the function returns NULL thus making the|
 |    base query to fail.                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     19-JUN-1997  Neeraj Tandon    Created                                 |
 +===========================================================================*/

FUNCTION get_dunning_site ( p_customer_id  IN NUMBER
                          )
RETURN NUMBER is
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
RETURN NULL;
--}
END;
--
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_current_dunning_type                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 |    Returns the current dunning_type associated with a customers profile   |
 |    or BILL_TO profile or Dunning profile                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_id                                          |
 |                    p_bill_to_site_id                                      |
 |              OUT:                                                         |
 |                    dunning_type                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |     To be used in Account Details form to determine whether               |
 |     staged_dunning_level field of ar_payment_schedules is updateable      |
 |     or not.                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     30-JUN-1997  Neeraj Tandon    Created                                 |
 |                                                                           |
 +===========================================================================+*/
--
FUNCTION get_current_dunning_type (p_customer_id     IN NUMBER,
                                   p_bill_to_site_id IN NUMBER DEFAULT NULL
                                  )
  return varchar2 is
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
RETURN NULL;
--}
END;
--
FUNCTION arxvamai_overall_cr_limit ( p_customer_id NUMBER,
                                     p_currency_code VARCHAR2,
                                     p_customer_site_use_id NUMBER
                                    ) RETURN NUMBER is
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
RETURN NULL;
--}
END;

--
FUNCTION arxvamai_order_cr_limit ( p_customer_id NUMBER,
                                   p_currency_code VARCHAR2,
                                   p_customer_site_use_id NUMBER
                                  ) RETURN NUMBER is
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
RETURN NULL;
--}
END;

--
FUNCTION get_primary_billto_site ( p_customer_id  IN NUMBER
                                 )
RETURN NUMBER is
BEGIN
--{BUG 4504905 - R12 this code is obsolete - stubbed out for compilation only
RETURN NULL;
--}
END;
--
--
END arp_cust_pkg;


/
