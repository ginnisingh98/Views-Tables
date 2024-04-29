--------------------------------------------------------
--  DDL for Package Body AP_TAX_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TAX_ENGINE_PKG" as
/* $Header: aptxengb.pls 120.3 2005/10/06 18:13:53 hongliu noship $ */

g_current_runtime_level    NUMBER;
g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--     calculate_tax
--
--  DESCRIPTION
--     This procedure provides an API for calculating tax for a document
--     in Oracle Payables and Oracle Purchasing.
--     This procedure returns calculated tax information including
--     non-recoverable and recoverable tax for a document when
--     a view name and the document header ID or line ID or shipment ID
--     are passed .
--     Used by Oracle Payables and Oracle Purchasing.
--
--     If the Trx Line ID is passed, then Trx Line ID is used ignoring the
--     Trx Header ID passed.
--
--  PARAMETERS
--     p_viewname                   IN  VARCHAR2,
--     p_trx_header_id              IN  NUMBER,
--     p_trx_line_id                IN  NUMBER,
--     p_trx_shipment_id            IN  NUMBER,
--     p_calling_sequence           IN  VARCHAR2,
--     p_tax_info_tbl               IN OUT NOCOPY  AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
--
--  RETURNS
--     A local tax_info_tbl is returned for Purchasing's  requirement.  Also a global
--     PL/SQL table g_tax_info_tbl stores all the tax information.
--
--  HISTORY
--     Fiona Purves       22-OCT-98  Created
--
--     Wei Feng           22-MAR-99  Enhanced
--
--
--     Wei Feng           19-JUL-1999  Fixed bug 927073
--
--        Tax on requisitions should be calculated initially using the
--        transaction currency, using the rounding options, convert into
--        functional currency using the Euro APIs, then store the tax
--        amounts in functional currency.  A new column has been added
--        to the requisition view to show transaction unit price for
--        this purpose.
--
--    Debasis Choudhuri   01-DEC-99 BugFix 1064036
--                                 Using native dynamic SQL.
--    Debasis Choudhuri   02-09-2000 Implement Tax_group and Bug Fix 1076352.
-----------------------------------------------------------------------


PROCEDURE calculate_tax
          (p_viewname             IN  VARCHAR2,
           p_trx_header_id        IN  NUMBER,
           p_trx_line_id          IN  NUMBER,
           p_trx_shipment_id      IN  NUMBER,
           p_calling_sequence     IN  VARCHAR2,
           p_tax_info_tbl         IN OUT NOCOPY tax_info_rec_tbl_type
) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.calculate_tax',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.calculate_tax)');
  END IF;
END calculate_tax;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--     calculate_tax  overloaded
--
--  DESCRIPTION
--     This procedure provides an API for calculating tax for a document
--     in Oracle Payables and Oracle Purchasing.
--     This procedure returns calculated tax information including
--     non-recoverable and recoverable tax for a document when
--     a PL/SQL table and the application name are passed as input
--     parameters.
--     Used by Oracle Payables and Oracle Purchasing.
--
--
--  PARAMETERS
--     p_pdt_tax_info_tbl           IN AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
--     p_application_name           IN VARCHAR2
--     p_tax_info_tbl               IN OUT NOCOPY  AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
--
--  RETURNS
--     A local tax_info_tbl is returned for Purchasing's  requirement.  Also a global
--     PL/SQL table g_tax_info_tbl stores all the tax information.
--
--  HISTORY
--     Prabha Seshadri       15-NOV-02  Created
-----------------------------------------------------------------------
PROCEDURE calculate_tax
          ( p_pdt_tax_info_tbl           IN  AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
          , p_application_name           IN  VARCHAR2
          , p_tax_info_tbl               IN OUT NOCOPY AP_TAX_ENGINE_PKG.tax_info_rec_tbl_type
           )
IS
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.calculate_tax',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.calculate_tax)');
  END IF;
END calculate_tax;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--     copy_record
--
--  DESCRIPTION
--     This procedure is called by calculate_ap_tax, calculate_po_tax,
--     summarize_tax. It copys the passed in PL/SQL record information
--     into PL/SQL tax table.
--
--  PARAMETERS
--     p_tax_info_rec                IN tax_info_rec_type
--     p_calling_sequence            IN  VARCHAR2
--
--  RETURNS
--     None
--
--  HISTORY
--     Fiona Purves, Wei Feng        22-MAR-99  Created
--
--
-----------------------------------------------------------------------

PROCEDURE copy_record ( p_calling_sequence          IN VARCHAR2,
                        p_tax_info_rec              IN tax_info_rec_type
                       ) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.copy_record',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.copy_record)');
  END IF;
