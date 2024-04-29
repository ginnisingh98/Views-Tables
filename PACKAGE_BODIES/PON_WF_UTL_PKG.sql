--------------------------------------------------------
--  DDL for Package Body PON_WF_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_WF_UTL_PKG" AS
/* $Header: PONWFUTB.pls 120.20.12010000.14 2014/10/21 06:53:17 spapana ship $ */
       -- Local private functions

       FUNCTION get_base_supplier_url RETURN VARCHAR2;
       FUNCTION get_base_buyer_url RETURN VARCHAR2;
       FUNCTION GET_NOTIF_PREFERENCE ( p_wf_message_name IN	WF_MESSAGES.NAME%TYPE,
       	                               p_doctype         IN 	PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE,
                                       p_is_slm_doc      IN  VARCHAR2)
       RETURN VARCHAR2;


       	/*
       	 Function: get_base_supplier_url
       	 Parameters: None
       	 Returns:  the base supplier url
       	 Sample output: http://server01:4761/OA_HTML/OA.jsp
       	*/

       	FUNCTION get_base_supplier_url RETURN VARCHAR2 IS

       	l_def_ext_user_resp VARCHAR2(240);
        l_application_id NUMBER;
        l_responsibility_id NUMBER;
        l_ext_fwk_agent  VARCHAR2(240);

        -- First try to get the Sourcing External Framework Agent.
        -- If not set, then get the responsibility associated with the
        -- 'Sourcing Default Responsibility for External User' profile option
        BEGIN
        --
        -- Access the Sourcing external APPS_FRAMEWORK_AGENT
        --
        l_ext_fwk_agent := FND_PROFILE.value('PON_EXT_APPS_FRAMEWORK_AGENT');
        --
        -- If the profile is not set, then try the default responsibility approach
        --
        IF (l_ext_fwk_agent IS NULL) THEN
          --
           l_ext_fwk_agent := FND_PROFILE.value('APPS_FRAMEWORK_AGENT');
        END IF;
        --
        -- add OA_HTML/OA.jsp to the profile value
        --
        IF ( l_ext_fwk_agent IS NOT NULL ) THEN
          --
          IF ( substr(l_ext_fwk_agent, -1, 1) = '/' ) THEN
            RETURN l_ext_fwk_agent ||  'OA_HTML/OA.jsp';
          ELSE
            RETURN l_ext_fwk_agent || '/' || 'OA_HTML/OA.jsp';
          END IF;
        --
        -- No profiles are setup so return nothing...
        --
        ELSE
         RETURN  '';
        END IF;
EXCEPTION
WHEN OTHERS THEN
     RETURN '';
