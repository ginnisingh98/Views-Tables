--------------------------------------------------------
--  DDL for Package Body IBY_TRXN_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TRXN_DOCUMENTS_PKG" AS
/* $Header: ibytxdcb.pls 120.7.12000000.3 2007/09/05 16:08:21 visundar ship $ */


  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_TRXN_DOCUMENTS_PKG';

  /* Gets the trxnmid based on (transaction id,trxntype id,status) */
  PROCEDURE getTrxnMID
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	trxnmid_out	OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE
	)
  IS
        CURSOR c_trxnmid
        (
        ci_transactionid iby_trxn_summaries_all.transactionid%TYPE,
        ci_trxntypeid    iby_trxn_summaries_all.trxntypeid%TYPE,
        ci_status        iby_trxn_summaries_all.status%TYPE
        )
        IS
          SELECT trxnmid INTO trxnmid_out
          FROM iby_trxn_summaries_all
          WHERE (transactionid=ci_transactionid)
            AND (status=ci_status)
            AND ((trxntypeid=NVL(ci_trxntypeid,trxntypeid)) OR (trxntypeid is NULL))
          ORDER BY creation_date DESC;
  BEGIN
        IF (c_trxnmid%ISOPEN) THEN
          CLOSE c_trxnmid;
        END IF;

        OPEN c_trxnmid(transactionid_in,trxntypeid_in,status_in);
        FETCH c_trxnmid INTO trxnmid_out;

        CLOSE c_trxnmid;
  EXCEPTION

	WHEN no_data_found THEN
	  raise_application_error(-20000, 'IBY_20534#ID='||transactionid_in||'#TYPE='||trxntypeid_in||'#STATUS='||status_in, FALSE);

	WHEN too_many_rows THEN
	  raise_application_error(-20000, 'IBY_20535#ID='||transactionid_in||'#TYPE='||trxntypeid_in||'#STATUS='||status_in, FALSE);

  END getTrxnMID;


   /*------*/
  /* Gets the trxnmid based on (transaction id,trxntype id) */
  PROCEDURE getTrxnMIDFinancing
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	trxnmid_out	OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE
	)
  IS
  BEGIN

	SELECT trxnmid INTO trxnmid_out
	FROM iby_trxn_summaries_all
	WHERE (transactionid=transactionid_in) AND (trxntypeid=trxntypeid_in);

  EXCEPTION

	WHEN no_data_found THEN
          trxnmid_out := -1;

	WHEN too_many_rows THEN
	  raise_application_error(-20000, 'IBY_20535#ID='||transactionid_in||'#TYPE='||trxntypeid_in, FALSE);

  END getTrxnMIDFinancing;
   /*------*/


  /* Add an empty document based on the master trxn id of a trxn. */
  PROCEDURE CreateDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	)
  IS

  l_docid    iby_trxn_documents.trxn_document_id%TYPE;

  BEGIN
      CreateDocument(trxnmid_in, doctype_in, l_docid);
  END CreateDocument;


  /*
   * Add an empty document based on master transaction id of a
   * transaction and return the generated document id.
   */
  PROCEDURE CreateDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	docid_out	OUT NOCOPY iby_trxn_documents.trxn_document_id%TYPE
	)
  IS

  trxn_document_id_seq      NUMBER;

  BEGIN
    SELECT iby_trxn_documentid_s.NEXTVAL INTO trxn_document_id_seq FROM dual;

        docid_out := trxn_document_id_seq;

	-- CHANGE: CATCH EXCEPTION FOR DOC UNIQUENESS CONSTRAINTS
	-- explicitly catch the exception and return an specific
        -- IBY_XXXX error code?
	--
	INSERT INTO iby_trxn_documents (trxnmid,doctype,document,object_version_number,last_update_date,last_updated_by,creation_date,created_by,last_update_login,trxn_document_id, payment_instruction_id)
	-- object version number is 0 as the document is empty
	--
	VALUES (trxnmid_in,doctype_in,empty_clob(),0,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id,trxn_document_id_seq, NULL);
	COMMIT;
  END CreateDocument;

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
	)
  IS

  trxn_document_id_seq      NUMBER;

  BEGIN
    SELECT iby_trxn_documentid_s.NEXTVAL INTO trxn_document_id_seq FROM dual;

    docid_out := trxn_document_id_seq;
