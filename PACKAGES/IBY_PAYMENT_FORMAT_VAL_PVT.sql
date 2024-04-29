--------------------------------------------------------
--  DDL for Package IBY_PAYMENT_FORMAT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYMENT_FORMAT_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyfvvls.pls 120.9.12000000.1 2007/01/18 06:06:12 appldev ship $ */
/*

PROCEDURE	: SCHEDULE_NUMBER

This procedure is responsible for validating Schedule Number

*/
 	PROCEDURE SCHEDULE_NUMBER
	(
		p_format_name IN VARCHAR2,
		p_pinstr_id IN NUMBER,
		p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	        p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	        x_error_code  OUT NOCOPY NUMBER,
	        x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE 	: SUPPLIER_TYPE

This procedure is responsible for Validating Supplier Type .

If Format Name Is In ('FVTPCCD','FVTIACHP','FVSPCCD', 'FVSPCCDP', 'FVTICTX' ,'FVBLCCDP')  ONLY NON-EMPLOYEES ARE ALLOWED.

If Format Name Is In ('FVTPPPD','FVTPPPDP','FVSPPPDP','FVSPPPD', 'FVBLPPDP','FVBLSLTR') ONLY EMPLYEES ARE ALLOWED
If Format Name Is In ('FVTIACHB','FVBLNCR','FVSPNCR') EITHER ALL EMPLOYEES OR ALL NON EMPLOYEES ARE ALLOWED.
\
*/
    PROCEDURE SUPPLIER_TYPE
	(
	 	p_format_name 		IN VARCHAR2,
	   	p_instruction_id 	IN NUMBER,
	   	p_docErrorTab 		IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   	p_docErrorRec 		IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
       		x_error_code  		OUT NOCOPY NUMBER,
       		x_error_mesg  		OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE 	: TREASURY_SYMBOLS_PROCESS

This procedure is responsible to insert the treasury symbol into the table FV_TP_TS_AMT_DATA along with the amount.
This table will later be used for the maximum treasury symbol validations.

*/
	PROCEDURE TREASURY_SYMBOLS_PROCESS
	(
	       p_format_name IN VARCHAR2,
               p_instruction_id   IN   NUMBER,
               p_payment_id  IN NUMBER,
	       p_invoice_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
 	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	:  MAX_TREASURY_SYMBOLS

This procedure is responsible to validate for maximum number of treasury symbols in a payment batch.

*/
	PROCEDURE MAX_TREASURY_SYMBOLS
	(
	       p_format_name IN VARCHAR2,
	       p_instruction_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: AGENCY_ADDRESS

This procedure is respnosible for Validation of Agency Address.

Agency Address should not be NULL.

*/
	PROCEDURE AGENCY_ADDRESS
	(
	       p_format_name IN VARCHAR2,
	       p_org_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAYEE_ADDRESS

This procedure is responsible for Validation of Payee Address

Payee Address should not be NULL.

*/
	PROCEDURE PAYEE_ADDRESS
	(
       	       p_format_name IN VARCHAR2,
	       p_payment_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: MAX_PAYMENT_AMT

This procedure is responsible for Validation of Payment Amount Exceeding the limit of 9,999,999.99

*/
	PROCEDURE MAX_PAYMENT_AMT
	(
       	       p_format_name IN VARCHAR2,
	       p_instruction_id IN NUMBER,
	       p_payment_amount IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: MAX_PAYMENT_AMT_2

This procedure is responsible for Validation of Payment Amount Exceeding the limit of 999,999.99

*/
	PROCEDURE MAX_PAYMENT_AMT_2
	(
       	       p_format_name IN VARCHAR2,
	       p_instruction_id IN NUMBER,
	       p_payment_amount IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAY_TAX_BENEFIT

This procedure is responsible such that Payments should pertain to Tax / Benefit only.

*/
	PROCEDURE PAY_TAX_BENEFIT
	(
           p_format_name IN VARCHAR2,
           p_payment_id  IN NUMBER,
           p_invoice_id  IN NUMBER,
	   p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  OUT NOCOPY NUMBER,
	   x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAY_SALARY_TRAVEL

This procedure is responsible such that Payments should pertain to Salary / Travel only.

*/
	PROCEDURE PAY_SALARY_TRAVEL
	(
	       p_format_name IN VARCHAR2,
	       p_reason_code IN VARCHAR2,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAYEE_SSN

This procedure is responsible for Validation of Payee Social Security Number.

Payee Social Security Number should not be NULL.

*/
	PROCEDURE PAYEE_SSN
	(
       	       p_format_name IN VARCHAR2,
               p_ssn_tin IN VARCHAR2,
               p_payee_party_id   IN  VARCHAR2,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: TAS_VALIDATION

This procedure is responsible for validation of Treasury account symbol (TAS) in Payment record .

TAS should me of minimum 7 characters and  can only be "0-9", "A-Z", ".", "(", ")", or "/"'.

*/
	PROCEDURE TAS_VALIDATION
	(
	       p_format_name IN VARCHAR2,
	       p_treasury_symbol IN VARCHAR2,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: AGENCY_LOCATION_CODE

This procedure is responisble for Validation of Agency Location Code.

Agency Location Code should not be NULL.

*/
	PROCEDURE AGENCY_LOCATION_CODE
	(
	       p_format_name 		IN VARCHAR2,
               p_agency_location_code 	IN ce_bank_accounts.agency_location_code%TYPE,
               p_bank_account_name	IN ce_bank_accounts.bank_account_name%TYPE,
	       p_docErrorTab 		IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec 		IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  		OUT NOCOPY NUMBER,
	       x_error_mesg  		OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: RTN_NUMBER

This procedure is responsible for validation of RTN Number.

It must a nine-digit numeric-only field.  Prohibit fewer or more than nine characters, allow for only numeric characters,
and prohibit the entry of all zeroes in this field. The ninth digit is the Check Digit which is validated using the Modulus formula.

*/
	PROCEDURE RTN_NUMBER
	(
       	       p_format_name IN VARCHAR2,
	       p_rtn_number IN VARCHAR2,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: PAY_ALONE_OPTION

This procedure is responsible for validation of Pay ALone.

"Pay Alone" for each invoice should not be 'NO' or NULL.


*/
	PROCEDURE PAY_ALONE_OPTION
	(
	       p_format_name IN VARCHAR2,
	       p_invoice_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: DEPOSITER_ACC_NUM

This procedure is responsible for Validation of Depositor Account number.

Account number should not be NULL.

*/
	PROCEDURE DEPOSITER_ACC_NUM
	(
	       p_format_name IN VARCHAR2,
	       p_dep_account_no IN iby_ext_bank_accounts.bank_account_num%TYPE,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: ACCOUNT_TYPE

This procedure is responsible for Validation of Account type.

Valid values for bank account type are "C" - Checking account; "S" - Savings account.

*/
	PROCEDURE ACCOUNT_TYPE
	(
       	       p_format_name IN VARCHAR2,
	       p_bank_account_type IN iby_ext_bank_accounts.bank_account_type%TYPE,
               p_bank_account_name IN iby_ext_bank_accounts.bank_account_name%TYPE,
               p_invoice_id        IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: RFC_ID

This procedure is responsible for validation of RFC_ID

RFC_ID should not be NULL.

*/
	PROCEDURE RFC_ID
	(
       	       p_format_name 		IN VARCHAR2,
	       p_payment_id 		IN NUMBER,
	       p_docErrorTab 		IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec 		IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  		OUT NOCOPY NUMBER,
	       x_error_mesg  		OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: MANDATORY_PPD_PPDP_REASON_CODE

This procedure is responsible for validation of following formats

Bulk Data PPDP Payment Format Report

ECS PPD Vendor Payment Format Program

ECS PPDP Vendor Payment Format Program

SPS PPD Vendor Payment Format Program

SPS PPDP Vendor Payment Format Program

to have a payment with a specified Federal payment reason.

*/
	PROCEDURE MANDATORY_PPD_PPDP_REASON_CODE
	(
       	       p_format_name IN VARCHAR2,
	       p_reason_code IN VARCHAR2,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-------------------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE LOG_ERROR_MESSAGES
        (
            p_level   IN NUMBER,
            p_module  IN VARCHAR2,
            p_message IN VARCHAR2
        );
---------------------------------------------------------------------------------------------------------------------------------
PROCEDURE EXTERNAL_BANK_ACCOUNT_ID
	(
           p_format_name 		IN VARCHAR2,
  	   p_external_bank_account_id 	IN NUMBER,
	   p_docErrorTab 		IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec 		IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  		OUT NOCOPY NUMBER,
	   x_error_mesg  		OUT NOCOPY VARCHAR2
	);
-----------------------------------------------------------------------------------------------------------------------------
 PROCEDURE FEDERAL_ID_NUMBER
	(
       	       p_format_name IN VARCHAR2,
               p_pay_instruction_id IN NUMBER,
	       p_docErrorTab IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	       p_docErrorRec IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	       x_error_code  OUT NOCOPY NUMBER,
	       x_error_mesg  OUT NOCOPY VARCHAR2
	);

-----------------------------------------------------------------------------------------------------------------------------
PROCEDURE AGENCY_ID_ABBREVIATION
	(
           p_format_name 	IN VARCHAR2,
	   p_instruction_id 	IN NUMBER,
	   p_docErrorTab 	IN  OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
	   p_docErrorRec 	IN  OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
	   x_error_code  	OUT NOCOPY NUMBER,
	   x_error_mesg  	OUT NOCOPY VARCHAR2
	);



END IBY_PAYMENT_FORMAT_VAL_PVT;


 

/
