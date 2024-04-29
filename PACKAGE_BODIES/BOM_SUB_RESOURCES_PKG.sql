--------------------------------------------------------
--  DDL for Package Body BOM_SUB_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SUB_RESOURCES_PKG" as
/* $Header: BOMSRESB.pls 120.2.12000000.2 2007/10/17 13:47:02 jiabraha ship $ */

PROCEDURE Insert_Row(
                    x_OPERATION_SEQUENCE_ID        NUMBER,
                    x_SUBSTITUTE_GROUP_NUM         NUMBER,
                    x_RESOURCE_ID                  NUMBER,
                    x_SCHEDULE_SEQ_NUM             NUMBER,
                    x_REPLACEMENT_GROUP_NUM        NUMBER,
                    x_ACTIVITY_ID                  NUMBER,
                    x_STANDARD_RATE_FLAG           NUMBER,
                    x_ASSIGNED_UNITS               NUMBER,
                    x_USAGE_RATE_OR_AMOUNT         NUMBER,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE NUMBER,
                    x_BASIS_TYPE                   NUMBER,
                    x_SCHEDULE_FLAG                NUMBER,
                    x_LAST_UPDATE_DATE             DATE,
                    x_LAST_UPDATED_BY              NUMBER,
                    x_CREATION_DATE                DATE,
                    x_CREATED_BY                   NUMBER,
                    x_LAST_UPDATE_LOGIN            NUMBER,
                    x_RESOURCE_OFFSET_PERCENT      NUMBER,
                    x_AUTOCHARGE_TYPE              NUMBER,
                    x_PRINCIPLE_FLAG               NUMBER,
                    x_ATTRIBUTE_CATEGORY           VARCHAR2,
                    x_ATTRIBUTE1                   VARCHAR2,
                    x_ATTRIBUTE2                   VARCHAR2,
                    x_ATTRIBUTE3                   VARCHAR2,
                    x_ATTRIBUTE4                   VARCHAR2,
                    x_ATTRIBUTE5                   VARCHAR2,
                    x_ATTRIBUTE6                   VARCHAR2,
                    x_ATTRIBUTE7                   VARCHAR2,
                    x_ATTRIBUTE8                   VARCHAR2,
                    x_ATTRIBUTE9                   VARCHAR2,
                    x_ATTRIBUTE10                  VARCHAR2,
                    x_ATTRIBUTE11                  VARCHAR2,
                    x_ATTRIBUTE12                  VARCHAR2,
                    x_ATTRIBUTE13                  VARCHAR2,
                    x_ATTRIBUTE14                  VARCHAR2,
                    x_ATTRIBUTE15                  VARCHAR2)
 IS
   BEGIN
   INSERT INTO BOM_SUB_OPERATION_RESOURCES(
                 OPERATION_SEQUENCE_ID,
                 SUBSTITUTE_GROUP_NUM,
                 RESOURCE_ID,
                 SCHEDULE_SEQ_NUM,
                 REPLACEMENT_GROUP_NUM,
                 ACTIVITY_ID,
                 STANDARD_RATE_FLAG,
                 ASSIGNED_UNITS,
                 USAGE_RATE_OR_AMOUNT,
                 USAGE_RATE_OR_AMOUNT_INVERSE,
                 BASIS_TYPE,
                 SCHEDULE_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 RESOURCE_OFFSET_PERCENT,
                 AUTOCHARGE_TYPE,
                 PRINCIPLE_FLAG,
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
                 attribute15)
              values  (
                    x_OPERATION_SEQUENCE_ID,
                    x_SUBSTITUTE_GROUP_NUM,
                    x_RESOURCE_ID,
                    x_SCHEDULE_SEQ_NUM,
                    x_REPLACEMENT_GROUP_NUM,
                    x_ACTIVITY_ID,
                    x_STANDARD_RATE_FLAG,
                    x_ASSIGNED_UNITS,
                    x_USAGE_RATE_OR_AMOUNT,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE,
                    x_BASIS_TYPE,
                    x_SCHEDULE_FLAG,
                    x_LAST_UPDATE_DATE,
                    x_LAST_UPDATED_BY,
                    x_CREATION_DATE,
                    x_CREATED_BY,
                    x_LAST_UPDATE_LOGIN,
                    x_RESOURCE_OFFSET_PERCENT,
                    x_AUTOCHARGE_TYPE,
                    x_PRINCIPLE_FLAG,
                    x_ATTRIBUTE_CATEGORY,
                    x_ATTRIBUTE1,
                    x_ATTRIBUTE2,
                    x_ATTRIBUTE3,
                    x_ATTRIBUTE4,
                    x_ATTRIBUTE5,
                    x_ATTRIBUTE6,
                    x_ATTRIBUTE7,
                    x_ATTRIBUTE8,
                    x_ATTRIBUTE9,
                    x_ATTRIBUTE10,
                    x_ATTRIBUTE11,
                    x_ATTRIBUTE12,
                    x_ATTRIBUTE13,
                    x_ATTRIBUTE14,
                    x_ATTRIBUTE15
                  );

  END INSERT_ROW;

