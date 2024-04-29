--------------------------------------------------------
--  DDL for Package ARP_TRX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTUTILS.pls 120.4.12010000.2 2008/11/13 15:45:44 rmanikan ship $ */

PROCEDURE delete_transaction(p_form_name         IN varchar2,
                             p_form_version      IN number,
                             p_customer_trx_id   IN NUMBER);

PROCEDURE lock_transaction(p_customer_trx_id   IN NUMBER);

PROCEDURE set_term_in_use_flag(p_form_name         IN varchar2,
                               p_form_version      IN number,
                               p_term_id           IN number,
                               p_term_in_use_flag  IN varchar2);

PROCEDURE set_posted_flag(p_customer_trx_id   IN NUMBER,
                          p_posted_flag      OUT NOCOPY BOOLEAN);


FUNCTION boolean_to_varchar2(p_boolean IN boolean) RETURN varchar2;

FUNCTION detect_freight_only_rules_case( p_customer_trx_id IN
                                         ra_customer_trx.customer_trx_id%type )
                      RETURN BOOLEAN;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    transaction_balance						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines the balances for a transaction				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id         - identifies the transaction |
 |                    p_open_receivables_flag                                |
 |                    p_exchange_rate                                        |
 |                    p_mode           - Can be 'ALL'  or 'SUMMARY'          |
 |                                     - All balances are returned in ALL    |
 |                                       mode. Only the Txn. original and    |
 |                                       remaining balances are returned     |
 |                                       in SUMMARY mode.                    |
 |                                                                           |
 |                    p_currency_mode  - Can be 'E'(ntered) or 'A'(ll)       |
 |                                     - The base currency amounts are only  |
 |                                       calculated and returned in 'A' mode.|
 |              OUT:                                                         |
 |                    < entered currency balances >                          |
 |                    < base currency balances >                             |
 |                                                                           |
 | NOTES                                                                     |
 |     Rounding errors for the base amounts are corrected in this procedure  |
 |     by putting the rounding error on the line balances. This may not be   |
 |     the same as how the rounding errors are corrected on the actual       |
 |     transaction. Therefore, the base line, tax and freight balances may   |
 |     not be accurate. The totals are always accurate, however.             |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE transaction_balances(p_customer_trx_id             IN
                                        ra_customer_trx.customer_trx_id%type,
                               p_open_receivables_flag       IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                               p_exchange_rate               IN
                                 ra_customer_trx.exchange_rate%type,
                               p_mode                        IN VARCHAR2,
                               p_currency_mode               IN VARCHAR2,
                               p_line_original              OUT NOCOPY NUMBER,
                               p_line_remaining             OUT NOCOPY NUMBER,
                               p_tax_original               OUT NOCOPY NUMBER,
                               p_tax_remaining              OUT NOCOPY NUMBER,
                               p_freight_original           OUT NOCOPY NUMBER,
                               p_freight_remaining          OUT NOCOPY NUMBER,
                               p_charges_original           OUT NOCOPY NUMBER,
                               p_charges_remaining          OUT NOCOPY NUMBER,
                               p_line_discount              OUT NOCOPY NUMBER,
                               p_tax_discount               OUT NOCOPY NUMBER,
                               p_freight_discount           OUT NOCOPY NUMBER,
                               p_charges_discount           OUT NOCOPY NUMBER,
                               p_total_discount             OUT NOCOPY NUMBER,
                               p_total_original             OUT NOCOPY NUMBER,
                               p_total_remaining            OUT NOCOPY NUMBER,
                               p_line_receipts              OUT NOCOPY NUMBER,
                               p_tax_receipts               OUT NOCOPY NUMBER,
                               p_freight_receipts           OUT NOCOPY NUMBER,
                               p_charges_receipts           OUT NOCOPY NUMBER,
                               p_total_receipts             OUT NOCOPY NUMBER,
                               p_line_credits               OUT NOCOPY NUMBER,
                               p_tax_credits                OUT NOCOPY NUMBER,
                               p_freight_credits            OUT NOCOPY NUMBER,
                               p_total_credits              OUT NOCOPY NUMBER,
                               p_line_adjustments           OUT NOCOPY NUMBER,
                               p_tax_adjustments            OUT NOCOPY NUMBER,
                               p_freight_adjustments        OUT NOCOPY NUMBER,
                               p_charges_adjustments        OUT NOCOPY NUMBER,
                               p_total_adjustments          OUT NOCOPY NUMBER,
                               p_aline_adjustments          OUT NOCOPY NUMBER,
                               p_atax_adjustments           OUT NOCOPY NUMBER,
                               p_afreight_adjustments       OUT NOCOPY NUMBER,
                               p_acharges_adjustments       OUT NOCOPY NUMBER,
                               p_atotal_adjustments         OUT NOCOPY NUMBER,
                               p_base_line_original         OUT NOCOPY NUMBER,
                               p_base_line_remaining        OUT NOCOPY NUMBER,
                               p_base_tax_original          OUT NOCOPY NUMBER,
                               p_base_tax_remaining         OUT NOCOPY NUMBER,
                               p_base_freight_original      OUT NOCOPY NUMBER,
                               p_base_freight_remaining     OUT NOCOPY NUMBER,
                               p_base_charges_original      OUT NOCOPY NUMBER,
                               p_base_charges_remaining     OUT NOCOPY NUMBER,
                               p_base_line_discount         OUT NOCOPY NUMBER,
                               p_base_tax_discount          OUT NOCOPY NUMBER,
                               p_base_freight_discount      OUT NOCOPY NUMBER,
                               p_base_total_discount        OUT NOCOPY NUMBER,
                               p_base_total_original        OUT NOCOPY NUMBER,
                               p_base_total_remaining       OUT NOCOPY NUMBER,
                               p_base_line_receipts         OUT NOCOPY NUMBER,
                               p_base_tax_receipts          OUT NOCOPY NUMBER,
                               p_base_freight_receipts      OUT NOCOPY NUMBER,
                               p_base_charges_receipts      OUT NOCOPY NUMBER,
                               p_base_total_receipts        OUT NOCOPY NUMBER,
                               p_base_line_credits          OUT NOCOPY NUMBER,
                               p_base_tax_credits           OUT NOCOPY NUMBER,
                               p_base_freight_credits       OUT NOCOPY NUMBER,
                               p_base_total_credits         OUT NOCOPY NUMBER,
                               p_base_line_adjustments      OUT NOCOPY NUMBER,
                               p_base_tax_adjustments       OUT NOCOPY NUMBER,
                               p_base_freight_adjustments   OUT NOCOPY NUMBER,
                               p_base_charges_adjustments   OUT NOCOPY NUMBER,
                               p_base_total_adjustments     OUT NOCOPY NUMBER,
                               p_base_aline_adjustments     OUT NOCOPY NUMBER,
                               p_base_atax_adjustments      OUT NOCOPY NUMBER,
                               p_base_afreight_adjustments  OUT NOCOPY NUMBER,
                               p_base_acharges_adjustments  OUT NOCOPY NUMBER,
                               p_base_atotal_adjustments    OUT NOCOPY NUMBER
                             );

