--------------------------------------------------------
--  DDL for Package AP_RETRO_PRICING_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_RETRO_PRICING_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: apretrus.pls 120.3.12010000.3 2010/08/19 07:38:32 sbonala ship $ */

/*=============================================================================
 |  FUNCTION - Are_Original_Invoices_Valid()
 |
 |  DESCRIPTION
 |      This function checks for a particular instruction if all the  base
 |  matched Invoices(along with Price Corrections,Qty Corrections) for the
 |  retropriced shipments(Records in AP_INVOICE_LINES_INTERFACE) are valid
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_org_id
 }      p_orig_invoices_valid  --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Are_Original_Invoices_Valid(
             p_instruction_id      IN            NUMBER,
             p_org_id              IN            NUMBER,
             p_orig_invoices_valid    OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Are_Holds_Ok()
 |
 |  DESCRIPTION
 |      This function checks for a particular instruction if all the  base
 |  matched Invoices(along with Price Corrections,Qty Corrections) for the
 |  retropriced shipments(Records in AP_INVOICE_LINES_INTERFACE) has any holds
 |  (other than Price Hold)
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_org_id
 }      p_orig_invoices_valid    --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Are_Holds_Ok(
             p_instruction_id      IN            NUMBER,
             p_org_id              IN            NUMBER,
             p_orig_invoices_valid    OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Is_sequence_assigned
 |
 |  DESCRIPTION
 |      This function checks whether or not a sequence is associated with
 |      a particular document category. Added for the bug5769161.
 |
 |  PARAMETERS
 |
 |      p_document_category_code
 |      p_set_of_books_id
 }      p_is_sequence_assigned    --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  12-MAR-2007 gagrawal            Creation
 |  22-MAY-2009 gagrawal            Changed to input org instead
 |                                  of set of books(bug8514744)
 |
 *============================================================================*/
FUNCTION Is_sequence_assigned(
             p_document_category_code                 IN            VARCHAR2,
             p_org_id                                 IN            NUMBER,
             p_is_sequence_assigned              OUT NOCOPY    VARCHAR2) RETURN BOOLEAN;