PROCEDURE Insert_Row(
                    x_OPERATION_SEQUENCE_ID        NUMBER,
                    x_SUBSTITUTE_GROUP_NUM         NUMBER,
                    x_RESOURCE_ID                  NUMBER,
                    x_SCHEDULE_SEQ_NUM             NUMBER,
                    x_REPLACEMENT_GROUP_NUM        NUMBER,
                    x_ACTIVITY_ID                  NUMBER,
                    x_STANDARD_RATE_FLAG           NUMBER,
                    x_ASSIGNED_UNITS               NUMBER,
                    x_USAGE_RATE_OR_AMOUNT         NUMBER,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE NUMBER,
                    x_BASIS_TYPE                   NUMBER,
                    x_SCHEDULE_FLAG                NUMBER,
                    x_LAST_UPDATE_DATE             DATE,
                    x_LAST_UPDATED_BY              NUMBER,
                    x_CREATION_DATE                DATE,
                    x_CREATED_BY                   NUMBER,
                    x_LAST_UPDATE_LOGIN            NUMBER,
                    x_RESOURCE_OFFSET_PERCENT      NUMBER,
                    x_AUTOCHARGE_TYPE              NUMBER,
                    x_PRINCIPLE_FLAG               NUMBER,
                    x_ATTRIBUTE_CATEGORY           VARCHAR2,
                    x_ATTRIBUTE1                   VARCHAR2,
                    x_ATTRIBUTE2                   VARCHAR2,
                    x_ATTRIBUTE3                   VARCHAR2,
                    x_ATTRIBUTE4                   VARCHAR2,
                    x_ATTRIBUTE5                   VARCHAR2,
                    x_ATTRIBUTE6                   VARCHAR2,
                    x_ATTRIBUTE7                   VARCHAR2,
                    x_ATTRIBUTE8                   VARCHAR2,
                    x_ATTRIBUTE9                   VARCHAR2,
                    x_ATTRIBUTE10                  VARCHAR2,
                    x_ATTRIBUTE11                  VARCHAR2,
                    x_ATTRIBUTE12                  VARCHAR2,
                    x_ATTRIBUTE13                  VARCHAR2,
                    x_ATTRIBUTE14                  VARCHAR2,
                    x_ATTRIBUTE15                  VARCHAR2,
                    x_SETUP_ID                     NUMBER)
 IS
   BEGIN
   INSERT INTO BOM_SUB_OPERATION_RESOURCES(
                 OPERATION_SEQUENCE_ID,
                 SUBSTITUTE_GROUP_NUM,
                 RESOURCE_ID,
                 SCHEDULE_SEQ_NUM,
                 REPLACEMENT_GROUP_NUM,
                 ACTIVITY_ID,
                 STANDARD_RATE_FLAG,
                 ASSIGNED_UNITS,
                 USAGE_RATE_OR_AMOUNT,
                 USAGE_RATE_OR_AMOUNT_INVERSE,
                 BASIS_TYPE,
                 SCHEDULE_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 RESOURCE_OFFSET_PERCENT,
                 AUTOCHARGE_TYPE,
                 PRINCIPLE_FLAG,
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
                 setup_id)
              values  (
                    x_OPERATION_SEQUENCE_ID,
                    x_SUBSTITUTE_GROUP_NUM,
                    x_RESOURCE_ID,
                    x_SCHEDULE_SEQ_NUM,
                    x_REPLACEMENT_GROUP_NUM,
                    x_ACTIVITY_ID,
                    x_STANDARD_RATE_FLAG,
                    x_ASSIGNED_UNITS,
                    x_USAGE_RATE_OR_AMOUNT,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE,
                    x_BASIS_TYPE,
                    x_SCHEDULE_FLAG,
                    x_LAST_UPDATE_DATE,
                    x_LAST_UPDATED_BY,
                    x_CREATION_DATE,
                    x_CREATED_BY,
                    x_LAST_UPDATE_LOGIN,
                    x_RESOURCE_OFFSET_PERCENT,
                    x_AUTOCHARGE_TYPE,
                    x_PRINCIPLE_FLAG,
                    x_ATTRIBUTE_CATEGORY,
                    x_ATTRIBUTE1,
                    x_ATTRIBUTE2,
                    x_ATTRIBUTE3,
                    x_ATTRIBUTE4,
                    x_ATTRIBUTE5,
                    x_ATTRIBUTE6,
                    x_ATTRIBUTE7,
                    x_ATTRIBUTE8,
                    x_ATTRIBUTE9,
                    x_ATTRIBUTE10,
                    x_ATTRIBUTE11,
                    x_ATTRIBUTE12,
                    x_ATTRIBUTE13,
                    x_ATTRIBUTE14,
                    x_ATTRIBUTE15,
                    x_SETUP_ID
                  );

  END INSERT_ROW;

