--------------------------------------------------------
--  DDL for Package CE_TRANSACTION_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_TRANSACTION_CODES_PKG" AUTHID CURRENT_USER as
/* $Header: cetrxcds.pls 120.4.12010000.2 2009/07/31 09:30:56 vnetan ship $ */
G_spec_revision     VARCHAR2(1000) := '$Revision: 120.4.12010000.2 $';

FUNCTION spec_revision RETURN VARCHAR2;
FUNCTION body_revision RETURN VARCHAR2;

--
-- Procedure
--  Insert_Row
-- Purpose
--   Inserts a row into ce_transaction_codes
-- History
--   00-00-94  Dean McCarthy Created
--   07-20-09  vnetan        8707463: Added REQUEST_ID column
-- Arguments
-- all the columns of the table ce_transaction_codes
-- Example
--   ce_transaction_codes.Insert_Row(....;
-- Notes
--
PROCEDURE Insert_Row(
    X_Rowid                   IN OUT NOCOPY VARCHAR2,
    X_Transaction_Code_Id     IN OUT NOCOPY NUMBER,
    X_Bank_Account_Id                NUMBER,
    X_Trx_Code                       VARCHAR2,
    X_Trx_Type                       VARCHAR2,
    X_Description                    VARCHAR2,
    X_Receivables_Trx_Id             NUMBER,
    X_Receipt_Method_Id              NUMBER,
    X_Create_Misc_Trx_Flag           VARCHAR2,
    X_Reconcile_flag                 VARCHAR2,
    X_Float_Days                     NUMBER,
    X_Matching_Against               VARCHAR2,
    X_Correction_Method              VARCHAR2,
    X_Start_Date                     DATE,
    X_End_Date                       DATE,
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
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_payroll_payment_format_Id      NUMBER DEFAULT NULL,
    X_reconciliation_sequence        NUMBER,
    X_request_id                     NUMBER DEFAULT NULL -- 8707463: Added
);
--
-- Procedure
--  Lock_Row
-- Purpose
--   Locks a row into ce_transaction_codes
-- History
--   00-00-94  Dean McCarthy Created
-- Arguments
-- all the columns of the table ce_transaction_codes
-- Example
--   ce_transaction_codes.Lock_Row(....;
-- Notes
--
PROCEDURE Lock_Row(
    X_Rowid                      VARCHAR2,
    X_Transaction_Code_Id        NUMBER,
    X_Bank_Account_Id            NUMBER,
    X_Trx_Code                   VARCHAR2,
    X_Trx_Type                   VARCHAR2,
    X_Description                VARCHAR2,
    X_Receivables_Trx_Id         NUMBER,
    X_Receipt_Method_Id          NUMBER,
    X_Create_Misc_Trx_Flag       VARCHAR2,
    X_Reconcile_Flag             VARCHAR2,
    X_Float_Days                 NUMBER,
    X_Matching_Against           VARCHAR2,
    X_Correction_Method          VARCHAR2,
    X_Start_Date                 DATE,
    X_End_Date                   DATE,
    X_Attribute_Category         VARCHAR2,
    X_Attribute1                 VARCHAR2,
    X_Attribute2                 VARCHAR2,
    X_Attribute3                 VARCHAR2,
    X_Attribute4                 VARCHAR2,
    X_Attribute5                 VARCHAR2,
    X_Attribute6                 VARCHAR2,
    X_Attribute7                 VARCHAR2,
    X_Attribute8                 VARCHAR2,
    X_Attribute9                 VARCHAR2,
    X_Attribute10                VARCHAR2,
    X_Attribute11                VARCHAR2,
    X_Attribute12                VARCHAR2,
    X_Attribute13                VARCHAR2,
    X_Attribute14                VARCHAR2,
    X_Attribute15                VARCHAR2,
    X_payroll_payment_format_Id  NUMBER  DEFAULT NULL,
    X_reconciliation_sequence    NUMBER
);
--
-- Procedure
--  Update_Row
-- Purpose
--   Updates a row into cb_transaction_codes
-- History
--   00-00-94  Dean McCarthy Created
--   07-20-09  vnetan        8707463: Added REQUEST_ID column
-- Arguments
-- all the columns of the table ce_transaction_codes
-- Example
--   ce_transaction_codes.Update_Row(....;
-- Notes
--
PROCEDURE Update_Row(
    X_Rowid                          VARCHAR2,
    X_Transaction_Code_Id            NUMBER,
    X_Bank_Account_Id                NUMBER,
    X_Trx_Code                       VARCHAR2,
    X_Trx_Type                       VARCHAR2,
    X_Description                    VARCHAR2,
    X_Receivables_Trx_Id             NUMBER,
    X_Receipt_Method_Id              NUMBER,
    X_Create_Misc_Trx_Flag           VARCHAR2,
    X_Reconcile_Flag                 VARCHAR2,
    X_Float_Days                     NUMBER,
    X_Matching_Against               VARCHAR2,
    X_Correction_Method              VARCHAR2,
    X_Start_Date                     DATE,
    X_End_Date                       DATE,
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
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER,
    X_payroll_payment_format_id      NUMBER  DEFAULT NULL,
    X_reconciliation_sequence        NUMBER,
    X_request_id                     NUMBER DEFAULT NULL -- 8707463: Added
);
--
-- Procedure
--  Delete_Row
-- Purpose
--   Deletes a row from cb_transaction_codes
-- History
--   00-00-94  Dean McCarhty  Created
-- Arguments
--    x_rowid         Rowid of a row
-- Example
--   cb_transaction_codes.delete_row('ajfdshj');
-- Notes
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
-- Procedure
--  check_unique_txn_code
-- Purpose
--   Checks for uniquness of Transaction codes before
--   insertion and updates for a given bank code
-- History
--   11-Jun-95  Ganesh Vaidee  Created
--   16-Jun-05  lkwan          bug 4435028 - new unique validate rules
--         Users should be able to enter the following
--         Type       Code    Transaction Source    Priority
--         Payment    100    AP Payments        1
--         Payment    100    Payroll            2
--         Payment    100    Cash Management        3
-- Arguments
--    x_row_id           Rowid of a row
--    X_trx_code         Transaction code of row to be inserted or updated
--    X_bank_account_id  Bank Account Id
--    X_trx_type         DEBIT, CREDIT, MISC_DEBIT, MISC_CREDIT, NSF, REJECTED, STOP
--    X_RECONCILE_FLAG   null, AR, AP, JE, CE, OI
--    X_RECONCILIATION_SEQUENCE   null, 1,2,3 ...
-- Example
--   ce_transaction_codes.check_unique_txn_code('ajfdshj', 11, '123.657.99', DEBIT, AP, 1 );
-- Notes
--
PROCEDURE check_unique_txn_code(
    X_trx_code                 IN VARCHAR2,
    X_bank_account_id          IN NUMBER,
    X_row_id                   IN VARCHAR2,
    X_trx_type                 IN VARCHAR2,
    X_reconcile_flag           IN VARCHAR2,
    X_reconciliation_sequence  IN NUMBER );

--
-- Function
--  Is In Use
-- Purpose
--   Checks whether this transaction code is referenced by a statement line or
--   archived statement line.
-- History
--   11-AUG-97  JaeSon Kim  Created
-- Arguments
--    CE_TRANSACTION_CODE_ID
-- Notes
--
FUNCTION is_in_use( X_ce_transaction_code_id NUMBER) RETURN BOOLEAN;

END CE_TRANSACTION_CODES_PKG;

/
