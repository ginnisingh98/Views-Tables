--------------------------------------------------------
--  DDL for Package Body AR_CUSTOM_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CUSTOM_CONTRACT_API" AS
/* $Header: ARXRMCCB.pls 115.2 2003/11/21 16:32:52 mraymond noship $ */


 pg_debug VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');


/*========================================================================
 | PUBLIC FUNCTION implemented_third_party
 |
 | DESCRIPTION
 |   This is the function to determine if theird party contract system
 |   has been implented and you wish to use feed this data to the
 |   Revenue Mangement Engine.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Revenue Managment Engine.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-MAR-2003           Obaidur Rashid    Created
 |
 *=======================================================================*/

FUNCTION implemented_third_party
  RETURN BOOLEAN IS

BEGIN

  -- Change 'FALSE' to 'TRUE' if u have implemented
  -- a third party contract solution.

  fnd_file.put_line(fnd_file.log,
    'ar_custom_contract_api.implemented_third_party()');

  RETURN FALSE;

END implemented_third_party;


/*========================================================================
 | PUBLIC PROCEDURE retrieve_contract
 |
 | DESCRIPTION
 |   If you have a third party contract solution, and you want to
 |   retrieve data from that system and integrate with Oracle's
 |   revenue management solution, you must write code in this routine
 |   populate the OUT parameters appropriately so that Revenue Management
 |   Engine can take these into consideration.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |   Called by Revenue Management Engine.
 |
 | PARAMETERS
 |   p_customer_trx_id       IN  NUMBER   Invoice ID
 |   p_customer_trx_line_id  IN  NUMBER   Invoice Line ID
 |   p_sales_order           IN  NUMBER   Sales Order Number (NOT ID)
 |   p_sales_order_line_id   IN  VARCHAR2 Sales Order Line ID
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | DD-MON-YYYY           Obaidur Rashid    Created
 |
 *=======================================================================*/

PROCEDURE retrieve_contract_info (
  p_customer_trx_id       IN  NUMBER,
  p_customer_trx_line_id  IN  NUMBER,
  p_sales_order           IN  NUMBER,
  p_sales_order_line_id   IN  VARCHAR2,
  p_transaction_date	  IN  DATE,
  x_contract_id	          OUT NOCOPY VARCHAR2,
  x_contract_line_id	  OUT NOCOPY VARCHAR2,
  x_acceptance_clause     OUT NOCOPY VARCHAR2,
  x_acceptance_expiry     OUT NOCOPY DATE,
  x_refund_clause         OUT NOCOPY VARCHAR2,
  x_refund_expiry         OUT NOCOPY DATE,
  x_cancellation_clause   OUT NOCOPY VARCHAR2,
  x_cancellation_expiry   OUT NOCOPY DATE,
  x_forfeiture_clause     OUT NOCOPY VARCHAR2,
  x_forfeiture_expiry     OUT NOCOPY DATE,
  x_fiscal_funding_clause OUT NOCOPY VARCHAR2,
  x_fiscal_expiry         OUT NOCOPY DATE) IS


BEGIN

  fnd_file.put_line(fnd_file.log,
    'ar_custom_contract_api.retrieve_Contract_info()+');

  IF pg_debug IN ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, '*** parameters ***');
    fnd_file.put_line(fnd_file.log, '  p_customer_trx_id : ' ||
      p_customer_trx_id);
    fnd_file.put_line(fnd_file.log, '  p_customer_trx_line_id : ' ||
      p_customer_trx_line_id);
    fnd_file.put_line(fnd_file.log, '  p_sales_order : ' || p_sales_order);
    fnd_file.put_line(fnd_file.log, '  p_sales_order_line_id : ' ||
      p_sales_order_line_id);
    fnd_file.put_line(fnd_file.log, '  p_transaction_date : ' ||
      p_transaction_date);
  END IF;

  -- Start out by assigning default  values to the out parameters.
  -- So, in the case where there is no associated contracts, our
  -- engine would still function.

  x_acceptance_clause 		:= 'N';
  x_acceptance_expiry 		:= NULL;
  x_refund_clause     		:= 'N';
  x_refund_expiry     		:= NULL;
  x_cancellation_clause	 	:= 'N';
  x_cancellation_expiry 	:= NULL;
  x_forfeiture_clause   	:= 'N';
  x_forfeiture_expiry   	:= NULL;
  x_fiscal_funding_clause       := 'N';
  x_fiscal_expiry         	:= NULL;

  -- Here put your custom logic to retrieve contract contingencies
  -- and populate the OUT parameters listed above appropriately.
  -- Please note that when a value of 'Y' for any clause
  -- would be interpreted as an existence of a contract contingency.
  -- And the corresponding expiration fiels will then be used to
  -- time the expiration of this clause.  Nevetheless, some
  -- contingencies may not have an expiration (e.g. Acceptance Clause).
  -- In those cases you can leave it null.

  -- If you are writing custom logic here then you must first change
  -- value to TRUE in the function third_party_implemented.

  fnd_file.put_line(fnd_file.log,
    'ar_custom_contract_api.retrieve_Contract_info()-');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
      arp_standard.debug('retrieve_contract_info: EXCEPTION NO_DATA_FOUND');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('retrieve_contract_info: EXCEPTION OTHERS');
    END IF;
    RAISE;

END retrieve_contract_info;


BEGIN

   null;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     arp_standard.debug('EXCEPTION: ar_custom_contract_api.initialize');
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ar_custom_contract_api.initialize');
     RAISE;

END ar_custom_contract_api;

/
