--------------------------------------------------------
--  DDL for Package PNT_PAYMENT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_PAYMENT_ITEMS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTPYITS.pls 120.0 2005/05/29 11:24:02 appldev noship $

PROCEDURE Insert_Row (
              X_ROWID                          IN OUT NOCOPY VARCHAR2,
              X_PAYMENT_ITEM_ID                IN OUT NOCOPY NUMBER,
              X_DUE_DATE                       IN     DATE,
              X_SET_OF_BOOKS_ID                IN     NUMBER,
              X_CURRENCY_CODE                  IN     VARCHAR2,
              X_EXPORT_CURRENCY_CODE           IN     VARCHAR2,
              X_RATE                           IN     NUMBER,
              X_PMT_ITEM_TYPE_LOOKUP_CODE      IN     VARCHAR2,
              X_PAYMENT_SCHEDULE_ID            IN     NUMBER,
              X_PAYMENT_TERM_ID                IN OUT NOCOPY NUMBER,
              X_VENDOR_ID                      IN     NUMBER   DEFAULT NULL,
              X_CUSTOMER_ID                    IN     NUMBER   DEFAULT NULL,
              X_VENDOR_SITE_ID                 IN     NUMBER   DEFAULT NULL,
              X_CUSTOMER_SITE_USE_ID           IN     NUMBER   DEFAULT NULL,
              X_ACTUAL_AMOUNT                  IN     NUMBER,
              X_ACCOUNTED_AMOUNT               IN     NUMBER   DEFAULT NULL,
              X_ACCOUNTED_DATE                 IN     DATE     DEFAULT NULL,
              X_EXPORT_CURRENCY_AMOUNT         IN     NUMBER,
              X_ESTIMATED_AMOUNT               IN     NUMBER,
              X_CREATION_DATE                  IN     DATE,
              X_CREATED_BY                     IN     NUMBER,
              X_LAST_UPDATE_DATE               IN     DATE,
              X_LAST_UPDATED_BY                IN     NUMBER,
              X_LAST_UPDATE_LOGIN              IN     NUMBER,
              X_ENTERED_BY_LEASE               IN     VARCHAR2,
              X_EXPORT_TO_AP_FLAG              IN     VARCHAR2 DEFAULT NULL,
              X_EXPORT_TO_AR_FLAG              IN     VARCHAR2 DEFAULT NULL,
              X_CUST_SHIP_SITE_ID              IN     NUMBER   DEFAULT NULL,
              x_org_id                         IN     NUMBER,
              x_comments                       IN     VARCHAR2 DEFAULT NULL,
              x_AP_INVOICE_NUM                 IN     VARCHAR2 DEFAULT NULL,
              x_GROUPING_RULE_ID               IN     NUMBER   DEFAULT NULL,
              x_ADJ_START_DATE                 IN     DATE     DEFAULT NULL,
              x_ADJ_END_DATE                   IN     DATE     DEFAULT NULL,
              x_LAST_ADJUSTMENT_TYPE_CODE      IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE_CATEGORY             IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE1                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE2                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE3                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE4                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE5                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE6                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE7                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE8                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE9                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE10                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE11                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE12                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE13                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE14                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE15                    IN     VARCHAR2 DEFAULT NULL
                     );

PROCEDURE Lock_Row   (
              X_PAYMENT_ITEM_ID                IN     NUMBER,
              X_ESTIMATED_AMOUNT               IN     NUMBER,
              X_ACTUAL_AMOUNT                  IN     NUMBER,
              X_PAYMENT_SCHEDULE_ID            IN     NUMBER,
              X_DUE_DATE                       IN     DATE,
              X_RATE                           IN     NUMBER,
              X_COMMENTS                       IN     VARCHAR2,
              x_AP_INVOICE_NUM                 IN     VARCHAR2 DEFAULT NULL,
              x_GROUPING_RULE_ID               IN     NUMBER   DEFAULT NULL,
              x_ADJ_START_DATE                 IN     DATE     DEFAULT NULL,
              x_ADJ_END_DATE                   IN     DATE     DEFAULT NULL,
              x_LAST_ADJUSTMENT_TYPE_CODE      IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE_CATEGORY             IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE1                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE2                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE3                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE4                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE5                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE6                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE7                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE8                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE9                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE10                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE11                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE12                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE13                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE14                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE15                    IN     VARCHAR2 DEFAULT NULL
                      );

PROCEDURE Update_Row (
              X_PAYMENT_ITEM_ID                IN     NUMBER,
              X_DUE_DATE                       IN     DATE,
              X_VENDOR_ID                      IN     NUMBER   DEFAULT NULL,
              X_CUSTOMER_ID                    IN     NUMBER   DEFAULT NULL,
              X_VENDOR_SITE_ID                 IN     NUMBER   DEFAULT NULL,
              X_CUSTOMER_SITE_USE_ID           IN     NUMBER   DEFAULT NULL,
              X_ESTIMATED_AMOUNT               IN     NUMBER,
              X_ACTUAL_AMOUNT                  IN     NUMBER,
              X_ACCOUNTED_AMOUNT               IN     NUMBER   DEFAULT NULL,
              X_ACCOUNTED_DATE                 IN     DATE     DEFAULT NULL,
              X_EXPORT_CURRENCY_AMOUNT         IN     NUMBER,
              X_LAST_UPDATE_DATE               IN     DATE,
              X_LAST_UPDATED_BY                IN     NUMBER,
              X_LAST_UPDATE_LOGIN              IN     NUMBER,
              X_PAYMENT_SCHEDULE_ID            IN     NUMBER,
              X_ENTERED_BY_LEASE               IN     VARCHAR2,
              X_EXPORT_TO_AP_FLAG              IN     VARCHAR2 DEFAULT NULL,
              X_EXPORT_TO_AR_FLAG              IN     VARCHAR2 DEFAULT NULL,
              X_CUST_SHIP_SITE_ID              IN     NUMBER   DEFAULT NULL,
              X_RATE                           IN     NUMBER,
              x_comments                       IN     VARCHAR2 DEFAULT NULL,
              x_AP_INVOICE_NUM                 IN     VARCHAR2 DEFAULT NULL,
              x_GROUPING_RULE_ID               IN     NUMBER   DEFAULT NULL,
              x_ADJ_START_DATE                 IN     DATE     DEFAULT NULL,
              x_ADJ_END_DATE                   IN     DATE     DEFAULT NULL,
              x_LAST_ADJUSTMENT_TYPE_CODE      IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE_CATEGORY             IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE1                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE2                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE3                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE4                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE5                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE6                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE7                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE8                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE9                     IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE10                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE11                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE12                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE13                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE14                    IN     VARCHAR2 DEFAULT NULL,
              x_ATTRIBUTE15                    IN     VARCHAR2 DEFAULT NULL
                     );

PROCEDURE Delete_Row (
              X_PAYMENT_ITEM_ID                IN     NUMBER
                     );

END pnt_payment_items_pkg;

 

/