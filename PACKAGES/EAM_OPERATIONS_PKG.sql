--------------------------------------------------------
--  DDL for Package EAM_OPERATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OPERATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: EAMOPTHS.pls 120.0 2005/05/25 15:59:39 appldev noship $ */

/************************************************
 * Default Values:				*
 * Many columns are not used in EAM. As we 	*
 * decided, we put the pre-determined default 	*
 * value into them. 				*
 * These are just indicative values. Actual	*
 * default values are in procedure spec.	*
 ************************************************/
Default_Repetitive_Schedule_Id	NUMBER := null;  -- Not Used.
Default_Scheduled_Quantity	NUMBER := 1; -- Not Used
Default_Qty_In_Queue	NUMBER := 0; -- Not Used
Default_Qty_Running	NUMBER := 0; -- Not Used
Default_Qty_Waiting_To_Move	NUMBER := 0; -- Not Used
Default_Qty_Rejected	NUMBER := 0; -- Not Used
Default_Qty_Scrapped	NUMBER := 0; -- Not Used
Default_Qty_Completed	NUMBER := 0; -- For Creating a new one
Default_Prev_Operation_Seq_Num	NUMBER := NULL; -- Not Used
Default_Next_Operation_Seq_Num	NUMBER := NULL; -- Not Used
Default_Count_Point_Type	NUMBER := 2; -- No - Autocgarge....Change made to incorporate direct items
Default_Backflush_Flag		NUMBER := 2; -- No ???
Default_Minimum_Transfer_Qty	NUMBER := 0; -- Not Used
Default_Date_Last_Moved		DATE := null; -- Not Used

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER	default null,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
		       X_Shutdown_Type			VARCHAR2,
		       X_Operation_Completed		VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Scheduled_Quantity             NUMBER	default 1,
                       X_Quantity_In_Queue              NUMBER	default 0,
                       X_Quantity_Running               NUMBER	default 0,
                       X_Quantity_Waiting_To_Move       NUMBER	default 0,
                       X_Quantity_Rejected              NUMBER	default 0,
                       X_Quantity_Scrapped              NUMBER	default 0,
                       X_Quantity_Completed             NUMBER	default 0,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Previous_Operation_Seq_Num     NUMBER	default null,
                       X_Next_Operation_Seq_Num         NUMBER	default null,
                       X_Count_Point_Type               NUMBER	default 1,
                       X_Backflush_Flag                 NUMBER	default 2,
                       X_Minimum_Transfer_Quantity      NUMBER	default 0,
                       X_Date_Last_Moved                DATE	default null,
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
		       X_X_Pos				NUMBER,
		       X_Y_Pos				NUMBER,
	   	       X_LONG_DESCRIPTION               VARCHAR2 default null,
     		       X_L_EAM_OP_REC	OUT NOCOPY	EAM_PROCESS_WO_PUB.eam_op_rec_type,
		       X_WO_Start_Date OUT NOCOPY DATE,
		       X_WO_Completion_Date OUT NOCOPY DATE
);


  PROCEDURE Update_Row(X_Rowid                   	VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
		       X_Shutdown_Type			VARCHAR2,
		       X_Operation_Completed		VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
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
		       X_X_Pos				NUMBER,
		       X_Y_Pos				NUMBER,
		       X_LONG_DESCRIPTION               VARCHAR2 default null,
	     	       X_L_EAM_OP_REC	  OUT NOCOPY	EAM_PROCESS_WO_PUB.eam_op_rec_type,
		       X_WO_Start_Date OUT NOCOPY DATE,
		       X_WO_Completion_Date OUT NOCOPY DATE
		);


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Operation_Seq_Num                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Operation_Sequence_Id            NUMBER,
                     X_Standard_Operation_Id            NUMBER,
                     X_Department_Id                    NUMBER,
		     X_Shutdown_Type			VARCHAR2,
		     X_Operation_Completed		VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_First_Unit_Start_Date            DATE,
                     X_First_Unit_Completion_Date       DATE,
                     X_Last_Unit_Start_Date             DATE,
                     X_Last_Unit_Completion_Date        DATE,
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
		     X_X_Pos				NUMBER,
		     X_Y_Pos				NUMBER,
		     X_LONG_DESCRIPTION               VARCHAR2 default null
                    );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
		       X_WO_Start_Date OUT NOCOPY DATE,
		       X_WO_Completion_Date OUT NOCOPY DATE);

END EAM_OPERATIONS_PKG;

 

/
