--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_UTIL" AUTHID CURRENT_USER AS
/* $Header: OKLRAUTS.pls 120.10.12010000.4 2009/06/12 11:22:07 racheruv ship $ */

  TYPE seg_num_array_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  TYPE seg_array_type IS TABLE OF FND_ID_FLEX_SEGMENTS.APPLICATION_COLUMN_NAME%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE seg_desc_array_type IS TABLE OF  FND_ID_FLEX_SEGMENTS_TL.FORM_LEFT_PROMPT%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE error_message_type IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;

  TYPE seg_num_name_type IS RECORD
    (seg_num  seg_num_array_type,
     seg_name seg_array_type,
     seg_desc seg_desc_array_type);

  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  -- sgorantl 06/03/2002
  G_RULE_DEF_NOT_FOUND        CONSTANT VARCHAR2(50)  := 'OKL_RULE_DEF_NOT_FOUND';
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  g_sysdate DATE := SYSDATE;

  -- Incorporated the change due to the failure in GCC check-in. Because ARCS does not allow code to be
  -- checked in with hard-coded date with DD-MON-YYYY format, which may create problem in non-englis databases.

  -- g_final_date CONSTANT DATE := TO_DATE('31-DEC-9999','DD-MON-RRRR');

  -- Got the julian date and added 5300000 to get the date 10/22/9798

  g_final_date CONSTANT DATE := TO_DATE('1','j') + 5300000;


  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_ACCOUNTING_UTIL';

  -- mvasudev, 9/25/01
  G_VARCHAR2  VARCHAR2(10)    := 'VARCHAR2';
  G_NUMBER    VARCHAR2(10)    := 'NUMBER';

  -- Keerthi 19-Sep-2003  Bug No 3149545
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;

  TYPE overlap_attrib_rec_type IS RECORD
  (
     attribute  VARCHAR2(30)
    ,attrib_type VARCHAR2(10)   := G_VARCHAR2
    ,value  VARCHAR2(150)
  );
  TYPE overlap_attrib_tbl_type IS TABLE OF overlap_attrib_rec_type
        INDEX BY BINARY_INTEGER;
  -- mvasudev, end

/*
retruns segment array based
*/

  PROCEDURE get_segment_array
    (p_concate_segments IN VARCHAR2,
	p_delimiter IN VARCHAR2,
	p_seg_array_type OUT NOCOPY seg_array_type);

/*
returns concatenated segment description or sql error message
*/

  FUNCTION get_concate_desc
    (p_chart_of_account_id IN NUMBER,
    p_concate_segments IN VARCHAR2)
	RETURN VARCHAR2;

/*
returns concatenated segment description or sql error message
*/
  FUNCTION get_concate_desc
    (p_code_combination_id IN NUMBER)
	RETURN VARCHAR2;

/*
Returns rule meaning or sql error message
*/

  FUNCTION get_rule_meaning (p_rule_code IN VARCHAR2)
           RETURN VARCHAR2;



/*
returns 't' if lookup code is valid else returns 'f'.
p_view_app_id in number -
pass 0 if lookup values has been registered using application object librarary's fnd lookup form
pass 3 if lookup values has been regristered using  application object librarary's fnd common lookup form
pass respective application id throught, which lookup values has been registered. in this case p_app_id
and p_view_app_id will be same

p_app_id in number default 540
pass application id in which you have registered your lookup type.
*/

  FUNCTION validate_lookup_code
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2,
	p_app_id IN NUMBER DEFAULT 540,
	p_view_app_id IN NUMBER DEFAULT 0)
	RETURN VARCHAR2;

/*
Returns all the error messages seprated by '--' and count for the same
*/
  PROCEDURE get_error_message
    (p_msg_count OUT NOCOPY NUMBER,
	p_msg_text OUT NOCOPY VARCHAR2);

/*
Returns all the error messages IN pl/sql table
*/

  PROCEDURE get_error_message(p_all_message OUT NOCOPY error_message_type);

