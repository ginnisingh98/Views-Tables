--------------------------------------------------------
--  DDL for Package Body CE_BANK_STATEMENT_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_STATEMENT_LOADER" AS
/* $Header: cebsldrb.pls 120.34.12010000.15 2010/03/17 06:24:27 rtumati ship $	*/

  l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  --l_DEBUG varchar2(1) := 'Y';

/*bug5100563*/
 n number:=0;
 G_last_val2 varchar2(30);
 G_last_val3 varchar2(30);
 G_last_val4 varchar2(30);
/*bug5100563*/

--bug5124547
 G_lcnt     number :=0;


/* 2421690
Start of Code Fix */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.34.12010000.15 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

/* End of Code Fix */

--
--  The following Procedures and Functions are shared by BAI2 format and Non-BAI2 format loading.
--
--  	Init_Hdr_Rec	Insert_Hdr	Lookup_Pos
--	Init_Line_Rec 	Insert_Line 	Lookup_Val
--
--  The following Procedures and Functions are for BAI2 format only.
--
--	Load_BAI2	Decode_Line_BAI
--      		Decode_Hdr_BAI
--
--  The following Procedures and Functions are for Non-BAI2 format only.
--
--	Load_Others	Decode_Line_Other	Hdr_Or_Line
--			Decode_Hdr_Other
--

    --Edifact ER start
  /* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							                                         |
|	Is_numeric 						                                                 |
|								                                                         |
|  DESCRIPTION								                                           |
|	To check the given string is numeric or not		                         |
|									                                                       |
|  CALLED BY								                                             |
|	covert_amt_edifact    						                                     |
|  REQUIRES								                                               |
|									                                                       |
|  HISTORY								                                               |
|	13-jul-2009	Created		RTUMATI				                                   |
 --------------------------------------------------------------------- */
  FUNCTION Is_numeric(str IN VARCHAR2)
  RETURN NUMBER IS
  l_number NUMBER(38);
  BEGIN
    l_number := to_number(str);
    RETURN 1;
  EXCEPTION WHEN Value_Error THEN
    RETURN 0;
  END Is_numeric;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							                                         |
|	covert_amt_edifact		                                                 |
|								                                                         |
|  DESCRIPTION								                                           |
|	To Decode the Non numerics  and to convert the amount to numeric		   |
|									                                                       |
|  CALLED BY								                                             |
|	Decode_Line_Others    						                                     |
|  REQUIRES								                                               |
|									                                                       |
|  HISTORY								                                               |
|	13-jul-2009	Created		RTUMATI				                                   |
 --------------------------------------------------------------------- */
 FUNCTION covert_amt_edifact(amount IN VARCHAR2)
  RETURN NUMBER IS
  l_number NUMBER;
  l_amount VARCHAR2(100);
  l_Lastchar VARCHAR2(1);
  BEGIN
      -- Check the Amount is numeric or not.
      l_number:=Is_numeric(amount);

      -- If the Amount is Non numeric
      IF (l_number=0) THEN
             -- Valiadte the Amount Provided at bank statement
             l_number:=Is_numeric(SubStr(amount,1,Length(amount)-1));
             IF (l_number=1) THEN
              -- Get the Last Char from the given string
                  l_Lastchar:=SubStr(amount,-1,Length(amount));
                  -- Get the Ascii value of Last Character
                  l_number := Ascii(l_Lastchar);
                      -- If the Last Character is in ('A','B','C','D','E','F','G','H','I') Decode
                      --the value correcpondigly to (1,  2,  3,  4,  5,  6,  7,  8,  9) and the amount shoule be positive
                      IF (l_number BETWEEN 65 AND 73) THEN
                          l_amount:=substr(amount,1,Length(amount)-1)||To_Char(l_number-64);
                          RETURN To_Number(l_amount);
                      -- If the Last Character is in ('J','K','L','M','N','O','P',Q','R') Decode
                      --the value correcpondigly to (1,  2,  3,  4,  5,  6,  7,  8,  9) and the amount should be negative
                      ELSIF(l_number BETWEEN 74 AND 82) THEN
                          l_amount:=substr(amount,1,Length(amount)-1)||To_Char(l_number-73);
                          RETURN (To_Number(l_amount)*-1);
                      -- If the Last Char is '{' then decode the char to '0' and amount to positive
                      ELSIF(l_number = 123) THEN
                          l_amount:=substr(amount,1,Length(amount)-1)||'0';
                          RETURN To_Number(l_amount);
                      -- If the Last Char is '}' then decode the char to '0' and amount to Negative
                      ELSIF(l_number = 125) THEN
                          l_amount:=substr(amount,1,Length(amount)-1)||'0';
                          RETURN (To_Number(l_amount)*-1);
                      ELSE --8911035
                        FND_MESSAGE.set_name('CE', 'CE_INVALID_EDIFACT_AMOUNT');
                        CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, G_rec_no, fnd_message.get, 'W');
                        RETURN NULL;
                      END IF;
             ELSE
              FND_MESSAGE.set_name('CE', 'CE_INVALID_EDIFACT_AMOUNT');
              CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, G_rec_no, fnd_message.get, 'W');
              RETURN NULL;
             END IF; --8911035
      -- If the amount is Numeric return the amount
      ELSIF(l_number=1) THEN
        RETURN amount;
      END IF;
   END;
 --Edifact ER end
/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Init_Hdr_Rec 							|
|									|
|  DESCRIPTION								|
|	Initialize Header variables after Insertion of the Header	|
|   	Record. 							|
|									|
|  CALLED BY								|
|	Load_BAI2, Load_Others						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Init_Hdr_Rec IS
BEGIN
  n := 0; -- 8367682: Added
  G_bank_name 		:= NULL;
  G_bank_branch_name 	:= NULL;
  G_statement_date	:= NULL;
  G_control_begin_balance := NULL;
  G_control_end_balance := NULL;
  G_cashflow_balance := NULL;
  G_int_calc_balance := NULL;
  G_average_close_ledger_mtd :=NULL;
  G_average_close_ledger_ytd :=NULL;
  G_average_close_available_mtd :=NULL;
  G_average_close_available_ytd :=NULL;
  G_one_day_float := NULL;
  G_two_day_float := NULL;
  G_control_total_dr 	:= NULL;
  G_control_total_cr 	:= NULL;
  G_control_dr_line_count := NULL;
  G_control_cr_line_count := NULL;
  G_control_line_count	:= NULL;
  G_check_digits	:= NULL;
  G_hdr_currency_code 	:= NULL;
  G_hdr_precision	:= NULL;
END Init_Hdr_Rec;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Init_Line_Rec 							|
|									|
|  DESCRIPTION								|
|	Initialize Line variables after Insertion of the Line		|
|   	Record. 							|
|									|
|  CALLED BY								|
|	Load_BAI2, Load_Others						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Init_Line_Rec IS
BEGIN
  G_line_number		:= NULL;
  G_trx_date 		:= NULL;
  G_trx_code 		:= NULL;
  G_effective_date 	:= NULL;
  G_trx_text 		:= NULL;
  G_invoice_text	:= NULL;
  G_amount	 	:= NULL;
  G_line_currency_code 	:= NULL;
  G_exchange_rate	:= NULL;
  G_bank_trx_number 	:= NULL;
  G_customer_text 	:= NULL;
  G_user_exchange_rate_type := NULL;
  G_exchange_rate_date	:= NULL;
  G_original_amount	:= NULL;
  G_charges_amount	:= NULL;
  G_bank_account_text	:= NULL;
  G_line_precision	:= NULL;
END Init_Line_Rec;

