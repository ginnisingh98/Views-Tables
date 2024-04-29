--------------------------------------------------------
--  DDL for Package Body WIP_INTERFACE_TH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_INTERFACE_TH" AS
/* $Header: wipjsthb.pls 120.1 2005/11/07 11:06:57 sjchen noship $ */

PROCEDURE Update_Row(
X_Rowid VARCHAR2,
X_Group_Id NUMBER,
X_Process_Phase NUMBER,
X_Process_Status NUMBER,
X_Request_Id NUMBER,
X_Source_Code VARCHAR2,
X_Source_Line_Id NUMBER,
X_Load_Type NUMBER,
X_Organization_Code VARCHAR2,
X_Job_Name VARCHAR2,
X_Line_Code VARCHAR2,
X_Start_Quantity NUMBER,
X_Net_Quantity NUMBER,
X_Processing_Work_Days NUMBER,
X_Daily_Production_Rate NUMBER,
X_Class_Code VARCHAR2,
X_Lot_Number VARCHAR2,
X_Schedule_Group_Name VARCHAR2,
X_Build_Sequence NUMBER,
X_Project_Number VARCHAR2,
X_Task_Number VARCHAR2,
X_Status_Type NUMBER,
X_Firm_Planned_Flag NUMBER,
X_Demand_Class VARCHAR2,
X_Scheduling_Method NUMBER,
X_First_Unit_Start_Date DATE,
X_Last_Unit_Start_Date DATE,
X_First_Unit_Completion_Date DATE,
X_Last_Unit_Completion_Date DATE,
X_Alternate_Bom_Designator VARCHAR2,
X_Bom_Revision VARCHAR2,
X_Bom_Revision_Date DATE,
X_Wip_Supply_Type NUMBER,
X_Alternate_Routing_Designator VARCHAR2,
X_Routing_Revision VARCHAR2,
X_Routing_Revision_Date DATE,
X_Completion_Subinventory VARCHAR2,
X_Locator VARCHAR2,
X_Description VARCHAR2,
X_Created_By_Name VARCHAR2,
X_Locator_Id NUMBER,
X_Organization_Id NUMBER,
X_Primary_Item_Id NUMBER,
X_Line_Id NUMBER,
X_Bom_Reference_Id NUMBER,
X_Routing_Reference_Id NUMBER,
X_Schedule_Group_Id NUMBER,
X_Project_Id NUMBER,
X_Task_Id NUMBER,
/*X_Project_Costed NUMBER,*/
X_Last_Update_login NUMBER,
X_Last_Updated_By NUMBER,
X_Last_Update_Date DATE,
X_Created_By NUMBER,
X_Creation_Date DATE,
X_Attribute_Category VARCHAR2,
X_Attribute1 VARCHAR2,
X_Attribute2 VARCHAR2,
X_Attribute3 VARCHAR2,
X_Attribute4 VARCHAR2,
X_Attribute5 VARCHAR2,
X_Attribute6 VARCHAR2,
X_Attribute7 VARCHAR2,
X_Attribute8 VARCHAR2,
X_Attribute9 VARCHAR2,
X_Attribute10 VARCHAR2,
X_Attribute11 VARCHAR2,
X_Attribute12 VARCHAR2,
X_Attribute13 VARCHAR2,
X_Attribute14 VARCHAR2,
X_Attribute15 VARCHAR2
) IS
BEGIN
	UPDATE WIP_JOB_SCHEDULE_INTERFACE SET
	GROUP_ID	=	X_Group_Id,
	PROCESS_PHASE	=	X_Process_Phase,
	PROCESS_STATUS	=	X_Process_Status,
	REQUEST_ID	=	X_Request_Id,
	SOURCE_CODE	=	X_Source_Code,
	SOURCE_LINE_ID	=	X_Source_Line_Id,
	LOAD_TYPE	=	X_Load_Type,
	ORGANIZATION_CODE	=	X_Organization_Code,
	JOB_NAME	=	X_Job_Name,
	LINE_CODE	=	X_Line_Code,
	START_QUANTITY	=	X_Start_Quantity,
	NET_QUANTITY	=	X_Net_Quantity,
	PROCESSING_WORK_DAYS=	X_Processing_Work_Days,
	DAILY_PRODUCTION_RATE=	X_Daily_Production_Rate,
	CLASS_CODE	=	X_Class_Code,
	LOT_NUMBER	=	X_Lot_Number,
	SCHEDULE_GROUP_NAME=	X_Schedule_Group_Name,
	BUILD_SEQUENCE	=	X_Build_Sequence,
	PROJECT_NUMBER	=	X_Project_Number,
	TASK_NUMBER	=	X_Task_Number,
	STATUS_TYPE	=	X_Status_Type,
	FIRM_PLANNED_FLAG=	X_Firm_Planned_Flag,
	DEMAND_CLASS	=	X_Demand_Class,
	SCHEDULING_METHOD=	X_Scheduling_Method,
	FIRST_UNIT_START_DATE=	X_First_Unit_Start_Date,
	LAST_UNIT_START_DATE=	X_Last_Unit_Start_Date,
	FIRST_UNIT_COMPLETION_DATE=	X_First_Unit_Completion_Date,
	LAST_UNIT_COMPLETION_DATE=	X_Last_Unit_Completion_Date,
	ALTERNATE_BOM_DESIGNATOR=	X_Alternate_Bom_Designator,
	BOM_REVISION	=	X_Bom_Revision,
	BOM_REVISION_DATE=	X_Bom_Revision_Date,
	WIP_SUPPLY_TYPE=	X_Wip_Supply_Type,
	ALTERNATE_ROUTING_DESIGNATOR=	X_Alternate_Routing_Designator,
	ROUTING_REVISION=	X_Routing_Revision,
	ROUTING_REVISION_DATE=	X_Routing_Revision_Date,
	COMPLETION_SUBINVENTORY=	X_Completion_Subinventory,
	COMPLETION_LOCATOR_SEGMENTS=	X_Locator,
	DESCRIPTION	 =	X_Description,
	CREATED_BY_NAME=	X_Created_By_Name,
	COMPLETION_LOCATOR_ID=	X_Locator_Id,
	ORGANIZATION_ID=	X_Organization_Id,
	PRIMARY_ITEM_ID=	X_Primary_Item_Id,
	LINE_ID	=	X_Line_Id,
	BOM_REFERENCE_ID	=	X_Bom_Reference_Id,
	ROUTING_REFERENCE_ID	=	X_Routing_Reference_Id,
	SCHEDULE_GROUP_ID	=	X_Schedule_Group_Id,
	PROJECT_ID	=	X_Project_Id,
	TASK_ID		=	X_Task_Id,
	/*PROJECT_COSTED = 	X_Project_Costed,*/
	LAST_UPDATE_LOGIN=	X_Last_Update_login,
	LAST_UPDATED_BY	=	X_Last_Updated_By,
	LAST_UPDATE_DATE=	X_Last_Update_Date,
	CREATED_BY	=	X_Created_By,
	CREATION_DATE	=	X_Creation_Date,
	ATTRIBUTE_CATEGORY =    X_Attribute_Category,
	ATTRIBUTE1	=	X_Attribute1,
	ATTRIBUTE2	=	X_Attribute2,
	ATTRIBUTE3	=	X_Attribute3,
	ATTRIBUTE4	=	X_Attribute4,
	ATTRIBUTE5	=	X_Attribute5,
	ATTRIBUTE6	=	X_Attribute6,
	ATTRIBUTE7	=	X_Attribute7,
	ATTRIBUTE8	=	X_Attribute8,
	ATTRIBUTE9	=	X_Attribute9,
	ATTRIBUTE10	=	X_Attribute10,
	ATTRIBUTE11	=	X_Attribute11,
	ATTRIBUTE12	=	X_Attribute12,
	ATTRIBUTE13	=	X_Attribute13,
	ATTRIBUTE14	=	X_Attribute14,
	ATTRIBUTE15	=	X_Attribute15
	WHERE rowid = X_rowid;

	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

	Delete_Children(X_Rowid);

        /* Fix for Bug#4405954, FP of Bug#4318303 */
        /* Delete records from WIP_JOB_DTLS_INTERFACE table */

        DELETE WIP_JOB_DTLS_INTERFACE WJDI
        WHERE  WJDI.PARENT_HEADER_ID IN
                    (SELECT WJSI.HEADER_ID
                     FROM   WIP_JOB_SCHEDULE_INTERFACE WJSI
                     WHERE  WJSI.rowid = X_Rowid
                    ) ;

	DELETE FROM WIP_JOB_SCHEDULE_INTERFACE
	WHERE rowid = X_Rowid;

	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;

