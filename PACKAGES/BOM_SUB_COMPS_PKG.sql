--------------------------------------------------------
--  DDL for Package BOM_SUB_COMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_SUB_COMPS_PKG" AUTHID CURRENT_USER as
/* $Header: bompiscs.pls 120.1 2005/06/21 03:25:38 appldev ship $ */

  PROCEDURE Get_Uom(X_uom_code			   IN OUT NOCOPY VARCHAR2,
		    X_sub_comp_id		       NUMBER,
		    X_org_id			       NUMBER);

  PROCEDURE Check_Unique(X_acd_type		   	NUMBER,
		         X_sub_comp_id		   	NUMBER,
		         X_comp_seq_id		   	NUMBER,
			 X_row_id			VARCHAR2);

  PROCEDURE Check_Commons(X_bill_seq_id			NUMBER,
		          X_org_id	       		NUMBER,
		          X_sub_comp_id			NUMBER);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Substitute_Component_Id        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Change_Notice                  VARCHAR2,
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
		       X_Enforce_Int_Requirements       NUMBER DEFAULT NULL
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Substitute_Component_Id          NUMBER,
                     X_Substitute_Item_Quantity         NUMBER,
                     X_Component_Sequence_Id            NUMBER,
                     X_Acd_Type                         NUMBER,
                     X_Change_Notice                    VARCHAR2,
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
		     X_Enforce_Int_Requirements         NUMBER DEFAULT NULL
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Substitute_Component_Id        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Substitute_Item_Quantity       NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Change_Notice                  VARCHAR2,
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
		       X_Enforce_Int_Requirements       NUMBER DEFAULT NULL
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END BOM_SUB_COMPS_PKG;

 

/
