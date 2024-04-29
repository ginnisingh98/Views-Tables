--------------------------------------------------------
--  DDL for Package Body CE_XML_LINES_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_XML_LINES_INF_PKG" AS
/* $Header: cexmllib.pls 120.3 2005/09/20 06:06:59 svali noship $ */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.3 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Ifx_Row(   X_Bank_Account_Num		VARCHAR2,
		       X_Statement_Number		VARCHAR2,
		       X_Line_Number			NUMBER,
		       X_Trx_Date			DATE,
		       X_Trx_Code		IN OUT  NOCOPY VARCHAR2,
		       X_Effective_Date			DATE,
		       X_Trx_Text			VARCHAR2,
		       X_Invoice_Text			VARCHAR2,
		       X_Bank_Account_Text		VARCHAR2,
		       X_Amount				NUMBER,
		       X_Charges_Amount			NUMBER,
		       X_Currency_Code			VARCHAR2,
		       X_Exchange_Rate			NUMBER,
		       X_user_exchange_rate_type	VARCHAR2,
		       X_exchange_rate_date		DATE,
		       X_original_amount		NUMBER,
		       X_Bank_Trx_Number		VARCHAR2,
		       X_Customer_Text			VARCHAR2,
		       X_Created_By		IN OUT	NOCOPY NUMBER,
		       X_Creation_Date		IN OUT	NOCOPY DATE,
                       X_Last_Updated_By	IN OUT	NOCOPY NUMBER,
                       X_Last_Update_Date	IN OUT	NOCOPY DATE,
		       X_Attribute_Category		VARCHAR2,
		       X_Attribute1			VARCHAR2,
		       X_Attribute10			VARCHAR2,
		       X_Attribute11			VARCHAR2,
		       X_Attribute12			VARCHAR2,
		       X_Attribute13			VARCHAR2,
		       X_Attribute14			VARCHAR2,
		       X_Attribute15			VARCHAR2,
		       X_Attribute2			VARCHAR2,
		       X_Attribute3			VARCHAR2,
		       X_Attribute4			VARCHAR2,
		       X_Attribute5			VARCHAR2,
		       X_Attribute6			VARCHAR2,
		       X_Attribute7			VARCHAR2,
		       X_Attribute8			VARCHAR2,
		       X_Attribute9			VARCHAR2) IS

  l_cnt         NUMBER;
  l_Rowid       ROWID;
  l_trx_code    VARCHAR2(30);

  l_seq		number;

  BEGIN

    DELETE FROM ce_statement_lines_interface
    WHERE  bank_account_num = ltrim(rtrim(X_Bank_Account_Num,' '), ' ')
    AND    statement_number = ltrim(rtrim(X_Statement_Number,' '), ' ')
    AND    line_number      = X_Line_Number;

    IF substr(X_trx_code,1,3) = 'BAI' THEN
      l_trx_code := substr(X_trx_code,5,3);
    ELSE
      l_trx_code := X_trx_code;
    END IF;

    CE_STAT_LINES_INF_PKG.Insert_Row(
			l_Rowid,
			ltrim(rtrim(X_Bank_Account_Num,' '), ' '),
			ltrim(rtrim(X_Statement_Number,' '), ' '),
			X_Line_Number,
			ltrim(rtrim(X_Trx_Date,' '), ' '),
			ltrim(rtrim(l_trx_code,' '), ' '),
			ltrim(rtrim(X_Effective_Date,' '), ' '),
			ltrim(rtrim(X_Trx_Text,' '), ' '),
			ltrim(rtrim(X_Invoice_Text,' '), ' '),
			ltrim(rtrim(X_Bank_Account_Text,' '), ' '),
			X_Amount,
			X_Charges_Amount,
			ltrim(rtrim(X_Currency_Code,' '), ' '),
			X_Exchange_Rate,
			ltrim(rtrim(X_user_exchange_rate_type,' '), ' '),
			ltrim(rtrim(X_exchange_rate_date,' '), ' '),
			X_original_amount,
			ltrim(rtrim(X_Bank_Trx_Number,' '), ' '),
			ltrim(rtrim(X_Customer_Text,' '), ' '),
			-1,
			sysdate,
			-1,
			sysdate,
			X_Attribute_Category,
			X_Attribute1,
			X_Attribute10,
			X_Attribute11,
			X_Attribute12 ,
			X_Attribute13,
			X_Attribute14,
			X_Attribute15,
			X_Attribute2,
			X_Attribute3,
			X_Attribute4,
			X_Attribute5,
			X_Attribute6,
			X_Attribute7,
			X_Attribute8,
			X_Attribute9);

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'CE_XML_LINES_INF_PKG.IFX_ROW');
      RAISE;
  END Ifx_row;

END CE_XML_LINES_INF_PKG;

/
