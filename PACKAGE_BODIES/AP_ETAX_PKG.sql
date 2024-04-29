--------------------------------------------------------
--  DDL for Package Body AP_ETAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ETAX_PKG" AS
/* $Header: apetaxpb.pls 120.15.12010000.3 2009/12/30 14:01:32 ppodhiya ship $ */

/*=============================================================================
 |  FUNCTION - Calling_eTax()
 |
 |  DESCRIPTION
 |      Public function that will call the requested AP_ETAX_SERVICES_PKG  function
 |      This API is called from different points throughout AP.
 |      This API assumes the calling code controls the commit cycle.
 |      This function returns TRUE if the call to the service is successful.
 |      Otherwise, FALSE.
 |
 |  PARAMETERS
 |      P_Invoice_Id - invoice id
 |      P_Line_Number - This parameter will be used to allow this API to
 |                      calculate tax only for the line specified in this
 |                      parameter.  Additionally, this parameter will be used
 |                      to determine the PREPAY line created for prepayment
 |                      unapplications.
 |      P_Calling_Mode - calling mode.  Identifies which service to call
 |      P_Override_Status - only for calling_mode OVERRIDE TAX
 |      P_Line_Number_To_Delete - required when calling mode is MARK TAX LINES DELETED
 |      P_Interface_Invoice_Id - invoice id in the ap_invoices_interface table.
 |                               this parameter is used only while calling the
 |                               API to calculate tax from the import program
 |      P_All_Error_Messages -  Determine if the calling point wants the returning
 |                              of all or only 1 error message.  Calling point will
 |                              pass Y in the case they want to handle the return of
 |                              more than one message from the FND message pile. N
 |                              if they just want 1 message to be returned.
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    07-OCT-2003   SYIDNER        Created
 |    05-NOV-2003   SYIDNER        Included new P_Line_Number_To_Delete and
 |                                 P_All_Error_Messages parameters
 |    05-MAR-2004   SYIDNER        Included P_Line_Number as a new parameter
 |
 *============================================================================*/

  FUNCTION Calling_eTax(
             P_Invoice_id              IN  NUMBER,
             P_Line_Number             IN  NUMBER 			DEFAULT NULL,
             P_Calling_Mode            IN  VARCHAR2,
             P_Override_Status         IN  VARCHAR2 			DEFAULT NULL,
             P_Line_Number_To_Delete   IN  NUMBER 			DEFAULT NULL,
             P_Interface_Invoice_Id    IN  NUMBER 			DEFAULT NULL,
	     P_Event_Id		       IN  NUMBER			DEFAULT NULL,
             P_All_Error_Messages      IN  VARCHAR2,
             P_error_code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN  VARCHAR2) RETURN BOOLEAN

  IS
    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);

    l_return_status              BOOLEAN := TRUE;
    l_assessable_value           NUMBER; --8911181
    l_invoice_amount             NUMBER; --8911181
    l_invoice_currency_code      AP_INVOICES_ALL.INVOICE_CURRENCY_CODE%TYPE; --8911181

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_PKG.Calling_eTax<-' ||
                               P_calling_sequence;

    ------------------------------------------------------------------
    l_debug_info := 'Step 1: P_Calling_Mode is:'||P_Calling_Mode;
    ------------------------------------------------------------------

    -- Bug 9034372. Added new calling mode : 'QUICK CANCEL'

    IF (P_Calling_Mode IN ('CALCULATE', 'APPLY PREPAY', 'QUICK CANCEL')) THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Calculate';
      -------------------------------------------------------------------
      -- BUG 8911181 START : Updating Invoice Lines Assessable Value --

	  SELECT to_number(fnd_profile.value('AP_JEA_TAX_ASSESSABLE_VALUE'))
	    INTO l_assessable_value
	    FROM dual;

	  IF l_assessable_value IS NOT NULL THEN

		SELECT invoice_currency_code
		  INTO l_invoice_currency_code
		  FROM ap_invoices_all
		 WHERE invoice_id = P_Invoice_Id;

		SELECT SUM(amount)
		  INTO l_invoice_amount
		  FROM ap_invoice_lines_all
		 WHERE invoice_id = P_Invoice_Id
		   AND line_type_lookup_code IN ('ITEM', 'FREIGHT');

               IF l_invoice_amount > l_assessable_value THEN

		 UPDATE ap_invoice_lines_all
		    SET assessable_value = AP_Utilities_Pkg.AP_Round_Currency(
			                        amount*l_assessable_value/
			                        decode(l_invoice_amount,0,
			                               decode(l_assessable_value,0,1,l_assessable_value),
						       l_invoice_amount)
						,l_invoice_currency_code)
		  WHERE Invoice_id = p_invoice_id
		    AND line_type_lookup_code NOT IN ('TAX', 'AWT');

		END IF; -- l_invoice_amount > l_assessable_value

	  END IF; -- l_assessable_value IS NOT NULL
	  -- BUG 8911181 ENDS


      IF NOT (AP_ETAX_SERVICES_PKG.Calculate(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Line_Number            => P_Line_Number,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'CALCULATE IMPORT') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Calculate_Import';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Calculate_Import(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_Interface_Invoice_Id   => P_Interface_Invoice_Id,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;


    ELSIF (P_Calling_Mode IN ('DISTRIBUTE', 'DISTRIBUTE RECOUP')) THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Distribute';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Distribute(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Line_Number            => P_Line_Number,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence))  THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'DISTRIBUTE IMPORT') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Distribute_Import';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Distribute_Import(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence))  THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'IMPORT INTERFACE') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Import_Interface';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Import_Interface(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_Interface_Invoice_Id   => P_Interface_Invoice_Id,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'REVERSE INVOICE') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Reverse_Invoice';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Reverse_Invoice(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'OVERRIDE TAX') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Override_Tax';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Override_Tax(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_Override_Status        => P_Override_Status,
			       P_Event_Id		=> P_Event_Id,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'OVERRIDE RECOVERY') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Override_Recovery';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Override_Recovery(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode IN  ('CANCEL INVOICE',
                               'FREEZE INVOICE',
                               'UNFREEZE INVOICE',
			       'DISCARD LINE',
			       'UNAPPLY PREPAY')) THEN  --bugfix:5697764
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Global_Document_Update';
      -------------------------------------------------------------------

      IF P_Calling_Mode IN ('DISCARD LINE', 'UNAPPLY PREPAY') THEN
         IF NOT (AP_ETAX_SERVICES_PKG.Global_Document_Update(
                               P_Invoice_id              => P_Invoice_Id,
			       P_Line_Number	 	 => P_Line_Number,
                               P_Calling_Mode            => P_Calling_Mode,
                               P_All_Error_Messages      => P_All_Error_Messages,
                               P_Error_Code              => P_Error_Code,
                               P_Calling_Sequence        => l_curr_calling_sequence)) THEN

            l_return_status := FALSE;
          END IF;
      ELSE
          IF NOT (AP_ETAX_SERVICES_PKG.Global_Document_Update(
                               P_Invoice_id              => P_Invoice_Id,
                               P_Calling_Mode            => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code              => P_Error_Code,
                               P_Calling_Sequence        => l_curr_calling_sequence)) THEN

            l_return_status := FALSE;
          END IF;
      END IF;

    ELSIF (P_Calling_Mode = 'MARK TAX LINES DELETED') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Mark_Tax_Lines_Deleted';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Mark_Tax_Lines_Deleted(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_Line_Number_To_Delete  => P_Line_Number_To_Delete,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;


    ELSIF (P_Calling_Mode = 'VALIDATE') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Validate_Invoice';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Validate_Invoice(
                               P_Invoice_id             => P_Invoice_Id,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'RECOUPMENT') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Generate_Recouped_Tax';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Generate_Recouped_Tax(
                               P_Invoice_id             => P_Invoice_Id,
			       P_Invoice_Line_Number	=> P_Line_Number,
                               P_Calling_Mode           => P_Calling_Mode,
                               P_All_Error_Messages     => P_All_Error_Messages,
                               P_Error_Code             => P_Error_Code,
                               P_Calling_Sequence       => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    ELSIF (P_Calling_Mode = 'DELETE_TAX_DIST') THEN
      -------------------------------------------------------------------
      l_debug_info := 'Step 2: Calling AP_ETAX_SERVICES_PKG.Delete_Tax_Distributions';
      -------------------------------------------------------------------

      IF NOT (AP_ETAX_SERVICES_PKG.Delete_Tax_Distributions
                        (p_invoice_id         => P_Invoice_Id,
                         p_calling_mode       => P_Calling_Mode,
                         p_all_error_messages => P_All_Error_Messages,
                         p_error_code         => P_Error_Code,
                         p_calling_sequence   => l_curr_calling_sequence)) THEN

        l_return_status := FALSE;
      END IF;

    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Calling_Mode = '||P_Calling_Mode||
          ' P_Override_Status = '||P_Override_Status||
          ' P_Line_Number_To_Delete = '||P_Line_Number_To_Delete||
          ' P_All_Error_Messages = '||P_All_Error_Messages||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Calling_eTax;