PROCEDURE Remove_Return_Char IS
BEGIN
/* Bug 7445326 - Added Carraige return newline character (ascii 13) for
   removal along with linefeed character(^M - ascii 10)*/

  UPDATE CE_STMT_INT_TMP
  SET    REC_NO = rtrim(REC_NO, '
'||fnd_global.local_chr(13)),
         REC_ID_NO = rtrim(REC_ID_NO, '
'||fnd_global.local_chr(13)),
         COLUMN1 = rtrim(COLUMN1, '
'||fnd_global.local_chr(13)),
         COLUMN2 = rtrim(COLUMN2, '
'||fnd_global.local_chr(13)),
         COLUMN3 = rtrim(COLUMN3, '
'||fnd_global.local_chr(13)),
         COLUMN4 = rtrim(COLUMN4, '
'||fnd_global.local_chr(13)),
         COLUMN5 = rtrim(COLUMN5, '
'||fnd_global.local_chr(13)),
         COLUMN6 = rtrim(COLUMN6, '
'||fnd_global.local_chr(13)),
         COLUMN7 = rtrim(COLUMN7, '
'||fnd_global.local_chr(13)),
         COLUMN8 = rtrim(COLUMN8, '
'||fnd_global.local_chr(13)),
         COLUMN9 = rtrim(COLUMN9, '
'||fnd_global.local_chr(13)),
         COLUMN10 = rtrim(COLUMN10, '
'||fnd_global.local_chr(13)),
         COLUMN11 = rtrim(COLUMN11, '
'||fnd_global.local_chr(13)),
         COLUMN12 = rtrim(COLUMN12, '
'||fnd_global.local_chr(13)),
         COLUMN13 = rtrim(COLUMN13, '
'||fnd_global.local_chr(13)),
         COLUMN14 = rtrim(COLUMN14, '
'||fnd_global.local_chr(13)),
         COLUMN15 = rtrim(COLUMN15, '
'||fnd_global.local_chr(13)),
         COLUMN16 = rtrim(COLUMN16, '
'||fnd_global.local_chr(13)),
         COLUMN17 = rtrim(COLUMN17, '
'||fnd_global.local_chr(13)),
         COLUMN18 = rtrim(COLUMN18, '
'||fnd_global.local_chr(13)),
         COLUMN19 = rtrim(COLUMN19, '
'||fnd_global.local_chr(13)),
         COLUMN20 = rtrim(COLUMN20, '
'||fnd_global.local_chr(13)),
         COLUMN21 = rtrim(COLUMN21, '
'||fnd_global.local_chr(13)),
         COLUMN22 = rtrim(COLUMN22, '
'||fnd_global.local_chr(13)),
         COLUMN23 = rtrim(COLUMN23, '
'||fnd_global.local_chr(13)),
         COLUMN24 = rtrim(COLUMN24, '
'||fnd_global.local_chr(13)),
         COLUMN25 = rtrim(COLUMN25, '
'||fnd_global.local_chr(13)),
         COLUMN26 = rtrim(COLUMN26, '
'||fnd_global.local_chr(13)),
         COLUMN27 = rtrim(COLUMN27, '
'||fnd_global.local_chr(13)),
         COLUMN28 = rtrim(COLUMN28, '
'||fnd_global.local_chr(13)),
         COLUMN29 = rtrim(COLUMN29, '
'||fnd_global.local_chr(13)),
         COLUMN30 = rtrim(COLUMN30, '
'||fnd_global.local_chr(13)),
         COLUMN31 = rtrim(COLUMN31, '
'||fnd_global.local_chr(13)),
         COLUMN32 = rtrim(COLUMN32, '
'||fnd_global.local_chr(13)),
         COLUMN33 = rtrim(COLUMN33, '
'||fnd_global.local_chr(13)),
         COLUMN34 = rtrim(COLUMN34, '
'||fnd_global.local_chr(13)),
         COLUMN35 = rtrim(COLUMN35, '
'||fnd_global.local_chr(13));
END Remove_Return_Char;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	CONV_TO_DATE 							|
|									|
|  DESCRIPTION								|
|	Convert string to date. If the conversion fails then log	|
|   	error. 				   				|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-2000	Created		BHCHUNG				|
 --------------------------------------------------------------------- */

FUNCTION CONV_TO_DATE(X_date	VARCHAR2)  RETURN DATE IS
BEGIN
  RETURN TO_DATE(X_date, G_date_format);
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CE', 'CE_CANNOT_CONVERT_DATE');
    FND_MESSAGE.set_token('DATE', X_date);
    FND_MESSAGE.set_token('FORMAT', G_date_format);
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, nvl(G_rec_no, 0), fnd_message.get, 'E');
END;


FUNCTION CONV_TIMESTAMP(X_date	VARCHAR2)  RETURN DATE IS
BEGIN
  RETURN TO_DATE(X_date, G_date_format || ' ' || G_timestamp_format);
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CE', 'CE_CANNOT_CONVERT_DATE');
    FND_MESSAGE.set_token('DATE', X_date);
    FND_MESSAGE.set_token('FORMAT', G_date_format);
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, nvl(G_rec_no, 0), fnd_message.get, 'E');
END;


FUNCTION Is_Number (X_string	VARCHAR2)  RETURN BOOLEAN IS
  l_dummy	NUMBER;
BEGIN
  l_dummy := to_number(X_string);
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;


/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Valid_Statement							|
|									|
|  DESCRIPTION								|
|	Check if this statement is the one user wants to 		|
|	import/autoreconcile.						|
|									|
|  CALLED BY								|
|	Insert_Hdr, Insert_Line						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
FUNCTION Valid_Statement RETURN BOOLEAN IS
  l_cnt			NUMBER := 1;
BEGIN
  --
  -- Check if this statement is the one user wants to import/autoreconcile.
  --
  IF G_bank_account_id IS NOT NULL THEN
    SELECT count(*)
    INTO   l_cnt
    FROM   CE_BANK_ACCOUNTS --FROM   AP_BANK_ACCOUNTS_ALL
    WHERE  bank_account_id  = G_bank_account_id
    AND    bank_account_num = G_bank_account_num;
  ELSIF G_bank_branch_id IS NOT NULL THEN
    SELECT count(*)
    INTO   l_cnt
    FROM   CE_BANK_BRANCHES_V --FROM   AP_BANK_BRANCHES
    WHERE  branch_party_id   = G_bank_branch_id
    AND    bank_branch_name = G_bank_branch_name;
  END IF;

  IF l_cnt = 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END Valid_Statement;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|       Delete_Orphaned_Lines 						|
|									|
|  DESCRIPTION								|
|	Delete Orphaned Lines.			                        |
|									|
|  CALLED BY								|
|	Load_Others						        |
|  REQUIRES								|
|									|
|  HISTORY								|
|	12-12-2001	Created		HEHAN				|
 --------------------------------------------------------------------- */
PROCEDURE Delete_Orphaned_Lines IS
  l_bank_account_num  ce_statement_lines_interface.bank_account_num%TYPE;
  l_statement_number ce_statement_lines_interface.statement_number%TYPE;
  h_rec_cnt NUMBER;

  CURSOR l_cursor IS
    SELECT bank_account_num, statement_number
    FROM ce_statement_lines_interface;

  BEGIN
    OPEN l_cursor;
      LOOP
        fetch l_cursor into l_bank_account_num, l_statement_number;
        EXIT WHEN l_cursor%NOTFOUND;

         SELECT count (1)
         INTO h_rec_cnt
         FROM ce_statement_headers_int
         WHERE bank_account_num = l_bank_account_num
         AND statement_number = l_statement_number;

         IF h_rec_cnt = 0 THEN
         DELETE FROM ce_statement_lines_interface
         WHERE bank_account_num = l_bank_account_num
         AND statement_number = l_statement_number;

         END IF;
      END LOOP;
    CLOSE l_cursor;
END Delete_Orphaned_Lines;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Validate_Subsidiary_Account             |
|									|
|  DESCRIPTION								|
|	Check if the bank account is of type Subsidiary	|
|									|
|  CALLED BY								|
|	Insert_Hdr   						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	25-MAY-2005	Created		JIKUMAR				|
 --------------------------------------------------------------------- */
PROCEDURE Validate_Subsidiary_Account IS
  l_rec_cnt		NUMBER;

BEGIN
	SELECT count(1)
	INTO l_rec_cnt
	FROM CE_BANK_ACCOUNTS BA,
	     CE_BANK_BRANCHES_V BB
	WHERE BA.ACCOUNT_CLASSIFICATION = 'SUBSIDIARY' AND
	      BB.branch_party_id   = BA.bank_branch_id AND
              BA.bank_account_num = G_bank_account_num AND
	      BB.BANK_BRANCH_NAME 		 = nvl(G_bank_branch_name,BB.BANK_BRANCH_NAME);

	if l_rec_cnt = 1 THEN
		G_subsidiary_flag := 'Y';
	else
		G_subsidiary_flag := 'N';
	end if;

EXCEPTION
	WHEN OTHERS THEN
	G_subsidiary_flag := 'N';
END Validate_Subsidiary_Account;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Insert_Hdr 							|
|									|
|  DESCRIPTION								|
|	Insert Header Record to Interface Table.			|
|									|
|  CALLED BY								|
|	Load_BAI2, Load_Others						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Insert_Hdr IS
  l_rec_cnt		NUMBER;
  l_err			NUMBER;
  l_request_id		NUMBER;
  l_program_name	VARCHAR2(30);
  l_debug_file		VARCHAR2(30);
  l_statement_number    VARCHAR2(50);
  G_conc_req_id		NUMBER;
  l_req_data		VARCHAR(30);
  ldr_exception		EXCEPTION;

  errbuf	VARCHAR2(256);
  retcode	NUMBER;

  CURSOR C_error IS
    SELECT count(*)
    FROM   CE_SQLLDR_ERRORS
    WHERE  statement_number = G_statement_number
    AND    bank_account_num = G_bank_account_num;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Insert_Hdr');

    cep_standard.debug('Statement Number	-'||G_statement_number||'.');
    cep_standard.debug('Bank Account Num 	-'||G_bank_account_num||'.');
    cep_standard.debug('Statement_date  	-'||G_statement_date||'.');
    cep_standard.debug('Bank Name		-'||G_bank_name||'.');
    cep_standard.debug('Bank Branch Name	-'||G_bank_branch_name||'.');
    cep_standard.debug('Begin Bal		-'||G_control_begin_balance||'.');
    cep_standard.debug('End Bal		-'||G_control_end_balance||'.');
    cep_standard.debug('Cashflow Bal	-'||G_cashflow_balance||'.');
    cep_standard.debug('Int Calc Bal	-'||G_int_calc_balance||'.');
    cep_standard.debug('Average close ledger mtd   -'||G_average_close_ledger_mtd||'.');
    cep_standard.debug('Average close ledger ytd   -'||G_average_close_ledger_ytd||'.');
    cep_standard.debug('Average close available mtd -'||G_average_close_available_mtd||'.');
    cep_standard.debug('Average close available ytd -'||G_average_close_available_ytd||'.');
    cep_standard.debug('One Day Float -'||G_one_day_float||'.');
    cep_standard.debug('Two Day Float   -'||G_two_day_float||'.');
    cep_standard.debug('Total DR		-'||G_control_total_dr||'.');
    cep_standard.debug('Total CR		-'||G_control_total_cr||'.');
    cep_standard.debug('Total DR Line cnt	-'||G_control_dr_line_count||'.');
    cep_standard.debug('Total CR Line cnt	-'||G_control_cr_line_count||'.');
    cep_standard.debug('Currency Code  	-'||G_hdr_currency_code||'.');
    cep_standard.debug('Bank Account ID	-'||to_char(G_sub_account_id)||'.');
    cep_standard.debug('Bank Branch ID	-'||to_char(G_sub_branch_id)||'.');
    cep_standard.debug('GL Date           -'||to_char(G_gl_date, 'DD-MON-YY')||'.');
    cep_standard.debug('Org ID	        -'||G_org_id||'.');
    cep_standard.debug('Format Type 	-'||G_format_type||'.');
  END IF;

  IF G_format_type = 'SWIFT940' THEN
    l_statement_number := G_statement_number || ' - ' || to_char(G_statement_date);

  /* Bug 3417789 added the IF condition - start code fix*/
  IF (trunc(sysdate) <> trunc(G_statement_date)) THEN
    SELECT count(1)
    INTO   G_total_line_deleted
    FROM   ce_statement_lines_interface
    WHERE  statement_number = l_statement_number
    AND    bank_account_num = G_bank_account_num;

    DELETE ce_statement_lines_interface
    WHERE  statement_number = l_statement_number
    AND    bank_account_num = G_bank_account_num;

    UPDATE ce_statement_lines_interface
    SET    statement_number = l_statement_number
    WHERE  statement_number = G_statement_number || ' - ' || to_char(sysdate);
  END IF;
  /* Bug 3417789 - End code fix */
  ELSE
    l_statement_number := G_statement_number;
  END IF;

  IF Valid_statement THEN
    --
    -- Overwrite the existing bank statement of the same bank account and statement number.
    --
    -- bug 3676745 MO and BA uptake
   /*
    IF G_org_id is not null THEN
      SELECT count(1)
      INTO   l_rec_cnt
      FROM   ce_statement_headers_int
      WHERE  bank_account_num = G_bank_account_num
      AND	 statement_number = l_statement_number
      AND  nvl(org_id,G_org_id) = G_org_id;
    ELSE*/
      SELECT count(1)
      INTO   l_rec_cnt
      FROM   ce_statement_headers_int
      WHERE  bank_account_num = G_bank_account_num
      AND	 statement_number = l_statement_number;
    --END IF;
    IF l_rec_cnt > 0 THEN
      /*IF G_org_id is not null THEN
        DELETE FROM ce_statement_headers_int
        WHERE  bank_account_num = G_bank_account_num
        AND	 statement_number = l_statement_number
        AND  nvl(org_id,G_org_id) = G_org_id;
      ELSE*/
        DELETE FROM ce_statement_headers_int
        WHERE  bank_account_num = G_bank_account_num
        AND	 statement_number = l_statement_number;
      --END IF;
      G_total_hdr_deleted := G_total_hdr_deleted + l_rec_cnt;
    END IF;

    -- bug 4337623 added for subsidiary bank accounts
	validate_subsidiary_account();

    INSERT INTO ce_statement_headers_int(
   	STATEMENT_NUMBER,
 	BANK_ACCOUNT_NUM,
 	STATEMENT_DATE,
 	BANK_NAME,
 	BANK_BRANCH_NAME,
 	CONTROL_BEGIN_BALANCE,
 	CONTROL_END_BALANCE,
 	CASHFLOW_BALANCE,
 	INT_CALC_BALANCE,
	AVERAGE_CLOSE_LEDGER_MTD,
	AVERAGE_CLOSE_LEDGER_YTD,
	AVERAGE_CLOSE_AVAILABLE_MTD,
	AVERAGE_CLOSE_AVAILABLE_YTD,
	ONE_DAY_FLOAT,
	TWO_DAY_FLOAT,
 	CONTROL_TOTAL_DR,
 	CONTROL_TOTAL_CR,
 	CONTROL_DR_LINE_COUNT,
 	CONTROL_CR_LINE_COUNT,
 	CONTROL_LINE_COUNT,
	CHECK_DIGITS,
 	RECORD_STATUS_FLAG,
 	CURRENCY_CODE,
 	CREATED_BY,
 	CREATION_DATE ,
	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	--ORG_ID,
	INTRA_DAY_FLAG,
	SUBSIDIARY_FLAG)
    VALUES(
  	rtrim(l_statement_number),
  	rtrim(G_bank_account_num),
  	G_statement_date,
  	rtrim(G_bank_name),
  	rtrim(G_bank_branch_name),
  	G_control_begin_balance,
  	G_control_end_balance,
  	G_cashflow_balance,
  	G_int_calc_balance,
	G_average_close_ledger_mtd,
	G_average_close_ledger_ytd,
	G_average_close_available_mtd,
	G_average_close_available_ytd,
	G_one_day_float,
	G_two_day_float,
  	G_control_total_dr,
  	G_control_total_cr,
  	G_control_dr_line_count,
  	G_control_cr_line_count,
	G_control_line_count,
        G_check_digits,
      	'N',
  	rtrim(rtrim(G_hdr_currency_code),'/'),
	G_user_id,
 	SYSDATE,
 	G_user_id,
	SYSDATE,
	--G_org_id,
	G_intra_day_flag,
	G_subsidiary_flag);

    --
    -- Submit concurrent program for import and auto-reconciliation process.
    --
    IF G_process_option <> 'LOAD' THEN
      --
      -- The program will be submitted only if there is no error.
      --
     /* 3019931
        Import should be done only for those records in the
        statement interface that belong to the current Org */
     --IF (FND_PROFILE.value('ORG_ID') = G_org_id) THEN
      OPEN  C_error;
      FETCH C_error INTO l_rec_cnt;
      CLOSE C_error;

      IF l_rec_cnt = 0 THEN
         IF G_process_option = 'ZALL' THEN
           l_program_name := 'ARPLABIR';
         ELSIF G_process_option = 'IMPORT' THEN
           l_program_name := 'ARPLABIM';
         END IF;

         cep_standard.debug('Process Option	-'||G_process_option);
         cep_standard.debug('Program Name	-'||l_program_name);

         l_req_data := fnd_conc_global.request_data;

         if(l_req_data IS NOT NULL)THEN
           G_conc_req_id := to_number(l_req_data);
         END IF;

         IF G_debug_file IS NOT NULL THEN
           l_debug_file := G_debug_file || '-REC';
         END IF;
	 -- pass both org_id and legal_entity_id to CE_AUTO_BANK_REC for Import/AutoRecon
         l_request_id := FND_REQUEST.SUBMIT_REQUEST(
				'CE',l_program_name,'','',NULL,
				G_process_option,
				to_char(G_sub_branch_id),
				to_char(G_sub_account_id),
				l_statement_number,
				l_statement_number,
				'',
				'',
				to_char(G_gl_date, 'YYYY/MM/DD HH24:MI:SS'),
				G_org_id,
				'',
				to_char(G_receivables_trx_id),
				to_char(G_payment_method_id),
				G_nsf_handling,
				G_display_debug,
				G_debug_path,
				l_debug_file,
				G_intra_day_flag,
				fnd_global.local_chr(0),
				'','',
				'','','','','','','','','','',
				'','','','','','','','','','',
				'','','','','','','','','','',
				'','','','','','','','','','',
				'','','','','','','','','','',
				'','','','','','','','','','',
				'','','','','','','','','','',
				'','','','','','','','','','');
        IF l_request_id = 0 THEN
          IF l_DEBUG in ('Y', 'C') THEN
  	    cep_standard.debug(FND_MESSAGE.get);
            cep_standard.debug('EXCEPTION: Fail to submit cuncurrent request for '|| l_program_name);
	  END IF;
          RAISE ldr_exception;
        END IF;
      ELSE
        FND_MESSAGE.set_name('CE', 'CE_ERROR_EXIST');
        CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, 0, fnd_message.get, 'W');
      END IF;

    -- END IF; --org_id
    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Insert_Hdr');
  END IF;
EXCEPTION
  WHEN ldr_exception THEN
    RAISE;
  WHEN OTHERS THEN
    l_err := SQLCODE;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Insert_Hdr - '|| to_char(l_err));
    END IF;
    RAISE;
END Insert_Hdr;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Get_Precision 							|
|									|
|  DESCRIPTION								|
|									|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */

FUNCTION Get_Precision(X_precision NUMBER) RETURN NUMBER IS
  l_precision	NUMBER;
BEGIN
  IF nvl(X_precision, 0) = 0 THEN
    l_precision := 1;
  ELSIF X_precision = 1 THEN
    l_precision := 10;
  ELSIF X_precision = 2 THEN
    l_precision := 100;
  ELSIF X_precision = 3 THEN
    l_precision := 1000;
  ELSIF X_precision = 4 THEN
    l_precision := 10000;
  ELSIF X_precision = 5 THEN
    l_precision := 100000;
  END IF;

  RETURN l_precision;
END Get_Precision;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Find_Formatted_String 						|
|									|
|  DESCRIPTION								|
|	Find Bank Transaction number in TRX_TEXT			|
|									|
|  CALLED BY								|
|	Insert Line, Get_Formatted_Sting				|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
FUNCTION Find_Formatted_String(X_format VARCHAR2,
			       X_trx_text varchar2) RETURN VARCHAR2 IS
  l_str		VARCHAR2(150);
  l_len		NUMBER;
  l_pos1	NUMBER;
  l_pos2	NUMBER;
  l_flag	NUMBER;
  l_fixed	VARCHAR2(30);
  l_format	VARCHAR2(1);
  l_fmt 	VARCHAR2(150);
  l_string	VARCHAR2(1);
  l_tmp_str     VARCHAR2(255);
  l_tmp_str2	VARCHAR2(255);
BEGIN
  l_fmt := replace(replace(X_format, '('),')');
  l_len := LENGTH(l_fmt);
  l_pos1 := instr(X_format, '(');

  IF l_pos1 = 1 THEN    -- the format has no indicator
    l_flag := 1;
    l_tmp_str := rtrim(ltrim(substr(X_trx_text, instr(X_trx_text, ' ', -1))));

    IF LENGTH(l_tmp_str) = l_len THEN
      WHILE ( l_len > 0 ) LOOP
        IF ( ( Is_Number(substr(l_tmp_str, l_len, 1))
               AND
               substr(l_fmt, l_len, 1) IN ('a', 'A') )
             OR
             ( NOT Is_Number(substr(l_tmp_str, l_len, 1))
	       AND
               substr(l_fmt, l_len, 1) IN ('n', 'N') ) ) THEN
          l_flag := 0;
          EXIT;		-- Not in the format
        END IF;
        l_len := l_len-1;
      END LOOP;

      IF l_flag = 1 THEN
        RETURN l_tmp_str;
      ELSE
        IF l_tmp_str = X_trx_text THEN   -- Format was not found.
          RETURN NULL;
        END IF;
        RETURN Find_Formatted_String( X_format, substr(X_trx_text, 1, instr(X_trx_text, ' ', -1)-1) );
      END IF;
    ELSE
      IF l_tmp_str = X_trx_text THEN   -- Format was not found.
          RETURN NULL;
      END IF;
      RETURN Find_Formatted_String( X_format, substr(X_trx_text, 1, instr(X_trx_text, ' ', -1)-1) );
    END IF;
  ELSE	-- the format has indicator
    l_fixed := substr(X_format, 1, l_pos1-1);
    l_pos2 := instr(X_trx_text, l_fixed);

    IF l_pos2 = 0 THEN
      RETURN NULL;  -- couldn't find format in TRX_TEXT.
    END IF;

    IF instr(X_format, '~') <> 0 THEN
      l_tmp_str := substr(X_trx_text, l_pos2 + LENGTH(l_fixed)) || ' .';
      RETURN substr(l_tmp_str, 1 , instr(l_tmp_str, ' ')-1);
    END IF;

    l_str := substr(X_trx_text, l_pos2, l_len);

    l_pos1 := l_pos1 + 1;
    l_format := substr(X_format, l_pos1, 1);
    l_string := substr(l_str, l_pos1 - 1, 1);
    WHILE ( l_format <> ')' ) LOOP
      IF ( (l_format in ('A','a') AND Is_Number(l_string))
	   OR
           (l_format in ('N','n') AND NOT Is_Number(l_string)) ) THEN
        RETURN Find_Formatted_String(X_format, REPLACE(X_trx_text, l_str));
      END IF;
      l_pos1 := l_pos1 + 1;
      l_format := substr(X_format, l_pos1, 1);
      l_string := substr(l_str, l_pos1 - 1, 1);
    END LOOP;
  END IF;

  IF G_include_indicator = 'Y' THEN
    RETURN l_str;
  ELSE
    RETURN substr(l_str, LENGTH(l_fixed)+1);
  END IF;
END Find_Formatted_String;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Get_Formatted_Sting 						|
|									|
|  DESCRIPTION								|
|	Decode Bank Trx Number format and call Find_Bank_Trx_Number	|
|									|
|  CALLED BY								|
|	Lookup_val, LOAD_BAI2							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */

FUNCTION Get_Formatted_String(X_string VARCHAR2) RETURN VARCHAR2 IS
  l_pos		NUMBER;
  l_format	VARCHAR2(50);
  l_tmp_format	VARCHAR2(150);
  l_return	VARCHAR2(255);
  l_return_tmp	VARCHAR2(255);
  l_concatenate_format_flag VARCHAR2(1);
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>> Get_Formatted_String' );
    cep_standard.debug('X_string  = '|| X_string );
  END IF;


  l_tmp_format := LTRIM(RTRIM(G_predefined_format));
  l_pos := INSTR(l_tmp_format, ',');
  l_return := NULL;
  l_concatenate_format_flag := nvl(G_concatenate_format_flag, 'N');
  --l_concatenate_format_flag := 'Y';

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('G_concatenate_format_flag = '||G_concatenate_format_flag||'.');
    cep_standard.debug('G_predefined_format = '||G_predefined_format||'.');
    cep_standard.debug('l_pos = '||l_pos||'.');

  END IF;


  WHILE l_pos <> 0 LOOP
    l_format := LTRIM(RTRIM(SUBSTR(l_tmp_format, 1, l_pos-1)));

 -- DBMS_OUTPUT.put_line('l_format 1: '||l_format);
    cep_standard.debug('l_format 1 = '||l_format||'.');

    IF (l_concatenate_format_flag = 'Y') THEN
      IF l_return IS NOT NULL THEN
        l_return := l_return || '/' || Find_Formatted_String(l_tmp_format, x_string);

        IF l_DEBUG in ('Y', 'C') THEN
    	  cep_standard.debug('l_return not null = '||l_return||'.');
  	END IF;
      ELSE
        l_return := Find_Formatted_String(l_tmp_format, x_string);

        IF l_DEBUG in ('Y', 'C') THEN
     	  cep_standard.debug('l_return  null = '||l_return||'.');
  	END IF;
      END IF;
    ELSE
      l_return := Find_Formatted_String(l_format, X_string);

      cep_standard.debug('concat = N - l_return  = '||l_return||'.');

      IF l_return IS NOT NULL THEN
        --l_return := Find_Formatted_String(l_format, X_string);
      	--RETURN l_return;
        IF l_DEBUG in ('Y', 'C') THEN
    	  cep_standard.debug('concat = N - l_return not null = '||l_return||'.');
  	END IF;

	RETURN rtrim(l_return, '/');

      END IF;
    END IF;

    IF l_return IS NOT NULL THEN
    	cep_standard.debug('l_return  = '||l_return||'.');
    END IF;

    l_tmp_format := SUBSTR(l_tmp_format, l_pos+1);
    l_pos := INSTR(l_tmp_format, ',');
  END LOOP;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('l_tmp_format 2 = '||l_tmp_format||'.');
  END IF;

  IF (l_concatenate_format_flag = 'Y') THEN
    IF l_return IS NOT NULL THEN
      l_return := l_return || '/' || Find_Formatted_String(LTRIM(RTRIM(l_tmp_format)), x_string);
    ELSE
      l_return := Find_Formatted_String(LTRIM(RTRIM(l_tmp_format)), x_string);
    END IF;
  ELSE
    --RETURN rtrim(Find_Formatted_String(LTRIM(RTRIM(l_tmp_format)), X_string), '/');
      l_return := rtrim(Find_Formatted_String(LTRIM(RTRIM(l_tmp_format)), X_string), '/');
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
    l_return_tmp :=  rtrim(l_return, '/');
    cep_standard.debug('l_return_tmp = '||l_return_tmp||'.');
  END IF;

    RETURN rtrim(l_return, '/');

END Get_Formatted_String;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Insert_Line 							|
|									|
|  DESCRIPTION								|
|	Insert Line Record to Interface Table.				|
|									|
|  CALLED BY								|
|	Load_BAI2, Load_Others						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Insert_Line IS
  l_rec_cnt	NUMBER;
  l_err  	NUMBER;
  l_row_id	ROWID;
  l_statement_number VARCHAR2(50);
BEGIN
 IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Insert_Line');

  cep_standard.debug('Line_number    	-'||to_char(G_line_number)||'.');
  cep_standard.debug('Statement Number	-'||G_statement_number||'.');
  cep_standard.debug('bank Account Num  -'||G_bank_account_num||'.');
  cep_standard.debug('Trx_date		-'||G_trx_date||'.');
  cep_standard.debug('Trx_code		-'||G_trx_code||'.');
  cep_standard.debug('Amount		-'||to_char(G_amount)||'.');
  cep_standard.debug('Trx Text		-'||G_trx_text||'.');
  cep_standard.debug('Customer Text	-'||G_customer_text||'.');
  cep_standard.debug('Invoice Text	-'||G_invoice_text||'.');
  cep_standard.debug('Bank Account Text -'||G_bank_account_text||'.');
  cep_standard.debug('Effective Date	-'||G_effective_date||'.');
  cep_standard.debug('Currency Code  	-'||G_line_currency_code||'.');
  cep_standard.debug('Exchange Rate    	-'||G_exchange_rate||'.');
  cep_standard.debug('Bank Trx Number	-'||G_bank_trx_number||'.');
  cep_standard.debug('Created By	-'||G_user_id||'.');
  cep_standard.debug('Creation Date	-'||to_char(SYSDATE)||'.');
  cep_standard.debug('User Ex Rate	-'||G_user_exchange_rate_type||'.');
  cep_standard.debug('Exchange rate Date-'||G_exchange_rate_date||'.');
  cep_standard.debug('Original_Amount 	-'||G_original_amount||'.');
  cep_standard.debug('Charges_Amount 	-'||G_charges_amount||'.');

  cep_standard.debug('Insert Line'||to_char(G_line_number));
 END IF;

  IF G_format_type = 'SWIFT940' THEN
    l_statement_number := G_statement_number || ' - ' || to_char(sysdate);
  ELSE
    l_statement_number := G_statement_number;
  END IF;

  IF Valid_Statement THEN
    --
    -- Overwrite the existing bank statement of the same bank account and statement number.
    --
    SELECT count(*)
    INTO   l_rec_cnt
    FROM   ce_statement_lines_interface
    WHERE  bank_account_num = G_bank_account_num
    AND	   statement_number = l_statement_number
    AND    line_number      = G_line_number;

    IF l_rec_cnt > 0 THEN
      DELETE FROM ce_statement_lines_interface
      WHERE  bank_account_num = G_bank_account_num
      AND    statement_number = l_statement_number
      AND    line_number      = G_line_number;
      G_total_line_deleted := G_total_line_deleted + l_rec_cnt;
    END IF;

    G_invoice_text 	:= rtrim(rtrim(G_invoice_text),'/');
    G_trx_text		:= rtrim(rtrim(rtrim(G_trx_text),'/'));
    G_bank_account_text := rtrim(rtrim(G_bank_account_text),'/');
    G_customer_text	:= rtrim(rtrim(G_customer_text),'/');
    G_bank_trx_number	:= rtrim(rtrim(G_bank_trx_number),'/');

    CE_STAT_LINES_INF_PKG.Insert_Row(l_row_id,
                       rtrim(G_bank_account_num),
                       rtrim(l_statement_number),
                       to_number(rtrim(G_line_number)),
                       rtrim(G_trx_date),
                       rtrim(G_trx_code),
                       rtrim(G_effective_date),
                       G_trx_text,
                       G_invoice_text,
		       G_bank_account_text,
                       to_number(G_amount),
                       to_number(rtrim(G_charges_amount)),
		       rtrim(G_line_currency_code),
                       to_number(G_exchange_rate),
                       rtrim(G_user_exchange_rate_type),
                       rtrim(G_exchange_rate_date),
		       to_number(rtrim(G_original_amount)),
                       G_bank_trx_number,
                       G_customer_text,
                       to_number(G_user_id),
                       SYSDATE,
                       to_number(G_user_id),
                       SYSDATE,
                       NULL,
                       NULL, NULL, NULL, NULL, NULL,
                       NULL, NULL, NULL, NULL, NULL,
                       NULL, NULL, NULL, NULL, NULL);
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Insert_Line');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLCODE;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Insert_Line - '|| to_char(l_err));
    END IF;
    RAISE;
END Insert_Line;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Get_Value 							|
|									|
|  DESCRIPTION								|
|	Returns the value of the position. Created to prevent using	|
|	dynamic SQL.							|
|									|
|  CALLED BY								|
|	Lookup_Val							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUL-2002	Created		BYLEUNG				|
 --------------------------------------------------------------------- */
FUNCTION Get_Value(X_pos	IN	NUMBER,
		X_rec_no	IN	NUMBER) RETURN VARCHAR2 IS
  l_result      VARCHAR2(255);
BEGIN
  IF (X_pos = 1) THEN
    SELECT substr(rtrim(ltrim(column1)),1,255)
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 2) THEN
    SELECT rtrim(ltrim(column2))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 3) THEN
    SELECT rtrim(ltrim(column3))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 4) THEN
    SELECT rtrim(ltrim(column4))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 5) THEN
    SELECT rtrim(ltrim(column5))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 6) THEN
    SELECT rtrim(ltrim(column6))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 7) THEN
    SELECT rtrim(ltrim(column7))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 8) THEN
    SELECT rtrim(ltrim(column8))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 9) THEN
    SELECT rtrim(ltrim(column9))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 10) THEN
    SELECT rtrim(ltrim(column10))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 11) THEN
    SELECT rtrim(ltrim(column11))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 12) THEN
    SELECT rtrim(ltrim(column12))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 13) THEN
    SELECT rtrim(ltrim(column13))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 14) THEN
    SELECT rtrim(ltrim(column14))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 15) THEN
    SELECT rtrim(ltrim(column15))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 16) THEN
    SELECT rtrim(ltrim(column16))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 17) THEN
    SELECT rtrim(ltrim(column17))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 18) THEN
    SELECT rtrim(ltrim(column18))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 19) THEN
    SELECT rtrim(ltrim(column19))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 20) THEN
    SELECT rtrim(ltrim(column20))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 21) THEN
    SELECT rtrim(ltrim(column21))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 22) THEN
    SELECT rtrim(ltrim(column22))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 23) THEN
    SELECT rtrim(ltrim(column23))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 24) THEN
    SELECT rtrim(ltrim(column24))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 25) THEN
    SELECT rtrim(ltrim(column25))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 26) THEN
    SELECT rtrim(ltrim(column26))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 27) THEN
    SELECT rtrim(ltrim(column27))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 28) THEN
    SELECT rtrim(ltrim(column28))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 29) THEN
    SELECT rtrim(ltrim(column29))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 30) THEN
    SELECT rtrim(ltrim(column30))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 31) THEN
    SELECT rtrim(ltrim(column31))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 32) THEN
    SELECT rtrim(ltrim(column32))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 33) THEN
    SELECT rtrim(ltrim(column33))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 34) THEN
    SELECT rtrim(ltrim(column34))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  ELSIF (X_pos = 35) THEN
    SELECT rtrim(ltrim(column35))
    INTO l_result
    FROM ce_stmt_int_tmp
    WHERE rec_no = X_rec_no;
  END IF;

  --
  -- If format is entered then search for the target string.
  --
  IF G_predefined_format IS NOT NULL THEN
    l_result := Get_Formatted_String(nvl(l_result,'x'));
  END IF;

  return(l_result);
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: Get_Value - X_pos '|| to_char(X_pos)||', X_rec_no '|| to_char(X_rec_no));
    END IF;
    RAISE;