PROCEDURE Lock_Row( x_ROW_ID                      VARCHAR2,
                    x_OPERATION_SEQUENCE_ID        NUMBER,
                    x_SUBSTITUTE_GROUP_NUM         NUMBER,
                    x_RESOURCE_ID                  NUMBER,
                    x_SCHEDULE_SEQ_NUM             NUMBER,
                    x_REPLACEMENT_GROUP_NUM        NUMBER,
                    x_ACTIVITY_ID                  NUMBER,
                    x_STANDARD_RATE_FLAG           NUMBER,
                    x_ASSIGNED_UNITS               NUMBER,
                    x_USAGE_RATE_OR_AMOUNT         NUMBER,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE NUMBER,
                    x_BASIS_TYPE                   NUMBER,
                    x_SCHEDULE_FLAG                NUMBER,
                    x_RESOURCE_OFFSET_PERCENT      NUMBER,
                    x_AUTOCHARGE_TYPE              NUMBER,
                    x_PRINCIPLE_FLAG               NUMBER,
                    x_ATTRIBUTE_CATEGORY           VARCHAR2,
                    x_ATTRIBUTE1                   VARCHAR2,
                    x_ATTRIBUTE2                   VARCHAR2,
                    x_ATTRIBUTE3                   VARCHAR2,
                    x_ATTRIBUTE4                   VARCHAR2,
                    x_ATTRIBUTE5                   VARCHAR2,
                    x_ATTRIBUTE6                   VARCHAR2,
                    x_ATTRIBUTE7                   VARCHAR2,
                    x_ATTRIBUTE8                   VARCHAR2,
                    x_ATTRIBUTE9                   VARCHAR2,
                    x_ATTRIBUTE10                  VARCHAR2,
                    x_ATTRIBUTE11                  VARCHAR2,
                    x_ATTRIBUTE12                  VARCHAR2,
                    x_ATTRIBUTE13                  VARCHAR2,
                    x_ATTRIBUTE14                  VARCHAR2,
                    x_ATTRIBUTE15                  VARCHAR2
         ) IS
  Counter NUMBER;
  CURSOR C IS SELECT
              operation_sequence_id,
              substitute_group_num,
              resource_id,
	      schedule_seq_num,
	      replacement_group_num,
              activity_id,
              standard_rate_flag,
              assigned_units,
              usage_rate_or_amount,
              usage_rate_or_amount_inverse,
              basis_type,
              schedule_flag,
              resource_offset_percent,
	      NVL(principle_flag, 2) principle_flag,
              autocharge_type,
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
              attribute15
        FROM  BOM_SUB_OPERATION_RESOURCES
        WHERE rowid = x_row_id
        FOR UPDATE of  operation_sequence_id, substitute_group_num, resource_id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  Counter := 0;
  LOOP
    BEGIN
      Counter := Counter + 1;
      OPEN C;
      FETCH C INTO Recinfo;
      IF (C%NOTFOUND) THEN
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
      END IF;
      CLOSE C;
      IF ((Recinfo.operation_sequence_id = x_Operation_Sequence_Id)
           AND (Recinfo.substitute_group_num = x_substitute_group_Num)
           AND (Recinfo.resource_id = x_Resource_Id)
           AND (Recinfo.schedule_seq_num = x_schedule_seq_num)
           AND (Recinfo.Replacement_group_num = x_replacement_group_num)
           AND ((Recinfo.activity_id = x_Activity_Id)
                OR ((Recinfo.activity_id IS NULL)
                    AND (x_Activity_Id IS NULL)))
           AND (Recinfo.standard_rate_flag = x_Standard_Rate_Flag)
           AND (Recinfo.assigned_units = x_Assigned_Units)
           AND (Recinfo.usage_rate_or_amount = x_Usage_Rate_Or_Amount)
           AND (Recinfo.usage_rate_or_amount_inverse = x_Usage_Rate_Or_Amount_Inverse)
           AND (Recinfo.basis_type = x_Basis_Type)
           AND (Recinfo.schedule_flag = x_Schedule_Flag)
           AND ((Recinfo.resource_offset_percent =  x_Resource_Offset_Percent)
                OR ((Recinfo.resource_offset_percent IS NULL)
                    AND (x_Resource_Offset_Percent IS NULL)))
           AND (Recinfo.autocharge_type = x_Autocharge_Type)
           AND ((Recinfo.principle_flag =  x_Principle_Flag)
                OR ((Recinfo.principle_flag IS NULL)
                    AND (x_Principle_Flag IS NULL)))
           AND ((Recinfo.attribute_category = x_Attribute_Category)
                OR ((Recinfo.attribute_category IS NULL)
                     AND (x_Attribute_Category IS NULL)))
           AND ((Recinfo.attribute1 = x_Attribute1)
                OR ((Recinfo.attribute1 IS NULL)
                    AND (x_Attribute1 IS NULL)))
           AND ((Recinfo.attribute2 = x_Attribute2)
                OR ((Recinfo.attribute2 IS NULL)
                    AND (x_Attribute2 IS NULL)))
           AND ((Recinfo.attribute3 = x_Attribute3)
                OR ((Recinfo.attribute3 IS NULL)
                    AND (x_Attribute3 IS NULL)))
           AND ((Recinfo.attribute4 = x_Attribute4)
                OR ((Recinfo.attribute4 IS NULL)
                    AND (x_Attribute4 IS NULL)))
           AND ((Recinfo.attribute5 = x_Attribute5)
                OR ((Recinfo.attribute5 IS NULL)
                    AND (x_Attribute5 IS NULL)))
           AND ((Recinfo.attribute6 = x_Attribute6)
                OR ((Recinfo.attribute6 IS NULL)
                    AND (x_Attribute6 IS NULL)))
           AND ((Recinfo.attribute7 = x_Attribute7)
                OR ((Recinfo.attribute7 IS NULL)
                    AND (x_Attribute7 IS NULL)))
           AND ((Recinfo.attribute8 = x_Attribute8)
                OR ((Recinfo.attribute8 IS NULL)
                    AND (x_Attribute8 IS NULL)))
           AND ((Recinfo.attribute9 = x_Attribute9)
                OR ((Recinfo.attribute9 IS NULL)
                    AND (x_Attribute9 IS NULL)))
           AND ((Recinfo.attribute10 = x_Attribute10)
                OR ((Recinfo.attribute10 IS NULL)
                    AND (x_Attribute10 IS NULL)))
           AND ((Recinfo.attribute11 = x_Attribute11)
                OR ((Recinfo.attribute11 IS NULL)
                    AND (x_Attribute11 IS NULL)))
           AND ((Recinfo.attribute12 = x_Attribute12)
                OR ((Recinfo.attribute12 IS NULL)
                    AND (x_Attribute12 IS NULL)))
           AND ((Recinfo.attribute13 = x_Attribute13)
                OR ((Recinfo.attribute13 IS NULL)
                    AND (x_Attribute13 IS NULL)))
           AND ((Recinfo.attribute14 = x_Attribute14)
                OR ((Recinfo.attribute14 IS NULL)
                    AND (x_Attribute14 IS NULL)))
           AND ((Recinfo.attribute15 = x_Attribute15)
                OR ((Recinfo.attribute15 IS NULL)
                    AND (x_Attribute15 IS NULL)))
      ) THEN
        return;
      ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
      END IF;
    EXCEPTION
      When APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        APP_EXCEPTION.Raise_Exception;
    END;
  END LOOP;
 END Lock_Row;

