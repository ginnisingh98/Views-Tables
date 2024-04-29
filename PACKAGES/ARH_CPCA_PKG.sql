--------------------------------------------------------
--  DDL for Package ARH_CPCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_CPCA_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPCAS.pls 120.1 2005/06/16 21:13:20 jhuang ship $*/


PROCEDURE Insert_Negative_Class_Amt
(         X_Customer_Profile_Class_Id      NUMBER,
          X_Created_By                     NUMBER,
          X_Creation_Date                  DATE,
          X_Currency_Code                  VARCHAR2,
          X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Last_Updated_By                NUMBER,
          X_Last_Update_Date               DATE,
          X_Auto_Rec_Min_Receipt_Amount    NUMBER,
          X_Last_Update_Login              NUMBER,
          X_Max_Interest_Charge            NUMBER,
          X_Min_Dunning_Amount             NUMBER,
          X_Min_Statement_Amount           NUMBER,
          X_Overall_Credit_Limit           NUMBER,
          X_Trx_Credit_Limit               NUMBER,
          X_Attribute_Category             VARCHAR2,
          X_Attribute1                     VARCHAR2,
          X_Attribute2                     VARCHAR2,
          X_Attribute3                     VARCHAR2,
          X_Attribute4                     VARCHAR2,
          X_Attribute5                     VARCHAR2,
          X_Attribute6                     VARCHAR2,
          X_Attribute7                     VARCHAR2,
          X_Attribute8                     VARCHAR2,
          X_Attribute9                     VARCHAR2,
          X_Attribute10                    VARCHAR2,
          X_Attribute11                    VARCHAR2,
          X_Attribute12                    VARCHAR2,
          X_Attribute13                    VARCHAR2,
          X_Attribute14                    VARCHAR2,
          X_Attribute15                    VARCHAR2,
          X_Interest_Rate                  NUMBER,
          X_Min_Fc_Balance_Amount          NUMBER,
          X_Min_Fc_Invoice_Amount          NUMBER,
          X_Min_Dunning_Invoice_Amount     NUMBER,
          X_Jgzz_attribute_Category             VARCHAR2,
          X_Jgzz_attribute1                     VARCHAR2,
          X_Jgzz_attribute2                     VARCHAR2,
          X_Jgzz_attribute3                     VARCHAR2,
          X_Jgzz_attribute4                     VARCHAR2,
          X_Jgzz_attribute5                     VARCHAR2,
          X_Jgzz_attribute6                     VARCHAR2,
          X_Jgzz_attribute7                     VARCHAR2,
          X_Jgzz_attribute8                     VARCHAR2,
          X_Jgzz_attribute9                     VARCHAR2,
          X_Jgzz_attribute10                    VARCHAR2,
          X_Jgzz_attribute11                    VARCHAR2,
          X_Jgzz_attribute12                    VARCHAR2,
          X_Jgzz_attribute13                    VARCHAR2,
          X_Jgzz_attribute14                    VARCHAR2,
          X_Jgzz_attribute15                    VARCHAR2
);

PROCEDURE compute_negative_id
(         X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Negative_Id                    IN OUT NOCOPY NUMBER,
          X_Notify_Flag                    IN OUT NOCOPY VARCHAR2
);
--
--
PROCEDURE old_amount_insert
(         X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Negative_Id                    NUMBER,
          X_Customer_Profile_Class_Id      NUMBER
);
--
--
END arh_cpca_pkg;

 

/
