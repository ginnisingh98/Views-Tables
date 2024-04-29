--------------------------------------------------------
--  DDL for Package PV_RULE_RECTYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_RULE_RECTYPE_PUB" AUTHID CURRENT_USER as
/* $Header: pvrtspcs.pls 120.1 2005/12/06 14:19:35 amaram noship $ */
-- Start of Comments
-- Package name     : PV_RULE_RECTYPE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


TYPE SELCRIT_Rec_Type IS RECORD
(
       SELECTION_CRITERIA_ID           NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       PROCESS_RULE_ID                 NUMBER := FND_API.G_MISS_NUM
,       ATTRIBUTE_ID                    NUMBER := FND_API.G_MISS_NUM
,       SELECTION_TYPE_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR
,       OPERATOR                        VARCHAR2(30) := FND_API.G_MISS_CHAR
,       RANK                            NUMBER := FND_API.G_MISS_NUM
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_SELCRIT_REC          SELCRIT_Rec_Type;


TYPE RULES_Rec_Type IS RECORD
(
       PROCESS_RULE_ID                 NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       PROCESS_RULE_NAME               VARCHAR2(100) := FND_API.G_MISS_CHAR
,       PARENT_RULE_ID                  NUMBER := FND_API.G_MISS_NUM
,       PROCESS_TYPE                    VARCHAR2(30) := FND_API.G_MISS_CHAR
,       RANK                            NUMBER := FND_API.G_MISS_NUM
,       STATUS_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR
,       START_DATE                      DATE := FND_API.G_MISS_DATE
,       END_DATE                        DATE := FND_API.G_MISS_DATE
,       ACTION                          VARCHAR2(500) := FND_API.G_MISS_CHAR
,       ACTION_VALUE                    VARCHAR2(15) := FND_API.G_MISS_CHAR
,       OWNER_RESOURCE_ID               NUMBER := FND_API.G_MISS_NUM
,       CURRENCY_CODE                   VARCHAR2(15) := FND_API.G_MISS_CHAR
,       LANGUAGE                        VARCHAR2(4) := FND_API.G_MISS_CHAR
,       SOURCE_LANG                     VARCHAR2(4) := FND_API.G_MISS_CHAR
,       DESCRIPTION                     VARCHAR2(500) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_RULES_REC          RULES_Rec_Type;


TYPE ENTYATTMAP_Rec_Type IS RECORD
(
       MAPPING_ID                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       PROCESS_RULE_ID                 NUMBER := FND_API.G_MISS_NUM
,       SOURCE_ATTR_TYPE                VARCHAR2(30) := FND_API.G_MISS_CHAR
,       SOURCE_ATTR_ID                  NUMBER := FND_API.G_MISS_NUM
,       TARGET_ATTR_TYPE                VARCHAR2(30) := FND_API.G_MISS_CHAR
,       TARGET_ATTR_ID                  NUMBER := FND_API.G_MISS_NUM
,       OPERATOR                        VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_ENTYATTMAP_REC          ENTYATTMAP_Rec_Type;


TYPE ENTYRLS_Rec_Type IS RECORD
(
       ENTITY_RULE_APPLIED_ID          NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       ENTITY                          VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ENTITY_ID                       NUMBER := FND_API.G_MISS_NUM
,       PROCESS_RULE_ID                 NUMBER := FND_API.G_MISS_NUM
,       PARENT_PROCESS_RULE_ID          NUMBER := FND_API.G_MISS_NUM
,       LATEST_FLAG                     VARCHAR2(5) := FND_API.G_MISS_CHAR
,       ACTION_VALUE                    VARCHAR2(15) := FND_API.G_MISS_CHAR
,       PROCESS_TYPE                    VARCHAR2(30) := FND_API.G_MISS_CHAR
,       WINNING_RULE_FLAG               VARCHAR2(1) := FND_API.G_MISS_CHAR
,       ENTITY_DETAIL                   VARCHAR2(100) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       PROCESS_STATUS                  VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_ENTYRLS_REC          ENTYRLS_Rec_Type;


TYPE ENTYROUT_Rec_Type IS RECORD
(
       ENTITY_ROUTING_ID               NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       PROCESS_RULE_ID                 NUMBER := FND_API.G_MISS_NUM
,       DISTANCE_FROM_CUSTOMER          NUMBER := FND_API.G_MISS_NUM
,       DISTANCE_UOM_CODE               VARCHAR2(10) := FND_API.G_MISS_CHAR
,       MAX_NEAREST_PARTNER             NUMBER := FND_API.G_MISS_NUM
,       ROUTING_TYPE                    VARCHAR2(30) := FND_API.G_MISS_CHAR
,       BYPASS_CM_OK_FLAG               VARCHAR2(1) := FND_API.G_MISS_CHAR
,       CM_TIMEOUT                      NUMBER := FND_API.G_MISS_NUM
,       CM_TIMEOUT_UOM_CODE             VARCHAR2(10) := FND_API.G_MISS_CHAR
,       PARTNER_TIMEOUT                 NUMBER := FND_API.G_MISS_NUM
,       PARTNER_TIMEOUT_UOM_CODE        VARCHAR2(10) := FND_API.G_MISS_CHAR
,       UNMATCHED_INT_RESOURCE_ID       NUMBER := FND_API.G_MISS_NUM
,       UNMATCHED_CALL_TAP_FLAG         VARCHAR2(5) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_ENTYROUT_REC          ENTYROUT_Rec_Type;


TYPE SELATTVAL_Rec_Type IS RECORD
(
       ATTR_VALUE_ID                   NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       SELECTION_CRITERIA_ID           NUMBER := FND_API.G_MISS_NUM
,       ATTRIBUTE_VALUE                 VARCHAR2(2000) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_TO_VALUE              VARCHAR2(500) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       SCORE                           NUMBER := FND_API.G_MISS_NUM
);

G_MISS_SELATTVAL_REC          SELATTVAL_Rec_Type;

End PV_RULE_RECTYPE_PUB;

 

/
