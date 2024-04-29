--------------------------------------------------------
--  DDL for Package OKE_NUMBER_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_NUMBER_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: OKENMOPS.pls 115.4 2002/11/21 23:01:53 ybchen ship $ */
PROCEDURE INSERT_ROW
( X_ROWID                           IN OUT NOCOPY VARCHAR2
, X_K_TYPE_CODE                     IN        VARCHAR2
, X_BUY_OR_SELL                     IN        VARCHAR2
, X_CREATION_DATE                   IN        DATE
, X_CREATED_BY                      IN        NUMBER
, X_LAST_UPDATE_DATE                IN        DATE
, X_LAST_UPDATED_BY                 IN        NUMBER
, X_LAST_UPDATE_LOGIN               IN        NUMBER
, X_CONTRACT_NUM_MODE               IN        VARCHAR2
, X_MANUAL_CONTRACT_NUM_TYPE        IN        VARCHAR2
, X_NEXT_CONTRACT_NUM               IN        NUMBER
, X_CONTRACT_NUM_INCREMENT          IN        NUMBER
, X_CONTRACT_NUM_WIDTH              IN        NUMBER
, X_CHGREQ_NUM_MODE                 IN        VARCHAR2
, X_MANUAL_CHGREQ_NUM_TYPE          IN        VARCHAR2
, X_CHGREQ_NUM_START_NUMBER         IN        NUMBER
, X_CHGREQ_NUM_INCREMENT            IN        NUMBER
, X_CHGREQ_NUM_WIDTH                IN        NUMBER
, X_LINE_NUM_START_NUMBER           IN        NUMBER
, X_LINE_NUM_INCREMENT              IN        NUMBER
, X_LINE_NUM_WIDTH                  IN        NUMBER
, X_SUBLINE_NUM_START_NUMBER        IN        NUMBER
, X_SUBLINE_NUM_INCREMENT           IN        NUMBER
, X_SUBLINE_NUM_WIDTH               IN        NUMBER
, X_DELV_NUM_START_NUMBER           IN        NUMBER
, X_DELV_NUM_INCREMENT              IN        NUMBER
, X_DELV_NUM_WIDTH                  IN        NUMBER
, X_ATTRIBUTE_CATEGORY              IN        VARCHAR2
, X_ATTRIBUTE1                      IN        VARCHAR2
, X_ATTRIBUTE2                      IN        VARCHAR2
, X_ATTRIBUTE3                      IN        VARCHAR2
, X_ATTRIBUTE4                      IN        VARCHAR2
, X_ATTRIBUTE5                      IN        VARCHAR2
, X_ATTRIBUTE6                      IN        VARCHAR2
, X_ATTRIBUTE7                      IN        VARCHAR2
, X_ATTRIBUTE8                      IN        VARCHAR2
, X_ATTRIBUTE9                      IN        VARCHAR2
, X_ATTRIBUTE10                     IN        VARCHAR2
, X_ATTRIBUTE11                     IN        VARCHAR2
, X_ATTRIBUTE12                     IN        VARCHAR2
, X_ATTRIBUTE13                     IN        VARCHAR2
, X_ATTRIBUTE14                     IN        VARCHAR2
, X_ATTRIBUTE15                     IN        VARCHAR2
);

