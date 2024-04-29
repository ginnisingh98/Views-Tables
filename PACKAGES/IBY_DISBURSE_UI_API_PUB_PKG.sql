--------------------------------------------------------
--  DDL for Package IBY_DISBURSE_UI_API_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DISBURSE_UI_API_PUB_PKG" AUTHID CURRENT_USER AS
/*$Header: ibydapis.pls 120.60.12010000.12 2010/05/20 12:56:36 gmaheswa ship $*/

 /*
  * Table of document ids.
  *
  * Maps to IBY_DOCS_PAYABLE_ALL.DOCUMENT_PAYABLE_ID.
  */
 TYPE docPayIDTab IS TABLE OF NUMBER(15)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of document statuses.
  *
  * Maps to IBY_DOCS_PAYABLE_ALL.DOCUMENT_STATUS.
  */
 TYPE docPayStatusTab IS TABLE OF VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of payment ids.
  *
  * Maps to IBY_PAYMENTS_ALL.PAYMENT_ID.
  */
 TYPE pmtIDTab IS TABLE OF NUMBER(15)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of payment statuses.
  *
  * Maps to IBY_PAYMENTS_ALL.PAYMENT_STATUS.
  */
 TYPE pmtStatusTab IS TABLE OF VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of payment document ids (i.e., paper stocks).
  *
  * Maps to CE_PAYMENT_DOCUMENTS.PAYMENT_DOCUMENT_ID.
  */
 TYPE pmtDocsTab IS TABLE OF NUMBER(15)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of paper document numbers. This table will hold
  * the list of paper document numbers that belong
  * to a particular payment document.
  *
  * Maps to IBY_USED_PAYMENT_DOCS.USED_DOCUMENT_NUMBER.
  */
 TYPE paperDocNumTab IS TABLE OF NUMBER(15)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of paper document use. This table will hold
  * the list of paper document numbers that belong
  * to a particular payment document.
  *
  * Maps to IBY_USED_PAYMENT_DOCS.DOCUMENT_USE.
  */
 TYPE paperDocUseReasonTab IS TABLE OF VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of application short names.
  *
  * Maps to FND_APPLICATION.APPLICATION_SHORT_NAME.
  */
 TYPE appNamesTab IS TABLE OF VARCHAR2(50)
     INDEX BY BINARY_INTEGER;

 /*
  * Table of application ids.
  *
  * Maps to FND_APPLICATION.APPLICATION_ID.
  */
 TYPE appIdsTab IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;


 /*
  * Table of ppr ids.
  *
  * Maps to IBY_PAY_SERVICE_REQUESTS. PAYMENT_SERVICE_REQUEST_ID.
  */
 TYPE pprIdsTab IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------
 | NAME:
 |     payment_stop_request
 |
 |
 | PURPOSE:For Initiating the payment stop process. This procedure should be
 | called only by AP. This should not be called by IBY.
 |
 |
 | PARAMETERS:
 |     IN      p_payment_id      -- payment id
 |             p_requested_by    -- user id
 |             p_request_reason
 |             p_request_reference
 |             p_request_date
 |
 |     OUT     x_return_status
 |             x_msg_count
 |             x_msg_data
 |
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE payment_stop_request (
        p_payment_id		     IN  NUMBER,
        p_requested_by       IN  NUMBER,
        p_request_reason     IN  VARCHAR2,
        p_request_reference  IN  VARCHAR2,
        p_request_date       IN  DATE,
        x_return_status	  OUT nocopy VARCHAR2,
        x_msg_count		    OUT nocopy NUMBER,
        x_msg_data		    OUT nocopy VARCHAR2);



