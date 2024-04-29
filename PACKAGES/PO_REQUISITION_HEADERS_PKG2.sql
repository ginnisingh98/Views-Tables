--------------------------------------------------------
--  DDL for Package PO_REQUISITION_HEADERS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_HEADERS_PKG2" AUTHID CURRENT_USER as
/* $Header: POXRIH3S.pls 120.0.12010000.1 2008/09/18 12:21:04 appldev noship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Requisition_Header_Id          NUMBER,
                       X_Preparer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Authorization_Status           VARCHAR2,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Transferred_To_Oe_Flag         VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_On_Line_Flag                   VARCHAR2,
                       X_Preliminary_Research_Flag      VARCHAR2,
                       X_Research_Complete_Flag         VARCHAR2,
                       X_Preparer_Finished_Flag         VARCHAR2,
                       X_Preparer_Finished_Date         DATE,
                       X_Agent_Return_Flag              VARCHAR2,
                       X_Agent_Return_Note              VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
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
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Interface_Source_Code          VARCHAR2,
                       X_Interface_Source_Line_Id       NUMBER,
                       X_Closed_Code                    VARCHAR2
                      );

END PO_REQUISITION_HEADERS_PKG2;

/
