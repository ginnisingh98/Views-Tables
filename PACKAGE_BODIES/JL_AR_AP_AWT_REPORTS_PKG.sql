--------------------------------------------------------
--  DDL for Package Body JL_AR_AP_AWT_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_AP_AWT_REPORTS_PKG" AS
/* $Header: jlarpwrb.pls 120.18.12010000.6 2009/12/08 14:41:12 abuissa ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL NUMBER;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(50) := 'JL.PLSQL.JL_AR_AP_AWT_REPORTS_PKG.';
  -- Logging Infra

PROCEDURE CHECK_RETURN  (v_return BOOLEAN)
IS
        function_error EXCEPTION;
BEGIN
        IF (v_return = FALSE ) THEN
                RAISE function_error;
        END IF;

EXCEPTION

        WHEN function_error THEN
                RAISE;
END CHECK_RETURN;




/**********************************************************************
 *                 FUNCTION JL_AR_AP_VOID_CERTIFICATES                 *
 **********************************************************************/



PROCEDURE JL_AR_AP_VOID_CERTIFICATES(
        p_payment_id            IN     Number,
        P_Calling_Sequence      IN     Varchar2)
IS


-----------VARIABLES-----------
    l_debug_info                Varchar2(300);
    l_awt_success               Varchar2(2000) := 'SUCCESS';
    l_calling_sequence          Varchar2(2000);

    l_checkrun_name             Varchar2(100);
    l_checkrun_id               Number;
    l_check_number              Number;


-- Logging Infra
l_procedure_name  CONSTANT  VARCHAR2(30) := 'JL_AR_AP_VOID_CERTIFICATES';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
-- Logging Infra



-------------------------------
    -- Cursor definition
-------------------------------

   CURSOR c_void_certificates (P_payment_Id  IN Number) IS
   SELECT  payment_instruction_id,
           paper_document_number
    FROM   iby_fd_payments_v
    WHERE  payment_id = p_payment_id;

------------------------------
BEGIN


   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

    -------------------------------
    -- Initializes debug variables
    -------------------------------
    l_calling_sequence := 'JL_AR_AP_AWT_REPORTS_PKG' || '.' ||
                          'JL_AR_AP_VOID_CERTIFICATES<--' || P_Calling_Sequence;
   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameter ';
     l_log_msg :=  l_log_msg||'P_Payment_Id: '||p_payment_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

    OPEN c_void_certificates(P_PAYMENT_ID);
    FETCH c_void_certificates INTO  l_checkrun_id, l_check_number;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg :=  'l_checkrun_id: '||l_checkrun_id;
     l_log_msg :=  l_log_msg||'l_check_number: '||l_check_number;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


     UPDATE     jl_ar_ap_awt_certif
        set     status = 'VOID'
        where   checkrun_id = l_checkrun_id
        and     check_number = l_check_number;

  close  c_void_certificates;

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level


EXCEPTION

    WHEN NO_DATA_FOUND THEN
   --   null;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: No Data Found';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


    WHEN others THEN
        IF (SQLCODE <> -20001) THEN
            Fnd_Message.Set_Name ('JL', 'JL_ZZ_AP_DEBUG');
            Fnd_Message.Set_Token('ERROR', SQLERRM);
            Fnd_Message.Set_Token('CALLING_SEQUENCE', l_calling_sequence);
            Fnd_Message.Set_Token('PARAMETERS',
              ', Check Id= '            || to_char(P_payment_Id));
            Fnd_Message.Set_Token('DEBUG_INFO', l_debug_info);
        END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);
      END IF;


END JL_AR_AP_VOID_CERTIFICATES;



/**********************************************************************
 |                                                                    |
 |                                                                    |
 |                                                                    |
 |                 FUNCTION JL_AR_AP_GEN_CERTIFICATES                 |
 |                                                                    |
 |                                                                    |
 |                                                                    |
 | NOTES                                                              |
 |      This module is called from Wrapper to IBY Callout PMt.        |
 |      The package will insert records into the table                |
 |      JL_AR_AP_AWT_CERTIF. This table is used for create the              |
 |      Withholding Certificates.                                       |
 |      Check runname is the Payment Innstruction  |
 |      Check ID id the payment ID                      |
 |                                                                    |
 **********************************************************************/



