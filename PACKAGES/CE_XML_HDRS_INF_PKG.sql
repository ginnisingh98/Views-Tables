--------------------------------------------------------
--  DDL for Package CE_XML_HDRS_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_XML_HDRS_INF_PKG" AUTHID CURRENT_USER as
/* $Header: cexmlhis.pls 120.1 2005/09/20 06:04:33 svali noship $ */

  G_spec_revision	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE Ifx_Row(   X_Statement_Number               VARCHAR2,
                       X_Bank_Branch_Name      IN OUT  NOCOPY VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Date                 DATE,
                       X_Check_Digits                   VARCHAR2,
                       X_Control_Begin_Balance          NUMBER,
                       X_Control_End_Balance            NUMBER,
                       X_Control_Total_Dr               NUMBER,
                       X_Control_Total_Cr               NUMBER,
                       X_Control_Dr_Line_Count          NUMBER,
                       X_Control_Cr_Line_Count          NUMBER,
                       X_Control_Line_Count             NUMBER,
                       X_Record_Status_Flag             VARCHAR2,
                       X_Currency_Code         IN OUT  NOCOPY  VARCHAR2,
                       X_Created_By            IN OUT  NOCOPY  NUMBER,
                       X_Creation_Date         IN OUT  NOCOPY  DATE,
                       X_Last_Updated_By       IN OUT  NOCOPY  NUMBER,
                       X_Last_Update_Date      IN OUT  NOCOPY DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Org_Id                IN OUT NOCOPY NUMBER,
                       X_Bank_Name             IN OUT NOCOPY  VARCHAR2,
		       X_Int_Calc_Balance		NUMBER,
		       X_Cashflow_Balance		NUMBER);

END CE_XML_HDRS_INF_PKG;

 

/