END Delete_Row;

PROCEDURE Delete_Resubmit(X_Rowid VARCHAR2) IS
BEGIN

        Delete_Children(X_Rowid);

	-- Possibly delete ops, reqs, res, instr as well?

END Delete_Resubmit;

PROCEDURE Delete_Children(X_Rowid VARCHAR2) IS
BEGIN
	DELETE FROM WIP_INTERFACE_ERRORS
	WHERE  INTERFACE_ID IN
		(SELECT INTERFACE_ID
		 FROM	WIP_JOB_SCHEDULE_INTERFACE
		 WHERE  ROWID = X_Rowid);

END Delete_Children;

PROCEDURE Lock_Row(
X_Rowid VARCHAR2,
X_Group_Id NUMBER,
X_Process_Phase NUMBER,
X_Process_Status NUMBER,
X_Request_Id NUMBER,
X_Source_Code VARCHAR2,
X_Source_Line_Id NUMBER,
X_Load_Type NUMBER,
X_Organization_Code VARCHAR2,
X_Job_Name VARCHAR2,
X_Line_Code VARCHAR2,
X_Start_Quantity NUMBER,
X_Net_Quantity NUMBER,
X_Processing_Work_Days NUMBER,
X_Daily_Production_Rate NUMBER,
X_Class_Code VARCHAR2,
X_Lot_Number VARCHAR2,
X_Schedule_Group_Name VARCHAR2,
X_Build_Sequence NUMBER,
X_Project_Number VARCHAR2,
X_Task_Number VARCHAR2,
X_Status_Type NUMBER,
X_Firm_Planned_Flag NUMBER,
X_Demand_Class VARCHAR2,
X_Scheduling_Method NUMBER,
X_First_Unit_Start_Date DATE,
X_Last_Unit_Start_Date DATE,
X_First_Unit_Completion_Date DATE,
X_Last_Unit_Completion_Date DATE,
X_Alternate_Bom_Designator VARCHAR2,
X_Bom_Revision VARCHAR2,
X_Bom_Revision_Date DATE,
X_Wip_Supply_Type NUMBER,
X_Alternate_Routing_Designator VARCHAR2,
X_Routing_Revision VARCHAR2,
X_Routing_Revision_Date DATE,
X_Completion_Subinventory VARCHAR2,
X_Locator VARCHAR2,
X_Description VARCHAR2,
X_Created_By_Name VARCHAR2,
X_Locator_Id NUMBER,
X_Organization_Id NUMBER,
X_Primary_Item_Id NUMBER,
X_Line_Id NUMBER,
X_Bom_Reference_Id NUMBER,
X_Routing_Reference_Id NUMBER,
X_Schedule_Group_Id NUMBER,
X_Project_Id NUMBER,
X_Task_Id NUMBER,
/*X_Project_Costed NUMBER,*/
X_Last_Update_login NUMBER,
X_Last_Updated_By NUMBER,
X_Last_Update_Date DATE,
X_Created_By NUMBER,
X_Creation_Date DATE,
X_Attribute_Category VARCHAR2,
X_Attribute1 VARCHAR2,
X_Attribute2 VARCHAR2,
X_Attribute3 VARCHAR2,
X_Attribute4 VARCHAR2,
X_Attribute5 VARCHAR2,
X_Attribute6 VARCHAR2,
X_Attribute7 VARCHAR2,
X_Attribute8 VARCHAR2,
X_Attribute9 VARCHAR2,
X_Attribute10 VARCHAR2,
X_Attribute11 VARCHAR2,
X_Attribute12 VARCHAR2,
X_Attribute13 VARCHAR2,
X_Attribute14 VARCHAR2,
X_Attribute15 VARCHAR2
) IS
CURSOR C IS
SELECT
	GROUP_ID
