--------------------------------------------------------
--  DDL for Package Body ARP_CSU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CSU_PKG" as
/* $Header: AROCSUB.pls 120.1 2005/08/11 01:04:17 hyu noship $ */
--
--
--
-- PROCEDURE
--     maintain_denormalized_data
--
-- DESCRIPTION
--		This procedure coordinates the calling of routines to maintains
--		denormailized site_use data.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     p_customer_id
--			p_address_id
--			p_site_use_id
--			p_site_use_code
--			p_primary_flag
--              OUT:
--
-- NOTES
--
--
--
--
procedure  maintain_denormalized_data ( p_customer_id 	in number,
					p_address_id  	in number,
					p_site_use_id 	in number,
					p_site_use_code in varchar2,
					p_status        in varchar2,
					p_primary_flag  in varchar2 ) is
BEGIN
  NULL;
end maintain_denormalized_data;
--
--
--
PROCEDURE delete_customer_alt_names(p_rowid in varchar2,
                                    p_status in varchar2,
                                    p_customer_id in number,
                                    p_site_use_id in number
                                    ) is
begin
  NULL;
end delete_customer_alt_names;
--
--
--
-- PROCEDURE
--     site_use_exists
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
--			p_address_id -
--			p_site_use_code  - type of site use to create
--              OUT:
--                      p_site_use_id - id of site use type
--			p_site_use_status - status of site use type
--
-- RETURNS  null
--
-- NOTES
--
PROCEDURE site_use_exists( 	p_address_id in number,
				p_site_use_code in varchar2,
				p_site_use_id out NOCOPY number,
				p_site_use_status out NOCOPY varchar2 ) is
begin
  NULL;
end site_use_exists;
--
--
--
-- PROCEDURE
--     update_su_status
--
-- DESCRIPTION
--		This procedure updates the staus of a row in ra_site_uses
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			p_customer_id
--			p_address_id
--			p_site_use_code
--			p_site_use_id	- id of row to be updated
--			p_status	- status to update row to(A,I)
--              OUT:
--
-- NOTES
--
--
--
--
PROCEDURE update_su_status (	p_customer_id in number,
				p_address_id in number,
				p_site_use_id in number,
				p_site_use_code in varchar2,
				p_status in varchar2 ) is
begin
  NULL;
end update_su_status;
  --
  --
--
--
--
-- PROCEDURE
--     check_unique_site_use_code
--
-- DESCRIPTION
--		This procedure ensures validates to ensure
--			1). An addres has only active site use per type.
--			2). A Customer only has one primary active site use of each type
--				DUN
--				STMTS
--				LEGAL
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_site_use_id
--			- p_customer_id
--			- p_address_id,
--			- p_site_use_code
--
--              OUT:
--
-- NOTES
--
--
--
procedure check_unique_site_use_code(	p_site_use_id in number,
					p_customer_id in number,
					p_address_id  in number,
					p_site_use_code in varchar2 ) is
begin
  NULL;
end check_unique_site_use_code;
--
--
--
--
--
-- PROCEDURE
--     check_unique_location
--
-- DESCRIPTION
--		This procedure ensures validates to ensure rows
--		in ra_site_uses have unique locations within customer/site_use_code
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_site_use_id
--			- p_customer_id
--			- p_site_use_code
--			- p_location
--
--              OUT:
--
-- NOTES
--
--
--
procedure check_unique_location( p_site_use_id 	  in number,
				 p_customer_id 	  in number,
				 p_site_use_code  in varchar2,
				 p_location       in varchar2
				) is
begin
  NULL;
end check_unique_location;
--
--
--
-- PROCEDURE
--     check_primary
--
-- DESCRIPTION
--		This procedure ensures that an address only has one active
--		site use per type.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--			- p_site_use_id
--			- p_customer_id,
--			- p_site_use_code
--
--              OUT:
--
-- NOTES
--
--
--
PROCEDURE check_primary ( p_site_use_id in number, p_customer_id in number, p_site_use_code in varchar2) is
begin
   NULL;
end   check_primary;
--
--
--
PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Site_Use_Id             IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Site_Use_Code                  VARCHAR2,
		       X_customer_id			NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Primary_Flag                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Location               IN OUT  NOCOPY VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Sic_Code                       VARCHAR2,
                       X_Payment_Term_Id                NUMBER,
                       X_Gsa_Indicator                  VARCHAR2,
                       X_Ship_Partial                   VARCHAR2,
                       X_Ship_Via                       VARCHAR2,
                       X_Fob_Point                      VARCHAR2,
                       X_Order_Type_Id                  NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_Freight_Term                   VARCHAR2,
                       X_Warehouse_Id                   NUMBER,
                       X_Territory_Id                   NUMBER,
                       X_Tax_Code                       VARCHAR2,
                       X_Tax_Reference                  VARCHAR2,
                       X_Demand_Class_Code              VARCHAR2,
                       x_inventory_location_id		NUMBER,
		       x_inventory_organization_id	NUMBER,
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
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Tax_Classification             VARCHAR2,
                       X_Tax_Header_Level_Flag          VARCHAR2,
                       X_Tax_Rounding_Rule              VARCHAR2,
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
                       X_Global_Attribute20             VARCHAR2,
                       X_Primary_Salesrep_Id            NUMBER  DEFAULT NULL,
                       X_Finchrg_Receivables_Trx_Id     NUMBER  DEFAULT NULL,
 		       X_GL_ID_Rec			NUMBER,
		       X_GL_ID_Rev			NUMBER,
		       X_GL_ID_Tax			NUMBER,
		       X_GL_ID_Freight			NUMBER,
		       X_GL_ID_Clearing			NUMBER,
		       X_GL_ID_Unbilled			NUMBER,
		       X_GL_ID_Unearned 		NUMBER
 		  ) IS
