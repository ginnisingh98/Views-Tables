--------------------------------------------------------
--  DDL for Package PJM_PROJECT_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PROJECT_PARAMS_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMPPRMS.pls 115.1 2002/10/29 20:13:53 alaw noship $ */

PROCEDURE insert_row
( X_ROWID                        IN OUT NOCOPY VARCHAR2
, X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
, X_SEIBAN_NUMBER_FLAG           IN     NUMBER
, X_COSTING_GROUP_ID             IN     NUMBER
, X_PLANNING_GROUP               IN     VARCHAR2
, X_WIP_ACCT_CLASS_CODE          IN     VARCHAR2
, X_EAM_ACCT_CLASS_CODE          IN     VARCHAR2
, X_START_DATE_ACTIVE            IN     DATE
, X_END_DATE_ACTIVE              IN     DATE
, X_IPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_ERV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_FREIGHT_EXPENDITURE_TYPE     IN     VARCHAR2
, X_TAX_EXPENDITURE_TYPE         IN     VARCHAR2
, X_MISC_EXPENDITURE_TYPE        IN     VARCHAR2
, X_PPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_DIR_ITEM_EXPENDITURE_TYPE    IN     VARCHAR2
, X_ATTRIBUTE_CATEGORY           IN     VARCHAR2
, X_ATTRIBUTE1                   IN     VARCHAR2
, X_ATTRIBUTE2                   IN     VARCHAR2
, X_ATTRIBUTE3                   IN     VARCHAR2
, X_ATTRIBUTE4                   IN     VARCHAR2
, X_ATTRIBUTE5                   IN     VARCHAR2
, X_ATTRIBUTE6                   IN     VARCHAR2
, X_ATTRIBUTE7                   IN     VARCHAR2
, X_ATTRIBUTE8                   IN     VARCHAR2
, X_ATTRIBUTE9                   IN     VARCHAR2
, X_ATTRIBUTE10                  IN     VARCHAR2
, X_ATTRIBUTE11                  IN     VARCHAR2
, X_ATTRIBUTE12                  IN     VARCHAR2
, X_ATTRIBUTE13                  IN     VARCHAR2
, X_ATTRIBUTE14                  IN     VARCHAR2
, X_ATTRIBUTE15                  IN     VARCHAR2
, X_CREATION_DATE                IN     DATE
, X_CREATED_BY                   IN     NUMBER
, X_LAST_UPDATE_DATE             IN     DATE
, X_LAST_UPDATED_BY              IN     NUMBER
, X_LAST_UPDATE_LOGIN            IN     NUMBER
);

PROCEDURE lock_row
( X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
, X_COSTING_GROUP_ID             IN     NUMBER
, X_WIP_ACCT_CLASS_CODE          IN     VARCHAR2
, X_EAM_ACCT_CLASS_CODE          IN     VARCHAR2
, X_START_DATE_ACTIVE            IN     DATE
, X_END_DATE_ACTIVE              IN     DATE
, X_IPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_ERV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_FREIGHT_EXPENDITURE_TYPE     IN     VARCHAR2
, X_TAX_EXPENDITURE_TYPE         IN     VARCHAR2
, X_MISC_EXPENDITURE_TYPE        IN     VARCHAR2
, X_PPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_DIR_ITEM_EXPENDITURE_TYPE    IN     VARCHAR2
, X_ATTRIBUTE_CATEGORY           IN     VARCHAR2
, X_ATTRIBUTE1                   IN     VARCHAR2
, X_ATTRIBUTE2                   IN     VARCHAR2
, X_ATTRIBUTE3                   IN     VARCHAR2
, X_ATTRIBUTE4                   IN     VARCHAR2
, X_ATTRIBUTE5                   IN     VARCHAR2
, X_ATTRIBUTE6                   IN     VARCHAR2
, X_ATTRIBUTE7                   IN     VARCHAR2
, X_ATTRIBUTE8                   IN     VARCHAR2
, X_ATTRIBUTE9                   IN     VARCHAR2
, X_ATTRIBUTE10                  IN     VARCHAR2
, X_ATTRIBUTE11                  IN     VARCHAR2
, X_ATTRIBUTE12                  IN     VARCHAR2
, X_ATTRIBUTE13                  IN     VARCHAR2
, X_ATTRIBUTE14                  IN     VARCHAR2
, X_ATTRIBUTE15                  IN     VARCHAR2
);

PROCEDURE update_row
( X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
, X_COSTING_GROUP_ID             IN     NUMBER
, X_WIP_ACCT_CLASS_CODE          IN     VARCHAR2
, X_EAM_ACCT_CLASS_CODE          IN     VARCHAR2
, X_START_DATE_ACTIVE            IN     DATE
, X_END_DATE_ACTIVE              IN     DATE
, X_IPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_ERV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_FREIGHT_EXPENDITURE_TYPE     IN     VARCHAR2
, X_TAX_EXPENDITURE_TYPE         IN     VARCHAR2
, X_MISC_EXPENDITURE_TYPE        IN     VARCHAR2
, X_PPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_DIR_ITEM_EXPENDITURE_TYPE    IN     VARCHAR2
, X_ATTRIBUTE_CATEGORY           IN     VARCHAR2
, X_ATTRIBUTE1                   IN     VARCHAR2
, X_ATTRIBUTE2                   IN     VARCHAR2
, X_ATTRIBUTE3                   IN     VARCHAR2
, X_ATTRIBUTE4                   IN     VARCHAR2
, X_ATTRIBUTE5                   IN     VARCHAR2
, X_ATTRIBUTE6                   IN     VARCHAR2
, X_ATTRIBUTE7                   IN     VARCHAR2
, X_ATTRIBUTE8                   IN     VARCHAR2
, X_ATTRIBUTE9                   IN     VARCHAR2
, X_ATTRIBUTE10                  IN     VARCHAR2
, X_ATTRIBUTE11                  IN     VARCHAR2
, X_ATTRIBUTE12                  IN     VARCHAR2
, X_ATTRIBUTE13                  IN     VARCHAR2
, X_ATTRIBUTE14                  IN     VARCHAR2
, X_ATTRIBUTE15                  IN     VARCHAR2
, X_LAST_UPDATE_DATE             IN     DATE
, X_LAST_UPDATED_BY              IN     NUMBER
, X_LAST_UPDATE_LOGIN            IN     NUMBER
);

PROCEDURE delete_row
( X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
);

PROCEDURE update_planning_group
( X_PROJECT_ID                   IN     NUMBER
, X_PLANNING_GROUP               IN     VARCHAR2
);

END;

 

/