END Get_Value;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Lookup_Pos 							|
|									|
|  DESCRIPTION								|
|	Returns the position of the column.				|
|									|
|  CALLED BY								|
|	Lookup_val							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Lookup_Pos(X_hdr_line			IN	VARCHAR2,
		     X_column			IN	VARCHAR2,
		     X_position			OUT NOCOPY 	NUMBER) IS
  CURSOR C_h IS
    SELECT nvl(position,0),
	   format,
	   include_format_ind,
	   concatenate_format_flag
    FROM   ce_bank_stmt_map_hdr_v
    WHERE  map_id	= G_map_id
    AND	   column_name 	= X_column;

  CURSOR C_l IS
    SELECT nvl(position,0),
	   format,
	   include_format_ind,
	   concatenate_format_flag
    FROM   ce_bank_stmt_map_line_v
    WHERE  map_id 	= G_map_id
    AND	   column_name 	= X_column;

  l_pos		NUMBER;
  l_err		NUMBER;
BEGIN
  IF X_hdr_line = 'H' THEN
    OPEN C_h;
    FETCH C_h INTO X_position, G_predefined_format, G_include_indicator, G_concatenate_format_flag;
    CLOSE C_h;
  ELSE
    OPEN C_l;
    FETCH C_l INTO X_position, G_predefined_format, G_include_indicator, G_concatenate_format_flag;
    CLOSE C_l;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_position := 0;
  WHEN OTHERS THEN
    l_err := SQLCODE;
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: Lookup_Pos - '|| to_char(l_err));
    END IF;
    RAISE;