FUNCTION JL_AR_AP_GEN_CERTIFICATES(
                p_payment_instruction_id  IN NUMBER,
                p_calling_module         IN VARCHAR2,
                p_errmsg                        IN OUT NOCOPY        VARCHAR2)
RETURN BOOLEAN
IS
-----------VARIABLES-----------
        v_return                        BOOLEAN                ;
        v_total_wh_amount                 NUMBER                ;
        v_total_tba         NUMBER          ;
        v_location_id                        NUMBER(15)        ;
        v_awt_type_code                        VARCHAR2(30)        ;
        v_tax_name                             VARCHAR2(15)        ;
        v_checkrun_name                   VARCHAR2(50)    ;
        v_checkrun_id    NUMBER;

        v_withholding_date                DATE                ;
        v_next_certificate_number        NUMBER                ;
        v_credit_amount                        NUMBER                ;

        v_prev_bank_account_num                VARCHAR2(30)        ;
        v_prev_pay_document_name        VARCHAR2(20)        ;
        v_prev_check_number                NUMBER(15)        ;
        v_prev_payment_identification        NUMBER(15)        ;
        v_prev_payment_type                VARCHAR2(30)        ;
        v_prev_tax_name                        VARCHAR2(15)        ;
        v_prev_vendor_id                NUMBER                ;
        v_prev_awt_type_code            VARCHAR2(30)    ;
        v_prev_checkrun_name            VARCHAR2(50)    ;
        v_prev_withholding_date         DATE                ;
        v_prev_checkrun_id    NUMBER;
      v_prev_legal_entity_id  NUMBER;
      v_prev_payment_instruction_id  NUMBER;
    DEBUG_Var varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
   l_debug_info                Varchar2(300);
--Logging infra
l_procedure_name  CONSTANT VARCHAR2(30) := 'JL_AR_AP_GEN_CERTIFICATES';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
--Logging infra
-----------CURSOR-----------


