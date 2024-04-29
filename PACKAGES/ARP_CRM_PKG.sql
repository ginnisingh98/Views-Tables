--------------------------------------------------------
--  DDL for Package ARP_CRM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CRM_PKG" AUTHID CURRENT_USER as
/* $Header: AROCRMS.pls 115.0 99/07/17 00:01:53 porting ship $ */

  PROCEDURE check_unique ( x_cust_receipt_method_id in number,
			   x_receipt_method_id	    in number,
			   x_start_date		    in date,
			   x_end_date		    in date,
			   x_meth_type		    in varchar2,
			   x_id			    in number
			  );
  PROCEDURE check_primary (x_cust_receipt_method_id in number,
			   x_start_date		    in date,
			   x_end_date		    in date,
			   x_meth_type		    in varchar2,
			   x_id			    in number
			  );

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Cust_Receipt_Method_Id  IN OUT NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Primary_Flag                   VARCHAR2,
                       X_Receipt_Method_Id              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Site_Use_Id                    NUMBER,
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
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cust_Receipt_Method_Id           NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Primary_Flag                     VARCHAR2,
                     X_Receipt_Method_Id                NUMBER,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
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
                     X_Attribute15                      VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Cust_Receipt_Method_Id         NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Primary_Flag                   VARCHAR2,
                       X_Receipt_Method_Id              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Site_Use_Id                    NUMBER,
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
                       X_Attribute15                    VARCHAR2
                      );
END arp_crm_pkg;

 

/
