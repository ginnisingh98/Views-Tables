--------------------------------------------------------
--  DDL for Package FND_ATTACHMENT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ATTACHMENT_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: AFAKUTLS.pls 120.1.12010000.5 2020/09/08 15:08:15 ctilley ship $ */


  FUNCTION get_atchmt_exists(l_entity_name VARCHAR2,
                             l_pkey1 VARCHAR2,
                             l_pkey2 VARCHAR2 DEFAULT NULL,
                             l_pkey3 VARCHAR2 DEFAULT NULL,
                             l_pkey4 VARCHAR2 DEFAULT NULL,
                             l_pkey5 VARCHAR2 DEFAULT NULL,
			     l_function_name VARCHAR2 DEFAULT NULL,
			     l_function_type VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_atchmt_exists, WNDS, WNPS);

  FUNCTION get_atchmt_exists_sql(l_entity_name VARCHAR2,
                             l_pkey1 VARCHAR2,
                             l_pkey2 VARCHAR2 DEFAULT NULL,
                             l_pkey3 VARCHAR2 DEFAULT NULL,
                             l_pkey4 VARCHAR2 DEFAULT NULL,
                             l_pkey5 VARCHAR2 DEFAULT NULL,
			     l_sqlstmt VARCHAR2 DEFAULT NULL,
			     l_function_name VARCHAR2 DEFAULT NULL,
			     l_function_type VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


PROCEDURE init_atchmt(l_function_name IN OUT NOCOPY VARCHAR2,
	       attachments_defined_flag OUT NOCOPY BOOLEAN,
		l_function_type IN OUT NOCOPY VARCHAR2);

PROCEDURE init_atchmt(l_function_name IN OUT NOCOPY VARCHAR2,
	       attachments_defined_flag OUT NOCOPY BOOLEAN,
		l_enabled_flag OUT NOCOPY VARCHAR2,
		l_session_context_field OUT NOCOPY VARCHAR2,
		l_function_type OUT NOCOPY VARCHAR2);

PROCEDURE init_form(X_entity_name IN VARCHAR2,
		    X_user_entity_name OUT NOCOPY VARCHAR2,
		    X_doc_type_meaning OUT NOCOPY VARCHAR2);

PROCEDURE init_doc_form(X_category_name IN VARCHAR2 DEFAULT NULL,
			X_category_id OUT NOCOPY NUMBER,
			X_category_desc OUT NOCOPY VARCHAR2,
			X_security_type IN NUMBER DEFAULT NULL,
			X_security_id IN NUMBER DEFAULT NULL,
			X_security_desc OUT NOCOPY VARCHAR2);

FUNCTION get_atchmt_function_name RETURN VARCHAR2;

PROCEDURE update_file_metadata ( X_file_id IN NUMBER DEFAULT NULL );

----------------------------------------------------------------------------
-- MergeAttachments (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   FND_ATTACHMENT_UTIL_PKG.MergeAttachments() has been registered
--   in Party Merge Data Dict.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.
--
procedure MergeAttachments(p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in varchar2,
                        p_to_fk_id in varchar2,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
			p_return_status in out nocopy varchar2);

FUNCTION get_user_function_name(X_function_type IN VARCHAR2,
			        X_application_id IN NUMBER,
				X_function_name IN VARCHAR2)
	RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_user_function_name, WNDS, WNPS, RNPS);


  --  package globals
  function_name VARCHAR2(30) DEFAULT NULL;
  function_type VARCHAR2(1) DEFAULT NULL;

procedure MergeCustAttach (
        req_id        in      NUMBER,
        set_num       in      NUMBER,
        process_mode  in      VARCHAR2);


-- get_attachment_doc_length (PUBLIC)
-- Returns the size of the document specified
--
FUNCTION get_attachment_doc_length(x_document_id IN number)
    RETURN NUMBER;

-- Determine if the url is considered secure
-- Returns:
-- Y - Secure
-- N - Not secure
--
FUNCTION isSecureUrl(x_url IN varchar2)
    RETURN varchar2;

-- Determine if the Web Attachment is allowed
-- Returns:
-- ALLOWED - Allow (no validation or passed)
-- NOT_ALLOWED_INVALID_PROTOCOL - Not allowed due to invalid protocol
-- NOT_ALLOWED_WARN - Not allowed and should warn the user of possibly unsecure URL
-- NOT_ALLOWED_BLOCK - Not allowed and is blocked.  Possibly unsecure URL
--
FUNCTION allow_url_redirect(x_url IN varchar2)
    RETURN varchar2;

-- Determine if the Web Attachment protocol is allowed
-- Returns:
-- Y - Protocol allowed
-- N - Protocol restricted
FUNCTION verify_url_protocol(x_url IN varchar2)
    RETURN varchar2;


END fnd_attachment_util_pkg;

/