/*
Returns all the error messages IN pl/sql table only if msg returned is not null
*/

  PROCEDURE get_error_msg(p_all_message OUT NOCOPY error_message_type);

/*
Returns 'T' if currency is valid and active else return 'F'
*/

  FUNCTION validate_currency_code(p_currency_code IN VARCHAR2)
  RETURN VARCHAR2;

/*
Returns 'T' if CODE COMBINATION ID is valid for GL else returns 'F'
Modified on 11-JUL-2008 Rkuttiya for Multi GAAP Project
added parameter p_ledger_id
*/

  FUNCTION validate_gl_ccid(p_ccid IN VARCHAR2,
                            p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2;

/*
Return status of OKL period in case of error returns null
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/
  FUNCTION get_okl_period_status(p_period_name IN VARCHAR2, p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2;

/*
Return status of GL period in case of error returns null
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/

  FUNCTION get_gl_period_status(p_period_name IN VARCHAR2, p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2;

/*
Returns 'T' if validate source id and source table else 'F'
*/
  FUNCTION validate_source_id_table
    (p_source_id IN NUMBER,
	p_source_table IN VARCHAR2)
	RETURN VARCHAR2;

/*
Returns out parameter set of books id and name or null in case of error
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/
  PROCEDURE get_set_of_books
    (p_set_of_books_id OUT NOCOPY NUMBER,
	p_set_of_books_name OUT NOCOPY VARCHAR2, p_ledger_id IN NUMBER DEFAULT NULL);

/*
Returns set of books id
11-JUL-2008 rkuttiya modified for Multi GAAP Project
Added new parameter p_representation_type
*/

  FUNCTION get_set_of_books_id(p_representation_type IN VARCHAR2 DEFAULT
'PRIMARY')
  RETURN NUMBER;

/*
Returns set of books name given set of books id
*/
  FUNCTION get_set_of_books_name(p_set_of_books_id IN NUMBER)
  RETURN VARCHAR2;

/*
Returns rounded amount given amount and currency code
*/

  FUNCTION round_amount
    (p_amount IN NUMBER,
	p_currency_code IN VARCHAR2)
	RETURN NUMBER;

/*
Returns rounded amount given amount,currency code and rounding rule

 The Procedure accepts 3 values.
       Amount
       Currency Code
       Round Option(For rounding cross currency pass the value 'CC',for Streams
                    'STM' and for Accounting Lines 'AEL')
*/


PROCEDURE round_amount
    (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_amount 		IN NUMBER,
     p_currency_code 	IN VARCHAR2,
     p_round_option     IN VARCHAR2,
     x_rounded_amount	OUT NOCOPY NUMBER);



/*
Returns currency conversion rate
*/
  FUNCTION get_curr_con_rate
    (p_from_curr_code IN VARCHAR2,
	p_to_curr_code IN VARCHAR2,
	p_con_date IN DATE,
	p_con_type IN VARCHAR2)
  RETURN NUMBER;

/* Procedure to get the exchange rate */

PROCEDURE get_curr_con_rate
     (
     p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_from_curr_code 	IN VARCHAR2,
     p_to_curr_code 	IN VARCHAR2,
     p_con_date 	IN DATE,
     p_con_type 	IN VARCHAR2,
     x_conv_rate 	OUT NOCOPY NUMBER);

/*
Returns accounting segment array based on set of books id assigned to responsibilty of the caller
10-JUL-2008 rkuttiya modified for Multi GAAP project
Added new parameter p_ledger_id
*/
  PROCEDURE get_accounting_segment
    (p_segment_array OUT NOCOPY seg_num_name_type,
     p_ledger_id IN NUMBER DEFAULT NULL);

/*
returns meaning for the lookup type and code
p_view_app_id IN NUMBER -
pass 0 IF lookup VALUES has been registered USING application object librarary's fnd lookup form
pass 3 if lookup values has been regristered using  application object librarary's fnd common lookup FORM
pass respective application id throught, which lookup VALUES has been registered. IN this CASE p_app_id
AND p_view_app_id will be same

p_app_id IN NUMBER DEFAULT 540
pass application id IN which you have registered your lookup TYPE.
*/

  FUNCTION get_lookup_meaning
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2,
	p_app_id IN NUMBER DEFAULT 540,
	p_view_app_id IN NUMBER DEFAULT 0)
	RETURN VARCHAR2;

