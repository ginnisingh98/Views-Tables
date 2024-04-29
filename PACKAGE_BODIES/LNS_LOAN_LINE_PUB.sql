--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_LINE_PUB" AS
/* $Header: LNS_LINE_PUBP_B.pls 120.7.12010000.3 2010/03/17 13:19:50 scherkas ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'LNS_LOAN_LINE_PUB';

 --These package variables used for ERS rules bulk processing api.
 --The values are set in the function GET_RULES_DERIVED_ERS_AMOUNT
 --The three public functions get_loan_party_id, get_loan_currency_code and get_loan_org_id
 --retrieve these for external api usage
 LNS_LOAN_PARTY_ID NUMBER(15);
 LNS_LOAN_CURRENCY_CODE VARCHAR2(15);
 LNS_LOAN_ORG_ID NUMBER(15);

procedure logMessage(log_level in number
				,module    in varchar2
				,message   in varchar2)
is

begin

IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
  FND_LOG.STRING(log_level, module, message);
END IF;

end;

/*========================================================================
 | PUBLIC PROCEDURE UPDATE_LINE_ADJUSTMENT_NUMBER
 |
 | DESCRIPTION
 |      This procedure updates the rec number column in loan lines table based on AR Adjustment api out parameter during loan approval
 |
 | NOTES
 |      There are no table-handler apis for loan lines table since it uses java-based EO
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Jan-2006           karamach          Added payment_schedule_id and installment_number for lns_loan_lines per bug#4887994
 | 20-Dec-2004           karamach          Created
 |
 *=======================================================================*/
PROCEDURE UPDATE_LINE_ADJUSTMENT_NUMBER(
                p_init_msg_list  IN VARCHAR2
				,p_loan_id        IN  NUMBER
				,p_loan_line_id   IN  NUMBER
				,p_rec_adjustment_number IN  VARCHAR2
                ,p_rec_adjustment_id IN  NUMBER
                ,p_payment_schedule_id IN  NUMBER
                ,p_installment_number IN  NUMBER
                ,p_adjustment_date IN  DATE
                ,p_original_flag IN VARCHAR2
				,x_return_status  OUT NOCOPY VARCHAR2
				,x_msg_count      OUT NOCOPY NUMBER
				,x_msg_data       OUT NOCOPY VARCHAR2) IS

l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(32767);


BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin UPDATE_LINE_ADJUSTMENT_NUMBER for loan_line_id: '|| p_loan_line_id);
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
                    FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --Call to record history
    LNS_LOAN_HISTORY_PUB.log_record_pre(
                                    p_id => p_loan_line_id,
                                    p_primary_key_name => 'LOAN_LINE_ID',
                                    p_table_name => 'LNS_LOAN_LINES'
    );

    -- update loan line
    UPDATE LNS_LOAN_LINES
    SET REC_ADJUSTMENT_NUMBER = p_rec_adjustment_number,
        REC_ADJUSTMENT_ID = p_rec_adjustment_id,
        PAYMENT_SCHEDULE_ID = p_payment_schedule_id,
        INSTALLMENT_NUMBER = p_installment_number,
        LAST_UPDATED_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = LNS_UTILITY_PUB.LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE = LNS_UTILITY_PUB.LAST_UPDATE_DATE,
        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
        ADJUSTMENT_DATE = p_adjustment_date,
        STATUS = 'APPROVED',
        ORIGINAL_FLAG = p_original_flag,
        APPR_REJECT_DATE = LNS_UTILITY_PUB.LAST_UPDATE_DATE,
        APPR_REJECT_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY
    WHERE LOAN_LINE_ID = p_loan_line_id
    AND LOAN_ID = p_loan_id;

    --Call to record history
    LNS_LOAN_HISTORY_PUB.log_record_post(
                                    p_id => p_loan_line_id,
                                    p_primary_key_name => 'LOAN_LINE_ID',
                                    p_table_name => 'LNS_LOAN_LINES',
                                    p_loan_id => p_loan_id
    );


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End UPDATE_LINE_ADJUSTMENT_NUMBER for loan_line_id: '|| p_loan_line_id);
    END IF;

EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
    END IF;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);
    END IF;

		WHEN OTHERS THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
    END IF;

END UPDATE_LINE_ADJUSTMENT_NUMBER;


/*========================================================================
 | PUBLIC FUNCTION GET_LOAN_PARTY_ID
 |
 | DESCRIPTION
 |      This function will be used by rules engine as a filter to the bulk processing rules api when executing query.
 |		The function returns the value for the package variable LNS_LOAN_PARTY_ID
 |
 | NOTES
 |      This function is used in the bulk rule processing api for better performance
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Jan-2006           karamach          Created
 *=======================================================================*/
FUNCTION GET_LOAN_PARTY_ID RETURN NUMBER
IS
BEGIN
	return LNS_LOAN_PARTY_ID;
END GET_LOAN_PARTY_ID;

/*========================================================================
 | PUBLIC FUNCTION GET_LOAN_CURRENCY_CODE
 |
 | DESCRIPTION
 |      This function will be used by rules engine as a filter to the bulk processing rules api when executing query.
 |		The function returns the value for the package variable LNS_LOAN_CURRENCY_CODE
 |
 | NOTES
 |      This function is used in the bulk rule processing api for better performance
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Jan-2006           karamach          Created
 *=======================================================================*/
FUNCTION GET_LOAN_CURRENCY_CODE RETURN VARCHAR2
IS
BEGIN
	return LNS_LOAN_CURRENCY_CODE;
END GET_LOAN_CURRENCY_CODE;

/*========================================================================
 | PUBLIC FUNCTION GET_LOAN_ORG_ID
 |
 | DESCRIPTION
 |      This function will be used by rules engine as a filter to the bulk processing rules api when executing query.
 |		The function returns the value for the package variable LNS_LOAN_ORG_ID
 |
 | NOTES
 |      This function is used in the bulk rule processing api for better performance
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Jan-2006           karamach          Created
 *=======================================================================*/
FUNCTION GET_LOAN_ORG_ID RETURN NUMBER
IS
BEGIN
	return LNS_LOAN_ORG_ID;
END GET_LOAN_ORG_ID;

/*========================================================================
 | PUBLIC FUNCTION GET_RULES_DERIVED_ERS_AMOUNT
 |
 | DESCRIPTION
 |    This function applies rules defined on the loan product
 |		for ERS loan receivables derivation and inserts into loan lines table.
 |		If NO rules have been defined for the loan product, calling this api retrieves
 |    ALL OPEN Receivables for the customer and inserts them into loan lines.
 |		The function returns the total requested amount for updating loan header
 |	  after inserting the receivables into lns_loan_lines table.
 |
 | NOTES
 |    This api does a bulk select if max_requested_amount is NOT specified on the product.
 |    This api does bulk insert into lns_loan_lines after retrieving the matching receivables into table types.
 |		Incase an error is encountered during processing the api returns zero with error message in the stack.
 |		The api also returns zero if no receivables found for inserting into loan lines.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Jan-2006           karamach          Created
 *=======================================================================*/
FUNCTION GET_RULES_DERIVED_ERS_AMOUNT(
    p_loan_id         		IN     NUMBER,
    p_primary_borrower_id   IN     NUMBER,
    p_currency_code         IN 	   VARCHAR2,
    p_org_id         		IN     NUMBER,
    p_loan_product_id		IN	   NUMBER
) RETURN NUMBER
IS
l_api_name     CONSTANT VARCHAR2(30) := 'GET_RULES_DERIVED_ERS_AMOUNT';
l_loan_id NUMBER;
l_party_id NUMBER;
l_currency_code VARCHAR2(15);
l_org_id NUMBER;
l_loan_product_id NUMBER;
l_loan_product_name VARCHAR2(80);
l_max_amount NUMBER;
l_loan_amount NUMBER;
l_inv_conv_amount NUMBER;
l_record_count NUMBER;
l_user_id NUMBER;
l_login_id NUMBER;
l_date DATE;
l_loan_line_exists VARCHAR2(1);
l_last_api_called       varchar2(100); --Store the last api that was called before exception
l_sort_attribute VARCHAR2(1024);
l_rule_exists VARCHAR2(1);
l_bulk_process VARCHAR2(1);