PROCEDURE Lock_Row( x_ROW_ID                      VARCHAR2,
                    x_OPERATION_SEQUENCE_ID        NUMBER,
                    x_SUBSTITUTE_GROUP_NUM         NUMBER,
                    x_RESOURCE_ID                  NUMBER,
                    x_SCHEDULE_SEQ_NUM             NUMBER,
                    x_REPLACEMENT_GROUP_NUM        NUMBER,
                    x_ACTIVITY_ID                  NUMBER,
                    x_STANDARD_RATE_FLAG           NUMBER,
                    x_ASSIGNED_UNITS               NUMBER,
                    x_USAGE_RATE_OR_AMOUNT         NUMBER,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE NUMBER,
                    x_BASIS_TYPE                   NUMBER,
                    x_SCHEDULE_FLAG                NUMBER,
                    x_RESOURCE_OFFSET_PERCENT      NUMBER,
                    x_AUTOCHARGE_TYPE              NUMBER,
                    x_PRINCIPLE_FLAG               NUMBER,
                    x_ATTRIBUTE_CATEGORY           VARCHAR2,
                    x_ATTRIBUTE1                   VARCHAR2,
                    x_ATTRIBUTE2                   VARCHAR2,
                    x_ATTRIBUTE3                   VARCHAR2,
                    x_ATTRIBUTE4                   VARCHAR2,
                    x_ATTRIBUTE5                   VARCHAR2,
                    x_ATTRIBUTE6                   VARCHAR2,
                    x_ATTRIBUTE7                   VARCHAR2,
                    x_ATTRIBUTE8                   VARCHAR2,
                    x_ATTRIBUTE9                   VARCHAR2,
                    x_ATTRIBUTE10                  VARCHAR2,
                    x_ATTRIBUTE11                  VARCHAR2,
                    x_ATTRIBUTE12                  VARCHAR2,
                    x_ATTRIBUTE13                  VARCHAR2,
                    x_ATTRIBUTE14                  VARCHAR2,
                    x_ATTRIBUTE15                  VARCHAR2,
                    x_SETUP_ID                     NUMBER
         ) IS
  Counter NUMBER;
  CURSOR C IS SELECT
              operation_sequence_id,
              substitute_group_num,
              resource_id,
	      schedule_seq_num,
	      replacement_group_num,
              activity_id,
              standard_rate_flag,
              assigned_units,
              usage_rate_or_amount,
              usage_rate_or_amount_inverse,
              basis_type,
              schedule_flag,
              resource_offset_percent,
	      NVL(principle_flag, 2) principle_flag,
              autocharge_type,
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
              setup_id
        FROM  BOM_SUB_OPERATION_RESOURCES
        WHERE rowid = x_row_id
        FOR UPDATE of  operation_sequence_id, substitute_group_num, resource_id, replacement_group_num NOWAIT; --for bug 3287004
  Recinfo C%ROWTYPE;