END Lookup_Pos;

FUNCTION Find_Last_Column_Pos(X_rec_no     NUMBER) RETURN NUMBER IS
  l_str		VARCHAR2(50);
BEGIN
  SELECT substr(column1,1,1)||substr(column2,1,1)||substr(column3,1,1)||substr(column4,1,1)||substr(column5,1,1)||
         substr(column6,1,1)||substr(column7,1,1)||substr(column8,1,1)||substr(column9,1,1)||substr(column10,1,1)||
 	 substr(column11,1,1)||substr(column12,1,1)||substr(column13,1,1)||substr(column14,1,1)||substr(column15,1,1)||
         substr(column16,1,1)||substr(column17,1,1)||substr(column18,1,1)||substr(column19,1,1)||substr(column20,1,1)||
 	 substr(column21,1,1)||substr(column22,1,1)||substr(column23,1,1)||substr(column24,1,1)||substr(column25,1,1)||
         substr(column26,1,1)||substr(column27,1,1)||substr(column28,1,1)||substr(column29,1,1)||substr(column30,1,1)||
 	 substr(column31,1,1)||substr(column32,1,1)||substr(column33,1,1)||substr(column34,1,1)||substr(column35,1,1)
  INTO   l_str
  FROM   ce_stmt_int_tmp
  WHERE  rec_no = X_rec_no;

  RETURN LENGTH(l_str);
END Find_Last_Column_Pos;


/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Lookup_Val 							|
|									|
|  DESCRIPTION								|
|	Locates the taget data using mapping info and returns it.	|
|									|
|  CALLED BY								|
|	Load_BAI2							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
FUNCTION Lookup_Val(X_hdr_line	VARCHAR2,
		    X_rec_no	NUMBER,
		    X_column	VARCHAR2,
		    X_rec_len   NUMBER 	DEFAULT 0) RETURN VARCHAR2 IS
  l_pos		NUMBER;
  l_value	VARCHAR2(255);
BEGIN
  Lookup_Pos(X_hdr_line, X_column, l_pos);
  IF l_pos = 0 THEN
   l_value := NULL;
  ELSE
    IF l_pos < 0 THEN
      IF X_rec_len = 0 THEN
        l_pos := Find_Last_Column_Pos(X_rec_no) + 1 + l_pos;
      ELSE
        l_pos := X_rec_len + l_pos;
      END IF;
    END IF;
    l_value := Get_Value(l_pos, X_rec_no);
  END IF;

  RETURN l_value;
END Lookup_Val;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Hdr_Or_Line 							|
|									|
|  DESCRIPTION								|
|	Find out NOCOPY if the given record is header or line info.		|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
FUNCTION Hdr_Or_Line(X_rec_id 	VARCHAR2) RETURN VARCHAR2 IS
  l_hdr		NUMBER;
  l_line	NUMBER;
BEGIN
  SELECT count(*)
  INTO   l_hdr
  FROM   CE_BANK_STMT_MAP_HDR
  WHERE  map_id = G_map_id
  AND    rec_id_no = X_rec_id;

  SELECT count(*)
  INTO   l_line
  FROM   CE_BANK_STMT_MAP_LINE
  WHERE  map_id = G_map_id
  AND    rec_id_no = X_rec_id;

  IF (l_hdr > 0 AND l_line > 0) THEN
    RETURN 'B';
  ELSIF l_hdr > 0 THEN
    RETURN 'H';
  ELSIF l_line > 0 THEN
    RETURN 'L';
  ELSE
    RETURN 'N';
  END IF;
END Hdr_Or_Line;


/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|   Valid_Bank_Account                                                  |
|                                                                       |
|  DESCRIPTION                                                          |
|   validate the bank account.                                          |
|                                                                       |
|  CALLED BY                                                            |
|   Load_BAI2                                                           |
|  REQUIRES                                                             |
|                                                                       |
|  HISTORY                                                              |
|   19-MAY-1999  BHCHUNG    Created  	                                |
|   25-FEB-2009  VNETAN     Bug 8209720 Modified C_bank cursor and      |
|                           l_cnt query to consider bank_branch_id and  |
|                           bank_account_id                             |
 --------------------------------------------------------------------- */
FUNCTION Valid_Bank_Account RETURN BOOLEAN IS
    CURSOR C_bank IS
        SELECT  BB.bank_name,
                BB.bank_branch_name,
                BB.branch_party_id,
                BA.bank_account_id,
                BA.currency_code
        FROM    CE_BANK_ACCOUNTS BA,
                CE_BANK_BRANCHES_V BB
        WHERE   BB.branch_party_id   = BA.bank_branch_id
         AND    BA.bank_account_num = G_bank_account_num
         AND    NVL(BA.account_classification,'DUMMY') = 'INTERNAL'               -- Bug 6511845
         AND    NVL(G_Bank_Branch_id, BA.Bank_branch_id) = BA.bank_branch_id      -- Bug 8209720
         AND    NVL(G_bank_account_id, BA.bank_account_id) = BA.bank_account_id;  -- Bug 8209720

    l_cnt		NUMBER;

BEGIN
    cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.valid_bank_account');
    IF G_bank_account_num IS NULL THEN
        cep_standard.debug('G_bank_account_num is null');
        FND_MESSAGE.set_name('CE', 'CE_SQLLDR_MISS_REQ_FIELD');
        FND_MESSAGE.set_token('FIELD', 'BANK_ACCOUNT_NUM');
        CE_SQLLDR_ERRORS_PKG.insert_row(
                NVL(G_statement_number, 'XXXXXXXXXXX'),
                NVL(G_bank_account_num, 'XXXXXXXXXXX'),
                G_rec_no, fnd_message.get, 'E');
        RETURN FALSE;
    END IF;

    SELECT count(*)
    INTO   l_cnt
    FROM   CE_BANK_ACCOUNTS
    WHERE  BANK_ACCOUNT_NUM = G_bank_account_num
     AND   NVL(ACCOUNT_CLASSIFICATION,'DUMMY') = 'INTERNAL'            -- Bug 6511845
     AND   NVL(G_Bank_Branch_id,Bank_branch_id) = Bank_branch_id       -- Bug 8209720
     AND   NVL(G_bank_account_id, bank_account_id) = bank_account_id;  -- Bug 8209720

    cep_standard.debug('l_cnt = '||to_char(l_cnt));
    IF l_cnt = 0 THEN      -- Bank account is not setup.
        FND_MESSAGE.set_name('CE', 'CE_BANK_ACCNT_NOT_DEFINED');
        FND_MESSAGE.set_token('BANK_ACCNT',G_bank_account_num);
        CE_SQLLDR_ERRORS_PKG.insert_row(
                G_statement_number,
                G_bank_account_num,
                G_rec_no, fnd_message.get, 'E');
        RETURN FALSE;

    ELSIF l_cnt > 1 THEN   -- There are more than one bank with this account number.
        FND_MESSAGE.set_name('CE', 'CE_TOO_MANY_BANK_ACCNT');
        FND_MESSAGE.set_token('BANK_ACCNT',G_bank_account_num);
        CE_SQLLDR_ERRORS_PKG.insert_row(
            G_statement_number,
            G_bank_account_num,
            G_rec_no, fnd_message.get, 'W');

    ELSE
        IF ( G_bank_name IS NULL OR G_bank_branch_name IS NULL OR G_hdr_currency_code IS NULL) THEN
            OPEN  C_bank;
            FETCH C_bank INTO G_bank_name, G_bank_branch_name, G_sub_branch_id,
                              G_sub_account_id, G_hdr_currency_code; --, G_org_id;
            CLOSE C_bank;
        END IF;

    END IF;

    cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.valid_bank_account');
    RETURN TRUE;

END Valid_Bank_Account;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Decode_Line_BAI 						|
|									|
|  DESCRIPTION								|
|	Decode record 16 and populate TEXT information.			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Decode_Line_BAI(X_rec_no NUMBER) IS
  CURSOR C_rec IS
    SELECT column3, column4
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;

  l_val1	VARCHAR2(100);
  l_val2	VARCHAR2(100);
  l_val3	VARCHAR2(100);
  l_rec_len     NUMBER;
  l_err		NUMBER;

  l_str		VARCHAR2(2000);
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Decode_Line_BAI');
  END IF;

  OPEN 	C_rec;
  FETCH C_rec
  INTO 	l_val1, l_val2;
  CLOSE C_rec;

  IF l_val1 = 'S' THEN
    l_rec_len := 10;
  ELSIF l_val1 = 'V' THEN
    l_rec_len := 9;
    G_effective_date := CONV_TO_DATE(l_val2);
  ELSIF l_val1 = 'D' THEN
    l_rec_len := 8 + to_number(l_val2) * 2;
  ELSE
    l_rec_len := 7;
  END IF;

  G_trx_text := substr(Lookup_Val('L', X_rec_no, 'TRX_TEXT', l_rec_len), 1, 255);
  G_invoice_text := substr(Lookup_Val('L', X_rec_no, 'INVOICE_TEXT', l_rec_len), 1, 30);
  G_customer_text := substr(Lookup_Val('L', X_rec_no, 'CUSTOMER_TEXT', l_rec_len), 1, 80);
  G_bank_account_text := substr(Lookup_Val('L', X_rec_no, 'BANK_ACCOUNT_TEXT', l_rec_len), 1, 30);
  G_bank_trx_number := substr(Lookup_Val('L', X_rec_no, 'BANK_TRX_NUMBER', l_rec_len), 1, 240);

  G_trx_date := CONV_TO_DATE(Lookup_Val('L', X_rec_no, 'TRX_DATE', l_rec_len));
  -- G_effective_date := CONV_TO_DATE(Lookup_Val('L', X_rec_no, 'EFFECTIVE_DATE', l_rec_len));
  G_line_currency_code :=  substr(Lookup_Val('L', X_rec_no, 'CURRENCY_CODE', l_rec_len), 1, 15);
  G_exchange_rate := to_number(Lookup_Val('L', X_rec_no, 'EXCHANGE_RATE', l_rec_len));
  G_user_exchange_rate_type := substr(Lookup_Val('L', X_rec_no, 'USER_EXCHANGE_RATE_TYPE', l_rec_len), 1, 30);
  G_exchange_rate_date :=  CONV_TO_DATE(Lookup_Val('L', X_rec_no, 'EXCHANGE_RATE_DATE', l_rec_len));
  G_original_amount := to_number(Lookup_Val('L', X_rec_no, 'ORIGINAL_AMOUNT', l_rec_len)) / G_line_precision;
  G_charges_amount := to_number(Lookup_Val('L', X_rec_no, 'CHARGES_AMOUNT', l_rec_len)) / G_line_precision;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Decode_Line_BAI');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLCODE;
    FND_MESSAGE.set_name('CE', 'CE_RECORD_FAIL');
    FND_MESSAGE.set_token('ERR', to_char(l_err));
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, nvl(X_rec_no, 0), fnd_message.get);
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Decode_Line_BAI - '|| to_char(l_err));
    END IF;
END Decode_Line_BAI;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	Find_Columns 							|
|									|
|  DESCRIPTION								|
|	Find consecutive 5 columns. Created to prevent using dynamic	|
|	SQL.								|
|									|
|  CALLED BY								|
|	Decode_Hdr_BAI							|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUL-2002	Created		BYLEUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Find_Columns(	X_cnt		IN	NUMBER,
			X_rec_no	IN	NUMBER,
			X_col1		OUT NOCOPY	VARCHAR2,
			X_col2		OUT NOCOPY	VARCHAR2,
			X_col3		OUT NOCOPY	VARCHAR2,
			X_col4		OUT NOCOPY	VARCHAR2,
			X_col5		OUT NOCOPY	VARCHAR2) IS
BEGIN
  IF (X_cnt = 1) THEN
    SELECT column1, column2, column3, column4, column5
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 2) THEN
    SELECT column2, column3, column4, column5, column6
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 3) THEN
    SELECT column3, column4, column5, column6, column7
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 4) THEN
    SELECT column4, column5, column6, column7, column8
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 5) THEN
    SELECT column5, column6, column7, column8, column9
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 6) THEN
    SELECT column6, column7, column8, column9, column10
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 7) THEN
    SELECT column7, column8, column9, column10, column11
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 8) THEN
    SELECT column8, column9, column10, column11, column12
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 9) THEN
    SELECT column9, column10, column11, column12, column13
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 10) THEN
    SELECT column10, column11, column12, column13, column14
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 11) THEN
    SELECT column11, column12, column13, column14, column15
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 12) THEN
    SELECT column12, column13, column14, column15, column16
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 13) THEN
    SELECT column13, column14, column15, column16, column17
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 14) THEN
    SELECT column14, column15, column16, column17, column18
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 15) THEN
    SELECT column15, column16, column17, column18, column19
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 16) THEN
    SELECT column16, column17, column18, column19, column20
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 17) THEN
    SELECT column17, column18, column19, column20, column21
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 18) THEN
    SELECT column18, column19, column20, column21, column22
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 19) THEN
    SELECT column19, column20, column21, column22, column23
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 20) THEN
    SELECT column20, column21, column22, column23, column24
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 21) THEN
    SELECT column21, column22, column23, column24, column25
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 22) THEN
    SELECT column22, column23, column24, column25, column26
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 23) THEN
    SELECT column23, column24, column25, column26, column27
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 24) THEN
    SELECT column24, column25, column26, column27, column28
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 25) THEN
    SELECT column25, column26, column27, column28, column29
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 26) THEN
    SELECT column26, column27, column28, column29, column30
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 27) THEN
    SELECT column27, column28, column29, column30, column31
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 28) THEN
    SELECT column28, column29, column30, column31, column32
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 29) THEN
    SELECT column29, column30, column31, column32, column33
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 30) THEN
    SELECT column30, column31, column32, column33, column34
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 31) THEN
    SELECT column31, column32, column33, column34, column35
    INTO   X_col1, X_col2, X_col3, X_col4, X_col5
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  ELSIF (X_cnt = 32) THEN
    SELECT column32, column33, column34, column35
    INTO   X_col1, X_col2, X_col3, X_col4
    FROM   ce_stmt_int_tmp
    WHERE  rec_no = X_rec_no;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: Find_Columns - X_cnt '|| to_char(X_cnt)||', X_rec_no '|| to_char(X_rec_no));
    END IF;
    RAISE;
