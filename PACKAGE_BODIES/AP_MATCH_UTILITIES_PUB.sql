--------------------------------------------------------
--  DDL for Package Body AP_MATCH_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_MATCH_UTILITIES_PUB" AS
/* $Header: aprmtutb.pls 120.0.12010000.3 2008/08/14 18:52:50 bgoyal ship $ */

/*=============================================================================
 | PUBLIC FUNCTION Check_Unvalidated_Invoices
 |
 | DESCRIPTION
 |   The function will Return 'TRUE' if there are unvalidated payables
 |   documents matched to a Purchase Order based on the input parameters.
 |
 | USAGE
 |      p_invoice_type and p_po_header_id are required parameters.
 |      Call this function, when the user unreserves funds for the PO.
 |      Unreserve from PO Header, pass p_po_line_id, p_line_location_id, p_po_distribution_id AS NULL
 |      Unreserve from PO Line, pass p_line_location_id and p_po_distribution_id AS NULL
 |      Unreserve from PO Shipment, pass p_po_distribution_id AS NULL
 |      Unreserve from PO Distribution, pass all parameters.
 |
 |      This function can also be used to prevent 'Final Close' of a PO if there are unvalidated
 |      invoices matched to it.
 |
 |      Parameter p_invoice_id
 |      ----------------------
 |      A special case during matching, is when a user indicates that it is a 'Final Match'. During
 |      invoice validation, Payables invokes po_actions.close_po() to 'Final Close' the PO.
 |
 |      When po_actions.close_po() is invoked as a result of 'Final Match', pass p_invoice_id
 |      to skip the check for the invoice doing the final match. Otherwise, we will not be
 |      able to final match or close the PO.
 |
 | RETURNS
 |      TRUE if there are unvalidated invoices, credit or debit memos.
 |
 | PARAMETERS
 |   p_invoice_type	  IN  Required parameter. Values: 'INVOICE' or 'CREDIT'
 |   p_po_header_id	  IN  Required parameter. PO Header Identifier.
 |   p_po_line_id	  IN  PO Line Identifier
 |   p_line_location_id	  IN  PO Shipment Identifier
 |   p_po_distribution_id IN  PO Distribution Identifier
 |   p_invoice_id	  IN  Invoice Identifier
 |   p_calling_sequence   IN  Calling module (package_name.procedure or block_name.field_name)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 |
 *=============================================================================*/

 FUNCTION Check_Unvalidated_Invoices(p_invoice_type	  IN  VARCHAR2 DEFAULT 'BOTH',
                                     p_po_header_id	  IN  NUMBER,
				     p_po_release_id	  IN  NUMBER DEFAULT NULL,
				     p_po_line_id	  IN  NUMBER DEFAULT NULL,
				     p_line_location_id	  IN  NUMBER DEFAULT NULL,
				     p_po_distribution_id IN  NUMBER DEFAULT NULL,
				     p_invoice_id	  IN  NUMBER DEFAULT NULL,
				     p_calling_sequence   IN  VARCHAR2)
				     RETURN BOOLEAN IS

	l_status 		Number;
	l_debug_info            Varchar2(240);
	l_curr_calling_sequence Varchar2(2000);
	l_sql_stmt		Varchar2(2000);

  BEGIN

      l_curr_calling_sequence := 'Ap_Match_Utilities_Pub.Check_Unvalidated_Invoices<-' || p_calling_sequence;

      /* Added the Hold Exists for bug#7203269 in the Select Query*/
      l_sql_stmt := 'SELECT  count(*)
	   	      FROM po_headers			ph,
			   po_distributions		pd,
			   po_releases			pr,
			   ap_invoice_distributions	aid,
			   ap_invoices			ai
	   	     WHERE ph.po_header_id        = :b_po_header_id
		       AND ph.po_header_id        = pd.po_header_id
		       AND pd.po_release_id	  = pr.po_release_id(+)
		       AND pd.po_distribution_id  = aid.po_distribution_id
		       AND aid.invoice_id	  = ai.invoice_id
		       AND ( exists (select ''hold''
                                     from ap_holds_all ah
                                     where ai.invoice_id = ah.invoice_id
                                     AND ah.release_lookup_code is null)
                             OR   exists (select ''unvalidated dist''
                                          from ap_invoice_distributions_all aid2
                                          where ai.invoice_id = aid2.invoice_id
                                          and   nvl(aid2.match_status_flag, ''N'') <> ''A'')) ';



      If p_invoice_type = 'INVOICE' Then

         l_sql_stmt := l_sql_stmt || ' AND ai.invoice_amount > 0';

      Elsif p_invoice_type = 'CREDIT' Then

         l_sql_stmt := l_sql_stmt || ' AND ai.invoice_amount < 0';

      End If;

      If p_invoice_id Is Not Null Then
         l_sql_stmt := l_sql_stmt || ' AND ai.invoice_id <> :b_invoice_id';
      End If;



      If p_po_release_id Is Not Null Then
             l_sql_stmt := l_sql_stmt || ' AND pr.po_release_id = nvl('||p_po_release_id||', pr.po_release_id) ';
      End If;

      If p_po_line_id Is Not Null Then

            l_sql_stmt := l_sql_stmt || ' AND pd.po_line_id = :b_line_id AND rownum = 1';

	    If p_invoice_id Is Not Null Then
	       Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_invoice_id, p_po_line_id;
	    Else
	       Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_po_line_id;
 	    End If;

      Elsif p_line_location_id Is Not Null Then

            l_sql_stmt := l_sql_stmt || ' AND pd.line_location_id = :b_line_location_id AND rownum = 1';
	    If p_invoice_id Is Not Null Then
	       Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_invoice_id, p_line_location_id;
	    Else
	       Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_line_location_id;
	    End If;

      Elsif p_po_distribution_id Is Not Null Then

            l_sql_stmt := l_sql_stmt || ' AND pd.po_distribution_id = :b_po_distribution_id AND rownum = 1';

	    If p_invoice_id Is Not Null Then
	       Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_invoice_id, p_po_distribution_id;
	    Else
	       Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_po_distribution_id;
	    End If;

     Elsif p_po_line_id Is Null And p_line_location_id Is Null And p_po_distribution_id Is Null Then
           l_sql_stmt := l_sql_stmt || ' AND rownum = 1';

           If p_invoice_id Is Not Null Then
             Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id, p_invoice_id;
           Else
	     Execute Immediate l_sql_stmt INTO l_status USING p_po_header_id;
           End If;

      End If;
     /* Added the if condition for bug#7203269 */
     If l_status > 0 Then
        RETURN (TRUE);
     Else
        RETURN (FALSE);
     End If;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN

      RETURN FALSE;

    WHEN OTHERS THEN

      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                              ' P_invoice_type       = ' || P_invoice_type
				    ||' P_po_header_id       = ' || P_po_header_id
	                            ||' P_po_line_id         = ' || P_po_line_id
	                            ||' P_line_location_id   = ' || P_line_location_id
	                            ||' P_po_distribution_id = ' || P_po_distribution_id);

        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

 END Check_Unvalidated_Invoices;

END AP_MATCH_UTILITIES_PUB;

/
