--------------------------------------------------------
--  DDL for Package ARP_LLCA_ADJUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_LLCA_ADJUST_PKG" AUTHID CURRENT_USER AS
/* $Header: ARLLADJS.pls 120.0 2005/08/29 21:08:31 djancis noship $ */


/*=============================================================================
 |  PROCEDURE  LLCA_Adjustments
 |
 |  DESCRIPTION
 |    This procedure will populate the ar_activity_details for a line level
 |    adjustment and then populate the required GT tables for accting calls
 |    if required.
 |
 |  PARAMETERS:
 |         IN :
 |        OUT :
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  23-AUG-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/
PROCEDURE LLCA_Adjustments(
              p_customer_trx_line_id        IN  NUMBER,
              p_customer_trx_id             IN  NUMBER,
              p_line_adjusted               IN  NUMBER,
              p_tax_adjusted                IN  NUMBER,
              p_adj_id                      IN  NUMBER,
              p_inv_currency_code           IN  VARCHAR2,
              p_gt_id                       IN OUT NOCOPY NUMBER
               );

/*=============================================================================
 |  PROCEDURE  Prorate_tax_Amount
 |
 |  DESCRIPTION
 |    This procedure will prorate the tax adjusted amount (non-recoverable)
 |    over all tax lines which belong to a LINE
 |
 |  PARAMETERS:
 |         IN :
 |        OUT :
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |  24-AUG-2005     Debbie Sue Jancis   Created
 |
 *===========================================================================*/
PROCEDURE Prorate_tax_amount(
              p_customer_trx_line_id        IN  NUMBER,
              p_customer_trx_id             IN  NUMBER,
              p_tax_adjusted                IN  NUMBER,
              p_adjustment_id               IN  NUMBER,
              p_gt_id                       IN  NUMBER,
              p_inv_currency_code           IN  VARCHAR2
                );

END ARP_LLCA_ADJUST_PKG;


 

/
