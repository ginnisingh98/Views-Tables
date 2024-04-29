--------------------------------------------------------
--  DDL for Package ARH_CROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_CROL_PKG" AUTHID CURRENT_USER as
/* $Header: ARHCROLS.pls 120.2 2005/06/16 21:10:10 jhuang ship $*/

  PROCEDURE check_unique(p_contact_role_id 	in number,
			 p_contact_id		in number,
			 p_usage_code		in varchar2);

  PROCEDURE check_primary(p_contact_role_id	in number,
			  p_contact_id		in number );

  FUNCTION  contact_role_exists(p_contact_id in number ,
				p_usage_code in varchar2 ) return Boolean;


  PROCEDURE Insert_Row(
                       X_Contact_Role_Id         IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Primary_Flag                   VARCHAR2,
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
                       x_org_contact_id                 NUMBER,
                       x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2
                      );

  PROCEDURE Update_Row(
                       X_Contact_Role_Id                NUMBER,
                       X_Last_Update_Date         in out      NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Primary_Flag                   VARCHAR2,
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
                       x_org_contact_id                 NUMBER,
                       x_return_status              out NOCOPY varchar2,
                       x_msg_count                  out NOCOPY number,
                       x_msg_data                   out NOCOPY varchar2,
                       x_object_version          IN OUT NOCOPY NUMBER
                       );

   PROCEDURE Update_Row(
                       X_Contact_Role_Id                NUMBER,
                       X_Last_Update_Date         in out      NOCOPY DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Usage_Code                     VARCHAR2,
                       X_Contact_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Primary_Flag                   VARCHAR2,
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
                       x_org_contact_id                 NUMBER,
                       x_return_status              out NOCOPY varchar2,
                       x_msg_count                  out NOCOPY number,
                       x_msg_data                   out NOCOPY varchar2
                       );


  PROCEDURE Delete_Row(X_contact_role_id   number);

  PROCEDURE delete_row(x_contact_id in number ,x_usage_code in varchar2);

END arh_crol_pkg;

 

/
