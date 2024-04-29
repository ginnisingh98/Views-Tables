--------------------------------------------------------
--  DDL for Package IBY_TRXN_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TRXN_DOCUMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibytxdcs.pls 120.4 2005/10/30 05:51:11 appldev noship $ */


  /* FetchDocument constant indicating doc is being accessed read-only. */
  C_FETCH_READONLY CONSTANT INTEGER := 0;
  /* FetchDocument constant indicating doc is being accessed read-write. */
  C_FETCH_READWRITE CONSTANT INTEGER := 1;

  /*
   * USE: Gets trxnmid based on (transaction id,trxntype id,status)
   *
   * ARGS:
   *    1.  transaction id of the trxn
   *    2.  trxn type (2 for auth, 3 for authcapture) of the trxn.
   *    3.  status of the trxn
   *
   * OUTS:
   *    4.  the trxnmid (master id) of the given trxn
   */
  PROCEDURE getTrxnMID
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE DEFAULT 0,
	trxnmid_out	OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE
	);

  /*--------------*/
  PROCEDURE getTrxnMIDFinancing
        (
        transactionid_in IN     iby_trxn_summaries_all.transactionid%TYPE,
        trxntypeid_in   IN      iby_trxn_summaries_all.trxntypeid%TYPE,
        trxnmid_out     OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE
        );
  /*--------------*/

  /*
   * USE: Add an empty document based on the master trxn id of a trxn.
   *
   * ARGS:
   *    1.  the trxnmid (master id) of the given trxn
   *    2.  application-defined document type of the doc to create
   */
  PROCEDURE CreateDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	);

  /*
   * USE: Add an empty document based on the master trxn id of a trxn
   *      and get the document id back.
   * ARGS:
   *    1.  the trxnmid (master id) of the given trxn
   *    2.  application-defined document type of the doc to create
   *
   * OUTS:
   *    3.  the document id (primary key to the table).
   */
  PROCEDURE CreateDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	docid_out       OUT NOCOPY iby_trxn_documents.trxn_document_id%TYPE
	);


  /*
   * USE: Add an empty document based on the master trxn id of a trxn
   *      and get the document id back. If document already exists, do
   *      not throw an error, instead return existing doc id.
   * ARGS:
   *    1.  the trxnmid (master id) of the given trxn
   *    2.  application-defined document type of the doc to create
   *
   * OUTS:
   *    3.  the document id (primary key to the table).
   */
  PROCEDURE CreateOrUpdateDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	docid_out       OUT NOCOPY iby_trxn_documents.trxn_document_id%TYPE
	);

  /*
   * USE: Add an empty document based on (transaction id, trxntype, status).
   *
   * ARGS:
   *    1.  transaction id of the trxn
   *    2.  trxn type (2 for auth, 3 for authcapture) of the trxn.
   *    3.  status of the trxn
   *    4.  application-defined document type of the doc to create
   */
  PROCEDURE CreateDocument
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE DEFAULT 0,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	);

  /*
   * Retro-fit IBY_TRXN_DOCUMENTS for storing R12 FD extract -
   * doctype is 100.
   * TRXNMID is made nullable
   * the doc will be associated with either IBY_TRXN_SUMMARIES_ALL
   * or IBY_PAY_INSTRUCTIONS_ALL depending on the doctype.
   * FZ 3/14/05
   */
  PROCEDURE CreateDocument
	(
	p_payment_instruction_id	IN	NUMBER,
	p_doctype   	            IN	NUMBER,
	p_doc                    IN CLOB,
	docid_out       OUT NOCOPY iby_trxn_documents.trxn_document_id%TYPE
	);

  /*
   * USE: Delete a document based on the master trxn id of a trxn.
   *
   * ARGS:
   *    1.  the trxnmid (master id) of the given trxn
   *    2.  application-defined document type of the doc to delete
   */
  PROCEDURE DeleteDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	);

  /*
   * USE: Delete a document based on based on (transaction id, trxntype, status)
   *
   * ARGS:
   *    1.  transaction id of the trxn
   *    2.  trxn type (2 for auth, 3 for authcapture) of the trxn.
   *    3.  status of the trxn
   *    4.  application-defined document type of the doc to delete
   */
  PROCEDURE DeleteDocument
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE DEFAULT 0,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	);

  /*
   * USE: Fetch a document based on (trxnmid, doctype).
   *
   * ARGS:
   *    1.  the trxnmid (master id) of the given trxn
   *    2.  application-defined document type of the doc to delete
   *    3.  indicates whether the fetch is readonly or not;
   *        if set to constant C_FETCH_READWRITE the document's versioning
   * 	    info will be updated and a SELECT FOR UPDATE statement
   *        will be used to retrieve it.
   * OUTS:
   *    4.   the document, which can be written to/appended.
   */
  PROCEDURE FetchDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	read_only_in	IN	INTEGER DEFAULT C_FETCH_READONLY,
	document_out	OUT NOCOPY iby_trxn_documents.document%TYPE
	);

  /*
   * USE: Over-loaded version of the above fetch method.
   *
   * ARGS:
   *    1.  transaction id of the trxn
   *    2.  trxn type (2 for auth, 3 for authcapture) of the trxn.
   *    3.  status of the trxn
   *    4.  application-defined document type of the doc to delete
   *    5.  indicates whether the fetch is readonly or not;
   *        if set to constant C_FETCH_READWRITE the document's versioning
   * 	    info will be updated and a SELECT FOR UPDATE statement
   *        will be used to retrieve it.
   * OUTS:
   *    6.   the document, which can be written to/appended.
   */
  PROCEDURE FetchDocument
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE DEFAULT 0,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	read_only_in	IN	INTEGER DEFAULT C_FETCH_READONLY,
	document_out	OUT NOCOPY iby_trxn_documents.document%TYPE
	);

  /*
   * USE: Fetch a document based on (payment_instruction_id, doctype)
   * for R12 Disbursement payment instruction
   * frzhang 8/17/2005
   *
   * ARGS:
   *    1.  the payment_instruction_id
   *    2.  application-defined document type of the doc - 100
   *    3.  indicates whether the fetch is readonly or not;
   *        if set to constant C_FETCH_READWRITE the document's versioning
   * 	    info will be updated and a SELECT FOR UPDATE statement
   *        will be used to retrieve it.
   * OUTS:
   *    4.   the document, which can be written to/appended.
   */
  PROCEDURE FetchDisbursementDocument
	(
	p_payment_instruction_id	IN	NUMBER,
	p_doctype   	            IN	NUMBER,
	read_only_in	IN	INTEGER DEFAULT C_FETCH_READONLY,
	document_out	OUT NOCOPY iby_trxn_documents.document%TYPE
	);

END IBY_TRXN_DOCUMENTS_PKG;


/
