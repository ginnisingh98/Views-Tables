--------------------------------------------------------
--  DDL for Package BOM_BILL_OF_MATLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BILL_OF_MATLS_PKG" AUTHID CURRENT_USER as
/* $Header: bompibms.pls 120.1 2005/06/21 03:23:10 appldev ship $ */

PROCEDURE Populate_Fields(
  P_Bill_Sequence_Id in number,
  P_Item_Seq_Increment in number,
  P_Current_Rev in out nocopy varchar2,
  P_Base_Model in out NOCOPY varchar2,
  P_Base_Model_Desc in out NOCOPY varchar2,
  P_Common_Item in out NOCOPY varchar2,
  P_Common_Description in out NOCOPY varchar2,
  P_Item_Num_Default in out NOCOPY number,
  P_Common_Org_Code in out NOCOPY varchar2,
  P_Common_Org_Name in out NOCOPY varchar2);

  PROCEDURE Check_Unique(X_Rowid			VARCHAR2,
			 X_Assembly_Item_Id		NUMBER,
			 X_Alternate_Bom_Designator	VARCHAR2,
			 X_Organization_Id		NUMBER);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Assembly_Item_Id               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Common_Assembly_Item_Id        NUMBER,
                       X_Specific_Assembly_Comment      VARCHAR2,
                       X_Pending_From_Ecn               VARCHAR2,
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
                       X_Assembly_Type                  NUMBER,
                       X_Common_Bill_Sequence_Id        IN OUT NOCOPY NUMBER,
                       X_Bill_Sequence_Id               IN OUT NOCOPY NUMBER,
                       X_Common_Organization_Id         NUMBER,
                       X_Next_Explode_Date              DATE,
		       X_structure_type_id		NUMBER := NULL,
		       X_implementation_date		DATE   := NULL,
		       X_effectivity_control            NUMBER := NULL
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Assembly_Item_Id                 NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Alternate_Bom_Designator         VARCHAR2,
                     X_Common_Assembly_Item_Id          NUMBER,
                     X_Specific_Assembly_Comment        VARCHAR2,
                     X_Pending_From_Ecn                 VARCHAR2,
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
                     X_Assembly_Type                    NUMBER,
                     X_Common_Bill_Sequence_Id          NUMBER,
                     X_Bill_Sequence_Id                 NUMBER,
                     X_Common_Organization_Id           NUMBER,
                     X_Next_Explode_Date                DATE,
		     X_structure_type_id		NUMBER := NULL,
		     X_implementation_date		DATE   := NULL
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Assembly_Item_Id               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Common_Assembly_Item_Id        NUMBER,
                       X_Specific_Assembly_Comment      VARCHAR2,
                       X_Pending_From_Ecn               VARCHAR2,
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
                       X_Assembly_Type                  NUMBER,
                       X_Common_Bill_Sequence_Id IN OUT NOCOPY NUMBER,
                       X_Bill_Sequence_Id               NUMBER,
                       X_Common_Organization_Id         NUMBER,
                       X_Next_Explode_Date              DATE,
		       X_structure_type_id		NUMBER := NULL,
		       X_implementation_date		DATE   := NULL,
		       X_effectivity_control            NUMBER := NULL
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END BOM_BILL_OF_MATLS_PKG;

 

/
