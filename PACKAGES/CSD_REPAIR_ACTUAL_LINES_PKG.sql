--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ACTUAL_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ACTUAL_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: csdtalns.pls 120.1 2008/02/15 04:02:21 takwong ship $ csdtalns.pls */

PROCEDURE Insert_Row(
          px_REPAIR_ACTUAL_LINE_ID   IN OUT NOCOPY NUMBER
         ,p_OBJECT_VERSION_NUMBER                  NUMBER
         ,p_ESTIMATE_DETAIL_ID                     NUMBER
         ,p_REPAIR_ACTUAL_ID                       NUMBER
         ,p_REPAIR_LINE_ID                         NUMBER
         ,p_CREATED_BY                             NUMBER
         ,p_CREATION_DATE                          DATE
         ,p_LAST_UPDATED_BY                        NUMBER
         ,p_LAST_UPDATE_DATE                       DATE
         ,p_LAST_UPDATE_LOGIN                      NUMBER
         ,p_ITEM_COST                              NUMBER
         ,p_JUSTIFICATION_NOTES                    VARCHAR2
         ,p_RESOURCE_ID                            NUMBER
         ,p_OVERRIDE_CHARGE_FLAG                   VARCHAR2
         ,p_ACTUAL_SOURCE_CODE                     VARCHAR2
         ,p_ACTUAL_SOURCE_ID                       NUMBER
         ,p_WARRANTY_CLAIM_FLAG                    VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_WARRANTY_NUMBER                        VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_WARRANTY_STATUS_CODE                   VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_REPLACED_ITEM_ID                       NUMBER   := FND_API.G_MISS_NUM
         ,p_ATTRIBUTE_CATEGORY                     VARCHAR2
         ,p_ATTRIBUTE1                             VARCHAR2
         ,p_ATTRIBUTE2                             VARCHAR2
         ,p_ATTRIBUTE3                             VARCHAR2
         ,p_ATTRIBUTE4                             VARCHAR2
         ,p_ATTRIBUTE5                             VARCHAR2
         ,p_ATTRIBUTE6                             VARCHAR2
         ,p_ATTRIBUTE7                             VARCHAR2
         ,p_ATTRIBUTE8                             VARCHAR2
         ,p_ATTRIBUTE9                             VARCHAR2
         ,p_ATTRIBUTE10                            VARCHAR2
         ,p_ATTRIBUTE11                            VARCHAR2
         ,p_ATTRIBUTE12                            VARCHAR2
         ,p_ATTRIBUTE13                            VARCHAR2
         ,p_ATTRIBUTE14                            VARCHAR2
         ,p_ATTRIBUTE15                            VARCHAR2
         ,p_LOCATOR_ID                             NUMBER
         ,p_LOC_SEGMENT1                           VARCHAR2
         ,p_LOC_SEGMENT2                           VARCHAR2
         ,p_LOC_SEGMENT3                           VARCHAR2
         ,p_LOC_SEGMENT4                           VARCHAR2
         ,p_LOC_SEGMENT5                           VARCHAR2
         ,p_LOC_SEGMENT6                           VARCHAR2
         ,p_LOC_SEGMENT7                           VARCHAR2
         ,p_LOC_SEGMENT8                           VARCHAR2
         ,p_LOC_SEGMENT9                           VARCHAR2
         ,p_LOC_SEGMENT10                          VARCHAR2
         ,p_LOC_SEGMENT11                          VARCHAR2
         ,p_LOC_SEGMENT12                          VARCHAR2
         ,p_LOC_SEGMENT13                          VARCHAR2
         ,p_LOC_SEGMENT14                          VARCHAR2
         ,p_LOC_SEGMENT15                          VARCHAR2
         ,p_LOC_SEGMENT16                          VARCHAR2
         ,p_LOC_SEGMENT17                          VARCHAR2
         ,p_LOC_SEGMENT18                          VARCHAR2
         ,p_LOC_SEGMENT19                          VARCHAR2
         ,p_LOC_SEGMENT20                          VARCHAR2);

PROCEDURE Update_Row(
          p_REPAIR_ACTUAL_LINE_ID                  NUMBER
         ,p_OBJECT_VERSION_NUMBER                  NUMBER
         ,p_ESTIMATE_DETAIL_ID                     NUMBER
         ,p_REPAIR_ACTUAL_ID                       NUMBER
         ,p_REPAIR_LINE_ID                         NUMBER
         ,p_CREATED_BY                             NUMBER
         ,p_CREATION_DATE                          DATE
         ,p_LAST_UPDATED_BY                        NUMBER
         ,p_LAST_UPDATE_DATE                       DATE
         ,p_LAST_UPDATE_LOGIN                      NUMBER
         ,p_ITEM_COST                              NUMBER
         ,p_JUSTIFICATION_NOTES                    VARCHAR2
         ,p_RESOURCE_ID                            NUMBER
         ,p_OVERRIDE_CHARGE_FLAG                   VARCHAR2
         ,p_ACTUAL_SOURCE_CODE                     VARCHAR2
         ,p_ACTUAL_SOURCE_ID                       NUMBER
         ,p_WARRANTY_CLAIM_FLAG                    VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_WARRANTY_NUMBER                        VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_WARRANTY_STATUS_CODE                   VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_REPLACED_ITEM_ID                       NUMBER   := FND_API.G_MISS_NUM
         ,p_ATTRIBUTE_CATEGORY                     VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_LOCATOR_ID    NUMBER
         ,p_LOC_SEGMENT1    VARCHAR2
         ,p_LOC_SEGMENT2    VARCHAR2
         ,p_LOC_SEGMENT3    VARCHAR2
         ,p_LOC_SEGMENT4    VARCHAR2
         ,p_LOC_SEGMENT5    VARCHAR2
         ,p_LOC_SEGMENT6    VARCHAR2
         ,p_LOC_SEGMENT7    VARCHAR2
         ,p_LOC_SEGMENT8    VARCHAR2
         ,p_LOC_SEGMENT9    VARCHAR2
         ,p_LOC_SEGMENT10    VARCHAR2
         ,p_LOC_SEGMENT11    VARCHAR2
         ,p_LOC_SEGMENT12    VARCHAR2
         ,p_LOC_SEGMENT13    VARCHAR2
         ,p_LOC_SEGMENT14    VARCHAR2
         ,p_LOC_SEGMENT15    VARCHAR2
         ,p_LOC_SEGMENT16    VARCHAR2
         ,p_LOC_SEGMENT17    VARCHAR2
         ,p_LOC_SEGMENT18    VARCHAR2
         ,p_LOC_SEGMENT19    VARCHAR2
         ,p_LOC_SEGMENT20    VARCHAR2);

PROCEDURE Lock_Row(
          p_REPAIR_ACTUAL_LINE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
          p_REPAIR_ACTUAL_LINE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

End CSD_REPAIR_ACTUAL_LINES_PKG;

/
