--------------------------------------------------------
--  DDL for Package IBY_EXTENSIBILITY_CALLOUTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EXTENSIBILITY_CALLOUTS_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyextcs.pls 120.0.12010000.2 2009/09/02 17:29:04 bkjain ship $*/

/*--------------------------------------------------------------------
 | NAME:
 |     isCentralBankReportingRequired
 |
 |
 | PURPOSE:
 |     This function can be overriden by customers to implement complex
 |     and country/bank specific central bank reporting requirements. The payment
 |     engine (payment build program) will call this function for each
 |     payments it creates; this function should determine if the central bank
 |     reporting is required for the payment based on factors such as
 |     payment amount limit, payer/payee residency classification, payer/payee
 |     bank account residency classification, transaction currency classification, etc.
 |
 |     This function will be called only when the central bank reporting is enabled
 |     (in the payment process profile setup UI).
 |
 |     The default implementation returns 'X'. This means the reporting condition
 |     would be determined by the conditions entered in the payment process profile
 |     setup UI. Otherwise if the function returns either 'Y' or 'N', it will
 |     override the conditions entered in the UI. 'Y' means central bank reporting
 |     is required for the payment; 'N' means not.
 |
 | PARAMETERS:
 |     IN
 |     p_payment_id: pk of the payment record. Implementor can use this pk to
 |     retrieve all related entities of the payment - i.e., payer/payee, internal
 |     and external bank accounts, etc. to determine if the central bank reporting
 |     is required.
 |
 |     OUT
 |     x_return_status: standard FND API return status.
 |
 | RETURNS:
 |     A flag of 'X', 'Y', 'N' as noted above.
 |
 | NOTES:
 |     For customization
 |
 *---------------------------------------------------------------------*/
 FUNCTION isCentralBankReportingRequired(
     p_payment_id             IN NUMBER,
     x_return_status          OUT NOCOPY VARCHAR2
     ) RETURN VARCHAR2;


/*--------------------------------------------------------------------
 | NAME:
 |     isCentralBankReportingRequired
 |
 |
 | PURPOSE:
 |     This function can be overriden by customers to implement complex
 |     and country/bank specific central bank reporting requirements. The payment
 |     engine (payment build program) will call this function for each
 |     payments it creates; this function should determine if the central bank
 |     reporting is required for the payment based on factors such as
 |     payment amount limit, payer/payee residency classification, payer/payee
 |     bank account residency classification, transaction currency classification, etc.
 |
 |     This function will be called only when the central bank reporting is enabled
 |     (in the payment process profile setup UI).
 |
 |     The default implementation returns 'X'. This means the reporting condition
 |     would be determined by the conditions entered in the payment process profile
 |     setup UI. Otherwise if the function returns either 'Y' or 'N', it will
 |     override the conditions entered in the UI. 'Y' means central bank reporting
 |     is required for the payment; 'N' means not.
 |
 | PARAMETERS:
 |     IN
 |     p_payment_id: pk of the payment record. Implementor can use this pk to
 |     retrieve all related entities of the payment - i.e., payer/payee, internal
 |     and external bank accounts, etc. to determine if the central bank reporting
 |     is required.
 |
 |     IN
 |     p_trx_cbr_index: pmtTable index being passed in the overloaded procedure
 |
 |     OUT
 |     x_return_status: standard FND API return status.
 |
 | RETURNS:
 |     A flag of 'X', 'Y', 'N' as noted above.
 |
 | NOTES:
 |     For customization
 |
 *---------------------------------------------------------------------*/
 FUNCTION isCentralBankReportingRequired(
     p_payment_id             IN NUMBER,
     p_trx_cbr_index	      IN BINARY_INTEGER,
     x_return_status          OUT NOCOPY VARCHAR2
     ) RETURN VARCHAR2;


END IBY_EXTENSIBILITY_CALLOUTS_PUB;


/
