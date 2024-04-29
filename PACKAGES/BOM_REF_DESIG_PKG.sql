--------------------------------------------------------
--  DDL for Package BOM_REF_DESIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_REF_DESIG_PKG" AUTHID CURRENT_USER as
/* $Header: bompirds.pls 120.2 2005/10/05 03:23:07 dikrishn ship $ */

  PROCEDURE Check_Unique(X_rowid			VARCHAR2,
			 X_component_sequence_id	NUMBER,
			 X_designator	VARCHAR2);

 PROCEDURE Check_Add (   X_Component_Sequence_Id		NUMBER,
		        X_Old_Component_Sequence_Id	NUMBER,
		        X_Designator			VARCHAR2,
		        X_Change_Notice			VARCHAR2 );

  PROCEDURE Default_Row(X_Total_Records          IN OUT NOCOPY NUMBER,
                        X_Component_Sequence_ID         NUMBER
                      );

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Component_Ref_Desig            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Ref_Designator_Comment         VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
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
                     X_Component_Ref_Desig              VARCHAR2,
                     X_Ref_Designator_Comment           VARCHAR2,
                     X_Change_Notice                    VARCHAR2,
                     X_Component_Sequence_Id            NUMBER,
                     X_Acd_Type                         NUMBER,
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
                       X_Component_Ref_Desig            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Ref_Designator_Comment         VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Component_Sequence_Id          NUMBER,
                       X_Acd_Type                       NUMBER,
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
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END BOM_REF_DESIG_PKG;

 

/