CURSOR  cur_certificates (p_payment_instruction_id IN NUMBER ) IS
-- RG check run name is similar to payment batch 11i concept
-- The process is for the Payment Batch
        SELECT
            ipmt.process_type payment_type              ,
            ipmt.payment_id        payment_identification,
            aba.bank_account_num   bank_account_num        ,
            nvl(ipmt.paper_document_number,ipmt.payment_reference_number) payment_document_name, --Bug6792997
            nvl(ipmt.paper_document_number,ipmt.payment_reference_number) check_number,  --Bug6792997
            atc.global_attribute4                awt_type_code                ,
            pv.vendor_id                        vendor_id ,
            'ipmt.call_app_pay_service_req_code' checkrun_name,
            ipmt.payment_instruction_id checkrun_id,
            aid.amount                            withholding_amount        ,
            aid.base_amount                        base_withholding_amount        ,
            -- Payment Exchange Rate ER 8648739 Start
            aid.awt_gross_amount*nvl(aip.exchange_rate,1) taxable_base_amount,
            -- Payment Exchange Rate ER 8648739 End
            ipmt.payment_date   withholding_date,
            atc.name                        tax_name,
            docs.legal_entity_id legal_entity_id
        FROM IBY_FD_PAYMENTS_V              ipmt,
             CE_BANK_ACCOUNTS               aba,
             IBY_FD_DOCS_PAYABLE_V          docs,
             AP_TAX_CODES_ALL               atc,
             AP_INVOICE_DISTRIBUTIONS_ALL   aid,
             AP_INVOICE_PAYMENTS_ALL        aip,
             PO_VENDORS                     pv
        WHERE  ipmt.payment_instruction_id  = p_payment_instruction_id
            and  ipmt.process_type ='IMMEDIATE'
            and ( ('GENERATE' = p_calling_module AND ipmt.payment_status ='INSTRUCTION_CREATED') OR
                  ('GENERATE'  = p_calling_module AND ipmt.payment_status ='FORMATTED') OR
                  ('REPRINT' = p_calling_module AND ipmt.payment_status ='READY_TO_REPRINT'))
            and ipmt.payment_id = docs.payment_id
            and aip.invoice_id  =  docs.calling_app_doc_unique_ref2
            -- Payment Exchange Rate ER 8648739 Start
            and aip.invoice_payment_id = docs.calling_app_doc_unique_ref4
            -- Payment Exchange Rate ER 8648739 End
            and ipmt.INTERNAL_BANK_ACCOUNT_ID =  aba.bank_account_id
            and atc.tax_id                    =  aid.withholding_tax_code_id   -- BUG 954106
            and aid.amount                    <> 0
            and aid.line_type_lookup_code     =  'AWT'
            and aid.awt_invoice_payment_id    =  aip.invoice_payment_id
            and aid.invoice_id                =  aip.invoice_id
            and ipmt.payee_party_id           =  pv.party_id
     UNION ALL
     SELECT ipmt.process_type payment_type,
            ipmt.payment_id payment_identification,
            aba.bank_account_num bank_account_num,
        nvl(ipmt.paper_document_number,ipmt.payment_reference_number) payment_document_name, --bug6792997
        nvl(ipmt.paper_document_number,ipmt.payment_reference_number) check_number,  --Bug6792997
            atc.global_attribute4 awt_type_code,
            pv.vendor_id vendor_id,
            'ipmt.call_app_pay_service_req_code' checkrun_name,
            ipmt.payment_instruction_id checkrun_id,
            aid.withholding_amount*(-1)  withholding_amount,
            aid.base_withholding_amount*(-1) base_withholding_amount,
            -- Payment Exchange Rate ER 8648739 Start
            aid.gross_amount * nvl(api.payment_exchange_rate,1) taxable_base_amount,
            -- Payment Exchange Rate ER 8648739 End
            ipmt.payment_date withholding_date,
            atc.name tax_name,
            docs.legal_entity_id legal_entity_id
       FROM iby_fd_payments_v ipmt,
            ce_bank_accounts aba,
            iby_fd_docs_payable_v docs,
            ap_tax_codes_all atc,
            AP_AWT_TEMP_DISTRIBUTIONS_ALL aid,
            ap_selected_invoices_all api,
            po_vendors pv
      WHERE ipmt.payment_instruction_id  = p_payment_instruction_id
        AND ipmt.process_type ='STANDARD'
        AND (('GENERATE' = p_calling_module AND ipmt.payment_status ='INSTRUCTION_CREATED') OR
             ('GENERATE'  = p_calling_module AND ipmt.payment_status ='FORMATTED') OR
             ('REPRINT'  = p_calling_module AND ipmt.payment_status ='READY_TO_REPRINT')) -- Dario
        AND ipmt.payment_id = docs.payment_id
        AND api.invoice_id  = docs.calling_app_doc_unique_ref2
        AND ipmt.internal_bank_account_id = aba.bank_account_id
       --AND atc.tax_id = aid.withholding_tax_code_id -- BUG 954106
       AND atc.name = aid.tax_name
       AND aid.checkrun_name = api.checkrun_name
       AND aid.invoice_id    = api.invoice_id
       AND aid.withholding_amount <> 0
       AND aid.payment_num   = api.payment_num
       AND ipmt.payee_party_id = pv.party_id
	  ORDER BY tax_name,
		vendor_id,
		bank_account_num,
		payment_document_name,
		check_number;

                /* Commented out for bug 1398067 */
--              and pv.global_attribute9        =  'DOMESTIC_ORIGIN'
---             and pv.vendor_id                =  ap.vendor_id;
--              and ap.checkrun_name                =  p_checkrun_name

------------------------------------------------------------------------------------------
FUNCTION INS_INTO_JL_AR_AP_AWT_CERTIF(
        v_next_certificate_number        IN NUMBER        ,
        v_bank_account_num                    IN VARCHAR2        ,
        v_payment_document_name                IN VARCHAR2        ,
        v_check_number                             IN NUMBER        ,
        v_location_id                            IN NUMBER        ,
        v_awt_type_code                            IN VARCHAR2        ,
        v_tax_name                                IN VARCHAR2        ,
        v_vendor_id                                IN NUMBER        ,
        v_checkrun_name                     IN VARCHAR2        ,
        v_withholding_amount                IN NUMBER        ,
      v_taxable_base_amount       IN NUMBER       ,
        v_withholding_date                IN DATE                ,
        v_credit_amount                        IN NUMBER,
        v_checkrun_id IN NUMBER,
      v_legal_entity_id  IN NUMBER ,
      v_payment_instruction_id IN NUMBER)