END get_base_supplier_url;


       	/*
	 Function: get_base_buyer_url
	 Parameters: None
	 Returns:  the base buyer url
	 Sample output: http://qapache.us.oracle.com:4761/OA_HTML/OA.jsp
	*/

	FUNCTION get_base_buyer_url RETURN VARCHAR2 IS

	     l_base_url VARCHAR2(240);

         l_api_name  CONSTANT   VARCHAR2(30) := 'get_base_buyer_url';
        BEGIN
           -- Bug:6268452. Due to DMZ issue, we need to make sure that Buyer's URL come from internal website. Since Site level Profile always maintain the internal URL, so we get the site level profile first.
           l_base_url := get_site_level_profile_value('APPS_FRAMEWORK_AGENT');

           IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(log_level => FND_LOG.level_statement,
                               module    => g_module_prefix || l_api_name,
                               message   => 'After calling get_site_level_profile_value. l_base_url='
                                                || l_base_url);
                END IF;
           END IF;

           if (l_base_url is  null) then
                l_base_url :=  FND_PROFILE.value('APPS_FRAMEWORK_AGENT');
                IF (g_fnd_debug = 'Y') THEN
                   IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(log_level => FND_LOG.level_statement,
                               module    => g_module_prefix || l_api_name,
                               message   => 'get_site_level_profile return NULL. After calling FND_PROFILE.value(); l_base_url='
                                                || l_base_url);
                   END IF;
                END IF;

           end if;

	   IF ( substr(l_base_url, -1, 1) = '/' ) THEN
	      RETURN l_base_url ||  'OA_HTML/OA.jsp';
	    ELSE
	      RETURN l_base_url || '/' || 'OA_HTML/OA.jsp';
	   END IF;

	   RETURN l_base_url || 'OA_HTML/OA.jsp';

	END get_base_buyer_url;


	/*
	 Function: get_page_url
	 Parameters: None
         Returns:  the complete url to access an OA page
	*/

	FUNCTION get_page_url (p_url_parameters_tab url_parameters_tab
	                      ,p_notif_performer  VARCHAR2)
        RETURN VARCHAR2 IS

	   i PLS_INTEGER;
	   l_page_url VARCHAR2(2000);

        BEGIN

           -- to get the base URL

       IF p_notif_performer = 'BUYER' THEN
		l_page_url := get_base_buyer_url;
	   ELSE
		l_page_url := get_base_supplier_url;
	   END IF;


	   -- appending each parameter as passed in
	   FOR i IN p_url_parameters_tab.FIRST..p_url_parameters_tab.LAST
	   LOOP
	       IF (i = 1) THEN
	         l_page_url := l_page_url || '?';
    	       ELSE
	         l_page_url := l_page_url || '&';
	       END IF;

    	       l_page_url := l_page_url || p_url_parameters_tab(i).name || '=' || p_url_parameters_tab (i).value;
	   END LOOP;
       /* Bug 3290344 removed call to UTL_URL.escape function specific to Oracle 9i database */
	   RETURN l_page_url;

        END get_page_url;


       /*
	 Procedure: set the workflow notification header attributes
	 Parameters:
	 Description: set the workflow notification header attributes
         Comments:  #HDR_NEG_TP_NAME, -> PREPARER_TP_NAME
                #HDR_NEG_TITLE,   -> AUCTION_TITLE
                #HDR_NEG_NUMBER,  -> DOC_NUMBER
                #FROM_ROLE,       -> PREPARER_TP_CONTACT_NAME
         The #FROM_ROLE attribute is the Preparer Trading Partner Contact Name in
         98% of the cases. Notifications whose #FROM_ROLE differs from this have to
         set this attribute in the calling procedure
	*/

	PROCEDURE set_hdr_attributes (p_itemtype	 IN  VARCHAR2
		                     ,p_itemkey	         IN  VARCHAR2
                                     ,p_auction_tp_name  IN  VARCHAR2
	                             ,p_auction_title    IN  VARCHAR2
	                             ,p_document_number  IN  VARCHAR2
	                             ,p_auction_tp_contact_name IN VARCHAR2) IS
	BEGIN

	      /* Setting the Company header attribute */
              wf_engine.SetItemAttrText(itemtype   => p_itemtype
                             ,itemkey    => p_itemkey
                             ,aname      => 'PREPARER_TP_NAME'
	                         ,avalue     => p_auction_tp_name);

              /* Setting the negotiation title header attribute */
              wf_engine.SetItemAttrText(itemtype   => p_itemtype
	                         ,itemkey    => p_itemkey
                             ,aname      => 'AUCTION_TITLE'
                             ,avalue     =>  pon_auction_pkg.replaceHtmlChars(p_auction_title));

	      /* Setting the negotiation document number attribute */
              wf_engine.SetItemAttrText(itemtype   => p_itemtype
                             ,itemkey    => p_itemkey
                             ,aname      => 'DOC_NUMBER'
                             ,avalue     => p_document_number);

               /* Setting the #From role attribute */
               wf_engine.SetItemAttrText (itemtype   => p_itemtype
                              ,itemkey    => p_itemkey
                              ,aname      => 'PREPARER_TP_CONTACT_NAME'
                              ,avalue     => p_auction_tp_contact_name);

	END set_hdr_attributes;

    FUNCTION get_menu_function_context (p_notif_performer   IN VARCHAR2)
       RETURN menu_function_parameter_rec IS

          l_menu_function_parameter_rec       menu_function_parameter_rec;

     BEGIN
        IF p_notif_performer = 'BUYER' THEN
		    l_menu_function_parameter_rec.OAHP := 'PON_SRC_SUPER_USER_HOME';
		    l_menu_function_parameter_rec.OASF := 'PON_SOURCING_BUYER';
	    ELSE
		    l_menu_function_parameter_rec.OAHP := 'PON_SRC_SUPPLIER_USER_HOME';
		    l_menu_function_parameter_rec.OASF := 'PON_SOURCING_SUPPLIER';
	    END IF;
        RETURN l_menu_function_parameter_rec;

     END get_menu_function_context;


    /*
     *   Function: get_dest_page_url
     *   Parameters: p_dest_func - the final destination page
     *               p_notif_performer - the recipient of the notification
     *               p_redirect_func - Review and Submit page parameter
     *   Returns:  the url for the redirect page
     *   This has 3 parameters
    */
     FUNCTION get_dest_page_url (p_dest_func         IN    VARCHAR2
                                ,p_notif_performer   IN    VARCHAR2)

     RETURN VARCHAR2 IS

     l_url_parameters_tab    url_parameters_tab;
     l_menu_function_parameter_rec   menu_function_parameter_rec;
     l_is_slm_doc varchar2(1) := 'N';
     l_url_param_cnt number := 1;

    BEGIN

    l_is_slm_doc := PON_SLM_UTIL_PKG.g_is_slm_doc;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module => g_module_prefix || 'get_dest_page_url',
      message  => 'Entered the procedure with p_dest_func : ' || p_dest_func || '; p_notif_performer : ' || p_notif_performer
       || '; is_slm_doc' || l_is_slm_doc);
    END IF; --}

    IF (l_is_slm_doc = 'N') THEN
      l_menu_function_parameter_rec := get_menu_function_context(p_notif_performer => p_notif_performer);
    END IF;

    -- This is the redirect page which will get these parameters and redirect
    -- to the final page
    l_url_parameters_tab(l_url_param_cnt).name := 'OAFunc';
    l_url_parameters_tab(l_url_param_cnt).value := 'PON_NOTIF_LINK_REDIRECT';
    l_url_param_cnt := l_url_param_cnt + 1;

    IF (l_is_slm_doc = 'N') THEN
      l_url_parameters_tab(l_url_param_cnt).name := 'OAHP';
      l_url_parameters_tab(l_url_param_cnt).value := l_menu_function_parameter_rec.OAHP;
      l_url_param_cnt := l_url_param_cnt + 1;
      l_url_parameters_tab(l_url_param_cnt).name := 'OASF';
      l_url_parameters_tab(l_url_param_cnt).value := l_menu_function_parameter_rec.OASF;
      l_url_param_cnt := l_url_param_cnt + 1;
    END IF;

    l_url_parameters_tab(l_url_param_cnt).name := 'destFunc';
    l_url_parameters_tab(l_url_param_cnt).value := p_dest_func;
    l_url_param_cnt := l_url_param_cnt + 1;

    -- This will be replaced by the actual notification id during runtime
    l_url_parameters_tab(l_url_param_cnt).name := 'notificationId';
    l_url_parameters_tab(l_url_param_cnt).value := '&#NID';
    l_url_param_cnt := l_url_param_cnt + 1;

    --Bug 6369383 : Add language Code
    -- This fix assumes that the caller of this procedure sets the language appropriately
    -- before making the call. The userenv language will be taken and set as the language code

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module => g_module_prefix || 'get_dest_page_url',
      message  => 'Adding language_code ; fnd_global.current_language : ' ||  fnd_global.current_language);
    END IF; --}

	--Bug 15991171 - removing language_code parameter from url