BEGIN
	INSERT INTO iby_trxn_documents (trxnmid,doctype,document,object_version_number,
   last_update_date,last_updated_by,creation_date,created_by,last_update_login,
   trxn_document_id, payment_instruction_id)
	-- object version number is 0 as the document is empty
	--
        -- work around for the unique key trxnmid/doctype
        -- FZ 8/28/2005. This should not be a problem
        -- for funds capture code as the doctype (100)
        -- is for R12 disbursement only
	VALUES (p_payment_instruction_id,p_doctype,p_doc,1,
   sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id,
   trxn_document_id_seq, p_payment_instruction_id);
EXCEPTION
   when DUP_VAL_ON_INDEX then null;
END;
  END CreateDocument;



  /*
   * First check if a document exists for a given (trxnmid, doctype)
   * combination. If it exists, return the existing document id
   * instead of inserting a new row in the table.
   *
   * Used in online financing.
   */
  PROCEDURE CreateOrUpdateDocument
        (
        trxnmid_in      IN      iby_trxn_summaries_all.trxnmid%TYPE,
        doctype_in      IN      iby_trxn_documents.doctype%TYPE,
        docid_out       OUT NOCOPY iby_trxn_documents.trxn_document_id%TYPE
        )

        IS

  l_docid    iby_trxn_documents.trxn_document_id%TYPE;

  cursor c_doc(ci_trxnmid in iby_trxn_summaries_all.trxnmid%type,
               ci_doctype in iby_trxn_documents.doctype%type)
  is
        SELECT trxn_document_id
        FROM iby_trxn_documents
        WHERE trxnmid = ci_trxnmid
        AND doctype = ci_doctype;

  BEGIN

        if (c_doc%isopen) then
           close c_doc;
        end if;

        open c_doc(trxnmid_in, doctype_in);
        fetch c_doc into l_docid;

        docid_out := l_docid;

        --
        -- Insert an empty CLOB in place of the
        -- existing CLOB. This empty CLOB will
        -- be overwitten by a new CLOB later.
        --
        -- If we don't do this, the existing
        -- CLOB gets overwritten by a new CLOB,
        -- but we get XML parse errors.
        --
        UPDATE iby_trxn_documents SET
            document=empty_clob()
        WHERE
            trxnmid = trxnmid_in
            AND doctype = doctype_in;

        if (c_doc%notfound) then
            CreateDocument(trxnmid_in, doctype_in, docid_out);
        end if;

        close c_doc;

  END CreateOrUpdateDocument;


  /* Add an empty document based on (transaction id, trxntype, status) */
  PROCEDURE CreateDocument
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	)
  IS
	l_mtrxnid iby_trxn_summaries_all.trxnmid%TYPE;
  BEGIN
	getTrxnMID(transactionid_in, trxntypeid_in, status_in,l_mtrxnid);
	CreateDocument(l_mtrxnid,doctype_in);
  END CreateDocument;


  /* Delete a document based on the master trxn id of a trxn. */
  PROCEDURE DeleteDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	)
  IS
  BEGIN
	DELETE FROM iby_trxn_documents WHERE (trxnmid=trxnmid_in) AND (doctype=doctype_in);
	COMMIT;
  END DeleteDocument;


  /* Add a document based on (transaction id, trxntype, status) */
  PROCEDURE DeleteDocument
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE
	)
  IS
	l_mtrxnid iby_trxn_summaries_all.trxnmid%TYPE;
  BEGIN
	getTrxnMID(transactionid_in,trxntypeid_in,status_in,l_mtrxnid);
	DeleteDocument(l_mtrxnid,doctype_in);
  END DeleteDocument;


  /* Fetches a document based on (transaction id,trxn type id,status,doctype) */
  PROCEDURE FetchDocument
	(
	transactionid_in IN	iby_trxn_summaries_all.transactionid%TYPE,
	trxntypeid_in	IN	iby_trxn_summaries_all.trxntypeid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	read_only_in	IN	INTEGER,
	document_out	OUT NOCOPY iby_trxn_documents.document%TYPE
	)
  IS
	l_trxnmid	iby_trxn_summaries_all.trxnmid%TYPE;
  BEGIN
	getTrxnMID(transactionid_in,trxntypeid_in,status_in,l_trxnmid);
	FetchDocument(l_trxnmid,doctype_in,read_only_in,document_out);
  END FetchDocument;


  /* Fetch a document based on (trxnmid,doctype) */
  PROCEDURE FetchDocument
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
	doctype_in	IN	iby_trxn_documents.doctype%TYPE,
	read_only_in	IN	INTEGER,
	document_out	OUT NOCOPY iby_trxn_documents.document%TYPE
	)
  IS
  BEGIN
	IF (read_only_in=C_FETCH_READWRITE) THEN
	  -- not read only so we update the last change information
	  --
	  UPDATE iby_trxn_documents
	  SET object_version_number=object_version_number+1, last_update_date=sysdate,last_updated_by=fnd_global.user_id,last_update_login=fnd_global.login_id
	  WHERE (trxnmid=trxnmid_in) AND (doctype=doctype_in);
	  COMMIT;

	  SELECT document INTO document_out
	  FROM iby_trxn_documents
	  WHERE (trxnmid=trxnmid_in) AND (doctype=doctype_in) FOR UPDATE;
	  -- must select as for update it to be able to write to it
	  -- from JDBC
	ELSE
	  SELECT document INTO document_out
	  FROM iby_trxn_documents
	  WHERE (trxnmid=trxnmid_in) AND (doctype=doctype_in);
	END IF;

  EXCEPTION

	WHEN no_data_found THEN
	  raise_application_error(-20000, 'IBY_19005#MID='||trxnmid_in||'#TYPE='||doctype_in, FALSE);

  END FetchDocument;



  PROCEDURE FetchDisbursementDocument
	(
	p_payment_instruction_id	IN	NUMBER,
	p_doctype   	            IN	NUMBER,
	read_only_in	IN	INTEGER DEFAULT C_FETCH_READONLY,
	document_out	OUT NOCOPY iby_trxn_documents.document%TYPE
	)
  IS
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.FetchDisbursementDocument';
      CURSOR l_doc_csr (p_payment_instruction_id IN NUMBER, p_doctype IN NUMBER) IS
  	   SELECT document INTO document_out
        FROM iby_trxn_documents
	    WHERE (payment_instruction_id=p_payment_instruction_id) AND (doctype=p_doctype) and rownum = 1
    ORDER BY trxn_document_id asc;

  BEGIN
    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'input p_payment_instruction_id: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'input p_doctype: ' || p_doctype,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'input read_only_in: ' || read_only_in,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


	IF (read_only_in=C_FETCH_READWRITE) THEN
      -- read write option is not used
      document_out := null;
      /*
	  -- not read only so we update the last change information
	  --
	  UPDATE iby_trxn_documents
	  SET object_version_number=object_version_number+1, last_update_date=sysdate,last_updated_by=fnd_global.user_id,last_update_login=fnd_global.login_id
	  WHERE (payment_instruction_id=p_payment_instruction_id) AND (doctype=p_doctype);
	  COMMIT;

	  SELECT document INTO document_out
	  FROM iby_trxn_documents
	  WHERE (payment_instruction_id=p_payment_instruction_id) AND (doctype=p_doctype) FOR UPDATE;
	  -- must select as for update it to be able to write to it
	  -- from JDBC
      */
	ELSE
      OPEN l_doc_csr(p_payment_instruction_id, p_doctype);
      FETCH l_doc_csr INTO document_out;
      CLOSE l_doc_csr;

	END IF;

	IF document_out IS NOT NULL THEN

    iby_debug_pub.add(debug_msg => 'After fetch, document_out is not null. ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
	ELSE
    iby_debug_pub.add(debug_msg => 'After fetch, document_out is null! ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

	END IF;


  EXCEPTION

	WHEN others THEN
     NULL;
	 -- raise_application_error(-20000, 'IBY_19005#MID='||p_payment_instruction_id||'#TYPE='||p_doctype, FALSE);

  END FetchDisbursementDocument;




END IBY_TRXN_DOCUMENTS_PKG;

/