CURSOR c_check_existing_line(pLoanId Number) IS
select 'Y' line_exists
from dual
where exists
(select null from lns_loan_lines where loan_id = pLoanId and end_date is null);

CURSOR c_loan_product(pLoanProductId Number, pOrgId Number) IS
select loan_product_name,MAX_REQUESTED_AMOUNT
from lns_loan_products_all_vl
where loan_product_id = pLoanProductId
and org_id = pOrgId;

--Need to define separate table types for each column for bulk insert since table type with all columns is not supported for bulk processing
TYPE lns_pmt_sch_id_type IS TABLE OF LNS_LOAN_LINES.PAYMENT_SCHEDULE_ID%TYPE INDEX BY PLS_INTEGER;
l_pmt_sch_id_tbl lns_pmt_sch_id_type;

TYPE lns_reference_id_type IS TABLE OF LNS_LOAN_LINES.REFERENCE_ID%TYPE INDEX BY PLS_INTEGER;
l_reference_id_tbl lns_reference_id_type;

TYPE lns_reference_number_type IS TABLE OF LNS_LOAN_LINES.REFERENCE_NUMBER%TYPE INDEX BY PLS_INTEGER;
l_reference_number_tbl lns_reference_number_type;

TYPE lns_reference_amount_type IS TABLE OF LNS_LOAN_LINES.REFERENCE_AMOUNT%TYPE INDEX BY PLS_INTEGER;
l_reference_amount_tbl lns_reference_amount_type;

TYPE lns_requested_amount_type IS TABLE OF LNS_LOAN_LINES.REQUESTED_AMOUNT%TYPE INDEX BY PLS_INTEGER;
l_requested_amount_tbl lns_requested_amount_type;

TYPE lns_installment_number_type IS TABLE OF LNS_LOAN_LINES.INSTALLMENT_NUMBER%TYPE INDEX BY PLS_INTEGER;
l_installment_number_tbl lns_installment_number_type;

CURSOR c_get_rule_object(pRuleObjectName VARCHAR2, pApplicationId NUMBER, pLoanProductId NUMBER, pOrgId NUMBER) IS
select 'Y' rule_exists, attr.DEFAULT_VALUE sort_attribute
FROM
FUN_RULE_OBJECTS_B obj, FUN_RULE_OBJ_ATTRIBUTES attr
WHERE obj.RULE_OBJECT_NAME = pRuleObjectName
AND obj.application_id = pApplicationId
AND obj.instance_label = to_char(pLoanProductId)
AND obj.ORG_ID = pOrgId
AND obj.PARENT_RULE_OBJECT_ID is not null
AND obj.RULE_OBJECT_ID = attr.RULE_OBJECT_ID;

CURSOR c_rule_result_invoices_sorted(pSortAttribute VARCHAR2) IS
select inv.payment_schedule_id,
inv.customer_trx_id,
inv.trx_number,
inv.AMOUNT_DUE_REMAINING,
inv.TERMS_SEQUENCE_NUMBER
FROM
LNS_OPEN_RECEIVABLES_V inv,
FUN_RULE_BULK_RESULT_GT results,
FUN_RULE_DETAILS rules
WHERE inv.payment_schedule_id = results.id
AND rules.RULE_DETAIL_ID = results.RULE_DETAIL_ID
AND results.RULE_DETAIL_ID <> -99
ORDER BY rules.SEQ, pSortAttribute;

/* -- pSortAttribute
(select DEFAULT_VALUE from
FUN_RULE_OBJ_ATTRIBUTES attr, FUN_RULE_DETAILS rule, FUN_RULE_BULK_RESULT_GT gt
where attr.RULE_OBJECT_ID = rule.rule_object_id
and rule.rule_detail_id = gt.rule_detail_id
and rownum < 2);
*/