--        l_url_parameters_tab(6).name := 'language_code';
--        l_url_parameters_tab(6).value := fnd_global.current_language; --userenv('LANG');

         --Bug 14406948
         --Added URL parameters for Bread Crumbs
         l_url_parameters_tab(l_url_param_cnt).name := 'addBreadCrumb';
         l_url_parameters_tab(l_url_param_cnt).value := 'Y';
         l_url_param_cnt := l_url_param_cnt + 1;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module => g_module_prefix || 'get_dest_page_url',
      message  => 'fnd_global.current_language : ' || fnd_global.current_language);
    END IF; --}

  	RETURN get_page_url(p_url_parameters_tab => l_url_parameters_tab
	                   ,p_notif_performer => p_notif_performer);

	END get_dest_page_url;


  /*
     *   Procedure: get_dest_page_params
     *   Purpose:   retrieve WF item attribute values for a given item type and item key. This
	 *              procedure is being called from NotificationLinkRedirectAMImpl.java to build
	 *              the final destination page url.
     *
     *   Parameters: p_ntf_id      - Notification Id
     *                p_dest_page   - final destination page
     *                x_auction_id  - auction id
     *                x_site_id     - site id
     *                x_bid_number  - bid number
     *                x_doc_type_id - document type id
     *                x_reviewpg_redirect_func - redirect func parameter for Review and Submit page
     *                x_neg_deleted   - Is negotiation deleted (hard delete)
     *
     *  The following is the list of destination pages with appropriate parameters needed to launch.
     * -------------------------------------------------------------------------
     * PAGE#    PAGE_NAME                     PAGE_PARAMETERS
     * -------------------------------------------------------------------------
     * PAGE-1:  Negotiation Summary           AuctionId; SiteId
     * PAGE-2:  View Net Changes              current_auction_id
     * PAGE-3:  New Round Summary             AuctionId
     * PAGE-4:  Review and Submit             from;redirectFunc; auctionHeaderId
     * PAGE-5:  Allocation by Item            auction_header_id;docTypeId
     * PAGE-6:  Award Summary                 retainAM;addBreadCrumb; AuctionId
     * PAGE-7:  View Quote                    auction_id; bid_number
     * PAGE-8:  Allocation Summary            auction_header_id;docTypeId; From
     * PAGE-9:  Acknowledge participation     auction_id; SiteId
     * ------------------------------------------------------------------------- */


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
              x_neg_deleted	OUT NOCOPY VARCHAR2) is