RETURN BOOLEAN
IS
        v_table_id                NUMBER;
        column_required                EXCEPTION;
        v_column_required        varchar2(50);
        v_org_id                NUMBER(15);

-- Logging Infra
l_procedure_name  CONSTANT  VARCHAR2(30) := 'INS_INTO_JL_AR_AP_AWT_CERTIF';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
-- Logging Infra

BEGIN

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level


                IF        v_next_certificate_number is null THEN
                        v_column_required := 'CERTIFICATE_NUMBER';
                        raise column_required;
                ELSIF
                        v_bank_account_num is null THEN

                        v_column_required := 'BANK_ACCOUNT_NUM';
                        raise column_required;
                ELSIF
                        v_payment_document_name        is null THEN

                        v_column_required := 'PAYMENT_DOCUMENT_NAME';
                        raise column_required;
                ELSIF
                        v_check_number is null THEN

                        v_column_required := 'CHECK_NUMBER';
                        raise column_required;
                ELSIF
                        v_location_id         is null THEN

                        v_column_required := 'LOCATION_ID';
                        raise column_required;
                ELSIF
                        v_withholding_date is null THEN

                        v_column_required := 'AWT_DATE';
                        raise column_required;
                ELSIF
                        v_awt_type_code        is null THEN

                        v_column_required := 'AWT_TYPE_CODE';
                        raise column_required;
                ELSIF
                        v_tax_name is        null THEN

                        v_column_required := 'TAX_NAME';
                        raise column_required;
                ELSIF
                        v_vendor_id        is null THEN

                        v_column_required := 'VENDOR_ID';
                        raise column_required;
--              ELSIF
--                      v_checkrun_name is null THEN
--
--                      v_column_required := 'CHECKRUN_NAME';
--                      raise column_required;
                ELSIF
                        v_withholding_amount is null THEN

                        v_column_required := 'WITHHOLDING_AMOUNT';
                        raise column_required;
                ELSIF
                        v_taxable_base_amount is null THEN

                        v_column_required := 'TAXABLE_BASE_AMOUNT';
                        raise column_required;
                ELSIF
                        v_credit_amount        is null THEN

                        v_column_required := 'CREDIT_AMOUNT';
                        raise column_required;
                END IF;


   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Getting next sequence from jl_ar_ap_awt_certif_s';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


                SELECT         jl_ar_ap_awt_certif_s.nextval
                INTO        v_table_id
                FROM         dual ;

                --Bug 6504015. added code for setting the org-id while insert.
                v_org_id := MO_GLOBAL.get_current_org_id;
        --in certificates we insert now for r12 payment id rather than check id

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'v_org_id: '||v_org_id;
     l_log_msg :=  l_log_msg||'v_table_id: '||v_table_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Inserting into jl_ar_ap_awt_certif_all table ';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


                INSERT INTO jl_ar_ap_awt_certif_all
                                (certificate_id                        ,
                                certificate_number                ,
                                bank_account_num                ,
                                payment_document_name                ,
                                check_number                        ,
                                location_id                        ,
                                awt_date                        ,
                                awt_type_code                        ,
                                tax_name                        ,
                                vendor_id                        ,
                                checkrun_name                        ,
                                credit_amount                        ,
                        taxable_base_amount             ,
                                withholding_amount                ,
                                status                                ,
                                created_by                        ,
                                creation_date                        ,
                                last_updated_by                        ,
                                last_update_date                ,
                                last_update_login                ,
                                request_id                        ,
                                program_application_id                ,
                                program_id                        ,
                                program_update_date        ,
                                checkrun_id,
                        legal_entity_id,
                        payment_instruction_id,
                                                org_id)
                VALUES(
                                v_table_id                        ,
                                v_next_certificate_number        ,
                                v_bank_account_num                ,
                                v_payment_document_name                ,
                                v_check_number                        ,
                                v_location_id                        ,
                                v_withholding_date                ,
                                v_awt_type_code                        ,
                                v_tax_name                        ,
                                v_vendor_id                        ,
                                v_checkrun_name                        ,
                                v_credit_amount                        ,
                        v_taxable_base_amount           ,
                                v_withholding_amount                ,
                                'NOT PRINTED'                        ,
                                fnd_global.user_id                ,
                                SYSDATE                                ,
                                fnd_global.user_id                ,
                                SYSDATE                                ,
                                fnd_global.login_id                ,
                                fnd_global.conc_request_id        ,
                                fnd_global.prog_appl_id                ,
                                fnd_global.conc_program_id        ,
                                SYSDATE,
                                v_checkrun_id,
                        v_legal_entity_id,
                        v_payment_instruction_id,
                                        v_org_id );



   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

                RETURN (TRUE);

