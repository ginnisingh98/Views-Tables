--------------------------------------------------------
--  DDL for Package PON_WF_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_WF_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: PONWFUTS.pls 120.9.12010000.3 2014/09/04 13:17:11 spapana ship $ */


	/* corresponding constants for the Sourcing doc types */

	SRC_AUCTION 		CONSTANT  varchar2(30) := 'BUYER_AUCTION';
	SRC_RFQ 		CONSTANT  varchar2(30) := 'REQUEST_FOR_QUOTE';
	SRC_RFI 		CONSTANT  varchar2(30) := 'REQUEST_FOR_INFORMATION';

	/* constants to determine the return value - YES or NO*/
	G_NO 		CONSTANT  varchar2(3)  := 'NO';
	G_YES 		CONSTANT  varchar2(3)  := 'YES';

	/* Read the profile option that enables/disables the debug log
	  store the profile value for logging in a global constant variable
	  so that we avoid checking the profile every time
	*/

	g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	/* package name for logging */

	g_pkg_name CONSTANT VARCHAR2(30) := 'PON_WF_UTL_PVT';

	/* module prefix for logging ->Create a module name used for logging */

	g_module_prefix CONSTANT VARCHAR2(50):='pon.plsql.' ||g_pkg_name || '.';


      /* Record that contains menu and function context (name/value pair) */

         TYPE menu_function_parameter_rec IS RECORD (OAHP VARCHAR2(240),
                                                     OASF VARCHAR2(240));

      /* Record that represents a URL parameter (name/value pair) */

         TYPE url_parameter_rec IS RECORD (name VARCHAR2(240),
                                           value VARCHAR2(240));

      /* Collection of URL parameters (Collections of name/value pairs) */

         /* removed the 'not null' from the url_parameters_tab type definition to be able to
            compile in Oracle 8i database */
         TYPE url_parameters_tab IS TABLE OF url_parameter_rec INDEX BY  BINARY_INTEGER;


     /* Low level function that returns an OA page URL using the following form
      at:   'http://<some_server>:<port>/OA_HTML/OA.jsp' || <parameters>'
      where: <some_server> and <port> are read from profile.
      <parameters> are construted from the input to the function. */

         FUNCTION get_page_url(p_url_parameters_tab url_parameters_tab
                              ,p_notif_performer  VARCHAR2)
         RETURN VARCHAR2;

      /* High-level function that returns the iSP Supplier Register page url */

      FUNCTION get_isp_supplier_register_url (p_registration_key  IN VARCHAR2
                                                                ,p_language_code     IN VARCHAR2)
      RETURN VARCHAR2;


      /* Sets the workflow notification header attributes */

      PROCEDURE set_hdr_attributes (p_itemtype         IN  VARCHAR2
                                   ,p_itemkey          IN  VARCHAR2
                                   ,p_auction_tp_name  IN  VARCHAR2
                                   ,p_auction_title    IN  VARCHAR2
                                   ,p_document_number  IN  VARCHAR2
                                   ,p_auction_tp_contact_name IN VARCHAR2);

     /* High-level function that returns a destination page url */
         FUNCTION get_dest_page_url (p_dest_func         IN    VARCHAR2
                                    ,p_notif_performer   IN    VARCHAR2)

         RETURN VARCHAR2;

	-- Retreive WF item attribute values for a given item type and item key
    PROCEDURE get_dest_page_params (
              p_ntf_id       IN NUMBER,
              p_dest_page    IN VARCHAR2,
              x_auction_id  OUT NOCOPY NUMBER,
              x_site_id     OUT NOCOPY NUMBER,
              x_bid_number  OUT NOCOPY NUMBER,
              x_doc_type_id OUT NOCOPY NUMBER,
	      x_reviewpg_redirect_func OUT NOCOPY VARCHAR2,
              x_request_id OUT NOCOPY NUMBER,
              x_DocumentNumber OUT NOCOPY VARCHAR2,
              x_entry_id   OUT NOCOPY NUMBER,
              x_message_type OUT NOCOPY VARCHAR2,
              x_discussion_id OUT NOCOPY NUMBER,
     	      x_neg_deleted OUT NOCOPY VARCHAR2);

PROCEDURE GetConcProgramType(itemtype             in varchar2,
                           itemkey              in varchar2,
                           actid                in number,
                           uncmode              in varchar2,
                           resultout            out NOCOPY varchar2);

PROCEDURE GetLastLineNumberInBatch(itemtype     in varchar2,
                           itemkey              in varchar2,
                           actid                in number,
                           uncmode              in varchar2,
                           resultout            out NOCOPY varchar2);

PROCEDURE GetLastWorksheetInBatch(itemtype     in varchar2,
                           itemkey              in varchar2,
                           actid                in number,
                           uncmode              in varchar2,
                           resultout            out NOCOPY varchar2);

Procedure ReportConcProgramStatus(
          p_request_id 		in Number,
          p_messagetype 	in Varchar2,
          p_RecepientUsername 	in Varchar2,
          p_recepientType 	in Varchar2,
          p_auction_header_id 	in number,
          p_ProgramTypeCode   	in Varchar2,
          p_DestinationPageCode in Varchar2,
          p_bid_number 		in Number,
    	  p_max_good_line_num 	in number default -1,
          p_last_goodline_worksheet in Varchar2	default ''
	  );

/*=======================================================================+
-- API Name: GET_NOTIF_PREFERENCE
--
-- Type    : Public
--
-- Pre-reqs: None
--
-- Function: This new API will determine whether the notification
--           preference for the current workflow message has been set.
--
-- Parameters:
--
--           p_wf_message_name IN VARCHAR2
--           p_auction_id IN NUMBER
--
+=======================================================================*/

    FUNCTION GET_NOTIF_PREFERENCE (
              p_wf_message_name IN WF_MESSAGES.NAME%TYPE
             ,p_auction_id IN PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE)
    RETURN VARCHAR2;


    /* High-level function that returns the external supplier url
        of the following form at:   'http://<some_server>:<port>/' */
    FUNCTION get_base_external_supplier_url RETURN VARCHAR2;

    /* High-level function that returns the internal buyer url
        of the following form at:   'http://<some_server>:<port>/' */
    FUNCTION get_base_internal_buyer_url RETURN VARCHAR2;

   /* Function returning FND Profile value at Site Level */
    FUNCTION get_site_level_profile_value(p_profile_name varchar2) RETURN VARCHAR2;

	/* Bug#16690413 Procedure to check the org access of the user */
    PROCEDURE check_org_access(p_auction_header_id NUMBER,
                          p_dest_page VARCHAR2,
                          x_has_access	OUT NOCOPY VARCHAR2,
                          x_org_id	OUT NOCOPY NUMBER);


    /* SLM UI Enhancement : Going forward when new workflow attribute is added,
     * if attribute is varchar, call below api's.
     * If attribute is of any other type, create new api's.
    */
    PROCEDURE SetItemAttrText(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              avalue in varchar2);

    FUNCTION GetItemAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             aname in varchar2) return varchar2;

    /* This api sets the notification attribute  */
    PROCEDURE SetNotifAttrText(nid in number,
                               aname in varchar2,
                               avalue in varchar2);

END PON_WF_UTL_PKG;

/