CURSOR wf_item_cur IS
  SELECT item_type,
         item_key
  FROM   wf_item_activity_statuses
  WHERE  notification_id  = p_ntf_id;


  -- The following cursor is to parse the CONTEXT string
  -- in the wf_notifications table to fetch the item type and item key.
  -- The format for the context string is ITEMTYPE:ITEM_KEY:OTHER
  -- For eg: The context PONAUCT:7136-1466:6566 will return
  --         PONAUCT as ItemType, and 7136-1466 as ItemKey.
  CURSOR wf_notif_context_cur IS
  SELECT SUBSTR(context,1,INSTR(context,':',1)-1),
         SUBSTR(context,INSTR(context,':')+1,
                       (INSTR(context,':',1,2) - INSTR(context,':')-1)),
         message_name
  FROM   wf_notifications
  WHERE  notification_id   = p_ntf_id;

  p_itemtype WF_ITEM_ACTIVITY_STATUSES.item_type%TYPE;  -- VARCHAR2(8)
  p_itemkey  WF_ITEM_ACTIVITY_STATUSES.item_key%TYPE;   -- VARCHAR2(240)

  p_message_name wf_notifications.message_name%TYPE;

  BEGIN
  x_bid_number := -1;
  x_site_id := -1;
  x_request_id := -1;
  x_DocumentNumber :='NOTSPECIFIED';

   -- Fetch the item_type and item_key values from
   -- wf_item_activity_statuses for a given notification_id.
   OPEN wf_item_cur;
   FETCH wf_item_cur INTO p_itemtype, p_itemkey;
   CLOSE wf_item_cur;

   -- If the wf_item_activity_statuses does not contain an entry,
   -- then parse the wf_notifications.context field to
   -- get the item_type and item_key values for a given notification_id.
   IF ((p_itemtype IS NULL) AND (p_itemkey IS NULL))
   THEN
        OPEN  wf_notif_context_cur;
        FETCH wf_notif_context_cur INTO p_itemtype, p_itemkey, p_message_name;
        CLOSE wf_notif_context_cur;

   END IF;


     -- Existent code had auction id item attribute being defined with different names
	 -- accross the existent item types. Reason why we read different item attributes
	 -- to get auction id value.
     -- From now on, any new item attribute that gets created to hold auction id
     -- in new item types should have its item attribute name named 'AUCTION_ID' for
     -- consistency
            IF (p_itemtype = 'PONAPPRV' or p_itemtype = 'PONAWAPR') THEN
                x_auction_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname    => 'AUCTION_HEADER_ID');
            ELSE
                x_auction_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname    => 'AUCTION_ID');
            END IF;
            IF (p_itemtype = 'PONCNCT' ) THEN
               --Bug 17505620
               --x_request_id, x_documentnumber will retain initial values if wf_engine returns null
               x_request_id := Nvl(wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname    => 'REQUEST_ID'),-1);
              x_documentnumber :=  Nvl(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                       itemkey => p_itemkey,
                                                                       aname => 'DOC_NUMBER'),'NOTSPECIFIED');
            END IF;


			-- getting parameters to access Acknowledgment Participation page
			-- constant parameters are being set in the NotificationLinkRedirectAMImpl.java
            IF (p_dest_page = 'PON_NEG_SUMMARY' or p_dest_page = 'PONRESAPN_ACKPARTICIPATN') THEN

                IF (p_message_name = 'NEGOTIATION_EXTENDED' or p_message_name = 'NEGOTIATION_SHORTENED') THEN
					--Bug 17505620
                    --x_site_id will retain initial value if WF_NOTIFICATION_ATTRIBUTES
                    --or wf_engine returns null
                       select Nvl(number_value,-1)
                       into   x_site_id
                       from   WF_NOTIFICATION_ATTRIBUTES
                       where  notification_id = p_ntf_id and
                              name = 'VENDOR_SITE_ID';

                ELSE

                  x_site_id := Nvl(wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                            itemkey  => p_itemkey,
                                                            aname    => 'VENDOR_SITE_ID'),-1);
                END IF;

            END IF;

			-- getting parameters needed to access View Quote page
			-- constant parameters are being set in the NotificationLinkRedirectAMImpl.java
			--Bug 17505620
            --x_bid_number will retain initial value if wf_engine returns null
            IF p_dest_page = 'PONRESENQ_VIEWBID' or p_dest_page = 'PONENQMGDR_MANAGEDRAFT' or p_dest_page = 'PONENQMGDR_MANAGEDRAFT_SURROG' THEN
               x_bid_number := Nvl(wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                            itemkey  => p_itemkey,
                                                            aname    => 'BID_ID'),-1);
            END IF;

			-- getting parameters needed to access Concurrent Errors page
			-- constant parameters are being set in the NotificationLinkRedirectAMImpl.java
            IF p_dest_page = 'PON_CONCURRENT_ERRORS' THEN
               x_bid_number := Nvl(wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                            itemkey  => p_itemkey,
                                                            aname    => 'BID_ID'),-1);
            END IF;



            -- getting parameters to access Allocation by Item or Allocation Summary pages
            -- constant parameters are being set in the NotificationLinkRedirectAMImpl.java
            IF (p_dest_page = 'PONCPOABI_ALLOCATEBYITEM' or p_dest_page = 'PONCPOSUM_ALLOCSUMMARY') THEN
                x_doc_type_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                              itemkey  => p_itemkey,
                                                              aname    => 'DOCTYPE_ID');
            END IF;

            -- getting parameters to access Review and Submit page
            -- constant parameters are being set in the NotificationLinkRedirectAMImpl.java
            IF (p_dest_page = 'PON_NEG_CRT_HEADER') THEN
                x_reviewpg_redirect_func := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                       itemkey  => p_itemkey,
                                                                       aname    => 'REVIEWPG_REDIRECTFUNC');
            END IF;


            IF (p_dest_page = 'PON_VIEW_MESSAGE_DETAILS' ) THEN
                 x_entry_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                           itemkey  => p_itemkey,
                                                           aname    => 'MESSAGE_ENTRY_ID');
                 x_message_type := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                           itemkey  => p_itemkey,
                                                           aname    => 'MESSAGE_TYPE');
                 x_discussion_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                           itemkey  => p_itemkey,
                                                           aname    => 'DISCUSSION_ID');
             END IF;

      BEGIN
         SELECT 'N'
         INTO  x_neg_deleted
         FROM  PON_AUCTION_HEADERS_ALL
         WHERE auction_header_id = x_auction_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_neg_deleted := 'Y';
  	  END;

 EXCEPTION
      WHEN OTHERS THEN
          IF ( wf_item_cur%ISOPEN ) THEN
             CLOSE wf_item_cur;
             RAISE;
		  END IF;

		  IF ( wf_notif_context_cur%ISOPEN ) THEN
             CLOSE wf_notif_context_cur;
             RAISE;
		  END IF;

 END get_dest_page_params;

        /*
         Function: get_isp_supplier_register_url
         Parameters: None
         Returns:  the url to the  iSP Supplier Register page
        */

    FUNCTION get_isp_supplier_register_url (p_registration_key  IN VARCHAR2
                                           ,p_language_code     IN VARCHAR2)
    RETURN VARCHAR2 IS

        l_ext_fwk_agent  VARCHAR2(2000);
       	l_def_ext_user_resp VARCHAR2(240);
        l_application_id NUMBER;
        l_responsibility_id NUMBER;

        BEGIN

        --
        -- Access the Sourcing external APPS_FRAMEWORK_AGENT
        --
        l_ext_fwk_agent := FND_PROFILE.value('PON_EXT_APPS_FRAMEWORK_AGENT');
        --
        -- If the profile is not set, then try the default responsibility approach
        --
        IF (l_ext_fwk_agent IS NULL) THEN
          --
           l_ext_fwk_agent := FND_PROFILE.value('APPS_FRAMEWORK_AGENT');
        END IF;

       IF ( substr(l_ext_fwk_agent, -1, 1) <> '/' ) THEN
         l_ext_fwk_agent := l_ext_fwk_agent||'/';
       END IF;
       l_ext_fwk_agent := l_ext_fwk_agent || 'OA_HTML/jsp/pos/registration/RegistrationReply.jsp?registrationKey=' || p_registration_key || '&' || 'regLang=' || p_language_code;

        /* Bug 3290344 removed call to UTL_URL.escape function specific to Oracle 9i database */
            RETURN l_ext_fwk_agent;

    END get_isp_supplier_register_url;

PROCEDURE GetConcProgramType(itemtype             in varchar2,
                             itemkey              in varchar2,
                           actid                in number,
                           uncmode              in varchar2,
                           resultout            out NOCOPY varchar2) IS

BEGIN

    resultout := wf_engine.GetItemAttrText (itemtype => itemtype,
	    itemkey  => itemkey,
	    aname    => 'CONCPROGRAM_TYPE');

END GetConcProgramType;