,	PROCESS_PHASE
,	PROCESS_STATUS
,	REQUEST_ID
,	SOURCE_CODE
,	SOURCE_LINE_ID
,	LOAD_TYPE
,	ORGANIZATION_CODE
,	JOB_NAME
,	LINE_CODE
,	START_QUANTITY
,	NET_QUANTITY
,	PROCESSING_WORK_DAYS
,	DAILY_PRODUCTION_RATE
,	CLASS_CODE
,	LOT_NUMBER
,	SCHEDULE_GROUP_NAME
,	BUILD_SEQUENCE
,	PROJECT_NUMBER
,	TASK_NUMBER
,	STATUS_TYPE
,	FIRM_PLANNED_FLAG
,	DEMAND_CLASS
,	SCHEDULING_METHOD
,	FIRST_UNIT_START_DATE
,	LAST_UNIT_START_DATE
,	FIRST_UNIT_COMPLETION_DATE
,	LAST_UNIT_COMPLETION_DATE
,	ALTERNATE_BOM_DESIGNATOR
,	BOM_REVISION
,	BOM_REVISION_DATE
,	WIP_SUPPLY_TYPE
,	ALTERNATE_ROUTING_DESIGNATOR
,	ROUTING_REVISION
,	ROUTING_REVISION_DATE
,	COMPLETION_SUBINVENTORY
,	COMPLETION_LOCATOR_SEGMENTS
,	DESCRIPTION
,	CREATED_BY_NAME
,	COMPLETION_LOCATOR_ID
,	ORGANIZATION_ID
,	PRIMARY_ITEM_ID
,	LINE_ID
,	BOM_REFERENCE_ID
,	ROUTING_REFERENCE_ID
,	SCHEDULE_GROUP_ID
,	PROJECT_ID
,	TASK_ID
/*,	PROJECT_COSTED*/
,	LAST_UPDATE_LOGIN
,	LAST_UPDATED_BY
,	LAST_UPDATE_DATE
,	CREATED_BY
,	CREATION_DATE
,	ATTRIBUTE_CATEGORY
,	ATTRIBUTE1
,	ATTRIBUTE2
,	ATTRIBUTE3
,	ATTRIBUTE4
,	ATTRIBUTE5
,	ATTRIBUTE6
,	ATTRIBUTE7
,	ATTRIBUTE8
,	ATTRIBUTE9
,	ATTRIBUTE10
,	ATTRIBUTE11
,	ATTRIBUTE12
,	ATTRIBUTE13
,	ATTRIBUTE14
,	ATTRIBUTE15
	FROM WIP_JOB_SCHEDULE_INTERFACE
	WHERE rowid = X_rowid
	FOR UPDATE of Interface_Id NOWAIT;
