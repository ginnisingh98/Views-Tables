--------------------------------------------------------
--  DDL for Package AP_CARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CARDS_PKG" AUTHID CURRENT_USER as
/* $Header: apiwcrds.pls 120.5.12010000.4 2009/09/25 15:41:48 syeluri ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Employee_Id                    NUMBER,
                       X_Card_Number                    VARCHAR2,
		       X_Card_Expiration_Date		DATE,
                       X_Card_Id                        IN OUT NOCOPY NUMBER,
                       X_Limit_Override_Amount          NUMBER,
                       X_Trx_Limit_Override_Amount      NUMBER,
                       X_Profile_Id                     NUMBER,
                       X_Cardmember_Name                VARCHAR2,
                       X_Department_Name                VARCHAR2,
                       X_Physical_Card_Flag             VARCHAR2,
                       X_Paper_Statement_Req_Flag       VARCHAR2,
                       X_Location_Id                    NUMBER,
  --                   X_Mothers_Maiden_Name            VARCHAR2, Commented for bug 2928064
                       X_Description                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Inactive_Date                  DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       X_Attribute26                    VARCHAR2,
                       X_Attribute27                    VARCHAR2,
                       X_Attribute28                    VARCHAR2,
                       X_Attribute29                    VARCHAR2,
                       X_Attribute30                    VARCHAR2,
                       X_CardProgramId                  NUMBER,
                       X_CardReferenceId                NUMBER,
                       X_paycardreferenceid             NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Employee_Id                      NUMBER,
		             X_Card_Expiration_Date		DATE,
                     X_Card_Id                          NUMBER,
                     X_Limit_Override_Amount            NUMBER,
                     X_Trx_Limit_Override_Amount        NUMBER,
                     X_Profile_Id                       NUMBER,
                     X_Cardmember_Name                  VARCHAR2,
                     X_Department_Name                  VARCHAR2,
                     X_Physical_Card_Flag               VARCHAR2,
                     X_Paper_Statement_Req_Flag         VARCHAR2,
                     X_Location_Id                      NUMBER,
   --                X_Mothers_Maiden_Name              VARCHAR2,Commented for bug 2928064
                     X_Description                      VARCHAR2,
                     X_Org_Id                           NUMBER,
                     X_Inactive_Date                    DATE,
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
                     X_Attribute26                      VARCHAR2,
                     X_Attribute27                      VARCHAR2,
                     X_Attribute28                      VARCHAR2,
                     X_Attribute29                      VARCHAR2,
                     X_Attribute30                      VARCHAR2,
                     X_CardProgramId                    NUMBER
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Employee_Id                    NUMBER,
		               X_Card_Expiration_Date		DATE,
                       X_Card_Id                        NUMBER,
                       X_Limit_Override_Amount          NUMBER,
                       X_Trx_Limit_Override_Amount      NUMBER,
                       X_Profile_Id                     NUMBER,
                       X_Cardmember_Name                VARCHAR2,
                       X_Department_Name                VARCHAR2,
                       X_Physical_Card_Flag             VARCHAR2,
                       X_Paper_Statement_Req_Flag       VARCHAR2,
                       X_Location_Id                    NUMBER,
  --                   X_Mothers_Maiden_Name            VARCHAR2,Commented for bug 2928064
                       X_Description                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Inactive_Date                  DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_Attribute26                    VARCHAR2,
                       X_Attribute27                    VARCHAR2,
                       X_Attribute28                    VARCHAR2,
                       X_Attribute29                    VARCHAR2,
                       X_Attribute30                    VARCHAR2,
                       X_CardProgramId                  NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

 /*  The 4 procedures added as part of Supplier PCard project. */

PROCEDURE Supplier_Insert_Row( x_Card_Id NUMBER,
                               X_Vendor_id NUMBER,
                               X_Vendor_Site_id NUMBER,
                               X_Last_Updated_By NUMBER,
                               X_Last_Update_Login NUMBER,
                               X_Last_Update_Date DATE,
                               X_Created_By NUMBER,
                               X_Creation_Date DATE,
                               X_Org_Id NUMBER,
                               X_Rowid IN OUT NOCOPY VARCHAR2 );

PROCEDURE Supplier_Update_Row( x_Card_Id NUMBER,
                               X_Vendor_id NUMBER,
                               X_Vendor_Site_id NUMBER,
                               X_Last_Updated_By NUMBER,
                               X_Last_Update_Login NUMBER,
                               X_Last_Update_Date DATE,
                               X_Rowid VARCHAR2 );

PROCEDURE Supplier_Lock_Row( X_Rowid VARCHAR2,
                             X_Vendor_Site_Id NUMBER );

PROCEDURE Supplier_Delete_Row ( X_Rowid VARCHAR2 );


--8726861
FUNCTION  GET_CARD_ID(
          P_CARD_NUMBER     IN AP_EXPENSE_FEED_LINES_ALL.CARD_NUMBER%TYPE)
  RETURN AP_CARDS_ALL.CARD_ID%TYPE ;
--8726861
--8947179
PROCEDURE UPG_HISTORICAL_TRANSACTIONS (errbuf OUT NOCOPY VARCHAR2,
				      retcode OUT NOCOPY NUMBER) ;

END AP_CARDS_PKG;

/