Procedure ReportConcProgramStatus(
          p_request_id 			in Number,
          p_messagetype 		in Varchar2,
          p_RecepientUsername 		in Varchar2,
          p_recepientType 		in Varchar2,
          p_auction_header_id 		in number,
          p_ProgramTypeCode   		in Varchar2,
          p_DestinationPageCode   	in Varchar2,
          p_bid_number 			in Number,
    	  p_max_good_line_num		in number default -1,
          p_last_goodline_worksheet in Varchar2	default ''
         ) is
  l_item_type Varchar2(8) := 'PONCNCT';
  l_item_key  Varchar2(240);
  l_language_code VARCHAR2(5);
  l_msg_suffix VARCHAR2(10);
  l_auction_title pon_auction_headers_all.auction_title%type;
  l_document_number pon_auction_headers_all.document_number%type;
  l_trading_partner_contact_name pon_auction_headers_all.trading_partner_contact_name%type;
  l_trading_partner_name pon_auction_headers_all.trading_partner_name%type;
  l_doctype_group_name pon_auc_doctypes.doctype_group_name%type;
  l_doctypemsgval Varchar2(80);

  --SLM UI Enhancement
  l_is_slm  VARCHAR2(1);
  l_slm_neg_doc  VARCHAR2(15);
  l_slm_subject_suffix VARCHAR2(4) := '';

BEGIN

  select to_char(p_auction_header_id) || '-' ||
         to_char(p_request_id)
   into l_item_key from dual;
  -- set the db session language
  PON_PROFILE_UTIL_PKG.get_wf_language(p_RecepientUsername, l_language_code);
  PON_AUCTION_PKG.set_session_language(null, l_language_code);
  SELECT
    auc.trading_partner_contact_name,
    auc.trading_partner_name,
    auc.auction_title,
    auc.document_number,
    dt.doctype_group_name
  INTO
    l_trading_partner_contact_name,
    l_trading_partner_name,
    l_auction_title,
    l_document_number,
    l_doctype_group_name
  FROM
    pon_auction_headers_all auc,
    pon_auc_doctypes dt
  WHERE
        dt.doctype_id= auc.doctype_id
    AND auc.auction_header_id = p_auction_header_id;

  --SLM UI Enhancement
  l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id);
  l_slm_neg_doc := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE(l_is_slm);
  --l_msg_suffix := PON_AUCTION_PKG.get_message_suffix(l_doctype_group_name);
  l_msg_suffix := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE_SUFFIX(l_is_slm, l_doctype_group_name);
  IF (l_is_slm = 'Y' AND
     (p_ProgramTypeCode IN ('NEG_APPROVAL', 'NEG_COPY', 'NEG_PUBLISH'))) THEN

    l_slm_subject_suffix := 'SLM_';

  END IF;

  l_doctypemsgval :=  PON_AUCTION_PKG.getmessage('PON_AUCTION',l_msg_suffix);
  if p_messagetype ='S' then
      wf_engine.CreateProcess(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            process  => 'REPORT_SUCCESS');

  else
      wf_engine.CreateProcess(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            process  => 'REPORT_FAILURE');
  end if;
  -- set standard notification header attributes
  PON_WF_UTL_PKG.set_hdr_attributes(l_item_type,
                                    l_item_key,
                                    l_trading_partner_name,
                                    l_auction_title,
                                    l_document_number,
                                    l_trading_partner_contact_name);

  --SLM UI Enhancement
  PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => l_item_type,
                                              p_itemkey  => l_item_key,
                                              p_value    => l_slm_neg_doc);

  -- set other core attributes
  wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'AUCTION_ID',
                              avalue   => p_auction_header_id);

  wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'BID_ID',
                              avalue   => p_bid_number);

  wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUEST_ID',
                              avalue   => p_request_id);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'CONCPROGRAM_TYPE',
                            avalue   => p_ProgramTypeCode);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'DESTINATION_PAGE_CODE',
                            avalue   => p_DestinationPageCode);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'RECEPIENT_USERNAME',
                            avalue   => p_RecepientUsername);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'DESTINATION_URL',
                            avalue   => get_dest_page_url(p_dest_func=>p_DestinationPageCode,
                                                          p_notif_performer=>p_recepientType));


    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'NOTIFICATION_SUBJECT',
                              avalue   => PON_AUCTION_PKG.getMessage('PONCPG' || p_messagetype || '_' || l_slm_subject_suffix || p_ProgramTypeCode,
                                                                     l_msg_suffix,
								     'REQUEST_ID', --REQUEST_ID
								     to_char(p_request_id),
                                                                     'DOC_TYPE',
                                                                      l_doctypemsgval,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title
								     ));

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'MAX_SUCCESS_LAST_BATCH_LINE_NO',
                            avalue   => to_char(p_max_good_line_num));


  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'LAST_SUCCESS_BATCH_WORKSHEET',
                            avalue   => p_last_goodline_worksheet);

 wf_engine.StartProcess(itemtype => l_item_type,
                             itemkey  => l_item_key );
END ReportConcProgramStatus;



PROCEDURE GetLastLineNumberInBatch(itemtype             in varchar2,
                           itemkey              in varchar2,
                           actid                in number,
                           uncmode              in varchar2,
                           resultout            out NOCOPY varchar2) IS

BEGIN

	BEGIN
	    resultout := wf_engine.GetItemAttrText (itemtype => itemtype,
	    					    itemkey  => itemkey,
						    aname    => 'MAX_SUCCESS_LAST_BATCH_LINE_NO');
	EXCEPTION
	    when others then resultout := -1;
	END;


END GetLastLineNumberInBatch;

/*********/

PROCEDURE GetLastWorksheetInBatch(itemtype     in varchar2,
                           itemkey              in varchar2,
                           actid                in number,
                           uncmode              in varchar2,
                           resultout            out NOCOPY varchar2) IS
BEGIN
    BEGIN
	    resultout := wf_engine.GetItemAttrText (
		                    itemtype => itemtype,
	    				    itemkey  => itemkey,
						    aname    => 'LAST_SUCCESS_BATCH_WORKSHEET');

    EXCEPTION
        WHEN OTHERS THEN
		    resultout := '';
    END;

END GetLastWorksheetInBatch;