CURSOR c_rule_result_invoices_nosort IS
select inv.payment_schedule_id,
inv.customer_trx_id,
inv.trx_number,
inv.AMOUNT_DUE_REMAINING reference_amount,
inv.AMOUNT_DUE_REMAINING,
inv.TERMS_SEQUENCE_NUMBER
FROM
LNS_OPEN_RECEIVABLES_V inv,
FUN_RULE_BULK_RESULT_GT results
WHERE inv.payment_schedule_id = results.id
AND results.RULE_DETAIL_ID <> -99;

CURSOR c_all_open_invoices_nosort(pPartyId NUMBER, pOrgId NUMBER, pCurrencyCode VARCHAR2) IS
select inv.payment_schedule_id,
inv.customer_trx_id,
inv.trx_number,
inv.AMOUNT_DUE_REMAINING reference_amount,
inv.AMOUNT_DUE_REMAINING,
inv.TERMS_SEQUENCE_NUMBER
FROM
LNS_OPEN_RECEIVABLES_V inv
WHERE inv.party_id = pPartyId
AND inv.org_id = pOrgId
AND inv.invoice_currency_code = pCurrencyCode;

CURSOR c_get_bulk_total(pLoanId NUMBER) IS
select sum(requested_amount) total_amount, count(loan_line_id) record_count
from lns_loan_lines
where loan_id = pLoanId
and end_date is null;

BEGIN

	  l_last_api_called := '';
		l_bulk_process := 'N';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    -- Standard Start of API savepoint
    SAVEPOINT loan_lines_derivation;


if (p_loan_id is null) then

    logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, l_api_name || ': ' ||  ' - missing loan_id');

		--throw exception
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_LOAN_ID');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ': ' ||  FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
end if;

--Initialize the local variables
l_loan_amount := 0;
l_record_count := 0;
l_loan_id := p_loan_id;
l_party_id := p_primary_borrower_id;
l_currency_code := p_currency_code;
l_org_id := p_org_id;
l_loan_product_id := p_loan_product_id;
l_user_id := LNS_UTILITY_PUB.created_by;
l_login_id := LNS_UTILITY_PUB.last_update_login;
l_date := sysdate;
l_loan_line_exists := 'N';

open c_check_existing_line(l_loan_id);
fetch c_check_existing_line into l_loan_line_exists;
close c_check_existing_line;

--if loan lines already exist, then the user should delete them explicitly before inheriting new receivables
if (l_loan_line_exists = 'Y') then

    logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, l_api_name || ': ' ||  ' - loan lines already exist for this loan_id');

		--throw exception
        FND_MESSAGE.SET_NAME('LNS', 'LNS_LOAN_LINES_EXIST');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ': ' ||  FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

end if;

if (p_primary_borrower_id is null OR p_currency_code is null OR p_org_id is null OR p_loan_product_id is null) then

--try to derive other id values from loan_id
null;

end if;

if (l_party_id is null OR l_currency_code is null OR l_org_id is null OR l_loan_product_id is null) then

    logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, l_api_name || ': ' ||  ' - invalid parameters');

		--throw exception
        FND_MESSAGE.SET_NAME('LNS', 'LNS_SOME_REQ_FIELDS_EMPTY');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ': ' || FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

end if;


--Get loan product name
open c_loan_product(l_loan_product_id,l_org_id);
fetch c_loan_product into l_loan_product_name,l_max_amount;
close c_loan_product;

if (l_loan_product_name is null) then

    logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, l_api_name || ': ' ||  ' - invalid loan_product_id');

		--throw exception
		FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
		FND_MESSAGE.SET_TOKEN('PARAMETER', 'p_loan_product_id');
		FND_MESSAGE.SET_TOKEN('VALUE', l_loan_product_id);
		FND_MSG_PUB.Add;
		LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ': ' || FND_MSG_PUB.Get(p_encoded => 'F'));
		RAISE FND_API.G_EXC_ERROR;

end if;

logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - passed IN parameters:');
logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_loan_id = ' || l_loan_id);
logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_primary_borrower_id = ' || l_party_id);
logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_currency_code = ' || l_currency_code);
logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_org_id = ' || l_org_id);
logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_loan_product_id = ' || l_loan_product_id);

logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Maximum Budgeted Amount for this loan:' || l_max_amount);