EXCEPTION
        WHEN column_required THEN
                p_errmsg := 'Column constraint NOT NULL in the column '
                            ||v_column_required||' - Error in INS_INTO_JL_AR_AP_AWT_CERTIF';

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: '||p_errmsg;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

                RETURN(FALSE);

        WHEN OTHERS THEN
                p_errmsg := SUBSTR(SQLERRM, 1, 100);
                p_errmsg := p_errmsg||' - Error in INS_INTO_JL_AR_AP_AWT_CERTIF';
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: '||p_errmsg;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

                RETURN(FALSE);
END;

------------------------------------------------------------------------------------------

FUNCTION SAME_PAYMENT_TAX_NAME_VENDOR(
        v_prev_bank_account_num         IN      VARCHAR2        ,
        v_prev_pay_document_name         IN      VARCHAR2        ,
        v_prev_check_number                  IN      NUMBER          ,
        v_prev_tax_name                       IN      VARCHAR2        ,
        v_prev_vendor_id                  IN      NUMBER          ,
        v_tax_name                               IN      VARCHAR2        ,
        v_vendor_id                          IN      NUMBER          ,
        v_bank_account_num                 IN      VARCHAR2        ,
        v_pay_document_name                 IN      VARCHAR2        ,
        v_check_number                        IN      NUMBER )


RETURN BOOLEAN
IS

-- Logging Infra
l_procedure_name  CONSTANT  VARCHAR2(30) := 'SAME_PAYMENT_TAX_NAME_VENDOR';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
-- Logging Infra

BEGIN
  -- RG
--    IF        (v_prev_tax_name is null and v_prev_vendor_id is null) then
--        v_prev_tax_name:= v_tax_name;
--          v_prev_vendor_id:=v_vendor_id;
--          v_prev_bank_account_num:=v_bank_account_num;
--          v_prev_pay_document_name:=v_pay_document_name;
--          v_prev_check_number:=v_check_number;
--              RETURN(TRUE) ;
--    else

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'v_tax_name: '||v_tax_name;
     l_log_msg :=  l_log_msg||'v_vendor_id: '||v_vendor_id;
     l_log_msg :=  l_log_msg||'v_bank_account_num: '||v_bank_account_num;
     l_log_msg :=  l_log_msg||'v_pay_document_name: '||v_pay_document_name;
     l_log_msg :=  l_log_msg||'v_check_number: '||v_check_number;
     l_log_msg :=  l_log_msg||'v_prev_tax_name: '||v_prev_tax_name;
     l_log_msg :=  l_log_msg||'v_prev_vendor_id: '||v_prev_vendor_id;
     l_log_msg :=  l_log_msg||'v_prev_bank_account_num: '||v_prev_bank_account_num;
     l_log_msg :=  l_log_msg||'v_prev_pay_document_name: '||v_prev_pay_document_name;
     l_log_msg :=  l_log_msg||'v_prev_check_number: '||v_prev_check_number;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


                IF        (v_tax_name                              = v_prev_tax_name)
                    and        (v_vendor_id                =  v_prev_vendor_id)
                    and (v_bank_account_num                 = v_prev_bank_account_num)
                    and (v_pay_document_name                 = v_prev_pay_document_name)
                    and (v_check_number                 = v_prev_check_number)
                THEN

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'+TRUE+(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

                        RETURN(TRUE) ;
                ELSE

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'+FALSE+(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

                        RETURN(FALSE) ;
                END IF;
--      end if;
END;

------------------------------------------------------------------------------------------

FUNCTION GEN_CERTIFICATE_NUMBER (
        p_awt_type_code                 IN         VARCHAR2,
        p_next_certificate_number        IN OUT NOCOPY        NUMBER)

RETURN BOOLEAN
IS
        max_number         NUMBER ;

-- Logging Infra
l_procedure_name  CONSTANT  VARCHAR2(30) := 'GEN_CERTIFICATE_NUMBER';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
-- Logging Infra