/*=============================================================================
 |  FUNCTION - Ppa_Already_Exists()
 |
 |  DESCRIPTION
 |      This function checks if PPA document already exists for a base matched
 |  invoice line that needs to be retropriced. The Adjustment Corrections on the
 |  base matched Invoice doesn't guarentee the existence of a PPA document.
 |  In case multiple PPA document exist for the base matched Invoice then we
 |  select the last PPA document created for reversal.
 |  Note: MAX(invoice_id) insures that we reverse the latest PPA.
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_ppa_exists            --OUT
 |     P_existing_ppa_inv_id   --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Ppa_Already_Exists(
             P_invoice_id          IN            NUMBER,
             P_line_number         IN            NUMBER,
             p_ppa_exists             OUT NOCOPY VARCHAR2,
             P_existing_ppa_inv_id    OUT NOCOPY NUMBER) RETURN BOOLEAN;



/*=============================================================================
 |  FUNCTION - Ipv_Dists_Exists()
 |
 |  DESCRIPTION
 |      This function checks if IPV distributions exist for base matched
 |  Invoice Line(also Price Correction and Qty Correction Lines) for a
 |  retropriced shipment
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_ipv_dists_exist  --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Ipv_Dists_exists(
             p_invoice_id          IN            NUMBER,
             p_line_number         IN            NUMBER,
             p_ipv_dists_exist        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Erv_Dists_Exists()
 |
 |  DESCRIPTION
 |      This function checks if ERV distributions exist for base matched
 |  Invoice Line(also Price Correction and Qty Correction Lines) for a
 |  retropriced shipment. This function is called Compute_IPV_Adjustment_Corr
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_erv_dists_exist    OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Erv_Dists_Exists(
             p_invoice_id          IN            NUMBER,
             p_line_number         IN            NUMBER,
             p_erv_dists_exist        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Adj_Corr_Exists()
 |
 |  DESCRIPTION
 |      This function checks if Adjustment Corrections exist for base matched
 |  Invoice Line(also Price Correction and Qty Correction Lines) for a
 |  retropriced shipment.
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_adj_corr_exists    OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Adj_Corr_Exists(
             p_invoice_id         IN             NUMBER,
             p_line_number        IN             NUMBER,
             p_adj_corr_exists        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Corrections_Exists()
 |
 |  DESCRIPTION
 |      This function returns Price or Qty Corrections Lines for affected base
 |   matched Invoice Line depending upon the line_type_lookup_code passed to the
 |   function
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_adj_corr_exists    OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Corrections_Exists(
             p_invoice_id              IN            NUMBER,
             p_line_number             IN            NUMBER,
             p_match_ype               IN            VARCHAR2,   --p_line_type_lookup_code bug#9573078
             p_lines_list      OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_lines_list_type,
             p_corrections_exist          OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Tipv_Exists()
 |
 |  DESCRIPTION
 |      This function returns all the Tax lines allocated to the base matched
 |  (or Price/Qty Correction) line that is affected by Retropricing. The function
 |  insures that the Tax line has TIPV distribtuions that need to be
 |  Retro-Adjusted.
 |  Note : Only EXCLUSIVE tax is supported for Po matched lines. TIPV distributions
 |         can only exist on the Tax line if the original invoce line(that the tax
 |         line is allocated to) has IPV distributions. Futhermore this check is
 |         only done if original invoice has IPV dists and the Original Invoice
 |         has not been retro-adjusted
 |
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_tax_lines_list   --OUT
 |     p_tipv_exist       --OUT
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
 FUNCTION Tipv_Exists(
             p_invoice_id              IN            NUMBER,
             p_invoice_line_number     IN            NUMBER,
             p_tax_lines_list OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_lines_list_type,
             p_tipv_exist                 OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


 /*=============================================================================
 |  FUNCTION - Terv_Dists_Exists()
 |
 |  DESCRIPTION
 |      This function is called from Compute_TIPV_Adjustment_Corr to check if TERV
 |  distributions exist for Tax line(allocated to a original line for a
 |  retropriced shipment). Furthermore check is only made if the allocated Tax lines
 |  have TIPV distributions.
 |
 |
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_terv_ccid           OUT
 |     p_terv_dists_exist    OUT
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
 FUNCTION Terv_Dists_Exists(
             p_invoice_id              IN            NUMBER,
             p_line_number             IN            NUMBER,
             p_terv_dists_exist           OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Get_Invoice_distribution_id()
 |
 |  DESCRIPTION
 |      This function returns the invoice_distribution_id
 |
 |  PARAMETERS
 |     NONE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Get_Invoice_distribution_id                     RETURN NUMBER;



/*=============================================================================
 |  FUNCTION - Get_Ccid()
 |
 |  DESCRIPTION
 |      This function returns the ccid depending on the Parameter
 |  p_invoice_distribution_id. This function is called in context
 |  of IPV distributions on the base matched line or Price Corrections.
 |  p_invoice_distribution_id
 |  = Related_dist_Id  for the IPV distributions on the base matched line.
 |  = corrected_dist_id   for the IPV distributions on the PC Line.
 |
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION get_ccid(
             p_invoice_distribution_id IN        NUMBER) RETURN NUMBER;


/*=============================================================================
 |  FUNCTION - Get_Dist_Type_lookup_code()
 |
 |  DESCRIPTION
 |      This function returns the Dist_Type_lookup_code depending on the
 |  parameter invoice_distribution_id. This function is called in context
 |  of IPV distributions on the base matched line or Price Corrections.
 |  p_invoice_distribution_id
 |  = Related_dist_Id  for the IPV distributions on the base matched line.
 |  = corrected_dist_id   for the IPV distributions on the PC Line.
 |
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION  Get_Dist_Type_lookup_code(
             p_invoice_distribution_id IN        NUMBER) RETURN VARCHAR2;


/*=============================================================================
 |  FUNCTION - get_max_ppa_line_num()
 |
 |  DESCRIPTION
 |      This function is called to get the max line number for the PPA Document
 |  from the global temp table for a given PPA invoice_id.
 |
 |  PARAMETERS
 |     P_invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION get_max_ppa_line_num(
             P_invoice_id              IN        NUMBER) RETURN NUMBER;


/*=============================================================================
 |  FUNCTION - Get_Exchange_Rate()
 |
 |  DESCRIPTION
 |      This function returns the Exchange rate on the Receipt or PO depending
 |  on the P_match paramter.
 |
 |  PARAMETERS
 |     P_match
 |     p_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION get_exchange_rate(
             P_match                   IN        VARCHAR2,
             p_id                      IN        NUMBER) RETURN NUMBER;


/*============================================================================
 |  FUNCTION - get_invoice_amount()
 |
 |  DESCRIPTION
 |      This function sums the invoice line amounts for the PPA docs created
 |  in the Global temporary tables for a particular invoice.
 |
 |  PARAMETERS
 |     NONE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
--Bugfix:4681253
FUNCTION get_invoice_amount(
             P_invoice_id              IN        NUMBER,
             p_invoice_currency_code   IN        VARCHAR2) RETURN NUMBER;


/*============================================================================
 |  FUNCTION - Get_corresponding_retro_DistId()
 |
 |  DESCRIPTION
 |      This function returns the distribution_id of the corresponding Retro
 |  Expense/Accrual distribution.
 |
 |  PARAMETERS
 |     NONE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Get_corresponding_retro_DistId(
            p_match_type               IN        VARCHAR2,
            p_ccid                     IN        NUMBER) RETURN NUMBER;


/*============================================================================
 |  FUNCTION - Create_Line()
 |
 |  DESCRIPTION
 |      This function is called to create zero amount adjustments lines
 |  for IPV reversals, reversals for existing Po Price Adjustment PPA lines,
 |  and to create Po Price Adjsutment lines w.r.t the Retropriced Amount.
 |
 |  PARAMETERS
 |     p_lines_rec
 |     P_calling_sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Create_Line(
             p_lines_rec    IN   AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
             P_calling_sequence        IN        VARCHAR2) RETURN BOOLEAN;


/*============================================================================
 |  FUNCTION - Get_Base_Match_Lines()
 |
 |  DESCRIPTION
 |      This function returns the list of all base matched Invoice Lines
 |  for the Instruction that are candidate for retropricing.
 |  Note: Retro price Adjustments and Adjustment corrections may already
 |        exist for these base matched lines.
 |
 |  PARAMETERS
 |    p_instruction_id
 |    p_instruction_line_id
 |    p_base_match_lines_list
 |    P_calling_sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Get_Base_Match_Lines(
           p_instruction_id            IN            NUMBER,
           p_instruction_line_id       IN            NUMBER,
           p_base_match_lines_list OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_lines_list_type,
           P_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN;



/*============================================================================
 |  FUNCTION - Create_ppa_Invoice()
 |
 |  DESCRIPTION
 |      This function inserts a temporary Ppa Invoice Header in the Global
 |  Temporary Tables.
 |
 |  PARAMETERS
 |    p_instruction_id
 |    p_instruction_line_id
 |    p_base_match_lines_list
 |    P_calling_sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Create_ppa_Invoice(
             p_instruction_id          IN            NUMBER,
             p_invoice_id              IN            NUMBER,  --Base match line's invoice_id
             p_line_number             IN            NUMBER,  --Base match line's line number
             p_batch_id                IN            NUMBER,
             p_ppa_invoice_rec OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_rec_type,
             P_calling_sequence        IN            VARCHAR2) RETURN BOOLEAN;

/*============================================================================
 |  FUNCTION - get_invoice_num()
 |
 |  DESCRIPTION
 |      This function is called from the APXIIMPT.rdf
 |
 |  PARAMETERS
 |    p_invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION get_invoice_num(
             p_invoice_id               IN            NUMBER) RETURN VARCHAR2;


/*============================================================================
 |  FUNCTION - get_corrected_pc_line_num()
 |
 |  DESCRIPTION
 |      This function is called to get the corrected line number for the
 |  Ajustment Correction Lines on the PPA document.
 |  Note: These lines correct the Zero Line Adjustments Lines for a PC.
 |
 |  PARAMETERS
 |    p_invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION get_corrected_pc_line_num(
             p_invoice_id               IN            NUMBER,
             p_line_number              IN            NUMBER) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION - Get_Erv_Ccid()
 |
 |  DESCRIPTION
 |      This function returns the ccid of the ERV distribution related to the
 |  IPV distribution on the Price Correction and (IPV+Item) distribution
 |  on the base match or qty correction.
 |
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Get_Erv_Ccid(
              p_invoice_distribution_id IN            NUMBER) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION - Get_Terv_Ccid()
 |
 |  DESCRIPTION
 |      This function returns the ccid of the TERV distribution related to the
 |  TIPV distribution.
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Get_Terv_Ccid(
              p_invoice_distribution_id IN            NUMBER) RETURN NUMBER;



END AP_RETRO_PRICING_UTIL_PKG;

/
