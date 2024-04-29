--------------------------------------------------------
--  DDL for Package MTL_STATUS_ATTRIB_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_STATUS_ATTRIB_VAL_PKG" AUTHID CURRENT_USER as
/* $Header: INVSDOSS.pls 120.0 2005/05/25 05:29:38 appldev noship $ */



  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Inventory_Item_Status_Code       VARCHAR2,
                     X_Attribute_Name                   VARCHAR2,
                     X_Attribute_Value                  VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Inventory_Item_Status_Code     VARCHAR2,
                       X_Status_Code_Ndb                NUMBER,
                       X_Attribute_Name                 VARCHAR2,
                       X_Attribute_Value                VARCHAR2,
                       X_Old_Attribute_Value            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE  Populate_Tab (status_code IN VARCHAR2 );

END MTL_STATUS_ATTRIB_VAL_PKG;

 

/
