--------------------------------------------------------
--  DDL for Package CSI_CTR_READING_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_READING_INTERFACE_PKG" AUTHID CURRENT_USER as
/* $Header: csitcris.pls 120.0 2005/06/09 21:37:38 epajaril noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_CTR_READING_INTERFACE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcris.pls';

PROCEDURE insert_row(
	 px_COUNTER_INTERFACE_ID               IN OUT NOCOPY NUMBER
	,p_PARALLEL_WORKER_ID                  NUMBER
	,p_BATCH_NAME                          VARCHAR2
	,p_SOURCE_TRANSACTION_DATE             DATE
	,p_PROCESS_STATUS                      VARCHAR2
        ,p_ERROR_TEXT                          VARCHAR2
	,px_COUNTER_VALUE_ID                   IN OUT NOCOPY NUMBER
	,p_COUNTER_ID                          NUMBER
	,p_VALUE_TIMESTAMP                     DATE
	,p_COUNTER_READING                     NUMBER
	,p_RESET_MODE                          VARCHAR2
	,p_RESET_REASON                        VARCHAR2
	,p_ADJUSTMENT_TYPE                     VARCHAR2
	,p_ADJUSTMENT_READING                  NUMBER
	,p_OBJECT_VERSION_NUMBER               NUMBER
	,p_LAST_UPDATE_DATE                    DATE
	,p_LAST_UPDATED_BY                     NUMBER
	,p_CREATION_DATE                       DATE
	,p_CREATED_BY                          NUMBER
	,p_LAST_UPDATE_LOGIN                   NUMBER
	,p_ATTRIBUTE1                          VARCHAR2
	,p_ATTRIBUTE2                          VARCHAR2
	,p_ATTRIBUTE3                          VARCHAR2
	,p_ATTRIBUTE4                          VARCHAR2
	,p_ATTRIBUTE5                          VARCHAR2
	,p_ATTRIBUTE6                          VARCHAR2
	,p_ATTRIBUTE7                          VARCHAR2
	,p_ATTRIBUTE8                          VARCHAR2
	,p_ATTRIBUTE9                          VARCHAR2
	,p_ATTRIBUTE10                         VARCHAR2
	,p_ATTRIBUTE11                         VARCHAR2
	,p_ATTRIBUTE12                         VARCHAR2
	,p_ATTRIBUTE13                         VARCHAR2
	,p_ATTRIBUTE14                         VARCHAR2
	,p_ATTRIBUTE15                         VARCHAR2
        ,p_ATTRIBUTE16                         VARCHAR2
        ,p_ATTRIBUTE17                         VARCHAR2
        ,p_ATTRIBUTE18                         VARCHAR2
        ,p_ATTRIBUTE19                         VARCHAR2
        ,p_ATTRIBUTE20                         VARCHAR2
        ,p_ATTRIBUTE21                         VARCHAR2
        ,p_ATTRIBUTE22                         VARCHAR2
        ,p_ATTRIBUTE23                         VARCHAR2
        ,p_ATTRIBUTE24                         VARCHAR2
        ,p_ATTRIBUTE25                         VARCHAR2
        ,p_ATTRIBUTE26                         VARCHAR2
        ,p_ATTRIBUTE27                         VARCHAR2
        ,p_ATTRIBUTE28                         VARCHAR2
        ,p_ATTRIBUTE29                         VARCHAR2
        ,p_ATTRIBUTE30                         VARCHAR2
	,p_ATTRIBUTE_CATEGORY                  VARCHAR2
	,p_DISABLED_FLAG                       VARCHAR2
	,p_COMMENTS                            VARCHAR2
	,p_SOURCE_TRANSACTION_TYPE_ID          NUMBER
	,p_SOURCE_TRANSACTION_ID               NUMBER
	,p_SOURCE_CODE                         VARCHAR2
	,p_SOURCE_LINE_ID                      NUMBER
	,p_COUNTER_NAME                        VARCHAR2
        ,p_AUTOMATIC_ROLLOVER_FLAG             VARCHAR2
        ,p_INCLUDE_TARGET_RESETS               VARCHAR2
        ,p_RESET_COUNTER_READING               NUMBER
        ,p_NET_READING                         NUMBER
        ,p_LIFE_TO_DATE_READING                NUMBER
        ,p_SOURCE_COUNTER_VALUE_ID             NUMBER
);

PROCEDURE update_row(
	 p_COUNTER_INTERFACE_ID                NUMBER
	,p_PARALLEL_WORKER_ID                  NUMBER
	,p_BATCH_NAME                          VARCHAR2
	,p_SOURCE_TRANSACTION_DATE             DATE
	,p_PROCESS_STATUS                      VARCHAR2
        ,p_ERROR_TEXT                          VARCHAR2
	,p_COUNTER_VALUE_ID                    NUMBER
	,p_COUNTER_ID                          NUMBER
	,p_VALUE_TIMESTAMP                     DATE
	,p_COUNTER_READING                     NUMBER
	,p_RESET_MODE                          VARCHAR2
	,p_RESET_REASON                        VARCHAR2
	,p_ADJUSTMENT_TYPE                     VARCHAR2
	,p_ADJUSTMENT_READING                  NUMBER
	,p_OBJECT_VERSION_NUMBER               NUMBER
	,p_LAST_UPDATE_DATE                    DATE
	,p_LAST_UPDATED_BY                     NUMBER
	,p_CREATION_DATE                       DATE
	,p_CREATED_BY                          NUMBER
	,p_LAST_UPDATE_LOGIN                   NUMBER
	,p_ATTRIBUTE1                          VARCHAR2
	,p_ATTRIBUTE2                          VARCHAR2
	,p_ATTRIBUTE3                          VARCHAR2
	,p_ATTRIBUTE4                          VARCHAR2
	,p_ATTRIBUTE5                          VARCHAR2
	,p_ATTRIBUTE6                          VARCHAR2
	,p_ATTRIBUTE7                          VARCHAR2
	,p_ATTRIBUTE8                          VARCHAR2
	,p_ATTRIBUTE9                          VARCHAR2
	,p_ATTRIBUTE10                         VARCHAR2
	,p_ATTRIBUTE11                         VARCHAR2
	,p_ATTRIBUTE12                         VARCHAR2
	,p_ATTRIBUTE13                         VARCHAR2
	,p_ATTRIBUTE14                         VARCHAR2
	,p_ATTRIBUTE15                         VARCHAR2
        ,p_ATTRIBUTE16                         VARCHAR2
        ,p_ATTRIBUTE17                         VARCHAR2
        ,p_ATTRIBUTE18                         VARCHAR2
        ,p_ATTRIBUTE19                         VARCHAR2
        ,p_ATTRIBUTE20                         VARCHAR2
        ,p_ATTRIBUTE21                         VARCHAR2
        ,p_ATTRIBUTE22                         VARCHAR2
        ,p_ATTRIBUTE23                         VARCHAR2
        ,p_ATTRIBUTE24                         VARCHAR2
        ,p_ATTRIBUTE25                         VARCHAR2
        ,p_ATTRIBUTE26                         VARCHAR2
        ,p_ATTRIBUTE27                         VARCHAR2
        ,p_ATTRIBUTE28                         VARCHAR2
        ,p_ATTRIBUTE29                         VARCHAR2
        ,p_ATTRIBUTE30                         VARCHAR2
	,p_ATTRIBUTE_CATEGORY                  VARCHAR2
	,p_DISABLED_FLAG                       VARCHAR2
	,p_COMMENTS                            VARCHAR2
	,p_SOURCE_TRANSACTION_TYPE_ID          NUMBER
	,p_SOURCE_TRANSACTION_ID               NUMBER
	,p_SOURCE_CODE                         VARCHAR2
	,p_SOURCE_LINE_ID                      NUMBER
	,p_COUNTER_NAME                        VARCHAR2
        ,p_AUTOMATIC_ROLLOVER_FLAG             VARCHAR2
        ,p_INCLUDE_TARGET_RESETS               VARCHAR2
        ,p_RESET_COUNTER_READING               NUMBER
        ,p_NET_READING                         NUMBER
        ,p_LIFE_TO_DATE_READING                NUMBER
        ,p_SOURCE_COUNTER_VALUE_ID             NUMBER
);

PROCEDURE lock_row(
	 p_COUNTER_INTERFACE_ID                NUMBER
	,p_PARALLEL_WORKER_ID                  NUMBER
	,p_BATCH_NAME                          VARCHAR2
	,p_SOURCE_TRANSACTION_DATE             DATE
	,p_PROCESS_STATUS                      VARCHAR2
        ,p_ERROR_TEXT                          VARCHAR2
	,p_COUNTER_VALUE_ID                    NUMBER
	,p_COUNTER_ID                          NUMBER
	,p_VALUE_TIMESTAMP                     DATE
	,p_COUNTER_READING                     NUMBER
	,p_RESET_MODE                          VARCHAR2
	,p_RESET_REASON                        VARCHAR2
	,p_ADJUSTMENT_TYPE                     VARCHAR2
	,p_ADJUSTMENT_READING                  NUMBER
	,p_OBJECT_VERSION_NUMBER               NUMBER
	,p_LAST_UPDATE_DATE                    DATE
	,p_LAST_UPDATED_BY                     NUMBER
	,p_CREATION_DATE                       DATE
	,p_CREATED_BY                          NUMBER
	,p_LAST_UPDATE_LOGIN                   NUMBER
	,p_ATTRIBUTE1                          VARCHAR2
	,p_ATTRIBUTE2                          VARCHAR2
	,p_ATTRIBUTE3                          VARCHAR2
	,p_ATTRIBUTE4                          VARCHAR2
	,p_ATTRIBUTE5                          VARCHAR2
	,p_ATTRIBUTE6                          VARCHAR2
	,p_ATTRIBUTE7                          VARCHAR2
	,p_ATTRIBUTE8                          VARCHAR2
	,p_ATTRIBUTE9                          VARCHAR2
	,p_ATTRIBUTE10                         VARCHAR2
	,p_ATTRIBUTE11                         VARCHAR2
	,p_ATTRIBUTE12                         VARCHAR2
	,p_ATTRIBUTE13                         VARCHAR2
	,p_ATTRIBUTE14                         VARCHAR2
	,p_ATTRIBUTE15                         VARCHAR2
        ,p_ATTRIBUTE16                         VARCHAR2
        ,p_ATTRIBUTE17                         VARCHAR2
        ,p_ATTRIBUTE18                         VARCHAR2
        ,p_ATTRIBUTE19                         VARCHAR2
        ,p_ATTRIBUTE20                         VARCHAR2
        ,p_ATTRIBUTE21                         VARCHAR2
        ,p_ATTRIBUTE22                         VARCHAR2
        ,p_ATTRIBUTE23                         VARCHAR2
        ,p_ATTRIBUTE24                         VARCHAR2
        ,p_ATTRIBUTE25                         VARCHAR2
        ,p_ATTRIBUTE26                         VARCHAR2
        ,p_ATTRIBUTE27                         VARCHAR2
        ,p_ATTRIBUTE28                         VARCHAR2
        ,p_ATTRIBUTE29                         VARCHAR2
        ,p_ATTRIBUTE30                         VARCHAR2
	,p_ATTRIBUTE_CATEGORY                  VARCHAR2
	,p_DISABLED_FLAG                       VARCHAR2
	,p_COMMENTS                            VARCHAR2
	,p_SOURCE_TRANSACTION_TYPE_ID          NUMBER
	,p_SOURCE_TRANSACTION_ID               NUMBER
	,p_SOURCE_CODE                         VARCHAR2
	,p_SOURCE_LINE_ID                      NUMBER
	,p_COUNTER_NAME                        VARCHAR2
        ,p_AUTOMATIC_ROLLOVER_FLAG             VARCHAR2
        ,p_INCLUDE_TARGET_RESETS               VARCHAR2
        ,p_RESET_COUNTER_READING               NUMBER
        ,p_NET_READING                         NUMBER
        ,p_LIFE_TO_DATE_READING                NUMBER
        ,p_SOURCE_COUNTER_VALUE_ID             NUMBER
        );

PROCEDURE delete_row(
	 p_COUNTER_INTERFACE_ID                NUMBER
       );

End CSI_CTR_READING_INTERFACE_PKG;

 

/
