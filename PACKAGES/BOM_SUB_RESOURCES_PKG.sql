--------------------------------------------------------
--  DDL for Package BOM_SUB_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_SUB_RESOURCES_PKG" AUTHID CURRENT_USER as
/* $Header: BOMSRESS.pls 120.0 2005/05/25 05:32:16 appldev noship $ */
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
                    x_ATTRIBUTE15                  VARCHAR2);

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
                    x_SETUP_ID                     NUMBER);


     PROCEDURE Lock_Row( x_ROW_ID                      VARCHAR2,
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
                    x_ATTRIBUTE15                  VARCHAR2);

     PROCEDURE Lock_Row( x_ROW_ID                      VARCHAR2,
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
                    x_SETUP_ID                     NUMBER);

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
                    x_ATTRIBUTE15                  VARCHAR2);

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
                    x_SETUP_ID                     NUMBER);



     PROCEDURE Delete_Row(X_Rowid VARCHAR2);

     PROCEDURE CHECK_UNIQUE_LINK(X_ROWID VARCHAR2,
                                 X_FROM_OP_SEQ_ID NUMBER,
                                 X_TO_OP_SEQ_ID NUMBER);

/*=====================================================================+
 | PROCEDURE
 |   Validate_Schedule_Flag
 |
 | PURPOSE
 |   Simultaneous Resources must be scheduled by
 |   nvl(schedule_seq_num, resource_seq_num).
 |   Call this procedure after all changes are inserted in the
 |   the database to check if these rules are violated.
 |   Added this Procedure for BUG 3950992
 | ARGUMENTS
 |   IN
 |     p_routing_sequence_id
 |   OUT
 |     x_return_status
 |     x_msg_data:  returns the error message
 |     x_operation_seq_num: returns the op seq at which the error
 |          occurred
 |
 +=====================================================================*/
     PROCEDURE Validate_Schedule_Flag(p_routing_sequence_id NUMBER,		--BUG 3950992
				      x_return_status OUT NOCOPY VARCHAR2,
				      x_msg_data OUT NOCOPY VARCHAR2,
				      x_operation_seq_num OUT NOCOPY NUMBER);

END BOM_SUB_RESOURCES_PKG;

 

/
