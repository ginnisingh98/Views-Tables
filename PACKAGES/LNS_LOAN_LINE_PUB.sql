--------------------------------------------------------
--  DDL for Package LNS_LOAN_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_LOAN_LINE_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_LINE_PUBP_S.pls 120.4.12010000.2 2010/03/17 13:18:53 scherkas ship $ */

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
 | 20-Dec-2004           karamach          Created
 *=======================================================================*/
PROCEDURE UPDATE_LINE_ADJUSTMENT_NUMBER(
											p_init_msg_list  IN VARCHAR2
											,p_loan_id        IN  NUMBER
											,p_loan_line_id IN  NUMBER
											,p_rec_adjustment_number IN  VARCHAR2
											,p_rec_adjustment_id IN  NUMBER
											,p_payment_schedule_id IN  NUMBER
											,p_installment_number IN  NUMBER
                                            ,p_adjustment_date IN  DATE
                                            ,p_original_flag IN VARCHAR2
											,x_return_status  OUT NOCOPY VARCHAR2
											,x_msg_count      OUT NOCOPY NUMBER
											,x_msg_data       OUT NOCOPY VARCHAR2);


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
FUNCTION GET_LOAN_PARTY_ID RETURN NUMBER;

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
FUNCTION GET_LOAN_CURRENCY_CODE RETURN VARCHAR2;

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
FUNCTION GET_LOAN_ORG_ID RETURN NUMBER;

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
) RETURN NUMBER;

END LNS_LOAN_LINE_PUB;

/