/*
returns meaning for the lookup type and code
p_view_app_id IN NUMBER -
pass 0 IF lookup VALUES has been registered USING application object librarary's fnd lookup form
pass 3 if lookup values has been regristered using  application object librarary's fnd common lookup FORM
pass respective application id throught, which lookup VALUES has been registered. IN this CASE p_app_id
AND p_view_app_id will be same

p_app_id IN NUMBER DEFAULT 540
pass application id IN which you have registered your lookup TYPE.
p_language IN VARCHAR2 DEFAULT USERENV(LANG)
pass language in which the meaning is desired
*/

  FUNCTION get_lookup_meaning_lang
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2,
	p_app_id IN NUMBER DEFAULT 540,
	p_view_app_id IN NUMBER DEFAULT 0,
    p_language IN VARCHAR2 DEFAULT USERENV('LANG'))
	RETURN VARCHAR2;

/*
Get the lookup meaning from fa lookup tables
*/

  FUNCTION get_fa_lookup_meaning
    (p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2)
	RETURN VARCHAR2;


/*
returns 'T' if validated else 'F'
*/

  FUNCTION validate_currency_con_type
    (p_currency_con_type IN VARCHAR2)
	RETURN VARCHAR2;

/*
returns period name , start date and end date given a date.
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/

  PROCEDURE get_period_info(p_date IN DATE,
  p_period_name OUT NOCOPY VARCHAR2,
  p_start_date OUT NOCOPY DATE,
  p_end_date OUT NOCOPY DATE,
  p_ledger_id IN NUMBER DEFAULT NULL);

/*
returns start date and end date given a period.
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/

  PROCEDURE get_period_info(p_period_name IN VARCHAR2,
  p_start_date OUT NOCOPY DATE,
  p_end_date OUT NOCOPY DATE,
  p_ledger_id IN NUMBER DEFAULT NULL);

/*
returns functional currency code
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/

  FUNCTION get_func_curr_code (p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN VARCHAR2;

/*
returns 'T' if validated else 'F'
*/

  FUNCTION validate_journal_category(p_category IN VARCHAR2)
  RETURN VARCHAR2;

/*
returns chart of account id if sucess else return -1;
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/

  FUNCTION get_chart_of_accounts_id (p_ledger_id IN NUMBER DEFAULT NULL)
  RETURN NUMBER;

-- mvasudev, 9/25/01
/*
check overlaps - for any attribute
*/

  PROCEDURE check_overlaps (
	p_id						IN NUMBER,
      p_attrib_tbl				IN overlap_attrib_tbl_type,
  	p_start_date_attribute_name	IN VARCHAR2 DEFAULT 'START_DATE',
  	p_start_date				IN DATE,
	p_end_date_attribute_name	IN VARCHAR2 DEFAULT 'END_DATE',
	p_end_date					IN DATE,
	p_view						IN VARCHAR2,
	x_return_status				OUT NOCOPY VARCHAR2,
	x_valid						OUT NOCOPY BOOLEAN);
  -- mvasudev, end

  -- mvasudev, 10/02/01
/*
Get Version - with any attribute
*/
  PROCEDURE get_version(
    p_attrib_tbl				IN overlap_attrib_tbl_type,
  	p_cur_version				   IN VARCHAR2,
	p_end_date_attribute_name	IN VARCHAR2 DEFAULT 'END_DATE',
	p_end_date					IN DATE,
	p_view						IN VARCHAR2,
  	x_return_status				   OUT NOCOPY VARCHAR2,
	x_new_version				   OUT NOCOPY VARCHAR2);
  -- mvasudev, end