BEGIN


   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level


   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'P_awt_type_code: '||p_awt_type_code;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


                SELECT         jaaac1.certificate_number
                INTO         max_number
                FROM        jl_ar_ap_awt_certif_all jaaac1
                WHERE         jaaac1.awt_type_code = p_awt_type_code
                  AND        jaaac1.certificate_number = (select max(jaaac2.certificate_number)
                                                       from jl_ar_ap_awt_certif_all jaaac2
                                                             where jaaac2.awt_type_code = p_awt_type_code)
                FOR UPDATE;


                IF         max_number IS NULL
                THEN
                        p_next_certificate_number  := 1;
                ELSE
                        p_next_certificate_number  := max_number + 1;
                END IF ;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'P_next_certificate_number = '||p_next_certificate_number;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level


                RETURN (TRUE);

EXCEPTION

        WHEN NO_DATA_FOUND THEN

                p_next_certificate_number  := 1;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: P_next_certificate_number = 1';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

                RETURN (TRUE);

        WHEN OTHERS THEN
                p_errmsg := SUBSTR(SQLERRM, 1, 100);
                p_errmsg := p_errmsg||' - Error in GEN_CERTIFICATE_NUMBER';

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: '||p_errmsg;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;


                RETURN(FALSE);
END;


------------------------------------------------------------------------------------------

FUNCTION  CALCULATE_CREDIT_AMOUNT(
                        v_vendor_id                        IN NUMBER        ,
                        v_awt_type_code                        IN VARCHAR2         ,
                        v_tax_name                        IN VARCHAR2        ,
                        v_payment_identification        IN NUMBER        ,
                        v_payment_type                        IN VARCHAR2        ,
                        v_credit_amount                 IN OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
        v_amount        NUMBER;

-- Logging Infra
l_procedure_name  CONSTANT  VARCHAR2(30) := 'CALCULATE_CREDIT_AMOUNT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
-- Logging Infra

BEGIN

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level


        --- Initialize Variables ---
            v_credit_amount := 0;


   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'v_vendor_id: '||v_vendor_id;
     l_log_msg :=  l_log_msg||'v_awt_type_code: '||v_awt_type_code;
     l_log_msg :=  l_log_msg||'v_tax_name: '||v_tax_name;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


        SELECT         (jlts.calc_wh_amnt - jlts.act_wheld_amnt)
        INTO        v_amount
        FROM         jl_ar_ap_sup_awt_cr_lts jlts,
                ap_tax_codes                atc
        WHERE
                jlts.po_vendor_id         = v_vendor_id
          and        jlts.awt_type_code        = v_awt_type_code
          and         jlts.tax_id                  = atc.tax_id
          and         status                        = 'AA'
--        and         For KI uptake
--              (( v_payment_type = 'BATCH'
--                 and selected_check_id = v_payment_identification ) --this condition is NA but will leave it
--              or ( v_payment_type = 'QUICK'
--                 and check_id = v_payment_identification ))
          and        atc.name                = v_tax_name;

        v_credit_amount        := v_amount;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg :=  'v_credit_amount = '||v_credit_amount;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

        RETURN (TRUE);


EXCEPTION

        WHEN NO_DATA_FOUND THEN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: No data found - returning TRUE ';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

                RETURN (TRUE);

        WHEN OTHERS THEN
                p_errmsg := SUBSTR(SQLERRM, 1, 100);
                p_errmsg := p_errmsg||' - Error in GEN_CERTIFICATE_NUMBER';

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: '||p_errmsg;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

                RETURN(FALSE);
END;

--------------------------------------------------------------------------------
--------------------------------- MAIN CODE ------------------------------------
--------------------------------------------------------------------------------


BEGIN


-- Logging Infra
-- l_procedure_name  := 'JL_AR_AP_GEN_CERTIFICATES';
-- Logging Infra


--- Initialize Variables ---
        v_prev_tax_name                        := NULL        ;
        v_prev_vendor_id                := NULL        ;
        v_total_wh_amount                 := 0        ;
        v_prev_awt_type_code                := NULL        ;
        v_prev_tax_name                        := NULL ;
        v_prev_checkrun_name                   := NULL ;
        v_prev_checkrun_id                := NULL ;
        v_prev_withholding_date                := NULL        ;
        v_prev_bank_account_num                := NULL ;
        v_prev_pay_document_name        := NULL ;
        v_prev_check_number                := 0        ;
        v_prev_payment_type                := NULL        ;
        v_prev_payment_identification        := 0        ;
        v_prev_legal_entity_id        := NULL;
        v_prev_payment_instruction_id :=NULL;

        v_next_certificate_number        := 0        ;
        v_total_wh_amount                 := 0        ;
        v_total_tba                     := 0    ;
--

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level


   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'P_payment_instruction_id:'||p_payment_instruction_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


   IF (p_payment_instruction_id is not null ) THEN

        -- Retrieving LOCATION_ID
           v_location_id := jg_zz_company_info.get_location_id;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg :=  'v_location_id:'||v_location_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

--    l_debug_info := 'Selecting Certificates ...';
--    IF (DEBUG_Var = 'Y') THEN
--       JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_debug_info);
--    END IF;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Selecting Certificates...';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


        FOR  rec_batch IN cur_certificates (p_payment_instruction_id) LOOP

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Selected Certificate Check: '||rec_batch.check_number;
     l_log_msg :=  l_log_msg||' Type: '||rec_batch.awt_type_code;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