BEGIN
  Counter := 0;
  LOOP
    BEGIN
      Counter := Counter + 1;
      OPEN C;
      FETCH C INTO Recinfo;
      IF (C%NOTFOUND) THEN
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
      END IF;
      CLOSE C;
      IF ((Recinfo.operation_sequence_id = x_Operation_Sequence_Id)
           AND (Recinfo.substitute_group_num = x_substitute_group_Num)
           AND (Recinfo.resource_id = x_Resource_Id)
           AND ((Recinfo.schedule_seq_num = x_schedule_seq_num) --for bug 3287004
                OR ((Recinfo.schedule_seq_num IS NULL)
                    AND (x_schedule_seq_num IS NULL)))
           AND (Recinfo.Replacement_group_num = x_replacement_group_num)
           AND ((Recinfo.activity_id = x_Activity_Id)
                OR ((Recinfo.activity_id IS NULL)
                    AND (x_Activity_Id IS NULL)))
           AND (Recinfo.standard_rate_flag = x_Standard_Rate_Flag)
           AND (Recinfo.assigned_units = x_Assigned_Units)
           AND (Recinfo.usage_rate_or_amount = x_Usage_Rate_Or_Amount)
           AND (Recinfo.usage_rate_or_amount_inverse = x_Usage_Rate_Or_Amount_Inverse)
           AND (Recinfo.basis_type = x_Basis_Type)
           AND (Recinfo.schedule_flag = x_Schedule_Flag)
           AND ((Recinfo.resource_offset_percent =  x_Resource_Offset_Percent)
                OR ((Recinfo.resource_offset_percent IS NULL)
                    AND (x_Resource_Offset_Percent IS NULL)))
           AND (Recinfo.autocharge_type = x_Autocharge_Type)
           AND ((Recinfo.principle_flag =  x_Principle_Flag)
                OR ((Recinfo.principle_flag IS NULL)
                    AND (x_Principle_Flag IS NULL)))
           AND ((Recinfo.attribute_category = x_Attribute_Category)
                OR ((Recinfo.attribute_category IS NULL)
                     AND (x_Attribute_Category IS NULL)))
           AND ((Recinfo.attribute1 = x_Attribute1)
                OR ((Recinfo.attribute1 IS NULL)
                    AND (x_Attribute1 IS NULL)))
           AND ((Recinfo.attribute2 = x_Attribute2)
                OR ((Recinfo.attribute2 IS NULL)
                    AND (x_Attribute2 IS NULL)))
           AND ((Recinfo.attribute3 = x_Attribute3)
                OR ((Recinfo.attribute3 IS NULL)
                    AND (x_Attribute3 IS NULL)))
           AND ((Recinfo.attribute4 = x_Attribute4)
                OR ((Recinfo.attribute4 IS NULL)
                    AND (x_Attribute4 IS NULL)))
           AND ((Recinfo.attribute5 = x_Attribute5)
                OR ((Recinfo.attribute5 IS NULL)
                    AND (x_Attribute5 IS NULL)))
           AND ((Recinfo.attribute6 = x_Attribute6)
                OR ((Recinfo.attribute6 IS NULL)
                    AND (x_Attribute6 IS NULL)))
           AND ((Recinfo.attribute7 = x_Attribute7)
                OR ((Recinfo.attribute7 IS NULL)
                    AND (x_Attribute7 IS NULL)))
           AND ((Recinfo.attribute8 = x_Attribute8)
                OR ((Recinfo.attribute8 IS NULL)
                    AND (x_Attribute8 IS NULL)))
           AND ((Recinfo.attribute9 = x_Attribute9)
                OR ((Recinfo.attribute9 IS NULL)
                    AND (x_Attribute9 IS NULL)))
           AND ((Recinfo.attribute10 = x_Attribute10)
                OR ((Recinfo.attribute10 IS NULL)
                    AND (x_Attribute10 IS NULL)))
           AND ((Recinfo.attribute11 = x_Attribute11)
                OR ((Recinfo.attribute11 IS NULL)
                    AND (x_Attribute11 IS NULL)))
           AND ((Recinfo.attribute12 = x_Attribute12)
                OR ((Recinfo.attribute12 IS NULL)
                    AND (x_Attribute12 IS NULL)))
           AND ((Recinfo.attribute13 = x_Attribute13)
                OR ((Recinfo.attribute13 IS NULL)
                    AND (x_Attribute13 IS NULL)))
           AND ((Recinfo.attribute14 = x_Attribute14)
                OR ((Recinfo.attribute14 IS NULL)
                    AND (x_Attribute14 IS NULL)))
           AND ((Recinfo.attribute15 = x_Attribute15)
                OR ((Recinfo.attribute15 IS NULL)
                    AND (x_Attribute15 IS NULL)))
           AND ((Recinfo.setup_id = x_Setup_Id)
                OR ((Recinfo.setup_id IS NULL)
                    AND (x_Setup_Id IS NULL)))
      ) THEN
        return;
      ELSE
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
      END IF;
    EXCEPTION
      When APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        APP_EXCEPTION.Raise_Exception;
    END;
  END LOOP;
 END Lock_Row;

PROCEDURE Update_Row(x_ROW_ID                      VARCHAR2,
                    x_OPERATION_SEQUENCE_ID        NUMBER,
                    x_SUBSTITUTE_GROUP_NUM         NUMBER,
                    x_RESOURCE_ID                  NUMBER,
                    x_SCHEDULE_SEQ_NUM           NUMBER,
                    x_REPLACEMENT_GROUP_NUM        NUMBER,
                    x_ACTIVITY_ID                  NUMBER,
                    x_STANDARD_RATE_FLAG           NUMBER,
                    x_ASSIGNED_UNITS               NUMBER,
                    x_USAGE_RATE_OR_AMOUNT         NUMBER,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE NUMBER,
                    x_BASIS_TYPE                   NUMBER,
                    x_SCHEDULE_FLAG                NUMBER,
                    x_LAST_UPDATE_DATE             DATE,
                    x_LAST_UPDATED_BY              NUMBER,
                    x_CREATION_DATE                DATE,
                    x_CREATED_BY                   NUMBER,
                    x_LAST_UPDATE_LOGIN            NUMBER,
                    x_RESOURCE_OFFSET_PERCENT      NUMBER,
                    x_AUTOCHARGE_TYPE              NUMBER,
                    x_PRINCIPLE_FLAG               NUMBER,
                    x_ATTRIBUTE_CATEGORY           VARCHAR2,
                    x_ATTRIBUTE1                   VARCHAR2,
                    x_ATTRIBUTE2                   VARCHAR2,
                    x_ATTRIBUTE3                   VARCHAR2,
                    x_ATTRIBUTE4                   VARCHAR2,
                    x_ATTRIBUTE5                   VARCHAR2,
                    x_ATTRIBUTE6                   VARCHAR2,
                    x_ATTRIBUTE7                   VARCHAR2,
                    x_ATTRIBUTE8                   VARCHAR2,
                    x_ATTRIBUTE9                   VARCHAR2,
                    x_ATTRIBUTE10                  VARCHAR2,
                    x_ATTRIBUTE11                  VARCHAR2,
                    x_ATTRIBUTE12                  VARCHAR2,
                    x_ATTRIBUTE13                  VARCHAR2,
                    x_ATTRIBUTE14                  VARCHAR2,
                    x_ATTRIBUTE15                  VARCHAR2)
 IS
