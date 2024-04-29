--------------------------------------------------------
--  DDL for Package PA_AGREEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AGREEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAINAGRS.pls 120.3 2007/02/07 10:43:40 rgandhi ship $ */


  PROCEDURE Insert_Row(
             X_Rowid                      IN OUT   NOCOPY VARCHAR2,/*File.sql.39*/
             X_Agreement_Id               IN OUT   NOCOPY NUMBER,/*File.sql.39*/
             X_Customer_Id                IN       NUMBER,
             X_Agreement_Num              IN       VARCHAR2,
             X_Agreement_Type             IN       VARCHAR2,
             X_Last_Update_Date           IN       DATE,
             X_Last_Updated_By            IN       NUMBER,
             X_Creation_Date              IN       DATE,
             X_Created_By                 IN       NUMBER,
             X_Last_Update_Login          IN       NUMBER,
             X_Owned_By_Person_Id         IN       NUMBER,
             X_Term_Id                    IN       NUMBER,
             X_Revenue_Limit_Flag         IN       VARCHAR2,
             X_Amount                     IN       NUMBER,
             X_Description                IN       VARCHAR2,
             X_Expiration_Date            IN       DATE,
             X_Attribute_Category         IN       VARCHAR2,
             X_Attribute1                 IN       VARCHAR2,
             X_Attribute2                 IN       VARCHAR2,
             X_Attribute3                 IN       VARCHAR2,
             X_Attribute4                 IN       VARCHAR2,
             X_Attribute5                 IN       VARCHAR2,
             X_Attribute6                 IN       VARCHAR2,
             X_Attribute7                 IN       VARCHAR2,
             X_Attribute8                 IN       VARCHAR2,
             X_Attribute9                 IN       VARCHAR2,
             X_Attribute10                IN       VARCHAR2,
             X_Template_Flag	          IN       VARCHAR2,
             X_Pm_agreement_reference     IN       VARCHAR2,
             X_Pm_Product_Code            IN       VARCHAR2,
             X_owning_organization_id     IN       NUMBER,
             x_agreement_currency_code    IN       VARCHAR2,
             x_invoice_limit_flag         IN       VARCHAR2,
	     X_org_id                     IN       NUMBER,/* Added for shared Services*/
/*Federal*/
             X_customer_order_number      IN       VARCHAR2 DEFAULT NULL,
             X_ADVANCE_REQUIRED           IN       VARCHAR2 DEFAULT 'N',
             X_start_date                 IN       DATE     DEFAULT NULL,
             X_Billing_sequence           IN       NUMBER   DEFAULT NULL,
             X_line_of_account            IN       VARCHAR2 DEFAULT NULL,
             X_payment_set_id             IN       NUMBER   DEFAULT NULL,
	     X_advance_amount             IN       NUMBER   DEFAULT NULL,
             X_attribute11                IN       VARCHAR2 DEFAULT NULL,
             X_attribute12                IN       VARCHAR2 DEFAULT NULL,
             X_attribute13                IN       VARCHAR2 DEFAULT NULL,
             X_attribute14                IN       VARCHAR2 DEFAULT NULL,
             X_attribute15                IN       VARCHAR2 DEFAULT NULL,
             X_attribute16                IN       VARCHAR2 DEFAULT NULL,
             X_attribute17                IN       VARCHAR2 DEFAULT NULL,
             X_attribute18                IN       VARCHAR2 DEFAULT NULL,
             X_attribute19                IN       VARCHAR2 DEFAULT NULL,
             X_attribute20                IN       VARCHAR2 DEFAULT NULL,
             X_attribute21                IN       VARCHAR2 DEFAULT NULL,
             X_attribute22                IN       VARCHAR2 DEFAULT NULL,
             X_attribute23                IN       VARCHAR2 DEFAULT NULL,
             X_attribute24                IN       VARCHAR2 DEFAULT NULL,
             X_attribute25                IN       VARCHAR2 DEFAULT NULL
                      );

  PROCEDURE Lock_Row(
             X_Rowid                      IN       VARCHAR2,
             X_Agreement_Id               IN       NUMBER,
             X_Customer_Id                IN       NUMBER,
             X_Agreement_Num              IN       VARCHAR2,
             X_Agreement_Type             IN       VARCHAR2,
             X_Owned_By_Person_Id         IN       NUMBER,
             X_Term_Id                    IN       NUMBER,
             X_Revenue_Limit_Flag         IN       VARCHAR2,
             X_Amount                     IN       NUMBER,
             X_Description                IN       VARCHAR2,
             X_Expiration_Date            IN       DATE,
             X_Attribute_Category         IN       VARCHAR2,
             X_Attribute1                 IN       VARCHAR2,
             X_Attribute2                 IN       VARCHAR2,
             X_Attribute3                 IN       VARCHAR2,
             X_Attribute4                 IN       VARCHAR2,
             X_Attribute5                 IN       VARCHAR2,
             X_Attribute6                 IN       VARCHAR2,
             X_Attribute7                 IN       VARCHAR2,
             X_Attribute8                 IN       VARCHAR2,
             X_Attribute9                 IN       VARCHAR2,
             X_Attribute10                IN       VARCHAR2,
             X_Template_Flag	          IN       VARCHAR2,
             X_Pm_agreement_reference     IN       VARCHAR2,
             X_Pm_Product_Code            IN       VARCHAR2,
             X_owning_organization_id     IN       NUMBER,
             x_agreement_currency_code    IN       VARCHAR2,
             x_invoice_limit_flag         IN       VARCHAR2,
/*Federal*/
             X_customer_order_number      IN       VARCHAR2 DEFAULT NULL,
             X_ADVANCE_REQUIRED           IN       VARCHAR2 DEFAULT NULL,
             X_start_date                 IN       DATE     DEFAULT NULL,
             X_Billing_sequence           IN       NUMBER   DEFAULT NULL,
             X_line_of_account            IN       VARCHAR2 DEFAULT NULL,
             X_payment_set_id             IN       NUMBER   DEFAULT NULL,
             X_advance_amount             IN       NUMBER   DEFAULT NULL,
             X_attribute11                IN       VARCHAR2 DEFAULT NULL,
             X_attribute12                IN       VARCHAR2 DEFAULT NULL,
             X_attribute13                IN       VARCHAR2 DEFAULT NULL,
             X_attribute14                IN       VARCHAR2 DEFAULT NULL,
             X_attribute15                IN       VARCHAR2 DEFAULT NULL,
             X_attribute16                IN       VARCHAR2 DEFAULT NULL,
             X_attribute17                IN       VARCHAR2 DEFAULT NULL,
             X_attribute18                IN       VARCHAR2 DEFAULT NULL,
             X_attribute19                IN       VARCHAR2 DEFAULT NULL,
             X_attribute20                IN       VARCHAR2 DEFAULT NULL,
             X_attribute21                IN       VARCHAR2 DEFAULT NULL,
             X_attribute22                IN       VARCHAR2 DEFAULT NULL,
             X_attribute23                IN       VARCHAR2 DEFAULT NULL,
             X_attribute24                IN       VARCHAR2 DEFAULT NULL,
             X_attribute25                IN       VARCHAR2 DEFAULT NULL
             );


  PROCEDURE Update_Row(
X_Rowid                    IN       VARCHAR2,
X_Agreement_Id             IN       NUMBER,
X_Customer_Id              IN       NUMBER,
X_Agreement_Num            IN       VARCHAR2,
X_Agreement_Type           IN       VARCHAR2,
X_Last_Update_Date         IN       DATE,
X_Last_Updated_By          IN       NUMBER,
X_Last_Update_Login        IN       NUMBER,
X_Owned_By_Person_Id       IN       NUMBER,
X_Term_Id                  IN       NUMBER,
X_Revenue_Limit_Flag       IN       VARCHAR2,
X_Amount                   IN       NUMBER,
X_Description              IN       VARCHAR2,
X_Expiration_Date          IN       DATE,
X_Attribute_Category       IN       VARCHAR2,
X_Attribute1               IN       VARCHAR2,
X_Attribute2               IN       VARCHAR2,
X_Attribute3               IN       VARCHAR2,
X_Attribute4               IN       VARCHAR2,
X_Attribute5               IN       VARCHAR2,
X_Attribute6               IN       VARCHAR2,
X_Attribute7               IN       VARCHAR2,
X_Attribute8               IN       VARCHAR2,
X_Attribute9               IN       VARCHAR2,
X_Attribute10              IN       VARCHAR2,
X_Template_Flag	           IN       VARCHAR2,
X_Pm_agreement_reference   IN       VARCHAR2,
X_Pm_Product_Code          IN       VARCHAR2,
X_owning_organization_id   IN       NUMBER,
x_agreement_currency_code  IN       VARCHAR2,
x_invoice_limit_flag       IN       VARCHAR2,
/*Federal*/
x_customer_order_number    IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_advance_required         IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_start_date               IN       DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
x_Billing_sequence         IN       NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
x_line_of_account          IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_payment_set_id           IN       NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
x_advance_amount           IN       NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
x_attribute11              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute12              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute13              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute14              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute15              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute16              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute17              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute18              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute19              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute20              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute21              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute22              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute23              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute24              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute25              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

             );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PA_AGREEMENTS_PKG;

/