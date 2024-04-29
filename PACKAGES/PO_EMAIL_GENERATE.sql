--------------------------------------------------------
--  DDL for Package PO_EMAIL_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_EMAIL_GENERATE" AUTHID CURRENT_USER AS
/* $Header: POXWPAMS.pls 115.9 2002/11/22 22:08:25 sbull noship $ */



procedure generate_header	(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY VARCHAR2,
				 document_type	in out NOCOPY  varchar2);


procedure generate_html		(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY clob,
				 document_type	in out NOCOPY  varchar2);
/*
EMAILPO FPH
changed signature to take item_type_key  instead of document_id parameter - No datatype changes
Format for item_type_key : <itemtype>:<itemkey>
Earlier format for document_id: <DocumentID>:<DocumentTypeCode>
Purpose: We need itemtype and itemkey to retrieve the attributes USER_ID, APPLICATION_ID and RESPONSIBILITY_ID
 		 to set the context so that terms and conditions profile options can be retrieved correctly
		 DocumentID and DocumentTypeCode are unnecessary
Upgrade considerations and implications:
	For any of the existing notifications which would still call this procedure with DocumentID:DocumentTypeCode
	the behaviour will be same as before the fix for retrieving correct profile options as and only site level
	profile options will be retrieved as context will not be set correctly. This is accomplished by handling any
	exceptions that would arise while calling wf_engine.GetItemAttrNumber  due to invalid itemtype and itemkey

Updates:
4/30/2002 by davidng - item_type_key is renamed back to document_id to standardize with common Workflow
standard.
*/
procedure generate_terms  (document_id	  in	 varchar2,
		           display_type	  in 	 varchar2,
                           document	  in out NOCOPY clob,
			   document_type  in out NOCOPY varchar2);


END PO_EMAIL_GENERATE;

 

/