PROCEDURE get_summary_trx_balances( p_customer_trx_id       IN
                                        ra_customer_trx.customer_trx_id%type,
                              p_open_receivables_flag       IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                              p_line_original              OUT NOCOPY NUMBER,
                              p_line_remaining             OUT NOCOPY NUMBER,
                              p_tax_original               OUT NOCOPY NUMBER,
                              p_tax_remaining              OUT NOCOPY NUMBER,
                              p_freight_original           OUT NOCOPY NUMBER,
                              p_freight_remaining          OUT NOCOPY NUMBER,
                              p_charges_original           OUT NOCOPY NUMBER,
                              p_charges_remaining          OUT NOCOPY NUMBER,
                              p_total_original             OUT NOCOPY NUMBER,
                              p_total_remaining            OUT NOCOPY NUMBER );

/*===========================================================================+
 | FUNTION                                                                   |
 |    IS_FV_ENABLED                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks whether the Federal is enabled or not using                     |
 |    Federal Financial api fv_install.enabled.                              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |         arp_standard.debug                                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |             OUT:                                                          |
 |                                                                           |
 | RETURNS    : T - True, F - False                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     23-Jun-08	      Thirumalaisamy      	Created              |
 +===========================================================================*/
FUNCTION IS_FV_ENABLED RETURN VARCHAR2;

/*===========================================================================+
 | FUNTION                                                                   |
 |    IS_CCR_SUPPLIER                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks the given party/site is CCR supplier/Site                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |         arp_standard.debug                                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_object_type - CUST - Customer, ADDR - Address         |
 |             OUT:                                                          |
 |                                                                           |
 | RETURNS    : T - True, F - False                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     23-Jun-08	      Thirumalaisamy      	Created              |
 +===========================================================================*/

FUNCTION IS_CCR_SUPPLIER(
 p_object_type           IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2;


PROCEDURE init;

END ARP_TRX_UTIL;

/
