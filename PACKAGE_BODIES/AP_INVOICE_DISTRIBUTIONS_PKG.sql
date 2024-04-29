--------------------------------------------------------
--  DDL for Package Body AP_INVOICE_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICE_DISTRIBUTIONS_PKG" AS
/* $Header: apiindib.pls 120.68.12010000.40 2010/11/02 18:17:58 mayyalas ship $ */

     G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_INVOICE_DISTRIBUTIONS_PKG';
     G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
     G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
     G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
     G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
     G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
     G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
     G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

     G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
     G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
     G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
     G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
     G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
     G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
     G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_INVOICE_DISTRIBUTIONS_PKG.';


     --Invoice Lines: Distributions. Added the parameter X_INVOICE_LINE_NUMBER
     -----------------------------------------------------------------------
     -- Procedure check_unique ensures the uniqueness of the primary key.
     --

     PROCEDURE CHECK_UNIQUE (X_ROWID                          VARCHAR2,
                             X_INVOICE_ID                     NUMBER,
			     X_INVOICE_LINE_NUMBER	      NUMBER,
                             X_DISTRIBUTION_LINE_NUMBER       NUMBER,
                             X_Calling_Sequence               VARCHAR2) IS
       dummy number := 0;
       current_calling_sequence VARCHAR2(2000);
       debug_info               VARCHAR2(100);

     begin

       -- Update the calling sequence
       --
       current_calling_sequence :=
             'AP_INVOICE_DISTRIBUTIONS_PKG.CHECK_UNIQUE<-'||X_Calling_Sequence;

       debug_info := 'Select from ap_invoice_distributions';

       select count(1)
       into   dummy
       from   ap_invoice_distributions
       where  (invoice_id = X_INVOICE_ID AND
	       invoice_line_number = X_INVOICE_LINE_NUMBER AND
               distribution_line_number = X_DISTRIBUTION_LINE_NUMBER)
       and    ((X_ROWID is null) or (rowid <> X_ROWID));

       if (dummy >= 1) then
          fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
          app_exception.raise_exception;
       end if;

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||X_ROWID
                                         ||', Invoice Id = '||X_INVOICE_ID
                                         ||', Distribution line number = '||
                                         X_DISTRIBUTION_LINE_NUMBER);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;
     end CHECK_UNIQUE;


     -----------------------------------------------------------------------


     -----------------------------------------------------------------------
     -- Function Get_UOM returns the unit_of_measure for the given
     -- ccid
     --
     FUNCTION Get_UOM(X_CCID IN NUMBER, X_Ch_Of_Accts_Id IN NUMBER)
         RETURN VARCHAR2
     IS
         column_name     VARCHAR2(20) := '';
         segment_val     gl_code_combinations.SEGMENT1%TYPE;
         uom             gl_stat_account_uom.unit_of_measure%TYPE;
         status          VARCHAR2(10) := '';
         industry        VARCHAR2(10) := '';

     BEGIN

         IF (FND_INSTALLATION.GET(101, 101, status, industry)) then
           IF (status <> 'I') then
             return('');
           END IF;
         ELSE
           return('');
         END IF;

         IF (FND_FLEX_APIS.get_segment_column(101, 'GL#', X_Ch_Of_Accts_Id,
                                              'GL_ACCOUNT', column_name)) THEN
            select decode(column_name, 'SEGMENT1', segment1,
                                       'SEGMENT2', segment2,
                                       'SEGMENT3', segment3,
                                       'SEGMENT4', segment4,
                                       'SEGMENT5', segment5,
                                       'SEGMENT6', segment6,
                                       'SEGMENT7', segment7,
                                       'SEGMENT8', segment8,
                                       'SEGMENT9', segment9,
                                       'SEGMENT10', segment10,
                                       'SEGMENT11', segment11,
                                       'SEGMENT12', segment12,
                                       'SEGMENT13', segment13,
                                       'SEGMENT14', segment14,
                                       'SEGMENT15', segment15,
                                       'SEGMENT16', segment16,
                                       'SEGMENT17', segment17,
                                       'SEGMENT18', segment18,
                                       'SEGMENT19', segment19,
                                       'SEGMENT20', segment20,
                                       'SEGMENT21', segment21,
                                       'SEGMENT22', segment22,
                                       'SEGMENT23', segment23,
                                       'SEGMENT24', segment24,
                                       'SEGMENT25', segment25,
                                       'SEGMENT26', segment26,
                                       'SEGMENT27', segment27,
                                       'SEGMENT28', segment28,
                                       'SEGMENT29', segment29,
                                       'SEGMENT30', segment30)
            into  segment_val
            from  gl_code_combinations
            where code_combination_id = X_CCID;

            select unit_of_measure
            into   uom
            from   gl_stat_account_uom
            where  account_segment_value = segment_val
            and chart_of_accounts_id =  X_Ch_Of_Accts_Id ;

            return(uom);
         ELSE
            return('');
         END IF;

     EXCEPTION
        WHEN OTHERS THEN
          RETURN('');

     END Get_UOM;


     -----------------------------------------------------------------------


     -----------------------------------------------------------------------
     -- Function Get_Posted_Status returns the posted_status for the
     -- distribution_line.
     --

     FUNCTION Get_Posted_Status(X_Accrual_Posted_Flag       VARCHAR2,
                                X_Cash_Posted_Flag          VARCHAR2,
                                X_Posted_Flag               VARCHAR2,
                                X_Org_Id          IN  NUMBER DEFAULT
                                mo_global.get_current_org_id )
        RETURN VARCHAR2
     IS
        l_posted_status       ap_lookup_codes.lookup_code%TYPE;
        l_cash_basis          VARCHAR2(1);
        l_accrual_posted_flag VARCHAR2(1);
        l_cash_posted_flag    VARCHAR2(1);
        l_posted_flag         VARCHAR2(1);

     BEGIN

        /*----------------------------------------------------
         *Manipulate pass in parameters
         *----------------------------------------------------*/
         l_accrual_posted_flag := NVL(X_Accrual_Posted_Flag, 'N');
         l_cash_posted_flag    := NVL(X_Cash_Posted_Flag, 'N');
         l_Posted_Flag         := NVL(X_Posted_Flag, 'N');

        /*----------------------------------------------------
         *Get the accounting method
         *l_cash_basis: 'Y' -- cash basis
         *              'N' -- accrual basis
         *----------------------------------------------------*/
        SELECT NVL(SLA_LEDGER_CASH_BASIS_FLAG, 'N')
        INTO   l_cash_basis
        FROM   ap_system_parameters_all ASP,
               gl_sets_of_books  SOB
        WHERE  asp.org_id = x_org_id
        AND    asp.set_of_books_id = sob.set_of_books_id;

        /*---------------------------------------------------
         * Figure out the posted status according to the
         * combination of flags and accounting options
         *---------------------------------------------------*/
        IF (l_cash_basis = 'Y') THEN  -- cash basis
           IF( l_cash_posted_flag = 'N' AND l_posted_flag = 'S') THEN
              l_posted_status := 'S';
           ELSE
              l_posted_status := l_cash_posted_flag;
           END IF;
        ELSE  --accrual basis
           IF( l_accrual_posted_flag = 'N' AND l_posted_flag = 'S') THEN
              l_posted_status := 'S';
           ELSE
              l_posted_status := l_accrual_posted_flag;
           END IF;
        END IF;

        return(l_posted_status);

     EXCEPTION
       WHEN OTHERS THEN
          RETURN('');

     END Get_Posted_Status;

     -----------------------------------------------------------------------

     -----------------------------------------------------------------------
     -- Procedure Select_Summary calculates the initial value for the
     -- distribution line total for an invoice.
     --

     PROCEDURE Select_Summary(X_Invoice_Id       IN NUMBER,
                              X_Total            IN OUT NOCOPY NUMBER,
                              X_Total_Rtot_DB    IN OUT NOCOPY NUMBER,
                              X_LINE_NUMBER      IN NUMBER, --Bug4539547
                              X_Calling_Sequence IN VARCHAR2)
     IS
       current_calling_sequence  VARCHAR2(2000);
       debug_info                VARCHAR2(100);
     BEGIN

        -- Update the calling sequence
        --
        current_calling_sequence :=
           'AP_INVOICE_DISTRIBUTIONS_PKG.Select_Summary<-'||X_Calling_Sequence;

        debug_info := 'Select from ap_invoice_distributions';

        -- eTax Uptake.
        -- This select should return the distribution total.  Prepayment and
        -- Prepayment Tax amount should be included if the flag
        -- invoice_includes_prepay_flag is set ot Y.
       --Bug4539547 Added IF statement
       If (X_LINE_NUMBER is null) then
        SELECT NVL(SUM(aid.amount), 0)
          INTO X_Total
          FROM ap_invoice_distributions_all aid,
               ap_invoice_lines_all ail
         WHERE ail.invoice_id = X_Invoice_Id
           AND ail.invoice_id = aid.invoice_id
           AND ail.line_number = aid.invoice_line_number
           AND ((aid.line_type_lookup_code NOT IN ('PREPAY', 'AWT', 'RETAINAGE')
                 AND aid.prepay_distribution_id IS NULL)
                 OR  (ail.line_type_lookup_code = 'RETAINAGE RELEASE'
                      AND aid.line_type_lookup_code = 'RETAINAGE')
                 OR  NVL(ail.invoice_includes_prepay_flag,'N') = 'Y');
        else
        SELECT NVL(SUM(aid.amount), 0)
          INTO X_Total
          FROM ap_invoice_distributions_all aid,
               ap_invoice_lines_all ail
         WHERE ail.invoice_id = X_Invoice_Id
           AND ail.invoice_id = aid.invoice_id
           AND ail.line_number = aid.invoice_line_number
           AND ail.line_number = X_LINE_NUMBER;

            --commented below condition for the bug 7312805/7244811
           /*AND ((aid.line_type_lookup_code NOT IN ('PREPAY', 'AWT', 'RETAINAGE')
                 AND aid.prepay_distribution_id IS NULL)
                 OR  (ail.line_type_lookup_code = 'RETAINAGE RELEASE'
                      AND aid.line_type_lookup_code = 'RETAINAGE')
                 OR  NVL(ail.invoice_includes_prepay_flag,'N') = 'Y');*/
        end if;

        X_Total_Rtot_DB := X_Total;

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||X_Invoice_Id
                                          ||',Total = '||X_Total
                                          ||',Total RTOT DB = '||
                                              X_Total_Rtot_DB);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;
     END Select_Summary;

 -----------------------------------------------------------------------

     -----------------------------------------------------------------------
     -- Procedure Set_Packet_Id reads the packet id for an invoice.
     --

     PROCEDURE Set_Inv_Packet_Id(X_Invoice_Id       IN NUMBER,
                                 X_Packet_id        IN OUT NOCOPY NUMBER,
                                 X_Calling_Sequence IN VARCHAR2)
     IS
       current_calling_sequence  VARCHAR2(2000);
       debug_info                VARCHAR2(100);
     BEGIN

        -- Update the calling sequence
        --
        current_calling_sequence :=
         'AP_INVOICE_DISTRIBUTION_PKG.Set_Inv_Packet_Id<-'||X_Calling_Sequence;

        debug_info := 'Select from ap_invoice_distributions';

        select decode(count(distinct(packet_id)),1,max(packet_id),'')
        into   X_Packet_Id
        from   ap_invoice_distributions
        where  invoice_id = X_Invoice_Id
        and    packet_id is not null;

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||X_Invoice_Id
                                         ||', Packet Id = '||X_Packet_Id);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END Set_Inv_Packet_Id;

     -----------------------------------------------------------------------

     -----------------------------------------------------------------------
     -- Function Query_New_Packet_Id returns true if the packet id has changed
     -- for a particular distribution.
     --

     FUNCTION Query_New_Packet_Id(X_Rowid            VARCHAR2,
                                  X_Packet_Id        NUMBER,
                                  X_Calling_Sequence VARCHAR2)
        RETURN BOOLEAN
     IS
        dummy  VARCHAR2(10);
        current_calling_sequence  VARCHAR2(2000);
        debug_info                VARCHAR2(100);
     BEGIN

        -- Update the calling sequence
        --
        current_calling_sequence :=
     'AP_INVOICE_DISTRIBUTIONS_PKG.Query_New_Packet_Id<-'||X_Calling_Sequence;

        debug_info := 'Select from ap_invoice_distributions';

        select 'TRUE'
        into   dummy
        from   ap_invoice_distributions
        where  rowid = X_Rowid
        and    NVL(packet_id, -1) <> NVL(X_Packet_Id, -1);

        return(TRUE);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN(FALSE);
       WHEN OTHERS THEN
          if (SQLCODE <> -20001) then
            FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||X_Rowid
                                           ||', Packet Id = '||X_Packet_Id);
          end if;
          APP_EXCEPTION.RAISE_EXCEPTION;
     END Query_New_Packet_Id;

     -----------------------------------------------------------------------

     -----------------------------------------------------------------------
     -- Function All_Encumbered returns true if given a distribution line
     -- all other distribution lines for the invoice have been encumbered.
     --

     FUNCTION All_Encumbered(X_Invoice_Id       NUMBER,
                             X_Rowid            VARCHAR2,
                             X_Calling_Sequence VARCHAR2)
        RETURN BOOLEAN
     IS
        dummy  VARCHAR2(80);
        current_calling_sequence   VARCHAR2(2000);
        debug_info                 VARCHAR2(100);
     BEGIN

        -- Update the calling sequence
        --
        current_calling_sequence :=
           'AP_INVOICE_DISTRIBUTIONS_PKG.All_Encumbered<-'||X_Calling_Sequence;

        debug_info := 'Select from sys.dual';

        select 'There are encumbered dists'
        into   dummy
        from   sys.dual
        where  not exists (select 'There are other unencumbered dists'
                             from ap_invoice_distributions
                            where invoice_id = X_Invoice_Id
                              and NVL(match_status_flag, 'N') <> 'A'
                              and rowid <> X_Rowid);

        return(TRUE);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          RETURN(FALSE);
       WHEN OTHERS THEN
          if (SQLCODE <> -20001) then
            FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||X_Invoice_Id
                                           ||', Rowid = '||X_Rowid);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
          end if;
          APP_EXCEPTION.RAISE_EXCEPTION;
     END All_Encumbered;

         -----------------------------------------------------------------------

    -----------------------------------------------------------------------
    -- Function Check_Cash_Basis_Paid returns true if given an invoice
    -- we are running cash basis and the invoice has 1 of 2 conditions
    -- set to TRUE; 1) There are posted payments and no voids.
    --              2) There are unposted payments linked to a void.
    --

     FUNCTION Check_Cash_Basis_Paid(X_Invoice_Id       NUMBER,
                                    X_Calling_Sequence VARCHAR2)
        RETURN BOOLEAN
     IS
        p_acct_meth    ap_system_parameters.accounting_method_option%TYPE;
        s_acct_meth    ap_system_parameters.secondary_accounting_method%TYPE;
        dummy          VARCHAR2(80);
        current_calling_sequence  VARCHAR2(2000);
        debug_info                VARCHAR2(100);
        l_cash_basis   VARCHAR2(1);
        CURSOR  posted_no_voids IS
           SELECT 'Has posted payment with no corresponding void'
           FROM   ap_invoice_payments p1
           WHERE  p1.invoice_id = X_Invoice_Id
           AND    nvl(p1.cash_posted_flag, 'N') = 'Y'
           AND    NOT EXISTS (SELECT 'This is the void partner'
                              FROM ap_invoice_payments p2
                              WHERE p2.invoice_id = p1.invoice_id
                              AND   p2.check_id = p1.check_id
                              AND   p2.payment_num = p1.payment_num
                              AND   p2.amount = ( -1 * p1.amount));
       CURSOR  unposted_w_voids IS
          SELECT 'Has unposted payment that is linked to a voided check'
          FROM   ap_invoice_payments p, ap_checks c
          WHERE  p.invoice_id = X_Invoice_Id
          AND    nvl(p.cash_posted_flag,'N') <> 'Y'
          AND    p.check_id = c.check_id
          AND    c.void_date IS NOT NULL;
     BEGIN

        -- Update the calling sequence
        --
        current_calling_sequence :=
    'AP_INVOICE_DISTRIBUTIONS_PKG.Check_Cash_Basis_Paid<-'||X_Calling_Sequence;

        debug_info := 'Select accounting method from SOB';

        SELECT NVL(sla_ledger_cash_basis_flag, 'N')
        INTO   l_cash_basis
        FROM   ap_system_parameters ASP,
               gl_sets_of_books  SOB,
               ap_invoices   AI
        WHERE  AI.invoice_id = x_invoice_id
        AND    AI.org_id = ASP.org_id
        AND    asp.set_of_books_id = sob.set_of_books_id;

        if (l_cash_basis <>'Y') then
          return(FALSE);
        end if;

        debug_info := 'Select from ap_invoice_payments';

        OPEN posted_no_voids;
        debug_info := 'Fetch cursor posted_no_voids';
        FETCH posted_no_voids INTO dummy;
        if (posted_no_voids%ROWCOUNT <> 0) then
          debug_info := 'Close cursor posted_no_voids - ROWCOUNT NOT ZERO';
          CLOSE posted_no_voids;
          return(TRUE);
        end if;
        debug_info := 'Close cursor posted_no_voids';
        CLOSE posted_no_voids;

        debug_info := 'Select from ap_invoice_payments and ap_checks';

        OPEN unposted_w_voids;
        debug_info := 'Fetch cursor unposted_w_voids';
        FETCH unposted_w_voids INTO dummy;
        if (unposted_w_voids%ROWCOUNT <> 0) then
          debug_info := 'Close cursor unposted_w_voids';
          CLOSE unposted_w_voids;
          return(TRUE);
        end if;

        return(FALSE);

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||X_Invoice_Id);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END Check_Cash_Basis_Paid;


     -----------------------------------------------------------------------



     -----------------------------------------------------------------------
     -- Procedure Adjust_PO is given a po_distribution_id, a line_location_id,
     -- an amount billed and a quantity_billed it adjusts PO accordingly.
     --

     PROCEDURE Adjust_PO(X_PO_Distribution_Id NUMBER,
                         X_Line_Location_id   NUMBER,
                         X_Quantity_Billed    NUMBER,
                         X_Amount_Billed      NUMBER,
                         X_Match_Basis        VARCHAR2,  /* Amount Based Matching */
                         X_Matched_Uom        VARCHAR2,  /* Bug 4121303 */
                         X_Calling_Sequence   VARCHAR2)
     IS
       l_po_ap_dist_rec          PO_AP_DIST_REC_TYPE;
       l_po_ap_line_loc_rec      PO_AP_LINE_LOC_REC_TYPE;
       l_return_status           VARCHAR2(100);
       l_msg_data                VARCHAR2(4000);
       current_calling_sequence  VARCHAR2(2000);
       l_debug_info              VARCHAR2(100);
       l_api_name		 VARCHAR2(50);


    BEGIN

       l_api_name := 'Adjust_Po';
       current_calling_sequence := 'AP_INVOICE_DISTRIBUTIONS_PKG.Adjust_PO<-'||X_Calling_Sequence;

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_DISTRIBUTIONS_PKG.Adjust_Po(-)');
       END IF;

       l_debug_info := 'Create l_po_ap_dist_rec object';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

       l_po_ap_dist_rec.add_change(
				 p_po_distribution_id => x_po_distribution_id,
                                 p_uom_code            => x_matched_uom,
                                 p_quantity_billed     => x_quantity_billed,
                                 p_amount_billed       => x_amount_billed,
                                 p_quantity_financed   => NULL,
                                 p_amount_financed     => NULL,
                                 p_quantity_recouped   => NULL,
                                 p_amount_recouped     => NULL,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL
                                );

       l_debug_info := 'Create l_po_ap_line_loc_rec object and populate the data';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => x_line_location_id,
                                 p_uom_code            => x_matched_uom,
                                 p_quantity_billed     => x_quantity_billed,
                                 p_amount_billed       => x_amount_billed,
                                 p_quantity_financed   => NULL,
                                 p_amount_financed     => NULL,
                                 p_quantity_recouped   => NULL,
                                 p_amount_recouped     => NULL,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL
                                );

       l_debug_info := 'Call the PO_AP_INVOICE_MATCH_GRP to update the Po Distributions and Po Line Locations';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                                        P_Api_Version 	       => 1.0,
                                        P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
                                        P_Dist_Changes_Rec     => l_po_ap_dist_rec,
                                        X_Return_Status        => l_return_status,
                                        X_Msg_Data             => l_msg_data);


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_DISTRIBUTIONS_PKG.Adjust_Po(-)');
       END IF;

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS','PO Distribution Id = '||
                        X_PO_Distribution_Id||', Line location Id = '||
                          X_Line_Location_Id||', Quantity Billed = '||
                           X_Quantity_Billed||', Amount Billed = '||
                           X_Amount_Billed);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END Adjust_PO;


  -----------------------------------------------------------------------

     -----------------------------------------------------------------------
     -- Function Substrbyte is used in substitution for the PL/SQL SUBSTRB.
     -- Reason: Currently (as of 7/20/95) SUBSTRB in Forms does not work
     -- properly.
     --

     FUNCTION Substrbyte(X_String           VARCHAR2,
                         X_Start            NUMBER,
                         X_End              NUMBER,
                         X_Calling_Sequence VARCHAR2)
       RETURN VARCHAR2
     IS
       result_str  VARCHAR2(2000) := '';
       current_calling_sequence   VARCHAR2(2000);
       debug_info                 VARCHAR2(100);
     BEGIN

       -- Update the calling sequence
       --
       current_calling_sequence :=
       'AP_INVOICE_DISTRIBUTION_PKG.Substrbyte<-'||X_Calling_Sequence;

       debug_info := 'Select from sys.dual';

       select SUBSTRB(X_String, X_Start, X_End)
       into   result_str
       from   sys.dual;

       return(result_str);

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS', 'String = '||X_String
                                         ||', Start = '||X_Start
                                         ||', End = '||X_End);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END Substrbyte;

     -----------------------------------------------------------------------
     -- FUNCTION insert_from_dist_set inserts records into
     -- ap_invoice_distributions given a line number, distribution set id and
     -- table of distribution information.  It returns FALSE if an error
     -- is encountered.
     -- Called from ap_invoice_lines_pkg.insert_from_dist_set or from Import
     -----------------------------------------------------------------------
     FUNCTION Insert_From_Dist_Set(
              X_batch_id            IN   NUMBER,
              X_invoice_id          IN   NUMBER,
              X_line_number         IN   NUMBER,
              X_dist_tab            IN   AP_INVOICE_LINES_PKG.dist_tab_type,
              X_Generate_Permanent  IN   VARCHAR2 DEFAULT 'N',
              X_Debug_Info          OUT  NOCOPY VARCHAR2,
              X_Debug_Context       OUT  NOCOPY VARCHAR2,
              X_Calling_Sequence    IN   VARCHAR2) RETURN BOOLEAN
     IS

     l_distribution_class     AP_INVOICE_DISTRIBUTIONS.DISTRIBUTION_CLASS%TYPE;
     l_created_by             AP_INVOICE_DISTRIBUTIONS.CREATED_BY%TYPE;
     l_inv_dist_id 	      AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;
     l_last_update_login
       AP_INVOICE_DISTRIBUTIONS.LAST_UPDATE_LOGIN%TYPE;
     l_existing_distributions NUMBER := 0;
     i                        BINARY_INTEGER := 0;
     current_calling_sequence VARCHAR2(2000);
     debug_info               VARCHAR2(100);
     --Bug 4539462 DBI logging
     l_dbi_key_value_list          ap_dbi_pkg.r_dbi_key_value_arr;
     l_calling_module        varchar2(30);   --bug7014798


	 l_country_code VARCHAR2(20);  --bug 9169915
	 l_org_id       NUMBER; --bug 9169915

     BEGIN

     --------------------------------------------------------------------------
     -- Step 1 - Update the calling sequence
     --------------------------------------------------------------------------
     current_calling_sequence :=
            'AP_INVOICE_DISTRIBUTIONS_PKG.insert_from_dist_set<-'||
            X_calling_sequence;

     -------------------------------------------------------------------------
     -- Step 2 - Validate line does not contain other distributions
     -------------------------------------------------------------------------
     debug_info := 'Verify line does not contain distributions';
     BEGIN
       SELECT count(*)
         INTO l_existing_distributions
         FROM ap_invoice_distributions
        WHERE invoice_id = X_invoice_id
          AND invoice_line_number = X_line_number;

       IF (l_existing_distributions <> 0) then
         X_debug_info := debug_info || ': line already has distributions';
         X_debug_context := current_calling_sequence;
         RETURN(FALSE);
       END IF;

     EXCEPTION
       WHEN OTHERS THEN
       NULL;
     END;


     -------------------------------------------------------------------------
     -- Step 3 - Set distribution class value (Permanent or Candidate)
     -------------------------------------------------------------------------
     if (X_Generate_Permanent = 'N') then
       l_distribution_class := 'CANDIDATE';
     else
       l_distribution_class := 'PERMANENT';
     end if;
     -------------------------------------------------------------------------
     -- Step 4 - Generate distributions
     -------------------------------------------------------------------------
     --bug 9169915
     select org_id
       into l_org_id
       from ap_invoices
      where invoice_id = X_invoice_id;

     SELECT JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null)
       INTO l_country_code
       FROM DUAL;
     --bug 9169915

     FOR i in nvl(X_dist_tab.FIRST, 0) .. nvl(X_dist_tab.LAST, -1) LOOP

	SELECT ap_invoice_distributions_s.nextval INTO l_inv_dist_id FROM DUAL;

        INSERT INTO ap_invoice_distributions (
                   batch_id,
                   invoice_id,
                   invoice_line_number,
                   invoice_distribution_id,
                   distribution_line_number,
                   line_type_lookup_code,
                   distribution_class,
                   description,
                   dist_match_type,
                   org_id,
                   dist_code_combination_id,
                   accounting_date,
                   period_name,
 		   accrual_posted_flag,
                   cash_posted_flag,
                   amount_to_post,
                   base_amount_to_post,
                   posted_amount,
                   posted_base_amount,
                   posted_flag,
                   accounting_event_id,
                   upgrade_posted_amt,
                   upgrade_base_posted_amt,
                   set_of_books_id,
                   amount,
                   base_amount,
                   rounding_amt,
                   quantity_variance,
                   base_quantity_variance,
                   match_status_flag,
                   encumbered_flag,
                   packet_id,
                   reversal_flag,
                   parent_reversal_id,
                   cancellation_flag,
                   income_tax_region,
                   type_1099,
                   stat_amount,
                   charge_applicable_to_dist_id,
                   prepay_amount_remaining,
                   prepay_distribution_id,
                   parent_invoice_id,
                   corrected_invoice_dist_id,
                   corrected_quantity,
                   other_invoice_id,
                   po_distribution_id,
                   rcv_transaction_id,
                   unit_price,
                   matched_uom_lookup_code,
                   quantity_invoiced,
                   final_match_flag,
                   related_id,
                   assets_addition_flag,
                   assets_tracking_flag,
                   asset_book_type_code,
                   asset_category_id,
                   project_id,
                   task_id,
                   expenditure_type,
                   expenditure_item_date,
                   expenditure_organization_id,
		   project_accounting_context,
                   pa_quantity,
                   pa_addition_flag,
                   award_id,
                   gms_burdenable_raw_cost,
                   awt_flag,
                   awt_group_id,
                   awt_tax_rate_id,
                   awt_gross_amount,
                   awt_invoice_id,
                   awt_origin_group_id,
                   awt_invoice_payment_id,
                   awt_withheld_amt,
                   inventory_transfer_status,
                   reference_1,
                   reference_2,
                   receipt_verified_flag,
                   receipt_required_flag,
                   receipt_missing_flag,
                   justification,
                   expense_group,
                   start_expense_date,
                   end_expense_date,
                   receipt_currency_code,
                   receipt_conversion_rate,
                   receipt_currency_amount,
                   daily_amount,
                   web_parameter_id,
                   adjustment_reason,
                   merchant_document_number,
                   merchant_name,
                   merchant_reference,
                   merchant_tax_reg_number,
                   merchant_taxpayer_id,
                   country_of_supply,
                   credit_card_trx_id,
                   company_prepaid_invoice_id,
                   cc_reversal_flag,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   global_attribute_category,
                   global_attribute1,
                   global_attribute2,
                   global_attribute3,
                   global_attribute4,
                   global_attribute5,
                   global_attribute6,
                   global_attribute7,
                   global_attribute8,
                   global_attribute9,
                   global_attribute10,
                   global_attribute11,
                   global_attribute12,
                   global_attribute13,
                   global_attribute14,
                   global_attribute15,
                   global_attribute16,
                   global_attribute17,
                   global_attribute18,
                   global_attribute19,
                   global_attribute20,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   program_application_id,
                   program_id,
                   program_update_date,
                   request_id,
		   --ETAX: Invwkb
		   intended_use,
		   --Freight and Special Charges
		   rcv_charge_addition_flag,
		---added for 7022001
		pay_awt_group_id)
       VALUES (
                   X_batch_id,                    -- batch_id
                   X_invoice_id,                  -- invoice_id
                   X_line_number,                 -- invoice_line_number
                   l_inv_dist_id,		  -- invoice_distribution_id
                   X_dist_tab(i).dist_line_num,   -- distribution_line_number
                   'ITEM',                        -- line_type_lookup_code
                   l_distribution_class,          -- distribution_class
                   X_dist_tab(i).description,     -- description
                   'NOT_MATCHED',                 -- dist_match_type
                   X_dist_tab(i).org_id,          -- l_org_id
                   X_dist_tab(i).dist_ccid,       -- dist_code_combination_id
                   X_dist_tab(i).accounting_date, -- accounting_date
                   X_dist_tab(i).period_name,     -- period_name
                   'N',                           -- accrual_posted_flag
                   'N',                           -- cash_posted_flag
                   NULL,                          -- amount_to_post
                   NULL,                          -- base_amount_to_post
                   NULL,                          -- posted_amount
                   NULL,                          -- posted_base_amount
                   'N',                           -- posted_flag
                   NULL,                          -- accounting_event_id
                   NULL,                          -- upgrade_posted_amt
                   NULL,                          -- upgrade_base_posted_amt
                   X_dist_tab(i).set_of_books_id, -- set_of_books_id
                   X_dist_tab(i).amount,          -- amount
                   X_dist_tab(i).base_amount,     -- base_amount
                   X_dist_tab(i).rounding_amt,    -- rounding_amt
                   NULL,                          -- quantity_variance
                   NULL,                          -- base_quantity_variance
		   --Invoice Lines: Distributions, changed match_status_flag
                   --to NULL from 'N'.
                   NULL,                          -- match_status_flag
                   'N',                           -- encumbered_flag
                   NULL,                          -- packet_id
                   'N',                           -- reversal_flag
                   NULL,                          -- parent_reversal_id
                   'N',                           -- cancellation_flag
                   X_dist_tab(i).income_tax_region,  -- income_tax_region
                   X_dist_tab(i).type_1099,       -- type_1099
                   NULL,                          -- stat_amount
                   NULL,                          -- charge_applicable_to_dist_id
                   NULL,                          -- prepay_amount_remaining
                   NULL,                          -- prepay_distribution_id
                   NULL,                          -- parent_invoice_id
                   NULL,                          -- corrected_inv_dist_id
                   NULL,                          -- corrected_quantity
                   NULL,                          -- other_invoice_id
                   NULL,                          -- po_distribution_id
                   NULL,                          -- rcv_transaction_id
                   NULL,                          -- unit_price
                   NULL,                          -- matched_uom_lookup_code
                   NULL,                          -- quantity_invoiced
                   NULL,                          -- final_match_flag
                   NULL,                          -- related_id
                   'U',                           -- assets_addition_flag
                   X_dist_tab(i).assets_tracking_flag,-- assets_tracking_flag
                   X_dist_tab(i).asset_book_type_code,-- asset_book_type_code
                   X_dist_tab(i).asset_category_id,   -- asset_category_id
                   X_dist_tab(i).project_id,      -- project_id
                   X_dist_tab(i).task_id,         -- task_id
                   X_dist_tab(i).expenditure_type,-- expenditure_type
                   X_dist_tab(i).expenditure_item_date, -- expenditure_item_date
                   X_dist_tab(i).expenditure_organization_id, -- expenditure_organization_id
		   X_dist_tab(i).project_accounting_context, --project_accounting_context
                   X_dist_tab(i).pa_quantity,     -- pa_quantity
                   X_dist_tab(i).pa_addition_flag,-- pa_addition_flag
                   X_dist_tab(i).award_id,        -- award_id
                   NULL,                          -- gms_burdenable_raw_cost
                   NULL,                          -- awt_flag
                   X_dist_tab(i).awt_group_id,    -- awt_group_id
                   NULL,                          -- awt_tax_rate_id
                   NULL,                          -- awt_gross_amount
                   NULL,                          -- awt_invoice_id
                   NULL,                          -- awt_origin_group_id
                   NULL,                          -- awt_invoice_payment_id
                   NULL,                          -- awt_withheld_amt
                   'N',                           -- inventory_transfer_status
		   --Bug9296445
                   X_dist_tab(i).reference_1,     --NULL,   -- reference_1
                   X_dist_tab(i).reference_2,     --NULL,   -- reference_2
                   NULL,                          -- receipt_verified_flag
                   NULL,                          -- receipt_required_flag
                   NULL,                          -- receipt_missing_flag
                   NULL,                          -- justification
                   NULL,                          -- expense_group
                   NULL,                          -- start_expense_date
                   NULL,                          -- end_expense_date
                   NULL,                          -- receipt_currency_code
                   NULL,                          -- receipt_conversion_rate
                   NULL,                          -- receipt_currency_amount
                   NULL,                          -- daily_amount
                   NULL,                          -- web_parameter_id
                   NULL,                          -- adjustment_reason
                   NULL,                          -- merchant_document_number
                   NULL,                          -- merchant_name
                   NULL,                          -- merchant_reference
                   NULL,                          -- merchant_tax_reg_number
                   NULL,                          -- merchant_taxpayer_id
                   NULL,                          -- country_of_supply
                   NULL,                          -- credit_card_trx_id
                   NULL,                          -- company_prepaid_invoice_id
                   NULL,                          -- cc_reversal_flag
                   X_dist_tab(i).attribute_category,  -- attribute_category
                   X_dist_tab(i).attribute1,      -- attribute1
                   X_dist_tab(i).attribute2,      -- attribute2
                   X_dist_tab(i).attribute3,      -- attribute3
                   X_dist_tab(i).attribute4,      -- attribute4
                   X_dist_tab(i).attribute5,      -- attribute5
                   X_dist_tab(i).attribute6,      -- attribute6
                   X_dist_tab(i).attribute7,      -- attribute7
                   X_dist_tab(i).attribute8,      -- attribute8
                   X_dist_tab(i).attribute9,      -- attribute9
                   X_dist_tab(i).attribute10,     -- attribute10
                   X_dist_tab(i).attribute11,     -- attribute11
                   X_dist_tab(i).attribute12,     -- attribute12
                   X_dist_tab(i).attribute13,     -- attribute13
                   X_dist_tab(i).attribute14,     -- attribute14
                   X_dist_tab(i).attribute15,     -- attribute15
                   NULL,                          -- global_attribute_category
                   NULL,                          -- global_attribute1
                   NULL,                          -- global_attribute2
		   --bugfix:4674194
		   Decode(AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_OPTION,
		   	  'Y',X_dist_tab(i).global_attribute3,''), --global_attribute3
                   NULL,                          -- global_attribute4
                   NULL,                          -- global_attribute5
                   NULL,                          -- global_attribute6
                   NULL,                          -- global_attribute7
                   NULL,                          -- global_attribute8
                   NULL,                          -- global_attribute9
                   NULL,                          -- global_attribute10
                   NULL,                          -- global_attribute11
                   NULL,                          -- global_attribute12
                   NULL,                          -- global_attribute13
                   NULL,                          -- global_attribute14
                   NULL,                          -- global_attribute15
                   NULL,                          -- global_attribute16
                   NULL,                          -- global_attribute17
                   NULL,                          -- global_attribute18
                   NULL,                          -- global_attribute19
                   NULL,                          -- global_attribute20
                   FND_GLOBAL.user_id,            -- created_by
                   SYSDATE,                       -- creation_date
                   FND_GLOBAL.user_id,            -- last_updated_by
                   SYSDATE,                       -- last_update_date
                   FND_GLOBAL.login_id,           -- last_update_login
                   NULL,                          -- program_application_id
                   NULL,                          -- program_id
                   NULL,                          -- program_update_date
                   NULL,                          -- request_id
	  X_Dist_Tab(i).intended_use,    -- intended_use
	 'N',				  -- rcv_charge_addition_flag
	 X_dist_tab(i).pay_awt_group_id    -- added for pay_awt_group_id for 7022001
                   );

		   IF x_dist_tab(i).award_id Is Not Null Then
			GMS_AP_API.CREATE_AWARD_DISTRIBUTIONS
				( p_invoice_id		     => x_invoice_id,
				  p_distribution_line_number => x_dist_tab(i).dist_line_num,
				  p_invoice_distribution_id  => l_inv_dist_id,
				  p_award_id                 => x_dist_tab(i).award_id,
				  p_mode		     => 'AP',
				  p_dist_set_id		     => NULL,
				  p_dist_set_line_number     => NULL);
		   END IF ;

	 --bug 9169915 bug9737142
	 IF l_country_code IN ('AR','CO') THEN
   	   JL_ZZ_AP_AWT_DEFAULT_PKG.SUPP_WH_DEF (X_invoice_id,
	                                         X_line_number,
						 l_inv_dist_id,
						 NULL);
         END IF;
	 --bug 9169915


     END LOOP;


     --Bug 4539462 DBI logging
     SELECT invoice_distribution_id
     BULK COLLECT INTO  l_dbi_key_value_list
     FROM ap_invoice_distributions
     WHERE invoice_id = X_invoice_id;

     AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'I',
               p_key_value1 => X_invoice_id,
               p_key_value_list => l_dbi_key_value_list,
                p_calling_sequence => current_calling_sequence);


  ----------------------------------------------------------------------------
  -- Step 5 - Update generate distributions flag in invoice line but only if
  -- generating distributions in permanent mode.
  ----------------------------------------------------------------------------
  debug_info := 'Setting generate distributions flag to Done';
  if (l_distribution_class = 'PERMANENT') then
    BEGIN
      UPDATE AP_INVOICE_LINES
         SET GENERATE_DISTS = 'D'
         WHERE invoice_id = X_invoice_id
         AND line_number = X_line_number;
    EXCEPTION
      WHEN OTHERS THEN
        X_debug_info := debug_info || ': Error encountered';
        X_debug_context := current_calling_sequence;
        return (FALSE);
    END;
  end if;

  return(TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      X_debug_info := 'Error encountered';
      X_debug_context := current_calling_sequence;
      return (FALSE);

  END insert_from_dist_set;


  -----------------------------------------------------------------------
    -- PROCEDURE update_distributions updates columns in
    --   AP_INVOICE_DISTRIBUTIONS such as match_status_flag, base_amount,
    --   type_1099, income_tax_region.
    -- PRECONDITION: Procedure is called during POST-FORMS-COMMIT
    -----------------------------------------------------------------------

    PROCEDURE update_distributions (
              X_invoice_id                   IN            number,
              X_line_number                  IN            number,
              X_type_1099                    IN            varchar2,
              X_income_tax_region            IN            varchar2,
              X_vendor_changed_flag          IN OUT NOCOPY varchar2,
              X_update_base                  IN OUT NOCOPY varchar2,
              X_reset_match_status           IN OUT NOCOPY varchar2,
              X_update_occurred              IN OUT NOCOPY varchar2,
              X_calling_sequence             IN            varchar2)
    IS
      l_purch_encumbrance_flag varchar2(10);
      l_multi_currency_flag    varchar2(10);
      l_base_dist_total        number;
      l_dist_total             number;
      l_base_currency_code
          ap_system_parameters.base_currency_code%TYPE;
      l_exchange_rate
          ap_invoices.exchange_rate%TYPE;
      l_exchange_rate_type
          ap_invoices.exchange_rate_type%TYPE;
      l_exchange_date
          ap_invoices.exchange_date%TYPE;
      l_base_amount
          ap_invoices.base_amount%TYPE;
      l_invoice_amount
          ap_invoices.invoice_amount%TYPE;
      l_invoice_currency_code
           ap_invoices.invoice_currency_code%TYPE;
      l_last_update_login
          ap_invoices.last_update_login%TYPE;
      l_last_updated_by
          ap_invoices.last_updated_by%TYPE;
      l_last_update_date
          ap_invoices.last_update_date%TYPE;
      l_invoice_distribution_id
           ap_invoice_distributions.invoice_distribution_id%TYPE;
      l_project_id
          ap_invoice_distributions.project_id%TYPE;
      l_task_id
          ap_invoice_distributions.task_id%TYPE;
      l_award_id
          ap_invoice_distributions.award_id%TYPE;  -- OGM_0.0 changes
      l_expenditure_item_date  DATE;
      l_expenditure_type
          ap_invoice_distributions.expenditure_type%TYPE;
      l_employee_id
          po_vendors.employee_id%TYPE;
      l_pa_quantity
          ap_invoice_distributions.pa_quantity%TYPE;
      l_dist_amount
          ap_invoice_distributions.amount%TYPE;
      l_dist_base_amount
          ap_invoice_distributions.base_amount%TYPE;
      l_expenditure_organization_id
          ap_invoice_distributions.expenditure_organization_id%TYPE;

      l_vendor_id              NUMBER;
      l_vendor_site_id         NUMBER;
      l_invoice_date           DATE;
      l_gl_allow_tax_override
          GL_TAX_OPTION_ACCOUNTS.ALLOW_TAX_CODE_OVERRIDE_FLAG%TYPE;
      l_tax_recoverable_flag
          ap_invoice_distributions.tax_recoverable_flag%TYPE;
      l_po_distribution_id
          ap_invoice_distributions.po_distribution_id%TYPE;
      l_line_location_id
          po_distributions.line_location_id%TYPE;
      l_accrue_on_receipt
           po_distributions.accrue_on_receipt_flag%TYPE;
      l_dist_count                   NUMBER;
      l_user_id                      NUMBER;
      l_dist_attribute_category
          ap_invoice_distributions.attribute_category%TYPE;
      l_dist_attribute1        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute2        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute3        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute4        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute5        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute6        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute7        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute8        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute9        ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute10       ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute11       ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute12       ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute13       ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute14       ap_invoice_distributions.attribute1%TYPE;
      l_dist_attribute15       ap_invoice_distributions.attribute1%TYPE;
      l_dist_posted_flag       ap_invoice_distributions.posted_flag%TYPE;
      l_dist_reversal_flag     ap_invoice_distributions.reversal_flag%TYPE;
      l_inv_attribute_category ap_invoices.attribute_category%TYPE;
      l_inv_attribute1         ap_invoices.attribute1%TYPE;
      l_inv_attribute2         ap_invoices.attribute1%TYPE;
      l_inv_attribute3         ap_invoices.attribute1%TYPE;
      l_inv_attribute4         ap_invoices.attribute1%TYPE;
      l_inv_attribute5         ap_invoices.attribute1%TYPE;
      l_inv_attribute6         ap_invoices.attribute1%TYPE;
      l_inv_attribute7         ap_invoices.attribute1%TYPE;
      l_inv_attribute8         ap_invoices.attribute1%TYPE;
      l_inv_attribute9         ap_invoices.attribute1%TYPE;
      l_inv_attribute10        ap_invoices.attribute1%TYPE;
      l_inv_attribute11        ap_invoices.attribute1%TYPE;
      l_inv_attribute12        ap_invoices.attribute1%TYPE;
      l_inv_attribute13        ap_invoices.attribute1%TYPE;
      l_inv_attribute14        ap_invoices.attribute1%TYPE;
      l_inv_attribute15        ap_invoices.attribute1%TYPE;
      l_msg_application        VARCHAR2(25);
      l_msg_type               VARCHAR2(25);
      l_msg_token1             VARCHAR2(30);
      l_msg_token2             VARCHAR2(30);
      l_msg_token3             VARCHAR2(30);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(30);
      l_billable_flag          VARCHAR2(25);
      l_invoice_type_lookup_code
          ap_invoices.invoice_type_lookup_code%TYPE;
      l_chart_of_accounts_id           NUMBER;
      l_DIST_CODE_COMBINATION_ID       NUMBER;
      l_concat_ids                     Varchar2(2000);
      l_concat_segs                    Varchar2(2000);
      l_concat_descrs                  Varchar2(300);
      l_errmsg                         Varchar2(1300);
      current_calling_sequence         VARCHAR2(2000);
      debug_info                       VARCHAR2(100);
      debug_context                    VARCHAR2(2000);
      l_key_value_list                 ap_dbi_pkg.r_dbi_key_value_arr; -- bug 9772522
      l_line_number
          ap_invoice_lines.line_number%TYPE;
      l_rounded_dist_id
          ap_invoice_distributions.invoice_distribution_id%type;
      l_round_amt_exists               BOOLEAN := FALSE;
      l_rounded_amt                    NUMBER;
       --Bug 4539462 DBI logging
       l_dbi_key_value_list        ap_dbi_pkg.r_dbi_key_value_arr;
       l_org_id			   ap_invoices_all.org_id%type;

      l_base_amt                   NUMBER; --6892789
      l_modified_dist_rounding_amt NUMBER; --6892789
      l_round_dist_id_list         AP_INVOICE_LINES_PKG.distribution_id_tab_type; --6892789

      cursor invoice_line_cursor is
      SELECT exchange_rate,
             exchange_rate_type,
             exchange_date,
             AI.invoice_currency_code,
             invoice_type_lookup_code,
             invoice_date,
             DECODE(x_line_number, null,
                    AI.last_update_login,
                    AIL.last_update_login ),
             DECODE(x_line_number, null,
                    AI.last_updated_by,
                    AIL.last_updated_by ),
             DECODE(x_line_number, null,
                    AI.last_update_date,
                    AIL.last_update_date ),
             AIL.line_number,
	     AI.org_id
      FROM   ap_invoices AI,
             ap_invoice_lines AIL
      WHERE  AI.invoice_id = X_invoice_id
        AND  AIL.invoice_id = AI.invoice_id
        AND  AIL.line_number = NVL(X_line_number, AIL.line_number);

      cursor pa_related_dist_cur is
      SELECT AID.invoice_distribution_id,
             AID.project_id,
             AID.task_id,
             AID.award_id,  -- OGM_0.0 changes
             AID.expenditure_item_date,
             AID.expenditure_type,
             PV.employee_id,
             AID.pa_quantity,
             AID.amount,
             AID.base_amount,
             AID.expenditure_organization_id,
             AI.vendor_id,
             AI.vendor_site_id,
             AID.tax_recoverable_flag,
             PD.line_location_id,
             PD.accrue_on_receipt_flag,
             AID.po_distribution_id,
             AID.attribute_category,
             AID.attribute1,
             AID.attribute2,
             AID.attribute3,
             AID.attribute4,
             AID.attribute5,
             AID.attribute6,
             AID.attribute7,
             AID.attribute8,
             AID.attribute9,
             AID.attribute10,
             AID.attribute11,
             AID.attribute12,
             AID.attribute13,
             AID.attribute14,
             AID.attribute15,
             NVL(AID.posted_flag,'N'),
             NVL(AID.reversal_flag,'N'),
             AI.attribute_category,
             AI.attribute1,
             AI.attribute2,
             AI.attribute3,
             AI.attribute4,
             AI.attribute5,
             AI.attribute6,
             AI.attribute7,
             AI.attribute8,
             AI.attribute9,
             AI.attribute10,
             AI.attribute11,
             AI.attribute12,
             AI.attribute13,
             AI.attribute14,
             AI.attribute15,
             gsob.chart_of_accounts_id
      FROM ap_invoice_distributions AID,
           ap_invoices AI,
           ap_suppliers PV,
           po_distributions PD,
           ap_system_parameters ap,
           gl_sets_of_books gsob
      WHERE  AI.invoice_id = X_invoice_id
        AND  AID.invoice_id = AI.invoice_id
        AND  AID.invoice_line_number =
             NVL(X_line_number, invoice_line_number)
        AND  AID.project_id IS NOT NULL
        AND  AI.vendor_id = PV.vendor_id
        AND  AID.po_distribution_id = PD.po_distribution_id (+)
        AND  AID.last_update_login = -3
        AND  ap.set_of_books_id = gsob.set_of_books_id
        AND  ap.set_of_books_id = AID.set_of_books_id
	AND  ap.org_id = ai.org_id;

        --Bug 1902980 last_update_login is set to -3 if the
        --record changes before reaching the PA code.
  BEGIN
    -- Update the calling sequence
    current_calling_sequence :=
        'AP_INVOICE_DISTRIBUTIONS_PKG.update_distributions<-'||
         X_calling_sequence;

    /*-----------------------------------------------------------------+
     |  First, assume that an update to AP_INVOICE_DISTRIBUTIONS       |
     |  will not occur.  We will override the this default value       |
     |  if an update does occur.                                       |
     +-----------------------------------------------------------------*/

    X_update_occurred := 'N';


    -- Bug 5052593 -- removed redundant code
    ----------------------------------------------------------
    --debug_info := 'Select from ap_system_parameters and
    --		   financials_system_parameters';
    ----------------------------------------------------------
     --SELECT FSP.purch_encumbrance_flag,
     --       SP.multi_currency_flag,
     --	    SP.base_currency_code
     --INTO l_purch_encumbrance_flag,
     --     l_multi_currency_flag,
     --	  l_base_currency_code
     --FROM financials_system_parameters FSP,
     --     ap_system_parameters SP;

    debug_info := 'select AP_INVOICES info';

    /*-----------------------------------------------------------------+
     |  Fetch the invoice information that we need in order to update  |
     |  the distribution base amounts                                  |
     +-----------------------------------------------------------------*/

    OPEN invoice_line_cursor;
    debug_info := 'Fetch cursor invoice_cursor';
    LOOP
    FETCH invoice_line_cursor
     INTO l_exchange_rate,
          l_exchange_rate_type,
          l_exchange_date,
          l_invoice_currency_code,
          l_invoice_type_lookup_code,
          l_invoice_date,
          l_last_update_login,
          l_last_updated_by,
          l_last_update_date,
          l_line_number,
	  l_org_id;
    EXIT WHEN invoice_line_cursor%NOTFOUND;

    ----------------------------------------------------------
    debug_info := 'Select from ap_system_parameters and
                  financials_system_parameters';
    ----------------------------------------------------------
       SELECT FSP.purch_encumbrance_flag,
              SP.multi_currency_flag,
              SP.base_currency_code
         INTO l_purch_encumbrance_flag,
              l_multi_currency_flag,
              l_base_currency_code
         FROM financials_system_parameters FSP,
              ap_system_parameters SP
	 WHERE sp.org_id = l_org_id
	  AND  sp.org_id = fsp.org_id;

      ---------------------------------------------------------
      debug_info := 'Update AP_INVOICE_DISTRIBUTIONS tax info';
      ---------------------------------------------------------

    /*-----------------------------------------------------------------+
     |  Update 1099 type and income tax region for each distribution   |
     |  line if the vendor changed (test performed in PRE-UPDATE)      |
     +-----------------------------------------------------------------*/

      IF (nvl(X_vendor_changed_flag,'N') = 'Y') THEN
        UPDATE ap_invoice_distributions
           SET type_1099 = X_type_1099,
               income_tax_region = X_income_tax_region
         WHERE invoice_id = X_invoice_id
           AND invoice_line_number = NVL(X_line_number, invoice_line_number);

        IF (SQL%ROWCOUNT > 0) THEN
          X_update_occurred := 'Y';
        END IF;

        -- Reset the vendor changed flag
        X_vendor_changed_flag := 'N';

      END IF; -- end of x_vendor_changed_flag

      --------------------------------------------------------------
      debug_info := 'Update AP_INVOICE_DISTRIBUTIONS match status';
      --------------------------------------------------------------

       -- Reset the match status flags if X_reset_match_status
       -- is Y and encumbrance is not on.
       -- Don't change NULLS to N as these have never been through
       -- AutoApproval
       --
      UPDATE ap_invoice_distributions
         SET match_status_flag = 'N'
       WHERE invoice_id = X_invoice_id
         AND invoice_line_number = NVL( x_line_number, invoice_line_number)
         --Bug 5003892  AND l_purch_encumbrance_flag <> 'Y'
         AND nvl(X_reset_match_status,'N') = 'Y'
         AND NVL(match_status_flag,'N') <> 'N'
	 -- Bug 9945411 Begin
         AND NVL( posted_flag, 'N' ) = 'N'
	 AND NVL( cash_posted_flag, 'N' ) = 'N'
	 AND NVL( encumbered_flag, 'X' ) <> 'Y'
	 -- Bug 9945411 End
	RETURNING invoice_distribution_id
        BULK COLLECT INTO l_dbi_key_value_list;

	--Bug 4539462 DBI logging
        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'U',
               p_key_value1 => X_invoice_id,
               p_key_value_list => l_dbi_key_value_list,
                p_calling_sequence => current_calling_sequence);

      if (SQL%ROWCOUNT > 0) then
        X_update_occurred := 'Y';
      end if;

      -- Reset the reset match status flag
      X_reset_match_status := 'N';

      IF (nvl(l_multi_currency_flag,'N') = 'Y' AND
          nvl(X_update_base,'N') = 'Y') THEN

        -- Update the distributions if this is a foreign currency invoice
        -- and there is an invoice exchange rate as something has been changed
        -- Check that the base amounts sum to the invoice base amount
        -- Fire for functional currency invoices if multi-curr is enabled
        -- as it may have just been changed to functional so we want to clear
        -- all the base columns
        -- Set the exchange rate info, base amount and WHO columns
        -- for the distributions

  	   --Bugfix:4644053 changed ap_invoice_distributions
	   --to ap_invoice_distributions_all
           debug_info := 'Update AP_INVOICE_DISTRIBUTIONS base amounts';

           UPDATE AP_INVOICE_DISTRIBUTIONS_ALL
           SET base_amount        =
                   DECODE(l_base_currency_code,
                         l_invoice_currency_code, NULL,
                         ap_utilities_pkg.ap_round_currency(
                         amount * l_exchange_rate,
                                  l_base_currency_code)),
               last_update_login  =  l_last_update_login,
               last_updated_by    = l_last_updated_by,
               last_update_date   = SYSDATE
           WHERE invoice_id = X_invoice_id
           AND invoice_line_number = nvl( x_line_number, invoice_line_number)
           AND NVL(posted_flag,'N') = 'N'
           AND ( ( base_amount is null AND
                       DECODE(l_base_currency_code,
                              l_invoice_currency_code, NULL,
                              ap_utilities_pkg.ap_round_currency(
                                   amount * l_exchange_rate,
                                   l_base_currency_code)) is not null)
                 OR
                 (NVL(base_amount,0) <>
                       DECODE(l_base_currency_code,
                              l_invoice_currency_code, NULL,
                              ap_utilities_pkg.ap_round_currency(
                                  amount * l_exchange_rate,
                                  l_base_currency_code))
                  AND  NVL(reversal_flag,'N') <> 'Y'   --Bug 8347194
                                  ))
               RETURNING invoice_distribution_id
               BULK COLLECT INTO l_key_value_list;

           if (SQL%ROWCOUNT > 0) then
              X_update_occurred := 'Y';
           end if;

           -- Reset the update base flag
           X_update_base := 'N';

        --END IF;

	-- Check to see if the base amounts add up to the invoice base amount
	-- If not update the biggest distribution
	-- Only do this if the distributions add up in the entered currency

        -----------------------------------------------------------------
        debug_info := 'Call API to check if rounding amount is existing';
        -----------------------------------------------------------------


 /* modifying following code as per the bug 6892789 as there is a chance that
     distribution base amt goes to -ve value (amount being +ve) so in such case,
     adjust dist base amount upto zero and adjust the remaing amount in another
     distribution having next max amount */
    -- get the distributions which can be adjusted
    l_round_amt_exists := AP_INVOICE_LINES_PKG.round_base_amts(
                              x_invoice_id          => X_invoice_id,
                              x_line_number         => l_line_number,
                              x_reporting_ledger_id => NULL,
                              x_round_dist_id_list  => l_round_dist_id_list,
                              x_rounded_amt         => l_rounded_amt,
                              x_debug_info          => debug_info,
                              x_debug_context       => debug_context,
                              x_calling_sequence    => current_calling_sequence);

    -- adjustment required and there are existing distributions that can be adjusted
    IF ( l_round_amt_exists  AND l_round_dist_id_list.count > 0 ) THEN
      for i in 1 .. l_round_dist_id_list.count -- iterate through dists till there is no need to adjust
      loop
          IF l_rounded_amt <> 0 THEN

            -- get the existing base amount for the selected distribution
            select base_amount
            INTO   l_base_amt
            FROM   AP_INVOICE_DISTRIBUTIONS
            WHERE  invoice_id = X_invoice_id
            AND    invoice_line_number = l_line_number
            AND    invoice_distribution_id = l_round_dist_id_list(i);

            -- get the calculated adjusted base amount and rounding amount
            -- get rounding amount for the next dist, if required
            l_base_amt := AP_APPROVAL_PKG.get_adjusted_base_amount(p_base_amount => l_base_amt,
                                                                   p_rounding_amt => l_modified_dist_rounding_amt,
                                                                   p_next_line_rounding_amt => l_rounded_amt);

            -- update the calculatd base amount, rounding amount
            UPDATE AP_INVOICE_DISTRIBUTIONS
            SET    base_amount = l_base_amt,
            rounding_amt = ABS( l_modified_dist_rounding_amt ),
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
            WHERE  invoice_distribution_id = l_round_dist_id_list(i);

            if (SQL%ROWCOUNT > 0) then
              X_update_occurred := 'Y';
            end if;
          ELSE -- adjustment not required or there are no dists that can be adjusted
              EXIT;
          END IF;
     end loop;
    END IF;

/* CHANGES FOR BUG - 3025688 ** STARTS **
      /*  Commenting out PA calls as this is no more needed.
          If we are doing matching, we expect the details provided in PO
          are already validated and no more validation of PA should happen
          again. After matching if there is any change in the information
          provided in the distribution will be handled in Form validation. */
     /*-----------------------------------------------------------------+
     | For Projects, the call to flex build the account has changed,   |
     | The new design calls for calling the PA routine if the exchange |
     | rate information has changed. The exchange rate information     |
     | change in the invoice workbench leads to the variable           |
     | X_update_base being set to 'Y' so we use this same variable to  |
     | determine whether to call the PA flexbuilder routine again or   |
     | not                                                             |
     +-----------------------------------------------------------------*/

/*        ------------------------------------------------
        debug_info := 'Call PA flex builder procedures';
        ------------------------------------------------

        OPEN pa_related_dist_cur;
        l_dist_count := 0;

        LOOP
          FETCH pa_related_dist_cur INTO
                        l_invoice_distribution_id,
                        l_project_id,
                        l_task_id,
                        l_award_id,   -- OGM_0.0 changes...
                        l_expenditure_item_date,
                        l_expenditure_type,
                        l_employee_id,
                        l_pa_quantity,
                        l_dist_amount,
                        l_dist_base_amount,
                        l_expenditure_organization_id,
                        l_vendor_id,
                        l_vendor_site_id,
                        l_tax_recoverable_flag,
                        l_line_location_id,
                        l_accrue_on_receipt,   -- Bug:1609628
                        l_po_distribution_id,
                        l_dist_attribute_category,
                        l_dist_attribute1,
                        l_dist_attribute2,
                        l_dist_attribute3,
                        l_dist_attribute4,
                        l_dist_attribute5,
                        l_dist_attribute6,
                        l_dist_attribute7,
                        l_dist_attribute8,
                        l_dist_attribute9,
                        l_dist_attribute10,
                        l_dist_attribute11,
                        l_dist_attribute12,
                        l_dist_attribute13,
                        l_dist_attribute14,
                        l_dist_attribute15,
                        l_dist_posted_flag, --Bug:1754223
                        l_dist_reversal_flag, --Bug:1754223
                        l_inv_attribute_category,
                        l_inv_attribute1,
                        l_inv_attribute2,
                        l_inv_attribute3,
                        l_inv_attribute4,
                        l_inv_attribute5,
                        l_inv_attribute6,
                        l_inv_attribute7,
                        l_inv_attribute8,
                        l_inv_attribute9,
                        l_inv_attribute10,
                        l_inv_attribute11,
                        l_inv_attribute12,
                        l_inv_attribute13,
                        l_inv_attribute14,
                        l_inv_attribute15,
                        l_chart_of_accounts_id;

          EXIT WHEN pa_related_dist_cur%NOTFOUND;

          -- get the user id
          FND_PROFILE.GET('USER_ID',l_user_id);

	  --Added the below if for bug7014798

          if instr(current_calling_sequence, 'RECURR') <> 0 then
             l_calling_module := 'APXRICAD';
          else
             l_calling_module := 'apiindib.pls';
          end if;


          -- call the new function (replacment of patc.get_status)

          PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
               X_PROJECT_ID          => l_project_id,
               X_TASK_ID             => l_task_id,
               X_EI_DATE             => l_expenditure_item_date,
               X_EXPENDITURE_TYPE    => l_expenditure_type,
               X_NON_LABOR_RESOURCE  => null,
               X_PERSON_ID           => l_employee_id,
               X_QUANTITY            => l_pa_quantity,
               X_denom_currency_code => l_invoice_currency_code,
               X_acct_currency_code  => l_base_currency_code,
               X_denom_raw_cost      => l_dist_amount,
               X_acct_raw_cost       => l_dist_base_amount,
               X_acct_rate_type      => l_exchange_rate_type,
               X_acct_rate_date      => l_exchange_date,
               X_acct_exchange_rate  => l_exchange_rate,
               X_TRANSFER_EI         => null,
               X_INCURRED_BY_ORG_ID  => l_expenditure_organization_id,
               X_NL_RESOURCE_ORG_ID  => null,
               X_TRANSACTION_SOURCE  => null,
               X_CALLING_MODULE      => l_calling_module,  --bug7014798
               X_VENDOR_ID           => l_vendor_id,
               X_ENTERED_BY_USER_ID  => l_user_id,
               X_ATTRIBUTE_CATEGORY  => l_dist_attribute_category,
               X_ATTRIBUTE1          => l_dist_attribute1,
               X_ATTRIBUTE2          => l_dist_attribute2,
               X_ATTRIBUTE3          => l_dist_attribute3,
               X_ATTRIBUTE4          => l_dist_attribute4,
               X_ATTRIBUTE5          => l_dist_attribute5,
               X_ATTRIBUTE6          => l_dist_attribute6,
               X_ATTRIBUTE7          => l_dist_attribute7,
               X_ATTRIBUTE8          => l_dist_attribute8,
               X_ATTRIBUTE9          => l_dist_attribute9,
               X_ATTRIBUTE10         => l_dist_attribute10,
               X_ATTRIBUTE11         => l_dist_attribute11,
               X_ATTRIBUTE12         => l_dist_attribute12,
               X_ATTRIBUTE13         => l_dist_attribute13,
               X_ATTRIBUTE14         => l_dist_attribute14,
               X_ATTRIBUTE15         => l_dist_attribute15,
               X_msg_application     => l_msg_application,
               X_msg_type            => l_msg_type,
               X_msg_token1          => l_msg_token1,
               X_msg_token2          => l_msg_token2,
               X_msg_token3          => l_msg_token3,
               X_msg_count           => l_msg_count,
               X_msg_data            => l_msg_data,
               X_BILLABLE_FLAG       => l_billable_flag);

          IF (l_msg_data is not null) THEN
            FND_MESSAGE.SET_NAME(l_msg_application, l_msg_data);
            -- For bug3469917. Need to add token values for non-PA applications.

              if (l_msg_application <> 'PA') Then


                IF (l_msg_token1 IS NOT NULL) THEN
                    fnd_message.set_token('PATC_MSG_TOKEN1',l_msg_token1);
                ELSE
                    fnd_message.set_token('PATC_MSG_TOKEN1',app_api.G_NULL_CHAR);
                END IF;
                IF (l_msg_token2 IS NOT NULL) THEN
                    fnd_message.set_token('PATC_MSG_TOKEN2',l_msg_token2);
                ELSE
                    fnd_message.set_token('PATC_MSG_TOKEN2',app_api.G_NULL_CHAR);
                END IF;
                IF (l_msg_token3 IS NOT NULL) THEN
                    fnd_message.set_token('PATC_MSG_TOKEN3',l_msg_token3);
                ELSE
                    fnd_message.set_token('PATC_MSG_TOKEN3',app_api.G_NULL_CHAR);
                END IF;

              end if;

             -- End for bug3469917
            app_exception.raise_exception;
          END IF;

          IF ( ( (l_po_distribution_id is NOT NULL) AND
                 (nvl(l_accrue_on_receipt,'N') <> 'Y') )
               OR
                 (l_po_distribution_id is NULL) ) THEN

            IF (l_invoice_type_lookup_code = 'EXPENSE REPORT') THEN

	      /*
              IF ( NOT pa_acc_gen_wf_pkg.ap_er_generate_account (
                           p_project_id        =>l_project_id,
                           p_task_id           => l_task_id,
                           p_expenditure_type  => l_expenditure_type,
                           p_vendor_id         => l_VENDOR_ID,
                           p_expenditure_organization_id =>l_EXPENDITURE_ORGANIZATION_ID,
                           p_expenditure_item_date =>l_EXPENDITURE_ITEM_DATE,
                           p_billable_flag         =>l_billable_flag,
                           p_chart_of_accounts_id =>l_CHART_OF_ACCOUNTS_ID,
                           p_calling_module       => 'apiindib.pls',
                           p_employee_id          => l_employee_id,
                           p_employee_ccid        => null,
                           p_expense_type         => null,
                           p_expense_cc           => null,
                           P_ATTRIBUTE_CATEGORY => l_inv_ATTRIBUTE_CATEGORY,
                           P_ATTRIBUTE1  => l_inv_ATTRIBUTE1,
                           P_ATTRIBUTE2  => l_inv_ATTRIBUTE2,
                           P_ATTRIBUTE3  => l_inv_ATTRIBUTE3,
                           P_ATTRIBUTE4  => l_inv_ATTRIBUTE4,
                           P_ATTRIBUTE5  => l_inv_ATTRIBUTE5,
                           P_ATTRIBUTE6  => l_inv_ATTRIBUTE6,
                           P_ATTRIBUTE7  => l_inv_ATTRIBUTE7,
                           P_ATTRIBUTE8  => l_inv_ATTRIBUTE8,
                           P_ATTRIBUTE9  => l_inv_ATTRIBUTE9,
                           P_ATTRIBUTE10 => l_inv_ATTRIBUTE10,
                           P_ATTRIBUTE11 => l_inv_ATTRIBUTE11,
                           P_ATTRIBUTE12 => l_inv_ATTRIBUTE12,
                           P_ATTRIBUTE13 => l_inv_ATTRIBUTE13,
                           P_ATTRIBUTE14 => l_inv_ATTRIBUTE14,
                           P_ATTRIBUTE15 => l_inv_ATTRIBUTE15,
                           P_LINE_ATTRIBUTE_CATEGORY => l_dist_ATTRIBUTE_CATEGORY,
                           P_LINE_ATTRIBUTE1  => l_dist_ATTRIBUTE1,
                           P_LINE_ATTRIBUTE2  => l_dist_ATTRIBUTE2,
                           P_LINE_ATTRIBUTE3  => l_dist_ATTRIBUTE3,
                           P_LINE_ATTRIBUTE4  => l_dist_ATTRIBUTE4,
                           P_LINE_ATTRIBUTE5  => l_dist_ATTRIBUTE5,
                           P_LINE_ATTRIBUTE6  => l_dist_ATTRIBUTE6,
                           P_LINE_ATTRIBUTE7  => l_dist_ATTRIBUTE7,
                           P_LINE_ATTRIBUTE8  => l_dist_ATTRIBUTE8,
                           P_LINE_ATTRIBUTE9  => l_dist_ATTRIBUTE9,
                           P_LINE_ATTRIBUTE10 => l_dist_ATTRIBUTE10,
                           P_LINE_ATTRIBUTE11 => l_dist_ATTRIBUTE11,
                           P_LINE_ATTRIBUTE12 => l_dist_ATTRIBUTE12,
                           P_LINE_ATTRIBUTE13 => l_dist_ATTRIBUTE13,
                           P_LINE_ATTRIBUTE14 => l_dist_ATTRIBUTE14,
                           P_LINE_ATTRIBUTE15 => l_dist_ATTRIBUTE15,
                           x_return_ccid      => l_DIST_CODE_COMBINATION_ID,
                           x_concat_segs      => l_concat_segs,
                           x_concat_ids       => l_concat_ids,
                           x_concat_descrs    => l_concat_descrs,
                           x_error_message    => l_errmsg,
                           x_award_set_id     => l_award_id )) THEN

                fnd_message.set_encoded(l_errmsg);
                app_exception.raise_exception;
              END IF;
	      */
/*	      null;
            ELSE  -- non expense report

	      /*
              IF ( NOT pa_acc_gen_wf_pkg.ap_inv_generate_account (
                           p_project_id  => l_project_id,
                           p_task_id     => l_task_id,
                           p_expenditure_type  => l_expenditure_type,
                           p_vendor_id         => l_VENDOR_ID,
                           p_expenditure_organization_id  => l_EXPENDITURE_ORGANIZATION_ID,
                           p_expenditure_item_date  => l_EXPENDITURE_ITEM_DATE,
                           p_billable_flag        => l_billable_flag,
                           p_chart_of_accounts_id =>l_CHART_OF_ACCOUNTS_ID,
                           P_ATTRIBUTE_CATEGORY => l_inv_ATTRIBUTE_CATEGORY,
                           P_ATTRIBUTE1  => l_inv_ATTRIBUTE1,
                           P_ATTRIBUTE2  => l_inv_ATTRIBUTE2,
                           P_ATTRIBUTE3  => l_inv_ATTRIBUTE3,
                           P_ATTRIBUTE4  => l_inv_ATTRIBUTE4,
                           P_ATTRIBUTE5  => l_inv_ATTRIBUTE5,
                           P_ATTRIBUTE6  => l_inv_ATTRIBUTE6,
                           P_ATTRIBUTE7  => l_inv_ATTRIBUTE7,
                           P_ATTRIBUTE8  => l_inv_ATTRIBUTE8,
                           P_ATTRIBUTE9  => l_inv_ATTRIBUTE9,
                           P_ATTRIBUTE10 => l_inv_ATTRIBUTE10,
                           P_ATTRIBUTE11 => l_inv_ATTRIBUTE11,
                           P_ATTRIBUTE12 => l_inv_ATTRIBUTE12,
                           P_ATTRIBUTE13 => l_inv_ATTRIBUTE13,
                           P_ATTRIBUTE14 => l_inv_ATTRIBUTE14,
                           P_ATTRIBUTE15 => l_inv_ATTRIBUTE15,
                           P_DIST_ATTRIBUTE_CATEGORY => l_dist_ATTRIBUTE_CATEGORY,
                           P_DIST_ATTRIBUTE1 => l_dist_ATTRIBUTE1,
                           P_DIST_ATTRIBUTE2 => l_dist_ATTRIBUTE2,
                           P_DIST_ATTRIBUTE3 => l_dist_ATTRIBUTE3,
                           P_DIST_ATTRIBUTE4 => l_dist_ATTRIBUTE4,
                           P_DIST_ATTRIBUTE5 => l_dist_ATTRIBUTE5,
                           P_DIST_ATTRIBUTE6 => l_dist_ATTRIBUTE6,
                           P_DIST_ATTRIBUTE7 => l_dist_ATTRIBUTE7,
                           P_DIST_ATTRIBUTE8 => l_dist_ATTRIBUTE8,
                           P_DIST_ATTRIBUTE9 => l_dist_ATTRIBUTE9,
                           P_DIST_ATTRIBUTE10 => l_dist_ATTRIBUTE10,
                           P_DIST_ATTRIBUTE11 => l_dist_ATTRIBUTE11,
                           P_DIST_ATTRIBUTE12 => l_dist_ATTRIBUTE12,
                           P_DIST_ATTRIBUTE13 => l_dist_ATTRIBUTE13,
                           P_DIST_ATTRIBUTE14 => l_dist_ATTRIBUTE14,
                           P_DIST_ATTRIBUTE15 => l_dist_ATTRIBUTE15,
                           x_return_ccid => l_DIST_CODE_COMBINATION_ID,
                           x_concat_segs => l_concat_segs,
                           x_concat_ids  => l_concat_ids,
                           x_concat_descrs => l_concat_descrs,
                           x_error_message    => l_errmsg,
                           x_award_set_id  => l_award_id )) THEN

                FND_MESSAGE.SET_ENCODED(l_errmsg);
                app_exception.raise_exception;

              END IF;
	      */
/*	      null;
            END IF; -- end of check l_invoice_type_lookup_code


/*-----------------------------------------------------------------+
     | update invoice_distributions with l_dist_code_combination_id    |
     +-----------------------------------------------------------------*/

 /*           IF (l_dist_posted_flag = 'N') THEN
              IF (l_dist_reversal_flag <> 'Y') THEN

                UPDATE ap_invoice_distributions
                    SET dist_code_combination_id   = l_dist_code_combination_id
                  WHERE invoice_distribution_id    = l_invoice_distribution_id;

               END IF; -- end of l_dist_reversal_flag
             END IF; -- end of l_dist_posted_flag

             l_dist_count := l_dist_count +1;

          END IF; -- end of check l_po_distribution_id/l_accrue_on_receipt_flag
        END LOOP; -- end loop of pa_related_dist_cursor
        CLOSE pa_related_dist_cur;

        IF (l_dist_count >0) THEN
          X_update_occurred := 'Y';
        END IF;

        UPDATE AP_INVOICE_DISTRIBUTIONS
           SET last_update_login = l_last_update_login
         WHERE invoice_id = X_invoice_id
           AND last_update_login = -3;
-- CHANGES FOR BUG - 3025688 ** ENDS   **
*/
      END IF;  -- check l_multi_currency_flag = y and x_update_base=y
    END LOOP; -- end of invoice_line_cursor

    debug_info := 'Close cursor invoice_line_cursor';
    CLOSE invoice_line_cursor;

    EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
           'X_invoice_id = '             ||X_invoice_id
           ||', X_line_number = '        ||X_line_number
           ||', X_type_1099 = '          ||X_type_1099
           ||', X_income_tax_region = '  ||X_income_tax_region
           ||', X_vendor_changed_flag = '||X_vendor_changed_flag
           ||', X_update_base = '        ||X_update_base
           ||', X_reset_match_status = ' ||X_reset_match_status
           ||', X_update_occurred = '    ||X_update_occurred
                                       );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END Update_Distributions;


   PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Invoice_Id                     NUMBER,
                       -- Invoice Lines Project Stage 1
                       X_Invoice_Line_Number            NUMBER,
                       X_Distribution_Class             VARCHAR2,
                       X_Invoice_Distribution_Id IN OUT NOCOPY NUMBER,
                       X_Dist_Code_Combination_Id       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Accounting_Date                DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Amount                         NUMBER,
                       X_Description                    VARCHAR2,
                       X_Type_1099                      VARCHAR2,
                       X_Posted_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Quantity_Invoiced              NUMBER,
                       X_Unit_Price                     NUMBER,
                       X_Match_Status_Flag              VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Prepay_Amount_Remaining        NUMBER,
                       X_Assets_Addition_Flag           VARCHAR2,
                       X_Assets_Tracking_Flag           VARCHAR2,
                       X_Distribution_Line_Number       NUMBER,
                       X_Line_Type_Lookup_Code          VARCHAR2,
                       X_Po_Distribution_Id             NUMBER,
                       X_Base_Amount                    NUMBER,
                       X_Pa_Addition_Flag               VARCHAR2,
                       X_Posted_Amount                  NUMBER,
                       X_Posted_Base_Amount             NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Accrual_Posted_Flag            VARCHAR2,
                       X_Cash_Posted_Flag               VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Stat_Amount                    NUMBER,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Accts_Pay_Code_Comb_Id         NUMBER,
                       X_Reversal_Flag                  VARCHAR2,
                       X_Parent_Invoice_Id              NUMBER,
                       X_Income_Tax_Region              VARCHAR2,
                       X_Final_Match_Flag               VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Pa_Quantity                    NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Quantity_Variance              NUMBER,
                       X_Base_Quantity_Variance         NUMBER,
                       X_Packet_Id                      NUMBER,
                       X_Awt_Flag                       VARCHAR2,
                       X_Awt_Group_Id                   NUMBER,
		       X_Pay_Awt_Group_Id               NUMBER,--bug6639866
                       X_Awt_Tax_Rate_Id                NUMBER,
                       X_Awt_Gross_Amount               NUMBER,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Other_Invoice_Id               NUMBER,
                       X_Awt_Invoice_Id                 NUMBER,
                       X_Awt_Origin_Group_Id            NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_Request_Id                     NUMBER,
                       X_Tax_Recoverable_Flag           VARCHAR2,
                       X_Award_Id                       NUMBER,
                       X_Start_Expense_Date             DATE,
                       X_Merchant_Document_Number       VARCHAR2,
                       X_Merchant_Name                  VARCHAR2,
		       X_Merchant_Reference		VARCHAR2,
                       X_Merchant_Tax_Reg_Number        VARCHAR2,
                       X_Merchant_Taxpayer_Id           VARCHAR2,
                       X_Country_Of_Supply              VARCHAR2,
                       X_Parent_Reversal_id    NUMBER,
                       X_rcv_transaction_id    NUMBER,
                       X_matched_uom_lookup_code  VARCHAR2,
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_global_attribute1              VARCHAR2 DEFAULT NULL,
                       X_global_attribute2              VARCHAR2 DEFAULT NULL,
                       X_global_attribute3              VARCHAR2 DEFAULT NULL,
                       X_global_attribute4              VARCHAR2 DEFAULT NULL,
                       X_global_attribute5              VARCHAR2 DEFAULT NULL,
                       X_global_attribute6              VARCHAR2 DEFAULT NULL,
                       X_global_attribute7              VARCHAR2 DEFAULT NULL,
                       X_global_attribute8              VARCHAR2 DEFAULT NULL,
                       X_global_attribute9              VARCHAR2 DEFAULT NULL,
                       X_global_attribute10             VARCHAR2 DEFAULT NULL,
                       X_global_attribute11             VARCHAR2 DEFAULT NULL,
                       X_global_attribute12             VARCHAR2 DEFAULT NULL,
                       X_global_attribute13             VARCHAR2 DEFAULT NULL,
                       X_global_attribute14             VARCHAR2 DEFAULT NULL,
                       X_global_attribute15             VARCHAR2 DEFAULT NULL,
                       X_global_attribute16             VARCHAR2 DEFAULT NULL,
                       X_global_attribute17             VARCHAR2 DEFAULT NULL,
                       X_global_attribute18             VARCHAR2 DEFAULT NULL,
                       X_global_attribute19             VARCHAR2 DEFAULT NULL,
                       X_global_attribute20             VARCHAR2 DEFAULT NULL,
                       -- Invoice Lines Project Stage 1
                       X_rounding_amt                   NUMBER DEFAULT NULL,
                       X_charge_applicable_to_dist_id   NUMBER DEFAULT NULL,
                       X_corrected_invoice_dist_id      NUMBER DEFAULT NULL,
                       X_related_id                     NUMBER DEFAULT NULL,
                       X_asset_book_type_code           VARCHAR2 DEFAULT NULL,
                       X_asset_category_id              NUMBER DEFAULT NULL ,
		       X_Intended_Use			VARCHAR2 DEFAULT NULL,
		       x_calling_sequence               VARCHAR2
   ) IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

   BEGIN
      -- Update the calling sequence
       --
       current_calling_sequence :=
       'AP_INVOICE_DISTRIBUTIONS_PKG.Insert_Row<-'||X_Calling_Sequence;

       debug_info := 'Calling invoice distribution handler';

       AP_AID_TABLE_HANDLER_PKG.Insert_Row
             (X_Rowid,
              X_Invoice_Id,
              -- Invoice Lines Project Stage 1
              X_Invoice_Line_Number,
              X_Distribution_Class,
              X_Invoice_Distribution_Id,
              X_Dist_Code_Combination_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Accounting_Date,
              X_Period_Name,
              X_Set_Of_Books_Id,
              X_Amount,
              X_Description,
              X_Type_1099,
              X_Posted_Flag,
              X_Batch_Id,
              X_Quantity_Invoiced,
              X_Unit_Price,
              X_Match_Status_Flag,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Prepay_Amount_Remaining,
              X_Assets_Addition_Flag,
              X_Assets_Tracking_Flag,
              X_Distribution_Line_Number,
              X_Line_Type_Lookup_Code,
              X_Po_Distribution_Id,
              X_Base_Amount,
              X_Pa_Addition_Flag,
              X_Posted_Amount,
              X_Posted_Base_Amount,
              X_Encumbered_Flag,
              X_Accrual_Posted_Flag,
              X_Cash_Posted_Flag,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_Stat_Amount,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute15,
              X_Accts_Pay_Code_Comb_Id,
              X_Reversal_Flag,
              X_Parent_Invoice_Id,
              X_Income_Tax_Region,
              X_Final_Match_Flag,
              X_Expenditure_Item_Date,
              X_Expenditure_Organization_Id,
              X_Expenditure_Type,
              X_Pa_Quantity,
              X_Project_Id,
              X_Task_Id,
              X_Quantity_Variance,
              X_Base_Quantity_Variance,
              X_Packet_Id,
              X_Awt_Flag,
              X_Awt_Group_Id,
	      X_Pay_Awt_Group_Id,--bug6639866
              X_Awt_Tax_Rate_Id,
              X_Awt_Gross_Amount,
              X_Reference_1,
              X_Reference_2,
              X_Org_Id,
              X_Other_Invoice_Id,
              X_Awt_Invoice_Id,
              X_Awt_Origin_Group_Id,
              X_Program_Application_Id,
              X_Program_Id,
              X_Program_Update_Date,
              X_Request_Id,
              X_Tax_Recoverable_Flag,
              X_Award_Id,
              X_Start_Expense_Date,
              X_Merchant_Document_Number,
              X_Merchant_Name,
              X_Merchant_Tax_Reg_Number,
              X_Merchant_Taxpayer_Id,
              X_Country_Of_Supply,
              X_Merchant_Reference,
              X_Parent_Reversal_Id,
              X_rcv_transaction_id,
              X_matched_uom_lookup_code,
              X_global_attribute_category,
              X_global_attribute1,
              X_global_attribute2,
              X_global_attribute3,
              X_global_attribute4,
              X_global_attribute5,
              X_global_attribute6,
              X_global_attribute7,
              X_global_attribute8,
              X_global_attribute9,
              X_global_attribute10,
              X_global_attribute11,
              X_global_attribute12,
              X_global_attribute13,
              X_global_attribute14,
              X_global_attribute15,
              X_global_attribute16,
              X_global_attribute17,
              X_global_attribute18,
              X_global_attribute19,
              X_global_attribute20,
              current_calling_sequence,
           -- Added by iyas cuz params don't exist in ap_aid_table_handlers_pkg
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
           -- Invoice Lines Project Stage 1
              X_rounding_amt,
              X_charge_applicable_to_dist_id,
              X_corrected_invoice_dist_id,
              X_related_id,
              X_asset_book_type_code,
              X_asset_category_id,
	      X_Intended_Use
             );


  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Invoice_Id                       NUMBER,
                     -- Invoice Lines Project Stage 1
                     X_Invoice_Line_Number              NUMBER,
                     X_Distribution_Class               VARCHAR2,
                     X_Invoice_Distribution_Id          NUMBER,
                     X_Dist_Code_Combination_Id         NUMBER,
                     X_Accounting_Date                  DATE,
                     X_Period_Name                      VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Amount                           NUMBER,
                     X_Description                      VARCHAR2,
                     X_Type_1099                        VARCHAR2,
                     X_Posted_Flag                      VARCHAR2,
                     X_Batch_Id                         NUMBER,
                     X_Quantity_Invoiced                NUMBER,
                     X_Unit_Price                       NUMBER,
                     X_Match_Status_Flag                VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Prepay_Amount_Remaining          NUMBER,
                     X_Assets_Addition_Flag             VARCHAR2,
                     X_Assets_Tracking_Flag             VARCHAR2,
                     X_Distribution_Line_Number         NUMBER,
                     X_Line_Type_Lookup_Code            VARCHAR2,
                     X_Po_Distribution_Id               NUMBER,
                     X_Base_Amount                      NUMBER,
                     X_Pa_Addition_Flag                 VARCHAR2,
                     X_Posted_Amount                    NUMBER,
                     X_Posted_Base_Amount               NUMBER,
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Accrual_Posted_Flag              VARCHAR2,
                     X_Cash_Posted_Flag                 VARCHAR2,
                     X_Stat_Amount                      NUMBER,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Accts_Pay_Code_Comb_Id    NUMBER,
                     X_Reversal_Flag                    VARCHAR2,
                     X_Parent_Invoice_Id                NUMBER,
                     X_Income_Tax_Region                VARCHAR2,
                     X_Final_Match_Flag                 VARCHAR2,
                     X_Expenditure_Item_Date            DATE,
                     X_Expenditure_Organization_Id      NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
                     X_Pa_Quantity                      NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Quantity_Variance                NUMBER,
                     X_Base_Quantity_Variance           NUMBER,
                     X_Packet_Id                        NUMBER,
                     X_Awt_Flag                         VARCHAR2,
                     X_Awt_Group_Id                     NUMBER,
		     X_Pay_Awt_Group_Id                 NUMBER,--bug6639866
                     X_Awt_Tax_Rate_Id                  NUMBER,
                     X_Awt_Gross_Amount                 NUMBER,
                     X_Reference_1                      VARCHAR2,
                     X_Reference_2                      VARCHAR2,
                     X_Org_Id                           NUMBER,
                     X_Other_Invoice_Id                 NUMBER,
                     X_Awt_Invoice_Id                   NUMBER,
                     X_Awt_Origin_Group_Id              NUMBER,
                     X_Program_Application_Id           NUMBER,
                     X_Program_Id                       NUMBER,
                     X_Program_Update_Date              DATE,
                     X_Request_Id                       NUMBER,
                     X_Tax_Recoverable_Flag             VARCHAR2,
                     X_Award_Id                         NUMBER,
                     X_Start_Expense_Date               DATE,
                     X_Merchant_Document_Number         VARCHAR2,
                     X_Merchant_Name                    VARCHAR2,
		     X_Merchant_Reference               VARCHAR2,
                     X_Merchant_Tax_Reg_Number          VARCHAR2,
                     X_Merchant_Taxpayer_Id             VARCHAR2,
                     X_Country_Of_Supply                VARCHAR2,
                     X_global_attribute_category        VARCHAR2 DEFAULT NULL,
                     X_global_attribute1                VARCHAR2 DEFAULT NULL,
                     X_global_attribute2                VARCHAR2 DEFAULT NULL,
                     X_global_attribute3                VARCHAR2 DEFAULT NULL,
                     X_global_attribute4                VARCHAR2 DEFAULT NULL,
                     X_global_attribute5                VARCHAR2 DEFAULT NULL,
                     X_global_attribute6                VARCHAR2 DEFAULT NULL,
                     X_global_attribute7                VARCHAR2 DEFAULT NULL,
                     X_global_attribute8                VARCHAR2 DEFAULT NULL,
                     X_global_attribute9                VARCHAR2 DEFAULT NULL,
                     X_global_attribute10               VARCHAR2 DEFAULT NULL,
                     X_global_attribute11               VARCHAR2 DEFAULT NULL,
                     X_global_attribute12               VARCHAR2 DEFAULT NULL,
                     X_global_attribute13               VARCHAR2 DEFAULT NULL,
                     X_global_attribute14               VARCHAR2 DEFAULT NULL,
                     X_global_attribute15               VARCHAR2 DEFAULT NULL,
                     X_global_attribute16               VARCHAR2 DEFAULT NULL,
                     X_global_attribute17               VARCHAR2 DEFAULT NULL,
                     X_global_attribute18               VARCHAR2 DEFAULT NULL,
                     X_global_attribute19               VARCHAR2 DEFAULT NULL,
                     X_global_attribute20               VARCHAR2 DEFAULT NULL,
                     -- Invoice Lines Project Stage 1
                     X_rounding_amt                   NUMBER DEFAULT NULL,
                     X_charge_applicable_to_dist_id   NUMBER DEFAULT NULL,
                     X_corrected_invoice_dist_id      NUMBER DEFAULT NULL,
                     X_related_id                     NUMBER DEFAULT NULL,
                     X_asset_book_type_code           VARCHAR2 DEFAULT NULL,
                     X_asset_category_id              NUMBER DEFAULT NULL,
		     --ETAX: Invoice Workbench
 		     X_Intended_Use		      VARCHAR2 DEFAULT NULL,
		     X_Calling_Sequence		      VARCHAR2
  ) IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

      CURSOR C IS
        SELECT
          PREPAY_DISTRIBUTION_ID,
          ACCOUNTING_EVENT_ID, -- Bug 9385883
          ACCOUNTING_DATE,
          ACCRUAL_POSTED_FLAG,
          ASSETS_ADDITION_FLAG,
          ASSETS_TRACKING_FLAG,
          CASH_POSTED_FLAG,
          DISTRIBUTION_LINE_NUMBER,
          DIST_CODE_COMBINATION_ID,
          INVOICE_ID,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LINE_TYPE_LOOKUP_CODE,
          PERIOD_NAME,
          SET_OF_BOOKS_ID,
          ACCTS_PAY_CODE_COMBINATION_ID,
          AMOUNT,
          BASE_AMOUNT,
          BATCH_ID,
          CREATED_BY,
          CREATION_DATE,
          DESCRIPTION,
          FINAL_MATCH_FLAG,
          INCOME_TAX_REGION,
          LAST_UPDATE_LOGIN,
          MATCH_STATUS_FLAG,
          POSTED_FLAG,
          PO_DISTRIBUTION_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          QUANTITY_INVOICED,
          REQUEST_ID,
          REVERSAL_FLAG,
          TYPE_1099,
          UNIT_PRICE,
          --AMOUNT_ENCUMBERED,
          --BASE_AMOUNT_ENCUMBERED,
          ENCUMBERED_FLAG,
          --PRICE_ADJUSTMENT_FLAG,
          --QUANTITY_UNENCUMBERED,
          STAT_AMOUNT,
          --AMOUNT_TO_POST,
          ATTRIBUTE1,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE_CATEGORY,
          --BASE_AMOUNT_TO_POST,
          EXPENDITURE_ITEM_DATE,
          EXPENDITURE_ORGANIZATION_ID,
          EXPENDITURE_TYPE,
          PARENT_INVOICE_ID,
          PA_ADDITION_FLAG,
          PA_QUANTITY,
          POSTED_AMOUNT,
          POSTED_BASE_AMOUNT,
          PREPAY_AMOUNT_REMAINING,
          PROJECT_ID,
          TASK_ID,
          --EARLIEST_SETTLEMENT_DATE,
          --REQ_DISTRIBUTION_ID,
          QUANTITY_VARIANCE,
          BASE_QUANTITY_VARIANCE,
          PACKET_ID,
          AWT_FLAG,
          AWT_GROUP_ID,
	  PAY_AWT_GROUP_ID,--bug6639866
          AWT_TAX_RATE_ID,
          AWT_GROSS_AMOUNT,
          AWT_INVOICE_ID,
          AWT_ORIGIN_GROUP_ID,
          REFERENCE_1,
          REFERENCE_2,
          ORG_ID,
          OTHER_INVOICE_ID,
          --AWT_INVOICE_PAYMENT_ID,
          GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4,
          GLOBAL_ATTRIBUTE5,
          GLOBAL_ATTRIBUTE6,
          GLOBAL_ATTRIBUTE7,
          GLOBAL_ATTRIBUTE8,
          GLOBAL_ATTRIBUTE9,
          GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12,
          GLOBAL_ATTRIBUTE13,
          GLOBAL_ATTRIBUTE14,
          GLOBAL_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE16,
          GLOBAL_ATTRIBUTE17,
          GLOBAL_ATTRIBUTE18,
          GLOBAL_ATTRIBUTE19,
          GLOBAL_ATTRIBUTE20,
          --LINE_GROUP_NUMBER,
          --RECEIPT_VERIFIED_FLAG,
          --RECEIPT_REQUIRED_FLAG,
          --RECEIPT_MISSING_FLAG,
          --JUSTIFICATION,
          --EXPENSE_GROUP,
          START_EXPENSE_DATE,
          --END_EXPENSE_DATE,
          --RECEIPT_CURRENCY_CODE,
          --RECEIPT_CONVERSION_RATE,
          --RECEIPT_CURRENCY_AMOUNT,
          --DAILY_AMOUNT,
          --WEB_PARAMETER_ID,
          --ADJUSTMENT_REASON,
          AWARD_ID,
          --MRC_DIST_CODE_COMBINATION_ID,
          --MRC_BASE_AMOUNT,
          --MRC_BASE_INV_PRICE_VARIANCE,
          --MRC_EXCHANGE_RATE_VARIANCE,
          --MRC_RATE_VAR_CCID,
          --MRC_EXCHANGE_DATE,
          --MRC_EXCHANGE_RATE,
          --MRC_EXCHANGE_RATE_TYPE,
          --MRC_RECEIPT_CONVERSION_RATE,
          DIST_MATCH_TYPE,
          RCV_TRANSACTION_ID,
          -- Invoice Lines Project Stage 1
          INVOICE_LINE_NUMBER,
          DISTRIBUTION_CLASS,
          INVOICE_DISTRIBUTION_ID,
          PARENT_REVERSAL_ID,
          TAX_RECOVERABLE_FLAG,
          --PA_CC_AR_INVOICE_ID,
          --PA_CC_AR_INVOICE_LINE_NUM,
          --PA_CC_PROCESSED_CODE,
          MERCHANT_DOCUMENT_NUMBER,
          MERCHANT_NAME,
          MERCHANT_REFERENCE,
          MERCHANT_TAX_REG_NUMBER,
          MERCHANT_TAXPAYER_ID,
          COUNTRY_OF_SUPPLY,
          MATCHED_UOM_LOOKUP_CODE,
          GMS_BURDENABLE_RAW_COST,
          --CREDIT_CARD_TRX_ID,
          --UPGRADE_POSTED_AMT,
          --UPGRADE_BASE_POSTED_AMT,
          -- Invoice Lines Project Stage 1
          ROUNDING_AMT,
          CHARGE_APPLICABLE_TO_DIST_ID,
          CORRECTED_INVOICE_DIST_ID,
          RELATED_ID,
          ASSET_BOOK_TYPE_CODE,
          ASSET_CATEGORY_ID,
	  INTENDED_USE
        FROM   AP_INVOICE_DISTRIBUTIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Invoice_Id NOWAIT;
        Recinfo C%ROWTYPE;

--Bug 9385883
    CURSOR D(l_event_id NUMBER) IS
    SELECT 'Locked'
      FROM xla_events xe
     WHERE xe.event_id      = l_event_id
       AND xe.application_id= 200
       FOR UPDATE OF event_id NOWAIT;

    Rec_xla_events_Info D%ROWTYPE;

BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
    'AP_INVOICE_DISTRIBUTIONS_PKG.Lock_Row<-'||X_Calling_Sequence;

    debug_info := 'Select from ap_invoice_distributions';

    OPEN C;

    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

--Bug 9385883
     IF (Recinfo.accounting_event_id IS NOT NULL) THEN
        debug_info := 'Select from xla_events';
        OPEN D(Recinfo.accounting_event_id);
        debug_info := 'Fetch curson D';
        FETCH D INTO Rec_xla_events_Info;

        IF (D%NOTFOUND) THEN
          debug_info := 'Close cursor D - ROW NOTFOUND';
          CLOSE D;
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
          APP_EXCEPTION.Raise_Exception;
        END IF;

        debug_info := 'Close cursor D';
        CLOSE D;
    END IF;

    if (
               (Recinfo.invoice_id =  X_Invoice_Id)
           AND (Recinfo.dist_code_combination_id =  X_Dist_Code_Combination_Id)
           -- Invoice Lines Project Stage 1
           AND (Recinfo.invoice_line_number = X_Invoice_Line_Number)
           AND (   (Recinfo.distribution_class  = X_Distribution_Class)
	   --Bug9336977
		OR (	(Recinfo.distribution_class IS NULL)
		    AND (X_Distribution_Class IS NULL)))
           AND (Recinfo.invoice_distribution_id = X_Invoice_Distribution_Id)
           AND (Recinfo.accounting_date =  X_Accounting_Date)
           AND (Recinfo.period_name =  X_Period_Name)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (   (Recinfo.amount =  X_Amount)
                OR (    (Recinfo.amount IS NULL)
                    AND (X_Amount IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.type_1099 =  X_Type_1099)
                OR (    (Recinfo.type_1099 IS NULL)
                    AND (X_Type_1099 IS NULL)))
           AND (   (Recinfo.posted_flag =  X_Posted_Flag)
                OR (    (Recinfo.posted_flag IS NULL)
                    AND (X_Posted_Flag IS NULL)))
           AND (   (Recinfo.batch_id =  X_Batch_Id)
                OR (    (Recinfo.batch_id IS NULL)
                    AND (X_Batch_Id IS NULL)))
           AND (   (Recinfo.quantity_invoiced =  X_Quantity_Invoiced)
                OR (    (Recinfo.quantity_invoiced IS NULL)
                    AND (X_Quantity_Invoiced IS NULL)))
           AND (   (Recinfo.unit_price =  X_Unit_Price)
                OR (    (Recinfo.unit_price IS NULL)
                    AND (X_Unit_Price IS NULL)))
           AND (   (Recinfo.match_status_flag =  X_Match_Status_Flag)
                OR (    (Recinfo.match_status_flag IS NULL)
                    AND (X_Match_Status_Flag IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (Recinfo.assets_addition_flag =  X_Assets_Addition_Flag)
           AND (Recinfo.assets_tracking_flag =  X_Assets_Tracking_Flag)
           AND (Recinfo.distribution_line_number =  X_Distribution_Line_Number)
           AND (Recinfo.line_type_lookup_code =  X_Line_Type_Lookup_Code)
           AND (   (Recinfo.po_distribution_id =  X_Po_Distribution_Id)
                OR (    (Recinfo.po_distribution_id IS NULL)
                    AND (X_Po_Distribution_Id IS NULL)))
           AND (   (Recinfo.base_amount =  X_Base_Amount)
                OR (    (Recinfo.base_amount IS NULL)
                    AND (X_Base_Amount IS NULL)))
           AND (   (Recinfo.pa_addition_flag =  X_Pa_Addition_Flag)
                OR (    (Recinfo.pa_addition_flag IS NULL)
                    AND (X_Pa_Addition_Flag IS NULL)))
           AND (   (Recinfo.posted_amount =  X_Posted_Amount)
                OR (    (Recinfo.posted_amount IS NULL)
                    AND (X_Posted_Amount IS NULL)))
           AND (   (Recinfo.posted_base_amount =  X_Posted_Base_Amount)
                OR (    (Recinfo.posted_base_amount IS NULL)
                    AND (X_Posted_Base_Amount IS NULL)))
           AND (   (Recinfo.encumbered_flag =  X_Encumbered_Flag)
                OR (    (Recinfo.encumbered_flag IS NULL)
                    AND (X_Encumbered_Flag IS NULL)))
           AND (Recinfo.accrual_posted_flag =  X_Accrual_Posted_Flag)
           AND (Recinfo.cash_posted_flag =  X_Cash_Posted_Flag)
           AND (   (Recinfo.stat_amount =  X_Stat_Amount)
                OR (    (Recinfo.stat_amount IS NULL)
                    AND (X_Stat_Amount IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (
               (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.accts_pay_code_combination_id =  X_Accts_Pay_Code_Comb_Id)
                OR (    (Recinfo.accts_pay_code_combination_id IS NULL)
                    AND (X_Accts_Pay_Code_Comb_Id IS NULL)))
           AND (   (Recinfo.reversal_flag =  X_Reversal_Flag)
                OR (    (Recinfo.reversal_flag IS NULL)
                    AND (X_Reversal_Flag IS NULL)))
           AND (   (Recinfo.parent_invoice_id =  X_Parent_Invoice_Id)
                OR (    (Recinfo.parent_invoice_id IS NULL)
                    AND (X_Parent_Invoice_Id IS NULL)))
           AND (   (Recinfo.income_tax_region =  X_Income_Tax_Region)
                OR (    (Recinfo.income_tax_region IS NULL)
                    AND (X_Income_Tax_Region IS NULL)))
           AND (   (Recinfo.final_match_flag =  X_Final_Match_Flag)
                OR (    (Recinfo.final_match_flag IS NULL)
                    AND (X_Final_Match_Flag IS NULL)))
           AND (   (Recinfo.expenditure_item_date =  X_Expenditure_Item_Date)
                OR (    (Recinfo.expenditure_item_date IS NULL)
                    AND (X_Expenditure_Item_Date IS NULL)))
           AND (   (Recinfo.expenditure_organization_id =  X_Expenditure_Organization_Id)
                OR (    (Recinfo.expenditure_organization_id IS NULL)
                    AND (X_Expenditure_Organization_Id IS NULL)))
           AND (   (Recinfo.expenditure_type =  X_Expenditure_Type)
                OR (    (Recinfo.expenditure_type IS NULL)
                    AND (X_Expenditure_Type IS NULL)))
           AND (   (Recinfo.pa_quantity =  X_Pa_Quantity)
                OR (    (Recinfo.pa_quantity IS NULL)
                    AND (X_Pa_Quantity IS NULL)))
           AND (   (Recinfo.project_id =  X_Project_Id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (X_Project_Id IS NULL)))
           AND (   (Recinfo.task_id =  X_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (   (Recinfo.quantity_variance =  X_Quantity_Variance)
                OR (    (Recinfo.quantity_variance IS NULL)
                    AND (X_Quantity_Variance IS NULL)))
           AND (   (Recinfo.base_quantity_variance =  X_Base_Quantity_Variance)
                OR (    (Recinfo.base_quantity_variance IS NULL)
                    AND (X_Base_Quantity_Variance IS NULL)))
           AND (   (Recinfo.packet_id =  X_Packet_Id)
                OR (    (Recinfo.packet_id IS NULL)
                    AND (X_Packet_Id IS NULL)))
           AND (   (Recinfo.awt_flag =  X_Awt_Flag)
                OR (    (Recinfo.awt_flag IS NULL)
                    AND (X_Awt_Flag IS NULL)))
           AND (   (Recinfo.awt_group_id =  X_Awt_Group_Id)
                OR (    (Recinfo.awt_group_id IS NULL)
                    AND (X_Awt_Group_Id IS NULL)))
           AND (   (Recinfo.pay_awt_group_id =  X_Pay_Awt_Group_Id)
                OR (    (Recinfo.pay_awt_group_id IS NULL)
                    AND (X_Pay_Awt_Group_Id IS NULL)))       --bug6639866
           AND (   (Recinfo.awt_tax_rate_id =  X_Awt_Tax_Rate_Id)
                OR (    (Recinfo.awt_tax_rate_id IS NULL)
                    AND (X_Awt_Tax_Rate_Id IS NULL)))
           AND (   (Recinfo.awt_gross_amount =  X_Awt_Gross_Amount)
                OR (    (Recinfo.awt_gross_amount IS NULL)
                    AND (X_Awt_Gross_Amount IS NULL)))
           AND (   (Recinfo.reference_1 =  X_Reference_1)
                OR (    (Recinfo.reference_1 IS NULL)
                    AND (X_Reference_1 IS NULL)))
           AND (   (Recinfo.reference_2 =  X_Reference_2)
                OR (    (Recinfo.reference_2 IS NULL)
                    AND (X_Reference_2 IS NULL)))
           AND (   (Recinfo.other_invoice_id =  X_Other_Invoice_Id)
                OR (    (Recinfo.other_invoice_id IS NULL)
                    AND (X_Other_Invoice_Id IS NULL)))
           AND (   (Recinfo.awt_invoice_id =  X_Awt_Invoice_Id)
                OR (    (Recinfo.awt_invoice_id IS NULL)
                    AND (X_Awt_Invoice_Id IS NULL)))
           AND (   (Recinfo.awt_origin_group_id =  X_Awt_Origin_Group_Id)
                OR (    (Recinfo.awt_origin_group_id IS NULL)
                    AND (X_Awt_Origin_Group_Id IS NULL)))
           AND (   (Recinfo.program_application_id = X_Program_Application_Id)
                OR (    (Recinfo.program_application_id IS NULL)
                    AND (X_Program_Application_id IS NULL)))
           AND (   (Recinfo.program_id = X_Program_Id)
                OR (    (Recinfo.program_id IS NULL)
                    AND (X_Program_Id IS NULL)))
           AND (   (Recinfo.program_update_date = X_Program_Update_Date)
                OR (    (Recinfo.program_update_date IS NULL)
                    AND (X_Program_Update_Date IS NULL)))
           AND (   (Recinfo.request_id = X_Request_Id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (X_Request_Id IS NULL)))
           AND (    (Recinfo.tax_recoverable_flag = X_Tax_Recoverable_Flag)
                OR (    (Recinfo.tax_recoverable_flag IS NULL)
                     AND (X_Tax_Recoverable_Flag IS NULL)))
           AND (    (Recinfo.award_id = X_Award_Id)
                OR (    (Recinfo.award_id IS NULL)
                     AND (X_Award_Id IS NULL)))
           AND (    (Recinfo.start_expense_date = X_Start_Expense_Date)
                OR (    (Recinfo.start_expense_date IS NULL)
                     AND (X_Start_Expense_Date IS NULL)))
           AND (    (Recinfo.merchant_document_number = X_Merchant_Document_Number)
                OR (    (Recinfo.merchant_document_number IS NULL)
                     AND (X_Merchant_Document_Number IS NULL)))
           AND (    (Recinfo.merchant_name = X_Merchant_Name)
                OR (    (Recinfo.merchant_name IS NULL)
                     AND (X_Merchant_Name IS NULL)))
           AND (    (Recinfo.merchant_tax_reg_number = X_Merchant_Tax_Reg_Number)
                OR (    (Recinfo.merchant_tax_reg_number IS NULL)
                     AND (X_Merchant_Tax_Reg_Number IS NULL)))
           AND (    (Recinfo.merchant_taxpayer_id = X_Merchant_Taxpayer_Id)
                OR (    (Recinfo.merchant_taxpayer_id IS NULL)
                     AND (X_Merchant_Taxpayer_Id IS NULL)))
           AND (    (Recinfo.merchant_reference = X_Merchant_Reference)
                OR (    (Recinfo.merchant_reference IS NULL)
                     AND (X_Merchant_Reference IS NULL)))
           AND (    (Recinfo.country_of_supply = X_Country_Of_Supply)
                OR (    (Recinfo.country_of_supply IS NULL)
                     AND (X_Country_Of_Supply IS NULL)))

      ) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

   if (
               (   (Recinfo.global_attribute_category =  X_global_attribute_category)
                OR (    (Recinfo.global_attribute_category IS NULL)
                    AND (X_global_attribute_category IS NULL)))
           AND (   (Recinfo.global_attribute1 =  X_global_attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (X_global_attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2 =  X_global_attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (X_global_attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3 =  X_global_attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (X_global_attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4 =  X_global_attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (X_global_attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5 =  X_global_attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (X_global_attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6 =  X_global_attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (X_global_attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7 =  X_global_attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (X_global_attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8 =  X_global_attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (X_global_attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9 =  X_global_attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (X_global_attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10 =  X_global_attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (X_global_attribute10 IS NULL)))
           AND (   (Recinfo.global_attribute11 =  X_global_attribute11)
                OR (    (Recinfo.global_attribute11 IS NULL)
                    AND (X_global_attribute11 IS NULL)))
           AND (   (Recinfo.global_attribute12 =  X_global_attribute12)
                OR (    (Recinfo.global_attribute12 IS NULL)
                    AND (X_global_attribute12 IS NULL)))
           AND (   (Recinfo.global_attribute13 =  X_global_attribute13)
                OR (    (Recinfo.global_attribute13 IS NULL)
                    AND (X_global_attribute13 IS NULL)))
           AND (   (Recinfo.global_attribute14 =  X_global_attribute14)
                OR (    (Recinfo.global_attribute14 IS NULL)
                    AND (X_global_attribute14 IS NULL)))
           AND (   (Recinfo.global_attribute15 =  X_global_attribute15)
                OR (    (Recinfo.global_attribute15 IS NULL)
                    AND (X_global_attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute16 =  X_global_attribute16)
                OR (    (Recinfo.global_attribute16 IS NULL)
                    AND (X_global_attribute16 IS NULL)))
           AND (   (Recinfo.global_attribute17 =  X_global_attribute17)
                OR (    (Recinfo.global_attribute17 IS NULL)
                    AND (X_global_attribute17 IS NULL)))
           AND (   (Recinfo.global_attribute18 =  X_global_attribute18)
                OR (    (Recinfo.global_attribute18 IS NULL)
                    AND (X_global_attribute18 IS NULL)))
           AND (   (Recinfo.global_attribute19 =  X_global_attribute19)
                OR (    (Recinfo.global_attribute19 IS NULL)
                    AND (X_global_attribute19 IS NULL)))
           AND (   (Recinfo.global_attribute20 =  X_global_attribute20)
                OR (    (Recinfo.global_attribute20 IS NULL)
                    AND (X_global_attribute20 IS NULL)))
          ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

       -- Invoice Lines Project Stage 1
       IF (
           (   (Recinfo.rOUNDING_AMT =  X_ROUNDING_AMT)
                OR (    (Recinfo.ROUNDING_AMT IS NULL)
                    AND (X_ROUNDING_AMT IS NULL)))
           AND (   (Recinfo.CHARGE_APPLICABLE_TO_DIST_ID =  X_CHARGE_APPLICABLE_TO_DIST_ID)
                OR (    (Recinfo.CHARGE_APPLICABLE_TO_DIST_ID IS NULL)
                    AND (X_CHARGE_APPLICABLE_TO_DIST_ID IS NULL)))
           AND (   (Recinfo.CORRECTED_INVOICE_DIST_ID =  X_CORRECTED_INVOICE_DIST_ID)
                OR (    (Recinfo.CORRECTED_INVOICE_DIST_ID IS NULL)
                    AND (X_CORRECTED_INVOICE_DIST_ID IS NULL)))
           AND (   (Recinfo.RELATED_ID =  X_RELATED_ID)
                OR (    (Recinfo.RELATED_ID IS NULL)
                    AND (X_RELATED_ID IS NULL)))
           AND (   (Recinfo.ASSET_BOOK_TYPE_CODE =  X_ASSET_BOOK_TYPE_CODE)
                OR (    (Recinfo.ASSET_BOOK_TYPE_CODE IS NULL)
                    AND (X_ASSET_BOOK_TYPE_CODE IS NULL)))
           AND (   (Recinfo.ASSET_CATEGORY_ID =  X_ASSET_CATEGORY_ID)
                OR (    (Recinfo.ASSET_CATEGORY_ID IS NULL)
                    AND (X_ASSET_CATEGORY_ID IS NULL)))
           AND (   (Recinfo.INTENDED_USE =  X_INTENDED_USE)
	        OR (    (Recinfo.INTENDED_USE IS NULL)
	            AND (X_INTENDED_USE IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        END IF;
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Invoice_Id                     NUMBER,
                       -- Invoice Lines Project Stage 1
                       X_Invoice_Line_Number            NUMBER,
                       X_Distribution_Class             VARCHAR2,
                       X_Dist_Code_Combination_Id       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Accounting_Date                DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Amount                         NUMBER,
                       X_Description                    VARCHAR2,
                       X_Type_1099                      VARCHAR2,
                       X_Posted_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Quantity_Invoiced              NUMBER,
                       X_Unit_Price                     NUMBER,
                       X_Match_Status_Flag              VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Prepay_Amount_Remaining        NUMBER,
                       X_Assets_Addition_Flag           VARCHAR2,
                       X_Assets_Tracking_Flag           VARCHAR2,
                       X_Distribution_Line_Number       NUMBER,
                       X_Line_Type_Lookup_Code          VARCHAR2,
                       X_Po_Distribution_Id             NUMBER,
                       X_Base_Amount                    NUMBER,
                       X_Pa_Addition_Flag               VARCHAR2,
                       X_Posted_Amount                  NUMBER,
                       X_Posted_Base_Amount             NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Accrual_Posted_Flag            VARCHAR2,
                       X_Cash_Posted_Flag               VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Stat_Amount                    NUMBER,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Accts_Pay_Code_Comb_Id         NUMBER,
                       X_Reversal_Flag                  VARCHAR2,
                       X_Parent_Invoice_Id              NUMBER,
                       X_Income_Tax_Region              VARCHAR2,
                       X_Final_Match_Flag               VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Pa_Quantity                    NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Quantity_Variance              NUMBER,
                       X_Base_Quantity_Variance         NUMBER,
                       X_Packet_Id                      NUMBER,
                       X_Awt_Flag                       VARCHAR2,
                       X_Awt_Group_Id                   NUMBER,
		       X_Pay_Awt_Group_Id               NUMBER,--bug6639866
                       X_Awt_Tax_Rate_Id                NUMBER,
                       X_Awt_Gross_Amount               NUMBER,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Other_Invoice_Id               NUMBER,
                       X_Awt_Invoice_Id                 NUMBER,
                       X_Awt_Origin_Group_Id            NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_Request_Id                     NUMBER,
                       X_Tax_Recoverable_Flag           VARCHAR2,
                       X_Award_Id                       NUMBER,
                       X_Start_Expense_Date             DATE,
                       X_Merchant_Document_Number       VARCHAR2,
                       X_Merchant_Name                  VARCHAR2,
                       X_Merchant_Tax_Reg_Number        VARCHAR2,
                       X_Merchant_Taxpayer_Id           VARCHAR2,
                       X_Country_Of_Supply              VARCHAR2,
                       X_Merchant_Reference             VARCHAR2,
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_global_attribute1              VARCHAR2 DEFAULT NULL,
                       X_global_attribute2              VARCHAR2 DEFAULT NULL,
                       X_global_attribute3              VARCHAR2 DEFAULT NULL,
                       X_global_attribute4              VARCHAR2 DEFAULT NULL,
                       X_global_attribute5              VARCHAR2 DEFAULT NULL,
                       X_global_attribute6              VARCHAR2 DEFAULT NULL,
                       X_global_attribute7              VARCHAR2 DEFAULT NULL,
                       X_global_attribute8              VARCHAR2 DEFAULT NULL,
                       X_global_attribute9              VARCHAR2 DEFAULT NULL,
                       X_global_attribute10             VARCHAR2 DEFAULT NULL,
                       X_global_attribute11             VARCHAR2 DEFAULT NULL,
                       X_global_attribute12             VARCHAR2 DEFAULT NULL,
                       X_global_attribute13             VARCHAR2 DEFAULT NULL,
                       X_global_attribute14             VARCHAR2 DEFAULT NULL,
                       X_global_attribute15             VARCHAR2 DEFAULT NULL,
                       X_global_attribute16             VARCHAR2 DEFAULT NULL,
                       X_global_attribute17             VARCHAR2 DEFAULT NULL,
                       X_global_attribute18             VARCHAR2 DEFAULT NULL,
                       X_global_attribute19             VARCHAR2 DEFAULT NULL,
                       X_global_attribute20             VARCHAR2 DEFAULT NULL,
                       X_Calling_Sequence               VARCHAR2,
                       -- Invoice Lines Project Stage 1
                       X_rounding_amt                   NUMBER DEFAULT NULL,
                       X_charge_applicable_to_dist_id    NUMBER DEFAULT NULL,
                       X_corrected_invoice_dist_id      NUMBER DEFAULT NULL,
                       X_related_id                     NUMBER DEFAULT NULL,
                       X_asset_book_type_code           VARCHAR2 DEFAULT NULL,
                       X_asset_category_id              NUMBER DEFAULT NULL,
		       X_intended_use			VARCHAR2 DEFAULT NULL
  ) IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

    --Bug9819170
    l_return_status              VARCHAR2(2000) ;
    l_api_name                   CONSTANT VARCHAR2(100) := 'Update_Row';
    --Bug9819170


  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
    'AP_INVOICE_DISTRIBUTIONS_PKG.Update_Row<-'||X_Calling_Sequence;

     AP_AID_TABLE_HANDLER_PKG.Update_Row
             (X_Rowid,
              X_Invoice_Id,
              -- Invoice Lines Project Stage 1
              X_Invoice_Line_number,
              X_Distribution_Class,
              X_Dist_Code_Combination_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Accounting_Date,
              X_Period_Name,
              X_Set_Of_Books_Id,
              X_Amount,
              X_Description,
              X_Type_1099,
              X_Posted_Flag,
              X_Batch_Id,
              X_Quantity_Invoiced,
              X_Unit_Price,
              X_Match_Status_Flag,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Prepay_Amount_Remaining,
              X_Assets_Addition_Flag,
              X_Assets_Tracking_Flag,
              X_Distribution_Line_Number,
              X_Line_Type_Lookup_Code,
              X_Po_Distribution_Id,
              X_Base_Amount,
              X_Pa_Addition_Flag,
              X_Posted_Amount,
              X_Posted_Base_Amount,
              X_Encumbered_Flag,
              X_Accrual_Posted_Flag,
              X_Cash_Posted_Flag,
              X_Last_Update_Login,
              X_Stat_Amount,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute15,
              X_Accts_Pay_Code_Comb_Id,
              X_Reversal_Flag,
              X_Parent_Invoice_Id,
              X_Income_Tax_Region,
              X_Final_Match_Flag,
              X_Expenditure_Item_Date,
              X_Expenditure_Organization_Id,
              X_Expenditure_Type,
              X_Pa_Quantity,
              X_Project_Id,
              X_Task_Id,
              X_Quantity_Variance,
              X_Base_Quantity_Variance,
              X_Packet_Id,
              X_Awt_Flag,
              X_Awt_Group_Id,
	      X_Pay_Awt_Group_Id,--bug6639866
              X_Awt_Tax_Rate_Id,
              X_Awt_Gross_Amount,
              X_Reference_1,
              X_Reference_2,
              X_Org_Id,
              X_Other_Invoice_Id,
              X_Awt_Invoice_Id,
              X_Awt_Origin_Group_Id,
              X_Program_Application_Id,
              X_Program_Id,
              X_Program_Update_Date,
              X_Request_Id,
              X_Tax_Recoverable_Flag,
              X_Award_Id,
              X_Start_Expense_Date,
              X_Merchant_Document_Number,
              X_Merchant_Name,
              X_Merchant_Tax_Reg_Number,
              X_Merchant_Taxpayer_Id,
              X_Country_Of_Supply,
              X_Merchant_Reference,
              X_global_attribute_category,
              X_global_attribute1,
              X_global_attribute2,
              X_global_attribute3,
              X_global_attribute4,
              X_global_attribute5,
              X_global_attribute6,
              X_global_attribute7,
              X_global_attribute8,
              X_global_attribute9,
              X_global_attribute10,
              X_global_attribute11,
              X_global_attribute12,
              X_global_attribute13,
              X_global_attribute14,
              X_global_attribute15,
              X_global_attribute16,
              X_global_attribute17,
              X_global_attribute18,
              X_global_attribute19,
              X_global_attribute20,
              current_calling_sequence,
              -- Invoice Lines Project Stage 1
              X_rounding_amt,
              X_charge_applicable_to_dist_id,
              X_corrected_invoice_dist_id,
              X_related_id,
              X_asset_book_type_code,
              X_asset_category_id,
	      X_intended_use
             );


            --Bug9819170
            debug_info :='CALL synchronize_tax_dff';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
            END IF;

               ap_etax_services_pkg.synchronize_tax_dff
                  (p_invoice_id            =>  X_Invoice_Id,
                   p_invoice_dist_id       =>  NULL,
                   p_related_id            =>  X_related_id,
                   p_detail_tax_dist_id    =>  NULL,
                   p_line_type_lookup_code =>  NULL,
                   p_invoice_line_number   =>  X_Invoice_Line_Number,
                   p_distribution_line_number => X_Distribution_Line_Number,
                   P_ATTRIBUTE1            =>  X_Attribute1,
                   P_ATTRIBUTE2            =>  X_Attribute2,
                   P_ATTRIBUTE3            =>  X_Attribute3,
                   P_ATTRIBUTE4            =>  X_Attribute4,
                   P_ATTRIBUTE5            =>  X_Attribute5,
                   P_ATTRIBUTE6            =>  X_Attribute6,
                   P_ATTRIBUTE7            =>  X_Attribute7,
                   P_ATTRIBUTE8            =>  X_Attribute8,
                   P_ATTRIBUTE9            =>  X_Attribute9,
                   P_ATTRIBUTE10           =>  X_Attribute10,
                   P_ATTRIBUTE11           =>  X_Attribute11,
                   P_ATTRIBUTE12           =>  X_Attribute12,
                   P_ATTRIBUTE13           =>  X_Attribute13,
                   P_ATTRIBUTE14           =>  X_Attribute14,
                   P_ATTRIBUTE15           =>  X_Attribute15,
                   P_ATTRIBUTE_CATEGORY    =>  X_Attribute_Category,
                   p_calling_sequence      =>  current_calling_sequence,
                   x_return_status         =>  l_return_status);

            --Bug9819170


  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;


 PROCEDURE Delete_Row(X_Rowid            VARCHAR2,
                       X_Calling_Sequence VARCHAR2) IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
    l_invoice_distribution_id       AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;

   BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
    'AP_INVOICE_DISTRIBUTIONS_PKG.Delete_Row<-'||X_Calling_Sequence;

     AP_AID_TABLE_HANDLER_PKG.Delete_Row(
       X_Rowid,
       current_calling_sequence);

  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;


  FUNCTION Get_UOM_From_Segments(
          X_Concatenated_Segments         IN      VARCHAR2,
          X_Ch_Of_Accts_Id                IN      NUMBER)
  RETURN VARCHAR2 IS

       l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
       l_num_segments                  NUMBER;
       l_account_segment_num           NUMBER;
       l_result                        BOOLEAN;
       l_segment_delimiter             VARCHAR2(1);
       l_uom                           gl_stat_account_uom.unit_of_measure%TYPE;
       l_status                        VARCHAR2(10) := '';
       l_industry                      VARCHAR2(10) := '';

  BEGIN
       -- Verify GL is installed
       --
       IF (FND_INSTALLATION.GET(101, 101, l_status, l_industry)) then
         IF (l_status <> 'I') then
           return('');
         END IF;
       ELSE
         return('');
       END IF;

       -- Get the delimiter used in the Accounting FF
       --
       l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                                'SQLGL',
                                                'GL#',
                                                X_Ch_Of_Accts_Id);

       IF (l_segment_delimiter IS NULL) THEN
             RETURN('');
       END IF;

       -- Break the passed concatenated segment into an array of segments
       --
       IF (X_Concatenated_Segments IS NOT NULL) THEN
           l_num_segments := FND_FLEX_EXT.breakup_segments(X_concatenated_segments,
                                          l_segment_delimiter,
                                          l_segments); --OUT
       END IF;

       -- Get the index of the Account segment in the FF
       --
       l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                    101,
                                    'GL#',
                                    X_Ch_Of_Accts_Id,
                                    'GL_ACCOUNT',
                                    l_account_segment_num);

       IF (NOT l_result) THEN
           RETURN('');
       END IF;

       -- Using the segment array and the index: Get the UOM value
       --
       SELECT unit_of_measure
       INTO   l_uom
       FROM   gl_stat_account_uom
       WHERE  account_segment_value = l_segments(l_account_segment_num)
       AND chart_of_accounts_id = X_Ch_Of_Accts_Id;

       RETURN(l_uom);

  EXCEPTION
     WHEN OTHERS THEN
        RETURN('');

  END Get_UOM_From_Segments;


  -- Bug 1567235.
  /* Function to get the sum of distribution amount for a given invoice
     and the balancing segment  */
  FUNCTION Get_Segment_Dist_Amount(
           X_Invoice_Id                   IN      NUMBER,
           X_Prepay_Dist_CCID             IN      NUMBER,
           X_Sob_Id                       IN      NUMBER) RETURN NUMBER IS

  l_dist_amount    NUMBER;

  BEGIN

     -- Bug 1892826. Added the line_type_lookup_code predicate
     -- Bug 2404982.  Added package qualifier to procedure call.
     SELECT sum(amount)
       INTO l_dist_amount
       FROM ap_invoice_distributions
      WHERE invoice_id = X_Invoice_Id
        AND line_type_lookup_code IN ('ITEM','PREPAY')
        AND nvl(reversal_flag,'N') <> 'Y'
        AND AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    dist_code_combination_id, X_Sob_Id) =
                AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    X_Prepay_Dist_CCID, X_Sob_Id);

     RETURN (l_dist_amount);

  END Get_Segment_Dist_Amount;


  -- Bug 1567235.
  /* Procedure to get the sum of distribution amount for a given invoice
     and the sum of the distribution amount for a given prepayment */
  PROCEDURE Get_Prepay_Amount_Available(
            X_Invoice_ID                   IN      NUMBER,
            X_Prepay_ID                    IN      NUMBER,
            X_Sob_Id                       IN      NUMBER,
            X_Balancing_Segment            OUT NOCOPY     VARCHAR2,
            X_Prepay_Amount                OUT NOCOPY     NUMBER,
            X_Invoice_Amount               OUT NOCOPY     NUMBER) IS

  l_prepay_amount         NUMBER;
  l_invoice_amount        NUMBER;
  l_bal_segment           VARCHAR2(30);

  -- Bug 2404982.  Added package qualifier to procedure call.
  CURSOR c_prepay_dist IS
  SELECT sum(nvl(prepay_amount_remaining,amount)),
         AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    aip.dist_code_combination_id, X_Sob_Id)
    FROM ap_invoice_distributions aip
   WHERE aip.invoice_id = X_Prepay_Id
     --bugfix:3881673
     AND aip.line_type_lookup_code in ('ITEM','ACCRUAL')
     AND nvl(aip.reversal_flag,'N') <> 'Y'
     AND nvl(aip.prepay_amount_remaining,amount) > 0
     AND AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    aip.dist_code_combination_id, X_Sob_Id) IN
             (SELECT AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    aid.dist_code_combination_id, X_Sob_Id)
                FROM ap_invoice_distributions aid
               WHERE aid.invoice_id = X_Invoice_ID)
   GROUP BY AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    aip.dist_code_combination_id, X_Sob_Id)
   ORDER BY AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    aip.dist_code_combination_id, X_Sob_Id);

  BEGIN

     OPEN c_prepay_dist;
     LOOP
       FETCH c_prepay_dist into l_prepay_amount, l_bal_segment;
       EXIT WHEN c_prepay_dist%NOTFOUND;

  -- Bug 2404982.  Added package qualifier to procedure call
       SELECT sum(amount)
         INTO l_invoice_amount
         FROM ap_invoice_distributions
        WHERE invoice_id = X_Invoice_ID
          AND line_type_lookup_code IN ('ITEM','PREPAY')
          AND nvl(reversal_flag,'N') <> 'Y'
          AND AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
    dist_code_combination_id, X_Sob_Id)
                   = l_bal_segment;

       IF l_invoice_amount <> 0 THEN
          EXIT;
       END IF;

     END LOOP;
     CLOSE c_prepay_dist;

     X_Balancing_Segment := l_bal_segment;
     X_Prepay_Amount := l_prepay_amount;
     X_Invoice_Amount := l_invoice_amount;

  END Get_Prepay_Amount_Available;


  -- Bug 1648309.
  /* Function to check if an invoice has item lines with different balancing
     segments. */
  FUNCTION Check_Diff_Dist_Segments(
           X_Invoice_Id                   IN      NUMBER,
           X_Sob_Id                       IN      NUMBER) RETURN BOOLEAN IS

  l_dist_count         NUMBER;

  BEGIN

  --Bug 2404982. Added package qualifier to procedure call.
     SELECT count(distinct(
                 AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
                 dist_code_combination_id, X_Sob_Id)) )
       INTO l_dist_count
       FROM ap_invoice_distributions
      WHERE invoice_id = X_Invoice_Id;

     IF l_dist_count > 1 THEN
        RETURN (TRUE);
     ELSE
        RETURN (FALSE);
     END IF;

  END Check_Diff_Dist_Segments;


  -- Bug 1567235
  /* Function to get the value of the balancing segment for a given
     CCID */
FUNCTION get_balancing_segment_value(
         X_Dist_Code_Combination_Id      IN      NUMBER,
         X_Sob_Id                        IN      NUMBER) RETURN VARCHAR2 IS

  l_dist_segments            FND_FLEX_EXT.SEGMENTARRAY ;
  l_segments                 FND_FLEX_EXT.SEGMENTARRAY ;
  l_num_of_segments          NUMBER ;
  l_result                   BOOLEAN ;
  l_coa_id                   NUMBER ;
  l_flex_segment_num         NUMBER ;

BEGIN

  SELECT chart_of_accounts_id
  INTO   l_coa_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = X_Sob_Id;

  -- Get the segments of the two given accounts
  IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL', 'GL#',
                                    l_coa_id,
                                    X_Dist_Code_Combination_Id,
                                    l_num_of_segments,
                                    l_dist_segments)
     ) THEN

    -- Return -1 if flex failed
    RETURN (-1);

  END IF;

  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                              101, 'GL#',
                              l_coa_id,
                              'GL_BALANCING',
                              l_flex_segment_num)
     ) THEN

    RETURN (-1);

  END IF;

  FOR i IN 1.. l_num_of_segments LOOP

    IF (i = l_flex_segment_num) THEN
        RETURN(l_dist_segments(i));
    END IF;

  END LOOP;

END Get_Balancing_Segment_Value;

  -- Bug 2118673
  /* Function to get the value of the balancing segment for a given
     account */
FUNCTION get_balancing_seg_from_acc(
         X_account      IN      VARCHAR2,
         X_Sob_Id       IN      NUMBER) RETURN VARCHAR2 IS

  l_delimiter                VARCHAR2(1);
  l_dist_segments            FND_FLEX_EXT.SEGMENTARRAY ;
  l_num_of_segments          NUMBER ;
  l_coa_id                   NUMBER ;
  l_flex_segment_num         NUMBER ;

BEGIN

  SELECT chart_of_accounts_id
  INTO   l_coa_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = X_Sob_Id;

  -- Get the delimiter
  l_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL', 'GL#', l_coa_id);

  -- Get the segments
  l_num_of_segments := FND_FLEX_EXT.BREAKUP_SEGMENTS(
                                      x_account, l_delimiter,
                                      l_dist_segments);

  -- Get the balancing segment number
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                              101, 'GL#',
                              l_coa_id,
                              'GL_BALANCING',
                              l_flex_segment_num)) THEN

    RETURN (-1);
  END IF;

  IF l_flex_segment_num > 0 AND l_flex_segment_num <= l_num_of_segments THEN
        RETURN(l_dist_segments(l_flex_segment_num));
  ELSE
        RETURN(NULL);
  END IF;
END Get_Balancing_Seg_from_acc;




  PROCEDURE Round_Biggest_Distribution(
          X_Base_Currency_Code IN VARCHAR2,
          X_Invoice_Id         IN NUMBER,
          X_Calling_Sequence   IN VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN

    -- Update current calling sequence
    --
    current_calling_sequence :=
    'AP_INVOICE_DISTRIBUTIONS_PKG.Round_Biggest_Distribution<-'
       ||X_Calling_Sequence;

    debug_info := 'Adjusting distribution amount in biggest distribution';

    -- bug 5052661 --  modified SELECT portion of SQL in where clause to go to base tables to avoid FTS
    UPDATE ap_invoice_distributions d1
       SET base_amount =
           (SELECT DECODE(SIGN(SUM(d2.base_amount) -
                            DECODE(max(f.minimum_accountable_unit), NULL,
                                   ROUND((SUM(d2.amount)
                                          * i.exchange_rate),MAX(f.precision)),
                                   ROUND((SUM(d2.amount) * i.exchange_rate)
                                         / MAX(f.minimum_accountable_unit)) *
                                   MAX(f.minimum_accountable_unit))),
                        1, d1.base_amount
                            - (SUM(d2.base_amount) -
                               DECODE(MAX(f.minimum_accountable_unit), NULL,
                                      ROUND((SUM(d2.amount)
                                             * i.exchange_rate),
                                            MAX(f.precision)),
                                      ROUND((SUM(d2.amount) * i.exchange_rate)
                                            / MAX(f.minimum_accountable_unit))*
                                      MAX(f.minimum_accountable_unit))),
                        -1, d1.base_amount
                             - (SUM(d2.base_amount) -
                                DECODE(MAX(f.minimum_accountable_unit), NULL,
                                       ROUND((SUM(d2.amount) *
                                              i.exchange_rate),
                                             MAX(f.precision)),
                                       ROUND((SUM(d2.amount) * i.exchange_rate)
                                            /MAX(f.minimum_accountable_unit))*
                                       MAX(f.minimum_accountable_unit))),
                        d1.base_amount)
              FROM ap_invoices i, ap_invoice_distributions d2, fnd_currencies F
             WHERE d1.invoice_id = i.invoice_id
               AND d1.invoice_id = d2.invoice_id
               AND f.currency_code = X_Base_Currency_Code
             GROUP BY i.exchange_rate)
     WHERE d1.invoice_id = X_Invoice_Id
       AND d1.posted_flag = 'N'
       AND (d1.invoice_id, d1.distribution_line_number) IN
           (SELECT d5.invoice_id, MAX(d5.distribution_line_number)
              FROM ap_invoice_distributions_all d5
             WHERE (d5.invoice_id, abs(d5.amount)) IN
                (SELECT i1.invoice_id , MAX(ABS(d3.amount))
                   FROM ap_invoices_all i1, ap_invoice_distributions_all d3
                  WHERE i1.invoice_id = X_Invoice_Id
                    AND i1.invoice_id = d3.invoice_id
                    AND d3.line_type_lookup_code <> 'TAX'
                    AND NOT EXISTS
                      (SELECT d4.invoice_id
                         FROM ap_invoice_distributions_all d4
                        WHERE d4.invoice_id = X_Invoice_Id
                          AND (1 = DECODE(X_Base_Currency_Code,
                                      i1.invoice_currency_code,1,
                                      DECODE(d4.exchange_rate,null,1,0))
                           OR    1 = DECODE(X_Base_Currency_Code,
                                     i1.invoice_currency_code,
                                     1,DECODE(d4.base_amount,null,1,0))))
                  GROUP BY i1.invoice_id, i1.invoice_amount
                 HAVING nvl(i1.invoice_amount,0) = nvl(sum(d3.amount),0))
             GROUP BY d5.invoice_id);


  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Round_Biggest_Distribution;


  -----------------------------------------------------------------------
  -- FUNCTION insert_single_dist_from_line inserts a record into
  -- ap_invoice_distributions given a line number number and/or line record.
  -- It returns FALSE if an error is encountered.
  -----------------------------------------------------------------------
  FUNCTION Insert_Single_Dist_From_Line(
           X_batch_id            IN         AP_INVOICES.BATCH_ID%TYPE,
           X_invoice_id          IN         NUMBER,
           X_invoice_date        IN         AP_INVOICES.INVOICE_DATE%TYPE,
           X_vendor_id           IN         AP_INVOICES.VENDOR_ID%TYPE,
           X_invoice_currency    IN         AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
           X_exchange_rate       IN         AP_INVOICES.EXCHANGE_RATE%TYPE,
           X_exchange_rate_type  IN         AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE,
           X_exchange_date       IN         AP_INVOICES.EXCHANGE_DATE%TYPE,
           X_line_number         IN         NUMBER,
           X_invoice_lines_rec   IN         AP_INVOICES_PKG.r_invoice_line_rec,
           X_line_source         IN         VARCHAR2,
           X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
           X_Validate_Info       IN         BOOLEAN DEFAULT TRUE,
           X_Error_Code          OUT NOCOPY VARCHAR2,
           X_Debug_Info          OUT NOCOPY VARCHAR2,
           X_Debug_Context       OUT NOCOPY VARCHAR2,
           X_Msg_Application     OUT NOCOPY VARCHAR2,
           X_Msg_Data            OUT NOCOPY VARCHAR2,
           X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN
  IS

  CURSOR line_rec IS
  SELECT INVOICE_ID,
      LINE_NUMBER,
      LINE_TYPE_LOOKUP_CODE,
      REQUESTER_ID,
      DESCRIPTION,
      LINE_SOURCE,
      ORG_ID,
      LINE_GROUP_NUMBER,
      INVENTORY_ITEM_ID,
      ITEM_DESCRIPTION,
      SERIAL_NUMBER,
      MANUFACTURER,
      MODEL_NUMBER,
      WARRANTY_NUMBER,
      GENERATE_DISTS,
      MATCH_TYPE,
      DISTRIBUTION_SET_ID,
      ACCOUNT_SEGMENT,
      BALANCING_SEGMENT,
      COST_CENTER_SEGMENT,
      OVERLAY_DIST_CODE_CONCAT,
      DEFAULT_DIST_CCID,
      PRORATE_ACROSS_ALL_ITEMS,
      ACCOUNTING_DATE,
      PERIOD_NAME,
      DEFERRED_ACCTG_FLAG,
      DEF_ACCTG_START_DATE,
      DEF_ACCTG_END_DATE,
      DEF_ACCTG_NUMBER_OF_PERIODS,
      DEF_ACCTG_PERIOD_TYPE,
      SET_OF_BOOKS_ID,
      AMOUNT,
      BASE_AMOUNT,
      ROUNDING_AMT,
      QUANTITY_INVOICED,
      UNIT_MEAS_LOOKUP_CODE,
      UNIT_PRICE,
      WFAPPROVAL_STATUS,
      DISCARDED_FLAG,
      ORIGINAL_AMOUNT,
      ORIGINAL_BASE_AMOUNT,
      ORIGINAL_ROUNDING_AMT,
      CANCELLED_FLAG,
      INCOME_TAX_REGION,
      TYPE_1099,
      STAT_AMOUNT,
      PREPAY_INVOICE_ID,
      PREPAY_LINE_NUMBER,
      INVOICE_INCLUDES_PREPAY_FLAG,
      CORRECTED_INV_ID,
      CORRECTED_LINE_NUMBER,
      PO_HEADER_ID,
      PO_LINE_ID,
      PO_RELEASE_ID,
      PO_LINE_LOCATION_ID,
      PO_DISTRIBUTION_ID,
      RCV_TRANSACTION_ID,
      FINAL_MATCH_FLAG,
      ASSETS_TRACKING_FLAG,
      ASSET_BOOK_TYPE_CODE,
      ASSET_CATEGORY_ID,
      PROJECT_ID,
      TASK_ID,
      EXPENDITURE_TYPE,
      EXPENDITURE_ITEM_DATE,
      EXPENDITURE_ORGANIZATION_ID,
      PA_QUANTITY,
      PA_CC_AR_INVOICE_ID,
      PA_CC_AR_INVOICE_LINE_NUM ,
      PA_CC_PROCESSED_CODE,
      AWARD_ID,
      AWT_GROUP_ID,
      REFERENCE_1,
      REFERENCE_2,
      RECEIPT_VERIFIED_FLAG,
      RECEIPT_REQUIRED_FLAG,
      RECEIPT_MISSING_FLAG,
      JUSTIFICATION,
      EXPENSE_GROUP,
      START_EXPENSE_DATE,
      END_EXPENSE_DATE,
      RECEIPT_CURRENCY_CODE,
      RECEIPT_CONVERSION_RATE,
      RECEIPT_CURRENCY_AMOUNT,
      DAILY_AMOUNT,
      WEB_PARAMETER_ID,
      ADJUSTMENT_REASON,
      MERCHANT_DOCUMENT_NUMBER,
      MERCHANT_NAME,
      MERCHANT_REFERENCE,
      MERCHANT_TAX_REG_NUMBER,
      MERCHANT_TAXPAYER_ID,
      COUNTRY_OF_SUPPLY,
      CREDIT_CARD_TRX_ID,
      COMPANY_PREPAID_INVOICE_ID,
      CC_REVERSAL_FLAG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      REQUEST_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      --ETAX: Invwkb, added included_tax_amount as modified the def
      --of ap_invoices_pkg.r_invoice_line_rec
      INCLUDED_TAX_AMOUNT,
      PRIMARY_INTENDED_USE,
      APPLICATION_ID,
      PRODUCT_TABLE,
      REFERENCE_KEY1,
      REFERENCE_KEY2,
      REFERENCE_KEY3,
      REFERENCE_KEY4,
      REFERENCE_KEY5,
      --bugfix:4674194
      SHIP_TO_LOCATION_ID,
      --bug7022001
      PAY_AWT_GROUP_ID
     FROM ap_invoice_lines_all
    WHERE invoice_id = X_invoice_id
      AND line_number = X_line_number;


  l_invoice_line_rec            AP_INVOICES_PKG.r_invoice_line_rec;
  l_invoice_attribute_rec       AP_UTILITIES_PKG.r_invoice_attribute_rec; --bug 8713737

  l_distribution_class
      AP_INVOICE_DISTRIBUTIONS.DISTRIBUTION_CLASS%TYPE;
  l_dist_ccid
      AP_INVOICE_DISTRIBUTIONS.DIST_CODE_COMBINATION_ID%TYPE;
  l_base_currency_code         AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
  l_chart_of_accounts_id       GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
  l_account_type               GL_CODE_COMBINATIONS.ACCOUNT_TYPE%TYPE;
  l_assets_tracking_flag
      AP_INVOICE_DISTRIBUTIONS.ASSETS_TRACKING_FLAG%TYPE;
  l_employee_id                AP_SUPPLIERS.EMPLOYEE_ID%TYPE;
  l_accounting_date            AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE;
  l_open_gl_date               AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE;
  l_open_period_name           AP_INVOICE_LINES.PERIOD_NAME%TYPE;
  user_id                      NUMBER;
  l_msg_application            VARCHAR2(25);
  l_msg_type                   VARCHAR2(25);
  l_msg_token1                 VARCHAR2(30);
  l_msg_token2                 VARCHAR2(30);
  l_msg_token3                 VARCHAR2(30);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(30);
  l_billable_flag              VARCHAR2(25);
  l_pa_allows_overrides        VARCHAR2(1) := 'N';
  l_error_found                VARCHAR2(1) := 'N';
  l_existing_distributions     NUMBER := 0;
  l_unbuilt_flex               VARCHAR2(240):='';
  l_reason_unbuilt_flex        VARCHAR2(2000):='';
  current_calling_sequence     VARCHAR2(2000);
  debug_info                   VARCHAR2(2000);
  --bug 8980626, size should be 2000 as error messages are assigned to it
  debug_context                VARCHAR2(2000);
  l_dist_code_concat           VARCHAR2(2000);
  l_invoice_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_invoice_type_lookup_code   ap_invoices_all.invoice_type_lookup_code%TYPE;
  l_sys_link_function          VARCHAR2(2); /* Bug 5102724 */
  l_web_parameter_id           number; --Bug5003249
  l_employee_ccid              number;
  l_message_text	       fnd_new_messages.message_text%type;
  l_copy_line_dff_flag         VARCHAR2(1); -- Bug 6837035
  l_copy_line_gdff_flag        VARCHAR2(1); -- Bug 8788072

  l_country_code               VARCHAR2(20);  --bug 9169915

  BEGIN

  --------------------------------------------------------------------------
  -- Step 1 - Update the calling sequence
  --------------------------------------------------------------------------
  current_calling_sequence :=
      'AP_INVOICE_DISTRIBUTIONS_PKG.insert_single_dist_from_line <-'||
      X_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 2 - If calling module provided X_invoice_id / X_line_number, then
  -- we assume the calling module is not passing a line record.  Read the line
  -- record from the transaction tables.
  -------------------------------------------------------------------------
  debug_info := 'Verify line record';
  IF (X_invoice_id IS NOT NULL AND X_line_number IS NOT NULL) THEN
    BEGIN
      OPEN line_rec;
      FETCH line_rec INTO l_invoice_line_rec;
      IF (line_rec%NOTFOUND) THEN
        CLOSE line_rec;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE line_Rec;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug_info := debug_info ||': No valid line record was found.';
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        return(FALSE);
    END;
  ELSE
    l_invoice_line_rec := X_invoice_lines_rec;
    IF (X_invoice_lines_rec.invoice_id IS NULL AND
        X_invoice_lines_rec.line_number is NULL ) THEN
      X_debug_info := debug_info || ': line not provided';
      X_debug_context := current_calling_sequence;
      RETURN (FALSE);
    END IF;
  END IF;

  ----------------------------------------------------------------------------
  -- Step 3 - Validate line does not contain other distributions
  ----------------------------------------------------------------------------
  IF (X_Validate_Info) then
    debug_info := 'Verify line does not contain distributions';
    BEGIN
      SELECT count(*)
      INTO l_existing_distributions
      FROM ap_invoice_distributions
     WHERE invoice_id = l_invoice_line_rec.invoice_id
       AND invoice_line_number = l_invoice_line_rec.line_number;

      IF (l_existing_distributions <> 0) then
        X_debug_info := debug_info || ': line already has distributions';
        X_debug_context := current_calling_sequence;
        RETURN(FALSE);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END IF; -- If calling module requested validation

  /* Bug  8713737 Begin */
  ---------------------------------------------------------------------------
  -- Step 3 b - Get the Invoice and Line DFF Info
  ---------------------------------------------------------------------------
  debug_info := 'Step 3 b - Get the Invoice and Line DFF Info';
  BEGIN
        select  attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
        into    l_invoice_attribute_rec.attribute_category,
                l_invoice_attribute_rec.attribute1,
                l_invoice_attribute_rec.attribute2,
                l_invoice_attribute_rec.attribute3,
                l_invoice_attribute_rec.attribute4,
                l_invoice_attribute_rec.attribute5,
                l_invoice_attribute_rec.attribute6,
                l_invoice_attribute_rec.attribute7,
                l_invoice_attribute_rec.attribute8,
                l_invoice_attribute_rec.attribute9,
                l_invoice_attribute_rec.attribute10,
                l_invoice_attribute_rec.attribute11,
                l_invoice_attribute_rec.attribute12,
                l_invoice_attribute_rec.attribute13,
                l_invoice_attribute_rec.attribute14,
                l_invoice_attribute_rec.attribute15
        from    ap_invoices
        where   invoice_id = l_invoice_line_rec.invoice_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        debug_info := debug_info ||': Failed to fetch Invoice header DFF info.';
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        return(FALSE);
  END;
    -- need to copy the line attributes to pass to PA APIs irrespective of
    -- whether these are copied to distribution or not.

    l_invoice_attribute_rec.line_attribute_category := l_invoice_line_rec.ATTRIBUTE_CATEGORY;
    l_invoice_attribute_rec.line_attribute1  := l_invoice_line_rec.ATTRIBUTE1 ;
    l_invoice_attribute_rec.line_attribute2  := l_invoice_line_rec.ATTRIBUTE2 ;
    l_invoice_attribute_rec.line_attribute3  := l_invoice_line_rec.ATTRIBUTE3 ;
    l_invoice_attribute_rec.line_attribute4  := l_invoice_line_rec.ATTRIBUTE4 ;
    l_invoice_attribute_rec.line_attribute5  := l_invoice_line_rec.ATTRIBUTE5 ;
    l_invoice_attribute_rec.line_attribute6  := l_invoice_line_rec.ATTRIBUTE6 ;
    l_invoice_attribute_rec.line_attribute7  := l_invoice_line_rec.ATTRIBUTE7 ;
    l_invoice_attribute_rec.line_attribute8  := l_invoice_line_rec.ATTRIBUTE8 ;
    l_invoice_attribute_rec.line_attribute9  := l_invoice_line_rec.ATTRIBUTE9 ;
    l_invoice_attribute_rec.line_attribute10 := l_invoice_line_rec.ATTRIBUTE10;
    l_invoice_attribute_rec.line_attribute11 := l_invoice_line_rec.ATTRIBUTE11;
    l_invoice_attribute_rec.line_attribute12 := l_invoice_line_rec.ATTRIBUTE12;
    l_invoice_attribute_rec.line_attribute13 := l_invoice_line_rec.ATTRIBUTE13;
    l_invoice_attribute_rec.line_attribute14 := l_invoice_line_rec.ATTRIBUTE14;
    l_invoice_attribute_rec.line_attribute15 := l_invoice_line_rec.ATTRIBUTE15;
  /* Bug  8713737 End */

  -- Bug 6837035 Retrieve the profile value to check if the DFF info should be
  -- copied onto distributions for imported lines.
  l_copy_line_dff_flag := NVL(fnd_profile.value('AP_COPY_INV_LINE_DFF'),'N');
  IF NVL(l_invoice_line_rec.line_source, 'DUMMY') <> 'IMPORTED' OR l_copy_line_dff_flag <> 'Y' THEN
    l_invoice_line_rec.ATTRIBUTE_CATEGORY := NULL;
    l_invoice_line_rec.ATTRIBUTE1 := NULL;
    l_invoice_line_rec.ATTRIBUTE2 := NULL;
    l_invoice_line_rec.ATTRIBUTE3 := NULL;
    l_invoice_line_rec.ATTRIBUTE4 := NULL;
    l_invoice_line_rec.ATTRIBUTE5 := NULL;
    l_invoice_line_rec.ATTRIBUTE6 := NULL;
    l_invoice_line_rec.ATTRIBUTE7 := NULL;
    l_invoice_line_rec.ATTRIBUTE8 := NULL;
    l_invoice_line_rec.ATTRIBUTE9 := NULL;
    l_invoice_line_rec.ATTRIBUTE10 := NULL;
    l_invoice_line_rec.ATTRIBUTE11 := NULL;
    l_invoice_line_rec.ATTRIBUTE12 := NULL;
    l_invoice_line_rec.ATTRIBUTE13 := NULL;
    l_invoice_line_rec.ATTRIBUTE14 := NULL;
    l_invoice_line_rec.ATTRIBUTE15 := NULL;
  END IF;
  -- Bug 6837035 End

  -- Bug 8788072 Start
  IF NVL(l_invoice_line_rec.line_source, 'DUMMY') = 'IMPORTED' THEN
    IF jg_globe_flex_val.Gdf_Context_Exists(l_invoice_line_rec.GLOBAL_ATTRIBUTE_CATEGORY) THEN
        l_copy_line_gdff_flag:='Y';
    ELSE
        l_copy_line_gdff_flag:='N';
    END IF;
  END IF;
  -- Bug 8788072 End

  ----------------------------------------------------------------------------
  -- Step 4 - Get GL Date and Period name.  Only if not called from the
  -- Open interface since Validation of the Import already verifies gl date
  -- nd period.
  ----------------------------------------------------------------------------
  IF (nvl(X_line_source, 'OTHERS') <> 'IMPORT') then
    debug_info := 'Get gl date from open period if line gl date is in' ||
                  'a closed one';
    BEGIN
      l_open_period_name := NULL;

      l_open_period_name :=
        AP_UTILITIES_PKG.GET_CURRENT_GL_DATE(
                l_invoice_line_rec.accounting_date,
	        l_invoice_line_rec.org_id);

      IF (l_open_period_name is NULL) then
        AP_UTILITIES_PKG.GET_OPEN_GL_DATE(l_invoice_line_rec.accounting_date,
                                          l_open_period_name,
                                          l_open_gl_date);
      --Invoice Lines: Distributions
      --For the case when the accounting_date on the line fell in an open
      --period, we were trying to insert NULL into a NOT NULL column
      --accounting_date, since the variable l_open_gl_date was not being
      --populated properly.
      ELSE
        l_open_gl_date := l_invoice_line_rec.accounting_date;
      END IF;
      IF (l_open_period_name is NULL) then
        X_error_code := 'AP_NO_OPEN_PERIOD';
        RETURN(FALSE);
      END IF;
    END;
  ELSE
    l_open_period_name := l_invoice_line_rec.period_name;
    l_open_gl_date := l_invoice_line_rec.accounting_date;
  END IF;

  --------------------------------------------------------------
  -- Step 5 - Get system level information necessary for
  -- validation and generation of distributions
  --------------------------------------------------------------
  debug_info := 'Get system information';
  BEGIN
    SELECT gsob.chart_of_accounts_id, ap.base_currency_code
      INTO l_chart_of_accounts_id, l_base_currency_code
      FROM ap_system_parameters ap, gl_sets_of_books gsob
     WHERE ap.set_of_books_id = gsob.set_of_books_id
       AND ap.set_of_books_id = l_invoice_line_rec.set_of_books_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Debug_info := debug_info || ': No GL information was found';
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
    RETURN(FALSE);
  END;


  ----------------------------------------------------------------------------
  -- Step 6 - Get Expenditure Item Date if PA related and if validation
  -- requested validate PA information. Note that expenditure item date may
  -- already be populated when the process is called from the Interface Import
  -- in which case we bypass getting the expenditure item date.

  ----------------------------------------------------------------------------
  debug_info := 'Get expenditure item date and validate if PA related';
  IF (l_invoice_line_rec.project_id is not null) then
    IF (l_invoice_line_rec.expenditure_item_date is null) then
      l_invoice_line_rec.expenditure_item_date :=
           AP_INVOICES_PKG.get_expenditure_item_date(
                                         l_invoice_line_rec.invoice_id,
                                         X_invoice_date,
                                         l_open_GL_date,
                                         NULL,
                                         NULL,
                                         l_error_found);
      IF (l_error_found = 'Y') then
        Debug_info :=
          debug_info ||': cannot read expenditure item date information';
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        RETURN(FALSE);
      END IF;
    END IF; -- Expenditure item date is null
    l_pa_allows_overrides :=
    FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES');

    -- The Import process should make the call with X_Validate_Info  FALSE
    -- since The same validation should have been done in the Import Validation

    IF (X_validate_info) then
      user_id := to_number(FND_PROFILE.VALUE('USER_ID'));

      BEGIN
        SELECT employee_id
          INTO l_employee_id
          FROM ap_suppliers  /* bUg 4718054 */
         WHERE DECODE(SIGN(TO_DATE(TO_CHAR(START_DATE_ACTIVE,'DD-MM-YYYY'),
               'DD-MM-YYYY') - TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY'),'DD-MM-YYYY')),
               1, 'N', DECODE(SIGN(TO_DATE(TO_CHAR(END_DATE_ACTIVE ,'DD-MM-YYYY'),
               'DD-MM-YYYY') -  TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY'),'DD-MM-YYYY')),
               -1, 'N', 0, 'N', 'Y')) = 'Y'
           AND enabled_flag = 'Y'
           AND vendor_id = X_vendor_id;
      EXCEPTION
        WHEN no_data_found then
          l_employee_id := NULL;
        WHEN OTHERS then
          l_employee_id := NULL;
      END;

--bug5003249
     Begin
        select default_code_comb_id
        into  l_employee_ccid
        from  PER_ASSIGNMENTS_F
        where person_id =  l_employee_id
        and   set_of_books_id =  l_invoice_line_rec.set_of_books_id
        and   trunc(sysdate) BETWEEN trunc(effective_start_date)
        and   nvl(trunc(effective_end_date), trunc(sysdate));
     EXCEPTION
         WHEN OTHERS then
          l_employee_ccid := NULL;
     End;

        select WEB_PARAMETER_ID
        into  l_web_parameter_id
        from  ap_invoice_lines
        where invoice_id = X_invoice_id
        AND line_number = X_line_number;

      /* Bug 5102724 */
      BEGIN
        SELECT invoice_type_lookup_code
        INTO   l_invoice_type_lookup_code
        FROM   ap_invoices_all
        WHERE  invoice_id = X_invoice_id;
      EXCEPTION
        WHEN no_data_found then
          NULL;
        WHEN OTHERS then
          NULL;
      END;

      If (l_invoice_type_lookup_code ='EXPENSE REPORT') Then
        l_sys_link_function :='ER' ;
      Else
        l_sys_link_function :='VI' ;
      End if;


    debug_info := 'Validate PA related information';
      PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
                    X_PROJECT_ID          => l_invoice_line_rec.project_id,
                    X_TASK_ID             => l_invoice_line_rec.task_id,
                    X_EI_DATE             => l_invoice_line_rec.expenditure_item_date,
                    X_EXPENDITURE_TYPE    => l_invoice_line_rec.expenditure_type,
                    X_NON_LABOR_RESOURCE  => null,
                    X_PERSON_ID           => l_employee_id,
                    X_QUANTITY            => nvl(l_invoice_line_rec.pa_quantity, '1'),
                    X_denom_currency_code => X_invoice_currency,
                    X_acct_currency_code  => l_base_currency_code,
                    X_denom_raw_cost      => l_invoice_line_rec.amount,
                    X_acct_raw_cost       => l_invoice_line_rec.base_amount,
                    X_acct_rate_type      => X_exchange_rate_type,
                    X_acct_rate_date      => X_exchange_date,
                    X_acct_exchange_rate  => X_exchange_rate,
                    X_TRANSFER_EI         => null,
                    X_INCURRED_BY_ORG_ID  => l_invoice_line_rec.expenditure_organization_id,
                    X_NL_RESOURCE_ORG_ID  => null,
                    X_TRANSACTION_SOURCE  => l_sys_link_function, /*bug 5102724 */
                    X_CALLING_MODULE      => 'apiindib.pls',
                    X_VENDOR_ID           => X_vendor_id,
                    X_ENTERED_BY_USER_ID  => user_id,
                    -- Bug 6837035 Start
                    X_ATTRIBUTE_CATEGORY  => l_invoice_line_rec.ATTRIBUTE_CATEGORY,
                    X_ATTRIBUTE1          => l_invoice_line_rec.ATTRIBUTE1,
                    X_ATTRIBUTE2          => l_invoice_line_rec.ATTRIBUTE2,
                    X_ATTRIBUTE3          => l_invoice_line_rec.ATTRIBUTE3,
                    X_ATTRIBUTE4          => l_invoice_line_rec.ATTRIBUTE4,
                    X_ATTRIBUTE5          => l_invoice_line_rec.ATTRIBUTE5,
                    X_ATTRIBUTE6          => l_invoice_line_rec.ATTRIBUTE6,
                    X_ATTRIBUTE7          => l_invoice_line_rec.ATTRIBUTE7,
                    X_ATTRIBUTE8          => l_invoice_line_rec.ATTRIBUTE8,
                    X_ATTRIBUTE9          => l_invoice_line_rec.ATTRIBUTE9,
                    X_ATTRIBUTE10         => l_invoice_line_rec.ATTRIBUTE10,
                    X_ATTRIBUTE11         => l_invoice_line_rec.ATTRIBUTE11,
                    X_ATTRIBUTE12         => l_invoice_line_rec.ATTRIBUTE12,
                    X_ATTRIBUTE13         => l_invoice_line_rec.ATTRIBUTE13,
                    X_ATTRIBUTE14         => l_invoice_line_rec.ATTRIBUTE14,
                    X_ATTRIBUTE15         => l_invoice_line_rec.ATTRIBUTE15,
                    -- Bug 6837035 End
                    X_msg_application     => l_msg_application,
                    X_msg_type            => l_msg_type,
                    X_msg_token1          => l_msg_token1,
                    X_msg_token2          => l_msg_token2,
                    X_msg_token3          => l_msg_token3,
                    X_msg_count           => l_msg_count,
                    X_msg_data            => l_msg_data,
                    X_BILLABLE_FLAG       => l_billable_flag);
        IF (l_msg_data is not null) THEN
          X_msg_application := l_msg_application;
          X_msg_data := l_msg_data;
	  --bugfix:5725904
	  Fnd_Message.Set_Name(l_msg_application, l_msg_data);
	  /*bug 6682104 setting the token values*/
            IF (l_msg_token1 IS NOT NULL) THEN
	       fnd_message.set_token('PATC_MSG_TOKEN1',l_msg_token1);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN1',FND_API.G_MISS_CHAR);
	    END IF;

            IF (l_msg_token2 IS NOT NULL) THEN
	        fnd_message.set_token('PATC_MSG_TOKEN2',l_msg_token2);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN2',FND_API.G_MISS_CHAR);
            END IF;

            IF (l_msg_token3 IS NOT NULL) THEN
	         fnd_message.set_token('PATC_MSG_TOKEN3',l_msg_token3);
            ELSE
	          fnd_message.set_token('PATC_MSG_TOKEN3',FND_API.G_MISS_CHAR);
            END IF;
	  l_message_text := Fnd_Message.get;
	  X_Error_Code := l_message_text;

          return(FALSE);
        END IF;
      END IF; -- X_validate_info is TRUE
    END IF; --l_project_id is not null

  ----------------------------------------------------------------------------
  -- Step 7 - Obtain final account and account related information.
  -- But only if calling module is not the Import since through the import
  -- The account should already be built.
  ----------------------------------------------------------------------------
  debug_info := 'Obtain account to be used in distribution';
  IF (nvl(X_line_source, 'OTHERS') <> 'IMPORT') then
    --Bug5003249 added condition on invoice type lookup code

    IF (l_invoice_line_rec.project_id is not null
        and l_invoice_type_lookup_code<>'PREPAYMENT') then
      -- Need to create a utility to flexbuild.  Look at import code.  Utility
      -- there is PA_FLEXBUILD

      debug_info := 'Billable Flag To PA FlexBuild '||l_billable_flag; --Bug6523162

      IF ( NOT (AP_UTILITIES_PKG.pa_flexbuild(
                    p_vendor_id                 => X_vendor_id,          --IN
                    p_employee_id               => l_employee_id,        --IN
                    p_set_of_books_id           =>
                      l_invoice_line_rec.set_of_books_id,                --IN
                    p_chart_of_accounts_id      =>
                      l_chart_of_accounts_id,                            --IN
                    p_base_currency_code        => l_base_currency_code, --IN
                    p_accounting_date           => l_open_GL_date,       --IN
                    p_award_id                  =>
                      l_invoice_line_rec.award_id,                       --IN
                    P_project_id                =>
                      l_invoice_line_rec.project_id,                     --IN
                    p_task_id                   =>
                      l_invoice_line_rec.task_id,                        --IN
                    p_expenditure_type          =>
                      l_invoice_line_rec.expenditure_type,
                    p_expenditure_org_id        =>
                      l_invoice_line_rec.expenditure_organization_id,
                    p_expenditure_item_date     =>
                      l_invoice_line_rec.expenditure_item_date,
                    p_invoice_attribute_rec     => l_invoice_attribute_rec, --bug 8713737
                    p_billable_flag             => l_billable_flag, --Bug6523162
                    p_employee_ccid             =>
                      l_employee_ccid,   --Bug5003249
                    p_web_parameter_id          =>
                      l_web_parameter_id,   --Bug5003249
                    p_invoice_type_lookup_code  =>
                      l_invoice_type_lookup_code, --Bug5003249
                    p_default_last_updated_by   => FND_GLOBAL.user_id,
                    p_default_last_update_login => FND_GLOBAL.login_id,
                    p_pa_default_dist_ccid      => l_dist_ccid,
                    p_pa_concatenated_segments  =>
                      l_dist_code_concat,                         --OUT NOCOPY
                    p_debug_Info                => debug_Info,    --OUT NOCOPY
                    p_debug_Context             => debug_Context, --OUT NOCOPY
                    p_calling_sequence          =>
                      'Get_Proj_And_Acc_For_Chrg_Dist' ,
                   p_default_dist_ccid         =>   l_invoice_line_rec.default_dist_ccid --IN bug 5386396
                  ))) THEN
        X_error_code := debug_Info; --Bug7598450
        debug_info := debug_info || ': Error encountered';
        debug_context := current_calling_sequence;
        RETURN(FALSE);
      END IF;

      IF (l_pa_allows_overrides = 'N') then
        IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                    l_dist_ccid,
                    l_chart_of_accounts_id,
                    l_open_gl_date,
                    current_calling_sequence))) then
          X_error_code := 'AP_INVALID_ACCOUNT';
          RETURN(FALSE);
        END IF;
      ELSE -- pa allows overrides is Y
        -- If the user provided an account at the line level,
        --  use it instead of the Account produced by PA
        IF (l_invoice_line_rec.default_dist_ccid is not null) then
         l_dist_ccid := l_invoice_line_rec.default_dist_ccid;
        END IF;
        IF (l_invoice_line_rec.overlay_dist_code_concat is NULL AND
            l_invoice_line_rec.balancing_segment is NULL AND
            l_invoice_line_rec.account_segment is NULL AND
            l_invoice_line_rec.cost_center_segment is NULL) then
          IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                       l_dist_ccid,
                       l_chart_of_accounts_id,
                       l_open_gl_date,
                       current_calling_sequence))) then
            X_error_code := 'AP_INVALID_ACCOUNT';
            RETURN(FALSE);
          END IF;
        ELSE
          IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                    l_invoice_line_rec.balancing_segment,
                    l_invoice_line_rec.cost_center_segment,
                    l_invoice_line_rec.account_segment,
                    l_invoice_line_rec.overlay_dist_code_concat,
                    l_dist_ccid,
                    l_invoice_line_rec.set_of_books_id,
                    'CREATE_COMB_NO_AT',
                    l_unbuilt_flex,
                    l_reason_unbuilt_flex,
                    FND_GLOBAL.RESP_APPL_ID,
                    FND_GLOBAL.RESP_ID,
                    FND_GLOBAL.USER_ID,
                    current_calling_sequence,
                    NULL,
                    l_open_gl_date))) THEN -- 7531219
            X_error_code := 'AP_CANNOT_OVERLAY';
            RETURN(FALSE);
          END IF;
        END IF; -- overlay information is null
      END IF; -- pa allows overrides
    ELSE -- project id is null

      l_dist_ccid := l_invoice_line_rec.default_dist_ccid;
      IF (l_invoice_line_rec.overlay_dist_code_concat is NULL AND
          l_invoice_line_rec.balancing_segment is NULL AND
          l_invoice_line_rec.account_segment is NULL AND
          l_invoice_line_rec.cost_center_segment is NULL) then
        IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                     l_dist_ccid,
                     l_chart_of_accounts_id,
                     l_open_gl_date,
                     current_calling_sequence))) THEN
          X_error_code := 'AP_INVALID_ACCOUNT';
          RETURN(FALSE);
        END IF;
      ELSE
        IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                    l_invoice_line_rec.balancing_segment,
                    l_invoice_line_rec.cost_center_segment,
                    l_invoice_line_rec.account_segment,
                    l_invoice_line_rec.overlay_dist_code_concat,
                    l_dist_ccid,
                    l_invoice_line_rec.set_of_books_id,
                    'CREATE_COMB_NO_AT',
                    l_unbuilt_flex,
                    l_reason_unbuilt_flex,
                    FND_GLOBAL.RESP_APPL_ID,
                    FND_GLOBAL.RESP_ID,
                    FND_GLOBAL.USER_ID,
                    current_calling_sequence,
                    NULL,
                    l_open_gl_date))) then --7531219
          X_error_code := 'AP_CANNOT_OVERLAY';
          RETURN(FALSE);
        END IF;
      END IF; -- overlay information is null
    END IF; -- project id is null

    IF (l_invoice_line_rec.project_id is not null) THEN

	GMS_AP_API.validate_transaction
			( x_project_id		  => l_invoice_line_rec.project_id,
			  x_task_id		  => l_invoice_line_rec.task_id,
			  x_award_id		  => l_invoice_line_rec.award_id,
			  x_expenditure_type	  => l_invoice_line_rec.expenditure_type,
			  x_expenditure_item_date => l_invoice_line_rec.expenditure_item_date,
			  x_calling_sequence	  => 'AWARD_ID',
			  x_msg_application       => l_msg_application,
			  x_msg_type              => l_msg_type,
			  x_msg_count             => l_msg_count,
			  x_msg_data              => l_msg_data ) ;

	IF (l_msg_data is not null) THEN
	    x_msg_application := l_msg_application;
	    x_msg_data := l_msg_data;
	    X_error_code := X_msg_data;  -- bug 7936518
	    return(FALSE);
	END IF;
    END IF ;

  ELSE

    -- Need to assign the value from the pass in record
    l_dist_ccid := l_invoice_line_rec.default_dist_ccid;

  END IF; -- Calling module is other than the IMPORT


  ---------------------------------------------------------------------------
  -- Step 8 - Get account type.
  ---------------------------------------------------------------------------
  debug_info := 'Get account type for ccid' || l_dist_ccid;
    BEGIN
    SELECT account_type
      INTO l_account_type
      FROM gl_code_combinations
     WHERE code_combination_id = l_dist_ccid;

  EXCEPTION
    When no_data_found THEN
       Debug_info := debug_info || ': cannot read account type information';
       X_debug_context := current_calling_sequence;
       X_debug_info := debug_info;
       RETURN(FALSE);
  END;
  -- Obtain the assets tracking flag given the account type
  IF (l_account_type = 'A' OR
      (l_account_type = 'E' AND
       l_invoice_line_rec.assets_tracking_flag = 'Y')) then
    l_assets_tracking_flag := 'Y';
  ELSE
    l_assets_tracking_flag := 'N';
  END IF;

  ----------------------------------------------------------------------------
  -- Step 9 - Set distribution class value (Permanent or Candidate)
  ----------------------------------------------------------------------------
  if (X_Generate_Permanent = 'N') then
    l_distribution_class := 'CANDIDATE';
  else
    l_distribution_class := 'PERMANENT';
  end if;


  ---------------------------------------------------------------------------
  -- ETAX: Invwkb
  -- Step 10 - Exclude the included_tax_amount from the line_amount before
  --	       creating a item distribution.
  ---------------------------------------------------------------------------
  --bug6653070

  /*l_invoice_line_rec.amount := l_invoice_line_rec.amount -
  				   NVL(l_invoice_line_rec.included_tax_amount,0);*/
  l_invoice_line_rec.base_amount := ap_utilities_pkg.ap_round_currency(
  					l_invoice_line_rec.amount * x_exchange_rate,
					l_base_currency_code);

  ----------------------------------------------------------------------------
  -- Step 11 - Generate distributions
  ----------------------------------------------------------------------------
  BEGIN

    INSERT INTO ap_invoice_distributions(
              batch_id,
              invoice_id,
              invoice_line_number,
              invoice_distribution_id,
              distribution_line_number,
              line_type_lookup_code,
              distribution_class,
              description,
              dist_match_type,
              org_id,
              dist_code_combination_id,
              accounting_date,
              period_name,
              accrual_posted_flag,
              cash_posted_flag,
              amount_to_post,
              base_amount_to_post,
              posted_amount,
              posted_base_amount,
              posted_flag,
              accounting_event_id,
              upgrade_posted_amt,
              upgrade_base_posted_amt,
              set_of_books_id,
              amount,
              base_amount,
              rounding_amt,
              quantity_variance,
              base_quantity_variance,
              match_status_flag,
              encumbered_flag,
              packet_id,
              reversal_flag,
              parent_reversal_id,
              cancellation_flag,
              income_tax_region,
              type_1099,
              stat_amount,
              charge_applicable_to_dist_id,
              prepay_amount_remaining,
              prepay_distribution_id,
              parent_invoice_id,
              corrected_invoice_dist_id,
              corrected_quantity,
              other_invoice_id,
              po_distribution_id,
              rcv_transaction_id,
              unit_price,
              matched_uom_lookup_code,
              quantity_invoiced,
              final_match_flag,
              related_id,
              assets_addition_flag,
              assets_tracking_flag,
              asset_book_type_code,
              asset_category_id,
              project_id,
              task_id,
              expenditure_type,
              expenditure_item_date,
              expenditure_organization_id,
              pa_quantity,
              pa_addition_flag,
              award_id,
              gms_burdenable_raw_cost,
              awt_flag,
              awt_group_id,
              awt_tax_rate_id,
              awt_gross_amount,
              awt_invoice_id,
              awt_origin_group_id,
              awt_invoice_payment_id,
              awt_withheld_amt,
              inventory_transfer_status,
              reference_1,
              reference_2,
              receipt_verified_flag,
              receipt_required_flag,
              receipt_missing_flag,
              justification,
              expense_group,
              start_expense_date,
              end_expense_date,
              receipt_currency_code,
              receipt_conversion_rate,
              receipt_currency_amount,
              daily_amount,
              web_parameter_id,
              adjustment_reason,
              merchant_document_number,
              merchant_name,
              merchant_reference,
              merchant_tax_reg_number,
              merchant_taxpayer_id,
              country_of_supply,
              credit_card_trx_id,
              company_prepaid_invoice_id,
              cc_reversal_flag,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              global_attribute_category,
              global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              program_application_id,
              program_id,
              program_update_date,
              request_id,
	      --ETAX: Invwkb
	      intended_use,
	      --Freight and Special Charges
	      rcv_charge_addition_flag,
	      --bug7022001
	      pay_awt_group_id)
    VALUES  (X_batch_id,                          -- batch_id
            l_invoice_line_rec.invoice_id,        -- invoice_id
            l_invoice_line_rec.line_number,       -- invoice_line_number
            ap_invoice_distributions_s.nextval,   -- invoice_distribution_id
            1,                                    -- distribution_line_number
            l_invoice_line_rec.line_type_lookup_code,  -- line_type_lookup_code
            l_distribution_class,                 -- distribution_class
            l_invoice_line_rec.description,       -- description
            'NOT_MATCHED',                        -- dist_match_type
            l_invoice_line_rec.org_id,            -- l_org_id
            l_dist_ccid,                          -- dist_code_combination_id
            l_open_gl_date,                       -- accounting_date
            l_open_period_name,                   -- period_name
            'N',                                  -- accrual_posted_flag
            'N',                                  -- cash_posted_flag
            NULL,                                 -- amount_to_post
            NULL,                                 -- base_amount_to_post
            NULL,                                 -- posted_amount
            NULL,                                 -- posted_base_amount
            'N',                                  -- posted_flag
            NULL,                                 -- accounting_event_id
            NULL,                                 -- upgrade_posted_amt
            NULL,                                 -- upgrade_base_posted_amt
            l_invoice_line_rec.set_of_books_id,   -- set_of_books_id
            l_invoice_line_rec.amount,            -- amount
            l_invoice_line_rec.base_amount,       -- base_amount
            l_invoice_line_rec.rounding_amt,      -- rounding_amt
            NULL,                                 -- quantity_variance
            NULL,                                 -- base_quantity_variance
	    --Invoice Lines: Distributions, changed match_status_flag
            --to NULL from 'N'.
            NULl,                                 -- match_status_flag
            'N',                                  -- encumbered_flag
            NULL,                                 -- packet_id
         -- decode(l_invoice_line_rec.line_type_lookup_code,
            'N',                                  -- reversal_flag
            NULL,                                 -- parent_reversal_id
            'N',                                  -- cancellation_flag
            decode(l_invoice_line_rec.type_1099,null,null,
                  l_invoice_line_rec.income_tax_region),  -- income_tax_region
            l_invoice_line_rec.type_1099,         -- type_1099
            NULL,                                 -- stat_amount
            NULL,                                 -- charge_applicable_to_dist_id
            NULL,                                 -- prepay_amount_remaining
            NULL,                                 -- prepay_distribution_id
            NULL,                                 -- parent_invoice_id
            NULL,                                 -- corrected_inv_dist_id
            NULL,                                 -- corrected_quantity
            NULL,                                 -- other_invoice_id
            NULL,                                 -- po_distribution_id
            NULL,                                 -- rcv_transaction_id
            NULL,                                 -- unit_price
            NULL,                                 -- matched_uom_lookup_code
            NULL,                                 -- quantity_invoiced
            NULL,                                 -- final_match_flag
            NULL,                                 -- related_id
            'U',                                  -- assets_addition_flag
            l_assets_tracking_flag,               -- assets_tracking_flag
            decode(l_assets_tracking_flag,'Y',
                 l_invoice_line_rec.asset_book_type_code, NULL),-- asset_book_type_code
            decode(l_assets_tracking_flag,'Y',
                    l_invoice_line_rec.asset_category_id, NULL),-- asset_category_id
            l_invoice_line_rec.project_id,                           -- project_id
            l_invoice_line_rec.task_id,                              -- task_id
            l_invoice_line_rec.expenditure_type,                     -- expenditure_type
            l_invoice_line_rec.expenditure_item_date,              -- expenditure_item_date
            l_invoice_line_rec.expenditure_organization_id,          -- expenditure_organization_id
            l_invoice_line_rec.pa_quantity,       -- pa_quantity
            decode(l_invoice_line_rec.project_id,NULL,'E', 'N'),     -- pa_addition_flag
            l_invoice_line_rec.award_id,                             -- award_id
            NULL,                                 -- gms_burdenable_raw_cost
            /*Added the following decode for bug#7695497 Start */
            decode(l_invoice_line_rec.line_type_lookup_code,
	           'AWT', decode(l_invoice_line_rec.line_source ,'MANUAL LINE ENTRY','M', NULL),
	           NULL),                                            -- awt_flag
            /*Added the above decode for bug#7695497 End */
            l_invoice_line_rec.awt_group_id,                         -- awt_group_id
            NULL,                                 -- awt_tax_rate_id
            NULL,                                 -- awt_gross_amount
            NULL,                                 -- awt_invoice_id
            NULL,                                 -- awt_origin_group_id
            NULL,                                 -- awt_invoice_payment_id
            NULL,                                 -- awt_withheld_amt
            'N',                                  -- inventory_transfer_status
	    --Bug9296445
            l_invoice_line_rec.reference_1,       --NULL,   -- reference_1
            l_invoice_line_rec.reference_2,       --NULL,   -- reference_2
            NULL,                                 -- receipt_verified_flag
            NULL,                                 -- receipt_required_flag
            NULL,                                 -- receipt_missing_flag
            NULL,                                 -- justification
            NULL,                                 -- expense_group
            NULL,                                 -- start_expense_date
            NULL,                                 -- end_expense_date
            NULL,                                 -- receipt_currency_code
            NULL,                                 -- receipt_conversion_rate
            NULL,                                 -- receipt_currency_amount
            NULL,                                 -- daily_amount
            NULL,                                 -- web_parameter_id
            NULL,                                 -- adjustment_reason
            NULL,                                 -- merchant_document_number
            NULL,                                 -- merchant_name
            NULL,                                 -- merchant_reference
            NULL,                                 -- merchant_tax_reg_number
            NULL,                                 -- merchant_taxpayer_id
            NULL,                                 -- country_of_supply
            NULL,                                 -- credit_card_trx_id
            NULL,                                 -- company_prepaid_invoice_id
            NULL,                                 -- cc_reversal_flag
            -- Bug 6837035 Start
            l_invoice_line_rec.attribute_category,-- attribute_category
            l_invoice_line_rec.attribute1,        -- attribute1
            l_invoice_line_rec.attribute2,        -- attribute2
            l_invoice_line_rec.attribute3,        -- attribute3
            l_invoice_line_rec.attribute4,        -- attribute4
            l_invoice_line_rec.attribute5,        -- attribute5
            l_invoice_line_rec.attribute6,        -- attribute6
            l_invoice_line_rec.attribute7,        -- attribute7
            l_invoice_line_rec.attribute8,        -- attribute8
            l_invoice_line_rec.attribute9,        -- attribute9
            l_invoice_line_rec.attribute10,        -- attribute10
            l_invoice_line_rec.attribute11,        -- attribute11
            l_invoice_line_rec.attribute12,        -- attribute12
            l_invoice_line_rec.attribute13,        -- attribute13
            l_invoice_line_rec.attribute14,        -- attribute14
            l_invoice_line_rec.attribute15,        -- attribute15
            -- Bug 6837035 End
            /* bug 8788072 changed from Null to decode */
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute_category, NULL), -- global_attribute_category
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute1, NULL), -- global_attribute1
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute2, NULL), -- global_attribute2
	    --bugfix:4674194
	    Decode(AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_OPTION,
	           'Y',l_invoice_line_rec.ship_to_location_id,
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute3, NULL)), --global_attribute3
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute4, NULL), -- global_attribute4
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute5, NULL), -- global_attribute5
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute6, NULL), -- global_attribute6
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute7, NULL), -- global_attribute7
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute8, NULL), -- global_attribute8
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute9, NULL), -- global_attribute9
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute10, NULL), -- global_attribute10
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute11, NULL), -- global_attribute11
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute12, NULL), -- global_attribute12
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute13, NULL), -- global_attribute13
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute14, NULL), -- global_attribute14
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute15, NULL), -- global_attribute15
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute16, NULL), -- global_attribute16
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute17, NULL), -- global_attribute17
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute18, NULL), -- global_attribute18
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute19, NULL), -- global_attribute19
            DECODE(l_copy_line_gdff_flag, 'Y', l_invoice_line_rec.global_attribute20, NULL), -- global_attribute20
            /* bug 8788072 */
            FND_GLOBAL.user_id,                   -- created_by
            SYSDATE,                              -- creation_date
            0,                                    -- last_updated_by
            SYSDATE,                              -- last_update_date
            FND_GLOBAL.login_id,                  -- last_update_login
            NULL,                                 -- program_application_id
            NULL,                                 -- program_id
            NULL,                                 -- program_update_date
            NULL,                                 -- request_id
	    l_invoice_line_rec.primary_intended_use, -- intended_use
	    'N',				  -- rcv_charge_addition_flag
            l_invoice_line_rec.pay_awt_group_id   --pay_awt_group_id  --bug7022001
	    ) returning invoice_distribution_id into l_invoice_distribution_id;

		   --bug 9169915 bug9737142
		   SELECT JG_ZZ_SHARED_PKG.GET_COUNTRY(l_invoice_line_rec.org_id, null)
			 INTO l_country_code
			 FROM DUAL;

   		   IF l_country_code IN ('AR','CO') THEN
   	             JL_ZZ_AP_AWT_DEFAULT_PKG.SUPP_WH_DEF (l_invoice_line_rec.invoice_id,
							l_invoice_line_rec.line_number,
							l_invoice_distribution_id,
							NULL);
                   END IF;
	           --bug 9169915

	    GMS_AP_API.CREATE_AWARD_DISTRIBUTIONS
			( p_invoice_id		     => l_invoice_line_rec.invoice_id,
			  p_distribution_line_number => 1,
			  p_invoice_distribution_id  => l_invoice_distribution_id,
			  p_award_id		     => l_invoice_line_rec.award_id,
			  p_mode		     => 'AP',
			  p_dist_set_id		     => NULL,
			  p_dist_set_line_number     => NULL );


     EXCEPTION
      WHEN OTHERS THEN
        X_debug_info := debug_info || ': Error encountered during dist insert';
        X_debug_context := current_calling_sequence;
	--Bugfix: 3859755, added the below stmt.
	X_Error_Code := sqlerrm;
        return (FALSE);
    END;

    ----------------------------------------------------------------------------
  -- Step 10 - Update generate distributions flag in invoice line if generating
  -- permanent distributions.
  ----------------------------------------------------------------------------
  debug_info := 'Setting generate distributions flag to Done';
  IF (l_distribution_class = 'PERMANENT') then
    BEGIN
      UPDATE AP_INVOICE_LINES
         SET GENERATE_DISTS = 'D'
       WHERE invoice_id = X_invoice_id
         AND line_number = l_invoice_line_rec.line_number;
    EXCEPTION
      WHEN OTHERS THEN
        X_debug_info := debug_info || ': Error encountered';
        X_debug_context := current_calling_sequence;
        return (FALSE);
    END;
  END IF;

  RETURN(TRUE);

  EXCEPTION
    WHEN OTHERS THEN
    X_debug_info := 'Error encountered';
    X_debug_context := current_calling_sequence;
    RETURN (FALSE);
  END insert_single_dist_from_line;

--Bug 8346277 Start
  -----------------------------------------------------------------------
  -- FUNCTION insert_AWT_dist_from_line inserts a record into
  -- ap_invoice_distributions given a line number number and/or line record.
  -- It returns FALSE if an error is encountered.
  -----------------------------------------------------------------------

FUNCTION   Insert_AWT_Dist_From_Line(
           X_batch_id            IN         AP_INVOICES.BATCH_ID%TYPE,
           X_invoice_id          IN         NUMBER,
           X_invoice_date        IN         AP_INVOICES.INVOICE_DATE%TYPE,
           X_vendor_id           IN         AP_INVOICES.VENDOR_ID%TYPE,
           X_invoice_currency    IN         AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
           X_exchange_rate       IN         AP_INVOICES.EXCHANGE_RATE%TYPE,
           X_exchange_rate_type  IN         AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE,
           X_exchange_date       IN         AP_INVOICES.EXCHANGE_DATE%TYPE,
           X_line_number         IN         NUMBER,
           X_invoice_lines_rec   IN         AP_INVOICES_PKG.r_invoice_line_rec,
           X_line_source         IN         VARCHAR2,
           X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
           X_Validate_Info       IN         BOOLEAN DEFAULT TRUE,
           X_Error_Code          OUT NOCOPY VARCHAR2,
           X_Debug_Info          OUT NOCOPY VARCHAR2,
           X_Debug_Context       OUT NOCOPY VARCHAR2,
           X_Msg_Application     OUT NOCOPY VARCHAR2,
           X_Msg_Data            OUT NOCOPY VARCHAR2,
           X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN
   IS

CURSOR line_rec IS
  SELECT INVOICE_ID
       , LINE_NUMBER
       , LINE_TYPE_LOOKUP_CODE
       , REQUESTER_ID
       , DESCRIPTION
       , LINE_SOURCE
       , ORG_ID
       , LINE_GROUP_NUMBER
       , INVENTORY_ITEM_ID
       , ITEM_DESCRIPTION
       , SERIAL_NUMBER
       , MANUFACTURER
       , MODEL_NUMBER
       , WARRANTY_NUMBER
       , GENERATE_DISTS
       , MATCH_TYPE
       , DISTRIBUTION_SET_ID
       , ACCOUNT_SEGMENT
       , BALANCING_SEGMENT
       , COST_CENTER_SEGMENT
       , OVERLAY_DIST_CODE_CONCAT
       , DEFAULT_DIST_CCID
       , PRORATE_ACROSS_ALL_ITEMS
       , ACCOUNTING_DATE
       , PERIOD_NAME
       , DEFERRED_ACCTG_FLAG
       , DEF_ACCTG_START_DATE
       , DEF_ACCTG_END_DATE
       , DEF_ACCTG_NUMBER_OF_PERIODS
       , DEF_ACCTG_PERIOD_TYPE
       , SET_OF_BOOKS_ID
       , AMOUNT
       , BASE_AMOUNT
       , ROUNDING_AMT
       , QUANTITY_INVOICED
       , UNIT_MEAS_LOOKUP_CODE
       , UNIT_PRICE
       , WFAPPROVAL_STATUS
       , DISCARDED_FLAG
       , ORIGINAL_AMOUNT
       , ORIGINAL_BASE_AMOUNT
       , ORIGINAL_ROUNDING_AMT
       , CANCELLED_FLAG
       , INCOME_TAX_REGION
       , TYPE_1099
       , STAT_AMOUNT
       , PREPAY_INVOICE_ID
       , PREPAY_LINE_NUMBER
       , INVOICE_INCLUDES_PREPAY_FLAG
       , CORRECTED_INV_ID
       , CORRECTED_LINE_NUMBER
       , PO_HEADER_ID
       , PO_LINE_ID
       , PO_RELEASE_ID
       , PO_LINE_LOCATION_ID
       , PO_DISTRIBUTION_ID
       , RCV_TRANSACTION_ID
       , FINAL_MATCH_FLAG
       , ASSETS_TRACKING_FLAG
       , ASSET_BOOK_TYPE_CODE
       , ASSET_CATEGORY_ID
       , PROJECT_ID
       , TASK_ID
       , EXPENDITURE_TYPE
       , EXPENDITURE_ITEM_DATE
       , EXPENDITURE_ORGANIZATION_ID
       , PA_QUANTITY
       , PA_CC_AR_INVOICE_ID
       , PA_CC_AR_INVOICE_LINE_NUM
       , PA_CC_PROCESSED_CODE
       , AWARD_ID
       , AWT_GROUP_ID
       , REFERENCE_1
       , REFERENCE_2
       , RECEIPT_VERIFIED_FLAG
       , RECEIPT_REQUIRED_FLAG
       , RECEIPT_MISSING_FLAG
       , JUSTIFICATION
       , EXPENSE_GROUP
       , START_EXPENSE_DATE
       , END_EXPENSE_DATE
       , RECEIPT_CURRENCY_CODE
       , RECEIPT_CONVERSION_RATE
       , RECEIPT_CURRENCY_AMOUNT
       , DAILY_AMOUNT
       , WEB_PARAMETER_ID
       , ADJUSTMENT_REASON
       , MERCHANT_DOCUMENT_NUMBER
       , MERCHANT_NAME
       , MERCHANT_REFERENCE
       , MERCHANT_TAX_REG_NUMBER
       , MERCHANT_TAXPAYER_ID
       , COUNTRY_OF_SUPPLY
       , CREDIT_CARD_TRX_ID
       , COMPANY_PREPAID_INVOICE_ID
       , CC_REVERSAL_FLAG
       , CREATION_DATE
       , CREATED_BY
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE
       , LAST_UPDATE_LOGIN
       , PROGRAM_APPLICATION_ID
       , PROGRAM_ID
       , PROGRAM_UPDATE_DATE
       , REQUEST_ID
       , ATTRIBUTE_CATEGORY
       , ATTRIBUTE1
       , ATTRIBUTE2
       , ATTRIBUTE3
       , ATTRIBUTE4
       , ATTRIBUTE5
       , ATTRIBUTE6
       , ATTRIBUTE7
       , ATTRIBUTE8
       , ATTRIBUTE9
       , ATTRIBUTE10
       , ATTRIBUTE11
       , ATTRIBUTE12
       , ATTRIBUTE13
       , ATTRIBUTE14
       , ATTRIBUTE15
       , GLOBAL_ATTRIBUTE_CATEGORY
       , GLOBAL_ATTRIBUTE1
       , GLOBAL_ATTRIBUTE2
       , GLOBAL_ATTRIBUTE3
       , GLOBAL_ATTRIBUTE4
       , GLOBAL_ATTRIBUTE5
       , GLOBAL_ATTRIBUTE6
       , GLOBAL_ATTRIBUTE7
       , GLOBAL_ATTRIBUTE8
       , GLOBAL_ATTRIBUTE9
       , GLOBAL_ATTRIBUTE10
       , GLOBAL_ATTRIBUTE11
       , GLOBAL_ATTRIBUTE12
       , GLOBAL_ATTRIBUTE13
       , GLOBAL_ATTRIBUTE14
       , GLOBAL_ATTRIBUTE15
       , GLOBAL_ATTRIBUTE16
       , GLOBAL_ATTRIBUTE17
       , GLOBAL_ATTRIBUTE18
       , GLOBAL_ATTRIBUTE19
       , GLOBAL_ATTRIBUTE20
       , INCLUDED_TAX_AMOUNT
       , PRIMARY_INTENDED_USE
       , APPLICATION_ID
       , PRODUCT_TABLE
       , REFERENCE_KEY1
       , REFERENCE_KEY2
       , REFERENCE_KEY3
       , REFERENCE_KEY4
       , REFERENCE_KEY5
       , SHIP_TO_LOCATION_ID
       , PAY_AWT_GROUP_ID
    FROM ap_invoice_lines_all
   WHERE invoice_id  = X_invoice_id
     AND line_number = X_line_number;


  l_invoice_line_rec           AP_INVOICES_PKG.r_invoice_line_rec;

  l_distribution_class         AP_INVOICE_DISTRIBUTIONS.DISTRIBUTION_CLASS%TYPE;
  l_dist_ccid                  AP_INVOICE_DISTRIBUTIONS.DIST_CODE_COMBINATION_ID%TYPE;
  l_base_currency_code         AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
  l_chart_of_accounts_id       GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
  l_account_type               GL_CODE_COMBINATIONS.ACCOUNT_TYPE%TYPE;
  l_assets_tracking_flag       AP_INVOICE_DISTRIBUTIONS.ASSETS_TRACKING_FLAG%TYPE;
  l_employee_id                AP_SUPPLIERS.EMPLOYEE_ID%TYPE;
  l_accounting_date            AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE;
  l_open_gl_date               AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE;
  l_open_period_name           AP_INVOICE_LINES.PERIOD_NAME%TYPE;
  user_id                      NUMBER;
  l_msg_application            VARCHAR2(25);
  l_msg_type                   VARCHAR2(25);
  l_msg_token1                 VARCHAR2(30);
  l_msg_token2                 VARCHAR2(30);
  l_msg_token3                 VARCHAR2(30);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(30);
  l_billable_flag              VARCHAR2(25);
  l_pa_allows_overrides        VARCHAR2(1) := 'N';
  l_error_found                VARCHAR2(1) := 'N';
  l_existing_distributions     NUMBER := 0;
  l_unbuilt_flex               VARCHAR2(240):='';
  l_reason_unbuilt_flex        VARCHAR2(2000):='';
  current_calling_sequence     VARCHAR2(2000);
  debug_info                   VARCHAR2(2000); --Bug 8725625-Increased width
  debug_context                VARCHAR2(2000);
  l_dist_code_concat           VARCHAR2(2000);
  l_invoice_distribution_id    ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_invoice_type_lookup_code   ap_invoices_all.invoice_type_lookup_code%TYPE;
  l_sys_link_function          VARCHAR2(2);
  l_web_parameter_id           number;
  l_employee_ccid              number;
  l_message_text	       fnd_new_messages.message_text%type;
  l_copy_line_dff_flag         VARCHAR2(1);
  l_Inc_AWT_For_Tax_Flag       Number :=1;
  l_dist_total number;

/* bug 10201001 begins */
--  l_accounting_event_id        ap_invoice_distributions.accounting_event_id%TYPE := -1;  --bug 9216708
  l_no_dists_exists               NUMBER := 0;   --bug 9216708

  cursor events_cur(p_invoice_id NUMBER,p_invoice_line_num NUMBER) is
  select distinct accounting_event_id
    from ap_invoice_distributions_all
   where invoice_id = p_invoice_id
     and invoice_line_number = p_invoice_line_num
     and posted_flag <> 'Y';

TYPE EventTab IS TABLE OF ap_invoice_distributions.accounting_event_id%TYPE INDEX BY BINARY_INTEGER;
l_accounting_event_id_list   EventTab;

/* bug 10201001 ends */
  BEGIN
  --------------------------------------------------------------------------
  -- Step 1 - Update the calling sequence
  --------------------------------------------------------------------------
  current_calling_sequence :=
      'AP_INVOICE_DISTRIBUTIONS_PKG.insert_single_dist_from_line <-'||
      X_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 2 - If calling module provided X_invoice_id / X_line_number, then
  -- we assume the calling module is not passing a line record.  Read the line
  -- record from the transaction tables.
  -------------------------------------------------------------------------
  debug_info := 'Verify line record';
  IF (X_invoice_id IS NOT NULL AND X_line_number IS NOT NULL) THEN
    BEGIN
      OPEN line_rec;
      FETCH line_rec INTO l_invoice_line_rec;
      IF (line_rec%NOTFOUND) THEN
        CLOSE line_rec;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE line_Rec;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug_info := debug_info ||': No valid line record was found.';
        X_debug_context := current_calling_sequence;
        X_debug_info := debug_info;
        return(FALSE);
    END;
  ELSE
    l_invoice_line_rec := X_invoice_lines_rec;
    IF (X_invoice_lines_rec.invoice_id IS NULL AND
        X_invoice_lines_rec.line_number is NULL ) THEN
      X_debug_info := debug_info || ': line not provided';
      X_debug_context := current_calling_sequence;
      RETURN (FALSE);
    END IF;
  END IF;




  SELECT DECODE(awt_include_tax_amt,'Y',1,'N',0,1)
         INTO l_Inc_AWT_For_Tax_Flag
    FROM ap_system_parameters_all
   WHERE org_id=l_invoice_line_rec.org_id
     AND rownum=1;
  ----------------------------------------------------------------------------
  -- Step 3 - Validate line does not contain other distributions
  ----------------------------------------------------------------------------
  IF (X_Validate_Info) then
    debug_info := 'Verify line does not contain distributions';
    BEGIN
      SELECT count(*)
      INTO l_existing_distributions
      FROM ap_invoice_distributions
     WHERE invoice_id = l_invoice_line_rec.invoice_id
       AND invoice_line_number = l_invoice_line_rec.line_number
       AND nvl(posted_flag,'N') <> 'N';

      IF (l_existing_distributions <> 0) then
        X_debug_info := debug_info || ': line already has posted distributions';
        X_debug_context := current_calling_sequence;
        RETURN(FALSE);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END IF; -- If calling module requested validation

  -- copied onto distributions for imported lines.
  l_copy_line_dff_flag := NVL(fnd_profile.value('AP_COPY_INV_LINE_DFF'),'N');
  IF NVL(l_invoice_line_rec.line_source, 'DUMMY') <> 'IMPORTED' OR l_copy_line_dff_flag <> 'Y' THEN
    l_invoice_line_rec.ATTRIBUTE_CATEGORY := NULL;
    l_invoice_line_rec.ATTRIBUTE1  := NULL;
    l_invoice_line_rec.ATTRIBUTE2  := NULL;
    l_invoice_line_rec.ATTRIBUTE3  := NULL;
    l_invoice_line_rec.ATTRIBUTE4  := NULL;
    l_invoice_line_rec.ATTRIBUTE5  := NULL;
    l_invoice_line_rec.ATTRIBUTE6  := NULL;
    l_invoice_line_rec.ATTRIBUTE7  := NULL;
    l_invoice_line_rec.ATTRIBUTE8  := NULL;
    l_invoice_line_rec.ATTRIBUTE9  := NULL;
    l_invoice_line_rec.ATTRIBUTE10 := NULL;
    l_invoice_line_rec.ATTRIBUTE11 := NULL;
    l_invoice_line_rec.ATTRIBUTE12 := NULL;
    l_invoice_line_rec.ATTRIBUTE13 := NULL;
    l_invoice_line_rec.ATTRIBUTE14 := NULL;
    l_invoice_line_rec.ATTRIBUTE15 := NULL;
  END IF;

  ----------------------------------------------------------------------------
  -- Step 4 - Get GL Date and Period name.  Only if not called from the
  -- Open interface since Validation of the Import already verifies gl date
  -- nd period.
  ----------------------------------------------------------------------------
  IF (nvl(X_line_source, 'OTHERS') <> 'IMPORT') then
    debug_info := 'Get gl date from open period if line gl date is in' ||
                  'a closed one';
    BEGIN
      l_open_period_name := NULL;

      l_open_period_name :=
        AP_UTILITIES_PKG.GET_CURRENT_GL_DATE(
                l_invoice_line_rec.accounting_date,
	        l_invoice_line_rec.org_id);

      IF (l_open_period_name is NULL) then
        AP_UTILITIES_PKG.GET_OPEN_GL_DATE(l_invoice_line_rec.accounting_date,
                                          l_open_period_name,
                                          l_open_gl_date);
      --Invoice Lines: Distributions
      --For the case when the accounting_date on the line fell in an open
      --period, we were trying to insert NULL into a NOT NULL column
      --accounting_date, since the variable l_open_gl_date was not being
      --populated properly.
      ELSE
        l_open_gl_date := l_invoice_line_rec.accounting_date;
      END IF;
      IF (l_open_period_name is NULL) then
        X_error_code := 'AP_NO_OPEN_PERIOD';
        RETURN(FALSE);
      END IF;
    END;
  ELSE
    l_open_period_name := l_invoice_line_rec.period_name;
    l_open_gl_date := l_invoice_line_rec.accounting_date;
  END IF;

  --------------------------------------------------------------
  -- Step 5 - Get system level information necessary for
  -- validation and generation of distributions
  --------------------------------------------------------------
  debug_info := 'Get system information';
  BEGIN
    SELECT gsob.chart_of_accounts_id, ap.base_currency_code
      INTO l_chart_of_accounts_id, l_base_currency_code
      FROM ap_system_parameters ap, gl_sets_of_books gsob
     WHERE ap.set_of_books_id = gsob.set_of_books_id
       AND ap.set_of_books_id = l_invoice_line_rec.set_of_books_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Debug_info := debug_info || ': No GL information was found';
      X_debug_context := current_calling_sequence;
      X_debug_info := debug_info;
    RETURN(FALSE);
  END;



  ----------------------------------------------------------------------------
  -- Step 7 - Obtain final account and account related information.
  -- But only if calling module is not the Import since through the import
  -- The account should already be built.
  ----------------------------------------------------------------------------
  debug_info := 'Obtain account to be used in distribution';
    -- Need to assign the value from the pass in record
    l_dist_ccid := l_invoice_line_rec.default_dist_ccid;

  ---------------------------------------------------------------------------
  -- Step 8 - Get account type.
  ---------------------------------------------------------------------------
  debug_info := 'Get account type for ccid ' || l_dist_ccid;
    BEGIN
    SELECT account_type
      INTO l_account_type
      FROM gl_code_combinations
     WHERE code_combination_id = l_dist_ccid;

  EXCEPTION
    WHEN no_data_found THEN
       Debug_info := debug_info || ': cannot read account type information';
       X_debug_context := current_calling_sequence;
       X_debug_info := debug_info;
       RETURN(FALSE);
  END;

debug_info := 'Obtain the assets tracking flag given the account type';
  -- Obtain the assets tracking flag given the account type
  IF (l_account_type = 'A' OR
      (l_account_type = 'E' AND
       l_invoice_line_rec.assets_tracking_flag = 'Y')) then
    l_assets_tracking_flag := 'Y';
  ELSE
    l_assets_tracking_flag := 'N';
  END IF;
debug_info := 'Before Step 9 - Set distribution class value (Permanent or Candidate)';
  ----------------------------------------------------------------------------
  -- Step 9 - Set distribution class value (Permanent or Candidate)
  ----------------------------------------------------------------------------
  if (X_Generate_Permanent = 'N') then
    l_distribution_class := 'CANDIDATE';
  else
    l_distribution_class := 'PERMANENT';
  end if;

debug_info := 'After Step 9 - Set distribution class value (Permanent or Candidate)'||l_distribution_class;
  ---------------------------------------------------------------------------
  -- ETAX: Invwkb
  -- Step 10 - Exclude the included_tax_amount from the line_amount before
  --	       creating a item distribution.
  ---------------------------------------------------------------------------

        debug_info := 'Before Calc Inv line base amount'||l_invoice_line_rec.amount ||'Xrate '|| x_exchange_rate ||'l_base_currency_code '||l_base_currency_code;

        l_invoice_line_rec.base_amount := ap_utilities_pkg.ap_round_currency(
  					l_invoice_line_rec.amount * x_exchange_rate,
					l_base_currency_code);

        debug_info := 'After Calc Inv line base amount'||l_invoice_line_rec.amount ||'Xrate ' || x_exchange_rate ||'l_base_currency_code '||l_base_currency_code;

  ----------------------------------------------------------------------------
  -- Step 11 - Generate distributions
  ----------------------------------------------------------------------------
  BEGIN
	l_dist_total:=0;

	debug_info  := 'Dist Total - '  ||l_dist_total ;


          SELECT SUM(AMOUNT)
            INTO l_dist_total
            FROM ap_invoice_distributions_all aid
           WHERE aid.invoice_id             = l_invoice_line_rec.invoice_id
             AND line_type_lookup_code NOT IN('AWT' , 'PREPAY','ERV','TERV')
             AND(l_Inc_AWT_For_Tax_Flag = 1
                 OR(aid.line_type_lookup_code NOT IN('REC_TAX' , 'NONREC_TAX' , 'TIPV' , 'TRV'))
                ) ;

	IF l_dist_total <> 0 THEN

/* bug 10201001 begins */
/*	  commented the following code
          -- bug 9216708 start
	  select count(*)
            into l_dists_exists
	    from ap_invoice_distributions_all
	   where invoice_id = l_invoice_line_rec.invoice_id
	     and accounting_event_id is NOT NULL
	     and line_type_lookup_code = 'AWT'
	     and awt_flag = 'M'
	     and nvl(posted_flag,'N') <> 'Y';

	IF l_dists_exists > 0 THEN
  	  SELECT nvl(max(aid.accounting_event_id),-1)
	    INTO l_accounting_event_id
	    FROM ap_invoice_distributions_all aid
           WHERE aid.invoice_id = l_invoice_line_rec.invoice_id
	     AND aid.line_type_lookup_code = 'AWT'
	     AND aid.awt_flag = 'M'
             AND NVL(posted_flag , 'N') <> 'Y';
	END IF;
*/

         OPEN events_cur (l_invoice_line_rec.invoice_id,l_invoice_line_rec.line_number);
         FETCH events_cur BULK COLLECT INTO l_accounting_event_id_list;
	 CLOSE events_cur;

/* bug 10201001 end */
          DELETE FROM ap_invoice_distributions_all aid
           WHERE invoice_id              = l_invoice_line_rec.invoice_id
             AND invoice_line_number     = l_invoice_line_rec.line_number
             AND NVL(posted_flag , 'N') <> 'Y';

/* bug 10201001 begins */
          FOR i in 1..l_accounting_event_id_list.count LOOP

	    SELECT count(*)
	      INTO l_no_dists_exists
	      FROM xla_events xe
	     WHERE xe.event_id = l_accounting_event_id_list(i)
	       AND xe.event_status_code <> 'P'
	       AND xe.application_id = 200
	       AND NOT EXISTS (SELECT 'No self assessed tax rows exists for this event'
                                 FROM ap_self_assessed_tax_dist_all asatd
                                WHERE asatd.invoice_id = l_invoice_line_rec.invoice_id
				  AND asatd.accounting_event_id = xe.event_id)
	       AND NOT EXISTS (SELECT 'No Invoice rows exist for this event'
	                         FROM ap_invoice_distributions_all aid
                                WHERE aid.invoice_id = l_invoice_line_rec.invoice_id
				  AND aid.accounting_event_id = xe.event_id)
	       AND NOT EXISTS (SELECT 'No payment rows exist for this event'
	                         FROM ap_invoice_payments_all aip,
				      ap_payment_history_all aph
				WHERE aip.invoice_id = l_invoice_line_rec.invoice_id
				  AND aip.check_id = aph.check_id
				  AND aph.accounting_event_id = xe.event_id)
	       AND NOT EXISTS (SELECT 'No prepayment rows exist for this event'
	                         FROM ap_prepay_history_all aprh
				WHERE aprh.invoice_id = l_invoice_line_rec.invoice_id
				  AND aprh.accounting_event_id = xe.event_id);

            IF (l_no_dists_exists <> 0) THEN
               AP_ACCOUNTING_EVENTS_PKG.delete_invoice_event(l_accounting_event_id_list(i),
	                                                  l_invoice_line_rec.invoice_id,
                                                          current_calling_sequence);
            END IF;
	  END LOOP;
 /* bug 10201001 end */
        debug_info := ' Before Insert AwT Distributions ';

          INSERT INTO ap_invoice_distributions_all
               ( batch_id
               , invoice_id
               , invoice_line_number
               , invoice_distribution_id
               , distribution_line_number
               , line_type_lookup_code
               , distribution_class
               , description
               , dist_match_type
               , org_id
               , dist_code_combination_id
               , accounting_date
               , period_name
               , accrual_posted_flag
               , cash_posted_flag
               , amount_to_post
               , base_amount_to_post
               , posted_amount
               , posted_base_amount
               , posted_flag
               , accounting_event_id
               , upgrade_posted_amt
               , upgrade_base_posted_amt
               , set_of_books_id
               , amount
               , base_amount
               , rounding_amt
               , quantity_variance
               , base_quantity_variance
               , match_status_flag
               , encumbered_flag
               , packet_id
               , reversal_flag
               , parent_reversal_id
               , cancellation_flag
               , income_tax_region
               , type_1099
               , stat_amount
               , charge_applicable_to_dist_id
               , prepay_amount_remaining
               , prepay_distribution_id
               , parent_invoice_id
               , corrected_invoice_dist_id
               , corrected_quantity
               , other_invoice_id
               , po_distribution_id
               , rcv_transaction_id
               , unit_price
               , matched_uom_lookup_code
               , quantity_invoiced
               , final_match_flag
               , related_id
               , assets_addition_flag
               , assets_tracking_flag
               , asset_book_type_code
               , asset_category_id
               , project_id
               , task_id
               , expenditure_type
               , expenditure_item_date
               , expenditure_organization_id
               , pa_quantity
               , pa_addition_flag
               , award_id
               , gms_burdenable_raw_cost
               , awt_flag
               , awt_group_id
               , awt_tax_rate_id
               , awt_gross_amount
               , awt_invoice_id
               , awt_origin_group_id
               , awt_invoice_payment_id
               , awt_withheld_amt
               , inventory_transfer_status
               , reference_1
               , reference_2
               , receipt_verified_flag
               , receipt_required_flag
               , receipt_missing_flag
               , justification
               , expense_group
               , start_expense_date
               , end_expense_date
               , receipt_currency_code
               , receipt_conversion_rate
               , receipt_currency_amount
               , daily_amount
               , web_parameter_id
               , adjustment_reason
               , merchant_document_number
               , merchant_name
               , merchant_reference
               , merchant_tax_reg_number
               , merchant_taxpayer_id
               , country_of_supply
               , credit_card_trx_id
               , company_prepaid_invoice_id
               , cc_reversal_flag
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , global_attribute_category
               , global_attribute1
               , global_attribute2
               , global_attribute3
               , global_attribute4
               , global_attribute5
               , global_attribute6
               , global_attribute7
               , global_attribute8
               , global_attribute9
               , global_attribute10
               , global_attribute11
               , global_attribute12
               , global_attribute13
               , global_attribute14
               , global_attribute15
               , global_attribute16
               , global_attribute17
               , global_attribute18
               , global_attribute19
               , global_attribute20
               , created_by
               , creation_date
               , last_updated_by
               , last_update_date
               , last_update_login
               , program_application_id
               , program_id
               , program_update_date
               , request_id
               , intended_use
               , rcv_charge_addition_flag
               , pay_awt_group_id
               , awt_related_id
               )
          SELECT X_batch_id batch_id
               , l_invoice_line_rec.invoice_id invoice_id
               , l_invoice_line_rec.line_number invoice_line_number
               , ap_invoice_distributions_s.nextval invoice_distribution_id
               , rownum distribution_line_number
               , 'AWT' line_type_lookup_code
               , l_distribution_class distribution_class
               , l_invoice_line_rec.description description
               , 'NOT_MATCHED' dist_match_type
               , l_invoice_line_rec.org_id l_org_id
               , l_dist_ccid dist_code_combination_id
               , l_open_gl_date accounting_date
               , l_open_period_name period_name
               , 'N' accrual_posted_flag
               , 'N' cash_posted_flag
               , NULL amount_to_post
               , NULL base_amount_to_post
               , NULL posted_amount
               , NULL posted_base_amount
               , 'N' posted_flag
	       /* bug 10201001
               , DECODE(l_accounting_event_id,-1,NULL,
			            l_accounting_event_id) accounting_event_id  bug 9216708 */
               , NULL accounting_event_id
               , NULL upgrade_posted_amt
               , NULL upgrade_base_posted_amt
               , l_invoice_line_rec.set_of_books_id set_of_books_id
               , ap_utilities_pkg.ap_round_currency
                             (l_invoice_line_rec.amount * aid.amount / l_dist_total
                             , X_invoice_currency) amount
               , DECODE(X_exchange_rate_type
                        , NULL , NULL
                        , ap_utilities_pkg.ap_round_currency(
                                       (l_invoice_line_rec.amount * aid.amount / l_dist_total) * X_exchange_rate
                                       , X_invoice_currency)) base_amount
               , 0 rounding_amt
               , NULL quantity_variance
               , NULL base_quantity_variance
               , NULL match_status_flag
               , 'N' encumbered_flag
               , NULL packet_id
               , 'N' reversal_flag
               , NULL parent_reversal_id
               , 'N' cancellation_flag
               , DECODE(l_invoice_line_rec.type_1099
                       , NULL , NULL
                       , l_invoice_line_rec.income_tax_region) income_tax_region
               , l_invoice_line_rec.type_1099 type_1099
               , NULL stat_amount
               , NULL charge_applicable_to_dist_id
               , NULL prepay_amount_remaining
               , NULL prepay_distribution_id
               , NULL parent_invoice_id
               , NULL corrected_inv_dist_id
               , NULL corrected_quantity
               , NULL other_invoice_id
               , NULL po_distribution_id
               , NULL rcv_transaction_id
               , NULL unit_price
               , NULL matched_uom_lookup_code
               , NULL quantity_invoiced
               , NULL final_match_flag
               , NULL related_id
               , 'U' assets_addition_flag
               , l_assets_tracking_flag assets_tracking_flag
               , DECODE(l_assets_tracking_flag
                       , 'Y' , l_invoice_line_rec.asset_book_type_code
                       , NULL) asset_book_type_code
               , DECODE(l_assets_tracking_flag
                       , 'Y' , l_invoice_line_rec.asset_category_id
                       , NULL) asset_category_id
               , l_invoice_line_rec.project_id project_id
               , l_invoice_line_rec.task_id task_id
               , l_invoice_line_rec.expenditure_type expenditure_type
               , l_invoice_line_rec.expenditure_item_date expenditure_item_date
               , l_invoice_line_rec.expenditure_organization_id expenditure_organization_id
               , l_invoice_line_rec.pa_quantity pa_quantity
               , DECODE(l_invoice_line_rec.project_id , NULL , 'E' , 'N') pa_addition_flag
               , l_invoice_line_rec.award_id award_id
               , NULL gms_burdenable_raw_cost
               , 'M' awt_flag
               , l_invoice_line_rec.awt_group_id awt_group_id
               , NULL awt_tax_rate_id
               , NULL awt_gross_amount
               , NULL awt_invoice_id
               , NULL awt_origin_group_id
               , NULL awt_invoice_payment_id
               , NULL awt_withheld_amt
               , 'N' inventory_transfer_status
               , l_invoice_line_rec.reference_1  reference_1 --NULL Bug9296445
               , l_invoice_line_rec.reference_2  reference_2 --NULL Bug9296445,
               , NULL receipt_verified_flag
               , NULL receipt_required_flag
               , NULL receipt_missing_flag
               , NULL justification
               , NULL expense_group
               , NULL start_expense_date
               , NULL end_expense_date
               , NULL receipt_currency_code
               , NULL receipt_conversion_rate
               , NULL receipt_currency_amount
               , NULL daily_amount
               , NULL web_parameter_id
               , NULL adjustment_reason
               , NULL merchant_document_number
               , NULL merchant_name
               , NULL merchant_reference
               , NULL merchant_tax_reg_number
               , NULL merchant_taxpayer_id
               , NULL country_of_supply
               , NULL credit_card_trx_id
               , NULL company_prepaid_invoice_id
               , NULL cc_reversal_flag
               , l_invoice_line_rec.attribute_category attribute_category
               , l_invoice_line_rec.attribute1 attribute1
               , l_invoice_line_rec.attribute2 attribute2
               , l_invoice_line_rec.attribute3 attribute3
               , l_invoice_line_rec.attribute4 attribute4
               , l_invoice_line_rec.attribute5 attribute5
               , l_invoice_line_rec.attribute6 attribute6
               , l_invoice_line_rec.attribute7 attribute7
               , l_invoice_line_rec.attribute8 attribute8
               , l_invoice_line_rec.attribute9 attribute9
               , l_invoice_line_rec.attribute10 attribute10
               , l_invoice_line_rec.attribute11 attribute11
               , l_invoice_line_rec.attribute12 attribute12
               , l_invoice_line_rec.attribute13 attribute13
               , l_invoice_line_rec.attribute14 attribute14
               , l_invoice_line_rec.attribute15 attribute15
               , NULL global_attribute_category
               , NULL global_attribute1
               , NULL global_attribute2
               , DECODE(AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_OPTION
                       , 'Y' , l_invoice_line_rec.ship_to_location_id
                       , '') global_attribute3
               , NULL global_attribute4
               , NULL global_attribute5
               , NULL global_attribute6
               , NULL global_attribute7
               , NULL global_attribute8
               , NULL global_attribute9
               , NULL global_attribute10
               , NULL global_attribute11
               , NULL global_attribute12
               , NULL global_attribute13
               , NULL global_attribute14
               , NULL global_attribute15
               , NULL global_attribute16
               , NULL global_attribute17
               , NULL global_attribute18
               , NULL global_attribute19
               , NULL global_attribute20
               , FND_GLOBAL.user_id created_by
               , SYSDATE creation_date
               , 0 last_updated_by
               , SYSDATE last_update_date
               , FND_GLOBAL.login_id last_update_login
               , NULL program_application_id
               , NULL program_id
               , NULL program_update_date
               , NULL request_id
               , l_invoice_line_rec.primary_intended_use intended_use
               , 'N' rcv_charge_addition_flag
               , l_invoice_line_rec.pay_awt_group_id pay_awt_group_id
               , aid.invoice_distribution_id awt_related_id
            FROM ap_invoice_distributions_all aid
           WHERE aid.invoice_id                 = l_invoice_line_rec.invoice_id
             AND aid.line_type_lookup_code NOT IN('AWT' , 'PREPAY','ERV','TERV')
             AND (  l_Inc_AWT_For_Tax_Flag      = 1
                       OR( aid.line_type_lookup_code NOT IN('REC_TAX' , 'NONREC_TAX' , 'TIPV' , 'TRV'))
                 ) ;


	debug_info := ' After Insert AwT Distributions ';
	end if;

	  UPDATE ap_invoice_distributions_all aid
	     SET aid.amount = aid.amount -
		 ((
		   SELECT SUM(aid1.amount)
		     FROM ap_invoice_distributions_all aid1
		    WHERE aid1.invoice_id          = aid.invoice_id
		      AND aid1.invoice_line_number = aid.invoice_line_number
		 )- l_invoice_line_rec.amount)
	   WHERE aid.invoice_id          = l_invoice_line_rec.invoice_id
	     AND aid.invoice_line_number = l_invoice_line_rec.line_number
	     AND ABS(aid.amount)         =
		 ( SELECT MAX(ABS(aid1.amount))
		     FROM ap_invoice_distributions_all aid1
		    WHERE aid1.invoice_id          = aid.invoice_id
		      AND aid1.invoice_line_number = aid.invoice_line_number)
	     AND rownum = 1;

	IF X_exchange_rate_type is not null then

	  UPDATE ap_invoice_distributions_all aid
	     SET aid.base_amount = aid.base_amount -
		 ((
		   SELECT SUM(aid1.base_amount)
		     FROM ap_invoice_distributions_all aid1
		    WHERE aid1.invoice_id          = aid.invoice_id
		      AND aid1.invoice_line_number = aid.invoice_line_number
		 )- l_invoice_line_rec.base_amount)
	   WHERE aid.invoice_id          = l_invoice_line_rec.invoice_id
	     AND aid.invoice_line_number = l_invoice_line_rec.line_number
	     AND ABS(aid.base_amount)         =
		 ( SELECT MAX(ABS(aid1.base_amount))
		     FROM ap_invoice_distributions_all aid1
		    WHERE aid1.invoice_id          = aid.invoice_id
		      AND aid1.invoice_line_number = aid.invoice_line_number)
	     AND rownum = 1;

	END IF;


    GMS_AP_API.CREATE_AWARD_DISTRIBUTIONS
                ( p_invoice_id		     => l_invoice_line_rec.invoice_id,
                  p_distribution_line_number => 1,
                  p_invoice_distribution_id  => l_invoice_distribution_id,
                  p_award_id		     => l_invoice_line_rec.award_id,
                  p_mode		     => 'AP',
                  p_dist_set_id		     => NULL,
                  p_dist_set_line_number     => NULL );


     EXCEPTION
      WHEN OTHERS THEN
        X_debug_info := debug_info || ': Error encountered during dist insert';
        X_debug_context := current_calling_sequence;
        --Bugfix: 3859755, added the below stmt.
        X_Error_Code := SQLERRM;
        RETURN (FALSE);
    END;

    ----------------------------------------------------------------------------
  -- Step 10 - Update generate distributions flag in invoice line if generating
  -- permanent distributions.
  ----------------------------------------------------------------------------
  debug_info := 'Setting generate distributions flag to Done';
  IF (l_distribution_class = 'PERMANENT') then
    BEGIN
      UPDATE AP_INVOICE_LINES
         SET GENERATE_DISTS = 'D'
       WHERE invoice_id = X_invoice_id
         AND line_number = l_invoice_line_rec.line_number;
    EXCEPTION
      WHEN OTHERS THEN
        X_debug_info := debug_info || ': Error encountered';
        X_debug_context := current_calling_sequence;
        return (FALSE);
    END;
  END IF;

  RETURN(TRUE);

EXCEPTION
    WHEN OTHERS THEN
    X_debug_info := 'Error encountered' ||debug_info;
    X_debug_context := current_calling_sequence;
    RETURN (FALSE);
END Insert_AWT_Dist_From_Line;

--Bug 8346277 End



  ----------------------------------------------------------------------
  -- PRIVATE FUNCTION get_project_and_account_for_chrg_dist encapsulates the
  -- logic for obtaining the project and account information for a
  -- distribution created for a charge line that is allocated to one
  -- or more lines in an invoice.
  -- Returns FALSE if an error is encountered and an specific error
  -- code for invalid PA, invalid account or if it is unable to overlay.
  --------------------------------------------------------------------------

  FUNCTION Get_Proj_And_Acc_For_Chrg_Dist(
  X_invoice_id             IN         NUMBER,
  X_invoice_date           IN         AP_INVOICES.INVOICE_DATE%TYPE,
  X_vendor_id              IN         NUMBER,
  X_invoice_currency_code  IN         AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
  X_sob_id                 IN         AP_INVOICE_LINES.SET_OF_BOOKS_ID%TYPE,
  X_chart_of_accounts_id   IN         GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE,
  X_base_currency_code     IN         AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE,
  X_amount                 IN         AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE,
  X_base_amount            IN         AP_INVOICE_DISTRIBUTIONS.BASE_AMOUNT%TYPE,
  X_exchange_rate_type     IN         AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE,
  X_exchange_date          IN         AP_INVOICES.EXCHANGE_DATE%TYPE,
  X_exchange_rate          IN         AP_INVOICES.EXCHANGE_RATE%TYPE,
  X_line_number            IN         NUMBER,
  X_GL_Date                IN         AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE,
  X_Period_Name            IN         AP_INVOICE_LINES.PERIOD_NAME%TYPE,
  X_chrg_line_project_id   IN         AP_INVOICE_LINES.PROJECT_ID%TYPE,
  X_chrg_line_task_id      IN         AP_INVOICE_LINES.TASK_ID%TYPE,
  X_chrg_line_award_id	   IN	      AP_INVOICE_LINES.award_ID%TYPE,
  X_chrg_line_expenditure_type IN         AP_INVOICE_LINES.EXPENDITURE_TYPE%TYPE,
  X_chrg_line_exp_org_id   IN         AP_INVOICE_LINES.EXPENDITURE_ORGANIZATION_ID%TYPE,
  X_chrg_assets_track_flag IN         AP_INVOICE_LINES.ASSETS_TRACKING_FLAG%TYPE,
  X_chrg_asset_book_type_code  IN         AP_INVOICE_LINES.ASSET_BOOK_TYPE_CODE%TYPE,
  X_chrg_asset_category_id IN         AP_INVOICE_LINES.ASSET_CATEGORY_ID%TYPE,
  X_item_dist_project_id   IN         AP_INVOICE_DISTRIBUTIONS.PROJECT_ID%TYPE,
  X_item_dist_task_id      IN         AP_INVOICE_DISTRIBUTIONS.TASK_ID%TYPE,
  X_item_dist_award_id	   IN	      AP_INVOICE_DISTRIBUTIONS.award_ID%TYPE,
  X_item_dist_expenditure_type IN         AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_TYPE%TYPE,
  X_item_dist_exp_org_id   IN         AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_ORGANIZATION_ID%TYPE,
  X_item_assets_track_flag IN         AP_INVOICE_DISTRIBUTIONS.ASSETS_TRACKING_FLAG%TYPE,
  X_item_asset_book_type_code  IN         AP_INVOICE_DISTRIBUTIONS.ASSET_BOOK_TYPE_CODE%TYPE,
  X_item_asset_category_id IN         AP_INVOICE_DISTRIBUTIONS.ASSET_CATEGORY_ID%TYPE,
  X_chrg_line_default_ccid IN         NUMBER,
  X_overlay_dist_code_concat   IN         AP_INVOICE_LINES.OVERLAY_DIST_CODE_CONCAT%TYPE,
  X_balancing_segment      IN         AP_INVOICE_LINES.BALANCING_SEGMENT%TYPE,
  X_account_segment        IN         AP_INVOICE_LINES.ACCOUNT_SEGMENT%TYPE,
  X_cost_center_segment    IN         AP_INVOICE_LINES.COST_CENTER_SEGMENT%TYPE,
  X_item_dist_ccid         IN         AP_INVOICE_DISTRIBUTIONS.DIST_CODE_COMBINATION_ID%TYPE,
  X_item_po_dist_id        IN         AP_INVOICE_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE,
  X_item_rcv_trx_id        IN         AP_INVOICE_DISTRIBUTIONS.RCV_TRANSACTION_ID%TYPE,
  X_pa_allows_overrides    IN         VARCHAR2,
  X_allow_po_override      IN         VARCHAR2,
  X_project_id             OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.PROJECT_ID%TYPE,
  X_task_id                OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.TASK_ID%TYPE,
  X_award_id		   OUT NOCOPY AP_INVOICE_LINES.award_ID%TYPE,
  X_expenditure_type       OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_TYPE%TYPE,
  X_expenditure_org_id     OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_ORGANIZATION_ID%TYPE,
  X_expenditure_item_date  OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_ITEM_DATE%TYPE,
  X_pa_addition_flag       OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.PA_ADDITION_FLAG%TYPE,
  X_account_for_dist       OUT NOCOPY NUMBER,
  X_assets_tracking_flag   OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.ASSETS_TRACKING_FLAG%TYPE,
  X_asset_book_typ_code    OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.ASSET_BOOK_TYPE_CODE%TYPE,
  X_asset_category_id      OUT NOCOPY AP_INVOICE_DISTRIBUTIONS.ASSET_CATEGORY_ID%TYPE,
  X_error_code             OUT NOCOPY VARCHAR2,
  X_msg_application        OUT NOCOPY VARCHAR2,
  X_msg_data               OUT NOCOPY VARCHAR2,
  X_default_dist_ccid      IN   AP_INVOICE_LINES.DEFAULT_DIST_CCID%TYPE) --bug 5386396
  RETURN BOOLEAN
IS

  l_po_accrue_on_receipt_flag PO_DISTRIBUTIONS.ACCRUE_ON_RECEIPT_FLAG%TYPE;
  l_po_ccid                   PO_DISTRIBUTIONS.CODE_COMBINATION_ID%TYPE;
  l_dist_ccid                 AP_INVOICE_DISTRIBUTIONS.DIST_CODE_COMBINATION_ID%TYPE;
  l_dist_code_concat          VARCHAR2(2000);
  l_employee_id               AP_SUPPLIERS.EMPLOYEE_ID%TYPE;
  l_account_type              GL_CODE_COMBINATIONS.ACCOUNT_TYPE%TYPE;
  user_id                     NUMBER;
  l_msg_application         VARCHAR2(25);
  l_msg_type              VARCHAR2(25);
  l_msg_token1               VARCHAR2(30);
  l_msg_token2               VARCHAR2(30);
  l_msg_token3               VARCHAR2(30);
  l_msg_count              NUMBER;
  l_msg_data              VARCHAR2(30);
  l_billable_flag             VARCHAR2(25);
  l_unbuilt_flex              VARCHAR2(240):='';
  l_reason_unbuilt_flex       VARCHAR2(2000):='';
  l_error_found               VARCHAR2(1) := 'N';
  l_vendor_id                 AP_INVOICES.VENDOR_ID%TYPE;
  current_calling_sequence            VARCHAR2(200);
  debug_context               VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_invoice_type_lookup_code   ap_invoices_all.invoice_type_lookup_code%TYPE;
  l_sys_link_function          VARCHAR2(2); /* Bug 5102724 */
  l_web_parameter_id           number; --Bug5003249
  l_employee_ccid              number;
  l_message_text	       fnd_new_messages.message_text%TYPE;
  l_invoice_attribute_rec       AP_UTILITIES_PKG.r_invoice_attribute_rec; --bug 8713737

BEGIN

  -------------------------------------------------------------------
  -- Step 1 - Gather whether distribution is project related and at
  -- which level.
  -------------------------------------------------------------------
  IF (X_item_dist_project_id IS NOT NULL) THEN
    X_project_id := X_item_dist_project_id;
    X_task_id := X_item_dist_task_id;
    X_expenditure_type := X_item_dist_expenditure_type;
    X_expenditure_org_id := X_item_dist_exp_org_id;
    X_pa_addition_flag := 'N';
  ELSIF (X_chrg_line_project_id is not null) then
    X_project_id := X_chrg_line_project_id;
    X_task_id := X_chrg_line_task_id;
    X_expenditure_type := X_chrg_line_expenditure_type;
    X_expenditure_org_id := X_chrg_line_exp_org_id;
    X_pa_addition_flag := 'N';
  ELSE
    X_project_id := NULL;
    X_task_id := NULL;
    X_expenditure_type := NULL;
    X_expenditure_org_id := NULL;
    X_pa_addition_flag := 'E';
  END IF;

  -------------------------------------------------------------------
  -- Step 2 - Validate PA information
  -------------------------------------------------------------------
  IF (X_project_id IS NOT NULL AND X_item_dist_project_id IS NOT NULL) then
    user_id := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));

    X_expenditure_item_date := AP_INVOICES_PKG.get_expenditure_item_date(
                                                   X_invoice_id,
                                                   X_invoice_date,
                                                   X_GL_date,
                                                   X_item_po_dist_id,
                                                   X_item_rcv_trx_id,
                                                   l_error_found);
    if (l_error_found = 'Y') then
      X_error_code := 'AP_CANNOT_READ_EXP_DATE';
      RETURN(FALSE);
    END IF;

    BEGIN
    SELECT employee_id
    INTO l_employee_id
        FROM ap_suppliers /* bUg 4718054 */
       WHERE DECODE(SIGN(TO_DATE(TO_CHAR(START_DATE_ACTIVE,'DD-MM-YYYY'),
               'DD-MM-YYYY') - TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY'),'DD-MM-YYYY')),
               1, 'N', DECODE(SIGN(TO_DATE(TO_CHAR(END_DATE_ACTIVE ,'DD-MM-YYYY'),
               'DD-MM-YYYY') -  TO_DATE(TO_CHAR(SYSDATE,'DD-MM-YYYY'),'DD-MM-YYYY')),
               -1, 'N', 0, 'N', 'Y')) = 'Y'
         AND enabled_flag = 'Y'
         AND vendor_id = l_vendor_id;
    EXCEPTION
      WHEN no_data_found then
        l_employee_id := NULL;
      WHEN OTHERS then
        l_employee_id := NULL;
    END;

--bug5003249
     Begin
        select default_code_comb_id
        into  l_employee_ccid
        from  PER_ASSIGNMENTS_F
        where person_id =  l_employee_id
        and   set_of_books_id =  x_sob_id
        and   trunc(sysdate) BETWEEN trunc(effective_start_date)
        and   nvl(trunc(effective_end_date), trunc(sysdate));
     EXCEPTION
         WHEN OTHERS then
          l_employee_ccid := NULL;
     End;

        select  WEB_PARAMETER_ID,   /* Bug 8713737 - added DFF columns*/
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
        into  l_web_parameter_id,
            l_invoice_attribute_rec.line_attribute_category,
            l_invoice_attribute_rec.line_attribute1 ,
            l_invoice_attribute_rec.line_attribute2 ,
            l_invoice_attribute_rec.line_attribute3 ,
            l_invoice_attribute_rec.line_attribute4 ,
            l_invoice_attribute_rec.line_attribute5 ,
            l_invoice_attribute_rec.line_attribute6 ,
            l_invoice_attribute_rec.line_attribute7 ,
            l_invoice_attribute_rec.line_attribute8 ,
            l_invoice_attribute_rec.line_attribute9 ,
            l_invoice_attribute_rec.line_attribute10,
            l_invoice_attribute_rec.line_attribute11,
            l_invoice_attribute_rec.line_attribute12,
            l_invoice_attribute_rec.line_attribute13,
            l_invoice_attribute_rec.line_attribute14,
            l_invoice_attribute_rec.line_attribute15
        from  ap_invoice_lines
        where invoice_id = X_invoice_id
        AND line_number = X_line_number;

     /* Bug 5102724 */
      BEGIN
        SELECT  invoice_type_lookup_code, /* Bug 8713737 - added DFF columns*/
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
        INTO    l_invoice_type_lookup_code,
                l_invoice_attribute_rec.attribute_category,
                l_invoice_attribute_rec.attribute1,
                l_invoice_attribute_rec.attribute2,
                l_invoice_attribute_rec.attribute3,
                l_invoice_attribute_rec.attribute4,
                l_invoice_attribute_rec.attribute5,
                l_invoice_attribute_rec.attribute6,
                l_invoice_attribute_rec.attribute7,
                l_invoice_attribute_rec.attribute8,
                l_invoice_attribute_rec.attribute9,
                l_invoice_attribute_rec.attribute10,
                l_invoice_attribute_rec.attribute11,
                l_invoice_attribute_rec.attribute12,
                l_invoice_attribute_rec.attribute13,
                l_invoice_attribute_rec.attribute14,
                l_invoice_attribute_rec.attribute15
        FROM   ap_invoices_all
        WHERE  invoice_id = X_invoice_id;
      EXCEPTION
        WHEN no_data_found then
          NULL;
        WHEN OTHERS then
          NULL;
      END;

      If (l_invoice_type_lookup_code ='EXPENSE REPORT') Then
        l_sys_link_function :='ER' ;
      Else
        l_sys_link_function :='VI' ;
      End if;

    PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
                X_PROJECT_ID          => X_project_id,
                X_TASK_ID             => X_task_id,
                X_EI_DATE             => X_expenditure_item_date,
                X_EXPENDITURE_TYPE    => X_expenditure_type,
                X_NON_LABOR_RESOURCE  => null,
                X_PERSON_ID           => l_employee_id,
                X_QUANTITY            => '1',
                X_denom_currency_code => X_invoice_currency_code,
                X_acct_currency_code  => X_base_currency_code,
                X_denom_raw_cost      => X_amount,
                X_acct_raw_cost       => X_base_amount,
                X_acct_rate_type      => X_exchange_rate_type,
                X_acct_rate_date      => X_exchange_date,
                X_acct_exchange_rate  => X_exchange_rate,
                X_TRANSFER_EI         => null,
                X_INCURRED_BY_ORG_ID  => X_expenditure_org_id,
                X_NL_RESOURCE_ORG_ID  => null,
                X_TRANSACTION_SOURCE  => l_sys_link_function,  /* bug 5102724 */
                X_CALLING_MODULE      => 'apiindib.pls',
                X_VENDOR_ID           => X_vendor_id,
                X_ENTERED_BY_USER_ID  => user_id,
                X_ATTRIBUTE_CATEGORY  => NULL,
                X_ATTRIBUTE1          => NULL,
                X_ATTRIBUTE2          => NULL,
                X_ATTRIBUTE3          => NULL,
                X_ATTRIBUTE4          => NULL,
                X_ATTRIBUTE5          => NULL,
                X_ATTRIBUTE6          => NULL,
                X_ATTRIBUTE7          => NULL,
                X_ATTRIBUTE8          => NULL,
                X_ATTRIBUTE9          => NULL,
                X_ATTRIBUTE10         => NULL,
                X_ATTRIBUTE11         => NULL,
                X_ATTRIBUTE12         => NULL,
                X_ATTRIBUTE13         => NULL,
                X_ATTRIBUTE14         => NULL,
                X_ATTRIBUTE15         => NULL,
                X_msg_application     => l_msg_application,
                X_msg_type            => l_msg_type,
                X_msg_token1          => l_msg_token1,
                X_msg_token2          => l_msg_token2,
                X_msg_token3          => l_msg_token3,
                X_msg_count           => l_msg_count,
                X_msg_data            => l_msg_data,
                X_BILLABLE_FLAG       => l_billable_flag);

    if (l_msg_data is not null) then
      X_msg_application := l_msg_application;
      X_msg_data := l_msg_data;
      --bugfix:5725904
      Fnd_Message.Set_Name(l_msg_application, l_msg_data);
      /*bug 6682104 setting the token values*/
            IF (l_msg_token1 IS NOT NULL) THEN
	       fnd_message.set_token('PATC_MSG_TOKEN1',l_msg_token1);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN1',FND_API.G_MISS_CHAR);
	    END IF;

            IF (l_msg_token2 IS NOT NULL) THEN
	        fnd_message.set_token('PATC_MSG_TOKEN2',l_msg_token2);
            ELSE
	       fnd_message.set_token('PATC_MSG_TOKEN2',FND_API.G_MISS_CHAR);
            END IF;

            IF (l_msg_token3 IS NOT NULL) THEN
	         fnd_message.set_token('PATC_MSG_TOKEN3',l_msg_token3);
            ELSE
	          fnd_message.set_token('PATC_MSG_TOKEN3',FND_API.G_MISS_CHAR);
            END IF;
      l_message_text := Fnd_Message.get;
      x_error_code := l_message_text;

      return(FALSE);

    end if;

  end if;


  --------------------------------------------------------------------------
  -- Step 3 - Gather the source of the account. Possible values are
  -- a) Account from item distribution (if no PA information)
  -- b) Account from item distribution (if PA information from dist)
  -- c) Account from PO if accrue on receipt and dist PO matched
  -- d) Account from PA if PA information from line
  -- Also, the accounts above may be overlayed with overlay information if:
  -- 1) Overlay information available
  -- 2) If PO matched and account not from line PA info and PO allows overrides
  -- 3) If account from line PA info and PA allows overrides
  -- 4) If account from item dist, (not PO matched but PA related) and
  --    PA allows overrides
  -- 5) If account from item dist (not PO matched and not PA related)
  ----------------------------------------------------------------------------
    --Bug5003249 added condition on invoice type lookup code
  IF (X_project_id IS NOT NULL AND X_item_dist_project_id IS NULL
      AND l_invoice_type_lookup_code<>'PREPAYMENT') THEN
    -- l_dist_ccid := AP_UTILITIES_PKG.PA_FLEXBUILD

    debug_info := 'Billable Flag To PA FlexBuild '||l_billable_flag; --Bug6523162

    IF ( NOT (AP_UTILITIES_PKG.pa_flexbuild(
               p_vendor_id          =>  X_vendor_id,          --IN
               p_employee_id        =>  l_employee_id,        --IN
               p_set_of_books_id    =>  X_sob_id,             --IN
               p_chart_of_accounts_id => X_chart_of_accounts_id, -- IN
               p_base_currency_code    =>  X_base_currency_code, --IN
               p_accounting_date       =>  X_GL_Date,            --IN
               p_award_id              =>  X_award_id,           --IN
               P_project_id             => X_project_id,
               p_task_id                => X_task_id,
               p_expenditure_type       => X_expenditure_type,
               p_expenditure_org_id     => X_expenditure_org_id,
               p_expenditure_item_date  => X_expenditure_item_date,
               p_invoice_attribute_rec  => l_invoice_attribute_rec, -- bug 8713737
               p_billable_flag             => l_billable_flag, --Bug6523162
               p_employee_ccid             =>
                      l_employee_ccid,   --Bug5003249
               p_web_parameter_id          =>
                      l_web_parameter_id,   --Bug5003249
               p_invoice_type_lookup_code  =>
                      l_invoice_type_lookup_code, --Bug5003249
               p_default_last_updated_by => FND_GLOBAL.user_id,
               p_default_last_update_login  => FND_GLOBAL.login_id,
               p_pa_default_dist_ccid       => l_dist_ccid,
               p_pa_concatenated_segments   => l_dist_code_concat, --OUT NOCOPY
               p_debug_Info                 => debug_Info, -- OUT  NOCOPY
               p_debug_Context             =>  debug_Context, --OUT  NOCOPY
               p_calling_sequence          => 'Get_Proj_And_Acc_For_Chrg_Dist' ,
               p_default_dist_ccid         =>  X_default_dist_ccid  --IN  bug 5386396
               ))) THEN
       debug_info := debug_info || ': Error encountered';
       debug_context := current_calling_sequence;
       RETURN(FALSE);
    END IF;
    IF (X_pa_allows_overrides = 'Y' AND
        (X_overlay_dist_code_concat   IS NOT NULL OR
         X_balancing_segment   IS NOT NULL OR
         X_account_segment     IS NOT NULL OR
         X_cost_center_segment IS NOT NULL)) THEN

      IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                   X_balancing_segment,
                   X_cost_center_segment,
                   X_account_segment,
                   X_overlay_dist_code_concat,
                   l_dist_ccid,
                   X_sob_id,
                   'CREATE_COMB_NO_AT',
                   l_unbuilt_flex,
                   l_reason_unbuilt_flex,
                   FND_GLOBAL.RESP_APPL_ID,
                   FND_GLOBAL.RESP_ID,
                   FND_GLOBAL.USER_ID,
                   'Create Charge Account',
                   NULL,
                   X_GL_Date))) then --7531219
        X_error_code := 'AP_CANNOT_OVERLAY';
        RETURN(FALSE);
      END IF;
    END IF;

  ELSIF (X_item_po_dist_id IS NOT NULL) THEN
    BEGIN
      SELECT code_combination_id,
             accrue_on_receipt_flag
        INTO l_po_ccid,
             l_po_accrue_on_receipt_flag
        FROM po_distributions
       WHERE po_distribution_id = X_item_po_dist_id;

    EXCEPTION
      When no_data_found then
        return(FALSE);
    END;

    IF (l_po_accrue_on_receipt_flag = 'Y') THEN
      l_dist_ccid := l_po_ccid;
    ELSE
      l_dist_ccid := X_item_dist_ccid;
    END IF;


    IF (((X_item_dist_project_id is null and
          X_allow_po_override = 'Y' ) OR
         (X_item_dist_project_id IS NOT NULL AND
          X_pa_allows_overrides = 'Y' AND
          X_allow_po_override = 'Y')) AND
        (X_overlay_dist_code_concat   IS NOT NULL OR
         X_balancing_segment          IS NOT NULL OR
         X_account_segment            IS NOT NULL OR
         X_cost_center_segment        IS NOT NULL)

         ) THEN

      IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                   X_balancing_segment,
                   X_cost_center_segment,
                   X_account_segment,
                   X_overlay_dist_code_concat,
                   l_dist_ccid,
                   X_sob_id,
                   'CREATE_COMB_NO_AT',
                   l_unbuilt_flex,
                   l_reason_unbuilt_flex,
                   FND_GLOBAL.RESP_APPL_ID,
                   FND_GLOBAL.RESP_ID,
                   FND_GLOBAL.USER_ID,
                   'Create Charge Account',
                   NULL,
                   X_GL_Date))) THEN --7531219
        X_error_code := 'AP_CANNOT_OVERLAY';
        RETURN(FALSE);
      END IF;

    ELSE
      IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                  l_dist_ccid,
                  X_chart_of_accounts_id,
                  X_GL_date,
                  'Create Charge Account'))) THEN
        X_error_code := 'AP_INVALID_ACCOUNT';
        RETURN(FALSE);
      END IF;

    END IF;

  ELSE
    l_dist_ccid := X_item_dist_ccid;
    if (X_overlay_dist_code_concat IS NOT NULL OR
        X_balancing_segment   IS NOT NULL OR
        X_account_segment     IS NOT NULL OR
        X_cost_center_segment IS NOT NULL) THEN

      IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                  X_balancing_segment,
                  X_cost_center_segment,
                  X_account_segment,
                  X_overlay_dist_code_concat,
                  l_dist_ccid,
                  X_sob_id,
                  'CREATE_COMB_NO_AT',
                  l_unbuilt_flex,
                  l_reason_unbuilt_flex,
                  FND_GLOBAL.RESP_APPL_ID,
                  FND_GLOBAL.RESP_ID,
                  FND_GLOBAL.USER_ID,
                  'Create Charge Account',
                  NULL,
                  X_GL_Date))) then --7531219
        X_error_code := 'AP_CANNOT_OVERLAY';
        RETURN(FALSE);
      END IF;
    ELSE
      IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(l_dist_ccid,
                                               X_chart_of_accounts_id,
                                               X_GL_date,
                                               'Create Charge Account'))) then
        X_error_code := 'AP_INVALID_ACCOUNT';
        RETURN(FALSE);
      END IF;
    END IF;
  END IF;

  X_account_for_dist := l_dist_ccid;

  -------------------------------------------------------------------
  -- Step 4 - Get account type and asset information
  -------------------------------------------------------------------
  BEGIN
    SELECT account_type
      INTO l_account_type
      FROM gl_code_combinations
     WHERE code_combination_id = l_dist_ccid;

  EXCEPTION
    WHEN no_data_found THEN
       RETURN(FALSE);
  END;

  IF (l_account_type = 'A') THEN
    X_assets_tracking_flag := 'Y';
    X_asset_book_typ_code := nvl(X_item_asset_book_type_code,
                                  X_chrg_asset_book_type_code);
    X_asset_category_id := nvl(X_item_asset_category_id,
                                      X_chrg_asset_category_id);
  ELSIF (l_account_type = 'E' AND
         X_chrg_assets_track_flag = 'Y') THEN
    X_assets_tracking_flag := 'Y';
    X_asset_book_typ_code := X_chrg_asset_book_type_code;
    X_asset_category_id := X_chrg_asset_category_id;
  ELSE
    X_assets_tracking_flag := 'N';
    X_asset_book_typ_code := NULL;
    X_asset_category_id := NULL;
  END IF;

  IF (X_item_dist_award_id IS NOT NULL) THEN
      gms_ap_api.get_distribution_award
			(p_invoice_id		    => NULL,
			 p_distribution_line_number => NULL,
			 p_invoice_distribution_id  => NULL,
			 p_award_set_id             => x_item_dist_award_id,
			 p_award_id		    => x_award_id);

  ELSIF (X_chrg_line_award_id is not null) then
    x_award_id := X_chrg_line_award_id;
  ELSE
    x_award_id := NULL;
  END IF;

  IF (X_award_id IS NOT NULL AND X_item_dist_award_id IS NOT NULL) then

	current_calling_sequence := 'AWARD_ID'; -- Bug 8600813: required when award_id is passed

	GMS_AP_API.validate_transaction
			( x_project_id		  => X_project_id,
			  x_task_id		  => X_task_id,
			  x_award_id		  => X_award_id,
			  x_expenditure_type	  => X_expenditure_type,
 			  x_expenditure_item_date => X_expenditure_item_date,
			  x_calling_sequence	  => current_calling_sequence,
			  x_msg_application       => l_msg_application,
			  x_msg_type              => l_msg_type,
			  x_msg_count             => l_msg_count,
			  x_msg_data              => l_msg_data );

	IF (l_msg_data is not null) THEN
	    X_msg_application := l_msg_application;
	    X_msg_data := l_msg_data;
	    X_error_code := X_msg_data;  -- bug 7936518
	    Return(FALSE);
	END IF;
  END IF;

  RETURN(TRUE);

END get_proj_and_acc_for_chrg_dist;


  -----------------------------------------------------------------------
  -- FUNCTION insert_charge_from_alloc inserts charge distributions based
  -- on the defined allocations for the parent line.
  -- It returns FALSE if an error is encountered.
  -----------------------------------------------------------------------
  FUNCTION Insert_Charge_From_Alloc(
           X_invoice_id          IN         NUMBER,
           X_line_number         IN         NUMBER,
           X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
           X_Validate_Info       IN         BOOLEAN DEFAULT TRUE,
           X_Error_Code          OUT NOCOPY VARCHAR2,
           X_Debug_Info          OUT NOCOPY VARCHAR2,
           X_Debug_Context       OUT NOCOPY VARCHAR2,
           X_Msg_Application     OUT NOCOPY VARCHAR2,
           X_Msg_Data            OUT NOCOPY VARCHAR2,
           X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN
  IS

  CURSOR alloc_rule_lines_cur IS
  SELECT ARL.to_invoice_line_number,
         ARL.percentage,
         ARL.amount,
         Sum(AID.amount)
    FROM AP_Allocation_Rule_Lines ARL,
         AP_invoice_distributions_all AID
    WHERE ARL.invoice_id = X_invoice_id
      AND AID.invoice_id = X_invoice_id
      AND ARL.chrg_invoice_line_number = X_line_number
      AND AID.invoice_line_number = ARL.to_invoice_line_number
      AND AID.line_type_lookup_code in ('ITEM', 'ACCRUAL', 'IPV', 'ERV')
  --Invoice Lines: Distributions,  Added the ARL.amount, ARL.percentage
  --to the GROUP BY , without those cursor is INVALID
  GROUP BY ARL.to_invoice_line_number, ARL.amount,ARL.percentage
  ORDER BY ARL.to_invoice_line_number;


  CURSOR applicable_lines_cur IS
    SELECT AIL.line_number,
           AIL.amount,
           sum(AID.amount)
      FROM AP_invoice_lines AIL,
           AP_invoice_distributions_all AID
     WHERE AIL.invoice_id = X_invoice_id
       AND nvl(AIL.discarded_flag, 'N') = 'N'
       AND nvl(AIL.cancelled_flag, 'N') = 'N'
       AND AIL.amount <> 0
       AND AIL.line_type_lookup_code = 'ITEM'
       AND nvl(AIL.match_type,'NOT_MATCHED') NOT IN
 	      ('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION','AMOUNT_CORRECTION')
       AND AID.invoice_line_number = AIL.line_number
       AND AID.invoice_id = X_invoice_id
       AND AID.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'IPV', 'ERV')
  --Invoice Lines: Distributions, added AIL.amount to the GROUPBY clause
  GROUP BY AIL.line_number,AIL.amount
  ORDER BY AIL.line_number;

  CURSOR applicable_dists_cur (P_line_number IN NUMBER) IS
    SELECT AID.invoice_distribution_id,
           AID.po_distribution_id,
           AID.rcv_transaction_id,
           AID.project_id,
           AID.task_id,
	   AID.pa_quantity,   -- bug6699834
           AID.expenditure_type,
           AID.expenditure_organization_id,
           AID.award_id,
	   AP_INVOICE_DISTRIBUTIONS_PKG.GET_TOTAL_DIST_AMOUNT(
			aid.invoice_distribution_id),
           AID.dist_code_combination_id,
           AID.assets_tracking_flag,
           AID.asset_book_type_code,
           AID.asset_category_id,
           AID.description
      FROM ap_invoice_distributions_all AID
     WHERE AID.invoice_id = X_invoice_id
       AND AID.invoice_line_number = P_line_number
       AND AID.line_type_lookup_code in ('ITEM', 'ACCRUAL')
  ORDER BY AID.distribution_line_number;


  l_batch_id               AP_INVOICE_DISTRIBUTIONS.BATCH_ID%TYPE;
  l_distribution_class     AP_INVOICE_DISTRIBUTIONS.DISTRIBUTION_CLASS%TYPE;
  l_org_id                 AP_INVOICE_LINES.ORG_ID%TYPE;
  l_sob_id                 AP_INVOICE_LINES.SET_OF_BOOKS_ID%TYPE;
  l_base_currency_code     AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
  l_chart_of_accounts_id   GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
  l_account_type           GL_CODE_COMBINATIONS.ACCOUNT_TYPE%TYPE;
  l_invoice_date           AP_INVOICES.INVOICE_DATE%TYPE;
  l_vendor_id              AP_INVOICES.VENDOR_ID%TYPE;
  l_invoice_amount         AP_INVOICES.INVOICE_AMOUNT%TYPE;
  l_exchange_rate          AP_INVOICES.EXCHANGE_RATE%TYPE;
  l_exchange_rate_type     AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE;
  l_exchange_date          AP_INVOICES.EXCHANGE_DATE%TYPE;
  l_invoice_currency_code  AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_assets_tracking_flag   AP_INVOICE_LINES.ASSETS_TRACKING_FLAG%TYPE;
  l_asset_book_type_code   AP_INVOICE_LINES.ASSET_BOOK_TYPE_CODE%TYPE;
  l_asset_category_id      AP_INVOICE_LINES.ASSET_CATEGORY_ID%TYPE;
  l_line_amount            AP_INVOICE_LINES.AMOUNT%TYPE;
  l_line_base_amount       AP_INVOICE_LINES.BASE_AMOUNT%TYPE;
  l_line_type_lookup_code  AP_INVOICE_LINES.LINE_TYPE_LOOKUP_CODE%TYPE;
  l_line_description       AP_INVOICE_LINES.DESCRIPTION%TYPE;
  l_sum_lines_amount       AP_INVOICE_LINES.AMOUNT%TYPE;
  l_default_dist_ccid      AP_INVOICE_LINES.DEFAULT_DIST_CCID%TYPE;
  l_overlay_dist_concat    AP_INVOICE_LINES.OVERLAY_DIST_CODE_CONCAT%TYPE;
  l_balancing_segment      AP_INVOICE_LINES.BALANCING_SEGMENT%TYPE;
  l_account_segment        AP_INVOICE_LINES.ACCOUNT_SEGMENT%TYPE;
  l_cost_center_segment    AP_INVOICE_LINES.COST_CENTER_SEGMENT%TYPE;
  l_project_id             AP_INVOICE_LINES.PROJECT_ID%TYPE;
  l_task_id                AP_INVOICE_LINES.TASK_ID%TYPE;
  l_award_id		   AP_INVOICE_LINES.AWARD_ID%TYPE;
  l_expenditure_type       AP_INVOICE_LINES.EXPENDITURE_TYPE%TYPE;
  l_expenditure_organization_id
    AP_INVOICE_LINES.EXPENDITURE_ORGANIZATION_ID%TYPE;
  l_accounting_date        AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE;
  l_created_by             AP_INVOICE_LINES.CREATED_BY%TYPE;
  l_last_update_login      AP_INVOICE_LINES.LAST_UPDATE_LOGIN%TYPE;
  l_awt_group_id           AP_INVOICE_LINES.AWT_GROUP_ID%TYPE;

l_pay_awt_group_id           AP_INVOICE_LINES.PAY_AWT_GROUP_ID%TYPE;	---7022001

  l_type_1099              AP_INVOICE_LINES.TYPE_1099%TYPE;
  l_income_tax_region      AP_INVOICE_LINES.INCOME_TAX_REGION%TYPE;
  l_open_gl_date           AP_INVOICE_LINES.ACCOUNTING_DATE%TYPE;
  l_open_period_name       AP_INVOICE_LINES.PERIOD_NAME%TYPE;
  l_invoice_distribution_id
    AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;
  l_po_distribution_id     AP_INVOICE_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE;
  l_rcv_transaction_id     AP_INVOICE_DISTRIBUTIONS.RCV_TRANSACTION_ID%TYPE;
  l_dist_project_id        AP_INVOICE_DISTRIBUTIONS.PROJECT_ID%TYPE;
  l_dist_task_id           AP_INVOICE_DISTRIBUTIONS.TASK_ID%TYPE;
  l_dist_pa_quantity       AP_INVOICE_DISTRIBUTIONS.PA_QUANTITY%TYPE; --6699834
  l_dist_award_id          AP_INVOICE_DISTRIBUTIONS.AWARD_ID%TYPE;
  l_dist_expenditure_type  AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_TYPE%TYPE;
  l_dist_expenditure_org_id
    AP_INVOICE_DISTRIBUTIONS.EXPENDITURE_ORGANIZATION_ID%TYPE;
  l_dist_amount            AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE;
  l_dist_base_amount       AP_INVOICE_DISTRIBUTIONS.BASE_AMOUNT%TYPE;
  l_dist_code_combination_id
    AP_INVOICE_DISTRIBUTIONS.DIST_CODE_COMBINATION_ID%TYPE;
  l_dist_assets_tracking_flag
    AP_INVOICE_DISTRIBUTIONS.ASSETS_TRACKING_FLAG%TYPE;
  l_dist_asset_book_type_code
    AP_INVOICE_DISTRIBUTIONS.ASSET_BOOK_TYPE_CODE%TYPE;
  l_dist_asset_category_id
    AP_INVOICE_DISTRIBUTIONS.ASSET_CATEGORY_ID%TYPE;
  l_dist_description       AP_INVOICE_DISTRIBUTIONS.DESCRIPTION%TYPE;
  l_dist_tab               AP_INVOICE_LINES_PKG.dist_tab_type;
  l_alloc_line_tab         AP_INVOICE_LINES_PKG.alloc_line_tab_type;
  l_rule_type              AP_ALLOCATION_RULES.RULE_TYPE%TYPE;
  l_rule_status            AP_ALLOCATION_RULES.STATUS%TYPE;
  l_alloc_rule_line_percent AP_ALLOCATION_RULE_LINES.PERCENTAGE%TYPE := 0;
  l_alloc_rule_line_amount AP_ALLOCATION_RULE_LINES.AMOUNT%TYPE := 0;
  l_alloc_rule_line_number
    AP_ALLOCATION_RULE_LINES.TO_INVOICE_LINE_NUMBER%TYPE;
  l_applicable_line_number AP_INVOICE_LINES.LINE_NUMBER%TYPE;
  l_applicable_line_amount AP_INVOICE_LINES.AMOUNT%TYPE := 0;
  l_sum_applic_lines       AP_INVOICE_LINES.AMOUNT%TYPE := 0;
  l_sum_dists_applic_line  AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE := 0;
  l_running_total_alloc    AP_INVOICE_LINES.AMOUNT%TYPE := 0;
  l_running_total_base_amt AP_INVOICE_LINES.BASE_AMOUNT%TYPE := 0;
  l_max_alloc              AP_INVOICE_LINES.AMOUNT%TYPE := 0;
  l_max_base_alloc         AP_INVOICE_LINES.BASE_AMOUNT%TYPE := 0;
  --Bug9296445
  l_reference_1	           AP_INVOICE_LINES.REFERENCE_1%TYPE;
  l_reference_2		   AP_INVOICE_LINES.REFERENCE_2%TYPE;

  l_msg_application      VARCHAR2(25);
  l_msg_data           VARCHAR2(30);
  i                        BINARY_INTEGER := 0;
  t                        BINARY_INTEGER := 0;
  l_max_i                  BINARY_INTEGER := 0;
  l_max_base_i             BINARY_INTEGER := 0;
  l_max_t                  BINARY_INTEGER := 0;
  l_pa_allows_overrides    VARCHAR2(1) := 'N';
  l_allow_po_override      AP_SYSTEM_PARAMETERS.ALLOW_FLEX_OVERRIDE_FLAG%TYPE;
  l_error_found            VARCHAR2(1) := 'N';
  l_error_code             VARCHAR2(80);
  l_existing_distributions NUMBER := 0;
  l_count_undistributed_lines NUMBER := 1;
  l_count_applicable_dists NUMBER := 0;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(1000);

  l_inv_dist_id		   AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;

  -- Bug 5114543
  l_max_dist_line_num	   NUMBER :=0;
  l_chrg_line_rec	   ap_invoice_lines_all%rowtype;
  l_dummy		   VARCHAR2(30);


  l_country_code VARCHAR2(20);   --bug 9169915

BEGIN


  ---------------------------------------------------------------------------
  -- Step 1 - Update the calling sequence
  ---------------------------------------------------------------------------
  current_calling_sequence :=
    'AP_INVOICE_DISTRIBUTIONS_PKG.insert_charge_from_alloc <-'
    ||X_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 2 - Validate the line exists and get line level information
  --------------------------------------------------------------------------
  debug_info := 'Verify valid invoice line provided';
  BEGIN
    SELECT org_id,
           set_of_books_id,
           default_dist_ccid,
           overlay_dist_code_concat,
           balancing_segment,
           account_segment,
           cost_center_segment,
           project_id,
           task_id,
	   award_id,
           expenditure_type,
           expenditure_organization_id,
           assets_tracking_flag,
           asset_book_type_code,
           asset_category_id,
           accounting_date,
           amount,
           base_amount,
           line_type_lookup_code,
           description,
           awt_group_id,
           type_1099,
           income_tax_region,
           created_by,
           last_update_login,
           pay_awt_group_id,
	   --Bug9296445
	   reference_1,
	   reference_2
      INTO l_org_id,
           l_sob_id,
           l_default_dist_ccid,
           l_overlay_dist_concat,
           l_balancing_segment,
           l_account_segment,
           l_cost_center_segment,
           l_project_id,
           l_task_id,
	   l_award_id,
           l_expenditure_type,
           l_expenditure_organization_id,
           l_assets_tracking_flag,
           l_asset_book_type_code,
           l_asset_category_id,
           l_accounting_date,
           l_line_amount,
           l_line_base_amount,
           l_line_type_lookup_code,
           l_line_description,
           l_awt_group_id,
           l_type_1099,
           l_income_tax_region,
           l_created_by,
           l_last_update_login,
           l_pay_awt_group_id,
           --Bug9296445
	   l_reference_1,
	   l_reference_2
      FROM ap_invoice_lines
     WHERE invoice_id = X_invoice_id
       AND line_number = X_line_number;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_debug_info := debug_info || ': line not found';
      X_debug_context := current_calling_sequence;
      RETURN (FALSE);

  END;
  --------------------------------------------------------------------------
  -- Step 3 - Validate line does not contain other distributions
  --------------------------------------------------------------------------
  IF (X_Validate_Info) then
    debug_info := 'Verify line does not contain distributions';
    BEGIN
      SELECT count(*)
        INTO l_existing_distributions
        FROM ap_invoice_distributions
       WHERE invoice_id = X_invoice_id
         AND invoice_line_number = X_line_number;

      IF (l_existing_distributions <> 0) then
          -- X_debug_info := debug_info || ': line already has distributions';
          -- X_debug_context := current_calling_sequence;
          -- RETURN(FALSE);

          -- Bug 5114543
	  -- Instead of returning a failure, reverse any open inv distributions and
	  -- continue with creation of charge distributions based on the allocation.

	  select ail.*
            into l_chrg_line_rec
	    from ap_invoice_lines_all ail
	   where invoice_id  = X_invoice_id
	     and line_number = X_line_number;

          if not ap_invoice_lines_pkg.reverse_charge_distributions
		                        (p_inv_line_rec         => l_chrg_line_rec
		                        ,p_calling_mode         => l_dummy
		                        ,x_error_code           => x_error_code
		                        ,x_debug_info           => debug_info
		                        ,p_calling_sequence     => current_calling_sequence) then

	     x_debug_info := debug_info || ': unable to reverse charge distributions';
	     x_debug_context := current_calling_sequence;
	     return (false);

          end if;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;

  --------------------------------------------------------------------------
  -- Step 4 - Get invoice information
  --------------------------------------------------------------------------
  debug_info := 'Get invoice information';
  BEGIN
    SELECT batch_id,
           invoice_date,
           vendor_id,
           exchange_rate,
           exchange_rate_type,
           exchange_date,
           invoice_currency_code,
           invoice_amount
      INTO l_batch_id,
           l_invoice_date,
           l_vendor_id,
           l_exchange_rate,
           l_exchange_rate_type,
           l_exchange_date,
           l_invoice_currency_code,
           l_invoice_amount
      FROM ap_invoices
     WHERE invoice_id = X_invoice_id;

  EXCEPTION
    When no_data_found then
      X_debug_info := debug_info || ': cannot read invoice';
      X_debug_context := current_calling_sequence;
      RETURN (FALSE);
  END;

  ---------------------------------------------------------------------------
  -- Step 5 - Validate all lines charge is allocated to have been distributed
  ---------------------------------------------------------------------------
  debug_info := 'Verify all lines to allocate against are distributed';

  BEGIN
    SELECT rule_type, status
      INTO l_rule_type, l_rule_status
      FROM ap_allocation_rules
     WHERE invoice_id = X_invoice_id
       AND chrg_invoice_line_number = X_line_number;

  EXCEPTION
    WHEN no_data_found THEN
      X_error_code := 'AP_NO_ALLOCATION_RULE_FOUND';
      RETURN(FALSE);
  END;

  IF (l_rule_status = 'EXECUTED') then
    X_error_code := 'AP_ALLOCATION_ALREADY_EXECUTED';
    RETURN(FALSE);
  END IF;

  IF (l_rule_type = 'PRORATION') then
    BEGIN
      --Bug 5558693
      SELECT DECODE(NVL(ai.net_of_retainage_flag, 'N'),
                   'Y', (SUM(NVL(ail.amount, 0)) + SUM(NVL(retained_amount,0))),
                    SUM(ail.amount) )
        INTO l_sum_lines_amount
        FROM ap_invoice_lines_all ail,
             ap_invoices_all ai
       WHERE ai.invoice_id = ail.invoice_id
         AND ail.invoice_id = X_invoice_id
         AND ail.line_type_lookup_code NOT IN ('AWT')
	 /*bugfix:5685469*/
	 AND    ((AIL.line_type_lookup_code <> 'TAX'
	          and (AIL.line_type_lookup_code NOT IN ('PREPAY')
		       or NVL(AIL.invoice_includes_prepay_flag,'N') = 'Y'
		      )
		 OR
		 (AIL.line_type_lookup_code = 'TAX'
                  and (AIL.prepay_invoice_id IS NULL
                      or (AIL.prepay_invoice_id is not null
                          and NVL(AIL.invoice_includes_prepay_flag, 'N') = 'Y'
			 )
	       	      )
		 )
		)
	       )
          group by ai.net_of_retainage_flag;

    EXCEPTION
      When no_data_found then
        X_debug_info := debug_info || ': cannot read lines for invoice';
        X_debug_context := current_calling_sequence;
        RETURN(FALSE);
    END;

    IF (l_invoice_amount <> l_sum_lines_amount) then
      X_error_code := 'AP_NON_FULL_INVOICE';
      RETURN(FALSE);
    END IF;

    BEGIN
      SELECT count(*)
        INTO l_count_undistributed_lines
        FROM ap_invoice_lines_all AIL
       WHERE AIL.invoice_id = X_invoice_id
         AND AIL.line_type_lookup_code = 'ITEM'
         AND NVL(AIL.match_type,'NOT_MATCHED') NOT IN
		('PRICE_CORRECTION', 'QTY_CORRECTION','LINE_CORRECTION','AMOUNT_CORRECTION')
         --Bug 5558693
         AND amount  <>
               (SELECT NVL(SUM(NVL(aid.amount,0)),0)
                          FROM ap_invoice_distributions_all AID
                         WHERE AID.invoice_id = ail.invoice_id
                           AND AID.invoice_line_number = AIL.line_number
                           AND (AID.line_type_lookup_code NOT IN ('RETAINAGE','PREPAY')
                                OR (AID.prepay_distribution_id IS NOT NULL
                                     AND AID.line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX', 'TIPV', 'TRV', 'TERV')))
                );

      IF (l_count_undistributed_lines <> 0) then
        X_error_code := 'AP_UNDISTRIBUTED_LINE_EXISTS';
        RETURN(FALSE);
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        X_debug_info := debug_info || ': cannot read lines for invoice';
        X_debug_context := current_calling_sequence;
    END;

  ELSE
    BEGIN

      SELECT count(*)
        INTO l_count_undistributed_lines
        FROM ap_invoice_lines AIL, ap_allocation_rule_lines ARL
       WHERE AIL.invoice_id = X_invoice_id
         AND ARL.invoice_id = X_invoice_id
         AND ARL.chrg_invoice_line_number = X_line_number
         AND ARL.to_invoice_line_number = AIL.line_number
         --Bug 5558693
         AND AIL.amount <> (SELECT NVL(SUM(nvl(amount,0)),0)
                              FROM ap_invoice_distributions AID
                             WHERE AID.invoice_id = AIL.invoice_id
                               AND AID.invoice_line_number = AIL.line_number
                               AND (AID.line_type_lookup_code NOT IN ('RETAINAGE','PREPAY')
                                OR (AID.prepay_distribution_id IS NOT NULL
                                     AND AID.line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX', 'TIPV', 'TRV', 'TERV')))
                           );

      IF (l_count_undistributed_lines <> 0) then
        X_error_code := 'AP_UNDISTRIBUTED_LINE_EXISTS';
        RETURN(FALSE);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_debug_info := debug_info || ': cannot read lines for invoice';
        X_debug_context := current_calling_sequence;
    END;
  END IF;

  ---------------------------------------------------------------------------
  -- Step 6 - Get GL Date and Period name.
  ---------------------------------------------------------------------------
  debug_info :=
    'Get gl date from open period if line gl date is in a closed one';
  BEGIN
    l_open_period_name := NULL;
    l_open_period_name := AP_UTILITIES_PKG.GET_CURRENT_GL_DATE(
                                    l_accounting_date,
				    l_org_id);

    IF (l_open_period_name is NULL) then
      AP_UTILITIES_PKG.GET_OPEN_GL_DATE(l_accounting_date, l_open_period_name,
                                        l_open_gl_date,l_org_id);
    --Invoice Lines: Distributions, added the ELSE part of the IF condition
    ELSE
      l_open_gl_date := l_accounting_date;
    END IF;

    IF (l_open_period_name is NULL) THEN
      X_error_code := 'AP_NO_OPEN_PERIOD';
      RETURN(FALSE);
    END IF;
  END;


  --------------------------------------------------------------
  -- Step 7 - Get system level information necessary for
  -- validation and generation of distributions
  --------------------------------------------------------------
  debug_info := 'Get system information';
  BEGIN
    SELECT gsob.chart_of_accounts_id, ap.base_currency_code,
           ap.allow_flex_override_flag
      INTO l_chart_of_accounts_id, l_base_currency_code,
           l_allow_po_override
      FROM ap_system_parameters ap, gl_sets_of_books gsob
     WHERE ap.set_of_books_id = gsob.set_of_books_id;

  l_pa_allows_overrides :=
    FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES');

  EXCEPTION
  WHEN no_data_found THEN
    Debug_info := debug_info || ': No GL information was found';
    X_debug_context := current_calling_sequence;
    X_debug_info := debug_info;
    RETURN(FALSE);
  END;


  --------------------------------------------------------------------------
  -- Step 8 - Commence proration to all applicable lines.
  -- Verify per line that we may not divide by 0 (which could happen
  -- if all distributions for a line are of type other than ITEM or
  -- ACCRUAL (IPV and ERV included).  Will divide sql into the 3 rule types.
  --------------------------------------------------------------------------
  debug_info := 'Commence proration';
  BEGIN
    IF (l_rule_type = 'PRORATION') THEN
      t := 0;
      BEGIN
        OPEN applicable_lines_cur;
        LOOP
          FETCH applicable_lines_cur
           INTO l_applicable_line_number,
                l_applicable_line_amount,
                l_sum_dists_applic_line;

          EXIT WHEN applicable_lines_cur%NOTFOUND;

          IF (l_sum_dists_applic_line <> 0) THEN
            l_sum_applic_lines :=
              l_sum_applic_lines + l_applicable_line_amount;
            l_alloc_line_tab(t).invoice_line_number :=
              l_applicable_line_number;
            l_alloc_line_tab(t).amount := l_applicable_line_amount;
            l_alloc_line_tab(t).sum_amount_dists := l_sum_dists_applic_line;
            t := t+1;
          END IF;
        END LOOP;
        CLOSE applicable_lines_cur;

        FOR t IN 0..l_alloc_line_tab.COUNT-1
        LOOP
          l_alloc_line_tab(t).amount :=
             AP_UTILITIES_PKG.Ap_Round_Currency(
               (l_alloc_line_tab(t).amount * l_line_amount) /
                l_sum_applic_lines,
                l_invoice_currency_code);
          IF (ABS(l_alloc_line_tab(t).amount) >= ABS(nvl(l_max_alloc,0)) OR
              t = 0) then
            l_max_alloc := l_alloc_line_tab(t).amount;
            l_max_t := t;
          END IF;
          l_running_total_alloc :=
            nvl(l_running_total_alloc, 0) + l_alloc_line_tab(t).amount;
        END LOOP;

	--Invoice Lines: Distributions
	--Basically for the case when user allocates the charge line
	--to items lines which have no item distributions, this can
	--result in l_alloca_line_tab having no records in the table.

        l_count_applicable_dists := l_alloc_line_tab.COUNT;
        IF (l_count_applicable_dists = 0) THEN
           x_error_code := 'NO_APPLICABLE_DISTS';
           RETURN(FALSE);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          CLOSE applicable_lines_cur;
          X_debug_info := debug_info || ': Error encountered';
          X_debug_context := current_calling_sequence;
          RETURN(FALSE);
      END;

      IF (l_line_amount <> l_running_total_alloc) then
        l_alloc_line_tab(l_max_t).amount :=
            l_alloc_line_tab(l_max_t).amount +
           (l_line_amount - l_running_total_alloc);
      END IF;

    ELSIF (l_rule_type = 'PERCENTAGE') then
      t := 0;
      BEGIN
        OPEN alloc_rule_lines_cur;
        LOOP
          FETCH alloc_rule_lines_cur
           INTO l_alloc_rule_line_number,
                l_alloc_rule_line_percent,
                l_alloc_rule_line_amount,
                l_sum_dists_applic_line;

          EXIT WHEN alloc_rule_lines_cur%NOTFOUND;

          IF (l_sum_dists_applic_line = 0) then
            X_error_code := 'AP_IMPROPER_LINE_IN_ALLOC_RULE';
            CLOSE alloc_rule_lines_cur;
            RETURN(FALSE);
          ELSE
            l_alloc_line_tab(t).invoice_line_number :=
                                       l_alloc_rule_line_number;
            l_alloc_line_tab(t).percentage := l_alloc_rule_line_percent;
            l_alloc_line_tab(t).amount :=
              AP_UTILITIES_PKG.Ap_Round_Currency(
                 (l_line_amount * l_alloc_rule_line_percent) / 100,
                  l_invoice_currency_code);
            l_alloc_line_tab(t).sum_amount_dists := l_sum_dists_applic_line;

            IF (ABS(l_alloc_line_tab(t).amount) >= ABS(nvl(l_max_alloc,0)) OR
                t = 0) THEN
              l_max_alloc := l_alloc_line_tab(t).amount;
              l_max_t := t;
            END IF;
            l_running_total_alloc :=
                 nvl(l_running_total_alloc, 0) + l_alloc_line_tab(t).amount;
            t := t+1;
          END IF;
        END LOOP;
        CLOSE alloc_rule_lines_Cur;

	--Invoice Lines: Distributions
	l_count_applicable_dists := l_alloc_line_tab.COUNT;
        IF (l_count_applicable_dists = 0) THEN
           x_error_code := 'NO_APPLICABLE_DISTS';
           RETURN(FALSE);
        END IF;

        IF (l_line_amount <> l_running_total_alloc) THEN
          l_alloc_line_tab(l_max_t).amount :=
            l_alloc_line_tab(l_max_t).amount +
               (l_line_amount - l_running_total_alloc);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          CLOSE alloc_rule_lines_cur;
          X_debug_info := debug_info || ': Error encountered';
          X_debug_context := current_calling_sequence;
          RETURN(FALSE);
      END;


    ELSE /* rule type is AMOUNT */
      t := 0;
      BEGIN
        OPEN alloc_rule_lines_cur;
        LOOP
          FETCH alloc_rule_lines_cur
           INTO l_alloc_rule_line_number,
                l_alloc_rule_line_percent,
                l_alloc_rule_line_amount,
                l_sum_dists_applic_line;

          EXIT WHEN alloc_rule_lines_cur%NOTFOUND;

          IF (l_sum_dists_applic_line = 0) then
            X_error_code := 'AP_IMPROPER_LINE_IN_ALLOC_RULE';
            CLOSE alloc_rule_lines_cur;
            RETURN(FALSE);
          ELSE
            l_alloc_line_tab(t).invoice_line_number :=
              l_alloc_rule_line_number;
            l_alloc_line_tab(t).amount := l_alloc_rule_line_amount;
            l_alloc_line_tab(t).sum_amount_dists := l_sum_dists_applic_line;
            t := t + 1;
          END IF;
        END LOOP;
        CLOSE alloc_rule_lines_Cur;

	--Invoice Lines: Distributions
	l_count_applicable_dists := l_alloc_line_tab.COUNT;
        IF (l_count_applicable_dists = 0) THEN
           x_error_code := 'NO_APPLICABLE_DISTS';
           RETURN(FALSE);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          CLOSE alloc_rule_lines_cur;
          X_debug_info := debug_info || ': Error encountered';
          X_debug_context := current_calling_sequence;
          RETURN(FALSE);
      END;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      X_debug_info := debug_info || ': Error encountered';
      X_debug_context := current_calling_sequence;
      RETURN(FALSE);
  END;


  --------------------------------------------------------------
  -- Step 9 - Commence proration to all applicable distributions.
  --------------------------------------------------------------
  debug_info := 'Commence proration to distributions';
  BEGIN
    i := 0;
    l_max_base_i := 0;
    l_max_base_alloc := 0;
    l_running_total_base_amt := 0;

    -- Bug 5114543
    l_max_dist_line_num := AP_INVOICE_LINES_PKG.get_max_dist_line_num
					(x_invoice_id, x_line_number) + 1;

    FOR t IN 0..l_alloc_line_tab.COUNT-1 LOOP
      l_running_total_alloc := 0;
      l_max_alloc := 0;
      l_max_i := -1;

      OPEN applicable_dists_cur(l_alloc_line_tab(t).invoice_line_number);
      LOOP
        FETCH applicable_dists_cur
         INTO l_invoice_distribution_id,
              l_po_distribution_id,
              l_rcv_transaction_id,
              l_dist_project_id,
              l_dist_task_id,
	      l_dist_pa_quantity,   -- bug6699834
              l_dist_expenditure_type,
              l_dist_expenditure_org_id,
              l_dist_award_id,
              l_dist_amount,
              l_dist_code_combination_id,
              l_dist_assets_tracking_flag,
              l_dist_asset_book_type_code,
              l_dist_asset_category_id,
              l_dist_description;

        EXIT WHEN applicable_dists_cur%NOTFOUND;

	-- Bug 5114543
        l_dist_tab(i).dist_line_num := l_max_dist_line_num;

        l_dist_tab(i).description := l_line_description;
        l_dist_tab(i).charge_applicable_to_dist := l_invoice_distribution_id;
        l_dist_tab(i).award_id := l_dist_award_id;
	l_dist_tab(i).pa_quantity := l_dist_pa_quantity; -- bug6699834
        l_dist_tab(i).attribute_category := NULL;
        l_dist_tab(i).attribute1 := NULL;
        l_dist_tab(i).attribute2 := NULL;
        l_dist_tab(i).attribute3 := NULL;
        l_dist_tab(i).attribute4 := NULL;
        l_dist_tab(i).attribute5 := NULL;
        l_dist_tab(i).attribute6 := NULL;
        l_dist_tab(i).attribute7 := NULL;
        l_dist_tab(i).attribute8 := NULL;
        l_dist_tab(i).attribute9 := NULL;
        l_dist_tab(i).attribute10 := NULL;
        l_dist_tab(i).attribute11 := NULL;
        l_dist_tab(i).attribute12 := NULL;
        l_dist_tab(i).attribute13 := NULL;
        l_dist_tab(i).attribute14 := NULL;
        l_dist_tab(i).attribute15 := NULL;
        l_dist_tab(i).type_1099   := l_type_1099;
        l_dist_tab(i).income_tax_region := l_income_tax_region;
        l_dist_tab(i).amount:=
          AP_UTILITIES_PKG.Ap_Round_Currency(
            (l_alloc_line_tab(t).amount * l_dist_amount) /
             l_alloc_line_tab(t).sum_amount_dists,
             l_invoice_currency_code);
        l_dist_tab(i).base_amount :=
          AP_UTILITIES_PKG.Ap_Round_Currency(
          NVL(l_dist_tab(i).amount, 0) * l_exchange_rate ,
          l_base_currency_code);
        l_dist_tab(i).rounding_amt := 0;

        -- Get project and account information
        --
        IF (NOT (
                Get_Proj_And_Acc_For_Chrg_Dist(
                 X_invoice_id,
                 l_invoice_date,
                 l_vendor_id,
                 l_invoice_currency_code,
                 l_sob_id,
                 l_chart_of_accounts_id,
                 l_base_currency_code,
                 l_dist_tab(i).amount,
                 l_dist_tab(i).base_amount,
                 l_exchange_rate_type,
                 l_exchange_date,
                 l_exchange_rate,
                 X_line_number,
                 l_open_gl_date,
                 l_open_period_name,
                 l_project_id,
                 l_task_id,
		 l_award_id,
                 l_expenditure_type,
                 l_expenditure_organization_id,
                 l_assets_tracking_flag,
                 l_asset_book_type_code,
                 l_asset_category_id,
                 l_dist_project_id,
                 l_dist_task_id,
		 l_dist_award_id,
                 l_dist_expenditure_type,
                 l_dist_expenditure_org_id,
                 l_dist_assets_tracking_flag,
                 l_dist_asset_book_type_code,
                 l_dist_asset_category_id,
                 l_default_dist_ccid,
                 l_overlay_dist_concat,
                 l_balancing_segment,
                 l_account_segment,
                 l_cost_center_segment,
                 l_dist_code_combination_id,
                 l_po_distribution_id,
                 l_rcv_transaction_id,
                 l_pa_allows_overrides,
                 l_allow_po_override,
                 l_dist_tab(i).project_id,
                 l_dist_tab(i).task_id,
                 l_dist_tab(i).award_id,
                 l_dist_tab(i).expenditure_type,
                 l_dist_tab(i).expenditure_organization_id,
                 l_dist_tab(i).expenditure_item_date,
                 l_dist_tab(i).pa_addition_flag,
                 l_dist_tab(i).dist_ccid,
                 l_dist_tab(i).assets_tracking_flag,
                 l_dist_tab(i).asset_book_type_code,
                 l_dist_tab(i).asset_category_id,
                 l_error_code,
                 l_msg_application,
                 l_msg_data,
                 l_default_dist_ccid --bug 5386396
            ))) THEN

          CLOSE applicable_dists_cur;

          IF (l_error_code is not null) then
            X_error_code := l_error_code;
            RETURN(FALSE);
          ELSIF (l_msg_data is not null) then
            X_msg_application := l_msg_application;
            X_msg_data := l_msg_data;
            RETURN(FALSE);
          ELSE
            X_debug_info := debug_info
                            ||': Error encountered while reading account info';
            X_debug_context := current_calling_sequence;
            RETURN(FALSE);
          END IF;
        END IF;

       -- l_dist_tab(i).assets_tracking_flag :=
        IF (l_dist_tab(i).assets_tracking_flag = 'Y') THEN
          l_dist_tab(i).asset_book_type_code := l_asset_book_type_code;
          l_dist_tab(i).asset_category_id := l_asset_category_id;
        END IF;

        IF (l_max_i = -1 OR ABS(nvl(l_max_alloc, 0)) <=
             ABS(l_dist_tab(i).amount)) then
          l_max_i := i;
          l_max_alloc := l_dist_tab(i).amount;
        END IF;
        IF (i = 0 OR ABS(nvl(l_max_base_alloc, 0)) <=
             ABS(l_dist_tab(i).base_amount)) THEN
          l_max_base_i := i;
          l_max_base_alloc := l_dist_tab(i).base_amount;
        END IF;
        l_running_total_alloc := nvl(l_running_total_alloc, 0) +
                                 l_dist_tab(i).amount;
        l_running_total_base_amt := nvl(l_running_total_base_amt, 0) +
                                    l_dist_tab(i).base_amount;

        i := i+1;

	-- Bug 5114543
	l_max_dist_line_num := l_max_dist_line_num +1;

      END LOOP; -- Loop through distributions within line

      CLOSE applicable_dists_cur;

      if (l_alloc_line_tab(t).amount <> l_running_total_alloc) then
        l_dist_tab(l_max_i).amount :=
            l_dist_tab(l_max_i).amount + (l_alloc_line_tab(t).amount -
                                             l_running_total_alloc);
        l_running_total_base_amt := l_running_total_base_amt -
                                      l_dist_tab(l_max_I).base_amount;
        l_dist_tab(l_max_i).base_amount :=
          AP_UTILITIES_PKG.Ap_Round_Currency(
            NVL(l_dist_tab(l_max_i).amount, 0) * l_exchange_rate ,
            l_base_currency_code);
        l_running_total_base_amt := l_running_total_base_amt +
                                    l_dist_tab(l_max_i).base_amount;
      end if;
      if (ABS(nvl(l_max_base_alloc, 0)) <=
          ABS(l_dist_tab(l_max_i).base_amount)) then
        l_max_base_i := l_max_i;
        l_max_base_alloc := l_dist_tab(l_max_i).base_amount;
      end if;

    END LOOP;  -- Loop through lines

    if (l_running_total_base_amt <> l_line_base_amount) then
      l_dist_tab(l_max_base_i).rounding_amt := l_line_base_amount -
                                                l_running_total_base_amt;
      l_dist_tab(l_max_base_i).base_amount :=
        l_dist_tab(l_max_base_i).base_amount + l_line_base_amount -
            l_running_total_base_amt;
    end if;

  END;

  ----------------------------------------------------------------------------
  -- Step 10 - Set distribution class value (Permanent or Candidate)
  ----------------------------------------------------------------------------
  if (X_Generate_Permanent = 'N') then
    l_distribution_class := 'CANDIDATE';
  else
    l_distribution_class := 'PERMANENT';
  end if;

   --bug 9169915
   SELECT JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null)
     INTO l_country_code
     FROM DUAL;
   --bug 9169915

  ----------------------------------------------------------------------------
  -- Step 11 - Generate distributions
  ----------------------------------------------------------------------------

  FOR i in nvl(l_dist_tab.FIRST, 0) .. nvl(l_dist_tab.LAST, -1)  LOOP

     SELECT ap_invoice_distributions_s.nextval INTO l_inv_dist_id FROM DUAL;

     INSERT INTO ap_invoice_distributions(
              batch_id,
              invoice_id,
              invoice_line_number,
              invoice_distribution_id,
              distribution_line_number,
              line_type_lookup_code,
              distribution_class,
              description,
              dist_match_type,
              org_id,
              dist_code_combination_id,
              accounting_date,
              period_name,
              accrual_posted_flag,
              cash_posted_flag,
              amount_to_post,
              base_amount_to_post,
              posted_amount,
              posted_base_amount,
              posted_flag,
              accounting_event_id,
              upgrade_posted_amt,
              upgrade_base_posted_amt,
              set_of_books_id,
              amount,
              base_amount,
              rounding_amt,
              quantity_variance,
              base_quantity_variance,
              match_status_flag,
              encumbered_flag,
              packet_id,
              reversal_flag,
              parent_reversal_id,
              cancellation_flag,
              income_tax_region,
              type_1099,
              stat_amount,
              charge_applicable_to_dist_id,
              prepay_amount_remaining,
              prepay_distribution_id,
              parent_invoice_id,
              corrected_invoice_dist_id,
              corrected_quantity,
              other_invoice_id,
              po_distribution_id,
              rcv_transaction_id,
              unit_price,
              matched_uom_lookup_code,
              quantity_invoiced,
              final_match_flag,
              related_id,
              assets_addition_flag,
              assets_tracking_flag,
              asset_book_type_code,
              asset_category_id,
              project_id,
              task_id,
              expenditure_type,
              expenditure_item_date,
              expenditure_organization_id,
              pa_quantity,
              pa_addition_flag,
              award_id,
              gms_burdenable_raw_cost,
              awt_flag,
              awt_group_id,
              awt_tax_rate_id,
              awt_gross_amount,
              awt_invoice_id,
              awt_origin_group_id,
              awt_invoice_payment_id,
              awt_withheld_amt,
              inventory_transfer_status,
              reference_1,
              reference_2,
              receipt_verified_flag,
              receipt_required_flag,
              receipt_missing_flag,
              justification,
              expense_group,
              start_expense_date,
              end_expense_date,
              receipt_currency_code,
              receipt_conversion_rate,
              receipt_currency_amount,
              daily_amount,
              web_parameter_id,
              adjustment_reason,
              merchant_document_number,
              merchant_name,
              merchant_reference,
              merchant_tax_reg_number,
              merchant_taxpayer_id,
              country_of_supply,
              credit_card_trx_id,
              company_prepaid_invoice_id,
              cc_reversal_flag,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              global_attribute_category,
              global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              program_application_id,
              program_id,
              program_update_date,
              request_id,
	      --ETAX: Invwkb
	      intended_use,
	      --Freight and Special Charges
	      rcv_charge_addition_flag,
	---7022001
	pay_awt_group_id)
    SELECT    l_batch_id,                       -- batch_id
              X_invoice_id,                     -- invoice_id
              X_line_number,                    -- invoice_line_number
              l_inv_dist_id,           		-- invoice_distribution_id
              l_dist_tab(i).dist_line_num,      -- distribution_line_number
              l_line_type_lookup_code,          -- line_type_lookup_code
              l_distribution_class,             -- distribution_class
              l_dist_tab(i).description,        -- description
              'NOT_MATCHED',                    -- dist_match_type
              l_org_id,                         -- l_org_id
              l_dist_tab(i).dist_ccid,          -- dist_code_combination_id
              l_open_gl_date,                   -- accounting_date
              l_open_period_name,               -- period_name
              'N',                              -- accrual_posted_flag
              'N',                              -- cash_posted_flag
              NULL,                             -- amount_to_post
              NULL,                             -- base_amount_to_post
              NULL,                             -- posted_amount
              NULL,                             -- posted_base_amount
              'N',                              -- posted_flag
              NULL,                             -- accounting_event_id
              NULL,                             -- upgrade_posted_amt
              NULL,                             -- upgrade_base_posted_amt
              l_sob_id,                         -- set_of_books_id
              l_dist_tab(i).amount,             -- amount
              l_dist_tab(i).base_amount,        -- base_amount
              l_dist_tab(i).rounding_amt,       -- rounding_amt
              NULL,                             -- quantity_variance
              NULL,                             -- base_quantity_variance
	      --Invoice Lines: Distributions, changed match_status_flag
	      --to NULL from 'N'.
              NULL,                             -- match_status_flag
              'N',                              -- encumbered_flag
              NULL,                             -- packet_id
              'N',                              -- reversal_flag
              NULL,                             -- parent_reversal_id
              'N',                              -- cancellation_flag
              decode(l_type_1099,null,null,l_income_tax_region),
                                                -- income_tax_region
              l_type_1099,                      -- type_1099
              NULL,                             -- stat_amount
              l_dist_tab(i).charge_applicable_to_dist, -- charge_applicable_to_dist_id
              NULL,                             -- prepay_amount_remaining
              NULL,                             -- prepay_distribution_id
              NULL,                             -- parent_invoice_id
              NULL,                             -- corrected_inv_dist_id
              NULL,                             -- corrected_quantity
              NULL,                             -- other_invoice_id
              NULL,                             -- po_distribution_id
              NULL,                             -- rcv_transaction_id
              NULL,                             -- unit_price
              NULL,                             -- matched_uom_lookup_code
              NULL,                             -- quantity_invoiced
              NULL,                             -- final_match_flag
              NULL,                             -- related_id
              'U',                              -- assets_addition_flag
              l_dist_tab(i).assets_tracking_flag,   -- assets_tracking_flag
              l_dist_tab(i).asset_book_type_code,   -- asset_book_type_code
              l_dist_tab(i).asset_category_id,  -- asset_category_id
              l_dist_tab(i).project_id,         -- project_id
              l_dist_tab(i).task_id,            -- task_id
              l_dist_tab(i).expenditure_type,   -- expenditure_type
              l_dist_tab(i).expenditure_item_date,  -- expenditure_item_date
              l_dist_tab(i).expenditure_organization_id,  -- expenditure_organization_id
/* commented for Bug fix 6699834. added below line as replacement                             NULL,                             -- pa_quantity  */
              l_dist_tab(i).pa_quantity,        -- pa_quantity  -- bug6699834
              l_dist_tab(i).pa_addition_flag,   -- pa_addition_flag
              NULL,                             -- award_id
              NULL,                             -- gms_burdenable_raw_cost
              NULL,                             -- awt_flag
              l_awt_group_id,                   -- awt_group_id
              NULL,                             -- awt_tax_rate_id
              NULL,                             -- awt_gross_amount
              NULL,                             -- awt_invoice_id
              NULL,                             -- awt_origin_group_id
              NULL,                             -- awt_invoice_payment_id
              NULL,                             -- awt_withheld_amt
              'N',                              -- inventory_transfer_status
              l_reference_1,                    -- NULL   --reference_1 --Bug9296445
              l_reference_2,                    -- NULL   --reference_2 --Bug9296445
              NULL,                             -- receipt_verified_flag
              NULL,                             -- receipt_required_flag
              NULL,                             -- receipt_missing_flag
              NULL,                             -- justification
              NULL,                             -- expense_group
              NULL,                             -- start_expense_date
              NULL,                             -- end_expense_date
              NULL,                             -- receipt_currency_code
              NULL,                             -- receipt_conversion_rate
              NULL,                             -- receipt_currency_amount
              NULL,                             -- daily_amount
              NULL,                             -- web_parameter_id
              NULL,                             -- adjustment_reason
              NULL,                             -- merchant_document_number
              NULL,                             -- merchant_name
              NULL,                             -- merchant_reference
              NULL,                             -- merchant_tax_reg_number
              NULL,                             -- merchant_taxpayer_id
              NULL,                             -- country_of_supply
              NULL,                             -- credit_card_trx_id
              NULL,                             -- company_prepaid_invoice_id
              NULL,                             -- cc_reversal_flag
              NULL,                             -- attribute_category
              NULL,                             -- attribute1
              NULL,                             -- attribute2
              NULL,                             -- attribute3
              NULL,                             -- attribute4
              NULL,                             -- attribute5
              NULL,                             -- attribute6
              NULL,                             -- attribute7
              NULL,                             -- attribute8
              NULL,                             -- attribute9
              NULL,                             -- attribute10
              NULL,                             -- attribute11
              NULL,                             -- attribute12
              NULL,                             -- attribute13
              NULL,                             -- attribute14
              NULL,                             -- attribute15
              NULL,                             -- global_attribute_category
              NULL,                             -- global_attribute1
              NULL,                             -- global_attribute2
	      --bugfix:4674194
	      decode(AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_OPTION,
	             'Y',ail1.ship_to_location_id,''), --global_attribute3
              NULL,                             -- global_attribute4
              NULL,                             -- global_attribute5
              NULL,                             -- global_attribute6
              NULL,                             -- global_attribute7
              NULL,                             -- global_attribute8
              NULL,                             -- global_attribute9
              NULL,                             -- global_attribute10
              NULL,                             -- global_attribute11
              NULL,                             -- global_attribute12
              NULL,                             -- global_attribute13
              NULL,                             -- global_attribute14
              NULL,                             -- global_attribute15
              NULL,                             -- global_attribute16
              NULL,                             -- global_attribute17
              NULL,                             -- global_attribute18
              NULL,                             -- global_attribute19
              NULL,                             -- global_attribute20
              l_created_by,                     -- created_by
              sysdate,                          -- creation_date
              0,                                -- last_updated_by
              sysdate,                          -- last_update_date
              l_last_update_login,              -- last_update_login
              NULL,                             -- program_application_id
              NULL,                             -- program_id
              NULL,                             -- program_update_date
              NULL,                             -- request_id
	      --ETAX: Invwkb
	      ail.primary_intended_use,		-- intended_use
	      'N',				-- rcv_charge_addition_flag
	 l_pay_awt_group_id                   -- pay_awt_group_id 7022001
         FROM ap_invoice_lines AIL, --Charge line
	      ap_invoice_lines AIL1, --ITEM Line
	      ap_invoice_distributions aid
         WHERE ail.invoice_id = X_invoice_id
         AND ail.line_number = X_line_number
	 AND aid.invoice_id = ail.invoice_id
	 AND aid.invoice_distribution_id = l_dist_tab(i).charge_applicable_to_dist
	 AND ail1.invoice_id = ail.invoice_id
	 AND ail1.line_number = aid.invoice_line_number;

	 --bug 9169915 bug9737142
	 IF l_country_code IN ('AR','CO') THEN
   	   JL_ZZ_AP_AWT_DEFAULT_PKG.SUPP_WH_DEF (X_invoice_id,
	                                         X_line_number,
						 l_inv_dist_id,
						 NULL);
         END IF;
	 --bug 9169915


	 GMS_AP_API.CREATE_AWARD_DISTRIBUTIONS
			( p_invoice_id		     => X_invoice_id,
			  p_distribution_line_number => l_dist_tab(i).dist_line_num,
			  p_invoice_distribution_id  => l_inv_dist_id,
			  p_award_id		     => l_dist_tab(i).award_id,
			  p_mode		     => 'AP',
			  p_dist_set_id		     => NULL,
			  p_dist_set_line_number     => NULL);


  END LOOP;


----------------------------------------------------------------------------
  -- Step 12 - Update generate distributions flag in invoice line if generating
  -- permanent distributions.
  ----------------------------------------------------------------------------
  debug_info := 'Setting generate distributions flag to Done';
  if (l_distribution_class = 'PERMANENT') then

    -- Bug 5114543
    -- generate_dists on the charge line should be set to 'Done'
    -- when the line amount equals the distributions total.

    BEGIN
      UPDATE AP_INVOICE_LINES
         SET GENERATE_DISTS = 'D'
       WHERE invoice_id = X_invoice_id
         AND line_number = X_line_number
	 AND amount = (select sum(amount)
			 from ap_invoice_distributions
			where invoice_id = x_invoice_id
			  and invoice_line_number = x_line_number);
    EXCEPTION
      WHEN OTHERS THEN
         X_debug_info := debug_info || ': Error encountered';
         X_debug_context := current_calling_sequence;
         return (FALSE);
    END;
  end if;

  ----------------------------------------------------------------------------
  -- Step 13 - Update status of allocation rule type if the distributions were
  -- generated in permanent mode.
  ----------------------------------------------------------------------------
  debug_info := 'Setting status of allocation rule to Executed';
  if (l_distribution_class = 'PERMANENT') then

    -- Bug 5114543
    -- allocation rule status should be set to 'Executed' when the associated
    -- charge line amount equals its distributions total.

    BEGIN
      UPDATE AP_ALLOCATION_RULES
         SET STATUS = 'EXECUTED'
       WHERE invoice_id = X_invoice_id
         AND chrg_invoice_line_number = X_line_number
	 AND exists
		(select 'Line Amount Equals Distribution Total'
		 from   ap_invoice_lines_all ail,
			ap_invoice_distributions_all aid
		 where  ail.invoice_id  = aid.invoice_id
		 and	ail.line_number = aid.invoice_line_number
		 and	ail.invoice_id  = X_invoice_id
		 and	ail.line_number = X_line_number
		 group by ail.line_number, ail.amount
		 having ail.amount = sum(aid.amount));

    EXCEPTION
      WHEN OTHERS THEN
         X_debug_info := debug_info || ': Error encountered';
         X_debug_context := current_calling_sequence;
         RETURN (FALSE);
    END;
  END IF;

  RETURN(TRUE);

  EXCEPTION
     WHEN OTHERS THEN
       X_debug_info := debug_info || 'Error encountered';
       X_debug_context := current_calling_sequence;
       X_error_code := sqlerrm;
       return (FALSE);

END insert_charge_from_alloc;

  -----------------------------------------------------------------------
  -- FUNCTION get_total_dist_amount returns the total of the original
  -- ITEM or ACCRUAL distribution when the same has been split into
  -- ITEM/ACCRUAL, IPV and ERV.  It may also be called in Price
  -- Corrections where there was no original ITEM/ACCRUAL. It returns
  -- NULL if an error is found.
  -----------------------------------------------------------------------
  FUNCTION Get_Total_Dist_Amount(
         X_invoice_distribution_id IN       NUMBER) RETURN NUMBER
  IS

  l_original_amount    AP_INVOICE_DISTRIBUTIONS.AMOUNT%TYPE := 0;

  BEGIN

    SELECT sum(nvl(AID.amount,0))
      INTO l_original_amount
      FROM ap_invoice_distributions_all  AID
     WHERE AID.invoice_distribution_id = X_invoice_distribution_id
        OR AID.related_id = X_invoice_distribution_id;


    RETURN(l_original_amount);

EXCEPTION
  WHEN no_data_found THEN
    RETURN(l_original_amount) ;
  WHEN OTHERS THEN
    RETURN(l_original_amount);

END get_total_dist_amount;


 -----------------------------------------------------------------------
  -- Function get_dist_line_num returns the distribution line
  -- number of invoice distributions belonging to P_invoice_dist_id
  -----------------------------------------------------------------------
  FUNCTION GET_DIST_LINE_NUM(
          X_invoice_dist_id      IN NUMBER)
  RETURN NUMBER
  IS
      l_dist_line_num number := 0;
  BEGIN

    SELECT nvl(distribution_line_number,0)
      INTO l_dist_line_num
      FROM ap_invoice_distributions
     WHERE invoice_distribution_id = X_invoice_dist_id;

    RETURN(l_dist_line_num);

  END GET_DIST_LINE_NUM;


  -----------------------------------------------------------------------
  -- Function get_inv_line_num returns the invoice line
  -- number of invoice distribution belonging to P_invoice_dist_id
  -----------------------------------------------------------------------
  FUNCTION GET_INV_LINE_NUM(
          X_invoice_dist_id      IN NUMBER )
  RETURN NUMBER
  IS
      l_inv_line_num number := 0;
  BEGIN

    SELECT nvl(invoice_line_number,0)
      INTO l_inv_line_num
      FROM ap_invoice_distributions
     WHERE invoice_distribution_id = X_invoice_dist_id;

    RETURN(l_inv_line_num);

  END GET_INV_LINE_NUM;

  -----------------------------------------------------------------------
  -- Function get_invoice_num returns the parent invoice
  -- number of invoice distribution belonging to P_invoice_dist_id
  -----------------------------------------------------------------------
  FUNCTION GET_INVOICE_NUM(
          X_invoice_dist_id      IN NUMBER )
  RETURN VARCHAR2
  IS
      l_inv_num VARCHAR2(50);
  BEGIN

    SELECT nvl(ai.invoice_num,0)
      INTO l_inv_num
      FROM ap_invoice_distributions aid,
           ap_invoices ai
     WHERE aid.invoice_distribution_id = X_invoice_dist_id
       AND aid.invoice_id = ai.invoice_id;

    RETURN(l_inv_num);

  END GET_INVOICE_NUM;


  -----------------------------------------------------------------------
  -- Function GET_REVERSAL_RELATED_ID returns the ditribution id value
  -- that should populates the related_id column when distribution line
  -- is reversed and invoice line is discarded.
  -----------------------------------------------------------------------
  FUNCTION GET_REVERSAL_RELATED_ID(
          X_related_dist_id    IN  NUMBER )
  RETURN NUMBER
  IS
      l_distribution_id  ap_invoice_distributions.invoice_distribution_id%TYPE;
  BEGIN

    BEGIN
      SELECT invoice_distribution_id
        INTO l_distribution_id
        FROM ap_invoice_distributions
       WHERE parent_reversal_id = X_related_dist_id;
    EXCEPTION
      WHEN no_data_found THEN
        l_distribution_id := null;
      WHEN TOO_MANY_ROWS THEN       -- added for 9590980
        l_distribution_id := null;
    END;

    RETURN(l_distribution_id);

  END GET_REVERSAL_RELATED_ID;


 --Invoice Lines: Distributions
 -----------------------------------------------------------------------
  -- Function GET_REVERSING_DIST_NUM returns the ditribution num value
  -- of the invoice distribution that is reversing the invoice distribution
  --identified by x_invoice_dist_id.
  -----------------------------------------------------------------------
 FUNCTION GET_REVERSING_DIST_NUM(X_Invoice_Dist_Id NUMBER) RETURN NUMBER IS
    l_reversing_dist_num ap_invoice_distributions.distribution_line_number%TYPE;
 BEGIN

   BEGIN
      SELECT distribution_line_number
      INTO l_reversing_dist_num
      FROM ap_invoice_distributions
      WHERE parent_reversal_id = x_invoice_dist_id;

   EXCEPTION WHEN NO_DATA_FOUND THEN
     l_reversing_dist_num := NULL;
     WHEN TOO_MANY_ROWS THEN     -- added for 9590980
      l_reversing_dist_num := null;
   END;

   RETURN(l_reversing_dist_num);

 END GET_REVERSING_DIST_NUM;


/*=============================================================================
 |  PUBLIC PROCEDURE Calculate_Variance
 |
 |  DESCRIPTION
 |   Procedure that calculates the IPV/ERV for an distribution line which
 |   could be ITEM, ACCRUAL, RETROEXPENSE, RETROACCRUAL or IPV type. It
 |   returns TRUE if there is no error or exception. It returns True if no
 |   error.
 |
 |  PARAMETERS
 |    x_distribution_id - Distributions which could be ITEM, ACCRUAL and IPV
 |    x_reporting_ledger_id - reporting set of books id value for MRC
 |    x_distribution_amt - Out parameter as updated value for this dist line
 |    x_dist_base_amt - Out parameter as updated value for this dist line
 |    x_ipv - Out parameter as calculated ipv
 |    x_bipv - Out parameter as calculated base amount for ipv
 |    x_erv - Out parameter as calculated erv in base currency code
 |    x_calling_sequence - calling sequence for debug purpose
 |    x_debug_switch - a control to log debug information
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES
 |
 |  NOTES
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

FUNCTION Calculate_Variance(
             X_DISTRIBUTION_ID      IN            NUMBER,
             X_REPORTING_LEDGER_ID  IN            NUMBER,
             X_DISTRIBUTION_AMT        OUT NOCOPY NUMBER,
             X_DIST_BASE_AMT           OUT NOCOPY NUMBER,
             X_IPV                  IN OUT NOCOPY NUMBER,
             X_BIPV                 IN OUT NOCOPY NUMBER,
             X_ERV                  IN OUT NOCOPY NUMBER,
             X_DEBUG_INFO           IN OUT NOCOPY VARCHAR2,
             X_DEBUG_CONTEXT        IN OUT NOCOPY VARCHAR2,
             X_CALLING_SEQUENCE     IN OUT NOCOPY VARCHAR2) Return Boolean

IS
  l_inv_currency_code        ap_invoices.invoice_currency_code%TYPE;
  l_base_currency_code       ap_system_parameters.base_currency_code%TYPE;
  l_dist_line_type           VARCHAR2(25);
  l_inv_price                ap_invoice_distributions.unit_price%TYPE;
  l_qty_invoiced             NUMBER;
  l_po_qty                   NUMBER;
  l_po_price                 po_line_locations.price_override%TYPE;
  l_po_rate                  NUMBER;
  l_rtxn_rate                NUMBER;
  l_inv_rate                 ap_invoices.exchange_rate%TYPE;
  l_match_option             po_line_locations.match_option%TYPE;
  l_rtxn_uom                 VARCHAR2(25);
  l_rtxn_item_id             rcv_shipment_lines.item_id%TYPE;
  l_po_uom                   po_line_locations.unit_meas_lookup_code%TYPE;
  l_distribution_amt         ap_invoice_distributions.amount%TYPE;
  l_dist_base_amt            ap_invoice_distributions.base_amount%TYPE;
  l_dist_match_type          ap_invoice_distributions.dist_match_type%TYPE;
  l_corrected_inv_dist_id    NUMBER(15);
  l_corrected_qty            NUMBER;
  l_uom_conv_rate            NUMBER;
  l_rate_diff                NUMBER;
  l_price_diff               NUMBER;

  l_original_dist_base_amt   NUMBER;
  l_original_dist_amt        NUMBER;

  l_corrected_inv_rate       ap_invoices.exchange_rate%TYPE;
  current_calling_sequence   VARCHAR2(2000);
  l_debug_info               VARCHAR2(100);

  l_match_basis              po_line_types.matching_basis%TYPE;  -- Amount Based Matching

  cursor invoice_dist_cursor is
  SELECT AI.invoice_currency_code,              -- l_inv_currency_code
         ASP.base_currency_code,                -- l_base_currency_code
         D.line_type_lookup_code,               -- l_dist_line_type
         D.unit_price,                          -- l_inv_price
         nvl(D.quantity_invoiced, 0),           -- l_quantity_invoiced
         nvl(PD.quantity_ordered,0) -
              nvl(PD.quantity_cancelled,0),     -- l_po_qty
         nvl(PLL.price_override, 0),            -- l_po_price
         decode(AI.invoice_currency_code,
                ASP.base_currency_code, 1,
                PD.rate), -- l_po_rate
         decode (AI.invoice_currency_code,
                 ASP.base_currency_code, 1 ,
                 RTXN.currency_conversion_rate),  -- l_rtxn_rate
         nvl(AI.exchange_rate,1),  -- l_inv_rate
         nvl(PLL.match_option, 'P'),            -- l_match_option
         D.matched_uom_lookup_code,             -- l_rtxn_uom
         RSL.item_id,                           -- l_rtxn_item_id
         PL.unit_meas_lookup_code,              -- l_po_uom
         D.amount,                              -- l_distribution_amt
         decode(AI.invoice_currency_code,
                ASP.base_currency_code, nvl(D.amount,0),
                                    nvl(D.base_amount,0)),  -- l_dist_base_amt
         D.dist_match_type,                     -- l_dist_match_type
         D.corrected_invoice_dist_id,           -- l_corrected_invoice_dist_id
         D.corrected_quantity,                  -- l_corrected_quantity
         PLL.matching_basis                     -- l_match_basis /* Amount Based Matching */
  FROM   ap_invoices_all AI,
         ap_system_parameters_all ASP,
         ap_invoice_distributions D,
         po_distributions PD,
         po_lines PL,
         po_line_types PLT,                     -- Amount Based Matching
         po_line_locations PLL,
         rcv_transactions RTXN,
         rcv_shipment_lines RSL
  WHERE  AI.invoice_id = D.invoice_id
    AND  D.invoice_distribution_id = X_distribution_id
    AND  nvl(ASP.org_id, -999) = nvl(AI.org_id,-999)
    AND  nvl(AI.org_id,-999) = nvl(D.org_id,-999)
    AND  D.po_distribution_id = PD.po_distribution_id
    AND  PL.po_header_id = PD.po_header_id
    AND  PL.po_line_id = PD.po_line_id
    AND  PL.line_type_id = PLT.line_type_id     -- Amount Based Matching
    AND  PD.line_location_id = PLL.line_location_id
    AND  D.rcv_transaction_id = RTXN.transaction_id (+)
    AND  RTXN.shipment_line_id = RSL.shipment_line_id (+)
    AND  D.posted_flag in ('N', 'P')
    AND  nvl(D.encumbered_flag, 'N') in ('N', 'H', 'P')
    AND  D.line_type_lookup_code in ( 'ITEM', 'ACCRUAL','IPV', 'RETROEXPENSE',
                                      'RETROACCRUAL');  --Retropricing

  BEGIN

    current_calling_sequence := 'AP_INVOICES_UTILITY_PKG.' ||
                                'CALCULATE_VARIANCE<-'|| X_calling_sequence;

   /*-----------------------------------------------------------------+
    |  Step 0 - Open Cursor to Initialize the all the information     |
    +-----------------------------------------------------------------*/
    l_debug_info := 'CALCULATE_VARIANCE - Fetch cursor invoice_dist_cursor';

    OPEN invoice_dist_cursor;
    FETCH invoice_dist_cursor INTO
                 l_inv_currency_code,
                 l_base_currency_code,
                 l_dist_line_type,
                 l_inv_price,
                 l_qty_invoiced,
                 l_po_qty,
                 l_po_price,
                 l_po_rate,
                 l_rtxn_rate,
                 l_inv_rate,
                 l_match_option,
                 l_rtxn_uom,
                 l_rtxn_item_id,
                 l_po_uom,
                 l_distribution_amt,
                 l_dist_base_amt,
                 l_dist_match_type,
                 l_corrected_inv_dist_id,
                 l_corrected_qty,
                 l_match_basis;

    IF (invoice_dist_cursor%NOTFOUND) THEN
      l_debug_info := 'CALCULATE_VARIANCE - ROW NOTFOUND';
      CLOSE invoice_dist_cursor;
      x_debug_info := l_debug_info;
      x_debug_context := current_calling_sequence;
      return (FALSE);
    END IF;

    CLOSE invoice_dist_cursor;
    l_debug_info := ' CALCULATE_VARIANCE - Close cursor invoice_dist_cursor';

   /*-----------------------------------------------------------------+
    | Amount Based Matching. IPV for l_match_basis = 'QUANTITY' only  |
    +-----------------------------------------------------------------*/

    IF l_match_basis = 'QUANTITY' THEN

       /*-----------------------------------------------------------------+
       | Step 2 - try to assemble the original dist amt and base amt     |
       +-----------------------------------------------------------------*/

        --Commented below and introduced new l_original_dist_base_amt
	--for bug#9252266

         /* l_original_dist_base_amt := l_dist_base_amt + NVL(x_bipv, 0)
                                + NVL(x_erv, 0); */

         l_original_dist_base_amt := AP_UTILITIES_PKG.ap_round_currency(
                                       ((l_distribution_amt+NVL(x_ipv, 0))*l_inv_rate)
                                          ,l_base_currency_code);
         l_original_dist_amt := l_distribution_amt + NVL(x_ipv, 0);


      /*-----------------------------------------------------------------+
       | Step 3 - converte po/rcv uom                                    |
       +-----------------------------------------------------------------*/

       IF (l_match_option = 'R' and l_po_uom <> l_rtxn_uom ) THEN
          l_uom_conv_rate := po_uom_s.po_uom_convert (
                             l_rtxn_uom,
                             l_po_uom,
                             l_rtxn_item_id);

          l_qty_invoiced := l_qty_invoiced * l_uom_conv_rate;
          l_inv_price := l_inv_price / l_uom_conv_rate;
       END IF;

    ELSIF (l_match_basis = 'AMOUNT') THEN

      l_original_dist_base_amt := l_dist_base_amt;
      l_original_dist_amt := l_distribution_amt;

    END IF;  -- End l_match_basis. /* Amount Based Matching  */

   /*-----------------------------------------------------------------+
    | Step 4 - get rate difference  and price diff                    |
    +-----------------------------------------------------------------*/

    If (l_rtxn_rate is null) Then
      l_rate_diff := l_inv_rate - l_po_rate;
    Else
      l_rate_diff := l_inv_rate - l_rtxn_rate;
    end if;

    l_price_diff := l_inv_price - l_po_price;

   /*-----------------------------------------------------------------+
    | Amount Based Matching. For AMOUNT Based mathing calculation of  |
    | ERV is different                                                |
    +-----------------------------------------------------------------*/

    IF l_match_basis = 'QUANTITY' THEN
        /*-----------------------------------------------------------------+
        | Step 5 - calculate erv/ipv                                      |
        +-----------------------------------------------------------------*/
        --Retropricing
       IF  l_dist_match_type  IN ('QTY_CORRECTION', 'PO_PRICE_ADJUSTMENT' ) THEN

          /*-----------------------------------------------------------------+
           | calculate erv/ipv - quantity correction                         |
           +-----------------------------------------------------------------*/

          l_debug_info := ' CALCULATE_VARIANCE - for QTY_CORRECTION';

          IF (l_rate_diff = 0) THEN
            x_erv := 0;
          ELSE
            x_erv := AP_UTILITIES_PKG.ap_round_currency(
                     l_corrected_qty * l_po_price *
                     l_rate_diff
                     ,l_base_currency_code);
          END IF;

          x_ipv := AP_UTILITIES_PKG.ap_round_currency(
                   l_corrected_qty * l_price_diff
                   ,l_inv_currency_code);

          IF (x_ipv = 0) THEN
              x_bipv := 0;
          ELSE
               -- Bug 5484167  base invoice price variance should be calculated directly from the invoice price variance
               --to avoid incorrect rounding logic
               /* x_bipv := AP_UTILITIES_PKG.ap_round_currency(
                            l_corrected_qty * l_inv_rate * l_price_diff
                            , l_base_currency_code);*/
               x_bipv := AP_UTILITIES_PKG.ap_round_currency(x_ipv * l_inv_rate, l_base_currency_code);

          END IF;

       ELSIF ( l_dist_match_type = 'PRICE_CORRECTION' ) THEN

          /*-----------------------------------------------------------------+
          | calculate erv/ipv - price correction                            |
          +-----------------------------------------------------------------*/

          l_debug_info := ' CALCULATE_VARIANCE - for PRICE CORRECTION';

          select nvl(AI.exchange_rate, 1)
          into l_corrected_inv_rate
          from AP_INVOICES AI,
              AP_INVOICE_DISTRIBUTIONS  D
          where D.invoice_distribution_id = l_corrected_inv_dist_id
          and D.invoice_id = AI.invoice_id;

          x_erv := AP_UTILITIES_PKG.ap_round_Currency( l_original_dist_amt *
                  (l_corrected_inv_rate - l_inv_rate)
                  , l_base_currency_code);

          x_ipv  := 0;
          x_bipv := 0;

       ELSE

          /*-----------------------------------------------------------------+
           | calculate erv/ipv - regular quantity base match                 |
           +-----------------------------------------------------------------*/

          l_debug_info := ' CALCULATE_VARIANCE - for regular base match
                          For Quantity Based Matching';

          IF (l_rate_diff = 0) THEN
             x_erv := 0;
          ELSE
             x_erv := AP_UTILITIES_PKG.ap_round_currency(
                         l_qty_invoiced * l_po_price * l_rate_diff
                         ,l_base_currency_code);
          END IF;

          IF (l_price_diff = 0) THEN
             x_ipv := 0;
             x_bipv := 0;
          ELSE
             x_ipv := AP_UTILITIES_PKG.ap_round_currency(
                         l_qty_invoiced * l_price_diff
                         , l_inv_currency_code );

             IF (x_ipv = 0) THEN
                x_bipv := 0;
             ELSE
               -- Bug 5484167  base invoice price variance should be calculated directly from the invoice price variance
               --to avoid incorrect rounding logic
               /* x_bipv := AP_UTILITIES_PKG.ap_round_currency(
                            l_qty_invoiced * l_inv_rate * l_price_diff
                            , l_base_currency_code);*/
               x_bipv := AP_UTILITIES_PKG.ap_round_currency(x_ipv * l_inv_rate, l_base_currency_code);

             END IF;

          END IF; -- end of check l_price_diff

       END IF; -- end of check the l_dist_match_type

    ELSE     -- l_match_basis = 'AMOUNT'. /*Amount Based Matching */

      IF ( l_dist_match_type = 'AMOUNT_CORRECTION' ) THEN

        /*-----------------------------------------------------------------+
        | calculate erv - amount correction                               |
        +-----------------------------------------------------------------*/

        l_debug_info := ' CALCULATE_VARIANCE - for AMOUNT CORRECTION';

        select nvl(AI.exchange_rate, 1)
        into l_corrected_inv_rate
        from AP_INVOICES AI,
             AP_INVOICE_DISTRIBUTIONS  D
        where D.invoice_distribution_id = l_corrected_inv_dist_id
        and D.invoice_id = AI.invoice_id;

        x_erv := AP_UTILITIES_PKG.ap_round_Currency( l_original_dist_amt *
                  (l_corrected_inv_rate - l_inv_rate)
                  , l_base_currency_code);

        x_ipv  := 0;
        x_bipv := 0;

      ELSE

        /*-----------------------------------------------------------------+
        | calculate erv - regular amount base match                       |
        +-----------------------------------------------------------------*/

        l_debug_info := ' CALCULATE_VARIANCE - for regular base match for
                          AMOUNT Based Matching';

        IF (l_rate_diff = 0) THEN
          x_erv := 0;
        ELSE
          x_erv := AP_UTILITIES_PKG.ap_round_currency(
                     l_original_dist_amt * l_rate_diff
                    ,l_base_currency_code);
        END IF;

        x_ipv := 0;
        x_bipv := 0;

      END IF;

    END IF;  -- END l_match_basis. /* Amount Based Matching */

   /*-----------------------------------------------------------------+
    | Step 6 - Prepare the out parameter                              |
    +-----------------------------------------------------------------*/
    IF ( x_erv <> 0 or x_ipv <> 0 or x_bipv <> 0 ) THEN
      l_debug_info := 'CALCULATE_VARIANCE - variance exists';
      X_DISTRIBUTION_AMT := l_original_dist_amt - X_IPV;
      X_DIST_BASE_AMT := l_original_dist_base_amt - X_ERV - X_BIPV;
      x_debug_info := l_debug_info;
      x_debug_context := current_calling_sequence;
    ELSE
      X_DISTRIBUTION_AMT := l_original_dist_amt;
      X_DIST_BASE_AMT := l_original_dist_base_amt;
    END IF;


    RETURN ( TRUE );

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'distribution Id = '
               || X_distribution_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      END IF;

      l_debug_info := 'CALCULATE_VARIANCE - OTHERS exception exists';
      x_debug_info := l_debug_info;
      x_debug_context := current_calling_sequence;
      RETURN ( FALSE);

END CALCULATE_VARIANCE;


/*============================================================================= |  Public FUNCTION Dist_Refer_Active_Corr
|
|      Check if the invoice distribution is been referred by a
|      active correction
|
|  PROGRAM FLOW
|
|       return TRUE  - if distribution is been referred by any correction
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date         Author               Description of Change
|  01/28/04     Surekha Myadam       Created
 *============================================================================*/

FUNCTION Dist_Refer_Active_Corr(
		P_Invoice_Dist_ID  IN NUMBER,
	        P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN IS
 dummy number := 0;
 current_calling_sequence   Varchar2(2000);
 debug_info                 Varchar2(100);
BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_DISTRIBUTIONS_PKG.DIST_REFER_ACTIVE_CORR<-'
                      ||p_Calling_Sequence;

    debug_info := 'Select from ap_invoice_distributions_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_distributions_all AID
    Where  NVL(AID.cancellation_flag, 'N' ) <> 'Y'
    And NVL( AID.reversal_flag, 'N' ) <> 'Y'
    And AID.corrected_invoice_dist_id = p_invoice_dist_id
    And rownum < 2;   --bug 5034678

    If (dummy >= 1) Then
      return  TRUE;
    End if;

    return FALSE;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Distribution Id = '||P_Invoice_Dist_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;


END Dist_Refer_Active_Corr;

/*=============================================================================
|  Public FUNCTION Chrg_Refer_Active_Dist
|
|      Check if this charge distribution is been allocated to  a
|      active invoice distribution
|
|  PROGRAM FLOW
|
|       return TRUE  - if distribution is been referred by any correction
|       return FALSE - otherwise.
|
|  MODIFICATION HISTORY
|  Date         Author               Description of Change
|  01/28/04     Surekha Myadam       Created
*============================================================================*/

FUNCTION Chrg_Refer_Active_Dist(
		P_Invoice_Dist_Id  IN NUMBER,
		P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN IS

 dummy number := 0;
 dummy_self number := 0; --bug9542963
 current_calling_sequence   Varchar2(2000);
 debug_info                 Varchar2(100);

BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_DISTRIBUTIONS_PKG.CHRG_REFER_ACTIVE_DIST<-'
                      ||p_Calling_Sequence;

    debug_info := 'Select from ap_invoice_distributions_all';

    Select count(*)
    Into   dummy
    From   ap_invoice_distributions_all AID
    Where  AID.charge_applicable_to_dist_id =  p_invoice_dist_id
    And    NVL(AID.cancellation_flag, 'N')  <> 'Y'
    And    NVL(AID.reversal_flag, 'N')      <> 'Y';

    --bug9542963
    Select count(*)
    Into   dummy_self
    From   ap_self_assessed_tax_dist_all AID
    Where  AID.charge_applicable_to_dist_id =  p_invoice_dist_id
    And    NVL(AID.cancellation_flag, 'N')  <> 'Y'
    And    NVL(AID.reversal_flag, 'N')      <> 'Y';

    If (dummy >= 1 or dummy_self >= 1 ) Then
      return  TRUE;
    End if;

    return FALSE;



Exception
 WHEN OTHERS THEN
  If (SQLCODE <> -20001) Then
   FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
   FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Distribution Id = '||P_Invoice_Dist_Id);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
  End If;
  APP_EXCEPTION.RAISE_EXCEPTION;
END Chrg_Refer_Active_Dist;

/*=============================================================================
|
|      Check if the invoice distribution is been referred by a
|      active correction. Wrapper API to be used from Java layer.
|      Introduced as part of bug 9374412.
|
|  PROGRAM FLOW
|
|       return 1  - if distribution is been referred by any correction
|       return 0  - otherwise.
|
|  MODIFICATION HISTORY
|  Date         Author               Description of Change
|  06/03/10     Pramod Podhiyath     Created
 *============================================================================*/

FUNCTION Dist_Refer_Active_Corr_Wrap(
		P_Invoice_Dist_ID  IN NUMBER,
	        P_Calling_Sequence IN VARCHAR2) RETURN NUMBER IS
 result_bool boolean := false ;
 result_num number := 0;
 current_calling_sequence   Varchar2(2000);
 debug_info                 Varchar2(1000);
BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_DISTRIBUTIONS_PKG.DIST_REFER_ACTIVE_CORR<-'
                      ||p_Calling_Sequence;

    debug_info := 'Inside wapper API Dist_Refer_Active_Corr_Wrap, ' ||
                  'invoked from NegotiationAMImpl.handleDistributionDeleteAction';

    result_bool := Dist_Refer_Active_Corr(P_Invoice_Dist_ID,
                                         P_Calling_Sequence) ;

    debug_info := 'Inside wapper API Dist_Refer_Active_Corr_Wrap, ' ||
                  'invoked from NegotiationAMImpl.handleDistributionDeleteAction';

    IF (result_bool) THEN
       result_num := 1 ;
    ELSE
       result_num := 0 ;
    END IF ;

    return result_num;

  Exception
    WHEN OTHERS THEN
      If (SQLCODE <> -20001) Then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Distribution Id = '||P_Invoice_Dist_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      End If;
      APP_EXCEPTION.RAISE_EXCEPTION;

END Dist_Refer_Active_Corr_Wrap;

/*=============================================================================
|  Public FUNCTION Chrg_Refer_Active_Dist_Wrap
|
|      Check if this charge distribution is been allocated to  a
|      active invoice distribution. Wrapper API to be used from Java layer.
|      Introduced as part of bug 9374412.
|
|  PROGRAM FLOW
|
|       return 1  - if distribution is been referred by any correction
|       return 0  - otherwise.
|
|  MODIFICATION HISTORY
|  Date         Author               Description of Change
|  06/03/10     Pramod Podhiyath     Created
*============================================================================*/

FUNCTION Chrg_Refer_Active_Dist_Wrap(
		P_Invoice_Dist_Id  IN NUMBER,
		P_Calling_Sequence IN VARCHAR2) RETURN NUMBER IS

 result_bool boolean := false ;
 result_num number := 0;
 current_calling_sequence   Varchar2(2000);
 debug_info                 Varchar2(1000);

BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_INVOICE_DISTRIBUTIONS_PKG.CHRG_REFER_ACTIVE_DIST<-'
                      ||p_Calling_Sequence;

    debug_info := 'Inside wapper API Chrg_Refer_Active_Dist_Wrap, ' ||
                  'invoked from NegotiationAMImpl.handleDistributionDeleteAction';

    result_bool := Chrg_Refer_Active_Dist(P_Invoice_Dist_Id,
                                          P_Calling_Sequence) ;

    IF (result_bool) THEN
       result_num := 1 ;
    ELSE
       result_num := 0 ;
    END IF ;

    return result_num;

Exception
 WHEN OTHERS THEN
  If (SQLCODE <> -20001) Then
   FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
   FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Distribution Id = '||P_Invoice_Dist_Id);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
  End If;
  APP_EXCEPTION.RAISE_EXCEPTION;
END Chrg_Refer_Active_Dist_Wrap;

PROCEDURE Make_Distributions_Permanent
                 (P_Invoice_Id IN NUMBER,
                  P_Invoice_Line_Number IN NUMBER DEFAULT NULL,
                  P_Calling_Sequence IN VARCHAR2) IS

TYPE INVOICE_LINE_NUMBER_LIST IS TABLE OF ap_invoice_lines.line_number%TYPE;
l_line_number_tab 	 INVOICE_LINE_NUMBER_LIST;
l_debug_info 		 VARCHAR2(2000);
current_calling_sequence VARCHAR2(2000);
l_line_number		NUMBER;
global_exception        EXCEPTION;

BEGIN

 current_calling_sequence := 'Ap_Invoice_Distributions_Pkg.Make_Distributions_Permanent<-  '
				||p_calling_sequence;

 l_debug_info := 'Updating ap_invoice_distributions';

 UPDATE ap_invoice_distributions_all
 SET distribution_class = 'PERMANENT'
 WHERE invoice_id = p_invoice_id
 AND   invoice_line_number = NVL(p_invoice_line_number, invoice_line_number)
 AND distribution_class = 'CANDIDATE'
 RETURNING invoice_line_number BULK COLLECT INTO l_line_number_tab;

 l_debug_info := 'Updating ap_self_assessed_tax_dist';

 UPDATE ap_self_assessed_tax_dist_all
 SET distribution_class = 'PERMANENT'
 WHERE invoice_id = p_invoice_id
 AND   invoice_line_number = NVL(p_invoice_line_number, invoice_line_number)
 AND distribution_class = 'CANDIDATE';

 l_debug_info := 'Updating ap_invoice_lines';

 FOR uniq_values IN 1 .. l_line_number_tab.count LOOP

   l_line_number := l_line_number_tab(uniq_values);

   UPDATE ap_invoice_lines_all ail
   SET generate_dists = 'D'
   WHERE nvl(ail.generate_dists,'N') = 'Y'
   AND invoice_id = p_invoice_id
   AND ail.line_number = l_line_number_tab(uniq_values);

   --Commented below condition for the bug 7483192
   /*AND ail.amount = (SELECT SUM(NVL(aid.amount,0))
  	             FROM ap_invoice_distributions_all aid
		     WHERE aid.invoice_id = ail.invoice_id
		     AND aid.invoice_line_number = ail.line_number
		     AND aid.distribution_class = 'PERMANENT'); */

   UPDATE AP_ALLOCATION_RULES ALR
   SET STATUS  = 'EXECUTED'
   WHERE alr.invoice_id = p_invoice_id
   AND alr.chrg_invoice_line_number = l_line_number_tab(uniq_values)
   AND EXISTS (SELECT 'Valid charge line'
               FROM ap_invoice_lines ail
               WHERE ail.invoice_id = p_invoice_id  --bug 5052657
               AND ail.line_number = alr.chrg_invoice_line_number
               AND nvl(ail.generate_dists,'N') = 'D'
               AND ail.line_type_lookup_code IN ('FREIGHT','MISCELLANEOUS'));

   --Bug:4674229
   DECLARE
      l_awt_success   Varchar2(1000);
   BEGIN
      Ap_Extended_Withholding_Pkg.Ap_Ext_Withholding_Default
               (p_invoice_id => p_invoice_id,
                p_inv_line_num => l_line_number_tab(uniq_values),
		p_inv_dist_id  => NULL,
                p_calling_module => current_calling_sequence,
		p_parent_dist_id => NULL,
                p_awt_success => l_awt_success);
      IF (l_awt_success <> 'SUCCESS') THEN
        RAISE Global_Exception;
      END IF;
   END;

 END LOOP;

EXCEPTION
 WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
   FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
   FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Id = '||P_Invoice_Id);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
  END IF;
  APP_EXCEPTION.RAISE_EXCEPTION;

END Make_Distributions_Permanent;

/*=============================================================================
|  Public FUNCTION Chrg_Refer_Active_Dist
|
|  This procedure will get the sum of total charge amount allocated
|  to a particular invoice distribution.
|
|  PROGRAM FLOW
|
|       return   - 0 if no charges are allocated to this distribution.
|		 - returns the sum of charge distributions that are
|		   allocated to this distribution.
|
|  MODIFICATION HISTORY
|  Date         Author               Description of Change
|  02/23/04     Surekha Myadam       Created
*============================================================================*/

Function Associated_Charges(P_Invoice_Id	      IN NUMBER,
			    P_Invoice_Distribution_Id IN NUMBER)
							RETURN NUMBER IS

l_total_charge_amount	  NUMBER := 0;
l_debug_info		  VARCHAR2(200);

BEGIN

  l_debug_info := 'Get total charge amount allocated to this distribution';

  SELECT sum(aid.amount)
  INTO l_total_charge_amount
  FROM ap_invoice_distributions aid
  WHERE aid.invoice_id = p_invoice_id
  AND aid.charge_applicable_to_dist_id = p_invoice_distribution_id;

  RETURN(l_total_charge_amount);

EXCEPTION
 WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
   FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
   FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice Distribution Id = '
					||P_Invoice_Distribution_Id);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
  END IF;
  APP_EXCEPTION.RAISE_EXCEPTION;

END Associated_Charges;


END AP_INVOICE_DISTRIBUTIONS_PKG;

/