/*==============================================================================================
 PROCEDURE : GET_NOTIF_PREFERENCE   PUBLIC
   PARAMETERS:
	p_wf_message_name	IN	workflow message name of current notification
	p_auction_id		IN	auction_header_id of current negotiation

   COMMENT   :  this function was introduced as a part of the notification
		subscriptions project in release-12. This function should be
		invoked in order to determine whether we need to send a particular
		notification to the buyer or supplier user. The UI to set the notification
		preferences can be viewed or modified by accessing the page via Sourcing
		Admin home page

   ==============================================================================================*/


FUNCTION GET_NOTIF_PREFERENCE (
    	p_wf_message_name 	IN 	WF_MESSAGES.NAME%TYPE,
       	p_auction_id 		IN 	PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE) RETURN VARCHAR2
IS

  l_document_type        PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE;
  l_api_name  CONSTANT   VARCHAR2(30) := 'get_notif_preference_1';

BEGIN

	IF (g_fnd_debug = 'Y') THEN
	  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        	FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'BEGIN: Check WF preference for'
						|| p_wf_message_name || ' for auction '
                                    		|| p_auction_id);
	  END IF;
	END IF;


	SELECT 	docTypes.DOCTYPE_GROUP_NAME
          INTO  l_document_type
	FROM   	PON_AUCTION_HEADERS_ALL   auctionHdr,
		PON_AUC_DOCTYPES          docTypes
	WHERE   auctionHdr.AUCTION_HEADER_ID = p_auction_id
   	AND	auctionHdr.DOCTYPE_ID = docTypes.DOCTYPE_ID;

	--SLM UI Enhancement
  RETURN GET_NOTIF_PREFERENCE(p_wf_message_name, l_document_type, PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_id));

	EXCEPTION
            --
            -- Exception can come if the auction_header_id or the doctype
            -- data is missing or the GET_NOTIF_PREFERENCE call returns
            -- error. In all these cases it should raise the error as
            -- this is an unnatural event
            --
            WHEN OTHERS THEN
		IF (g_fnd_debug = 'Y') THEN
		  IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level  => FND_LOG.level_exception,
			       		module    => g_module_prefix || l_api_name,
			       		message   => 'EXCEPTION: Check WF preference for'
						|| p_wf_message_name || ' for auction '
                                    		|| p_auction_id);
		  END IF;
		END IF;
		RAISE;

END GET_NOTIF_PREFERENCE;


/*==============================================================================================
 PROCEDURE : GET_NOTIF_PREFERENCE   PUBLIC
   PARAMETERS:
	p_wf_message_name	IN	workflow message name of current notification
	p_doctype               IN	document type group name of current negotiation

   COMMENT   :  this function was introduced as a part of the notification
		subscriptions project in release-12. This function should be
		invoked in order to determine whether we need to send a particular
		notification to the buyer or supplier user. The UI to set the notification
		preferences can be viewed or modified by accessing the page via Sourcing
		Admin home page

   ==============================================================================================*/


FUNCTION GET_NOTIF_PREFERENCE (
    	p_wf_message_name IN	WF_MESSAGES.NAME%TYPE,
       	p_doctype         IN 	PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE,
        p_is_slm_doc    IN  VARCHAR2) --SLM UI Enhancement
RETURN VARCHAR2
IS

l_notif_pref VARCHAR2(3);
l_api_name  CONSTANT   VARCHAR2(30) := 'get_notif_preference_2';
l_yes CONSTANT VARCHAR2(2) := 'Y';
l_no CONSTANT VARCHAR2(2) := 'N';

BEGIN

	IF (g_fnd_debug = 'Y') THEN
	  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

        	FND_LOG.string(log_level => FND_LOG.level_statement,
		               module    => g_module_prefix || l_api_name,
			       message   => 'BEGIN: Check WF preference for'
						||  p_wf_message_name || ' for doctype '
                                    		||  p_doctype);
  	  END IF;
	END IF;

  --SLM UI Enhancement : for slm assessments, check SLM_SUBSCRIPTION_FLAG
	SELECT DECODE(P_DOCTYPE,SRC_AUCTION, notifGroups.AUCTION_SUBSCRIPTION_FLAG,
		            	SRC_RFQ,    notifGroups.RFQ_SUBSCRIPTION_FLAG,
                      	    	SRC_RFI,
                              Decode(p_is_slm_doc, 'Y',notifGroups.SLM_SUBSCRIPTION_FLAG , notifGroups.RFI_SUBSCRIPTION_FLAG),
                      		l_yes)
   	INTO 	l_notif_pref
	FROM 	PON_NOTIF_SUBSCRIPTION_GROUPS 	notifGroups,
        	PON_NOTIF_GROUP_MEMBERS 	notifMessages
    	WHERE
		notifGroups.NOTIF_GROUP_CODE 	=  notifMessages.NOTIF_GROUP_CODE
    	AND	notifMessages.NOTIF_MESSAGE_NAME = P_WF_MESSAGE_NAME;


	IF (g_fnd_debug = 'Y') THEN
	  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        	FND_LOG.string(log_level => FND_LOG.level_statement,
		               module    => g_module_prefix || l_api_name,
			       message   => 'BEGIN: Check WF preference for'
						|| p_wf_message_name || ' for doctype  '
                                    		|| p_doctype || ' with return value '
						|| l_notif_pref);
  	  END IF;
	END IF;

        IF l_notif_pref = 'Y' THEN
           l_notif_pref := l_yes;
        ELSE
           l_notif_pref := l_no;
        END IF;

        RETURN l_notif_pref;

	EXCEPTION
            WHEN NO_DATA_FOUND THEN
                --
                -- If there is no subscription for a message name then
                -- the member data can be missing or it can be for some
                -- not to be subscribed message. Hence, return true i.e.
                -- the older behavior
                --
                IF (g_fnd_debug = 'Y') THEN
                  IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(log_level  => FND_LOG.level_exception,
                                        module    => g_module_prefix || l_api_name,
                                        message   => 'EXCEPTION: NO DATA FOUND for message name:'
                                                || p_wf_message_name || ' for doctype '
                                                || p_doctype);
                  END IF;
                END IF;
                RETURN l_yes;

           WHEN OTHERS THEN
                --
                -- Chances are rare but if any such error happens then it will simply
                -- raise the error to the upper level
                --
		IF (g_fnd_debug = 'Y') THEN
		  IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
		        FND_LOG.string(log_level => FND_LOG.level_exception,
			               module    => g_module_prefix || l_api_name,
				       message   => 'EXCEPTION:Check WF preference for '
                                	    || P_WF_MESSAGE_NAME
	                                    || ' for doctype  '
        	                            || p_doctype);
		   END IF;
		END IF;
		RAISE;