END Find_Columns;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Decode_Hdr_BAI 							|
|									|
|  DESCRIPTION								|
|	Decode record 03 and 88 and populate CONTROL information.	|
|									|
|  CALLED BY								|
|	Load_BAI2							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Decode_Hdr_BAI(X_rec_id	VARCHAR2,
		     X_rec_no	NUMBER) IS
  l_cnt		NUMBER;
  l_cursor_id	INTEGER;
  l_exec_id	INTEGER;
  l_query	VARCHAR2(1000);
  l_val1	VARCHAR2(100);
  l_val2	VARCHAR2(100);
  l_val3	VARCHAR2(100);
  l_val4	VARCHAR2(100);
  l_val5	VARCHAR2(100);
  l_temp_val1	VARCHAR2(100);
  l_temp_val2   VARCHAR2(100);
  l_temp_val3	VARCHAR2(100);
  l_temp_val4	VARCHAR2(100);
  l_temp_val5	VARCHAR2(100);
  l_err		NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Decode_Hdr_BAI');
  END IF;

  IF X_rec_id in ('3','03') THEN
    l_cnt := 3;
  ELSIF X_rec_id = '88' THEN
	/*bug5124547*/
	if G_lcnt <> 0 then
	    l_cnt := 1+G_lcnt;
	    G_lcnt :=0;
	else
	   l_cnt := 1;
	end if;
	/*bug5124547*/
  END IF;
  WHILE (l_cnt <= 32) LOOP
    Find_Columns(l_cnt, X_rec_no, l_val1, l_val2, l_val3, l_val4, l_val5);

  /* bug 3771128. Remove the '/' character.Check if the last
	read value is a trx_code i.e., g_last_val1 is not null then
	swap the values so that the values are correctly placed in
	the corresponding variables. This will simulate the 88 record
	as being started with a trx_code. - Start*/
/*bug5100563*/
    IF n =1 then
	l_val5 := l_val4;
	l_val4 := l_val3;
	l_val3 := l_val2;
	l_val2 := l_val1;
	l_val1 := G_last_val1;
	l_cnt := l_cnt -1;
	n:=0;
    ELSIF n =2 then
	l_val5 := l_val3;
	l_val4 := l_val2;
	l_val3 := l_val1;
	l_val2 := G_last_val2;
	l_val1 := G_last_val1;
	l_cnt := l_cnt -2;
	n:=0;
    ELSIF n =3 then
	l_val5 := l_val2;
	l_val4 := l_val1;
	l_val3 := G_last_val3;
	l_val2 := G_last_val2;
	l_val1 := G_last_val1;
	l_cnt := l_cnt -3;
	n:=0;
    END IF;

 IF rtrim(rtrim(l_val1),'/') IS NOT NULL THEN --7688232  If condition added
    if (instr(l_val1,'/') >0) then
	l_val1 := rtrim(rtrim(l_val1),'/');
	G_last_val1:= l_val1;
	n:=1;
	exit;
    elsif (instr(l_val2,'/') >0) then
	l_val1 := rtrim(rtrim(l_val1),'/');
	l_val2 := rtrim(rtrim(l_val2),'/');
	G_last_val1:= l_val1;
	G_last_val2:= l_val2;
	n:=2;
	exit;
    elsif (instr(l_val3,'/') >0) then
	l_val1 := rtrim(rtrim(l_val1),'/');
	l_val2 := rtrim(rtrim(l_val2),'/');
	l_val3 := rtrim(rtrim(l_val3),'/');
	G_last_val1:= l_val1;
	G_last_val2:= l_val2;
	G_last_val3:= l_val3;
	n:=3;
	exit;
    end if;
 END IF; --7688232
/*bug5100563*/
    IF l_val1 = '010' THEN
      G_control_begin_balance := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '015' THEN
      G_control_end_balance := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '045' THEN
      G_cashflow_balance := to_number(l_val2)/G_hdr_precision;
      G_int_calc_balance := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '020' THEN
      G_average_close_ledger_mtd := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '025' THEN
      G_average_close_ledger_ytd := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '050' THEN
      G_average_close_available_mtd := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '055' THEN
      G_average_close_available_ytd := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '072' THEN
      G_one_day_float := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '074' THEN
      G_two_day_float := to_number(l_val2)/G_hdr_precision;
    ELSIF l_val1 = '400' THEN
		G_control_total_dr := to_number(l_val2)/G_hdr_precision;
		IF(l_val3 IS NOT NULL) THEN     -- Bug 9005502 Added if Condition
	      /*Bug 3164477 added the following 2 lines for dr line count*/
	      G_control_dr_line_count := to_number(l_val3);
	      select decode(G_control_dr_line_count,null,
	                    G_control_line_count,
				nvl(G_control_line_count,0)+G_control_dr_line_count)
		     into G_control_line_count from dual;
		END IF;      -- Bug 9005502 Added if Condition
    ELSIF l_val1 = '100' THEN
		G_control_total_cr := to_number(l_val2)/G_hdr_precision;
		IF(l_val3 IS NOT NULL) THEN  -- Bug 9005502 Added if Condition
		     /*Bug 3164477 added the following 2 lines for cr line count*/
		      G_control_cr_line_count := to_number(l_val3);
		      select decode(G_control_cr_line_count,null,
		                    G_control_line_count,
					nvl(G_control_line_count,0)+G_control_cr_line_count)
			     into G_control_line_count from dual;
		END IF;        -- Bug 9005502 Added if Condition
	-- Bug 9005502 Start
    ELSIF L_VAL1 = '102' THEN
		G_control_cr_line_count := to_number(l_val2);
		G_control_line_count := Nvl(G_control_line_count,0) + Nvl(G_control_cr_line_count,0);


    ELSIF L_VAL1 = '402' THEN
		G_control_dr_line_count := to_number(l_val2);
		G_control_line_count :=  Nvl(G_control_line_count,0) + Nvl(G_control_dr_line_count,0);
	-- Bug 9005502 End

	END IF;


   IF l_val4 = 'S' THEN
	/*bug5124547*/
	Find_Columns(l_cnt+4,X_rec_no, l_temp_val1, l_temp_val2, l_temp_val3, l_temp_val4, l_temp_val5);
	if (instr(l_temp_val1,'/')>0) then
		G_lcnt :=2;
	elsif (instr(l_temp_val2,'/')>0) then
		G_lcnt :=1;
	elsif (instr(l_temp_val3,'/')>0) then
		G_lcnt :=0;
	end if;
	      l_cnt := l_cnt + 7;
	/*bug5124547*/
    ELSIF l_val4 = 'V' THEN
      l_cnt := l_cnt + 6;
    ELSIF l_val4 = 'D' THEN
      l_cnt := l_cnt + 5 + to_number(l_val5) * 2;
    ELSE
      l_cnt := l_cnt + 4;
    END IF;
  END LOOP;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Decode_Hdr_BAI');
  END IF;
EXCEPTION  -- Bug 3608257 added this EXCEPTION section
  WHEN OTHERS THEN
    l_err := SQLCODE;
    FND_MESSAGE.set_name('CE', 'CE_RECORD_FAIL');
    FND_MESSAGE.set_token('ERR', to_char(l_err));
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, nvl(X_rec_no, 0), fnd_message.get);
    cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Decode_Hdr_BAI - '|| to_char(l_err));
