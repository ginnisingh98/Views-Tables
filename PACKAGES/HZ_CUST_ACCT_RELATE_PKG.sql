--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_RELATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_RELATE_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHAARTS.pls 120.6 2005/08/22 06:34:59 idali ship $ */

PROCEDURE Insert_Row (
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_COMMENTS                              IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_CUSTOMER_RECIPROCAL_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_BILL_TO_FLAG                          IN     VARCHAR2,
    X_SHIP_TO_FLAG                          IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,  /* Bug 3456489 */
    X_CUST_ACCT_RELATE_ID                   IN OUT NOCOPY NUMBER   /* Bug 4529413 */
);

PROCEDURE Update_Row (
    X_CUST_ACCT_RELATE_ID                   IN OUT NOCOPY NUMBER,  /* Bug 4529413 */
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_COMMENTS                              IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_CUSTOMER_RECIPROCAL_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_BILL_TO_FLAG                          IN     VARCHAR2,
    X_SHIP_TO_FLAG                          IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_COMMENTS                              IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_CUSTOMER_RECIPROCAL_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_BILL_TO_FLAG                          IN     VARCHAR2,
    X_SHIP_TO_FLAG                          IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_CUST_ACCOUNT_ID                       IN OUT NOCOPY NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN OUT NOCOPY NUMBER,
    X_RELATIONSHIP_TYPE                     OUT NOCOPY    VARCHAR2,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE1                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE2                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE3                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE4                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE5                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE6                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE7                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE8                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE9                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE10                           OUT NOCOPY    VARCHAR2,
    X_CUSTOMER_RECIPROCAL_FLAG              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_BILL_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_SHIP_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ORG_ID                                IN OUT NOCOPY NUMBER,   /* Bug 3456489 */
    X_CUST_ACCT_RELATE_ID                   IN OUT NOCOPY NUMBER    -- Bug 4529413
);

PROCEDURE Select_Row (
    X_CUST_ACCOUNT_ID                       OUT NOCOPY    NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               OUT NOCOPY    NUMBER,
    X_RELATIONSHIP_TYPE                     OUT NOCOPY    VARCHAR2,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE1                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE2                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE3                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE4                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE5                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE6                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE7                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE8                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE9                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE10                           OUT NOCOPY    VARCHAR2,
    X_CUSTOMER_RECIPROCAL_FLAG              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_BILL_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_SHIP_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ORG_ID                                OUT NOCOPY    NUMBER,   /* Bug 3456489 */
    X_CUST_ACCT_RELATE_ID                   OUT NOCOPY    NUMBER,   -- Bug 4529413
    X_ROWID                                 IN            ROWID
);


PROCEDURE Delete_Row (
    X_ROWID                                 IN     ROWID
);

END HZ_CUST_ACCT_RELATE_PKG;

 

/
