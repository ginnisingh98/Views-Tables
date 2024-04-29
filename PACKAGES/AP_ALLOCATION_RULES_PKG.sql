--------------------------------------------------------
--  DDL for Package AP_ALLOCATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ALLOCATION_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: apalocrs.pls 120.5 2004/10/27 01:25:47 pjena noship $ */

/*==========================================================================*/
/*                                                                          */
/* This function may be called to create an associated allocation rule of   */
/* type Fully Prorated (PRORATION) for a given charge (Freight/Misc) line.  */
/* It returns FALSE if an error is encountered, TRUE otherwise.             */
/* The following error codes may be returned via the X_error_code OUT       */
/* parameter:                                                               */
/*  'NO_AUTO_GENERATE_DISTS'  -  Line has flag to generate dists off        */
/*  'LINE_DOES_NOT_EXIST'     -  Line provided does not exist               */
/*  'OTHER_ALLOCATIONS_EXIST' -  Line has other allocation rule associated  */
/*                               with it.                                   */
/*  'COULD_NOT_INSERT_ALLOC_RULE' -  Could not insert allocation rule       */
/*                                                                          */
/*==========================================================================*/

FUNCTION Insert_Fully_Prorated_Rule(
          X_invoice_id          IN         NUMBER,
          X_line_number         IN         NUMBER,
          X_error_code          OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/*==========================================================================*/
/*                                                                          */
/* This function may be called to create an allocation rule and rule lines  */
/* of type Amount Based (AMOUNT) for a given charge (Freight/Misc) line     */
/* given the line group number to find the associated lines to allocate     */
/* across. This function should be used by the Open Interface Import process*/
/* It returns FALSE if an error is encountered, TRUE otherwise.             */
/* The following error codes may be returned via the X_error_code OUT       */
/* parameter:                                                               */
/*  'NO_AUTO_GENERATE_DISTS'  -  Line has flag to generate dists off        */
/*  'LINE_DOES_NOT_EXIST'     -  Line provided does not exist               */
/*  'CANNOT_ALLOCATE_TO_NON_ITEM' - Freight/Misc line is requesting alloca- */
/*                                  tion across another Freight/Misc line   */
/*  'CANNOT_ALLOCATE_ACROSS_ZERO' - Lines to allocate across sum up to zero */
/*                                  making proration impossible.            */
/*  'OTHER_ALLOCATIONS_EXIST' -  Line has other allocation rule associated  */
/*                               with it.                                   */
/*  'COULD_NOT_INSERT_ALLOC_RULE' -  Could not insert allocation rule       */
/*  'COULD_NOT_INSERT_ALLOC_LINES'-  Could not insert allocation rule lines */
/*  'COULD_NOT_PERFORM_ROUNDING'  -  Could not allocate the rounding due    */
/*                                   to proration.                          */
/*                                                                          */
/*==========================================================================*/
FUNCTION Insert_From_Line_Group_Number(
          X_invoice_id          IN         NUMBER,
	  X_line_number         IN         NUMBER,
          X_error_code          OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


/*==========================================================================*/
/*                                                                          */
/* This function may be called to create an allocation rule and rule lines  */
/* of type PERCENTAGE for a given charge (Freight/Misc) line.               */
/*									    */
/*==========================================================================*/
PROCEDURE Insert_Percentage_Alloc_Rule(
	  X_Invoice_id	 	 IN	   NUMBER,
	  X_Chrg_Line_Number     IN	   NUMBER,
	  X_To_Line_Number	 IN	   NUMBER,
	  X_Rule_Generation_Type IN	   VARCHAR2 DEFAULT 'SYSTEM',
	  X_Status		 IN	   VARCHAR2 DEFAULT 'PENDING',
	  X_Percentage		 IN	   NUMBER,
	  X_Calling_Sequence     IN	   VARCHAR2);

------------------------------------------------------------------------------
--  This function is called if the user wants to view the Allocations from
--  the standpoint of ITEM Type of line.
--  This function calls : Create_Proration_Rule for every  charge line
--  with Auto Generate Dists = 'Y' and Match Type <> OTHER_TO_RECEIPT
--  Create Proration Rule when called in this context
--  (Window Context: ALLOCATIONS) creates temporary allocation lines for
--  charge line which do not have a Rule (or have a pending PRORATION rule)
--  associated with them.
--  It returns FALSE if an error is encountered, TRUE otherwise.
--  The following error codes may be returned via the X_error_code OUT
--  parameter:
--  'AP_NO_CHARGES_EXIST'  -  No charge lines exist for this invoice.
--  'AP_GENERATE_DISTS_IS_NO' - Generate Dists Flag is N for this chrg line
--  'AP_NO_ITEM_LINES_AVAIL' - No Item Lines exist or sum total of Item
--                             lines is zero for this Invoice
------------------------------------------------------------------------------
FUNCTION Create_Allocations(
          X_Invoice_id       IN            NUMBER,
          X_Window_context   IN            VARCHAR2,
          X_Error_Code          OUT NOCOPY VARCHAR2,
          X_Debug_Info          OUT NOCOPY VARCHAR2,
          X_Debug_Context       OUT NOCOPY VARCHAR2,
          X_Calling_Sequence IN            VARCHAR2)
RETURN BOOLEAN;

------------------------------------------------------------------------------
-- This function may be called from the following:
--  1. Create_Allocations Function to generate temporary Allocations so
--     that the user can view Allocations from the standpoint of ITEM Line.
--  2. In the WNFI for Allocations Rule Window, to create a default
--     rule of type PRORATION.(If a one doesn't exist)
--  3. When-List-Changed of  Rule Type in the Allocation Rules window. This
--     function re-creates the Proration lines for the Rule Type PRORATION
--  It returns FALSE if an error is encountered, TRUE otherwise.
--  The following error codes may be returned via the X_error_code OUT
--  parameter:
--  'AP_NO_CHARGES_EXIST'  -  No charge lines exist for this invoice.
--  'AP_GENERATE_DISTS_IS_NO' - Generate Dists Flag is N for this chrg line
--  'AP_NO_ITEM_LINES_AVAIL' - No Item Lines exist or sum total of Item
--                             lines is zero for this Invoice
------------------------------------------------------------------------------
FUNCTION Create_Proration_Rule(
          X_invoice_id       IN            NUMBER,
          X_chrg_line_number IN            NUMBER,
          X_rule_type        IN            VARCHAR2,
          X_Window_context   IN            VARCHAR2,
          X_Error_Code          OUT NOCOPY VARCHAR2,
          X_Debug_Info          OUT NOCOPY VARCHAR2,
          X_Debug_Context       OUT NOCOPY VARCHAR2,
          X_calling_sequence IN            VARCHAR2)
RETURN  BOOLEAN;


-----------------------------------------------------------------------
--  This procedure sums up the Allocations lines from the Standpoint of a
--  Item Line. This procedures sums up the Allocations lines from the
--  Allocation_rule_lines table(AMOUNT, PERCENTAGE and Executed PRORATION)
--  UNIONED with the PENDING Proration allocation rule lines from the
--  Global Temporary Table(AP_ALLOCATION_RULE_LINES_GT).
-----------------------------------------------------------------------
PROCEDURE select_item_summary(
           X_Invoice_id               IN             NUMBER,
           X_to_invoice_line_number   IN             NUMBER,
           X_allocated_total          IN OUT NOCOPY  NUMBER,
           X_allocated_total_rtot_db  IN OUT NOCOPY  NUMBER,
           X_calling_sequence         IN      VARCHAR2);


-----------------------------------------------------------------------
-- This function Inserts/Updates/Deletes records
-- in the Ap_allocation_Rule_lines based on the allocation_flag
-- passed to this function via manual allocation for AMOUNT and
-- PERCENTAGE type Rules in the Allocation Rule Window.
------------------------------------------------------------------------
FUNCTION Allocation_Rule_Lines(
          X_Invoice_id               IN            NUMBER,
          X_chrg_invoice_line_number IN            NUMBER,
          X_to_invoice_line_number   IN            NUMBER,
          X_allocated_percentage     IN            NUMBER,
          X_allocated_amount         IN            NUMBER,
          X_allocation_flag          IN            VARCHAR2,
          X_Error_code                  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


------------------------------------------------------------------------
--  This procedure is used to get the setup and invoice information needed
--  by the both the sub-components(Allocation Rules Window and Allocations)
--  of the Allocations Form.
------------------------------------------------------------------------
PROCEDURE form_startup(
           X_invoice_id                    IN         NUMBER,
           X_chart_of_accounts_id          OUT NOCOPY NUMBER,
           X_invoice_date                  OUT NOCOPY DATE,
           X_vendor_type_lookup_code       OUT NOCOPY VARCHAR2,
           X_vendor_name                   OUT NOCOPY VARCHAR2,
           X_invoice_num                   OUT NOCOPY VARCHAR2,
           X_invoice_currency_code         OUT NOCOPY VARCHAR2,
           X_calling_sequence              IN         VARCHAR2);


------------------------------------------------------------------------
--  Table Handler for the AP_ALLOCATION RULES Table for the update of
--  Rule Type.
------------------------------------------------------------------------
Procedure Update_row(
             X_rowid     IN OUT NOCOPY  VARCHAR2,
             X_Invoice_Id               NUMBER,
             X_chrg_invoice_line_number NUMBER,
             X_Rule_Type                VARCHAR2,
             X_Rule_Generation_Type     VARCHAR2,
             X_Status                   VARCHAR2,
             X_last_updated_by          NUMBER,
             X_last_update_date         DATE,
             X_last_update_login        NUMBER,
             X_calling_Sequence         VARCHAR2);


------------------------------------------------------------------------
--  Table Handler for the AP_ALLOCATION RULES Table for the Locking of
--  Allocation Rule associated with the Charge Line.
------------------------------------------------------------------------
Procedure Lock_row(
             X_rowid     IN OUT NOCOPY  VARCHAR2,
             X_Invoice_Id               NUMBER,
             X_chrg_invoice_line_number NUMBER,
             X_Rule_Type                VARCHAR2,
             X_Rule_Generation_Type     VARCHAR2,
             X_Status                   VARCHAR2,
             X_calling_Sequence         VARCHAR2);

--------------------------------------------------------------

------------------------------------------------------------------------------
-- This function is called while updating the Amount for a Charge Line
-- in the Invoice Window of the Invoice Workbench.
-- The function prorates the already allocated allocation lines for the
-- Pending Allocation rule(Amount and Percenatge) with respect to the new
-- Charge Line Amount(Amount <> 0).
-- The function returns TRUE and performs NO Action if the Charge Line
-- does not has an Allocation Rule or the Charge Line has a Pending Rule
-- of type Proration.
--  It returns FALSE if an error is encountered, TRUE otherwise.
--  The following error codes may be returned via the X_error_code OUT
--  parameter:
--  'AP_NO_CHARGES_EXIST'  -  No charge lines exist for this invoice.
--  'AP_GENERATE_DISTS_IS_NO' - Generate Dists Flag is N for this chrg line
--  'AP_NO_ITEM_LINES_AVAIL' - No Item Lines exist or sum total of Item
--                             lines is zero for this Invoice
--  'AP_ALLOC_EXECUTED' -- You cannot make this change because this line's
--                         allocation rule has been executed.
------------------------------------------------------------------------------
FUNCTION Prorate_allocated_lines(
          X_invoice_id        IN            NUMBER,
          X_chrg_line_number  IN            NUMBER,
          X_new_chrg_line_amt IN            NUMBER,
          X_Error_Code           OUT NOCOPY VARCHAR2,
          X_Debug_Info           OUT NOCOPY VARCHAR2,
          X_Debug_Context        OUT NOCOPY VARCHAR2,
          X_calling_sequence  IN            VARCHAR2)
RETURN BOOLEAN;


------------------------------------------------------------------------------
-- This function is called while updating the Amount for a Charge Line to 0
-- in the Invoice Window of the Invoice Workbench.
-- This function
-- The function returns TRUE and performs NO Action if the Charge Line
-- does not has an Allocation Rule or the Charge Line has a Pending Rule
-- of type Proration.
--  It returns FALSE if an error is encountered, TRUE otherwise.
--  The following error codes may be returned via the X_error_code OUT
--  parameter:
--  'AP_NO_CHARGES_EXIST'  -  No charge lines exist for this invoice.
--  'AP_GENERATE_DISTS_IS_NO' - Generate Dists Flag is N for this chrg line
--  'AP_ALLOC_EXECUTED' -- You cannot make this change because this line's
--                         allocation rule has been executed.
------------------------------------------------------------------------------
FUNCTION Delete_Allocations(
          X_invoice_id        IN            NUMBER,
          X_chrg_line_number  IN            NUMBER,
          X_new_chrg_line_amt IN            NUMBER,
          X_Error_Code           OUT NOCOPY VARCHAR2,
          X_Debug_Info           OUT NOCOPY VARCHAR2,
          X_Debug_Context        OUT NOCOPY VARCHAR2,
          X_calling_sequence  IN            VARCHAR2)
RETURN BOOLEAN;


-------------------------------------------------------------------------
-- This Procedure deletes the pending Allocation Rule Lines so
-- that the Rule Lines can be recreated as of the latest snapshot
-- This function is called from the following
--  1.  Whenever the user changes the Rule Type of the Allocation Rule
--  2.  Delete Allocations(Whenever a user updates the charge line amount
--      to 0 in the Invoice Window).
-----------------------------------------------------------------------
PROCEDURE Delete_Allocation_Lines(
           X_invoice_id          IN      NUMBER,
           X_chrg_line_number    IN      NUMBER,
           X_calling_sequence    IN      VARCHAR2);

-------------------------------------------------------------------------
-- This Procedure creates Allocation Rule and Rule Lines for tax lines.
-- It is invoked after tax lines are inserted from the AP eTax utilities
-- package.
-------------------------------------------------------------------------
FUNCTION insert_tax_allocations (
          X_invoice_id          IN         NUMBER,
	  X_chrg_line_number	IN	   NUMBER,
          X_error_code          OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END AP_ALLOCATION_RULES_PKG;

 

/