OPEN c_get_rule_object('LNS_ERS_LOAN_PRODUCT', 206, l_loan_product_id, l_org_id);
FETCH c_get_rule_object INTO l_rule_exists,l_sort_attribute;
CLOSE c_get_rule_object;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - l_rule_exists: ' || l_rule_exists);

IF (l_rule_exists = 'Y') THEN

	--Begin code to apply rules

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Before calling api FUN_RULE_PUB.SET_INSTANCE_CONTEXT');
	l_last_api_called := 'FUN_RULE_PUB.SET_INSTANCE_CONTEXT';
	FUN_RULE_PUB.SET_INSTANCE_CONTEXT(P_RULE_OBJECT_NAME => 'LNS_ERS_LOAN_PRODUCT',
									  P_APPLICATION_SHORT_NAME => 'LNS',
									  P_INSTANCE_LABEL => to_char(l_loan_product_id),
									  P_ORG_ID => l_org_id
									  );

	LNS_LOAN_PARTY_ID := l_party_id;
	LNS_LOAN_CURRENCY_CODE := l_currency_code;
	LNS_LOAN_ORG_ID := l_org_id;

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Before calling api FUN_RULE_PUB.apply_rule_bulk');
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - where clause for apply_rule_bulk: ');
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'PARTY_ID = ' || l_party_id || ' AND INVOICE_CURRENCY_CODE = ' || l_currency_code || ' AND ORG_ID = ' || l_org_id);

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  'LNS_LOAN_LINE_PUB.LNS_LOAN_PARTY_ID = ' || LNS_LOAN_LINE_PUB.LNS_LOAN_PARTY_ID);
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  'LNS_LOAN_LINE_PUB.LNS_LOAN_CURRENCY_CODE = ' || LNS_LOAN_LINE_PUB.LNS_LOAN_CURRENCY_CODE);
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  'LNS_LOAN_LINE_PUB.LNS_LOAN_ORG_ID = ' || LNS_LOAN_LINE_PUB.LNS_LOAN_ORG_ID);
	l_last_api_called := 'FUN_RULE_PUB.apply_rule_bulk';
	FUN_RULE_PUB.apply_rule_bulk(p_application_short_name => 'LNS',
	                              p_rule_object_name => 'LNS_ERS_LOAN_PRODUCT',
	                              p_param_view_name => 'LNS_OPEN_RECEIVABLES_V',
								  p_additional_where_clause => 'PARTY_ID = LNS_LOAN_LINE_PUB.GET_LOAN_PARTY_ID AND INVOICE_CURRENCY_CODE = LNS_LOAN_LINE_PUB.GET_LOAN_CURRENCY_CODE AND ORG_ID = LNS_LOAN_LINE_PUB.GET_LOAN_ORG_ID',
	                              p_primary_key_column_name => 'PAYMENT_SCHEDULE_ID'
								 );

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - After calling api FUN_RULE_PUB.apply_rule_bulk');

END IF; -- IF (l_rule_exists = 'Y') THEN