END Decode_Hdr_BAI;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Load_BAI2 							|
|									|
|  DESCRIPTION								|
|	Loading engine for BAI2 format.					|
|									|
|  CALLED BY								|
|	Load_Bank_Statement						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Load_BAI2 IS

  CURSOR C_tmp_tbl IS
    SELECT rec_no, rec_id_no, column1, rtrim(replace(column2,' '),'/') col2, column6, rtrim(replace(column8,' '),'/') col8
    FROM   ce_stmt_int_tmp
    ORDER BY rec_no;

  CURSOR C_trx_text IS
    SELECT  column_name,
            format,
            include_format_ind,
	    concatenate_format_flag
    FROM    ce_bank_stmt_map_line
    WHERE   map_id = G_map_id
    AND     position = -1;

  l_control_total_cr	NUMBER	:= 0;  -- Calculate total credit  amount.
  l_control_total_dr	NUMBER	:= 0;  -- Calculate total debit  amount.
  l_control_total_cnt	NUMBER	:= 0;  -- Count total number of records in 03,16,88,49.
  l_rec_cnt    		NUMBER;	       -- Count total number of records in 03,16,88,49.
  l_cnt			NUMBER;

  l_currency_code	VARCHAR2(15);
  l_line_cnt   		NUMBER;
  l_last_rid   		VARCHAR2(2);
  l_err	       		NUMBER;
  l_statement_date	DATE;
  l_bank_trx_num	VARCHAR2(240);
  l_process_this_record BOOLEAN := TRUE; /* 2643505 */
  l_rec ce_stmt_int_tmp%rowtype; -- Bug 3228203

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Load_BAI');
  END IF;

  FOR C_rec IN C_tmp_tbl LOOP
    G_rec_no := C_rec.rec_no;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('CE_BANK_STATEMENT_LOADER.Load_BAI - G_rec_no = '||G_rec_no );
    END IF;

    IF ( G_rec_no = 1 AND
         C_rec.rec_id_no <> '01' ) THEN
      FND_MESSAGE.set_name('CE', 'CE_INVALID_BAI2');
      CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, C_rec.rec_no, fnd_message.get, 'E');
      EXIT;
    ELSIF C_rec.rec_id_no = '01' THEN
      Init_Hdr_Rec;
      Init_Line_Rec;
      l_line_cnt := 0;
      l_last_rid := '1';
      IF nvl(C_rec.col8,'X') <> '2' THEN
        FND_MESSAGE.set_name('CE', 'CE_INVALID_BAI2');
        CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, C_rec.rec_no, fnd_message.get, 'E');
        EXIT;
      END IF;
    ELSIF C_rec.rec_id_no = '02' THEN

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>C_rec.rec_id_no = 02');
    END IF;

      G_statement_number := lookup_val('H', C_rec.rec_no, 'STATEMENT_NUMBER');

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('G_statement_number = '|| G_statement_number);
    END IF;

      G_statement_date   := CONV_TIMESTAMP(lookup_val('H', C_rec.rec_no, 'STATEMENT_DATE') || ' ' || lookup_val('H', C_rec.rec_no, 'STATEMENT_TIMESTAMP'));

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('G_statement_date = '|| G_statement_date);
    END IF;

      IF G_statement_number IS NULL THEN
        FND_MESSAGE.set_name('CE', 'CE_SQLLDR_MISS_REQ_FIELD');
        FND_MESSAGE.set_token('FIELD', 'STATEMENT_NUMBER');
        CE_SQLLDR_ERRORS_PKG.insert_row('XXXXXXXXXXX' , NVL(G_bank_account_num, 'XXXXXXXXXXX'),
				C_rec.rec_no, fnd_message.get);
        EXIT;
      END IF;

      IF G_statement_date IS NULL THEN
        FND_MESSAGE.set_name('CE', 'CE_SQLLDR_MISS_REQ_FIELD');
        FND_MESSAGE.set_token('FIELD', 'STATEMENT_DATE');
        CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, NVL(G_bank_account_num, 'XXXXXXXXXXX'),
				C_rec.rec_no, fnd_message.get);
        EXIT;
      END IF;

      l_statement_date	 := G_statement_date;
      l_currency_code	 := C_rec.column6;
      l_last_rid := '2';

      -- Added for p2p
      IF (G_gl_date_source = 'STATEMENT') THEN
        G_gl_date := trunc(G_statement_date);
      END IF;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<C_rec.rec_id_no = 02');
    END IF;

    ELSIF C_rec.rec_id_no = '03' THEN
      l_rec_cnt := 1;

      G_bank_account_num  := lookup_val('H', C_rec.rec_no, 'BANK_ACCOUNT_NUM');
      G_hdr_precision := Get_Precision(to_number(Lookup_Val('H', C_rec.rec_no, 'PRECISION')));
      IF ( G_hdr_precision = 1 AND G_precision <> 1 )THEN
        G_hdr_precision := G_precision;
      ELSIF ( G_hdr_precision <> 1 AND G_precision = 1 )THEN
        G_precision := G_hdr_precision;
      END IF;

      G_hdr_currency_code := nvl(lookup_val('H', C_rec.rec_no, 'CURRENCY_CODE'), l_currency_code);

      /* 2643505 Added */
      IF Valid_Bank_Account THEN
		l_process_this_record := TRUE;
      ELSE
		l_process_this_record := FALSE;
      END IF;
      /* 2643505 End Code Added */

      Decode_Hdr_BAI(C_rec.rec_id_no, C_rec.rec_no);

      l_last_rid := '3';
    ELSIF C_rec.rec_id_no = '16' THEN
      Init_Line_Rec;
      l_line_cnt := l_line_cnt + 1;
      l_rec_cnt := l_rec_cnt + 1;

      G_line_number      	:= l_line_cnt;

      G_line_precision := Get_Precision(to_number(Lookup_Val('L', C_rec.rec_no, 'PRECISION')));
      IF ( G_line_precision = 1 AND G_precision <> 1 )THEN
        G_line_precision := G_precision;
      END IF;

      G_trx_code := lookup_val('L', C_rec.rec_no, 'TRX_CODE');
      G_amount   := to_number(lookup_val('L', C_rec.rec_no, 'AMOUNT'))/G_line_precision;

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug('Decode_Line_BAI(C_rec.rec_no)  = ' );
      END IF;

      Decode_Line_BAI(C_rec.rec_no);

      IF (to_number(G_trx_code) BETWEEN 100 AND 399) THEN
        l_control_total_cr := l_control_total_cr + G_amount;
      /* 2933873
         New specifications state that transaction codes upto 890
         can be used for Debit
      ELSIF (to_number(G_trx_code) BETWEEN 400 AND 699) THEN */
      ELSIF (to_number(G_trx_code) BETWEEN 400 AND 760) THEN
        l_control_total_dr := l_control_total_dr + G_amount;
      ELSIF (to_number(G_trx_code)=890 AND G_amount IS NULL) THEN    --Start 9381722
        G_amount:=0;
      END IF;

      IF G_trx_date IS NULL THEN
        G_trx_date		:= NVL(G_statement_date, l_statement_date);
      END IF;

      l_last_rid := '16';
      /* 2643505 Added the IF Condition */
      IF (l_process_this_record) THEN
      		Insert_Line;
      END IF;

    ELSIF C_rec.rec_id_no = '88' THEN
      l_rec_cnt := l_rec_cnt + 1;

      IF l_last_rid = '3' THEN
        Decode_Hdr_BAI(C_rec.rec_id_no, C_rec.rec_no);
      ELSIF l_last_rid = '16' THEN
	/* 2643505 Added the IF Condition */
	IF l_process_this_record THEN
	/* Bug3228203 added the following select stmt and modified
	   the next update stmt.*/
 	SELECT * INTO l_rec FROM ce_stmt_int_tmp
	WHERE rec_id_no = C_rec.rec_id_no AND rec_no = C_rec.rec_no;

         /* Bug 6792668 Added rtrim */

         UPDATE 	ce_statement_lines_interface
         SET  trx_text = rtrim(substr(ltrim(rtrim(trx_text ||' '|| C_rec.column1)) ||
	 decode(l_rec.column2,null,null,','||ltrim(rtrim(l_rec.column2))) ||
	 decode(l_rec.column3,null,null,','||ltrim(rtrim(l_rec.column3))) ||
	 decode(l_rec.column4,null,null,','||ltrim(rtrim(l_rec.column4))) ||
	 decode(l_rec.column5,null,null,','||ltrim(rtrim(l_rec.column5))) ||
	 decode(l_rec.column6,null,null,','||ltrim(rtrim(l_rec.column6))) ||
	 decode(l_rec.column7,null,null,','||ltrim(rtrim(l_rec.column7))) ||
	 decode(l_rec.column8,null,null,','||ltrim(rtrim(l_rec.column8))) ||
	 decode(l_rec.column9,null,null,','||ltrim(rtrim(l_rec.column9))) ||
	 decode(l_rec.column10,null,null,','||ltrim(rtrim(l_rec.column10))) ||
	 decode(l_rec.column11,null,null,','||ltrim(rtrim(l_rec.column11))) ||
	 decode(l_rec.column12,null,null,','||ltrim(rtrim(l_rec.column12))) ||
	 decode(l_rec.column13,null,null,','||ltrim(rtrim(l_rec.column13))) ||
	 decode(l_rec.column14,null,null,','||ltrim(rtrim(l_rec.column14))) ||
	 decode(l_rec.column15,null,null,','||ltrim(rtrim(l_rec.column15))) ||
	 decode(l_rec.column16,null,null,','||ltrim(rtrim(l_rec.column16))) ||
	 decode(l_rec.column17,null,null,','||ltrim(rtrim(l_rec.column17))) ||
	 decode(l_rec.column18,null,null,','||ltrim(rtrim(l_rec.column18))) ||
	 decode(l_rec.column19,null,null,','||ltrim(rtrim(l_rec.column19))) ||
	 decode(l_rec.column20,null,null,','||ltrim(rtrim(l_rec.column20))) ||
	 decode(l_rec.column21,null,null,','||ltrim(rtrim(l_rec.column21))) ||
	 decode(l_rec.column22,null,null,','||ltrim(rtrim(l_rec.column22))) ||
	 decode(l_rec.column23,null,null,','||ltrim(rtrim(l_rec.column23))) ||
	 decode(l_rec.column24,null,null,','||ltrim(rtrim(l_rec.column24))) ||
	 decode(l_rec.column25,null,null,','||ltrim(rtrim(l_rec.column25))) ||
	 decode(l_rec.column26,null,null,','||ltrim(rtrim(l_rec.column26))) ||
	 decode(l_rec.column27,null,null,','||ltrim(rtrim(l_rec.column27))) ||
	 decode(l_rec.column28,null,null,','||ltrim(rtrim(l_rec.column28))) ||
	 decode(l_rec.column29,null,null,','||ltrim(rtrim(l_rec.column29))) ||
	 decode(l_rec.column30,null,null,','||ltrim(rtrim(l_rec.column30))) ||
	 decode(l_rec.column31,null,null,','||ltrim(rtrim(l_rec.column31))) ||
	 decode(l_rec.column32,null,null,','||ltrim(rtrim(l_rec.column32))) ||
	 decode(l_rec.column33,null,null,','||ltrim(rtrim(l_rec.column33))) ||
	 decode(l_rec.column34,null,null,','||ltrim(rtrim(l_rec.column34))) ||
	 decode(l_rec.column35,null,null,','||ltrim(rtrim(l_rec.column35)))
	 ,1,255))
         WHERE   bank_account_num = G_bank_account_num
         AND     statement_number = G_statement_number
	 AND	line_number   	 = l_line_cnt;

         FOR C_rec1 IN C_trx_text LOOP
           G_predefined_format := C_rec1.format;
           G_include_indicator := C_rec1.include_format_ind;
           G_concatenate_format_flag := C_rec1.concatenate_format_flag;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('C_rec.rec_id_no = 88 and l_last_rid = 16 ' );
    cep_standard.debug('G_predefined_format = '||G_predefined_format||'.');
    cep_standard.debug('G_include_indicator = '||G_include_indicator||'.');
    cep_standard.debug('G_concatenate_format_flag = '||G_concatenate_format_flag||'.');
  END IF;
 	   IF (C_rec1.column_name = 'BANK_TRX_NUMBER') THEN  --Start 8273630
                 IF (G_predefined_format IS NOT NULL AND G_bank_trx_number IS NULL) THEN
                    G_bank_trx_number := Get_Formatted_String(ltrim(C_rec.column1));  --Bug 6448644
                 ELSIF(G_predefined_format IS NULL) THEN
                    BEGIN

		      select SubStr(trx_text,1,240) INTO G_bank_trx_number
                      FROM ce_statement_lines_interface
                      WHERE bank_account_num = G_bank_account_num
                      AND statement_number = G_statement_number
	                    AND	line_number = l_line_cnt;

		EXCEPTION
                      WHEN OTHERS THEN  --no_data_found
                      l_err := SQLCODE;
                      IF l_DEBUG in ('Y', 'C') THEN
                        cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Load_BAI - '|| to_char(l_err) || ' Rec no - '||nvl(G_rec_no, 0)||'No description for the line');
                      END IF;
                      RAISE;
                    END;
                  END IF;--end of 8273630

           ELSIF ( C_rec1.column_name = 'INVOICE_TEXT'AND
                   G_invoice_text IS NULL ) THEN
	       G_invoice_text := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'CUSTOMER_TEXT'AND
                   G_customer_text IS NULL ) THEN
	       G_customer_text := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'BANK_ACCOUNT_TEXT'AND
                   G_bank_account_text IS NULL ) THEN
               G_bank_account_text := Get_Formatted_String(C_rec.column1);
	   ELSIF ( C_rec1.column_name = 'CURRENCY_CODE'AND
                   G_line_currency_code IS NULL ) THEN
	       G_line_currency_code := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'USER_EXCHANGE_RATE_TYPE'AND
                   G_user_exchange_rate_type IS NULL ) THEN
	       G_user_exchange_rate_type := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'EXCHANGE_RATE_DATE'AND
                   G_exchange_rate_date IS NULL ) THEN
               G_exchange_rate_date := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'EXCHANGE_RATE'AND
                   G_exchange_rate IS NULL ) THEN
               G_exchange_rate := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'ORIGINAL_AMOUNT'AND
                   G_original_amount IS NULL ) THEN
               G_original_amount := Get_Formatted_String(C_rec.column1);
           ELSIF ( C_rec1.column_name = 'CHARGES_AMOUNT'AND
                   G_charges_amount IS NULL ) THEN
               G_charges_amount := Get_Formatted_String(C_rec.column1);
           END IF;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('C_rec1.column_name = '||C_rec1.column_name||'.');
    cep_standard.debug('G_bank_trx_number = '||G_bank_trx_number||'.');
    cep_standard.debug('G_invoice_text = '||G_invoice_text ||'.');
    cep_standard.debug('G_customer_text = '||G_customer_text ||'.');
    cep_standard.debug('G_bank_account_text = '||G_bank_account_text ||'.');
    cep_standard.debug('G_line_currency_code = '||G_line_currency_code ||'.');
    cep_standard.debug('G_user_exchange_rate_type = '||G_user_exchange_rate_type ||'.');
    cep_standard.debug('G_exchange_rate_date = '||G_exchange_rate_date ||'.');
    cep_standard.debug('G_exchange_rate = '||G_exchange_rate ||'.');
    cep_standard.debug('G_original_amount = '||G_original_amount ||'.');
    cep_standard.debug('G_charges_amount = '||G_charges_amount||'.');
  END IF;

           UPDATE  ce_statement_lines_interface
           SET	   bank_trx_number         = G_bank_trx_number,
		   invoice_text            = G_invoice_text,
		   customer_text           = G_customer_text,
                   bank_account_text       = G_bank_account_text,
		   currency_code           = G_line_currency_code,
		   user_exchange_rate_type = G_user_exchange_rate_type,
		   exchange_rate_date      = G_exchange_rate_date,
		   exchange_rate           = G_exchange_rate,
	           original_amount         = G_original_amount,
	 	   charges_amount          = G_charges_amount
           WHERE   bank_account_num   = G_bank_account_num
           AND     statement_number   = G_statement_number
  	   AND	  line_number        = l_line_cnt;
         END LOOP;
        END IF; /* 2643505 Added */
      END IF;
    ELSIF C_rec.rec_id_no = '49' THEN
      l_rec_cnt := l_rec_cnt + 1;
      l_line_cnt := 0;

      IF (nvl(to_number(C_rec.col2), l_rec_cnt) <> l_rec_cnt) THEN
        FND_MESSAGE.set_name('CE', 'CE_SQLLDR_MISSING_RECORD');
        FND_MESSAGE.set_token('GIVEN', C_rec.col2);
        FND_MESSAGE.set_token('COUNTED', to_char(l_rec_cnt));
        CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, C_rec.rec_no, fnd_message.get);
      END IF;

      G_statement_date := nvl(G_statement_date, l_statement_date);
      /* 2643505 Added the IF Condition */
      IF l_process_this_record THEN
      		Insert_Hdr;
      END IF;
      l_process_this_record := TRUE;
      /*2643505 End Code Added */
      Init_Hdr_Rec;
      l_control_total_cr := 0;
      l_control_total_dr := 0;
    ELSIF C_rec.rec_id_no NOT IN ('98', '99') THEN
      FND_MESSAGE.set_name('CE', 'CE_INVALID_BAI2');
      CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, C_rec.rec_no, fnd_message.get, 'E');
      EXIT;
    END IF;

  END LOOP;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Load_BAI');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLCODE;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Load_BAI - '|| to_char(l_err) ||
			' Rec no - '|| nvl(G_rec_no, 0));
    END IF;
    RAISE;
END Load_BAI2;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Decode_Hdr_Other 						|
|									|
|  DESCRIPTION								|
|	Load header information for NON-BAI2 format.			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Decode_Hdr_Other(X_rec_no	NUMBER,
  			   X_column_name VARCHAR2) IS
  l_err	NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Decode_Hdr_Other');
  END IF;

  IF X_column_name = 'STATEMENT_NUMBER' THEN
    G_statement_number := Lookup_Val('H', X_rec_no, X_column_name);
  ELSIF X_column_name = 'BANK_ACCOUNT_NUM' THEN
    G_bank_account_num := Lookup_Val('H', X_rec_no, X_column_name);
  ELSIF X_column_name = 'STATEMENT_DATE' THEN
    IF G_statement_date IS NULL THEN
     G_statement_date := CONV_TO_DATE(Lookup_Val('H', X_rec_no, X_column_name));
    END IF;
  ELSIF X_column_name = 'STATEMENT_TIMESTAMP' THEN
    G_statement_date   := CONV_TIMESTAMP( Lookup_Val('H', X_rec_no, 'STATEMENT_DATE') || ' ' || lookup_val('H', X_rec_no, 'STATEMENT_TIMESTAMP'));
  ELSIF X_column_name = 'BANK_NAME' THEN
    IF G_bank_name IS NULL THEN
      G_bank_name := Lookup_Val('H', X_rec_no, X_column_name);
    END IF;
  ELSIF X_column_name = 'BANK_BRANCH_NAME' THEN
    IF G_bank_branch_name IS NULL THEN
      G_bank_branch_name := Lookup_Val('H', X_rec_no, X_column_name);
    END IF;
  ELSIF X_column_name = 'CONTROL_BEGIN_BALANCE' THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Decode_Hdr_Other: ' || 'G_hdr_precision: ' || to_char(G_hdr_precision));
    END IF;
    -- EDifact ER To Handle Non Numeric Values at Balances
    IF( G_format_type='EDIFACT_FR') THEN
      G_control_begin_balance := fnd_number.canonical_to_number(covert_amt_edifact(Lookup_Val('H', X_rec_no, X_column_name)))/ G_hdr_precision;
    ELSE
      G_control_begin_balance := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Decode_Hdr_Other: ' || 'G_control_begin_balance: ' || to_char(G_control_begin_balance));
    END IF;
  ELSIF X_column_name = 'CONTROL_END_BALANCE' THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Decode_Hdr_Other: ' || 'G_hdr_precision: ' || to_char(G_hdr_precision));
    END IF;
    -- EDifact ER To Handle Non Numeric Values at Balances
    IF( G_format_type='EDIFACT_FR') THEN
      G_control_end_balance := fnd_number.canonical_to_number(covert_amt_edifact(Lookup_Val('H', X_rec_no, X_column_name)))/ G_hdr_precision;
    ELSE
      G_control_end_balance := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Decode_Hdr_Other: ' || 'G_control_end_balance: ' || to_char(G_control_end_balance));
    END IF;
  ELSIF X_column_name = 'AVAILABLE_BALANCE' THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Decode_Hdr_Other: ' || 'G_hdr_precision: ' || to_char(G_hdr_precision));
    END IF;
    G_cashflow_balance := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
  ELSIF X_column_name = 'VALUE_DATED_BALANCE' THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Decode_Hdr_Other: ' || 'G_hdr_precision: ' || to_char(G_hdr_precision));
    END IF;
    G_int_calc_balance := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
  ELSIF X_column_name = 'ONE_DAY_FLOAT' THEN
    IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('Decode_Hdr_Other: ' || 'G_hdr_precision: ' || to_char(G_hdr_precision));
    END IF;
    G_one_day_float := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
  ELSIF X_column_name = 'TWO_DAY_FLOAT' THEN
    IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('Decode_Hdr_Other: ' || 'G_hdr_precision: ' || to_char(G_hdr_precision));
    END IF;
    G_two_day_float := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
  ELSIF X_column_name = 'CONTROL_TOTAL_DR' THEN
    G_control_total_dr := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
  ELSIF X_column_name = 'CONTROL_TOTAL_CR' THEN
    G_control_total_cr := fnd_number.canonical_to_number(Lookup_Val('H', X_rec_no, X_column_name)) / G_hdr_precision;
  ELSIF X_column_name = 'CONTROL_DR_LINE_COUNT' THEN
    G_control_dr_line_count := to_number(Lookup_Val('H', X_rec_no, X_column_name));
  ELSIF X_column_name = 'CONTROL_CR_LINE_COUNT' THEN
    G_control_cr_line_count := to_number(Lookup_Val('H', X_rec_no, X_column_name));
  ELSIF X_column_name = 'CONTROL_LINE_COUNT' THEN
    G_control_line_count := to_number(Lookup_Val('H', X_rec_no, X_column_name));
  ELSIF X_column_name = 'CURRENCY_CODE' THEN
    G_hdr_currency_code := Lookup_Val('H', X_rec_no, X_column_name);
  ELSIF X_column_name = 'CHECK_DIGITS' THEN
    G_check_digits := Lookup_Val('H', X_rec_no, X_column_name);
  END IF;

  -- Added for p2p
  IF G_gl_date_source = 'STATEMENT' THEN
    G_gl_date := G_statement_date;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Decode_Hdr_Other');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLCODE;
    FND_MESSAGE.set_name('CE', 'CE_RECORD_FAIL');
    FND_MESSAGE.set_token('ERR', to_char(l_err));
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, nvl(X_rec_no, 0), fnd_message.get);
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Decode_Hdr_Other - '|| to_char(l_err));
    END IF;