BEGIN
   NULL;
END Insert_Row;
--
--

PROCEDURE Update_Row(X_Rowid                  IN OUT  NOCOPY VARCHAR2 ,
                       X_Site_Use_Id            IN OUT  NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Site_Use_Code                  VARCHAR2,
		       X_customer_id			NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Primary_Flag                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Location                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Sic_Code                       VARCHAR2,
                       X_Payment_Term_Id                NUMBER,
                       X_Gsa_Indicator                  VARCHAR2,
                       X_Ship_Partial                   VARCHAR2,
                       X_Ship_Via                       VARCHAR2,
                       X_Fob_Point                      VARCHAR2,
                       X_Order_Type_Id                  NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_Freight_Term                   VARCHAR2,
                       X_Warehouse_Id                   NUMBER,
                       X_Territory_Id                   NUMBER,
                       X_Tax_Code                       VARCHAR2,
                       X_Tax_Reference                  VARCHAR2,
                       X_Demand_Class_Code              VARCHAR2,
		       x_inventory_location_id		NUMBER,
		       x_inventory_organization_id	NUMBER,
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
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Tax_Classification             VARCHAR2,
                       X_Tax_Header_Level_Flag          VARCHAR2,
                       X_Tax_Rounding_Rule              VARCHAR2,
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
                       X_Global_Attribute20             VARCHAR2,
                       X_Primary_Salesrep_Id            NUMBER  DEFAULT NULL,
                       X_Finchrg_Receivables_Trx_Id     NUMBER  DEFAULT NULL,
  		       X_GL_ID_Rec			NUMBER,
		       X_GL_ID_Rev			NUMBER,
		       X_GL_ID_Tax			NUMBER,
		       X_GL_ID_Freight			NUMBER,
		       X_GL_ID_Clearing			NUMBER,
		       X_GL_ID_Unbilled			NUMBER,
		       X_GL_ID_Unearned 		NUMBER

  ) IS
BEGIN
   NULL;
END Update_Row;
--
--

PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Site_Use_Id                      NUMBER,
                     X_Site_Use_Code                    VARCHAR2,
                     X_Address_Id                       NUMBER,
                     X_Primary_Flag                     VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Location                         VARCHAR2,
                     X_Contact_Id                       NUMBER,
                     X_Bill_To_Site_Use_Id              NUMBER,
                     X_Sic_Code                         VARCHAR2,
                     X_Payment_Term_Id                  NUMBER,
                     X_Gsa_Indicator                    VARCHAR2,
                     X_Ship_Partial                     VARCHAR2,
                     X_Ship_Via                         VARCHAR2,
                     X_Fob_Point                        VARCHAR2,
                     X_Order_Type_Id                    NUMBER,
                     X_Price_List_Id                    NUMBER,
                     X_Freight_Term                     VARCHAR2,
                     X_Warehouse_Id                     NUMBER,
                     X_Territory_Id                     NUMBER,
                     X_Tax_Code                         VARCHAR2,
                     X_Tax_Reference                    VARCHAR2,
                     X_Demand_Class_Code                VARCHAR2,
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
                     X_Attribute16                      VARCHAR2,
                     X_Attribute17                      VARCHAR2,
                     X_Attribute18                      VARCHAR2,
                     X_Attribute19                      VARCHAR2,
                     X_Attribute20                      VARCHAR2,
                     X_Attribute21                      VARCHAR2,
                     X_Attribute22                      VARCHAR2,
                     X_Attribute23                      VARCHAR2,
                     X_Attribute24                      VARCHAR2,
                     X_Attribute25                      VARCHAR2,
                     X_Tax_Classification               VARCHAR2,
                     X_Tax_Header_Level_Flag            VARCHAR2,
                     X_Tax_Rounding_Rule                VARCHAR2,
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
                     X_Global_Attribute20               VARCHAR2,
                     X_Primary_Salesrep_Id              NUMBER  DEFAULT NULL,
                     X_Finchrg_Receivables_Trx_Id       NUMBER  DEFAULT NULL,
 		     X_GL_ID_Rec			NUMBER,
		     X_GL_ID_Rev			NUMBER,
		     X_GL_ID_Tax			NUMBER,
		     X_GL_ID_Freight			NUMBER,
		     X_GL_ID_Clearing			NUMBER,
		     X_GL_ID_Unbilled			NUMBER,
		     X_GL_ID_Unearned 			NUMBER


  ) IS
BEGIN
  NULL;
END Lock_Row;
--
--

END arp_csu_pkg;

/
