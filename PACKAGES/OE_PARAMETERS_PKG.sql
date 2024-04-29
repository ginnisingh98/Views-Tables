--------------------------------------------------------
--  DDL for Package OE_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: OEXPARAS.pls 120.1 2005/06/08 03:40:32 appldev  $ */

 -- Pack J
 -- Record Type for oe_sys_parameters_all attributes
  TYPE sys_param_all_rec_type IS RECORD
   (Org_id                  NUMBER
   ,Parameter_Code          VARCHAR2(80)  --<R12.MOAC>
   ,Parameter_Value         VARCHAR2(240)
   ,Creation_Date           DATE
   ,Created_By              NUMBER(15)
   ,Last_Update_Date        DATE
   ,Last_Updated_By         NUMBER(15)
   ,Last_Update_Login       NUMBER(15)
   ,Context                 VARCHAR2(30)
   ,Attribute1              VARCHAR2(240)
   ,Attribute2              VARCHAR2(240)
   ,Attribute3              VARCHAR2(240)
   ,Attribute4              VARCHAR2(240)
   ,Attribute5              VARCHAR2(240)
   ,Attribute6              VARCHAR2(240)
   ,Attribute7              VARCHAR2(240)
   ,Attribute8              VARCHAR2(240)
   ,Attribute9              VARCHAR2(240)
   ,Attribute10             VARCHAR2(240)
   ,Attribute11             VARCHAR2(240)
   ,Attribute12             VARCHAR2(240)
   ,Attribute13             VARCHAR2(240)
   ,Attribute14             VARCHAR2(240)
   ,Attribute15             VARCHAR2(240));

   --- Procedures for oe_sys_parameters_all table
   Procedure Insert_Row(p_sys_param_all_rec IN
			       oe_parameters_pkg.sys_param_all_rec_type,
			x_row_id  OUT NOCOPY VARCHAR2);
   Procedure Lock_Row(p_row_id  IN  VARCHAR2);
   Procedure Update_Row(x_row_id  IN OUT NOCOPY  VARCHAR2,
                        p_sys_param_all_rec IN
			       oe_parameters_pkg.sys_param_all_rec_type);
   --- End

  PROCEDURE Insert_Row(X_Rowid        IN OUT NOCOPY  	VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date             DATE,
                       X_Last_Updated_By                NUMBER  ,
                       X_Creation_Date                  DATE ,
                       X_Created_By                     NUMBER ,
                       X_Last_Update_Login              NUMBER,
                       X_Master_Organization_Id         NUMBER,
		       X_customer_relationships_flag    varchar2,
		       X_Audit_trail_Enable_Flag        varchar2,
                    --MRG BGN
                       X_Compute_Margin_Flag            VARCHAR2,
                    --MRG END
                      --freight rating begin
                       X_Freight_Rating_Enabled_Flag    VARCHAR2,
                       X_Fte_Ship_Method_Enabled_Flag       VARCHAR2,
                       --freight rating end
                       X_Context 		        VARCHAR2,
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
                     X_Organization_Id                  NUMBER,
                     X_Master_Organization_Id           NUMBER,
		     x_customer_relationships_flag      varchar2,
                     X_Audit_trail_Enable_Flag          VARCHAR2,
                  --MRG BGN
                     X_Compute_Margin_Flag              VARCHAR2,
                  --MRG END
                     --freight rating begin
                     X_Freight_Rating_Enabled_Flag      VARCHAR2,
                     X_Fte_Ship_Method_Enabled_Flag         VARCHAR2,
                     --freight rating end
                     X_Context		                VARCHAR2,
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
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Master_Organization_Id         NUMBER,
		       x_customer_relationships_flag    varchar2,
                       X_Audit_trail_Enable_Flag        VARCHAR2,
                     --MRG BGN
                       X_Compute_Margin_Flag            VARCHAR2,
                     --MRG END
                       --freight rating begin
                       X_Freight_Rating_Enabled_Flag    VARCHAR2,
                       X_Fte_Ship_Method_Enabled_Flag   VARCHAR2,
                       --freight rating end
                       X_Context 	                VARCHAR2,
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
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END OE_PARAMETERS_PKG;

 

/