/*=============================================================================
 |  FUNCTION - Calculate_Quote ()
 |
 |  DESCRIPTION
 |      This function will return the tax amount and indicate if it is inclusive.
 |      This will be called from the recurring invoices form. This is a special
 |      case, as the invoices for which the tax is to be calculated are not yet
 |      saved to the database and eBTax global temporary tables are populated
 |      based on the parameters. A psuedo-line is inserted into the GTT and
 |      removed after the tax amount is calculated.
 |
 |  PARAMETERS
 |      P_Invoice_header_rec 	- Invoice header info
 |      P_Invoice_Lines_Rec	- Invoice lines info
 |      P_Calling_Mode 		- Calling mode. (CALCULATE_QUOTE)
 |      P_All_Error_Messages 	- Should API return 1 error message or allow
 |                                calling point to get them from message stack
 |      P_error_code 		- Error code to be returned
 |      P_calling_sequence 	- Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    13-AUG-2003   Sanjay         Created
 *============================================================================*/
  FUNCTION Calculate_Quote(
             P_Calling_Mode            IN  VARCHAR2,
             P_All_Error_Messages      IN  VARCHAR2,
             P_Invoice_Header_Rec      IN  ap_invoices_all%ROWTYPE	DEFAULT NULL,
             P_Invoice_Lines_Rec       IN  ap_invoice_lines_all%ROWTYPE DEFAULT NULL,
	     P_Tax_Amount	       OUT NOCOPY NUMBER,
	     P_Tax_Amt_Included        OUT NOCOPY VARCHAR2,
             P_error_code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN  VARCHAR2) RETURN BOOLEAN IS

       l_curr_calling_sequence      VARCHAR2(4000);
       l_return_status              BOOLEAN := TRUE;

  BEGIN

       l_curr_calling_sequence := 'AP_ETAX_PKG.Calculate_Quote<-' || P_calling_sequence;


       IF P_Calling_Mode = 'CALCULATE QUOTE' THEN

          IF NOT (AP_ETAX_SERVICES_PKG.CALCULATE_QUOTE(
                               P_Invoice_Header_Rec	=> p_invoice_header_rec,
                               P_Invoice_Lines_Rec	=> p_invoice_lines_rec,
                               P_Calling_Mode		=> p_calling_mode,
                               P_Tax_Amount		=> p_tax_amount,
			       P_Tax_Amt_Included       => P_Tax_Amt_Included,
                               P_Error_Code		=> p_error_code,
                               P_Calling_Sequence	=> p_calling_sequence )) THEN

             l_return_status := FALSE;
          END IF;
       END IF;

       RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);

      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

