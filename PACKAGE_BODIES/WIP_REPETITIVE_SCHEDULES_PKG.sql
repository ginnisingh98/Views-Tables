--------------------------------------------------------
--  DDL for Package Body WIP_REPETITIVE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REPETITIVE_SCHEDULES_PKG" as
/* $Header: wiprsvhb.pls 115.7 2002/11/29 15:32:54 rmahidha ship $ */

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
                       X_O_Proc_Variance_Account   	NUMBER,
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
  ) IS
    CURSOR C IS SELECT rowid FROM WIP_REPETITIVE_SCHEDULES
                 WHERE repetitive_schedule_id = X_Repetitive_Schedule_Id;

   BEGIN


       INSERT INTO WIP_REPETITIVE_SCHEDULES(
              repetitive_schedule_id,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              wip_entity_id,
              line_id,
              daily_production_rate,
              processing_work_days,
              status_type,
              firm_planned_flag,
              alternate_bom_designator,
              common_bom_sequence_id,
              bom_revision,
              bom_revision_date,
              alternate_routing_designator,
              common_routing_sequence_id,
              routing_revision,
              routing_revision_date,
              first_unit_start_date,
              first_unit_completion_date,
              last_unit_start_date,
              last_unit_completion_date,
              date_released,
              date_closed,
              quantity_completed,
              description,
              demand_class,
              material_account,
              material_overhead_account,
              resource_account,
              overhead_account,
              outside_processing_account,
              material_variance_account,
              overhead_variance_account,
              resource_variance_account,
              outside_proc_variance_account,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
	      po_creation_time
             ) VALUES (

              X_Repetitive_Schedule_Id,
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Wip_Entity_Id,
              X_Line_Id,
              X_Daily_Production_Rate,
              X_Processing_Work_Days,
              X_Status_Type,
              X_Firm_Planned_Flag,
              X_Alternate_Bom_Designator,
              X_Common_Bom_Sequence_Id,
              X_Bom_Revision,
              X_Bom_Revision_Date,
              X_Alternate_Routing_Designator,
              X_Common_Routing_Sequence_Id,
              X_Routing_Revision,
              X_Routing_Revision_Date,
              X_First_Unit_Start_Date,
              X_First_Unit_Completion_Date,
              X_Last_Unit_Start_Date,
              X_Last_Unit_Completion_Date,
              X_Date_Released,
              X_Date_Closed,
              X_Quantity_Completed,
              X_Description,
              X_Demand_Class,
              X_Material_Account,
              X_Material_Overhead_Account,
              X_Resource_Account,
              X_Overhead_Account,
              X_Outside_Processing_Account,
              X_Material_Variance_Account,
              X_Overhead_Variance_Account,
              X_Resource_Variance_Account,
              X_O_Proc_Variance_Account,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
	      X_PO_Creation_Time
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


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
  ) IS
    CURSOR C IS
        SELECT *
        FROM   WIP_REPETITIVE_SCHEDULES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Repetitive_Schedule_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if ( (Recinfo.repetitive_schedule_id =  X_Repetitive_Schedule_Id)
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (Recinfo.daily_production_rate =  X_Daily_Production_Rate)
           AND (Recinfo.processing_work_days =  X_Processing_Work_Days)
           AND (Recinfo.status_type =  X_Status_Type)
           AND (Recinfo.firm_planned_flag =  X_Firm_Planned_Flag)
           AND (   (Recinfo.common_bom_sequence_id =  X_Common_Bom_Sequence_Id)
                OR (    (Recinfo.common_bom_sequence_id IS NULL)
                    AND (X_Common_Bom_Sequence_Id IS NULL)))
           AND (   (Recinfo.bom_revision =  X_Bom_Revision)
                OR (    (Recinfo.bom_revision IS NULL)
                    AND (X_Bom_Revision IS NULL)))
           AND (   (Recinfo.bom_revision_date =  X_Bom_Revision_Date)
                OR (    (Recinfo.bom_revision_date IS NULL)
                    AND (X_Bom_Revision_Date IS NULL)))
           AND (   (Recinfo.common_routing_sequence_id =  X_Common_Routing_Sequence_Id)
                OR (    (Recinfo.common_routing_sequence_id IS NULL)
                    AND (X_Common_Routing_Sequence_Id IS NULL)))
           AND (   (Recinfo.routing_revision =  X_Routing_Revision)
                OR (    (Recinfo.routing_revision IS NULL)
                    AND (X_Routing_Revision IS NULL)))
           AND (   (Recinfo.routing_revision_date =  X_Routing_Revision_Date)
                OR (    (Recinfo.routing_revision_date IS NULL)
                    AND (X_Routing_Revision_Date IS NULL)))
           AND (Recinfo.first_unit_start_date =  X_First_Unit_Start_Date)
           AND (Recinfo.first_unit_completion_date =  X_First_Unit_Completion_Date)
           AND (Recinfo.last_unit_start_date =  X_Last_Unit_Start_Date)
           AND (Recinfo.last_unit_completion_date =  X_Last_Unit_Completion_Date)
           AND (   (Recinfo.date_released =  X_Date_Released)
                OR (    (Recinfo.date_released IS NULL)
                    AND (X_Date_Released IS NULL)))
           AND (   (Recinfo.date_closed =  X_Date_Closed)
                OR (    (Recinfo.date_closed IS NULL)
                    AND (X_Date_Closed IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.demand_class =  X_Demand_Class)
                OR (    (Recinfo.demand_class IS NULL)
                    AND (X_Demand_Class IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



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

  ) IS
  BEGIN
    UPDATE WIP_REPETITIVE_SCHEDULES
    SET
       repetitive_schedule_id          =     X_Repetitive_Schedule_Id,
       organization_id                 =     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       wip_entity_id                   =     X_Wip_Entity_Id,
       line_id                         =     X_Line_Id,
       daily_production_rate           =     X_Daily_Production_Rate,
       processing_work_days            =     X_Processing_Work_Days,
       status_type                     =     X_Status_Type,
       firm_planned_flag               =     X_Firm_Planned_Flag,
       alternate_bom_designator        =     X_Alternate_Bom_Designator,
       common_bom_sequence_id          =     X_Common_Bom_Sequence_Id,
       bom_revision                    =     X_Bom_Revision,
       bom_revision_date               =     X_Bom_Revision_Date,
       alternate_routing_designator    =     X_Alternate_Routing_Designator,
       common_routing_sequence_id      =     X_Common_Routing_Sequence_Id,
       routing_revision                =     X_Routing_Revision,
       routing_revision_date           =     X_Routing_Revision_Date,
       first_unit_start_date           =     X_First_Unit_Start_Date,
       first_unit_completion_date      =     X_First_Unit_Completion_Date,
       last_unit_start_date            =     X_Last_Unit_Start_Date,
       last_unit_completion_date       =     X_Last_Unit_Completion_Date,
       date_released                   =     X_Date_Released,
       date_closed                     =     X_Date_Closed,
       description                     =     X_Description,
       demand_class                    =     X_Demand_Class,
       material_account                =     X_Material_Account,
       material_overhead_account       =     X_Material_Overhead_Account,
       resource_account                =     X_Resource_Account,
       overhead_account                =     X_Overhead_Account,
       outside_processing_account      =     X_Outside_Processing_Account,
       material_variance_account       =     X_Material_Variance_Account,
       overhead_variance_account       =     X_Overhead_Variance_Account,
       resource_variance_account       =     X_Resource_Variance_Account,
       outside_proc_variance_account   =     X_O_Proc_Variance_Account,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM WIP_REPETITIVE_SCHEDULES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END WIP_REPETITIVE_SCHEDULES_PKG;

/
