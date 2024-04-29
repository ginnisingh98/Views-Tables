--------------------------------------------------------
--  DDL for Package ARP_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CUST_PKG" AUTHID CURRENT_USER as
/* $Header: AROCUSTS.pls 120.2 2005/07/21 00:02:08 hyu noship $ */
procedure   Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Customer_Id             IN OUT NOCOPY NUMBER,
                       X_Customer_Name           IN OUT NOCOPY VARCHAR2,
                       X_Customer_Number         IN OUT NOCOPY VARCHAR2,
                       X_Customer_Key                   VARCHAR2,
                       X_Status                		VARCHAR2,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Customer_Prospect_code         VARCHAR2,
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
                       X_Tax_Header_Level_Flag          VARCHAR2,
                       X_Tax_Rounding_Rule          	VARCHAR2,
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
                      );
--
--
procedure   Lock_Row(X_Rowid                            VARCHAR2,
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
                     X_Tax_Header_Level_Flag          	VARCHAR2,
                     X_Tax_Rounding_Rule          	VARCHAR2,
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
                    );
--
--
procedure Update_Row  (X_Rowid                          VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Name                  VARCHAR2,
                       X_Customer_Number                VARCHAR2,
                       X_Customer_Key                   VARCHAR2,
                       X_Status                    	VARCHAR2,
                       X_Orig_System_Reference          VARCHAR2,
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
                       X_Customer_Name_Phonetic         VARCHAR2,
                       X_Tax_Header_Level_Flag          VARCHAR2,
                       X_Tax_Rounding_Rule          	VARCHAR2,
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
                      );

--
--
procedure check_unique_customer_name(p_rowid in varchar2,
				     p_customer_name in varchar2,
				     p_warning_flag in out NOCOPY varchar2
	    	       		     );
--
--
procedure check_unique_customer_number(p_rowid in varchar2,
				       p_customer_number in varchar2
	    	       		      );
--
--
procedure check_unique_orig_system_ref(p_rowid in varchar2,
			 	       p_orig_system_reference in varchar2
				      );
--
--

FUNCTION get_statement_site (p_customer_id IN NUMBER
                            ) RETURN NUMBER;

--
--

FUNCTION get_dunning_site   (p_customer_id IN NUMBER
                            ) RETURN NUMBER;

--
--
FUNCTION get_current_dunning_type (p_customer_id     in NUMBER,
				   p_bill_to_site_id in NUMBER DEFAULT NULL
                                  ) RETURN VARCHAR2;

--
FUNCTION arxvamai_overall_cr_limit ( p_customer_id NUMBER,
                                     p_currency_code VARCHAR2,
                                     p_customer_site_use_id NUMBER
                                    ) RETURN NUMBER;

--
FUNCTION arxvamai_order_cr_limit ( p_customer_id NUMBER,
                                   p_currency_code VARCHAR2,
                                   p_customer_site_use_id NUMBER
                                  ) RETURN NUMBER;

--
TYPE id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_site_use_id_tab  id_tab;
--
FUNCTION get_primary_billto_site ( p_customer_id IN NUMBER
                                  ) RETURN NUMBER;
--

end;

 

/