BEGIN
   UPDATE BOM_SUB_OPERATION_RESOURCES SET
                 OPERATION_SEQUENCE_ID        =   x_OPERATION_SEQUENCE_ID,
                 SUBSTITUTE_GROUP_NUM         =   x_SUBSTITUTE_GROUP_NUM,
                 RESOURCE_ID                  =   x_RESOURCE_ID,
                 SCHEDULE_SEQ_NUM             =   x_SCHEDULE_SEQ_NUM,
                 REPLACEMENT_GROUP_NUM        =   x_REPLACEMENT_GROUP_NUM ,
                 ACTIVITY_ID                  =   x_ACTIVITY_ID,
                 STANDARD_RATE_FLAG           =   x_STANDARD_RATE_FLAG,
                 ASSIGNED_UNITS               =   x_ASSIGNED_UNITS,
                 USAGE_RATE_OR_AMOUNT         =   x_USAGE_RATE_OR_AMOUNT,
                 USAGE_RATE_OR_AMOUNT_INVERSE =   x_USAGE_RATE_OR_AMOUNT_INVERSE,
                 BASIS_TYPE                   =   x_BASIS_TYPE,
                 SCHEDULE_FLAG                =   x_SCHEDULE_FLAG,
                 LAST_UPDATE_DATE             =   x_LAST_UPDATE_DATE,
                 LAST_UPDATED_BY              =   x_LAST_UPDATED_BY,
                 CREATION_DATE                =   x_CREATION_DATE,
                 CREATED_BY                   =   x_CREATED_BY,
                 LAST_UPDATE_LOGIN            =   x_LAST_UPDATE_LOGIN,
                 RESOURCE_OFFSET_PERCENT      =   x_RESOURCE_OFFSET_PERCENT,
                 AUTOCHARGE_TYPE              =   x_AUTOCHARGE_TYPE,
                 PRINCIPLE_FLAG               =   x_PRINCIPLE_FLAG,
                 attribute_category           =   x_attribute_category,
                 attribute1                   =   x_attribute1,
                 attribute2                   =   x_attribute2,
                 attribute3                   =   x_attribute3,
                 attribute4                   =   x_attribute4,
                 attribute5                   =   x_attribute5,
                 attribute6                   =   x_attribute6,
                 attribute7                   =   x_attribute7,
                 attribute8                   =   x_attribute8,
                 attribute9                   =   x_attribute9,
                 attribute10                  =   x_attribute10,
                 attribute11                  =   x_attribute11,
                 attribute12                  =   x_attribute12,
                 attribute13                  =   x_attribute13,
                 attribute14                  =   x_attribute14,
                 attribute15                  =   x_attribute15
  WHERE rowid = x_row_id;
  IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;

END;

PROCEDURE Update_Row(x_ROW_ID                      VARCHAR2,
                    x_OPERATION_SEQUENCE_ID        NUMBER,
                    x_SUBSTITUTE_GROUP_NUM         NUMBER,
                    x_RESOURCE_ID                  NUMBER,
                    x_SCHEDULE_SEQ_NUM           NUMBER,
                    x_REPLACEMENT_GROUP_NUM        NUMBER,
                    x_ACTIVITY_ID                  NUMBER,
                    x_STANDARD_RATE_FLAG           NUMBER,
                    x_ASSIGNED_UNITS               NUMBER,
                    x_USAGE_RATE_OR_AMOUNT         NUMBER,
                    x_USAGE_RATE_OR_AMOUNT_INVERSE NUMBER,
                    x_BASIS_TYPE                   NUMBER,
                    x_SCHEDULE_FLAG                NUMBER,
                    x_LAST_UPDATE_DATE             DATE,
                    x_LAST_UPDATED_BY              NUMBER,
                    x_CREATION_DATE                DATE,
                    x_CREATED_BY                   NUMBER,
                    x_LAST_UPDATE_LOGIN            NUMBER,
                    x_RESOURCE_OFFSET_PERCENT      NUMBER,
                    x_AUTOCHARGE_TYPE              NUMBER,
                    x_PRINCIPLE_FLAG               NUMBER,
                    x_ATTRIBUTE_CATEGORY           VARCHAR2,
                    x_ATTRIBUTE1                   VARCHAR2,
                    x_ATTRIBUTE2                   VARCHAR2,
                    x_ATTRIBUTE3                   VARCHAR2,
                    x_ATTRIBUTE4                   VARCHAR2,
                    x_ATTRIBUTE5                   VARCHAR2,
                    x_ATTRIBUTE6                   VARCHAR2,
                    x_ATTRIBUTE7                   VARCHAR2,
                    x_ATTRIBUTE8                   VARCHAR2,
                    x_ATTRIBUTE9                   VARCHAR2,
                    x_ATTRIBUTE10                  VARCHAR2,
                    x_ATTRIBUTE11                  VARCHAR2,
                    x_ATTRIBUTE12                  VARCHAR2,
                    x_ATTRIBUTE13                  VARCHAR2,
                    x_ATTRIBUTE14                  VARCHAR2,
                    x_ATTRIBUTE15                  VARCHAR2,
                    x_SETUP_ID                     NUMBER)
 IS