--           l_debug_info := 'Selected Certificate Check:' ||
--              to_char(rec_batch.check_number) || ' Type:' || rec_batch.awt_type_code;
             -- Debug Information
--           IF (DEBUG_Var = 'Y') THEN
--              JL_ZZ_AP_EXT_AWT_UTIL.Debug (l_debug_info);
--           END IF;
             -- End Debug

             IF SAME_PAYMENT_TAX_NAME_VENDOR (
                                        v_prev_bank_account_num,
                                        v_prev_pay_document_name,
                                        v_prev_check_number,
                                        v_prev_tax_name,
                                        v_prev_vendor_id,
                                        rec_batch.tax_name,
                                        rec_batch.vendor_id,
                                        rec_batch.bank_account_num,
                                        rec_batch.payment_document_name,
                                        rec_batch.check_number)
             THEN
                IF rec_batch.base_withholding_amount is null
                THEN
                    v_total_wh_amount := v_total_wh_amount +
                                         rec_batch.withholding_amount;
                ELSE
                    v_total_wh_amount := v_total_wh_amount +
                                        rec_batch.base_withholding_amount;
                END IF;
                    v_total_tba := v_total_tba + rec_batch.taxable_base_amount;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'v_total_tba: '||v_total_tba;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level


             ELSE

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'v_prev_tax_name: '||v_prev_tax_name;
     l_log_msg :=  l_log_msg||'v_prev_vendor_id: '||v_prev_vendor_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

               IF (v_prev_tax_name IS NOT NULL)
                 and (v_prev_vendor_id IS NOT NULL)
               THEN
                   v_return := GEN_CERTIFICATE_NUMBER (
                                                v_prev_awt_type_code        ,
                                                v_next_certificate_number) ;

                 --  check_return (v_return);

                   v_return := CALCULATE_CREDIT_AMOUNT(
                                                v_prev_vendor_id                ,
                                                v_prev_awt_type_code                ,
                                                v_prev_tax_name                        ,
                                                v_prev_payment_identification   ,
                                                v_prev_payment_type                ,
                                                v_credit_amount);

                  --  check_return (v_return);

                                v_return := INS_INTO_JL_AR_AP_AWT_CERTIF(
                                                v_next_certificate_number        ,
                                                v_prev_bank_account_num                ,
                                                v_prev_pay_document_name        ,
                                                v_prev_check_number                ,
                                                v_location_id                         ,
                                                v_prev_awt_type_code                ,
                                                v_prev_tax_name                        ,
                                                v_prev_vendor_id                ,
                                                v_prev_checkrun_name        ,
                                                v_total_wh_amount                ,
                                                v_total_tba                     ,
                                                v_prev_withholding_date                ,
                                                v_credit_amount,
                                                v_prev_checkrun_id,
                                                v_prev_legal_entity_id,
                                                v_prev_payment_instruction_id );

                        --        check_return (v_return);

                   END IF;


                        ---Initialize Variables for sum New TAX_NAME and SUPPLIER---


                        v_prev_bank_account_num         := rec_batch.bank_account_num        ;
                        v_prev_pay_document_name         := rec_batch.payment_document_name;
                        v_prev_check_number                 := rec_batch.check_number        ;
                        v_prev_tax_name                        := rec_batch.tax_name                ;
                        v_prev_vendor_id                      := rec_batch.vendor_id                ;
                        v_prev_awt_type_code                := rec_batch.awt_type_code        ;
                        v_prev_tax_name                        := rec_batch.tax_name                ;
                        v_prev_checkrun_name                 := rec_batch.checkrun_name         ;
                        v_prev_withholding_date                 := rec_batch.withholding_date   ;
                        v_total_tba                   := rec_batch.taxable_base_amount;
                        v_prev_payment_type                := rec_batch.payment_type        ;
                        v_prev_payment_identification        := rec_batch.payment_identification;
                        v_prev_checkrun_id            := rec_batch.checkrun_id;
                        v_prev_legal_entity_id        := rec_batch.legal_entity_id;
                        v_prev_payment_instruction_id := p_payment_instruction_id;



   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Parameters ';
     l_log_msg :=  l_log_msg||'rec_batch.base_withholding_amount: '||rec_batch.base_withholding_amount;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

                    IF         rec_batch.base_withholding_amount is null
                    THEN
                                v_total_wh_amount :=  rec_batch.withholding_amount;
                    ELSE
                                v_total_wh_amount :=  rec_batch.base_withholding_amount;
                    END IF;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'v_total_wh_amount = '||v_total_wh_amount;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

                END IF;

        END LOOP;


        --
        -- INSERT THE LAST LINE
        --


   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'Inserting last line... ';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

        IF         (v_prev_tax_name        IS NOT NULL)
           and         (v_prev_vendor_id         IS NOT NULL)
        THEN

                v_return := GEN_CERTIFICATE_NUMBER (
                                        v_prev_awt_type_code        ,
                                        v_next_certificate_number);

                -- check_return (v_return);


                v_return := CALCULATE_CREDIT_AMOUNT(
                                        v_prev_vendor_id                ,
                                        v_prev_awt_type_code                ,
                                        v_prev_tax_name                        ,
                                        v_prev_payment_identification   ,
                                        v_prev_payment_type                ,
                                        v_credit_amount);

                -- check_return (v_return);


                v_return := INS_INTO_JL_AR_AP_AWT_CERTIF(
                                        v_next_certificate_number        ,
                                        v_prev_bank_account_num                ,
                                        v_prev_pay_document_name        ,
                                        v_prev_check_number                ,
                                        v_location_id                        ,
                                        v_prev_awt_type_code                ,
                                        v_prev_tax_name                        ,
                                        v_prev_vendor_id                ,
                                        v_prev_checkrun_name            ,
                                        v_total_wh_amount                ,
                              v_total_tba                     ,
                                        v_prev_withholding_date                ,
                                        v_credit_amount,
                                        v_prev_checkrun_id,
                              v_prev_legal_entity_id,
                              v_prev_payment_instruction_id );

                -- check_return (v_return);

                p_errmsg := ' All the certificates have been generated correctly ';

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'+Certificates generated+(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

          RETURN(TRUE);
        ELSE
                p_errmsg := ' Certificates have not been generated';

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'+Certificates NOT generated+(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

          RETURN(TRUE);
        END IF;

   ELSE
        p_errmsg := ' The parameter is null ';

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'+Parameter is NULL+Return FALSE+(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Procedure level

        RETURN(FALSE);
   END IF;


EXCEPTION
        WHEN NO_DATA_FOUND THEN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: No data found - returning TRUE.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

             RETURN(TRUE);
        WHEN OTHERS THEN
           p_errmsg := SUBSTR(SQLERRM, 1, 100);
           p_errmsg := p_errmsg||' - Package  JL_AR_AP_GEN_CERTIFICATES ';
           -- R12 Cannot have this rollback.
           --rollback;
           -- Debug Information
           -- IF (DEBUG_Var = 'Y') THEN
           --    JL_ZZ_AP_EXT_AWT_UTIL.Debug ('CERTIFICATES ERROR: '||SQLERRM);
           -- END IF;
          -- end debug

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'EXCEPTION: '||p_errmsg;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

          RETURN(FALSE);

END JL_AR_AP_GEN_CERTIFICATES;

END JL_AR_AP_AWT_REPORTS_PKG;

/
