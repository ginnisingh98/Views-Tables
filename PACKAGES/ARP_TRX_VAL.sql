--------------------------------------------------------
--  DDL for Package ARP_TRX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_VAL" AUTHID CURRENT_USER AS
/* $Header: ARTUVA3S.pls 115.3 2004/01/22 17:41:22 srivasud ship $ */

FUNCTION check_commitment_overapp( p_commitment_trx_id IN number,
                                   p_commitment_class  IN varchar2,

                                   p_commitment_amount IN number,
                                   p_trx_amount        IN number,
                                   p_so_source_code    IN varchar2,
                                   p_so_installed_flag IN varchar2,
                                   p_commitment_bal    OUT NOCOPY number)
RETURN BOOLEAN;

FUNCTION check_currency_amounts(
                                 p_customer_trx_id       IN number,
                                 p_currency_code         IN varchar2,
                                 p_display_message_flag  IN boolean
                               )  RETURN boolean;

/*Bug3283086 */
FUNCTION check_payment_method_validate(p_trx_date            IN  DATE,
                             p_currency_code                 IN  VARCHAR2,
                             p_bill_to_customer_id	     IN  NUMBER,
                             p_pay_to_customer_id	     IN  NUMBER,
			     p_receipt_method_id	     IN  NUMBER,
			     p_set_of_books_id		     IN  NUMBER) RETURN BOOLEAN;
END ARP_TRX_VAL;

 

/
