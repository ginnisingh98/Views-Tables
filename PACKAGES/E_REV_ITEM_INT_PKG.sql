--------------------------------------------------------
--  DDL for Package E_REV_ITEM_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."E_REV_ITEM_INT_PKG" AUTHID CURRENT_USER as
/* $Header: bompiris.pls 120.1 2005/06/21 03:24:59 appldev ship $ */

  PROCEDURE After_Delete(X_revised_item_sequence_id	NUMBER);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Scheduled_Date                 DATE,
                       X_Mrp_Active                     NUMBER,
                       X_Update_Wip                     NUMBER,
                       X_Use_Up                         NUMBER,
                       X_Use_Up_Item_Id                 NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Category_Set_Id                NUMBER,
                       X_Structure_Id                   NUMBER,
                       X_Item_From                      VARCHAR2,
                       X_Item_To                        VARCHAR2,
                       X_Category_From                  VARCHAR2,
                       X_Category_To                    VARCHAR2,
                       X_Increment_Rev                  NUMBER,
                       X_Item_Type                      VARCHAR2,
                       X_Use_Up_Plan_Name               VARCHAR2,
                       X_Alternate_Selection_Code       NUMBER,
                       X_Base_Item_Id                   NUMBER,
		       X_Submit_Request                 BOOLEAN,
  		       X_model_item_access              NUMBER,
		       X_planning_item_access           NUMBER,
  		       X_std_item_access                NUMBER,
                       X_impl_code                      NUMBER,
		       X_report_code                    NUMBER,
		       X_delete_code                    NUMBER,
		       X_From_End_Item_Unit_Number      VARCHAR2,
		       X_req_id                     IN OUT NOCOPY NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Change_Notice                    VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Scheduled_Date                   DATE,
                     X_Mrp_Active                       NUMBER,
                     X_Update_Wip                       NUMBER,
                     X_Use_Up                           NUMBER,
                     X_Use_Up_Item_Id                   NUMBER,
                     X_Revised_Item_Sequence_Id         NUMBER,
                     X_Alternate_Bom_Designator         VARCHAR2,
                     X_Category_Set_Id                  NUMBER,
                     X_Structure_Id                     NUMBER,
                     X_Item_From                        VARCHAR2,
                     X_Item_To                          VARCHAR2,
                     X_Category_From                    VARCHAR2,
                     X_Category_To                      VARCHAR2,
                     X_Increment_Rev                    NUMBER,
                     X_Item_Type                        VARCHAR2,
                     X_Use_Up_Plan_Name                 VARCHAR2,
                     X_Alternate_Selection_Code         NUMBER,
                     X_Base_Item_Id                     NUMBER,
		     X_From_End_Item_Unit_Number        VARCHAR2
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Change_Notice                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Scheduled_Date                 DATE,
                       X_Mrp_Active                     NUMBER,
                       X_Update_Wip                     NUMBER,
                       X_Use_Up                         NUMBER,
                       X_Use_Up_Item_Id                 NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Category_Set_Id                NUMBER,
                       X_Structure_Id                   NUMBER,
                       X_Item_From                      VARCHAR2,
                       X_Item_To                        VARCHAR2,
                       X_Category_From                  VARCHAR2,
                       X_Category_To                    VARCHAR2,
                       X_Increment_Rev                  NUMBER,
                       X_Item_Type                      VARCHAR2,
                       X_Use_Up_Plan_Name               VARCHAR2,
                       X_Alternate_Selection_Code       NUMBER,
                       X_Base_Item_Id                   NUMBER,
		       X_Submit_Request                 BOOLEAN,
  		       X_model_item_access              NUMBER,
		       X_planning_item_access           NUMBER,
  		       X_std_item_access                NUMBER,
                       X_impl_code                      NUMBER,
		       X_report_code                    NUMBER,
		       X_delete_code                    NUMBER,
		       X_From_End_Item_Unit_Number      VARCHAR2,
		       X_req_id                     IN OUT NOCOPY NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  /* ERES
  Need to declare this proc in the spec in order that it can be
  invoked directly from the client code in an eSignature scenario
  ==============================================================*/
  PROCEDURE Call_Mass_Change (X_change_notice in varchar2,
                              X_org_id        in NUMBER,
                              X_model_item_access in NUMBER,
                              X_planning_item_access in NUMBER,
                              X_std_item_access in NUMBER,
                              X_impl_code in NUMBER,
                              X_report_code in NUMBER,
                              X_delete_code in NUMBER,
                              X_req_id IN OUT NOCOPY NUMBER
                              );

END E_REV_ITEM_INT_PKG;

 

/
