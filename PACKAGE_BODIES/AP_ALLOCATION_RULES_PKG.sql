--------------------------------------------------------
--  DDL for Package Body AP_ALLOCATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ALLOCATION_RULES_PKG" as
/* $Header: apalocrb.pls 120.13.12010000.2 2009/01/13 09:29:04 sanjagar ship $ */

-----------------------------------------------------------------------
-- FUNCTION insert_fully_prorated creates an PRORATION type allocation
-- rule given an invoice line of type freight or misc.
-----------------------------------------------------------------------

FUNCTION Insert_Fully_Prorated_Rule(
          X_invoice_id          IN         NUMBER,
          X_line_number         IN         NUMBER,
          X_error_code          OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_other_alloc_rules           NUMBER;
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(200);
BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'AP_ALLOCATION_RULES_PKG.'||
                              'insert_fully_prorated_rule';
  --------------------------------------------------------------
  -- Step 1 - Verify line exists, has generate_dists flag
  -- set to Y
  --------------------------------------------------------------
  BEGIN
    SELECT generate_dists
      INTO l_generate_dists
      FROM ap_invoice_lines
     WHERE invoice_id = X_invoice_id
       AND line_number = X_line_number;

    /* Bug 5131721 */
    IF (nvl(l_generate_dists, 'N') = 'D') THEN
      X_error_code := 'AP_GENERATE_DISTS_IS_NO';
      RETURN(FALSE);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)

          ||', Invoice Line Number = '||TO_CHAR(X_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  --------------------------------------------------------------
  -- Step 2 - Verify no other allocation rules exist for
  -- this line
  --------------------------------------------------------------

  BEGIN
    l_other_alloc_rules := 0;
    SELECT COUNT(*)
      INTO l_other_alloc_rules
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_line_number;

    IF (l_other_alloc_rules <> 0) THEN
      X_error_code := 'AP_ALLOCATIONS_EXIST';
      RETURN(FALSE);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    INSERT INTO ap_allocation_rules(
          invoice_id,
          chrg_invoice_line_number,
          rule_type,
          rule_generation_type,
          status,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
    VALUES(
          X_invoice_id,              -- invoice_id
          X_line_number,             -- chrg_invoice_line_number
          'PRORATION',               -- rule_type
          'SYSTEM',                  -- rule_generation_type
          'PENDING',                 -- status
          SYSDATE,                   -- creation_date
          FND_GLOBAL.USER_ID,        -- created_by
          0,                         -- last_updated_by
          SYSDATE,                   -- last_update_date
          FND_GLOBAL.LOGIN_ID,       -- last_update_login
          FND_GLOBAL.PROG_APPL_ID,   -- program_application_id
          FND_GLOBAL.CONC_PROGRAM_ID,-- program_id
          SYSDATE,                   -- program_update_date
          FND_GLOBAL.CONC_REQUEST_ID -- request_id
           );
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
    END;

  RETURN(TRUE);
END insert_fully_prorated_rule;


-----------------------------------------------------------------------
-- FUNCTION insert_from_line_group_number creates an AMOUNT type
-- allocation rule and rule lines given an invoice line of type
-- freight or misc populated with a line_group_number (Open Interface
-- Import)
-----------------------------------------------------------------------

FUNCTION insert_from_line_group_number (
          X_invoice_id          IN         NUMBER,
          X_line_number         IN         NUMBER,
          X_error_code          OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_line_group_number           AP_INVOICE_LINES.LINE_GROUP_NUMBER%TYPE;
  l_amount_to_prorate           AP_INVOICE_LINES.AMOUNT%TYPE;
  l_total_prorated              AP_INVOICE_LINES.AMOUNT%TYPE;
  l_inv_curr_code               AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_count_non_item_lines        NUMBER := 0;
  l_prorating_total             NUMBER := 0;
  l_other_alloc_rules           NUMBER;
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(200);
BEGIN

  -- Update the calling sequence
  current_calling_sequence := 'AP_ALLOCATION_RULES_PKG.'||
                              'insert_from_prorated_rule';
  --------------------------------------------------------------
  -- Step 1 - Verify line exists, has generate_dists flag
  -- set to Y
  --------------------------------------------------------------
  BEGIN
    SELECT ail.generate_dists,
           ail.line_group_number,
           ail.amount ,     --bug6653070
           ai.invoice_currency_code
      INTO l_generate_dists,
           l_line_group_number,
           l_amount_to_prorate,
           l_inv_curr_code
      FROM ap_invoice_lines ail,
           ap_invoices ai
     WHERE ail.invoice_id = X_invoice_id
       AND ail.line_number = x_line_number
       AND ai.invoice_id = X_invoice_id;

    /* Bug 5131721 */
    IF (nvl(l_generate_dists, 'N') = 'D') THEN
      X_error_code := 'AP_GENERATE_DISTS_IS_NO';
      RETURN(FALSE);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  --------------------------------------------------------------
  -- Step 2 - Verify lines it is to be allocated across are of
  -- type ITEM
  --------------------------------------------------------------
  BEGIN
    SELECT COUNT(*)
      INTO l_count_non_item_lines
      FROM ap_invoice_lines
     WHERE invoice_id = X_invoice_id
       AND line_number <> X_line_number
       AND line_group_number = l_line_group_number
       AND line_type_lookup_code <> 'ITEM';

    IF (l_count_non_item_lines <> 0) THEN
      X_error_code := 'AP_NO_ITEMS_LINES_AVAIL';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------
  -- Step 3 - Verify sum to prorate across is non zero
  --------------------------------------------------------------
  BEGIN
    SELECT SUM(amount)
      INTO l_prorating_total
      FROM ap_invoice_lines
     WHERE invoice_id = X_invoice_id
       AND line_number <> X_line_number
       AND line_group_number = l_line_group_number
       AND line_type_lookup_code = 'ITEM'
       AND nvl(match_type,'NOT_MATCHED') NOT IN
              ('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION');

    IF (l_prorating_total = 0) THEN
      X_error_code := 'AP_NO_ITEMS_LINES_AVAIL';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;


  --------------------------------------------------------------
  -- Step 4 - Verify no other allocation rules exist for
  -- this line
  --------------------------------------------------------------

  BEGIN
    l_other_alloc_rules := 0;
    SELECT COUNT(*)
      INTO l_other_alloc_rules
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_line_number;

    IF (l_other_alloc_rules <> 0) THEN
      X_error_code := 'AP_ALLOCATIONS_EXIST';
      RETURN(FALSE);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;


  --------------------------------------------------------------
  -- Step 5 - Insert Allocation Rule
  --------------------------------------------------------------
  BEGIN
    INSERT INTO ap_allocation_rules(
          invoice_id,
          chrg_invoice_line_number,
          rule_type,
          rule_generation_type,
          status,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
      VALUES(
          X_invoice_id,              -- invoice_id
          X_line_number,             -- chrg_invoice_line_number
          'AMOUNT',                  -- rule_type
          'SYSTEM',                  -- rule_generation_type
          'PENDING',                 -- status
          SYSDATE,                   -- creation_date
          FND_GLOBAL.USER_ID,        -- created_by
          0,                         -- last_updated_by
          SYSDATE,                   -- last_update_date
          FND_GLOBAL.LOGIN_ID,       -- last_update_login
          FND_GLOBAL.PROG_APPL_ID,   -- program_application_id
          FND_GLOBAL.CONC_PROGRAM_ID,-- program_id
          SYSDATE,                   -- program_update_date
          FND_GLOBAL.CONC_REQUEST_ID -- request_id
	     );
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;


  --------------------------------------------------------------
  -- Step 6 - Insert Allocation Rule Lines
  --------------------------------------------------------------
  BEGIN
     INSERT INTO ap_allocation_rule_lines  (
          invoice_id,
          chrg_invoice_line_number,
	  to_invoice_line_number,
          amount,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
     SELECT
          X_invoice_id,              -- invoice_id
	  X_line_number,             -- chrg_invoice_line_number
	  line_number,               -- to_invoice_line_number
          ap_utilities_pkg.ap_round_currency(l_amount_to_prorate * amount /
				     l_prorating_total, l_inv_curr_code),
                                     -- amount
          SYSDATE,                   -- creation_date
          FND_GLOBAL.USER_ID,        -- created_by
          0,                         -- last_updated_by
          SYSDATE,                   -- last_update_date
          FND_GLOBAL.LOGIN_ID,       -- last_update_login
          FND_GLOBAL.PROG_APPL_ID,   -- program_application_id
          FND_GLOBAL.CONC_PROGRAM_ID,-- program_id
          SYSDATE,                   -- program_update_date
	  FND_GLOBAL.CONC_REQUEST_ID -- request_id
       FROM ap_invoice_lines
      WHERE invoice_id = X_invoice_id
        AND line_number <> X_line_number
        AND line_group_number = l_line_group_number
        AND line_type_lookup_code = 'ITEM'
        AND nvl(match_type,'NOT_MATCHED') NOT IN
              ('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION');

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  --------------------------------------------------------------
  -- Step 6 - Verify if there is any rounding and apply it to
  -- max of largest.
  --------------------------------------------------------------
  BEGIN
    SELECT SUM(amount)
      INTO l_total_prorated
      FROM ap_allocation_rule_lines
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_line_number;

    IF (l_amount_to_prorate <> l_total_prorated) THEN
      UPDATE ap_allocation_rule_lines
	 SET amount = amount + (l_amount_to_prorate - l_total_prorated)
       WHERE invoice_id = X_invoice_id
	 AND chrg_invoice_line_number = X_line_number
         AND to_invoice_line_number =
 	                   (SELECT (MAX(ail1.line_number))
                              FROM ap_invoice_lines ail1
                             WHERE ail1.invoice_id = X_invoice_id
			       AND ail1.line_number <> X_line_number
			       AND ail1.amount <> 0
                               AND ail1.line_group_number = l_line_group_number
			       AND ABS(ail1.amount) >=
		                 ( SELECT  MAX(ABS(ail2.amount))
				     FROM  ap_invoice_lines ail2
				    WHERE  ail2.invoice_id = X_invoice_id
				      AND  ail2.line_number <> X_line_number
				      AND  ail2.line_number <> ail1.line_number
				      AND  ail2.line_group_number =
				             l_line_group_number));
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  RETURN(TRUE);
END insert_from_line_group_number;

Procedure Insert_Percentage_Alloc_Rule(
          X_Invoice_id           IN        NUMBER,
	  X_Chrg_Line_Number     IN        NUMBER,
	  X_To_Line_Number       IN        NUMBER,
	  X_Rule_Generation_Type IN        VARCHAR2 DEFAULT 'SYSTEM',
	  X_Status               IN        VARCHAR2 DEFAULT 'PENDING',
	  X_Percentage           IN        NUMBER,
	  X_Calling_Sequence     IN	   VARCHAR2) IS

l_debug_info		VARCHAR2(100);
current_calling_sequence VARCHAR2(2000);
BEGIN

   current_calling_sequence := 'Insert_Percentage_Alloc_Rule<-'||X_Calling_Sequence;

   l_debug_info := 'Insert record into AP_ALLOCATION_RULES';

   Insert into AP_ALLOCATION_RULES
            (Invoice_id,
	     Chrg_Invoice_Line_Number,
	     Rule_Type,
	     Rule_Generation_Type,
	     Status,
	     Creation_Date,
	     Created_By,
             Last_Updated_By,
             Last_Update_Date,
             Last_Update_Login,
             Program_Application_Id,
             Program_Id,
             Program_Update_Date,
             Request_Id)
      values(x_invoice_id,
             x_chrg_line_number,
	     'PERCENTAGE',
	     x_rule_generation_type,
	     x_status,
	     sysdate,
	     fnd_global.user_id,
	     fnd_global.user_id,
	     sysdate,
	     fnd_global.login_id,
	     NULL,
	     NULL,
	     NULL,
	     NULL);


      l_debug_info := 'Inserting record into AP_ALLOCATION_RULE_LINES';

      Insert Into ap_allocation_rule_lines (
      		Invoice_id,
                chrg_invoice_line_number,
	        to_invoice_line_number,
	        percentage,
	        amount,
	        creation_date,
	        created_by,
	        last_updated_by,
	        last_update_date,
	        last_update_login,
	        program_application_id,
	        program_id,
	        program_update_date,
	        request_id)
	  values(x_invoice_id,
	         x_chrg_line_number,
	         x_to_line_number,
	         x_percentage,
	         NULL,
	         sysdate,
	         fnd_global.user_id,
	         fnd_global.user_id,
	         sysdate,
	         fnd_global.login_id,
	         NULL,
	         NULL,
	         NULL,
	         NULL);

EXCEPTION
 WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_Invoice_Id)
	        ||', Chrg Invoice Line Number = '||TO_CHAR(X_Chrg_Line_Number)
	        ||', To Invoice Line Number = '||TO_CHAR(X_To_Line_Number)
		||', Rule Generation Type = '||x_rule_generation_type
		||', Percentage = '||TO_CHAR(x_percentage)
		||', Status = '||x_status);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Percentage_Alloc_Rule;



---------------------------------------------------------------------------
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
--  'AP_NO_ITEMS_LINES_AVAIL' - No Item Lines exist or sum total of Item
--                             lines is zero for this Invoice
----------------------------------------------------------------------------
FUNCTION Create_Allocations(
              X_Invoice_id       IN            NUMBER,
              X_Window_context   IN            VARCHAR2,
              X_Error_Code          OUT NOCOPY VARCHAR2,
              X_Debug_Info          OUT NOCOPY VARCHAR2,
              X_Debug_Context       OUT NOCOPY VARCHAR2,
              X_Calling_Sequence IN            VARCHAR2) RETURN BOOLEAN

IS

 CURSOR chrg_lines_cur IS
 SELECT invoice_id,
        line_number
   FROM ap_invoice_lines
  WHERE line_type_lookup_code in ('FREIGHT', 'MISCELLANEOUS')
    AND generate_dists <> 'D' -- Bug 5131721
    AND NVL(match_type, 'NOT_MATCHED') <> 'OTHER_TO_RECEIPT'
    AND invoice_id = X_invoice_id
ORDER BY line_number;

l_chrg_lines_count         BINARY_INTEGER := 0;
l_invoice_id               AP_INVOICE_LINES_ALL.Invoice_Id%TYPE;
l_chrg_line_number         AP_INVOICE_LINES_ALL.line_number%TYPE;
l_error_code               VARCHAR2(30);
debug_info                 VARCHAR2(200);
debug_context              VARCHAR2(2000);
current_calling_sequence   VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  current_calling_sequence := 'Ap_Allocation_Rules_Pkg.'||
                              'Create_Allocations';

  --------------------------------------------------------------
  debug_info := ' Step 1 - Verify IF any chrg line exists for '
                ||'this Invoice';
  --------------------------------------------------------------
  BEGIN

    SELECT COUNT(*)
      INTO l_chrg_lines_count
     FROM ap_invoice_lines
    WHERE line_type_lookup_code in ('FREIGHT', 'MISCELLANEOUS', 'TAX')
      AND generate_dists <> 'D' -- Bug 5131721
      AND NVL(match_type, 'NOT_MATCHED') <> 'OTHER_TO_RECEIPT'
      AND invoice_id = X_invoice_id;

    IF (l_chrg_lines_count =  0) THEN
      X_error_code := 'AP_NO_CHARGES_EXIST';
      RETURN(FALSE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------
  debug_info := ' Step 2 - For all  Freight/Misc lines '
  ||' create  allocation rule.';
  -- of TYPE Proration if one does
  -- not exist. Prorate the chrg line accross all item lines
  --------------------------------------------------------------

  OPEN chrg_lines_cur;
  LOOP
    FETCH chrg_lines_cur
     INTO l_invoice_id,
          l_chrg_line_number;

  EXIT WHEN chrg_lines_cur%NOTFOUND;

   IF (NOT  (Ap_Allocation_Rules_Pkg.Create_Proration_Rule(
               l_invoice_id,
               l_chrg_line_number,
               NULL,                     --     rule_type
               X_Window_context,         --
               l_error_code,             --     OUT
               Debug_Info,               --     OUT
               Debug_Context,            --     OUT
               current_calling_sequence  --  IN
              )))  THEN

     IF (l_error_code IS NOT NULL) THEN
        X_error_code := l_error_code;
        CLOSE chrg_lines_cur;
        RETURN (FALSE);
     ELSE
        CLOSE chrg_lines_cur;
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        RETURN (FALSE);
     END IF;
  END IF;

  END LOOP;
  CLOSE chrg_lines_cur;
  RETURN(TRUE);
END Create_Allocations;


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
--  'AP_NO_ITEMS_LINES_AVAIL' - No Item Lines exist or sum total of Item
--                             lines is zero for this Invoice
------------------------------------------------------------------------------
FUNCTION Create_Proration_Rule(
          X_invoice_id        IN            NUMBER,
          X_chrg_line_number  IN            NUMBER,
          X_rule_type         IN            VARCHAR2,
          X_window_context    IN            VARCHAR2,
          X_Error_Code           OUT NOCOPY VARCHAR2,
          X_Debug_Info           OUT NOCOPY VARCHAR2,
          X_Debug_Context        OUT NOCOPY VARCHAR2,
          X_calling_sequence  IN            VARCHAR2)
RETURN  BOOLEAN IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_alloc_rule                  NUMBER;
  l_alloc_rule_lines            NUMBER;
  l_amount_to_prorate           AP_INVOICE_LINES.AMOUNT%TYPE;
  l_total_prorated              AP_INVOICE_LINES.AMOUNT%TYPE;
  l_inv_curr_code               AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_rule_type                   AP_ALLOCATION_RULES.RULE_TYPE%TYPE;
  l_rule_status                 AP_ALLOCATION_RULES.STATUS%TYPE;
  l_prorating_total             NUMBER := 0;
  l_create_alloc_rule           VARCHAR2(1) := 'Y';
  l_create_alloc_rule_lines     VARCHAR2(1) := 'Y';

  debug_info                    VARCHAR2(200);
  debug_context                 VARCHAR2(2000);
  current_calling_sequence      VARCHAR2(2000);

BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'Ap_Allocation_Rules_Pkg.'||
                              'Create_Proration_Rule';
  --------------------------------------------------------------
  debug_info := ' Step 1 - Verify IF any chrg line exists for '
                ||'this Invoice';
  --------------------------------------------------------------
  BEGIN
    SELECT ail.generate_dists,
           ail.amount,   --bug6653070
           ai.invoice_currency_code
      INTO l_generate_dists,
           l_amount_to_prorate,
           l_inv_curr_code
      FROM ap_invoice_lines ail,
           ap_invoices ai
     WHERE ail.invoice_id = X_invoice_id
       AND ail.line_number = x_chrg_line_number
       AND ai.invoice_id = X_invoice_id;

    /* Bug 5131721 */
    IF (nvl(l_generate_dists, 'N') = 'D') THEN
      X_error_code := 'AP_GENERATE_DISTS_IS_NO';
      RETURN(FALSE);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_error_code := 'AP_NO_CHARGES_EXIST';
      RETURN(FALSE);
    WHEN OTHERS THEN
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_chrg_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN(FALSE);
  END;

  --------------------------------------------------------------
  debug_info := ' Step 2 - Verify IF the  allocation rule exist '
  ||'this chrg line.';
  --------------------------------------------------------------
  BEGIN

    l_create_alloc_rule := 'Y';
    l_alloc_rule := 0;
    SELECT COUNT(*)
      INTO l_alloc_rule
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_chrg_line_number;

    IF (l_alloc_rule <> 0) THEN
       l_create_alloc_rule := 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;


  --------------------------------------------------------------
  debug_info := ' Step 3 -  IF the  allocation rules exist then '
  ||'determine the Status and Rule type.';
  -- associated with the charge line
  --------------------------------------------------------------
  IF l_create_alloc_rule = 'N'  then

    BEGIN
      SELECT rule_type,
             status
        INTO l_rule_type,
             l_rule_status
        FROM ap_allocation_rules
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_chrg_line_number;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF l_rule_status = 'EXECUTED' THEN
       RETURN(TRUE);
    END IF;

    -- X_Rule_type is not NULL when create_proration_rule is
    -- called from WHEN-LIST-CHANGED in Allocation Rules Window
    IF (X_rule_type is NOT NULL ) then
      l_rule_type := X_rule_type;
    END IF;

    IF l_rule_type <> 'PRORATION' then
       RETURN(TRUE);
    END IF;

  ELSE --Allocation Rule does not exists.

    l_rule_type := 'PRORATION';
    l_rule_status := 'PENDING';

  END IF;

  --------------------------------------------------------------
  -- IF allocation rule lines exist for  this chrg line and the
  -- Rule_type is PRORATION
  debug_info := 'Step 4 - Recreate the Allocation Rule Lines '
  ||'after deleting the existing ones.';
  --------------------------------------------------------------
  IF l_create_alloc_rule = 'N' AND l_rule_status = 'PENDING' THEN

    BEGIN
      l_alloc_rule_lines := 0;
      SELECT COUNT(*)
        INTO l_alloc_rule_lines
        FROM ap_allocation_rule_lines
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_chrg_line_number;

      IF (l_rule_type ='PRORATION') THEN
        l_create_alloc_rule_lines := 'Y';
        IF l_alloc_rule_lines <> 0 then
          Ap_Allocation_Rules_Pkg.delete_allocation_lines(
                              X_invoice_id,
                              X_chrg_Line_number,
                              'Insert_fully_prorated_rule');
        END IF;
      ELSE
        l_create_alloc_rule_lines := 'N';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END IF;


  -----------------------------------------------------------------
  debug_info := ' Step 5 - Verify sum to prorate across is non zero';
  -----------------------------------------------------------------
  IF  l_create_alloc_rule_lines = 'Y' AND
      l_rule_status = 'PENDING'  then

    BEGIN
      SELECT SUM(amount)
        INTO l_prorating_total
        FROM ap_invoice_lines
       WHERE invoice_id = X_invoice_id
         AND line_number <> X_chrg_line_number
         AND line_type_lookup_code = 'ITEM'
         AND nvl(match_type,'NOT_MATCHED') NOT IN
              ('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION');

      IF (l_prorating_total = 0) THEN
        X_error_code := 'AP_NO_ITEMS_LINES_AVAIL';   --7191037
        RETURN(FALSE);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;

  END IF;

  --------------------------------------------------------------
  debug_info := ' Step 6  - Create Allocation Rule.';
  --------------------------------------------------------------
 IF l_create_alloc_rule = 'Y' AND
    X_window_context <> 'ALLOCATIONS' THEN
    BEGIN
      INSERT INTO ap_allocation_rules(
          invoice_id,
          chrg_invoice_line_number,
          rule_type,
          rule_generation_type,
          status,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
      VALUES(
          X_invoice_id,          -- invoice_id
          X_chrg_line_number,    -- chrg_invoice_line_number
          'PRORATION',           -- rule_type
          'USER',                -- rule_generation_type
          'PENDING',             -- status
          SYSDATE,               -- creation_date
          FND_GLOBAL.USER_ID,    -- created_by
          0,                     -- last_updated_by
          SYSDATE,               -- last_update_date
          FND_GLOBAL.LOGIN_ID,   -- last_update_login
          NULL,                  -- program_application_id
          NULL,                  -- program_id
          SYSDATE,               -- program_update_date
          NULL                   -- request_id
           );
    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                                 current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '
            ||to_char(X_Invoice_ID)
            ||', Invoice Line Number = '||to_char(X_chrg_Line_Number));
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END;
  END IF;

  -------------------------------------------------------------
  debug_info := ' Step 7 - Create  Allocation Rule Lines for '
                  ||'PRORATION.';
  -- Allocation Rule Lines for Rule Type are not saved unless
  -- the Allocation Rule has been EXECUTED.
  -- A latest snapshot of PRORATION Rules is generated evertime
  -- for the current state of the Invoice.
  --------------------------------------------------------------
  IF l_create_alloc_rule_lines = 'Y' AND
     l_rule_status = 'PENDING' THEN

    IF X_window_context = 'ALLOCATIONS' then

      BEGIN
        INSERT INTO ap_allocation_rule_lines_gt(
          invoice_id,
          chrg_invoice_line_number,
	  to_invoice_line_number,
          amount,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
        SELECT
          X_invoice_id,        -- invoice_id
	  X_chrg_line_number,  -- chrg_invoice_line_number
	  line_number,         -- to_invoice_line_number
          ap_utilities_pkg.ap_round_currency(l_amount_to_prorate * amount /
				     l_prorating_total, l_inv_curr_code),
                               -- amount
          SYSDATE,             -- creation_date
          FND_GLOBAL.USER_ID,  -- created_by
          0,                   -- last_updated_by
          SYSDATE,             -- last_update_date
          FND_GLOBAL.LOGIN_ID, -- last_update_login
          NULL,                -- program_application_id
          NULL,                -- program_id
          SYSDATE,             -- program_update_date
	  NULL                 -- request_id
         FROM ap_invoice_lines
        WHERE invoice_id = X_invoice_id
          AND line_number <> X_chrg_line_number
          AND line_type_lookup_code = 'ITEM'
          AND nvl(match_type,'NOT_MATCHED') NOT IN
              ('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION');
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                                   current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '
                          ||to_char(X_Invoice_ID)
                          ||', Invoice Line Number = '
                          ||to_char(X_chrg_Line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;

    ELSE

      BEGIN
        INSERT INTO ap_allocation_rule_lines(
          invoice_id,
          chrg_invoice_line_number,
	  to_invoice_line_number,
          amount,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
        SELECT
          X_invoice_id,        -- invoice_id
	  X_chrg_line_number,  -- chrg_invoice_line_number
	  line_number,         -- to_invoice_line_number
          ap_utilities_pkg.ap_round_currency(l_amount_to_prorate * amount /
				     l_prorating_total, l_inv_curr_code),
                               -- amount
          SYSDATE,             -- creation_date
          FND_GLOBAL.USER_ID,  -- created_by
          0,                   -- last_updated_by
          SYSDATE,             -- last_update_date
          FND_GLOBAL.LOGIN_ID, -- last_update_login
          NULL,                -- program_application_id
          NULL,                -- program_id
          SYSDATE,             -- program_update_date
	  NULL                 -- request_id
        FROM ap_invoice_lines
       WHERE invoice_id = X_invoice_id
         AND line_number <> X_chrg_line_number
         AND line_type_lookup_code = 'ITEM'
         AND nvl(match_type,'NOT_MATCHED') NOT IN
              ('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION');

      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                                   current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '
                                 ||to_char(X_Invoice_ID)
                                 ||', Invoice Line Number = '
                                 ||to_char(X_chrg_Line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
    END IF;
  END IF;

  --------------------------------------------------------------
  debug_info := 'Step 8 - Verify if there is any rounding and '
                ||' apply it to max of largest.';
  --------------------------------------------------------------
  IF l_create_alloc_rule_lines = 'Y' then
    IF X_window_context = 'ALLOCATIONS' then
      BEGIN
        SELECT SUM(amount)
          INTO l_total_prorated
          FROM ap_allocation_rule_lines_gt
         WHERE invoice_id = X_invoice_id
           AND chrg_invoice_line_number = X_chrg_line_number;

        IF (l_amount_to_prorate <> l_total_prorated) THEN
          UPDATE ap_allocation_rule_lines_gt
             SET amount = amount + (l_amount_to_prorate - l_total_prorated)
           WHERE invoice_id = X_invoice_id
	     AND chrg_invoice_line_number = X_chrg_line_number
             AND to_invoice_line_number =
 	             (SELECT (MAX(ail1.line_number))
                        FROM ap_invoice_lines ail1
                       WHERE ail1.invoice_id = X_invoice_id
	                 AND ail1.line_number <> X_chrg_line_number
		         AND ail1.amount <> 0
		         AND ABS(ail1.amount) >=
		            ( SELECT  MAX(ABS(ail2.amount))
		                FROM  ap_invoice_lines ail2
			       WHERE  ail2.invoice_id = X_invoice_id
			         AND  ail2.line_number <> X_chrg_line_number
			         AND  ail2.line_number <> ail1.line_number
			     )
                      );
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id ='
                  ||to_char(X_Invoice_ID)
                  ||', Invoice Line Number = '||to_char(X_chrg_Line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;
    ELSE
      BEGIN
        SELECT SUM(amount)
          INTO l_total_prorated
          FROM ap_allocation_rule_lines
         WHERE invoice_id = X_invoice_id
           AND chrg_invoice_line_number = X_chrg_line_number;

        IF (l_amount_to_prorate <> l_total_prorated) THEN
          UPDATE ap_allocation_rule_lines
             SET amount = amount + (l_amount_to_prorate - l_total_prorated)
           WHERE invoice_id = X_invoice_id
	     AND chrg_invoice_line_number = X_chrg_line_number
             AND to_invoice_line_number =
 	           (SELECT (MAX(ail1.line_number))
                      FROM ap_invoice_lines ail1
                     WHERE ail1.invoice_id = X_invoice_id
	               AND ail1.line_number <> X_chrg_line_number
		       AND ail1.amount <> 0
		       AND ABS(ail1.amount) >=
		           ( SELECT MAX(ABS(ail2.amount))
		               FROM ap_invoice_lines ail2
			      WHERE ail2.invoice_id = X_invoice_id
			        AND ail2.line_number <> X_chrg_line_number
			        AND ail2.line_number <> ail1.line_number
		            ));

        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '
                ||to_char(X_Invoice_ID)
                ||', Invoice Line Number = '||to_char(X_chrg_Line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;
    END IF;
  END IF;


  RETURN(TRUE);

END Create_Proration_rule;




-----------------------------------------------------------------------
--  This procedure sums up the Allocations lines from the Standpoint of a
--  Item Line. This procedures sums up the Allocations lines from the
--  Allocation_rule_lines table(AMOUNT, PERCENTAGE and Executed PRORATION)
--  UNIONED with the PENDING Proration allocation rule lines from the
--  Global Temporary Table(AP_ALLOCATION_RULE_LINES_GT).
-----------------------------------------------------------------------
PROCEDURE Select_Item_Summary(
        X_Invoice_id               IN            NUMBER,
        X_to_invoice_line_number   IN            NUMBER,
        X_allocated_total          IN OUT NOCOPY NUMBER,
        X_allocated_total_rtot_db  IN OUT NOCOPY NUMBER,
        X_calling_sequence         IN            VARCHAR2) IS

current_calling_sequence     VARCHAR2(2000);
debug_info                   VARCHAR2(100);
l_allocated_total            NUMBER := 0;
l_allocated_total_rtot_db    NUMBER := 0;
l_allocated_total_gt         NUMBER := 0;
l_allocated_total_gt_rtot_db NUMBER := 0;
--

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
       'Ap_Allocation_Rules_Pkg.select_Item_summary<-'||X_Calling_Sequence;
  ----------------------------------------------------------
  debug_info := 'Get allocated total';
  ----------------------------------------------------------

  SELECT nvl(sum(amount), 0), nvl(sum(amount), 0)
  INTO   l_allocated_total, l_allocated_total_rtot_db
  FROM   ap_allocation_rule_lines
  WHERE  invoice_id = X_invoice_id
  AND    to_invoice_line_number = X_to_invoice_line_number;


  ----------------------------------------------------------
  debug_info := 'Get allocated total from the GT Table';
  ----------------------------------------------------------
  SELECT nvl(sum(amount), 0), nvl(sum(amount), 0)
  INTO   l_allocated_total_gt, l_allocated_total_gt_rtot_db
  FROM   ap_allocation_rule_lines_gt
  WHERE  invoice_id = X_invoice_id
  AND    to_invoice_line_number = X_to_invoice_line_number;

  X_allocated_total := l_allocated_total + l_allocated_total_gt;
  X_allocated_total_rtot_db := l_allocated_total_rtot_db +
                                    l_allocated_total_gt_rtot_db;

EXCEPTION
     WHEN OTHERS THEN
      IF (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'X_invoice_id ='||to_char(X_invoice_id)
                || ' X_allocated_total (OUT) ='||to_char(X_allocated_total)
                || ' X_allocated_total_rtot_db (OUT) ='
                ||to_char(X_allocated_total_rtot_db));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

END Select_Item_Summary;


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
   X_Error_code                  OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_alloc_rule_line             NUMBER;

  debug_info                    VARCHAR2(100);
  current_calling_sequence      VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  current_calling_sequence := 'Ap_Allocation_Rules_Pkg.'||
                              'Allocation_Rule_Lines';

  --------------------------------------------------------------
  debug_info := ' Step 1 - Verify IF allocation rule line exists';
  --  i.e. chrg line is allocated to the Item Line.'
  --------------------------------------------------------------

  BEGIN
    l_alloc_rule_line := 0;
    SELECT COUNT(*)
      INTO l_alloc_rule_line
      FROM ap_allocation_rule_lines
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_chrg_invoice_line_number
       AND to_invoice_line_number = X_to_invoice_line_number;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------
  -- IF the allocation line does not exists
  --  and IF the X_allocation_flag is Y
  debug_info := ' Step 2 - Insert the allocation rule line.';
  --------------------------------------------------------------
  IF  l_alloc_rule_line =  0 then

     IF X_allocation_flag = 'Y' then
       BEGIN
         INSERT INTO ap_allocation_rule_Lines(
            invoice_id,
            chrg_invoice_line_number,
            to_invoice_line_number,
            percentage,
            amount,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id)
         VALUES(
            X_invoice_id,               -- invoice_id
            X_chrg_invoice_line_number, -- chrg_invoice_line_number
            X_to_invoice_line_number,   -- to_invoice_line_number
            X_allocated_percentage,     -- percentage
            X_allocated_Amount,         -- amount
            SYSDATE,                    -- creation_date
            FND_GLOBAL.USER_ID,         -- created_by
            SYSDATE,                    -- last_update_date
            FND_GLOBAL.USER_ID,         -- last_updated_by
            FND_GLOBAL.LOGIN_ID,        -- last_update_login
            NULL,                       -- program_application_id
            NULL,                       -- program_id
            NULL,                       -- program_update_date
            NULL                        -- request_id
                 );
       EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                                    current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '
                ||to_char(X_Invoice_ID) ||', Invoice Line Number = '
                ||to_char(X_chrg_Invoice_Line_Number));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
       END;

     END IF; --Allocation_flag

  END IF;

  --------------------------------------------------------------
  -- IF the allocation line exists
  --  and IF the Allocation_flag is N
  debug_info := ' Step 3 -Delete the allocation rule line. ';
  --------------------------------------------------------------
  IF l_alloc_rule_line <> 0 THEN

     IF X_allocation_flag = 'N' then
        BEGIN
          DELETE FROM ap_allocation_rule_lines
           WHERE invoice_id = X_invoice_id
             AND chrg_invoice_line_number = X_chrg_invoice_line_number
             AND to_invoice_line_number = X_to_invoice_line_number;

          RETURN(TRUE);
         EXCEPTION
            WHEN OTHERS THEN
              IF (SQLCODE <> -20001) THEN
                 X_error_code := 'COULD_NOT_INSERT_ALLOC_RULE';
                 FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                 FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
                 FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
                 FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||to_char(X_Invoice_ID)
                      ||', Invoice Line Number = '||to_char(X_chrg_Invoice_Line_Number));
                 FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
              END IF;
              APP_EXCEPTION.RAISE_EXCEPTION;
         END;

      END IF;
  END IF;

  --------------------------------------------------------------
  -- IF the allocation line exists
  -- and   IF the Allocation_flag is Y
  debug_info := ' Step 4 - Update the allocation rule line ';
  --------------------------------------------------------------
  IF l_alloc_rule_line <> 0 THEN

     IF X_allocation_flag = 'Y' then
         BEGIN
           UPDATE ap_allocation_rule_lines
              SET Amount = X_allocated_AMount,
                  percentage = X_allocated_percentage,
                  last_update_date = SYSDATE,
                  last_updated_by = FND_GLOBAL.user_id,
                  last_update_login = FND_GLOBAL.login_id
            WHERE invoice_id = X_invoice_id
              AND chrg_invoice_line_number = X_chrg_invoice_line_number
              AND to_invoice_line_number = X_to_invoice_line_number;

           RETURN(TRUE);

         EXCEPTION
            WHEN OTHERS THEN
              IF (SQLCODE <> -20001) THEN
                 X_error_code := 'COULD_NOT_INSERT_ALLOC_RULE';
                     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
                     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
                     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||to_char(X_Invoice_ID)
                        ||', Invoice Line Number = '||to_char(X_chrg_Invoice_Line_Number));
                     FND_MESSAGE.SET_TOKEN('DEBUG_INFO','Inserting Allocation Rule Lines');
             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;
         END;
       END IF; -- allocaton_flag

  END IF; -- If other rule line exists

  RETURN(TRUE);

END Allocation_Rule_Lines;


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
           X_calling_sequence              IN         VARCHAR2) IS

l_org_id		 NUMBER;
current_calling_sequence VARCHAR2(2000);
debug_info               VARCHAR2(100);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
       'Ap_Allocation_Rules_Pkg.form_startup<-'||X_Calling_Sequence;

  --------------------------------------------------------------
  debug_info := 'Get invoice information';
  --------------------------------------------------------------
  SELECT ai.invoice_date,
         pv.vendor_type_lookup_code,
         pv.vendor_name,
         ai.invoice_num,
         ai.invoice_currency_code,
	 ai.org_id
  INTO   X_invoice_date,
         X_vendor_type_lookup_code,
         X_vendor_name,
         X_invoice_num,
         X_invoice_currency_code,
	 l_org_id
  FROM   ap_invoices ai, po_vendors pv
  WHERE  ai.invoice_id = X_invoice_id
  AND    ai.vendor_id = pv.vendor_id;


  --------------------------------------------------------------
  debug_info := 'Get chart of accounts';
  --------------------------------------------------------------
  SELECT gl.chart_of_accounts_id
  INTO   X_chart_of_accounts_id
  FROM   ap_system_parameters ap,
         gl_sets_of_books gl
  WHERE  gl.set_of_books_id = ap.set_of_books_id
  AND    ap.org_id = l_org_id;

EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'X_invoiceid ='||to_char(X_invoice_id));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

END form_startup;


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
             X_calling_Sequence         VARCHAR2) IS

current_calling_sequence VARCHAR2(2000);
debug_info               VARCHAR2(100);

BEGIN

current_calling_sequence := 'Ap_Allocation_Rules_Pkg.Update_Row<-'
                              ||X_Calling_Sequence;

  -- Check for uniqueness of the lineine number


  --------------------------------------------------------------
  debug_info := 'Update ap_allocation_rules';
  --------------------------------------------------------------

  UPDATE ap_allocation_rules
     SET invoice_id               = X_invoice_id,
         chrg_invoice_line_number = X_chrg_invoice_line_number,
         rule_type                = X_rule_type,
         rule_generation_type     = X_rule_generation_type,
         status                   = X_status,
         last_updated_by          = X_last_updated_by,
         last_update_date         = X_last_update_Date,
         last_update_login        = X_last_update_login
   WHERE rowid   = X_rowid;

  IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END;



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
             X_calling_Sequence         VARCHAR2)
IS

  CURSOR C IS
        SELECT *
        FROM   AP_ALLOCATION_RULES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Invoice_Id NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);


BEGIN
 -- Update the calling sequence
  --
  current_calling_sequence := 'Ap_Allocation_Rules_Pkg.Lock_Row<-'
                             ||X_Calling_Sequence;

  --------------------------------------------------------------
  debug_info := 'Select from ap_allocation_rules';
  --------------------------------------------------------------

  OPEN C;

  --------------------------------------------------------------
  debug_info := 'Fetch cursor C';
  --------------------------------------------------------------
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    debug_info := 'Close cursor C - ROW NOTFOUND';
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  --------------------------------------------------------------
  debug_info := 'Close cursor C';
  --------------------------------------------------------------
  CLOSE C;

  IF (
          (Recinfo.invoice_id =  X_Invoice_Id)
      AND (   (Recinfo.chrg_invoice_line_number =
                          X_chrg_invoice_line_number)
                OR (    (Recinfo.chrg_invoice_line_number IS NULL)
                    AND (X_chrg_invoice_line_number IS NULL)))
      AND (   (Recinfo.rule_type =
                          X_rule_type)
                OR (    (Recinfo.rule_type IS NULL)
                    AND (X_rule_type IS NULL)))
      AND (   (Recinfo.rule_generation_type =
                          X_Rule_generation_type)
                OR (    (Recinfo.Rule_generation_type IS NULL)
                    AND (X_rule_generation_type IS NULL)))
       AND (   (Recinfo.status =
                          X_status)
                OR (    (Recinfo.status IS NULL)
                    AND (X_status IS NULL)))

 ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
              ', INVOICE_ID == ' ||TO_CHAR(X_Invoice_Id));
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

END Lock_Row;

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
--  'AP_NO_ITEMS_LINES_AVAIL' - No Item Lines exist or sum total of Item
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
RETURN  BOOLEAN IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_alloc_rule                  NUMBER;
  l_amount_to_prorate           AP_INVOICE_LINES.AMOUNT%TYPE;
  l_total_prorated              AP_INVOICE_LINES.AMOUNT%TYPE;
  l_inv_curr_code               AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_rule_type                   AP_ALLOCATION_RULES.RULE_TYPE%TYPE;
  l_rule_status                 AP_ALLOCATION_RULES.STATUS%TYPE;
  l_prorating_total             NUMBER := 0;
  l_prorated_total              NUMBER := 0;

  debug_info                    VARCHAR2(100);
  debug_context                 VARCHAR2(2000);
  current_calling_sequence      VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
 current_calling_sequence := 'Ap_Allocation_Rules_Pkg.'||
                              'Prorate_allocated_lines';
  --------------------------------------------------------------
  debug_info := 'Step 1 - Verify chrg line exists, has '
                ||' generate_dists flag set to Y';
  --------------------------------------------------------------
  BEGIN
    SELECT ail.generate_dists,
           X_new_chrg_line_amt,    --bug6653070
           ai.invoice_currency_code
      INTO l_generate_dists,
           l_amount_to_prorate,
           l_inv_curr_code
      FROM ap_invoice_lines ail,
           ap_invoices ai
     WHERE ail.invoice_id = X_invoice_id
       AND ail.line_number = x_chrg_line_number
       AND ai.invoice_id = X_invoice_id;

    /* Bug 5131721 */
    IF (nvl(l_generate_dists, 'N') = 'D') THEN
      X_error_code := 'AP_GENERATE_DISTS_IS_NO';
      RETURN(FALSE);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_error_code := 'AP_NO_CHARGES_EXIST';
      RETURN(FALSE);
    WHEN OTHERS THEN

      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_chrg_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN(FALSE);
  END;

  --------------------------------------------------------------
  debug_info := 'Step 2 - Verify IF the  allocation rule exist '
               ||'for this chrg line.';
  --------------------------------------------------------------
  BEGIN

    l_alloc_rule := 0;
    SELECT COUNT(*)
      INTO l_alloc_rule
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_chrg_line_number;

    IF (l_alloc_rule =  0) THEN
      RETURN(TRUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------
  -- IF the  allocation rules exist then
  debug_info := ' Step 3 - determine the Status and Rule Type';
  --  associated with the charge line.'
  --------------------------------------------------------------
  IF l_alloc_rule <> 0  then

    BEGIN
      SELECT rule_type,
             status
        INTO l_rule_type,
             l_rule_status
        FROM ap_allocation_rules
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_chrg_line_number;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_rule_status =  'EXECUTED')  THEN
      X_error_code := 'AP_ALLOC_EXECUTED';
      RETURN(FALSE);
    END IF;


  END IF;

  --------------------------------------------------------------
  -- For AMOUNT and PERCENTAGE Based Rule Types verify that'
  debug_info := 'Step 4 - The Sum to prorate across is non zero';
 ---------------------------------------------------------------
  IF l_rule_type <> 'PRORATION' AND
     X_new_chrg_line_amt <> 0  THEN

    BEGIN
      SELECT NVL(SUM(amount) ,0)
        INTO l_prorating_total
        FROM ap_allocation_rule_lines
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_chrg_line_number;

      IF (l_prorating_total = 0) THEN
        X_error_code := 'AP_NO_ITEMS_LINES_AVAIL';
        RETURN(FALSE);
      END IF;

      IF (l_prorating_total = X_new_chrg_line_amt ) THEN
        RETURN(TRUE);
      END IF;


    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END IF;

 ---------------------------------------------------------
 debug_info := 'Step 5 - Update ap_allocation_rule_lines ';
 ---------------------------------------------------------
  IF (l_rule_type <> 'PRORATION' AND
     X_new_chrg_line_amt <> 0 )     THEN

    BEGIN

      UPDATE ap_allocation_rule_lines
         SET amount = ap_utilities_pkg.ap_round_currency(
                      l_amount_to_prorate*amount/
                      l_prorating_total, l_inv_curr_code),
             last_updated_by = FND_GLOBAL.USER_ID,
             last_update_date = SYSDATE,
             last_update_login = FND_GLOBAL.LOGIN_ID
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_chrg_line_number;

     EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                                   current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '
                                 ||to_char(X_Invoice_ID)
                                 ||', Invoice Line Number = '
                                 ||to_char(X_chrg_Line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
     END;

  END IF;

  --------------------------------------------------------------
  debug_info := 'Step 6 - Verify if there is any rounding and '
                ||'apply it to max of largest.';
  --------------------------------------------------------------
 IF (l_rule_type <> 'PRORATION' AND
     X_new_chrg_line_amt <> 0 )     THEN
      BEGIN
        SELECT SUM(amount)
          INTO l_total_prorated
          FROM ap_allocation_rule_lines
         WHERE invoice_id = X_invoice_id
           AND chrg_invoice_line_number = X_chrg_line_number;

        IF (l_amount_to_prorate <> l_total_prorated) THEN
          UPDATE ap_allocation_rule_lines
             SET amount = amount + (l_amount_to_prorate - l_total_prorated)
           WHERE invoice_id = X_invoice_id
             AND chrg_invoice_line_number = X_chrg_line_number
             AND to_invoice_line_number =
                     (SELECT (MAX(arl1.to_invoice_line_number))
                        FROM ap_allocation_rule_lines arl1
                       WHERE arl1.invoice_id = X_invoice_id
                         AND arl1.chrg_invoice_line_number = X_chrg_line_number
                         AND arl1.amount <> 0
                         AND ABS(arl1.amount) >=
                            ( SELECT  MAX(ABS(arl2.amount))
                                FROM  ap_allocation_rule_lines arl2
                               WHERE  arl2.invoice_id = X_invoice_id
                                 AND  arl2.chrg_invoice_line_number = X_chrg_line_number
                                      AND  arl2.to_invoice_line_number <>
                                            arl2.to_invoice_line_number
                                             ));
         END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id ='
               ||to_char(X_Invoice_ID)
               ||', Invoice Line Number ='
               ||to_char(X_chrg_Line_Number));
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
     END;
   END IF;


RETURN(TRUE);
END Prorate_allocated_lines;

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
RETURN  BOOLEAN IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_alloc_rule                  NUMBER;
  l_amount_to_prorate           AP_INVOICE_LINES.AMOUNT%TYPE;
  l_total_prorated              AP_INVOICE_LINES.AMOUNT%TYPE;
  l_inv_curr_code               AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_rule_type                   AP_ALLOCATION_RULES.RULE_TYPE%TYPE;
  l_rule_status                 AP_ALLOCATION_RULES.STATUS%TYPE;
  l_prorating_total             NUMBER := 0;
  l_prorated_total              NUMBER := 0;

  debug_info                    VARCHAR2(100);
  debug_context                 VARCHAR2(2000);
  current_calling_sequence      VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
 current_calling_sequence := 'Ap_Allocation_Rules_Pkg.'||
                              'Delete_Allocations';
  --------------------------------------------------------------
  debug_info := 'Step 1 - Verify chrg line exists, has '
                ||' generate_dists flag set to Y';
  --------------------------------------------------------------
  BEGIN
    SELECT ail.generate_dists,
           X_new_chrg_line_amt,
           ai.invoice_currency_code
      INTO l_generate_dists,
           l_amount_to_prorate,
           l_inv_curr_code
      FROM ap_invoice_lines ail,
           ap_invoices ai
     WHERE ail.invoice_id = X_invoice_id
       AND ail.line_number = x_chrg_line_number
       AND ai.invoice_id = X_invoice_id;

    /* Bug 5131721 */
    IF (nvl(l_generate_dists, 'N') = 'D') THEN
      X_error_code := 'AP_GENERATE_DISTS_IS_NO';
      RETURN(FALSE);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_error_code := 'AP_NO_CHARGES_EXIST';
      RETURN(FALSE);
    WHEN OTHERS THEN
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id =
'||TO_CHAR(X_invoice_id)
          ||', Invoice Line Number = '||TO_CHAR(X_chrg_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  --------------------------------------------------------------
  debug_info := 'Step 2 - Verify IF the  allocation rule exist '
               ||'for this chrg line.';
  --------------------------------------------------------------
  BEGIN

    l_alloc_rule := 0;
    SELECT COUNT(*)
      INTO l_alloc_rule
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_chrg_line_number;

    IF (l_alloc_rule =  0) THEN
      RETURN(TRUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------
  ---  IF the  allocation rules exist then '
  debug_info := ' Step 3 - Determine the Status and Rule type ';
  --   associated with the charge line.
  --------------------------------------------------------------
  IF l_alloc_rule <> 0  then

    BEGIN
      SELECT rule_type,
             status
        INTO l_rule_type,
             l_rule_status
        FROM ap_allocation_rules
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_chrg_line_number;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_rule_status =  'EXECUTED')  THEN
      X_error_code := 'AP_ALLOC_EXECUTED';
      RETURN(FALSE);
    END IF;


  END IF;


 --------------------------------------------------------
 debug_info := 'Step 4 - If the New Amount is Zero, all '
 ||'pending  allocation rules will be deleted.';
 -------------------------------------------------------
  IF X_new_chrg_line_amt = 0 THEN

    DELETE FROM ap_allocation_rules
    WHERE invoice_id = X_Invoice_Id
      AND  chrg_invoice_line_number = X_chrg_line_number;

    IF l_rule_type <> 'PRORATION' THEN
      Ap_Allocation_Rules_Pkg.Delete_Allocation_Lines(
          X_invoice_id       => X_Invoice_Id,
          X_chrg_line_number => X_chrg_line_number,
          X_calling_sequence => current_calling_sequence);
    END IF;

    RETURN(TRUE);
  END IF;

RETURN(TRUE);
END Delete_Allocations;

-------------------------------------------------------------------------
-- This Procedure deletes the pending Allocation Rule Lines so
-- that the Rule Lines can be recreated as of the latest snapshot
-- This function is called from the following
--  1.  Whenever the user changes the Rule Type of the Allocation Rule
--  2.  Delete Allocations(Whenever a user updates the charge line amount
--      to 0 in the Invoice Window).
------------------------------------------------------------------------
PROCEDURE delete_allocation_lines(
          X_invoice_id          IN     NUMBER,
          X_chrg_line_number    IN     NUMBER,
          X_calling_sequence    IN     VARCHAR2) IS

  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(100);

BEGIN
current_calling_sequence :=
     'Ap_Allocation_Rules_Pkg.Delete_allocations_lines<-'||X_Calling_Sequence;
  -----------------------------------------------------------
  debug_info := 'Deleting any existing allocation rows ';
  ----------------------------------------------------------
  DELETE FROM ap_allocation_rule_lines
   WHERE      invoice_id = X_invoice_id
     AND      chrg_invoice_line_number = X_chrg_line_number;

EXCEPTION
     WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              'X_Invoice_Id = '||to_char(X_invoice_id) );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

END Delete_Allocation_Lines;

-------------------------------------------------------------------------
-- This Procedure creates Allocation Rule and Rule Lines for tax lines.
-- It is invoked after tax lines are inserted from the AP eTax utilities
-- package.
-------------------------------------------------------------------------
FUNCTION insert_tax_allocations (
          X_invoice_id          IN         NUMBER,
          X_chrg_line_number    IN         NUMBER,
          X_error_code          OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

  l_generate_dists              AP_INVOICE_LINES.GENERATE_DISTS%TYPE;
  l_line_group_number           AP_INVOICE_LINES.LINE_GROUP_NUMBER%TYPE;
  l_amount_to_prorate           AP_INVOICE_LINES.AMOUNT%TYPE;
  l_total_prorated              AP_INVOICE_LINES.AMOUNT%TYPE;
  l_inv_curr_code               AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_count_non_item_lines        NUMBER := 0;
  l_prorating_total             NUMBER := 0;
  l_other_alloc_rules           NUMBER;
  l_other_alloc_rule_line	NUMBER;
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(200);

BEGIN

  -- Update the calling sequence
  current_calling_sequence := 'AP_ALLOCATION_RULES_PKG.'||
                              'insert_tax_allocations';

  --------------------------------------------------------------
  -- Step 1 - Verify line exists, has generate_dists flag
  -- set to Y
  --------------------------------------------------------------
  BEGIN
    SELECT ail.generate_dists,
           ail.line_group_number,
           ail.amount,
           ai.invoice_currency_code
      INTO l_generate_dists,
           l_line_group_number,
           l_amount_to_prorate,
           l_inv_curr_code
      FROM ap_invoice_lines ail,
           ap_invoices ai
     WHERE ail.invoice_id  = x_invoice_id
       AND ail.line_number = x_chrg_line_number
       AND ai.invoice_id   = ail.invoice_id;

    /* Bug 5131721 */
    IF (nvl(l_generate_dists, 'N') = 'D' ) THEN
      X_error_code := 'AP_GENERATE_DISTS_IS_NO';
      RETURN(FALSE);
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id) ||
                                           ', Invoice Line Number = '||TO_CHAR(X_chrg_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  --------------------------------------------------------------
  -- Step 2 - Delete any allocation rules/rule lines that exists.
  --------------------------------------------------------------
  BEGIN
    l_other_alloc_rules := 0;
    SELECT COUNT(*)
      INTO l_other_alloc_rules
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_chrg_line_number;

    SELECT COUNT(*)
      INTO l_other_alloc_rule_line
      FROM ap_allocation_rule_lines
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_chrg_line_number;


    IF (l_other_alloc_rules <> 0) THEN

	DELETE FROM ap_allocation_rules
         WHERE invoice_id = X_invoice_id
           AND chrg_invoice_line_number = X_chrg_line_number;

    END IF;

    IF (l_other_alloc_rule_line <> 0) THEN

	DELETE FROM ap_allocation_rule_lines
         WHERE invoice_id = X_invoice_id
           AND chrg_invoice_line_number = X_chrg_line_number;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------
  -- Step 5 - Insert Allocation Rule
  --------------------------------------------------------------
  BEGIN
    INSERT INTO ap_allocation_rules(
          invoice_id,
          chrg_invoice_line_number,
          rule_type,
          rule_generation_type,
          status,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
      VALUES(
          X_invoice_id,              -- invoice_id
          X_chrg_line_number,        -- chrg_invoice_line_number
          'AMOUNT',                  -- rule_type
          'SYSTEM',                  -- rule_generation_type
          'EXECUTED',                -- status
          SYSDATE,                   -- creation_date
          FND_GLOBAL.USER_ID,        -- created_by
          FND_GLOBAL.USER_ID,        -- last_updated_by
          SYSDATE,                   -- last_update_date
          FND_GLOBAL.LOGIN_ID,       -- last_update_login
          FND_GLOBAL.PROG_APPL_ID,   -- program_application_id
          FND_GLOBAL.CONC_PROGRAM_ID,-- program_id
          SYSDATE,                   -- program_update_date
          FND_GLOBAL.CONC_REQUEST_ID -- request_id
	     );
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id ='||TO_CHAR(X_invoice_id) ||
                                           ', Invoice Line Number = '||TO_CHAR(X_chrg_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  --------------------------------------------------------------
  -- Step 6 - Insert Allocation Rule Lines
  --------------------------------------------------------------
  BEGIN
     INSERT INTO ap_allocation_rule_lines  (
          invoice_id,
          chrg_invoice_line_number,
	  to_invoice_line_number,
          amount,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id)
   SELECT x_invoice_id,		      -- invoice_id
	  x_chrg_line_number,         -- chrg_invoice_line_number
	  zxl.trx_line_number,	      -- to_invoice_line_number
	  sum(zxl.tax_amt),	      -- amount
	  SYSDATE,                    -- creation_date
	  FND_GLOBAL.USER_ID,         -- created_by
          FND_GLOBAL.USER_ID,         -- last_updated_by
          SYSDATE,                    -- last_update_date
          FND_GLOBAL.LOGIN_ID,        -- last_update_login
          FND_GLOBAL.PROG_APPL_ID,    -- program_application_id
          FND_GLOBAL.CONC_PROGRAM_ID, -- program_id
          SYSDATE,                    -- program_update_date
	  FND_GLOBAL.CONC_REQUEST_ID  -- request_id
     FROM zx_lines 	   zxl,
          ap_invoice_lines apl
    WHERE apl.invoice_id		= x_invoice_id
      AND apl.line_number		= x_chrg_line_number
      AND apl.summary_tax_line_id	= zxl.summary_tax_line_id
      AND zxl.application_id 		= AP_ETAX_PKG.AP_APPLICATION_ID
      AND zxl.entity_code		= AP_ETAX_PKG.AP_ENTITY_CODE
      AND zxl.event_class_code          IN (AP_ETAX_PKG.AP_INV_EVENT_CLASS_CODE,
                                            AP_ETAX_PKG.AP_PP_EVENT_CLASS_CODE,
                                            AP_ETAX_PKG.AP_ER_EVENT_CLASS_CODE)
      AND zxl.trx_id			= apl.invoice_id
      AND NVL(zxl.reporting_only_flag, 'N') = 'N'
    GROUP BY zxl.trx_line_number;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_invoice_id) ||
                                           ', Invoice Line Number = '||TO_CHAR(X_chrg_line_number));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      X_error_code := 'AP_DEBUG';
      RETURN (FALSE);
  END;

  RETURN(TRUE);

END insert_tax_allocations;

END AP_ALLOCATION_RULES_PKG;

/