/*
convert the string into upper
*/

FUNCTION okl_upper(p_string IN VARCHAR2)
RETURN VARCHAR2;

/*
get concatenated segments based on ccid
*/

FUNCTION get_concat_segments(p_ccid IN NUMBER)
RETURN VARCHAR2;


/*
format the amount according to profile options and currency code.
*/

FUNCTION format_amount(p_amount IN NUMBER
                      ,p_currency_code IN VARCHAR2)
RETURN VARCHAR2;

/*
validate the amount according to currency code.
*/

FUNCTION validate_amount(p_amount IN NUMBER
                        ,p_currency_code IN VARCHAR2)
RETURN NUMBER;


/*  10-JUL-2008 rkuttiya modified for Multi GAAP
 *  added a new parameter p_ledger_id
 */

FUNCTION get_segment_desc(p_segment IN VARCHAR2
                         ,p_ledger_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

/*
This Function gets the label for a particular AK attribute belongs
a particular region. This is called at the time of displaying a token
along with the message. It returns NULL if the region or the attribute
is not found.
*/

FUNCTION Get_Message_Token
(
 p_region_code    IN ak_region_items.region_code%TYPE,
 p_attribute_code IN ak_region_items.attribute_code%TYPE,
 p_application_id IN fnd_application.application_id%TYPE DEFAULT 540
)
RETURN VARCHAR2;



/*
This function returns the rounded amount for a given amount and currency code
using the cross currency rounding rule
*/


FUNCTION cross_currency_round_amount
    (p_amount IN NUMBER,
     p_currency_code IN VARCHAR2)
RETURN NUMBER;


/*
This procedure returns the rounded amount for a given amount and currency code
using the cross currency rounding rule
*/

PROCEDURE cross_currency_round_amount
    (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_amount 		IN NUMBER,
     p_currency_code 	IN VARCHAR2,
     x_rounded_amount	OUT NOCOPY NUMBER);


/*
This function returns the rounded and formatted amount for a given amount and currency
code using the cross currency rounding rule
*/


FUNCTION cc_round_format_amount
    (p_amount IN NUMBER,
     p_currency_code IN VARCHAR2)
RETURN VARCHAR2;


/*
This procedure returns the rounded and formatted amount for a given amount and currency
code using the cross currency rounding rule
*/

PROCEDURE cc_round_format_amount
    (p_api_version      IN NUMBER,
     p_init_msg_list 	IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count 	OUT NOCOPY NUMBER,
     x_msg_data 	OUT NOCOPY VARCHAR2,
     p_amount 		IN NUMBER,
     p_currency_code 	IN VARCHAR2,
     x_formatted_amount OUT NOCOPY VARCHAR2);

/*
This procedure converts the amount from contract currency to functional
currency. And then returns the rounded amount. This also returns the
currency conversion factors along.
*/

PROCEDURE convert_to_functional_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_to_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
);


/*
This overloaded procedure converts the amount from contract currency to functional
currency. And then returns the rounded amount. This also returns the
currency conversion factors along. This returns the retur_status also.
*/

PROCEDURE convert_to_functional_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_to_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
);


/*
This procedure converts the amount from functional currency to contract
currency. And then returns the rounded amount. This also returns the
currency conversion factors along.
*/

PROCEDURE convert_to_contract_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_from_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
);


/*
This overloaded procedure converts the amount from functional currency to contract
currency. And then returns the rounded amount. This also returns the
currency conversion factors along. . This returns the retur_status also.
*/

