--------------------------------------------------------
--  DDL for Package AP_CALC_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CALC_WITHHOLDING_PKG" AUTHID CURRENT_USER as
/* $Header: apclawts.pls 120.7.12010000.2 2008/09/09 10:07:28 njakkula ship $ */

-- ====================================================================
--          P R I V A T E - G L O B A L V A R I A B L E S
-- ====================================================================
-- Added for Bug 7232736
     g_org_id           NUMBER(15); /* Bug3700128. MOAC Project */

PROCEDURE AP_Calculate_AWT_Amounts (
          P_Invoice_Id              IN     NUMBER,
          P_Awt_Date                IN     DATE,
          P_Calling_Module          IN     VARCHAR2,
          P_Create_Dists            IN     VARCHAR2,
          P_Amount                  IN     NUMBER,
          P_Payment_Num             IN     NUMBER,
          P_Checkrun_Name           IN     VARCHAR2,
          P_Last_Updated_By         IN     NUMBER,
          P_Last_Update_Login       IN     NUMBER,
          P_Program_Application_Id  IN     NUMBER,
          P_Program_Id              IN     NUMBER,
          P_Request_Id              IN     NUMBER,
          P_AWT_Success             IN OUT NOCOPY VARCHAR2,
          P_Calling_Sequence        IN     VARCHAR2,
          P_Invoice_Payment_Id      IN     NUMBER DEFAULT NULL,
          p_checkrun_id             in     number default null,
          p_org_id                  in     number default null);

PROCEDURE Handle_Bucket (
          P_Awt_Period_Name         IN     VARCHAR2,
          P_Amount_Subject          IN     NUMBER,
          P_Amount_Withheld         IN     NUMBER,
          P_Vendor_Id               IN     NUMBER,
          P_Tax_Name                IN     VARCHAR2,
          P_Calling_Module          IN     VARCHAR2,
          P_Last_Updated_By         IN     NUMBER,
          P_Last_Update_Login       IN     NUMBER,
          P_Program_Application_Id  IN     NUMBER,
          P_Program_Id              IN     NUMBER,
          P_Request_Id              IN     NUMBER,
          P_Calling_Sequence        IN     VARCHAR2);

PROCEDURE Insert_Temp_Distribution(
          InvoiceId                 IN     NUMBER,
          SuppId                    IN     NUMBER,
          PaymentNum                IN     NUMBER,
          GroupId                   IN     NUMBER,
          TaxName                   IN     VARCHAR2,
          CodeCombinationId         IN     NUMBER,
          GrossAmount               IN     NUMBER,
          WithheldAmount            IN     NUMBER,
          AwtDate                   IN     DATE,
          GLPeriodName              IN     VARCHAR2,
          AwtPeriodType             IN     VARCHAR2,
          AwtPeriodName             IN     VARCHAR2,
	 -- P_Awt_Related_Id	    IN	   NUMBER  DEFAULT NULL, --Bug 6168793
          CheckrunName              IN     VARCHAR2,
          WithheldRateId            IN     NUMBER,
          ExchangeRate              IN     NUMBER,
          CurrCode                  IN     VARCHAR2,
          BaseCurrCode              IN     VARCHAR2,
          auto_offset_segs          IN     VARCHAR2,
          P_Calling_Sequence        IN     VARCHAR2,
          HandleBucket              IN     VARCHAR2 DEFAULT 'N',
          LastUpdatedBy             IN     NUMBER   DEFAULT NULL,
          LastUpdateLogin           IN     NUMBER   DEFAULT NULL,
          ProgramApplicationId      IN     NUMBER   DEFAULT NULL,
          ProgramId                 IN     NUMBER   DEFAULT NULL,
          RequestId                 IN     NUMBER   DEFAULT NULL,
          CallingModule             IN     VARCHAR2 DEFAULT NULL,
          P_Invoice_Payment_Id      IN     NUMBER   DEFAULT NULL,
          invoice_exchange_rate     IN     NUMBER   DEFAULT NULL,
          GLOBAL_ATTRIBUTE_CATEGORY IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE1         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE2         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE3         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE4         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE5         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE6         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE7         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE8         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE9         IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE10        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE11        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE12        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE13        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE14        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE15        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE16        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE17        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE18        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE19        IN     VARCHAR2 DEFAULT NULL,
          GLOBAL_ATTRIBUTE20        IN     VARCHAR2 DEFAULT NULL,
          p_checkrun_id             in     number   default null,
          P_Awt_Related_Id          IN     NUMBER  DEFAULT NULL    --bug6524425
          );

END AP_CALC_WITHHOLDING_PKG;

/
