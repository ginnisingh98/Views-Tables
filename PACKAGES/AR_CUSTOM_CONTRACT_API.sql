--------------------------------------------------------
--  DDL for Package AR_CUSTOM_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CUSTOM_CONTRACT_API" AUTHID CURRENT_USER AS
/* $Header: ARXRMCCS.pls 120.2 2005/10/30 03:59:48 appldev noship $ */


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
  RETURN BOOLEAN;


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
  x_fiscal_expiry         OUT NOCOPY DATE);

END ar_custom_contract_api;

 

/