PROCEDURE LOCK_ROW
( X_ROWID                           IN        VARCHAR2
, X_K_TYPE_CODE                     IN        VARCHAR2
, X_BUY_OR_SELL                     IN        VARCHAR2
, X_CREATION_DATE                   IN        DATE
, X_CREATED_BY                      IN        NUMBER
, X_LAST_UPDATE_DATE                IN        DATE
, X_LAST_UPDATED_BY                 IN        NUMBER
, X_LAST_UPDATE_LOGIN               IN        NUMBER
, X_CONTRACT_NUM_MODE               IN        VARCHAR2
, X_MANUAL_CONTRACT_NUM_TYPE        IN        VARCHAR2
, X_NEXT_CONTRACT_NUM               IN        NUMBER
, X_CONTRACT_NUM_INCREMENT          IN        NUMBER
, X_CONTRACT_NUM_WIDTH              IN        NUMBER
, X_CHGREQ_NUM_MODE                 IN        VARCHAR2
, X_MANUAL_CHGREQ_NUM_TYPE          IN        VARCHAR2
, X_CHGREQ_NUM_START_NUMBER         IN        NUMBER
, X_CHGREQ_NUM_INCREMENT            IN        NUMBER
, X_CHGREQ_NUM_WIDTH                IN        NUMBER
, X_LINE_NUM_START_NUMBER           IN        NUMBER
, X_LINE_NUM_INCREMENT              IN        NUMBER
, X_LINE_NUM_WIDTH                  IN        NUMBER
, X_SUBLINE_NUM_START_NUMBER        IN        NUMBER
, X_SUBLINE_NUM_INCREMENT           IN        NUMBER
, X_SUBLINE_NUM_WIDTH               IN        NUMBER
, X_DELV_NUM_START_NUMBER           IN        NUMBER
, X_DELV_NUM_INCREMENT              IN        NUMBER
, X_DELV_NUM_WIDTH                  IN        NUMBER
, X_ATTRIBUTE_CATEGORY              IN        VARCHAR2
, X_ATTRIBUTE1                      IN        VARCHAR2
, X_ATTRIBUTE2                      IN        VARCHAR2
, X_ATTRIBUTE3                      IN        VARCHAR2
, X_ATTRIBUTE4                      IN        VARCHAR2
, X_ATTRIBUTE5                      IN        VARCHAR2
, X_ATTRIBUTE6                      IN        VARCHAR2
, X_ATTRIBUTE7                      IN        VARCHAR2
, X_ATTRIBUTE8                      IN        VARCHAR2
, X_ATTRIBUTE9                      IN        VARCHAR2
, X_ATTRIBUTE10                     IN        VARCHAR2
, X_ATTRIBUTE11                     IN        VARCHAR2
, X_ATTRIBUTE12                     IN        VARCHAR2
, X_ATTRIBUTE13                     IN        VARCHAR2
, X_ATTRIBUTE14                     IN        VARCHAR2
, X_ATTRIBUTE15                     IN        VARCHAR2
);

PROCEDURE UPDATE_ROW
( X_K_TYPE_CODE                     IN        VARCHAR2
, X_BUY_OR_SELL                     IN        VARCHAR2
, X_LAST_UPDATE_DATE                IN        DATE
, X_LAST_UPDATED_BY                 IN        NUMBER
, X_LAST_UPDATE_LOGIN               IN        NUMBER
, X_CONTRACT_NUM_MODE               IN        VARCHAR2
, X_MANUAL_CONTRACT_NUM_TYPE        IN        VARCHAR2
, X_NEXT_CONTRACT_NUM               IN        NUMBER
, X_CONTRACT_NUM_INCREMENT          IN        NUMBER
, X_CONTRACT_NUM_WIDTH              IN        NUMBER
, X_CHGREQ_NUM_MODE                 IN        VARCHAR2
, X_MANUAL_CHGREQ_NUM_TYPE          IN        VARCHAR2
, X_CHGREQ_NUM_START_NUMBER         IN        NUMBER
, X_CHGREQ_NUM_INCREMENT            IN        NUMBER
, X_CHGREQ_NUM_WIDTH                IN        NUMBER
, X_LINE_NUM_START_NUMBER           IN        NUMBER
, X_LINE_NUM_INCREMENT              IN        NUMBER
, X_LINE_NUM_WIDTH                  IN        NUMBER
, X_SUBLINE_NUM_START_NUMBER        IN        NUMBER
, X_SUBLINE_NUM_INCREMENT           IN        NUMBER
, X_SUBLINE_NUM_WIDTH               IN        NUMBER
, X_DELV_NUM_START_NUMBER           IN        NUMBER
, X_DELV_NUM_INCREMENT              IN        NUMBER
, X_DELV_NUM_WIDTH                  IN        NUMBER
, X_ATTRIBUTE_CATEGORY              IN        VARCHAR2
, X_ATTRIBUTE1                      IN        VARCHAR2
, X_ATTRIBUTE2                      IN        VARCHAR2
, X_ATTRIBUTE3                      IN        VARCHAR2
, X_ATTRIBUTE4                      IN        VARCHAR2
, X_ATTRIBUTE5                      IN        VARCHAR2
, X_ATTRIBUTE6                      IN        VARCHAR2
, X_ATTRIBUTE7                      IN        VARCHAR2
, X_ATTRIBUTE8                      IN        VARCHAR2
, X_ATTRIBUTE9                      IN        VARCHAR2
, X_ATTRIBUTE10                     IN        VARCHAR2
, X_ATTRIBUTE11                     IN        VARCHAR2
, X_ATTRIBUTE12                     IN        VARCHAR2
, X_ATTRIBUTE13                     IN        VARCHAR2
, X_ATTRIBUTE14                     IN        VARCHAR2
, X_ATTRIBUTE15                     IN        VARCHAR2
);

END OKE_NUMBER_OPTIONS_PKG;

 

/