PROCEDURE convert_to_contract_currency
(
 p_khr_id  		  	IN OKC_K_HEADERS_B.id%TYPE,
 p_from_currency   		IN fnd_currencies.currency_code%TYPE,
 p_transaction_date 		IN DATE,
 p_amount 			IN NUMBER,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_contract_currency		OUT NOCOPY OKC_K_HEADERS_B.currency_code%TYPE,
 x_currency_conversion_type	OUT NOCOPY OKL_K_HEADERS.currency_conversion_type%TYPE,
 x_currency_conversion_rate	OUT NOCOPY OKL_K_HEADERS.currency_conversion_rate%TYPE,
 x_currency_conversion_date	OUT NOCOPY OKL_K_HEADERS.currency_conversion_date%TYPE,
 x_converted_amount 		OUT NOCOPY NUMBER
);


/*
This function returns valid GL date
If p_ledger_id passed to the API is null then it considers ledger from primary representation.
Otherwise, it considers the ledger id that is passed to it.
Added p_ledger_id argument as part of bug 5707866 by nikshah
*/
FUNCTION get_valid_gl_date(p_gl_date IN DATE, p_ledger_id IN NUMBER DEFAULT NULL)
RETURN DATE;

-- Added by Santonyr 02-Aug-2004 for bug 3808697.
-- This function is to derive the transaction amount for each transaction from FA.

FUNCTION get_fa_trx_amount
  (p_book_type_code  IN VARCHAR2,
   p_asset_id        IN NUMBER,
   p_transaction_type IN VARCHAR2,
   p_transaction_header_id IN  NUMBER   )
RETURN NUMBER;

-- Added by Santonyr 10-Oct-2004.
-- This function is returns if a OKL transaction is actual or draft..

FUNCTION Get_Draft_Actual_Trx
  (p_trx_id IN NUMBER,
  p_source_table IN VARCHAR2,
  p_khr_id IN NUMBER )
RETURN VARCHAR2;

-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This function is to return the FA transaction date.


FUNCTION get_fa_trx_date
  (p_book_type_code  IN VARCHAR2)
RETURN DATE;

-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This procedure is to return the FA transaction date.

PROCEDURE get_fa_trx_date
  (p_book_type_code  IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_fa_trx_date OUT NOCOPY DATE);

-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This procedure is to return the first FA transaction date for a contract.

FUNCTION Get_FA_Trx_Start_Date
  (p_asset_number IN VARCHAR2,
  p_corporate_book IN VARCHAR2,
  p_khr_id IN NUMBER,
  p_sts_code IN VARCHAR2)
RETURN DATE;

-- Added by Santonyr 10-Dec-2004 for bug 4028662.
-- This procedure is to return the last FA transaction date for a contract.

FUNCTION Get_FA_Trx_End_Date
  (p_asset_number IN VARCHAR2,
  p_corporate_book IN VARCHAR2,
  p_khr_id IN NUMBER)
RETURN DATE;

/*
Return valuation method code in case of error returns null
Added by nikshah 22-Jan-2007 for bug 5707866
*/
FUNCTION get_valuation_method_code( p_ledger_id  NUMBER DEFAULT NULL)
RETURN VARCHAR2;

/*
Return account derivation option, if not found in system options then return null
Added by nikshah 08-Feb-2007 for bug 5707866
*/
FUNCTION get_account_derivation
RETURN VARCHAR2;

-- MGAAP 7263041
FUNCTION get_fa_reporting_book( p_org_id  NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_fa_reporting_book( p_kle_id  NUMBER ) RETURN VARCHAR2;

-- SECHAWLA 09-mar-2009 : added as part of MG Impacts on Investor Agreement
PROCEDURE get_reporting_product(p_api_version           IN  	NUMBER,
           		 	            p_init_msg_list         IN  	VARCHAR2,
           			            x_return_status         OUT 	NOCOPY VARCHAR2,
           			            x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
                                p_contract_id 		    IN 		NUMBER,
                                x_rep_product           OUT   	NOCOPY VARCHAR2,
							    x_rep_product_id        OUT   	NOCOPY NUMBER,
								x_rep_deal_type         OUT     NOCOPY VARCHAR2);


END OKL_ACCOUNTING_UTIL;




/