BEGIN
   UPDATE BOM_SUB_OPERATION_RESOURCES SET
                 OPERATION_SEQUENCE_ID        =   x_OPERATION_SEQUENCE_ID,
                 SUBSTITUTE_GROUP_NUM         =   x_SUBSTITUTE_GROUP_NUM,
                 RESOURCE_ID                  =   x_RESOURCE_ID,
                 SCHEDULE_SEQ_NUM             =   x_SCHEDULE_SEQ_NUM,
                 REPLACEMENT_GROUP_NUM        =   x_REPLACEMENT_GROUP_NUM ,
                 ACTIVITY_ID                  =   x_ACTIVITY_ID,
                 STANDARD_RATE_FLAG           =   x_STANDARD_RATE_FLAG,
                 ASSIGNED_UNITS               =   x_ASSIGNED_UNITS,
                 USAGE_RATE_OR_AMOUNT         =   x_USAGE_RATE_OR_AMOUNT,
                 USAGE_RATE_OR_AMOUNT_INVERSE =   x_USAGE_RATE_OR_AMOUNT_INVERSE,
                 BASIS_TYPE                   =   x_BASIS_TYPE,
                 SCHEDULE_FLAG                =   x_SCHEDULE_FLAG,
                 LAST_UPDATE_DATE             =   x_LAST_UPDATE_DATE,
                 LAST_UPDATED_BY              =   x_LAST_UPDATED_BY,
                 CREATION_DATE                =   x_CREATION_DATE,
                 CREATED_BY                   =   x_CREATED_BY,
                 LAST_UPDATE_LOGIN            =   x_LAST_UPDATE_LOGIN,
                 RESOURCE_OFFSET_PERCENT      =   x_RESOURCE_OFFSET_PERCENT,
                 AUTOCHARGE_TYPE              =   x_AUTOCHARGE_TYPE,
                 PRINCIPLE_FLAG               =   x_PRINCIPLE_FLAG,
                 attribute_category           =   x_attribute_category,
                 attribute1                   =   x_attribute1,
                 attribute2                   =   x_attribute2,
                 attribute3                   =   x_attribute3,
                 attribute4                   =   x_attribute4,
                 attribute5                   =   x_attribute5,
                 attribute6                   =   x_attribute6,
                 attribute7                   =   x_attribute7,
                 attribute8                   =   x_attribute8,
                 attribute9                   =   x_attribute9,
                 attribute10                  =   x_attribute10,
                 attribute11                  =   x_attribute11,
                 attribute12                  =   x_attribute12,
                 attribute13                  =   x_attribute13,
                 attribute14                  =   x_attribute14,
                 attribute15                  =   x_attribute15,
                 setup_id                     =   x_setup_id
  WHERE rowid = x_row_id;
  IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;

END;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
 DELETE FROM BOM_SUB_OPERATION_RESOURCES
 WHERE rowid=x_rowid;
END Delete_Row;

PROCEDURE CHECK_UNIQUE_LINK(X_ROWID VARCHAR2,
                            X_FROM_OP_SEQ_ID NUMBER,
                            X_TO_OP_SEQ_ID NUMBER) IS