IF (l_max_amount IS NOT NULL) THEN

	if (l_rule_exists = 'Y') then
		--Based on rules, fetch matching invoices in the specified sort order until the max requested amount is reached
		--There could be an invoice with only a partial amount added from it if the last invoice that is picked has its balance amount
		--more than the remaining balance on the specified maximum requested amount
		l_last_api_called := 'Fetch in loop using cursor c_rule_result_invoices_sorted';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - l_last_api_called: ' || l_last_api_called);
		for c_result_inv_rec in c_rule_result_invoices_sorted(l_sort_attribute) loop
			--calculate the invoice conversion amount since this could be less than the remaining balance on the invoice
			--based on the amount remaining in the max requested amount limit for this loan
			l_inv_conv_amount := least(c_result_inv_rec.AMOUNT_DUE_REMAINING,l_max_amount - l_loan_amount);
			if (l_inv_conv_amount > 0) then
				l_record_count := l_record_count + 1;
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Begin processing Row#' || l_record_count);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Payment_schedule_id is: ' || c_result_inv_rec.payment_schedule_id);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Trx_Number: ' || c_result_inv_rec.trx_number);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Amount_Due_Remaining: ' || c_result_inv_rec.AMOUNT_DUE_REMAINING);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'The receivable conversion amount(loan line requested amount) is ' || l_inv_conv_amount);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Total Loan Amount:' || l_loan_amount);
				l_pmt_sch_id_tbl(l_record_count) := c_result_inv_rec.payment_schedule_id;
				l_installment_number_tbl(l_record_count) := c_result_inv_rec.TERMS_SEQUENCE_NUMBER;
				l_reference_id_tbl(l_record_count) := c_result_inv_rec.customer_trx_id;
				l_reference_number_tbl(l_record_count) := c_result_inv_rec.trx_number;
				l_reference_amount_tbl(l_record_count) := c_result_inv_rec.AMOUNT_DUE_REMAINING;
				l_requested_amount_tbl(l_record_count) := l_inv_conv_amount;
		    l_loan_amount := l_loan_amount + l_inv_conv_amount;
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - End processing Row#' || l_record_count);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Total Loan Amount:' || l_loan_amount);
			end if;
			exit when (l_loan_amount >= l_max_amount);
		end loop;
	else -- else part for if (l_rule_exists = 'Y') then
		--Since rules do not exist, fetch all open invoices in no particular order until the max requested amount is reached
		--There could be an invoice with only a partial amount added from it if the last invoice that is picked has its balance amount
		--more than the remaining balance on the specified maximum requested amount
		l_last_api_called := 'Fetch in loop using cursor c_all_open_invoices_nosort';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - l_last_api_called: ' || l_last_api_called);
		for c_result_inv_rec in c_all_open_invoices_nosort(l_party_id, l_org_id, l_currency_code) loop
			--calculate the invoice conversion amount since this could be less than the remaining balance on the invoice
			--based on the amount remaining in the max requested amount limit for this loan
			l_inv_conv_amount := least(c_result_inv_rec.AMOUNT_DUE_REMAINING,l_max_amount - l_loan_amount);
			if (l_inv_conv_amount > 0) then
				l_record_count := l_record_count + 1;
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Begin processing Row#' || l_record_count);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Payment_schedule_id is: ' || c_result_inv_rec.payment_schedule_id);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Trx_Number: ' || c_result_inv_rec.trx_number);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Amount_Due_Remaining: ' || c_result_inv_rec.AMOUNT_DUE_REMAINING);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'The receivable conversion amount(loan line requested amount) is ' || l_inv_conv_amount);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Total Loan Amount:' || l_loan_amount);
				l_pmt_sch_id_tbl(l_record_count) := c_result_inv_rec.payment_schedule_id;
				l_installment_number_tbl(l_record_count) := c_result_inv_rec.TERMS_SEQUENCE_NUMBER;
				l_reference_id_tbl(l_record_count) := c_result_inv_rec.customer_trx_id;
				l_reference_number_tbl(l_record_count) := c_result_inv_rec.trx_number;
				l_reference_amount_tbl(l_record_count) := c_result_inv_rec.AMOUNT_DUE_REMAINING;
				l_requested_amount_tbl(l_record_count) := l_inv_conv_amount;
		    l_loan_amount := l_loan_amount + l_inv_conv_amount;
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - End processing Row#' || l_record_count);
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - Total Loan Amount:' || l_loan_amount);
			end if;
			exit when (l_loan_amount >= l_max_amount);
		end loop;
	end if; -- if (l_rule_exists = 'Y') then

ELSE --if (l_max_amount is not null) then

	  l_bulk_process := 'Y';
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - l_bulk_process: ' || l_bulk_process);
		if (l_rule_exists = 'Y') then
			-- bulk fetch rule results without sort
			l_last_api_called := 'Bulk Collect using cursor c_rule_result_invoices_nosort';
		  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - BEGIN: ' || l_last_api_called);
			open c_rule_result_invoices_nosort;
			fetch c_rule_result_invoices_nosort bulk collect into l_pmt_sch_id_tbl,l_reference_id_tbl,l_reference_number_tbl,l_reference_amount_tbl,l_requested_amount_tbl,l_installment_number_tbl;
			close c_rule_result_invoices_nosort;
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - END: ' || l_last_api_called);
		else
			--bulk fetch all open invoices without sort
			l_last_api_called := 'Bulk Collect using cursor c_all_open_invoices_nosort';
  		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - BEGIN: ' || l_last_api_called);
			open c_all_open_invoices_nosort(l_party_id, l_org_id, l_currency_code);
			fetch c_all_open_invoices_nosort bulk collect into l_pmt_sch_id_tbl,l_reference_id_tbl,l_reference_number_tbl,l_reference_amount_tbl,l_requested_amount_tbl,l_installment_number_tbl;
			close c_all_open_invoices_nosort;
  		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - END: ' || l_last_api_called);
		end if; -- if (l_rule_exists = 'Y') then

