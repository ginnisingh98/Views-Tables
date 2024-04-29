--------------------------------------------------------
--  DDL for Package Body CE_XML_HDRS_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_XML_HDRS_INF_PKG" as
/* $Header: cexmlhib.pls 120.4 2005/08/30 16:00:41 lkwan noship $ */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.4 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Ifx_Row(   X_Statement_Number               VARCHAR2,
                       X_Bank_Branch_Name      IN OUT  NOCOPY VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Date                 DATE,
                       X_Check_Digits                   VARCHAR2,
                       X_Control_Begin_Balance          NUMBER,
                       X_Control_End_Balance            NUMBER,
                       X_Control_Total_Dr               NUMBER,
                       X_Control_Total_Cr               NUMBER,
                       X_Control_Dr_Line_Count          NUMBER,
                       X_Control_Cr_Line_Count          NUMBER,
                       X_Control_Line_Count             NUMBER,
                       X_Record_Status_Flag             VARCHAR2,
                       X_Currency_Code         IN OUT  NOCOPY  VARCHAR2,
                       X_Created_By            IN OUT  NOCOPY NUMBER,
                       X_Creation_Date         IN OUT  NOCOPY  DATE,
                       X_Last_Updated_By       IN OUT  NOCOPY  NUMBER,
                       X_Last_Update_Date      IN OUT  NOCOPY DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Org_Id                IN OUT  NOCOPY NUMBER,
                       X_Bank_Name             IN OUT  NOCOPY VARCHAR2,
		       X_Int_Calc_Balance		NUMBER,
		       X_Cashflow_Balance		NUMBER) IS

  l_temp		NUMBER;
  l_temp2		NUMBER;
  l_temp3		NUMBER;
  l_temp4		NUMBER;
  l_org_id		CE_BANK_ACCOUNTS.ACCOUNT_OWNER_org_id%TYPE;
  l_bank_name		CE_BANK_BRANCHES_V.bank_name%TYPE;
  l_bank_branch_name	CE_BANK_BRANCHES_V.bank_branch_name%TYPE;
  l_curr_code		CE_BANK_ACCOUNTS_V.currency_code%TYPE;

  l_seq			NUMBER;

  BEGIN

    DELETE FROM ce_statement_headers_int
    WHERE  bank_account_num = ltrim(rtrim(X_Bank_Account_Num,' '),' ')
    AND    statement_number = ltrim(rtrim(X_Statement_Number,' '),' ');

    SELECT count(BA.ACCOUNT_OWNER_org_id),
           count(BB.bank_name),
           count(BB.bank_branch_name),
           count(BA.currency_code)
    INTO   l_temp, l_temp2, l_temp3, l_temp4
    FROM   CE_BANK_ACCOUNTS BA,
           CE_BANK_BRANCHES_V BB
    WHERE  BA.bank_account_num = X_Bank_Account_Num
    AND    BB.branch_party_id = BA.bank_branch_id;

    IF (l_temp = 1) THEN
      SELECT ACCOUNT_OWNER_org_id
      INTO   l_org_id
      FROM   CE_BANK_ACCOUNTS
      WHERE  bank_account_num = X_Bank_Account_Num;
    ELSE
      l_org_id := TO_NUMBER(null);
    END IF;

    IF (X_Bank_Name is null) THEN
      IF (l_temp2 = 1) THEN
        SELECT bb.bank_name
        INTO   l_bank_name
        FROM   CE_BANK_ACCOUNTS BA,
               CE_BANK_BRANCHES_V BB
        WHERE  BA.bank_account_num = X_Bank_Account_Num
        AND    BB.branch_party_id = BA.bank_branch_id;
      ELSE
        l_bank_name := '';
      END IF;
    ELSE
      l_bank_name := X_Bank_Name;
    END IF;

    IF (X_Bank_Branch_Name is null) THEN
      IF (l_temp3 = 1) THEN
        SELECT bb.bank_branch_name
        INTO   l_bank_branch_name
        FROM   CE_BANK_ACCOUNTS BA,
               CE_BANK_BRANCHES_V BB
        WHERE  BA.bank_account_num = X_Bank_Account_Num
        AND    BB.branch_party_id = BA.bank_branch_id;
      ELSE
        l_bank_branch_name := '';
      END IF;
    ELSE
      l_bank_branch_name := ltrim(rtrim(X_Bank_Branch_Name,' '),' ');
    END IF;

    IF (X_Currency_Code is null) THEN
      IF (l_temp2 = 1) THEN
        SELECT currency_code
        INTO   l_curr_code
        FROM   CE_BANK_ACCOUNTS
        WHERE  bank_account_num = X_Bank_Account_Num;
      ELSE
        l_curr_code := '';
      END IF;
    ELSE
      l_curr_code := ltrim(rtrim(X_Currency_Code,' '),' ');
    END IF;

    INSERT INTO CE_STATEMENT_HEADERS_INT(
		statement_number,
		bank_branch_name,
		bank_account_num,
		statement_date,
		check_digits,
		control_begin_balance,
		control_end_balance,
		control_total_dr,
		control_total_cr,
		control_dr_line_count,
		control_cr_line_count,
		control_line_count,
		record_status_flag,
		currency_code,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		attribute_category,
		attribute1,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		bank_name,
		org_id,
		int_calc_balance,
		cashflow_balance
	) VALUES (
		ltrim(rtrim(X_Statement_Number,' '),' '),
		l_bank_branch_name,
		ltrim(rtrim(X_Bank_Account_Num,' '),' '),
		ltrim(rtrim(X_Statement_Date,' '),' '),
		X_Check_Digits,
		X_Control_Begin_Balance,
		X_Control_End_Balance,
		X_Control_Total_Dr,
		X_Control_Total_Cr,
		X_Control_Dr_Line_Count,
		X_Control_Cr_Line_Count,
		X_Control_Line_Count,
		X_Record_Status_Flag,
		l_curr_code,
		-1,
		sysdate,
		-1,
		sysdate,
		X_Attribute_Category,
		X_Attribute1,
		X_Attribute10,
		X_Attribute11,
		X_Attribute12,
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
		X_Attribute9,
		l_bank_name,
		l_org_id,
		X_Int_Calc_Balance,
		X_Cashflow_Balance
	);

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'CE_XML_HDRS_INF_PKG.IFX_ROW');
      RAISE;
  END Ifx_row;

END CE_XML_HDRS_INF_PKG;

/