END GET_NOTIF_PREFERENCE;


    /*
         Function: get_base_external_supplier_url
         Parameters: None
         Returns:  the base external supplier url
         Sample output: http://server01:4761/
    */

        FUNCTION get_base_external_supplier_url RETURN VARCHAR2 IS

        l_def_ext_user_resp VARCHAR2(240);
        l_application_id NUMBER;
        l_responsibility_id NUMBER;
        l_ext_fwk_agent  VARCHAR2(240);

        -- First try to get the Sourcing External Framework Agent.
        -- If not set, then get the responsibility associated with the
        -- 'Sourcing Default Responsibility for External User' profile option
        BEGIN
        --
        -- Access the Sourcing external APPS_FRAMEWORK_AGENT
        --
        l_ext_fwk_agent := FND_PROFILE.value('PON_EXT_APPS_FRAMEWORK_AGENT');
        --
        -- If the profile is not set, then try the default responsibility approach
        --
        IF (l_ext_fwk_agent IS NULL) THEN
          --
          l_def_ext_user_resp := FND_PROFILE.value('PON_DEFAULT_EXT_USER_RESP');
          --
          IF (l_def_ext_user_resp IS NOT NULL) THEN
            --
            -- get the value of 'APPS_FRAMEWORK_AGENT' profile  at this responsibility level
            --
            BEGIN
              SELECT application_id, responsibility_id
              INTO   l_application_id, l_responsibility_id
              FROM   fnd_responsibility
              WHERE  responsibility_key = l_def_ext_user_resp
              AND    (end_date IS NULL OR end_date > sysdate);
              --
              l_ext_fwk_agent := FND_PROFILE.value_specific(
                                  name => 'APPS_FRAMEWORK_AGENT',
                                  responsibility_id => l_responsibility_id,
                                  application_id => l_application_id );
              --
            EXCEPTION
              WHEN OTHERS THEN
                l_ext_fwk_agent := null;
            END;
          END IF;
        END IF;
        --
        -- If still NULL, fall back to APPS_FRAMEWORK_AGENT
        --
        IF (l_ext_fwk_agent IS NULL) THEN
           l_ext_fwk_agent := FND_PROFILE.value('APPS_FRAMEWORK_AGENT');
        END IF;

        RETURN l_ext_fwk_agent;

EXCEPTION
WHEN OTHERS THEN
     RETURN '';
END get_base_external_supplier_url;


FUNCTION get_site_level_profile_value(p_profile_name varchar2) RETURN VARCHAR2 IS

       l_level_id NUMBER;
       l_profile_value varchar2(240);

       -- this cursor fetches profile option values
       cursor profile_value(p_name varchar2, a_id number, l_id number, l_val number) is
         select fpov.profile_option_value
                 from fnd_profile_options fpo,
                          fnd_profile_option_values fpov
                 where   fpo.profile_option_name = p_name
         and  fpo.start_date_active  <= sysdate
         and  nvl(fpo.end_date_active, sysdate) >= sysdate
                 and  fpo.profile_option_id=fpov.profile_option_id
                 and  fpov.application_id=a_id
                 and fpov.level_id=l_id
                 and fpov.level_value=l_val
                 and fpov.profile_option_value is not null;

        BEGIN

            l_level_id := 10001;
            open profile_value(p_profile_name,0,l_level_id,0);
            fetch profile_value into l_profile_value;

            if (profile_value%NOTFOUND) then
               l_profile_value := NULL;
            end if; -- value_uas%NOTFOUND

            close profile_value;

        RETURN l_profile_value;

EXCEPTION
WHEN OTHERS THEN
     RETURN NULL;
END get_site_level_profile_value;

/*
    Function: get_base_internal_buyer_url
    Parameters: None
    Returns:  the base internal buyer url
    Sample output: http://server01:4761/
*/

FUNCTION get_base_internal_buyer_url RETURN VARCHAR2 IS
         l_base_url VARCHAR2(240) := '';
         l_api_name  CONSTANT   VARCHAR2(30) := 'get_base_internal_buyer_url';
	BEGIN
	   -- Bug:6261134. Due to DMZ issue, we need to make sure that Buyer's URL come from internal website. Since Site level Profile always maintain the internal URL, so we get the site level profile first.
	   l_base_url := get_site_level_profile_value('APPS_FRAMEWORK_AGENT');

	   IF (g_fnd_debug = 'Y') THEN
	      	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'After calling get_site_level_profile_value. l_base_url='
						|| l_base_url);
	  	END IF;
	   END IF;

	   IF (l_base_url is  null) then
                l_base_url :=  FND_PROFILE.value('APPS_FRAMEWORK_AGENT');
	        IF (g_fnd_debug = 'Y') THEN
	  	   IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        	     	FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'get_site_level_profile return NULL. After calling FND_PROFILE.value(); l_base_url='
						|| l_base_url);
	  	   END IF;
	        END IF;

           END IF;

	   RETURN l_base_url;

END get_base_internal_buyer_url;

-- Bug#16690413 API to check the org access of the user

PROCEDURE check_org_access(p_auction_header_id NUMBER,
                          p_dest_page VARCHAR2,
                          x_has_access	OUT NOCOPY VARCHAR2 ,
                          x_org_id	OUT NOCOPY NUMBER) IS