END Decode_Hdr_Other;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	Decode_Line_Other 						|
|									|
|  DESCRIPTION								|
|	Load line information for NON-BAI2 format.			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAY-1999	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Decode_Line_Other(X_rec_no	NUMBER,
   			    X_column_name VARCHAR2) IS
  l_err	NUMBER;
  REQ_FIELD_MISSING	EXCEPTION;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Decode_Line_Other');
  END IF;

  IF X_column_name = 'LINE_NUMBER' THEN
    G_line_number := NVL(to_number(Lookup_Val('L', X_rec_no, X_column_name)), G_line_number);
  ELSIF X_column_name = 'TRX_DATE' THEN
    G_trx_date := NVL(CONV_TO_DATE(Lookup_Val('L', X_rec_no, X_column_name)), G_statement_date);
  ELSIF X_column_name = 'TRX_CODE' THEN
    G_trx_code := Lookup_Val('L', X_rec_no, X_column_name);
  ELSIF X_column_name = 'EFFECTIVE_DATE' THEN
    G_effective_date := CONV_TO_DATE(Lookup_Val('L', X_rec_no, X_column_name));
  ELSIF X_column_name = 'TRX_TEXT' THEN
    G_trx_text := Lookup_Val('L', X_rec_no, X_column_name);
  ELSIF X_column_name = 'INVOICE_TEXT' THEN
    --Edifact ER To Extract the Invoice text from the immediate 05 record
    IF( G_format_type='EDIFACT_FR' AND G_rec_id='05' AND G_prev_rec_id='04' ) THEN
       G_invoice_text := Lookup_Val('L', X_rec_no, X_column_name);
    ELSIF (G_format_type <> 'EDIFACT_FR' ) THEN
       G_invoice_text := Lookup_Val('L', X_rec_no, X_column_name);
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
	    cep_standard.debug('Decode_Line_Other: ' || 'G_invoice_text: ' || to_char(G_invoice_text));
    END IF;
  ELSIF X_column_name = 'AMOUNT' THEN
    --Edifact ER To handle the Non Numeric characters at Edifact Line Amounts
    IF( G_format_type='EDIFACT_FR') THEN
       G_amount := fnd_number.canonical_to_number(Abs(covert_amt_edifact(Lookup_Val('L', X_rec_no, X_column_name))))/ G_line_precision;
    ELSE
       G_amount := fnd_number.canonical_to_number(Lookup_Val('L', X_rec_no, X_column_name))/ G_line_precision;
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
	    cep_standard.debug('Decode_Line_Other: ' || 'G_amount: ' || to_char(G_amount));
    END IF;
  ELSIF X_column_name = 'CURRENCY_CODE' THEN
    G_line_currency_code := Lookup_Val('L', X_rec_no, X_column_name);
  ELSIF X_column_name = 'EXCHANGE_RATE' THEN
    G_exchange_rate := fnd_number.canonical_to_number(Lookup_Val('L', X_rec_no, X_column_name));
  ELSIF X_column_name = 'BANK_TRX_NUMBER' THEN
    G_bank_trx_number := Lookup_Val('L', X_rec_no, X_column_name);
  ELSIF X_column_name = 'CUSTOMER_TEXT' THEN
    G_customer_text := Lookup_Val('L', X_rec_no, X_column_name);
  ELSIF X_column_name = 'USER_EXCHANGE_RATE_TYPE' THEN
    G_user_exchange_rate_type := Lookup_Val('L', X_rec_no, X_column_name);
  ELSIF X_column_name = 'EXCHANGE_RATE_DATE' THEN
    G_exchange_rate_date := CONV_TO_DATE(Lookup_Val('L', X_rec_no, X_column_name));
  ELSIF X_column_name = 'ORIGINAL_AMOUNT' THEN
    G_original_amount := fnd_number.canonical_to_number(Lookup_Val('L', X_rec_no, X_column_name)) / G_line_precision;
  ELSIF X_column_name = 'CHARGES_AMOUNT' THEN
    G_charges_amount := fnd_number.canonical_to_number(Lookup_Val('L', X_rec_no, X_column_name)) / G_line_precision;
  ELSIF X_column_name = 'BANK_ACCOUNT_TEXT' THEN
    G_bank_account_text := Lookup_Val('L', X_rec_no, X_column_name);
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Decode_Line_Other');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLCODE;
    FND_MESSAGE.set_name('CE', 'CE_RECORD_FAIL');
    FND_MESSAGE.set_token('ERR', to_char(l_err));
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, nvl(X_rec_no, 0), fnd_message.get);
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Decode_Line_Other - '||to_char(l_err));
    END IF;
END Decode_Line_Other;

FUNCTION Get_Main_Rec_ID (X_hdr_or_line VARCHAR2) RETURN VARCHAR2 IS
  CURSOR C_line_rec_id IS
    SELECT distinct(rec_id_no) recID
    FROM   ce_bank_stmt_map_line
    WHERE  map_id = G_map_id;

  CURSOR C_hdr_rec_id IS
    SELECT distinct(rec_id_no) recID
    FROM   ce_bank_stmt_map_hdr
    WHERE  map_id = G_map_id;

  l_lowest_rec_no 	NUMBER := 10000000;
  l_min_rec_no  	NUMBER;
  l_rec_id		VARCHAR2(30);
  l_err			NUMBER;
BEGIN
  IF X_hdr_or_Line = 'L' THEN
    FOR C_rec IN C_line_rec_id LOOP
      SELECT MIN(rec_no)
      INTO   l_min_rec_no
      FROM   ce_stmt_int_tmp
      WHERE  rec_id_no = C_rec.recID;

      IF l_lowest_rec_no > l_min_rec_no THEN
        l_lowest_rec_no := l_min_rec_no;
        l_rec_id := C_rec.recID;
      END IF;
    END LOOP;
  ELSE
    FOR C_rec IN C_hdr_rec_id LOOP
      SELECT MIN(rec_no)
      INTO   l_min_rec_no
      FROM   ce_stmt_int_tmp
      WHERE  rec_id_no = C_rec.recID;

      IF l_lowest_rec_no > l_min_rec_no THEN
        l_lowest_rec_no := l_min_rec_no;
        l_rec_id := C_rec.recID;
      END IF;
    END LOOP;
  END IF;

  RETURN (l_rec_id);
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLCODE;
    IF X_hdr_or_Line = 'L' THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('Get_Main_Rec_ID: ' || 'EXCEPTION: Fail finding the record id of major line which contains
				     the main line information - '|| to_char(l_err) ||
			' Rec no - '|| nvl(G_rec_no, 0));
      END IF;
    ELSE
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('Get_Main_Rec_ID: ' || 'EXCEPTION: Fail finding the record id of major line which contains
				     the main header information - ' || to_char(l_err) ||
			' Rec no - '|| nvl(G_rec_no, 0));
      END IF;
    END IF;
    RAISE;
END Get_Main_Rec_ID;

PROCEDURE Load_Others IS
  CURSOR C_tmp_tbl IS
    SELECT rec_no, rec_id_no
    FROM   CE_STMT_INT_TMP
    ORDER BY rec_no;

  CURSOR C_hdr_tbl(p_rec_id VARCHAR2) IS
    SELECT column_name, position
    FROM   CE_BANK_STMT_MAP_HDR
    WHERE  map_id = G_map_id
    AND    rec_id_no = p_rec_id;

  CURSOR C_line_tbl(p_rec_id VARCHAR2) IS
    SELECT column_name, position
    FROM   CE_BANK_STMT_MAP_LINE
    WHERE  map_id = G_map_id
    AND    rec_id_no = p_rec_id;

  l_hdr_flag		NUMBER	:= 0;
  l_line_flag		NUMBER	:= 0;
  l_line_num		NUMBER;

  l_line_rec_id		VARCHAR2(30);
  l_hdr_rec_id		VARCHAR2(30);

  l_hdr_or_line		VARCHAR2(1);
  l_old_rec_type	VARCHAR2(1) := 'H';
  l_err			NUMBER;
  l_process_this_record BOOLEAN := TRUE; /* 2831725 */

  INVALID_ACCOUNT	EXCEPTION;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Load_Others');
  END IF;

  l_line_rec_id := Get_Main_Rec_ID('L');
  l_hdr_rec_id  := Get_Main_Rec_ID('H');

  FOR C_rec IN C_tmp_tbl LOOP
     G_rec_no := C_rec.rec_no;

          --Edifact ER Validations are included for EDIFACT
     IF (G_format_type='EDIFACT_FR') THEN
          G_rec_id := C_rec.rec_id_no;
          -- If the file not started with record id '01' discard the file processing
          IF (G_rec_no=1 AND G_rec_id <> '01' ) THEN
              FND_MESSAGE.set_name('CE', 'CE_INVALID_EDIFACT');
              CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, C_rec.rec_no, fnd_message.get, 'E');
              IF l_DEBUG in ('Y', 'C') THEN
                cep_standard.debug('Load_Others: The File Not started with 01 Record id');
              END IF;
              EXIT;
          -- If the file has orphan '05' discard the file processing
          ELSIF ( G_rec_id = '05' AND G_prev_rec_id NOT IN ('05','04') )THEN
              FND_MESSAGE.set_name('CE', 'CE_INVALID_EDIFACT');
              CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, C_rec.rec_no, fnd_message.get, 'E');
              IF l_DEBUG in ('Y', 'C') THEN
                cep_standard.debug('Load_Others: The File has 05 Record with out Parent 04 Record at Rec no: '||To_Char(G_rec_no));
              END IF;
              EXIT;
          END IF;
     END IF;
      --Edifact ER


     l_hdr_or_line := Hdr_Or_Line(C_rec.rec_id_no);

     IF l_hdr_or_line = 'H' THEN
       IF l_old_rec_type = 'L' THEN
	/* 2831725 Added the IF Condition below */
	 IF (l_process_this_record) THEN
         	Insert_Line;
	 END IF;
         Init_Line_Rec;
       END IF;
       l_old_rec_type := 'H';

       IF ( C_rec.rec_id_no = l_hdr_rec_id AND l_hdr_flag = 1 ) THEN
	/* 2831725 Added the IF Condition below */
	 IF (l_process_this_record) THEN
         	Insert_Hdr;
	 END IF;
      	 Init_Hdr_Rec;
         l_line_flag := 0;
       END IF;

       --
       -- Get precision first
       --
       G_hdr_precision := Get_Precision(to_number(Lookup_Val('H', G_rec_no, 'PRECISION')));
       IF ( G_hdr_precision = 1 AND G_precision <> 1 )THEN
         G_hdr_precision := G_precision;
       ELSIF ( G_hdr_precision <> 1 AND G_precision = 1 )THEN
        G_precision := G_hdr_precision;
       END IF;
       IF l_DEBUG in ('Y', 'C') THEN
         cep_standard.debug('G_precision: ' || to_char(G_precision));
         cep_standard.debug('G_hdr_precision: ' || to_char(G_hdr_precision));
       END IF;

       FOR C_hdr IN C_hdr_tbl(C_rec.rec_id_no) LOOP
         Decode_Hdr_Other(C_rec.rec_no, C_hdr.column_name);
	 /* 2831725 Code Added begins */
         IF ( C_hdr.column_name = 'BANK_ACCOUNT_NUM' ) THEN
         	IF (NOT Valid_Bank_Account ) THEN
			l_process_this_record := FALSE;
		ELSE
			l_process_this_record := TRUE;
		END IF;
		/*RAISE INVALID_ACCOUNT;*/
         END IF;
	/* 2831725 Added Code Ends */
         IF C_rec.rec_id_no = l_hdr_rec_id THEN
           l_hdr_flag := 1;
         END IF;
       END LOOP;
       l_line_num := 1;
     ELSIF l_hdr_or_line = 'L' THEN
       l_old_rec_type := 'L';
       IF ( C_rec.rec_id_no = l_line_rec_id AND l_line_flag = 1 ) THEN
	/* 2831725 Added the IF Condition below */
		IF (l_process_this_record) THEN
           		Insert_Line;
		END IF;
      	   Init_Line_Rec;
       END IF;

       --
       -- Get precision first
       --
       G_line_precision := Get_Precision(to_number(Lookup_Val('L', G_rec_no, 'PRECISION')));
       IF ( G_line_precision = 1 AND G_precision <> 1 )THEN
         G_line_precision := G_precision;
       END IF;

       FOR C_line IN C_line_tbl(C_rec.rec_id_no) LOOP
         Decode_Line_Other(C_rec.rec_no, C_line.column_name);
       END LOOP;

       IF C_rec.rec_id_no = l_line_rec_id THEN
         IF G_line_number IS NULL THEN
            G_line_number := l_line_num;
	 END IF;
         l_line_flag := 1;
         l_line_num := l_line_num + 1;
       END IF;
     ELSIF l_hdr_or_line = 'B' THEN
        IF l_DEBUG in ('Y', 'C') THEN
  	  cep_standard.debug('This rec_id '|| C_rec.rec_id_no ||' is assigned for both header and line');
        END IF;
        FND_MESSAGE.set_name('CE', 'CE_RECID_IN_HDR_LINE');
        FND_MESSAGE.set_token('RECID', C_rec.rec_id_no);
 	CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, G_rec_no, fnd_message.get, 'E');
        EXIT;
     END IF;
      IF (G_format_type='EDIFACT_FR') THEN  --8835022 start
          G_prev_rec_id := C_rec.rec_id_no; --Edifact ER Previous Record Id
          IF l_DEBUG in ('Y', 'C') THEN
  	        cep_standard.debug('G_prev_rec_id: '|| G_prev_rec_id);
          END IF;
      END IF; --8835022 End
   END LOOP;

   --
   -- Insert any remain line or header record
   --
   IF G_amount IS NOT NULL THEN
	/* 2831725 Added the IF Condition below */
	IF (l_process_this_record) THEN
     		Insert_Line;
	END IF;
   END IF;

   IF G_statement_date IS NOT NULL THEN
	/* 2831725 Added the IF Condition below */
	IF (l_process_this_record) THEN
     		Insert_Hdr;
	END IF;
   END IF;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Load_Others');
  END IF;
