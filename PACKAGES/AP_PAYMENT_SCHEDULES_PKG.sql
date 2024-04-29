--------------------------------------------------------
--  DDL for Package AP_PAYMENT_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PAYMENT_SCHEDULES_PKG" AUTHID CURRENT_USER AS
/* $Header: apipascs.pls 120.5.12010000.3 2009/10/06 05:41:11 rseeta ship $ */

  PROCEDURE adjust_pay_schedule (X_invoice_id          IN number,
                                 X_invoice_amount      IN number,
                                 X_payment_status_flag IN OUT NOCOPY varchar2,
                                 X_invoice_type_lookup_code IN varchar2,
                                 X_last_updated_by     IN number,
                                 X_message1            IN OUT NOCOPY varchar2,
                                 X_message2            IN OUT NOCOPY varchar2,
                                 X_reset_match_status  IN OUT NOCOPY varchar2,
                                 X_liability_adjusted_flag IN OUT NOCOPY varchar2,
                                 X_calling_sequence    IN varchar2,
				 X_calling_mode        IN varchar2,
                                 x_revalidate_ps       IN OUT NOCOPY varchar2);

  --Bug 3484292, function added to get amount withheld per schedule
  FUNCTION get_amt_withheld_per_sched(X_invoice_id	       IN NUMBER,
                                      X_gross_amount           IN NUMBER,
   				      X_currency_code          IN VARCHAR2)
  RETURN NUMBER;

  FUNCTION get_discount_available(X_invoice_id	       IN NUMBER,
				  X_payment_num	       IN NUMBER,
				  X_check_date	       IN DATE,
				  X_currency_code      IN VARCHAR2)
    RETURN NUMBER;
--  PRAGMA restrict_references(get_discount_available, WNDS, WNPS, RNPS);

  FUNCTION get_discount_date(X_invoice_id	       IN NUMBER,
			     X_payment_num	       IN NUMBER,
			     X_check_date	       IN DATE)
    RETURN DATE;
  PRAGMA restrict_references(get_discount_date, WNDS, WNPS, RNPS);


  PROCEDURE Lock_Row(	X_Invoice_Id                               NUMBER,
			X_Last_Updated_By                          NUMBER,
			X_Last_Update_Date                         DATE,
			X_Payment_Cross_Rate                       NUMBER,
			X_Payment_Num                              NUMBER,
			X_Amount_Remaining                         NUMBER,
			X_Created_By                               NUMBER,
			X_Creation_Date                            DATE,
			X_Discount_Date                            DATE,
			X_Due_Date                                 DATE,
			X_Future_Pay_Due_Date                      DATE,
			X_Gross_Amount                             NUMBER,
			X_Hold_Flag                                VARCHAR2,
			X_iby_hold_reason                          VARCHAR2, /*bug 8893354*/
			X_Last_Update_Login                        NUMBER,
			X_Payment_Method_Lookup_Code               VARCHAR2 default null,
                        X_payment_method_code                      varchar2,
			X_Payment_Priority                         NUMBER,
			X_Payment_Status_Flag                      VARCHAR2,
			X_Second_Discount_Date                     DATE,
			X_Third_Discount_Date                      DATE,
			X_Batch_Id                                 NUMBER,
			X_Discount_Amount_Available                NUMBER,
			X_Second_Disc_Amt_Available                NUMBER,
			X_Third_Disc_Amt_Available                 NUMBER,
			X_Attribute1                               VARCHAR2,
			X_Attribute10                              VARCHAR2,
			X_Attribute11                              VARCHAR2,
			X_Attribute12                              VARCHAR2,
			X_Attribute13                              VARCHAR2,
			X_Attribute14                              VARCHAR2,
			X_Attribute15                              VARCHAR2,
			X_Attribute2                               VARCHAR2,
			X_Attribute3                               VARCHAR2,
			X_Attribute4                               VARCHAR2,
			X_Attribute5                               VARCHAR2,
			X_Attribute6                               VARCHAR2,
			X_Attribute7                               VARCHAR2,
			X_Attribute8                               VARCHAR2,
			X_Attribute9                               VARCHAR2,
			X_Attribute_Category                       VARCHAR2,
			X_Discount_Amount_Remaining                NUMBER,
			X_Global_Attribute_Category                VARCHAR2,
			X_Global_Attribute1                        VARCHAR2,
			X_Global_Attribute2                        VARCHAR2,
			X_Global_Attribute3                        VARCHAR2,
			X_Global_Attribute4                        VARCHAR2,
			X_Global_Attribute5                        VARCHAR2,
			X_Global_Attribute6                        VARCHAR2,
			X_Global_Attribute7                        VARCHAR2,
			X_Global_Attribute8                        VARCHAR2,
			X_Global_Attribute9                        VARCHAR2,
			X_Global_Attribute10                       VARCHAR2,
			X_Global_Attribute11                       VARCHAR2,
			X_Global_Attribute12                       VARCHAR2,
			X_Global_Attribute13                       VARCHAR2,
			X_Global_Attribute14                       VARCHAR2,
			X_Global_Attribute15                       VARCHAR2,
			X_Global_Attribute16                       VARCHAR2,
			X_Global_Attribute17                       VARCHAR2,
			X_Global_Attribute18                       VARCHAR2,
			X_Global_Attribute19                       VARCHAR2,
			X_Global_Attribute20                       VARCHAR2,
			X_External_Bank_Account_Id                 NUMBER,
			X_Inv_Curr_Gross_Amount                    NUMBER,
                        X_Org_Id                                   NUMBER,
			X_Calling_Sequence                         VARCHAR2,
			--Third Party Payments
			X_Remit_To_Supplier_Name		VARCHAR2,
			X_Remit_To_Supplier_Id		NUMBER,
			X_Remit_To_Supplier_Site		VARCHAR2,
			X_Remit_To_Supplier_Site_Id		NUMBER,
			X_Relationship_Id				NUMBER
  );

END AP_PAYMENT_SCHEDULES_PKG;

/
