--------------------------------------------------------
--  DDL for Package ARP_APP_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_APP_CALC_PKG" AUTHID CURRENT_USER AS
/* $Header: ARAPPRUS.pls 120.2 2006/01/12 14:33:39 vcrisost ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_RULE_SET_ID                                                           |
 | DESCRIPTION                                                               |
 |   Given the cust_trx_type_id from the payment schedule this function will |
 |   return the rule_set_id to be used for this transaction                  |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Public                                                            |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   cust_trx_type_id - this is the transaction type of the item      |
 |          associated with the payment schedule                             |
 |   OUT NOCOPY    This function will return the rule_set_id to be used while       |
 |          calling the calc_applied_and_remaining procedure                 |
 | MODIFICATION HISTORY                                                      |
 |   06-25-97  Joan Zaman --  Created                                        |
 +===========================================================================*/

 function get_rule_set_id ( p_trx_type_id in number ) return number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   CALC_APPLIED_AND_REMAINING                                              |
 | DESCRIPTION                                                               |
 |   Given all the remaining amounts this procedure will calculate the new   |
 |   applied amounts and remaining amounts based on the amount you want to   |
 |   apply. The rule used for calculating the applied amounts is the rule    |
 |   currently active in the system options form.                            |
 |                                                                           |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Public                                                             |
 |                                                                           |
 | PARAMETERS                                                                |
 |   IN -   amt   -- This is the mount to be applied to all parts using      |
 |                   the rule                                                |
 |          rule_set_id -- Which rule to use
 |          currency  -- currency the amount is in , used for rounding when  |
 |                       prorating                                           |
 |       line_remaining -- Remaining line amt at the time of the applic.     |
 |       line_tax_remaining -- Remaining tax amt related to the line         |
 |       freight_remaining -- Remaining line amt at the time of the applic.  |
 |       freight_tax_remaining -- Remaining tax amt related to the freight   |
 |       charges_remaining -- Remaining line amt at the time of the applic.  |
 |       charges_tax_remaining -- Remaining tax amt related to the charges   |
 |   OUT NOCOPY
 |       line_applied - Amount applied for this part                         |
 |       line_tax_applied - Amount applied for this part                     |
 |       freight_applied - Amount applied for this part                      |
 |       freight_tax_applied - Amount applied for this part                  |
 |       charges_applied - Amount applied for this part                      |
 |       charges_tax_applied - Amount applied for this part                  |
 |                                                                           |
 |       Also all the new remaining amounts will be provided back. This is   |
 |       mainly important for the c-functions                                |
 |       Most PL/SQL procedures will calculate their own remaining amounts   |
 | USAGE NOTES                                                               |
 |       1. Only provide positive values to this procedure                   |
 |          In case of adjustment provide +ve values and negate afterwards   |
 |       2. Only Line_Tax_ values will be used for now because tax on        |
 |          freight and charges does not yet exists. Pass a zero value for it|
 | MODIFICATION HISTORY                                                      |
 |   03-11-97  Joan Zaman --  Created                                        |
 |===========================================================================*/
procedure calc_applied_and_remaining ( amt in number
                               ,rule_set_id number
                               ,currency in varchar2
                               ,line_remaining in out NOCOPY number
                               ,line_tax_remaining in out NOCOPY number
                               ,freight_remaining in out NOCOPY number
                               ,freight_tax_remaining in out NOCOPY number
                               ,charges_remaining in out NOCOPY number
                               ,charges_tax_remaining in out NOCOPY number
                               ,line_applied out NOCOPY number
                               ,line_tax_applied  out NOCOPY number
                               ,freight_applied  out NOCOPY number
                               ,freight_tax_applied  out NOCOPY number
                               ,charges_applied  out NOCOPY number
                               ,charges_tax_applied  out NOCOPY number);

-- This is the simple version and implies that there is no tax on charges
-- nor on freight. This is the situation in release 10 and 11 .

procedure calc_applied_and_remaining ( p_amt in number
                               ,p_rule_set_id number
                               ,p_currency in varchar2
                               ,p_line_remaining in out NOCOPY number
                               ,p_line_tax_remaining in out NOCOPY number
                               ,p_freight_remaining in out NOCOPY number
                               ,p_charges_remaining in out NOCOPY number
                               ,p_line_applied out NOCOPY number
                               ,p_line_tax_applied  out NOCOPY number
                               ,p_freight_applied  out NOCOPY number
                               ,p_charges_applied  out NOCOPY number
                               ,p_created_from in varchar2 DEFAULT NULL
                               );


/*===========================================================================+
 | PROCEDURE                                                                 |
 |  COMPILE_RULE ()                                                          |
 | DESCRIPTION                                                               |
 |  This procedure will create a long column that will be inserted into      |
 |  the ar_application_rules table with the according rule                   |
 |  This compilation makes it possible for the calc_applied_and_remaining    |
 |  procedure not to select multiple times from app_rule... tables           |
 |                                                                           |
 |  This procedure should be called from the application rules set up form   |
 |  from the post_update trigger when the freeze flag getds set to 'Y'       |
 |                                                                           |
 |  Whenever a rule will be frozen a compiled rule will be created and stored|
 |  in the long column rule_source.                                          |
 |                                                                           |
 |  Before creating the long column the procedure will check whether         |
 |  the rule is valid. Following checks will be made :                       |
 |    1. Is there one and only one Over Application Block                    |
 |    2. Are there one or more non-overapplication Blocks                    |
 |    3. Is every Line type present in one of the non-overapplication blocks |
 |    4. Has one and only one of the application block lines in every        |
 |       application block the rounding correction checked                   |
 |                                                                           |
 |  SCOPE -- Public -- To be called from the application rules set up form   |
 |  PARAMETERS                                                               |
 |     IN -- rule_id -- This is the id from the rule you want to compile.    |
 |                                                                           |
 |  MODIFICATION HISTORY                                                     |
 |   03-11-97 -- Joan Zaman -- Created                                       |
 +===========================================================================*/


procedure COMPILE_RULE ( p_rule_set_id in ar_app_rule_sets.rule_set_id%TYPE);

end ARP_APP_CALC_PKG;

 

/
