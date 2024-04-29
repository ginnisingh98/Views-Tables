--------------------------------------------------------
--  DDL for Package ARH_CREL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_CREL_PKG" AUTHID CURRENT_USER as
/* $Header: ARHCRELS.pls 120.3 2005/06/16 21:10:01 jhuang ship $*/
  --
  PROCEDURE  check_unique(x_customer_id in number ,x_related_customer_id in number );
  --
  PROCEDURE Insert_Row(
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
		       X_relationship_type		VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
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
                       X_BILL_TO_FLAG                    VARCHAR2,
                       X_SHIP_TO_FLAG                    VARCHAR2,
                        x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2

                      );



  PROCEDURE Update_Row(
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
		       X_relationship_type		VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date         IN OUT      NOCOPY DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
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
                       X_BILL_TO_FLAG                    VARCHAR2,
                       X_SHIP_TO_FLAG                    VARCHAR2,
                        x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2,
                      x_object_version                  IN NUMBER DEFAULT -1,
		      X_Row_Id				IN ROWID  DEFAULT NULL			--Bug Fix: 3237327
                      );
END arh_crel_pkg;

 

/