CURSOR c_resp_rec(l_function_name varchar2)
  IS
   SELECT DISTINCT
         r.RESPONSIBILITY_id ,urg.RESPONSIBILITY_APPLICATION_ID
FROM fnd_compiled_menu_functions cmf
, fnd_form_functions ff
, fnd_responsibility r
, fnd_user_resp_groups urg
, fnd_user u
WHERE cmf.function_id = ff.function_id
AND r.menu_id = cmf.menu_id
AND urg.responsibility_id = r.responsibility_id
AND cmf.GRANT_FLAG='Y'
and r.APPLICATION_ID=urg.RESPONSIBILITY_APPLICATION_ID
AND u.user_id = urg.user_id
and ff.function_name=l_function_name
AND u.user_id = fnd_global.user_id;


  l_user_id fnd_user.user_id%type;
  l_resp_id fnd_responsibility.responsibility_id%type;
  l_appl_id fnd_application.application_id%type;
  l_appl_short_name fnd_application_vl.application_short_name%type;
  l_ou_value fnd_profile_option_values.profile_option_value%type;
  l_sp_value fnd_profile_option_values.profile_option_value%type;
  l_resp_rec c_resp_rec%ROWTYPE;
  l_api_name  CONSTANT   VARCHAR2(30) := 'check_org_access';
  l_has_access	VARCHAR2(1) ;



BEGIN


l_user_id:= fnd_global.user_id;


SELECT org_id INTO x_org_id FROM pon_auction_headers_all
WHERE auction_header_id = p_auction_header_id;


OPEN c_resp_rec(p_dest_page);
  LOOP
    FETCH c_resp_rec INTO l_resp_rec;
    EXIT
  WHEN c_resp_rec%NOTFOUND;

BEGIN

l_resp_id:= l_resp_rec.RESPONSIBILITY_id;
l_appl_id:=  l_resp_rec.RESPONSIBILITY_APPLICATION_ID;


select application_short_name into l_appl_short_name
from fnd_application_vl
where application_id = l_appl_id;


l_ou_value := fnd_profile.value_specific(
  'ORG_ID',l_user_id, l_resp_id, l_appl_id);
l_sp_value := fnd_profile.value_specific(
  'XLA_MO_SECURITY_PROFILE_LEVEL', l_user_id, l_resp_id, l_appl_id);

IF (g_fnd_debug = 'Y') THEN
	      	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'Responsibility Id '||l_resp_rec.RESPONSIBILITY_ID || ','||'MO: Operating Unit: '||l_ou_value ||','|| 'MO: Security Profile: '||l_sp_value);
	  	END IF;
	   END IF;


if l_sp_value is null and l_ou_value is null THEN
x_has_access:='N';
else
 /*begin
  select DISTINCT 'Y' INTO l_has_access FROM dual
  WHERE
  x_org_id = l_ou_value
 OR ( EXISTS ( SELECT 1
  from PER_SECURITY_PROFILES psp,
       PER_SECURITY_ORGANIZATIONS pso
 where pso.SECURITY_PROFILE_ID = psp.SECURITY_PROFILE_ID
 AND psp.SECURITY_PROFILE_ID = l_sp_value
 AND x_org_id IN (pso.ORGANIZATION_ID) ));
 EXCEPTION
 WHEN OTHERS THEN
 l_has_access := 'N';
 END;*/
 --Bug 18642927
 --We should not directly query the table
 --Instead the mo_global API should be used to check org access
 BEGIN
          fnd_global.APPS_INITIALIZE (l_user_id, l_resp_id,l_appl_id);
            mo_global.init('PON');
            SELECT mo_global.check_access(x_org_id) INTO l_has_access FROM dual;

            IF (g_fnd_debug = 'Y') THEN
    	      	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'l_has_access =>' || l_has_access);
	          	END IF;
	          END IF;

        EXCEPTION
        WHEN OTHERS THEN
          l_has_access := 'N';
        END;
end if;


IF(l_has_access = 'Y') THEN
x_has_access:='Y';
 CLOSE c_resp_rec;
RETURN;
END IF;


exception when others THEN
x_has_access:='N';
   END;
   END LOOP;

CLOSE c_resp_rec;


END check_org_access;

/*=======================================================================+
 | FILENAME
 |  PONWFUTB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package: PON_WF_UTL_PKG
 |
 | NOTES
 | CREATE
 | MODIFIED
 *=====================================================================*/

procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2) is

l_api_name  CONSTANT   VARCHAR2(30) := 'PON_WF_UTL_PKG.SetItemAttrText';
BEGIN

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => aname,
                                 avalue   => avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_fnd_debug = 'Y') THEN
	      	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'Error in SetItemAttrText when setting attribute '||aname);
	  	    END IF;
	   END IF;

END SetItemAttrText;

function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return varchar2 IS

l_api_name  CONSTANT   VARCHAR2(30) := 'PON_WF_UTL_PKG.GetItemAttrText';

BEGIN

  return wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_fnd_debug = 'Y') THEN
	      	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'Error in GetItemAttrText when getting attribute '||aname);
	  	    END IF;
	   END IF;
     return NULL;

END GetItemAttrText;


/* This api sets the notification attribute  */
PROCEDURE SetNotifAttrText(nid in number,
                           aname in varchar2,
                           avalue in varchar2)
IS
 l_api_name  CONSTANT   VARCHAR2(30) := 'PON_WF_UTL_PKG.SetNotifAttrText';
BEGIN
    wf_notification.SetAttrText(nid, aname, avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_fnd_debug = 'Y') THEN
	      	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        		FND_LOG.string(log_level => FND_LOG.level_statement,
			       module    => g_module_prefix || l_api_name,
			       message   => 'Error in SetNotifAttrText when setting attribute '||aname);
	  	    END IF;
	   END IF;

END SetNotifAttrText;

END PON_WF_UTL_PKG;

/