END copy_record;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--     initialize_g_tax_info_rec
--
--  DESCRIPTION
--     This procedure is called by calculate_tax.  It initializes each
--     column in g_tax_info_rec to NULL.
--
--  PARAMETERS
--     p_calling_sequence            IN  VARCHAR2
--
--  RETURNS
--     None
--
--  HISTORY
--     Wei Feng                      22-MAR-99  Created
--
--
-----------------------------------------------------------------------

PROCEDURE initialize_g_tax_info_rec ( p_calling_sequence   IN VARCHAR2) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.initialize_g_tax_info_rec',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.initialize_g_tax_info_rec)');
  END IF;
END initialize_g_tax_info_rec;

----------------------------------------------------------------------
--  PUBLIC FUNCTION
--     sum_tax_group_rate
--
--  DESCRIPTION
--     This function is to accumulate the total tax rate and offset tax
--     rate of a tax group.
--
--     This function is called by AP_TAX_LINES_SUMMARY_V in order to
--     provide a solution for multiple taxes inclusive calculation.
--     (bug 989021  and bug 1084978).
--
--     The formula used in the view as follows:
--
--     (dist_amount - dist_amount * sum_tax_group_rate / (sum_tax_group_rate + 100))
--      * (tax_rate/100 +1)
--
--  PARAMETERS
--     p_tax_group_id             IN  NUMBER
--     p_trx_date                 IN  DATE
--     p_vendor_site_id           IN  NUMBER
--
--  RETURNS
--     NUMBER
--
--  HISTORY
--     Wei Feng                      22-NOV-99  Created
--     Wei Feng                      22-NOV-99  Modified
--           Added sel_tax_group_offset_rate to fix bug 1084978:
--           Inclusive multiple tax calculation for offset tax.
--
--
-----------------------------------------------------------------------

FUNCTION sum_tax_group_rate
   (p_tax_group_id     IN  ar_tax_group_codes_all.tax_group_id%TYPE,
    p_trx_date         IN  ap_invoices_all.invoice_date%TYPE,
    p_vendor_site_id   IN  po_vendor_sites_all.vendor_site_id%TYPE
   ) return NUMBER IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.sum_tax_group_rate',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.sum_tax_group_rate)');
  END IF;
END sum_tax_group_rate;

-----------------------------------------------------------------------
--  PUBLIC FUNCTION
--     offset_factor
--
--  DESCRIPTION
--     This function is to calculate the unit price factor due to offset and inclusive
--
--     This function is called by AP_TAX_LINES_SUMMARY_V in order to
--     provide a solution for inclusive tax calculation for tax with offset.
--
--     The formula used in the view as follows:
--
--     dist_amount * factor
--
--  PARAMETERS
--  p_offset_tax_flag	     	IN VARCHAR2,
--  p_amount_includes_tax_flag 	IN VARCHAR2,
--  p_tax_rate			IN NUMBER,
--  p_offset_tax_code_id     	IN NUMBER,
--  p_trx_date         		IN DATE
--
--  RETURNS
--     NUMBER
--
--  HISTORY
--     Helen Si                     18-AUG-04   Created
--
-----------------------------------------------------------------------

FUNCTION offset_factor
   (p_offset_tax_flag	     IN  ap_supplier_sites_all.offset_tax_flag%TYPE,
    p_amount_includes_tax_flag IN ap_invoice_distributions_all.amount_includes_tax_flag%TYPE,
    p_tax_rate		IN ap_tax_codes_all.tax_rate%TYPE,
    p_offset_tax_code_id     IN  ap_tax_codes_all.offset_tax_code_id%TYPE,
    p_trx_date         IN  ap_invoices_all.invoice_date%TYPE
   ) return NUMBER IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.offset_factor',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.offset_factor)');
  END IF;
END offset_factor;

-------------------------------------------------------------------------------
--
--   get_amount
--
--   HISTORY
--     Surekha Myadam                 12-DEC-2001       Created
-------------------------------------------------------------------------------

FUNCTION get_amount( p_invoice_distribution_id     NUMBER,
                     p_line_type_lookup_code       VARCHAR2,
                     p_amount_includes_tax_flag    VARCHAR2,
                     p_amount                      NUMBER ) RETURN NUMBER IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'AP.PLSQL.AP_TAX_ENGINE_PKG.get_amount',
           'Warning - obsolete code being referenced: AP_TAX_ENGINE_PKG.get_amount)');
  END IF;
END get_amount;

-------------------------------------------------------------------------------
--
--   get_system_tax_defaults
--
-------------------------------------------------------------------------------
BEGIN

  NULL;

END AP_TAX_ENGINE_PKG;

/
