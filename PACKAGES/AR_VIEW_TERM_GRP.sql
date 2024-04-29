--------------------------------------------------------
--  DDL for Package AR_VIEW_TERM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_VIEW_TERM_GRP" AUTHID CURRENT_USER AS
/* $Header: ARVTERMS.pls 120.1 2005/01/14 19:43:39 jbeckett noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

TYPE pay_now_record IS RECORD(
         base_amount             ra_terms.base_amount%TYPE,
         first_installment_code  ra_terms.first_installment_code%TYPE,
         relative_amount_total   ra_terms_lines.relative_amount%TYPE,
         first_installment_count NUMBER );

TYPE amounts_record IS RECORD(
	line_id				NUMBER,
	term_id				NUMBER,
	line_amount			NUMBER,
	tax_amount			NUMBER,
	freight_amount			NUMBER,
	total_amount			NUMBER);

TYPE amounts_table IS TABLE OF amounts_record INDEX BY BINARY_INTEGER;

TYPE summary_amounts_rec IS RECORD(
	line_amount			NUMBER,
	tax_amount			NUMBER,
	freight_amount			NUMBER,
	total_amount			NUMBER);

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*=======================================================================+
 |  Declare Global variables
 +=======================================================================*/


/*========================================================================
 | PUBLIC Procedure pay_now_amounts
 |
 | DESCRIPTION
 |      For a given line, tax and freight amount, determines corresponding
 |      pay now amounts from payment terms.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date         Author         	Description of Changes
 | 10-NOV-2004	J Beckett       Created
 |
 *=======================================================================*/
PROCEDURE pay_now_amounts(
           -- Standard API parameters.
               	p_api_version      	IN  NUMBER,
             	p_init_msg_list    	IN  VARCHAR2,
              	p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		p_term_id 		IN NUMBER,
		p_currency_code 	IN fnd_currencies.currency_code%TYPE,
		p_line_amount		IN NUMBER,
		p_tax_amount		IN NUMBER,
                p_freight_amount	IN NUMBER,
		x_pay_now_line_amount   OUT NOCOPY NUMBER,
		x_pay_now_tax_amount    OUT NOCOPY NUMBER,
		x_pay_now_freight_amount OUT NOCOPY NUMBER,
		x_pay_now_total_amount	OUT NOCOPY NUMBER,
                x_return_status    	OUT NOCOPY VARCHAR2,
                x_msg_count        	OUT NOCOPY NUMBER,
                x_msg_data         	OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC Procedure pay_now_amounts (overloaded)
 |
 | DESCRIPTION
 |      For a given line, tax and freight amount, determines corresponding
 |      pay now amounts from payment terms. Data is input/output in a table.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date         Author         	Description of Changes
 | 10-NOV-2004	J Beckett       Created
 |
 *=======================================================================*/
  PROCEDURE pay_now_amounts(
                p_api_version      	IN  NUMBER,
                p_init_msg_list    	IN  VARCHAR2,
                p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		p_currency_code 	IN  fnd_currencies.currency_code%TYPE,
		p_amounts_tbl           IN OUT NOCOPY ar_view_term_grp.amounts_table,
		x_pay_now_summary_rec	OUT NOCOPY ar_view_term_grp.summary_amounts_rec,
                x_return_status    	OUT NOCOPY VARCHAR2,
                x_msg_count        	OUT NOCOPY NUMBER,
                x_msg_data         	OUT NOCOPY VARCHAR2);

END AR_VIEW_TERM_GRP;

 

/