END IF; -- IF (l_max_amount IS NOT NULL) THEN

IF (l_pmt_sch_id_tbl.count <= 0) THEN
		--No open receivable found for derivation.
		--throw exception
		FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_REC_FOUND');
		FND_MSG_PUB.Add;
		LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ': ' || FND_MSG_PUB.Get(p_encoded => 'F'));
		RAISE FND_API.G_EXC_ERROR;
END IF;

l_last_api_called := 'Bulk insert into lns_loan_lines';
logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - BEGIN: ' || l_last_api_called);

forall i in l_pmt_sch_id_tbl.first..l_pmt_sch_id_tbl.last
  insert into lns_loan_lines(
	LOAN_LINE_ID
	,LOAN_ID
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,CREATION_DATE
	,CREATED_BY
	,OBJECT_VERSION_NUMBER
	,REFERENCE_TYPE
	,REFERENCE_ID
	,REFERENCE_NUMBER
	,REFERENCE_DESCRIPTION
	,REFERENCE_AMOUNT
	,REQUESTED_AMOUNT
	,REC_ADJUSTMENT_NUMBER
	,END_DATE
	,REC_ADJUSTMENT_ID
	,PAYMENT_SCHEDULE_ID
	,INSTALLMENT_NUMBER
  )
  values(
	LNS_LOAN_LINE_S.nextval
	,l_loan_id
	,l_date
	,l_user_id
	,l_login_id
	,l_date
	,l_user_id
	,1
	,'RECEIVABLE'
	,l_reference_id_tbl(i)
	,l_reference_number_tbl(i)
	,null
	,l_reference_amount_tbl(i)
	,l_requested_amount_tbl(i)
	,null
	,null
	,null
	,l_pmt_sch_id_tbl(i)
	,l_installment_number_tbl(i)
  );

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': ' ||  ' - END: ' || l_last_api_called);

	IF (l_bulk_process = 'Y') THEN
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Record fetch was performed as a bulk operation since maximum loan amount is NOT specified in loan product');
		/* --open cursor to get number of records and total requested amount from lns_loan_lines
		OPEN c_get_bulk_total(l_loan_id);
		FETCH c_get_bulk_total INTO l_loan_amount, l_record_count;
		CLOSE c_get_bulk_total;
		--the return value should not be null
		--handle case when no loan lines were inserted by this procedure
		if (l_loan_amount is null) then
			l_loan_amount := 0;
		end if;
		*/
		l_loan_amount := 0;
		l_record_count := 0;
		for j in l_requested_amount_tbl.first..l_requested_amount_tbl.last loop
			l_record_count := l_record_count + 1;
			l_loan_amount := l_loan_amount + l_requested_amount_tbl(j);
		end loop;
	END IF;
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Inserted '|| l_record_count || ' rows into lns_loan_lines successfully!');
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - The total loan amount processed is ' || l_loan_amount);

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

return l_loan_amount;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - before rollback');
				ROLLBACK TO loan_lines_derivation;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - after rollback');
				logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
				return 0;
	WHEN OTHERS THEN
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - before rollback');
		ROLLBACK TO loan_lines_derivation;
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - after rollback');
		logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
		FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
		FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_last_api_called || ' SQLERRM: ' || SQLERRM);
		FND_MSG_PUB.ADD;
		return 0;

END GET_RULES_DERIVED_ERS_AMOUNT;

END LNS_LOAN_LINE_PUB;

/