dummy NUMBER;
from_op_seq_num NUMBER;
to_op_seq_num NUMBER;
BEGIN
	SELECT operation_seq_num
	INTO   from_op_seq_num
	FROM   bom_operation_sequences
	WHERE  operation_sequence_id = x_from_op_seq_id;

	SELECT operation_seq_num
	INTO   to_op_seq_num
	FROM   bom_operation_sequences
	WHERE  operation_sequence_id = x_to_op_seq_id;

  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_OPERATION_NETWORKS
     WHERE from_op_seq_id = X_From_Op_Seq_Id
     AND   To_Op_Seq_Id = X_To_Op_Seq_Id
     AND  ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('BOM','BOM_LINK_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('FROM_OP_SEQ_ID',to_char(from_op_seq_num), FALSE);
      FND_MESSAGE.SET_TOKEN('TO_OP_SEQ_ID',to_char(to_op_seq_num), FALSE);
      APP_EXCEPTION.RAISE_EXCEPTION;
END;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ** Function : get_resource_code
 ** Scope    : local
 ** Purpose  : To get the resource code for the id passed.  Added as part of bug fix 4932342.
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
FUNCTION get_resource_code (
   p_resource_id    IN   NUMBER
)
   RETURN VARCHAR2
IS
   l_resource_code        VARCHAR2 (10);

   CURSOR csr_res_code (
      p_res_id    IN   NUMBER
   )
   IS
	   SELECT br.resource_code
          FROM bom_resources br
         WHERE br.resource_id = p_res_id;
BEGIN
   OPEN csr_res_code (p_resource_id);

   LOOP
      FETCH csr_res_code
       INTO l_resource_code;
      EXIT WHEN csr_res_code%NOTFOUND;
   END LOOP;

   CLOSE csr_res_code;

   RETURN l_resource_code;
END get_resource_code;

PROCEDURE Validate_Schedule_Flag(p_routing_sequence_id NUMBER,		-- BUG 3950992
		   x_return_status OUT NOCOPY VARCHAR2,
                   x_msg_data OUT NOCOPY VARCHAR2,
                   x_operation_seq_num OUT NOCOPY NUMBER) IS

  CURSOR operations (p_rtg_seq_id NUMBER)IS
	SELECT operation_seq_num, operation_sequence_id
	FROM bom_operation_sequences
	WHERE routing_sequence_id = p_rtg_seq_id;

 /*Fix for bug 6074930 - Added schedule_flag <> 2 conditions in the queries below.
  This is done to filter off unscheduled resources, sub-resources. */
  CURSOR op_resources(p_opn_seq_num NUMBER) IS
	SELECT * FROM
    (
     (
      SELECT bor.resource_id,
	         bor.resource_seq_num,
             bor.schedule_seq_num,
             bor.substitute_group_num,
             bor.schedule_flag
        FROM bom_operation_resources bor ,
             bom_operation_sequences bos ,
             bom_resources br ,
             bom_department_resources bdr ,
             cst_activities ca ,
             bom_setup_types bst
       WHERE br.resource_id = bor.resource_id
         AND bdr.department_id = bos.department_id
         AND bdr.resource_id = bor.resource_id
         AND bor.operation_sequence_id = bos.operation_sequence_id
         AND NVL ( bos.operation_type , 1 ) = 1
         AND bor.activity_id = ca.activity_id ( + )
         AND bor.setup_id = bst.setup_id ( + )
         AND bor.operation_sequence_id = p_opn_seq_num
	 AND bor.schedule_flag <> 2
       UNION
      SELECT bor.resource_id,
	         bor.resource_seq_num,
             bor.schedule_seq_num,
             bor.substitute_group_num,
             bor.schedule_flag
        FROM bom_operation_resources bor ,
             eng_revised_operations ero ,
             bom_resources br ,
             bom_department_resources bdr ,
             cst_activities ca ,
             bom_setup_types bst
       WHERE br.resource_id = bor.resource_id
         AND bdr.department_id = ero.department_id
         AND bdr.resource_id = bor.resource_id
         AND bor.operation_sequence_id = ero.operation_sequence_id
         AND bor.acd_type IS NOT NULL
         AND NVL ( ero.operation_type , 1 ) = 1
         AND bor.activity_id = ca.activity_id ( + )
         AND bor.setup_id = bst.setup_id ( + )
         AND bor.operation_sequence_id = p_opn_seq_num
	 AND bor.schedule_flag <> 2
      )
      UNION ALL
      SELECT bor.resource_id,
	         to_number(NULL) resource_seq_num,
             bor.schedule_seq_num,
             bor.substitute_group_num,
             bor.schedule_flag
        FROM bom_sub_operation_resources bor ,
             bom_operation_sequences bos ,
             bom_resources br ,
             bom_department_resources bdr ,
             cst_activities ca ,
             bom_setup_types bst
       WHERE br.resource_id = bor.resource_id
         AND bdr.department_id = bos.department_id
         AND bdr.resource_id = bor.resource_id
         AND bor.operation_sequence_id = bos.operation_sequence_id
         AND NVL ( bos.operation_type , 1 ) = 1
         AND bor.activity_id = ca.activity_id ( + )
         AND bor.setup_id = bst.setup_id ( + )
         AND bor.operation_sequence_id = p_opn_seq_num
	 AND bor.schedule_flag <> 2
    ) ORDER BY nvl(schedule_seq_num, resource_seq_num);

   last_res_seq NUMBER := 0;
   last_sub_group NUMBER := 0;
   last_sched_seq NUMBER := 0;
   last_scheduled_flag NUMBER := 0;
   last_res_code VARCHAR2(50) :='';
   last_res_id NUMBER := 0;
   error_exists BOOLEAN := false;
BEGIN
	for cur_op in operations (p_routing_sequence_id) loop
	   last_res_seq := 0;
	   last_sub_group := 0;
	   last_sched_seq := 0;
	   last_scheduled_flag := 0;
	   last_res_code := '';

	   for cur_opres in op_resources(cur_op.operation_sequence_id) loop
	    /*Fix for bug 6074930 - In below If condition, added check on last_res_seq is null,
	    since for sub resources, resource_seq_num can be null*/
	   	if ( (last_res_seq is null) or (last_res_seq <>0) ) then
			if ((nvl(last_sched_seq,last_res_seq) = nvl(cur_opres.schedule_seq_num, cur_opres.resource_seq_num))) then
				if (last_scheduled_flag <> cur_opres.schedule_flag) then
					FND_MESSAGE.SET_NAME('BOM', 'BOM_SIM_RES_SAME_PRIOR_NEXT');
					FND_MESSAGE.set_token(  token => 'OP_SEQ',
					value=> to_char(cur_op.operation_seq_num),
					translate => FALSE);
					FND_MESSAGE.set_token(  token => 'RES_SEQ_1',
					value=> get_resource_code(last_res_id),
					translate => FALSE);
					FND_MESSAGE.set_token(  token => 'RES_SEQ_2',
					value=> get_resource_code(cur_opres.resource_id),
					translate => FALSE);
					error_exists := true;
				end if;
			end if;
		end if;
		if (error_exists = true) then
                   x_return_status := fnd_api.g_ret_sts_error;
                   x_msg_data := fnd_message.get;
                   x_operation_seq_num := cur_op.operation_seq_num;
                   return;
		end if;
                last_res_seq := cur_opres.resource_seq_num;
                last_sub_group := cur_opres.substitute_group_num;
                last_sched_seq := cur_opres.schedule_seq_num;
                last_scheduled_flag := cur_opres.schedule_flag;
				last_res_id := cur_opres.resource_id;
		-- commented as part of bug fix 4932342
		-- last_res_code := cur_opres.resource_code; Will query separately the resource_code for msg
	   end loop;
	end loop;
EXCEPTION
	WHEN OTHERS THEN
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
END Validate_Schedule_Flag;


END BOM_SUB_RESOURCES_PKG;

/