Recinfo C%ROWTYPE;
BEGIN
	OPEN C;
	FETCH C INTO RECINFO;
	IF C%NOTFOUND THEN
		CLOSE C;
		FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE C;

	IF ((RECINFO.GROUP_ID = X_Group_Id) OR
	   (RECINFO.GROUP_ID IS NULL AND  X_Group_Id IS NULL)) AND
	   ((RECINFO.PROCESS_PHASE = X_Process_Phase) OR
	   (RECINFO.PROCESS_PHASE IS NULL AND X_Process_Phase IS NULL)) AND
	   ((RECINFO.PROCESS_STATUS = X_Process_Status) OR
	   (RECINFO.PROCESS_STATUS IS NULL AND X_Process_Status IS NULL)) AND
	   ((RECINFO.REQUEST_ID = X_Request_Id) OR
	   (RECINFO.REQUEST_ID IS NULL AND X_Request_Id IS NULL)) AND
	   ((RECINFO.SOURCE_CODE = X_Source_Code) OR
	   (RECINFO.SOURCE_CODE IS NULL AND X_Source_Code IS NULL)) AND
	   ((RECINFO.SOURCE_LINE_ID = X_Source_Line_Id) OR
	   (RECINFO.SOURCE_LINE_ID IS NULL AND X_Source_Line_Id IS NULL)) AND
	   ((RECINFO.LOAD_TYPE = X_Load_Type) OR
	   (RECINFO.LOAD_TYPE IS NULL AND X_Load_Type IS NULL)) AND
	   ((RECINFO.START_QUANTITY = X_Start_Quantity) OR
	   (RECINFO.START_QUANTITY IS NULL AND X_Start_Quantity IS NULL)) AND
	   ((RECINFO.NET_QUANTITY = X_Net_Quantity) OR
	   (RECINFO.NET_QUANTITY IS NULL AND X_Net_Quantity IS NULL)) AND
	   ((RECINFO.PROCESSING_WORK_DAYS = X_Processing_Work_Days) OR
	   (RECINFO.PROCESSING_WORK_DAYS IS NULL AND X_Processing_Work_Days IS NULL)) AND
	   ((RECINFO.DAILY_PRODUCTION_RATE = X_Daily_Production_Rate) OR
	   (RECINFO.DAILY_PRODUCTION_RATE IS NULL AND X_Daily_Production_Rate IS NULL)) AND
	   ((RECINFO.CLASS_CODE = X_Class_Code) OR
	   (RECINFO.CLASS_CODE IS NULL AND X_Class_Code IS NULL)) AND
	   ((RECINFO.LOT_NUMBER = X_Lot_Number) OR
	   (RECINFO.LOT_NUMBER IS NULL AND X_Lot_Number IS NULL)) AND
	   ((RECINFO.BUILD_SEQUENCE = X_Build_Sequence) OR
	   (RECINFO.BUILD_SEQUENCE IS NULL AND X_Build_Sequence IS NULL)) AND
	   ((RECINFO.STATUS_TYPE = X_Status_Type) OR
	   (RECINFO.STATUS_TYPE IS NULL AND X_Status_Type IS NULL)) AND
	   ((RECINFO.FIRM_PLANNED_FLAG = X_Firm_Planned_Flag) OR
	   (RECINFO.FIRM_PLANNED_FLAG IS NULL AND X_Firm_Planned_Flag IS NULL)) AND
	   ((RECINFO.DEMAND_CLASS = X_Demand_Class) OR
	   (RECINFO.DEMAND_CLASS IS NULL AND X_Demand_Class IS NULL)) AND
	   ((RECINFO.SCHEDULING_METHOD = X_Scheduling_Method) OR
	   (RECINFO.SCHEDULING_METHOD IS NULL AND X_Scheduling_Method IS NULL)) AND
	   ((RECINFO.FIRST_UNIT_START_DATE = X_First_Unit_Start_Date) OR
	   (RECINFO.FIRST_UNIT_START_DATE IS NULL AND X_First_Unit_Start_Date IS NULL)) AND
	   ((RECINFO.LAST_UNIT_START_DATE = X_Last_Unit_Start_Date) OR
	   (RECINFO.LAST_UNIT_START_DATE IS NULL AND X_Last_Unit_Start_Date IS NULL)) AND
	   ((RECINFO.FIRST_UNIT_COMPLETION_DATE = X_First_Unit_Completion_Date) OR
	   (RECINFO.FIRST_UNIT_COMPLETION_DATE IS NULL AND X_First_Unit_Completion_Date IS NULL)) AND
	   ((RECINFO.LAST_UNIT_COMPLETION_DATE = X_Last_Unit_Completion_Date) OR
	   (RECINFO.LAST_UNIT_COMPLETION_DATE IS NULL AND X_Last_Unit_Completion_Date IS NULL)) AND
	   ((RECINFO.ALTERNATE_BOM_DESIGNATOR = X_Alternate_Bom_Designator) OR
	   (RECINFO.ALTERNATE_BOM_DESIGNATOR IS NULL AND X_Alternate_Bom_Designator IS NULL)) AND
	   ((RECINFO.BOM_REVISION = X_Bom_Revision) OR
	   (RECINFO.BOM_REVISION IS NULL AND X_Bom_Revision IS NULL)) AND
	   ((RECINFO.BOM_REVISION_DATE = X_Bom_Revision_Date) OR
	   (RECINFO.BOM_REVISION_DATE IS NULL AND X_Bom_Revision_Date IS NULL)) AND
	   ((RECINFO.WIP_SUPPLY_TYPE = X_Wip_Supply_Type) OR
	   (RECINFO.WIP_SUPPLY_TYPE IS NULL AND X_Wip_Supply_Type IS NULL)) AND
	   ((RECINFO.ALTERNATE_ROUTING_DESIGNATOR = X_Alternate_Routing_Designator) OR
	   (RECINFO.ALTERNATE_ROUTING_DESIGNATOR IS NULL AND X_Alternate_Routing_Designator IS NULL)) AND
	   ((RECINFO.ROUTING_REVISION = X_Routing_Revision) OR
	   (RECINFO.ROUTING_REVISION IS NULL AND X_Routing_Revision IS NULL)) AND
	   ((RECINFO.ROUTING_REVISION_DATE = X_Routing_Revision_Date) OR
	   (RECINFO.ROUTING_REVISION_DATE IS NULL AND X_Routing_Revision_Date IS NULL)) AND
	   ((RECINFO.COMPLETION_SUBINVENTORY = X_Completion_Subinventory) OR
	   (RECINFO.COMPLETION_SUBINVENTORY IS NULL AND X_Completion_Subinventory IS NULL)) AND
	   ((RECINFO.DESCRIPTION = X_Description) OR
	   (RECINFO.DESCRIPTION IS NULL AND X_Description IS NULL)) AND
	   ((RECINFO.COMPLETION_LOCATOR_ID = X_Locator_Id) OR
	   (RECINFO.COMPLETION_LOCATOR_ID IS NULL AND X_Locator_Id IS NULL)) AND
	   ((RECINFO.ORGANIZATION_ID = X_Organization_Id) OR
	   (RECINFO.ORGANIZATION_ID IS NULL AND X_Organization_Id IS NULL))