/*--------------------------------------------------------------------
 | NAME:
 |     payment_stop_release
 |
 |
 | PURPOSE:For Releasing the stop request . This procedure should be
 | called only by AP. This should not be called by IBY.
 |
 |
 | PARAMETERS:
 |     IN      p_payment_id      -- payment id
 |             p_released_by     -- user id
 |             p_release_reason
 |             p_release_reference
 |             p_release_date
 |
 |     OUT     x_return_status
 |             x_msg_count
 |             x_msg_data
 |
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE payment_stop_release (
        p_payment_id	     IN  NUMBER,
        p_released_by        IN  NUMBER,
        p_release_reason     IN  VARCHAR2,
        p_release_reference  IN  VARCHAR2,
        p_release_date       IN  DATE,
        x_return_status	     OUT nocopy VARCHAR2,
        x_msg_count	     OUT nocopy NUMBER,
        x_msg_data	     OUT nocopy VARCHAR2);





/*--------------------------------------------------------------------
 | NAME:
 |     remove_document_payable
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE remove_document_payable (
     p_doc_id         IN NUMBER,
     p_doc_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     remove_documents_payable
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE remove_documents_payable (
     p_doc_list         IN docPayIDTab,
     p_doc_status_list  IN docPayStatusTab,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     remove_payment
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE remove_payment (
     p_pmt_id         IN NUMBER,
     p_pmt_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     remove_payments
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE remove_payments (
     p_pmt_list         IN pmtIDTab,
     p_pmt_status_list  IN pmtStatusTab,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     remove_payment_request
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE remove_payment_request (
     p_payreq_id        IN  NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     stop_payment
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE stop_payment (
     p_pmt_id         IN NUMBER,
     p_pmt_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     stop_payments
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE stop_payments (
     p_pmt_list         IN pmtIDTab,
     p_pmt_status_list  IN pmtStatusTab,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     void_payment
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE void_payment (
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_pmt_id         IN NUMBER,
     p_voided_by      IN NUMBER,
     p_void_date      IN DATE,
     p_void_reason    IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     void_pmt_internal
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE void_pmt_internal (
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_pmt_id         IN NUMBER,
     p_voided_by      IN NUMBER,
     p_void_date      IN DATE,
     p_void_reason    IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     is_void_allowed
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE is_void_allowed (
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_pmt_id         IN NUMBER,
     x_return_flag    OUT NOCOPY VARCHAR2,   /* 'Y'/'N' flag */
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     void_pmts_internal
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE void_pmts_internal (
     p_instr_id         IN NUMBER,
     p_voided_by        IN NUMBER,
     p_void_date        IN DATE,
     p_void_reason      IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     validate_paper_doc_number
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE validate_paper_doc_number (
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_payment_doc_id      IN NUMBER,
     x_paper_doc_num       IN OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     show_warn_msgs_flag   IN VARCHAR2 DEFAULT FND_API.G_TRUE
     );


/*--------------------------------------------------------------------
 | NAME:
 |     validate_payment_document
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE validate_payment_document (
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_payment_doc_id      IN NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2
     );



/*--------------------------------------------------------------------
 | NAME:
 |     terminate_pmt_instruction
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE terminate_pmt_instruction (
     p_instr_id       IN NUMBER,
     p_instr_status   IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     terminate_pmt_request
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE terminate_pmt_request (
     p_req_id         IN NUMBER,
     p_req_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     resubmit_pmt_request
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE resubmit_pmt_request (
     p_payreq_id     IN NUMBER,
     x_conc_req_id   IN OUT NOCOPY NUMBER,
     x_error_buf     IN OUT NOCOPY VARCHAR2,
     x_return_status IN OUT NOCOPY NUMBER
     );


/*--------------------------------------------------------------------
 | NAME:
 |     resubmit_instruction
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE resubmit_instruction (
     p_ins_id        IN NUMBER,
     x_conc_req_id   IN OUT NOCOPY NUMBER,
     x_error_buf     IN OUT NOCOPY VARCHAR2,
     x_return_status IN OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     reprint_prenum_pmt_documents
 |
 | PURPOSE:
 |     Reprints the specified set of payment documents (checks) for a
 |     payment instruction. Usually, this method is invoked to reprint
 |     payment documents that were spoiled during the print process
 |     (e.g., printer alignment issues, ink problems etc.)
 |
 |     Because the used payment document numbers need to be recorded,
 |     the caller should provide the list of used payment document
 |     numbers. The caller should also provide the new payment document
 |     numbers to be used in the re-print. These new payment document
 |     numbers will be stamped on the corresponding payments.
 |
 |     This method should only be invoked for reprinting payment documents
 |     that are prenumbered (paper stock type is 'prenumbered'). For
 |     reprinting payment documents that are on blank stock use the method
 |     reprint_blank_pmt_documents().
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE reprint_prenum_pmt_documents(
     p_instr_id          IN NUMBER,
     p_pmt_doc_id        IN NUMBER,
     p_pmt_list          IN pmtIDTab,
     p_new_ppr_docs_list IN pmtDocsTab,
     p_old_ppr_docs_list IN pmtDocsTab,
     p_printer_name      IN VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     reprint_blank_pmt_documents
 |
 | PURPOSE:
 |     Reprints the specified set of payment documents (checks) for a
 |     payment instruction. Usually, this method is invoked to reprint
 |     payment documents that were spoiled during the print process
 |     (e.g., printer alignment issues, ink problems etc.)
 |
 |     In this case, the used payment document numbers do not need to
 |     be recorded because for blank paper stock, the printer can generate
 |     another check with the same paper document id. Therefore, the
 |     the caller need not provide the list of used payment document
 |     numbers. The caller need not provide the new payment document
 |     numbers to be used in the re-print either because the existing
 |     paper document numbers will be re-used in the reprint .
 |
 |     This method should only be invoked for reprinting payment
 |     documents that are printed on blank paper stock (not for
 |     paper stock type that is 'prenumbered'). For reprinting
 |     payment documents that are on prenumbered stock use the method
 |     reprint_prenum_pmt_documents().
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE reprint_blank_pmt_documents(
     p_instr_id          IN NUMBER,
     p_pmt_list          IN pmtIDTab,
     p_printer_name      IN VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     reprint_payment_instruction
 |
 | PURPOSE:
 |     Reprints all the payment documents associated with a payment
 |     instruction. Usually this API is called when the earlier invoked
 |     print process spoiled all the payment documents linked to the
 |     payment instruction due to a printer problem (e.g., printer
 |     misalinged).
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE reprint_payment_instruction (
     p_instr_id          IN NUMBER,
     p_printer_name      IN VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id         IN NUMBER,
     p_pmt_doc_id       IN NUMBER,
     p_used_docs_list   IN paperDocNumTab,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id         IN NUMBER,
     p_pmt_doc_id       IN NUMBER,
     p_used_docs_list   IN paperDocNumTab,
     p_used_pmts_list   IN paperDocNumTab,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_used_pmts_list     IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_used_pmts_list     IN paperDocNumTab,
     p_skipped_docs_list  IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_instr_print_status
 |
 | PURPOSE:
 |     Records the final print status for all the paper documents that
 |     are part of a payment instruction.
 |
 |     This is an overloaded method. See the other method signature for
 |     complete documentation.
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_instr_print_status(
     p_instr_id       IN NUMBER,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_instr_print_status
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_instr_print_status(
     p_instr_id           IN NUMBER,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_final_print_status
 |
 |
 | PURPOSE:
 |
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_final_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_used_pmts_list     IN paperDocNumTab,
     p_skipped_docs_list  IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     );


 /*--------------------------------------------------------------------
 | NAME:
 |   record_print_status
 |
 | PURPOSE:
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
 |   Internal API, not for public use.
 *---------------------------------------------------------------------*/
 PROCEDURE record_print_status(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN VARCHAR2,
     p_used_pmts_list     IN VARCHAR2,
     p_submit_postive_pay IN VARCHAR2,
     p_skipped_docs_list  IN VARCHAR2 DEFAULT NULL,
     p_arg7  IN VARCHAR2 DEFAULT NULL,
     p_arg8  IN VARCHAR2 DEFAULT NULL, p_arg9  IN VARCHAR2 DEFAULT NULL,
     p_arg10  IN VARCHAR2 DEFAULT NULL, p_arg11  IN VARCHAR2 DEFAULT NULL,
     p_arg12  IN VARCHAR2 DEFAULT NULL, p_arg13  IN VARCHAR2 DEFAULT NULL,
     p_arg14  IN VARCHAR2 DEFAULT NULL, p_arg15  IN VARCHAR2 DEFAULT NULL,
     p_arg16  IN VARCHAR2 DEFAULT NULL, p_arg17  IN VARCHAR2 DEFAULT NULL,
     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     mark_all_pmts_complete
 |
 |
 | PURPOSE:
 |
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
 | NOTES: Overloaded method.
 *---------------------------------------------------------------------*/
 PROCEDURE mark_all_pmts_complete(
     p_instr_id       IN NUMBER,
     x_return_status  OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     mark_all_pmts_complete
 |
 |
 | PURPOSE:
 |
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
 PROCEDURE mark_all_pmts_complete(
     p_instr_id           IN NUMBER,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     transmit_pmt_instruction
 |
 |
 | PURPOSE:
 |
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

PROCEDURE transmit_pmt_instruction (
     p_instr_id         IN NUMBER,
     p_trans_status     IN VARCHAR2,
     p_error_code       IN VARCHAR2,
     p_error_msg        IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     construct_callout_pkg_name
 |
 |
 | PURPOSE:
 |
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
 FUNCTION construct_callout_pkg_name (
     p_app_short_name IN VARCHAR2
     ) RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |
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
 PROCEDURE print_debuginfo(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2,
     p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
     )
     ;

/*--------------------------------------------------------------------
 | NAME:  get_message_text
 |
 |
 | PURPOSE:  This function will return the transalated message text
 |           for validation errors stored in iby_transaction_errors
 |           This function should be used from the UI pages.
 |
 | PARAMETERS:
 |     IN  p_transaction_error_id - Transaction error id for the error
 |     IN  p_error_code           - Error code.  This paramester is required
 |                                  so that the function does not hit the
 |                                  iby_transaction_errors table again.
 |
 | RETURNS: translated message_text
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_message_text (p_transaction_error_id IN NUMBER,
                            p_error_code           IN VARCHAR2)
 RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:  get_message_list
 |
 |
 | PURPOSE:  This function will return the transalated message text
 |           for validation errors stored in iby_transaction_errors for an
 |           specific transaction.  This function will return the list of
 |           messages in html format.
 |           This function should be used from the UI pages.
 |
 | PARAMETERS:
 |     IN  p_transaction_id   - Transaction id (instruction, payment or
 |                              document id)
 |     IN  p_transaction_type - Transaction type.
 |                              (PAYMENT, PAYMENT INSTRUCTION, etc.)
 |
 | RETURNS: translated list of messages for a transaction in html format
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_message_list (p_transaction_id   IN NUMBER,
                            p_transaction_type IN VARCHAR2)
 RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     perform_check_print
 |
 | PURPOSE: This procedure calls the IBY_CHECKNUMBER_PUB.performCheckNumbering
 |          procedure to lock the payment document and number the payments
 |
 |
 | PARAMETERS:
 |     IN  p_instruction_id    -  Payment Instruction to print
 |     IN  p_pmt_document_id   -  Payment document id used to print
 |                                payment instruction
 |     IN  p_printer_name      -  Printer defined by the user
 |
 |     OUT x_return_status     -  Return status (S, E, U)
 |     OUT x_return_message    -  This error code will indicate if there
 |                                is any error during the numbering of the
 |                                payment instruction or if the payment
 |                                document cannot be locked.
 |
 | NOTES:  This procedure is only called from the Print UI since it will
 |         number the complete payment instruction.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE perform_check_print(
             p_instruction_id    IN NUMBER,
             p_pmt_document_id   IN NUMBER,
             p_printer_name      IN VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2);

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDocUsed
 |
 |
 | PURPOSE:
 |
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
 FUNCTION checkIfDocUsed(
     p_paper_doc_num     IN NUMBER,
     p_pmt_document_id   IN NUMBER
     ) RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     populatePaymentFunctions
 |
 |
 | PURPOSE:
 |     Populate the payment functions that user has access to
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
 PROCEDURE populatePaymentFunctions(
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2);

/*--------------------------------------------------------------------
 | NAME:
 |     checkUserFunctionAccess
 |
 |
 | PURPOSE:
 |     Check whether the user has access to a particular function
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
FUNCTION checkUserFunctionAccess(p_function_name IN VARCHAR2)
RETURN VARCHAR2;


/*--------------------------------------------------------------------
 | NAME:
 |     checkUserAccess
 |
 |
 | PURPOSE:
 |     Check whether the user has access to all the org. or payment function
 |      of a particular object.
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
 PROCEDURE checkUserAccess(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             x_access_flag       IN OUT NOCOPY VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2);

/*--------------------------------------------------------------------
 | NAME:
 |     insert_conc_request
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insert_conc_request(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             p_conc_request_id   IN NUMBER,
             p_completed_flag    IN VARCHAR2 DEFAULT 'N',
             x_return_status     IN OUT NOCOPY VARCHAR2
             );

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfAllPmtsTerminated
 |
 | PURPOSE:
 |     Checks if all payments of a given payment instruction
 |     have been terminated.
 |
 | PARAMETERS:
 |     IN
 |       p_instr_id   - Payment instruction id to verify.
 |
 |     OUT
 |       NONE
 |
 | RETURNS:
 |       TRUE  - if all payments have been terminated.
 |       FALSE - if at least one non-terminated payment exists.
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfAllPmtsTerminated(
     p_instr_id          IN NUMBER
     ) RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtInInstExists
 |
 | PURPOSE:
 |     Checks if all payments of a given payment instruction
 |     have been terminated.
 |
 | PARAMETERS:
 |     IN
 |       p_payreq_id - Payment request to verify.
 |
 |     OUT
 |       NONE
 |
 | RETURNS:
 |       TRUE  - if at least one payment of the ppr is part of
 |                   an instruction.
 |       FALSE - if none of the payments of the ppr are part of
 |                   an instruction.
 |
 | NOTES:
 |       This method is meant exclusively to be used by the
 |       terminate_pmt_request(..) API. Do not use call this
 |       method for other general purposes.
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtInInstExists(
     p_payreq_id          IN NUMBER
     ) RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     lock_pmt_entity
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE lock_pmt_entity(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             p_conc_request_id   IN NUMBER DEFAULT NULL,
             x_return_status     IN OUT NOCOPY VARCHAR2
             );

/*--------------------------------------------------------------------
 | NAME:
 |     unlock_pmt_entity
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE unlock_pmt_entity(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2
             );

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_electronic_instr
 |
 |
 | PURPOSE:
 |
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_electronic_instr(
             p_instr_id          IN NUMBER,
             x_return_status     IN OUT NOCOPY VARCHAR2
             );

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfInstrXmitOutsideSystem
 |
 |
 | PURPOSE:
 |
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfInstrXmitOutsideSystem(
     p_instr_id          IN NUMBER
     ) RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtEntityLocked
 |
 |
 | PURPOSE:
 |     Checks if a given payment entity is locked (i.e., stamped
 |     with a concurrent request id).
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtEntityLocked(
     p_object_id         IN NUMBER,
     p_object_type       IN VARCHAR2
     ) RETURN BOOLEAN;

 -- Submit the masking request set
 PROCEDURE submit_masking_req_set (
     x_request_id      OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2
 );

 -- Submit the decrypt request set
 PROCEDURE submit_decrypt_req_set (
     x_request_id      OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2
 );

/*--------------------------------------------------------------------
 | NAME:
 |     get_conc_request_status
 |
 | PURPOSE:
 |     Get the concurrent request id status using the FND API.
 |
 | PARAMETERS:
 |     IN     x_request_id
 |
 | RETURNS: x_request_status (ERROR, PENDING)
 |
 | NOTES:
 |     Internal API, not for public use.
 |     This API is used by the FD Dashboard to determine if a request
 |     has terminated with error.
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_conc_request_status (
     x_request_id     IN NUMBER)
 RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     print_completed_pmts
 |
 |
 | PURPOSE:
 |     Prints list of payments marked complete using the provided
 |     completion group id.
 |
 |     This function is used for debugging purposes.
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_completed_pmts(
             p_completion_id          IN NUMBER
             );

/*--------------------------------------------------------------------
 | NAME:
 |     print_completed_docs
 |
 |
 | PURPOSE:
 |     Prints list of documents payable marked complete using the
 |     provided completion group id.
 |
 |     This function is used for debugging purposes.
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_completed_docs(
             p_completion_id          IN NUMBER
             );

/*--------------------------------------------------------------------
 | NAME:
 |     is_security_function_valid
 |
 | PURPOSE:
 |     This API will return Y or N is the security function passed
 |     is assigned to the user.  This function wraps the
 |     FND_FUNCTION.TEST API.
 |
 | PARAMETERS:
 |     IN     x_security_function_name
 |
 | RETURNS: x_function_valid (Y, N)
 |
 | NOTES:
 |     Internal API, not for public use.
 |     This API is used by the taks list page to determine if a user is
 |     available to do the setup for the Shared, FD or FC tasks.
 |
 *---------------------------------------------------------------------*/
 FUNCTION is_security_function_valid(
     x_security_function_name     IN VARCHAR2)
 RETURN VARCHAR2;


 /*--------------------------------------------------------------------
 | NAME:
 |     Rejected_user_acc
 |
 |
 | PURPOSE:
 |     Checks whether the user has access to all the org. or payment function
 |      of rejected or removed entities ( documents or payments) for a
 |      given payment service request.
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
 PROCEDURE Rejected_user_acc(
             p_pay_service_request_id  IN NUMBER,
             x_inaccessible_entities OUT NOCOPY VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2);


/*--------------------------------------------------------------------
 | NAME:
 |     get_vendor_id
 |
 |
 | PURPOSE:
 |     Get the vendor_id from AP tables based on the party_id
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
 PROCEDURE get_vendor_id(
             p_party_id  IN NUMBER,
             x_vendor_id OUT NOCOPY NUMBER);

 /*--------------------------------------------------------------------
 | NAME:
 |     get_default_bank_acct
 |
 |
 | PURPOSE:
 |     Get the default_bank_acct
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
 PROCEDURE get_default_bank_acct(
             currency_code   iby_ext_bank_accounts.currency_code%TYPE,
	     Payee_Party_Id         IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
	     Payee_Party_Site_Id    IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
	     Supplier_Site_Id       IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
	     Payer_Org_Id           IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
	     Payer_Org_Type         IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
	     Payment_Function       IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE,
	     old_ext_bank_acct_id       IBY_EXT_BANK_ACCOUNTS.ext_bank_account_id%TYPE,
	     x_default_bank_acct_id OUT NOCOPY iby_ext_bank_accounts.ext_bank_account_id%TYPE);

Procedure initialize;

 /*--------------------------------------------------------------------
 | NAME:
 |     Get_Pmt_Completion_Point
 |
 |
 | PURPOSE:
 |     Get Payment Completion Point
 |
 | PARAMETERS:
 |     IN
 |        p_instruction_id NUMBER - Payment Instruction ID
 |
 |     OUT
 |        VARCHAR2 - Payment Completion Point (CREATED, FORMATTED, TRANSMITTED, MANUAL)
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
FUNCTION Get_Pmt_Completion_Point (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2;

END IBY_DISBURSE_UI_API_PUB_PKG;


/
