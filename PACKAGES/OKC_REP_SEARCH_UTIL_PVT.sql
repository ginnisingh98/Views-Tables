--------------------------------------------------------
--  DDL for Package OKC_REP_SEARCH_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_SEARCH_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVREPSRCHUTILS.pls 120.0.12010000.2 2008/11/26 10:26:02 strivedi noship $ */

  ------------------------------------------------------------------------------
    -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------

  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_SEARCH_UTIL_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';




  ------------------------------------------------------------------------------
    -- PROCEDURES AND FUNCTIONS
  ------------------------------------------------------------------------------

    -- API name     : get_rep_doc_acl
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at crawl-time to get the ACL list for the given
    --                contract document (for repository contracts) or for the
    --                given contract document and version (for archived
    --                contracts). The list of ACLs is then indexed with the
    --                document to be used at query-time to determine whether
    --                a user has access to the document.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_bus_doc_id IN NUMBER
    --                   The document ID of the contract document currently
    --                   being crawled.
    --   IN         : p_bus_doc_version IN NUMBER
    --                   The version of the contract document currently being
    --                   crawled.
    --   IN           p_driving_table IN VARCHAR2
    --                   The table that drives the VO associated with the
    --                   contract document currently being crawled. There are
    --                   two possible values: 'okc_rep_contracts_all' (for
    --                   repository contracts) and 'okc_rep_contract_vers'
    --                   (for archived contracts).
    --   OUT        : x_acl OUT VARCHAR2
    --                   A space-delimited string of ACL keys that define
    --                   access to this document.
    --                   Example:  g32324 g4434 u88932 u72223 admin_acl o23452
    -- Note         :
   PROCEDURE get_rep_doc_acl
     ( p_bus_doc_id IN NUMBER,
       p_bus_doc_version IN NUMBER,
       p_driving_table IN VARCHAR2,
       x_acl OUT NOCOPY VARCHAR2);

    -- API name     : get_current_user_acl_keys
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at query-time to get the ACL keys for the
    --                current user. This list of ACL keys is then used to
    --                check each search hit and verify that the user is
    --                permitted to view that specific hit. If a user is
    --                not permitted to view a given hit, then that hit is
    --                removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : None.
    --   OUT        : x_keys  OUT VARCHAR2
    --                   A space-delimited string of ACL keys that define
    --                   the user's access rights.
    --                   Example:  no_acl o23452 u23452 g2241 g2308
    -- Note         :
   PROCEDURE get_current_user_acl_keys
     ( x_keys OUT NOCOPY VARCHAR2);

    -- API name     : get_current_user_moac_keys
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at query-time to get the list of operating
    --                units that the current user may access. This list of
    --                operating unit IDs is then used to check each search hit
    --                and verify that the user is permitted to view that
    --                specific hit. If a user is not permitted to view a given
    --                hit, then that hit is removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : None.
    --   OUT        : x_keys  OUT VARCHAR2
    --                   A space-delimited string of the IDs of the operating
    --                   units to which the current user has access.
    --                   Example:  134 325 4384
    -- Note         :
   PROCEDURE get_current_user_moac_keys
     ( x_keys OUT NOCOPY VARCHAR2);

    -- API name     : get_intent_profile_keys
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at query-time to get the list of intent codes
    --                that represent the types of contracts (e.g. Buy, Sell)
    --                that the current user may access. This list of
    --                intent codes is then used to check each search hit
    --                and verify that the user is permitted to view that
    --                specific hit. If a user is not permitted to view a given
    --                hit, then that hit is removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : None.
    --   OUT        : x_keys  OUT VARCHAR2
    --                   A string of single-character intent codes that
    --                   represent the types of contracts (e.g. Buy, Sell) to
    --                   which the current user has access. This string is
    --                   parse into another string containing the single
    --                   characters separated by spaces in the BusDocSearchPlugIn
    --                   class (e.g. "SA" -> "S A").
    --                   Example:  BA
    --                   Example:  BSOA
    -- Note         :
   PROCEDURE get_intent_profile_keys
     ( x_keys OUT NOCOPY VARCHAR2);

    -- API name     : get_current_user_quote_access
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class in the
    --                queryPostProcess() method at query-time to discover the
    --                current user's level of access for a given Sales Quote
    --                document. The possible return values are UPDATE, READ,
    --                and NONE. If a user is not permitted to view a given
    --                quote (meaning that this procedure returns NONE), then
    --                that quote document is removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_quote_number  IN NUMBER
    --                   The ID number of the sales quote document
    --                   currently being processed.
    --   OUT        : x_access  OUT VARCHAR2
    --                   A string that represents the current user's level of
    --                   access for the given Sales Quote document.
    -- Note         :
   PROCEDURE get_current_user_quote_access
     ( p_quote_number IN NUMBER,
       x_access OUT NOCOPY VARCHAR2);

    -- API name     : get_local_language_attributes
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class in the
    --                queryPostProcess() method at query-time to fetch
    --                three language-dependent attributes: document type,
    --                intent, and status. The local language values of
    --                these three attributes are returned in a space-
    --                delimited string in the order docType, intent, status.
    -- Parameters   :
    --   IN         : p_doc_type_code IN NUMBER
    --                   The document type code of the contract document
    --                   currently being processed by queryPostProcess().
    --   IN         : p_intent_code IN NUMBER
    --                   The intent code of the contract document currently
    --                   being processed by queryPostProcess().
    --   IN         : p_status_code IN NUMBER
    --                   The status code of the contract document currently
    --                   being processed by queryPostProcess().
    --   OUT        : x_attrs  OUT VARCHAR2
    --                   A string containing three sub-strings separated by
    --                   spaces. These three sub-strings represent the
    --                   local-language vlue of document type, intent,
    --                   and status.
    -- Note         :
   PROCEDURE get_local_language_attributes
     ( p_doc_type_code IN VARCHAR,
       p_intent_code IN VARCHAR,
       p_status_code IN VARCHAR,
       x_attrs OUT NOCOPY VARCHAR2);



    -- API name     : get_rep_parties
    -- Type         : Private.
    -- Function     : This function fetches the party names for a given
    --                repository contract. It is called in the SQL statements
    --                of RepHeaderSearchExpVO and RepArchiveSearchExpVO in the
    --                oracle.apps.okc.repository.search.server package.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_contract_id IN NUMBER
    --                   The contract ID of the contract document currently
    --                   being crawled.
    --   OUT        : x_parties OUT VARCHAR2
    --                   A string of party names that define
    --                   the parties of this repository contract. The party
    --                   names are separated by spaces.
    --                   Example:  Vision, Inc. AT&T Informologics
    -- Note         :
   FUNCTION get_rep_parties(
        p_contract_id IN NUMBER
     ) RETURN VARCHAR2;


    -- API name      : get_terms_last_update_date.
    -- Type          : Private.
    -- Function      : This function returns the last_update_date value of the the business
    --                document's contract terms.
    -- Pre-reqs      : None.
    -- Parameters    :
    -- IN            : p_document_type       IN VARCHAR2       Required
    --                   Type of the document that is being checked
    --               : p_document_id       IN VARCHAR2       Required
    --                   Id of the document that is being checked
    -- OUT           : Returns the last_update_date value of the the business
    --                 document's contract terms.
   FUNCTION get_terms_last_update_date(
      p_document_type IN  VARCHAR2,
      p_document_id   IN  NUMBER
    ) RETURN DATE;




    -- API name      : draft_attachment_exists.
    -- Type          : Private.
    -- Function      : This function returns Y if the generated draft attachment exists for
    --                the business document passed as input. It will also check that
    --                attachment's last_update_date is later than the business document's
    --                Term's last_update_date.
    -- Pre-reqs      : None.
    -- Parameters    :
    -- IN            : p_document_type       IN VARCHAR2       Required
    --                   Type of the document that is being checked
    --               : p_document_id       IN VARCHAR2       Required
    --                   Id of the document that is being checked
    -- OUT           : Return Y if the latest generated draft attachment exists for the
    --                business document, else returns N
   FUNCTION draft_attachment_exists(
      p_document_type IN  VARCHAR2,
      p_document_id   IN  NUMBER
    ) RETURN VARCHAR2;




   -- API name      : is_contract_status_draft.
   -- Type          : Private.
   -- Function      : This function returns Y if the business document status is
   --                 draft.
   -- Pre-reqs      : None.
   -- Parameters    :
   -- IN            : p_document_type       IN VARCHAR2       Required
   --                   Type of the document that is being checked
   --               : p_document_id       IN VARCHAR2       Required
   --                   Id of the document that is being checked
   -- OUT           : Returns Y if the business document status is
   --                draft, else returns N
   FUNCTION is_contract_status_draft(
       p_document_type IN  VARCHAR2,
       p_document_id   IN  NUMBER
     ) RETURN VARCHAR2;



/*    -- API name   : get_neg_parties
    -- Type         : Private.
    -- Function     : This function fetches the party names for a given
    --                negotiation contract. It is called in the SQL statements
    --                of NegSearchExpVO.xml in the
    --                oracle.apps.okc.repository.search.server package.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_auction_header_id IN NUMBER
    --                   The auction header ID of the contract document currently
    --                   being crawled.
    --   OUT        : x_parties OUT VARCHAR2
    --                   A string of party names that define
    --                   the parties of this negotiation contract. The party
    --                   names are separated by spaces.
    --                   Example:  Vision, Inc. AT&T Informologics
    -- Note         :    */
   FUNCTION get_neg_parties(
        p_auction_header_id IN NUMBER
     ) RETURN VARCHAR2;





 END OKC_REP_SEARCH_UTIL_PVT;

/
