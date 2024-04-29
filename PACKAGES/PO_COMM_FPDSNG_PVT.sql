--------------------------------------------------------
--  DDL for Package PO_COMM_FPDSNG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMM_FPDSNG_PVT" AUTHID CURRENT_USER AS
/* $Header: POXFPDSNGS.pls 120.3 2008/01/08 12:51:20 lgoyal noship $ */

----------------------------------------------------
PROCEDURE SUBMIT_REQUEST(itemtype	IN VARCHAR2,
						itemkey		IN VARCHAR2,
						actid		IN NUMBER,
						funcmode	IN VARCHAR2,
						resultout	OUT NOCOPY VARCHAR2);

----------------------------------------------------
FUNCTION START_PROCESS( p_document_id NUMBER,
						p_release_num NUMBER,
						p_revision_num NUMBER)
RETURN CLOB;

----------------------------------------------------
FUNCTION FPDSNGXMLGEN(	p_document_id NUMBER,
						p_release_num NUMBER,
						p_revision_num NUMBER)
RETURN clob;

----------------------------------------------------
FUNCTION getFPDSNGFileName(	p_document_type varchar2,
							p_orgid number,
							p_document_id varchar2,
							p_revision_num number,
							p_release_num number,
							p_language_code varchar2)
RETURN varchar2;

----------------------------------------------------
PROCEDURE Store_Blob(	p_document_id		IN number,
						p_revision_number	IN number ,
						p_document_type		IN varchar2,
						p_file_name			IN varchar2,
						p_result			IN BLOB,
						p_media_id			OUT NOCOPY number);

----------------------------------------------------
FUNCTION clob_to_blob(p_ClobData IN CLOB )
RETURN BLOB;

----------------------------------------------------
FUNCTION blob_to_clob (p_BlobData IN BLOB)
RETURN CLOB;

----------------------------------------------------
FUNCTION getDocumentId RETURN NUMBER;

----------------------------------------------------
FUNCTION getReleaseId RETURN NUMBER;

----------------------------------------------------
FUNCTION getRevisionNum RETURN NUMBER;

----------------------------------------------------
FUNCTION Replace_Clob_String (
	p_ClobData IN CLOB,
	p_str_to_replace IN VARCHAR2,
	p_replace_with IN VARCHAR2)
RETURN CLOB;

----------------------------------------------------
PROCEDURE Communicate(	p_document_id IN NUMBER,
						p_revision_number IN VARCHAR2,
						p_document_type  IN VARCHAR2,
						p_request_id OUT NOCOPY NUMBER);


END PO_COMM_FPDSNG_PVT;

/