EXCEPTION
  WHEN INVALID_ACCOUNT THEN
    null;
  WHEN OTHERS THEN
    l_err := SQLCODE;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_BANK_STATEMENT_LOADER.Load_Others - '||to_char(l_err)||
			'Rec no - '|| nvl(G_rec_no, 0));
    END IF;
    RAISE;
END Load_Others;

PROCEDURE Decode_Line_SWIFT IS
  CURSOR C_tmp_tbl IS
  SELECT rec_no,
	 column35
  FROM   CE_STMT_INT_TMP
  WHERE  rec_id_no = '61'
  ORDER BY rec_no;

  l_col2	VARCHAR2(255);
  l_col3	VARCHAR2(255);
  l_col4	VARCHAR2(255);
  l_col5	VARCHAR2(255);
  l_col6	VARCHAR2(255);
  l_col7	VARCHAR2(255);
  l_col8	VARCHAR2(255);

  l_tmp		VARCHAR2(255);
  l_str		VARCHAR2(255);
  l_cd		VARCHAR2(1);

  l_pos		NUMBER;
  l_pos1	NUMBER;
  l_pos2	NUMBER;
  l_pos3	NUMBER;
BEGIN
  FOR C_rec IN C_tmp_tbl LOOP
    l_str  := C_rec.column35;

    -- Get Entry Date
    l_tmp := SUBSTR(l_str, 1, 4);
    IF Is_Number(l_tmp) THEN
      l_col2 := l_tmp;
      l_str := SUBSTR(l_str, 5);
    ELSE
      l_col2 := NULL;
    END IF;

    -- Get Debit/Credit Mark
    l_tmp := SUBSTR(l_str, 1, 1);
    IF l_tmp = 'R' THEN
      l_col3 := SUBSTR(l_str, 1, 2);
      l_str := SUBSTR(l_str, 3);
      IF SUBSTR(l_col3, 2, 1) = 'C' THEN
        l_cd := 'D';
      ELSE
        l_cd := 'C';
      END IF;
    ELSE
      l_col3 := l_tmp;
      l_str := SUBSTR(l_str, 2);
      l_cd := l_tmp;
    END IF;

    -- Get Fund Code
    l_tmp := SUBSTR(l_str, 1, 1);
    IF NOT Is_Number(l_tmp) THEN
      l_col4 := l_tmp;
      l_str := SUBSTR(l_str, 2);
    ELSE
      l_col4 := NULL;
    END IF;

    -- Get Amount
    /*Bug 4127039*/

    l_pos1 := INSTR(l_str,'N');
    l_pos2 := INSTR(l_str,'S');
    l_pos3 := INSTR(l_str,'F');

    IF l_pos1 = 0 THEN l_pos1 := 9999999; END IF;
    IF l_pos2 = 0 THEN l_pos2 := 9999999; END IF;
    IF l_pos3 = 0 THEN l_pos3 := 9999999; END IF;

    l_pos := LEAST(l_pos1,l_pos2,l_pos3);

    l_col5 := replace(SUBSTR(l_str, 1, l_pos - 1), ',', '.');

--    IF l_col3 IN ('D', 'RC') THEN
--      l_col5 := '-' || l_col5;
--    END IF;
    l_str := SUBSTR(l_str, l_pos + 1);

    -- Get Trx Codes
    l_col6 := SUBSTR(l_str, 1, 3) || l_cd;
    l_str  := SUBSTR(l_str, 4);

    -- Get Reference to Account Owner and Accounting Service Institution's Reference
    l_pos := INSTR(l_str, '//');
    IF l_pos = 0 THEN
      l_col7 := l_str;
      l_col8 := NULL;
    ELSE
      l_col7 :=  SUBSTR(l_str, 1, l_pos - 1);
      l_col8 :=  SUBSTR(l_str, l_pos + 2);
    END IF;

    UPDATE	CE_STMT_INT_TMP
    SET   	column2 = l_col2,
		column3 = l_col3,
		column4 = l_col4,
		column5 = l_col5,
		column6 = l_col6,
		column7 = l_col7,
		column8 = l_col8
    WHERE	rec_no = C_rec.rec_no;
  END LOOP;
END Decode_Line_SWIFT;

PROCEDURE Decode_Description IS
  CURSOR C_tmp_tbl IS
  SELECT rec_no,
         column1
  FROM   CE_STMT_INT_TMP
  WHERE  rec_id_no = '9'
  ORDER BY rec_no;

  CURSOR C_tmp_tbl2 IS
  SELECT rec_no,
         column1
  FROM   CE_STMT_INT_TMP
  WHERE  rec_id_no = '86'
  ORDER BY rec_no;

  l_rec_no	NUMBER;
  l_rec_id	VARCHAR2(30);
BEGIN
  FOR C_rec IN C_tmp_tbl LOOP
    SELECT	MAX(rec_no)
    INTO	l_rec_no
    FROM    	CE_STMT_INT_TMP
    WHERE	rec_no < C_rec.rec_no
    AND         rec_id_no <> '9';

  /* Bug 4041064 added the following IF */
  IF l_rec_no IS NOT NULL THEN
    SELECT 	rec_id_no
    INTO	l_rec_id
    FROM	CE_STMT_INT_TMP
    WHERE       rec_no = l_rec_no;

    IF l_rec_id = '61' THEN
      UPDATE 	CE_STMT_INT_TMP
      SET	rec_id_no = '61A'
      WHERE     rec_no = C_rec.rec_no;
    ELSIF l_rec_id = '86' THEN
      UPDATE 	CE_STMT_INT_TMP
      SET	column1 = column1 || '   ' || C_rec.column1
      WHERE     rec_no = l_rec_no;

      DELETE FROM CE_STMT_INT_TMP
      WHERE  rec_no = C_rec.rec_no;
    END IF;
  END IF; --4041064
  END LOOP;

  FOR C_rec IN C_tmp_tbl2 LOOP
    SELECT 	rec_id_no
    INTO	l_rec_id
    FROM	CE_STMT_INT_TMP
    WHERE       rec_no = C_rec.rec_no - 1;

    IF l_rec_id = '61' THEN
      UPDATE 	CE_STMT_INT_TMP         -- This 86 record comes after 61.
      SET	rec_id_no = '61A'         	-- Marks it as 61A.
      WHERE     rec_no = C_rec.rec_no;
    ELSIF l_rec_id = '61A' THEN
      UPDATE 	CE_STMT_INT_TMP			-- Comes after supplementary details (61A).
      SET	column1 = column1 || '   '      -- Concatinate 86 to 61A.
			  || C_rec.column1
      WHERE     rec_no = C_rec.rec_no - 1;

      DELETE FROM CE_STMT_INT_TMP		-- Delete 86.
      WHERE  rec_no = C_rec.rec_no;
    END IF;
  END LOOP;

END Decode_Description;

PROCEDURE Load_SWIFT940 IS
BEGIN
  Decode_Line_SWIFT;
  Decode_Description;
  Load_Others;
END Load_SWIFT940;

PROCEDURE Load_Bank_Statement(errbuf		OUT NOCOPY	VARCHAR2,
			      retcode		OUT NOCOPY 	NUMBER,
			      X_MAP_ID			NUMBER,
			      X_REQUEST_ID		NUMBER,
			      X_data_file		VARCHAR2,
  			      X_process_option		VARCHAR2,
  			      X_gl_date			VARCHAR2,
  			      X_org_id			VARCHAR2,
 			      X_receivables_trx_id	NUMBER,
  			      X_payment_method_id	NUMBER,
  			      X_nsf_handling		VARCHAR2,
  			      X_display_debug		VARCHAR2,
  			      X_debug_path		VARCHAR2,
  			      X_debug_file		VARCHAR2,
  			      X_bank_branch_id		NUMBER,
  			      X_bank_account_id		NUMBER,
			      X_intra_day_flag		VARCHAR2 DEFAULT 'N',
                              X_gl_date_source          VARCHAR2 DEFAULT NULL) IS
  l_return		BOOLEAN;

  l_phase		VARCHAR2(30);
  l_status		VARCHAR2(30);
  l_dev_phase		VARCHAR2(30);
  l_dev_status		VARCHAR2(30);
  l_message		VARCHAR2(1000);

  l_cnt			NUMBER;
  l_err			NUMBER;
  l_format_type		VARCHAR2(30);
  l_precision	        NUMBER;
  l_request_id		NUMBER := X_REQUEST_ID;
  SQL_LOADER_ERROR	EXCEPTION;
  INVALID_DATA_FILE	EXCEPTION;
BEGIN

  G_data_file_name	    :=  X_data_file;
  G_process_option	    :=  X_process_option;
  G_gl_date 	    	    :=	to_date(X_gl_date,'YYYY/MM/DD HH24:MI:SS');
  G_intra_day_flag	    :=  X_intra_day_flag;
  -- modified for p2p
  G_gl_date_source          :=  X_gl_date_source;

  G_receivables_trx_id      :=	X_receivables_trx_id;
  G_payment_method_id 	    :=	X_payment_method_id;
  G_nsf_handling 	    :=	X_nsf_handling;
  G_display_debug 	    :=	X_display_debug;
  G_debug_path 	    	    :=	X_debug_path;
  G_debug_file 	    	    :=	X_debug_file;
  G_bank_branch_id 	    :=	X_bank_branch_id;
  G_bank_account_id 	    :=	X_bank_account_id;
  G_org_id 	   	    :=	X_org_id;

  G_map_id	:= X_MAP_ID;
  G_user_id 	:= FND_GLOBAL.user_id;

  IF (G_gl_date_source = 'USER') THEN
    G_gl_date :=  to_date(X_gl_date,'YYYY/MM/DD HH24:MI:SS');
  ELSIF (G_gl_date_source = 'SYSTEM') THEN
    G_gl_date :=  SYSDATE;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.enable_debug(G_debug_path,
			      G_debug_file || '-LBS');
  	cep_standard.debug('>>CE_BANK_STATEMENT_LOADER.Load_Bank_Statement');
  END IF;
  --
  -- Wait until SQL*Loader program is completed.
  --
  IF (l_request_id IS NOT NULL) THEN
    LOOP
      l_return := FND_CONCURRENT.wait_for_request(
			l_request_id,
			10,
			300,
			l_phase,
			l_status,
			l_dev_phase,
			l_dev_status,
			l_message);

      l_return := FND_CONCURRENT.get_request_status(
			l_request_id,
			NULL,
			NULL,
			l_phase,
			l_status,
			l_dev_phase,
			l_dev_status,
			l_message);

      IF (NVL(l_dev_phase,'ERROR') = 'COMPLETE') THEN
        EXIT;
      END IF;
    END LOOP;

    IF (NVL(l_dev_status, 'ERROR') NOT IN ('NORMAL', 'WARNING')) THEN
      RAISE SQL_LOADER_ERROR;
    END IF;
  END IF;

  --
  -- Check if the CE_STAT_INT_TMP was populated by SQL*Loader.
  --
  SELECT 	count(*)
  INTO   	l_cnt
  FROM   	CE_STMT_INT_TMP;
  IF l_cnt = 0 THEN
    RAISE INVALID_DATA_FILE;
  END IF;

  Remove_Return_Char;

  SELECT 	format_type,
		precision,
		date_format,
		timestamp_format
  INTO   	G_format_type,
		l_precision,
		G_date_format,
		G_timestamp_format
  FROM   	ce_bank_stmt_int_map_v
  WHERE  	map_id = X_MAP_ID;

  --
  -- assign devision factor depending on the precision.
  --
  G_precision := Get_Precision(nvl(l_precision, 0));

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('Load_Bank_Statement: ' || 'Format Type:'||l_format_type);
    cep_standard.debug('>>G_format_type= '||G_format_type);
  END IF;


  IF G_format_type = 'BAI2' THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>call Load_BAI2');
    END IF;
    Load_BAI2;
  ELSIF G_format_type = 'SWIFT940' THEN
    IF l_DEBUG in ('Y', 'C') THEN
     cep_standard.debug('>>call Load_SWIFT940');
    END IF;
   Load_SWIFT940;
  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
     cep_standard.debug('>>call Load_Others');
    END IF;
   Load_Others;
  END IF;
  Delete_Orphaned_Lines;

  IF ( nvl(G_total_hdr_deleted, 0) <> 0 ) THEN
    FND_MESSAGE.set_name('CE', 'CE_EXIST_HDR_DELETED');
    FND_MESSAGE.set_token('CNT', to_char(G_total_hdr_deleted));
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, 0, fnd_message.get);
  END IF;
  IF ( nvl(G_total_line_deleted, 0) <> 0 ) THEN
    FND_MESSAGE.set_name('CE', 'CE_EXIST_LINE_DELETED');
    FND_MESSAGE.set_token('CNT', to_char(G_total_line_deleted));
    CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, 0, fnd_message.get);
  END IF;

  CE_BANK_STMT_SQL_LDR.Print_Report(G_map_id, G_data_file_name);

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STATEMENT_LOADER.Load_Bank_Statement');
  END IF;
  IF G_display_debug = 'Y' THEN
    cep_standard.disable_debug(G_display_debug);
  END IF;
EXCEPTION
WHEN SQL_LOADER_ERROR THEN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('EXCEPTION: Load_Bank_Statement - Sql*Loader was not finished');
  END IF;
  FND_MESSAGE.set_name('CE', 'CE_SQLLOADER_FAIL');
  CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, 0, fnd_message.get, 'E');
  CE_BANK_STMT_SQL_LDR.Print_Report(G_map_id, G_data_file_name);
WHEN INVALID_DATA_FILE THEN
  FND_MESSAGE.set_name('CE', 'CE_INVALID_DATA_FILE');
  FND_MESSAGE.set_token('DATA_FILE',G_data_file_name);
  CE_SQLLDR_ERRORS_PKG.insert_row(G_statement_number, G_bank_account_num, 0, fnd_message.get, 'E');
  CE_BANK_STMT_SQL_LDR.Print_Report(G_map_id, G_data_file_name);
WHEN OTHERS THEN
  l_err     := SQLCODE;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('EXCEPTION: Load_Bank_Statement - '||to_char(l_err));
  END IF;
  RAISE;
END Load_Bank_Statement;

END CE_BANK_STATEMENT_LOADER;

/
