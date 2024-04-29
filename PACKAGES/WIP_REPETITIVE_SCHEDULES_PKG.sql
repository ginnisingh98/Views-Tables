--------------------------------------------------------
--  DDL for Package WIP_REPETITIVE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REPETITIVE_SCHEDULES_PKG" AUTHID CURRENT_USER as
/* $Header: wiprsvhs.pls 115.7 2002/11/29 15:32:42 rmahidha ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Line_Id                        NUMBER,
                       X_Daily_Production_Rate          NUMBER,
                       X_Processing_Work_Days           NUMBER,
                       X_Status_Type                    NUMBER,
                       X_Firm_Planned_Flag              NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Common_Bom_Sequence_Id         NUMBER,
                       X_Bom_Revision                   VARCHAR2,
                       X_Bom_Revision_Date              DATE,
                       X_Alternate_Routing_Designator   VARCHAR2,
                       X_Common_Routing_Sequence_Id     NUMBER,
                       X_Routing_Revision               VARCHAR2,
                       X_Routing_Revision_Date          DATE,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Date_Released                  DATE,
                       X_Date_Closed                    DATE,
                       X_Quantity_Completed             NUMBER,
                       X_Description                    VARCHAR2,
                       X_Demand_Class                   VARCHAR2,
                       X_Material_Account               NUMBER,
                       X_Material_Overhead_Account      NUMBER,
                       X_Resource_Account               NUMBER,
                       X_Overhead_Account               NUMBER,
                       X_Outside_Processing_Account     NUMBER,
                       X_Material_Variance_Account      NUMBER,
                       X_Overhead_Variance_Account      NUMBER,
                       X_Resource_Variance_Account      NUMBER,
                       X_O_Proc_Variance_Account   NUMBER,
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
		       X_PO_Creation_Time		NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Repetitive_Schedule_Id           NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Daily_Production_Rate            NUMBER,
                     X_Processing_Work_Days             NUMBER,
                     X_Status_Type                      NUMBER,
                     X_Firm_Planned_Flag                NUMBER,
                     X_Common_Bom_Sequence_Id           NUMBER,
                     X_Bom_Revision                     VARCHAR2,
                     X_Bom_Revision_Date                DATE,
                     X_Common_Routing_Sequence_Id       NUMBER,
                     X_Routing_Revision                 VARCHAR2,
                     X_Routing_Revision_Date            DATE,
                     X_First_Unit_Start_Date            DATE,
                     X_First_Unit_Completion_Date       DATE,
                     X_Last_Unit_Start_Date             DATE,
                     X_Last_Unit_Completion_Date        DATE,
                     X_Date_Released                    DATE,
                     X_Date_Closed                      DATE,
                     X_Description                      VARCHAR2,
                     X_Demand_Class                     VARCHAR2,
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
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Line_Id                        NUMBER,
                       X_Daily_Production_Rate          NUMBER,
                       X_Processing_Work_Days           NUMBER,
                       X_Status_Type                    NUMBER,
                       X_Firm_Planned_Flag              NUMBER,
                       X_Alternate_Bom_Designator       VARCHAR2,
                       X_Common_Bom_Sequence_Id         NUMBER,
                       X_Bom_Revision                   VARCHAR2,
                       X_Bom_Revision_Date              DATE,
                       X_Alternate_Routing_Designator   VARCHAR2,
                       X_Common_Routing_Sequence_Id     NUMBER,
                       X_Routing_Revision               VARCHAR2,
                       X_Routing_Revision_Date          DATE,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Date_Released                  DATE,
                       X_Date_Closed                    DATE,
                       X_Description                    VARCHAR2,
                       X_Demand_Class                   VARCHAR2,
                       X_Material_Account               NUMBER,
                       X_Material_Overhead_Account      NUMBER,
                       X_Resource_Account               NUMBER,
                       X_Overhead_Account               NUMBER,
                       X_Outside_Processing_Account     NUMBER,
                       X_Material_Variance_Account      NUMBER,
                       X_Overhead_Variance_Account      NUMBER,
                       X_Resource_Variance_Account      NUMBER,
                       X_O_Proc_Variance_Account  NUMBER,
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

END WIP_REPETITIVE_SCHEDULES_PKG;

 

/