RETURN l_return_status;

  END Calculate_Quote;

/*=============================================================================
 |  FUNCTION - callETax()
 |
 |  DESCRIPTION
 |      Public function that will call the requested AP_ETAX_SERVICES_PKG function
 |
 |      This API is a wrapper of the calling_etax() api, mainly used by JDBC calls
 |      from OA based applications.
 |      This API will commit at the end.
 |      This function returns 0 if the call to the service is successful.
 |      Otherwise, 1.
 |
 |  PARAMETERS
 |      x_Invoice_Id - invoice id
 |      x_Line_Number - This parameter will be used to allow this API to
 |                      calculate tax only for the line specified in this
 |                      parameter.  Additionally, this parameter will be used
 |                      to determine the PREPAY line created for prepayment
 |                      unapplications.
 |      x_Calling_Mode - calling mode.  Identifies which service to call
 |      x_Override_Status - only for calling_mode OVERRIDE TAX
 |      x_Line_Number_To_Delete - required when calling mode is MARK TAX LINES DELETED
 |      x_Interface_Invoice_Id - invoice id in the ap_invoices_interface table.
 |                               this parameter is used only while calling the
 |                               API to calculate tax from the import program
 |      x_All_Error_Messages -  Determine if the calling point wants the returning
 |                              of all or only 1 error message.  Calling point will
 |                              pass Y in the case they want to handle the return of
 |                              more than one message from the FND message pile. N
 |                              if they just want 1 message to be returned.
 |      x_event_id - used by OVERRIDE TAX
 |      x_error_code - Error code to be returned
 |      x_calling_sequence -  Calling sequence
 |
 *============================================================================*/

  FUNCTION callETax(
             x_Invoice_id              IN  NUMBER,
             x_Line_Number             IN  NUMBER                       DEFAULT NULL,
             x_Calling_Mode            IN  VARCHAR2,
             x_Override_Status         IN  VARCHAR2                     DEFAULT NULL,
             x_Line_Number_To_Delete   IN  NUMBER                       DEFAULT NULL,
             x_Interface_Invoice_Id    IN  NUMBER                       DEFAULT NULL,
             x_Event_Id                IN  NUMBER                       DEFAULT NULL,
             x_All_Error_Messages      IN  VARCHAR2,
             x_error_code              OUT NOCOPY VARCHAR2,
             x_Calling_Sequence        IN  VARCHAR2) RETURN NUMBER

  IS
    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_PKG.callETax<-' ||
                               x_calling_sequence;

    ------------------------------------------------------------------
    l_debug_info := 'calling the calling_etax() api';
    ------------------------------------------------------------------
    IF NOT (ap_etax_pkg.calling_etax(
                 p_invoice_id             => x_invoice_id,
                 p_line_number            => x_line_number,
                 p_calling_mode           => x_calling_mode,
                 p_override_status        => x_override_status,
                 p_line_number_to_delete  => x_line_number_to_delete,
                 p_Interface_Invoice_Id   => x_interface_invoice_id,
                 P_Event_Id               => x_event_id,
                 p_all_error_messages     => x_all_error_messages,
                 p_error_code             => x_error_code,
                 p_calling_sequence       => l_curr_calling_sequence)) THEN
       	RETURN 1; -- failed
    ELSE
	RETURN 0; -- successful
    END IF;

    -- make sure we commit here
    commit;

  EXCEPTION
    WHEN OTHERS THEN
/*
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' x_Invoice_Id = '||x_Invoice_Id||
          ' x_Calling_Mode = '||x_Calling_Mode||
          ' x_Override_Status = '||x_Override_Status||
          ' x_Line_Number_To_Delete = '||x_Line_Number_To_Delete||
          ' x_All_Error_Messages = '||x_All_Error_Messages||
          ' x_Error_Code = '||x_Error_Code||
          ' x_Calling_Sequence = '||x_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
*/

      RETURN 1;

  END callETax;

END AP_ETAX_PKG;

/
