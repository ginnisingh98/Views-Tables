--------------------------------------------------------
--  DDL for Package IBY_VALIDATIONSETS_CALLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_VALIDATIONSETS_CALLS_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyvalcs.pls 120.6.12010000.7 2010/04/06 07:12:43 asarada ship $*/

PROCEDURE CITI_AT_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_AT_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE AT_EFT_INT_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE AT_EFT_INT_PAYER (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE AT_EFT_INT_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_BE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_BE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE BE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE BE_EFT_INT_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE BE_EFT_INT_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_BE_EFT_INT_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE I_BE_EFT_INT_INSTR (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_instruction_id     IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_CH_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_CH_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_CH_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CH_EFT_GEN_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CH_EFT_GEN_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_DE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) ;

PROCEDURE CITI_DE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE DE_EFT_DOM_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) ;

PROCEDURE DE_EFT_DOM_PAYER (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE DE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) ;

PROCEDURE P_DE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE DE_EFT_INT_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) ;

PROCEDURE DE_EFT_INT_PAYER (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE DE_EFT_INT_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) ;

PROCEDURE P_DE_EFT_INT_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

/* Bug 5569624: Added new document level validation set for Denmark */

PROCEDURE DK_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_DK_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_DK_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_DK_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_ES_CHECK_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_ES_CHECK_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_ES_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) ;

PROCEDURE P_CITI_ES_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_ES_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_FI_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_FI_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_FI_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_FR_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_FR_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_FR_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_GR_CHECK_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_GR_CHECK_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_GR_CHECK_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_GR_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_GR_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_GR_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_IE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_IE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_IE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_IT_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_IT_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE JP_EFT_ZENGIN_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE JP_EFT_ZENGIN_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

/*   Bug 5571714: Unique Remittance Identifier (KID code) validation
                  for Norway. */

PROCEDURE NO_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_NO_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_NO_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_NO_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_PL_EFT_MTMS_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_PL_EFT_MTMS_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_PL_EFT_MTMS_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PEKAO_PL_WIRE_TR_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PEKAO_PL_WIRE_TR_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PEKAO_PL_WIRE_TR_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_PEKAO_PL_WIRE_TR_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PEKAO_PL_WIRE_ST_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PEKAO_PL_WIRE_ST_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PEKAO_PL_WIRE_ST_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_PT_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_PT_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_PT_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE PT_CHECK_GEN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_SE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_SE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_SE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE SE_EFT_BANKGIRO_INLAND_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE SE_EFT_BANKGIRO_UTLAND_SI_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE SE_EFT_BANKGIRO_UTLAND_UT_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE SE_EFT_POSTGIRO_INLAND_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE SE_EFT_POSTGIRO_UTLAND_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_GB_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE CITI_GB_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE P_CITI_GB_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE US_NACHA_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE US_NACHA_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

/*--------------------------------------------------------------------
 | NAME:
 |     US_NACHA_PAYEE_ACCOUNT
 |
 | PURPOSE:
 |     In order to make sure that the payee bank account exists
 |     while making the IAT payments.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/

PROCEDURE US_NACHA_PAYEE_ACCOUNT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE I_US_NACHA_INSTR (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_instruction_id     IN IBY_PAY_INSTRUCTIONS_ALL.
                                 payment_instruction_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);


PROCEDURE IS_NOT_NULL (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE IS_NULL (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE VALIDATE_LENGTH (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE DIGITS_ONLY (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE IS_NUMERIC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE IS_STRING (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE IS_NOT_STRING (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE IN_SET (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE NOT_IN_SET (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE START_WITH (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE NOT_START_WITH (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE IS_IN_LOOKUP (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE GREATER_THAN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE GREATER_THAN_EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE LESS_THAN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE LESS_THAN_EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

PROCEDURE NOT_EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

 PROCEDURE performCharacterValidation(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.
                                    validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN IBY_DOCS_PAYABLE_ALL.payment_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER);

 PROCEDURE print_debuginfo(p_module IN VARCHAR2,
     p_debug_text IN VARCHAR2);

  PROCEDURE VALIDATE_PAYEE_BIC(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE VALIDATE_PAYEE_IBAN(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE VALIDATE_BANK_CHARGE_BEARER(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE VALIDATE_PAYER_IBAN(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

 PROCEDURE VALIDATE_PAYER_ADDRESS(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);


/*--------------------------------------------------------------------
 | NAME:
 |     ECE_DOC
 |
 | PURPOSE:
 |     Transactional field validations for E-Commerce gateway format
 |     (EDI validations).
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE ECE_DOC (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     ECE_INTERNAL_BANK
 |
 | PURPOSE:
 |     Internal bank account validations for E-Commerce gateway format.
 |     (EDI validations).
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE ECE_INTERNAL_BANK (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     ECE_PAYEE
 |
 | PURPOSE:
 |     Payee validations for E-Commerce gateway format.
 |     (EDI validations).
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE ECE_PAYEE (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_INT_BANK_ACC_CURR_IN
 |
 | PURPOSE:
 |     Validate whether Internal Bank Account currency exists in the
 |     parameter defined while assigning validation.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE VALIDATE_INT_BANK_ACC_CURR_IN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER
     );


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_DEL_CHN_FORMAT_VALUE
 |
 | PURPOSE:
 |    Validate whether delivery channel format value exists in the
 |    parameter defined while assigning validation.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE VALIDATE_DEL_CHN_FORMAT_VALUE (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_MAX_PAYMENT_AMOUNT
 |
 | PURPOSE:
 |    Validates the payment amount against the maximum limit defined
 |    with parameter while assigning validation.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE VALIDATE_MAX_PAYMENT_AMOUNT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_DOC_PMT_CURR
 |
 | PURPOSE:
 |    Validate whether document payment currency exists in the
 |    parameter defined while assigning validation.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE VALIDATE_DOC_PMT_CURR (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_PAYEE_BRC_COUNTRY_IN
 |
 | PURPOSE:
 |    Validate whether payee branch country exists in the list of
 |    values given with the parameter while assigning validation.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE VALIDATE_PAYEE_BRC_COUNTRY_IN (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_DEL_CHN_NOT_IN
 |
 | PURPOSE:
 |    Validates whether delivery channel format value doesnt exists in
 |    the list of values with the parameter while assigning validation.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE VALIDATE_DEL_CHN_NOT_IN (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_FIN_URI
 |
 | PURPOSE:
 |    Validates the combination of URI and URI check digit for Finland
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
PROCEDURE VALIDATE_FIN_URI (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);


FUNCTION FIN_URI_CHECK_DIGIT_VAL( uri IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
				   uri_check_digit IBY_DOCS_PAYABLE_ALL.URI_CHECK_DIGIT%TYPE)
				   RETURN BOOLEAN;

/*SEPA Credit Transfer 3.3 */

PROCEDURE VALIDATE_PAYER_LEGAL_ENTITY_ID(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

PROCEDURE VALIDATE_INV_LEGAL_ENTITY_ID(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id           IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER);

END IBY_VALIDATIONSETS_CALLS_PUB;

/