THEN IF
	   ((RECINFO.PRIMARY_ITEM_ID = X_Primary_Item_Id) OR
	   (RECINFO.PRIMARY_ITEM_ID IS NULL AND X_Primary_Item_Id IS NULL)) AND
	   ((RECINFO.LINE_ID = X_Line_Id) OR
	   (RECINFO.LINE_ID IS NULL AND X_Line_Id IS NULL)) AND
	   ((RECINFO.BOM_REFERENCE_ID = X_Bom_Reference_Id) OR
	   (RECINFO.BOM_REFERENCE_ID IS NULL AND X_Bom_Reference_Id IS NULL)) AND
	   ((RECINFO.ROUTING_REFERENCE_ID = X_Routing_Reference_Id) OR
	   (RECINFO.ROUTING_REFERENCE_ID IS NULL AND X_Routing_Reference_Id IS NULL)) AND
	   ((RECINFO.SCHEDULE_GROUP_ID = X_Schedule_Group_Id) OR
	   (RECINFO.SCHEDULE_GROUP_ID IS NULL AND X_Schedule_Group_Id IS NULL)) AND
	   ((RECINFO.PROJECT_ID = X_Project_Id) OR
	   (RECINFO.PROJECT_ID IS NULL AND X_Project_Id IS NULL)) AND
	   ((RECINFO.TASK_ID = X_Task_Id) OR
	   (RECINFO.TASK_ID IS NULL AND X_Task_Id IS NULL)) AND
	   /*((RECINFO.PROJECT_COSTED = X_Project_Costed) OR
	   (RECINFO.PROJECT_COSTED IS NULL AND X_Project_Costed IS NULL)) AND*/
	   ((RECINFO.LAST_UPDATE_LOGIN = X_Last_Update_Login) OR
	   (RECINFO.LAST_UPDATE_LOGIN IS NULL AND X_Last_Update_Login IS NULL)) AND
	   ((RECINFO.LAST_UPDATED_BY = X_Last_Updated_By) OR
	   (RECINFO.LAST_UPDATED_BY IS NULL AND X_Last_Updated_By IS NULL)) AND
	   ((RECINFO.LAST_UPDATE_DATE = X_Last_Update_Date) OR
	   (RECINFO.LAST_UPDATE_DATE IS NULL AND X_Last_Update_Date IS NULL)) AND
	   ((RECINFO.ATTRIBUTE_CATEGORY = X_Attribute_Category) OR
	   (RECINFO.ATTRIBUTE_CATEGORY IS NULL AND X_Attribute_Category IS NULL))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
	   AND ((RECINFO.CREATED_BY = X_Created_By) OR
	   (RECINFO.CREATED_BY IS NULL AND X_Created_By IS NULL)) AND
	   ((RECINFO.CREATION_DATE = X_Creation_Date) OR
	   (RECINFO.CREATION_DATE IS NULL AND X_Creation_Date IS NULL))
		THEN
		RETURN;

	ELSE
		FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
	ELSE
		FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;

END Lock_Row;

END WIP_INTERFACE_TH;

/
