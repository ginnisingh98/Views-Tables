--------------------------------------------------------
--  DDL for Package HZ_PAYMENT_METHOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PAYMENT_METHOD_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPYMTS.pls 120.0 2005/07/06 21:13:00 acng noship $*/
PROCEDURE Insert_Row(
    x_cust_receipt_method_id         IN OUT NOCOPY NUMBER,
    x_customer_id                    IN NUMBER,
    x_receipt_method_id              IN NUMBER,
    x_primary_flag                   IN VARCHAR2,
    x_site_use_id                    IN NUMBER,
    x_start_date                     IN DATE,
    x_end_date                       IN DATE,
    x_attribute_category             IN VARCHAR2,
    x_attribute1                     IN VARCHAR2,
    x_attribute2                     IN VARCHAR2,
    x_attribute3                     IN VARCHAR2,
    x_attribute4                     IN VARCHAR2,
    x_attribute5                     IN VARCHAR2,
    x_attribute6                     IN VARCHAR2,
    x_attribute7                     IN VARCHAR2,
    x_attribute8                     IN VARCHAR2,
    x_attribute9                     IN VARCHAR2,
    x_attribute10                    IN VARCHAR2,
    x_attribute11                    IN VARCHAR2,
    x_attribute12                    IN VARCHAR2,
    x_attribute13                    IN VARCHAR2,
    x_attribute14                    IN VARCHAR2,
    x_attribute15                    IN VARCHAR2
);

PROCEDURE Lock_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_cust_receipt_method_id         IN NUMBER,
    x_customer_id                    IN NUMBER,
    x_receipt_method_id              IN NUMBER,
    x_primary_flag                   IN VARCHAR2,
    x_site_use_id                    IN NUMBER,
    x_start_date                     IN DATE,
    x_end_date                       IN DATE,
    x_attribute_category             IN VARCHAR2,
    x_attribute1                     IN VARCHAR2,
    x_attribute2                     IN VARCHAR2,
    x_attribute3                     IN VARCHAR2,
    x_attribute4                     IN VARCHAR2,
    x_attribute5                     IN VARCHAR2,
    x_attribute6                     IN VARCHAR2,
    x_attribute7                     IN VARCHAR2,
    x_attribute8                     IN VARCHAR2,
    x_attribute9                     IN VARCHAR2,
    x_attribute10                    IN VARCHAR2,
    x_attribute11                    IN VARCHAR2,
    x_attribute12                    IN VARCHAR2,
    x_attribute13                    IN VARCHAR2,
    x_attribute14                    IN VARCHAR2,
    x_attribute15                    IN VARCHAR2,
    x_last_update_date               IN DATE,
    x_last_updated_by                IN NUMBER,
    x_creation_date                  IN DATE,
    x_created_by                     IN NUMBER,
    x_last_update_login              IN NUMBER,
    x_request_id                     IN NUMBER,
    x_program_application_id         IN NUMBER,
    x_program_id                     IN NUMBER,
    x_program_update_date            IN DATE
);

PROCEDURE Update_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_cust_receipt_method_id         IN NUMBER,
    x_customer_id                    IN NUMBER,
    x_receipt_method_id              IN NUMBER,
    x_primary_flag                   IN VARCHAR2,
    x_site_use_id                    IN NUMBER,
    x_start_date                     IN DATE,
    x_end_date                       IN DATE,
    x_attribute_category             IN VARCHAR2,
    x_attribute1                     IN VARCHAR2,
    x_attribute2                     IN VARCHAR2,
    x_attribute3                     IN VARCHAR2,
    x_attribute4                     IN VARCHAR2,
    x_attribute5                     IN VARCHAR2,
    x_attribute6                     IN VARCHAR2,
    x_attribute7                     IN VARCHAR2,
    x_attribute8                     IN VARCHAR2,
    x_attribute9                     IN VARCHAR2,
    x_attribute10                    IN VARCHAR2,
    x_attribute11                    IN VARCHAR2,
    x_attribute12                    IN VARCHAR2,
    x_attribute13                    IN VARCHAR2,
    x_attribute14                    IN VARCHAR2,
    x_attribute15                    IN VARCHAR2
);

PROCEDURE Delete_Row( x_cust_receipt_method_id   IN NUMBER);

END HZ_PAYMENT_METHOD_PKG;

 

/
